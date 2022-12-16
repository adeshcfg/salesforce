public class DocumentAPIClientMockTest implements HttpCalloutMock {
 public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        HttpResponse response;
        if(req.getEndpoint() == 'https://login.automotion.com/{{dptenandId}}/oauth2/v2.0/token'){
            response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"123PPGMndks6Os"}');
            response.setStatusCode(200);
        }
        else{
            response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String json = '{'+
                  '"id": "xyz",'+
                  '"DocUrl": "task@626f2cf7-f198-4343-8422-69ddb6bbcf84_pdf",'+
                  '"docId": "626f2cf7-f198-4343-8422-69ddb6bbcf84"'+
                
        '}';
            response.setBody(json);
            response.setStatusCode(200);
        }
        // Create a fake response
        
        return response;
    }
}