/**************************************************************************************************
*
*  Class:   TestBatchConvertAttachmentsToConVersion
*
*  @description : This class contains unit tests for Batch Class to convert Attachments to Content Versions
*  @author : A5E Consulting
*  @date : 02/06/2025
*
*************************************************************************************************/

@isTest(seeAllData=false)
public class TestBatchConvertAttachmentsToConVersion {
    @testSetup
    static void testData() {
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Communication_Preference__c = 'Fax';
        acct.fax = '651426256';
        insert acct;
        
        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;
        
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = '123456789';
        acc.Insolvency__c = inslv.Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Package Generated';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        acc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        insert acc;
        
        String csvString = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Canadian Tire Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","0000000008PCOM","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123"\n"T","2","999","3","1","08/15/2008","12:32:06"';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert documentObj;
        
        Attachment att = new Attachment(
            Name = 'testAtt',
            Description = 'PoC Document',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            parentId = acc.Id
        );
        insert att;
        
        EmailMessage eMessage = new EmailMessage();
        eMessage.RelatedToId = acc.Id;
        insert eMessage;
        
        Attachment att1 = new Attachment(
            Name = 'testAttEmail',
            Description = 'PoC Document',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            parentId = eMessage.Id
        );
        insert att1;
    }
    
    // Testing send email with attachments
    static testMethod void processBatchJob() {
        Test.startTest();
        List<Insolvency_Account__c> listOfInsolAccnts = [select id from Insolvency_Account__c];
        Set<Id> setOfInsolvAccntIds = new Set<Id>{listOfInsolAccnts[0].Id};
        Database.executeBatch(new BatchConvertAttachmentsToConVersion(setOfInsolvAccntIds));
        Test.stopTest();
    }
}