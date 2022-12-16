/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process Productbulk record(consume API)
*  @author : A5E Consulting
*  @date : 14/03/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalBulkProductStatusProcessing/*') 
global class PortalProductStatusBulkProcessor{
    
    @HttpPost
    global static string postAssignment(){    
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
        //Process the Product based on Identfier in portal request
        system.debug('param'+mapParameters.get('Identifier'));
       /* List<Product__c> listProducts = [SELECT ID, Customer_identifier__c
                                         FROM Product__c 
                                         WHERE Name =: mapParameters.get('Name')
                                         LIMIT 1];
        
        Product__c product = new Product__c();
        if(!listProducts.isEmpty()){
            product = listProducts[0];    
        }*/
        
        
        String StatusResponse; 
        StatusResponse = PortalProductStatusBulkProcessingUtil.processBulkProducts(req.requestBody.toString()); 

        Map<String, Object> stringMap = new Map<String, Object>();
        if(StatusResponse == 'success'){ 
            system.debug('Inside block');
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