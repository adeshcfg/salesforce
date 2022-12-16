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
        List<Judgment__c> listJudgment = [SELECT ID, Name, Created_By__c, Last_Modified_By__c,Writ_Renewal_Date__c,Garnishment_Date__c,
                                          Judgment_Number__c,Legal_Status__c,Legal_Sub_Status__c,Suit_Amount_3__c,Suit_Amount_2__c,
                                          Suit_Amount_4__c,Suit_Amount_5__c,Suit_Amount_1__c,Judgment_Date__c,Interest_Rate_two__c,
                                          Balance_two__c,Interest_Rate_three__c,Balance_three__c,Interest_Rate_four__c,Balance_four__c,
                                          Interest_Rate_five__c,Balance_five__c
                                          FROM Judgment__c 
                                          WHERE Judgment_Number__c =: mapParameters.get('Judgment_Number')
                                          //AND RecordType.Developername= :'Agency'
                                          LIMIT 1];
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