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
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Trigger__c = true;
        insert config;  
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
        insert insolAcct;
        
        insolAcct.Insolvency_Status__c = 'For Owner Review';
        update insolAcct;
        
		
        //Call Controller method
        ApexPages.StandardController sc = new ApexPages.StandardController(insolAcct);
        InsolvencyAccountCreateController contr = new InsolvencyAccountCreateController(sc);
        contr.redirPage();
    }
}