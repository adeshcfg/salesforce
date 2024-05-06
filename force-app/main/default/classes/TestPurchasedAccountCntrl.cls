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
        
        //Application config creation
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = false,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
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