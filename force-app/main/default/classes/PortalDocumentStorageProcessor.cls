/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 18/01/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalDocStorageProcessor/*')
global class PortalDocumentStorageProcessor {
    
    @HttpPost
    global static string postAssignment(){    
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
        //Decision variables
        //Process the Customer based on Identfier in portal request
        system.debug('param'+mapParameters.get('Identifier'));
        system.debug('doc number '+mapParameters.get('Document_Storage_Number'));
        List<Document_Storage__c> listDocStorages = [SELECT ID
                                             FROM Document_Storage__c 
                                             WHERE Document_Storage_Number__c =: mapParameters.get('Document_Storage_Number')                                   
                                             LIMIT 1];
        system.debug('listDocStorages: '+listDocStorages);
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Document_Storage__c documentStorage = new Document_Storage__c();
        if(!listDocStorages.isEmpty()){
            system.debug('documentStorage: '+documentStorage);
            documentStorage = listDocStorages[0];    
        }
        StatusResponse = PortalDocumentStorageProcessorUtil.processDocumentStorage(mapParameters, documentStorage); 

          
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