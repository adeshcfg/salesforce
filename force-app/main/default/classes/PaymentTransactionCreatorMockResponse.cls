/**************************************************************************************************
 *
 *  Class:   
 *  @description : Mock Response class for PaymentTransactionCreator
 *  @author : A5E Consulting
 *  @date : 02/08/2021
 
 *************************************************************************************************/
@isTest
public class PaymentTransactionCreatorMockResponse implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
        // Optionally, only send a mock response for a specific endpoint
        // and method.   
        system.debug('req.getEndpoint(): '+req.getEndpoint());     
    	if(req.getEndpoint() == 'https://test.com/api/Authorize'){
        	// Create a fake response
			res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"result":{"Token":"testtoken"}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        	if(req.getEndpoint().startsWith('https://test.com/portalapi/autherize')){
           	// Create a fake response
            res.setHeader('Content-Type', 'application/json');
			String jsonTokenResponse = '{"result":{"statusCode":200}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
         if(req.getEndpoint() == 'https://test.com/api/requestfunds'){
           	// Create a fake response
            res.setHeader('Content-Type', 'application/json');
			String jsonTokenResponse = '{"result":{"Id":"124568"}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        if(req.getEndpoint() == 'https://test.com/api/recurrenttransaction/1111111'){
           	// Create a fake response
            res.setHeader('Content-Type', 'application/json');
			String jsonTokenResponse = '{"result":{"statusCode":200}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        system.debug('req.getEndpoint()1: '+req.getEndpoint());
        if(req.getEndpoint().startsWith('https://test.com/portalapi')){
           	// Create a fake response
           	system.debug('req.getEndpoint()::: '+req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
			String jsonTokenResponse = '{"token_type":"Bearer","access_token":"eyJ0eXAiOiJKV"}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        system.debug('req.getEndpoint()2'+req.getEndpoint());
        if(req.getEndpoint().startsWith('https://test.com/endpointurl')){
           	// Create a fake response
            res.setHeader('Content-Type', 'application/json');
			String jsonTokenResponse = '{"IsSuccess":true,"ReturnMessage":Updated}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        return res;
    }
}