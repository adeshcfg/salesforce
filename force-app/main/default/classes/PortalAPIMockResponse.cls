/**************************************************************************************************
 *
 *  Class:   
 *  @description : Mock Response class for API in classes for object sync to portal
 *  @author : A5E Consulting
 *  @date : 24/01/2022
 
 *************************************************************************************************/
@isTest
public class PortalAPIMockResponse implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        // Optionally, only send a mock response for a specific endpoint
        // and method.   
        system.debug('req.getEndpoint(): '+req.getEndpoint());   
        
        //Mock response for access token
        if(req.getEndpoint() == 'https://test.com/api/Authorize'){
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"result":{"Token":"testtoken"}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        //mock response for Account Judgment API
        if(req.getEndpoint() == 'https://test.com/api/AccountJudgment/1111111'){
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"result":{"statusCode":200}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        
        //mock response for SnapShotAPI
        if(req.getEndpoint() == 'https://test.com/api/services/snapshots'){
            system.debug('req.getEndpoint()'+req.getEndpoint());
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"result":{"statusCode":202}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(202);  
         }
      //mock response for SnapShotAPI
        if(req.getEndpoint() == 'https://test1.com/api/services/snapshots'){
            system.debug('req.getEndpoint()'+req.getEndpoint());
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"result":{"statusCode":200}}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        if(req.getEndpoint() <> NULL) { if((req.getEndpoint()).contains('https://test.com/endpointurlplacement')){
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{'+
                  '"id": "xyz",'+
                  '"DocUrl": "task@626f2cf7-f198-4343-8422-69ddb6bbcf84_pdf",'+
                  '"docId": "626f2cf7-f198-4343-8422-69ddb6bbcf84"'+
                
        '}';
        
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
        }
        if((req.getEndpoint()).contains('https://test.com/endpointurlTask')){
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{'+
                  '"id": "xyz",'+
                  '"DocUrl": "task@626f2cf7-f198-4343-8422-69ddb6bbcf84_csv",'+
                  '"docId": "626f2cf7-f198-4343-8422-69ddb6bbcf84"'+
                
        '}';
        
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        if((req.getEndpoint()).contains('https://test.com/documentAPI')){
            // Create a fake response
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{'+
                '"$id": "1",'+
	'"isSuccess": true,'+
	'"returnMessage": "document Record Created",'+
	'"data": "2775365c-3eee-4cb8-982d-3de03c5cee14 Document Created Successfully",'+
	'"statusCode": 0,'+
	'"tag": null'+
                '}';
        
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
		
          if((req.getEndpoint()).contains('https://test.com/FidemAPI')){
              // Create a fake response
              res.setHeader('Content-Type', 'application/json');
              String jsonTokenResponse = '{'+
                  '"$id": "1",'+
                  '"isSuccess": true,'+
                  '"returnMessage": "document Record Created",'+
                  '"data": "2775365c-3eee-4cb8-982d-3de03c5cee14 Document Created Successfully",'+
                  '"statusCode": 0,'+
                  '"Code": 2020,'+
                  '"tag": null'+
                  '}';
              
              res.setBody(jsonTokenResponse);
              res.setStatusCode(500);  
         }
                                       
        system.debug('req.getEndpoint()1: '+req.getEndpoint());
        //mock response for access token
        if(req.getEndpoint().startsWith('https://test.com/portalapi')){
            // Create a fake response
            system.debug('req.getEndpoint()::: '+req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"token_type":"Bearer","access_token":"eyJ0eXAiOiJKV"}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
         }
        // below code is for increasing code coverage
        //mock response for access token
        if(req.getEndpoint().startsWith('https://test.com/endpoint')){
            // Create a fake response
            system.debug('req.getEndpoint()::: '+req.getEndpoint());
            res.setHeader('Content-Type', 'application/json');
            String jsonTokenResponse = '{"token_type":"Bearer","access_token":"eyJ0eXAiOiJKV"}';
            res.setBody(jsonTokenResponse);
            res.setStatusCode(200);  
        }}
        system.debug('req.getEndpoint()2'+req.getEndpoint());
        return res;
    }
}