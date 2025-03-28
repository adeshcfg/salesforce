/**************************************************************************************************
*
*  Class:   
*  @description : Test class for TestPortalProductProcessingAPI
*  @author : A5E Consulting
*  @date : 05/08/2022

*************************************************************************************************/
@isTest
public class TestPortalProductProcessingAPI {
    public static testMethod void testPortalProductProcessingAPI(){
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
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
         Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Name';
        FieldMap2.Field_JSON_Tag__c ='Name';
        FieldMap2.Object_Name__c = 'Product';
        FieldMap2.Name = 'Name';        
        insert FieldMap2;
        
        
          Pool__c pool = new Pool__c();
         //pool.Name = 'Test';
         pool.Placement_Agency__c = 89;
         Insert pool;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Account_ID__c = prod.id;
        prodExt.Description__c = 'Test data';
        insert prodExt;        
        
        PortalProductProcessingAPI.processProduct(prod.Id); 
        
          Product__c prod1 = new Product__c();
        prod1.name = '123455667';
        prod1.Payment_Setup_Status__c = 'Automated';
        prod1.Collection_Agency__c = 30;
        prod1.Funding_Status__c = 'Pending';
        prod1.Funding_Type__c = 'Automated';
        prod1.Disbursement_Amount__c = 1000.00;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Last_Name__c = 'xyz';
        prod1.Pool_Name__c = pool.id;
        prod1.Placement_Status__c = '100010';
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        insert prod1;
        
        prod1.Funding_Status__c = 'Released';
        update prod1;
        
        Product__c prod2= new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 30;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Last_Name__c = 'xyz';
        prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c =null;
        prod2.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod2;
    
        Product__c prod6= new Product__c();
        List<User> systemName1=[Select Name from User where Name ='System API'];
        prod6.name = '123454522';
        prod6.Internal_Status__c = 'Active';
        prod6.Payment_Setup_Status__c = 'Automated';
        prod6.Funding_Status__c = 'Funded';
        prod6.Funding_Type__c = 'Automated';
        prod6.Disbursement_Amount__c = 3000.00;
        prod6.Collection_Agency__c = 30;
        prod6.Current_Balance__c = 7730;
        prod6.Current_Principal_Balance__c = 5000;
        prod6.Current_Interest_Amount__c = 2730;
        prod6.product_status__C = '310000';
        prod6.Current_Workflow__c = 'Collection Process';
        prod6.Requested_Close_Date__c = System.Today();
        prod6.Status__c = 'New Allocation - New Allocation';
        prod6.Sub_Status__c = 'Ready';
        prod6.Product_Status__c = 'Test';
        prod6.Last_Name__c = 'xyz';
        prod6.Pool_Name__c = pool.id;
        prod6.Placement_Status__c = '100010';
        prod6.Credit_Counselling_Date__c =null;
        prod6.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod6.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod6;
        
        Product__c prod8= new Product__c();
        List<User> systemName2=[Select Name from User where Name ='System API'];
        prod8.name = '123454522';
        prod8.Internal_Status__c = 'Active';
        prod8.Payment_Setup_Status__c = 'Automated';
        prod8.Funding_Status__c = 'Funded';
        prod8.Funding_Type__c = 'Automated';
        prod8.Disbursement_Amount__c = 3000.00;
        prod8.Collection_Agency__c = 30;
        prod8.Current_Balance__c = 7730;
        prod8.Current_Principal_Balance__c = 5000;
        prod8.Current_Interest_Amount__c = 2730;
        prod8.product_status__C = '310000';
        prod8.Current_Workflow__c = 'Collection Process';
        prod8.Requested_Close_Date__c = System.Today();
        prod8.Status__c = 'New Allocation - New Allocation';
        prod8.Sub_Status__c = 'Ready';
        prod8.Product_Status__c = 'Test';
        prod8.Last_Name__c = 'xyz';
        prod8.Pool_Name__c = pool.id;
        prod8.Placement_Status__c = '100010';
        prod8.Credit_Counselling_Date__c =null;
        prod8.Purchase_Status__c = 'Buyback/Putback Approved';
        prod8.Putback_Buyback_Amount__c = 100;
        prod8.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod8;
        
        Product__c prod10= new Product__c();
        List<User> systemName3=[Select Name from User where Name ='System API'];
        prod10.name = '1234547888';
        prod10.Internal_Status__c = 'Active';
        prod10.Payment_Setup_Status__c = 'Automated';
        prod10.Funding_Status__c = 'Funded';
        prod10.Funding_Type__c = 'Automated';
        prod10.Disbursement_Amount__c = 3000.00;
        prod10.Collection_Agency__c = 30;
        prod10.Current_Balance__c = 7730;
        prod10.Current_Principal_Balance__c = 5000;
        prod10.Current_Interest_Amount__c = 2730;
        prod10.product_status__C = '310000';
        prod10.Current_Workflow__c = 'Collection Process';
        prod10.Requested_Close_Date__c = System.Today();
        prod10.Status__c = 'New Allocation - New Allocation';
        prod10.Sub_Status__c = 'Ready';
        prod10.Product_Status__c = 'Test';
        prod10.Last_Name__c = 'xyz';
        prod10.Pool_Name__c = pool.id;
        prod10.Placement_Status__c = '100010';
        prod10.Credit_Counselling_Date__c =null;
        prod10.Purchase_Status__c = 'Buyback/Putback Approved';
        prod10.Putback_Buyback_Amount__c = 100;
        prod10.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        insert prod10;
      
        
        List<id> prodids = new List<id>();
        prodids.add(prod.id);
        prodids.add(prod10.id);
        prodids.add(prod1.id);
        prodids.add(prod2.id);
        prodids.add(prod6.id);
        prodids.add(prod8.id);
        PortalProductProcessingAPI.processProductBulkBatch(prodids, new List<Product__c>());
		PortalProductProcessingAPI.processProductBulk(prodids);
        PortalProductProcessingAPI.processProductBulkBatchone(new Set<Id>(prodids));
        
    }
    
    public static testMethod void testPortalBulkProductProcessingAPI(){
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
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Account_ID__c = prod.id;
        prodExt.Description__c = 'Test data';
        insert prodExt;        
        
        list<ID> listProductID = new list<ID>();
        listProductID.add(prod.ID);
        PortalProductProcessingAPI.processProductBulk(listProductID); 
       // PortalProductProcessingAPI.processProductNonFutureContext(prod.Id); 
        
    }
    /*
      public static  void testPortalProductProcess(){
        
       Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        insert prod;
        
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Account_ID__c = prod.id;
        prodExt.Description__c = 'Test data';
        insert prodExt;  
        
		PortalProductProcessingAPI.processProductNonFutureContext(prod.Id); 
    }*/
}