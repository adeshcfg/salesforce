/**************************************************************************************************
 *
 *  Class:   TestDefaultTrusteeAssignPopUpController 
 *
 *  @description : This class contains unit tests for default pop up trustee asignee
 *  @author : A5E Consulting
 *  @date : 05/01/2018
 * 
 *************************************************************************************************/

@isTest(seeAllData = false)
public class TestTrusteeAssignPopUpController {

     //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         // insert insolvency account
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c();
         insert insolvAacc ;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c();
         insolv.name = 'test-trustee002';
         insert insolv; 
     }
     
     // Testing default popup
     static testMethod void defaultPopUp(){
         Insolvency__c insolv = [SELECT Id, Trustee__c FROM Insolvency__c LIMIT 1];
         TrusteeAssignPopUpController obj = new TrusteeAssignPopUpController(new ApexPages.StandardController(insolv));         
     }
}