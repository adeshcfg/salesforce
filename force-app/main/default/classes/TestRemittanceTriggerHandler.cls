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
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Remittance_Trigger__c = true;
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
        
    }    

}