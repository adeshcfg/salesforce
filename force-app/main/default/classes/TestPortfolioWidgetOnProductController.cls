/**************************************************************************************************
*
*  Class:   
*
*  @description : PortfolioWidgeton Product
*  @author : A5E Consulting
*  @date : 30/09/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestPortfolioWidgetOnProductController {
   
    static testMethod void insertTestData(){
        Portfolio_Name__c protfolio =  new Portfolio_Name__c ();
        protfolio.Name = 'MBNA24';
        protfolio.Account_Purchasing_Entity_ID__c = 'test';
        Insert protfolio;
        
        product__c productInstance = new product__c();
        productInstance.Portfolio_Name_Lookup__c = protfolio.ID;
        insert productInstance;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'Testing';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        insert prodInstance;
        
        Judgment__C judgmetInstance = new Judgment__C();
        string recrdid = [SELECT id FROM RecordType WHERE sobjecttype = 'Judgment__C' AND RecordType.Name = 'Judgment'].id;
        judgmetInstance.RecordTypeId = recrdid;
        judgmetInstance.Legal_Status__c = 'Judgment';
        judgmetInstance.Legal_Sub_Status__c = 'Vacated';
        judgmetInstance.Product_1__c = prodInstance.name;
        insert judgmetInstance;
        
        Account_Judgment__c accJudg = new Account_Judgment__c();
        accJudg.product__c = prodInstance.id;
        accJudg.judgment__c = judgmetInstance.id;
        accJudg.Status__c = 'Active';
        insert accJudg;
        
        settlement__c settle = new settlement__c();
        settle.Judgment__c = judgmetInstance.id;
        settle.Status__c = 'In Progress';
        settle.Proposal_Amount__c = 100;
        insert settle;
        
        portfolioWidgetOnProductController.getproduct(productInstance.ID);
        SettlementWidgetOnProductController.getproductName(prodInstance.ID);
    }


}