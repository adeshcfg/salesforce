@isTest
public class TestJudgmentTrigger {
    
    @isTest public static void TestJudgment()
    {    
         Judgment__C judg= new Judgment__C();
        string recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        insert judg;
        judg.Legal_Sub_Status__c='Vacated';
        Update judg;
        
         
        
    }    
     
}