public class Utilities {
    
    public static final Set<String> APP_ACCEPTED_DECISIONS = new Set<String>{'Approved', 'Auto App', 'Completed', 'Appr OfferCd', 'Appr Not Dis'};
    
    private static final String APP_COMPLETED_FROM_INTERNAL = 'Internal';
    private static final String APP_COMPLETED_FROM_EXTERNAL = 'External';
    public static Boolean runAccountJudgmentTrigger = true;
    
    public static PowerCurveWSUtil.Channel getChannelByProfile() {
        return (getInternalOrExternal() == APP_COMPLETED_FROM_EXTERNAL) ?   PowerCurveWSUtil.Channel.SFExternal : PowerCurveWSUtil.Channel.SFInternal;
    }

    public static String getInternalOrExternal() {
        
        Application_Form_Settings__c appFormSettings = Application_Form_Settings__c.getOrgDefaults();
        Id siteProfileId = (Id)AppFormSettings.Site_Profile_Id__c;
        Id userVerificationSiteProfileId = (Id)AppFormSettings.User_Verification_Site_Profile_Id__c;

        Id pId = (Id)UserInfo.getProfileId();
        return (pId == siteProfileId || pId == userVerificationSiteProfileId)   ?   APP_COMPLETED_FROM_EXTERNAL : APP_COMPLETED_FROM_INTERNAL;
    }
    
    //Updated by A5E Consulting
    //Ingest flow - Customer Matching Changes
    public static PowerCurveWSUtil.Channel getChannelByApplicationCompletedFrom(String applicationCompletedFrom) {
        return (applicationCompletedFrom == APP_COMPLETED_FROM_EXTERNAL)    ?   PowerCurveWSUtil.Channel.SFExternal : PowerCurveWSUtil.Channel.SFInternal;
    }
    
    //Added by A5E Consulting
    //Appilcation Workflow and Data Sync
    public static Application__c getApplicationById(Id applicationId) {
        
        Application__c appln = null;
        
        if(applicationId != null){
            
            appln = [SELECT Id,Name, Middle_Name__c,Email_Address__c,Permanent_Address_Street_Name__c,Years_At_Permanent_Address__c,Previous_Address_Unit_Number__c,
                                                Employment_Status__c,Employer_Street_Number__c,Previous_Employer_Street_Number__c,Previous_Employer_PostalCode__c,Mothers_Maiden_Name__c,
                                                Province__c,Total_Credit_Worthiness__c,Email_Authentication_Sent_Date__c,Lender_Approved_Amount__c,
                                                Previous_Address_Province__c,Requested_Credit_Limit__c,Interest_Rate__c,
                                                Email_Auth_Token__c,Credit_Score__c, AML_Decision__c, Primary_Phone_Number__c, CurrentBKCP__c, Politically_Exposed_Foreign_Person__c, Third_Party_Direction__c,
                                                SIN__c,Current_BKCP__c,Permanent_Address_Street_Number__c,Permanent_Address_PostalCode__c,Housing_Costs__c,Previous_Address_City__c,Months_At_Previous_Address__c,
                                                Employment_Years__c,Employer_Province__c,Previous_Employment_Years__c,Previous_Employer_Province__c,Offer_Code_Origination_System_Id__c,Fraud_Alert__c,
                                                Application_Completed_From__c,Birth_Date__c,Permanent_Address_Unit_Number__c,Permanent_Address_Province__c,Home_Owner__c,Previous_Address_Street_Name__c,
                                                Years_At_Previous_Address__c,Occupation__c,Employer_City__c,Previous_Employment_Months__c,Previous_Employer_City__c,Offer_Code__c,Authentication_Choice__c,Monthly_Expenses__c,
                                                Customer__r.SF_ID__c,Email_Authentication_Status__c,Customer__c,Last_Name__c,Communications_Preference__c,Permanent_Address_City__c,
                                                Months_At_Permanent_Address__c,Previous_Address_Street_Number__c,Previous_Address_PostalCode__c,Employer_Name__c,Employer_Street_Name__c,Previous_Employer_name__c,
                                                Previous_Employer_Street_Name__c,Previous_Gross_Monthly_Income__c,Authentication_Result__c,Number_of_Dependants__c,Max_Credit_Card_Allowed_Amount__c,
                                                Gender__c,Marital_Status__c,Salutation__c,Home_Phone__c,First_Name__c,Cell_Phone__c,Work_Phone__c,Employment_Months__c,Employer_PostalCode__c,Previous_Employer_Unit_Number__c,Loan_Type__c,
                                                PcoD_Bankruptcy_State__c,Gross_Monthly_Income__c,Employer_Phone__c,Employer_Unit_Number__c ,
                                                Program_Id__c,Program_Name__c,Program_Product_Id__c,Program_Product_Name__c,Program_Product_Tier_Name__c,Program_Tier_Id__c,Sales_Channel_Id__c,Sales_Channel_Name__c,
                                                Permanent_Address_Type__c, Current_Income_Interval__c,Previous_Income_Interval__c,Previous_Address_Type__c, Decision__c, Application_Status__c, Final_Status__c,  
                                                Preferred_language__c,Decision_Timestamp__c,Decision_Summary__c,DSR_Score__c,Scorecard_Program__c, 
                                                Accounts_On_File__c, Revolving_Debt_Utilization__c, Bankruptcies__c, Month_Since_BK_Discharge__c, Bad_Debt_Write_Off__c,Months_Since_Bad_Debt_Write_Off__c, 
                                                Employer_Address_Type__c, Previous_Employer_Address_Type__c,
                                                Permanent_Address_PO_Box__c, Previous_Address_PO_Box__c, Employer_PO_Box__c, Previous_Employer_PO_Box__c, 
                                                //Underwriting Rules for 4 Pillars - Updates for Tier Type 
                                                Referral_Id__c, Strategy_Tier__c, 
                                                //Auto vs Manual
                                                Initial_Application_Status__c, Initial_Decision__c,Verification_Status__c    
                                                FROM Application__c WHERE Id =: applicationId];
           
            //Added by A5E Consulting 
            //Appilcation Workflow and Data Sync
            //For Default values for existing Application Records
            if(String.isBlank(appln.Program_Id__c)){
                updateFixedApplicationData(appln);
            }
        }        
        
        return appln;//(applications.size() > 0) ? applications[0] : null;    
    }
    
