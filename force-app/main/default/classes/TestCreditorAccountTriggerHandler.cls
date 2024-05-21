
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
     
     static testMethod void afterInsertTest(){
        Account Truscomp = new Account();
        Id Recrdid = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name LIKE 'Trustee Company'].id;
        Truscomp.RecordTypeId = Recrdid;
        Truscomp.name = 'Test';
        insert Truscomp;

        Deposit_Accounts__c depositeAcc = new Deposit_Accounts__c();
        depositeAcc.Name = 'CCL';
        depositeAcc.Account_Number__c = '1993-130';
        depositeAcc.Bank_Name__c = 'Canaccede Credit LP Blocked';
        depositeAcc.Entity_Name__c = 'Canaccede Credit LP';
        depositeAcc.Account_Name_on_Clearing_Account__c = 'CCLP - 130';
        depositeAcc.Transit_Number__c = '03482';
        insert depositeAcc;

        // Trustee Office Record
        Account Trusoff = new Account();
        Id Recordid = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name LIKE 'Trustee Office'].id;
        Trusoff.RecordTypeId = Recordid;
        Trusoff.name = 'Testrecord';
        Trusoff.Trustee_ID__c = Truscomp.id;
        Trusoff.Is_Active__c = true;
        Trusoff.Follow_up_Email__c = 'Test@test.com';
        insert Trusoff;

        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '00-000001';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Trustee__c = Trusoff.id;
        insert insolv1;

        Creditor_Account__c creditorAccount=new Creditor_Account__c();
        creditorAccount.Name='test123';
        creditorAccount.Insolvency__c=insolv1.ID;
        creditorAccount.External_Correlation_ID__c='';
        insert creditorAccount;
        list<Creditor_Account__c> creditorAccountRecords=new list<Creditor_Account__c>();
        creditorAccountRecords.add(creditorAccount);
         CreditorAccountTriggerHandler.handleAfterInsert(creditorAccountRecords);         
     }    
 
 }