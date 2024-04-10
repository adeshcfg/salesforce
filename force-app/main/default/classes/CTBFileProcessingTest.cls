@isTest
public class CTBFileProcessingTest {
    @TestSetup
    static void makeData() {
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = 'Insolvency Daily Update';
        docInfo.Document_Extension__c = 'csv';
        docInfo.Document_Name__c = 'TestFile';
        docInfo.Document_Id__c = 'testdocid';
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Database.insert(docInfo);
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;

        String csvString = 'H,2,999,10,4/5/2024,10:07:05,T,DRN00001,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\nD,2,999,9/19/2023,41414,Consumer Proposal,Canadian Tire Credit Card,HILDA,ZIRK,1108-1660 Henderson Hwy,,Winnipeg,MB,CA,R2G 1H7,,11/12/1977,9/15/2023,21-2986827,1,L.C. Taylor & Co. Ltd.,386 Broadway Suite 605,,Winnipeg,MB,R3C3R6,0000000008PCOM,,,9/15/2023,500,9/15/2023,10,9/15/2023,11,9/16/2023,12,9/16/2023,13,9/17/2023,14,9/18/2023,15,9/19/2023,16,,,Test\nT,2,999,444,442,4/5/2024,10:07:05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert documentObj;
    }

    @isTest
    static void processFileTest() {
        Document doc = [SELECT Id FROM Document WHERE DeveloperName = 'my_document' LIMIT 1];
        Document_Storage__c docStorage = [SELECT Id, Document_Name__c FROM Document_Storage__c WHERE Document_Name__c = 'TestFile' LIMIT 1];
        Test.startTest();
        System.enqueueJob(new CTBFileProcessingQueueable(System.Label.CTB_Insolvency_Account, doc.Id, docStorage));
        Test.stopTest();
    }
}
