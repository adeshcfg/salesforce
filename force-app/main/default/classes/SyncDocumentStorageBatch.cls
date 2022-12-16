/**************************************************************************************************
*
*  Class:   
*
*  @description : this class is for to call portal API for document Storage Reocds.
*  @author : A5E Consulting
*  @date : 24/06/2022

*************************************************************************************************/
global class SyncDocumentStorageBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{
    String queryStr;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    List<Id> docStorageIdSet;
    //string identifier = 'TC-013495';
    global SyncDocumentStorageBatch(List<Id> docIds) {
        System.debug('>>>>docIds>>>>'+docIds);
        //List<Id> docStorageIdSet = new List<Id>();
        docStorageIdSet = docIds;
        queryStr = 'Select ID, Name, Creator__c, Document_Storage_Number__c, Document_Id__c, Document_Name__c, Document_Type__c, Document_URL__c, Placement_Identifier__c,'; 
        queryStr += 'Uploaded_By__c, Visibility__c, Record_Type_Identifier__c, Customer_Identifier__c, Product_Identifier__c, Judgment_Identifier__c, Settlement_Identifier__c, File_Processing_Status__c,';
        queryStr += 'Work_Assignment_Identifier__c, Created_By__c, Last_Modified_By__c,Document_Related_To__c, Work_Assignment__r.Record_type_Identifier__c FROM Document_Storage__c WHERE Id IN: docStorageIdSet';
    }
    //Fetch all collection agency data
    global database.QueryLocator start(Database.BatchableContext BC) { 
        //System.debug('>><><>'+docStorageIdSet);
        //String queryStr = 'Select ID, Name, Creator__c, Document_Storage_Number__c, Document_Id__c, Document_Name__c, Document_Type__c, Document_URL__c, Placement_Identifier__c,'; 
        //queryStr += 'Uploaded_By__c, Visibility__c, Record_Type_Identifier__c, Customer_Identifier__c, Product_Identifier__c, Judgment_Identifier__c, Settlement_Identifier__c, File_Processing_Status__c,';
        //queryStr += 'Work_Assignment_Identifier__c, Created_By__c, Last_Modified_By__c,Document_Related_To__c, Work_Assignment__r.Record_type_Identifier__c FROM Document_Storage__c WHERE Id IN: docStorageIdSet';
        return database.getQueryLocator(queryStr);
    }
    
    //Call the Portal API for every document storage record that are created in 'CommissionStatementBatch' class.
    global void execute(Database.BatchableContext BC, List<Document_Storage__c> listDocumentStorage) {
        String documentStorageJSONRequest;
        system.debug('Block run');
        API_Call_Details__c apiCallDetails1 = API_Call_Details__c.getInstance('Agency Portal API');
        String pdfURL = apiCallDetails1.PDF_API_URL__c.replace('Document', 'SFDocument');
        for( Document_Storage__c documentStorageInstance: listDocumentStorage) {
            //Create JSON request for customer update
            system.debug('documentStorageInstance '+documentStorageInstance);
            system.debug('task type checking: '+documentStorageInstance.Work_Assignment__r.Record_type_Identifier__c); 
            documentStorageJSONRequest = '{'+
                '"Name": "'+documentStorageInstance.Name+'",'+
                '"Creator": "'+documentStorageInstance.Creator__c+'",'+
                '"Document_Storage_Number": "'+documentStorageInstance.Document_Storage_Number__c+'",'+
                '"Document_Id": "'+documentStorageInstance.Document_Id__c+'",'+
                '"Document_Name": "'+documentStorageInstance.Document_Name__c+'",'+
                '"Document_Type": "'+documentStorageInstance.Document_Type__c+'",'+
                '"Document_URL": "'+documentStorageInstance.Document_URL__c+'",'+
                '"Placement_Identifier": "'+documentStorageInstance.Placement_Identifier__c+'",'+
                '"Uploaded_By": "'+documentStorageInstance.Uploaded_By__c+'",'+
                '"Visibility": "'+documentStorageInstance.Visibility__c+'",'+
                '"Record_Type_Identifier": "'+documentStorageInstance.Record_Type_Identifier__c+'",'+
                '"Customer_Identifier": "'+documentStorageInstance.Customer_Identifier__c+'",'+
                '"Product_Identifier": "'+documentStorageInstance.Product_Identifier__c+'",'+
                '"Judgment_Identifier": "'+documentStorageInstance.Judgment_Identifier__c+'",'+
                '"Settlement_Identifier": "'+documentStorageInstance.Settlement_Identifier__c+'",'+
                '"Work_Assignment_Identifier": "'+documentStorageInstance.Work_Assignment_Identifier__c+'",'+
                '"Created_By": "'+documentStorageInstance.Created_By__c+'",'+
                '"Last_Modified_By": "'+documentStorageInstance.Last_Modified_By__c+'",'+
                '"Task_Type": "'+documentStorageInstance.Work_Assignment__r.Record_type_Identifier__c+'",'+
                '"Document_Related_To": "'+documentStorageInstance.Document_Related_To__c+'"'+
                '}';
            system.debug('documentStorageJSONRequest: '+documentStorageJSONRequest);
            
            //Get access token for http request
            String accToken;
            accToken = getRequestToken();
            system.debug('accToken: '+accToken);
            if (accToken != '') {
                // Instantiate a new http object
                Http h = new Http();
                // Instantiate a new HTTP request
                HttpRequest req = new HttpRequest();
                system.debug('documentStorageJSONRequest: '+documentStorageJSONRequest);
                req.setBody(documentStorageJSONRequest);
                system.debug('req body'+req.getBody());
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json;charset=UTF-8');
                //apiCallDetails1.PDF_API_URL__c = 
                req.setEndpoint(pdfURL+documentStorageInstance.Document_Id__c);
                req.setMethod('PUT');         
                system.debug('req endpoint:: '+req.getEndpoint());
                system.debug('req body:: '+req.getBody());
                documentStorageInstance.Outbound_API_Request_Body__c = req.getBody();
                system.debug('Outbound req body:: '+req.getBody());
                system.debug('req:: '+req);
                
                
                try{
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): '+res.getBody());
                    Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                    documentStorageInstance.Outbound_API_Response_Body__c = res.getBody();
                    system.debug('Outbound res body::' +res.getBody());
                    if(res.getStatusCode() == 200
                       && bodyMap.get('IsSuccess') == String.valueOf('true')){
                           system.debug(bodyMap.get('ReturnMessage'));
                       }       
                    else{
                        system.debug('Error Response');
                        system.debug(bodyMap.get('ReturnMessage'));
                    }
                    system.debug('documentStorageInstance.Document_Type__c: '+documentStorageInstance.Document_Type__c);
                    system.debug('documentStorageInstance.File_Processing_Status__c: '+documentStorageInstance.File_Processing_Status__c);
                }
                catch(Exception ex){
                    system.debug('exception ex: '+ex);
                }
            }//apiCallDetails1 = null;
        }
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        update listDocumentStorage;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
    
    global void finish(Database.BatchableContext BC){
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