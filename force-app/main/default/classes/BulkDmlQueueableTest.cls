@isTest
public class BulkDmlQueueableTest {
    @TestSetup
    static void makeData() {
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

        Document_Storage__c docStorage = new Document_Storage__c();
        docStorage.Work_Assignment__c = workAssignment.Id;
        docStorage.Document_Name__c = 'Product Failed.csv';
        docStorage.Document_Extension__c = 'csv';
        docStorage.Document_Type__C = 'Payment Processing File';
        docStorage.Visibility__c = 'Authoring agencies + CFG  ';
        docStorage.Uploaded_By__c = 'Internal User';
        docStorage.Creator__c = UserInfo.getName();
        docStorage.File_Processing_Date__c = System.Today();
        docStorage.Document_Related_To__c = 'Task';
        docStorage.File_Processing_Status__c = 'In Progress';
        insert docStorage;

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonOtherPhone = '1234567890',
            Work_Phone__pc = '1234567890',
            PersonHomePhone = '1234567890',
            PersonBirthdate = System.Today().addMonths(-36),
            PersonMailingState = 'State',
            PersonMailingPostalCode = 'Postal',
            PersonMailingCity = 'City',
            PersonMailingStreet = 'Mailing',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '20';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

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
        insert settings;
    }

    @isTest
    public static void testPositive() {
        Document_Storage__c docStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < 200; i++) {
            Customer_Staging__c custStaging = new Customer_Staging__c();
            custStaging.Comment__c = 'SUCCESS';
            custStaging.ProdID__c = '656P178' + String.valueOf(i);
            custStaging.Placement_Agency__c = '68';
            custStaging.Status__c = 'Pending';
            custStaging.Document_Storage__c = docStorage.Id;
            custStaging.Include_in_Processing__c = true;
            recordsToInsert.add(custStaging);
        }
        Test.startTest();
        System.enqueueJob(new BulkDmlQueueable(recordsToInsert, 0, 'CustomerStagingExcelProcessing'));
        Test.stopTest();
    }

    @isTest
    public static void testPositiveBulk() {
        Document_Storage__c docStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];
        List<SObject> recordsToInsert = new List<SObject>();
        for (Integer i = 0; i < 12000; i++) {
            Customer_Staging__c custStaging = new Customer_Staging__c();
            custStaging.Comment__c = 'SUCCESS';
            custStaging.ProdID__c = '656P178' + String.valueOf(i);
            custStaging.Placement_Agency__c = '68';
            custStaging.Status__c = 'Pending';
            custStaging.Document_Storage__c = docStorage.Id;
            custStaging.Include_in_Processing__c = true;
            recordsToInsert.add(custStaging);
        }
        Test.startTest();
        System.enqueueJob(new BulkDmlQueueable(recordsToInsert, 0, 'CustomerStagingExcelProcessing'));
        Test.stopTest();
    }

    @isTest
    public static void testNegative() {
        Document_Storage__c docStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];
        List<SObject> recordsToInsert = new List<SObject>();
        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Test';
        custStaging.Document_Storage__c = docStorage.Id;
        custStaging.Include_in_Processing__c = true;
        recordsToInsert.add(custStaging);
        Test.startTest();
        try {
            System.enqueueJob(new BulkDmlQueueable(recordsToInsert, 0, 'CustomerStagingExcelProcessing'));
        } catch (DmlException ex) {
            System.assert(true, 'Insert failed');
        }
        Test.stopTest();
    }

    @isTest
    public static void testUpdate() {
        Document_Storage__c docStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];
        docStorage.Document_Name__c = 'Test.csv';
        List<SObject> recordsToInsert = new List<SObject>();
        recordsToInsert.add(docStorage);
        Test.startTest();
        System.enqueueJob(new BulkDmlQueueable(recordsToInsert, 0, 'Update'));
        Test.stopTest();
    }

    @isTest
    public static void testDelete() {
        Document_Storage__c docStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];
        List<SObject> recordsToInsert = new List<SObject>();
        recordsToInsert.add(docStorage);
        Test.startTest();
        System.enqueueJob(new BulkDmlQueueable(recordsToInsert, 0, 'Delete'));
        Test.stopTest();
    }

    @isTest
    public static void testAccountJudgmentProcessinge() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        List<SObject> recordsList = new List<SObject>();
        Product__c prod = new Product__c(
            Phone_Other__c = '1234567890',
            Phone_Work__c = '1234567890',
            Phone_Home__c = '1234567890',
            Date_of_Birth__c = System.Today().addMonths(-36),
            State__c = 'State',
            Zip_Code__c = 'Postal',
            Purchase_Province__c = 'PE',
            Deceased_Date__c = null,
            City__c = 'City',
            Statute_Date__c = null,
            Insolvency_Date__c = null,
            Credit_Counselling_Date__c = system.today(),
            First_Name__c = 'FirstName',
            Last_Name__c = 'LastName',
            Status__c = 'New Allocation - New Allocation',
            Sub_Status__c = 'Ready',
            Product_Status__c = 'Test',
            Customer__c = [SELECT Id FROM Account LIMIT 1]
            .Id,
            Source_System__c = 'FDR',
            Collection_Agency__c = 20,
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId()
        );
        insert prod;
        recordsList.add(prod);
        Test.startTest();
        System.enqueueJob(new BulkDmlQueueable(recordsList, 'AccountJudgmentProcessing'));
        Test.stopTest();
    }
}
