@isTest
public class TestPortalSettlementProcessingAPI {
     public static testMethod void testSettlementAPI(){
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
        FieldMap.Field_API__c = 'Status__c';
        FieldMap.Field_JSON_Tag__c ='Status';
        FieldMap.Object_Name__c = 'Settlement';
        FieldMap.Name = 'Status';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Settlement_Number__c';
        FieldMap1.Field_JSON_Tag__c ='Settlement_Number';
        FieldMap1.Object_Name__c = 'Settlement';
        FieldMap1.Name = 'Settlement Number';        
        insert FieldMap1;
        
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Settlement_complete_date__c';
        FieldMap2.Field_JSON_Tag__c ='Settlement_complete_date';
        FieldMap2.Object_Name__c = 'Settlement';
        FieldMap2.Name = 'Settlement complete date';
        FieldMap2.Field_Type__c = 'Date';        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Proposal_Amount__c';
        FieldMap3.Field_JSON_Tag__c ='Proposal_Amount';
        FieldMap3.Object_Name__c = 'Settlement';
        FieldMap3.Name = 'Proposal_Amount';
        FieldMap3.Field_Type__c = 'Currency';        
        insert FieldMap3;
        
        Agency_Portal_Fields_Mapping__c FieldMap4 = new Agency_Portal_Fields_Mapping__c();
        FieldMap4.Field_API__c = '  Product_Identifier__c';
        FieldMap4.Field_JSON_Tag__c ='  Product_Identifier';
        FieldMap4.Object_Name__c = 'Settlement';
        FieldMap4.Name = 'Product_Identifier';                
        insert FieldMap4;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        //Settlement Record Creation
        
        Settlement__c Sttlmnt= new Settlement__c();
        Sttlmnt.Product__c = prod.Id;
        Sttlmnt.Status__c='New';
        Sttlmnt.Proposal_Amount__c= 111;
        Sttlmnt.Monthly_Expenses_Comments__c = 'test';
        Sttlmnt.Monthly_Income_Comments__c = 'test';
        Sttlmnt.Total_Wealth_Comments__c = 'test';
      	Sttlmnt.Comment__c='testing';
        Sttlmnt.Employment_Comments__c='testing\n\r\\sclass';
        Sttlmnt.HomeOwner_Status_Comments__c='testing\n\r\\sclass';
        insert Sttlmnt;
        
        PortalSettlementProcessingAPI.processSettlement(Sttlmnt.Id); 
    }
}