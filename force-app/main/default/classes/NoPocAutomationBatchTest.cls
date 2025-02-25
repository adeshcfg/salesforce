/**
 * @description       : Test class for NoPocAutomationBatch
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-25-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class NoPocAutomationBatchTest {
    @TestSetup
    static void makeData() {
        PoC_Package_Settings__c poc = new PoC_Package_Settings__c(
            Name = 'Scotia Bank',
            CFG_Trustee_Email_Default_content__c = 'test',
            CFG_Trustee_Email_Default_Subject__c = 'test',
            CFG_Office_Name__c = 'Test',
            CFG_Office_Address_1__c = 'PO Box 758 STN B',
            CFG_Office_Address__c = 'PO Box 758 STN B',
            CFG_Office_Fax_Number__c = '844-827-9220',
            CFG_Office_Phone_Number__c = '844-827-9222',
            CFG_Office_City__c = 'London',
            CFG_Office_Province_Short_Code__c = 'ON',
            CFG_Office_Postal_Code__c = 'N6A 4Y8',
            CFG_Payment_Postal_Code__c = 'N6A 4Y8',
            CFG_Office_Email_Address__c = 'test@canaccede.com',
            CFG_Office_Website__c = 'www.google.com',
            CFG_Office_Province__c = 'Test',
            Company_Name__c = 'Test',
            Client_Company_Name_French__c = 'Test',
            Client_Company_Name__c = 'Test'
        );
        PoC_Package_Settings__c ctb = new PoC_Package_Settings__c(
            Name = 'Canadian Tire',
            CFG_Trustee_Email_Default_content__c = 'test',
            CFG_Trustee_Email_Default_Subject__c = 'test',
            CFG_Office_Name__c = 'Test',
            CFG_Office_Address_1__c = 'PO Box 758 STN B',
            CFG_Office_City__c = 'London',
            CFG_Office_Province_Short_Code__c = 'ON',
            CFG_Office_Postal_Code__c = 'N6A 4Y8',
            CFG_Payment_Postal_Code__c = 'N6A 4Y8',
            CFG_Office_Fax_Number__c = '844-827-9220',
            CFG_Office_Phone_Number__c = '844-827-9222',
            CFG_Office_Email_Address__c = 'test@canaccede.com',
            CFG_Office_Website__c = 'www.google.com',
            CFG_Office_Province__c = 'Test',
            Company_Name__c = 'Test',
            Client_Company_Name_French__c = 'Test',
            Client_Company_Name__c = 'Test'
        );
        insert new List<PoC_Package_Settings__c>{ poc, ctb };

        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.fax = '651426256';
        acct.Follow_up_Email__c = 'test283@yopmail.com';
        acct.Business_Email__c = 'test11283@yopmail.com';
        acct.Preferred_Language__c = 'French';
        insert acct;

        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;

        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'No PoC Required';
        acc.Reason_for_No_PoC_Required_Dropdown__c = 'Unable to Locate Account';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
    }

    @isTest
    static void automationBatchTest() {
        Test.startTest();
        NoPocAutomationBatch noPocBatch = new NoPocAutomationBatch();
        Database.executeBatch(noPocBatch);
        Test.stopTest();
    }

    @isTest
    static void schedulerTest() {
        Test.startTest();
        NoPocAutomationBatch noPocBatch = new NoPocAutomationBatch();
        String sch = '0 0 23 * * ?';
        System.schedule('Test automation Check', sch, noPocBatch);
        Test.stopTest();
    }
}
