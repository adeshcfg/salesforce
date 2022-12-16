/**************************************************************************************************
*
*  Class:   
*
*  @description : This class for test code coverage for the Adjudication and AML web service
*  @author : A5E Consulting
*  @date : 03/27/2020   
*
*************************************************************************************************/
@isTest
public class DecisionWSUtilReqMock implements HttpCalloutMock {
    private static HttpResponse resp;
    
    public DecisionWSUtilReqMock(String testBody) {
        resp = new HttpResponse();
        resp.setBody(testBody);
        resp.setStatusCode(200);
        resp.setStatus('OK');
        System.debug('resp=='+resp);
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        return resp;
    }
    
}