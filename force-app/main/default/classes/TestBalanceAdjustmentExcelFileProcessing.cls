@isTest
private class TestBalanceAdjustmentExcelFileProcessing{
    static{
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
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
        portalSettings.Valid_Payment_Types__c='3000,5000,1000,1001,1002,7000,4000,1003,7001,1004,4002,4003,5001,4001,3400,5003,5002';
        insert portalSettings;
    }
    
    @isTest static void testMethod1(){
		Document_storage__c documentstoragecObj = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Product Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );
		
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );

        insert documentstoragecObj;
		insert documentstoragecObj2;
        Account_judgment__c accountjudgmentcObj = new Account_judgment__c ();
        insert accountjudgmentcObj;
        
		Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = Date.today()
        );
        insert placementhistorycObj;
        
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
        prod.Status__c = 'Pending Recall - PIF';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert prod;
         
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1000',
            Payment_Source__c='1',
            CCS_Account__c = prod.Id,
            Direct_Payment_Type__c = 'Balance adjustment due for Equipment Return',
            Agency_Calculated_Comm__c = 25.00,
            Ignore_Warning__c = true
        );
        insert productpaymentscObj;
		
        Product_payments__c productpaymentscObj1 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='4000',
            Payment_Source__c='1',
            CCS_Account__c = prod.Id,
            Direct_Payment_Type__c = 'Direct Payment',
            Agency_Calculated_Comm__c = 25.00,
            Ignore_Warning__c = true
        );
        insert productpaymentscObj1;
        
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1000","tran_date":"07-01-2022T","tran_amount":"1000,0","pay_principal":"9,00","pay_interest":"25,00","direct_payment_type":"Balance adjustment due for Equipment Return"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":"25.00","pay_interest":"9.00","commission_rate_override":"24"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]',wrkAss.Id,documentstoragecObj.Id);
		instance.processExcelFileRecords();
		BalanceAdjustmentExcelFileProcessing.nameFormat('Hello');
		instance.getCommissionRateValues();
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        instance.mapTaxMetadata = mcs;
                
    }

    @isTest static void testMethod2(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );

		insert documentstoragecObj2;
        Account_judgment__c accountjudgmentcObj = new Account_judgment__c ();
        insert accountjudgmentcObj;
		
		Placement__c plcmnt = new Placement__c();
		plcmnt.name = '1234';
		plcmnt.Commission_rate__c = 2;
		insert plcmnt;
        
		Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = Date.today()
        );
        insert placementhistorycObj;
        
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
		prod.Commission_Rate__c = 0;
		prod.State__c = 'AB';
		prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today();
        insert prod;
        
        Product__c prod1 = new Product__c();
        prod1.name = '1105P811';
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
		prod1.Commission_Rate__c = 0;
		prod1.State__c = 'AB';
		prod1.Commission_Adjustment__c = 2;
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod1.Recalled_Date__c = system.today();
        insert prod1;
		
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Judgment';
		judgment.Legal_Sub_Status__c = 'Recommended for legal action';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		List<Product_payments__c> prodList = new List<Product_payments__c>();
		Map<Id,product__c> productmap = new map<Id,product__c>();
		Map<String,String> mapAccountPrimaryNumber = new Map<String,String>();
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Posting_Date__c = Date.today(), 
            Payment_Type__c ='1003', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = '1234',
            Commission_Rate_for_Payment__c = 10
            
        );
        Product_payments__c productpaymentscObj1 = new Product_payments__c (
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
		mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c,'1263');

		prodList.add(productpaymentscObj);
		productmap.put(prod.id,prod);
        insert productpaymentscObj;
		
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
		
		

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1002","tran_date":"07/01/2022T","tran_amount":"","pay_principal":"9","pay_interest":null,"direct_payment_type":"ABC","pay_source":"5"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/01/2022T","tran_amount":"1000,0","pay_principal":"9","pay_interest":null},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12","pay_source":"3"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
		BalanceAdjustmentExcelFileProcessing.nameFormat('Hello');
		instance.getCommissionRateValues();
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        instance.mapTaxMetadata = mcs;
		instance.validationOnRecordUpdate(prodList,productmap,documentstoragecObj2,mapAccountPrimaryNumber);

    }
	
	@isTest static void testMethod3(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );

		insert documentstoragecObj2;
         Account_judgment__c accountjudgmentcObj = new Account_judgment__c ();
        insert accountjudgmentcObj;
        
		Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = Date.today()
        );
        insert placementhistorycObj;
            
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
		prod.Commission_Rate__c = 0;
		prod.State__c = 'AB';
		prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today();
		prod.Collection_Agency__c =29;
		prod.Settlement_Rate__c = 2;
		prod.Current_Balance__c = 9;
        insert prod;
		
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Post-Judgment';
		judgment.Legal_Sub_Status__c = 'Payment Arrangement';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		List<Product_payments__c> prodList = new List<Product_payments__c>();
		Map<Id,product__c> productmap = new map<Id,product__c>();
		Map<String,String> mapAccountPrimaryNumber = new Map<String,String>();
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Type__c ='1001', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Commission_Rate_for_Payment__c = 0,
            Ignore_Warning__c = true
			);
				
		mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c,'1263');

		prodList.add(productpaymentscObj);
		productmap.put(prod.id,prod);
        insert productpaymentscObj;
		
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
		
		Placement__c plcmnt = new Placement__c();
		plcmnt.name = '1234';
		plcmnt.Commission_rate__c = 2;
		insert plcmnt;

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1002","tran_date":"07-01-2022T","tran_amount":"-10","pay_principal":"9","pay_interest":null,"Commsion_Rate_Override":"24","direct_payment_type":"Direct Payment"},{"data_id":"1105P811","tran_type":"1002","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10","Agency_Allocation":"29","Commsion_Rate_Override":"24"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12","Commsion_Rate_Override":"24","pay_source":"3.00","Agency_Allocation":"29"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
		BalanceAdjustmentExcelFileProcessing.nameFormat('Hello');
		instance.getCommissionRateValues();
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        instance.mapTaxMetadata = mcs;
		instance.validationOnRecordUpdate(prodList,productmap,documentstoragecObj2,mapAccountPrimaryNumber);

    }
	
	@isTest static void testMethod4(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );

		insert documentstoragecObj2;
         Account_judgment__c accountjudgmentcObj = new Account_judgment__c ();
        insert accountjudgmentcObj;
        
		
        
		Pool__c pool = new Pool__c();
		pool.Commission_Rate__c = 2;
		insert pool;

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
		prod.Commission_Rate__c = 0;
		prod.State__c = 'AB';
		prod.Commission_Adjustment__c = 2;
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today();
		prod.Collection_Agency__c =NULL;
		prod.Current_Balance__c = 9;
		prod.Pool_Name__c = pool.id;
		prod.Settlement_Rate__c = 2;
		prod.Current_Balance__c  = 3;
        insert prod;
				
		Product__c prod2 = new Product__c();
        prod2.name = '1105P700';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Released Batch';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 2000.00;
        prod2.Current_Balance__c = 7000;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2000;
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
		prod2.Commission_Rate__c = 0;
		prod2.State__c = 'AB';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod2.Recalled_Date__c = system.today();
		prod2.Collection_Agency__c =29;
		prod2.Current_Balance__c = 9;
		prod2.Commission_Adjustment__c = 0;
		prod2.Pool_Name__c = pool.id;
		prod2.Settlement_Rate__c = 2;
		prod2.Current_Balance__c  = 3;
        prod2.Recalled_Date__c = Date.newInstance(2022, 09, 22);
        insert prod2;
		
        Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = System.today().addDays(-60),
            Product__c = prod.id
        );
        insert placementhistorycObj;
        
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Pre-Judgment';
		judgment.Legal_Sub_Status__c = 'Claim Issued';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		List<Product_payments__c> prodList = new List<Product_payments__c>();
		Map<Id,product__c> productmap = new map<Id,product__c>();
		Map<String,String> mapAccountPrimaryNumber = new Map<String,String>();
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Type__c ='1001', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
            Payment_Agency__c = NULL,
            Ignore_Warning__c = true
			);
			Product_payments__c productpaymentscObj2 = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='8900', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);

			Product_payments__c productpaymentscObj3 = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);
			Product_payments__c productpaymentscObj4 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Type__c ='1003', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);
			Product_payments__c productpaymentscObj5 = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);
			Product_payments__c productpaymentscObj6 = new Product_payments__c (
            Payment_Amount__c = 1.1, 
            Payment_Type__c ='1003', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);
			
			Product_payments__c productpaymentscObj7 = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1000', 
            Payment_Posting_Date_Text__c = 'test value',
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Pay_Due__c =  null,
			Payment_Source__c = '2',
			Payment_Posting_Date__c = Date.newInstance(2023, 10, 30)
			);

		mapAccountPrimaryNumber.put(productpaymentscObj.CCS_Account_Name__c,'1263');

		prodList.add(productpaymentscObj);
		prodList.add(productpaymentscObj2);
		prodList.add(productpaymentscObj3);
		prodList.add(productpaymentscObj4);
		prodList.add(productpaymentscObj5);
		prodList.add(productpaymentscObj6);
		prodList.add(productpaymentscObj7);

		productmap.put(prod.id,prod);
		productmap.put(prod2.id,prod);
        insert productpaymentscObj;
		
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Payment Sub-Purpose 1';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
		
		Placement__c plcmnt = new Placement__c();
		plcmnt.name = '1234';
		plcmnt.Commission_rate__c = 2;
		insert plcmnt;
        
        Placement_History__c plcmntHist = new Placement_History__c();
		plcmntHist.Product__c = prod.Id;
        plcmntHist.Placement_Recall_Date__c = Date.newInstance(2022, 07, 30);
		insert plcmntHist;

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1001","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"direct_payment_type":"Equipment Return Payment","pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
		BalanceAdjustmentExcelFileProcessing.nameFormat('Hello');
		instance.getCommissionRateValues();
        Map<String, Province_Tax_Rate_Mapping__mdt> mcs = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        instance.mapTaxMetadata = mcs;
        instance.mapProvinceAcronymTaxMetadata = mcs;
		instance.validationOnRecordUpdate(prodList,productmap,documentstoragecObj2,mapAccountPrimaryNumber);

    }
    
    @isTest static void testMethod5(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );
		insert documentstoragecObj2;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
		prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today().addDays(-20);
		prod.Collection_Agency__c =9999;
        insert prod;	
        
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Pre-Judgment';
		judgment.Legal_Sub_Status__c = 'Claim Issued';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1001', 
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Payment_Source__c = '2',
            Payment_Agency__c = NULL
			);

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1001","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"direct_payment_type":"Equipment Return Payment","pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
    }
    
    @isTest static void testMethod6(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );
		insert documentstoragecObj2;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
		prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today();
		prod.Collection_Agency__c =29;
        insert prod;	
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = System.today().addDays(-60),
            Product__c = prod.id
        );
        insert placementhistorycObj;
        
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Pre-Judgment';
		judgment.Legal_Sub_Status__c = 'Claim Issued';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1001', 
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Payment_Source__c = '2',
            Payment_Agency__c = NULL,
            Agency_Calculated_Comm__c = 10
			);

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"1001","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"direct_payment_type":"Equipment Return Payment","pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
    }
	
    @isTest static void testMethod7(){
		Document_storage__c documentstoragecObj2 = new Document_storage__c (
            Creator__c = 'test value', 
            Document_Name__c = 'Product Payment Upload File', 
            Document_Type__c = 'Direct Payment Upload File', 
            Uploaded_By__c ='Internal User'
        );
		insert documentstoragecObj2;

        Product__c prod = new Product__c();
        prod.name = '1105P700';
		prod.State__c = 'AB';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
		prod.Recalled_Date__c = system.today();
		prod.Collection_Agency__c =29;
        insert prod;	
        
        Placement_history__c placementhistorycObj = new Placement_history__c (
            Placement_Recall_Date__c = System.today().addDays(-14),
            Product__c = prod.id
        );
        insert placementhistorycObj;
        
		Judgment__c judgment = new Judgment__c();
		judgment.Legal_Status__c ='Pre-Judgment';
		judgment.Legal_Sub_Status__c = 'Claim Issued';
		judgment.Legal_Agency__c = '29';
		insert judgment;
		
		Account_Judgment__c accJudgement = new Account_Judgment__c();
		accJudgement.Product__c = prod.Id;
		accJudgement.judgment__c = judgment.Id;
		insert accJudgement;
		
		Product_payments__c productpaymentscObj = new Product_payments__c (
            Payment_Amount__c = -1.1, 
            Payment_Type__c ='1001', 
            CCS_Account__c = prod.Id,
			CCS_Account_Name__c = 'test',
			Payment_Source__c = '2',
            Payment_Agency__c = NULL,
            Agency_Calculated_Comm__c = 10
			);

		BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing('[{"data_id":"1105P700.0","tran_type":"","tran_date":"","tran_amount":"1000,0","pay_principal":"9","pay_interest":null,"pay_source":"2"},{"data_id":"1105P811","tran_type":"1000","tran_date":"07/12/2022","tran_amount":"1000.0","pay_principal":null,"pay_interest":"9"},{"data_id":"1105P711","tran_type":"1001","tran_date":"07/08/2022","tran_amount":"15909.06","pay_principal":null,"pay_interest":"10"},{"data_id":"1105P865","tran_type":"1002","tran_date":"07/07/2022","tran_amount":"10000","pay_principal":null,"pay_interest":"11"},{"data_id":"1106P052","tran_type":"3000","tran_date":"07/09/2022","tran_amount":"200","pay_principal":null,"pay_interest":"12"}]','1234',documentstoragecObj2.Id);
		instance.processExcelFileRecords();
    }
    
}