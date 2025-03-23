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
 public class TestInsolvencyPaymentsTriggerHandler{
     
     @testSetup
     static void testData(){
           //Application config creation
         Application_Config_Settings__c config = new Application_Config_Settings__c(
             Run_Remittance_Validation__c = false,
             Run_Insolvency_Payment_Trigger__c = true,
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
        list<Insolvency_Payment__c> insolPaymentRecords=new list<Insolvency_Payment__c>();
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

        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        insert portfolioName;

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account records
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.RecordTypeId = recordTypeList[0].Id;
        insolvencyAccount.Name = '4537049889659';
        insolvencyAccount.Insolvency_Status__c = 'No PoC Required';
        insolvencyAccount.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Insolvency__c = insolv1.Id;
        insolvencyAccount.Account_Number_Without_Space__c = '4537049889659';
        insolvencyAccount.Portfolio_Group_Name__c = 'CCL001';
        insolvencyAccount.Previous_Account_Reference__c = '111';
        insolvencyAccount.Debtor_1_Estate_Number__c = '00-000001';
        insolvencyAccount.Client_Identifier__c = 'Scotia';
        insert insolvencyAccount;
         
       	//Insolvency Account records
        Insolvency_Account__c insolvencyAccount1 = new Insolvency_Account__c();
        insolvencyAccount1.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        insolvencyAccount1.Name = '4537049889658';
        insolvencyAccount1.Client_Identifier__c = 'Canadian Tire';
        insolvencyAccount1.Insolvency__c = insolv1.Id;
        insert insolvencyAccount1;
         
        Remittance__c remittanceInstance = new Remittance__c();
        insert remittanceInstance;
		
        Insolvency_Payment__c paymentInstance2 = new Insolvency_Payment__c();
        paymentInstance2.Insolvency_Account__c = insolvencyAccount1.ID;
        paymentInstance2.Payment_Posting_Date__c = system.today();
        paymentInstance2.Payment_Amount__c = -321.98;
        paymentInstance2.Payment_Reversed__c = 'Stopped';
        paymentInstance2.Payment_Reversal_Date__c = system.today();
        insert paymentInstance2;
        
        insolPaymentRecords.add(paymentInstance2);
        InsolvencyPaymentsTriggerHandler.handleBeforeInsert(insolPaymentRecords);
         
        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c();
        paymentInstance1.Insolvency_Account__c = insolvencyAccount.ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c = 'Test File Uploaded123456';
        paymentInstance1.Remittance__c = remittanceInstance.Id;
        insert paymentInstance1;
         
        insolPaymentRecords.add(paymentInstance1);
        InsolvencyPaymentsTriggerHandler.handleAfterInsert(insolPaymentRecords);
        InsolvencyPaymentsTriggerHandler.handleBeforeDelete(insolPaymentRecords);
     }         
     static testMethod void insolvencyBeforeInsertTest1(){
        list<Insolvency_Payment__c> insolPaymentRecords=new list<Insolvency_Payment__c>();
         Map<Id,Insolvency_Payment__c> mapOfInsolvencyPay = new Map<Id,Insolvency_Payment__c>();
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

        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        insert portfolioName;

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account records
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.RecordTypeId = recordTypeList[0].Id;
        insolvencyAccount.Name = '4537049889659';
        insolvencyAccount.Insolvency_Status__c = 'No PoC Required';
        insolvencyAccount.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Insolvency__c = insolv1.Id;
        insolvencyAccount.Account_Number_Without_Space__c = '4537049889659';
        insolvencyAccount.Portfolio_Group_Name__c = 'CCL001';
        insolvencyAccount.Previous_Account_Reference__c = '111';
        insolvencyAccount.Debtor_1_Estate_Number__c = '00-000001';
        insolvencyAccount.Client_Identifier__c = 'Scotia';
        insert insolvencyAccount;
         
       	//Insolvency Account records
        Insolvency_Account__c insolvencyAccount1 = new Insolvency_Account__c();
        insolvencyAccount1.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        insolvencyAccount1.Name = '4537049889658';
        insolvencyAccount1.Client_Identifier__c = 'Canadian Tire';
        insolvencyAccount1.Insolvency__c = insolv1.Id;
        insert insolvencyAccount1;
         
        Remittance__c remittanceInstance = new Remittance__c();
        insert remittanceInstance;
		
        Insolvency_Payment__c paymentInstance2 = new Insolvency_Payment__c();
        paymentInstance2.Insolvency_Account__c = insolvencyAccount1.ID;
        paymentInstance2.Payment_Posting_Date__c = system.today();
        paymentInstance2.Payment_Amount__c = -321.98;
        paymentInstance2.Payment_Reversed__c = 'Stopped';
        paymentInstance2.Payment_Reversal_Date__c = system.today();
        insert paymentInstance2;
        
        insolPaymentRecords.add(paymentInstance2);
        InsolvencyPaymentsTriggerHandler.handleBeforeInsert(insolPaymentRecords);
         
        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c();
        paymentInstance1.Insolvency_Account__c = insolvencyAccount.ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c = 'Test File Uploaded123456';
        paymentInstance1.Remittance__c = remittanceInstance.Id;
        insert paymentInstance1;
         mapOfInsolvencyPay.put(paymentInstance1.Id, paymentInstance1);
         
        insolPaymentRecords.add(paymentInstance1);
        InsolvencyPaymentsTriggerHandler.handleBeforeUpdate(insolPaymentRecords,mapOfInsolvencyPay);
     }         
 }