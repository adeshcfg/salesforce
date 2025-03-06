/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of RemittanceTriggerHandler
 *  @author : A5E Consulting
 *  @date : 09/26/2018
 * 
 *************************************************************************************************/
 
@isTest
public class TestRemittanceTriggerHandler{
	
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
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;
    }
    
    static testMethod void insolvencyBeforeInsertTest(){
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolvList.add(insolv1);
        insert insolvList;
        
        //Insolvency Account Records 
        List<Insolvency_Account__c> insolvAccntList = new List<Insolvency_Account__c>();  
        Insolvency_Account__c insAcc1 = new Insolvency_Account__c();
        insAcc1.Insolvency_Status__c = 'New';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;
        insAcc1.Account_Number_Without_Space__c='123';
        insolvAccntList.add(insAcc1);
        insert insolvAccntList;
        
        insAcc1.Insolvency_Status__c = 'For Owner Review';
        update insolvAccntList;
        
        //Remittance record creation
        List<Remittance__c> remListList = new List<Remittance__c>();
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.Cheque_Payment_Reference_Number__c = 'ref 1';
        remittance1.Payment_Posting_Date__c = System.Today().addDays(-30);
        remListList.add(remittance1);
        insert remittance1;
        
        //Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Insolvency_Account__c = insAcc1.Id;
        insert payment1;
        
        //Update Remitance
        Remittance__c remittance2 = new Remittance__c();
        remittance2.Status__c = 'New';
        remittance2.Cheque_Payment_Reference_Number__c = 'ref 2';
        remittance2.Payment_Posting_Date__c = System.Today().addDays(-60);
        
        //After Update check
        Map<Id, Remittance__c> remMap = new Map<Id, Remittance__c>();
        remMap.put(remittance1.Id, remittance2);        
        RemittanceTriggerHandler.handleAfterUpdate(remListList, remMap);
        RemittanceTriggerHandler.handleAfterInsert(remListList);
        RemittanceTriggerHandler.handleBeforeDelete(remListList);        
    }  
    
     static testMethod void insolvencyUpdateTestPositive(){
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolvList.add(insolv1);
        insert insolvList;
        
        //Insolvency Account Records 
        List<Insolvency_Account__c> insolvAccntList = new List<Insolvency_Account__c>();  
        Insolvency_Account__c insAcc1 = new Insolvency_Account__c();
        insAcc1.Insolvency_Status__c = 'New';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;
        insAcc1.Account_Number_Without_Space__c='123';
        insolvAccntList.add(insAcc1);
        insert insolvAccntList;
        
        insAcc1.Insolvency_Status__c = 'For Owner Review';
        update insolvAccntList;
        
        //Remittance record creation
        List<Remittance__c> remListList = new List<Remittance__c>();
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.Cheque_Payment_Reference_Number__c = 'ref 1';
        remittance1.Payment_Posting_Date__c = System.Today().addDays(-30);
        remListList.add(remittance1);
        insert remittance1;
        
        //Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Insolvency_Account__c = insAcc1.Id;
        insert payment1;
        
        //Update Remitance
        Remittance__c remittance2 = new Remittance__c();
        remittance2.Status__c = 'New';
        remittance2.Cheque_Payment_Reference_Number__c = 'ref 1';
        remittance2.Payment_Posting_Date__c = System.Today().addDays(-60);
        
        //After Update check
        Map<Id, Remittance__c> remMap = new Map<Id, Remittance__c>();
        remMap.put(remittance1.Id, remittance2);        
        RemittanceTriggerHandler.handleAfterUpdate(remListList, remMap);
        RemittanceTriggerHandler.handleAfterInsert(remListList);
        RemittanceTriggerHandler.handleBeforeDelete(remListList);        
    }
    
         static testMethod void insolvencyUpdateTestNegative(){
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolvList.add(insolv1);
        insert insolvList;
             
        //Account Record Creation
        Account acc = new Account(Name = 'Scotia');
		insert acc;
        
        //Insolvency Account Records 
        List<Insolvency_Account__c> insolvAccntList = new List<Insolvency_Account__c>();  
        Insolvency_Account__c insAcc1 = new Insolvency_Account__c();
        insAcc1.Insolvency_Status__c = 'New';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;
        insAcc1.Account_Number_Without_Space__c='123';
        insolvAccntList.add(insAcc1);
        insert insolvAccntList;
        
        insAcc1.Insolvency_Status__c = 'For Owner Review';
        update insolvAccntList;
        
        //Remittance record creation
        List<Remittance__c> remListList = new List<Remittance__c>();
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.Cheque_Payment_Reference_Number__c = 'ref 1';
        remittance1.Payment_Posting_Date__c = System.Today().addDays(-30);
        remListList.add(remittance1);
        insert remittance1;
        
        //Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Insolvency_Account__c = insAcc1.Id;
        payment1.Is_Payment_Remitted__c = false;
        payment1.Remitted_Back_To__c = acc.Id;
        insert payment1;
             
        Insolvency_Payment__c payment2 = [Select Id, Is_Payment_Remitted__c from Insolvency_Payment__c where id  =: payment1.Id];
        payment2.Is_Payment_Remitted__c = true;
             update payment2;
        
        //Update Remitance
        Remittance__c remittance2 = new Remittance__c();
        remittance2.Status__c = 'New';
        remittance2.Cheque_Payment_Reference_Number__c = 'ref 2';
        remittance2.Payment_Posting_Date__c = System.Today().addDays(-60);
        
        //After Update check
        Map<Id, Remittance__c> remMap = new Map<Id, Remittance__c>();
        remMap.put(remittance1.Id, remittance2);        
        RemittanceTriggerHandler.handleAfterUpdate(remListList, remMap);
        RemittanceTriggerHandler.handleAfterInsert(remListList);
        RemittanceTriggerHandler.handleBeforeDelete(remListList);        
    }

}