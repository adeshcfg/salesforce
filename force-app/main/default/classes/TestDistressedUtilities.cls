@isTest
public class TestDistressedUtilities {
    static testMethod void dissUtility(){
        
        
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
        
        map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
        system.debug('placementStatusMap::'+placementStatusMap);
        Placement_Status_Mapping__c placeStatusCode = new Placement_Status_Mapping__c();
        placeStatusCode.Name = '100010';
        placeStatusCode.Description__c ='Demand Letters - In Process - Initial Letter Sent';
        insert placeStatusCode;
        
        Placement_Status_Mapping__c placeStatusCode1 = new Placement_Status_Mapping__c();
        placeStatusCode1.Name = '900010';
        placeStatusCode1.Description__c ='Demand Letters - Media Requested';
        insert placeStatusCode1 ;
        
        Placement_Status_Mapping__c placeStatusCode2 = new Placement_Status_Mapping__c();
        placeStatusCode2.Name = '100000';
        placeStatusCode2.Description__c ='New Allocation - New AllocationReady';
        insert placeStatusCode2 ;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Status__c';
        FieldMap.Field_JSON_Tag__c ='Status';
        FieldMap.Object_Name__c = 'Settlement';
        FieldMap.Name = 'Status';        
        insert FieldMap;
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        docStorage.Uploaded_By__c = 'External User';
        insert docStorage;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        poolData.Commission_Rate__c=2;
             //poolData.Name='test';
        insert poolData;
        
        Map<ID, Pool__c> poolMap = new Map<ID, Pool__c>();
        poolMap.put(poolData.id,poolData);
        
        List<Product__c> prodList = new List<Product__c>();
        
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
       prod2.Data_Status_Description__c='Closed test';
        prod2.Last_Name__c = 'xyz';
        prod2.Recoverable_Fee__c =123;
        //prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c =null;
        prod2.Purchase_Status__c = 'Buyback/Putback Approved';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prod2.Recoverable_Fee__c = 100;
        prod2.Allocated_Amount_Principal__c = 200;
        prod2.Allocated_Amount_Interest__c = 300;
        prod2.Commission_Rate_at_Time_of_Placement__c=2;
        prod2.Commission_Rate__c=4;
        prod2.Settlement_Rate__c=5;
        prod2.Value_Tier_at_Time_of_Placement__c='A';
        prod2.Placed_Settlement_Rate__c=5;
        prod2.Current_Bal_NSF_Fees__c = 400;
        prod2.Purchase_Province__c ='AB';
        prod2.State__c='Ontario';
        prod2.Collection_Sub_Status__c='Credit Counselling';
        insert prod2;
Product__c prod3= new Product__c();
       // List<User> systemName=[Select Name from User where Name ='System API'];
        prod3.name = '12345';
        prod3.Internal_Status__c = 'Active';
        prod3.Payment_Setup_Status__c = 'Automated';
        prod3.Funding_Status__c = 'Funded';
        prod3.Funding_Type__c = 'Automated';
        prod3.Disbursement_Amount__c = 3000.00;
        prod3.Collection_Agency__c = 30;
        prod3.Current_Balance__c = 7730;
        prod3.Current_Principal_Balance__c = 5000;
        prod3.Current_Interest_Amount__c = 2730;
        prod3.Data_Status_Description__c='Insolvency test';
        prod3.product_status__C = '310000';
        prod3.Current_Workflow__c = 'Collection Process';
        prod3.Requested_Close_Date__c = System.Today();
        prod3.Status__c = 'New Allocation - New Allocation';
        prod3.Sub_Status__c = 'Ready';
        prod3.Product_Status__c = 'Test';
        prod3.Last_Name__c = 'xyz';
        //prod2.Pool_Name__c = pool.id;
        prod3.Placement_Status__c = '100010';
        prod3.Credit_Counselling_Date__c =null;
        prod3.Purchase_Status__c = 'Buyback/Putback Approved';
        prod3.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prod3.Recoverable_Fee__c = 100;
        prod3.Allocated_Amount_Principal__c = 200;
        prod3.Allocated_Amount_Interest__c = 300;
        prod3.Commission_Rate_at_Time_of_Placement__c=2;
        prod3.Commission_Rate__c=4;
        prod3.Settlement_Rate__c=5;
        prod3.Value_Tier_at_Time_of_Placement__c='A';
        prod3.Placed_Settlement_Rate__c=5;
        prod3.Recoverable_Fee__c = 100;
        prod3.Allocated_Amount_Principal__c = 200;
        prod3.Allocated_Amount_Interest__c = 300;
        prod3.Current_Bal_NSF_Fees__c = 400;
        prod3.Purchase_Province__c ='AB';
        prod3.State__c='Ontario';
        prod3.Collection_Sub_Status__c='Cease and Desist – In Writing';
        insert prod3;
       Product__c prod4= new Product__c();
                prod4.Data_Status_Description__c='Insolvent test';
                    prod4.Collection_Sub_Status__c='Buy back/put back and sale categories';
insert prod4;
   Product__c prod5= new Product__c();
                prod5.Collection_Sub_Status__c='Paid in Full Account';
//insert prod5;  
        Product__c prod6= new Product__c();
                prod6.Collection_Sub_Status__c='Fraud Claimed';
//insert prod6;
        Settlement__c settle = new Settlement__c();
        settle.Product__c = prod2.Id;
        settle.Status__c = 'Ready for review';
        insert settle;
        
        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Product_ID__c = prod2.ID;
        productStaging.Data_Id__c = prod2.Name;
        productStaging.Name__c = prod2.Name;
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
        productStaging.Status_Changed_Date_Text__c = '27/03/2023';
        productStaging.Status_Changed_Date__c ='27/03/2023';
        productStaging.Fees__c = 300;
      //  productStaging.Pool_Name__c='test';
        insert productStaging;
        
        List<Product_staging__c> prodStagingList = new List<Product_staging__c>();
        prodStagingList.add(productStaging);
        
        Map<String, Product__c> mapProductName = new Map<String, Product__c>();
        Map<String ,Pool__C> poolMap1 = new Map<String ,Pool__C>();
        
        mapProductName.put(prod2.name,prod2);
        mapProductName.put(prod3.name,prod3);
        mapProductName.put(prod4.name,prod4);
        poolMap1.put(poolData.name,poolData);
        
        Map<ID, Product__c> prodMap = new Map<ID, Product__c>();
        prodMap.put(prod2.id, prod2);
        prodMap.put(prod3.id, prod3);
        prodMap.put(prod4.id, prod4);
        
        Placement__c place = new Placement__c();
        place.name = '1';
        place.Commission_Rate__c=8;
        place.Serviceable_Province__c='test';
        insert place;
        
        Map<String, Placement__c> placeMap = new Map<String, Placement__c>();
        placeMap.put(place.name,place);
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod2.id;
        placeHist.Placement_ID_Text__c = '1';
        insert placeHist;
        
        prod2.Placement_Status__c = '900010';
        update prod2;
        
        prodList.add(prod2);
        
        List<ID> prodIdList = new List<ID>();
        map<ID, String> placeStatus = new map<ID, String>();
        
        placeStatus.put(prod2.id,productStaging.Placement_Status_Code__c);
        prodIdList.add(prod2.id);        
          Placement_history__c placementhistorycObj = new Placement_history__c (
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = place.id
            
        );
        placementhistorycObj.Placement_Status__c='test';
        insert placementhistorycObj;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        //DistressedUtilities.UpdateSettlement(prodIdList);
        
        DistressedUtilities.createPlacementHistory(prodList,place.id,10.2,null);
        
        DistressedUtilities.createPlaceHistoryAlloExcel(productStaging,prod2,placeMap,poolMap);
        
        DistressedUtilities.createPlaceHistoryAlloExcel_New(productStaging,prod2,placeMap,poolMap);
        
        DistressedUtilities.updatePlacementHistory(prod2.id,placeStatusCode1.name);
        
        DistressedUtilities.updatePlacementHistory_New(prodIdList,placeStatus);
        
        DistressedUtilities.allocationValidationOnRecordUpdate(prodStagingList, prodList, mapProductName, docStorage.id, poolMap1);
        
        system.debug('mapProductName::::'+mapProductName);
        prod2.Collection_Agency__c = 30;
        update prod2;
        DistressedUtilities.recallValidationOnRecordUpdate(prodStagingList, prodList, mapProductName, docStorage.id, workAssignment.id, docStorage);
        
        set<string> successStringSet = new set<string>();
        successStringSet.add('test');
        set<string> failedStringSet =  new set<string>();
        failedStringSet.add('test');
        DistressedUtilities.postDocumentAPI(docStorage.id, workAssignment.id, 2, 2, successStringSet, failedStringSet, 'test', 'test', prodStagingList,'Account Status Update File');
        
              
    }
      ////////////////////////////////////////////////////////////////////////// Test Data AND Method changes by me//////////////////////////////////////////////////////////////////////////////////////////// 
        static testMethod void disThirdByMe(){
            
      
        Work_Assignment__c workAssignment1 = new Work_Assignment__c();
        workAssignment1.Purpose__c = 'Excel Processing';
        workAssignment1.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment1;
        
        Document_Storage__c docStorage1 = new Document_Storage__c();
        docStorage1.Work_Assignment__c = workAssignment1.ID;
        docStorage1.Uploaded_By__c = 'External User';
        insert docStorage1;
            
        Pool__c poolData1 = new Pool__c();
        poolData1.Placement_Agency__c = 89;
        poolData1.Commission_Rate__c=2;
             //poolData.Name='test';
        insert poolData1;
        
        Map<ID, Pool__c> poolMap1 = new Map<ID, Pool__c>();
        poolMap1.put(poolData1.id,poolData1);
            
            
        List<Product__c> prodList1 = new List<Product__c>();
        
        Product__c prodd2= new Product__c();
        List<User> systemNamee=[Select Name from User where Name ='System API'];
        prodd2.name = '12345';
        prodd2.Internal_Status__c = 'Active';
        prodd2.Payment_Setup_Status__c = 'Automated';
        prodd2.Funding_Status__c = 'Funded';
        prodd2.Funding_Type__c = 'Automated';
        prodd2.Disbursement_Amount__c = 3000.00;
        prodd2.Collection_Agency__c = 30;
        prodd2.Current_Balance__c = 7730;
        prodd2.Current_Principal_Balance__c = 5000;
        prodd2.Current_Interest_Amount__c = 2730;
        prodd2.product_status__C = '310000';
        prodd2.Current_Workflow__c = 'Collection Process';
        prodd2.Requested_Close_Date__c = System.Today();
        prodd2.Status__c = 'New Allocation - New Allocation';
        prodd2.Sub_Status__c = 'Ready';
        prodd2.Product_Status__c = 'Test';
       prodd2.Data_Status_Description__c='Closed test';
        prodd2.Last_Name__c = 'xyz';
        prodd2.Recoverable_Fee__c =123;
        //prod2.Pool_Name__c = pool.id;
        prodd2.Placement_Status__c = '100010';
        prodd2.Credit_Counselling_Date__c =null;
        prodd2.Purchase_Status__c = 'Buyback/Putback Approved';
        prodd2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prodd2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prodd2.Recoverable_Fee__c = 100;
        prodd2.Allocated_Amount_Principal__c = 200;
        prodd2.Allocated_Amount_Interest__c = 300;
        prodd2.Commission_Rate_at_Time_of_Placement__c=2;
        prodd2.Commission_Rate__c=4;
        prodd2.Settlement_Rate__c=5;
        prodd2.Value_Tier_at_Time_of_Placement__c='A';
        prodd2.Placed_Settlement_Rate__c=5;
        prodd2.Current_Bal_NSF_Fees__c = 400;
        prodd2.Purchase_Province__c ='AB';
        prodd2.State__c='Ontario';
        prodd2.Collection_Sub_Status__c='Credit Counselling';
        insert prodd2;
            
            Map<String, Product__c> mapProductName1 = new Map<String, Product__c>();
        Map<String ,Pool__C> poolMap2 = new Map<String ,Pool__C>();
        
        mapProductName1.put(prodd2.name,prodd2);
            poolMap2.put(poolData1.name,poolData1);
            
        Product_Staging__c productStaging1 = new Product_Staging__c();
        productStaging1.Product_ID__c = prodd2.ID;
        productStaging1.Data_Id__c = NULL; //prod2.Name;
        productStaging1.Name__c = NULL;//prod2.Name;
        productStaging1.Document_Storage__c = docStorage1.ID;
        productStaging1.Comment__c = 'SUCCESS';
        productStaging1.Status__c = 'Processed';
        productStaging1.Identifier__c = docStorage1.ID;
        productStaging1.Placement_Agency__c = '1';
        productStaging1.Status_Changed_Date__c = String.valueOf(Date.today());
        productStaging1.Placement_Status_Code__c = '900000';
        productStaging1.Pool_Name_ID__c = poolData1.id;
        productStaging1.Current_Principal_Balance__c = 5000;
        productStaging1.Current_Interest_Balance__c = 400;
        productStaging1.Status_Changed_Date_Text__c = '27/03/2023';
        productStaging1.Status_Changed_Date__c ='27/03/2023';
        productStaging1.Fees__c = 300;
      //  productStaging.Pool_Name__c='test';
        insert productStaging1;
        
        List<Product_staging__c> prodStagingList1 = new List<Product_staging__c>();
        prodStagingList1.add(productStaging1);
            
        set<string> successStringSet = new set<string>();
        successStringSet.add('test');
        set<string> failedStringSet =  new set<string>();
        failedStringSet.add('test');    
        
        DistressedUtilities.allocationValidationOnRecordUpdate(prodStagingList1,prodList1, mapProductName1, docStorage1.id, poolMap2);
        DistressedUtilities.validatePutbackBuybackRecords(prodStagingList1, mapProductName1, docStorage1.id);
        DistressedUtilities.validateProductStatusUpdateRecords(prodStagingList1, mapProductName1, docStorage1.id);
        DistressedUtilities.recallValidationOnRecordUpdate(prodStagingList1, prodList1, mapProductName1, docStorage1.id, workAssignment1.id, docStorage1);
        DistressedUtilities.postDocumentAPI(docStorage1.id, workAssignment1.id, 2, 2, successStringSet, failedStringSet, 'test', 'test', prodStagingList1,'Account Status Update File');  

        
        }
    
