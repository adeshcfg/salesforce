/**************************************************************************************************
 *
 *  Class:   TestCustomLookupController
 *
 *  @description : This class contains unit tests for custom look up results
 *  @author : A5E Consulting
 *  @date : 21/07/2019
 * 
 *************************************************************************************************/

@isTest
public class TestCustomLookupController{
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = '29';
        insert judg;
        

        Product__c prod = TestRecordsFactory.createProduct('1111');
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        Product__c prod2 = TestRecordsFactory.createProduct('2222');
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
    }
    
   //Test linkRecords
    static testMethod void testlookupRecords(){
        String objectName = 'Product__c';
        String filterField = 'Name';
        String searchString = '11';
        String whereClauseField = 'Collection_Sub_Status__c';
        String whereClauseValue = 'Legal';
        Product__c prod = [SELECT Id FROM Product__c WHERE Name = '2222' LIMIT 1];
        List<Id> excludeIds = new List<Id>{prod.Id};
            
        CustomLookupController.fetchRecords(objectName, filterField, searchString, whereClauseField, whereClauseValue, excludeIds);
        try{
            CustomLookupController.fetchRecords(objectName, null , searchString, whereClauseField, whereClauseValue, excludeIds);
        }Catch(Exception ex){
            // Exception thrown back to aura component
        }
    }
}