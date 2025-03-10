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
         Test.startTest();
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
         
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(
             Name = 'Scotia Bank',
             Account_Statement_Not_Allowed__c = '0018A00000uB1Nt,0018A00000uB1Nt'
         );
         insert poc;
         
         //Insolvency insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'Dup-1';
        insolv.Insolvency_Date__c = Date.Today().addMonths(-1);
        insolv.Insolvency_Type__c='Bankruptcy';
        insolv.Debtor_2_Estate_Number__c='1234';
        insolv.Voting_Decision__c = 'Needs Manual Review';
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
        insolAcct.Asset_Status__c ='Purchased';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = 'Unsecured';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.Portfolio_Group_Name__c='CAL005';
        insolAcct.recordTypeId = devRecordTypeId;
        insolAcct.Last_Payment_Date__c = Date.newInstance(2020, 01, 05);
        insolAcct.Voting_Options__c = 'Vote: Decline - With Creditor Meeting Request';
        insolAcct.Proof_of_Claim_Required__c = false;
        insolAcct.Asset_Status__c = 'Putback';
        insert insolAcct;
         
         blob testData = Blob.valueOf('testing testing');
         
         Attachment attach = new Attachment();
         attach.Name = 'Amended PoC - ';
         attach.IsPrivate = false;
         attach.Description = 'test';
         attach.ParentId = insolAcct.Id;
         attach.Body = testData;
         insert attach;
         
         
         PocDocUtility.generateAttachmentRecord(insolAcct.name,insolAcct);
         Test.stopTest();
     }

     // Unit test for saving poc pdf document as attachment of insolvancy account
		static testMethod void savePOCDocTest(){
            Test.startTest();
          Insolvency_Account__c insolAcct = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolAcct.Id);
          
          POCDocController obj = new POCDocController();
          obj.language = 'en_US';
          obj.pageName = 'Canaccede';  
          obj.savePOCDoc(); 
          // fr //  
          POCDocController objCa = new POCDocController();
          objCa.language = 'fr';
          objCa.pageName = 'Canaccede';  
          objCa.savePOCDoc();    
   		  		 
          POCDocController obj1 = new POCDocController();          
          obj1.language = 'en_US';
          obj1.pageName = 'Fidem';  
          obj1.savePOCDoc(); 
           // fr //   
          POCDocController objFi = new POCDocController();          
          objFi.language = 'fr';
          objFi.pageName = 'Fidem';  
          objFi.savePOCDoc();  
          
          POCDocController obj2 = new POCDocController();          
          obj2.language = 'en_US';
          obj2.pageName = 'GoEasyUnSecured';  
          obj2.savePOCDoc();
          //fr//
          POCDocController objGo = new POCDocController();          
          objGo.language = 'fr';
          objGo.pageName = 'GoEasyUnSecured';  
          objGo.savePOCDoc();  
            
          POCDocController obj3 = new POCDocController();          
          obj3.language = 'en_US';
          obj3.pageName = 'Canadian Tire';  
          obj3.savePOCDoc(); 
          //fr//
          POCDocController objCn = new POCDocController();          
          objCn.language = 'fr';
          objCn.pageName = 'Canadian Tire';  
          objCn.savePOCDoc();  
            
          //fr//
          POCDocController objflexi = new POCDocController();          
          objflexi.language = 'fr';
          objflexi.pageName = 'Flexiti';  
          objflexi.savePOCDoc();
          
		  POCDocController obj4 = new POCDocController();          
          obj4.language = 'en_US';
          obj4.pageName = 'Flexiti';  
          obj4.savePOCDoc();             
		  
		  POCDocController objMM = new POCDocController();          
          objMM.language = 'fr';
          objMM.pageName = 'Money Mart';  
          objMM.savePOCDoc();
          
		  POCDocController obj5 = new POCDocController();          
          obj5.language = 'en_US';
          obj5.pageName = 'Money Mart';  
          obj5.savePOCDoc();
            
          try{
             throw new DMLException('My DML EXCEPTION'); 
          }catch(Exception ex){
              obj.handleException(ex);
          }
            Test.stopTest();
          //obj.goToInsolvancyAccount();
     }
    
    static testMethod void testChangeLangugae(){
        Test.startTest();
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
        
          obj.language = 'en_US';
          obj.pageName = 'Fidem';
          obj.changeLanguage();
        
          obj.language = 'en_US';
          obj.pageName = 'GoEasyUnSecured';
          obj.changeLanguage();
        
          obj.language = 'en_US';
          obj.pageName = 'Flexiti';
          obj.changeLanguage();
        
          obj.language = 'fr';
          obj.pageName = 'Flexiti';
          obj.changeLanguage();
          
          try{
             throw new DMLException('My DML EXCEPTION'); 
          }catch(Exception ex){
              obj.handleException(ex);
          }
        Test.stopTest();
          //obj.goToInsolvancyAccount();
          //Test.stopTest();
    }
}