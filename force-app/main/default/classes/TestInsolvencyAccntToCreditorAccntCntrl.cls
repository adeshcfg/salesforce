/**************************************************************************************************
 *
 *  Class:    TestInsolvencyAccntToCreditorAccntCntrl
 *
 *  @description : Test Insolvency Account creation from Creditor Account
 *  @author : A5E Consulting
 *  @date : 05/05/2020
 *
 *************************************************************************************************/
@isTest(seeAllData =  false)
public class TestInsolvencyAccntToCreditorAccntCntrl {
    @TestSetup
    static void makeData(){
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
        insolvencyRec.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyRec.Client_Identifiers__c = 'Scotia Bank';
        INSERT insolvencyRec;

        //Insolvency Account record Creation
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.Account_Type__c = 'Mortgage';
        insolvencyAccount.Insolvency__c = insolvencyRec.Id;
        insolvencyAccount.Insolvency_Type__c = 'Consumer Proposal';
        insolvencyAccount.Creditor_Name__c = '12345';
        insolvencyAccount.Address_of_Creditor__c = 'Street 123';
        insolvencyAccount.Unsecured_Asset_Amount__c = 123.00;
        insolvencyAccount.Secured_Asset_Amount__c = 123.00;
        insolvencyAccount.Preferred_Amount__c = 123.00;
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Liabilities_Type_Code__c = 'ltc';
        insolvencyAccount.Name = 'test';
        //Insolvency Account Related  Test data of creditorId  & liabilityId 
        insolvencyAccount.Creditor_Id__c = '1234553454';
        insolvencyAccount.Liability_Id__c = '1234553454';
        INSERT insolvencyAccount;
    }

    @IsTest
    static void testCreateCreditorAccount(){
        Insolvency_Account__c insolvencyAccount = [SELECT Id, Insolvency__c FROM Insolvency_Account__c LIMIT 1];
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(insolvencyAccount);
        InsolvencyAccountToCreditorAccountCntrl obj= new InsolvencyAccountToCreditorAccountCntrl(sc);
        obj.createCreditorAccount();

        // Verify new Creditor Account created
        Creditor_Account__c creditorAccount = [SELECT Insolvency__c FROM Creditor_Account__c LIMIT 1];
        System.assertEquals(insolvencyAccount.Insolvency__c, creditorAccount.Insolvency__c);

        obj.insolvAccount.Name = null;
        obj.createCreditorAccount();
        Test.stopTest();
    }
}