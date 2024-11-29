@isTest
public class CTBApiCalloutsQueueableTest {
    @isTest
    static void testQueueable() {
        Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567890';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            insolvencyAccounts,
            System.Label.CTB_Insolvency_Account, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [
            SELECT Id, Insolvency_Sub_Status__c
            FROM insolvency_account__c
            WHERE Id IN :insolvencyAccounts
        ];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }

    @isTest
    static void testQueueable1() {
        //Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        Test.setMock(HttpCalloutMock.class, new MyFirstHttpMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<Insolvency_Payment__c> insolvencyPayments = new List<Insolvency_Payment__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567891';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;

        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Payment_Amount__c = 1000;
        payment1.Insolvency_Account__c = insolAcct1.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        insolvencyPayments.add(payment1);

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            insolvencyPayments,
            System.Label.CTB_Payment, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<Insolvency_Payment__c> updatedInsolvencyAccounts = [SELECT Id, Payment_Sub_Status__c FROM Insolvency_Payment__c WHERE Id IN :insolvencyPayments];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }

    public class MyFirstHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            String responseBody = '{"access_token": "test","IsSuccess": true}';
            res.setBody(responseBody);
            return res;
        }
    }

    @isTest
    static void testQueueable2() {
        //Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        Test.setMock(HttpCalloutMock.class, new MySecondHttpMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<Insolvency_Payment__c> insolvencyPayments = new List<Insolvency_Payment__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567892';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;

        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Payment_Amount__c = 1234;
        payment1.Insolvency_Account__c = insolAcct1.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        insolvencyPayments.add(payment1);

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            insolvencyPayments,
            System.Label.CTB_Payment, //'YourBatchName',
            'DRN_DailyUpdate_'
        );
        queueable.errorProcessingStatusUpdate(System.Label.CTB_Payment, insolvencyPayments);
        queueable.populateErrorMesssage(System.Label.CTB_Payment, payment1.id, 'error invalid record');
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<Insolvency_Payment__c> updatedInsolvencyAccounts = [SELECT Id, Payment_Sub_Status__c FROM Insolvency_Payment__c WHERE Id IN :insolvencyPayments];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }

    @isTest
    static void testQueueable3() {
        //Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        Test.setMock(HttpCalloutMock.class, new MySecondHttpMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'
        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        List<Insolvency_Payment__c> insolvencyPayments = new List<Insolvency_Payment__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567892';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);

        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Payment_Amount__c = 4450;
        payment1.Insolvency_Account__c = insolAcct1.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        insolvencyPayments.add(payment1);

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            insolvencyAccounts,
            System.Label.CTB_Insolvency_Account, //'YourBatchName',
            'DRN_DailyUpdate_'
        );
        queueable.errorProcessingStatusUpdate(System.Label.CTB_Insolvency_Account, insolvencyAccounts);
        queueable.populateErrorMesssage(System.Label.CTB_Insolvency_Account, insolAcct1.id, 'error invalid record');
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<Insolvency_Payment__c> updatedInsolvencyAccounts = [SELECT Id, Payment_Sub_Status__c FROM Insolvency_Payment__c WHERE Id IN :insolvencyPayments];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }

    @isTest
    static void testQueueable4() {
        Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567890';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);
        Statement_Processing_Settings__c setting = new Statement_Processing_Settings__c();
        setting.Name = 'Canadian Tire';
        insert setting;

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            new List<ContentVersion>{ contentVersionData },
            null, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [
            SELECT Id, Insolvency_Sub_Status__c
            FROM insolvency_account__c
            WHERE Id IN :insolvencyAccounts
        ];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }

    @isTest
    static void testQueueable5() {
        Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567890';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);
        Statement_Processing_Settings__c setting = new Statement_Processing_Settings__c();
        setting.Name = 'Canadian Tire';
        insert setting;

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            new List<ContentVersion>{ contentVersionData },
            null, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Test Document';
        docInfo.Statement_Processing_Status__c = 'Processing';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = '7843843jsks';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.Bulk_API_Job_ID__c = '750As0000059sSvIAI';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        System.schedule('GetSuccessFailedFilesScheduler', '0 0 23 * * ?', new GetSuccessFailedFilesScheduler());
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [
            SELECT Id, Insolvency_Sub_Status__c
            FROM insolvency_account__c
            WHERE Id IN :insolvencyAccounts
        ];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }
    @isTest
    static void testQueueable6() {
        Test.setMock(HttpCalloutMock.class, new GetSuccessFailedFilesSchedulerMock1());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567890';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);
        Statement_Processing_Settings__c setting = new Statement_Processing_Settings__c();
        setting.Name = 'Canadian Tire';
        insert setting;

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            new List<ContentVersion>{ contentVersionData },
            null, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Test Document';
        docInfo.Statement_Processing_Status__c = 'Processing';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = '7843843jsks';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.Bulk_API_Job_ID__c = '750As0000059sSvIAI';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        System.schedule('GetSuccessFailedFilesScheduler', '0 0 23 * * ?', new GetSuccessFailedFilesScheduler());
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [
            SELECT Id, Insolvency_Sub_Status__c
            FROM insolvency_account__c
            WHERE Id IN :insolvencyAccounts
        ];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }
    @isTest
    static void testQueueable7() {
        Test.setMock(HttpCalloutMock.class, new GetSuccessFailedFilesSchedulerMock2());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;

        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;

        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;

        Id contentVersionId = contentVersionData.id; // 'your_content_version_id'

        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list

        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Active';
        insert insolv1;

        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = '2221111234567890';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);
        Statement_Processing_Settings__c setting = new Statement_Processing_Settings__c();
        setting.Name = 'Canadian Tire';
        insert setting;

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            new List<ContentVersion>{ contentVersionData },
            null, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Test Document';
        docInfo.Statement_Processing_Status__c = 'Processing';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = '7843843jsks';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.Bulk_API_Job_ID__c = '750As0000059sSvIAI';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;

        Document_Storage__c child = new Document_Storage__c();
        child.Document_Name__c = 'Child';
        child.Document_Storage__c = docInfo.Id;
        child.Insolvency_Account__c = insolAcct1.Id;
        insert child;
        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        System.schedule('GetSuccessFailedFilesScheduler', '0 0 23 * * ?', new GetSuccessFailedFilesScheduler());
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [
            SELECT Id, Insolvency_Sub_Status__c
            FROM insolvency_account__c
            WHERE Id IN :insolvencyAccounts
        ];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }
    public class GetSuccessFailedFilesSchedulerMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String responseBody = '{"access_token": "test","IsSuccess": true,"state":"JobComplete","numberRecordsProcessed":3416,"numberRecordsFailed":0}';
            if (req.getEndpoint().contains('successfulResults') || req.getEndpoint().contains('failedResults')) {
                responseBody = 'sf__Id,sf__Created,Document_Name__c,Document_URL__c,Document_Type__c,Document_Extension__c,Statement_Processing_Status__c,Document_Related_To__c,Insolvency_Account__c,Uploaded_By__c,Creator__c,Visibility__c,RecordTypeId,Document_Storage__c\n"a39As00000109VlIAI","true","000000000000010_20241111_CTStatements.pdf","000000000000010_20241111_CTStatements.pdf","ctb_statement_output","pdf","Processed","Insolvency Account","a11As000001ZSYlIAO","System","System","CFG only","0123a000000LLE5AAO","a39As00000109E3IAI"';
            }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    public class GetSuccessFailedFilesSchedulerMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String responseBody = '{"access_token": "test","IsSuccess": true,"state":"Failed"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }
    public class MySecondHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(300);
            String responseBody = '{"access_token": "test","IsSuccess": true}';
            res.setBody(responseBody);
            return res;
        }
    }
}
