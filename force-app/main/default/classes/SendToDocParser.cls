/**************************************************************************************************
*
*  Class:   
*
*  @description : This class will send the Creditor's Package to DocParser to create Insolvency
*  @author : A5E Consulting
*  @date : 05/30/2018   
*
*************************************************************************************************/
public Class SendToDocParser{

    /*public Application_Config_Settings__c appConSet{get; set;}
    public Boolean error{get;set;}
    public String errorMessage{get;set;}
    public Case caseRecord{get;set;}
    public Attachment attach{get;set;}
    public EmailMessage emailMsg{get;set;}
    public String strParserId{get;set;}
    public String strApiKey{get;set;}
    public String strTargetURL{get;set;}
    public Boolean manualProcess{get;set;}
    */
    
    /*public sendToDocParser(){
        appConSet = Application_Config_Settings__c.getOrgDefaults();
        List<Domain_Name_Parser__c> domPar = Domain_Name_Parser__c.getall().values();
        //String caseID = ApexPages.currentPage().getParameters().get('id');
        
        //Intialize variables
        caseRecord = new Case();
        attach = new Attachment();
        emailMsg = new EmailMessage();
        strParserID = null;
        strApiKey = '';
        strTargetURL = '';
        error = false;
        errorMessage = '';
        
        caseRecord = [select id, Document_ID__c, status, Assigned_To__c from case where id =: caseID];
        attach = [select id, name, body from Attachment where ParentID in (select id from EmailMessage where RelatedToId =: caseID ) limit 1];
        emailMsg = [select id, FromAddress from EmailMessage where RelatedToId =: caseID limit 1];
        
        caseRecord.Assigned_To__c = UserInfo.getUserId();
        
        
        if(caseRecord.status == 'New'){
            error = true;
            errorMessage += 'Case is not accepted. Please accept the Case\n';
        }
        
        if((caseRecord.status == 'Completed' || caseRecord.status == 'DocParser Processing') && caseRecord.document_id__c <> null){
            error = true;
            errorMessage += 'Document is already sent to the Parser\n';
        }
        
        String emailAddress = emailMsg.FromAddress;
        String domainName = emailAddress.split('@').get(1);
        //String strParserId;
        for(Domain_Name_Parser__c dnp : domPar){
            if(dnp.Domain_Name__c == domainName){
                strParserId = dnp.Parser_Name__c;
            }
        }
        
        if(strParserId == null){
            manualProcess = true;
            //manualProcessMessage = 'Need to Process this record Manually';
        }
        // change the following variables according to your use-case
        strApiKey = appConSet.Doc_Parser_API_Key__c;//'7146d1c4f964579e9faa36c112b2035e3d965a03';
        //String strParserId = appConSet.Doc_Parser_ID_E1__c;//'sgsaenoqjtbu';
        
        strTargetURL = appConSet.Target_URL_for_Insolvency__c;//'https://api.docparser.com/v1/document/upload/' + strParserId + '?remote_id='+strId;
        strTargetURL = strTargetURL + strParserId + '?remote_id='+caseID;
        

    }*/
    
    @future(callout=true)
    public static void sendDoc(List<ID> listID, String differentParser){
        
        Application_Config_Settings__c appConSet = Application_Config_Settings__c.getOrgDefaults();
        List<Domain_Name_Parser__c> domPar = Domain_Name_Parser__c.getall().values();
        List<French_Domain_Name_Parser__c> domFrePar = French_Domain_Name_Parser__c.getall().values();
        
        for(ID strId : listID){
            
            //Declaration and Intialize variables
            Case caseRecord = new Case();
            List<Attachment> attach = new List<Attachment>();
            List<EmailMessage> emailMsg = new List<EmailMessage>();
            String strParserID = null;
            String strApiKey = '';
            String strTargetURL = '';
            Boolean manualProcess = false;
            //error = false;
            String errorMessage = '';
            
            try{
                caseRecord = [select id, Document_ID__c, status, Assigned_To__c, SuppliedEmail from case where id =: strId];
                emailMsg = [select id, FromAddress from EmailMessage where RelatedToId =: strId];
                
                if(emailMsg.size() > 0){
                    attach = [select id, name, body from Attachment where ParentID = :emailMsg[0].id ];
                }else{
                    attach = [select id, name, body from Attachment where ParentID = :strId];
                }
                caseRecord.Assigned_To__c = UserInfo.getUserId();
                
                String emailAddress = caseRecord.SuppliedEmail;
                String domainName = emailAddress.split('@').get(1);
                //String strParserId;
                if(differentParser == 'English'){
                for(Domain_Name_Parser__c dnp : domPar){
                    if(dnp.Domain_Name__c == domainName){
                        strParserId = dnp.Parser_Name__c;
                    }
                }
                }else if(differentParser == 'French'){
                    for(French_Domain_Name_Parser__c fnp : domFrePar){
                        if(fnp.Domain_Name__c == domainName){
                            strParserId = fnp.Parser_Name__c;
                        }
                    }
                    //strParserId = appConSet.French_Parser_ID__c;
                }
                
                if(strParserId == null){
                    manualProcess = true;
                    //manualProcessMessage = 'Need to Process this record Manually';
                }
                // change the following variables according to your use-case
                strApiKey = appConSet.Doc_Parser_API_Key__c;//'7146d1c4f964579e9faa36c112b2035e3d965a03';
                //String strParserId = appConSet.Doc_Parser_ID_E1__c;//'sgsaenoqjtbu';
                
                strTargetURL = appConSet.Target_URL_for_Insolvency__c;//'https://api.docparser.com/v1/document/upload/' + strParserId + '?remote_id='+strId;
                strTargetURL = strTargetURL + strParserId + '?remote_id='+strId;
                
                if(manualProcess == true){
                    caseRecord.status = 'Manually Process';
                    //errorMessage = 'This Document can not be parsed, Need to process it manually';
                    
                    CaseTriggerHandler.runCaseTrigger = false;
                    update caseRecord;
                    CaseTriggerHandler.runCaseTrigger = true;
                    
                    //return null;
                }
                if(manualProcess == false){
                    String strSeparationKey = 'A_RANDOM_STRING';
                    
                    // assemble the body payload
                    String strHeader = '--' + strSeparationKey + '\nContent-Disposition: form-data; name="file"; filename="' + attach[0].Name + '"\nContent-Type: application/octet-stream\n\n';
                    String strBody = EncodingUtil.base64Encode(attach[0].Body);
                    String strFooter = '\n--' + strSeparationKey + '--';
                    
                    String strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n'));
                    while(strHeaderEncoded.endsWith('=')) {
                        strHeader+=' ';
                        strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader+'\n'));
                    }
                    String strBodyEncoded = strBody;
                    String strFooterEncoded = EncodingUtil.base64Encode(Blob.valueOf(strFooter));
                    
                    Blob blobBody = null;
                    String last4Bytes = strBodyEncoded.substring(strBodyEncoded.length()-4,strBodyEncoded.length());
                    
                    if(last4Bytes.endsWith('=')) {
                        Blob decoded4Bytes = EncodingUtil.base64Decode(last4Bytes);
                        HttpRequest objHttpRequest = New HttpRequest();
                        objHttpRequest.setBodyAsBlob(decoded4Bytes);
                        String last4BytesFooter = objHttpRequest.getBody()+strFooter;
                        blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded.substring(0,strBodyEncoded.length()-4)+EncodingUtil.base64Encode(Blob.valueOf(last4BytesFooter)));
                    } else {
                        blobBody = EncodingUtil.base64Decode(strHeaderEncoded+strBodyEncoded+strFooterEncoded);
                    }
                    
                    if(blobBody.size()>3000000) {
                        // throw new CustomException('File size limit is 3 MBytes');
                        system.debug('File size limit is 3 MBytes');
                    }else{
                        system.debug('blobBody.size()'+blobBody.size());
                    }
                    
                    
                    try{
                        // send out the request
                        HttpRequest req = New HttpRequest();
                        req.setHeader('Content-Type', 'multipart/form-data; boundary=' + strSeparationKey);
                        req.setHeader('Authorization', 'Basic ' + strApiKey);
                        req.setMethod('POST');
                        system.debug('strTargetURL' + strTargetURL);
                        req.setEndpoint(strTargetURL);
                        req.setBodyAsBlob(blobBody);
                        req.setHeader('Content-Length', String.valueof(req.getBodyAsBlob().size()));
                        system.debug('req : ' + req);
                        Http http = New Http();
                        HTTPResponse res = http.send(req);
                        system.debug('res'+res.getBody());
                        
                        JSONParser parser = JSON.createParser(res.getBody());
                        
                        String documentID = null;
                        CaseComment addCom = new CaseComment();
                        //CommentBody=t.CommentBody, ParentId=mapCase.get(t.ParentId).id, isPublished=TRUE
                        while (parser.nextToken() != null) {
                            
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
                                // Get the value.
                                parser.nextToken();
                                //get Document ID value
                                documentID = parser.getText();
                                caseRecord.Document_ID__C = documentID;
                                caseRecord.status = 'DocParser Processing';
                                caseRecord.Parser_Sent_DateTime__c = system.now();
                                break;
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'errorCode')) {
                                // Get the value.
                                parser.nextToken();
                                //get Document ID value
                                //error = true;
                                errorMessage += parser.getText();
                                caseRecord.status = 'Manually Process';
                                addCom.CommentBody = errorMessage;
                                addCom.ParentID = caseRecord.id;
                                break;
                            }
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message')) {
                                // Get the value.
                                parser.nextToken();
                                //get Document ID value
                                //error = true;
                                errorMessage += parser.getText();
                                caseRecord.status = 'Manually Process';
                                addCom.CommentBody = errorMessage;
                                addCom.ParentID = caseRecord.id;
                                break;
                            }
                        }
                        
                        if(addCom.ParentID <> null){
                            addCom.isPublished = TRUE;
                            insert addCom;
                        }
                        CaseTriggerHandler.runCaseTrigger = false;
                        caseRecord.Creditor_s_Pack_Language__c = differentParser;
                        update caseRecord;
                        CaseTriggerHandler.runCaseTrigger = true;
                    }catch(Exception e){
                        System.debug('An exception occurred: ' + e.getMessage());
                        CaseComment addCom = new CaseComment();
                        addCom.CommentBody = e.getMessage();
                        addCom.ParentID = caseRecord.id;
                        insert addCom;
                        
                        caseRecord.status = 'System Error';
                        caseRecord.Creditor_s_Pack_Language__c = differentParser;
                        CaseTriggerHandler.runCaseTrigger = false;
                        update caseRecord;
                        CaseTriggerHandler.runCaseTrigger = True;
                        
                        /*
                        Messaging.SingleEmailMessage eMsg = new Messaging.SingleEmailMessage();
                        User internalUser = [select id from User where name = 'Canaccede API' limit 1];
                        eMsg.setTargetObjectId(internalUser.id);
                        //must be false if sending to internal user    
                        eMsg.saveAsActivity = false; 
                        eMsg.setTreatTargetObjectAsRecipient(True);
                        eMsg.setSenderDisplayName('Canaccede API');  
                        eMsg.setSubject('Exception in SendtoDocParser class');  
                        eMsg.setBccSender(false);  
                        eMsg.setUseSignature(false);  
                        eMsg.setPlainTextBody(''+ e.getMessage());  
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {eMsg});
                        */
                    }
                }
            }catch(Exception e){
                System.debug('An exception occurred: ' + e.getMessage());
                CaseComment addCom = new CaseComment();
                addCom.CommentBody = e.getMessage();
                addCom.ParentID = caseRecord.id;
                insert addCom;
                
                caseRecord.status = 'System Error';
                CaseTriggerHandler.runCaseTrigger = false;
                update caseRecord;
                CaseTriggerHandler.runCaseTrigger = True;
                
                /*
                Messaging.SingleEmailMessage eMsg = new Messaging.SingleEmailMessage();
                User internalUser = [select id from User where name = 'Canaccede API' limit 1];
                eMsg.setTargetObjectId(internalUser.id);
                //must be false if sending to internal user    
                eMsg.saveAsActivity = false; 
                eMsg.setTreatTargetObjectAsRecipient(True);
                eMsg.setSenderDisplayName('Canaccede API');  
                eMsg.setSubject('Exception in SendtoDocParser class');  
                eMsg.setBccSender(false);  
                eMsg.setUseSignature(false);  
                eMsg.setPlainTextBody(''+ e.getMessage());  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {eMsg});
                */
                
            }finally{
                if(caseRecord.parentID == null){
                    CaseComment addCom = new CaseComment();
                    addCom.CommentBody = attach[0].name + ' has been processed';
                    addCom.ParentID = caseRecord.id;
                    insert addCom;
                }else{
                    CaseComment addCom = new CaseComment();
                    addCom.CommentBody = attach[0].name + ' has been processed';
                    addCom.ParentID = caseRecord.parentID;
                    insert addCom;
                }
            }
        }
        
    }
}