/**
 * @description       : Test class for ZipFileProcessingStatusApi
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-14-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class ZipFileProcessingStatusApiTest {
    @TestSetup
    static void makeData() {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('Test');
        cv.Title = 'Test_Anea';
        cv.PathOnClient = 'Test_Anea' + '.csv';
        insert cv;

        Document_Storage__c docStoreZip = new Document_Storage__c(
            Document_Name__c = 'Test_Anea.zip',
            Comment__c = cv.Id,
            File_Processing_Status__c = 'Pending'
        );
        insert docStoreZip;
    }

    @isTest
    static void testApiSuccess() {
        String jsonRequest = '{"status" : "Success", "docName" : "Test_Anea.zip", "docUrl" : "docUrl", "docSfId" : "docSfId"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsonRequest);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        ZipFileProcessingStatusApi.finishProcessing();
    }

    @isTest
    static void testApiPartial() {
        Document_Storage__c docStore = [SELECT Id FROM Document_Storage__c LIMIT 1];
        String jsonRequest =
            '{"status" : "Partial", "docName" : "Test_Anea.zip", "docUrl" : "docUrl", "docSfId" : "docSfId", "failedDocIds" : ["' +
            docStore.Id +
            '"]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsonRequest);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        ZipFileProcessingStatusApi.finishProcessing();
    }

    @isTest
    static void testApiFailed() {
        Document_Storage__c docStore = [SELECT Id FROM Document_Storage__c LIMIT 1];
        String jsonRequest = '{"status" : "Failed", "docName" : "Test_Anea.zip", "docUrl" : "docUrl", "docSfId" : "docSfId", "errorMessage" : "errorMessage"}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof(jsonRequest);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        ZipFileProcessingStatusApi.finishProcessing();
    }
}
