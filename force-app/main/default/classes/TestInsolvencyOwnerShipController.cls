/**************************************************************************************************
 *
 *  Class:   TestInsolvencyOwnerShipController
 *
 *  @description : This class contains unit tests for generating and saving poc pdf document
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 * 
 *************************************************************************************************/

 @isTest
 public class TestInsolvencyOwnerShipController{
     //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
            //Application config creation
        Application_Config_Settings__c config = new Application_Config_Settings__c(
          Run_Remittance_Validation__c = false,
          Run_Remittance_Trigger__c = true,
          Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
          Run_Insolvency_Trigger__c = false,
          Run_Insolvency_Account_Duplicate_Check__c = true,
          Run_Insolvency_Account_Trigger__c = false,
          Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
          Run_Insolvency_Status_Validations__c = true,
          Bank_Eligible_for_Duplicate_Check__c = 'SPL',
          Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
      );
      insert config;
          
          Insolvency_Account__c insolvAacc = new Insolvency_Account__c(name = 'test');
          insert insolvAacc ;
          
          // insert insolvency record
          Insolvency__c insolv = new Insolvency__c(name = 'test-insolOwner', Is_Record_Locked__c = true);
          insert insolv;      
     }
      
     // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void testRecorOwneship(){
         Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
         ApexPages.currentPage().getParameters().put('Id', insolv.Id);  
         InsolvencyOwnerShipController obj = new InsolvencyOwnerShipController(new ApexPages.StandardController(insolv));
         
         obj.isScotiaBankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
         
         obj.isScotiaBankCommunityUser = false;
         obj.isChaseBankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
         
         obj.isChaseBankCommunityUser = false;
         obj.isSDABankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
         
         obj.isSDABankCommunityUser = false;
         obj.isChaseBankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
 
         obj.isChaseBankCommunityUser = false;
         obj.isFairstoneBankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
 
         obj.isFairstoneBankCommunityUser = false;
         obj.isGoeasyBankCommunityUser = true;
         obj.checkInsolvencyAccountOwnerShip();
      }
 }