    //Added by A5E Consulting
    //Appilcation Workflow and Data Sync
    //Update Fixed Application Data    
    public static void updateFixedApplicationData(Application__c appln){
    
        if(appln.Loan_Type__c != null){
            
            if (appln.Loan_Type__c.contains('Term Loan')) {
                    
                appln.Program_Id__c = '109736';
                appln.Program_Name__c = 'Term Loan';
                appln.Program_Tier_Id__c = '1400';
                appln.Program_Product_Tier_Name__c = 'Term Loan';
                appln.Program_Product_Id__c = '5639';
                appln.Program_Product_Name__c = 'Term Loan';   
            
            }
            else if (appln.Loan_Type__c.contains('MasterCard')) {
                    
                appln.Program_Id__c = '73318';
                appln.Program_Name__c = 'Credit Card';
                appln.Program_Tier_Id__c = '1301';
                appln.Program_Product_Tier_Name__c = 'MasterCard';
                appln.Program_Product_Id__c = '3779';
                appln.Program_Product_Name__c = 'Affirm Card';  
            
            }
        }
        else{
            
            appln.Program_Id__c = '73318';
            appln.Program_Name__c = 'Credit Card';
            appln.Program_Tier_Id__c = '1301';
            appln.Program_Product_Tier_Name__c = 'MasterCard';
            appln.Program_Product_Id__c = '3779';
            appln.Program_Product_Name__c = 'Affirm Card';  
        
        }
        
        if (appln.Application_Completed_From__c == 'SFInternal') {
            appln.Sales_Channel_Id__c = '217';
            appln.Sales_Channel_Name__c = 'SFIntApp';
        } else {
            appln.Sales_Channel_Id__c = '216';
            appln.Sales_Channel_Name__c = 'SFExtApp';
        }       
        
        //Address Type
        appln.Permanent_Address_Type__c = 'Physical';
        if (String.isNotBlank(appln.Previous_Address_City__c)) {
            appln.Previous_Address_Type__c = 'Physical';
        }
        
        //Income Interval
        appln.Current_Income_Interval__c = 'Monthly';
        appln.Employer_Address_Type__c = 'Physical';
        if (String.isNotBlank(appln.Previous_Employer_Name__c)) {
            appln.Previous_Income_Interval__c = 'Monthly';
            appln.Previous_Employer_Address_Type__c = 'Physical';
        }        
    }
    
    
    //Addedby A5E Consulting
    //Appilcation Workflow and Data Sync
    public static void updateApplicationDecisionData(Application__c appln, PowerCurveWSUtil.DecisionResponse response, Boolean isSubmit){
        
        if(isSubmit){
            appln.Name = response.customerRequestId;
            appln.Application_Number__c = response.customerRequestId;
            appln.Max_Credit_Card_Allowed_Amount__c = response.maxCreditCardAllowedAmount;
            appln.Total_Credit_Worthiness__c = response.totalCreditWorthiness;            
            appln.Fraud_Alert__c = response.fraudAlert;
            appln.PcoD_Bankruptcy_State__c = response.applicantType; 
            
            //maxLoanAmount only for Term Loan Application
            if(response.maxLoanAmount != null){
                appln.Max_Loan_Amount__c = response.maxLoanAmount;
            }
            
            //Automatic vs Manual Processed On Application Records
            appln.Initial_Decision__c = response.decision;
            appln.Initial_Application_Status__c = response.applicationStatus;            
        }
        
        appln.Decision__c = response.decision;
        appln.Application_Status__c = response.applicationStatus;      
        
        
        appln.Decision_Timestamp__c = response.decisionTimestamp; 
        
        //PCOD Decision
        appln.Decision_Result__c = response.decisionResult; 
        appln.Decision_Status__c = response.decisionStatus; 
        
        appln.Housing_Costs__c = response.monthlyHousingCost;
        //appln.Monthly_Expenses__c = response.monthlyExpenses;
        appln.Gross_Monthly_Income__c = response.grossMonthlyIncome;
        appln.Credit_Score__c = response.creditScore;
        appln.DSR_Score__c = response.dsrScore;
        appln.Scorecard_Program__c = response.scorecardProgram;
        appln.Decision_Summary__c = response.decisionSummary;   
                
        //Credit Bureau Summary  
        appln.Accounts_On_File__c = response.accountsOnFile;  
        appln.Revolving_Debt_Utilization__c = response.revolvingDebtUtilization;  
        appln.Bankruptcies__c = response.bankruptcies;  
        appln.Month_Since_BK_Discharge__c = response.monthSinceBKDischarge;  
        appln.Bad_Debt_Write_Off__c = response.badDebtWriteOff;  
        appln.Months_Since_Bad_Debt_Write_Off__c = response.monthsSinceBadDebtWriteOff;  
        //system.debug('CheckresponseData' +  response.ApplicationstatusCreditbeurue);
        //appln.Application_Status__c  = response.ApplicationstatusCreditbeurue;
        //Underwriting Rules for 4 Pillars - Updates for Tier Type 
        String strtTier = 'Default';
        if(String.isNotBlank(response.appStrategyTier)){
            strtTier = response.appStrategyTier;
        }
        appln.Strategy_Tier__c = strtTier;
    }
    
