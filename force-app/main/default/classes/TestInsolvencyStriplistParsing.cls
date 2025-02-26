@isTest
public class TestInsolvencyStriplistParsing {
    @testSetup
    public static void testSetup() {
        EFT_Processing_Config__c config = new EFT_Processing_Config__c();
        config.Insolvency_EFT_RecordTypeID__c = Schema.SObjectType.EFT_Files__c.getRecordTypeInfosByName().get('Insolvency EFT').getRecordTypeId();
        config.Insolvency_Payment_Record_TypeID__c = Schema.SObjectType.Insolvency_Payment__c.getRecordTypeInfosByName()
            .get('Insolvency Payment')
            .getRecordTypeId();
        insert config;

        //Application config creation
        Application_Config_Settings__c config1 = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = true,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config1;
        Account Truscomp = new Account();
        Id Recrdid = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name LIKE 'Trustee Company'].id;
        Truscomp.RecordTypeId = Recrdid;
        Truscomp.name = 'Test';
        insert Truscomp;

        Deposit_Accounts__c depositeAcc = new Deposit_Accounts__c();
        depositeAcc.Name = 'CCL';
        depositeAcc.Account_Number__c = '1993-130';
        depositeAcc.Bank_Name__c = 'Canaccede Credit LP Blocked';
        depositeAcc.Entity_Name__c = 'Canaccede Credit LP';
        depositeAcc.Account_Name_on_Clearing_Account__c = 'CCLP - 130';
        depositeAcc.Transit_Number__c = '03482';
        insert depositeAcc;

