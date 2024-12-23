/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class contains unit tests for paymentReversal
 *  @author : A5E Consulting
 *  @date : 09/04/2020
 *
 *************************************************************************************************/
@isTest
public class TestpaymentReversalController {
    @testSetup
    static void testthis() {
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
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;
        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;
    }
    static testMethod void TestData() {
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;
        //CCS Agency
        Product__c prod = new Product__c(Name = 'Test8965412300023'/*, Account_Purchase_Date__c = System.today()*/);
        // Commented by me      prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        // // From Here
        prod.customer__c = customer1.Id;
        prod.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'product__c' AND name = 'CCS Account' Limit 1 /* like '%ccs%' Limit 1*/].id;
        // upto here
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;

        /*Account acc1= new Account( Name='krishna');
acc1.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
insert acc1;*/
        //Dividend for CCS//
        Remittance__c remittance2 = new Remittance__c();
        remittance2.Status__c = 'New';
        remittance2.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'CCS_Dividend' AND sobjecttype = 'Remittance__C' LIMIT 1].Id;
        remittance2.Cheque_Amount__c = 145.25;
        remittance2.Fairshare_Amount__c = 100.25;
        remittance2.Deposit_Account_Name__c = 'CIHL';
        // remittance2.CCS_Agency__c = acc1.Id;//
        insert remittance2;

        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(
            Account_Number__c = 'unknown',
            Remittance__c = remittance2.Id,
            Allocated__c = false,
            Unallocated_Amount__c = 12.00,
            Unallocated_Fairshare_Amount__c = 20.00
        );
        unAloccPay.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'unallocated_payment__c' AND name LIKE '%ccs%' LIMIT 1].id;
        //unAloccPay.Remittance__c=divid.Id;
        insert unAloccPay;

        ApexPages.currentPage().getParameters().put('Id', String.valueOf(remittance2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(remittance2);
        PaymentReversalController payment = new PaymentReversalController(sc);

        payment.submit();

        payment.ccspayments();
        payment.insonlencypayments();
        payment.Unallocated();
        payment.getItems();
    }
    // test for insolvency payments//
    static testMethod void TestData2() {
        // Dividend for insolvency//
        Id accountTrusteeCompanyRtypeId = Schema.getGlobalDescribe()
            .get('Account')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Trustee Company')
            .getRecordTypeId();
        Account acc = new Account(Name = 'test', RecordTypeID = accountTrusteeCompanyRtypeId);
        insert acc;
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' AND sobjecttype = 'Remittance__C' LIMIT 1].Id;
        remittance1.Cheque_Amount__c = 145.25;
        remittance1.Deposit_Account_Name__c = 'CIHL';
        remittance1.Trustee_name__c = acc.Id;
        insert remittance1;
        //Insolvency Account Record
        Insolvency_Account__c insAcc2 = new Insolvency_Account__c();
        insAcc2.Insolvency_Status__c = 'For Owner Review';
        insAcc2.Client_Identifier__c = 'Scotia Bank';
        insAcc2.Claim_Type__c = 'Unsecured';
        /*sAcc2.Insolvency__c = insolv1.id;*/
        insAcc2.Name = 'Test- 002';
        insAcc2.Account_Number_Without_Space__c = 'Test-002';
        insert insAcc2;

        // insolvency payments

        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.Insolvency_Account__c = insAcc2.Id;
        insert payment1;

        ApexPages.currentPage().getParameters().put('Id', String.valueOf(remittance1.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(remittance1);
        PaymentReversalController payment = new PaymentReversalController(sc);

        payment.submit();

        payment.ccspayments();
        payment.insonlencypayments();
        payment.Unallocated();
        payment.getItems();
    }
}