/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a utility class for potential customer matching 
 *  @author : A5E Consulting
 *  @date : 03/30/2016
 *
 *  Change History:
 *
 *  Developer       Date          Description
 *  ------------------------------------------------------------------------------------------------
 *
 *  A5E Consulting 03/30/2016     Class created
 *  A5E Consulting 03/30/2016     Added populateAccountFields method to populate Person Account Fields based on corresponding Application fields
 *  A5E Consulting 03/30/2016     Added submitToPCOD method to submit Applcation to PCOD
 *  A5E Consulting 03/30/2016     Added getApplicationById method to get Applcation record based on Id
 *  A5E Consulting 03/31/2016     Added Constants
 *  A5E Consulting 04/04/2016     Added utility method for Exact Match List
 *  A5E Consulting 04/04/2016     Added utility method for uncertain Match List 
 *  A5E Consulting 05/03/2016     Added new utility method to keep the same assignment
 *  A5E Consulting 05/03/2016     Updated the SOQL queries to sort by created date 
 *  A5E Consulting 05/03/2016     Resubmit method instead of Submit  
 *  A5E Consulting 05/03/2016     Updates to  populateApplicationBasedOnDecision method
 *  A5E Consulting 06/06/2016     New formatDate method
 *************************************************************************************************/
public class PotentialMatchUtil {
    
    //Constants
    public static final String MANUAL_REVIEW_REASON_MULTIPLE_EXACT_MATCHES = 'Multiple Exact Matches';
    public static final String MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES = 'Multiple Uncertain Matches';
    public static final String APP_NAME_MANUAL_REVIEW = 'Manual Review';    
   
        
    //@future(callout=true)
    public static void assignSelectedAccountToApplication(Id accountId, Id applicationId){
       
        //Updated By A5E Consulting PVT LTD
        //Appilcation Workflow and Data Sync
        //resubmitToPCOD(getAccountById(accountId), getApplicationById(applicationId));
        
        //resubmitToPCOD(getAccountById(accountId), Utilities.getApplicationById(applicationId)); 
    }    
   
    public static void createNewAccountAndAssignToApplication(Id applicationId){
       
       RecordType personAccRecType = [ select Id from RecordType where IsPersonType = true and SObjectType = 'Account' and DeveloperName = 'Fidem_Customer'];
       Account accnt = new Account(RecordTypeId = personAccRecType.Id); 
       
        //Updated By A5E Consulting
        //Appilcation Workflow and Data Sync
        //populateAccountFieldsBasedOnApplication(accnt, getApplicationById(applicationId));
        populateAccountFieldsBasedOnApplication(accnt, Utilities.getApplicationById(applicationId));
        createNewAccountAndAssignToApplicationFuture(accnt.ID, applicationId );
    }
    
    @future(callout=true)
    public static void createNewAccountAndAssignToApplicationFuture(Id accountId, Id applicationId){       
      
        //Updated By A5E Consulting        
        //Appilcation Workflow and Data Sync
        //resubmitToPCOD(getAccountById(accountId), getApplicationById(applicationId));
        //resubmitToPCOD(getAccountById(accountId), Utilities.getApplicationById(applicationId));       
    }
    
    //Keep the same customer 
    public static void keepSameCustomer(Id applicationId){
        
        //Updated By A5E Consulting
        //Appilcation Workflow and Data Sync
        //appln = getApplicationById(applicationId);
        Application__c appln = Utilities.getApplicationById(applicationId);
         
        //Clear review flags
        appln.Needs_Manual_Review__c = false; 
        appln.Manual_Review_Reason__c = null;  
              
        //Update appln
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update appln;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;         
    }
    
    //Populate Account fields Based On Application fields
    @TestVisible
    private static void populateAccountFieldsBasedOnApplication(Account personAccount, Application__c appln){
        
        personAccount.Salutation = appln.Salutation__c;
        personAccount.FirstName = appln.First_Name__c;
        personAccount.Middle_Name__pc = appln.Middle_Name__c;
        personAccount.LastName = appln.Last_Name__c;
        personAccount.PersonBirthdate = appln.Birth_Date__c;
        personAccount.PersonMailingState = appln.Province__c;
        personAccount.PersonEmail = appln.Email_Address__c;
        personAccount.SIN__pc = appln.SIN__c;
        personAccount.Gender__pc = appln.Gender__c;
        personAccount.PersonHomePhone = appln.Home_Phone__c;
        personAccount.PersonMobilePhone = appln.Cell_Phone__c;
        personAccount.Work_Phone__pc = appln.Work_Phone__c;
        personAccount.Communication_Preference__pc = appln.Communications_Preference__c;
        personAccount.Number_of_Dependants__pc = appln.Number_of_Dependants__c;
        personAccount.Marital_Status__pc = appln.Marital_Status__c;
        personAccount.Home_Owner__pc = appln.Home_Owner__c;
        personAccount.Monthly_Home_Expense__pc = appln.Housing_Costs__c;
        personAccount.Monthly_Expense__pc = appln.Monthly_Expenses__c;
        personAccount.PersonMailingStreet = appln.Permanent_Address_Street_Number__c + ' ' + appln.Permanent_Address_Street_Name__c;
        personAccount.PersonMailingCity = appln.Permanent_Address_City__c;
        personAccount.PersonMailingState = appln.Permanent_Address_Province__c;
        personAccount.PersonMailingPostalCode = appln.Permanent_Address_PostalCode__c;

        upsert personAccount;                       
    }
    