    //Added  by A5E Consulting
    //Appilcation Workflow and Data Sync for REDECIDE
    public static void updateApplicationRedecideDecisionData(Application__c appln, PowerCurveWSUtil.DecisionResponse response){
    
        String logHistory = '';
        
        //PCOD Decision
        appln.Decision_Result__c = response.decisionResult; 
        appln.Decision_Status__c = response.decisionStatus; 
        
        if(!String.isBlank(response.decision) && (!response.decision.equalsIgnoreCase(appln.Decision__c))){
            logHistory += 'Decision:  Old Value = '+ appln.Decision__c +' & New Value = '+response.decision+'\n';
            appln.Decision__c = response.decision;
        }
        
        if(!String.isBlank(response.applicationStatus)  && (!response.applicationStatus.equalsIgnoreCase(appln.Application_Status__c))){
            logHistory += 'Application Status:  Old Value = '+ appln.Application_Status__c +' &  New Value = '+response.applicationStatus+'\n';
            appln.Application_Status__c = response.applicationStatus;
        }
        
        if(response.DecisionTimestamp != null){            
            logHistory += 'Decision Timestamp:  Old Value = '+ appln.Decision_Timestamp__c +' & New Value = '+response.DecisionTimestamp+'\n';
            appln.Decision_Timestamp__c = response.DecisionTimestamp;            
        }
        
        if(!String.isBlank(response.decisionSummary)){
            appln.Decision_Summary__c = response.decisionSummary;
        }
        
        if(!String.isBlank(response.firstName) && (!response.firstName.equalsIgnoreCase(appln.First_Name__c))){
            logHistory += 'First Name:  Old Value = '+ appln.First_Name__c +' &  New Value = '+response.firstName+'\n';
            appln.First_Name__c = response.firstName;
        }
        
        if(!String.isBlank(response.middleName) && (!response.middleName.equalsIgnoreCase(appln.Middle_Name__c))){
            logHistory += 'Middle Name:  Old Value = '+ appln.Middle_Name__c +' &  New Value = '+response.middleName+'\n';
            appln.Middle_Name__c = response.middleName;
        }
        
        if(!String.isBlank(response.lastName) && (!response.lastName.equalsIgnoreCase(appln.Last_Name__c))){
            logHistory += 'Last Name:  Old Value = '+ appln.Last_Name__c +' &  New Value = '+response.lastName+'\n';
            appln.Last_Name__c = response.lastName;
        }
        
        if(!String.isBlank(response.sin) && (!response.sin.equalsIgnoreCase(appln.SIN__c))){
            logHistory += 'SIN:  Old Value = '+ appln.SIN__c +' &  New Value = '+response.sin+'\n';
            appln.SIN__c = response.sin;
        }
        
         if(response.dateOfBirth != null && appln.Birth_Date__c != response.dateOfBirth ){
            logHistory += 'Birth Date:  Old Value = '+ appln.Birth_Date__c +' &  New Value = '+response.dateOfBirth+'\n';
            appln.Birth_Date__c = response.dateOfBirth;
        } 
        
        if(!String.isBlank(response.email) && (!response.email.equalsIgnoreCase(appln.Email_Address__c))){
            logHistory += 'Email Address:  Old Value = '+ appln.Email_Address__c +' &  New Value = '+response.email+'\n';
            appln.Email_Address__c = response.email;
        }
        
        if(!String.isBlank(response.gender) && (!response.gender.equalsIgnoreCase(appln.Gender__c)) ){
            logHistory += 'Gender:  Old Value = '+ appln.Gender__c +' &  New Value = '+response.gender+'\n';
            appln.Gender__c = response.gender;
        }
                
        if(!String.isBlank(response.maritalStatus) && (!response.maritalStatus.equalsIgnoreCase(appln.Marital_Status__c)) ){
            logHistory += 'Marital Status:  Old Value = '+ appln.Marital_Status__c +' &  New Value = '+response.maritalStatus+'\n';
            appln.Marital_Status__c = response.maritalStatus;
        } 
        
        if(!String.isBlank(response.preferredLanguage) && (!response.preferredLanguage.equalsIgnoreCase(appln.Decision__c))){
            logHistory += 'Preferred Language:  Old Value = '+ appln.Preferred_language__c +' &  New Value = '+response.preferredLanguage+'\n';
            appln.Preferred_language__c = response.preferredLanguage;
        }
        
        if(!String.isBlank(response.preferredMethod) && (!response.preferredMethod.equalsIgnoreCase(appln.Communications_Preference__c)) ){
            logHistory += 'Communications Preference:  Old Value = '+ appln.Communications_Preference__c  +' &  New Value = '+response.preferredMethod+'\n';
            appln.Communications_Preference__c = response.preferredMethod;
        }
        
        //Street Number        
        if(!String.isBlank(response.streetNumber) && (!response.streetNumber.equalsIgnoreCase(appln.Permanent_Address_Street_Number__c)) ){
            logHistory += 'Permanent Address Street Number:  Old Value = '+ appln.Permanent_Address_Street_Number__c +' &  New Value = '+response.streetNumber+'\n';
            appln.Permanent_Address_Street_Number__c = response.streetNumber;
        }
        
        //poBox
        if(!String.isBlank(response.poBox) && (!response.poBox.equalsIgnoreCase(appln.Permanent_Address_PO_Box__c)) ){
            logHistory += 'Permanent Address PO Box:  Old Value = '+ appln.Permanent_Address_PO_Box__c +' &  New Value = '+response.poBox+'\n';
            appln.Permanent_Address_PO_Box__c = response.poBox;
        }
        
        if(!String.isBlank(response.streetName) && (!response.streetName.equalsIgnoreCase(appln.Permanent_Address_Street_Name__c)) ){
            logHistory += 'Permanent Address Street Name:  Old Value = '+ appln.Permanent_Address_Street_Name__c +' &  New Value = '+response.streetName+'\n';
            appln.Permanent_Address_Street_Name__c = response.streetName;
        }
        
        if(!String.isBlank(response.suiteNumber) && (!response.suiteNumber.equalsIgnoreCase(appln.Permanent_Address_Unit_Number__c)) ){
            logHistory += 'Permanent Address Unit Number:  Old Value = '+ appln.Application_Status__c +' &  New Value = '+response.suiteNumber+'\n';
            appln.Permanent_Address_Unit_Number__c = response.suiteNumber; 
        }
        
        if(!String.isBlank(response.city) && (!response.city.equalsIgnoreCase(appln.Permanent_Address_City__c)) ){
            logHistory += 'Permanent Address City:  Old Value = '+ appln.Permanent_Address_City__c +' &  New Value = '+response.city+'\n';
            appln.Permanent_Address_City__c = response.city;
        }
             
        if(!String.isBlank(response.provinceCode) && (!response.provinceCode.equalsIgnoreCase(appln.Permanent_Address_Province__c)) ){
            logHistory += 'Permanent Address Province:  Old Value = '+ appln.Application_Status__c +' &  New Value = '+response.provinceCode+'\n';
            appln.Permanent_Address_Province__c = response.provinceCode;
        }
        
        if(!String.isBlank(response.postalCode) && (!response.postalCode.equalsIgnoreCase(appln.Permanent_Address_PostalCode__c)) ){
            logHistory += 'Permanent Address PostalCode:  Old Value = '+ appln.Permanent_Address_PostalCode__c +' &  New Value = '+response.postalCode+'\n';
            appln.Permanent_Address_PostalCode__c = response.postalCode;
        }
        
        if(response.lengthOfResidenceYears != null && appln.Years_At_Permanent_Address__c!=response.lengthOfResidenceYears ){
            logHistory += 'Years At Permanent Address:  Old Value = '+ appln.Years_At_Permanent_Address__c +' &  New Value = '+response.lengthOfResidenceYears+'\n';
            appln.Years_At_Permanent_Address__c = response.lengthOfResidenceYears;
        } 
         
        if(response.lengthOfResidenceMonths != null && appln.Months_At_Permanent_Address__c != response.lengthOfResidenceMonths){
            logHistory += 'Months At Permanent Address:  Old Value = '+ appln.Months_At_Permanent_Address__c +' &  New Value = '+response.lengthOfResidenceMonths+'\n';
            appln.Months_At_Permanent_Address__c = response.lengthOfResidenceMonths; 
        }         
        
        if(!String.isBlank(response.residentialStatus) && (!response.residentialStatus.equalsIgnoreCase(appln.Home_Owner__c)) ){
            logHistory += 'Home Owner:  Old Value = '+ appln.Home_Owner__c+' &  New Value = '+response.residentialStatus+'\n';
            appln.Home_Owner__c = response.residentialStatus;
        } 
        
        //Employer Information
        if(!String.isBlank(response.employerName) && (!response.employerName.equalsIgnoreCase(appln.Employer_Name__c)) ){
            logHistory += 'Employer Name:  Old Value = '+ appln.Employer_Name__c +' &  New Value = '+response.employerName+'\n';
            appln.Employer_Name__c = response.employerName;
        } 
        
        if(!String.isBlank(response.employerPhone) && (!response.employerPhone.equalsIgnoreCase(appln.Employer_Phone__c)) ){
            logHistory += 'Employer Phone:  Old Value = '+ appln.Employer_Phone__c +' &  New Value = '+response.employerPhone+'\n';
            appln.Employer_Phone__c = response.employerPhone;
        } 
        
        if(!String.isBlank(response.employerStreetName) && (!response.employerStreetName.equalsIgnoreCase(appln.Employer_Street_Name__c)) ){
            logHistory += 'Employer Street Name:  Old Value = '+ appln.Employer_Street_Name__c +' &  New Value = '+response.employerStreetName+'\n';
            appln.Employer_Street_Name__c = response.employerStreetName;
        } 
        
        if(!String.isBlank(response.employerStreetNumber) && (!response.employerStreetNumber.equalsIgnoreCase(appln.Employer_Street_Number__c))){
            logHistory += 'Employer Street Number:  Old Value = '+ appln.Employer_Street_Number__c +' &  New Value = '+response.employerStreetNumber+'\n';
            appln.Employer_Street_Number__c = response.employerStreetNumber;
        } 
        
        if(!String.isBlank(response.employerUnitNumber) && (!response.employerUnitNumber.equalsIgnoreCase(appln.Employer_Unit_Number__c))){
            logHistory += 'Employer Unit Number:  Old Value = '+ appln.Employer_Unit_Number__c +' &  New Value = '+response.employerUnitNumber+'\n';
            appln.Employer_Unit_Number__c = response.employerUnitNumber;
        }
        
        if(!String.isBlank(response.employerCity) && (!response.employerCity.equalsIgnoreCase(appln.Employer_City__c)) ){
            logHistory += 'Employer City:  Old Value = '+ appln.Employer_City__c +' &  New Value = '+response.employerCity+'\n';
            appln.Employer_City__c = response.employerCity;
        }
        
        if(!String.isBlank(response.employerProvinceCode) && (!response.employerProvinceCode.equalsIgnoreCase(appln.Employer_Province__c)) ){
            logHistory += 'Employer Province:  Old Value = '+ appln.Employer_Province__c +' &  New Value = '+response.employerProvinceCode+'\n';
            appln.Employer_Province__c = response.employerProvinceCode;
        }
        
        if(!String.isBlank(response.employerPostalCode) && (!response.employerPostalCode.equalsIgnoreCase(appln.Employer_PostalCode__c))){
            logHistory += 'Employer PostalCode:  Old Value = '+ appln.Employer_PostalCode__c +' &  New Value = '+response.employerPostalCode+'\n';
            appln.Employer_PostalCode__c = response.employerPostalCode;
        }
       
        if(response.employmentYears != null && appln.Employment_Years__c != response.employmentYears){
            logHistory += 'Employment Years:  Old Value = '+ appln.Employment_Years__c +' &  New Value = '+response.employmentYears+'\n';
            appln.Employment_Years__c = response.employmentYears;
        }
        
        if(response.employmentMonths != null && response.employmentMonths != appln.Employment_Months__c){
            logHistory += 'Employment Months:  Old Value = '+ appln.Employment_Months__c +' &  New Value = '+response.employmentMonths+'\n';
            appln.Employment_Months__c = response.employmentMonths;
        }
        
        if(response.grossMonthlyIncome != null && response.grossMonthlyIncome != appln.Gross_Monthly_Income__c){
            logHistory += 'Gross Monthly Income:  Old Value = '+ appln.Gross_Monthly_Income__c +' & New Value = '+response.grossMonthlyIncome+'\n';
            appln.Gross_Monthly_Income__c = response.grossMonthlyIncome;
        }
         
        if(!String.isBlank(response.employmentStatus) && (!response.employmentStatus.equalsIgnoreCase(appln.Employment_Status__c)) ){
            logHistory += 'Employment Status:  Old Value = '+ appln.Employment_Status__c+' &  New Value = '+response.employmentStatus+'\n';
            appln.Employment_Status__c = response.employmentStatus;
        }
        
        /*
        //Approval Amount Information.
        if(response.requestedCreditLimit != null && appln.Requested_Credit_Limit__c != response.requestedCreditLimit){
            logHistory += 'Requested Credit Limit:  Old Value = '+ appln.Requested_Credit_Limit__c +' &  New Value = '+response.requestedCreditLimit+'\n';
            appln.Requested_Credit_Limit__c = response.requestedCreditLimit;
        }
        */
        
        if(response.MaxCreditCardAllowedAmount != null &&  response.MaxCreditCardAllowedAmount != appln.Max_Credit_Card_Allowed_Amount__c){
            logHistory += 'Max Credit Card Allowed Amount:  Old Value = '+ appln.Max_Credit_Card_Allowed_Amount__c+' &  New Value = '+response.MaxCreditCardAllowedAmount+'\n';
            appln.Max_Credit_Card_Allowed_Amount__c = response.MaxCreditCardAllowedAmount;
        }
        
        if(response.TotalCreditWorthiness != null && response.TotalCreditWorthiness != appln.Total_Credit_Worthiness__c){
            logHistory += 'Total Credit Worthiness:  Old Value = '+ appln.Total_Credit_Worthiness__c+' &  New Value = '+response.TotalCreditWorthiness+'\n';
            appln.Total_Credit_Worthiness__c = response.TotalCreditWorthiness;
        }
        
        //maxLoanAmount only for Term Loan Application
        if(response.maxLoanAmount != null && response.maxLoanAmount != appln.Max_Loan_Amount__c){
            logHistory += 'Max Loan Amount:  Old Value = '+ appln.Max_Loan_Amount__c +' & New Value = '+response.maxLoanAmount+'\n';
            appln.Max_Loan_Amount__c = response.maxLoanAmount;
        }
        
        if(!String.isBlank(response.FraudAlert) && (!response.FraudAlert.equalsIgnoreCase(appln.Fraud_Alert__c))){
            logHistory += 'Fraud Alert:  Old Value = '+ appln.Fraud_Alert__c +' &  New Value = '+response.FraudAlert+'\n';
            appln.Fraud_Alert__c = response.FraudAlert;
        }
        
        if(!String.isBlank(response.ApplicantType) && (!response.ApplicantType.equalsIgnoreCase(appln.PcoD_Bankruptcy_State__c)) ){
            logHistory += 'Applicant Type:  Old Value = '+ appln.PcoD_Bankruptcy_State__c +' &  New Value = '+response.ApplicantType+'\n';
            appln.PcoD_Bankruptcy_State__c = response.ApplicantType;
        }
          
        //Ecpenses & Income Information.
        if(response.monthlyHousingCost != null && response.monthlyHousingCost != appln.Housing_Costs__c){
            logHistory += 'Housing Costs:  Old Value = '+ appln.Housing_Costs__c+' &  New Value = '+response.monthlyHousingCost+'\n';
            appln.Housing_Costs__c = response.monthlyHousingCost; 
        }                 
        
        /*
        if(response.monthlyExpenses != null && response.monthlyExpenses != appln.Monthly_Expenses__c){
            logHistory += 'Monthly Expenses:  Old Value = '+ appln.Monthly_Expenses__c+' &  New Value = '+response.monthlyExpenses+'\n';
            appln.Monthly_Expenses__c = response.monthlyExpenses; 
        } 
        */
        
        //Credit Score Information 
        if(!String.isBlank(response.scorecardProgram) && (!response.scorecardProgram.equalsIgnoreCase(appln.Scorecard_Program__c)) ){
            logHistory += 'Scorecard Program:  Old Value = '+ appln.Scorecard_Program__c +' &  New Value = '+response.scorecardProgram+'\n';
            appln.Scorecard_Program__c = response.scorecardProgram;
        }
        
        if(response.dsrScore != null && response.dsrScore != appln.DSR_Score__c){
            logHistory += 'DSR Score:  Old Value = '+ appln.DSR_Score__c+' &  New Value = '+response.dsrScore+'\n';
            appln.DSR_Score__c = response.dsrScore;
        }          
        
        if(!String.isBlank(response.creditScore) && (!response.creditScore.equalsIgnoreCase(appln.Credit_Score__c)) ){
            logHistory += 'Credit Score:  Old Value = '+ appln.Credit_Score__c +' &  New Value = '+response.creditScore+'\n';
            appln.Credit_Score__c = response.creditScore;  
        }   
        
        if(response.declaredBKCP != null && appln.Current_BKCP__c != response.declaredBKCP){
            
            logHistory += 'Current BKCP:  Old Value = '+ appln.Current_BKCP__c +' &  New Value = '+response.declaredBKCP+'\n';
            appln.Current_BKCP__c = response.declaredBKCP;
        }
        
        //Credit Bureau Summary  
        if(response.accountsOnFile != null && appln.Accounts_On_File__c != response.accountsOnFile){
            logHistory += 'Accounts on File:  Old Value = '+ appln.Accounts_On_File__c +' &  New Value = '+response.accountsOnFile+'\n';
            appln.Accounts_On_File__c = response.accountsOnFile;  
        }        
        if(response.revolvingDebtUtilization != null && appln.Revolving_Debt_Utilization__c != response.revolvingDebtUtilization){
            logHistory += 'Revolving Debt Utilization:  Old Value = '+ appln.Revolving_Debt_Utilization__c +' &  New Value = '+response.revolvingDebtUtilization+'\n';
            appln.Revolving_Debt_Utilization__c = response.revolvingDebtUtilization; 
        }        
        if(response.bankruptcies != null && appln.Bankruptcies__c != response.bankruptcies){
            logHistory += 'Bankruptcies:  Old Value = '+ appln.Bankruptcies__c +' &  New Value = '+response.bankruptcies+'\n';
            appln.Bankruptcies__c = response.bankruptcies;
        }        
        if(response.monthSinceBKDischarge != null && appln.Month_Since_BK_Discharge__c != response.monthSinceBKDischarge){
            logHistory += 'Month Since BK Discharge:  Old Value = '+ appln.Month_Since_BK_Discharge__c +' &  New Value = '+response.monthSinceBKDischarge+'\n';
            appln.Month_Since_BK_Discharge__c = response.monthSinceBKDischarge;
        }
        if(response.badDebtWriteOff != null && appln.Bad_Debt_Write_Off__c != response.badDebtWriteOff){
            logHistory += 'Bad Debt Write Off:  Old Value = '+ appln.Bad_Debt_Write_Off__c +' &  New Value = '+response.badDebtWriteOff+'\n';
            appln.Bad_Debt_Write_Off__c = response.badDebtWriteOff; 
        }
        if(response.monthsSinceBadDebtWriteOff != null && appln.Months_Since_Bad_Debt_Write_Off__c != response.monthsSinceBadDebtWriteOff){
            logHistory += 'Months Since Bad Debt Write Off:  Old Value = '+ appln.Months_Since_Bad_Debt_Write_Off__c +' &  New Value = '+response.monthsSinceBadDebtWriteOff+'\n';
            appln.Months_Since_Bad_Debt_Write_Off__c = response.monthsSinceBadDebtWriteOff;
        } 
        
        //Underwriting Rules for 4 Pillars - Updates for Tier Type 
        String strtTier = 'Default';
        if(String.isNotBlank(response.appStrategyTier)){
            strtTier = response.appStrategyTier;
        }
        if(!String.isBlank(strtTier) && (!strtTier.equalsIgnoreCase(appln.Strategy_Tier__c)) ){
            logHistory += 'Strategy Tier:  Old Value = '+ appln.Strategy_Tier__c +' &  New Value = '+strtTier+'\n';
            appln.Strategy_Tier__c = strtTier;  
        }         
        
        //Note Record
        if(String.isNotBlank(logHistory)){
            Note logHistoryNote = new Note();
            logHistoryNote.title = 'Redecide Changes - ' + convertDateToString(system.today());
            logHistoryNote.body = logHistory;           
            logHistoryNote.parentId = appln.Id;
            insert logHistoryNote;
        }
    }
    
