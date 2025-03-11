@IsTest
public class TestDeleteRecordsService {
    
    
	@isTest 
    private static void testGetPositive() {
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = 'services/apexrest/v1/deleteRecords/';
        req.httpMethod = 'DELETE';
        req.requestBody= Blob.valueOf('{\"Result\": \"success\"}');
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        DeleteRecordsService.deleteRecords();
        Test.stopTest();
        System.assertEquals(true, DeleteRecordsService.isBatchStarted);

    }
}