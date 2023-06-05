@isTest
public with sharing class TestSnapshotProcessor {
    
    @testSetup
    static void createData() {

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
        settings.API_Request_Timeout__c = 200;
        insert settings;

        

    }

    @IsTest
    static void testProductSnapShot(){
        //Product__c prod = [SELECT Id, Collection_Agency_Placement__c FROM Product__c LIMIT 1];

        

        SnapshotProcessorMock mock = new SnapshotProcessorMock();
        HttpResponse accessToken = new HttpResponse();
        accessToken.setBody(mock.ACCESS_TOKEN);
        HttpResponse successTermsConditions = new HttpResponse();
        successTermsConditions.setBody(mock.CREATE_SNAPSHOT_SUCCESS);
        successTermsConditions.setStatusCode(200);
        // fill out values here
        mock.addResponse(accessToken);
        mock.addResponse(successTermsConditions);
        mock.addResponse(successTermsConditions);


        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, mock);
       

       Id productRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Distressed_Account').getRecordTypeId();

        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        place.Commission_Rate__c = 10;
        place.Commission_Rate_Mode__c = 'Commission Rate Only';
        insert place;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 12;
        insert pool;
        
        Product__c prod = new Product__c();
        prod.Name = '1566P000';
        prod.Commission_Rate__c=13;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Collection_Agency_Placement__c = place.id;
        prod.Pool_Name__c = pool.id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = productRecordTypeId;
        insert prod;
        
        SnapshotProcessor.createSnapshotFile(new List<Id> {prod.Id}, prod.Collection_Agency_Placement__c);
        
        Test.stopTest();
    }
}