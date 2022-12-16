@isTest
public class TestSnapShotAPIToPortal {
   public static testMethod void testSnapShotApi(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/api/services/';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
       
       
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
       
       Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
       
       Product__c product = new Product__c();
        product.name = 'Test Product';
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product.name = 'Test Product';
        insert product2;
        
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
        productStaging.Status__c = 'Processed';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'SUCCESS';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Processed';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        insert productStaging2;
        
       List<Id> prodIdList = new List<Id>();
       prodIdList.add(product.ID);
       
       Test.startTest();
       SnapShotAPIToPortal.parse(docStorage.ID,prodIdList);
        Test.stopTest();
   }
    
    public static testMethod void testSnapForUniDocId(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/api/services/';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
       
       
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
       
       Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
       
       Product__c product = new Product__c();
        product.name = 'Test Product';
        product.collection_agency__c = 29;
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product2.collection_agency__c = 29;
        insert product2;
        
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
        productStaging.Status__c = 'Processed';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'SUCCESS';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Processed';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        insert productStaging2;
        
       List<Id> prodIdList = new List<Id>();
       prodIdList.add(product.ID);
        
       Datetime myDate = Datetime.now();
            String curreTime = myDate.format('HHmmss');
            string currentDate = Datetime.now().format('yyMMdd');
            String DocumentStorageId = 'DS_ACC'+currentDate+curreTime;
        
       Test.startTest();
       SnapShotAPIToPortal.parse(DocumentStorageId,prodIdList);
       Test.stopTest();
   }
     public static testMethod void testSnapForElse(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
       
       API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test1.com/api/services/';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
       
       
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
       
       Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        insert docStorage;
       
       Product__c product = new Product__c();
        product.name = 'Test Product';
        product.collection_agency__c = 29;
        insert product;
         
        Product__c product2 = new Product__c();
        product2.name = 'Test Product2';
        product2.collection_agency__c = 29;
        insert product2;
        
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
        productStaging.Status__c = 'Processed';
        productStaging.Identifier__c = docStorage.ID;
        productStaging.Placement_Agency__c = '1';
        productStaging.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging.Placement_Status_Code__c = '900000';
        productStaging.Pool_Name_ID__c = poolData.id;
        productStaging.Current_Principal_Balance__c = 5000;
        productStaging.Current_Interest_Balance__c = 400;
        productStaging.Fees__c = 300;
        insert productStaging;
        
        Product_Staging__c productStaging2 = new Product_Staging__c();
        productStaging2.Product_ID__c = product.ID;
        productStaging2.Document_Storage__c = docStorage.ID;
        productStaging2.Comment__c = 'SUCCESS';
        productStaging2.Placement_Agency__c = '1';
        productStaging2.Identifier__c = docStorage.ID;
        productStaging2.Pool_Name_ID__c = poolData.id;
        productStaging2.status__c='Processed';
        productStaging2.Current_Principal_Balance__c = 5000;
        productStaging2.Current_Interest_Balance__c = 400;
        productStaging2.Fees__c = 300;
        insert productStaging2;
        
       List<Id> prodIdList = new List<Id>();
       prodIdList.add(product.ID);
      
       Test.startTest();
       SnapShotAPIToPortal.parse(docStorage.ID,prodIdList);
       Test.stopTest();
   }
}