@isTest
public class TestDocumentAPIClient {
    public static API_Call_Details__c testDocumentAPI() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        insert settings;
        return settings;
    }

    public static testMethod void testDocAPIcall() {
        API_Call_Details__c api = testDocumentAPI();

        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert docAzur;

        test.startTest();
        String failed;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed = 'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality'; //,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        DocumentAPIClientUtil.ParsedResponse res = DocumentAPIClient.postDocument(bl, 'Customer Contact Information Failed.csv', 'Task');
        DocumentAPIClient.getDocument(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        test.stopTest();
    }

    public static testMethod void testPrePDFCont() {
        API_Call_Details__c api = testDocumentAPI();

        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        docAzur.Customer_Identifier__c = 'ABC';
        insert docAzur;

        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        PageReference pageRef = Page.PreviewPdf; //Observe how we set the Page here
        Test.setCurrentPage(pageRef); //Applying page context here

        ApexPages.currentPage().getParameters().put('documentId', docAzur.Document_ID__c);
        ApexPages.StandardController sc = new ApexPages.standardController(docAzur);
        PreviewPdfController controller = new PreviewPdfController();
        String getPDFTest = controller.pdf;
        String getStringTest = controller.getString;
        Test.stopTest();
    }

    public static testMethod void testDocAPIcall2() {
        API_Call_Details__c api = testDocumentAPI();

        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'DC-01110';
        insert docAzur;

        test.startTest();
        String failed;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed = 'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality'; //,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        DocumentAPIClientUtil.ParsedResponse res = DocumentAPIClient.postDocument2(docAzur.Document_ID__c, 'Customer Contact Information Failed.csv', 'Task');
        DocumentAPIClientUtil.ReverseProxyAPI parsedResponse = new DocumentAPIClientUtil.ReverseProxyAPI();
        parsedResponse.isSuccess = true;
        parsedResponse.returnMessage = 'Test';
        parsedResponse.statusCode = 123;
        DocumentAPIClientUtil.ReverseProxyAPIData ParsedResponseData = new DocumentAPIClientUtil.ReverseProxyAPIData();
        ParsedResponseData.id = '12345';
        ParsedResponseData.success = true;
        parsedResponse.data = ParsedResponseData;
        DocumentAPIClient.getDocument(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        test.stopTest();
    }

    public static testMethod void testDocAPIcall3() {
        API_Call_Details__c api = testDocumentAPI();

        // Document Storage data
        Document_Storage__c docAzur = new Document_Storage__c();
        docAzur.Document_Type__c = 'Selling Bill';
        docAzur.Document_URL__c = 'bill@gmail.com';
        docAzur.Document_ID__c = 'd5ded3c9-c160-497d-a258-99246d189b9c';
        insert docAzur;
        id folderid = [SELECT id FROM folder WHERE name = 'Metadata_Content'].id;
        test.startTest();
        String failed;
        String DocUrl;
        String docId;
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        failed = 'data_1id,pri_email1,pri_add1,pri_add2,pri_municipality'; //,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';
        Blob bl = Blob.valueOf(failed);
        DocumentAPIClientUtil.ParsedResponse res = DocumentAPIClient.postDocument2(docAzur.Document_ID__c, 'Customer Contact Information Failed.csv', 'Task');
        res.DocUrl = 'Test';
        res.docId = 'Test';
        DocumentAPIClient.getDocument(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentInfo(docAzur.Document_ID__c);
        DocumentAPIClient.getDocumentJSON(docAzur.Document_URL__c);
        //DocumentAPIClient.createDocumentFromAzure(folderid,'Agency Portal API');
        test.stopTest();
    }

    public static testMethod void testGetContentVersionIdForAzureFile() {
        API_Call_Details__c api = testDocumentAPI();
        Test.setMock(HttpCalloutMock.class, new DocumentAPIClientMockTest());
        Test.startTest();
        DocumentAPIClient.getContentVersionIdForAzureFile('test', 'test');
        Test.stopTest();
    }
}
