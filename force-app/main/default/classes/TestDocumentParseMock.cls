public class TestDocumentParseMock implements HttpCalloutMock {
    
    private static String calloutResponse;
    private static Integer calloutStatusCode;
    public TestDocumentParseMock(String resp, Integer sc) {
        calloutResponse = resp;
        calloutStatusCode = sc;
    }
    
    public static HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(calloutResponse);
        res.setStatusCode(calloutStatusCode);
        return res;
    }

    public static TestDocumentParseMock getDocumentParserResponse() {
        return new TestDocumentParseMock(acceptResponse, 200);
    }

    public static String acceptResponse = '{"access_token":"token"}';
}