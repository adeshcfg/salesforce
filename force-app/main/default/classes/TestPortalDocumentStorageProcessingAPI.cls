/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Document Storage API (TestPortalDocumentStorageProcessingAPI)
 *  @author : A5E Consulting
 *  @date : 28/01/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalDocumentStorageProcessingAPI {
    public static testMethod void testDocumentStorageAPI(){
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
        
        //Product Record Creation
        Product__c prod=new Product__C();
        prod.Name ='123456789';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        INSERT prod;
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        judg.Judgment_Number__c='JC-001';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        //Document Storage Record Creation
        Document_Storage__c docStor=new Document_Storage__c();
        docStor.Product__c=prod.id;
        docStor.Judgment__c=judg.id;
        INSERT docStor;
        
        PortalDocumentStorageProcessingAPI.processDocumentStorage(docStor.Id); 
    }
}