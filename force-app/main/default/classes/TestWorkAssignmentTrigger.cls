@isTest
public class TestWorkAssignmentTrigger {
    
    @istest public static void Testcase()
    {
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Work_Assignment_Trigger__c=false);
        insert config;
        config.Run_Work_Assignment_Trigger__c=true;
        update config;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
        //Id rid=[Select Id From RecordType where sobjecttype = 'case' limit 1].id;
        Work_Assignment__c caseNew=new Work_Assignment__c();
        //caseNew.RecordTypeId=rid;
        caseNew.Accept_Assignment__c=True;
        insert caseNew;
        caseNew.Accept_Assignment__c=false;
        update caseNew;
        caseNew.Accept_Assignment__c=false;
        Delete caseNew;
    }
}