    static testMethod void disUtilitySettlemt(){
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
        FieldMap.Field_API__c = 'Status__c';
        FieldMap.Field_JSON_Tag__c ='Status';
        FieldMap.Object_Name__c = 'Settlement';
        FieldMap.Name = 'Status';        
        insert FieldMap;
        
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Allocation File';
        insert workAssignment;
        
        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        docStorage.Uploaded_By__c = 'External User';
        insert docStorage;
        
        Pool__c poolData = new Pool__c();
        poolData.Placement_Agency__c = 89;
        insert poolData;
        
        Map<ID, Pool__c> poolMap = new Map<ID, Pool__c>();
        poolMap.put(poolData.id,poolData);
        
        List<Product__c> prodList = new List<Product__c>();
        
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
        //prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c =null;
        prod2.Purchase_Status__c = 'Buyback/Putback Approved';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prod2.Recoverable_Fee__c = 100;
        prod2.Allocated_Amount_Principal__c = 200;
        prod2.Allocated_Amount_Interest__c = 300;
        prod2.Current_Bal_NSF_Fees__c = 400;
        prod2.Purchase_Province__c ='AB';
        insert prod2;
        
Agency_Portal_Fields_Mapping__c mapping3 = new Agency_Portal_Fields_Mapping__c(Name = 'Settlement_Number', Object_Name__c = 'Settlement', 
                                                                                       Field_API__c = 'Settlement_Number__c',
                                                                                      Field_Type__c = 'text');
        insert mapping3;
        
        List<ID> prodIdList = new List<ID>();
        prodIdList.add(prod2.id);
               Settlement__c settle = new Settlement__c();
        settle.Product__c = prod2.Id;
        settle.Status__c = 'Ready for review';
        settle.Settlement_Number__c='123';
        settle.Comment__c='testing class';
        settle.Monthly_Expenses_Comments__c='testing batch apex';
        settle.Monthly_Income_Comments__c='testing batch apex';
        settle.Total_Wealth_Comments__c='testing batch apex';
        insert settle;
        List<Id> settleIDs=new list<id>();
        settleIDs.add(settle.Id);
        Test.startTest();  
               updateSettlementStatusBatch.processSettlement(settleIDs);
        DistressedUtilities.UpdateSettlement(prodIdList);
        DistressedUtilities.loadSettlementIDMap(prodIdList);
        Test.stopTest();
    }
}