/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Test class for JudgmentIdentifier Batch
 *  @author : A5E Consulting
 *  @date : 06/15/2020
 
 *************************************************************************************************/
@isTest
public class TestJudgmentIdentifierBatch {
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
    }
    
    public static testMethod void TestJudgment(){ 
        Product__c prodInstance = new Product__c();
        prodInstance.name = 'TestName';
        prodInstance.Collection_Agency__c = 6;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Run_Identifier_Check_On__c = date.today();
        insert prodInstance;
        
        Judgment__C judgmetInstance= new Judgment__C();
        string recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judgmetInstance.RecordTypeId=recrdid;
        judgmetInstance.Legal_Status__c='Post-Judgment';
        judgmetInstance.Legal_Sub_Status__c='Dormant';
        judgmetInstance.Legal_Agency__c = '29';
        insert judgmetInstance;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Judgment__c = judgmetInstance.Id;
        accJudgment.Product__c = prodInstance.Id;
        accJudgment.Status__c = 'Active';
        insert accJudgment;
    
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prodInstance.id;
        accjudg.Judgment__c=judgmetInstance.id;
        accjudg.Status__c='Active';
        insert accjudg;
        
        Test.startTest();
        JudgmentIdentifierBatch c = new JudgmentIdentifierBatch();
        Database.executeBatch(c);
        Test.stopTest();    
    }
}