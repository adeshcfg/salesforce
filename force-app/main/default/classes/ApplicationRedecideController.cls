/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a class for Redecide Application
 *  @author : A5E Consulting
 *  @date : 07/12/2016
 *  
 
 *************************************************************************************************/
 
public with sharing class ApplicationRedecideController{
    
    public Application__C application{get;set;}
    public Application_Form_Configuration__c afSettings{get;set;}
    public Application_Form_Settings__c appFormSettings {get;set;}
    public Boolean progressBar{get;set;}
    public string errorMessage{get;set;}
    
    public ApplicationRedecideController(){
        
    }
    
    public ApplicationRedecideController(ApexPages.StandardController controller) {
        String appID = ApexPages.currentPage().getParameters().get('id');
        
        system.debug(''+appID);
        
        progressBar = true;
        errorMessage = null;
        
        afSettings = Application_Form_Configuration__c.getOrgDefaults();
        appFormSettings = Application_Form_Settings__c.getOrgDefaults();
        
        application = new Application__C();
        application = [Select id, Name, Last_Name__c, First_Name__c, Birth_Date__c, SIN__C, 
                Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, Permanent_Address_City__c, 
                Permanent_Address_PostalCode__c, Permanent_Address_Province__c, Primary_Phone_Number__c, 
                Home_Phone__c, Cell_Phone__c, Work_Phone__c,
                Marital_Status__c, Home_Owner__c,
                Third_Party_Direction__c, Politically_Exposed_Foreign_Person__c,
                Employment_Years__c, Employment_Months__c, 
                Previous_Employment_Years__c, Previous_Employment_Months__c, 
                Gross_Monthly_Income__c, Employment_Status__c,
                CurrentBKCP__c, Number_of_Dependants__c,
                Housing_Costs__c, Monthly_Expenses__c,
                Webservice_Response__c, Adjudication_Response__c, AML_Response__c,
                AML_Decision__c, Decision__c,
                Campaign_Code__c  
                From Application__c where id = : appID];
                
        system.debug(''+application);
    }
    
    public pageReference reDecide(){
        
        DecisionWSUtil.IntegrationResponse intResponse = new DecisionWSUtil.IntegrationResponse();
        system.debug('intResponse: '+intResponse);
        Boolean flagSIN = false;
        Boolean flagAMLPresent = true;
        
        //Employment length check
        Boolean flagEmployment = false;   
        
        try{
            //submit to adjudication engine
            if(null != application.SIN__c && (application.SIN__c).startsWith('9')){
                flagSIN = true;
            }
            
            //Employment length check
            if(DecisionWS.getGreaterOfEmpLength(Application) < (appFormSettings.Minimum_Employment_Length__c +1)){
                flagEmployment = true;
            }
            
            if(String.isBlank(application.AML_Response__c ) || !((application.AML_Response__c).contains('<BureauHit>Y</BureauHit>'))){
                flagAMLPresent = false;
            }
            if(application.CurrentBKCP__c != 'None' && flagSIN == false && flagEmployment == false){
                intResponse = DecisionWS.reDecide(application, afSettings);
                system.debug('intResponse in if:'+intResponse);
                
                Application.Redecide_Request__c = intResponse.request;
                Application.Redecide_Response__c = intResponse.response;
                //Application.Adjudication_Response__c = intResponse.adjudicationResponse;
                if(String.isBlank(application.AML_Response__c )){
                    Application.AML_Response__c = intResponse.amlResponse;
                }
            }
        }
        catch(Exception e){
            //Application.Name = APP_NAME_INCOMPLETE_POWER_CURVE_ERR;
            Application.Application_Status_Last_Changed_Date__c = system.now();
            Application.Application_Status__c = 'Needs Review';
            system.debug(''+e);
        }        
        
        //Set all time stamps
        Application.Application_Status_Last_Changed_Date__c = system.now();
        Application.Decision_Timestamp__c = system.now();
        Application.Adjudication_Decision_Last_Changed_Date__c = system.now();
        Application.AML_Decision_Last_Changed_Date__c = system.now();
        Application.AML_Decision_Timestamp__c = System.now();
        
        //Fetch auto number field to populate on the records
        String ApplicationAutoNumberValue = [SELECT id, Fidem_Application_Number__c from Application__c where id =: application.id].Fidem_Application_Number__c;
        Application.Name = ApplicationAutoNumberValue;
        
        System.debug('intResponse  : '+ intResponse );
        //if current BKCP value is selected as None
        if(Application.CurrentBKCP__c == 'None'){
            
            Application.Decision__c = null;
            Application.AML_Decision__c = null;
            Application.Fraud_Flag__c = null;
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'User is not currently or have not been in a bankruptcy or consumer proposal process within the last 7 years';
        }
        else if(flagSIN == true){
        
            Application.Decision__c = null;
            Application.AML_Decision__c = null;
            Application.Fraud_Flag__c = null;
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'User is not permanent resident of Canada';
        }
        //Employment length failed
        else if(flagEmployment == true){
            Application.Decision__c = null;
            Application.AML_Decision__c = null;
            Application.Fraud_Flag__c = null;
            Application.Application_Status__c = 'System Declined';
            Application.Decision_Summary__c = 'Current and Previous Employment Length Failed';
        }
        else if (null == intResponse || String.isBlank(Application.Webservice_Response__c)) {
            // due to exception returned null
            
            Application.Application_Status__c = 'Needs Review';
            Application.CSR_Manual_Review_Reason__c = 'System Not Reachable – Adjudication';
            Application.Decision__c = 'Needs Review';
        } 
        else {
            // Set decision-related fields on Application
            //Adjudication
            Application.Decision__c = intResponse.adjudicationStatus;
            Application.Decline_Reason__c = intResponse.declineReason;
            
            Application.Decision_Summary__c = intResponse.decisionSummary;
            Application.Lender_Approved_Amount__c = intResponse.approvedAmount;
            Application.Interest_Rate__c = intResponse.approvedInterestRate;
            
            //AML
            if(flagAMLPresent == false){
                Application.AML_Decision__c = intResponse.amlStatus;
                
                if(intResponse.fraudFlag == 'N'){
                    Application.Fraud_Flag__c = 'No';
                }else if(intResponse.fraudFlag == 'Y'){
                    Application.Fraud_Flag__c = 'Yes';
                }
                Application.AML_Decision_Summary__c = intResponse.amlSummary;
                //Application.AML_Decision_Timestamp__c = intResponse.amlTimestamp;
                Application.AML_Declined_Reason__c = intResponse.amlDeclineReason;
                Application.Unique_ID_AML__c = intResponse.amlUniqueNumber;
            }
            
            Application.CSR_Manual_Review_Reason__c = intResponse.needsReviewReason;
            
            system.debug('Decision : ' + Application.Decision__c);
            system.debug('AML decision: ' + Application.AML_Decision__c );
            
            //Calculate application status
            if(Application.Decision__c == 'Approved' && Application.AML_Decision__c == 'Approved'){
                Application.Application_Status__c = 'System Approved';
                
            }
            else if(Application.Decision__c == 'Needs Review' || Application.AML_Decision__c == 'Needs Review'){
                Application.Application_Status__c = 'Needs Review';
            }
            else if(Application.Decision__c == 'Declined' || Application.AML_Decision__c == 'Declined'){
                Application.Application_Status__c = 'System Declined';
                
            }else if(Application.Decision__c == 'Approved' && String.isBlank(Application.AML_Decision__c)){
                Application.Application_Status__c = 'Needs Review';
                
            }
            
        }
        //Calculate DSR Score
        Application.DSR_Score__c = ((Application.Housing_Costs__c + Application.Monthly_Expenses__c) / Application.Gross_Monthly_Income__c)*100;
        
        try{
            ApplicationTriggerHandler.runApplicationLoadTrigger = false;
            update application;
            ApplicationTriggerHandler.runApplicationLoadTrigger = true;
            
        }catch(Exception e){
            system.debug('Exception : ' + e);
            if(e.getTypeName() == 'System.DmlException'){
                
                errorMessage = e.getDmlMessage(0);
            }else{
                errorMessage = e.getMessage();
            }
        }        
        
        progressBar = false;
        
        return null;
    }
}