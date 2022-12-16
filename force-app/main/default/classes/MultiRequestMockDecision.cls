/**************************************************************************************************
*
*  Class:   
*
*  @description : This class for test code coverage for the Adjudication and AML web service
*  @author : A5E Consulting
*  @date : 04/06/2020   
*
*************************************************************************************************/
@isTest
public class MultiRequestMockDecision implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
 
    public MultiRequestMockDecision(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
 
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            //throw new MyCustomException('HTTP callout not supported for test methods');
            return null;
        }
    }
 
    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}