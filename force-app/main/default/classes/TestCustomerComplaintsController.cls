@isTest
public with sharing class TestCustomerComplaintsController {
    @TestSetup
    static void makeData() {
        Product__c prod = new Product__c();
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Released Batch';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod;

        /* Account customer = new Account();
        customer.LastName = 'Rogers';
        customer.DO_NOT_SOLICIT__pc = false;
        customer.Duplicate_Customer__pc = false;
        customer.Future_Payment_Reminder__c = true;
        customer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
        insert customer; */

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        // wrkAss.Customer__c = customer.Id;
        wrkAss.Product__c = prod.Id;
        wrkAss.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Complaint').getRecordTypeId();
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
    }

    @isTest
    static void testGetCustomerComplaints() {
        List<Product__c> productList = [SELECT Id FROM Product__c LIMIT 1];
        Test.startTest();
        List<Work_Assignment__c> customerComplaints = CustomerComplaintsController.getCustomerComplaints(productList[0].Id);
        Test.stopTest();
    }

    @isTest
    static void exceptionTest() {
        Test.startTest();
        try {
            List<Work_Assignment__c> customerComplaints = CustomerComplaintsController.getCustomerComplaints('12345');
        } catch (Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Success');
        }
        Test.stopTest();
    }
}
