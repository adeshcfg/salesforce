/**
 * @description       : Queueable class to get file list and store other API callout methods for incoming file
 * @author            : adesh.ikhar@canaccede.com
 * @group             :
 * @last modified on  : 06-06-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CTBGetFileApiQueueable implements Queueable, Database.AllowsCallouts {
    public static final String API_TYPE_PARAMETER = 'incoming_decrypted';
    public static final String FILE_TYPE_PARAMETER = 'csv';
    public void execute(QueueableContext context) {
        // Call API to get the list of files
        List<String> fileNameList = getFileList(API_TYPE_PARAMETER, FILE_TYPE_PARAMETER);
        if (!fileNameList.isEmpty()) {
            for (Document_Storage__c doc : [SELECT Id, Document_Name__c FROM Document_Storage__c WHERE Document_Name__c IN :fileNameList]) {
                // Check if we already have document storage record for any file
                if (fileNameList.contains(doc.Document_Name__c)) {
                    // Remove the file name if we already have a document storage record
                    fileNameList.remove(fileNameList.indexOf(doc.Document_Name__c));
                }
            }
        }
        // Enqueue the file processing class
        if (!fileNameList.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new CTBFileProcessingQueueable(fileNameList, System.Label.CTB_Insolvency_Account));
        } else {
            CTBFileValidationUtility.sendEmail(
                'Account files processing status : No files processed',
                'No files were found on the server to process or all the files are already processed for today'
            );
        }
    }

    /**
     * @description : Method to call API and get list of files from SFTP
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @return List<String>
     **/
    public static List<String> getFileList(String type, String fileType) {
        List<String> fileNameList = new List<String>();
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint = apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy') + 'types/' + type + '?filter=' + Datetime.now().format('yyyyMMdd');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200) {
                FileListWrapper fileList = (FileListWrapper) System.JSON.deserialize(res.getBody(), FileListWrapper.class);
                if (fileList.files != null && !fileList.files.isEmpty()) {
                    for (String fileName : fileList.files) {
                        // Only add csv files in the list
                        if (fileName.substring(fileName.length() - 3, fileName.length()) == fileType) {
                            // Get only the file name from the file path and remove file extension
                            fileNameList.add(fileName.substringAfterLast('/'));
                        }
                    }
                }
            } else {
                createApiError(String.valueOf(res.getStatusCode()), res.getBody());
            }
        } catch (Exception ex) {
            createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getFileList ' + ex.getStackTraceString());
        }
        return fileNameList;
    }

    /**
     * @description : Method to get specific file uploaded in SF from SFTP
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @param fileName
     * @return String
     **/
    public static String getDocumentId(String fileName) {
        String documentId = '';
        Folder downloadFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String filePath = Datetime.now().format('yyyyMMdd') + '/' + filename;
        String endpoint =
            apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy') +
            'sobjects/folders/' +
            downloadFolder.Id +
            '?type=' +
            API_TYPE_PARAMETER +
            '&name=' +
            EncodingUtil.urlEncode(filePath, 'UTF-8');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 200) {
                DocumentAPIClientUtil.ReverseProxyAPI parsedResponse = new DocumentAPIClientUtil.ReverseProxyAPI();
                parsedResponse = (DocumentAPIClientUtil.ReverseProxyAPI) System.JSON.deserialize(res.getBody(), DocumentAPIClientUtil.ReverseProxyAPI.class);
                documentId = parsedResponse.data.id;
            } else {
                createApiError(String.valueOf(res.getStatusCode()), res.getBody());
            }
        } catch (Exception ex) {
            createApiError(ex.getMessage(), ex.getStackTraceString());
            System.debug('Exception in getContentVersionId ' + ex.getStackTraceString());
        }
        return documentId;
    }

    // Wrapper class for file list API response
    public class FileListWrapper {
        public boolean hasMore;
        public List<String> files;
    }

    /**
     * @description : Method to create API Error record
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @param exceptionMsg
     * @param stackTraceString
     **/
    public static void createApiError(String exceptionMsg, String stackTraceString) {
        API_Error__c apiError = new API_Error__c(Action__c = 'API Failed', Error__c = exceptionMsg + stackTraceString);
        insert apiError;
        CTBFileValidationUtility.sendEmail('CTB Account file processing failed', 'API Failed with error - ' + apiError.Error__c);
    }
}
