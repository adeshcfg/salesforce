/**
 * @description       : Class for CTB File creation callouts
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-28-2023
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
        Map<Integer, String> codeStatusMap = new Map<Integer, String>{
            0 => 'Success',
            2020 => 'Unable to read file from Salesforce',
            2025 => 'Unable to store file in Azure Blob Storage',
            2030 => 'Unable to publish the file - cannot confirm file was delivered to the destination'
        };
        switch on RestContext.request.requestURI.substringAfterLast('/') {
            // Executed when SFUpload API is called to return status of file upload from salesforce to ftp
            when 'SFUpload' {
                System.debug('SFUpload API called');
                // processSFUpload('', '');
            }
            // Executed when FTPUpload API is called to give information of file uploaded to ftp
            when 'FTPUpload' {
                System.debug('FTPUpload API called');
            }
        }
        // TODO: Add error logic, currently returning only successful response
        Map<String, Object> stringMap = new Map<String, Object>();
        stringMap.put('success', true);
        PortalDocumentStorageProcessor.createResponse(JSON.serialize(stringMap, true), 200);
        return JSON.serialize(stringMap, true);
    }

    /**
     * @description : Method to update Insolvency accounts/payments and document storage based on the status received
     * @author adeshi@a5econsulting.net | 11-08-2023
     * @param fileName
     * @param uploadStatus
     **/
    public static void processSFUpload(String fileName, String uploadStatus) {
        // TODO: Add Insolvency payment update logic
        String accountStatusToUpdate = uploadStatus == 'SUCCESS' ? 'Delivered' : 'Pending File';
        String docStorageStatusToUpdate = uploadStatus == 'SUCCESS' ? 'Successful' : 'Failed';
        Insolvency_Account__c[] accountsToUpdate = new List<Insolvency_Account__c>();
        // Update document storage status associated to the file
        Document_storage__c[] docStorageToUpdate = [SELECT Id FROM Document_storage__c WHERE Document_Name__c = :fileName LIMIT 1];
        if (!docStorageToUpdate.isEmpty()) {
            docStorageToUpdate[0].File_Processing_Status__c = docStorageStatusToUpdate;
        }
        // Update insolvency account records status from the file
        for (Insolvency_Account__c acc : [SELECT Id, Insolvency_Sub_Status__c FROM Insolvency_Account__c WHERE CTB_Update_Filename__c = :fileName]) {
            acc.Insolvency_Sub_Status__c = accountStatusToUpdate;
            accountsToUpdate.add(acc);
        }
        try {
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
            if (!docStorageToUpdate.isEmpty()) {
                update docStorageToUpdate;
            }
        } catch (DmlException ex) {
            System.debug('DMLException in processSFUpload ' + ex.getDmlMessage(0));
        }
    }

    /**
     * @description : Method to create document storage record and queue processing of staging records validation and creation
     * @author adeshi@a5econsulting.net | 11-28-2023
     * @param documentId
     * @param fileName
     * @param docId
     **/
    public static void processFTPUpload(String documentId, String fileName, String docId) {
        // TODO: Add queueable method call to actually process staging records after document storage record creation
        // Create document storage status associated to the file
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = getFileIdentifier(documentId);
        // docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';
        // docInfo.Document_URL__c = parsedResponse.docUrl;
        docInfo.Document_Extension__c = 'csv';
        docInfo.Document_Name__c = fileName;
        docInfo.Document_Id__c = docId;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
        try {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            insert docInfo;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        } catch (DmlException ex) {
            System.debug('DMLException in processSFUpload ' + ex.getDmlMessage(0));
        }
    }

    /**
     * @description : Method to get type of file based on header value in csv file
     * @author adeshi@a5econsulting.net | 11-28-2023
     * @param documentId
     * @return String
     **/
    public static String getFileIdentifier(String documentId) {
        Document fileToProccess = [SELECT Id, Body FROM Document WHERE Id = :documentId];
        String csvContents = fileToProccess.Body.toString();
        String csvHeader = csvContents.split('\n', 2)[0];
        System.debug(csvHeader);
        List<String> headerData = csvHeader.split(',');
        System.debug(headerData);
        // Add DRN Identifier conditions to get file identifier
        /* if (headerData[7] == '') {
         } */
        return 'Insolvency Daily Update';
    }
}
// CTBFileUploadWebService.getFileIdentifier('015S0000001pmO8IAI');
