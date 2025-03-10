@Istest(SeeAllData=true)
public class TestCFG_ProcessBulkAPIResult {
    public static testMethod void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c settings = API_Call_Details__c.getValues('Agency Portal API');
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        update settings;

        Placement__c place = new Placement__c();
        place.name = '780';
        place.Serviceable_Province__c = 'ON';
        insert place;

        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;

        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Purpose__c = 'Excel Processing';
        workAssignment.Sub_Purpose__c = 'Product Buyback/Putback File';
        workAssignment.Placement_Agency__c = place.id;
        insert workAssignment;

        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.ID;
        docStorage.Uploaded_By__c = 'External User';
        insert docStorage;

        Product__c product3 = new Product__c();
        product3.name = '1000P005';
        product3.Collection_Agency__c = 29;
        product3.Pool_Name_Text__c = poolInstance.name;
        product3.Status_Changed_Date__C = Date.newInstance(2022, 9, 3);
        product3.Placement_Status__c = '800110';
        product3.Assignment_Date__c = Date.newInstance(2022, 8, 3);
        product3.State__c = 'ON';
        product3.Pool_Name__c = poolInstance.id;
        product3.Data_Status_Description__c = 'Closed-test';
        product3.Purchase_Status__c = 'Buyback/Putback Approved';
        product3.Collection_Sub_Status__c = 'Credit Counselling';
        product3.Purchase_Province__c = 'AB';
        product3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert product3;

        Product__c product4 = new Product__c();
        product4.name = '1000P006';
        product4.Collection_Agency__c = 29;
        product4.Pool_Name_Text__c = poolInstance.name;
        product4.Status_Changed_Date__C = Date.newInstance(2022, 9, 3);
        product4.Placement_Status__c = '800110';
        product4.Assignment_Date__c = Date.newInstance(2022, 8, 3);
        product4.State__c = 'ON';
        product4.Pool_Name__c = poolInstance.id;
        product4.Data_Status_Description__c = 'Closed-test';
        product4.Purchase_Status__c = 'Buyback/Putback Approved';
        product4.Collection_Sub_Status__c = 'Paid in Full Account';
        product4.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        product4.Purchase_Province__c = 'AB';
        insert product4;

        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = product3.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.CreatedDate = Date.today().addDays(-180);
        insert placeHist;

        Product_Staging__c productStaging = new Product_Staging__c();
        productStaging.Name__c = product3.Name;
        productStaging.Comment__c = 'Success';
        productStaging.Placement_Agency__c = '29';
        productStaging.Current_Commission_Rate__c = 22;
        productStaging.Placed_Commission_Rate__c = 25;
        productStaging.Current_Settlement_Rate__c = 15;
        productStaging.Placed_Settlement_Rate__c = 20;
        productStaging.Value_Tier_at_Time_of_Placement__c = 'A';
        productStaging.Status__c = 'Pending';
        productStaging.Identifier__c = docStorage.id;
        productStaging.Placement_Status_Code__c = '100000';
        productStaging.Data_Status_Code__c = '300000';
        productStaging.Document_Storage__c = productStaging.Identifier__c;
        productStaging.Data_Id__c = product3.Name;
        productStaging.Is_Record_Process__c = false;
        insert productStaging;

        Product_Staging__c productStaging1 = new Product_Staging__c();
        productStaging1.Name__c = product4.Name;
        productStaging1.Comment__c = 'Success';
        productStaging1.Placement_Agency__c = '700';
        productStaging1.Current_Commission_Rate__c = 22;
        productStaging1.Placed_Commission_Rate__c = 25;
        productStaging1.Current_Settlement_Rate__c = 15;
        productStaging1.Placed_Settlement_Rate__c = 20;
        productStaging1.Value_Tier_at_Time_of_Placement__c = 'A';
        productStaging1.Status__c = 'Pending';
        productStaging1.Identifier__c = docStorage.id;
        productStaging1.Placement_Status_Code__c = '100000';
        productStaging1.Data_Status_Code__c = '300000';
        productStaging1.Document_Storage__c = productStaging1.Identifier__c;
        productStaging1.Data_Id__c = product4.Name;
        productStaging1.Is_Record_Process__c = false;
        insert productStaging1;

        List<Product_Staging__c> listProductStaging = new List<Product_Staging__c>();
        listProductStaging.add(productStaging);

        Test.startTest();
        CFG_ProcessBulkAPIResult obj = new CFG_ProcessBulkAPIResult(null, docStorage.id, workAssignment.id, 'Product Allocation File', docStorage);
        obj.execute(null, listProductStaging);
        obj.updateRecordProcessCheck(listProductStaging);
        DataBase.executeBatch(obj);

        CFG_ProcessBulkAPIResult obj1 = new CFG_ProcessBulkAPIResult(null, docStorage.id, workAssignment.id, 'Account Status Update File', docStorage);
        obj1.execute(null, listProductStaging);
        obj1.updateRecordProcessCheck(listProductStaging);
        DataBase.executeBatch(obj1);
        Test.stopTest();
    }
}
