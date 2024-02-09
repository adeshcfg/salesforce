@isTest
public class TestDisplayProductAllocStagController {
    @testSetup
    static void testData(){
        Placement__c placement = new Placement__c();
        placement.name = '1';
        insert placement;            
        
        Placement_Status_Code_Mapping__c PlacementCode = new Placement_Status_Code_Mapping__c();
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
        
        Agency_Portal_Fields_Mapping__c mapping3 = new Agency_Portal_Fields_Mapping__c(Name = 'Sent_for_Review_Date', Object_Name__c = 'Product', 
                                                                                       Field_API__c = 'Sent_to_Review_Date__c',
                                                                                       Field_Type__c = 'DateTime');
        
        listmapping.add(mapping3);
        
        Agency_Portal_Fields_Mapping__c mapping4 = new Agency_Portal_Fields_Mapping__c(Name = 'Placement_Status', Object_Name__c = 'Product', 
                                                                                       Field_API__c = 'Placement_Status__c');
        listmapping.add(mapping4);
        
        Agency_Portal_Fields_Mapping__c mapping5 = new Agency_Portal_Fields_Mapping__c(Name = 'Collection_Agency', Object_Name__c = 'Product', 
                                                                                       Field_API__c = 'Collection_Agency__c');
        listmapping.add(mapping5);
        Agency_Portal_Fields_Mapping__c mapping6 = new Agency_Portal_Fields_Mapping__c(Name = 'Placement_Agency', Object_Name__c = 'Product_Staging__c', 
                                                                                       Field_API__c = 'Placement_Agency__c');
        listmapping.add(mapping6); 
        insert listmapping;
        
        
    }
    
    public static testMethod void testAccStatusUpdate(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
      API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';//endpointurl
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Account Status Update File';
        insert workAssignment;
        
        Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Payment Upload File';
        insert workAssignment1;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        
         Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        insert docStorage1;
        
        Product__c product = new Product__c();
        product.name = 'Test Product';
        product.Sent_to_Review_Date__c = date.today();
        product.Purchase_Province__c = 'AB';
        insert product;
        
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product2.Sent_to_Review_Date__c = date.today();
        product2.Purchase_Province__c = 'AB';
        insert product2;
        
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Account_ID__c = product.id;
        prodExt.Description__c = 'Test data';
        insert prodExt;
        
        Product_Extension__c prodExt1 = new Product_Extension__c();
        prodExt1.Account_ID__c = product2.id;
        prodExt1.Description__c = 'Test data';
        insert prodExt1;
        
        Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'SUCCESS';
        productStaging.status__c='Pending';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today()+5);
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'ERROR';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Pending';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        productStaging.Placement_Status_Code__c='900000';
        insert productStaging2;
        
        Product_Staging__c productStaging3 = new Product_Staging__c();
        productStaging3.Product_ID__c = product2.ID;
        productStaging3.Document_Storage__c = docStorage.ID;
        productStaging3.Comment__c = 'SUCCESS';
        productStaging3.Identifier__c = docStorage.ID;
        productStaging3.Placement_Agency__c = '1';
        productStaging3.Status_Changed_Date__c = String.valueOf(Date.today()-5);
        productStaging3.Placement_Status_Code__c = '900000';
        productStaging3.Pool_Name_ID__c = poolData.id;
        productStaging3.status__c='Processed';
        productStaging3.Current_Principal_Balance__c = 5000;
        productStaging3.Current_Interest_Balance__c = 400;
        productStaging3.Fees__c = 300;
        productStaging3.Include_in_Processing__c =true;
        insert productStaging3;
        
        list<Product_Staging__c>  listprg = new list<Product_Staging__c>() ;  
        listprg.add(productStaging2);
        listprg.add(productStaging3);
        
        PageReference pageRef = Page.DisplayProductAllocateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        
        DisplayProductAllocateStagingController controller = new DisplayProductAllocateStagingController();
        controller.isSelected = true;
        controller.getlistProductStagingWrapper();
        