    //Submit Application to PCOD and update application
  /*  @TestVisible
    private static void resubmitToPCOD(Account personAccount, Application__c appln) {
        
        PowerCurveWSUtil.DecisionResponse response = PowerCurveWSUtil.changeQueue(personAccount.SF_ID__c, appln, Utilities.getChannelByApplicationCompletedFrom(appln.Application_Completed_From__c));
        
        if (response == null || String.isNotBlank(response.ErrorMessage)) {
            // Some Error
        } else {            
            //Set decision-related fields on Application            
            //populateApplicationBasedOnDecision(appln, response);      
            //Updated By A5E Consulting 
            //Appilcation Workflow and Data Sync
            Utilities.updateApplicationDecisionData(appln, response, false);         
        }  
        
        //Clear review flags
        appln.Needs_Manual_Review__c = false; 
        appln.Manual_Review_Reason__c = null;  
        
        //Map Application to Account
        appln.Customer__c = personAccount.Id;  
        
        //Update appln
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update appln;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;    
    }*/
    
    //Populate Application fields Based On Decision fields
    /*
    private static void populateApplicationBasedOnDecision(Application__c appln, PowerCurveWSUtil.DecisionResponse response){        
        
        appln.Decision__c = response.DecisionResult;
        appln.Application_Status__c = response.DecisionStatus;
        appln.Decision_Timestamp__c = response.DecisionTimestamp;
    }
    */
     
    /*
    //Get Application record based on Id
    private static Application__c getApplicationById(Id applicationId) {
        
        Application__c applnDB = [SELECT Id, Customer__c, Name, SIN__c, Gender__c, Salutation__c, First_Name__c, 
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
                                        Mothers_Maiden_Name__c, Authentication_Result__c, Authentication_Choice__c, Fraud_Alert__c, Customer__r.SF_ID__c, Application_Completed_From__c, 
                                        Province__c, Number_of_Dependants__c, Monthly_Expenses__c    
                                        FROM Application__c WHERE Id =: applicationId
                                 ];    
        return applnDB;
    }  
    */
    //Get Account record based on Id
    private static Account getAccountById(Id accntId) {
        
        Account accntDB = [SELECT Id, SF_ID__c FROM Account WHERE Id =: accntId];    
        return accntDB;
    }
    
    //Utility method for Exact Match List
    public static List<Account> getExactMatchList(Application__c appln){
      
      List<Account> dbAccnts = [select Id, SF_ID__c, FirstName, LastName, PersonEmail, PersonBirthdate, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry from Account 
                                 where IsPersonAccount = true and LastName = :appln.Last_Name__c and (
                                  (SIN__pc != null and SIN__pc = :appln.SIN__c) or 
                                  (PersonBirthdate != null and PersonBirthdate = :appln.Birth_Date__c and FirstName = :appln.First_Name__c)) 
                                  AND recordType.name = 'Fidem Customer'
                                  order by createdDate desc 
                                  ];
        return dbAccnts;    
    }
    
    //Utility method for Uncertain Match List
    public static List<Account> getUncertainMatchList(Application__c appln){
                
        String firstNameSearchTerm = appln.First_Name__c.subString(0,1) + '%';
        List<Account> dbAccnts = [select Id, SF_ID__c, FirstName, LastName, PersonEmail, PersonBirthdate, PersonMailingStreet, PersonMailingCity, PersonMailingState, PersonMailingPostalCode, PersonMailingCountry from Account  
                                  where IsPersonAccount = true and LastName = :appln.Last_Name__c and 
                                  (PersonEmail != null and PersonEmail = :appln.Email_Address__c and FirstName like :firstNameSearchTerm) 
                                  AND recordType.name = 'Fidem Customer'
                                  order by createdDate desc 
                                 ];
        return dbAccnts;               
    }
    
    public static String formatDate(Date d) {
        if (d == null) {
            return null;
        }
        return Datetime.newInstance(d.year(), d.month(), d.day()).format('MM-dd-yyyy');
    }           
}