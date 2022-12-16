/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to send Notifications for Recalled Accounts to Portal
 *  @author : A5E Consulting
 *  @date : 08/07/2022
 
 *************************************************************************************************/
public class SendRecalledAccountsToPortalBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        //Get Document storage created today with payment Type= Recalled Account Updates
        return Database.getQueryLocator(
            [SELECT ID,  Name, Creator__c, Document_Storage_Number__c, Document_Id__c, Document_Name__c, Document_Type__c, Document_URL__c, Placement_Identifier__c, 
             Uploaded_By__c, Visibility__c, Record_Type_Identifier__c, Customer_Identifier__c, 
             Product_Identifier__c, Judgment_Identifier__c, Settlement_Identifier__c, File_Processing_Status__c,
             Work_Assignment_Identifier__c, Created_By__c, Last_Modified_By__c,Document_Related_To__c,
             Work_Assignment__r.Record_type_Identifier__c
             FROM Document_Storage__c
             WHERE CreatedDate = TODAY 
             //AND Placement_Identifier__c = '102'
             AND Payment_type__c = 'Recalled Account']
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Document_Storage__c> listDocumentStorage){
        system.debug('listDocumentStorage::'+listDocumentStorage);
        String Title = '';
        String Message = '';
        for(Document_Storage__c docString : listDocumentStorage){    
            //call to portal API to send doc storage record
            processDocumentStorage(docString.Name, docString.Creator__c, docString.Document_Storage_Number__c, docString.Document_Id__c, docString.Document_Name__c, docString.Document_Type__c,
                                              docString.Document_URL__c, docString.Placement_Identifier__c, docString.Uploaded_By__c, docString.Visibility__c,
                                              docString.Record_Type_Identifier__c, docString.Work_Assignment_Identifier__c, docString.Created_By__c,
                                              docString.Last_Modified_By__c, docString.Work_Assignment__r.Record_type_Identifier__c);
        }
    }    
    
    public void finish(Database.BatchableContext bc){
       //Database.executeBatch(new CallToNotificationApi());
       Database.executeBatch(new SendAccountUpdatesDocumentToPortalBatch());	
    }    
    
    //API call to portal to send doc storage
    public static void processDocumentStorage(String Name, String Creator, String Document_Storage_Number, String Document_Id, String Document_Name, String Document_Type,
                                              String Document_URL, String Placement_Identifier, String Uploaded_By, String Visibility,
                                              String Record_Type_Identifier, String Work_Assignment_Identifier, String Created_By,
                                              String Last_Modified_By, String Task_Type
                                             ){ 
        system.debug('SEND DOCUMENT to PORTAL API');
        
        String documentStorageJSONRequest;
            documentStorageJSONRequest = '{'+
                '"Name": "'+Name+'",'+
                '"Creator": "'+Creator+'",'+
                '"Document_Storage_Number": "'+Document_Storage_Number+'",'+
                '"Document_Id": "'+Document_Id+'",'+
                '"Document_Name": "'+Document_Name+'",'+
                '"Document_Type": "'+Document_Type+'",'+
                '"Document_URL": "'+Document_URL+'",'+
                '"Placement_Identifier": "'+Placement_Identifier+'",'+
                '"Uploaded_By": "'+Uploaded_By+'",'+
                '"Visibility": "'+Visibility+'",'+
                '"Record_Type_Identifier": "'+Record_Type_Identifier+'",'+
                '"Work_Assignment_Identifier": "'+Work_Assignment_Identifier+'",'+
                '"Created_By": "'+Created_By+'",'+
                '"Last_Modified_By": "'+Last_Modified_By+'",'+
                '"Task_Type": "'+Task_Type+'",'+
                '"Document_Related_To": "'+ 'Task' +'"'+
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
            String ENdpoint = '';
            ENdpoint = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFDocument');
            //apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFDocument');
            req.setEndpoint(ENdpoint+Document_Id);
            req.setMethod('PUT');         
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            req.setTimeout(120000);
            //documentStorageInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
    
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                //documentStorageInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body::' +res.getBody());
                system.debug('response**'+ res.getStatusCode());
                if(res.getStatusCode() == 200
                && bodyMap.get('IsSuccess') == String.valueOf('true')){
                    system.debug(bodyMap.get('ReturnMessage'));
                }       
                else{
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
}