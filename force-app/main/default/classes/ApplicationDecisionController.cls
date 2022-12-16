public class ApplicationDecisionController {
    public Application_Form_Settings__c AppFormSettings {get;set;}
    public String adjudicationDecsion{get;set;}
    public String amlDecision{get;set;}
    public String applicationStatus{get;set;}
    public String applicationId {get;set;}
    
    //Decline Page updates
    public String loanType {get;set;}
    
    public Boolean cardNotInBKCP {get;set;}
    public String DECISION_ACCEPTED {get;set;} 
    public String DECISION_DECLINED {get;set;}
    public String DECISION_ERROR {get;set;}
    
    private Application__c application;

    public ApplicationDecisionController() {
        final String BKCP_NOT_DISCHARGED = 'BKCP Not Discharged';

        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        
        DECISION_ACCEPTED = 'System Approved';
        DECISION_DECLINED = 'System Declined';
        DECISION_ERROR = 'Needs Review';
        
        applicationId = ApexPages.currentPage().getParameters().get('id');
        
        //Updated By A5E Consulting
        //Appilcation Workflow and Data Sync changes
        application = Utilities.getApplicationById(applicationId);
                     
        //Decline Page updates
        loanType = application.Loan_Type__c;
        adjudicationDecsion = application.Decision__c;
        amlDecision = application.AML_Decision__c;
        if(String.isBlank(amlDecision)){
            amlDecision = '';
        }
        applicationStatus = application.Application_Status__c;
    }

}