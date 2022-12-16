/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of PurchasedAccountCntrl
 *  @author : A5E Consulting
 *  @date : 10/09/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestPurchasedAccountCntrl{
    
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Status_Validations__c = false;
        insert config;  
    }
    
    //Test Controller
    static testMethod void controllerTest(){
        
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insert insolv;
        
        //Insolvency Account
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c();
        insolvAcc.name = 'insolvAccnt';
        insolvAcc.Insolvency__c = insolv.Id;
        insolvAcc.Purchase_Export_Completed__c = false;
        insolvAcc.Insolvency_Status__c = 'Claim Filed';
        insert insolvAcc;
        
        //PAL List record
        Purchased_Account_List__c pal = new Purchased_Account_List__c();
        pal.Number_of_Records_Processed__c = 10;
        insert pal;
        
        //Test Controller
        PurchasedAccountCntrl pac = new PurchasedAccountCntrl(); 
        pac.runJob();   
    }
}