        DisplayProductAllocateStagingController.productStagingWrapper wrapper = new DisplayProductAllocateStagingController.productStagingWrapper(productStaging2,false);
        //controller.isSelected = true;
        
        wrapper.productStaging = productStaging2;
        wrapper.selected = true;
        controller.getTotalPages();
        controller.selectAll();
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.updateSearchItemsMap();
        controller.listAccountStaging = listprg;
        controller.listProductStaging = listprg;
        controller.executeWarning = false;
        controller.pageNumber = 2;
        controller.showHide = 'hidden';
        controller.recordIdentfier=String.valueOf(docStorage.Id);
        controller.SaveRecords();
        
        set<string> successStringSet = new set<string>();
        successStringSet.add('test');
        set<string> failedStringSet =  new set<string>();
        failedStringSet.add('test');
        //DisplayProductAllocateStagingController.postDocumentAPI(docStorage.id, workAssignment.id, 2, 2, successStringSet, failedStringSet, 'test', 'test', listprg,'Account Status Update File');
        
        Test.startTest();   
        DisplayProductAllocateStagingController test2 = new DisplayProductAllocateStagingController();
        test2.getlistProductStagingWrapper();
        test2.failed = 'Test';
        test2.success = 'Test';
        test2.failedRecords = 1;
        test2.successRecords = 2;
        id jobid = database.executeBatch(new CFG_ProcessSuccessRecords(workAssignment.id,docStorage.id,'Product Allocation File')); 
        Test.stopTest();
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
    
