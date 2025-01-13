/**
 * @description       : Test class for DisplayProductStatusStagingController
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-13-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class TestProductStatusStagingController {
    @testSetup
    static void testData() {
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

        list<Agency_Portal_Fields_Mapping__c> listmapping = new List<Agency_Portal_Fields_Mapping__c>();
        Agency_Portal_Fields_Mapping__c mapping1 = new Agency_Portal_Fields_Mapping__c(Name = 'Name', Object_Name__c = 'Product', Field_API__c = 'Name');
        listmapping.add(mapping1);
        Agency_Portal_Fields_Mapping__c mapping2 = new Agency_Portal_Fields_Mapping__c(
            Name = 'Product_Status',
            Object_Name__c = 'Product',
            Field_API__c = 'Product_Status__c'
        );
        listmapping.add(mapping2);
        insert listmapping;

        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Status Update File';
        insert workAssignment;

        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
    }

    @isTest
    static void testAccStatusUpdate() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Document_storage__c docStorage = [SELECT Id, Work_Assignment__c FROM Document_Storage__c LIMIT 1];

        ProductTriggerHandler.runProductTrigger = false;
        ProductTriggerHandler.runProductAPI = false;
        Product__c product = new Product__c();
        product.name = 'Test Product';
        insert product;

        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        insert product2;

        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'WARNING';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Product_Status__c = '201000';
        insert productStaging;

        Product_Staging__c productStaging3 = new Product_Staging__c();
        productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = docStorage.ID;
        productStaging3.Comment__c = 'Success';
        productStaging3.Identifier__c = docStorage.ID;
        productStaging.Product_Status__c = '201010';
        insert productStaging3;

        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'ERROR';
        productStaging.Product_Status__c = '201010';
        insert productStaging2;

        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        PageReference pageRef = Page.DisplayProductStatusStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);

        DisplayProductStatusStagingController controller = new DisplayProductStatusStagingController();
        DisplayProductStatusStagingController.productStagingWrapper wrap = new DisplayProductStatusStagingController.productStagingWrapper(
            productStaging,
            true
        );
        wrap.selected = true;
        DisplayProductStatusStagingController.productStagingWrapper wrap1 = new DisplayProductStatusStagingController.productStagingWrapper(
            productStaging3,
            true
        );
        DisplayProductStatusStagingController.productStagingWrapper wrap2 = new DisplayProductStatusStagingController.productStagingWrapper(
            productStaging2,
            false
        );
        List<DisplayProductStatusStagingController.productStagingWrapper> wrapList = new List<DisplayProductStatusStagingController.productStagingWrapper>();
        wrapList.add(wrap);
        wrapList.add(wrap1);
        wrapList.add(wrap2);
        API_Call_Details__c api = TestBuybackPutbackStagingController.testDocumentAPI();
        Test.startTest();
        DisplayProductStatusStagingController test2 = new DisplayProductStatusStagingController();
        test2.listProductStagingWrapper = wrapList;
        test2.isSelected = true;
        test2.failed = 'Test';
        test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        test2.updateSearchItemsMap();
        test2.updateSet();
        test2.save();
        test2.selectAll();
        // test2.save();
        test2.last();
        test2.previous();
        test2.getAllRecords();
        test2.first();
        test2.next();
        test2.getTotalPages();
        test2.getlistProductStagingWrapper();
        test2.isSelected = false;
        test2.save();
        test2.getlistProductStagingWrapper();
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }

    @isTest
    static void testAlreadyProcessed() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Document_storage__c docStorage = [SELECT Id, Work_Assignment__c FROM Document_Storage__c LIMIT 1];
        docStorage.File_Processing_Status__c = DisplayProductStatusStagingController.PROCESSED;
        update docStorage;
        ProductTriggerHandler.runProductTrigger = false;
        ProductTriggerHandler.runProductAPI = false;
        Product__c product = new Product__c();
        product.name = 'Test Product';
        insert product;

        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'WARNING';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Product_Status__c = '201000';
        insert productStaging;

        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        PageReference pageRef = Page.DisplayProductStatusStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);
        DisplayProductStatusStagingController test2 = new DisplayProductStatusStagingController();
    }
}
