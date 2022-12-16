/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for ProbableUnallocatedPaymentsCntrl
 *  @author : A5E Consulting
 *  @date : 11/14/2018
 * 
 *************************************************************************************************/
@IsTest
public class TestProbableUnallocatedPaymentsCntrl{
    @testSetup
    static void testData(){
        
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insolv.Insolvency_Status__c = 'For Owner Review';
        insert insolv;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();

        // Insolvency Account
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.RecordTypeId = scotiabank;
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct;
    }
    
     //Test Controller
    static testMethod void testController(){
        Insolvency_Account__c insolvAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', insolvAcc.Id);
        ProbableUnallocatedPaymentsCntrl obj = new ProbableUnallocatedPaymentsCntrl(new ApexPages.StandardController(insolvAcc));
    }
}