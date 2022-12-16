public with sharing class trac_UserVerificationErrorController {
    
    public Application__c App {get;set;}
    public Application_Form_Settings__c AppFormSettings {get;set;}
  
    //Error message changes
    //Added by A5E Consulting
    public String noBureauHit {get;set;}
    public String thinBureauHit {get;set;}
    public String toManyAttempts {get;set;}
    public String submittedExamAgain {get;set;}
    public String technicalIssue {get;set;}
    public String errorMessage {get;set;}
        
    public trac_UserVerificationErrorController() {
        
        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        String applicationId = ApexPages.currentPage().getParameters().get('id');
        
        // Updated By A5E Consulting PVT LTD
        // Appilcation Workflow and Data Sync
         
        App = Utilities.getApplicationById(applicationId);
        // App = getApplicationById(applicationId);
        
        System.debug('trac_UserVerificationErrorController applicationId :'+applicationId);
            
        //Error message changes
        //Updated by A5E Consulting
        noBureauHit = TransUnionWSUtil.ERROR_MESSAGE_NO_BUREAU_HIT;
        thinBureauHit = TransUnionWSUtil.ERROR_MESSAGE_THIN_BUREAU_HIT;
        toManyAttempts =  TransUnionWSUtil.ERROR_MESSAGE_TOO_MANY_ATTEMPTS;   
        submittedExamAgain = TransUnionWSUtil.ERROR_MESSAGE_SUBMITTED_EXAM_AGAIN;
        technicalIssue = TransUnionWSUtil.ERROR_MESSAGE_TECHNICAL_ISSUE;
        
        errorMessage = ApexPages.currentPage().getParameters().get('errorMessage');
    
        System.debug('trac_UserVerificationErrorController errorMessage :'+errorMessage);
        
        //Commented by A5E Consulting
        //Email Athentication Changes
        //PowerCurveWSUtil.Channel channel = Utilities.getChannelByProfile();
        //PowerCurveWSUtil.changeQueue(App.Customer__r.SF_ID__c, App, channel);       
        PowerCurveWSUtil.DecisionResponse response = PowerCurveWSUtil.changeQueue(App.Customer__r.SF_ID__c, App, Utilities.getChannelByProfile());
                
        if (response == null || String.isNotBlank(response.ErrorMessage)) {
            // Some Error
        
        } else {
            // Set decision-related fields on Application            
            //App.Decision__c = response.DecisionResult;
            //App.Application_Status__c = response.DecisionStatus;
            //App.Decision_Timestamp__c = response.DecisionTimestamp;   
            
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            Utilities.updateApplicationDecisionData(App, response, false);                      
        } 
    }
  
    public void updateApplication(){
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update App;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true; 
    }

    /**
     *  @description Gets Application with given Id if exists
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-01-04
     */
     /*
    private static Application__c getApplicationById(Id applicationId) {
        List<Application__c> applications = [
            SELECT Id, Customer__c, Name, SIN__c, Gender__c, Salutation__c, First_Name__c, 
                Middle_Name__c, Last_Name__c, Birth_Date__c, Current_BKCP__c, Marital_Status__c, Home_Phone__c, Cell_Phone__c, Work_Phone__c, 
                Email_Address__c, Communications_Preference__c, Permanent_Address_Unit_Number__c, Permanent_Address_Street_Number__c, 
                Permanent_Address_Street_Name__c, Permanent_Address_City__c, Permanent_Address_Province__c, Permanent_Address_PostalCode__c, 
                Years_At_Permanent_Address__c, Months_At_Permanent_Address__c, Home_Owner__c, Housing_Costs__c, 
                Previous_Address_Unit_Number__c, Previous_Address_Street_Number__c, Previous_Address_Street_Name__c, Previous_Address_City__c, 
                Previous_Address_Province__c, Previous_Address_PostalCode__c, Years_At_Previous_Address__c, Months_At_Previous_Address__c, 
                Employment_Status__c, Employer_Name__c, Occupation__c, Employment_Years__c, Employment_Months__c, Gross_Monthly_Income__c, Employer_Unit_Number__c, 
                Employer_Street_Number__c, Employer_Street_Name__c, Employer_City__c, Employer_Province__c, Employer_PostalCode__c, Employer_Phone__c, 
                Requested_Credit_Limit__c,Previous_Employer_name__c, Previous_Employment_Months__c, Previous_Employment_Years__c,Previous_Employer_Unit_Number__c,
                Previous_Employer_Street_Number__c,Previous_Employer_Street_Name__c, Previous_Employer_City__c,Previous_Employer_Province__c,
                Previous_Employer_PostalCode__c, Previous_Gross_Monthly_Income__c, Offer_Code__c, Offer_Code_Origination_System_Id__c, Loan_Type__c,
                Mothers_Maiden_Name__c, Authentication_Result__c, Authentication_Choice__c, Fraud_Alert__c, Customer__r.SF_ID__c
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }
    */
}