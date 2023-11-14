@isTest
public class TestJudgmentTrigger {
    
    @isTest public static void TestJudgment()
    {   
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_JudgmentTrigger__c = true;  
        insert config;
        
        Judgment__C judg1= new Judgment__C();
        string recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg1.RecordTypeId=recrdid;
        judg1.Legal_Status__c='Post-Judgment';
        judg1.Legal_Sub_Status__c='Dormant';
        judg1.Legal_Agency__c = 'Test Agency';
        insert judg1;
        judg1.Legal_Sub_Status__c='Writ Filed';
        Update judg1;
        
        
        
    }    
    
    
}