@IsTest
public class GetZipFilesSchedulerTest {
    @testSetup
    static void mockDataSetup() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/Document';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 20.0;
        insert settings;

        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'ss.zip';
        docInfo.Statement_Processing_Status__c = 'In Progress';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = '993sdjh';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;
        Statement_Processing_Settings__c setting = new Statement_Processing_Settings__c();
        setting.Name = 'Canadian Tire';
        insert setting;
    }
    @isTest
    static void testGetZipFileSchedQueueable() {
        Test.setMock(HttpCalloutMock.class, new GetZipFileHttpMockCallout());

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

        // Start the test
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest', '0 0 23 * * ?', new GetZipFilesScheduler());

        Test.stopTest();
    }

    @isTest
    static void testGetZipFileSchedQueueable2() {
        Test.setMock(HttpCalloutMock.class, new GetZipFileHttpMockCallout2());

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

        try {
            // Start the test
            Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest', '0 0 23 * * ?', new GetZipFilesScheduler());
            Test.stopTest();
        } catch (exception ex) {
        }
    }

    @isTest
    static void testGetZipFileSchedQueueable3() {
        Test.setMock(HttpCalloutMock.class, new GetZipFileHttpMockCallout3());

        String sampleCsv = 'Name,Type' + '\n' + '000000000000001_temp.pdf,ctb_statement_output/000000000000001_temp.pdf';
        String folderId = [SELECT Id FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1].Id;
        Document doc = new Document();
        doc.Name = 'TestCsv';
        doc.FolderId = folderId;
        doc.Body = Blob.valueOf(sampleCsv);
        doc.Type = 'csv';
        doc.IsPublic = true;
        insert doc;

        // Start the test
        Test.startTest();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'ss.zip';
        docInfo.Statement_Processing_Status__c = 'In Progress';
        docInfo.Document_Type__c = 'Statement Processing File';
        docInfo.Document_Extension__c = 'zip';
        docInfo.Token_Id__c = '993sdjh';
        docInfo.Uploaded_By__c = 'System';
        docInfo.Creator__c = 'System';
        docInfo.Visibility__c = 'CFG only';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
        insert docInfo;

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
        insolAcct1.Correlation_Id__c = '000000000000001';
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;

        String jobId = System.schedule('ScheduleApexClassTest', '0 0 23 * * ?', new GetZipFilesScheduler());
        System.scheduleBatch(new ProcessStatementZipFilesBatch(), 'ProcessStatementZipFilesBatch', 5);

        Test.stopTest();
    }
    public class GetZipFileHttpMockCallout3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            Document doc = [SELECT Id FROM Document WHERE Name = 'TestCsv' LIMIT 1];
            HttpResponse res = new HttpResponse();
            String responseBody =
                '{"access_token": "test","IsSuccess": true,"hasMore":true,"files":["test/ssTest.zip"],"oid":"2332cddss","sfFileId":"' +
                doc.Id +
                '"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            if (req.getMethod() == 'GET') {
                res.setStatusCode(201);
            } else if (req.getMethod() == 'POST') {
                res.setStatusCode(201);
            }
            return res;
        }
    }
    public class GetZipFileHttpMockCallout2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String responseBody = '{"access_token": "test","IsSuccess": true,"hasMore":true,"files":""}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }
    public class GetZipFileHttpMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String responseBody = '{"access_token": "test","IsSuccess": true,"hasMore":true,"files":["test/ssTest.zip"],"oid":"2332cddss"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            if (req.getMethod() == 'GET') {
                res.setStatusCode(200);
            } else if (req.getMethod() == 'POST') {
                res.setStatusCode(201);
            }
            return res;
        }
    }
}
