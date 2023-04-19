public class SnapShotAPIToPortal {
    
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public static responseHolder listAccountRecordWrapper = new responseHolder();
    public static errorJSON dataOfErrorJSON = new errorJSON();
    public static String sJOSN;
    public static void parse(String documentStorageId,List<Id> prodIdList){
        List<Agencies> awList  = new List<Agencies>();
        Set<String> placeId = new Set<String>();
       
        //for product and pool screen allocation
        if(documentStorageId.contains('DS_ACC') ){
            List<Product__c> listProd = [Select collection_agency__c,Name from Product__c where id IN: prodIdList]; 
            
            for(Product__c prod : listProd){
                placeId.add(String.valueOf(prod.collection_agency__c));
                
                Snapshot snap = new Snapshot();
                
                snap.DocumentStorageId = documentStorageId;
                for(String place : placeId){
                    Agencies agcy = new Agencies();
                    List<String> docIdList = new List<String>();
                    for(Product__c prodStaging2 : listProd){
                        if(place == String.valueOf(prodStaging2.collection_agency__c)){
                            docIdList.add(prodStaging2.name);
                        }
                    }
                    agcy.DataIds = docIdList;
                    agcy.Agency = Integer.valueOf(place);
                    awList.add(agcy);
                }
                snap.Allocations = awList;
                sJOSN = JSON.serialize(snap);
                system.debug('sJOSN::'+sJOSN); 
            }	
        }else{
            List<Product_Staging__c> listProdStaging = [Select Placement_Agency__c ,Identifier__c ,Data_Id__c 
                                                        From Product_Staging__c
                                                        where
                                                        //Is_Record_Process__c = true  AND 
                                                        Identifier__c =: documentStorageId
                                                        AND Status__c  = 'Processed'];
            
            for(Product_Staging__c prodStaging : listProdStaging){
                placeId.add(prodStaging.Placement_Agency__c);
                
            }	
            
            Snapshot snap = new Snapshot();
            
            snap.DocumentStorageId = documentStorageId;
            for(String place : placeId){
                Agencies agcy = new Agencies();
                List<String> docIdList = new List<String>();
                for(Product_Staging__c prodStaging2 : listProdStaging){
                    if(place == prodStaging2.Placement_Agency__c){
                        docIdList.add(prodStaging2.Data_Id__c);
                    }
                }
                agcy.DataIds = docIdList;
                agcy.Agency = Integer.valueOf(place);
                awList.add(agcy);
            }
            snap.Allocations = awList;
            sJOSN = JSON.serialize(snap);
        }
        
        
        system.debug('sJOSN::'+sJOSN);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            // system.debug('productEquipmentJSONRequest: '+productEquipmentJSONRequest);
            req.setBody(sJOSN);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'services');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+'snapshots');
            req.setMethod('POST');         
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            //productEuipmentInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
            
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                //productEuipmentInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body::' +res.getBody());
                
                if(res.getStatusCode() == 202){
                    system.debug('inside before 202');
                    listAccountRecordWrapper = deSerializeJSON(res.getBody());
                    system.debug('inside after 202');
                    /*accountRecordsWrapper accountList = new accountRecordsWrapper();
accountList = listAccountRecordWrapper.documents;
List<documentsList> docList = new List<documentsList>();
docList = accountList.documents;*/
                    document_storage__c docData;
                    if(!documentStorageId.contains('DS_ACC') ){
                        docData = [select id,Work_Assignment__c from document_storage__c where id = :documentStorageId];
                        
                    }
                    if(docData != null){
                        Work_Assignment__c updateWorkAssign  = new Work_Assignment__c();
                        updateWorkAssign.id = docData.Work_Assignment__c;
                        updateWorkAssign.Comment_Reply__c = 'SnapShot requested successfully';
                        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                        update updateWorkAssign;
                        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
                    }
                    
                    //system.debug(bodyMap.get('ReturnMessage'));
                }       
                else{
                    system.debug('inside else 202');
                    //Error handling
                    dataOfErrorJSON = deSerializeErrorJSON(res.getBody());
                    system.debug('inside else after 202');
                    system.debug('docData::'+documentStorageId);
                    
                    document_storage__c docData;
                    if(!documentStorageId.contains('DS_ACC') ){
                        docData = [select id,Work_Assignment__c,File_Processing_Status__c from document_storage__c where id = :documentStorageId];
                    }
                    if(docData != null){
                        Work_Assignment__c updateWorkAssign  = new Work_Assignment__c();
                        updateWorkAssign.id = docData.Work_Assignment__c;
                        
                        if(dataOfErrorJSON.returnMessage != null && dataOfErrorJSON.returnMessage.length() > 1200){
                            updateWorkAssign.Comment_Reply__c = dataOfErrorJSON.returnMessage.subString(0,1199);
                        }else{
                            updateWorkAssign.Comment_Reply__c = dataOfErrorJSON.returnMessage;
                        }
                        updateWorkAssign.Status__c = 'Completed';
                        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                        update updateWorkAssign;
                        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
                        
                        docData.File_Processing_Status__c = 'Processed';
                        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                        update docData;
                        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
                    }
                    
                    //When snapshot failed from product and from pool screen.
                    if(documentStorageId.contains('DS_ACC') ){
                        String userName = UserInfo.getName();
                        system.debug('inside email');
                        CFG_EmailNotification.snapshotFailedEmailNotification(userName,dataOfErrorJSON.returnMessage,documentStorageId);
                        
                    }
                    
                    system.debug('dataOfErrorJSON::'+dataOfErrorJSON);
                    system.debug('Error Response');
                    system.debug(bodyMap.get('ReturnMessage'));
                }
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex);
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
    
    public static responseHolder deSerializeJSON(String dataAsString) {
        responseHolder listAccountRecordWrapper = (responseHolder)JSON.deserialize(dataAsString, responseHolder.class);
        system.debug('listAccountRecordWrapper::'+listAccountRecordWrapper);
        return listAccountRecordWrapper;
    }
    
    public static errorJSON deSerializeErrorJSON(String dataAsString) {
        errorJSON errJSON = (errorJSON)JSON.deserialize(dataAsString, errorJSON.class);
        system.debug('errJSON::'+errJSON);
        return errJSON;
    }
    
    public class accountRecordsWrapper{
        List<documentsList> documents;
    }
    public class documentsList{
        public String id{get;set;}
        public String placeId{get;set;}
        public String objectType{get;set;}
        public String fileName{get;set;}
    }
    public class responseHolder{
        public String id{get;set;}
        public String status{get;set;}
        public String code{get;set;}
        List<accountRecordsWrapper> documents{get;set;}
    }
    
    public class errorJSON{
        public String id{get;set;}
        public String isSuccess{get;set;}
        public String returnMessage{get;set;}
        public String data{get;set;}
        public String statusCode{get;set;}
        public String tag{get;set;}
        //accountRecordsWrapper documents{get;set;}
    }
    
    public class Agencies {
        public List<String> DataIds{get; set;}
        public Integer Agency{get; set;}
    }
    public class Snapshot {
        
        public String DocumentStorageId {get; set;}
        public List<Agencies> Allocations {get; set;}
    }
    
}