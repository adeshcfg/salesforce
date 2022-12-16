/**************************************************************************************************
*
*  Class:   
*
*  @description : API for portal to saleforce to process customer record
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
@RestResource(urlMapping='/PortalCustomerProcessor/*') 
global class PortalCustomerProcessor{
    
    @HttpPost
    global static string processCustomer(){    
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
        List<Account> listAccounts = [SELECT ID, FirstName, LastName, PersonEmail, personMailingCity, personMailingStreet, 
                                      		 personMailingPostalCode, personMailingState, PersonHomePhone, PersonMobilePhone, 
                                      		 Work_Phone__pc, PersonOtherPhone, SIN__pc,
                                            (SELECT ID, First_Name__c, Last_Name__c, Email_Address__c, Address_Line1__c, City__c,
                                             Zip_Code__c/*, State__c*/, Phone_Home__c, Phone_Work__c, Phone_Other__c, Date_of_Birth__c 
                                             FROM Products__r)
                                      FROM Account 
                                      WHERE SF_ID__c =: mapParameters.get('Identifier')
                                      AND RecordType.Developername= :'Canaccede_Customer'
                                      LIMIT 1];
        String StatusResponse; 
        Map<String, Object> stringMap = new Map<String, Object>();
        if(!listAccounts.isEmpty()){
            StatusResponse = PortalCustomerProcessorUtil.updateCustomer(mapParameters, listAccounts[0]); 
        }
        else{
            StatusResponse = 'Customer Identifier not found in Salesforce';
        }  
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