/**
 *  @description Controller for ...
 *  @author      Ahsan Butt, Traction on Demand.
 *  @date        2016-01-06
 */
public with sharing class AuthCompleteController {
    public Application_Form_Settings__c AppFormSettings {get;set;}
    public String decision { get;set; }
    public Boolean fraud { get;set; }
    public String loanType { get;set; }
    
    //Email Authentication updates - PassedNoFraud
    public Boolean fraudTrueNA { get;set; }

    public String FAILED {get;set;}
    public String PASSED {get;set;}
    public String LOAN {get;set;}
    public String CREDIT {get;set;}
    
    //Email Authentication updates - PassedNoFraud
    public String PASSED_NO_FRAUD {get;set;}
    
    public Application__c app;

    public AuthCompleteController() {
        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        String applicationId = ApexPages.currentPage().getParameters().get('id');
        
        /** Updated By A5E Consulting PVT LTD
         *  @Project Appilcation Workflow and Data Sync
         *  @date        22th July 2016
        */
        app = Utilities.getApplicationById(applicationId);
        /*******************************************************************************************************/
        
        //TODO
        //app = getApplicationById(applicationId);

        //Commented by A5E Consulting
        //Email Athentication Changes
        //PowerCurveWSUtil.Channel channel = Utilities.getChannelByProfile();
        //PowerCurveWSUtil.changeQueue(app.Customer__r.SF_ID__c, app, channel);        
        PowerCurveWSUtil.DecisionResponse response = PowerCurveWSUtil.changeQueue(app.Customer__r.SF_ID__c, app, Utilities.getChannelByProfile());
        
        if (response == null || String.isNotBlank(response.ErrorMessage)) {
            // Some Error                   
        } else {
            // Set decision-related fields on Application            
            //app.Decision__c = response.DecisionResult;
            //app.Application_Status__c = response.DecisionStatus;
            //app.Decision_Timestamp__c = response.DecisionTimestamp;
            
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            Utilities.updateApplicationDecisionData(app, response, false);                         
        }   
        
        fraud = app.Fraud_Alert__c == 'TRUE';
        loanType = app.Loan_Type__c;
        decision = app.Authentication_Result__c;
        
        //Email Authentication updates - PassedNoFraud
        fraudTrueNA = app.Fraud_Alert__c == 'True-N/A';

        FAILED = 'Failed';
        PASSED = 'Passed';
        
        //Email Authentication updates - PassedNoFraud
        PASSED_NO_FRAUD = 'PassedNoFraud';

        LOAN = 'Affirm Financial Term Loan';
        CREDIT = 'Affirm Financial MasterCard';        
    }
    
    public void updateApplication(){
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update app;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
    } 
    
    /**
     *  @description Gets Application with given Id if exists
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-01-04
     */
     
    //TODO 
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
                Mothers_Maiden_Name__c, Authentication_Result__c, Authentication_Choice__c, Fraud_Alert__c, Customer__r.SF_ID__c, Needs_Manual_Review__c 
            FROM Application__c WHERE Id =: applicationId
        ];
    
        return (applications.size() > 0) ? applications[0] : null;
    }
    */
    
}