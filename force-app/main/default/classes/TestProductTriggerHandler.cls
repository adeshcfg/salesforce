/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class contains unit tests for validating behavior of ProductTriggerHandler
 *  @author : A5E Consulting
 *  @date : 10/14/2016
 *
 *************************************************************************************************/
@isTest
private class TestProductTriggerHandler {
    //Initialize Custom Settings
    static {
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.Run_Product_Validation_Trigger__c = true;
        loanSettings.Run_Product_Trigger__c = true;
        loanSettings.Run_Product_Before_Trigger__c = true;
        loanSettings.Load_Customer_Data__c = true;
        loanSettings.Canaccede_API_User__c = 'abc@xyz.com';
        loanSettings.EnableNewAccountNameCreationLogic__c = true;
        insert loanSettings;

        API_Call_Details__c settings = new API_Call_Details__c();
        /*apiCallDetails.name = 'Agency Portal API';
apiCallDetails.API_Request_Timeout__c = 90000;
apiCallDetails.PDF_API_URL__c = 'https://api-agencies-uat.canaccede.com/api/Document/';
apiCallDetails.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
apiCallDetails.Client_ID__c = 'f647baee-683f-4e34-95f0-611a3482baae';
apiCallDetails.Client_Secret__c ='.uE7Q~glV.Ks.SacXYsRRRnWbXAT~2dxHkiPW';
apiCallDetails.Proxy_Client_ID__c = 'd4849d4d-eb42-4933-9403-7c512af05dd5';
apiCallDetails.Scope_Prefix__c ='https://canaccedeb2ctestdev.onmicrosoft.com/';
apiCallDetails.Scope_Suffix__c ='/.default';
apiCallDetails.Tenand_ID__c ='3724313f-5b9b-496f-b8e9-411e00dd3e02';
insert apiCallDetails;*/

        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Placement_Status_Code_Mapping__c placeStatusCode = new Placement_Status_Code_Mapping__c();
        placeStatusCode.Name = '111010';
        placeStatusCode.Parent_Status__c = 'Demand Letters';
        placeStatusCode.Status__c = 'In Process';
        placeStatusCode.Sub_Status__c = 'Initial Letter Sent';
        placeStatusCode.Placement_Status_Code__c = '111010';
        placeStatusCode.Data_Status_Code__c = '';
        placeStatusCode.Data_Status_Description__c = '';
        placeStatusCode.Complete_Status__c = 'Demand Letters - In Process - Initial Letter Sent';
        insert placeStatusCode;

        Placement_Status_Code_Mapping__c placeStatusCode1 = new Placement_Status_Code_Mapping__c();
        placeStatusCode1.Name = '111600';
        placeStatusCode1.Parent_Status__c = 'Demand Letters';
        placeStatusCode1.Status__c = 'Media Requested';
        placeStatusCode1.Sub_Status__c = '';
        placeStatusCode1.Placement_Status_Code__c = '111600';
        placeStatusCode1.Data_Status_Code__c = '';
        placeStatusCode1.Data_Status_Description__c = '';
        placeStatusCode1.Complete_Status__c = 'Demand Letters - Media Requested';
        insert placeStatusCode1;

        Placement_Status_Code_Mapping__c placeStatusCode2 = new Placement_Status_Code_Mapping__c();
        placeStatusCode2.Name = '100000';
        placeStatusCode2.Parent_Status__c = 'New Allocation';
        placeStatusCode2.Status__c = 'New Allocation ';
        placeStatusCode2.Sub_Status__c = 'Ready';
        placeStatusCode2.Placement_Status_Code__c = '100000';
        placeStatusCode2.Data_Status_Code__c = '300000';
        placeStatusCode2.Data_Status_Description__c = 'Placement (3); Allocated';
        placeStatusCode2.Complete_Status__c = 'New Allocation - New AllocationReady';
        insert placeStatusCode2;

        Placement_Status_Code_Mapping__c placeStatusCode3 = new Placement_Status_Code_Mapping__c();
        placeStatusCode3.Name = 'Testing';
        placeStatusCode3.Parent_Status__c = 'New Allocation';
        placeStatusCode3.Status__c = 'New Allocation ';
        placeStatusCode3.Sub_Status__c = 'Ready';
        placeStatusCode3.Placement_Status_Code__c = 'Testing';
        placeStatusCode3.Data_Status_Code__c = '300000';
        placeStatusCode3.Data_Status_Description__c = 'Placement (3); Allocated';
        placeStatusCode3.Complete_Status__c = 'New Allocation - New AllocationReady';
        insert placeStatusCode3;

        Placement_Status_Code_Mapping__c placeStatusCode4 = new Placement_Status_Code_Mapping__c();
        placeStatusCode4.Name = '100010';
        placeStatusCode4.Parent_Status__c = 'Demand Letters';
        placeStatusCode4.Status__c = 'In Process';
        placeStatusCode4.Sub_Status__c = 'Initial Letter Sent';
        placeStatusCode4.Placement_Status_Code__c = '100010';
        placeStatusCode4.Data_Status_Code__c = '';
        placeStatusCode4.Data_Status_Description__c = '';
        placeStatusCode4.Complete_Status__c = 'In Process - Initial Letter Sent';
        insert placeStatusCode4;

        Business_Separator_Settings__c bs = new Business_Separator_Settings__c();
        bs.name = 'CCS Account';
        bs.value__c = 'Canaccede Customer';
        insert bs;

        Data_Status_Mapping__c dataMap = new Data_Status_Mapping__c();
        dataMap.name = '310000';
        dataMap.Description__C = 'Test';
        insert dataMap;

        Data_Status_Mapping__c dataMap1 = new Data_Status_Mapping__c();
        dataMap1.name = 'Test';
        dataMap1.Description__C = 'Test';
        insert dataMap1;

        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.Run_Product_Name_Logic__c = true;
        insert portalSettings;
        
        //Portfolio record creation
        Portfolio_Name__c portfolio_AAL = new Portfolio_Name__c();
        portfolio_AAL.Name = 'MBNA25';
        portfolio_AAL.Account_Purchasing_Entity_ID__c = 'test';
        portfolio_AAL.CIML_Reporting_Name__c = 'testing portfolio'; 
        portfolio_AAL.Portfolio_Group_Name__c = 'AAL';
        portfolio_AAL.Purchase_ID__c = 7060;
        insert portfolio_AAL;
    }

