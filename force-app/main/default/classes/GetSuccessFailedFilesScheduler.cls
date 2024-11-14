/**
 * @description       : Scheduler and Batch class to get and upload success and failure files for CTB statement processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 11-14-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class GetSuccessFailedFilesScheduler implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Document_Storage__c> docStorageToUpdateList = new List<Document_Storage__c>();
    public Map<String, List<ContentVersion>> docStorageIdConVersionToInsertMap = new Map<String, List<ContentVersion>>();
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new GetSuccessFailedFilesScheduler());
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Document_Name__c, Bulk_API_Job_ID__c, Comment__c, (Select Insolvency_Account__c, Insolvency_Account__r.CTB_Statements_Received_Date__c From Document_Storages__r Where Insolvency_Account__c != null) From Document_Storage__c WHERE CreatedDate = TODAY AND Document_Extension__c = \'zip\' AND Statement_Processing_Status__c = \'Processing\''
        );
    }

    public void execute(Database.BatchableContext bc, List<Document_Storage__c> docStorageList) {
        try {
            startProcessing(docStorageList);
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in GetSuccessFailedFilesScheduler ' + ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!docStorageToUpdateList.isEmpty()) {
            try {
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                Database.update(docStorageToUpdateList);
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
                // Queue job to do API callout
                System.enqueueJob(new CTBApiCalloutsQueueable(docStorageIdConVersionToInsertMap));
            } catch (DmlException ex) {
                System.debug('DMLException in GetSuccessFailedFilesScheduler ' + ex.getDmlMessage(0));
                CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            }
        }
    }

    /**
     * @description : Method to check Bulk API job status and get result CSVs
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param docStorageList
     **/
    public void startProcessing(List<Document_Storage__c> docStorageList) {
        Map<String, Insolvency_Account__c> uniqueAccountsToUpdateMap = new Map<String, Insolvency_Account__c>();
        Map<String, String> mapSkippedFileNameDocStorageId = new Map<String, String>();
        List<ContentVersion> conVersionToInsertList = new List<ContentVersion>();
        Integer successRecordsCount = 0;
        Integer failedRecordsCount = 0;
        for (Document_Storage__c doc : docStorageList) {
            if (String.isBlank(doc.Bulk_API_Job_ID__c)) {
                continue;
            }
            if (!doc.Document_Storages__r.isEmpty()) {
                uniqueAccountsToUpdateMap = updateStatementIdentifier(doc.Document_Storages__r, uniqueAccountsToUpdateMap);
            }
            List<ContentVersion> conVersionToInsertListPerDocStorage = new List<ContentVersion>();
            mapSkippedFileNameDocStorageId.put('Skipped' + '_' + doc.Document_Name__c.remove('.zip'), doc.Id);
            String bulkJobStatus = getJobStatus(doc.Bulk_API_Job_ID__c);
            if (bulkJobStatus == 'JobComplete') {
                doc.Statement_Processing_Status__c = 'Processed';
                String successCsv = getresultCsv(doc.Bulk_API_Job_ID__c, 'successfulResults');
                successRecordsCount = successCsv.split(ProcessStatementZipFilesBatch.lineBreak).size() - 1;
                // Generate success file if returned csv contains mroe than 2 rows(including header)
                if (successRecordsCount > 0) {
                    ContentVersion successCv = createConVersion('Success', doc.Document_Name__c, successCsv);
                    conVersionToInsertList.add(successCv);
                    conVersionToInsertListPerDocStorage.add(successCv);
                } else {
                    // If status is jobcomplete but no success records were returned, check and generate failed file
                    doc.Statement_Processing_Status__c = 'Failed';
                    String failedCsv = getresultCsv(doc.Bulk_API_Job_ID__c, 'failedResults');
                    failedRecordsCount = failedCsv.split(ProcessStatementZipFilesBatch.lineBreak).size() - 1;
                    if (failedRecordsCount > 0) {
                        ContentVersion failedCv = createConVersion('Failed', doc.Document_Name__c, failedCsv);
                        conVersionToInsertList.add(failedCv);
                        conVersionToInsertListPerDocStorage.add(failedCv);
                    }
                }
            } else if (bulkJobStatus == 'Failed') {
                String failedCsv = getresultCsv(doc.Bulk_API_Job_ID__c, 'failedResults');
                failedRecordsCount = failedCsv.split(ProcessStatementZipFilesBatch.lineBreak).size() - 1;
                if (failedRecordsCount > 0) {
                    ContentVersion failedCv = createConVersion('Failed', doc.Document_Name__c, failedCsv);
                    conVersionToInsertList.add(failedCv);
                    conVersionToInsertListPerDocStorage.add(failedCv);
                }
            } else {
                doc.Statement_Processing_Status__c = 'Failed';
            }
            doc.Comment__c =
                doc.Comment__c +
                ProcessStatementZipFilesBatch.lineBreak +
                'Success Records : ' +
                successRecordsCount +
                ProcessStatementZipFilesBatch.lineBreak +
                'Failed Records : ' +
                failedRecordsCount;
            docStorageToUpdateList.add(doc);
            docStorageIdConVersionToInsertMap.put(doc.Id, conVersionToInsertListPerDocStorage);
        }
        try {
            if (!conVersionToInsertList.isEmpty()) {
                Database.insert(conVersionToInsertList);
            }
            if (!uniqueAccountsToUpdateMap.values().isEmpty()) {
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
                Database.update(uniqueAccountsToUpdateMap.values());
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            }
        } catch (DmlException ex) {
            System.debug('DMLException in GetSuccessFailedFilesScheduler ' + ex.getDmlMessage(0));
            CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
        }
        // Check for skipped csv
        for (ContentVersion skippedConVer : [
            SELECT Id, PathOnClient, Title
            FROM ContentVersion
            WHERE Title IN :mapSkippedFileNameDocStorageId.keySet()
        ]) {
            docStorageIdConVersionToInsertMap.get(mapSkippedFileNameDocStorageId.get(skippedConVer.Title)).add(skippedConVer);
        }
    }

    /**
     * @description : Method to check statement received checkbox for accounts who got statements attached
     * @author adeshi@a5econsulting.net | 09-06-2024
     * @param statementDocStorageList
     * @param uniqueAccountsToUpdateMap
     * @return Map<String, Insolvency_Account__c>
     **/
    public static Map<String, Insolvency_Account__c> updateStatementIdentifier(
        List<Document_Storage__c> statementDocStorageList,
        Map<String, Insolvency_Account__c> uniqueAccountsToUpdateMap
    ) {
        for (Document_Storage__c statementDoc : statementDocStorageList) {
            Insolvency_Account__c account = new Insolvency_Account__c(Id = statementDoc.Insolvency_Account__c, CTB_Statements_Received__c = true);
            // Update statements received date with today's date only for accounts which don't have this field already populated
            if (statementDoc.Insolvency_Account__r.CTB_Statements_Received_Date__c == null) {
                account.CTB_Statements_Received_Date__c = System.today();
            }
            uniqueAccountsToUpdateMap.put(statementDoc.Insolvency_Account__c, account);
        }
        return uniqueAccountsToUpdateMap;
    }

    /**
     * @description : Method to upload CSV file to respective dated folder in Azure
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param cvId
     * @param fileName
     **/
    public static void uploadFile(String cvId, String fileName) {
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint =
            apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy') +
            'sobjects/' +
            cvId +
            '/' +
            GetZipFilesListQueueable.API_TYPE_PARAMETER +
            '?name=' +
            EncodingUtil.urlEncode(Datetime.now().format('yyyyMMdd') + '/' + fileName, 'UTF-8');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() != 200) {
                CTBGetFileApiQueueable.createApiError(String.valueOf(res.getStatusCode()), res.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getFileList ' + ex.getStackTraceString());
        }
    }

    /**
     * @description : Method to create content version with given info
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param fileName
     * @param csvString
     * @return ContentVersion
     **/
    public static ContentVersion createConVersion(String prefix, String fileName, String csvString) {
        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof(csvString);
        contentVersionData.Title = prefix + '_' + fileName.remove('.zip');
        contentVersionData.PathOnClient = contentVersionData.Title + '.csv';
        return contentVersionData;
    }

    /**
     * @description : Method to get Bulk API job status
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param jobId
     * @return String
     **/
    public static String getJobStatus(String jobId) {
        String jobStatus = '';
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/' + jobId);
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        Http h = new Http();
        try {
            HttpResponse resp = h.send(request);
            if (resp.getStatusCode() <= 299) {
                Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(resp.getBody());
                jobStatus = (String) respMap.get('state');
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(resp.getStatusCode()), resp.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getJobStatus ' + ex.getStackTraceString());
        }
        return jobStatus;
    }

    /**
     * @description : Method to get result CSVs once Bulk API job is completed
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param jobId
     * @param resultType
     * @return String
     **/
    public static String getresultCsv(String jobId, String resultType) {
        String resultCsv = '';
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(URl.getOrgDomainUrl().toExternalForm() + '/services/data/v60.0/jobs/ingest/' + jobId + '/' + resultType);
        request.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());
        Http h = new Http();
        try {
            HttpResponse resp = h.send(request);
            if (resp.getStatusCode() <= 299) {
                resultCsv = resp.getBody();
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(resp.getStatusCode()), resp.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getresultCsv ' + ex.getStackTraceString());
        }
        return resultCsv;
    }
}
