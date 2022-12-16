/**************************************************************************************************
*
*  Class:   
*
*  @description : This class decide which flow to call ReDecide or ReSubmit
*  @author : A5E Consulting
*  @date : 14 Sept 2020   
*
*************************************************************************************************/
public with sharing class ApplicationResubmitReDecideController{
    
    public Application__C application{get;set;}
    public Application_Form_Settings__c afSettings{get;set;}
    public Boolean progressBar{get;set;}
    public string message{get;set;}
    List<Attachment> attachList{get;set;}
    ApexPages.StandardController standardController;
    
    public ApplicationResubmitReDecideController(){
        
    }
    
    public ApplicationResubmitReDecideController(ApexPages.StandardController controller) {
        String appID = ApexPages.currentPage().getParameters().get('id');
        standardController = controller;
        
        system.debug(''+appID);
        
        progressBar = true;
        message = null;
        
        afSettings = Application_Form_Settings__c.getOrgDefaults();
        
        application = new Application__C();
        application = [Select id, Name, Last_Name__c, First_Name__c, Birth_Date__c, SIN__C, 
                Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, Permanent_Address_City__c, 
                Permanent_Address_PostalCode__c, Permanent_Address_Province__c, Primary_Phone_Number__c, 
                Home_Phone__c, Cell_Phone__c, Work_Phone__c,
                Marital_Status__c, Home_Owner__c,
                Third_Party_Direction__c, Politically_Exposed_Foreign_Person__c,
                Employment_Years__c, Employment_Months__c, Gross_Monthly_Income__c, Employment_Status__c,
                CurrentBKCP__c, Number_of_Dependants__c,
                Housing_Costs__c, Monthly_Expenses__c, Decision__c,
                Webservice_Response__c, Adjudication_Response__c, AML_Response__c,
                Application_Status__c,
                Campaign_Code__c  
                From Application__c where id = : appID];
        
        attachList = [select id, createdDate from attachment where parentID =: appID and name = 'Adjudication - Response.txt' order by createdDate asc limit 1];
        
        system.debug(''+application);
    }
    
    public PageReference reDecideResubmit(){
        
        if(application.Application_Status__c == 'Completed - Credit Card' || application.Application_Status__c == 'Archived'){
            message = 'Application redecide can not be done as application status is ' + application.Application_Status__c;
            return null;
        }
        try{
        
            //system.debug('Attachlist : ' + attachList.size());
            //system.debug('Attachlist : ' + (application.Adjudication_Response__c).contains('<Hit>N</Hit>'));
            if(null != attachList && attachList.size() > 0 && String.isNotBlank(application.Adjudication_Response__c) && (application.Adjudication_Response__c).contains('<Hit>Y</Hit>')){
                
                Date attachmentCreatedDate = Date.valueOf(attachList[0].CreatedDate);
                Date CreditReportExpiryDate =  attachmentCreatedDate.addDays(Integer.valueOf(afSettings.Credit_Report_Expiry_Date__c));
                if(system.today() < CreditReportExpiryDate){
                    ApplicationRedecideController appReDecide = new ApplicationRedecideController(standardController);
                    appReDecide.reDecide();
                    message = 'Application has been redecided';
                }else{
                    ApplicationResubmitController applicationResubmit = new ApplicationResubmitController(standardController);
                    applicationResubmit.reSubmit();
                    message = 'Application has been re-submitted because Credit report was expired';
                }
            }else{
                ApplicationResubmitController applicationResubmit = new ApplicationResubmitController(standardController);
                message = validateApplication(application);
                if(String.isBlank(message)){
                    applicationResubmit.reSubmit();
                    message = 'Application has been re-submitted because adjudication was not present';
                }
                
            }
        }catch(Exception e){
            message = 'Due to system exception process failed';
        }
        
        return null;
    }
    
    public String validateApplication(Application__c app){
             
        String message = 'Please fill below fields : ';
        if(String.isBlank(app.Last_Name__c)){
            message += 'Last Name <br/>';
        }
        if(String.isBlank(app.First_Name__c)){
            message += 'First Name <br/>';
        }
        if(null == app.Birth_Date__c){
            message += 'Birth Date <br/>';
        }
        if(String.isBlank(app.Permanent_Address_Street_Number__c)){
            message += 'Permanent Address Street Number <br/>';
        }
        if(String.isBlank(app.Permanent_Address_Street_Name__c)){
            message += 'Permanent Address Street Name <br/>';
        }
        if(String.isBlank(app.Permanent_Address_City__c)){
            message += 'Permanent Address City <br/>';
        }
        if(String.isBlank(app.Permanent_Address_PostalCode__c)){
            message += 'Permanent Address Postal Code <br/>';
        }
        if(String.isBlank(app.Permanent_Address_Province__c)){
            message += 'Permanent Address Province <br/>';
        }
        if(String.isBlank(app.Marital_Status__c)){
            message += 'Marital Status <br/>';
        }
        if(String.isBlank(app.Home_Owner__c)){
            message += 'Home Owner <br/>';
        }
        if(null == app.Employment_Years__c){
            message += 'Employment Years <br/>';
        }
        if(null == app.Employment_Months__c){
            message += 'Employment Months <br/>';
        }
        if(null == app.Gross_Monthly_Income__c){
            message += 'Gross Monthly Income <br/>';
        }
        if(String.isBlank(app.Employment_Status__c)){
            message += 'Employment Status <br/>';
        }
        if(String.isBlank(app.CurrentBKCP__c)){
            message += 'Current BKCP <br/>';
        }
        if(String.isBlank(app.Number_of_Dependants__c)){
            message += 'Number of Dependents <br/>';
        }
        if(null == app.Housing_Costs__c){
            message += 'Housing Costs <br/>';
        }
        if(null == app.Monthly_Expenses__c){
            message += 'Monthly Expenses <br/>';
        }
        
        if(app.Primary_Phone_Number__c == 'Home Phone' && String.isBlank(app.Home_Phone__c)){
            message += 'Primary Phone number is selected as Home Phone but Home Phone number is missing <br/>';
        }else if(app.Primary_Phone_Number__c == 'Mobile Phone' && String.isBlank(app.Cell_Phone__c)){
            message += 'Primary Phone number is selected as Mobile Phone but Mobile Phone number is missing <br/>';
        }else if(app.Primary_Phone_Number__c == 'Work Phone' && String.isBlank(app.Work_Phone__c  )){
            message += 'Primary Phone number is selected as Work Phone but Work Phone number is missing <br/>';
        }
        
        if(message == 'Please fill below fields : '){
            message = '';
        }

        return message;
    }
}