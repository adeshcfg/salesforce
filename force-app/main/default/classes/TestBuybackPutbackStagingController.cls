@isTest
public class TestBuybackPutbackStagingController {
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
        workAssignment.Sub_Purpose__c = 'Product Buyback/Putback File';
        insert workAssignment;

        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        docStorage.Document_Type__c = DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE;
        insert docStorage;

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
        productStaging.Comment__c = 'Success';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Putback_Buyback_Amount__c = 100;
        insert productStaging;

        Product_Staging__c productStaging3 = new Product_Staging__c();
        productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = docStorage.ID;
        productStaging3.Comment__c = 'Success';
        productStaging3.Identifier__c = docStorage.ID;
        productStaging3.Placement_Agency__c = '1';
        productStaging3.Putback_Buyback_Amount__c = 200;
        insert productStaging3;

        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'ERROR';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging3.Putback_Buyback_Amount__c = 300;
        insert productStaging2;

        testDocumentAPI();
    }

    public static testMethod void testPutbackStatusUpdate() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

        Document_Storage__c docStorage = [SELECT Id, Document_Type__c, Work_Assignment__c FROM Document_Storage__c LIMIT 1];
        List<Product_Staging__c> listProductStaging = [
            SELECT Id, Product_ID__c, Document_Storage__c, Comment__c, Placement_Agency__c, Identifier__c, Putback_Buyback_Amount__c
            FROM Product_Staging__c
            ORDER BY Putback_Buyback_Amount__c
        ];

        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        PageReference pageRef = Page.DisplayAccountStatusUpdateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);

        DisplayBuybackPutbackStagingController controller = new DisplayBuybackPutbackStagingController();
        DisplayBuybackPutbackStagingController.productStagingWrapper wrap = new DisplayBuybackPutbackStagingController.productStagingWrapper(
            listProductStaging[0],
            true
        );
        wrap.selected = true;
        DisplayBuybackPutbackStagingController.productStagingWrapper wrap1 = new DisplayBuybackPutbackStagingController.productStagingWrapper(
            listProductStaging[2],
            true
        );
        DisplayBuybackPutbackStagingController.productStagingWrapper wrap2 = new DisplayBuybackPutbackStagingController.productStagingWrapper(
            listProductStaging[1],
            false
        );
        List<DisplayBuybackPutbackStagingController.productStagingWrapper> wrapList = new List<DisplayBuybackPutbackStagingController.productStagingWrapper>();
        wrapList.add(wrap);
        wrapList.add(wrap1);
        wrapList.add(wrap2);
        Test.startTest();
        DisplayBuybackPutbackStagingController test2 = new DisplayBuybackPutbackStagingController();
        test2.listProductStagingWrapper = wrapList;
        test2.isSelected = true;
        test2.failed = 'Test';
        test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        test2.save();
        test2.selectAll();
        test2.updateSearchItemsMap();
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

    public static testMethod void testAccStatusUpdate() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Document_Storage__c docStorage = [SELECT Id, Document_Type__c, Work_Assignment__c FROM Document_Storage__c LIMIT 1];
        Test.startTest();
        DisplayBuybackPutbackStagingController.generateSuccessErrorFiles(
            docStorage.Id,
            docStorage.Work_Assignment__c,
            DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE
        );
        Test.stopTest();
    }

    public static API_Call_Details__c testDocumentAPI() {
        API_Call_Details__c settings = new API_Call_Details__c();
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
}
