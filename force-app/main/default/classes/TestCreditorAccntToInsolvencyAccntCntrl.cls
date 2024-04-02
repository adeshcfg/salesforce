/**************************************************************************************************
 *
 *  Class:    TestCreditorAccntToInsolvencyAccntCntrl
 *
 *  @description : Test Creditor Account creation from Insolvency
 *  @author : A5E Consulting
 *  @date : 05/05/2020
 
 *************************************************************************************************/
@isTest

public class TestCreditorAccntToInsolvencyAccntCntrl {
    @TestSetup
    static void makeData(){
        //Application config creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
        config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
        config.Eligible_for_Validn_Needed_Calculation__c = 'test';
        config.Bank_Eligible_for_Duplicate_Check__c = 'test';
        config.Eligible_for_Claim_Type_Calculation__c = 'test';
        config.Doc_Parser_API_Key__c = '7146d1c4f964579e9faa36c112b2035e3d965a03';
        config.Target_URL_for_Insolvency__c = 'https://api.docparser.com/v1/document/upload'; 
        insert config;  
        
        //Insolvency record creation
        Insolvency__c insolvencyRec = new Insolvency__c();
        insolvencyRec.Name = 'INSOL-90809';
        //insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Client_Identifiers__c = 'Scotia Bank';
        INSERT insolvencyRec;

        //Insolvency Account record Creation
        Creditor_Account__c creditorAccount = new Creditor_Account__c();
        creditorAccount.Creditor_Name__c = '12345';
        creditorAccount.Address_of_Creditor__c = 'Street 123';
        creditorAccount.Unsecured_Asset_Amount__c = 123.00;
        creditorAccount.Secured_Asset_Amount__c = 123.00;
        creditorAccount.Preferred_Amount__c = 123.00;
        creditorAccount.Claim_Type__c = 'Unsecured';
        creditorAccount.Liabilities_Type_Code__c = 'ltc';
        creditorAccount.Insolvency__c = insolvencyRec.Id;
       
        //creditor Account Related  Test data of creditorId  & liabilityId 
        creditorAccount.Creditor_Id__c = '1234553454';
        creditorAccount.Liability_Id__c = '1234553454';
        INSERT creditorAccount;
    }

    @IsTest
    static void testCreateInsolvnecyAccount(){
        Creditor_Account__c creditorAccount = [SELECT Id, Insolvency__c FROM Creditor_Account__c LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(creditorAccount);
        CreditorAccountToInsolvencyAccountCntrl obj= new CreditorAccountToInsolvencyAccountCntrl(sc);
        List < SelectOption > recordTypes = obj.getRecordTypes();
        obj.selectedRecordType = recordTypes[0].getValue();
        obj.createInsolvencyAccount();
        // Verify new Insolvency Account created
        Insolvency_Account__c insolvencyAccount = [SELECT Insolvency__c, RecordTypeId FROM Insolvency_Account__c LIMIT 1];
        System.assertEquals(creditorAccount.Insolvency__c, insolvencyAccount.Insolvency__c);
        System.assertEquals(obj.selectedRecordType, insolvencyAccount.RecordTypeId);
        Test.stopTest();
    }

    @IsTest
    static void testCreateInsolvnecyAccountException(){
        Creditor_Account__c creditorAccount = [SELECT Id, Insolvency__c FROM Creditor_Account__c LIMIT 1];

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(creditorAccount);
        CreditorAccountToInsolvencyAccountCntrl obj= new CreditorAccountToInsolvencyAccountCntrl(sc);
        List < SelectOption > recordTypes = obj.getRecordTypes();
        obj.selectedRecordType = creditorAccount.Id;
        try{
        obj.createInsolvencyAccount();
        }catch(Exception ex){
            System.assertEquals(true, ex.getMessage() != NULL);
        }
        Test.stopTest();
    }
}