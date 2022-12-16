@isTest
public class TestExcelToJSONBatch {
	
     public static testMethod void testPortalDocumentStorage(){
        
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        
         Placement__c place = new Placement__c();
        place.Name = '1';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;
         
        Product__c productInstance = new Product__c();
        productInstance.Name = '100000002';
        productInstance.Status__c = 'New Allocation - New Allocation';
        productInstance.Sub_Status__c = 'Ready';
        productInstance.Product_Status__c = 'Test';
        insert productInstance;
        
        Document_Storage__c docStorage = new Document_Storage__c();
     
        docStorage.Document_Storage_Number__c = 'DC-002300';
        docStorage.Product__c = productInstance.Id;
        docStorage.Product_Identifier__c = productInstance.name;
        //docStorage.Judgment__c = judgment.ID;
        //docStorage.Judgment_Identifier__c = 'JC-001';
        docStorage.Document_Type__c = 'Account Status Update File';
        docStorage.Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade2';
         docStorage.Document_URL__c = 'task@aa804d72-c6fd-4aa4-ad6e-f9384d340e44_xlsx';
        //docStorage.RecordTypeId = DistressedRecordTypeID;
        docStorage.Placement_Identifier__c = '1';
        insert docStorage;
        
        //docStorage.Document_Type__c = 'Account Status Update File';
       // update docStorage;
       
         Test.startTest();
         
         ExcelToJSONBatch eTJ = new ExcelToJSONBatch(docStorage.Document_Id__c,docStorage.Product_Identifier__c,docStorage.id,docStorage.Document_Type__c,docStorage.Document_URL__c);
         DataBase.executeBatch(eTJ); 
         
         Test.stopTest();
    }
    
}