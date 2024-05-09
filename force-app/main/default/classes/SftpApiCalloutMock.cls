/**
 * @description       : Mock callout class for SFTP API callout test classes
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 05-09-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class SftpApiCalloutMock implements HttpCalloutMock {
    public String documentId = '';
    public SftpApiCalloutMock(String documentId) {
        this.documentId = documentId;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String responseString = '{}';
        res.setHeader('Content-Type', 'application/json');
        // Optionally, only send a mock response for a specific endpoint
        if (req.getEndpoint() == 'https://test.com/api/accessToken') {
            responseString = '{"result":{"Token":"testtoken"}}';
        }
        if (req.getEndpoint().contains('filter')) {
            responseString = '{"$id":"1","hasMore":false,"files":["ctbsftpinbox/20240504/DRN_DailyUpdate_20240506024618.csv"]}';
        }
        if (req.getEndpoint().contains('sobjects/folders/')) {
            responseString =
                '{"$id":"1","StatusCode":201,"IsSuccess":true,"ReturnMessage":null,"Data":{"$id":"2","id":"' +
                documentId +
                '","success":true,"errors":{"$id":"3","$values":[]}}}';
        }
        res.setBody(responseString);
        res.setStatusCode(200);
        return res;
    }
}
