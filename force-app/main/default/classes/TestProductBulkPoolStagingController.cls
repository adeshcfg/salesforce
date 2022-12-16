@isTest
public class TestProductBulkPoolStagingController {
    @testSetup
    static void testData(){
        Placement__c placement = new Placement__c();
        placement.name = '1';
        insert placement;            
            
        Placement_Status_Code_Mapping__c PlacementCode = Placement_Status_Code_Mapping__c.getOrgDefaults();
        PlacementCode.name = '900000';
        PlacementCode.Parent_Status__c = 'New Allocation';
        PlacementCode.Status__c = 'New Allocation';
        PlacementCode.Sub_Status__c = 'Ready';
        PlacementCode.Placement_Status_Code__c = '900000';
        placementCode.Data_Status_Code__c = '200000';
        insert PlacementCode;
        system.debug('PlacementCode test class' +PlacementCode);
    
        list<Agency_Portal_Fields_Mapping__c> listmapping = new list<Agency_Portal_Fields_Mapping__c>();
        Agency_Portal_Fields_Mapping__c mapping1 = new Agency_Portal_Fields_Mapping__c(Name = 'Name', Object_Name__c = 'Product', 
                                                                                       Field_API__c = 'Name');
        listmapping.add(mapping1);
        
        
        Agency_Portal_Fields_Mapping__c mapping2 = new Agency_Portal_Fields_Mapping__c(Name = 'Product_Status', Object_Name__c = 'Product', 
                                                                                       Field_API__c = 'Product_Status__c');
        listmapping.add(mapping2);
        insert listmapping;
        
        
    }
    
    public static testMethod void testAccStatusUpdate(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Account Status Update File';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        
        ProductTriggerHandler.runProductTrigger = false;
        ProductTriggerHandler.runProductAPI = false;
        Product__c product = new Product__c();
        product.name = 'Test Product';
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        insert product2;
        
        Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;   
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        poolData.Placement_agency_lookup__c = placement1.id;
        insert poolData;
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'Success';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        insert productStaging;
        
        Product_Staging__c productStaging3 = new Product_Staging__c();
        productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = docStorage.ID;
        productStaging3.Comment__c = 'Success';
        productStaging3.Identifier__c = docStorage.ID;
        productStaging3.Placement_Agency__c = '1';
        productStaging3.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging3.Placement_Status_Code__c = '800000';
        insert productStaging3;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'ERROR';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        insert productStaging2;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        PageReference pageRef = Page.DisplayAccountStatusUpdateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);

        DisplayProductBulkPoolStagingController controller = new DisplayProductBulkPoolStagingController();
        system.debug('test.listProductStagingWrapper:'+controller.listProductStagingWrapper.size());
        controller.listProductStagingWrapper[0].selected = true;
        controller.listProductStagingWrapper[1].selected = true;
        controller.listProductStagingWrapper[2].selected = false;
        //test.listProductStagingWrapper[2].selected = true;
        controller.Save();
        controller = new DisplayProductBulkPoolStagingController();
    
    
        API_Call_Details__c api = testDocumentAPI();
       
        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        
        Test.startTest();   

        DisplayProductBulkPoolStagingController test2 = new DisplayProductBulkPoolStagingController();
        test2.failed = 'Test';
        test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        test2.postDocumentAPI();
        
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }
    
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
    public static testMethod void testDocAPIcall(){
        
        
    }
}