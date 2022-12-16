public with sharing class SendAuthEmailController {
    public Boolean elgibleForEmail {get;set;}
    public String inelgibleReason {get;set;}
    
    // Constants
    public String NO_EMAIL {get;set;}
    public String AUTH_ALREADY_COMPLETED {get;set;}
    public String MISSING_LENDER_APPROVED_AMOUNT {get;set;}    
    
    //Customer Matching Updates
    //public String MARKED_MANUAL_REVIEW {get;set;}  
    
    private String AUTH_CHOICE_COMPLETED = 'Completed';
    private String AUTH_RESULT_PASSED = 'Passed';
    private String EMAIL_AUTH_STATUS_SENT = 'Sent to Applicant';  
    
    //Email Authentication updates - PassedNoFraud
    private String AUTH_RESULT_PASSED_NO_FRAUD = 'PassedNoFraud';
    
    //Added by A5E Consulting
    //Email Authentication
    private String EMAIL_SENT_AUTH_STATUS = 'EmailSent';   
    
    private Application__c application;
    private Application_Form_Settings__c AppFormSettings;
    
    public SendAuthEmailController() {
        String applicationId = ApexPages.currentPage().getParameters().get('id');
        
        
        // Updated By A5E Consulting PVT LTD
        // Appilcation Workflow and Data Sync
        application = Utilities.getApplicationById(applicationId); 
        // application = getApplicationById(applicationId);
        
        System.debug('application Id : '+application.Id);
        System.debug('application Name : '+application.Name);

        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        
        elgibleForEmail = false;
        
        // Set constants
        NO_EMAIL = 'No email';
        AUTH_ALREADY_COMPLETED = 'Auth already completed';
        MISSING_LENDER_APPROVED_AMOUNT = 'Lender Approved Amount is not Available';
        
        if (String.isBlank(application.Email_Address__c)) {
            // No email
            inelgibleReason = NO_EMAIL;
            
        } 
        //Email Authentication updates - PassedNoFraud
        else if (application.Authentication_Choice__c == AUTH_CHOICE_COMPLETED || application.Authentication_Result__c == AUTH_RESULT_PASSED || application.Authentication_Result__c == AUTH_RESULT_PASSED_NO_FRAUD){
            // Authentication process already complete
            inelgibleReason = AUTH_ALREADY_COMPLETED;
        } 
        
        //Email Authentication changes
        else if (application.Lender_Approved_Amount__c == null || Application.Lender_Approved_Amount__c == 0){
            inelgibleReason = MISSING_LENDER_APPROVED_AMOUNT;
        }
        else {
            // Elgible
            elgibleForEmail = true;
        }
    }
    
    /**
     *  @description Sets fields on application record that will trigger auth email workflow
     *  @author      Ahsan Butt, Traction On Demand
     *  @date        2016-01-10
     */
     public void invokeEmail() {
        if (elgibleForEmail == true) {
            // Generate email auth token using MD5 hash of appId and current date-time
            Datetime current = Datetime.now();
            String hashString = application.Id + current.formatGmt('yyyyMMddHHmmssSSS');
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            
            application.Email_Auth_Token__c = EncodingUtil.convertToHex(hash);
            // system.debug('hexDigest: ' + hexDigest );
            
            application.Email_Authentication_Sent_Date__c = current;
            application.Email_Authentication_Status__c = EMAIL_AUTH_STATUS_SENT;
            
            // Calculate expiration date
            Integer expiryDays = Integer.valueOf(AppFormSettings.Email_Authentication_Expiry_Days__c);
            application.Email_Authentication_Expiration_Date__c = current.addDays(expiryDays);
            
            //Updated by A5E Consulting
            //Email Authentication
            //Set 'EmailSent' as Authentication Status 
            application.Authentication_Result__c = EMAIL_SENT_AUTH_STATUS;
        
            //Resubmit the application to PCOD
            PowerCurveWSUtil.DecisionResponse response = PowerCurveWSUtil.changeQueue(application.Customer__r.SF_ID__c, application, Utilities.getChannelByApplicationCompletedFrom(application.Application_Completed_From__c));
            if (response == null || String.isNotBlank(response.ErrorMessage)) {
                // Some Error - what to do
                //appln.Name = APP_NAME_INCOMPLETE_POWER_CURVE_ERR;
            
            } else {
                // Set decision-related fields on Application            
                //application.Decision__c = response.DecisionResult;
                //application.Application_Status__c = response.DecisionStatus;
                //application.Decision_Timestamp__c = response.DecisionTimestamp; 
                
                //Updated By A5E Consulting 
                //Appilcation Workflow and Data Sync
                Utilities.updateApplicationDecisionData(application, response, false);                       
            }    
            
            ApplicationTriggerHandler.runApplicationLoadTrigger = false;
            update application;
            ApplicationTriggerHandler.runApplicationLoadTrigger = true;  
        }
     }
    
    /**
     *  @description Gets Application with given Id if exists
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2015-12-30
     */
    /* 
    private Application__c getApplicationById(Id applicationId) {
        List<Application__c> applications = [SELECT Id, Authentication_Choice__c, Authentication_Result__c, Email_Address__c, Email_Authentication_Sent_Date__c, Email_Authentication_Status__c, Email_Auth_Token__c, Needs_Manual_Review__c  FROM Application__c WHERE Id =: applicationId];
        
        return (applications.size() > 0) ? applications[0] : null;
    }
    */
     /*
    //Get Application based on Record ID
    private Application__c getApplicationById(Id applicationId) {
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
                Mothers_Maiden_Name__c, Authentication_Result__c, Authentication_Choice__c, Fraud_Alert__c, PcoD_Bankruptcy_State__c,
                Total_Credit_Worthiness__c, Max_Credit_Card_Allowed_Amount__c, Customer__r.SF_ID__c,  
                Needs_Manual_Review__c, Email_Authentication_Sent_Date__c, Email_Authentication_Status__c,
                Email_Auth_Token__c, Lender_Approved_Amount__c, Final_Status__c, Application_Completed_From__c              
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }*/    
}