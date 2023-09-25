/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update Judgment Record from 
*            Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 17/01/2022

*************************************************************************************************/
public class PortalJudgmentProcessingAPI {
    
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    
    public static Map<String, Agency_Portal_Fields_Mapping__c> JobCodeMap = Agency_Portal_Fields_Mapping__c.getAll();
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    public static map<String, Agency_Portal_Fields_Mapping__c> mapAgencyField = Agency_Portal_Fields_Mapping__c.getAll();
    public static map<String, object> mapAgencyJudgFieldData = new map<String, object>();

    @future (callout=true)
    public static void processJudgment(ID judgmentId){ 
                                 
        String Query = 'SELECT ID, ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Judgment'){
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        Query = Query.removeEnd(', ');
        system.debug('Query after:'+Query);
        Query+= ' FROM Judgment__c WHERE ID=: judgmentId';
        system.debug('Query: '+Query);
        list<Judgment__c> listJudgment= Database.query(Query);
        system.debug('listJudgment: '+listJudgment); 
                                    
        String JudgmentJSONRequest;
        Judgment__c judgmentInstance;
        if(!listJudgment.isEmpty()){
            //Create JSON request for customer update
            judgmentInstance = listJudgment[0];
            system.debug('judgmentInstance '+judgmentInstance);
            for(Agency_Portal_Fields_Mapping__c agencyFieldData : mapAgencyField.values()){
                if(agencyFieldData.Object_Name__c == 'Judgment'){
                    mapAgencyJudgFieldData.put(agencyFieldData.Field_JSON_Tag__c, judgmentInstance.get(agencyFieldData.Field_API__c));
                }
            }
            JudgmentJSONRequest = JSON.serialize(mapAgencyJudgFieldData);
            
        }
        system.debug('JudgmentJSONRequest: '+JudgmentJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('JudgmentJSONRequest: '+JudgmentJSONRequest);
            req.setBody(JudgmentJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFJudgement');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+judgmentInstance.Judgment_Number__c);
            req.setMethod('PUT');
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            judgmentInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
   
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                judgmentInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body:: '+res.getBody());
                if(res.getStatusCode() == 200
                   && bodyMap.get('IsSuccess') == String.valueOf('true')){
                       system.debug(bodyMap.get('ReturnMessage'));
                   }       
                else{
                    String userName = UserInfo.getName();
                    API_Error__c apiErrorData = New API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Request__c = judgmentInstance.name;
                    if(res.getBody().length() > 131071){
                                
                        apiErrorData.Response__c =res.getBody().subString(0,131071);
                    }else{
                        apiErrorData.Response__c =res.getBody();
                    }
                    listAPIErrors.add(apiErrorData);
                    
                    CFG_EmailNotification.snapshotFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Error__c,apiErrorData.Action__c);
                    system.debug(bodyMap.get('ReturnMessage'));
                }
            }
            catch(Exception ex){
                String userName = UserInfo.getName();
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = ex.getMessage();
                apiErrorData.Action__c = 'API Failed';
                apiErrorData.Request__c = judgmentInstance.name;
                listAPIErrors.add(apiErrorData);
                
                CFG_EmailNotification.snapshotFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Error__c,apiErrorData.Action__c);
            }

            insert listAPIErrors;

            if(judgmentInstance != NULL){
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                update judgmentInstance;
                JudgmentTriggerHandler.runJudgmentTrigger = true;
            }
        }
    }
    
    //Get Access Token
    public static string getRequestToken() {
        String bodyParams = '';
        Map<String, Object> wResp;
        try{
            system.debug('apiCallDetails: '+apiCallDetails);
            String dptenandId = apiCallDetails.Tenand_ID__c;
            String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
            String dpapiClientClientId = apiCallDetails.Client_ID__c;
            String dpapiClientSecret = apiCallDetails.Client_Secret__c;
            String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
            String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
            
            authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
            system.debug('authorizationtUrl changed: '+authorizationtUrl);
            bodyParams =  'client_id='+dpapiClientClientId;
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
            wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
            system.debug('wResp: '+wResp.get('access_token'));
            
        }
        catch(Exception ex){
            String userName = UserInfo.getName();
            API_Error__c apiError = New API_Error__c();
            apiError.Error__c = ex.getMessage();
            apiError.Action__c = 'Access Token';
            apiError.Response__c = bodyParams;
            listAPIErrors.add(apiError); 
            CFG_EmailNotification.snapshotFailedEmailNotifyTOCFGSupport(userName,apiError.Error__c,apiError.Action__c);
        }
        insert listAPIErrors;
        return String.valueOf(wResp.get('access_token'));
    }
    
}