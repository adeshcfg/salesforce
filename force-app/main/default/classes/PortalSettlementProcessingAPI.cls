public class PortalSettlementProcessingAPI {
     public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
     static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
     public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    @future (callout=true)
    public static void processSettlement(ID settlementId){ 
                String Query = 'SELECT ID,Name,Comment__c,Proposal_Total_Percent__c,Employment_Comments__c,HomeOwner_Status_Comments__c,Proposal_Principal_Percent__c,Monthly_Expenses_Comments__c,Monthly_Income_Comments__c,Total_Wealth_Comments__c,';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Settlement'){
             //Query += fieldMappingInstance.Field_API__c + ', ';
             //Added below IF-Else loop for #4931
                if(fieldMappingInstance.Field_API__c=='Payment_Plan_Length__c'){
                    Query += ROUND(fieldMappingInstance.Field_API__c,0) + ', ';
                }
                else{
                Query += fieldMappingInstance.Field_API__c + ', ';
                }
            }
            
        }
        Query = Query.removeEnd(', ');
        system.debug('Query after:'+Query);
        Query+= ' FROM Settlement__c WHERE ID=: settlementId';
        system.debug('Query: '+Query);
        list<Settlement__c> listSettlement = Database.query(Query); 
     
         system.debug('listSettlement: '+listSettlement);                             
        
        String settlemntJSONRequest;
        Settlement__c settlementInstance;
      
        
        if(!listSettlement.isEmpty()){
            //Create JSON request for settlement update
            settlementInstance = listSettlement[0];
            system.debug('settlementInstance '+settlementInstance);
            String commentReply ='';
            String monthlyExpensesComments = '';
            String monthlyIncomeComments = '';
            String totalWealthComments = '';
            String employmentCommment = '';
            String homeownerStatusComments = '';
            if(String.isNotBlank(settlementInstance.Comment__c)){
                commentReply = String.valueOf(settlementInstance.Comment__c).replace('\n', '').replace('\r', ' ');   
                commentReply = commentReply.replaceAll('\\s+', ' ');
            }
           
            if(String.isNotBlank(settlementInstance.Monthly_Expenses_Comments__c)){
               monthlyExpensesComments = settlementInstance.Monthly_Expenses_Comments__c.replaceAll( '\\s+', ' ');
               monthlyExpensesComments = monthlyExpensesComments.replace('\n', '').replace('\r', ' ');
            }
             if(String.isNotBlank(settlementInstance.Monthly_Income_Comments__c)){
               monthlyIncomeComments = settlementInstance.Monthly_Income_Comments__c.replaceAll( '\\s+', ' ');
               monthlyIncomeComments= monthlyIncomeComments.replace('\n', '').replace('\r', ' ');
            }
            if(String.isNotBlank(settlementInstance.Total_Wealth_Comments__c)){
               totalWealthComments = settlementInstance.Total_Wealth_Comments__c.replaceAll( '\\s+', ' ');
               totalWealthComments= totalWealthComments.replace('\n', '').replace('\r', ' ');
            }
            if(String.isNotBlank(settlementInstance.Employment_Comments__c)){
               employmentCommment = employmentCommment.replace('\n', '').replace('\r', ' ');
               employmentCommment = settlementInstance.Employment_Comments__c.replaceAll( '\\s+', ' ');
            }
            if(String.isNotBlank(settlementInstance.HomeOwner_Status_Comments__c)){
               homeownerStatusComments = homeownerStatusComments.replace('\n', '').replace('\r', ' ');
               homeownerStatusComments = settlementInstance.HomeOwner_Status_Comments__c.replaceAll( '\\s+', ' ');
            }
             system.debug('employmentCommment:'+employmentCommment);
             system.debug('homeownerStatusComments:'+homeownerStatusComments);
            system.debug('commentReply:'+commentReply);
              settlemntJSONRequest = '{'+ 
           '"Name": "'+settlementInstance.Name+'",'+
           '"Comment_Reply": "'+commentReply+'",'+
           '"Proposal_Total_Percent": "'+settlementInstance.Proposal_Total_Percent__c+'",'+
           '"Proposal_Principal_Percent": "'+settlementInstance.Proposal_Principal_Percent__c+'",'+
           '"Monthly_Expenses_Comments": "'+monthlyExpensesComments+'",'+
           '"Monthly_Income_Comments": "'+monthlyIncomeComments+'",'+
           '"Employment_Comments": "'+employmentCommment+'",'+
           '"HomeOwner_Status_Comments": "'+homeownerStatusComments+'",'+
           '"Total_Wealth_Comments": "'+totalWealthComments+'",'; 
            for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
                if(mapping.Object_Name__c == 'Settlement'){
                    if(mapping.Field_Type__c != 'DateTime'){
                        settlemntJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                        settlementInstance.get(mapping.Field_API__c)+'\", ';    
                    }
                    else{
                        if(mapping.Field_Type__c == 'DateTime' && settlementInstance.get(mapping.Field_API__c) != NULL){
                            DateTime ss = DateTime.valueOf(settlementInstance.get(mapping.Field_API__c));
                            
                            String convertedDateTime = ss.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
                            system.debug('convertedDateTime::'+mapping.Field_JSON_Tag__c+convertedDateTime);
                            settlemntJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+
                            convertedDateTime+'\", ';  
                            
                        }        
                    }
                    
                    /*settlemntJSONRequest += '\"'+mapping.Field_JSON_Tag__c+ '\":"'+settlementInstance.get(mapping.Field_API__c)+'\", ';*/
                }
            }
            settlemntJSONRequest = settlemntJSONRequest.removeEnd(', ');
            settlemntJSONRequest += '}';
        
        }
        system.debug('settlemntJSONRequest: '+settlemntJSONRequest); 
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('settlemntJSONRequest: '+settlemntJSONRequest);
            req.setBody(settlemntJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFSettelment');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+settlementInstance.Settlement_Number__c);
            req.setMethod('PUT');           
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            settlementInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
    
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                settlementInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body:: '+res.getBody());
                if(res.getStatusCode() == 200
                && bodyMap.get('IsSuccess') == String.valueOf('true')){
                    system.debug(bodyMap.get('ReturnMessage'));
                }       
                else{
                    system.debug('Error Response');
                    system.debug(bodyMap.get('ReturnMessage'));
                    //Added by Nagendra - #4931
                    String userName = UserInfo.getName();
                    API_Error__c apiErrorData = New API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Request__c = req.getBody();             
                    apiErrorData.Response__c =res.getBody();                
                    listAPIErrors.add(apiErrorData);
                    
                    CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Response__c,apiErrorData.Action__c);
              //4931 - changes end
                }
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex);
                  //Added by Nagendra - #4931
                  String userName = UserInfo.getName();
                  API_Error__c apiErrorData = New API_Error__c();
                  apiErrorData.Action__c = 'API Failed';
                  apiErrorData.Request__c = req.getBody();     
                  apiErrorData.Error__c=settlementInstance.Settlement_Number__c +' '+'Record failed due to'+' '+ex.getMessage()+' '+ex.getStackTraceString();        
                 // apiErrorData.Response__c =res.getBody();                
                  listAPIErrors.add(apiErrorData);
                  
                  CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Response__c,apiErrorData.Action__c);
            //4931 - changes end
            }
            //Added if loop by Nagendra - #4931
            if(!listAPIErrors.isEmpty()){
                insert listAPIErrors;
            }
            
            if(settlementInstance != NULL){
                SettlementTriggerHandler.runSettlementTrigger = false;
                update settlementInstance;
                SettlementTriggerHandler.runSettlementTrigger = true;
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
        //Map<String, Object> resultMap = (Map<String, Object>) wResp.get('access_token');
        //system.debug('resultMap::'+resultMap);
        //system.debug('token'+resultMap.get('Token'));
        return String.valueOf(wResp.get('access_token'));
    }
    
}