    public static String getUserProfile (){
        return [Select Id, Name from Profile where Id=:Userinfo.getProfileId()].Name;
    }
    
    public static List<PermissionSetAssignment> getPermissionSet(){
        return [SELECT PermissionSet.Name, PermissionSet.Label FROM PermissionSetAssignment WHERE Assignee.Id =: UserInfo.getUserId()];
    }
    
    public static String convertDateToString(Date dt){
        return String.valueof(date.newinstance(dt.year(), dT.month(), dT.day()));
    }
    
    //No adjudication for BKCP non-Home Owners
    public static Boolean prohibitAdjudication(String selHomeOwnerOptions, String SelCurrentBKCP,  Boolean isPreferredPartner){
        Boolean prohibitAdjudication = false;
        
        if (!isPreferredPartner){
            
            if(String.isNotBlank(selHomeOwnerOptions) && (selHomeOwnerOptions == 'Yes') && String.isNotBlank(SelCurrentBKCP) && (SelCurrentBKCP == 'None')){
                prohibitAdjudication = false;
            }
            else{
                prohibitAdjudication = true;
            }
        }
        
        return prohibitAdjudication;
    }
    
    public static Boolean prohibitAdjudication(String selHomeOwnerOptions, String SelCurrentBKCP){
        Boolean prohibitAdjudication = false;
        
        if(String.isNotBlank(selHomeOwnerOptions) && (selHomeOwnerOptions == 'Yes') && String.isNotBlank(SelCurrentBKCP) && (SelCurrentBKCP == 'None')){
            prohibitAdjudication = false;
        }
        else{
            prohibitAdjudication = true;
        }
        
        return prohibitAdjudication;
    }
    
