/***************************************************
* Author         : A5E Consultancy
* Created On     : 1 Apr 2017
* Description    : Provided user to choose & send email templates regarding Product
*
***************************************************/

public class SendProductEmailCntrl {
    
    // 
    public Boolean printEmail {set;get;}
    public Set<String> printEmailSet{set;get;}
    // To change preview section visible 
    public Boolean displayPreviewEmail{set;get;}
    
    //Collection Custom Setting
    public Collection_Custom_Setting__c collCustSett = Collection_Custom_Setting__c.getOrgDefaults();
    
    // Setting preview section to true
    public void previewEmail() {
        // There is no email template selected
        if(selectedTemplate == 'null' || selectedTemplate == null){
            displayPreviewEmail = false;  
        }else{
            displayPreviewEmail = true;
        }
        if(printEmailSet.contains(selectedTemplate)){
            printEmail = true;
        }else{
            printEmail = false;
        }
    }

    
    // Custom Product Object
    Product__c prod{set;get;}
    public String selectedTemplate{set;get;}
    
    // Email validation check
    public Boolean invalidEmail {set;get;}
    public Id prodId{set;get;}
    
    // Store product record type
    public String productType{set;get;}
    
    // Constructor to read product Id from URL, Queries and validates email
    public SendProductEmailCntrl() {
        prodId = ApexPages.currentPage().getParameters().get('Id');
        prod = [SELECT Id, RecordTypeId , Customer__r.PersonContactID, Customer__r.PersonEmail, Loan_Type__c,Customer__r.Name, Address_Line1__c,Address_Line2__c, city__c/*, State__c*/, Zip_Code__c, 
                Originating_Creditor__c, Account_Purchasing_Entity__c, Previous_Primary_Account_Number__c
                FROM Product__c WHERE Id =: prodId];
        printEmailSet = new Set<String>();
        
        // Check whether product is of which type
        if(Utilities.getProdRecorTypeName(prod.RecordTypeId) == 'Credit_Card_Account'){
            productType = 'CreditCard';
        }
        else if(Utilities.getProdRecorTypeName(prod.RecordTypeId) == 'Loan_Account'){
            productType = 'Loan';
        }
        else if(Utilities.getProdRecorTypeName(prod.RecordTypeId) == 'Distressed_Account'){
            productType = 'Distressed';
        }
        
        // If email is NULL set Error
        if(prod.Customer__r.PersonEmail == null){
            invalidEmail = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Email address is missing on Customer record'));
        }
        
        //Email Templates that require forced auto print
        for(String templateName : collCustSett.Auto_Print_Email_Template__c.split(',')){
            printEmailSet.add(templateName);
        }
    }
    
    public Boolean isRestrictedUser(){
        Boolean restricedUser = false;
        
        Set<String> currentUsersPermissionSet = new Set<String>();
        for(PermissionSetAssignment permissionSet : Utilities.getPermissionSet()){
            currentUsersPermissionSet.add(permissionSet.PermissionSet.Name);
        }
        system.debug('currentUsersPermissionSet=='+currentUsersPermissionSet);
        if(currentUsersPermissionSet.contains('Restricted_User_Permissions')){
            restricedUser = true;
        }
        return restricedUser;
    }
    // Loads Email Template Names from Custom Label Product Bill Email Templates
    public List<SelectOption> getEmailTemplates() {

        List<SelectOption> options = new List<SelectOption>(); 
        // Default value to --Select--
        options.add(new SelectOption('', '------Select-----'));
        
        // Add product email template if product type is of Credit card type
        if(productType == 'CreditCard'){
            if(!isRestrictedUser()){
                for(String templateName : collCustSett.Credit_Card_Email_Templates__c.split(',')){
                    options.add(new SelectOption(templateName.trim(), templateName.trim()));
                }
            }else{
                for(String templateName : collCustSett.Resticted_Credit_Card_Email_Templates__c.split(',')){
                    options.add(new SelectOption(templateName.trim(), templateName.trim()));
                }
            }
        }
        
        // Add product email template if product type is of Loan type
        else if(productType == 'Loan'){
            if(!isRestrictedUser()){
                for(String templateName : collCustSett.Term_Loan_Email_Templates__c.split(',')){
                    options.add(new SelectOption(templateName.trim(), templateName.trim()));
                }
            }else{
                for(String templateName : collCustSett.Resticted_Term_Loan_Email_Templates__c.split(',')){
                    options.add(new SelectOption(templateName.trim(), templateName.trim()));
                }
            }
        }
        // Add product email template if product type is of Distressed type
        else if(productType == 'Distressed'){
            for(String templateName : collCustSett.Distressed_Email_Templates__c.split(',')){
                options.add(new SelectOption(templateName.trim(), templateName.trim()));
            }
        }
        return options; 
    }
    
    
    // Sending Email to Customer regrading Product Plan bill
    public PageReference send(){
        if(selectedTemplate == 'null' || selectedTemplate == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please select email template'));  
            return null;
        }
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        List<Messaging.SendEmailResult> listEmailResult = null;
        
        
        // Fetch Email template which has been selected on VF page Radio button                    
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = : selectedTemplate];
        
        // Single Email instance to compose Email feature
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Set Recipient email Addresses, and reply to
        //Set Organization-Wide Email Addresses
        //mail.setReplyTo('lending@affirmfinancial.ca');
        //mail.setOrgWideEmailAddressId(collCustSett.Account_Management_Org_Email_ID__c);
        if(productType == 'Loan' && productType == 'CreditCard'){
            mail.setOrgWideEmailAddressId(collCustSett.Account_Management_Org_Email_ID__c);
        } else if(productType == 'Distressed'){
            mail.setOrgWideEmailAddressId(collCustSett.Distressed_Account_Manage_Org_Email_ID__c);
        }
        
        mail.setTemplateId(emailTemplate.Id);
        mail.setWhatId(prod.Id);
        mail.setTargetObjectId(prod.Customer__r.PersonContactID);
        mail.setSaveAsActivity(false);
        
        listSingleEmailMessages.add(mail);
        
        // Sending email
        if(listSingleEmailMessages.size() >0){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages); 
        }
        
        for(Messaging.SendEmailResult emailResult : listEmailResult){
            if(emailResult.isSuccess()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Email sent successfully'));              

               // Creating Activity if Email sent successfully
               createActivity('Send Email - '+selectedTemplate);
            }
               
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.confirm,'Email not sent'));   
            }                                       
       }
       return null;
    }
    
    // Creating Activity
    public void createActivity(String activityName){
        
        Task activity = new Task( Subject = activityName,
                WhatId = prod.Id,
                OwnerId = UserInfo.getUserId(),
                Status='Completed');
        insert activity;
    }
}