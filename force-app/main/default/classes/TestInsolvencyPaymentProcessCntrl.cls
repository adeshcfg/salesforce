/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class contains unit tests for payment processing
 *  @author : A5E Consulting
 *  @date : 21/01/2019
 *
 *************************************************************************************************/
@isTest
public class TestInsolvencyPaymentProcessCntrl {
    @testSetup
    static void testData() {
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

        RecordType remittanceRecType = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case' AND DeveloperName = 'Remittance'
        ];
        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@testOrg.com';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.recordTypeId = remittanceRecType.Id;
        caseObj.Status = 'New';
        insert caseObj;

        Id accountTrusteeCompanyRtypeId = Schema.getGlobalDescribe()
            .get('Account')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Trustee Company')
            .getRecordTypeId();
        Account acc = new Account(Name = 'test', RecordTypeID = accountTrusteeCompanyRtypeId);
        insert acc;

        // Remittance creation//
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' AND sobjecttype = 'Remittance__C'].Id;
        remittance1.Email_to_Case_Reference_Number__c = caseObj.Id;
        remittance1.Cheque_Amount__c = 145.25;
        remittance1.Deposit_Account_Name__c = 'CIHL';
        remittance1.Trustee_name__c = acc.Id;
        insert remittance1;

        //Remittance record creation
        Remittance__c remittance2 = new Remittance__c();
        remittance2.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' AND sobjecttype = 'Remittance__C'].Id;
        remittance2.Status__c = 'New';
        remittance2.Trustee_name__c = acc.Id;
        remittance2.Cheque_Amount__c = 123.00;
        remittance2.Deposit_Account_Name__c = 'CAL';
        insert remittance2;

        Remittance__c remittance3 = new Remittance__c();
        remittance3.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' AND sobjecttype = 'Remittance__C'].Id;
        remittance3.Status__c = 'New';
        remittance3.Deposit_Account_Name__c = 'CAL';
        remittance3.Cheque_Amount__c = 1183.0;
        insert remittance3;

        Attachment att = new Attachment(Name = 'Test attachment', ParentId = remittance3.Id, Body = Blob.valueOf('Test'));
        insert att;

        //Deposit Slip Record creation
        Deposit_Slip__c ds = new Deposit_Slip__c();
        ds.recordTypeid = [SELECT id FROM RecordType WHERE SobjectType = 'Deposit_Slip__c' AND name LIKE '%insolvency%'].id;
        insert ds;

        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Date__c = system.today();
        insolv1.Insolvency_Received_Date__c = system.today();
        insolv1.Insolvency_Status__c = 'Active';
        insolv1.Debtor_1_Court_Number__c = 'test';
        insolv1.Court_Division_Number__c = 'test';
        insolv1.Court_District_Name__c = 'Mission';
        insolv1.Court_Province__c = 'Newfoundland and Labrador';
        insolv1.Debtor_2_First_Name__c = 'Gari';
        insolv1.Debtor_2_Last_Name__c = 'Steves';
        insolv1.Debtor_2_Date_of_Birth__c = system.today();
        insolv1.Debtor_2_Gender__c = 'Male';
        insolv1.Debtor_2_Mailing_Street__c = '45 A street 12';
        insolv1.Debtor_2_Mailing_City__c = 'test city';
        insolv1.Debtor_2_Mailing_State_Province__c = 'Newfoundland and Labrador';
        insolv1.Debtor_2_Mailing_Postal_Code__c = 'N8U 7Y7';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        insert insolv1;

        //Insolvency Account Record
        Insolvency_Account__c insAcc1 = new Insolvency_Account__c();
        insAcc1.Insolvency_Status__c = 'For Owner Review';
        insAcc1.Client_Identifier__c = 'Scotia Bank';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;
        insAcc1.Name = 'Test- 001';
        insAcc1.Account_Type__c = 'Mortgage';
        insAcc1.Account_Number_Without_Space__c = 'Test-001';
        insert insAcc1;

        //Insolvency Account Record
        Insolvency_Account__c insAcc2 = new Insolvency_Account__c();
        insAcc2.Insolvency_Status__c = 'For Owner Review';
        insAcc2.Client_Identifier__c = 'Scotia Bank';
        insAcc2.Claim_Type__c = 'Unsecured';
        insAcc2.Insolvency__c = insolv1.id;
        insAcc2.Name = 'Test- 002';
        insAcc2.Account_Number_Without_Space__c = 'Test-002';
        insAcc2.Portfolio_Group_Name__c = 'CIA';
        insert insAcc2;

