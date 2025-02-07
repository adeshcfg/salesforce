/**************************************************************************************************
 *
 *  Class:   TestPOCDocDataController
 *
 *  @description : This class contains unit tests for merge fields for POC pdf
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 * 
 *************************************************************************************************/

@isTest
public class TestPOCDocDataController{
    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         //Custom setting record creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Display_Duplicate_Accounts_List_View__c=10;
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config; 
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank',Client_Company_Name__c = 'test');
         insert poc;
         
         //Insolvency insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        
        //insolv.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        
        insolv.Insolvency_Type__c='Bankruptcy';
        insert insolv;
         
        //Insolvency Account insertion
        Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Excluded_from_Purchase__c=False;
        insolAcct.Excluded_Account_Comments__c='TestData';
        insolAcct.Is_Duplicate_Resolved__c=False;
        insolAcct.Insolvency_Type__c='Bankruptcy';
        insolAcct.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct.Last_Payment_Date_2__c =Date.newInstance(2020,02, 11);
        insolAcct.Last_Payment_Date_3__c =Date.newInstance(2020,02, 14);
        insolAcct.Account_Original_Open_Date__c =Date.newInstance(2020,02, 10); 
        insolAcct.Account_Open_date__c =Date.newInstance(2020,01, 08);
        insolAcct.Charge_Off_Date__c =Date.newInstance(2020,02, 16);
        insolAcct.Acknowledgement_date__c =Date.newInstance(2020,02, 18);
        insolAcct.Product_Code__c='MOR';
        insolAcct.Debtor__c='test';
        insolAcct.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct.Asset_Status__c='Bulk Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.Portfolio_Group_Name__c='CAL005';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcct.Last_Payment_Date__c=Date.newInstance(2020, 01, 08);
        insert insolAcct;
     }
      static testMethod void mergeFieldsTest(){
          Insolvency_Account__c insolAcct = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolAcct.Id);
          
          POCDocDataController obj = new POCDocDataController();
     }
}