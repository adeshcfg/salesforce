@isTest
public class TestCustomerContactInfoStagingController {
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
    public static API_Call_Details__c testDocumentAPI(){
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
        return settings;
      
    }
    public static testMethod void testCustomerContactInfoUpdate(){
         Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c api = testDocumentAPI();
        String success;
        String failed;
        Boolean SuccessHasRecord;
        Boolean FailedHasRecord;
        Date dT = System.Today();
        list<Product__c> listProd = new list<Product__c>();
        Id workAssignmentId;
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Status Update' + Date.today();
        workAssignment.Description__c = 'Product Status Update Status';
        workAssignment.Status__c = 'Completed'; 
        workAssignment.Assign_To__c = 'Agency';
        workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.id = workAssignmentId ;
        workAssignment.Sub_Purpose__c = 'Customer Contact Information Update File';
        insert workAssignment;
        
        workAssignmentId = workAssignment.Id;
        
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        failedDocStorage.Work_Assignment__c = workAssignmentID;    
        failedDocStorage.Document_Name__c = 'Product Failed.csv';
        failedDocStorage.Document_Extension__c = 'csv';
        failedDocStorage.Document_Type__C = 'Payment Processing File';
        failedDocStorage.Visibility__c = 'Authoring agencies + CFG  ';
        failedDocStorage.Uploaded_By__c = 'Internal User';
        failedDocStorage.Creator__c = UserInfo.getName();
        failedDocStorage.File_Processing_Date__c = dt;
        failedDocStorage.Document_Related_To__c = 'Task';
        failedDocStorage.File_Processing_Status__c = 'PROCESSED';         
        insert failedDocStorage;
        
        Customer_Staging__c custStaging = new Customer_Staging__c();       
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c= '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Pending';
        custStaging.Document_Storage__c = failedDocStorage.id;  
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper ccisw = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(custStaging, false);
        
        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;

        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.PersonBirthdate = system.today().addYears(-20);
        accInstance.PersonMailingStreet = '3024 Port Street';
        accInstance.PersonMailingCity = 'T';
        accInstance.PersonMailingState = 'ON';
        accInstance.PersonMailingPostalCode = '91762';
        accInstance.PersonHomePhone = '613-555-0172';
        accInstance.Work_Phone__pc = '613-555-0162';
        accInstance.PersonOtherPhone = '613-555-0122';
        accInstance.PersonEmail = 'annatestt@email.com';
        accInstance.SIN__pc = '0123';
        Insert accInstance;
        
        Product__c product = new Product__c();
        product.Name = custStaging.ProdID__c;  
        product.customer__c = accInstance.id;
        product.Status__c = 'New Allocation - New Allocation';
        product.Sub_Status__c = 'Ready';
        product.Product_Status__c = 'Test';
        insert product;
        
        Product__c prod =  new Product__c();
        prod.Name = custStaging.ProdID__c;
        prod.id = product.id;
        listProd.add(prod);
        
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        
        DisplayCustomerContInfoStagingController send = new DisplayCustomerContInfoStagingController();
        send.save();
    }
 public static testMethod void testCustomerContactInfoUpdate2(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c api = testDocumentAPI();
        String success;
        String failed;
        Boolean SuccessHasRecord;
        Boolean FailedHasRecord;
        Date dT = System.Today();
        list<Product__c> listProd = new list<Product__c>();
        Id workAssignmentId;
     
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Status Update' + Date.today();
        workAssignment.Description__c = 'Product Status Update Status';
        workAssignment.Status__c = 'Completed';  
        workAssignment.Assign_To__c = 'Agency';
        workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.Sub_Purpose__c = 'Customer Contact Information Update File';
     	workAssignment.Comments_History__c = 'test';
        insert workAssignment;
     
        workAssignmentId = workAssignment.id;
                
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        failedDocStorage.Work_Assignment__c = workAssignmentID;    
        failedDocStorage.Document_Name__c = 'Product Failed.csv';
        failedDocStorage.Document_Extension__c = 'csv';
        failedDocStorage.Document_Type__C = 'Payment Processing File';
        failedDocStorage.Visibility__c = 'Authoring agencies + CFG  ';
        failedDocStorage.Uploaded_By__c = 'Internal User';
        failedDocStorage.Creator__c = UserInfo.getName();
        failedDocStorage.File_Processing_Date__c = dt;
        failedDocStorage.Document_Related_To__c = 'Task';
        failedDocStorage.File_Processing_Status__c = 'PROCESSED';     
        insert failedDocStorage;

        
        Customer_Staging__c custStaging = new Customer_Staging__c();       
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c= '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;  
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper ccisw = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(custStaging, false);
        
        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;
         
        Account accInstance = new Account();
        accInstance.FirstName = 'Ana';
        accInstance.LastName = 'Starrk';
        accInstance.PersonBirthdate = system.today().addYears(-20);
        accInstance.PersonMailingStreet = '3024 Port Street';
        accInstance.PersonMailingCity = 'T';
        accInstance.PersonMailingState = 'ON';
        accInstance.PersonMailingPostalCode = '91762';
        accInstance.PersonHomePhone = '613-555-0172';
        accInstance.Work_Phone__pc = '613-555-0162';
        accInstance.PersonOtherPhone = '613-555-0122';
        accInstance.PersonEmail = 'annatestt@email.com';
        accInstance.SIN__pc = '0123';
        Insert accInstance;
        
        Product__c product = new Product__c();
        product.Name = custStaging.ProdID__c;  
        product.customer__c = accInstance.id;
        product.Status__c = 'New Allocation - New Allocation';
        product.Sub_Status__c = 'Ready';
        product.Product_Status__c = 'Test';
        insert product;
        
        Product__c prod =  new Product__c();
        prod.Name = custStaging.ProdID__c;
        prod.id = product.id;
        listProd.add(prod);

        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        
        DisplayCustomerContInfoStagingController send = new DisplayCustomerContInfoStagingController();
        send.save();
    }
    
    public static testMethod void testDocAPIcall(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c api = testDocumentAPI();
       
        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert   docAzur; 
        
        test.startTest();
        String failed;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed =  'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality';//,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        DocumentAPIClientUtil.ParsedResponse res = DocumentAPIClient.postDocument(bl, 'Customer Contact Information Failed.csv', 'Task');
        DocumentAPIClient.getDocument(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        test.stopTest();
    }
}