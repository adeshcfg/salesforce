public class PortalAgencyUserProcessingAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    @future (callout=true)
    public static void processAgencyUser(ID agencyUserId){ 
        list<Agency_User__c> listAgencyUser = [SELECT ID, Name,First_Name__c,Last_Name__c,Is_Active__c,Email_Address__c,Contact_Number__c,Role__c,
                                               Placement_Identifier__c,Created_By__c,Last_Modified_By__c, Agency_Type__c,Placement__c
                                               FROM Agency_User__c 
                                               WHERE ID= :agencyUserId];
        system.debug('listAgencyUser: '+listAgencyUser);                             
        
        String agencyUserJSONRequest;
        Agency_User__c agencyUserInstance;
        if(!listAgencyUser.isEmpty()){
            //Create JSON request for customer update
            agencyUserInstance = listAgencyUser[0];
            system.debug('agencyUserInstance '+agencyUserInstance);
            agencyUserJSONRequest = '{'+
                '"Name": "'+agencyUserInstance.Name+'",'+
                '"First_Name": "'+agencyUserInstance.First_Name__c+'",'+
                '"Last_Name": "'+agencyUserInstance.Last_Name__c+'",'+
                '"Is_Active": "'+agencyUserInstance.Is_Active__c+'",'+
                '"Email_Address": "'+agencyUserInstance.Email_Address__c+'",'+
                '"Contact_Number": "'+agencyUserInstance.Contact_Number__c+'",'+
                '"Role": "'+agencyUserInstance.Role__c+'",'+
                '"Placement_Identifier": "'+agencyUserInstance.Placement_Identifier__c+'",'+              
                '"Agency_Type": "'+agencyUserInstance.Agency_Type__c+'",'+
                '"Last_Modified_By": "'+agencyUserInstance.Last_Modified_By__c  +'",'+      
                '"Created_By": "'+agencyUserInstance.Created_By__c+'"'+     
                '}';
        }
        system.debug('agencyUserJSONRequest: '+agencyUserJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('agencyUserJSONRequest: '+agencyUserJSONRequest);
            req.setBody(agencyUserJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFAgencyContact');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+agencyUserInstance.Name);
            req.setMethod('PUT');         
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            agencyUserInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
            
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                agencyUserInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body:: '+res.getBody());
                if(res.getStatusCode() == 200
                   && bodyMap.get('IsSuccess') == String.valueOf('true')){
                       system.debug(bodyMap.get('ReturnMessage'));
                   }       
                else{
                    system.debug('Error Response');
                    system.debug(bodyMap.get('ReturnMessage'));
                }
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex);
            }
            
            if(agencyUserInstance != NULL){
                AgencyUserTriggerHandler.runAgencyUserTrigger = false;
                update agencyUserInstance;
                AgencyUserTriggerHandler.runAgencyUserTrigger = true;
            }
        }
    }
    
    //Get Access Token
    public static string getRequestToken() {
        system.debug('apiCallDetails: '+apiCallDetails);
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        system.debug('authorizationtUrl changed: '+authorizationtUrl);
        String bodyParams =  'client_id='+dpapiClientClientId;
        bodyParams =  bodyParams+'&client_secret='+dpapiClientSecret;
        bodyParams =  bodyParams+'&scope='+apiCallDetails.Scope_Prefix__c+dpapiProxyClientId+apiCallDetails.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        system.debug('bodyParams: '+bodyParams);        
        system.debug('authorizationtUrl: '+authorizationtUrl);
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        
        system.debug('req: '+req);
        HttpResponse hresp = h.send(req);
        system.debug('hresp: '+hresp);
        system.debug('hresp.getBody(): '+hresp.getBody());
        Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        system.debug('wResp: '+wResp.get('access_token'));
        return String.valueOf(wResp.get('access_token'));
    }
    
}