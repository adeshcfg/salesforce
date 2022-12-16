/**************************************************************************************************
 *
 *  Class:   
 *  @description : Mock Response class for Bulk API  for Allocation in classes
 *  @author : A5E Consulting
 *  @date : 20/02/2023
 
 *************************************************************************************************/
@isTest
public class BulkAPIMockResponse implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        // Optionally, only send a mock response for a specific endpoint
        // and method.   
        system.debug('req.getEndpoint(): '+req.getEndpoint());   
        
        //Mock response for access token
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{';
  			jsonTokenResponse += '"id" : "7506g00000DhRA2AAN",';
            jsonTokenResponse += '"operation" : "insert",';
            jsonTokenResponse += '"object" : "Product_Staging__c",';
            jsonTokenResponse += '"createdById" : "0056g000005HQPyAAO",';
            jsonTokenResponse += '"createdDate" : "2018-12-18T22:51:36.000+0000",';
            jsonTokenResponse += '"systemModstamp" : "2018-12-18T22:51:58.000+0000",';
            jsonTokenResponse += '"state" : "Open",';
            jsonTokenResponse += '"concurrencyMode" : "Parallel",';
            jsonTokenResponse += '"contentType" : "CSV",';
            jsonTokenResponse += '"apiVersion" : 57.0,';
            jsonTokenResponse += '"jobType" : "V2Ingest",';
            jsonTokenResponse += '"contentUrl" : "services/data/v57.0/jobs/ingest/7506g00000DhRA2AAN/batches",';
            jsonTokenResponse += '"lineEnding" : "LF",';
            jsonTokenResponse += '"columnDelimiter" : "COMMA",';
            jsonTokenResponse += '"retries" : 0,';
            jsonTokenResponse += '"totalProcessingTime" : 0,';
            jsonTokenResponse += '"apiActiveProcessingTime" : 0,';
            jsonTokenResponse += '"apexProcessingTime" : 0';
            jsonTokenResponse += '}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         
        //mock response for Account Judgment API
        return res;
    }
 
}