public class ProcessStatementZipFilesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    public Boolean reRunGetStatements = false;
    public List<Document_Storage__c> docStorageToUpdateList = new List<Document_Storage__c>();
    public static Map<String, Document_Storage__c> mapDocumentIdDocStorage = new Map<String, Document_Storage__c>();
    public static String lineBreak = '\n';
    public static String bulkUploadHeader = 'Document_Name__c,Document_URL__c,Document_Type__c,Document_Extension__c,Statement_Processing_Status__c,Document_Related_To__c, Insolvency_Account_ID__c,Uploaded_By__c,Creator__c,Visibility__c';

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Token_ID__c From Document_Storage__c WHERE (Statement_Processing_Status__c = \'In Progress\' OR Statement_Processing_Status__c = \'Pending Process\')'
        );
    }

    public void execute(Database.BatchableContext bc, List<Document_Storage__c> docStorageList) {
        try {
            startProcessing(docStorageList);
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in ProcessStatementZipFilesBatch ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!docStorageToUpdateList.isEmpty()) {
            try {
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                Database.update(docStorageToUpdateList);
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            } catch (DmlException ex) {
                System.debug('DMLException in ProcessStatementZipFilesBatch ' + ex.getDmlMessage(0));
                CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            }
        }
        try {
            finishHelper();
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in ProcessStatementZipFilesBatch ' + ex.getStackTraceString());
        }
    }

    public void finishHelper() {
        List<SObject> recordsToUpdate = new List<SObject>();
        Statement_Processing_Settings__c stmtProcessingSettings = Statement_Processing_Settings__c.getInstance('Canadian Tire');
        stmtProcessingSettings.Number_of_Statements_Attempts__c = stmtProcessingSettings.Number_of_Statements_Attempts__c + 1;
        if (reRunGetStatements && stmtProcessingSettings.Number_of_Statements_Attempts__c < stmtProcessingSettings.Max_Limit_of_Statements_Attempts__c) {
            recordsToUpdate.add(stmtProcessingSettings);
            Database.update(recordsToUpdate);
            System.scheduleBatch(new ProcessStatementZipFilesBatch(), 'ProcessStatementZipFilesBatch', 15);
        } else {
            for (Document_Storage__c doc : [
                SELECT Id
                FROM Document_Storage__c
                WHERE Statement_Processing_Status__c = 'Pending Process' OR Statement_Processing_Status__c = 'In Progress'
            ]) {
                doc.Statement_Processing_Status__c = 'Failed';
                recordsToUpdate.add(doc);
            }
            if (!recordsToUpdate.isEmpty()) {
                try {
                    DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                    Database.update(recordsToUpdate);
                    DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
                } catch (DmlException ex) {
                    System.debug('DMLException in ProcessStatementZipFilesBatch ' + ex.getDmlMessage(0));
                    CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
                }
            }
        }
    }

    public void startProcessing(List<Document_Storage__c> docStorageList) {
        for (Document_Storage__c doc : docStorageList) {
            Map<String, String> statusDocumentIdMap = getStatementsDocId(doc.Token_ID__c);
            if (statusDocumentIdMap == null) {
                reRunGetStatements = true;
                return;
            }
            if (!statusDocumentIdMap.containsKey('documentId')) {
                doc.Statement_Processing_Status__c = statusDocumentIdMap.get('status');
                docStorageToUpdateList.add(doc);
                reRunGetStatements = true;
                continue;
            }
            mapDocumentIdDocStorage.put(statusDocumentIdMap.get('documentId'), doc);
        }
        if (mapDocumentIdDocStorage != null) {
            startBulkApiJob(mapDocumentIdDocStorage);
        }
    }

    public void startBulkApiJob(Map<String, Document_Storage__c> mapDocumentIdDocStorage) {
        Map<String, Document> idDocumentMap = new Map<String, Document>([SELECT Name, Body FROM Document WHERE Id IN :mapDocumentIdDocStorage.keySet()]);
        Map<String, String> correlationIdAccountIdMap = getCorrelationIdAccountMap(mapDocumentIdDocStorage.keySet());
        for (String docId : mapDocumentIdDocStorage.keySet()) {
            List<FileInfo> fileInfoList = createWrapperList(idDocumentMap.get(docId).Body.toString(), correlationIdAccountIdMap);
            String bulkUploadCsv = createBulkUploadCsv(fileInfoList);
            String jobId = createIngestionJob();
            uploadData(jobId, bulkUploadCsv);
            mapDocumentIdDocStorage.get(docId).Bulk_API_Job_ID__c = jobId;
            mapDocumentIdDocStorage.get(docId).Statement_Processing_Status__c = 'Processing';
            docStorageToUpdateList.add(mapDocumentIdDocStorage.get(docId));
        }
    }

    public static Map<String, String> getStatementsDocId(String tokenId) {
        Map<String, String> statusDocumentIdMap = new Map<String, String>();
        // Folder downloadFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint = apiCallDetails.PDF_API_URL__c.replace('Document', 'Background') + 'jobs/' + tokenId;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '2');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 201) {
                // To do : update after getting the actual reponse
                Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(res.getBody());
            } else if (res.getStatusCode() == 204) {
                statusDocumentIdMap.put('status', 'Pending Process');
            } else if (res.getStatusCode() == 500) {
                statusDocumentIdMap.put('status', 'Failed');
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(res.getStatusCode()), res.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getTokenId ' + ex.getStackTraceString());
        }
        return statusDocumentIdMap;
    }

    public static Map<String, String> getCorrelationIdAccountMap(Set<String> documentIds) {
        Map<String, String> correlationIdAccountIdMap = new Map<String, String>();
        Set<String> correlationIds = new Set<String>();
        List<Document> filesToProcess = [SELECT Name, Body FROM Document WHERE Id IN :documentIds];
        for (Document fileToProccess : filesToProcess) {
            String csvContents = fileToProccess.Body.toString();
            List<String> csvRows = csvContents.split('\n');
            if (csvRows.isEmpty()) {
                continue;
            }
            for (Integer i = 0; i < csvRows.size(); i++) {
                // Split the current row into columns
                List<String> csvColumns = CTBFileValidationUtility.parseCsv(csvRows[i]);
                // To do : get sample csv and map correlation id
                correlationIds.add(csvColumns[0].substring(0, 15));
            }
        }
        for (Insolvency_Account__c acc : [SELECT Id, Correlation_Id__c FROM Insolvency_Account__c WHERE Correlation_Id__c IN :correlationIds]) {
            correlationIdAccountIdMap.put(acc.Correlation_Id__c, acc.Id);
        }
        return correlationIdAccountIdMap;
    }

    public static List<FileInfo> createWrapperList(String csvContents, Map<String, String> correlationIdAccountIdMap) {
        List<FileInfo> fileInfoList = new List<FileInfo>();
        List<String> csvRows = csvContents.split('\n');
        if (csvRows.isEmpty()) {
            return fileInfoList;
        }
        for (Integer i = 0; i < csvRows.size(); i++) {
            // Split the current row into columns
            List<String> csvColumns = CTBFileValidationUtility.parseCsv(csvRows[i]);
            // To do : get sample csv and map all fields to fileinfo wrapper
            fileInfoList.add(new FileInfo(csvColumns[0], csvColumns[0] + csvColumns[1], correlationIdAccountIdMap.get(csvColumns[0].substring(0, 15))));
        }
        return fileInfoList;
    }

    public static String createBulkUploadCsv(List<FileInfo> fileInfoList) {
        String detailRow = '';
        for (FileInfo info : fileInfoList) {
            detailRow +=
                '\n' +
                info.docName +
                info.docUrl +
                'CTB Statements' +
                'pdf' +
                'Processed' +
                'Insolvency Account' +
                info.accId +
                'System' +
                'System' +
                'CFG only';
        }
        return bulkUploadHeader + detailRow;
    }

    public static String createIngestionJob() {
        String jobId = '';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest');
        request.setHeader('content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        String body = '{' + '"operation": "insert",' + '"object": "Document_Storage__c"",' + '}';
        request.setBody(body);
        Http h = new Http();
        try {
            HttpResponse resp = h.send(request);
            if (resp.getStatusCode() <= 299) {
                Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
                jobId = (String) respMap.get('id');
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(resp.getStatusCode()), resp.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getTokenId ' + ex.getStackTraceString());
        }
        return jobId;
    }

    public static void uploadData(String jobId, String csvString) {
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/' + jobId + '/batches');
        request.setHeader('content-type', 'text/csv');
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        request.setBody(csvString);
        Http h = new Http();
        try {
            HttpResponse resp = h.send(request);
            if (resp.getStatusCode() <= 299) {
                updateBulkJobState(jobId);
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(resp.getStatusCode()), resp.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getTokenId ' + ex.getStackTraceString());
        }
    }

    public static void updateBulkJobState(String jobId) {
        HttpRequest request = new HttpRequest();
        request.setMethod('PATCH');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/' + jobId);
        request.setHeader('content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        request.setBody('{ "state" : "UploadComplete" }');
        Http h = new Http();
        try {
            HttpResponse resp = h.send(request);
            if (resp.getStatusCode() <= 299) {
                System.debug('Processing started for JobId ' + jobId);
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(resp.getStatusCode()), resp.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getTokenId ' + ex.getStackTraceString());
        }
    }

    public class FileInfo {
        public String docName { get; set; }
        public String docUrl { get; set; }
        public String accId { get; set; }

        public FileInfo(String docName, String docUrl, String accId) {
            this.docName = docName;
            this.docUrl = docUrl;
            this.accId = accId;
        }
    }
}
