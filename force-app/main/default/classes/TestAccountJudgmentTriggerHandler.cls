/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for AccountJudgment object
 *  @author : A5E Consulting
 *  @date : 06/15/2020
 
 *************************************************************************************************/
@isTest
public class TestAccountJudgmentTriggerHandler {
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c
            (Run_Product_Coll_Sub_Status_Validation__c = true,
            Run_Account_Judgment_Trigger__c = true);
        insert config;
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Pre-legal';
        mapping.Judgment_Legal_Sub_Status__c = 'Recommended for legal action';
        mapping.Codes__c='210000';
        mapping.Product_Parent__c ='Pre - Legal - In Process';
        mapping.Product_Sub_status__c ='Recommended for Legal Action';
        insert mapping;
    }
    
     public static testMethod void TestAccountJudgment(){
     
        testData();
        
        //Product Record Creation
         Product__c prod=new Product__C();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Collection_Agency__c = 72;
        INSERT prod;
         
      
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        String recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Agency__c = '72';
        judg.Legal_Status__c='Pre-legal';
        judg.Legal_Sub_Status__c='Recommended for legal action';
        insert judg;
        
         //Account-Judgment Record Creation
        List<Account_Judgment__c> AccountJud = new List<Account_Judgment__c>();
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        AccountJud.add(accjudg);
        Utilities.runAccountJudgmentTrigger = True;
        accjudg.Status__c='InActive';
        update accjudg; 
        AccountJud.add(accjudg);
        AccountJudgmentTriggerHandler.handleBeforeInsert(AccountJud);
        AccountJudgmentTriggerHandler.getAccJudgmentRelatedData(AccountJud);
        AccountJudgmentTriggerHandler.updateAmountsOnJudgment(AccountJud);
        //AccountJudgmentTriggerHandler.getAccJudgmentRelatedAgencyData(AccountJud);
     }
    
    //This method will provide test coverage for function nameFormat
    public static testMethod void TestnameFormat()
    {
        Test.startTest();
        system.assertEquals('Test', AccountJudgmentTriggerHandler.nameFormat('test'));
        Test.stopTest();
    }
    
    //This method will provide test coverage for function populateProductNameOnJudgment
    public static testMethod void TestpopulateProductNameOnJudgment()
    {
        Test.startTest();
        testData();
        
        //Product Record Creation
        Product__c prod=new Product__C();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Collection_Agency__c = 72;
        INSERT prod;
         
      
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        String recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Agency__c = '72';
        judg.Legal_Status__c='Pre-legal';
        judg.Legal_Sub_Status__c='Recommended for legal action';
        insert judg;
        
         //Account-Judgment Record Creation
        List<Account_Judgment__c> AccountJud = new List<Account_Judgment__c>();
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        insert accjudg;
        AccountJud.add(accjudg);        
        AccountJudgmentTriggerHandler.populateProductNameOnJudgment(AccountJud);
        Test.stopTest();
    }    
}