/**
 * @description       : Queueable class to get file list and store other API callout methods for incoming file
 * @author            : adesh.ikhar@canaccede.com
 * @group             :
 * @last modified on  : 05-07-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CTBGetFileApiQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        // Call API to get the list of files
        List<String> fileNameList = getFileList();
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
        if (!fileNameList.isEmpty()) {
            System.enqueueJob(new CTBFileProcessingQueueable(fileNameList, System.Label.CTB_Insolvency_Account));
        }
    }

    /**
     * @description : Method to call API and get list of files from SFTP
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @return List<String>
     **/
    public static List<String> getFileList() {
        List<String> fileNameList = new List<String>();
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint = apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy') + 'types/ctbsftpinbox?filter=' + Datetime.now().format('yyyyMMdd');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            String statusCode = String.valueOf(res.getStatusCode());
            if (res.getStatusCode() == 200) {
            }
        } catch (Exception ex) {
            System.debug('Exception in getFileList ' + ex.getStackTraceString());
        }
        return fileNameList;
    }

    /**
     * @description : Method to get specific uploaded in SF from SFTP
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @param fileName
     * @return String
     **/
    public static String getContentVersionId(String fileName) {
        String contentVersionId = '';
        Folder downloadFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint =
            apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy') +
            'sobjects/folders/' +
            downloadFolder.Id +
            '?type=ctbsftpinbox&name=' +
            filename;
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
                parsedResponse = (DocumentAPIClientUtil.ReverseProxyAPI) System.JSON.deserialize(
                    parsedResponse.response,
                    DocumentAPIClientUtil.ReverseProxyAPI.class
                );
                contentVersionId = parsedResponse.data.id;
            }
        } catch (Exception ex) {
            System.debug('Exception in getContentVersionId ' + ex.getStackTraceString());
        }
        return contentVersionId;
    }
}
