/**************************************************************************************************
 *
 *  Class:   TestCustomerAccountJudgmentCntrl
 *
 *  @description : This class contains unit tests for custom look up results
 *  @author : A5E Consulting
 *  @date : 01/08/2019
 * 
 *************************************************************************************************/

@isTest
public class TestCustomerAccountJudgmentCntrl{
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
         
        Account acc = TestRecordsFactory.createBusinessAccount('TestAccount');
		acc.RecordTypeID = TestRecordsFactory.getObjectRecordType('Account', 'CCS_Agency');
        insert acc;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Product__c prod = TestRecordsFactory.createProduct('1111');
        prod.CCS_Agency__c = acc.Id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
    }
    
   //Test linkRecords
    static testMethod void fetchAccountJudgments(){
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        CustomerAccountJudgmentCntrl.fetchAccountJudgments(accId);
    }
}