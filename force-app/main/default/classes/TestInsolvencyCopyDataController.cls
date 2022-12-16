/**************************************************************************************************
 *
 *  Class:   TestInsolvencyCopyDataController
 *
 *  @description : This class contains unit tests for InsolvencyCopyDataController
 *  @author : A5E Consulting
 *  @date : 04/13/2018
 * 
 *************************************************************************************************/

@isTest
public class TestInsolvencyCopyDataController{

    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         Insolvency__c ins = new Insolvency__c(Name = 'NewInsolv', Insolvency_Status__c='Staging');
         insert ins;
     }
     
      // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void testController(){
         Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
         ApexPages.currentPage().getParameters().put('Id', insolv.Id);
         InsolvencyCopyDataController obj = new InsolvencyCopyDataController(new ApexPages.StandardController(insolv));
     }
}