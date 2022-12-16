/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Distressed Notes API (TestPortalDistressedNotesProcessingAPI)
 *  @author : A5E Consulting
 *  @date : 14/02/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalDistressedNotesProcessingAPI {
    public static testMethod void testDistressedNotesApi(){
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
        insert settings;
        
        Account Acc = new Account();      
        Acc.Name='Testcust';
        Acc.Broker_Name__c='Testbroker'; 
        insert Acc;
        
        Judgment__c jud = new  Judgment__c();      
        jud.Company_Name__c='Testcompant';
        jud.Legal_Agency__c = 'Test Agency';
        insert jud;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        INSERT prod;
        
        Settlement__c settle = new  Settlement__c();      
        settle.Product__c= prod.Id;
        settle.Proposal_Amount__c= 123;
        settle.Status__c='New';
        settle.Employment__c='Yes';
        settle.Homeowner_Status__c='Yes';
        insert settle;
        
        Distressed_notes__c distressedNotes = new Distressed_notes__c();       
        distressedNotes.Title__c = 'Test';
        insert distressedNotes;
        
        PortalDistressedNotesProcessingAPI.processDistressedNotes(distressedNotes.Id,'PUT'); 
    }
 
}