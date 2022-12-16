/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of DisplayAccStatusUpdateStagingController
 *  @author : A5E Consulting
 *  @date : 21/02/2022
 * 
 *************************************************************************************************/
@isTest
public class TestAccStatusUpdateStagingController {
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
        product.Placement_Status__c = '900000';
        product.Assignment_Date__c = Date.today().addDays(5);
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product2.Placement_Status__c = '900000';
        product2.Assignment_Date__c = Date.today().addDays(5);
        insert product2;
        
        List<Product_Staging__c> listProdStaging = new List<Product_Staging__c>();
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = '<b>ERROR</b> - Account not found.<br/>';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.status__c = 'Pending';
        insert productStaging;
        listProdStaging.add(productStaging);
        
        Product_Staging__c productStaging3 = new Product_Staging__c();
        productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = docStorage.ID;
        productStaging3.Comment__c = 'Success';
        productStaging3.Identifier__c = docStorage.ID;
        productStaging3.Placement_Agency__c = '1';
        productStaging3.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging3.Placement_Status_Code__c = '800000';
        productStaging3.status__c = 'Pending';
        insert productStaging3;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'ERROR';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.status__c = 'Pending';
        insert productStaging2;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        PageReference pageRef = Page.DisplayAccountStatusUpdateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);

        DisplayAccStatusUpdateStagingController controller = new DisplayAccStatusUpdateStagingController();
        controller.getlistProductStagingWrapper();
        DisplayAccStatusUpdateStagingController.productStagingWrapper wrapper = new DisplayAccStatusUpdateStagingController.productStagingWrapper(productStaging2,false);
        controller.isSelected = true;
        
        wrapper.accStaging = productStaging2;
        wrapper.selected = true;
        controller.getTotalPages();
        controller.selectAll();
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.updateSearchItemsMap();
        controller.pageNumber = 2;

    
        API_Call_Details__c api = testDocumentAPI();
       
        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert docAzur; 
        Test.startTest();   
        DisplayAccStatusUpdateStagingController.productStagingWrapper ccisw = new DisplayAccStatusUpdateStagingController.productStagingWrapper(productStaging, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.accStaging = productStaging;
        

        DisplayAccStatusUpdateStagingController test2 = new DisplayAccStatusUpdateStagingController();
        test2.listAccountStaging = listProdStaging;
        test2.setCon = null;
        //test2.failed = 'Test';
        //test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        //test2.postDocumentAPI();
        
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
        Work_Assignment__c workAssignment12 = new Work_Assignment__c();
        workAssignment12.Purpose__c = 'Excel Processing';
        workAssignment12.Sub_Purpose__c = 'Account Status Update File';
        insert workAssignment12;
        
        Placement__c placement= new Placement__c();      
        placement.Name= '9999'; 
        placement.Serviceable_Province__c = 'AB';
        placement.Agency_Name__c = 'Warehouse';
        insert placement; 
        
        Product__c product20 = new Product__c();
        product20.name = 'Test Product2';
        product20.Placement_Status__c = '900000';
        product20.Assignment_Date__c = Date.today().addDays(5);
        insert product20;
        
        Product__c product21 = new Product__c();
        product21.name = 'Test Product3';
        product21.Placement_Status__c = '900000';
        product21.Assignment_Date__c = Date.today().addDays(5);
        insert product21;
        
        Document_Storage__c docStorage22 = new Document_Storage__c();
        docStorage22.Work_Assignment__c = workAssignment12.ID;
        insert docStorage22;

        
        Product_Staging__c productStaging30 = new Product_Staging__c();
        productStaging30.Product_ID__c = product20.ID;
        productStaging30.Document_Storage__c = docStorage22.ID;
        productStaging30.Comment__c = 'Success';
        productStaging30.Identifier__c = docStorage22.ID;
        productStaging30.Placement_Agency__c = '1';
        productStaging30.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging30.Placement_Status_Code__c = '800000';
        insert productStaging30;
        
        Product_Staging__c productStaging31 = new Product_Staging__c();
        productStaging31.Product_ID__c = product21.ID;
        productStaging31.Document_Storage__c = docStorage22.ID;
        productStaging31.Comment__c = 'Success';
        productStaging31.Identifier__c = docStorage22.ID;
        productStaging31.Placement_Agency__c = '1';
        productStaging31.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging31.Placement_Status_Code__c = '800000';
        productStaging31.Status__c = 'Processed';
        insert productStaging31;

        PageReference myVfPage = Page.DisplayAccountStatusUpdateStaging;
        Test.setCurrentPage(myVfPage);
        
        Product_Staging__c prodStagingTest = [Select id, Identifier__c from Product_Staging__c limit 1];
        prodStagingTest.Identifier__c = prodStagingTest.Id;
        //prodStagingTest.Name = 'Test';
        update prodStagingTest;
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        API_Call_Details__c api = testDocumentAPI();

        test.startTest();
        String failed;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed =  'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality';//,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        DocumentAPIClientUtil.ParsedResponse res = DocumentAPIClient.postDocument(bl, 'Customer Contact Information Failed.csv', 'Task');
        DocumentAPIClient.getDocument(docAzur.Document_ID__c);
        //DocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        test.stopTest();

        List<Product_Staging__c> prodStagingTest1 = [Select id,Identifier__c from Product_Staging__c where Identifier__c =: prodStagingTest.Id limit 1];
       // Put Id into the current page Parameters
      ApexPages.currentPage().getParameters().put('id',prodStagingTest1[0].Identifier__c);




        DisplayAccStatusUpdateStagingController instance1 = new DisplayAccStatusUpdateStagingController();
        instance1.getlistProductStagingWrapper();
        instance1.isSelected = true;
            
        //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(prodStagingTest1);
        //instance1.SetCon();
      //setCon.setSelected(prodStagingTest1);
      //instance1.isSelected = true;
      
            
        DisplayAccStatusUpdateStagingController.productStagingWrapper ccisw = new DisplayAccStatusUpdateStagingController.productStagingWrapper(prodStagingTest, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.accStaging = prodStagingTest;
        
        DisplayAccStatusUpdateStagingController.productStagingWrapper testWrap=new DisplayAccStatusUpdateStagingController.productStagingWrapper(prodStagingTest,false); 
        testWrap.selected = true;
       
       instance1.saveSelectiveRecords();
       instance1.isSelected= true;

       instance1.saveAllRecords();
       //instance1.first();
       instance1.next();
       //instance1.last();
       instance1.previous();
       instance1.getTotalPages();
       instance1.selectAll();


       //instance1.postDocumentAPI();
       instance1.save();


    }
    
    public static testMethod void testAccStatusUpdateSetController(){
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
        product.Assignment_Date__c = Date.today().addDays(5);
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product2.Assignment_Date__c = Date.today().addDays(5);
        insert product2;
        
        List<Product_Staging__c> listProdStaging = new List<Product_Staging__c>();
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'Success';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        insert productStaging;
        listProdStaging.add(productStaging);
        
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
        
        //ApexPages.StandardSetController sc = new ApexPages.StandardSetController();
       PageReference pageRef = Page.DisplayAccountStatusUpdateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);

        DisplayAccStatusUpdateStagingController controller = new DisplayAccStatusUpdateStagingController();
        //controller.listProductStagingWrapper[0].selected = true;
        //controller.updateSearchItemsMap();
        //system.debug('test.listProductStagingWrapper:'+controller.listProductStagingWrapper.size());
       /* controller.listProductStagingWrapper[0].selected = true;
        controller.listProductStagingWrapper[1].selected = true;
        controller.listProductStagingWrapper[2].selected = false;
        //test.listProductStagingWrapper[2].selected = true;
        controller.Save();
        controller = new DisplayAccStatusUpdateStagingController();*/
    
    
        API_Call_Details__c api = testDocumentAPI();
       
        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert docAzur; 
        Test.startTest();   
        DisplayAccStatusUpdateStagingController.productStagingWrapper ccisw = new DisplayAccStatusUpdateStagingController.productStagingWrapper(productStaging, False);
        ccisw.selected = true;
        ccisw.disabled = true;
        ccisw.accStaging = productStaging;
        
            
        DisplayAccStatusUpdateStagingController test2 = new DisplayAccStatusUpdateStagingController();
        test2.listAccountStaging = listProdStaging;
        test2.setCon = null;
        //test2.failed = 'Test';
        //test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        //test2.postDocumentAPI();
        
        Test.stopTest();
        ProductTriggerHandler.runProductTrigger = true;
    }
    

    
}