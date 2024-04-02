@isTest
public class TestInsolvencyEFTProcessing {
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
        insolv1.Name = '12456780';
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
        insolvencyAccount.Investment_Group__c = 'AFFIRM';
        insolvencyAccount.Portfolio_Name_Lookup__c = portfolioName.id;
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
        portalApi.PDF_API_URL__c = 'https://exceltojson.com/insolvency';
        insert portalApi;
    }
    public static testMethod void TestPaymentUpload() {
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        //insert config;

        String testOutputJSON = '';
        InsolvencyPaymentUploadController controller = new InsolvencyPaymentUploadController();
        //upload error
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //account no null
        testOutputJSON =
            '[{' +
            '"AccountNumber":null,' +
            '"ClientID":254801.0,' +
            '"ClientName":"LEBLANC, JUSTIN ",' +
            '"PaymentSource":3,' +
            '"PaymentType":1000,' +
            '"NetPayment":390.0,' +
            '"FairSharePayment":110.0,' +
            '"GrossPayment":500.0' +
            '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //net payment null
        testOutputJSON =
            '[{' +
            '"AccountNumber":"4537049889659",' +
            '"ClientID":254801.0,' +
            '"ClientName":"LEBLANC, JUSTIN ",' +
            '"PaymentSource":3,' +
            '"PaymentType":1000,' +
            '"NetPayment":null,' +
            '"FairSharePayment":110.0,' +
            '"GrossPayment":500.0' +
            '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        //success
        testOutputJSON =
            '[{' +
            '"AccountNumber":"4537049889659",' +
            '"ClientID":254801.0,' +
            '"ClientName":"LEBLANC, JUSTIN ",' +
            '"PaymentSource":3,' +
            '"PaymentType":1000,' +
            '"NetPayment":390.0,' +
            '"FairSharePayment":110.0,' +
            '"GrossPayment":500.0' +
            '},' +
            '{' +
            '"AccountNumber":"4537049851733",' +
            '"ClientID":257269.0,' +
            '"ClientName":"URINTSOV, OLGA ",' +
            '"PaymentSource":3,' +
            '"PaymentType":1000,' +
            '"NetPayment":50.7,' +
            '"FairSharePayment":14.3,' +
            '"GrossPayment":65.0' +
            '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.excelFile = testOutputJSON;
        controller.importDatatoApex(testOutputJSON);

        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        system.debug('eftInstance: ' + eftInstance);
        Test.setCurrentPageReference(new PageReference('InsolvencyPaymentUpload'));
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new InsolvencyPaymentUploadController();
        controller.showAllocatedProductPayments();
        controller.ShowUnallocatedProductPayments();
    }

    public static testMethod void testProcessBatch() {
        List<EFTUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<EFTUtil.paymentRecordsWrapper>();
        EFTUtil.paymentRecordsWrapper wrapper = new EFTUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '4537049889659';
        wrapper.chequeNumber = 'TestFile';
        wrapper.paymentSource = '3';
        wrapper.paymentType = '1000';
        wrapper.netPayment = '65.0';
        wrapper.postingDate = string.valueOf(system.today());
        listPaymentRecordWrapper.add(wrapper);

        EFT_Files__c eft = new EFT_Files__c();
        eft.Posting_Date__c = system.today();
        insert eft;

        ProcessInsolvencyEFTBatch batch1 = new ProcessInsolvencyEFTBatch(listPaymentRecordWrapper, eft);
        database.executeBatch(batch1);
    }

    public static testMethod void testInsertInsolvencyPaymentBatch() {
        Insolvency_Account__c insolvencyAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        insert eft;
        blob blob1;
        Attachment allocatedPayment = new Attachment();
        allocatedPayment.parentid = eft.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,netPayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber';
        attachBody += '\n';
        attachBody += '4537049889659,' + insolvencyAccount.Id + ',35.60,' + String.valueOf(system.today()) + ',null,null,null,TestCCSFileUpload';
        allocatedPayment.Body = Blob.valueOf(attachBody);
        insert allocatedPayment;

        InsertInsolvencyPaymentsBatch batch1 = new InsertInsolvencyPaymentsBatch(eft);
        database.executeBatch(batch1);
    }

    public static testMethod void testDisplayAllocatedInsolvencyPayments() {
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;

        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c();
        paymentInstance1.Insolvency_Account__c = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0].ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;

        DisplayAllocatedInsolvencyController controller;
        Test.setCurrentPageReference(new PageReference('DisplayAllocatedInsolvencyPayments'));
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new DisplayAllocatedInsolvencyController();
        controller.Save();
    }

    public static testMethod void testDisplayUnallocatedInsolvencyPayments() {
        Insolvency_Account__c insoAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        eft.Allocated_Payments_Amount__c = 0;
        insert eft;
        blob blob1;
        Attachment unallocatedPayment = new Attachment();
        unallocatedPayment.parentid = eft.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        String attachBody = 'AccountNumber,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber';
        attachBody += '\n';
        attachBody += '4537049209659,' + '61.0,' + String.valueOf(system.today()) + ',www.google.com,,3,1000,TestInsolvencyFileUpload';
        attachBody += '4537049889659,' + '61.0,' + String.valueOf(system.today()) + ',www.google.com,3,1000,TestInsolvencyFileUpload';
        unallocatedPayment.Body = Blob.valueOf(attachBody);
        insert unallocatedPayment;

        Test.setCurrentPageReference(new PageReference('DisplayInsolvencyUnallocatedPayments'));
        System.currentPageReference().getParameters().put('id', eft.Id);
        EFT_Files__c eftInstance = new EFT_Files__c(Insolvency_Account__c = insoAccount.Id);
        EFTUtil.paymentRecordsWrapper wrapper = new EFTUtil.paymentRecordsWrapper();
        wrapper.prodLookup = eftInstance;
        List<EFTUtil.paymentRecordsWrapper> listUnallocatedPayment = new List<EFTUtil.paymentRecordsWrapper>{ wrapper };
        DisplayInsolUnAllocatedPaymentController controller = new DisplayInsolUnAllocatedPaymentController();
        controller.wrapperMap.put(0, wrapper);
        controller.Save();
        controller.Cancel();

        InsertUnallocatedPaymentsBatch batch2 = new InsertUnallocatedPaymentsBatch(listUnallocatedPayment, eft, 'Insolvency');
        database.executeBatch(batch2);
    }

    public static testMethod void testDisplayUnAllocatedProcessedInsoPayments() {
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;

        Unallocated_Payment__c paymentInstance1 = new Unallocated_Payment__c();
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Unallocated_Amount__c = 321.98;
        paymentInstance1.Cheque_Number__c = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;

        DisplayUnallocatedProcessedController controller;
        Test.setCurrentPageReference(new PageReference('DisplayUnallocatedProcessed'));
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        System.currentPageReference().getParameters().put('rt', 'Insolvency');
        controller = new DisplayUnallocatedProcessedController();
        controller.redirectPaymentUpload();
    }

    @isTest
    public static void testProcessExcelFile() {
        String excelFile = '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';
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        InsolvencyPaymentUploadController controller = new InsolvencyPaymentUploadController();
        controller.excelFile = excelFile;
        Test.startTest();
        controller.processExcelFile();
        Test.stopTest();
    }
}