    //Grt Application Name for non adjudicated BKCP non-Home Owners
    /*
    public static String getDeclinedAppName(){
        
        //Sequence Number from Custom Settings
        Application_Form_Settings__c appFormSettings = Application_Form_Settings__c.getOrgDefaults();
        Integer seqNo = appFormSettings.Forced_Decline_App_Seq__c.intvalue();
        appFormSettings.Forced_Decline_App_Seq__c = appFormSettings.Forced_Decline_App_Seq__c + 1;
        update appFormSettings;
        
        //Application Name
        String declinedAppName = 'AFM'+ seqNo;
        System.debug('declinedAppName :' + declinedAppName);
        
        return declinedAppName;
    }
    */
    
    //return RecordType fot the Product
    public static String getProductRecordType(String sourceSystem){
    
        String prodRecordType = getDevNameForProductType(sourceSystem);
        String strRecordTypeID = [Select Id From RecordType where sobjecttype = 'Product__c' and DeveloperName =: prodRecordType].id;
        
        return strRecordTypeID;
    }
    
    //Return DeveloperName fot the Product Record Types
    public static string getProdRecorTypeName(Id recordTypeId){
        String developerName;       
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Product__c' and Id =: recordTypeId];
        if(recordTypes.size() > 0){
            developerName = recordTypes[0].DeveloperName;
        }
        
        return developerName;
    }
    
