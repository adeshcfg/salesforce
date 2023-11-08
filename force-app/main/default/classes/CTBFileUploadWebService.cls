/**
 * @description       : Class for CTB File creation callouts
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-08-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
@RestResource(urlMapping='/CTBFileUploadWebService/*')
global with sharing class CTBFileUploadWebService {
    /**
     * @description : Method called by Portal to send file upload status or new file details created from FTP
     * @author adeshi@a5econsulting.net | 11-08-2023
     * @return String
     **/
    @HttpPost
    global static String handleCTBFileTransmission() {
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            when 'SFUpload' {
                System.debug('SFUpload API called');
                // processSFUpload('', '');
            }
            when 'FTPUpload' {
                System.debug('FTPUpload API called');
            }
        }
        Map<String, Object> stringMap = new Map<String, Object>();
        stringMap.put('success', true);
        PortalDocumentStorageProcessor.createResponse(JSON.serialize(stringMap, true), 200);
        return JSON.serialize(stringMap, true);
    }

    /**
     * @description : Update Insolvency accounts based on the status received
     * @author adeshi@a5econsulting.net | 11-08-2023
     * @param fileName
     * @param uploadStatus
     **/
    public static void processSFUpload(String fileName, String uploadStatus) {
        String statusToUpdate = uploadStatus == 'SUCCESS' ? '' : 'Pending to sent on File';
        Insolvency_Account__c[] accountsToUpdate = new List<Insolvency_Account__c>();
        for (Insolvency_Account__c acc : [SELECT Id, Canadian_Tire_Sub_Status__c FROM Insolvency_Account__c WHERE CTB_Update_Filename__c = :fileName]) {
            acc.Canadian_Tire_Sub_Status__c = statusToUpdate;
            accountsToUpdate.add(acc);
        }
        if (!accountsToUpdate.isEmpty()) {
            try {
                update accountsToUpdate;
            } catch (DmlException ex) {
                System.debug('DMLException in processSFUpload ' + ex.getDmlMessage(0));
            }
        }
    }
}
