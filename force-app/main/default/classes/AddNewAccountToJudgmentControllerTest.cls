/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for legal Judgment data functionality
 *  @author : A5E Consulting
 *  @date : 21/07/2019
 * 
 *************************************************************************************************/

@isTest
public class AddNewAccountToJudgmentControllerTest{
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c(Name='1111');
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        prodList.add(new Product__c(Name='2222',Status__c = 'New Allocation - New Allocation',Sub_Status__c = 'Ready',Product_Status__c = 'Test'));
        prodList.add(new Product__c(Name='3333',Status__c = 'New Allocation - New Allocation',Sub_Status__c = 'Ready',Product_Status__c = 'Test'));
        insert prodList;
        
        Account_Judgment__c accJudg = new Account_Judgment__c(Product__c = prod.Id, Judgment__c = judg.Id);
        insert accJudg;
        
    }
    
    //Test Adding Product to Judgment
    static testMethod void testAddNewAccountToJudgment(){
        Judgment__c judg = [SELECT Id FROM Judgment__c LIMIT 1];
        
        Judgment__c judg2 = new Judgment__c();
        judg2.Legal_Agency__c = 'Test Agency';
        insert judg2;
        
        
        
        AddNewAccountToJudgmentController.saveAccountJudgmentRecord( [SELECT ID FROM Product__c] ,judg.Id);
        AddNewAccountToJudgmentController.fetchLinkedAccounts(judg.Id);
        
        Account_Judgment__c accJudg = [SELECT Id, Judgment__c, Status__c, Product__c FROM Account_Judgment__c LIMIT 1];
        accJudg.ID = null;
        accJudg.Judgment__c = judg2.Id;
        accJudg.Status__c ='Active';
        insert accJudg;
        AddNewAccountToJudgmentController.deactivateAccJudgRelatedAccounts(judg.Id);
        
        
    }

        static testMethod void testDMLException(){
            Judgment__c judg2 = new Judgment__c();
            judg2.Balance_one__c = 0.01;
            try{
            insert judg2;
            }catch(System.DMLException ex){
                String msg = AddNewAccountToJudgmentController.readDMLMessage(ex);

            }
        }
}