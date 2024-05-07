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
        if(!listData.isEmpty()){
            //Get access token for http request
            String accToken;
            accToken = AzureUtility.getRequestToken('Agency Portal API');
            if (accToken != '') {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json');
                
                apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy');
                req.setMethod('POST');
                string apiUrl = apiCallDetails.PDF_API_URL__c + 'sobjects/' + contentVersionDataID + '/ctbsftpoutbox?name=' + fileNameFormat;
               	req.setEndpoint(apiUrl);

				system.debug('Endpoint req body:: '+req.getEndpoint());
                Map<id,sobject> mapRecordUpdate = new Map<id,sobject>();
                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    system.debug('Status code: '+res.getStatusCode());
                    String statusCode = String.valueOf(res.getStatusCode());
                    system.debug('statusCode: '+statusCode);
                    
                    Insolvency_Payment__c newinsolPayRec = new Insolvency_Payment__c();
  					//update processing sub status based on portal response
                    mapRecordUpdate = populateProcessingSubStatus(batchName,statusCode,listData,fileNameFormat);   
                    if(!statusCode.startsWith('2')){
                        //if we get error response then maintain error log
                        String response = '';
                        if(res.getBody().length() > 131071){
                            response =res.getBody().subString(0,131071);
                        }else{
                            response =res.getBody();
                        }
                        
                        CTBFileGenerator.exceptionHandling(response,NULL,NULL,mapRecordUpdate.values(),batchName);
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
                            errorMap.put(insolAccData.id,insolAccData);
                        }
                    }
                    if(batchName == System.Label.CTB_Payment){
                        for(Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>)listData){
                            insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                            errorMap.put(insolPayData.id,insolPayData);
                        }
                    }
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(ex.getMessage(),ex.getStackTraceString(),NULL,errorMap.values(),batchName);
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(),ex.getStackTraceString(),'CTB API Failed');
                }
                try{
                    
                    if (!mapRecordUpdate.values().isEmpty()) {
                        update mapRecordUpdate.values();
                    }
                }catch(DMLException dmlEx){
                    Map<id, sObject> insolvAcctErrorListMap = new Map<id, sObject>();
                    system.debug('Exception class'+dmlEx.getDMLMessage(0));
                    system.debug('getStackTraceString class'+dmlEx.getStackTraceString());
                    system.debug('getDmlId class'+dmlEx.getDmlId(0));
                    if(batchName == System.Label.CTB_Insolvency_Account){
                        insolvency_account__c insolAccError = new insolvency_account__c();
                        insolAccError.id = dmlEx.getDmlId(0);
                        insolAccError.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                        insolAccError.Error_Message__c = dmlEx.getStackTraceString();
                        insolvAcctErrorListMap.put(insolAccError.id, insolAccError);
                    }
                    if(batchName == System.Label.CTB_Payment){
                        Insolvency_Payment__c insolPayError = new Insolvency_Payment__c();
                        insolPayError.id = dmlEx.getDmlId(0);
                        insolPayError.Payment_Sub_Status__c = 'File Error Parsing Record';
                        insolvAcctErrorListMap.put(insolPayError.id, insolPayError);
                    }
                    
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(dmlEx.getDMLMessage(0),dmlEx.getStackTraceString(),dmlEx.getDmlId(0),null,batchName); 
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getName(),dmlEx.getStackTraceString(),'Record update Failed');
                    system.debug('above if');
                    try{
                        if(insolvAcctErrorListMap != null && !insolvAcctErrorListMap.isEmpty()) {
                            update insolvAcctErrorListMap.values();
                        }
                    }catch(DMLException ex){
                        system.debug('Exception class'+ex.getDMLMessage(0));
                        system.debug('getDmlId class'+ex.getDmlId(0));
                    }
                    
                }
            }
        }
    }
    
    public Map<id,sObject> populateProcessingSubStatus(string batchName,string statusCode,List<sObject> listData,string fileNameFormat){
        Map<id,sObject> insolAccAndPaymentMap = new Map<id,sObject>();
        if(batchName == System.Label.CTB_Insolvency_Account){   
            //if we get success response then update insolvency account fields
            for(insolvency_account__c insolAccData : (List<insolvency_account__c>)listData){
                insolvency_account__c newInsolAccRec = new insolvency_account__c(); 
                if(statusCode.startsWith('2')){
                    newInsolAccRec.id = insolAccData.id;
                    newInsolAccRec.Insolvency_Sub_Status__c = 'Sent on File';
                    newInsolAccRec.CTB_Update_Filename__c = fileNameFormat;
                    newInsolAccRec.CTB_Update_File_Timestamp__c = NULL;
                    insolAccAndPaymentMap.put(newInsolAccRec.id,newInsolAccRec);
                }else{
                    newInsolAccRec.id = insolAccData.id;
                    newInsolAccRec.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    insolAccAndPaymentMap.put(newInsolAccRec.id,newInsolAccRec);
                }
            }
        }
        
        if(batchName == System.Label.CTB_Payment){
            //if we get success response then update insolvency account fields 
            for(Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>)listData){
                Insolvency_Payment__c newinsolPayRec = new Insolvency_Payment__c();
                if(statusCode.startsWith('2')){
                    newinsolPayRec.id = insolPayData.id;
                    newinsolPayRec.Payment_Sub_Status__c = 'Sent on File';
                    newinsolPayRec.CTB_Update_Filename__c = fileNameFormat;
                    newinsolPayRec.CTB_Update_File_Timestamp__c = NULL;
                    insolAccAndPaymentMap.put(newinsolPayRec.id,newinsolPayRec);
                }else{
                    newinsolPayRec.id = insolPayData.id;
                    newinsolPayRec.Payment_Sub_Status__c = 'File Error Parsing Record';
                    insolAccAndPaymentMap.put(newinsolPayRec.id,newinsolPayRec);
                }
            }
        } 
        return insolAccAndPaymentMap;
    }

}