/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process Settelment record(consume API)
*  @author : A5E Consulting
*  @date : 

*************************************************************************************************/
@RestResource(urlMapping='/PortalSettlementProcessor/*') 
global class PortalSettlementProcessor{
    
    @HttpPost
    global static string postSettlement(){    
        //Store Response
        RestRequest req = RestContext.request;
        system.debug('req.requestBody: '+req);
        Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        system.debug('mapJSONResponse: '+mapJSONResponse);       
        Map<String, String> mapParameters = new Map<String, String>();      
        
        map<String, String> mapHeaders = req.headers;
        
        //iterate through they keys, to store string values
        for(String paramKey : mapJSONResponse.keySet()){
            mapParameters.put(paramKey, String.valueOf(mapJSONResponse.get(paramKey)));
            system.debug('header: ' + paramKey + ' value: ' + mapJSONResponse.get(paramKey));
        } 
        system.debug('authetincated');       
        system.debug('param'+mapParameters.get('Identifier'));
        List<Settlement__c> listSettlements = [SELECT ID,Comment__c,Comments_History__c, Status__c
                                               FROM Settlement__c 
                                               WHERE Settlement_Number__c =: mapParameters.get('Settlement_Number')
                                               LIMIT 1];
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Settlement__c settlement = new Settlement__c();
        if(!listSettlements.isEmpty()){
            settlement = listSettlements[0];    
        }
        StatusResponse = PortalSettlementProcessorUtil.processSettlement(mapParameters, settlement); 

          
        if(StatusResponse == 'success'){     
            stringMap.put('success', true);
            createResponse(JSON.serialize(stringMap, true), 200);               
        }
        else{
            stringMap.put('errors', true);
            stringMap.put('reason', StatusResponse);
            createResponse( JSON.serialize(stringMap, true), 500);
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