/**
 * @description       : Class to handle Zip File Processing Status API which will be called by Portal
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-26-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@RestResource(urlMapping='/ZipFileProcessor')
global class ZipFileProcessingStatusApi {
    /**
     * @description : Method to finish putback/buyback processing
     * @author adesh.ikhar@canaccede.com | 02-12-2025
     * @return string
     **/
    @HttpPost
    global static String finishProcessing() {
        List<String> productIdList = new List<String>();
        Document_Storage__c zipDocStorage = new Document_Storage__c();
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            String requestString = '';
            String csvContentDocId = '';
            requestString = RestContext.request.requestBody.toString();
            JsonRequest zipFileStatus = (JsonRequest) JSON.deserialize(requestString, JsonRequest.class);
            List<Document_Storage__c> zipDocStorageList = [
                SELECT Id, Comment__c
                FROM Document_storage__c
                WHERE Document_Name__c = :zipFileStatus.docName AND File_Processing_Status__c = 'Pending'
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if (!zipDocStorageList.isEmpty()) {
                zipDocStorage = zipDocStorageList[0];
                List<ContentVersion> csvConVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :zipDocStorage.Comment__c];
                if (!csvConVersion.isEmpty()) {
                    csvContentDocId = csvConVersion[0].ContentDocumentId;
                }
            }
            if (zipFileStatus.status == 'Failed') {
                zipDocStorage.Comment__c = requestString;
                updateDocStorageStatus(zipDocStorage, 'Failed', zipFileStatus.errorMessage);
                CTBFileValidationUtility.sendEmail('Putback/Buyback Zip generation failed', zipFileStatus.errorMessage, System.Label.Putback_Buyback_Email_Ids);
            } else {
                zipDocStorage.Document_URL__c = zipFileStatus.docUrl;
                updateDocStorageStatus(zipDocStorage, 'Processed', requestString);
                updateProductPurchaseStatus(zipDocStorage.Id);
                String zipFiledDownloadLink =
                    '<a href="' +
                    URL.getOrgDomainUrl().toExternalForm() +
                    '/servlet/servlet.FileDownload?file=' +
                    zipFileStatus.docSfId +
                    '">' +
                    zipFileStatus.docName +
                    '</a>';
                String csvFiledDownloadLink =
                    '<a href="' +
                    URL.getOrgDomainUrl().toExternalForm() +
                    '/sfc/servlet.shepherd/document/download/' +
                    csvContentDocId +
                    '">' +
                    zipFileStatus.docName.replace('zip', 'csv') +
                    '</a>';
                if (zipFileStatus.status == 'Success') {
                    String emailBody =
                        'Please find below links for Putback/Buyback CSV and Evidence ZIP file -<br/>' +
                        'ZIP - ' +
                        zipFiledDownloadLink +
                        '<br/>CSV - ' +
                        csvFiledDownloadLink;
                    CTBFileValidationUtility.sendEmail('Putback/Buyback processing completed', emailBody, System.Label.Putback_Buyback_Email_Ids);
                }
                if (zipFileStatus.status == 'Partial') {
                    String emailBody =
                        'Please find below links for Putback/Buyback CSV and Evidence ZIP file -' +
                        '<br/>ZIP - ' +
                        zipFiledDownloadLink +
                        '<br/>CSV - ' +
                        csvFiledDownloadLink +
                        '<br/>Below documents failed to get added in the ZIP -' +
                        '<br/>' +
                        getCommaSepartedDocStorageList(zipFileStatus.failedDocIds);
                    CTBFileValidationUtility.sendEmail('Putback/Buyback processing completed partially', emailBody, System.Label.Putback_Buyback_Email_Ids);
                }
            }
            responseMap.put('status', 'Success');
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            responseMap.put('status', 'Error');
            responseMap.put('errorMessage', ex.getMessage());
            updateDocStorageStatus(zipDocStorage, 'Failed', ex.getMessage());
            PutbackBuybackUtility.createApiError(
                ex.getMessage(),
                ex.getStackTraceString(),
                'Putback/Buyback Zip File processing failed',
                System.Label.Putback_Buyback_Email_Ids
            );
        }
        PortalDocumentStorageProcessor.createResponse(JSON.serialize(responseMap, true), 200);
        return JSON.serialize(responseMap, true);
    }

    /**
     * @description : Method to update product purchase status using provided identifier from staging records
     * @author adesh.ikhar@canaccede.com | 03-26-2025
     * @param identifier
     **/
    public static void updateProductPurchaseStatus(String identifier) {
        List<String> productIdList = new List<String>();
        List<Product_Staging__c> productStagingList = [SELECT Data_Id__c FROM Product_Staging__c WHERE Identifier__c = :identifier];
        for (Product_Staging__c staging : productStagingList) {
            productIdList.add(staging.Data_Id__c);
        }
        PutbackBuybackQueueable.updateProductPurchaseStatus(productIdList, 'Buyback/Putback Submitted to Seller');
        Database.delete(productStagingList);
    }

    /**
     * @description : Method to update document storage record with passed info
     * @author adesh.ikhar@canaccede.com | 02-12-2025
     * @param zipDocStorage
     * @param status
     * @param requestBody
     **/
    public static void updateDocStorageStatus(Document_Storage__c zipDocStorage, String status, String requestBody) {
        zipDocStorage.File_Processing_Status__c = status;
        zipDocStorage.Inbound_API_Request_Body__c = requestBody;
        zipDocStorage.Comment__c = null;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        update zipDocStorage;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }

    /**
     * @description : Method to build formatted comma separated list of failed doc storage records
     * @author adesh.ikhar@canaccede.com | 02-12-2025
     * @param failedDocIds
     * @return String
     **/
    public static String getCommaSepartedDocStorageList(List<String> failedDocIds) {
        List<String> formattedFailedDocNames = new List<String>();
        for (Document_Storage__c failedDocStorage : [
            SELECT Document_Name__c, Document_Type__c, Document_URL__c, Product__r.Customer__r.Name, Product__r.Seller__r.Name
            FROM Document_storage__c
            WHERE Id IN :failedDocIds
        ]) {
            formattedFailedDocNames.add(
                failedDocStorage.Product__r.Customer__r.Name + '-' + failedDocStorage.Document_Type__c + '-' + failedDocStorage.Document_Name__c
            );
        }
        return formattedFailedDocNames.toString();
    }

    public class JsonRequest {
        public String status { get; set; }
        public String docName { get; set; }
        public String errorMessage { get; set; }
        public String docUrl { get; set; }
        public List<String> failedDocIds { get; set; }
        public String docSfId { get; set; }
    }
}
