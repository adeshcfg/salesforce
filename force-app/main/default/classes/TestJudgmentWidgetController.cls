/**************************************************************************************************
*
*  Class:   
*
*  @description : TestClientServiceWidget
*  @author : A5E Consulting
*  @date : 05/08/2022  

*************************************************************************************************/
@istest
public class TestJudgmentWidgetController {
     public static testMethod void testJudgmentWidgetController(){
        test.startTest();
         
        List<Account_Judgment__c> AccountJud = new List<Account_Judgment__c>();
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Status__c='Active';
        insert accjudg;
       
        Product__c prod = new Product__c();
        prod.Name = '1566P000';
        prod.Commission_Rate__c=13;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        
        
        JudgmentWidgetController.getaccountnumbers(accjudg.id);
        test.stopTest();
    }

}