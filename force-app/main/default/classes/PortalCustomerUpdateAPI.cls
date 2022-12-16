/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a webservice class to update Customer Record from Salesforce to Portal DB
 *  @author : A5E Consulting
 *  @date : 16/09/2021
 
 *************************************************************************************************/
public class PortalCustomerUpdateAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    @future (callout=true)
    public static void updateCustomerDetails(Set<id> customerId){
        list<Account> listCustomers = [SELECT ID, FirstName, LastName, PersonEmail, PersonMailingStreet, PersonMailingPostalCode, 
                                              PersonMailingCity, PersonBirthdate, PersonHomePhone, PersonOtherPhone, PersonMobilePhone, 
                                       		  Work_Phone__pc, Secret_Code__c, Secret_Code_Expiration_Date__c, SF_ID__c,
                                       		  PersonMailingState,SIN__pc
                                      FROM Account 
                                      WHERE ID IN: customerID
                                      AND RecordType.Developername= :'Canaccede_Customer'];
        
        String customerUpdateJSONRequest;
        Account customerInstance;
        if(!listCustomers.isEmpty()){
            //Create JSON request for customer update
            customerInstance = listCustomers[0];
            system.debug('customerInstance '+customerInstance);
            customerUpdateJSONRequest = '{'+
                //'"Identifier":'+customerInstance.SF_ID__c+','+
                '"Primary_FirstName": "'+customerInstance.FirstName+'",'+
                '"Primary_LastName": "'+customerInstance.LastName+'",'+
                '"Primary_PersonMailingStreet": "'+customerInstance.PersonMailingState+'",'+
                '"Primary_PersonEmail": "'+customerInstance.PersonEmail+'",'+
                '"Primary_PersonBirthdate": "'+customerInstance.PersonBirthdate+'",'+
                '"Primary_SIN": "'+customerInstance.SIN__pc+'",'+
                '"Primary_PersonMailingStreet": "'+customerInstance.PersonMailingStreet+'",'+
                '"Primary_PersonMailingCity": "'+customerInstance.PersonMailingCity+'",'+
                '"Primary_PersonMailingPostalCode": "'+customerInstance.PersonMailingPostalCode+'",'+
                '"Primary_PersonMailingState": "'+customerInstance.PersonMailingState+'",'+
                '"Primary_PersonHomePhone": "'+customerInstance.PersonHomePhone+'",'+
                '"Primary_Work_Phone": "'+customerInstance.Work_Phone__pc+'",'+
                '"Primary_PersonOtherPhone": "'+customerInstance.PersonMobilePhone+'",'+
                '"SecretCode": "'+customerInstance.Secret_Code__c+'",'+
                '"SecretCode_ExpirationDate": "'+customerInstance.Secret_Code_Expiration_Date__c+'"'+
                '}';
        }
        
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('req: '+req);
            system.debug('customerUpdateJSONRequest: '+customerUpdateJSONRequest);
            req.setBody(customerUpdateJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+'Customers/'+customerInstance.SF_ID__c);
			//req.setEndpoint('https://paschidev-cnccd-cstprt-d.azurewebsites.net/api/'+'Customers/'+customerInstance.SF_ID__c);
			
			system.debug('req endpoint'+req.getEndpoint());
			req.setMethod('PATCH');
    		HttpResponse res;
            String ExceptionString = '';
            try{
                // Send the request, and return a response
                res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                
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
            	ExceptionString = String.valueOf(ex);
                system.debug('ExceptionString:: '+ExceptionString);
            } 
            customerInstance.Outbound_API_Request__c = req.getBody();
            customerInstance.Outbound_API_Response__c = res.getBody();
			system.debug('customerInstance.Outbound_API_Response__c::'+customerInstance.Outbound_API_Response__c);
            if(String.isBlank(customerInstance.Outbound_API_Response__c)){
            	customerInstance.Outbound_API_Response__c  = ExceptionString;    
            }
            CustomerTriggerHandler.runCustomerTrigger = false;
            update customerInstance;
            CustomerTriggerHandler.runCustomerTrigger = true;
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
        //Map<String, Object> resultMap = (Map<String, Object>) wResp.get('access_token');
        //system.debug('resultMap::'+resultMap);
        //system.debug('token'+resultMap.get('Token'));
        return String.valueOf(wResp.get('access_token'));
    }
}