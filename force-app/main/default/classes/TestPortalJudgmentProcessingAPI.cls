/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Judgment API (PortalJudgmentProcessingAPI)
 *  @author : A5E Consulting
 *  @date : 28/01/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalJudgmentProcessingAPI {
    
    public static testMethod void testAccountJudgmentAPI(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

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
        settings.API_Request_Timeout__c = 90;
        insert settings;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Legal_Status__c';
        FieldMap.Field_JSON_Tag__c ='Legal_Status';
        FieldMap.Object_Name__c = 'Judgment';
        FieldMap.Name = 'Legal_Status';
        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Judgment_Number__c';
        FieldMap1.Field_JSON_Tag__c ='Judgment_Number';
        FieldMap1.Object_Name__c = 'Judgment';
        FieldMap1.Name = 'Judgment_Number';
        
        insert FieldMap1;
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        String recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        
        Judgment__c judg1 = [select Id, Name from Judgment__c where id = : judg.id];

        PortalJudgmentProcessingAPI.processJudgment(judg1.Id); 
    }
    
    public static testMethod void testAccountJudgmentAPI1(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/FidemAPIError';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90;
        insert settings;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Legal_Status__c';
        FieldMap.Field_JSON_Tag__c ='Legal_Status';
        FieldMap.Object_Name__c = 'Judgment';
        FieldMap.Name = 'Legal_Status';
        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Judgment_Number__c';
        FieldMap1.Field_JSON_Tag__c ='Judgment_Number';
        FieldMap1.Object_Name__c = 'Judgment';
        FieldMap1.Name = 'Judgment_Number';
        
        insert FieldMap1;
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        String recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        
        Judgment__c judg1 = [select Id, Name from Judgment__c where id = : judg.id];

        PortalJudgmentProcessingAPI.processJudgment(judg1.Id); 
    }

}