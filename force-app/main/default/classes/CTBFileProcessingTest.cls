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

        String csvString = '"H","2","999","10","4/5/2024","10:07:05","T","DRN00001","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",\n"D","2","999","9/19/2023","41414","Consumer Proposal","Canadian Tire Credit Card","HILDA","ZIRK","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","0000000008PCOM","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","16","","","Test"\n"T","2","999","444","442","4/5/2024","10:07:05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert documentObj;

        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Canadian Tire';
        config.Eligible_for_Claim_Type_Calculation__c = 'Canadian Tire';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'Canadian Tire';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;

        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insolv.Client_Identifiers__c = 'New';
        insolv.Insolvency_Type__c = 'Bankruptcy';
        insert insolv;

        //Portfolio record
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARD';
        portfolioName.Account_Purchasing_Entity_ID__c = ' 13';
        insert portfolioName;

        //Insolvency Account records
        List<Insolvency_Account__c> iaListNew = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        ia1.Name = '001278905436';
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 1000;
        ia1.Insolvency__c = insolv.Id;
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        ia1.Asset_Status__c = 'Purchased';
        ia1.Distressed_Data_Id__c = '848085644';
        ia1.Sent_For_Owner_Review_Date_Original__c = date.today();
        ia1.Trustee_Not_Providing_LoR__c = false;
        ia1.Distressed_Data_Id__c = '1';
        ia1.Claim_Filed_Date__c = System.now();
        ia1.Correlation_Id__c = '0000000008PCOM';
        iaListNew.add(ia1);
        insert iaListNew;
    }

    @isTest
    static void processFileTest() {
        String csvRow = '"H","2","999","10","4/5/2024","10:07:05","T","DRN00001, test"';
        Document doc = [SELECT Id FROM Document WHERE DeveloperName = 'my_document' LIMIT 1];
        Document_Storage__c docStorage = [SELECT Id, Document_Name__c FROM Document_Storage__c WHERE Document_Name__c = 'TestFile' LIMIT 1];
        Test.startTest();
        CTBFileValidationUtility.parseCsv(csvRow);
        System.enqueueJob(new CTBFileProcessingQueueable(System.Label.CTB_Insolvency_Account, doc.Id, docStorage));
        Test.stopTest();
    }
}
