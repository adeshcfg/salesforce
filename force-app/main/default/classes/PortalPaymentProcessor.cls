/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process request funds record
*  @author : A5E Consulting
*  @date : 20/07/2021

*************************************************************************************************/
@RestResource(urlMapping='/PortalPaymentProcessor/*') 
global class PortalPaymentProcessor{
    
    //Webhook function
    @HttpPost
    global static string createRequestFunds(){    
        //Store Response
        RestRequest req = RestContext.request;
        system.debug('req.requestBody: '+req);
        Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        system.debug('mapJSONResponse: '+mapJSONResponse);
        //Map<String, Object> mapData = (Map<String, Object>) mapJSONResponse.get('Data');
        Map<String, String> mapParameters = new Map<String, String>();
        //system.debug('mapData: '+mapData);
        
        map<String, String> mapHeaders = req.headers;
        
        //iterate through they keys, to store string values
        for(String paramKey : mapJSONResponse.keySet()){
            mapParameters.put(paramKey, String.valueOf(mapJSONResponse.get(paramKey)));
            system.debug('header: ' + paramKey + ' value: ' + mapJSONResponse.get(paramKey));
        } 
        system.debug('authetincated');
        //Decision variables
        //Create or update the payment based on payment processor Id
        List<Payment_Transaction__c> listPayTransactions = [SELECT ID, Product__c, Product__r.Name 
                                                  FROM Payment_Transaction__c 
                                                  WHERE Payment_Processor_Id__c =: mapParameters.get('Payment_Processor_Id') limit 1];
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        if(!listPayTransactions.isEmpty()){
            StatusResponse = PortalPaymentProcessorUtil.updateRequestFund(mapParameters, listPayTransactions[0], String.valueOf(mapJSONResponse)); 
        }
        else{
            StatusResponse = PortalPaymentProcessorUtil.createRequestFund(mapParameters, String.valueOf(mapJSONResponse));
        }  
        if(StatusResponse == 'success'){     
            stringMap.put('success', true);
            createResponse(JSON.serialize(stringMap, true), 200);               
        }
        else{
            stringMap.put('errors', true);
            stringMap.put('reason', StatusResponse);
            createResponse(JSON.serialize(stringMap, true), 500);
        }
        system.debug('StatusResponse:'+StatusResponse);
        return  JSON.serialize(stringMap, true);
    }
    
     public static void createResponse(String responseBody, Integer statusCode) {
        System.debug('statusCode '+statusCode);
        RestContext.response.statusCode = statusCode;
        RestContext.response.responseBody = Blob.valueOf(responseBody);
        RestContext.response.addHeader('Content-Type', 'application/json');
    }
}