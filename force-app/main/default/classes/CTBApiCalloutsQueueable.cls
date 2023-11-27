public class CTBApiCalloutsQueueable implements Queueable, Database.AllowsCallouts{
    private Id contentVersionDataID;
    private List<sObject> listData;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public string batchName = '';
    public string fileNameFormat = '';
    
    public CTBApiCalloutsQueueable(Id cvID,List<sObject> Data,string CTBBatchName,string fileName) {
        contentVersionDataID = cvID;
        listData = Data;
        batchName = CTBBatchName;
        fileNameFormat = fileName;
    }
    
    public void execute(QueueableContext context) {
       system.debug('inside CTBApiCalloutsQueueable');
        List<insolvency_account__c> insolAccList = new List<insolvency_account__c>();
        String JSONRequest;
        if(!listData.isEmpty()){
            //Create JSON request for customer update
            if(batchName == System.Label.CTB_Insolvency_Account){
                JSONRequest = '{'+ 
                '"RemoteId": "'+contentVersionDataID+'",'+
                '"FileName": "'+fileNameFormat+'",'+  
                '"FileType": "'+'SftpCtbNotification"' +
                '}';
            }
            system.debug('JSONRequest@@'+JSONRequest);
            //Get access token for http request
            String accToken;
            accToken = getRequestToken();
            if (accToken != '') {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setBody(JSONRequest);
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFComplain');
                //req.setEndpoint(apiCallDetails.PDF_API_URL__c+complaintInstance.Task_Number__c);
                req.setMethod('PUT');
                system.debug('Outbound req body:: '+req.getBody());

                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    system.debug('Status code: '+res.getStatusCode());
                    Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    system.debug('Outbound res.getBody() :: '+res.getBody());
                    String statusCode = String.valueOf(res.getStatusCode());
                    if(statusCode.startsWith('2')
                       && bodyMap.get('IsSuccess') == true){
                           if(batchName == System.Label.CTB_Insolvency_Account){
                               insolvency_account__c newInsolAccRec = new insolvency_account__c(); 
                               for(insolvency_account__c insolAccData : (List<insolvency_account__c>)listData){
                                   newInsolAccRec.id = insolAccData.id;
                                   newInsolAccRec.Insolvency_Sub_Status__c = 'Sent on File';
                                   newInsolAccRec.CTB_Update_Filename__c = fileNameFormat;
                                   newInsolAccRec.CTB_Update_File_Timestamp__c = NULL;
                                   insolAccList.add(newInsolAccRec);
                               }
                           }
                       }       
                    else if(!statusCode.startsWith('2')){
                        String response = '';
                        if(res.getBody().length() > 131071){
                            
                            response =res.getBody().subString(0,131071);
                        }else{
                            response =res.getBody();
                        }
                        CTBFileGenerator.exceptionHandling(response,NULL,NULL);
                    	CFG_EmailNotification.apiFailedEmailNotify(response,'Error Response');
                    }
                }
                catch(Exception ex){
                    system.debug('Exception class'+ex);
                    system.debug('exceptionline::'+ex.getStackTraceString());
                    CTBFileGenerator.exceptionHandling(ex.getMessage(),ex.getStackTraceString(),NULL);
                    CFG_EmailNotification.apiFailedEmailNotify(ex.getMessage(),'API Failed');
                }
                try{
                    if(insolAccList != NULL && insolAccList.size() > 0){
                        update insolAccList;
                    }
                }catch(DMLException dmlEx){
                    CTBFileGenerator.exceptionHandling(dmlEx.getDMLMessage(0),dmlEx.getStackTraceString(),dmlEx.getDmlId(0)); 
                    CFG_EmailNotification.apiFailedEmailNotify(dmlEx.getDMLMessage(0),'Record update Failed');
                }
            }
            
            
        }
    }
    
    //Get Access Token
    public static string getRequestToken() {
        system.debug('apiCallDetails: '+apiCallDetails);
        String bodyParams = '';
        Map<String, Object> wResp;
        try{
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
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
            CTBFileGenerator.exceptionHandling(ex.getMessage(),ex.getStackTraceString(),NULL);
            CFG_EmailNotification.apiFailedEmailNotify(ex.getMessage(),'Access Token');
        }
        return String.valueOf(wResp.get('access_token'));
    }

}