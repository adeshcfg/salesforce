/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a webservice class(provide) to send notification to portal
 *  @author : A5E Consulting
 *  @date : 17/01/2022
 
 *************************************************************************************************/
public class PortalNotificationAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    
    public static void sendPaymentNotification(String placeId, String Type, String Title, String TaskNumber, String Message){
        system.debug('Type::'+Type);
        Timezone tz = Timezone.getTimeZone('America/New_York');
		DateTime dtpre = DateTime.now();
        system.debug('tz.getOffset(dtpre)' +tz.getOffset(dtpre));
        String JSONRequest = '';
		
        String convertedDateTime = JSON.serialize(Datetime.now()).substringBetween('"');

        //create notification JSON
        JSONRequest = '{'+
            '"place_id": "'+placeId+'",'+
            '"Type": "'+Type+'",'+
            '"Title": "'+Title+'",'+
            '"LastModifiedBy": "'+UserInfo.getName()+'",'+
            '"Message": "'+Message+'",';
        JSONRequest += '"Date":"'+
        convertedDateTime+'\", ';  
        
        JSONRequest += '"TaskNumber": "'+TaskNumber+'"';
        
        JSONRequest+= '}';   
                                               
        system.debug('JSONRequest:: '+JSONRequest);
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('JSONRequest: '+JSONRequest);
            req.setBody(JSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'notifications');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c);
            req.setMethod('POST');
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
    
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                //productInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res body::' +res.getBody());
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
        if(!Test.isRunningTest()){
        	HttpResponse hresp = h.send(req);
            system.debug('hresp: '+hresp);
            system.debug('hresp.getBody(): '+hresp.getBody());
            Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
            system.debug('wResp: '+wResp.get('access_token')); 
            return String.valueOf(wResp.get('access_token'));
        }
        else{
            return null;
        }
        
    }
}