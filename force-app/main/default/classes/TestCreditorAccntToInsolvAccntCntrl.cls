/**************************************************************************************************
 *
 *  Class:    TestCreditorAccntToInsolvAccntCntrl
 *
 *  @description : Unit test for TestCreditorAccntToInsolvAccntCntrl
 *  @author : A5E Consulting
 *  @date : 19/05/2020
 
 *************************************************************************************************/
@isTest
public class TestCreditorAccntToInsolvAccntCntrl {
    @TestSetup
    static void makeData() {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        config.Ignore_Account_Number_for_DuplicateCheck__c = '123123';
        config.Profile_Eligible_for_Duplicate_Check__c = 'System Administrator';
        config.Eligible_for_Validn_Needed_Calculation__c = 'test';
        config.Bank_Eligible_for_Duplicate_Check__c = 'test';
        config.Eligible_for_Claim_Type_Calculation__c = 'test';
        insert config;   

        //Insolvency record creation
        Insolvency__c insolvencyRec = new Insolvency__c();
        insolvencyRec.Name = 'INSOL-90809';
        //insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Insolvency_Status__c = 'Staging';
        INSERT insolvencyRec;

        //Creditor Account record Creation
        Creditor_Account__c creditorAccount = new Creditor_Account__c();
        creditorAccount.Insolvency__c = insolvencyRec.Id;
        creditorAccount.Creditor_Name__c = 'test';
        creditorAccount.Address_of_Creditor__c = 'street 123';
        creditorAccount.Unsecured_Asset_Amount__c = 100.00;
        creditorAccount.Secured_Asset_Amount__c = 10.00;
        creditorAccount.Preferred_Amount__c = 10.00;
        creditorAccount.Claim_Type__c = 'Secured';
        creditorAccount.Liabilities_Type_Code__c = 'la';
        creditorAccount.Insolvency__c = insolvencyRec.Id;
        creditorAccount.Created_By_Doc_Parser__c = TRUE;
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

        List<Creditor_Account__c> creditorAccounts = [SELECT Id FROM Creditor_Account__c WHERE Id =: creditorAccount.Id];
        System.assertEquals(0, creditorAccounts.size());

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