/**************************************************************************************************
*
*  Class:   TestInsolvencyStatusUpdateBatch
*
*  @description : This class contains unit tests for InsolvencyStatusUpdateBatch
*  @author : A5E Consulting
*  @date : 10/10/2018
* 
*************************************************************************************************/

@isTest
public class TestInsolvencyStatusUpdateBatch {
    
    static testMethod void InsolvencyStatusUpdate(){
        
        // Insolvency record with status For Owner Review
        Insolvency__c insol = new Insolvency__c();
        insol.Name = 'Test Insolvency';
        insol.Insolvency_Status__c = 'For Owner Review';
        INSERT insol;
        
        
        // Insolvency Account with status Claim Filed
        Insolvency_Account__c insolAcc = new Insolvency_Account__c();
        insolAcc.Claim_Type__c = 'Unsecured';
        insolAcc.Proof_of_Claim_Required__c = false; 
        insolAcc.Insolvency_Status__c='Claim Filed';
        insolAcc.Client_Identifier__c='Scotia Bank';
        insolAcc.Insolvency__c = insol.Id;
        INSERT insolAcc; 
        
        // Insolvency Account with status No PoC Required
        Insolvency_Account__c insolAcc1 = new Insolvency_Account__c();
        insolAcc1.Claim_Type__c = 'Unsecured';
        insolAcc1.Proof_of_Claim_Required__c = false; 
        insolAcc1.Insolvency_Status__c='No PoC Required';
        insolAcc1.Client_Identifier__c='Scotia Bank';
        insolAcc1.Reason_for_No_PoC_Required_Dropdown__c = 'Other';
        insolAcc1.Reason_for_No_PoC_Required__c = 'Test';
        insolAcc1.Insolvency__c = insol.Id;
        INSERT insolAcc1;    
        
        Test.startTest();
        InsolvencyStatusUpdateBatch insolStatus = new InsolvencyStatusUpdateBatch();
        Database.executeBatch(insolStatus);
        Test.stopTest(); 
        
    }
}