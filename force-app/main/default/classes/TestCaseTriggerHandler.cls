/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of CaseTriggerHandler
 *  @author : A5E Consulting
 *  @date : 10/24/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestCaseTriggerHandler{
    
    @testSetup
    static void testData(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Run_Case_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Open_Assignment_Calculation__c='test',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;
    }
    
    //Test all methods
    static testMethod void caseTriggerHandlerTest(){
        
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insert insolv;
        
        //Insolvency Account Record
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Account_Number_Without_Space__c='123';
        ia1.Insolvency__c = insolv.id;
        insert ia1;
        
        //Cases
        List<Case> cases = new List<Case>();   
        
        Case cseInsolv1 = new Case();
        cseInsolv1.subject = 'Review Insolvency';
        cseInsolv1.status = 'New';
        cseInsolv1.Assign_To__c = 'Scotia Bank';
        cseInsolv1.Insolvency__c = insolv.id;
        insert cseInsolv1;
        Case cseInsolv2 = new Case();
        cseInsolv2.subject = 'Review Insolvency';
        cseInsolv2.status = 'New';
        cseInsolv2.Assign_To__c = 'CFG';
        cseInsolv2.Insolvency__c = insolv.id;        
        insert cseInsolv2;     
        
        Case cseIAL1 = new Case();
        cseIAL1.subject = 'Review Insolvency Account';
        cseIAL1.status = 'New';
        cseIAL1.Assign_To__c = 'Scotia Bank';
        cseIAL1.Insolvency_Account__c = ia1.id;
        cseIAL1.Insolvency_Assignment_Type__c = 'Account Validation';
        insert cseIAL1;
        Case cseIAL2 = new Case();
        cseIAL2.subject = 'Review Insolvency Account';
        cseIAL2.status = 'New';
        cseIAL2.Assign_To__c = 'CFG';
        cseIAL2.Insolvency_Account__c = ia1.id;
        insert cseIAL2;
        
        cases.add(cseInsolv1);
        cases.add(cseInsolv2);
        cases.add(cseIAL1);
        cases.add(cseIAL2);
        
        cseIAL1.status = 'Closed';
        update cseIAL1;  
                
        //Test Insert   
        CaseTriggerHandler.handleBeforeInsert(cases);     
        CaseTriggerHandler.handleAfterInsert(cases);
        //Test Update 
        Map<ID, Case> caseMap = new Map<ID, Case>();
        caseMap.put(cseInsolv1.id, cseInsolv2);     
        caseMap.put(cseInsolv2.id, cseInsolv1);  
        caseMap.put(cseIAL1.id, cseIAL2);     
        caseMap.put(cseIAL2.id, cseIAL1);     
        CaseTriggerHandler.handleBeforeUpdate(cases, caseMap); 
        CaseTriggerHandler.handleAfterUpdate(cases, caseMap);  
        
        //Test Delete 
        CaseTriggerHandler.handleAfterDelete(cases, caseMap);  
    }
    
    //Test Insolvency Cases
    static testMethod void caseTriggerHandlerTestIns(){
        
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insert insolv;
                
        //Cases
        List<Case> cases = new List<Case>(); 
        List<Case> cases2 = new List<Case>(); 
        
        Case cseInsolv1 = new Case();
        cseInsolv1.subject = 'Review Insolvency';
        cseInsolv1.status = 'New';
        cseInsolv1.Assign_To__c = 'Scotia Bank';
        cseInsolv1.Insolvency__c = insolv.id;
        cseInsolv1.RecordTypeId=[select id from recordtype where DeveloperName='Remittance' AND sobjecttype = 'Case' LIMIT 1].id;
        insert cseInsolv1;
        
        Case cseInsolv3 = new Case();
        cseInsolv3.subject = 'Review Insolvency';
        cseInsolv3.status = 'New';
        cseInsolv3.Assign_To__c = 'Scotia Bank';
        cseInsolv3.Insolvency__c = insolv.id;
        cseInsolv3.RecordTypeId=[select id from recordtype where DeveloperName='CCS_Dividend' AND sobjecttype = 'Case' LIMIT 1].id;
        insert cseInsolv3;
        
        Case cseInsolv2 = new Case();
        cseInsolv2.subject = 'Review Insolvency';
        cseInsolv2.status = 'New';
        cseInsolv2.Assign_To__c = 'CFG';
        cseInsolv2.Insolvency__c = insolv.id;  
        cseInsolv2.RecordTypeId=[select id from recordtype where DeveloperName='EmailToCase'].id;
        insert cseInsolv2; 
        
        Case cseInsolv4 = new Case();
        cseInsolv4.subject = 'Review Insolvency';
        cseInsolv4.status = 'New';
        cseInsolv4.Assign_To__c = 'CFG';
        cseInsolv4.Insolvency__c = insolv.id;  
        cseInsolv4.RecordTypeId=[select id from recordtype where DeveloperName='EmailToCase'].id;
        insert cseInsolv4; 
        
      	cases2.add(cseInsolv3);
        cases.add(cseInsolv1);
        
        //Test Insert  
        CaseTriggerHandler.handleBeforeInsert(cases);      
        CaseTriggerHandler.handleAfterInsert(cases);
        CaseTriggerHandler.handleBeforeInsert(cases2);
        CaseTriggerHandler.handleAfterInsert(cases2);
       
        
        //Test Update 
        Map<ID, Case> caseMap = new Map<ID, Case>();
        caseMap.put(cseInsolv1.id, cseInsolv2);     
        CaseTriggerHandler.handleBeforeUpdate(cases, caseMap); 
        CaseTriggerHandler.handleAfterUpdate(cases, caseMap);
             
        Map<ID, Case> caseMap2 = new Map<ID, Case>();
        caseMap2.put(cseInsolv3.id, cseInsolv4);     
        CaseTriggerHandler.handleBeforeUpdate(cases2, caseMap2); 
        CaseTriggerHandler.handleAfterUpdate(cases2, caseMap2);
        
        //Test Delete 
        CaseTriggerHandler.handleAfterDelete(cases, caseMap);
        CaseTriggerHandler.handleAfterDelete(cases2, caseMap2);
      }
    
    //Test Insolvency Account Cases
    static testMethod void caseTriggerHandlerTestInsAccnt(){
        
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456789';
        insert insolv;
        
        //Insolvency Account Record
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Insolvency__c = insolv.id;
        ia1.Account_Number_Without_Space__c='123';
        insert ia1;
        
        //Cases
        List<Case> cases = new List<Case>();   
        Case cseIAL1 = new Case();
        cseIAL1.subject = 'Review Insolvency Account';
        cseIAL1.status = 'New';
        cseIAL1.Assign_To__c = 'Scotia Bank';
        cseIAL1.Insolvency_Account__c = ia1.id;
        cseIAL1.Insolvency_Assignment_Type__c = 'Account Validation';
        insert cseIAL1;
        Case cseIAL2 = new Case();
        cseIAL2.subject = 'Review Insolvency Account';
        cseIAL2.status = 'New';
        cseIAL2.Assign_To__c = 'CFG';
        cseIAL2.Insolvency_Account__c = ia1.id;
        insert cseIAL2;
                
        cases.add(cseIAL1);
        
        cseIAL1.status = 'Closed';
        update cseIAL1; 
                 
        //Test Insert     
        CaseTriggerHandler.handleBeforeInsert(cases);     
        CaseTriggerHandler.handleAfterInsert(cases);
        
        //Test Update 
        Map<ID, Case> caseMap = new Map<ID, Case>();
        caseMap.put(cseIAL1.id, cseIAL2);     
        CaseTriggerHandler.handleAfterUpdate(cases, caseMap);  
        
        //Test Delete 
        CaseTriggerHandler.handleAfterDelete(cases, caseMap);  
    }
}