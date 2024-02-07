/**************************************************************************************************
*
* Class: AzureUtility
*
* @description : get access token and call the allocation and account status update API based on document type.  
* @author : A5E Consulting
* @date : 10/03/2023
* Test Class: TestDisplayProductAllocStagController,TestPortalJudgmentProcessingAPI,TestUpdateAmountPastDueController

*************************************************************************************************/
public class AzureUtility {
	public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public static String accTokenBulk;
	public static String allocate = 'Product Allocation File';
    public static String recall = 'Account Status Update File';
    public static List<API_Error__c> ErrorList = new List<API_Error__c>();
    
    //Call allocation/account status update API based in document type.
    public static String apiCall(List<String> listProductJSONRequest1, string docType){
        accTokenBulk = getRequestToken();
        
        for(String ProductJSONRequest : listProductJSONRequest1){
            //Get access token for http request
            if (accTokenBulk != '') {
                // Instantiate a new http object
                Http h = new Http();
                // Instantiate a new HTTP request
                HttpRequest req = new HttpRequest();
                req.setBody(ProductJSONRequest);
                system.debug('req body'+req.getBody());
                req.setHeader('Authorization', 'Bearer ' + accTokenBulk);
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                if(docType == allocate){
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFProduct');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c+'bulk');
                    req.setMethod('PUT');
                }else if(docType == recall){
                    apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFBulkProductUpdate');
                    req.setEndpoint(apiCallDetails.PDF_API_URL__c+'bulk');
                    req.setMethod('PATCH');
                }
                
                system.debug('req endpoint:: '+req.getEndpoint());
                system.debug('req body:: '+req.getBody());
                //productInstance.Outbound_API_Request_Body__c = req.getBody();
                system.debug('Outbound req body:: '+req.getBody());
                system.debug('req:: '+req);
                
                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    //productInstance.Outbound_API_Response_Body__c = res.getBody();
                    system.debug('Outbound res body1111::' +res.getBody());
                    system.debug('res.getStatusCode()' +res.getStatusCode());
                    if(res.getStatusCode() == 200 && !Test.isRunningTest()){
                        system.debug(bodyMap.get('ReturnMessage'));
                    }       
                    else{
                        try{
                            API_Error__c apiError = new API_Error__c();  
                            apiError.End_Point__c ='Bulk API';
                            if(req.getBody().length() > 131071){
                                apiError.Request__c = req.getBody().subString(0,131071);
                                
                            }else{
                                apiError.Request__c = req.getBody();
                            }
                            if(res.getBody().length() > 131071){
                                
                                apiError.Response__c =res.getBody().subString(0,131071);
                            }else{
                                apiError.Response__c =res.getBody();
                            }
                            
                            ErrorList.add(apiError);
                        }catch(Exception ex){
                            system.debug('exception ex: '+ex);
                            
                            
                        }
                        
                    }
                }
                catch(Exception ex){
                    system.debug('exception ex: '+ex);
                    
                    
                }
                
            }
        }
        if(!ErrorList.isEmpty()){
            insert ErrorList;
        }
        
        return null;
    }
    
    //Get Access Token
    public static string getRequestToken(){
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        String bodyParams =  'client_id='+dpapiClientClientId;
        bodyParams =  bodyParams+'&client_secret='+dpapiClientSecret;
        bodyParams =  bodyParams+'&scope='+apiCallDetails.Scope_Prefix__c+dpapiProxyClientId+apiCallDetails.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
       
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        
        system.debug('req: '+req);
        HttpResponse hresp;
        if(!test.isRunningTest()){
            hresp = h.send(req);
            Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
            system.debug('wResp: '+wResp.get('access_token'));
            return String.valueOf(wResp.get('access_token'));
        }else{
            return null;
        }
    }
    
    public static string getRequestToken(API_Call_Details__c apiCallDetails){
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        String bodyParams =  'client_id='+dpapiClientClientId;
        bodyParams =  bodyParams+'&client_secret='+dpapiClientSecret;
        bodyParams =  bodyParams+'&scope='+apiCallDetails.Scope_Prefix__c+dpapiProxyClientId+apiCallDetails.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        system.debug('bodyParams'+bodyParams);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(authorizationtUrl);
        
        system.debug('req: '+req);
        HttpResponse hresp;

        hresp = h.send(req);
        system.debug('hresp: '+hresp);
        Map<String, Object> wResp = (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        system.debug('wResp: '+wResp.get('access_token'));
        return String.valueOf(wResp.get('access_token'));
    }
    
    public static string getRequestToken(string apiName){
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance(apiName);
        
        return getRequestToken(apiCallDetails);
    }
    
    public static String apiCallToPortal(string apiName,List<String> JSONRequestList, string replacePdfApiUrl,
                                        List<sobject> objectInstance, string portalApiCall){
       Judgment__c judInstanceData;
       String name ='';     
       String endPoint = '';                                     
       if(portalApiCall == 'Judgment'){
           for(Judgment__c judInstance : (List<Judgment__c>)objectInstance){
               name = judInstance.name;
               endPoint = judInstance.Judgment_Number__c;
               judInstance.Outbound_API_Request_Body__c = JSONRequestList[0];
               judInstanceData = judInstance;
           }                                 
       }                                          
       String accToken = getRequestToken(apiName); 
        // Instantiate a new http object
        for(String JSONRequest : JSONRequestList){
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setBody(JSONRequest);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', replacePdfApiUrl);
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+endPoint);
            req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
            req.setMethod('PUT');
            
            system.debug('outbbound request'+req.getBody());
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if(portalApiCall == 'Judgment'){
                    judInstanceData.Outbound_API_Response_Body__c = res.getBody();
                }
                
                String statusCode = String.valueOf(res.getStatusCode());
                if(statusCode.startsWith('2')
                   && bodyMap.get('IsSuccess') == String.valueOf('true')){
                   }       
                else if(!statusCode.startsWith('2')){
                    String userName = UserInfo.getName();
                    API_Error__c apiErrorData = New API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Request__c = name;
                    if(res.getBody().length() > 131071){
                        
                        apiErrorData.Response__c =res.getBody().subString(0,131071);
                    }else{
                        apiErrorData.Response__c =res.getBody();
                    }
                    ErrorList.add(apiErrorData);
                    
                    CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Response__c,apiErrorData.Action__c);
                }
            }
            catch(Exception ex){
                String userName = UserInfo.getName();
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = ex.getMessage();
                apiErrorData.Action__c = 'API Failed';
                if(!Test.isRunningTest()){
                    apiErrorData.Request__c = name;
                }
                ErrorList.add(apiErrorData);
                
                CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Error__c,apiErrorData.Action__c);
            }
            
            insert ErrorList;
            if(judInstanceData != NULL){
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                update judInstanceData;
                JudgmentTriggerHandler.runJudgmentTrigger = true;
            }
        }
        return null;
    }
    
}