    public static testMethod void testAccStatusUpdate1(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        API_Call_Details__c api = testDocumentAPI();
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Account Status Update File';
        workAssignment.Comments_History__c = 'testing';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        
        Product__c product = new Product__c();
        product.name = 'Test Product';
        product.Purchase_Province__c = 'AB';
        product.Placement_Status__c='900000';
        insert product;
        
        Placement__c placement1 = new Placement__c();
        placement1.name = '11';
        insert placement1;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
        
        Product__c prod=new Product__C();
        prod.Pool_Name__c = poolData.id;
        prod.Name ='647P1545';
        prod.Collection_Agency_Placement__c = placement1.id;
        prod.Purchase_Province__c = 'AB';
        prod.Placement_Status__c='900000';
        insert prod;
        
        List<Product__c> prodNew = new List<Product__c>();
        prodNew.add(prod);
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'ERROR - Testing';
        productStaging.status__c='Pending';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Placement_Status_Code__c='900000';
        insert productStaging;
        
        Product_Staging__c productStaging1 = new Product_Staging__c();
        productStaging1.Product_ID__c = prod.ID;
        productStaging1.Document_Storage__c = docStorage.ID;
        productStaging1.Comment__c = 'Testing';
        productStaging1.Include_in_Processing__c = true;
        productStaging1.status__c='Pending';
        productStaging1.Identifier__c = docStorage.ID;
        productStaging1.Placement_Agency__c = '1';
        productStaging1.Pool_Name_ID__c = poolData.id;
        productStaging1.Placement_Status_Code__c='900000';
        insert productStaging1;
        list<Product_Staging__c>  listprg = new list<Product_Staging__c>() ;  
        listprg.add(productStaging);
        
        PageReference pageRef = Page.DisplayProductAllocateStaging;
        pageRef.getParameters().put('id', String.valueOf(docStorage.Id));
        pageRef.getParameters().put('docType', String.valueOf('Account Allocation File'));
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(docStorage);
        
        DisplayProductAllocateStagingController controller = new DisplayProductAllocateStagingController();
        DisplayProductAllocateStagingController.getSnapshortRecords(prodNew);
        DisplayProductAllocateStagingController.getSnapshortRecordsTwo(prodNew);
        controller.getlistProductStagingWrapper();
        
        DisplayProductAllocateStagingController.productStagingWrapper wrapper = new DisplayProductAllocateStagingController.productStagingWrapper(productStaging,false);
        
        wrapper.productStaging = productStaging;
        wrapper.selected = false;
        
        controller.getTotalPages();
        controller.selectAll();
        controller.first();
        controller.last();
        controller.previous();
        controller.next();
        controller.updateSearchItemsMap();
        controller.listAccountStaging = listprg;
        controller.listProductStaging = listprg;
        controller.executeWarning = false;
        controller.pageNumber = 2;
        controller.showHide = 'hidden';
        controller.recordIdentfier=String.valueOf(docStorage.Id);
        controller.SaveRecords();
        
        set<string> successStringSet = new set<string>();
        successStringSet.add('test');
        set<string> failedStringSet =  new set<string>();
        failedStringSet.add('test');
        //DisplayProductAllocateStagingController.postDocumentAPI(docStorage.id, workAssignment.id, 2, 2, successStringSet, failedStringSet, 'test', 'test', listprg,'Product Allocation File');
        
        Test.startTest();   
        // RecallProductProcessing.recallProducts(listprg, 'workAssignmentId');
        DisplayProductAllocateStagingController test2 = new DisplayProductAllocateStagingController();
        test2.getlistProductStagingWrapper();
        test2.failed = 'Test';
        test2.success = 'Test';
        test2.failedRecords = 0;
        test2.successRecords = 0;
       id jobid = database.executeBatch(new CFG_ProcessSuccessRecords(workAssignment.id,docStorage.id,'Product Allocation File')); 
        // CFG_ProcessSuccessRecords obj1 = new CFG_ProcessSuccessRecords(workAssignment.id,docStorage.id,'allocate'); 
       // obj.execute(null,listprg);
        //CFG_ProductBulkApiProcess.successErrorfileAccStatusUpdate(docStorage.id,'Account Status Update File');
        //CFG_ProductBulkApiProcess.successErrorfileAccStatusUpdate(docStorage.id,'Product Payment Upload File');
        Test.stopTest();
    }
    @istest
    static void testRecallProductProcessing(){
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Account Status Update File';
        workAssignment.Comments_History__c = 'testing';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
        
        Product__c product = new Product__c();
        product.name = 'Test Product';
        product.Purchase_Province__c = 'AB';
        product.Placement_Status__c='900000';
        product.Collection_Agency__c=88;
        insert product;        
        Product__c product1 = new Product__c();
        product1.name = 'Test Product';
        product1.Purchase_Province__c = 'AB';
        product1.Placement_Status__c='800000';
        product1.Collection_Agency__c=88;
        insert product1;  
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = product.ID;
        productStaging.Document_Storage__c = docStorage.ID;
        productStaging.Comment__c = 'ERROR - Testing';
        productStaging.status__c='Pending';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Placement_Status_Code__c='800000';
        //    productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        
        insert productStaging;
        
        Placement_Status_Code_Mapping__c PlacementCode = new Placement_Status_Code_Mapping__c();
        PlacementCode.name = '800000';
        PlacementCode.Parent_Status__c = 'New Allocation';
        PlacementCode.Status__c = 'New Allocation';
        PlacementCode.Sub_Status__c = 'Ready';
        PlacementCode.Placement_Status_Code__c = '800000';
        placementCode.Data_Status_Code__c = '200000';
        insert PlacementCode;
        map<String, Placement_Status_Code_Mapping__c> codeMapping = new map<String, Placement_Status_Code_Mapping__c>();
        codeMapping.put(PlacementCode.name,PlacementCode);
        list<Product_Staging__c>  listprg = new list<Product_Staging__c>() ;  
        listprg.add(productStaging);
        RecallProductProcessing.recallProducts(listprg, 'workAssignmentId');
        AllocationProductProcessing.allocateProducts(listprg, 'workAssignmentId');
    }
}