@isTest
public class TestErrorCSVFileGenerationBatch {
    
     public static API_Call_Details__c testDocumentAPI(){
        //Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
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
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        return settings;
      
    }
    
    @isTest
    static void testbatch(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c api = testDocumentAPI();
        
        Work_Assignment__c wrkAss3 = new Work_Assignment__c();
        wrkAss3.Status__c = 'Request to Reopen';
        wrkAss3.RecordTypeId=Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Excel Processing').getRecordTypeId();
        insert   wrkAss3;
        Document_Storage__c d=new Document_Storage__c();
        d.Work_Assignment__c=wrkAss3.id;
        insert d;
       Product_Staging__c productStaging = new Product_Staging__c();
       // productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = d.ID;
        productStaging.Comment__c = '<b>ERROR</b> - Account not found.<br/>';
        productStaging.Identifier__c = d.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.status__c = 'Processed';
        productStaging.Include_in_Processing__c=true;
        insert productStaging;
        
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
        Product_Staging__c productStaging3 = new Product_Staging__c();
        //productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = d.ID;
        productStaging3.Comment__c = 'Success';
        productStaging3.Identifier__c = d.ID;
        productStaging3.Placement_Agency__c = '1';
        productStaging3.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging3.Placement_Status_Code__c = '800000';
        productStaging3.status__c = 'Pending';
        insert productStaging3;
        string abc=(string)d.id;
        String docType = 'Account Status Update File';
        
        test.startTest();
    //Set mock response
        HttpCalloutMock authenticationResponse = new DecisionWSUtilReqMock(mockWebServiceAuthenticationString());
       // HttpCalloutMock adjudicationResponse = new DecisionWSUtilReqMock(mockWebServiceStringBody());
        
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
       // endpoint2TestResp.put('adjudication', adjudicationResponse);
        endpoint2TestResp.put('authentication', authenticationResponse );
        
        HttpCalloutMock multiCalloutMock = new MultiRequestMockDecision(endpoint2TestResp);
        
        //Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ErrorCSVFileGenerationBatch e=new ErrorCSVFileGenerationBatch(abc,docType);
        database.executeBatch(e);
        test.stopTest();
    }
       Static String mockWebServiceAuthenticationString(){
        String authBody = '{"token_type":"test","expires_in":"","ext_expires_in":"","access_token":"test"}';
        
        return authBody;
    }
}