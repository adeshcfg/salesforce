/**
 * @description       : Scheduler and Batch class to get and upload success and failure files for CTB statement processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 06-06-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class GetSuccessFailedFilesScheduler implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    public static List<Document_Storage__c> docStorageToUpdateList = new List<Document_Storage__c>();
    public static List<ContentVersion> conVersionToInsertList = new List<ContentVersion>();
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new GetSuccessFailedFilesScheduler());
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Document_Name__c, Bulk_API_Job_ID__c From Document_Storage__c WHERE CreatedDate = TODAY AND Document_Type__c = \'zip\' AND Statement_Processing_Status__c = \'Processing\''
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
                System.enqueueJob(new CTBApiCalloutsQueueable(conVersionToInsertList));
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
    public static void startProcessing(List<Document_Storage__c> docStorageList) {
        for (Document_Storage__c doc : docStorageList) {
            if (String.isBlank(doc.Bulk_API_Job_ID__c)) {
                continue;
            }
            String bulkJobStatus = getJobStatus(doc.Bulk_API_Job_ID__c);
            if (bulkJobStatus == 'JobComplete' || bulkJobStatus == 'Failed') {
                String successCsv = getresultCsv(doc.Bulk_API_Job_ID__c, 'successfulResults');
                String failedCsv = getresultCsv(doc.Bulk_API_Job_ID__c, 'failedResults');
                conVersionToInsertList.add(createConVersion(doc.Document_Name__c, successCsv));
                conVersionToInsertList.add(createConVersion(doc.Document_Name__c, failedCsv));
                doc.Statement_Processing_Status__c = 'Processed';
            } else {
                doc.Statement_Processing_Status__c = 'Failed';
            }
            docStorageToUpdateList.add(doc);
        }
        if (!conVersionToInsertList.isEmpty()) {
            try {
                Database.insert(conVersionToInsertList);
            } catch (DmlException ex) {
                System.debug('DMLException in GetSuccessFailedFilesScheduler ' + ex.getDmlMessage(0));
                CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            }
        }
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
            CTBGetFileApiQueueable.API_TYPE_PARAMETER +
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
    public static ContentVersion createConVersion(String fileName, String csvString) {
        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof(csvString);
        contentVersionData.Title = 'Success' + fileName.remove('.zip');
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
