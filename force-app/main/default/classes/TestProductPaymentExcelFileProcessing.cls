@isTest
private class TestProductPaymentExcelFileProcessing {
    static {
        API_Call_Details__c apiCallDetails = new API_Call_Details__c();
        apiCallDetails.name = 'Agency Portal API';
        apiCallDetails.API_Request_Timeout__c = 90000;
        apiCallDetails.PDF_API_URL__c = 'https://api-agencies-uat.canaccede.com/api/Document/';
        apiCallDetails.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        apiCallDetails.Client_ID__c = 'f647baee-683f-4e34-95f0-611a3482baae';
        apiCallDetails.Client_Secret__c = '.uE7Q~glV.Ks.SacXYsRRRnWbXAT~2dxHkiPW';
        apiCallDetails.Proxy_Client_ID__c = 'd4849d4d-eb42-4933-9403-7c512af05dd5';
        apiCallDetails.Scope_Prefix__c = 'https://canaccedeb2ctestdev.onmicrosoft.com/';
        apiCallDetails.Scope_Suffix__c = '/.default';
        apiCallDetails.Tenand_ID__c = '3724313f-5b9b-496f-b8e9-411e00dd3e02';
        insert apiCallDetails;

        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Work_Assignment_Status__c = 'Requested,In Progress';
        portalSettings.Agency_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.CFG_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.Media_Status__c = 'Requested,In Progress';
        portalSettings.Excel_File_Processing_Status__c = 'Requested,In Progress,Completed';
        portalSettings.Valid_Payment_Types__c = '3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '9999';
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;
    }

    @isTest
    static void testMethod1() {
        Province_Tax_Rate_Mapping__mdt mdt = new Province_Tax_Rate_Mapping__mdt();
        mdt.Province_Name__c = 'Ontario';
        mdt.Total_Tax_Rate__c = 13;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Document_storage__c documentstoragecObj = new Document_storage__c(
            Creator__c = 'test value',
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj;

        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Creator__c = 'test value',
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
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
        prod.Data_Status_Description__c = 'Closed: Settled in Full';
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Settlement_Rate__c = null;
        prod.Recoverable_Fee__c = 2;
        prod.Non_Recoverable_Fee__c = 3;
        prod.Purchase_Province__c = 'BC';
        //prod.Purchase_Status__c = 'Putback Approved';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;

        Product__c prod1 = new Product__c();
        prod1.name = '1105P800';
        prod1.Payment_Setup_Status__c = 'Automated';
        prod1.Funding_Status__c = 'Released Batch';
        prod1.Funding_Type__c = 'Automated';
        prod1.Disbursement_Amount__c = 2000.00;
        prod1.Current_Balance__c = 7000;
        prod1.Current_Principal_Balance__c = 5000;
        prod1.Current_Interest_Amount__c = 2000;
        prod1.Current_Workflow__c = 'Collection Process';
        prod1.Requested_Close_Date__c = System.Today();
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Data_Status_Description__c = 'Closed: Settled in Full';
        prod1.Collection_Agency__c = 9999;
        prod1.Recalled_Date__c = System.today() - 10;
        prod1.State__c = 'ON';
        prod1.Commission_Adjustment__c = 30;
        prod1.Purchase_Province__c = 'BC';
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod1;

        Account_judgment__c accountjudgmentcObj = new Account_judgment__c(Product__c = prod1.id);
        insert accountjudgmentcObj;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            Placement__c = plcmnt.id,
            Pool_Commission_Rate__c = 20
        );
        insert placementhistorycObj;

        Placement_history__c placementhistorycObj1 = new Placement_history__c(
            product__c = prod1.id,
            Placement_Recall_Date__c = Date.today() - 10,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj1;

        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 5.1,
            Payment_Posting_Date__c = Date.today(),
            Payment_Type__c = '1000',
            Payment_Source__c = '2',
            Payment_Posting_Date_Text__c = '2022/09/14',
            Pay_Due__c = 20,
            CCS_Account__c = prod.Id,
            Payment_Provided_Agency__c = plcmnt.id,
            Ignore_Warning__c = true
        );
        insert productpaymentscObj;

        Product_payments__c productpaymentscObj1 = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Posting_Date__c = Date.today(),
            Payment_Type__c = '1000',
            Payment_Source__c = '2',
            Payment_Posting_Date_Text__c = '2022/09/15',
            Pay_Due__c = 20,
            CCS_Account__c = prod1.Id,
            Payment_Provided_Agency__c = plcmnt.id,
            Ignore_Warning__c = true
        );
        insert productpaymentscObj1;

