/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 11/02/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalDistressedNotesProcessor/*')
global class PortalDistressedNotesProcessor {
    
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
        //Process the Customer based on Identfier in portal request
        system.debug('param'+mapParameters.get('Identifier'));
        system.debug('Distressed Notes Name '+mapParameters.get('Name'));
        List<Distressed_notes__c> listDistressedNotes = [SELECT ID,Distressed_Notes_Number__c,Agency_ID__c
                                             FROM Distressed_notes__c 
                                             WHERE Name =: mapParameters.get('Name')                                   
                                             LIMIT 1];
        system.debug('listDistressedNotes: '+listDistressedNotes);
        
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Distressed_notes__c distressedNotes = new Distressed_notes__c();
        if(!listDistressedNotes.isEmpty()){
            system.debug('distressedNotes: '+distressedNotes);
            distressedNotes = listDistressedNotes[0];    
        }
        
        StatusResponse = PortalDistressedNotesProcessorUtil.processDistressedNotes(mapParameters, distressedNotes); 

        
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