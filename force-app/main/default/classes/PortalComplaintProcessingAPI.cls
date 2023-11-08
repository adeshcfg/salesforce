/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update Complaint Record from 
*                 Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 23/02/2022

*************************************************************************************************/
public class PortalComplaintProcessingAPI {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    @future (callout=true)
    public static void processComplaint(ID workAssignmentId,String triggereve, String oldLatestComment){
        system.debug('triggereve: '+triggereve); 
        list<Work_Assignment__c> listWorkAssignment = [SELECT ID, Name, Task_Number__c, Description__c, Priority__c,Status__c, Source__c,
                                                       Requested_Date__c, Due_Date__c,Latest_Comment__c, Created_By__c, Last_Modified_By__c,
                                                       Customer_Identifier__c,/* Judgment_Identifier__c, Settlement_identifier__c,*/
                                                       Placement_Agency_Identifier__c, Product_Identifier__c, Assign_To__c,
                                                       Assign_To_Agency_User__c, Assigned_To_User_Name__c,Customer_Name__c,
                                                       Resolution_By__c,Resolution_Date__c, Agency_Investigation_Notes__c,
                                                       Complaint_Type__c, Root_Cause__c,Root_Cause_Other__c,Complaint_Type_Other__c,
                                                       Account_Being_CB_Reported_By_Agency__c,Complaint_Related_To_Another_Products__c,Is_The_Complaint_Valid__c,
                                                       Have_You_Provided_Supporting_Media__c,Reopen_Comments__c,Agency_Currently_Has_Account_On_Hold__c,
                                                       Date_Complaint_Received_By_Agency__c,CFG_Complaint_Analysis__c , Original_Creditor__c ,Next_follow_up_date__c,
                                                       Products_List__c,Is_Multiple_Products__c,Canaccede_Entity__c, Canaccede_Entity_ID__c,Assigned_To_Agency_User_Email__c
                                                       FROM Work_Assignment__c 
                                                       WHERE ID= :workAssignmentId];
        system.debug('listWorkAssignment: '+listWorkAssignment);
        
        String complaintJSONRequest;
        Work_Assignment__c complaintInstance;
        if(!listWorkAssignment.isEmpty()){
            //Create JSON request for customer update
            complaintInstance = listWorkAssignment[0];
            system.debug('complaintInstance '+complaintInstance);
            //Handles the break for for long text area field.
            String description = complaintInstance.Description__c;
            String escapeDescString = description.escapeUnicode();
            
            //Product List
            String productsList = complaintInstance.Products_List__c;
            String escapeProdlistString = '';
            if(!String.isBlank(productsList)){
                escapeProdlistString = productsList.escapeUnicode();
            } 
            //Bug 5520: Changes Starts
            //Agency_Investigation_Notes__c
            String agencyInvestigationNotes = complaintInstance.Agency_Investigation_Notes__c;
            String escapeagencyInvestigationNotes = '';
            if(!String.isBlank(agencyInvestigationNotes)){
                escapeagencyInvestigationNotes = agencyInvestigationNotes.escapeUnicode();
            }      
            //CFG_Complaint_Analysis__c  
               String cfgComplaintAnalysis = complaintInstance.CFG_Complaint_Analysis__c;
               String escapecfgComplaintAnalysis = '';
               if(!String.isBlank(cfgComplaintAnalysis)){
                escapecfgComplaintAnalysis = cfgComplaintAnalysis.escapeUnicode();
               }   
            //Bug 5520: Changes Ends
            //Bug 5554: Changes Starts
              //CFG_Complaint_Analysis__c  
              String reopenComments = complaintInstance.CFG_Complaint_Analysis__c;
              String escapereopenComments = '';
              if(!String.isBlank(reopenComments)){
                escapereopenComments = reopenComments.escapeUnicode();
              }   
           //Bug 5554: Changes Ends
            //Bug 5520: Updated below JSON for long text area fields with escapeagencyInvestigationNotes,escapecfgComplaintAnalysis
            complaintJSONRequest = '{'+
                //'"Identifier":'+workAssignmentInstance.SF_ID__c+','+
                '"Name": "'+complaintInstance.Name+'",'+
                '"Task_Number": "'+complaintInstance.Task_Number__c+'",'+
                //'"Description": "'+complaintInstance.Description__c+'",'+
                '"Description": "'+escapeDescString+'",'+
                '"Priority": "'+(String.isNotBlank(complaintInstance.Priority__c) ? complaintInstance.Priority__c: '')+'",'+
                '"Status": "'+complaintInstance.Status__c+'",'+
                '"Requested_Date": "'+complaintInstance.Requested_Date__c+'",'+
                '"Due_Date": "'+complaintInstance.Due_Date__c+'",'+
                '"Next_follow_up_date": "'+complaintInstance.Next_follow_up_date__c+'",';
                    complaintJSONRequest += '"Comment_Reply": "'+(String.isnotBlank(complaintInstance.Latest_Comment__c) ? 
                    complaintInstance.Latest_Comment__c.escapeUnicode()
                   : complaintInstance.Latest_Comment__c) +'",';
                complaintJSONRequest += '"Reopen_Comments": "'+escapereopenComments+'",'+
                '"Complaint_Type": "'+complaintInstance.Complaint_Type__c+'",'+
                '"Root_Cause": "'+complaintInstance.Root_Cause__c+'",'+
               '"Original_Creditor": "'+complaintInstance.Original_Creditor__c+'",'+
                '"Resolution_By": "'+complaintInstance.Resolution_By__c+'",'+
                '"Resolution_Date": "'+complaintInstance.Resolution_Date__c+'",'+
                '"Result_of_Investigation": "'+escapeagencyInvestigationNotes+'",'+
                '"Source": "'+complaintInstance.Source__c+'",'+
                '"CFG_Complaint_Analysis": "'+escapecfgComplaintAnalysis+'",'+
                '"Assign_To": "'+UserInfo.getName()+'",'+
                '"Assign_To_Agency_User": "'+complaintInstance.Assigned_To_Agency_User_Email__c+'",'+
                '"Assigned_To_User_Name": "'+complaintInstance.Assigned_To_User_Name__c+'",'+
                '"Last_Modified_By": "'+complaintInstance.Last_Modified_By__c+'",'+
                '"Customer_Identifier": "'+complaintInstance.Customer_Identifier__c+'",'+
                '"Customer_Name": "'+complaintInstance.Customer_Name__c+'",'+
                '"Product_Identifier": "'+complaintInstance.Product_Identifier__c+'",'+
                '"Complaint_Related_To_Another_Products": "'+complaintInstance.Complaint_Related_To_Another_Products__c+'",'+
                '"Root_Cause_Other": "'+complaintInstance.Root_Cause_Other__c+'",'+
                '"Complaint_Type_Other": "'+complaintInstance.Complaint_Type_Other__c+'",'+
                '"Is_The_Complaint_Valid": "'+complaintInstance.Is_The_Complaint_Valid__c+'",'+
                '"Have_You_Provided_Supporting_Media": "'+complaintInstance.Have_You_Provided_Supporting_Media__c+'",'+
                '"Account_Being_CB_Reported_By_Agency": "'+complaintInstance.Account_Being_CB_Reported_By_Agency__c+'",'+
                '"Agency_Currently_Has_Account_On_Hold": "'+complaintInstance.Agency_Currently_Has_Account_On_Hold__c+'",'+
                '"Date_Complaint_Received_By_Agency": "'+complaintInstance.Date_Complaint_Received_By_Agency__c +'",'+
                //New Field Added for agency
                '"Products_List": "'+escapeProdlistString.escapeUnicode()+'",'+
                '"Is_Multiple_Products": "'+complaintInstance.Is_Multiple_Products__c+'",'+
                '"Placement_Agency_Identifier": "'+complaintInstance.Placement_Agency_Identifier__c+'",'+
               '"Canaccede_Entity": '+complaintInstance.Canaccede_Entity_ID__c +
                '}';
        }
        system.debug('complaintJSONRequest: '+complaintJSONRequest);
        
        //Get access token for http request
        String accToken;
        accToken = getRequestToken();
        system.debug('accToken: '+accToken);
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            system.debug('complaintJSONRequest: '+complaintJSONRequest);
            req.setBody(complaintJSONRequest);
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SFComplain');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c+complaintInstance.Task_Number__c);
            req.setMethod('PUT');
            system.debug('req endpoint:: '+req.getEndpoint());
            complaintInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: '+req.getBody());
            system.debug('req:: '+req);
            
            
            try{
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): '+res.getBody());
                system.debug('Status code: '+res.getStatusCode());
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                complaintInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res.getBody() :: '+res.getBody());
                String statusCode = String.valueOf(res.getStatusCode());
                if(statusCode.startsWith('2')
                   && bodyMap.get('IsSuccess') == String.valueOf('true')){
                    system.debug('Status code: '+res.getStatusCode());
                    system.debug(bodyMap.get('ReturnMessage'));
                   }       
                else if(!statusCode.startsWith('2')){
                    system.debug('Status code: '+res.getStatusCode());
                    String userName = UserInfo.getName();
                    API_Error__c apiErrorData = New API_Error__c();
                    apiErrorData.Action__c = 'API Failed';
                    apiErrorData.Request__c = complaintInstance.Task_Number__c;
                    if(res.getBody().length() > 131071){
                                
                        apiErrorData.Response__c =res.getBody().subString(0,131071);
                    }else{
                        apiErrorData.Response__c =res.getBody();
                    }
                    listAPIErrors.add(apiErrorData);
                    
                    CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Response__c,apiErrorData.Action__c);
                }
            }
            catch(Exception ex){
                system.debug('exception ex: '+ex.getStackTraceString());
                String userName = UserInfo.getName();
                API_Error__c apiErrorData = New API_Error__c();
                apiErrorData.Error__c = complaintInstance.Task_Number__c +' '+'Record failed due to'+' '+ex.getMessage()+' '+ex.getStackTraceString();
                apiErrorData.Action__c = 'API Failed';
                if(!Test.isRunningTest()){
                    apiErrorData.Request__c = complaintInstance.Task_Number__c;
                }
                
                listAPIErrors.add(apiErrorData);
                
                CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiErrorData.Error__c,apiErrorData.Action__c);
            }
            
            insert listAPIErrors;
            
            if(complaintInstance != NULL){
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                update complaintInstance;
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            }
        }
    }   
    
    //Get Access Token
    public static string getRequestToken() {
        system.debug('apiCallDetails: '+apiCallDetails);
        String bodyParams = '';
        Map<String, Object> wResp;
        try{
        String dptenandId = apiCallDetails.Tenand_ID__c;
        String dpapiProxyClientId = apiCallDetails.Proxy_Client_ID__c;
        String dpapiClientClientId = apiCallDetails.Client_ID__c;
        String dpapiClientSecret = apiCallDetails.Client_Secret__c;
        String authorizationtUrl =  apiCallDetails.AuthorizationtUrl__c;
        String parsePDFApi =  apiCallDetails.PDF_API_URL__c;
        
        authorizationtUrl = authorizationtUrl.replace('{{tenandId}}', dptenandId);
        bodyParams =  'client_id='+dpapiClientClientId;
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
        wResp =   (Map<String, Object>) JSON.deserializeUntyped(hresp.getBody());
        system.debug('wResp: '+wResp.get('access_token'));
    }
        catch(Exception ex){
            system.debug('Exception occured :'+ex);
            String userName = UserInfo.getName();
            API_Error__c apiError = New API_Error__c();
            apiError.Error__c = ex.getMessage();
            apiError.Action__c = 'Access Token';
            apiError.Response__c = bodyParams;
            listAPIErrors.add(apiError); 
            CFG_EmailNotification.apiFailedEmailNotifyTOCFGSupport(userName,apiError.Error__c,apiError.Action__c);
        }
        return String.valueOf(wResp.get('access_token'));
    }
}