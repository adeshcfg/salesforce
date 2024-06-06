/**
 * @description       : Queueable class to initiate zip file processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 06-06-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class GetZipFilesListQueueable implements Queueable, Database.AllowsCallouts {
    public static final String API_TYPE_PARAMETER = 'ctb_statements';
    public static final String FILE_TYPE_PARAMETER = 'zip';
    public void execute(QueueableContext context) {
        try {
            initializeZipFileProcessing();
        } catch (Exception e) {
            System.debug('Exception in initializeZipFileProcessing ' + e.getStackTraceString());
            CTBFileProcessingQueueable.createInsolvencyError(e.getMessage(), e.getStackTraceString());
        }
    }

    /**
     * @description : Method to start zip file processing
     * @author adesh.ikhar@canaccede.com | 05-28-2024
     **/
    public static void initializeZipFileProcessing() {
        // Call API to get the list of files
        List<String> zipFileList = CTBGetFileApiQueueable.getFileList(API_TYPE_PARAMETER, FILE_TYPE_PARAMETER);
        // Create doc storage record with No files status if no zip files were found on blob storage
        if (zipFileList.isEmpty()) {
            Document_Storage__c docInfo = new Document_Storage__c();
            docInfo.Document_Name__c = Datetime.now().format('yyyyMMdd');
            docInfo.Statement_Processing_Status__c = 'No Files';
            docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
            try {
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                Database.insert(docInfo);
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            } catch (DmlException ex) {
                System.debug('DMLException in createDocStorage ' + ex.getDmlMessage(0));
                CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            }
            return;
        }
        try {
            // Start Zip file processing
            startProcessing(zipFileList);
            // Schedule the next job to process the zip file
            System.scheduleBatch(new ProcessStatementZipFilesBatch(), 'ProcessStatementZipFilesBatch', 15);
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in initializeZipFileProcessing ' + ex.getStackTraceString());
        }
    }

    /**
     * @description : Method to create and return document storage record
     * @author adesh.ikhar@canaccede.com | 05-28-2024
     * @param fileName
     * @param tokenId
     * @return Document_Storage__c
     **/
    public static Document_Storage__c createDocStorage(String fileName, String tokenId) {
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = fileName;
        docInfo.Statement_Processing_Status__c = 'In Progress';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = tokenId;
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        return docInfo;
    }

    /**
     * @description : Method to do API call and create document storage record based on response
     * @author adesh.ikhar@canaccede.com | 05-28-2024
     * @param zipFileList
     **/
    public static void startProcessing(List<String> zipFileList) {
        List<Document_Storage__c> listDocStorageToInsert = new List<Document_Storage__c>();
        for (String fileName : zipFileList) {
            String tokenId = getTokenId(fileName);
            if (String.isBlank(tokenId)) {
                continue;
            }
            listDocStorageToInsert.add(createDocStorage(fileName, tokenId));
        }
        if (!listDocStorageToInsert.isEmpty()) {
            try {
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                Database.insert(listDocStorageToInsert);
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            } catch (DmlException ex) {
                System.debug('DMLException in startProcessing ' + ex.getDmlMessage(0));
                CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            }
        }
    }

    /**
     * @description : Mthod to initiate zip file processing and get token Id
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param fileName
     * @return String
     **/
    public static String getTokenId(String fileName) {
        String tokenId = '';
        Folder downloadFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String filePath = Datetime.now().format('yyyyMMdd') + '/' + filename;
        String endpoint =
            apiCallDetails.PDF_API_URL__c.replace('Document', 'Background') +
            'jobs?type=' +
            API_TYPE_PARAMETER +
            '&location=' +
            EncodingUtil.urlEncode(filePath, 'UTF-8') +
            '&sfFolder=' +
            downloadFolder.Id;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Content-Length', '2');
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 201) {
                Map<String, Object> respMap = (Map<String, Object>) Json.deserializeUntyped(res.getBody());
                tokenId = (String) respMap.get('oid');
            } else {
                CTBGetFileApiQueueable.createApiError(String.valueOf(res.getStatusCode()), res.getBody());
            }
        } catch (Exception ex) {
            CTBGetFileApiQueueable.createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getTokenId ' + ex.getStackTraceString());
        }
        return tokenId;
    }
}
