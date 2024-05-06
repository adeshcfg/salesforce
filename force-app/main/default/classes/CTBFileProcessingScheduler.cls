/**
 * @description       : Scheduler class for CTB file processing, will call portal API to check for file and process
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 04-08-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CTBFileProcessingScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // To Do : Call API to check if file uploaded and get file details
        // Create doc storage record with the received details
        // Document_Storage__c docInfo = processFTPUpload(documentId, fileName, docId);
        // System.enqueueJob(new CTBFileProcessingQueueable(System.Label.CTB_Insolvency_Account, documentId, docInfo));
    }

    /**
     * @description : Method to create document storage record and queue processing of staging records validation and creation
     * @author adeshi@a5econsulting.net | 11-28-2023
     * @param documentId
     * @param fileName
     * @param docId
     **/
    public static Document_Storage__c processFTPUpload(String documentId, String fileName, String docId) {
        // TODO: Add queueable method call to actually process staging records after document storage record creation
        // Create document storage status associated to the file
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = 'Insolvency Daily Update';
        // docInfo.Work_Assignment__c = 'a3LS0000000h6NCMAY';
        // docInfo.Document_URL__c = parsedResponse.docUrl;
        docInfo.Document_Extension__c = 'csv';
        docInfo.Document_Name__c = fileName;
        docInfo.Document_Id__c = docId;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
        try {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            Database.insert(docInfo);
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return docInfo;
        } catch (DmlException ex) {
            System.debug('DMLException in processSFUpload ' + ex.getDmlMessage(0));
            return null;
        }
    }
}
