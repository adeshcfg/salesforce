@isTest
public class TestCTBInsolvencyAccountGeneratorSchdler {
    @TestSetup
    static void makeData(){
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
    }
    
    @isTest
    static void testMethod1(){
        Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        test.startTest();
        CTBInsolvencyAccountGeneratorScheduler ctb=new CTBInsolvencyAccountGeneratorScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test CTB Check', sch, ctb); 
        Test.stopTest(); 
    }
}