    //Test Before Update
    static testMethod void productBeforeUpdateTest() {
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        insert config;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

        Statute_Date_Update__mdt mdt = new Statute_Date_Update__mdt();
        mdt.Months__c = 10;
        mdt.MasterLabel = 'Alberta';

        //insert mdt;

        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Pool__c pool = new Pool__c();
        pool.Placement_Agency__c = 89;
        insert pool;

        Pool__c pool1 = new Pool__c();
        pool1.Placement_Agency__c = 29;
        insert pool1;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '30';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        Placement__c plcgy2 = new Placement__c();
        plcgy2.Name = '40';
        plcgy2.Agency_Email__c = 'test@gmail.com';
        insert plcgy2;

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;

        Product__c prod = new Product__c();
        prod.name = '123451212';
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
        prod.Last_Name__c = 'xyz';
        prod.Pool_Name__c = pool.id;
        prod.Collection_Agency__c = 30;
        prod.Placement_Status__c = '100010';
        prod.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod.state__c = 'Alberta';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod.Purchase_Province__c = 'PE';
        prod.Customer__c = customer.id;
        insert prod;

        Product__c prod1 = new Product__c();
        prod1.name = '123455667';
        prod1.Payment_Setup_Status__c = 'Automated';
        prod1.Collection_Agency__c = 30;
        prod1.Funding_Status__c = 'Pending';
        prod1.Funding_Type__c = 'Automated';
        prod1.Disbursement_Amount__c = 1000.00;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Last_Name__c = 'xyz';
        prod1.Pool_Name__c = pool.id;
        prod1.Placement_Status__c = '100010';
        prod1.Purchase_Province__c = 'PE';
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        prod1.Customer__c = customer.id;
        prod1.Last_Name__c = 'TestLastName';
        insert prod1;

        prod1.Funding_Status__c = 'Released';
        update prod1;

        Product__c prod2 = new Product__c();
        List<User> systemName = [SELECT Name FROM User WHERE Name = 'System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 30;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Last_Name__c = 'xyz';
        prod2.Pool_Name__c = pool.id;
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c = null;
        prod2.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prod2.Purchase_Province__c = 'PE';
        prod2.Customer__c = customer1.id;
        insert prod2;

        Product__c prod6 = new Product__c();
        List<User> systemName1 = [SELECT Name FROM User WHERE Name = 'System API'];
        prod6.name = '123454522';
        prod6.Internal_Status__c = 'Active';
        prod6.Payment_Setup_Status__c = 'Automated';
        prod6.Funding_Status__c = 'Funded';
        prod6.Funding_Type__c = 'Automated';
        prod6.Disbursement_Amount__c = 3000.00;
        prod6.Collection_Agency__c = 30;
        prod6.Current_Balance__c = 7730;
        prod6.Current_Principal_Balance__c = 5000;
        prod6.Current_Interest_Amount__c = 2730;
        prod6.product_status__C = '310000';
        prod6.Current_Workflow__c = 'Collection Process';
        prod6.Requested_Close_Date__c = System.Today();
        prod6.Status__c = 'New Allocation - New Allocation';
        prod6.Sub_Status__c = 'Ready';
        prod6.Product_Status__c = 'Test';
        prod6.Last_Name__c = 'xyz';
        prod6.Pool_Name__c = pool.id;
        prod6.Placement_Status__c = '100010';
        prod6.Credit_Counselling_Date__c = null;
        prod6.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod6.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        //prod2.Insolvency_Date__c =Date.newInstance(2016, 12, 9);
        prod6.Customer__c = customer1.id;
        prod6.Purchase_Province__c = 'PE';
        insert prod6;

        Product__c prod8 = new Product__c();
        List<User> systemName2 = [SELECT Name FROM User WHERE Name = 'System API'];
        prod8.name = '1234545221';
        prod8.Internal_Status__c = 'Active';
        prod8.Payment_Setup_Status__c = 'Automated';
        prod8.Funding_Status__c = 'Funded';
        prod8.Funding_Type__c = 'Automated';
        prod8.Disbursement_Amount__c = 3000.00;
        prod8.Collection_Agency__c = 30;
        prod8.Current_Balance__c = 7730;
        prod8.Current_Principal_Balance__c = 5000;
        prod8.Current_Interest_Amount__c = 2730;
        prod8.product_status__C = '310000';
        prod8.Current_Workflow__c = 'Collection Process';
        prod8.Requested_Close_Date__c = System.Today();
        prod8.Status__c = 'New Allocation - New Allocation';
        prod8.Sub_Status__c = 'Ready';
        prod8.Product_Status__c = 'Test';
        prod8.Last_Name__c = 'xyz';
        prod8.Pool_Name__c = pool.id;
        prod8.Placement_Status__c = '100010';
        prod8.Credit_Counselling_Date__c = null;
        prod8.Purchase_Status__c = 'Buyback/Putback Approved';
        prod8.Putback_Buyback_Amount__c = 100;
        prod8.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod8.Customer__c = customer1.id;
        prod8.Purchase_Province__c = 'PE';
        insert prod8;

        Product__c prod10 = new Product__c();
        List<User> systemName3 = [SELECT Name FROM User WHERE Name = 'System API'];
        prod10.Purchase_Province__c = 'PE';
        prod10.name = '1234547888';
        prod10.Internal_Status__c = 'Active';
        prod10.Payment_Setup_Status__c = 'Automated';
        prod10.Funding_Status__c = 'Funded';
        prod10.Funding_Type__c = 'Automated';
        prod10.Disbursement_Amount__c = 3000.00;
        prod10.Collection_Agency__c = 30;
        prod10.Current_Balance__c = 7730;
        prod10.Current_Principal_Balance__c = 5000;
        prod10.Current_Interest_Amount__c = 2730;
        prod10.product_status__C = '310000';
        prod10.Current_Workflow__c = 'Collection Process';
        prod10.Requested_Close_Date__c = System.Today();
        prod10.Status__c = 'New Allocation - New Allocation';
        prod10.Sub_Status__c = 'Ready';
        prod10.Product_Status__c = 'Test';
        prod10.Last_Name__c = 'xyz';
        prod10.Pool_Name__c = pool.id;
        prod10.Placement_Status__c = '100010';
        prod10.Credit_Counselling_Date__c = null;
        prod10.Purchase_Status__c = 'Buyback/Putback Approved';
        prod10.Putback_Buyback_Amount__c = 100;
        prod10.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod10.Customer__c = customer1.id;
        insert prod10;

        List<Product__c> prodList = new List<Product__c>();
        List<Product__c> prodListData = new List<Product__c>();
        //prodList.add(prod);
        //prodList.add(prod2);

        Map<ID, Product__c> prodMap = new Map<ID, Product__c>();
        prodMap.put(prod.id, prod);
        prodMap.put(prod2.id, prod2);
        prodMap.put(prod1.id, prod1);
        prodMap.put(prod6.id, prod6);
        prodMap.put(prod8.id, prod8);
        prodMap.put(prod10.id, prod10);

        product__c prod3 = new product__c();
        prod3.Id = Prod2.Id;
        prod3.Collection_Agency__c = 40;
        prod3.Funding_Status__c = 'Released';
        prod3.Product_Status__c = 'Test';
        system.debug('prod2' + prod2);
        prod3.Status__c = 'In Process';
        prod3.Sub_Status__c = 'Initial Letter Sent';
        prod3.Placement_Status__c = '100010';
        prod3.Invalid_Submission__c = true;
        prod3.Refer_to_Legal__c = 'Approved';
        prod3.Last_Name__c = 'xyz';
        prod3.State__c = 'MB';
        prod3.Pool_Name__c = pool1.id;
        prod3.Collection_Sub_Status__c = 'Credit Counselling';
        prod3.Interest_Rate__c = 5;
        prod3.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Deceased_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Last_Payment_Date__c = Date.newInstance(2022, 8, 9);
        //prod3.Date_for_Stat_Barred_calculations__c = Date.newInstance(2022, 8, 9);
        prod3.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod3.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod3.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod3.Purchase_Province__c = 'PE';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod3.Customer__c = null;
        prod3.Last_Name__c = 'Test';
        system.debug('prod2' + prod2);

        product__c prod4 = new product__c();
        prod4.id = prod.ID;
        prod4.Disbursement_Amount__c = 1000.00;
        prod4.Collection_Agency__c = null;
        prod4.Purchase_Province__c = 'PE';
        prod4.Placement_Status__c = 'Testing';
        prod4.Status__c = 'In Process';
        prod4.Pool_Name__c = pool.id;
        prod4.Refer_to_Legal__c = 'Declined';
        prod4.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod4.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod4.State__c = 'Alberta';
        prod4.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod4.Purchase_Status__c = 'Buyback/Putback Initiated';
        //update prod;

        product__c prod5 = new product__c();
        prod5.id = prod1.ID;
        prod5.Disbursement_Amount__c = 1000.00;
        prod5.Collection_Agency__c = 40;
        prod5.Placement_Status__c = 'Testing';
        prod5.Status__c = 'In Process';
        prod5.Pool_Name__c = pool.id;
        prod5.Refer_to_Legal__c = 'Declined';
        prod5.Last_Payment_Date__c = Date.newInstance(2022, 10, 9);
        prod5.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod5.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod5.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod5.Purchase_Province__c = 'PE';

        product__c prod7 = new product__c();
        prod7.id = prod6.ID;
        prod7.Disbursement_Amount__c = 1000.00;
        prod7.Collection_Agency__c = 40;
        prod7.Placement_Status__c = 'Testing';
        prod7.Status__c = 'In Process';
        prod7.Pool_Name__c = pool.id;
        prod7.Refer_to_Legal__c = 'Declined';
        prod7.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod7.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod7.Purchase_Province__c = 'PE';
        prod7.Purchase_Status__c = 'Buyback/Putback Initiated';

        product__c prod9 = new product__c();
        prod9.id = prod8.ID;
        prod9.Purchase_Province__c = 'PE';
        prod9.Disbursement_Amount__c = 1000.00;
        prod9.Collection_Agency__c = 40;
        prod9.Placement_Status__c = 'Testing';
        prod9.Status__c = 'In Process';
        prod9.Pool_Name__c = pool.id;
        prod9.Refer_to_Legal__c = 'Declined';
        prod9.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod9.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod9.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';

        product__c prod11 = new product__c();
        prod11.id = prod10.ID;
        prod11.Disbursement_Amount__c = 1000.00;
        prod11.Collection_Agency__c = 40;
        prod11.Placement_Status__c = 'Testing';
        prod11.Status__c = 'In Process';
        prod11.Purchase_Province__c = 'PE';
        prod11.Pool_Name__c = pool.id;
        prod11.Refer_to_Legal__c = 'For Review';
        prod11.Statute_Date__c = Date.newInstance(2022, 12, 15);
        prod11.Charged_Off_Date__c = Date.newInstance(2020, 12, 15);
        prod11.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod11.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';

        prodList.add(prod3);
        prodList.add(prod4);
        prodList.add(prod5);
        prodList.add(prod7);
        prodList.add(prod9);
        prodList.add(prod11);
        prodListData.add(prod3);
        //prodListData.add(prod4);
        system.debug('prodList' + prodList);
        system.debug('prodMap:' + prodMap);
        ProductTriggerHandler.handleBeforeUpdate(prodList, prodMap);
        //ProductTriggerHandler.handleafterinsertdate(prodListData);
    }
    static testMethod void productBeforeUpdateTes1t() {
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        insert config;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

        Statute_Date_Update__mdt mdt = new Statute_Date_Update__mdt();
        mdt.Months__c = 10;
        mdt.MasterLabel = 'Alberta';

        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        Pool__c pool = new Pool__c();
        pool.Placement_Agency__c = 89;
        insert pool;

        Pool__c pool1 = new Pool__c();
        pool1.Placement_Agency__c = 29;
        insert pool1;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '40';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        /*Account customer1 = new Account(FirstName = 'FirstName', 
LastName = 'Last Name',
PersonMailingPostalCode = '998Y',
OwnerId = UserInfo.getUserId(),
PersonMailingCity = 'test',
PersonMailingStreet = 'test',
PersonMailingState = 'test',
PersonBirthdate = Date.newInstance(1976, 10,6),
PersonHomePhone = '8990-898-876',
Work_Phone__pc = '8990-898-876',
PersonOtherPhone = '8990-898-876',
Address_Last_Changed_Date__c = Date.newInstance(2022, 12, 5),
RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()); 
insert customer1;*/
        /*Account customer = new Account(FirstName = 'FirstName', LastName = 'Last Name',PersonMailingCity = 'Toronto', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId());
         insert customer;*/
        id prodRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonMailingCity = 'Toronto',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;
		
        Map<ID, Product__c> prodMap = new Map<ID, Product__c>();
        List<Product__c> prodList = new List<Product__c>();
        
        /*Product__c prod = new Product__c();
        prod.name = '123451212';
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
        prod.Last_Name__c = 'xyz';
        prod.Pool_Name__c = pool.id;
        prod.Collection_Agency__c = 30;
        prod.Placement_Status__c = '100010';
        prod.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod.state__c = 'Alberta';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod.Purchase_Province__c = 'PE';
        prod.Last_Payment_Date__c = System.today() - 30;
        prod.Open_Date__c = System.today() - 60;
        //prod.Customer__c = customer1.id;
        insert prod;

        Product__c prod2 = new Product__c();
        List<User> systemName = [SELECT Name FROM User WHERE Name = 'System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 30;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Last_Name__c = 'xyz';
        prod2.Placement_Status__c = '100010';
        prod2.Credit_Counselling_Date__c = null;
        prod2.Purchase_Status__c = 'Buyback/Putback Submitted to Seller';
        prod2.Last_Payment_Date__c = Date.newInstance(2016, 12, 5);
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod2.Purchase_Province__c = 'PE';

        insert prod2;

        

        
        prodMap.put(prod.id, prod);
        prodMap.put(prod2.id, prod2);

        product__c prod3 = new product__c();
        prod3.Id = Prod2.Id;
        prod3.Collection_Agency__c = 40;
        prod3.Funding_Status__c = 'Released';
        prod3.Product_Status__c = 'Test';
        prod3.Status__c = 'In Process';
        prod3.Sub_Status__c = 'Initial Letter Sent';
        prod3.Placement_Status__c = '100010';
        prod3.Invalid_Submission__c = true;
        prod3.Refer_to_Legal__c = 'Approved';
        prod3.Last_Name__c = 'xyz';
        prod3.State__c = 'MB';
        prod3.Pool_Name__c = pool1.id;
        prod3.Collection_Sub_Status__c = 'Credit Counselling';
        prod3.Interest_Rate__c = 5;
        prod3.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Deceased_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Last_Payment_Date__c = Date.newInstance(2022, 8, 9);
        prod3.Statute_Date__c = null;
        prod3.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod3.Purchase_Status__c = 'Putback Initiated';
        prod3.Purchase_Province__c = 'PE';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod3.Customer__c = customer1.id;
        prod3.Last_Name__c = 'Test';
        prod3.product_status__C = '';

        product__c prod4 = new product__c();
        prod4.id = prod.ID;
        prod4.Disbursement_Amount__c = 1000.00;
        prod4.Collection_Agency__c = null;
        prod4.Purchase_Province__c = 'PE';
        prod4.Placement_Status__c = 'Testing';
        prod4.Status__c = 'In Process';
        prod4.Pool_Name__c = pool.id;
        prod4.Refer_to_Legal__c = 'Declined';
        prod4.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod4.Statute_Date__c = null;
        prod4.State__c = 'Alberta';
        prod4.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod4.Purchase_Status__c = 'Buyback/Putback Initiated';
        prod4.product_status__C = '';
        prod4.Zip_Code__c = '887O';
        prod4.Customer__c = customer1.id;*/
        
        product__c prod5 = new product__c();
        prod5.name = '123451234';
        prod5.RecordTypeId = prodRecordTypeId;
        prod5.Disbursement_Amount__c = 1000.00;
        prod5.Collection_Agency__c = null;
        prod5.Purchase_Province__c = 'PE';
        prod5.Placement_Status__c = 'Testing';
        prod5.Status__c = 'In Process';
        prod5.Pool_Name__c = pool.id;
        prod5.Open_Date__c = Date.newInstance(2022, 12, 9);
        prod5.Statute_Date__c = null;
        prod5.State__c = 'Alberta';
        prod5.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod5.product_status__C = '';
        prod5.Zip_Code__c = '887O';
        prod5.Last_Payment_Date__c = System.today() - 20;
        prod5.Customer__c = null;
        prod5.Last_Name__c = 'lastname';
        insert prod5;
        
        product__c prod6 = new product__c();
        prod6.Id = prod5.Id;
        prod6.name = '123451234';
        prod6.RecordTypeId = prodRecordTypeId;
        prod6.Disbursement_Amount__c = 1000.00;
        prod6.Collection_Agency__c = null;
        prod6.Purchase_Province__c = 'PE';
        prod6.Placement_Status__c = 'Testing';
        prod6.Status__c = 'In Process';
        prod6.Pool_Name__c = pool.id;
        prod6.Open_Date__c = Date.newInstance(2023, 12, 9);
        prod6.Statute_Date__c = null;
        prod6.State__c = 'Alberta';
        prod6.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod6.product_status__C = '';
        prod6.Zip_Code__c = '887O';
        prod6.Last_Payment_Date__c = System.today() - 10;
        prod6.Customer__c = null;
        prod6.Last_Name__c = 'lastname';
        
        prodMap.put(prod5.id, prod6);
        //prod5.Customer__c = customer1.id;
                
        //prodList.add(prod3);
        //prodList.add(prod4);
        prodList.add(prod5);
        
        ProductTriggerHandler.handleBeforeUpdate(prodList, prodMap);
        ProductTriggerHandler.handleAfterUpdateUpdatedate(prodList, prodMap);
        //ProductTriggerHandler.getCustomerRecord(prod.Customer__c);
        //ProductTriggerHandler.needtoUpdateCustomer(prod3);
    }

    //Test Before Insert
    static testMethod void productBeforeInsertTest() {
        Id recordTypeId = Utilities.getProductRecordType('Megasys');

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '89';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        Placement__c plcgy2 = new Placement__c();
        plcgy2.Name = '30';
        plcgy2.Agency_Email__c = 'test@gmail.com';
        insert plcgy2;

        Pool__c pool = new Pool__c();
        //pool.Name = 'Test';
        pool.Placement_Agency__c = 89;
        insert pool;

        Statute_Date_Update__mdt mdt = new Statute_Date_Update__mdt();
        mdt.Months__c = 10;
        mdt.MasterLabel = 'AB';

        List<Product__c> prodList = new List<Product__c>();

        Product__c prod = new Product__c();
        prod.name = 'Prod1';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Phone_Other__c = '8974563214';
        prod.Phone_Work__c = '27896541236';
        prod.Requested_Close_Date__c = null;
        prod.Closed_Date__c = null;
        prod.Payment_Due_Date__c = System.Today().addDays(-10);
        prod.Internal_Status__c = 'Active';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod.Customer__c = customer1.id;
        prod.Purchase_Province__c = 'PE';
        prod.Open_Date__c = System.Today().addDays(-20);
        prodList.add(prod);

        prod = new Product__c();
        prod.name = 'Prod2';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Phone_Other__c = '8974563214';
        prod.Phone_Work__c = '27896541236';
        prod.Requested_Close_Date__c = null;
        prod.Closed_Date__c = null;
        prod.Purchase_Province__c = 'PE';
        prod.Payment_Due_Date__c = System.Today().addDays(-190);
        prod.Internal_Status__c = 'Active';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        prod.Customer__c = customer.id;
        prodList.add(prod);

        prod = new Product__c();
        prod.name = 'Prod6';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Phone_Other__c = '8974563214';
        prod.Phone_Work__c = '27896541236';
        prod.Requested_Close_Date__c = null;
        prod.Closed_Date__c = null;
        prod.Purchase_Province__c = 'PE';
        prod.Payment_Due_Date__c = System.Today().addDays(20);
        prod.Internal_Status__c = 'Active';
        prod.product_status__C = '310000';
        prod.Collection_Agency_Placement__c = plcgy1.id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod.Customer__c = customer1.id;
        prodList.add(prod);

        prod = new Product__c();
        prod.name = 'Prod3';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Phone_Other__c = '8974563214';
        prod.Phone_Work__c = '27896541236';
        prod.Requested_Close_Date__c = null;
        prod.Closed_Date__c = System.Today().addDays(-50);
        prod.Payment_Due_Date__c = System.Today().addDays(-190);
        prod.Internal_Status__c = 'Active';
        prod.Purchase_Province__c = 'PE';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod.Customer__c = customer.id;
        prodList.add(prod);

        prod = new Product__c();
        prod.recordTypeId = recordTypeId;
        prod.name = 'Prod4';
        prod.Phone_Home__c = '55345678999';
        prod.Purchase_Province__c = 'PE';
        prod.Phone_Other__c = '8774563214';
        prod.Phone_Work__c = null;
        prod.Requested_Close_Date__c = System.Today();
        prod.product_status__C = null;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        prod.Customer__c = customer1.id;
        prodList.add(prod);

        prod = new Product__c();
        prod.recordTypeId = recordTypeId;
        prod.name = 'Prod5';
        prod.Phone_Home__c = null;
        prod.Phone_Other__c = null;
        prod.Phone_Work__c = null;
        prod.product_status__C = '310000';
        prod.Requested_Close_Date__c = System.Today().addYears(-50);
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Purchase_Province__c = 'PE';
        //prod.Account_Portfolio_ID__c = 'Test';
        prod.Pool_Name__c = pool.id;
        prod.Placement_Status__c = '111010';
        prod.Collection_Agency__c = 30;
        prod.Last_Name__c = 'xyz';
        prod.Purchase_Province__c = 'PE';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod.Customer__c = customer.id;
        prod.State__c = 'AB';
        insert prod;

        product__c prod1 = new product__c();
        prod1.name = '1000P8';
        //prod1 = prod.clone(true);
        prod1.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        insert prod1;

        prodList.add(prod);
        prodList.add(prod1);

        Product_Name_Details__c prodNameDetails = new Product_Name_Details__c();
        prodNameDetails.name = 'Test';
        prodNameDetails.Last_Product_Number_in_the_Group__c = 6;
        insert prodNameDetails;
        Test.startTest();
        ProductTriggerHandler.utilityMethod();
        //System.assertEquals(true, prod.isClone());
        ProductTriggerHandler.handleBeforeInsert(prodList);
        ProductTriggerHandler.handleafterinsertdate(prodList);
        Test.stopTest();
    }

    static testMethod void productAfterInsertUpdateTest1() {
        ID ProductID;
        Date updatedDate;
        string fieldSetLabel;
        Boolean activeVersaPayPayment;

        Product__c ProdData = new Product__c();
        Product__c ProdDataOld = new Product__c();

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonMailingCity = '',
            PersonMailingStreet = '',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;

        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonMailingCity = 'Toronto',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '20';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
		
        Portfolio_Name__c portfolio = [select id,Purchase_ID__c from Portfolio_Name__c where Name = 'MBNA25'];
        
        Product__c prod = new Product__c(
            Purchase_Province__c = 'PE',
            Deceased_Date__c = null,
            City__c = 'Toronto',
            Statute_Date__c = null,
            Insolvency_Date__c = null,
            Credit_Counselling_Date__c = system.today(),
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Status__c = 'New Allocation - New Allocation',
            Sub_Status__c = 'Ready',
            Product_Status__c = 'Test',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        List<Product__c> prodList1 = new List<Product__c>();
        List<Product__c> prodList = new List<Product__c>();
        prodList.add(prod);

        insert prodList;
        prod.Collection_Sub_Status__c = 'Pending Recall';
        //prod.Credit_Counselling_Date__c=system.today();
        prod.Address_Line1__c = 'test';
        prod.Date_of_Birth__c = Date.newInstance(1977, 12, 9);
        prod.Insolvency_Date__c = system.today();
        prod.Deceased_Date__c = system.today();
        prod.City__c = 'Toronto';
        prod.Last_Payment_Date__c = system.today();
        Map<ID, Product__c> prodMap = new Map<ID, Product__c>();
        prodMap.put(prod.id, prod);
        system.debug('calling 1 start' + prodList);
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, true);
        system.debug('calling 1 end');
        Task tsk = new Task();
        tsk.WhatId = customer.Id;
        tsk.subject = 'Address Changes';
        tsk.OwnerId = UserInfo.getUserId();
        //insert tsk;

        Product__c prod1 = new Product__c(
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        prod1.Data_Status_Description__c = 'Test';
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Credit_Counselling_Date__c = system.today();
        prod1.Purchase_Province__c = 'PE';
        prod1.Proposed_Payment_Amount__c = 10;
        prod1.Total_Paid_To_Date__c = 5;
        prod1.Accepted_Payment_Amount__c = 19;
        prod1.Expected_First_disbursement_date__c = system.Today().addDays(-70);
        prod1.Proposal_Received_Date__c = system.Today().addDays(-75);
        insert prod1;

        Product__c prod12 = new Product__c(
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        prod12.Data_Status_Description__c = 'Test';
        prod12.Status__c = 'New Allocation - New Allocation';
        prod12.Sub_Status__c = 'Ready';
        prod12.Product_Status__c = 'Test';
        prod12.Is_Future_PTP__c = true;
        prod12.Purchase_Province__c = 'PE';
        prod12.Credit_Counselling_Date__c = null;
        insert prod12;
        prodMap.put(prod12.Id, prod12);
        prodList.add(prod1);
        list<product__c> prodList123 = new List<product__c>();
        prodList123.add(prod12);
        prodList123.add(prod1);
        list<product__c> prodList1234 = new List<product__c>();
        prodList1234.add(prod1);
        prodList1234.add(prod12);
        //prod.First_Name__c = 'changed';
        prod.Address_Last_Changed_Date__c = system.Today().addDays(-1);
        prod.Phone_Other__c = '123456';
        prod.Phone_Work__c = '123456';
        prod.Phone_Home__c = '123456';
        //prod.Date_of_Birth__c = system.Today().addDays(-7000);
        prod.State__c = 'ON';
        prod.Zip_Code__c = '123456';
        prod.City__c = 'NYC';
        prod.Address_Line1__c = 'Street 1';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Company_Name__c = 'Test';
        update prod;

        Map<ID, Product__c> prodMap1 = new Map<ID, Product__c>();
        Product__c prodd = new Product__c();
        prodd = new Product__c();
        prodd.name = 'Prod6';
        // prodd.recordTypeId = recordTypeId;
        prodd.Phone_Home__c = '12345678999';
        prodd.Phone_Other__c = '8974563214';
        prodd.Phone_Work__c = '27896541236';
        prodd.Requested_Close_Date__c = null;
        prodd.Closed_Date__c = null;
        prodd.Payment_Due_Date__c = System.Today().addDays(20);
        prodd.Internal_Status__c = 'Active';
        prodd.product_status__C = '310000';
        // prodd.Collection_Agency_Placement__c = plcgy1.id;
        prodd.Status__c = 'New Allocation - New Allocation';
        prodd.Sub_Status__c = 'Ready';
        prodd.Product_Status__c = 'Test';
        prodd.Company_Name__c = 'Test';
        prodd.Collection_Agency__c = 20;
        prodd.state__c = 'AB';
        prodd.Customer__c = customer1.Id;
        prodd.City__c = 'Toronto';
        prodd.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodd.Purchase_Province__c = 'PE';
        prodd.Portfolio_Name_Lookup__c = portfolio.id;
        insert prodd;
        prodMap1.put(Prodd.id, prodd);

        Product__c prod2 = new Product__c();
        prod2 = new Product__c();
        prod2.name = 'Prod7';
        // prod2.recordTypeId = recordTypeId;
        prod2.Phone_Home__c = '12345678999';
        prod2.Phone_Other__c = '8974563214';
        prod2.Phone_Work__c = '27896541236';
        prod2.Requested_Close_Date__c = null;
        prod2.Closed_Date__c = null;
        prod2.Payment_Due_Date__c = System.Today().addDays(20);
        prod2.Internal_Status__c = 'Active';
        prod2.product_status__C = '310000';
        // prod2.Collection_Agency_Placement__c = plcgy1.id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Company_Name__c = 'Test Company';
        prod2.Is_Future_PTP__c = true;
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod2.Portfolio_Name_Lookup__c = portfolio.id;
        prodList1.add(prod2);

        system.debug('calling 2 start' + prodList);
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, true);
        system.debug('calling 2 end');
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c = false;
        insert config;

        prodMap.put(prod1.Id, prod1);
        ProductTriggerHandler.utilityMethod();
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, false);
        // ProductTriggerHandler.handleAfterUpdate(prodList1,prodMap1);
        ProductTriggerHandler.PTPFlowStep2(prodList123);
        ProductTriggerHandler.validationRules(prodList, prodMap);
        ProductTriggerHandler.checkInBetweenPayments(ProductID, updatedDate);
        ProductTriggerHandler.getProductFieldsets(fieldSetLabel);
        ProductTriggerHandler.versaPayRecords(prodList);
        ProductTriggerHandler.createAddressChangedTask(ProdData);
        ProductTriggerHandler.hasActiveAddressChangedTask(ProdData);
        ProductTriggerHandler.hasProductCustomerDataChanged(ProdData, ProdDataOld);
        ProductTriggerHandler.isActiveSORProduct(ProdData);
        ProductTriggerHandler.isActiveMSProduct(ProdData);
        ProductTriggerHandler.calculateDeliquency(ProdData, ProdDataOld, true);
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(prodList, prodMap);
        ProductTriggerHandler.creatJudgment(new List<Product__c>{ prodd });
        ProductTriggerHandler.nameFormat('Testting');
        ProductTriggerHandler.PTPFlowStep2(prodList1234);
        ProductTriggerHandler.getMatchingCustomers(prodd);
        ProductTriggerHandler.needtoUpdateCustomer(prod);
        ProductTriggerHandler.updateCustomerFromProduct(prod);
        ProductTriggerHandler.handleAfterUpdate(prodList, prodMap);
        ProductTriggerHandler.handleAfterUpdateUpdatedate(prodList, prodMap);
        List<Product__c> newProdList = new List<Product__c>();
        Product__c prodNew = new Product__c();
        prodNew.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prodNew.Deceased_Date__c = Date.newInstance(2021, 2, 19);
        //prodNew.Account_Portfolio_ID__c = 'Test';
        //newProdList.add(prodNew);

        Product__c prodOld = new Product__c();
        prodOld.name = 'Prod60';
        // prod2.recordTypeId = recordTypeId;
        prodOld.Phone_Home__c = '12121212';
        prodOld.Phone_Other__c = '8974563214';
        prodOld.Phone_Work__c = '27896541236';
        prodOld.Requested_Close_Date__c = null;
        prodOld.Closed_Date__c = null;
        prodOld.Payment_Due_Date__c = System.Today().addDays(20);
        prodOld.Internal_Status__c = 'Active';
        prodOld.product_status__C = '310000';
        prodOld.Status__c = 'New Allocation - New Allocation';
        prodOld.Sub_Status__c = 'Ready';
        prodOld.Product_Status__c = 'Test';
        prodOld.Company_Name__c = 'Test Company';
        prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 19);
        prodOld.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        //prodOld.Account_Portfolio_ID__c = 'Test';
        prodold.Purchase_Province__c = 'PE';
        prodOld.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodOld.Customer__c = customer1.id;
        prodOld.Portfolio_Name_Lookup__c = portfolio.id;
        insert prodOld;

        Map<ID, Product__c> oldprodMap = new Map<ID, Product__c>();
        oldprodMap.put(prodOld.Id, prodOld);

        prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 20);
        update prodOld;
        newProdList.add(prodOld);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(newProdList, oldprodMap);
        ProductTriggerHandler.handleBeforeInsert(newProdList);
        ProductTriggerHandler.handleafterinsertdate(newProdList);

