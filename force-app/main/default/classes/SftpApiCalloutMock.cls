/**
 * @description       : Mock callout class for SFTP API callout test classes
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-14-2025
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
        res.setStatusCode(200);
        // Optionally, only send a mock response for a specific endpoint
        if (req.getEndpoint() == 'https://test.com/api/accessToken') {
            responseString = '{"result":{"Token":"testtoken"}}';
        }
        if (req.getEndpoint().contains('filter')) {
            responseString = '{"$id":"1","hasMore":false,"files":["ctbsftpinbox/20240504/ptd.drn.drnbkruptupd.date.time","ctbsftpinbox/20240504/ptd.drn.inactive.stmt.reprint.zip.date.time"]}';
        }
        if (req.getEndpoint().contains('sobjects/folders/')) {
            responseString =
                '{"$id":"1","StatusCode":201,"IsSuccess":true,"ReturnMessage":null,"Data":{"$id":"2","id":"' +
                documentId +
                '","success":true,"errors":{"$id":"3","$values":[]}}}';
        }
        if (req.getEndpoint().contains('sobjects/' + documentId)) {
            responseString = '{"docId":"docId", "DocUrl":"DocUrl", "request":"request", "response":"response"}';
        }
        if (req.getEndpoint().contains('background/zip')) {
            responseString = '{"result":{"Token":"testtoken"}}';
            res.setStatusCode(202);
        }
        res.setBody(responseString);
        return res;
    }
}