    //Return DeveloperName fot the Product Record Types
    public static Map <Id, String> getProdRecorTypeMap(){
        
        Map <Id, String> prodRecorTypeMap = new Map<Id, String>();
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Product__c'];
        
        for(RecordType recordType : recordTypes){
            prodRecorTypeMap.put(recordType.Id ,recordType.DeveloperName);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.DeveloperName);
        }       
        
        return prodRecorTypeMap;
    }
    
    public static String getDevNameForProductType(String sourceSystem){
        return getDevNameProdProductTypeMap().get(sourceSystem);
    }
    
    //return Map of Application recordType
    public static Map<String, String> getDevNameProdProductTypeMap(){
        Map<String, string> devNameProdProductTypeMap = new Map<String, string>();
        devNameProdProductTypeMap.put('Megasys','Loan_Account');
        devNameProdProductTypeMap.put('FDR','Credit_Card_Account');
        devNameProdProductTypeMap.put('DebtNext','Insolvency_Account');
        
        return devNameProdProductTypeMap;
    }
    
    //return RecordType fot the Product
    public static Id getAppRecordTypeId(String appProductType){
        //System.debug('appProductType :'+appProductType);
        if(String.isNotBlank(appProductType)){
            String devName = getDevNameForAppProductType(appProductType);
            //System.debug('devName :'+devName);
            if(String.isNotBlank(devName)){             
                RecordType appRecordType = [select Id, Name, DeveloperName from RecordType where DeveloperName=:devName and SObjectType = 'Application__c'];
                //System.debug('appRecordType.Id :'+appRecordType.Id);
                return appRecordType.Id;
            }
        }
        return null;
    }
    
    //return devName of recordType for Application
    public static String getDevNameForAppProductType(String appProductType){
        return getDevNameAppProductTypeMap().get(appProductType);
    }
    
    //return Map of Application recordType
    public static Map<String, String> getDevNameAppProductTypeMap(){
        Map<String, string> devNameAppProductTypeMap = new Map<String, string>();
        devNameAppProductTypeMap.put('Affirm Financial Term Loan','Term_Loan');
        devNameAppProductTypeMap.put('Affirm Financial MasterCard','Credit_Card');
        
        return devNameAppProductTypeMap;
    }
    
    //Format the phone number if it has 10 or 11 characters
    public static String formatPhone(String phoneNbr){
        
        if(String.isNotBlank(phoneNbr)){
            if (phoneNbr.length() == 10) {
                return '(' + phoneNbr.substring(0,3) + ') ' + phoneNbr.substring(3,6) + '-' + phoneNbr.substring(6,10);         
            }       
            else if (phoneNbr.length() == 11) {
                if (phoneNbr.substring(0,1) == '1') {
                    return  '(' + phoneNbr.substring(1,4) + ') ' + phoneNbr.substring(4,7) + '-' + phoneNbr.substring(7,11);
                }
            }
        }
        
        return phoneNbr;
    }
    
    //Rectify Requested Close Date
    public static Date rectifyRequestedCloseDate(Date requestedCloseDate){
        
        if(requestedCloseDate != null){
            Integer intYear = requestedCloseDate.year();
            
            if (intYear < 2000){
                requestedCloseDate = requestedCloseDate.addYears(100);
                return requestedCloseDate;
            }
        }
        
        return requestedCloseDate;
    }
    
    public static Integer getNumberOfDaysDelinquent(Date nextPaymentDate){
        if(nextPaymentDate == null){
            return null;    
        }
        Integer daysBetween = nextPaymentDate.daysBetween(System.Today());
        System.debug('daysBetween :'+daysBetween);
        
        Integer numberOfDaysDelinquent = daysBetween > 0 ? daysBetween : 0;
        System.debug('numberOfDaysDelinquent :'+numberOfDaysDelinquent);
        
        return numberOfDaysDelinquent;      
    }    
    
    //Get No of cycles for Megasys Accounts
    public static Integer getNumberOfCyclesDelinquentMS(Decimal numberOfDaysDelinquent, Boolean versapayPayment){
        
        //Number Of Days Delinquent = null
        if(numberOfDaysDelinquent == null){
            return null;
        }
        
        //Number Of Days Delinquent = 0
        if(numberOfDaysDelinquent == 0){
            return 0;
        }
        
        
        //Number Of Days Delinquent between 1 and 30
        if(numberOfDaysDelinquent >= 1 && numberOfDaysDelinquent <= 30){
            if(numberOfDaysDelinquent >= 1 && numberOfDaysDelinquent <= 10 && versapayPayment == true){
                return 0;
            }
            else{
                return 1;
            }
        }       
            
        //Number Of Days Delinquent between 31 and 60
        if(numberOfDaysDelinquent >= 31 && numberOfDaysDelinquent <= 60){
            if(numberOfDaysDelinquent >= 31 && numberOfDaysDelinquent <= 40 && versapayPayment == true){
                return 1;
            }
            else{
                return 2;
            }
        }
        
        //Number Of Days Delinquent between 61 and 90
        if(numberOfDaysDelinquent >= 61 && numberOfDaysDelinquent <= 90){
            if(numberOfDaysDelinquent >= 61 && numberOfDaysDelinquent <= 70 && versapayPayment == true){
                return 2;
            }
            else{
                return 3;
            }
        }
        
        //Number Of Days Delinquent between 91 and 120
        if(numberOfDaysDelinquent >= 91 && numberOfDaysDelinquent <= 120){
            if(numberOfDaysDelinquent >= 91 && numberOfDaysDelinquent <= 100 && versapayPayment == true){
                return 3;
            }
            else{
                return 4;
            }
        }
        
        //Number Of Days Delinquent between 121 and 150
        if(numberOfDaysDelinquent >= 121 && numberOfDaysDelinquent <= 150){
            return 5;
        }
        
        //Number Of Days Delinquent between 151 and 180
        if(numberOfDaysDelinquent >= 151 && numberOfDaysDelinquent <= 180){
            return 6;
        }
        
        //Number Of Days Delinquent greater than 180
        if(numberOfDaysDelinquent >= 181){
            return 7;
        }   
        
        return null;    
    }
 }