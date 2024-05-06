/**************************************************************************************************
 *
 *  Class:   AddNewJudgmentControllerTest
 *
 *  @description : This class contains unit tests for legal Judgment data functionality
 *  @author : A5E Consulting
 *  @date : 21/07/2019
 * 
 *************************************************************************************************/

@isTest
public class AddNewJudgmentControllerTest{
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = '29';
        insert judg;
        
        Product__c prod = TestRecordsFactory.createProduct('1111');
        insert prod;
    }
    
   //Test linkRecords
    static testMethod void testlinkRecords(){
        Judgment__c judg = [SELECT Id FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        AddNewJudgmentController.linkRecords(prod.Id, judg.Id);
        AddNewJudgmentController.getlinkedJudgments(prod.Id);
    }
}