/**************************************************************************************************
 *
 *  Class:   TestOpportunityTriggerHandler
 *
 *  @description : This is Test class for OpportunityTrigger
 *  @author : A5E Consulting
 *  @date : 07/01/2020
 *************************************************************************************************/
@isTest
public class TestOpportunityTriggerHandler {
    @testSetup
    public static void testData(){
        Sales_Processing__c	 config = new Sales_Processing__c();
        config.Run_Opportunity_Trigger__c = true;
        insert config;
    }
    
    public static testMethod void testOppLineCreation(){
        Account account = new Account();
        account.Name = 'Sales Pipeline Customer';
        insert account;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Sales Pipeline';
        opportunity.CloseDate = system.today().addDays(-10);
        opportunity.AccountId = account.Id;
    	opportunity.StageName = 'Propsecting';
        opportunity.Face_Value__c = 50000;
        opportunity.Opportunity_Portfolio_Type__c = 'Insolvency';
        opportunity.Opportunity_Type__c = 'Hybrid';	
        opportunity.Asset_Class__c = 'Credit Card;Term Loan';	
        opportunity.Channel__c = 'Debt Originator';
        opportunity.Bulk_Payment_Date__c = system.today().addDays(30);
        opportunity.Term_Frequency__c = 'Monthly';
        opportunity.Opportunity_Term__c = 3;
        opportunity.Forward_Flow_Starting_From__c = system.today().addDays(10);
        opportunity.Credit_Card_Bulk_Purchase_Amount__c = 200;
        opportunity.Credit_Card_Forward_Flow_Purchase_Amount__c = 100;
        opportunity.Credit_Card_Bulk_Face_Value__c = 2000;
        opportunity.Credit_Card_Forward_Flow_Face_Value__c = 2000;
        opportunity.Term_Loan_Bulk_Purchase_Amount__c = 600;
        opportunity.Term_Loan_Forward_Flow_Purchase_Amount__c = 300;
        opportunity.Term_Loan_Bulk_Face_Value__c = 3000;
        opportunity.Term_Loan_Forward_Flow_Face_Value__c = 3000;
        insert opportunity;
        
        opportunity.Term_Loan_Bulk_Purchase_Amount__c = 500;
        update opportunity;
    }
}