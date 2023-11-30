/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process Judgment record(consume API)
*  @author : A5E Consulting
*  @date : 12/01/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalJudgmentProcessor/*') 
global class PortalJudgmentProcessor {
    @HttpPost
    global static string postJudgment(){    
        List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
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
        String judgmentNumber = mapParameters.get('Judgment_Number');
        String Query = 'SELECT Id,Name, ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Judgment'){
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        Query = Query.removeEnd(', ');
        Query += ' FROM Judgment__c WHERE Judgment_Number__c = :judgmentNumber LIMIT 1';
        List<Judgment__c> listJudgment = Database.query(Query);
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Judgment__c Judgment = new Judgment__c();
        system.debug('listJudgment::'+listJudgment);
        if(!listJudgment.isEmpty()){
            Judgment = listJudgment[0];    
        }
        StatusResponse = PortalJudgmentProcessorUtil.processJudgment(mapParameters, Judgment); 
        
        
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