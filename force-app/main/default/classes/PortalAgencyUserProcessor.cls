@RestResource(urlMapping='/PortalAgencyUserProcessor/*')
global class PortalAgencyUserProcessor {
      @HttpPost
    global static string postAgencyUser(){    
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
       // system.debug('param'+mapParameters.get('Identifier'));
       // system.debug('doc number '+mapParameters.get('Name'));
        List<Agency_User__c> listAgencyUser = [SELECT ID,Placement__c
                                             FROM Agency_User__c 
                                             WHERE Email_Address__c	 =: mapParameters.get('Email_Address')                                   
                                             LIMIT 1];
        system.debug('listAgencyUser: '+listAgencyUser);
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        Agency_User__c agencyUser = new Agency_User__c();
        if(!listAgencyUser.isEmpty()){           
            agencyUser = listAgencyUser[0];    
        }
        StatusResponse = PortalAgencyUserProcessorUtil.processAgencyUser(mapParameters, agencyUser); 

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