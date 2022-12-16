@isTest
public class TestCaseTrigger {     
@istest public static void Testcase()
{
 Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Case_Trigger__c=false);
insert config;
config.Run_Case_Trigger__c=true;
update config;
CaseTriggerHandler.runCaseTrigger=True;
Id rid=[Select Id From RecordType where sobjecttype = 'case' limit 1].id;
case caseNew=new case();
caseNew.RecordTypeId=rid;
caseNew.Accept_Assignment__c=True;
insert caseNew;
caseNew.Accept_Assignment__c=false;
update caseNew;
delete caseNew;
}
}