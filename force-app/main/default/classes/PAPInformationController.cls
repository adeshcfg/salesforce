/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a controller class to input PAP Information
*  @author : A5E Consulting
*  @date : 07/22/2016
*
*************************************************************************************************/

public with sharing class PAPInformationController{
    
    public Application__c application{get;set;}
    public Attachment papSupportDocument{get;set;}
    public List<Attachment> attList;
    public Boolean acceptTermsCondition{get;set;}
    
    public boolean showError{get;set;}
    public String errorMessage{get;set;}
    public boolean showSuccessMessage{get;set;}
    
    public String acceptFormat{get;set;}
    public Integer acceptFileSize{get;set;}
    public Integer fileSize{get;set;}
    public string fileId{get;set;}
    
    public boolean displayPopup {get; set;} 
    
    public List<Attachment> lstAttachment {get;set;}
    
    public PAPInformationController(){
        
        String loanType = ApexPages.currentPage().getParameters().get('loanType');
        
        if(loanType.equalsIgnoreCase('Affirm Financial Term Loan')){
            
            //Custom Settings
            Loan_ReEngineering__c loanSettings = Loan_ReEngineering__c.getOrgDefaults();
            
            //To Display Message
            showError = false;
            showSuccessMessage = false;  
            
            //Initialize TermsCondition Check bx
            acceptTermsCondition = false;     
            
            //List of PAP attachments
            attList = new List<Attachment>();
            lstAttachment  = new List<Attachment>();
            papSupportDocument = new Attachment();
            
            //File Validation
            acceptFormat = loanSettings.File_Formats__c;
            //fileSize = (Integer)loanSettings.File_Size__c;
            acceptFileSize = (Integer)loanSettings.File_Size__c;
            
            //Get Application ID
            Id applicationId = ApexPages.currentPage().getParameters().get('id');
            application = [select id, name, Decision__c, Authentication_Result__c, Authentication_Choice__c, Application_Fullfillment_Status__c, PAP_Transit_Code__c, PAP_Bank_Code__c, PAP_Account_Number__c from Application__C where id =: applicationId];
            
            //Attachment List
            attList = [Select id, Name , ParentId , body  from Attachment where ParentId=:applicationId and Name like 'PAP_%' ORDER BY CreatedDate DESC ];
            lstAttachment = attList ;
            if(attList != null && attList.size() > 0){          
                fileId = attList[0].id;            
            }
            
            String appDecision = application.Decision__c;
            String appFullfillmentStatus = application.Application_Fullfillment_Status__c;
            if('Declined' == appDecision){
                showError = true;
                errorMessage = 'The Application Decision is Declined, you cannot continue with PAP.';
            }
            else if(application.Authentication_Result__c != 'Passed' && application.Authentication_Choice__c != 'Completed'){
                showError = true;
                errorMessage = 'The Authentication is not completed for this Application, you cannot continue with PAP.';               
            }
            else if(('Tele Scripting Completed' != appFullfillmentStatus) 
                    && ('PAP Information uploaded' != appFullfillmentStatus) 
                    && ('Ready for Approval' != appFullfillmentStatus) 
                    && ('Approved for Funding' != appFullfillmentStatus) 
                    && ('CSR Reviewed' != appFullfillmentStatus)
                    && ('CSR Rework' != appFullfillmentStatus)){          
                        
                        showError = true;
                        errorMessage = 'The Application is not in correct Fullfillment Status, you cannot continue with PAP';
                    }else if('Completed' == appFullfillmentStatus){
                        showError = true;
                        errorMessage = 'The Application Fulfillment Status is Completed, you cannot continue with PAP.';               
                    }
            
            //String loanCal = ApexPages.currentPage().getParameters().get('appFulfill');
            /*
if(loanCal != 'Loan Calculator Completed' 
&& loanCal != 'PAP Information uploaded' 
&& loanCal != 'PAP upload Failed' 
&& loanCal != 'Tele-Scripting Required'
&& loanCal != 'Executing Loan Document' 
&& loanCal != 'Loan Document Executed' 
&& loanCal != 'E-Signing Failed'
&& loanCal != 'Ready for Approval' 
&& loanCal != 'Approval for Funding' 
&& loanCal != 'Completed' ){
showError = true;
}
*/
        }   
        else{
            errorMessage='This Application is for Credit Card, you cannot continue with PAP Information.';
            showError=true;
        }         
    }
    
    public void upload(){
        //
    }
    
    public PageReference navigatePrevious() {
        PageReference pageRef = new PageReference('/' + application.id);
        return pageref;
    }
    
    public PageReference updatePaymentMethod(){
        
        PageReference pageRef;
        
        if(application.PAP_Transit_Code__c != null 
           && application.PAP_Bank_Code__c != null 
           && application.PAP_Account_Number__c != null 
           //&& papSupportDocument.body != null 
           && acceptTermsCondition == true){
               
               //PAP Fields needs to be numeric
               if((!application.PAP_Transit_Code__c.isNumeric()) || (!application.PAP_Bank_Code__c.isNumeric()) || (!application.PAP_Account_Number__c.isNumeric())){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter numbers only for PAP fields');
                   ApexPages.addMessage(myMsg);
                   papSupportDocument = new Attachment();
                   return null;
               }
               
               //PAP Document is required if not available already
               if(attList.size() == 0 && papSupportDocument.body == null){
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload the PAP Document');
                   ApexPages.addMessage(myMsg);
                   papSupportDocument = new Attachment();
                   return null;
               }
               
               //PAP file validation
               if(papSupportDocument.body != null){
                   
                   //File Extention
                   String extensionVal = papSupportDocument.Name.substringAfterLast('.').toLowerCase();
                   if(!acceptFormat.contains(extensionVal)){
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please attach '+ acceptFormat +' files only');
                       ApexPages.addMessage(myMsg);
                       papSupportDocument = new Attachment();
                       return null;    
                   }   
                   
                   //File Size
                   if(fileSize > acceptFileSize){
                       ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'File size greater than accepted file size');
                       ApexPages.addMessage(myMsg);
                       papSupportDocument = new Attachment();
                       return null;                        
                   }
               }
               
               //Insert PAP DOcument
               if(papSupportDocument.body != null){
                   papSupportDocument.parentid = application.id;
                   papSupportDocument.name = 'PAP_' + papSupportDocument.name;
                   insert papSupportDocument;
               }               
               
               Profile prof = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId()];
               
               if('CFG - Loan Administrator' != prof.Name){
                   application.Application_Fullfillment_Status__c = 'Ready for Approval';
               }
               application.PAP_Information_I_Accept__c = acceptTermsCondition;
               application.PAP_Information_I_Accept_DateTime__c = system.Now();
               
               ApplicationTriggerHandler.runApplicationLoadTrigger = false;
               update application;
               ApplicationTriggerHandler.runApplicationLoadTrigger = true;
               
               papSupportDocument = new Attachment();
               showSuccessMessage = true;
               pageRef = ApexPages.currentPage();
           }
        else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill all the information');
            ApexPages.addMessage(myMsg);
            
            papSupportDocument = new Attachment();
            return null;
        }
        
        acceptTermsCondition = false;
        return pageRef;
    }
    
    public void closePopup() {
        displayPopup = false;    
    }     
    public void showPopup() {
        displayPopup = true;    
    }
}