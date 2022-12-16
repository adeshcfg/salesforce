/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update worassignment Record from 
*                 Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 12/01/2022

*************************************************************************************************/
public class PortalWorkAssignmentProcessingAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    @future (callout=true)
    public static void processWorkAssignment(ID workAssignmentId,String triggereve,Boolean commentStatus){
        system.debug('triggereve: '+triggereve); 
        list<Work_Assignment__c> listWorkAssignment = [SELECT ID, Name, Title__c, Task_Number__c, Sub_Purpose__c, Status__c, Source__c,
                                                       Requested_Date__c, Purpose__c, Priority__c, Due_Date__c,
                                                       Description__c, Created_By__c,
                                                       Customer_Identifier__c, Judgment_Identifier__c, Settlement_identifier__c,
                                                       Placement_Agency_Identifier__c, Assign_To__c, Product_Identifier__c, Last_Modified_By__c,
                                                       Assign_To_Agency_User__c, Assigned_To_User_Name__c, Application__c, Statements__c, Cardholder_Agreement__c,
                                                       Check_Copy__c, PPSA_Registration__c, Drivers_License__c, Repossession_And_Auction_Documents__c,
                                                       Note_Lines__c, Other__c,Other_Media_Request__c,Last_Payment_Statement__c,
                                                       Charge_Off_Statement__c,Latest_Comment__c,Start_Month__c,Assigned_To_Agency_User_Email__c,
                                                       Start_Year__c,End_Month__c,End_Year__c,Application_Status__c,Statements_Status__c,Cardholder_Agreement_Status__c,
                                                       Check_Copy_Status__c,PPSA_Registration_Status__c,Drivers_License_Status__c,Repossession_And_Auction_DocumentsStatus__c,
                                                       Note_Lines_Status__c,Other_Media_Request_Status__c
                                                       FROM Work_Assignment__c 
                                                       WHERE ID= :workAssignmentId];
        system.debug('listWorkAssignment: '+listWorkAssignment);                             
        /*
list<Account> listCustomers = [SELECT ID, FirstName, LastName, PersonEmail, PersonMailingStreet, PersonMailingPostalCode, 
PersonMailingCity, PersonBirthdate, PersonHomePhone, PersonOtherPhone, PersonMobilePhone, 
Work_Phone__pc, Secret_Code__c, Secret_Code_Expiration_Date__c, SF_ID__c,
PersonMailingState,SIN__pc
FROM Account 
WHERE ID IN :setCustomerID
AND RecordType.Developername= :'Canaccede_Customer'];
*/
        String workAssignmentJSONRequest;
        Work_Assignment__c workAssignmentInstance;
        if(!listWorkAssignment.isEmpty()){
            //Create JSON request for customer update
            workAssignmentInstance = listWorkAssignment[0];
            system.debug('workAssignmentInstance '+workAssignmentInstance);
            String Descrip = '';
            String commentReply ='';
            if(String.isNotBlank(workAssignmentInstance.Description__c)){
            	Descrip = String.valueOf(workAssignmentInstance.Description__c).replace('\n', '').replace('\r', '');    
            }
            if(String.isNotBlank(workAssignmentInstance.Latest_Comment__c)){
            	commentReply = String.valueOf(workAssignmentInstance.Latest_Comment__c).replace('\n', '').replace('\r', '');    
            }
           	//system.debug('Descrip::'+Descrip);
            workAssignmentJSONRequest = '{';
            workAssignmentJSONRequest += '"Name": "'+workAssignmentInstance.Name+'",'+
                //'"Title": "'+workAssignmentInstance.Title__c+'",'+
                '"Title": "'+(String.isNotBlank(workAssignmentInstance.Title__c) ? workAssignmentInstance.Title__c : '')+'",'+
                '"Task_Number": "'+workAssignmentInstance.Task_Number__c+'",'+
                '"Description": "'+Descrip+'",'+
                '"Purpose": "'+workAssignmentInstance.Purpose__c+'",'+
                '"Sub_Purpose": "'+workAssignmentInstance.Sub_Purpose__c+'",'+
                //'"Priority": "'+workAssignmentInstance.Priority__c+'",'+
                '"Priority": "'+(String.isNotBlank(workAssignmentInstance.Priority__c) ? workAssignmentInstance.Priority__c: '')+'",'+
                '"Status": "'+workAssignmentInstance.Status__c+'",'+
                '"Requested_Date": "'+workAssignmentInstance.Requested_Date__c+'",'+
                '"Due_Date": "'+workAssignmentInstance.Due_Date__c+'",'+
                //'"Customer_Identifier": "'+workAssignmentInstance.Customer_Identifier__c+'",'+
                '"Judgment_Identifier": "'+workAssignmentInstance.Judgment_Identifier__c+'",'+
                '"Product_Identifier": "'+workAssignmentInstance.Product_Identifier__c+'",'+
                '"Settlement_Identifier": "'+workAssignmentInstance.Settlement_Identifier__c+'",'+
                '"Placement_Agency_Identifier": "'+workAssignmentInstance.Placement_Agency_Identifier__c+'",'+
                '"Source": "'+workAssignmentInstance.Source__c+'",'+
                '"Assign_To": "'+workAssignmentInstance.Assign_To__c+'",'+
                '"Last_Modified_By": "'+workAssignmentInstance.Last_Modified_By__c+'",'+
                '"Assign_To_Agency_User": "'+workAssignmentInstance.Assigned_To_Agency_User_Email__c+'",'+
                '"Assigned_To_User_Name": "'+workAssignmentInstance.Assigned_To_User_Name__c+'",'+
                //'"Statement_Start_Date": "'+workAssignmentInstance.Statement_Start_Date__c+'",'+
                //'"Statement_End_Date": "'+workAssignmentInstance.Statement_End_Date__c+'",'+
                //Addtional fields for Media request sub-purpose
                '"Start_Month": "'+workAssignmentInstance.Start_Month__c+'",'+
                '"Start_Year": "'+workAssignmentInstance.Start_Year__c+'",'+
                '"End_Month": "'+workAssignmentInstance.End_Month__c+'",'+
                '"End_Year": "'+workAssignmentInstance.End_Year__c+'",'+
                //Addtional fields for Media request sub-purpose
                '"Application": "'+workAssignmentInstance.Application__c+'",'+
                '"Statements": "'+workAssignmentInstance.Statements__c+'",'+
                '"Cardholder_Agreement": "'+workAssignmentInstance.Cardholder_Agreement__c+'",'+
                '"Check_Copy": "'+workAssignmentInstance.Check_Copy__c+'",'+
                '"PPSA_Registration": "'+workAssignmentInstance.PPSA_Registration__c+'",'+
                '"Drivers_License": "'+workAssignmentInstance.Drivers_License__c+'",'+
                '"Repossession_And_Auction_Documents": "'+workAssignmentInstance.Repossession_And_Auction_Documents__c+'",'+
                '"Note_Lines": "'+workAssignmentInstance.Note_Lines__c+'",'+
                '"Other": "'+workAssignmentInstance.Other__c+'",'+
                '"Other_Media_Request": "'+workAssignmentInstance.Other_Media_Request__c+'",'+
                
                // Fields of media request status
                
                //'"Application_Status": "'+workAssignmentInstance.Application_Status__c+'",'+
                '"Statements_Status": "'+workAssignmentInstance.Statements_Status__c+'",'+
                '"Cardholder_Agreement_Status": "'+workAssignmentInstance.Cardholder_Agreement_Status__c+'",'+
                '"Check_Copy_Status": "'+workAssignmentInstance.Check_Copy_Status__c+'",'+
                '"PPSA_Registration_Status": "'+workAssignmentInstance.PPSA_Registration_Status__c+'",'+
                '"Drivers_License_Status": "'+workAssignmentInstance.Drivers_License_Status__c+'",'+
                '"Repossession_And_Auction_DocumentsStatus": "'+workAssignmentInstance.Repossession_And_Auction_DocumentsStatus__c+'",'+
               '"Note_Lines_Status": "'+workAssignmentInstance.Note_Lines_Status__c+'",'+
                '"Other_Media_Request_Status": "'+workAssignmentInstance.Other_Media_Request_Status__c+'",'+
                '"Last_Payment_Statement": "'+workAssignmentInstance.Last_Payment_Statement__c+'",'+
                '"Charge_Off_Statement": "'+workAssignmentInstance.Charge_Off_Statement__c+'",';
                
                //'"Comment_Reply": "'+commentReply+'",';
        		//workAssignmentJSONRequest = workAssignmentJSONRequest.replaceAll('null', ''); 
        		if(commentStatus == True){
                	workAssignmentJSONRequest = workAssignmentJSONRequest + '"Comment_Reply":"'+commentReply+'",';
              	}       
				if(workAssignmentInstance.Customer_Identifier__c != null){
                	workAssignmentJSONRequest = workAssignmentJSONRequest + '"Customer_Identifier":"'+workAssignmentInstance.Customer_Identifier__c+'",';
              	}
                else{
                    workAssignmentJSONRequest = workAssignmentJSONRequest + '"Customer_Identifier": null,';
                }   
            
                if(workAssignmentInstance.Application_Status__c != null){
                    workAssignmentJSONRequest = workAssignmentJSONRequest + '"Application_Status":"'+workAssignmentInstance.Application_Status__c+'"';
                }
                else{
                    workAssignmentJSONRequest = workAssignmentJSONRequest + '"Application_Status": ""';
                }
        	}
        
       	workAssignmentJSONRequest += '}';
        system.debug('workAssignmentJSONRequest: '+workAssignmentJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('workAssignmentJSONRequest: '+workAssignmentJSONRequest);
            req.setBody(workAssignmentJSONRequest);
            system.debug('req body'+req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'Task');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+workAssignmentInstance.Task_Number__c);
            req.setMethod('PUT');
            //req.setEndpoint('https://paschidev-cnccd-cstprt-d.azurewebsites.net/api/'+'Customers/'+workAssignmentInstance.SF_ID__c);
            system.debug('req endpoint:: '+req.getEndpoint());
            system.debug('req body:: '+req.getBody());
            workAssignmentInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
            
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                workAssignmentInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res.getBody() :: '+res.getBody());
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
            
            if(workAssignmentInstance != NULL){
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                update workAssignmentInstance;
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
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
        if(!Test.isRunningTest()) {
            Map<String, Object> wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
            system.debug('wResp: '+wResp.get('access_token'));
            //Map<String, Object> resultMap = (Map<String, Object>) wResp.get('access_token');
            //system.debug('resultMap::'+resultMap);
            //system.debug('token'+resultMap.get('Token'));
            return String.valueOf(wResp.get('access_token'));
        } else {
            return 'test';
        }
        
    }
}