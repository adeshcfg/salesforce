
/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of CreditorAccountTriggerHandler
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 * 
 *************************************************************************************************/
 
 @isTest
 public class TestCreditorAccountTriggerHandler{
     
     @testSetup
     static void testData(){
           //Application config creation
         Application_Config_Settings__c config = new Application_Config_Settings__c(
             Run_Remittance_Validation__c = false,
             Run_Creditor_Account_Trigger__c = true,
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
     }
     
     static testMethod void insolvencyBeforeInsertTest(){
        Creditor_Account__c creditorAccount=new Creditor_Account__c();
        creditorAccount.External_Correlation_ID__c='';
        insert creditorAccount;
        list<Creditor_Account__c> creditorAccountRecords=new list<Creditor_Account__c>();
        creditorAccountRecords.add(creditorAccount);
         CreditorAccountTriggerHandler.handleAfterInsert(creditorAccountRecords);         
     }    
 
 }