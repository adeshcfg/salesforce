/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process Complaint record(consume API)
*  @author : A5E Consulting
*  @date : 23/02/2022

*************************************************************************************************/
@RestResource(urlMapping='/PortalComplaintProcessor/*') 
global class PortalComplaintProcessor {
    
    @HttpPost
    global static string postComplaint(){    
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
        List<Work_Assignment__c> listComplaint = [SELECT ID, Comment_Reply__c, Comments_History__c,Latest_Comment__c,
                                                  Status__c, Original_Creditor__c,Last_Modified_By__c,Settlement_Identifier__c,Judgment_Identifier__c
                                             FROM Work_Assignment__c 
                                             WHERE Task_Number__c =: mapParameters.get('Task_Number')
                                             //AND RecordType.Developername= :'Agency'
                                             LIMIT 1];
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Work_Assignment__c complaint = new Work_Assignment__c();
        if(!listComplaint.isEmpty()){
            complaint = listComplaint[0];    
        }
        StatusResponse = PortalComplaintProcessorUtil.processComplaint(mapParameters, complaint); 

          
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