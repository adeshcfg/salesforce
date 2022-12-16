/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex class that takes Document ID as input and fetch JSON from DocParser and create Insolvency Account
*  @author : A5E Consulting
*  @date : 22/06/2018

*************************************************************************************************/
public Class InsolvencyAccountCreationFuture{
    
    @future(callout=true)
    public static void SendPDFtoParser(String documentID){
        
        Application_Config_Settings__c appConSet = Application_Config_Settings__c.getOrgDefaults();
        String strTargetURL = appConSet.Target_URL_for_DataFetch__c;//'https://api.docparser.com/v1/document/upload/' + strParserId + '?remote_id='+strId;
        //Id unknownBankRecordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Unknown Bank' and sObjectType = 'Insolvency_Account__c'].id;
        
        List<Domain_Name_Parser__c> domPar = Domain_Name_Parser__c.getall().values();
        List<French_Domain_Name_Parser__c> domFrePar = French_Domain_Name_Parser__c.getall().values();
        String strSeparationKey = 'A_RANDOM_STRING';
        
        // change the following variables according to your use-case
        String strApiKey = appConSet.Doc_Parser_API_Key__c;//'7146d1c4f964579e9faa36c112b2035e3d965a03';
        Case caseRecord = new Case();
        
        String remoteID = documentID;
        try{
            List<Insolvency__C> insol = [select id, name, document_id__c, createdDate from Insolvency__c where Remote_ID__c = :remoteID]; //Document_ID__c =: documentID];
            caseRecord = [select id, Document_ID__c, status, parentID, SuppliedEmail, Creditor_s_Pack_Language__c, createdDate from case where Id =: remoteID];
            List<EmailMessage> emailMsg = [select id, FromAddress from EmailMessage where RelatedToId =: caseRecord.ID limit 1];
            List<Attachment> attach = new List<Attachment>();
            
            if(emailMsg.size() > 0){
                attach = [select id, name, body, description, createdDate from Attachment where ParentID = :emailMsg[0].Id and description = 'Creditors Package' order by lastModifiedDate asc];
            }else{
                attach = [select id, name, body, description from Attachment where ParentID = :caseRecord.Id and description = 'Creditors Package' order by lastModifiedDate asc];
            }
            String emailAddress = caseRecord.SuppliedEmail;
            String domainName = emailAddress.split('@').get(1);
            String strParserId;
            if(caseRecord.Creditor_s_Pack_Language__c == 'English'){
                for(Domain_Name_Parser__c dnp : domPar){
                    if(dnp.Domain_Name__c == domainName){
                        strParserId = dnp.Parser_Name__c;
                    }
                }
            }else if(caseRecord.Creditor_s_Pack_Language__c == 'French'){
                for(French_Domain_Name_Parser__c fnp : domFrePar){
                    if(fnp.Domain_Name__c == domainName){
                        strParserId = fnp.Parser_Name__c;
                    }
                }
                //strParserId = domFrePar.French_Parser_ID__c;
            }
            /*
            HttpRequest req = New HttpRequest();
            req.setHeader('Content-Type', 'multipart/form-data; boundary=' + strSeparationKey);
            //test Target URL- ' https://api.docparser.com/v1/results/sgsaenoqjtbu/b578de4e4185420b1c4fcefae83f815c';
            strTargetURL = strTargetURL + '/' +  strParserId + '/' + insol.Document_ID__C;
            req.setHeader('Authorization', 'Basic ' + strApiKey);
            req.setMethod('GET');
            req.setEndpoint(strTargetURL);
            Http http = New Http();
            HTTPResponse res1 = http.send(req);
            
            String payload = (''+res1.getBody()).removeEnd(']');
            payload = payload.removeStart('[');
            
            Map<String, Object> parsedData = (Map<String, Object>)JSON.deserializeUntyped(payload);
            Map<String, Object> parsedMap = new Map<String, Object>();
            List<Map<String, Object>> data = new List<Map<String, Object>>();
            
            system.debug('list deserialized ' + parseddata);
            */
            CaseComment addCom = new CaseComment();
            Boolean error = false;
            /*
            if(null <> parsedData.get('errorCode') && '' <> parsedData.get('errorCode')){
              addCom.commentBody = (String)parsedData.get('errorCode');
              addCom.commentBody += '\n';
              addCom.commentBody += (String)parsedData.get('message');
              
              caseRecord.status = 'Manually Process';
              CaseTriggerHandler.runCaseTrigger = false;
              update caseRecord;
              CaseTriggerHandler.runCaseTrigger = True;
              if(insol.size() > 0){
                addCom.commentBody += 'Insolvency Record is created. Insolvency Estate Number : ' + insol[0].Name;
              }
              addCom.parentId = caseRecord.id;
              insert addCom;
              error = true;
              
            }
            
            if(error == false){
              List<Object> listInsolAccounts = (List<Object>)parsedData.get('_insolvent_accounts');
              
              try{
                  list<Insolvency_Account__c> listInsAcc = new List<Insolvency_Account__c>();
                  for(Object inAc : listInsolAccounts){
                      Insolvency_Account__c insAcc = new Insolvency_Account__c();
                      Map<String, Object> mapAcc = (Map<String, Object>)inAc;
                      insAcc.Insolvency__c = insol[0].id;
                      insAcc.name = (String.isNotBlank((String)mapAcc.get('key_2')) ? (String)mapAcc.get('key_2') : 'Unknown');
                      insAcc.Creditor__c = (String)mapAcc.get('key_0');
                      insAcc.Creditor_Address__c = (String)mapAcc.get('key_1');
                      String strUnsecuredDebtAmount = (String)mapAcc.get('key_3');
                      insAcc.Unsecured_Debt_Amount__c = Decimal.valueOf(strUnsecuredDebtAmount.remove(',')); 
                      String strSecuredAssetAmount = (String)mapAcc.get('key_4');
                      insAcc.Secured_Asset_Amount__c = Decimal.valueOf(strSecuredAssetAmount.remove(','));
                      insAcc.recordTypeId = unknownBankRecordTypeId;
                      insAcc.client_identifier__c = 'Unknown';
                      listInsAcc.add(insAcc);
                  }
                  
                  //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
                  insert listInsAcc;
                  //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
                  
              }catch(Exception manualExcep){
                  caseRecord.status = 'Manually Process';
                  CaseTriggerHandler.runCaseTrigger = false;
                  update caseRecord;
                  CaseTriggerHandler.runCaseTrigger = True;
                  if(insol.size() > 0){
                    addCom.commentBody = addCom.commentBody == null ? '' : addCom.commentBody;
                    addCom.commentBody += 'Insolvency Record is created. Insolvency Estate Number : ' + insol[0].Name;
                    addCom.commentBody += '. Need to process Insolvency Accounts Manually';
                  }
                  addCom.parentId = caseRecord.id;
                  insert addCom;
                  error = true;
              }
              */
              insol[0].Insolvency_Status__c = 'Staging';
              insol[0].Insolvency_Received_Date__c = (caseRecord.createdDate).date();
              InsolvencyTriggerHandler.runInsolvencyTrigger = false;
              update insol;
              InsolvencyTriggerHandler.runInsolvencyTrigger = true;
              
              /*
              if(error != true){
                  caseRecord.status = 'Completed';
                  
              }
              */
              
              caseRecord.Insolvency__c = insol[0].id;
              CaseTriggerHandler.runCaseTrigger = false;
              update caseRecord;
              CaseTriggerHandler.runCaseTrigger = True;
              
              Attachment newAttach = attach[0].clone(false,false,false,false);
              newAttach.parentID = insol[0].id;
              insert newAttach;
            //}
        }catch(Exception e){
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
        }
    }
}