/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccountCreateController
 *  @author : A5E Consulting
 *  @date : 05/15/2018
 
 *************************************************************************************************/
 @isTest
private class TestInsolvencyAccountCreateController {
    @testSetup
    static void testData(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = true,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
    }
        
    static testMethod void InsolvencyAccountCreateTest(){
        //Create Insolvency
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;
        
        //Create Insolvency Account
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Account_Number_Without_Space__c='123';
        insert insolAcct;
        
        insolAcct.Insolvency_Status__c = 'For Owner Review';
        update insolAcct;
        
		
        //Call Controller method
        ApexPages.StandardController sc = new ApexPages.StandardController(insolAcct);
        InsolvencyAccountCreateController contr = new InsolvencyAccountCreateController(sc);
        contr.redirPage();
    }
}