        //Payments creation //
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.Insolvency_Account__c = insAcc1.Id;
        insert payment1;

        //Payments creation //
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = remittance2.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c = insAcc1.Id;
        payment2.Deposit_Account_Type__c = 'CAL';
        insert payment2;

        Insolvency_Payment__c payment3 = new Insolvency_Payment__c();
        payment3.Remittance__c = remittance3.Id;
        payment3.Payment_Amount__c = 1123.00;
        payment3.Insolvency_Account__c = insAcc2.Id;
        insert payment3;

        Unallocated_Payment__c unallocatedPayment = new Unallocated_Payment__c(
            Account_Number__c = 'test',
            Actioned__c = false,
            Allocated__c = false,
            Allocated_To__c = 'Insolvency',
            Bank_Name__c = 'Auto Capital',
            Created_by_EFT_Processing__c = false,
            Created_by_Striplist_Parsing__c = false,
            Is_Payment_Remitted__c = false,
            Payment_Posting_Date__c = System.today(),
            Remittance__c = remittance3.Id,
            Unallocated_Amount__c = 1000
        );
        insert unallocatedPayment;

        //Custom setting //
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.name = 'CIML';
        depAcc.Account_Number__c = '123';
        depAcc.Bank_Name__c = 'CIML';
        depAcc.Transit_Number__c = '123';
        depacc.Entity_Name__c = 'test';
        insert depAcc;
        remittance1.Deposit_Account_Name__c = 'CIML';
        update remittance1;

        Deposit_Accounts__c depAcc2 = new Deposit_Accounts__c();
        depAcc2.Name = 'CAL';
        depAcc2.Account_Number__c = '1082-767';
        depAcc2.Bank_Name__c = 'CA LTD Blocked  ';
        depAcc2.Entity_Name__c = 'Canaccede Assets Ltd';
        depAcc2.Transit_Number__c = '03482';
        insert depAcc2;
        remittance1.Deposit_Account_Name__c = 'CAL';
        update remittance2;

        Deposit_Accounts__c depAcc3 = new Deposit_Accounts__c();
        depAcc3.Name = 'CIH';
        depAcc3.Account_Number__c = '767';
        depAcc3.Bank_Name__c = 'CIH';
        depAcc3.Entity_Name__c = 'Canaccede Assets Ltd';
        depAcc3.Transit_Number__c = '03485';
        insert depAcc3;
        remittance3.Deposit_Account_Name__c = 'CIH';
        update remittance3;
    }

    //Test Controller//
    static testMethod void testController() {
        Remittance__c remit = [SELECT Id, Cheque_Amount__c FROM Remittance__c LIMIT 1];
        PageReference pageRef = Page.RemittanceInline;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', remit.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(remit);
        InsolvencyPaymentProcessingController obj = new InsolvencyPaymentProcessingController(sc);
        obj.insolvencyAccNumbers = '';
        obj.searchInsolvencyAccounts();
        obj.insolvencyAccNumbers = '456';
        obj.searchInsolvencyAccounts();
        obj.filterSearchResults();
        obj.getwrapIsNotEmpty();
        obj.saveInsolveyncyPayments();
        obj.calculateTotal();
        obj.addUnallocatedPayment();
        for (Unallocated_Payment__c unAlloc : obj.unAllocPaymentList) {
            unAlloc.Unallocated_Amount__c = 121.00;
            unAlloc.Account_Number__c = 'test123';
        }
        obj.getShowSaveButton();
        obj.getunAllocAmountIsNotEmpty();
        obj.saveUnAllocatedAmount();
        Decimal totalAmount = obj.getTotalAmount();
        InsolvencyPaymentProcessingController.assignBankInformation(remit.id);
        obj.getwrapListWithAmountNotEmpty();
        obj.getwrapListWithZeroAmountNotEmpty();
        obj.getAttachIsNotEmpty();
    }

    static testMethod void testNullConditions() {
        Remittance__c remit = [SELECT Id, Cheque_Amount__c FROM Remittance__c WHERE Trustee_Name__c = NULL LIMIT 1];
        PageReference pageRef = Page.RemittanceInline;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', remit.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(remit);
        InsolvencyPaymentProcessingController obj = new InsolvencyPaymentProcessingController(sc);
        obj.insolvencyAccNumbers = 'Test';
        obj.searchInsolvencyAccounts();
        obj.saveInsolveyncyPayments();
        InsolvencyPaymentProcessingController.assignBankInformation(remit.id);
    }
}