/**************************************************************************************************
 *
 *  Class:   TestPOCDocController
 *
 *  @description : This class contains unit tests for generating and saving poc pdf document
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 * 
 *************************************************************************************************/

@isTest
public class TestPOCDocController{
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
         
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank');
         insert poc;
         
         //Insolvency insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        
        //insolv.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        
        insolv.Insolvency_Type__c='Bankruptcy';
        insolv.Debtor_2_Estate_Number__c='1234';
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
        insolAcct.Product_Code__c='MOR';
        insolAcct.Debtor__c='test';
        insolAcct.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct.Asset_Status__c ='Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.Portfolio_Group_Name__c='CAL005';
        insolAcct.recordTypeId = devRecordTypeId;
        insert insolAcct;
     }
     
     // Unit test for saving poc pdf document as attachment of insolvancy account
		static testMethod void savePOCDocTest(){
          Insolvency_Account__c insolAcct = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolAcct.Id);
          
          POCDocController obj = new POCDocController();
          obj.language = 'en_US';
          obj.savePOCDoc();
          
          try{
             throw new DMLException('My DML EXCEPTION'); 
          }catch(Exception ex){
              obj.handleException(ex);
          }
          //obj.goToInsolvancyAccount();
     }
    
    static testMethod void testChangeLangugae(){
		  Insolvency_Account__c insolAcct = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolAcct.Id);
          
          POCDocController obj = new POCDocController();
          obj.language = 'en_US';
          obj.pageName = 'Canaccede';
          obj.changeLanguage();
        
          obj.language = 'fr';
          obj.pageName = 'Canaccede';
          obj.changeLanguage();
        
          obj.language = 'en_US';
          obj.pageName = 'Scotia';
          obj.changeLanguage();
        
          obj.language = 'fr';
          obj.pageName = 'Scotia';
          obj.changeLanguage();
          
          try{
             throw new DMLException('My DML EXCEPTION'); 
          }catch(Exception ex){
              obj.handleException(ex);
          }
          //obj.goToInsolvancyAccount();
    }
}