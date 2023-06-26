/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update DistressedNotes Record from 
*                 Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 11/02/2022

*************************************************************************************************/
public class PortalDistressedNotesProcessingAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    @future (callout=true)
    public static void processDistressedNotes(ID distressedNotesId, String method){ 
        list<Distressed_notes__c> listDistressedNotes = [SELECT ID, Name, Body__c, Created_By__c, Customer__c, Customer_Identifier__c, Hist_Completed__c, Hist_Due__c, Hist_Open__c, Hist_Private__c, 
                                                         Judgment__c, Judgment_Identifier__c, Last_Modified_By__c, Notes_Date__c, 
                                                         Notes_History__c, Product__c, Product_Identifier__c, Settlement__c,Settlement_Identifier__c,
                                                         Settlement_account__c, DistressedTitle__c, Title__c,Visibility__c,Distressed_Notes_Number__c,Agency_ID__c                                   
                                                         FROM Distressed_notes__c 
                                                         WHERE ID= :distressedNotesId];
        system.debug('listDistressedNotes: '+listDistressedNotes);
        
        String distressedNotesJSONRequest;
        Distressed_notes__c distressedNotesInstance;
        if(!listDistressedNotes.isEmpty()){
            //Create JSON request for customer update
            distressedNotesInstance = listDistressedNotes[0];
            //String body = distressedNotesInstance.Body__c;
            //String escapeString = body.escapeUnicode();
            //system.debug('escapeString '+escapeString);
            system.debug('distressedNotesInstance '+distressedNotesInstance);
            
            //For Ticket: 4618 - changes done by satyajit
            String escapedValue = '';
            String escapedTitle = '';
            
            if(String.isNotBlank(distressedNotesInstance.Body__c)){
                escapedValue = String.valueOf(distressedNotesInstance.Body__c).replace('\n', '').replace('\r', ' ');   
                escapedValue = escapedValue.replaceAll('\\s+', ' ');
            }
            if(String.isNotBlank(distressedNotesInstance.Title__c)){
                escapedTitle = String.valueOf(distressedNotesInstance.Title__c).replace('\n', '').replace('\r', ' ');   
                escapedTitle = escapedTitle.replaceAll('\\s+', ' ');
            }
            
            distressedNotesJSONRequest = '{'+
                '"Name": "'+distressedNotesInstance.Distressed_Notes_Number__c+'",'+
                '"Title": "'+escapedTitle+'",'+
                '"Body": "'+escapedValue+'",'+
                '"Notes_History": "'+distressedNotesInstance.Notes_History__c+'",'+
                '"Notes_Date": "'+distressedNotesInstance.Notes_Date__c+'",'+
                '"Hist_Open": "'+distressedNotesInstance.Hist_Open__c+'",'+
                '"Hist_Completed": "'+distressedNotesInstance.Hist_Completed__c+'",'+
                '"Hist_Due": "'+distressedNotesInstance.Hist_Due__c+'",'+
                '"Hist_Private": "'+distressedNotesInstance.Hist_Private__c+'",'+
                '"Visibility": "'+distressedNotesInstance.Visibility__c+'",'+
                '"Customer_Identifier": "'+distressedNotesInstance.Customer_Identifier__c+'",'+
                '"Product_Identifier": "'+distressedNotesInstance.Product_Identifier__c+'",'+
                '"Judgment_Identifier": "'+distressedNotesInstance.Judgment_Identifier__c+'",'+
                '"Settlement_Identifier": "'+distressedNotesInstance.Settlement_Identifier__c+'",'+
                '"Created_By": "'+distressedNotesInstance.Created_By__c+'",'+
                '"Last_Modified_By": "'+distressedNotesInstance.Last_Modified_By__c+'",'+
                '"Place_Id": "'+distressedNotesInstance.Agency_ID__c+'"'+
                '}';
        }
        //distressedNotesJSONRequest = distressedNotesJSONRequest.escapeHtml4();
        system.debug('distressedNotesJSONRequest: '+distressedNotesJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('distressedNotesJSONRequest: '+distressedNotesJSONRequest);
            req.setBody(distressedNotesJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFDistressedNote');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+distressedNotesInstance.Name);
            req.setMethod(method);         
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            distressedNotesInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
            
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                distressedNotesInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body:: '+res.getBody());
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
            
            if(distressedNotesInstance != NULL){
                DistressedNotesTriggerHandler.runDistressedNotesTrigger = false;
                update distressedNotesInstance;
                DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;
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