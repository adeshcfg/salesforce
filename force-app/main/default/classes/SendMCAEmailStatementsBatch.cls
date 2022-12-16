/**************************************************************************************************
 *
 *  Class:   Batch class for sending email statement to customers
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 24/03/2021
 
*************************************************************************************************/
public class SendMCAEmailStatementsBatch implements Database.Batchable<sObject>{
    static String TEMPLATE_NAME = 'MCA Email Statement';
    MCA_Configuration__c config = MCA_Configuration__c.getOrgDefaults();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, Name, Email__c, Merchant__r.OwnerId, Merchant__c, Merchant__r.Name, Merchant__r.Business_Email__c,'+
            ' Officer_First_Name__c, Officer_Last_Name__c, Current_Balance__c FROM Merchant_Account__c WHERE'+
            ' Account_Status__c != \'Written Off\' AND Account_Status__c != \'Paid in full\''
            ); 
    }
    
    public void execute(Database.BatchableContext bc, List<Merchant_Account__c> listMerchantAccounts){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> listAttachments = new List<Attachment>();
        List<String> sendTo;
        Messaging.SingleEmailMessage mail;
        String emailBody;
        
        EmailTemplate template = [SELECT ID, Body, HtmlValue, Subject
                                    FROM EmailTemplate 
                                    WHERE Name = :TEMPLATE_NAME LIMIT 1];
        OrgWideEmailAddress OrgWideAddress;
        if(!Test.isRunningTest()){
            OrgWideAddress = [SELECT ID
                              FROM OrgWideEmailAddress 
                              WHERE Address= :config.Org_Wide_From_Address__c
                              LIMIT 1];    
        }
        
        list<Task> listEmailActivity = new list<Task>();
        for(Merchant_Account__c merchantAccount : listMerchantAccounts){
            mail = new Messaging.SingleEmailMessage();
            
            //replace merchant account field names with values in email body
            emailBody = template.HtmlValue;
            emailBody = emailBody.replace('{!Merchant_Account__c.Merchant__c}', merchantAccount.Merchant__r.Name);
            emailBody = emailBody.replace('{!Merchant_Account__c.Name}', merchantAccount.Name);
            //emailBody = emailBody.replace('{!Merchant_Account__c.Officer_First_Name__c}', merchantAccount.Officer_First_Name__c);
            //emailBody = emailBody.replace('{!Merchant_Account__c.Officer_Last_Name__c}', merchantAccount.Officer_Last_Name__c);
            
            //Create PDF file
            PageReference pdf = Page.MCAEmailStatement;
            pdf.getParameters().put('id',merchantAccount.Id);   
            pdf.setRedirect(true);
            Blob b;
            if(Test.isRunningTest()) { 
                b = blob.valueOf('Unit.Test');
            } 
            else {
                b = pdf.getContentAsPDF();
            }
            Attachment attachment = new Attachment();
            attachment.Body = b;
            // add the user entered name
            attachment.Name = config.Email_Statement_File_Name__c;
            attachment.IsPrivate = false;
            // attach the pdf to the account
            attachment.ParentId = merchantAccount.Id;
            listAttachments.add(attachment);
            
            sendTo = new List<String>();
            //Email should be sent to both email addresses if different
            if(String.isNotBlank(merchantAccount.Email__c)){
                sendTo.add(merchantAccount.Email__c);
            }
            if(String.isNotBlank(merchantAccount.Merchant__r.Business_Email__c) 
            && merchantAccount.Email__c <> merchantAccount.Merchant__r.Business_Email__c){
                    sendTo.add(merchantAccount.Merchant__r.Business_Email__c);    
            }
            
            if(!sendTo.isEmpty()){ 
                mail.setToAddresses(sendTo);
                if(!Test.isRunningTest()){
                    mail.setOrgWideEmailAddressId(OrgWideAddress.Id);   
                }
                mail.setHtmlBody(emailBody);
                mail.setSubject(template.Subject);
                
                
                Messaging.EmailFileAttachment emailFile = new Messaging.EmailFileAttachment();
                emailFile.setFileName(config.Email_Statement_File_Name__c);
                emailFile.setBody(b);
                
                //mail.setTemplateId(template.Id);
                //Need to replace logic for adding contactid for template use
                //mail.setTargetObjectId('0035600000UYnRk');
                mail.setSaveAsActivity(true);
                //mail.setWhatId(merchantAccount.Id);
                //mail.setTreatTargetObjectAsRecipient(false);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] {emailFile});
                
                mails.add(mail);
                //Saving Email Activity as setSaveAsActivity does not work with custom object
                listEmailActivity.add(new Task(Subject = 'Email Sent', 
                                               OwnerId = UserInfo.getUserId(), 
                                               WhatId = merchantAccount.Id,
                                               TaskSubtype = 'Email',
                                               ActivityDate = Date.today(),
                                               Status = 'Completed'));
            }
        }
        if(!Test.isRunningTest()){
            insert listAttachments;
            system.debug('mails: '+mails);
            if(config.Send_Email_Statements__c){
            	Messaging.sendEmail(mails);    
                insert listEmailActivity;
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}