/*------------------------------------------------------------------------------------------------------------------
 * Class : ProcessingUnallocatedProductController
 * @description : This class contains unit tests for validating behavior of InlineInsolvencyAccountsCntrl
 * @author : A5E Consulting
 * @date : 03/04/2019
 ---------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestProcessingUnallocatedProductctlr {
    @testSetup
    static void testData() {
        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;

        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Do_Not_Run_Payment_Validation__c = false
        );
        insert config;
        Remittance__c remit = new Remittance__c(
            Cheque_Payment_Reference_Number__c = '1234',
            Cheque_Amount__c = 12.00,
            Total_Unallocated_Amount__c = 12.00,
            Payment_Posting_Date__c = System.Today().addDays(-2),
            recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%' LIMIT 1]
            .id,
            Status__c = 'New'
        );
        insert remit;

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod = new Product__c();
        prod.customer__c = customer.Id;
        prod.name = '124567';
        prod.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;

        //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(
            Account_Number__c = 'unknown',
            Remittance__c = remit.Id,
            Allocated__c = false,
            Deposit_Slip__c = ds.id,
            Cheque_Number__c = '12345',
            Is_Payment_Remitted__c = false
        );
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c = 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';

        insert depAcc;
        remit.Deposit_Account_Name__c = 'CIML';
        update remit;

        //Payments
        Product_Payments__C payment1 = new Product_Payments__C();
        payment1.Payment_Source__c = '2';
        payment1.Dividend__c = remit.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.CCS_Account__C = prod.id;
        payment1.Unallocated_Payment__c = unAloccPay.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        payment1.Payment_Type__c = '1000';
        insert payment1;
        //ETC
    }

    //Test Controller
    /*static testMethod void testController(){
        Unallocated_Payment__c unAloccPay = [SELECT Id FROM Unallocated_Payment__c LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__C LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
        
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
       
        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__C LIMIT 1].Id;
        obj.save();
    }*/

    static testMethod void testController1() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod2 = new Product__c();
        prod2.name = '123456';
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        Remittance__c remit = new Remittance__c(
            Cheque_Payment_Reference_Number__c = '1234',
            Cheque_Amount__c = 12.00,
            Total_Unallocated_Amount__c = 12.00,
            Payment_Posting_Date__c = System.Today().addDays(-2),
            recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%']
            .id,
            Status__c = 'New'
        );
        insert remit;

        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(
            Account_Number__c = 'unknown',
            Allocated__c = false,
            Deposit_Slip__c = ds.id,
            Cheque_Number__c = '12345',
            Is_Payment_Remitted__c = false
        );
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Unallocated_Payment__c unAloccPay1 = new Unallocated_Payment__c(
            Account_Number__c = 'unknown',
            Allocated__c = false,
            Deposit_Slip__c = ds.id,
            Remittance__c = remit.id,
            Cheque_Number__c = '12345',
            Is_Payment_Remitted__c = false
        );
        unAloccPay1.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay1;
        /*unAloccPay.Account_Number__c = prod2.name;
        unAloccPay.Allocated__c = true;
        update unAloccPay;*/

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C = prod2.id;
        payment2.Unallocated_Payment__c = unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CCL';
        payment2.Payment_Type__c = '1000';
        insert payment2;

        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();

        /*unAloccPay.Remittance__c = NULL;
        unAloccPay.Allocated__c = true;
       
        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.save(); */
    }

    static testMethod void testController2() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod2 = new Product__c();
        prod2.name = '123456';
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c = 'AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

        Remittance__c remit = new Remittance__c(
            Cheque_Payment_Reference_Number__c = '1234',
            Cheque_Amount__c = 12.00,
            Total_Unallocated_Amount__c = 12.00,
            Payment_Posting_Date__c = System.Today().addDays(-2),
            recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%']
            .id,
            Status__c = 'New'
        );
        insert remit;

        //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(
            Account_Number__c = 'unknown',
            Remittance__c = remit.Id,
            Allocated__c = false,
            Deposit_Slip__c = ds.id,
            Cheque_Number__c = '12345',
            Is_Payment_Remitted__c = false
        );
      Test.startTest();  
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C = prod2.id;
        payment2.Unallocated_Payment__c = unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'ETC';
        payment2.Payment_Type__c = '1000';
        insert payment2;

        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;

        obj.save();

        unAloccPay.Account_Number__c = '123456';
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = null;
        unAloccPay.Allocated__c = true;

        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.save();
      Test.stopTest();  
    }

    static testMethod void testController3() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod2 = new Product__c();
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c = 'AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

        //Deposit Slip Record creation
      Test.startTest(); 
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234';
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;

        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c = ds.id;
        unAloccPay.Cheque_Number__c = '12345';
        unAloccPay.Is_Payment_Remitted__c = false;
        unAloccPay.Allocated__c = false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C = Prod2.id;
        payment2.Unallocated_Payment__c = unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CIH';
        payment2.Payment_Type__c = '1000';
        //insert payment2;

        Product_Payments__C payment3 = new Product_Payments__C();
        payment3.Payment_Source__c = '2';
        payment3.Dividend__c = unAloccPay.Remittance__c;
        payment3.Payment_Amount__c = 1123.00;
        payment3.CCS_Account__C = Prod2.id;
        payment3.Unallocated_Payment__c = unAloccPay.id;
        payment3.Deposit_Account_Type__c = 'CIA';
        payment3.Payment_Type__c = '1000';
        payment3.Ignore_Warning__c = true;
        insert new List<Product_Payments__C>{payment3,payment2};

        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);

        remit.id = unAloccPay.Remittance__c;
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;

        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c = ds.id;
        unAloccPay2.Cheque_Number__c = '12345';
        unAloccPay2.Is_Payment_Remitted__c = false;
        unAloccPay2.Allocated__c = false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay2;

        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
       // obj.save();
    Test.stopTest();
    }

    static testMethod void testController4() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod2 = new Product__c();
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c = 'AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

     Test.startTest();   
       //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234';
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;

        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c = ds.id;
        unAloccPay.Cheque_Number__c = '12345';
        unAloccPay.Is_Payment_Remitted__c = false;
        unAloccPay.Allocated__c = false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C = prod2.id;
        payment2.Unallocated_Payment__c = unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'ETC';
        payment2.Payment_Type__c = '1000';
        insert payment2;

        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);

        remit.id = unAloccPay.Remittance__c;
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;

        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c = ds.id;
        unAloccPay2.Cheque_Number__c = '12345';
        unAloccPay2.Is_Payment_Remitted__c = false;
        unAloccPay2.Allocated__c = false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay2;

        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
      Test.stopTest();  
    }

    static testMethod void testController5() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        Product__c prod2 = new Product__c();
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c = 'AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

        //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234';
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;

        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c = ds.id;
        unAloccPay.Cheque_Number__c = '12345';
        unAloccPay.Is_Payment_Remitted__c = false;
        unAloccPay.Allocated__c = false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C = prod2.id;
        payment2.Unallocated_Payment__c = unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'AAL';
        payment2.Payment_Type__c = '1000';
        insert payment2;
        
  Test.startTest();
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);

        remit.id = unAloccPay.Remittance__c;
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;

        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c = ds.id;
        unAloccPay2.Cheque_Number__c = '12345';
        unAloccPay2.Is_Payment_Remitted__c = false;
        unAloccPay2.Allocated__c = false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay2;

        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
     Test.stopTest();   
    }

    static testMethod void testController6() {
        Product__c prod2 = new Product__c();
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer;
        prod2.customer__c = customer.Id;
        //prod2.Portfolio_Group_Name__c = 'AAL001';
        prod2.RecordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;

        //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%ccs%'].id;
        insert ds;

        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234';
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;

        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c = ds.id;
        unAloccPay.Cheque_Number__c = '12345';
        unAloccPay.Is_Payment_Remitted__c = false;
        unAloccPay.Allocated__c = false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay;

        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);

        remit.id = unAloccPay.Remittance__c;
        remit.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'remittance__C' AND name LIKE '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;

        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c = ds.id;
        unAloccPay2.Cheque_Number__c = '12345';
        unAloccPay2.Is_Payment_Remitted__c = false;
        unAloccPay2.Allocated__c = false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_Payment__C' AND name LIKE '%Insolvency%'].id;
        insert unAloccPay2;

        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));

        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
    }
}