        // Trustee Office Record
        Account Trusoff = new Account();
        Id Recordid = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND name LIKE 'Trustee Office'].id;
        Trusoff.RecordTypeId = Recordid;
        Trusoff.name = 'Testrecord';
        Trusoff.Trustee_ID__c = Truscomp.id;
        Trusoff.Is_Active__c = true;
        Trusoff.Follow_up_Email__c = 'Test@test.com';
        insert Trusoff;

        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '00-000001';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Trustee__c = Trusoff.id;
        insert insolv1;

        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        insert portfolioName;

        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

        //Insolvency Account records
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.RecordTypeId = recordTypeList[0].Id;
        insolvencyAccount.Name = '4537049889659';
        insolvencyAccount.Insolvency_Status__c = 'No PoC Required';
        insolvencyAccount.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Insolvency__c = insolv1.Id;
        insolvencyAccount.Account_Number_Without_Space__c = '4537049889659';
        insolvencyAccount.Portfolio_Group_Name__c = 'CCL001';
        insolvencyAccount.Previous_Account_Reference__c = '111';
        //insolvencyAccount.Investment_Group__c = 'AFFIRM';
        //insolvencyAccount.Portfolio_Name_Lookup__c = portfolioName.id;
        insolvencyAccount.Debtor_1_Estate_Number__c = '00-000001';

        insert insolvencyAccount;

        API_Call_Details__c portalApi = new API_Call_Details__c();
        portalApi.Name = 'Agency Portal API';
        portalApi.AuthorizationtUrl__c = 'https://test.com/api/Authorize';
        portalApi.API_Request_Timeout__c = 90000;
        portalApi.Client_ID__c = 'test';
        portalApi.Client_Secret__c = 'test';
        portalApi.Proxy_Client_ID__c = 'test';
        portalApi.Scope_Prefix__c = 'test';
        portalApi.Scope_Suffix__c = 'test';
        portalApi.Tenand_ID__c = 'test';
        portalApi.PDF_API_URL__c = 'https://exceltojson.com/api';
        insert portalApi;
    }
    public static testMethod void TestPaymentUpload() {
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        //insert config;

        String testOutputJSON = '';
        Remittance__c remittanceInstance = new Remittance__c();
        remittanceInstance.Cheque_Amount__c = 390;
        insert remittanceInstance;
        ApexPages.StandardController sc = new ApexPages.StandardController(remittanceInstance);
        StriplistInsolPaymentUploadController controller = new StriplistInsolPaymentUploadController(sc);
        //upload error
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //account no null
        testOutputJSON =
            '[{' +
            '"AccountNumber":,' +
            '"ClientID":254801.0,' +
            '"ClientName":"LEBLANC, JUSTIN ",' +
            '"EstateNumber":00-000001,' +
            '"Amount":39.0,' +
            '}]';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //EstateNumber null
        testOutputJSON =
            '[{' +
            '"AccountNumber":"4537049889659",' +
            '"ClientID":254801.0,' +
            '"DebtorName":"LEBLANC JUSTIN ",' +
            '"EstateNumber":,' +
            '"Amount":null,' +
            '}]';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //net payment null
        testOutputJSON =
            '[{' +
            '"AccountNumber":"4537049889659",' +
            '"ClientID":254801.0,' +
            '"DebtorName":"LEBLANC JUSTIN ",' +
            '"EstateNumber":00-000001,' +
            '"Amount":null,' +
            '}]';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        remittanceInstance.Cheque_Amount__c = 313.53;
        update remittanceInstance;
        //success
        testOutputJSON =
            '[' +
            '{' +
            '"EstateNumber": "12456780",' +
            '"DebtorName": "WHALENBERNARD",' +
            '"Amount": 245.94,' +
            '"accountID":"1234",' +
            '"AccountNumber": "477666559659"' +
            '},' +
            '{' +
            '"EstateNumber": "0",' +
            '"DebtorName": "WHALEN, BERNARDY",' +
            '"Amount": 89,' +
            '"accountID":"1234",' +
            '"AccountNumber": "4537049889659"' +
            '},' +
            '{' +
            '"EstateNumber": "00-000001",' +
            '"DebtorName": "WHALEN, BERNARDY",' +
            '"Amount": "",' +
            '"AccountNumber": "4537049889659"' +
            '},' +
            '{' +
            '"EstateNumber": "51-2397556",' +
            '"DebtorName": "WHEATLEY, KEVIN Michael",' +
            '"Amount": 67.59,' +
            '"AccountNumber": "438930122025"' +
            '}' +
            ']';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);
        controller.backToDividend();

        Test.setCurrentPageReference(new PageReference('InsolvencyPaymentUpload'));
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.showAllocatedProductPayments();
        controller.ShowUnallocatedProductPayments();
        controller.showallocated = true;
        controller.showunallocated = true;
        controller.postingDate = '1234';
    }

    public static testMethod void testProcessBatch() {
        Remittance__c remittance = new Remittance__c();
        insert remittance;
        List<StriplistUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<StriplistUtil.paymentRecordsWrapper>();
        StriplistUtil.paymentRecordsWrapper wrapper = new StriplistUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '4537049889659';
        wrapper.debtorName = 'TestFile';
        wrapper.estateNumber = '00-000001';
        wrapper.amount = '65.0';
        listPaymentRecordWrapper.add(wrapper);
        wrapper = new StriplistUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '111';
        wrapper.debtorName = 'TestFile';
        wrapper.estateNumber = '00-000001';
        wrapper.amount = '65.0';
        listPaymentRecordWrapper.add(wrapper);

        ProcessInsolvencyStriplistBatch batch1 = new ProcessInsolvencyStriplistBatch(listPaymentRecordWrapper, remittance);
        database.executeBatch(batch1);
    }

    public static testMethod void testInsertInsolvencyPaymentBatch() {
        Insolvency_Account__c insolvencyAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        Remittance__c remittance = new Remittance__c();
        insert remittance;
        blob blob1;
        Attachment allocatedPayment = new Attachment();
        allocatedPayment.parentid = remittance.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,debtorName,estateNumber,amount';
        attachBody += '\n';
        attachBody += '4537049889659,' + insolvencyAccount.Id + ',TestName,00-000001,100';
        allocatedPayment.Body = Blob.valueOf(attachBody);
        insert allocatedPayment;

        InsertInsolvencyPaymentsStriplistBatch batch1 = new InsertInsolvencyPaymentsStriplistBatch(remittance);
        database.executeBatch(batch1);

        remittance.Status__c = 'Processed';
        update remittance;
        Test.startTest();
        database.executeBatch(batch1);
        Test.stopTest();
    }

    public static testMethod void testDisplayAllocatedInsolvencyPayments() {
        Remittance__c remittanceInstance = new Remittance__c();
        insert remittanceInstance;

        Test.startTest();
        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c();
        paymentInstance1.Insolvency_Account__c = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0].ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c = 'Test File Uploaded123456';
        paymentInstance1.Remittance__c = remittanceInstance.Id;
        insert paymentInstance1;

        DisplayStriplistInsolAllocatedController controller;
        Test.setCurrentPageReference(new PageReference('DisplayStriplistInsolAllocatedPayments'));
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        controller = new DisplayStriplistInsolAllocatedController();
        controller.Save();
        controller.Redirect();
        Test.stopTest();
    }

    public static testMethod void testDisplayUnallocatedInsolvencyPayments() {
        Insolvency_Account__c insoAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        Remittance__c remittanceInstance = new Remittance__c();
        remittanceInstance.Allocated_Payments_Amount__c = 130;
        insert remittanceInstance;
        blob blob1;
        Attachment unallocatedPayment = new Attachment();
        unallocatedPayment.parentid = remittanceInstance.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,debtorName,estateNumber,amount';
        attachBody += '\n';
        attachBody += '4537049889659,' + insoAccount.Id + ',TestName,00-000001,100';
        unallocatedPayment.Body = Blob.valueOf(attachBody);
        insert unallocatedPayment;

        Test.startTest();
        Test.setCurrentPageReference(new PageReference('DisplayStriplistUnallocatedPayments'));
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        DisplayStriplistInsolUnallocController controller = new DisplayStriplistInsolUnallocController();
        Remittance__c dividendInstance = new Remittance__c(Insolvency_Account__c = insoAccount.Id);
        StriplistUtil.paymentRecordsWrapper wrapper = new StriplistUtil.paymentRecordsWrapper();
        wrapper.insolvencyAccInstance = dividendInstance;
        wrapper.amount = '1000';
        List<StriplistUtil.paymentRecordsWrapper> listUnallocatedPayment = new List<StriplistUtil.paymentRecordsWrapper>{ wrapper };
        controller.wrapperMap.put(0, wrapper);
        controller.Save();
        controller.Cancel();
        Test.stopTest();

        InsertUnallocatedPaymentsStriplistBatch batch2 = new InsertUnallocatedPaymentsStriplistBatch(listUnallocatedPayment, remittanceInstance, 'Insolvency');
        database.executeBatch(batch2);
    }

    public static testMethod void testFileUploadErrors() {
        Remittance__c remittanceInstance = new Remittance__c();
        remittanceInstance.Cheque_Amount__c = 390;
        remittanceInstance.File_Processing_Status__c = 'Completed';
        remittanceInstance.Status__c = 'Processed';
        insert remittanceInstance;
        Test.setCurrentPageReference(new PageReference('StriplistInsolvencyPaymentUpload'));
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(remittanceInstance);
        StriplistInsolPaymentUploadController controller = new StriplistInsolPaymentUploadController(sc);
        remittanceInstance.Status__c = 'Payment Reversed';
        update remittanceInstance;
        controller = new StriplistInsolPaymentUploadController(sc);
        StriplistInsolPaymentUploadController.insertApiError('responseBody', 'endPoint', 'error');
        //upload error
    }

    @isTest
    public static void testProcessExcelFile() {
        String excelFile = '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';
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        Remittance__c remittanceInstance = new Remittance__c();
        remittanceInstance.Cheque_Amount__c = 390;
        remittanceInstance.File_Processing_Status__c = 'In Progress';
        remittanceInstance.Status__c = 'In Progress';
        insert remittanceInstance;
        ApexPages.StandardController sc = new ApexPages.StandardController(remittanceInstance);
        StriplistInsolPaymentUploadController controller = new StriplistInsolPaymentUploadController(sc);
        controller.excelFile = excelFile;
        Test.startTest();
        controller.processExcelFile();
        Test.stopTest();
    }
}
