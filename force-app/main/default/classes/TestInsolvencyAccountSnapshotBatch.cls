/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyAccountSnapshotBatch
 *  @author : A5E Consulting
 *  @date : 05/07/2018
 * 
 *************************************************************************************************/
 @isTest
public class TestInsolvencyAccountSnapshotBatch {
    
    static testMethod void insolvencyAccountBatchTest(){
        //create insolvency
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = 'test-AccSnap';
        insolv1.Debtor_2_Estate_Number__c = 'test-AccSnap';       
        insert insolv1;
        
        //create Insolvency Account
        Insolvency_Account__c insolAcc = new Insolvency_Account__c();
        insolAcc.Insolvency__c = insolv1.id;
        insolAcc.Insolvency_Status__c = 'For Owner Review';
        insolAcc.Account_Type__c = 'Mortgage';
        insolAcc.Borrower_Primary__c = 'Kajal';
        insolAcc.Type_of_Service__c = 'Service Only';
        insolAcc.Claim_Type__c = 'Secured';
        insolAcc.Claim_Amount__c = 2300;
        insert insolAcc;  
        
        //execute InsolvencyAccountSnapshotBatch
        Database.executeBatch(New InsolvencyAccountSnapshotBatch(), 200);
    }       
}