        Test.stopTest();
        // ProductTriggerHandler.updateCustomerFromProduct(prod);
        // ProductTriggerHandler.needtoUpdateCustomer(prod1);
    }

    //Test After Insert Update
    static testMethod void productAfterInsertUpdateTest() {
        ID ProductID;
        Date updatedDate;
        string fieldSetLabel;
        Boolean activeVersaPayPayment;

        Product__c ProdData = new Product__c();
        Product__c ProdDataOld = new Product__c();

        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonMailingCity = 'Toronto',
            PersonMailingStreet = '',
            PersonBirthdate = Date.newInstance(1976, 12, 9),
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;

        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonMailingCity = 'Toronto',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '20';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
		
        Portfolio_Name__c portfolio = [select id,Purchase_ID__c from Portfolio_Name__c where Name = 'MBNA25'];
        
        Product__c prod = new Product__c(
            Purchase_Province__c = 'PE',
            Deceased_Date__c = null,
            Statute_Date__c = null,
            Insolvency_Date__c = null,
            Credit_Counselling_Date__c = null,
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Status__c = 'New Allocation - New Allocation',
            Sub_Status__c = 'Ready',
            Product_Status__c = 'Test',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        List<Product__c> prodList1 = new List<Product__c>();
        List<Product__c> prodList = new List<Product__c>();
        prodList.add(prod);

        insert prodList;
        prod.Collection_Sub_Status__c = 'Pending Recall';
        prod.Credit_Counselling_Date__c = system.today();
        prod.Address_Line1__c = 'test';
        prod.Date_of_Birth__c = Date.newInstance(1977, 12, 9);
        prod.Insolvency_Date__c = system.today();
        prod.Deceased_Date__c = system.today();
        prod.City__c = 'Toronto';
        prod.Last_Payment_Date__c = system.today();
        Map<ID, Product__c> prodMap = new Map<ID, Product__c>();
        prodMap.put(prod.id, prod);
        system.debug('calling 1 start' + prodList);
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, true);
        system.debug('calling 1 end');
        Task tsk = new Task();
        tsk.WhatId = customer.Id;
        tsk.subject = 'Address Changes';
        tsk.OwnerId = UserInfo.getUserId();
        //insert tsk;

        Product__c prod1 = new Product__c(
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        prod1.Data_Status_Description__c = 'Test';
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Credit_Counselling_Date__c = null;
        prod1.Purchase_Province__c = 'PE';
        prod1.Proposed_Payment_Amount__c = 10;
        prod1.Total_Paid_To_Date__c = 5;
        prod1.Accepted_Payment_Amount__c = 19;
        prod1.Expected_First_disbursement_date__c = system.Today().addDays(-70);
        prod1.Proposal_Received_Date__c = system.Today().addDays(-75);
        insert prod1;

        Product__c prod12 = new Product__c(
            First_Name__c = 'ProdFirstName',
            Last_Name__c = 'ProdLastName',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId(),
            Portfolio_Name_Lookup__c = portfolio.id
        );
        prod12.Data_Status_Description__c = 'Test';
        prod12.Status__c = 'New Allocation - New Allocation';
        prod12.Sub_Status__c = 'Ready';
        prod12.Product_Status__c = 'Test';
        prod12.Is_Future_PTP__c = true;
        prod12.Purchase_Province__c = 'PE';
        insert prod12;

        prodList.add(prod1);
        list<product__c> prodList123 = new List<product__c>();
        prodList123.add(prod12);
        prodList123.add(prod1);
        list<product__c> prodList1234 = new List<product__c>();
        prodList1234.add(prod1);
        prodList1234.add(prod12);
        prod.First_Name__c = 'changed';
        prod.Address_Last_Changed_Date__c = system.Today().addDays(-1);
        prod.Phone_Other__c = '123456';
        prod.Phone_Work__c = '123456';
        prod.Phone_Home__c = '123456';
        prod.Date_of_Birth__c = system.Today().addDays(-7000);
        prod.State__c = 'ON';
        prod.Zip_Code__c = '123456';
        prod.City__c = 'NYC';
        prod.Address_Line1__c = 'Street 1';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Company_Name__c = 'Test';
        update prod;

        Map<ID, Product__c> prodMap1 = new Map<ID, Product__c>();
        Product__c prodd = new Product__c();
        prodd = new Product__c();
        prodd.name = 'Prod6';
        // prodd.recordTypeId = recordTypeId;
        prodd.Phone_Home__c = '12345678999';
        prodd.Phone_Other__c = '8974563214';
        prodd.Phone_Work__c = '27896541236';
        prodd.Requested_Close_Date__c = null;
        prodd.Closed_Date__c = null;
        prodd.Payment_Due_Date__c = System.Today().addDays(20);
        prodd.Internal_Status__c = 'Active';
        prodd.product_status__C = '310000';
        // prodd.Collection_Agency_Placement__c = plcgy1.id;
        prodd.Status__c = 'New Allocation - New Allocation';
        prodd.Sub_Status__c = 'Ready';
        prodd.Product_Status__c = 'Test';
        prodd.Company_Name__c = 'Test';
        prodd.Collection_Agency__c = 20;
        prodd.state__c = 'AB';
        prodd.Customer__c = customer1.Id;
        prodd.City__c = 'Toronto';
        prodd.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodd.Purchase_Province__c = 'PE';
        prodd.Portfolio_Name_Lookup__c = portfolio.id;
        insert prodd;
        prodMap1.put(Prodd.id, prodd);

        Product__c prod2 = new Product__c();
        prod2 = new Product__c();
        prod2.name = 'Prod7';
        // prod2.recordTypeId = recordTypeId;
        prod2.Phone_Home__c = '12345678999';
        prod2.Phone_Other__c = '8974563214';
        prod2.Phone_Work__c = '27896541236';
        prod2.Requested_Close_Date__c = null;
        prod2.Closed_Date__c = null;
        prod2.Payment_Due_Date__c = System.Today().addDays(20);
        prod2.Internal_Status__c = 'Active';
        prod2.product_status__C = '310000';
        // prod2.Collection_Agency_Placement__c = plcgy1.id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Company_Name__c = 'Test Company';
        prod2.Is_Future_PTP__c = true;
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod2.Portfolio_Name_Lookup__c = portfolio.id;
        prodList1.add(prod2);

        system.debug('calling 2 start' + prodList);
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, true);
        system.debug('calling 2 end');
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c = false;
        insert config;

        prodMap.put(prod1.Id, prod);
        ProductTriggerHandler.utilityMethod();
        ProductTriggerHandler.handleAferInsertUpdate(prodList, prodMap, false);
        // ProductTriggerHandler.handleAfterUpdate(prodList1,prodMap1);
        ProductTriggerHandler.PTPFlowStep2(prodList123);
        ProductTriggerHandler.validationRules(prodList, prodMap);
        ProductTriggerHandler.checkInBetweenPayments(ProductID, updatedDate);
        ProductTriggerHandler.getProductFieldsets(fieldSetLabel);
        ProductTriggerHandler.versaPayRecords(prodList);
        ProductTriggerHandler.createAddressChangedTask(ProdData);
        ProductTriggerHandler.hasActiveAddressChangedTask(ProdData);
        ProductTriggerHandler.hasProductCustomerDataChanged(ProdData, ProdDataOld);
        ProductTriggerHandler.isActiveSORProduct(ProdData);
        ProductTriggerHandler.isActiveMSProduct(ProdData);
        ProductTriggerHandler.calculateDeliquency(ProdData, ProdDataOld, true);
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(prodList, prodMap);
        ProductTriggerHandler.creatJudgment(new List<Product__c>{ prodd });
        ProductTriggerHandler.nameFormat('Testting');
        ProductTriggerHandler.PTPFlowStep2(prodList1234);
        ProductTriggerHandler.getMatchingCustomers(prodd);
        ProductTriggerHandler.needtoUpdateCustomer(prod);
        ProductTriggerHandler.updateCustomerFromProduct(prod);
        ProductTriggerHandler.handleAfterUpdate(prodList, prodMap);
        ProductTriggerHandler.handleAfterUpdateUpdatedate(prodList, prodMap);
        List<Product__c> newProdList = new List<Product__c>();
        Product__c prodNew = new Product__c();
        prodNew.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        prodNew.Deceased_Date__c = Date.newInstance(2021, 2, 19);
        //prodNew.Account_Portfolio_ID__c = 'Test';
        //newProdList.add(prodNew);

        Product__c prodOld = new Product__c();
        prodOld.name = 'Prod60';
        // prod2.recordTypeId = recordTypeId;
        prodOld.Phone_Home__c = '12121212';
        prodOld.Phone_Other__c = '8974563214';
        prodOld.Phone_Work__c = '27896541236';
        prodOld.Requested_Close_Date__c = null;
        prodOld.Closed_Date__c = null;
        prodOld.Payment_Due_Date__c = System.Today().addDays(20);
        prodOld.Internal_Status__c = 'Active';
        prodOld.product_status__C = '310000';
        prodOld.Status__c = 'New Allocation - New Allocation';
        prodOld.Sub_Status__c = 'Ready';
        prodOld.Product_Status__c = 'Test';
        prodOld.Company_Name__c = 'Test Company';
        prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 19);
        prodOld.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        //prodOld.Account_Portfolio_ID__c = 'Test';
        prodold.Purchase_Province__c = 'PE';
        prodOld.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodOld.Customer__c = customer1.id;
        prodOld.Portfolio_Name_Lookup__c = portfolio.id;
        insert prodOld;

        Map<ID, Product__c> oldprodMap = new Map<ID, Product__c>();
        oldprodMap.put(prodOld.Id, prodOld);

        prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 20);
        update prodOld;
        newProdList.add(prodOld);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(newProdList, oldprodMap);
        ProductTriggerHandler.handleBeforeInsert(newProdList);
        ProductTriggerHandler.handleafterinsertdate(newProdList);
		prodOld.Credit_Counselling_Date__c = System.today();
        update prodOld;
        Test.stopTest();
        // ProductTriggerHandler.updateCustomerFromProduct(prod);
        // ProductTriggerHandler.needtoUpdateCustomer(prod1);
    }

    @IsTest
    static void testCalculateDeliquency() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;

        Product__c prod = new Product__c();
        prod.name = '123451212';
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
        prod.Last_Name__c = 'xyz';
        prod.Collection_Agency__c = 30;
        prod.Placement_Status__c = '100010';
        prod.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod.state__c = 'Alberta';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod.Customer__c = customer.id;
        prod.Purchase_Province__c = 'PE';
        prod.Internal_Status__c = 'Active';
        insert prod;

        Product__c prodOld = new Product__c();
        prodOld.name = 'Prod6';
        prodOld.Phone_Home__c = '12345678999';
        prodOld.Phone_Other__c = '8974563214';
        prodOld.Phone_Work__c = '27896541236';
        prodOld.Requested_Close_Date__c = null;
        prodOld.Closed_Date__c = null;
        prodOld.Payment_Due_Date__c = System.Today().addDays(20);
        prodOld.Internal_Status__c = 'Active';
        prodOld.product_status__C = '310000';
        prodOld.Status__c = 'New Allocation - New Allocation';
        prodOld.Sub_Status__c = 'Ready';
        prodOld.Product_Status__c = 'Test';
        prodOld.Company_Name__c = 'Test Company';
        //prodOld.Account_Portfolio_ID__c = 'Test';
        prodold.Credit_Counselling_Date__c = null;
        prodold.Purchase_Province__c = 'PE';
        prodOld.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodOld.Customer__c = customer1.id;
        insert prodOld;

        Product__c prod2 = new Product__c();
        prod2.name = '12345121232';
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
        prod2.Last_Name__c = 'xyz';
        prod2.Collection_Agency__c = 30;
        prod2.Placement_Status__c = '100010';
        prod2.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod2.state__c = 'Alberta';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod2.Customer__c = customer.id;
        prod2.Purchase_Province__c = 'PE';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Due_Date__c = System.today() + 2;
        prod2.Deceased_Date__c = null; //System.today()+10;
        insert prod2;

        Product__c prod3 = new Product__c();
        prod3.name = '12345121232';
        prod3.Payment_Setup_Status__c = 'Automated';
        prod3.Funding_Status__c = 'Released Batch';
        prod3.Funding_Type__c = 'Automated';
        prod3.Disbursement_Amount__c = 2000.00;
        prod3.Current_Balance__c = 7000;
        prod3.Current_Principal_Balance__c = 5000;
        prod3.Current_Interest_Amount__c = 2000;
        prod3.Current_Workflow__c = 'Collection Process';
        prod3.Requested_Close_Date__c = System.Today();
        prod3.Status__c = 'New Allocation - New Allocation';
        prod3.Sub_Status__c = 'Ready';
        prod3.Product_Status__c = 'Test';
        prod3.Last_Name__c = 'xyz';
        prod3.Collection_Agency__c = 30;
        prod3.Placement_Status__c = '100010';
        prod3.Open_Date__c = Date.newInstance(2022, 12, 5);
        prod3.state__c = 'Alberta';
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prod3.Customer__c = customer.id;
        prod3.Purchase_Province__c = 'PE';
        prod3.Payment_Due_Date__c = System.today() + 2;
        prod3.Credit_Counselling_Date__c = null;
        insert prod3;
        Test.startTest();
        ProductTriggerHandler.UtilityMethod();
        ProductTriggerHandler.calculateDeliquency(prod, prodOld, false);
        ProductTriggerHandler.calculateDeliquency(prod2, prodOld, false);
        ProductTriggerHandler.calculateDeliquency(prod3, prodOld, false);
        //prod3.Date_for_Stat_Barred_calculations__c=System.today()+5;

        Test.stopTest();
        prod3.Statute_Date__c = null;
        prod3.Credit_Counselling_Date__c = System.today() + 1;
        update prod3;
        prod2.Deceased_Date__c = System.today() + 10;
        update prod2;
    }

    @istest
    static void testcalculateBalanceBackdatedPayments2Method() {
        list<product__c> newProdList = new List<product__c>();
        map<id, product__c> oldprodMap = new Map<id, product__c>();
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;
        Product__c prodOld = new Product__c();
        prodOld.name = 'Prod6';
        // prod2.recordTypeId = recordTypeId;
        prodOld.Phone_Home__c = '12345678999';
        prodOld.Phone_Other__c = '8974563214';
        prodOld.Phone_Work__c = '27896541236';
        prodOld.Requested_Close_Date__c = null;
        prodOld.Closed_Date__c = null;
        prodOld.Payment_Due_Date__c = System.Today().addDays(20);
        prodOld.Internal_Status__c = 'Active';
        prodOld.product_status__C = '310000';
        prodOld.Status__c = 'New Allocation - New Allocation';
        prodOld.Sub_Status__c = 'Ready';
        prodOld.Product_Status__c = 'Test';
        prodOld.Company_Name__c = 'Test Company';
        //prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 19);
        //prodOld.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        //prodOld.Account_Portfolio_ID__c = 'Test';
        prodold.Credit_Counselling_Date__c = null;
        prodold.Purchase_Province__c = 'PE';
        prodOld.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodOld.Customer__c = customer1.id;
        insert prodOld;
        oldprodMap.put(prodOld.Id, prodOld);

        prodold.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prodold.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        prodOld.Customer__c = customer.id;
        update prodold;
        newProdList.add(prodold);
        test.starttest();
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(newProdList, oldprodMap);
        test.stopTest();
    }

    @istest
    static void testcalculateBalanceBackdatedPayments3Method() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;
        Account customer1 = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId()
        );
        insert customer1;
        list<product__c> newProdList = new List<product__c>();
        map<id, product__c> oldprodMap = new Map<id, product__c>();
        Product__c prodOld = new Product__c();
        prodOld.name = 'Prod6';
        // prod2.recordTypeId = recordTypeId;
        prodOld.Phone_Home__c = '12345678999';
        prodOld.Phone_Other__c = '8974563214';
        prodOld.Phone_Work__c = '27896541236';
        prodOld.Requested_Close_Date__c = null;
        prodOld.Closed_Date__c = null;
        prodOld.Payment_Due_Date__c = System.Today().addDays(20);
        prodOld.Internal_Status__c = 'Active';
        prodOld.product_status__C = '310000';
        prodOld.Status__c = 'New Allocation - New Allocation';
        prodOld.Sub_Status__c = 'Ready';
        prodOld.Product_Status__c = 'Test';
        prodOld.Company_Name__c = 'Test Company';
        //prodOld.Deceased_Date__c = Date.newInstance(2022, 2, 19);
        prodOld.Insolvency_Date__c = Date.newInstance(2016, 12, 9);
        //prodOld.Account_Portfolio_ID__c = 'Test';
        prodold.Credit_Counselling_Date__c = null;
        prodold.Purchase_Province__c = 'PE';
        prodOld.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prodOld.Customer__c = customer1.id;
        insert prodOld;
        oldprodMap.put(prodOld.Id, prodOld);
        prodold.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prodold.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        prodOld.Customer__c = customer.id;
        update prodold;
        newProdList.add(prodold);
        test.starttest();
        ProductTriggerHandler.calculateBalanceBackdatedPayments2(newProdList, oldprodMap);
        test.stopTest();
    }

    static testMethod void productBeforeUpdateTest1() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        List<Product__c> prodList = new List<Product__c>();
        product__c prod3 = new product__c();
        prod3.name = '12346';
        prod3.Interest_Rate__c = 5;
        prod3.Credit_Counselling_Date__c = Date.newInstance(2016, 12, 9);
        prod3.Last_Payment_Date__c = Date.newInstance(2022, 8, 9);
        prod3.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod3.Interest_Waived_Off__c = true;
        prod3.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 10, 5);
        prod3.Interest_Waived_Off_Start_Date__c = Date.newInstance(2023, 10, 1);
        prod3.Interest_Waived_Of_End_Date__c = Date.newInstance(2023, 10, 15);

        product__c prod4 = new product__c();
        prod4.name = '12345';
        prod4.Collection_Sub_Status__c = 'Credit Counselling';
        prod4.Interest_Waived_Off__c = true;
        prod4.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2023, 10, 14);
        prod4.Interest_Waived_Off_Start_Date__c = Date.newInstance(2023, 10, 1);
        prod4.Interest_Waived_Of_End_Date__c = Date.newInstance(2023, 10, 15);
        prod4.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();

        product__c prod5 = new product__c();
        prod5.name = '12347';
        prod5.Current_Principal_Balance__c = 1000;
        prod5.Interest_Rate__c = 40;
        prod5.Insolvency_Date__c = null;
        prod5.Interest_Amount_Last_Calculated_Date__c = Date.newInstance(2022, 12, 15);
        prod5.Collection_Sub_Status__c = 'Buy back/put back and sale categories';
        prod5.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod5.Deceased_Date__c = null;
        prod5.Interest_Waived_Off__c = false;

        prodList.add(prod3);
        prodList.add(prod4);
        prodList.add(prod5);
        ProductTriggerHandler.handleBeforeInsert(prodList);
    }

    @isTest
    static void testNeedToUpdateCustomer() {
        Account customer = new Account(
            FirstName = 'FirstName',
            LastName = 'Last Name',
            PersonOtherPhone = '1234567890',
            Work_Phone__pc = '1234567890',
            PersonHomePhone = '1234567890',
            PersonBirthdate = System.Today().addMonths(-36),
            PersonMailingState = 'State',
            PersonMailingPostalCode = 'Postal',
            PersonMailingCity = 'City',
            PersonMailingStreet = 'Mailing',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fidem Customer').getRecordTypeId()
        );
        insert customer;

        Placement__c plcgy1 = new Placement__c();
        plcgy1.Name = '20';
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;

        Product__c prod = new Product__c(
            Phone_Other__c = '1234567890',
            Phone_Work__c = '1234567890',
            Phone_Home__c = '1234567890',
            Date_of_Birth__c = System.Today().addMonths(-36),
            State__c = 'State',
            Zip_Code__c = 'Postal',
            Purchase_Province__c = 'PE',
            Deceased_Date__c = null,
            City__c = 'City',
            Statute_Date__c = null,
            Insolvency_Date__c = null,
            Credit_Counselling_Date__c = system.today(),
            First_Name__c = 'FirstName',
            Last_Name__c = 'LastName',
            Status__c = 'New Allocation - New Allocation',
            Sub_Status__c = 'Ready',
            Product_Status__c = 'Test',
            Customer__c = customer.Id,
            Source_System__c = 'FDR',
            RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId()
        );
        insert prod;

        Test.startTest();
        ProductTriggerHandler.existingCustomer = new Map<Id, Account>(
            [
                SELECT
                    Id,
                    OwnerId,
                    PersonMailingCity,
                    PersonMailingStreet,
                    PersonMailingPostalCode,
                    PersonMailingState,
                    PersonBirthdate,
                    PersonHomePhone,
                    Work_Phone__pc,
                    PersonOtherPhone,
                    Address_Last_Changed_Date__c,
                    FirstName,
                    LastName
                FROM Account
            ]
        );
        ProductTriggerHandler.needtoUpdateCustomer(prod);
        Test.stopTest();
    }
}