@isTest
public class VotingEngineClientMockResponse implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        HttpResponse response;
        if(req.getEndpoint() == 'https://login.microsoftonline.com/{{dptenandId}}/oauth2/v2.0/token'){
            response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token":"123PPGMndks6Os"}');
            response.setStatusCode(200);
        }
        else{
            response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String json = '{'+
              '"dRejection": ['+
                '{'+
                  '"reasonCode": "ENTERTAINMENT_EXCEEDED",'+
                  '"diagnosticInfo": "100.0",'+
                  '"difference": 50.0'+
                '},'+
                '{'+
                '"reasonCode": "PAST_REVIEW_PERIOD",'+
                '"diagnosticInfo": "72",'+
                '"difference": 27.0'+
              '}'+
              '],'+
              '"dResults": ['+
                '{'+
                  '"rejected": "1",'+
                  '"result": true'+
                '}'+
              '],'+
              '"vExtendedResults": {'+
                  '"proposedMonthlyPayment": {'+
                        '"amount": -270.0'+
                    '},'+
                    '"maxCounterMonthlyPayment": {'+
            '"amount": -563.0'+
        '},'+
        '"totalPayoutOffered": {'+
            '"amount": 10425.0,'+
            '"totalReturn": 0.3196,'+
            '"adjustedReturn": 0.3321'+
        '},'+
        '"acceptableMonthlyPayment": {'+
            '"amount": -160.0'+
        '},'+
        '"bkDuration": 9,'+
       '"bkNetPayout": {'+
            '"amount": -439.5,'+
            '"totalReturn": -0.0135,'+
            '"adjustedReturn": -0.014'+
        '},'+
        '"maxCounterPayout": {'+
            '"amount": -33217.0,'+
            '"totalReturn": -1.0185,'+
            '"adjustedReturn": -1.0581'+
        '},'+
        '"surplusIncomePayments": {'+
            '"amount": 0.0'+
        '},'+
        '"proposedCounterPayout": {'+
            '"amount": -15930.0,'+
            '"totalReturn": -0.4884,'+
            '"adjustedReturn": -0.5074'+
        '},'+
        '"counterWithBKInsteadOfCP": true,'+
        '"adjustedUnsecuredDebt": {'+
            '"amount": 31392.68'+
        '},'+
        '"minAcceptablePayout": {'+
            '"amount": -9440.0,'+
            '"totalReturn": -0.2894,'+
            '"adjustedReturn": -0.3007'+
        '},'+
        '"shouldWeFurtherCounterWithBK": true,'+
        '"cpNetPayout": {'+
            '"amount": 6416.25,'+
            '"totalReturn": 0.1967,'+
            '"adjustedReturn": 0.2044'+
        '}'+
              '}'+
        '}';
            response.setBody(json);
            response.setStatusCode(200);
        }
        // Create a fake response
        
        return response;
    }
}