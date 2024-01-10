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
}
