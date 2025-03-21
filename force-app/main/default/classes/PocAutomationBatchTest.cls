/**
 * @description       : Test class for PocAutomationBatch
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-05-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class PocAutomationBatchTest {
    @TestSetup
    static void makeData() {
        Test.startTest(); 
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Eligible_for_Voting_Decision__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Display_Duplicate_Accounts_List_View__c = 10;
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;

        PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', Account_Statement_Not_Allowed__c = '0018A00000uB1Nt,0018A00000uB1Nt');
        insert poc;

        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.Number_Of_Open_Complaint__c = 6;
        accInstance.Phone_Number__pc = '123';
        insert accInstance;

        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        insolv.Insolvency_Type__c = 'Bankruptcy';
        insolv.Debtor_2_Estate_Number__c = '1234';
        insolv.Voting_Decision__c = 'Auto Approved';
        insolv.Trustee__c = accInstance.Id;
        insert insolv;

        String devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestScotia';
        insolAcct.Account_Number_Without_Space__c = 'TestScotia';
        insolAcct.Insolvency_Status__c = 'PoC Details Provided';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Excluded_from_Purchase__c = false;
        insolAcct.Excluded_Account_Comments__c = 'TestData';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.Insolvency_Type__c = 'Bankruptcy';
        insolAcct.Insolvency_Date__c = Date.newInstance(2020, 4, 11);
        insolAcct.Last_Payment_Date_2__c = Date.newInstance(2020, 2, 11);
        insolAcct.Last_Payment_Date_3__c = Date.newInstance(2020, 2, 14);
        insolAcct.Account_Original_Open_Date__c = Date.newInstance(2020, 2, 10);
        insolAcct.Account_Open_date__c = Date.newInstance(2020, 1, 8);
        insolAcct.Charge_Off_Date__c = Date.newInstance(2020, 2, 16);
        insolAcct.Acknowledgement_date__c = Date.newInstance(2020, 2, 18);
        insolAcct.Product_Code__c = 'MOR';
        insolAcct.Debtor__c = 'test';
        insolAcct.PoC_Created_Date__c = DateTime.newInstance(2020, 1, 8);
        insolAcct.Asset_Status__c = 'Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = 'Unsecured';
        insolAcct.Reasons_for_Duplicate_Account_Number__c = 'Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.Portfolio_Group_Name__c = 'CAL005';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcct.Last_Payment_Date__c = Date.newInstance(2020, 1, 5);
        insolAcct.Voting_Options__c = 'Vote: Decline - With Creditor Meeting Request';
        insolAcct.Proof_of_Claim_Required__c = true;
        insolAcct.Include_Voting_Letter__c = true;

        Insolvency_Account__c insolAcctPoc = insolAcct.clone();
        insolAcctPoc.Insolvency_Status__c = 'PoC Details Provided';
        insolAcctPoc.Asset_Status__c = 'Putback';
        insolAcctPoc.Claim_Amount__c = 50;
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        insert new List<Insolvency_Account__c>{ insolAcct, insolAcctPoc };

        Attachment statement = new Attachment(Name = 'statement.pdf', Body = Blob.valueOf('Test'), ParentId = insolAcct.Id, Description = 'Account Statement');
        insert statement;
        
        ContentVersion conVer = new ContentVersion(Title='TestConVer',PathOnClient='path',VersionData = EncodingUtil.base64Decode('String'));
        insert conVer;
        
        conVer = [Select id, ContentDocumentId from ContentVersion where id =: conVer.Id];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = insolAcct.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        //conDocLinks.add(contentDocumentLink);
        insert contentDocumentLink;
        Test.stopTest();
    }

    @isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new PocAutomationBatch());
        Test.stopTest();
    }
    
    @isTest
    static void isTodayOutsideGivenBusinessDateRange_Test() {
        Test.startTest();
        PocDocUtility.isTodayOutsideGivenBusinessDateRange(System.Now() - 2, 5);
        Test.stopTest();
    }
    
    @isTest
    static void generateAttachmentRecord_Test() {
        Test.startTest();
        Insolvency_Account__c insolvancyAcc = [Select Id,Insolvency_Account__c.Amended_Claim_Flag__c, Name,Insolvency__r.Name, Insolvency__r.Debtor_1_First_Name__c, Insolvency__r.Debtor_1_Last_Name__c FROM Insolvency_Account__c LIMIT 1];
        PocDocUtility.generateAttachmentRecord('Test Record', insolvancyAcc);
        ContentVersion conVer = new ContentVersion(Title='TestConVer 1',PathOnClient='path',VersionData = EncodingUtil.base64Decode('String'));
        insert conVer;
        PocDocUtility.generateContentDocLinkRecord(conVer, insolvancyAcc);
        Test.stopTest();
    } 
    
    
    @isTest
    static void updateErrorAccounts_Test() {
        Test.startTest();
        List<Insolvency_Account__c> insolvancyAcc = [Select Id,Insolvency_Account__c.Amended_Claim_Flag__c, Name,Insolvency__r.Name, Insolvency__r.Debtor_1_First_Name__c, Insolvency__r.Debtor_1_Last_Name__c FROM Insolvency_Account__c];
        PocDocUtility.updateErrorAccounts(insolvancyAcc, 'Test Record Error');
        Test.stopTest();
    } 
    
    @isTest
    static void getPdfVfPageName_Test() {
        Test.startTest(); 
        PocDocUtility.getPdfVfPageName('Canaccede', 'en_US'); 
        PocDocUtility.getPdfVfPageName('Canaccede', 'French'); 
        PocDocUtility.getPdfVfPageName('Fidem', 'French');
        PocDocUtility.getPdfVfPageName('CanadianTire', 'en_US');
        PocDocUtility.getPdfVfPageName('CanadianTire', 'French');
        PocDocUtility.getPdfVfPageName('GoEasyUnSecured', 'en_US');
        PocDocUtility.getPdfVfPageName('GoEasyUnSecured', 'French');
        PocDocUtility.getPdfVfPageName('FairstoneNew', 'en_US');
        PocDocUtility.getPdfVfPageName('FairstoneNew', 'French');
        PocDocUtility.getPdfVfPageName('Flexiti', 'en_US');
        PocDocUtility.getPdfVfPageName('Flexiti', 'French');
        PocDocUtility.getPdfVfPageName('Money Mart', 'en_US');
        PocDocUtility.getPdfVfPageName('Money Mart', 'French');
        Test.stopTest();
    }
    
    @isTest
    static void testScheduler() {
        Test.startTest();
        System.schedule('TestJob', '0 0 23 * * ?', new PocAutomationBatch());
        Test.stopTest();
    }
}