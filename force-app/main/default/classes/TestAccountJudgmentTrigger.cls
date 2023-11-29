@isTest
public class TestAccountJudgmentTrigger {
@testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
    }
    
     @isTest public static void TestAccountJudgment(){
         //Product Record Creation
   product__C prod=new product__C();
    string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
    prod.RecordTypeId=recrdid;
    prod.Name ='123456789';
    prod.Previously_Reviewed_for_Legal_Action__c=True;
    prod.Current_Principal_Balance__c=101;
    prod.Current_Interest_Amount__c=1000;
    INSERT prod;
         //Judgment Record Creation
         Judgment__c judg= new Judgment__c();
         string recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = '29';
        insert judg;
         ////Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
         accjudg.Product__c=prod.id;
         accjudg.Judgment__c=judg.id;
         accjudg.Status__c='Active';
         INSERT accjudg;
         accjudg.Status__c='In-Active';
         update accjudg;
         
     }
}