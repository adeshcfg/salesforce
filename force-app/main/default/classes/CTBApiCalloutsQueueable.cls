public class CTBApiCalloutsQueueable implements Queueable, Database.AllowsCallouts{
    private Id contentVersionDataID;
    private List<sObject> listData;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public string batchName = '';
    public string fileNameFormat = '';
    
    public CTBApiCalloutsQueueable(Id cvID,List<sObject> Data,string CTBBatchName,string fileName) {
        //ContentVersion ID
        contentVersionDataID = cvID;
        //Retrive Data
        listData = Data;
        //Batch Name
        batchName = CTBBatchName;
        //File Name
        fileNameFormat = fileName;
    }
    
    public void execute(QueueableContext context) {
       system.debug('inside CTBApiCalloutsQueueable');
        Map<id,insolvency_account__c> insolAccMap = new Map<id,insolvency_account__c>();
        Map<id,Insolvency_Payment__c> insolPayMap = new Map<id,Insolvency_Payment__c>();
        String JSONRequest;
        List<id> errorList = new List<id>();
        //bild JSON to send the portal
        if(!listData.isEmpty()){
            //Create JSON request for customer update
            JSONRequest = '{'+ 
                '"RemoteId": "'+contentVersionDataID+'",'+
                '"FileName": "'+fileNameFormat+'",'+  
                '"FileType": "'+'SftpCtbNotification"' +
                '}';
            
            system.debug('JSONRequest@@'+JSONRequest);
            //Get access token for http request
            String accToken;
            accToken = AzureUtility.getRequestToken('Agency Portal API');
            if (accToken != '') {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                //req.setBody(JSONRequest);
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json');
                
                apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy');
                req.setMethod('POST');
                string apiUrl = apiCallDetails.PDF_API_URL__c + 'sobjects/' + contentVersionDataID + '/ctbsftpoutbox?name=' + fileNameFormat;
               	req.setEndpoint(apiUrl);
                system.debug('Outbound req body:: '+req.getBody());
				system.debug('Endpoint req body:: '+req.getEndpoint());
                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    system.debug('Status code: '+res.getStatusCode());
                    Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    system.debug('bodyMap: '+bodyMap);
                    system.debug('Outbound res.getBody() :: '+res.getBody());
                    String statusCode = String.valueOf(res.getStatusCode());
                    system.debug('statusCode: '+statusCode);
                    insolvency_account__c newInsolAccRec = new insolvency_account__c(); 
                    Insolvency_Payment__c newinsolPayRec = new Insolvency_Payment__c();
                    if(statusCode.startsWith('2')){
                           if(batchName == System.Label.CTB_Insolvency_Account){
                            //if we get success response then update insolvency account fields
                               for(insolvency_account__c insolAccData : (List<insolvency_account__c>)listData){
                                   newInsolAccRec.id = insolAccData.id;
                                   newInsolAccRec.Insolvency_Sub_Status__c = 'Sent on File';
                                   newInsolAccRec.CTB_Update_Filename__c = fileNameFormat;
                                   newInsolAccRec.CTB_Update_File_Timestamp__c = NULL;
                                   insolAccMap.put(newInsolAccRec.id,newInsolAccRec);
                               }
                           }
                           
                           if(batchName == System.Label.CTB_Payment){
                            //if we get success response then update insolvency account fields 
                               for(Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>)listData){
                                   newinsolPayRec.id = insolPayData.id;
                                   newinsolPayRec.Payment_Sub_Status__c = 'Sent on File';
                                   newinsolPayRec.CTB_Update_Filename__c = fileNameFormat;
                                   newinsolPayRec.CTB_Update_File_Timestamp__c = NULL;
                                   insolPayMap.put(newinsolPayRec.id,newinsolPayRec);
                               }
                           }
                       }       
                    else if(!statusCode.startsWith('2')){
                        if(batchName == System.Label.CTB_Insolvency_Account){
                            newInsolAccRec.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                            insolAccMap.put(newInsolAccRec.id,newInsolAccRec);
                            errorList.add(newInsolAccRec.id);
                        }
                        if(batchName == System.Label.CTB_Payment){
                            newinsolPayRec.Payment_Sub_Status__c = 'File Error Parsing Record';
                            insolPayMap.put(newinsolPayRec.id,newinsolPayRec);
                        }
                        //if we get error response then maintain error log
                        String response = '';
                        if(res.getBody().length() > 131071){
                            response =res.getBody().subString(0,131071);
                        }else{
                            response =res.getBody();
                        }
                        
                        CTBFileGenerator.exceptionHandling(response,NULL,NULL,insolPayMap.values(),batchName);
                    	CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(),response,'Error Response');
                    }
                }
                catch(Exception ex){
                    system.debug('Exception class'+ex);
                    system.debug('exceptionline::'+ex.getStackTraceString());
                    Map<id,sObject> errorMap = new Map<id,sObject>();
                    if(batchName == System.Label.CTB_Insolvency_Account){
                        for(insolvency_account__c insolAccData : (List<insolvency_account__c>)listData){
                            insolAccData.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                            errorList.add(insolAccData.id);
                            errorMap.put(insolAccData.id,insolAccData);
                        }
                    }
                    if(batchName == System.Label.CTB_Payment){
                        for(Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>)listData){
                            insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                            errorList.add(insolPayData.id);
                            errorMap.put(insolPayData.id,insolPayData);
                        }
                    }
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(ex.getMessage(),ex.getStackTraceString(),NULL,errorMap.values(),batchName);
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(),ex.getStackTraceString(),'CTB API Failed');
                }
                try{
                    if (!insolAccMap.values().isEmpty()) {
                        update insolAccMap.values();
                    }
                    if (!insolPayMap.values().isEmpty()) {
                        update insolPayMap.values();
                    }
                }catch(DMLException dmlEx){
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(dmlEx.getDMLMessage(0),dmlEx.getStackTraceString(),dmlEx.getDmlId(0),null,batchName); 
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(),dmlEx.getStackTraceString(),'Record update Failed');
                }
            }
        }
    }

}