@isTest
public class MegasysWSUtilReqMock implements HttpCalloutMock {
    private static HttpResponse resp;
    
    public MegasysWSUtilReqMock(String testBody) {
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