        Product_payments__c productpaymentscObj2 = new Product_payments__c(
            Payment_Amount__c = 100,
            Payment_Posting_Date__c = Date.today(),
            Payment_Type__c = '1002',
            Payment_Source__c = '2',
            Payment_Posting_Date_Text__c = '2022/09/15',
            Pay_Due__c = 20,
            CCS_Account__c = prod.Id,
            Payment_Provided_Agency__c = plcmnt.id,
            Ignore_Warning__c = true
        );
        insert productpaymentscObj2;

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","pay_source":"2","tran_type":"3008","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P711","tran_type":"1001","tran_date":"2022/08/22","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null}]',
            wrkAss.Id,
            documentstoragecObj.Id
        );
        instance.processExcelFileRecords();
        ProductPaymentExcelFileProcessing.paymentRecordsWrapper wrapper = new ProductPaymentExcelFileProcessing.paymentRecordsWrapper();
        wrapper.accountID = '12345';
        wrapper.accountNumber = '12345';
        wrapper.tran_tax = '123';
        wrapper.payment_agency = '290';
        ProductPaymentExcelFileProcessing.nameFormat('Hello');
        instance.getCommissionRateValues();
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        instance.mapTaxMetadata = mcs;
    }

    @isTest
    static void testMethod2() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = false;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Purchase_Province__c = 'BC';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        insert prod;

        Placement_history__c placementhistorycObj1 = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj1;

        Judgment__c judgment = new Judgment__c();
        judgment.Legal_Status__c = 'Judgment';
        judgment.Legal_Sub_Status__c = 'Recommended for legal action';
        judgment.Legal_Agency__c = '29';
        insert judgment;

        Account_Judgment__c accJudgement = new Account_Judgment__c();
        accJudgement.Product__c = prod.Id;
        accJudgement.judgment__c = judgment.Id;
        insert accJudgement;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Posting_Date__c = Date.today() - 5,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

		Product_payments__c productpaymentscObj2 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod1.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = '1234'
        );
        insert productpaymentscObj2;
        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"23/05/01","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        instance.warehouseAgencyId = [SELECT Id FROM Placement__c WHERE Name = '9999' LIMIT 1].Id;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod3() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Balance Adjustment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = false;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Current_Balance__c = 7000;
        prod.Current_Principal_Balance__c = 5000;
        prod.Current_Interest_Amount__c = 2000;
        prod.Current_Workflow__c = 'Collection Process';
        prod.Requested_Close_Date__c = System.Today();
        prod.Status__c = 'Pending Recall - Client Request';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'Ontario';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        prod.Settlement_Rate__c = 2;
        prod.Purchase_Province__c = 'BC';
        insert prod;

        settlement__c settlementData = new settlement__c();
        settlementData.Product__c = prod.id;
        settlementData.Required_Amount__c = 10;
        settlementData.Payment_Frequency__c = 'One Time Payment';
        settlementData.Status__c = 'Approved';
        insert settlementData;

        Judgment__c judgment = new Judgment__c();
        judgment.Legal_Status__c = 'Judgment';
        judgment.Legal_Sub_Status__c = 'Recommended for legal action';
        judgment.Legal_Agency__c = '29';
        insert judgment;

        Account_Judgment__c accJudgement = new Account_Judgment__c();
        accJudgement.Product__c = prod.Id;
        accJudgement.judgment__c = judgment.Id;
        insert accJudgement;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1002',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Payment_Agency__c = '29',
            Ignore_Warning__c = true
        );

        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P700.0","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        Province_Tax_Rate_Mapping__mdt metaData = new Province_Tax_Rate_Mapping__mdt();
        metaData.Tax_Type__c = 'HST';
        metaData.Province_Name__c = 'ON';
        metaData.Province_Tax_Rate__c = 10;
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        mcs.put('Ontario', metaData);
        instance.mapTaxMetadata = mcs;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod4() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 2;
        insert pool;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Current_Balance__c = 7000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today() - 20;
        prod.Collection_Agency__c = 29;
        prod.Pool_Name__c = pool.id;
        prod.Data_Status_Description__c = 'Closed-test';
        prod.Purchase_Province__c = 'BC';
        insert prod;

        Product__c prod2 = new Product__c();
        prod2.name = '1105P700';
        prod2.Current_Balance__c = 7000;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Commission_Rate__c = 0;
        prod2.State__c = 'AB';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod2.Collection_Agency__c = 9999;
        prod2.Commission_Adjustment__c = 0;
        prod2.Pool_Name__c = pool.id;
        prod2.Purchase_Province__c = 'BC';
        insert prod2;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();

        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1001',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 20,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

        Product_payments__c productpaymentscObj2 = new Product_payments__c(
            Payment_Amount__c = 0,
            Payment_Type__c = '4000',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 20,
            Payment_Source__c = '2',
            Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
        );

        Product_payments__c productpaymentscObj3 = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Type__c = '1000',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 20,
            Payment_Source__c = '2',
            Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
        );
        Product_payments__c productpaymentscObj4 = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = -20,
            Payment_Source__c = '2',
            Original_Of_Payment_Reversal__c = 'a0DS000000EMBvAMAX',
            Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
        );
        Product_payments__c productpaymentscObj5 = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = -20,
            Payment_Source__c = '1',
            Original_Of_Payment_Reversal__c = 'a0DS000000EMBvAMAX',
            Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
        );
        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        prodList.add(productpaymentscObj2);
        prodList.add(productpaymentscObj3);
        prodList.add(productpaymentscObj4);
        prodList.add(productpaymentscObj5);
        productmap.put(prod.id, prod);

        insert productpaymentscObj;

        mapPlacementIDs.put(plcmnt.id, plcmnt);

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod5() {
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Document_storage__c documentstoragecObj = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj;

        Product__c prod1 = new Product__c();
        prod1.name = '1105P800';
        prod1.Collection_Agency__c = 9999;
        prod1.Recalled_Date__c = System.today() - 30;
        prod1.Commission_Adjustment__c = 10;
        prod1.Purchase_Province__c = 'BC';
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod1;

        Product__c prod2 = new Product__c();
        prod2.name = '1105P801';
        prod2.Collection_Agency__c = 29;
        prod2.Recalled_Date__c = System.today() - 30;
        prod2.Commission_Adjustment__c = 20;
        prod2.Purchase_Province__c = 'BC';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;

        Product__c prod3 = new Product__c();
        prod3.name = '1105P802';
        prod3.Collection_Agency__c = 29;
        prod3.Recalled_Date__c = System.today() - 30;
        prod3.Commission_Adjustment__c = 20;
        prod3.Purchase_Province__c = 'BC';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod3;

        Placement_history__c placementhistorycObj3 = new Placement_history__c(
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj3;

        Placement_history__c placementhistorycObj4 = new Placement_history__c(
            product__c = prod3.id,
            Placement_Recall_Date__c = Date.today() - 30,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj4;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P800","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P801","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P802","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"}]',
            '1234',
            documentstoragecObj.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod6() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(Placement_Recall_Date__c = System.today().addDays(-60), Product__c = prod.id);
        insert placementhistorycObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1001","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"direct_payment_type":"Equipment Return Payment","pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod7() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        insert plcmnt;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            Placement_Recall_Date__c = System.today().addDays(-14),
            Product__c = prod.id,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod8() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Balance Adjustment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = false;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Status__c = 'Recall Pending Recall - Client Request';
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        prod.Settlement_Rate__c = null;
        prod.Purchase_Province__c = 'BC';
        insert prod;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1002',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            Placement_Recall_Date__c = Date.today(),
            Product__c = prod.id,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod9() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        insert plcmnt;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        prod.Commission_Adjustment__c = 20;
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            Placement_Recall_Date__c = System.today().addDays(-14),
            Product__c = prod.id,
            Placement__c = plcmnt.id,
            Product_Commission_rate__C = 10
        );
        insert placementhistorycObj;

        Judgment__c judgment = new Judgment__c();
        judgment.Legal_Status__c = 'Pre-Judgment';
        judgment.Legal_Sub_Status__c = 'Claim Issued';
        judgment.Legal_Agency__c = '29';
        insert judgment;

        Account_Judgment__c accJudgement = new Account_Judgment__c();
        accJudgement.Product__c = prod.Id;
        accJudgement.judgment__c = judgment.Id;
        insert accJudgement;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod10() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        insert plcmnt;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        prod.Commission_Adjustment__c = 20;
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            Placement_Recall_Date__c = System.today().addDays(-14),
            Product__c = prod.id,
            Placement__c = plcmnt.id,
            Product_Commission_rate__C = 10
        );
        insert placementhistorycObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod11() {
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Document_storage__c documentstoragecObj = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj;

        Product__c prod2 = new Product__c();
        prod2.name = '1105P801';
        prod2.Collection_Agency__c = 29;
        prod2.Recalled_Date__c = System.today() - 30;
        prod2.Commission_Adjustment__c = 20;
        prod2.Purchase_Province__c = 'BC';
        prod2.Collection_Agency_Placement__c = plcmnt.id;
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;

        Placement_history__c placementhistorycObj3 = new Placement_history__c(
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj3;

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Status__c = 'Requested';
        wrkAss.Task_Number__c = 'TA-00007';
        insert wrkAss;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P800","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P801","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P802","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"}]',
            wrkAss.Id,
            documentstoragecObj.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod12() {
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Document_storage__c documentstoragecObj = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj;

        Product__c prod2 = new Product__c();
        prod2.name = '1105P801';
        prod2.Collection_Agency__c = 29;
        prod2.Recalled_Date__c = System.today() - 30;
        prod2.Commission_Adjustment__c = 20;
        prod2.Purchase_Province__c = 'BC';
        prod2.Collection_Agency_Placement__c = plcmnt.id;
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;

        Placement_history__c placementhistorycObj3 = new Placement_history__c(
            product__c = prod2.id,
            Placement_Recall_Date__c = Date.today() - 10,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj3;

        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Status__c = 'Requested';
        wrkAss.Task_Number__c = 'TA-00007';
        insert wrkAss;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P800","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P801","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P802","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"}]',
            wrkAss.Id,
            documentstoragecObj.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod13() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Purchase_Province__c = 'BC';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        insert prod;

        Placement_history__c placementhistorycObj1 = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj1;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Posting_Date__c = Date.today() - 5,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

		Product_payments__c productpaymentscObj2 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod1.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = '1234'
        );
        insert productpaymentscObj2;
        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.warehouseAgencyId = [SELECT Id FROM Placement__c WHERE Name = '9999' LIMIT 1].Id;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod14() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = false;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Requested_Close_Date__c = System.Today();
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Purchase_Province__c = 'BC';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        insert prod;

        Placement_history__c placementhistorycObj1 = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj1;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Posting_Date__c = Date.today() - 5,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

		Product_payments__c productpaymentscObj2 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod1.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = '1234'
        );
        insert productpaymentscObj2;
        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        Province_Tax_Rate_Mapping__mdt metaData = new Province_Tax_Rate_Mapping__mdt();
        metaData.Tax_Type__c = 'HST';
        metaData.Province_Name__c = 'ON';
        metaData.Province_Tax_Rate__c = 10;
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        mcs.put('Ontario', metaData);
        instance.mapTaxMetadata = mcs;
        instance.warehouseAgencyId = [SELECT Id FROM Placement__c WHERE Name = '9999' LIMIT 1].Id;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod15() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        prod.Collection_Agency__c = 29;
        prod.Commission_Adjustment__c = 20;
        prod.Collection_Agency_Placement__c = plcmnt.id;
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            Placement_Recall_Date__c = System.today().addDays(-14),
            Product__c = prod.id,
            Placement__c = plcmnt.id,
            Product_Commission_rate__C = 10
        );
        insert placementhistorycObj;

        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Type__c = '1001',
            CCS_Account__c = prod.Id,
            Payment_Source__c = '2',
            Pay_Due__c = 15
        );

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
    }

    @isTest
    static void testMethod17() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Direct Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = false;
        insert plcmnt;
        mapPlacementIDs.put(plcmnt.id, plcmnt);

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Purchase_Province__c = 'BC';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today();
        insert prod;

        Placement_history__c placementhistorycObj1 = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Pool_Commission_Rate__c = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj1;

        Judgment__c judgment = new Judgment__c();
        judgment.Legal_Status__c = 'Judgment';
        judgment.Legal_Sub_Status__c = 'Recommended for legal action';
        judgment.Legal_Agency__c = '29';
        insert judgment;

        Account_Judgment__c accJudgement = new Account_Judgment__c();
        accJudgement.Product__c = prod.Id;
        accJudgement.judgment__c = judgment.Id;
        insert accJudgement;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = -1.1,
            Payment_Posting_Date__c = Date.today() - 5,
            Payment_Type__c = '1003',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 123,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

		Product_payments__c productpaymentscObj2 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod1.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = '1234'
        );
        insert productpaymentscObj2;
        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);
        productmap.put(prod.id, prod);
        insert productpaymentscObj;

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        Province_Tax_Rate_Mapping__mdt metaData = new Province_Tax_Rate_Mapping__mdt();
        metaData.Tax_Type__c = 'HST';
        metaData.Province_Name__c = 'ON';
        metaData.Province_Tax_Rate__c = 10;
        metaData.Canada_Tax_rate__c = 12;
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        mcs.put('Ab', metaData);
        instance.mapTaxMetadata = mcs;
        instance.warehouseAgencyId = [SELECT Id FROM Placement__c WHERE Name = '9999' LIMIT 1].Id;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod18() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 2;
        insert pool;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Current_Balance__c = 7000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today() - 20;
        prod.Collection_Agency__c = 29;
        prod.Pool_Name__c = pool.id;
        prod.Data_Status_Description__c = 'Closed-test';
        prod.Purchase_Province__c = 'BC';
        insert prod;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();

        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 1.1,
            Payment_Type__c = '1001',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = null,
            Payment_Source__c = '2',
            Ignore_Warning__c = true
        );

        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);

        productmap.put(prod.id, prod);

        insert productpaymentscObj;

        //Judgment Record Creation
        Judgment__c judg3 = new Judgment__c();
        string recordid9 = [SELECT id FROM RecordType WHERE sobjecttype = 'Judgment__C' AND RecordType.Name = 'Judgment'].id;
        judg3.RecordTypeId = recordid9;
        judg3.Legal_Status__c = 'Post-Judgment';
        judg3.Legal_Sub_Status__c = 'Dormant';
        judg3.Legal_Agency__c = 'Test Agency';
        judg3.Filing_Date_Text__c = '2023-05-10';
        insert judg3;

        //Account-Judgment Record Creation
        Account_Judgment__c accjudg3 = new Account_Judgment__c();
        accjudg3.Product__c = prod.id;
        accjudg3.Judgment__c = judg3.id;
        accjudg3.Status__c = 'Active';
        insert accjudg3;

        mapPlacementIDs.put(plcmnt.id, plcmnt);

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        Province_Tax_Rate_Mapping__mdt metaData = new Province_Tax_Rate_Mapping__mdt();
        metaData.Tax_Type__c = 'HST';
        metaData.Province_Name__c = 'ON';
        metaData.Province_Tax_Rate__c = 10;
        metaData.Canada_Tax_rate__c = 12;
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        mcs.put('Ab', metaData);
        instance.mapTaxMetadata = mcs;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }

    @isTest
    static void testMethod19() {
        Document_storage__c documentstoragecObj2 = new Document_storage__c(
            Document_Name__c = 'Product Payment Upload File',
            Document_Type__c = 'Product Payment Upload File',
            Uploaded_By__c = 'Internal User'
        );
        insert documentstoragecObj2;

        Placement__c plcmnt = new Placement__c();
        plcmnt.name = '1234';
        plcmnt.Commission_rate__c = 2;
        plcmnt.Apply_Ontario_Rate_on_Legal_Account__c = true;
        insert plcmnt;

        Pool__c pool = new Pool__c();
        pool.Commission_Rate__c = 2;
        insert pool;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
        prod.Current_Balance__c = 7000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Commission_Rate__c = 0;
        prod.State__c = 'AB';
        prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Recalled_Date__c = system.today() - 20;
        prod.Collection_Agency__c = 29;
        prod.Pool_Name__c = pool.id;
        prod.Data_Status_Description__c = 'Closed-test';
        prod.Purchase_Province__c = 'BC';
        insert prod;

        List<Product_payments__c> prodList = new List<Product_payments__c>();
        Map<Id, product__c> productmap = new Map<Id, product__c>();
        Map<Id, Placement__c> mapPlacementIDs = new Map<Id, Placement__c>();
        Map<String, String> mapAccountPrimaryNumber = new Map<String, String>();

        Product_payments__c productpaymentscObj = new Product_payments__c(
            Payment_Amount__c = 100,
            Payment_Type__c = '1001',
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
            CCS_Account_Name__c = 'test',
            Pay_Due__c = 10,
            Payment_Source__c = '1',
            Payment_Provided_Agency__c = plcmnt.id,
            Agency_Calculated_Comm__c = 50,
            Ignore_Warning__c = true
        );

        mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c, '1263');

        prodList.add(productpaymentscObj);

        productmap.put(prod.id, prod);

        insert productpaymentscObj;

        Placement_history__c placementhistorycObj = new Placement_history__c(
            product__c = prod.id,
            Placement_Recall_Date__c = Date.today() - 10,
            CreatedDate = system.today() - 50,
            Product_Commission_rate__C = 20,
            Placement__c = plcmnt.id
        );
        insert placementhistorycObj;

        //Judgment Record Creation
        Judgment__c judg3 = new Judgment__c();
        string recordid9 = [SELECT id FROM RecordType WHERE sobjecttype = 'Judgment__C' AND RecordType.Name = 'Judgment'].id;
        judg3.RecordTypeId = recordid9;
        judg3.Legal_Status__c = 'Post-Judgment';
        judg3.Legal_Sub_Status__c = 'Dormant';
        judg3.Legal_Agency__c = 'Test Agency';
        judg3.Filing_Date_Text__c = '2023-05-10';
        insert judg3;

        //Account-Judgment Record Creation
        Account_Judgment__c accjudg3 = new Account_Judgment__c();
        accjudg3.Product__c = prod.id;
        accjudg3.Judgment__c = judg3.id;
        accjudg3.Status__c = 'Active';
        insert accjudg3;

        mapPlacementIDs.put(plcmnt.id, plcmnt);

        ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(
            '[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"","tran_amount":"","tran_principal":"9","tran_interest":null,"tran_court":"89","tran_attorney":null,"tran_nsf":null,"tran_general":"1.0","tran_other":"1.0","tran_retained":"1.0"},{"data_id":"1105P701","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","tran_principal":null,"tran_interest":"9","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null,"billing_entity":"93","fee_type":"test"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","tran_principal":null,"tran_interest":"10","tran_court":null,"tran_attorney":"abc","tran_nsf":null,"tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","tran_principal":null,"tran_interest":"11","tran_court":null,"tran_attorney":null,"tran_nsf":"test","tran_general":null,"tran_other":null,"tran_retained":null},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","tran_principal":null,"tran_interest":"12","tran_court":null,"tran_attorney":null,"tran_nsf":null,"tran_general":null,"tran_other":null,"pri_acctno":23434.00,"commission_rate":"2","pay_source":"8928.0","tran_retained":null}]',
            '1234',
            documentstoragecObj2.Id
        );
        instance.processExcelFileRecords();
        Province_Tax_Rate_Mapping__mdt metaData = new Province_Tax_Rate_Mapping__mdt();
        metaData.Tax_Type__c = 'HST';
        metaData.Province_Name__c = 'ON';
        metaData.Province_Tax_Rate__c = 10;
        metaData.Canada_Tax_rate__c = 12;
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        mcs.put('Ab', metaData);
        instance.mapTaxMetadata = mcs;
        instance.validationOnRecordUpdate(prodList, productmap, documentstoragecObj2, mapAccountPrimaryNumber, mapPlacementIDs);
    }
}