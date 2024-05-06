/**************************************************************************************************
 *
 *  Class:    FidemCustomerNotificationBatch
 *
 *  @description : To send Monthly Email Statement to Fidem Customers
 *  @author : A5E Consulting
 *  @date : 05/21/2021
 *
 *************************************************************************************************/

public class FidemCustomerNotificationBatch implements Database.Batchable<sobject>{
    static Final String TEMPLATE_NAME = 'Fidem Customer Notification Template';
    static Final String orgWideEmail = 'accountmanagement@fidemfinance.ca';
    static Final String externalStatus = 'Normal Status';
    static Final String recordType = 'Credit Card Account';
        
    //Start Method
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //Fetch all eligible product records 
        return Database.getQueryLocator([select Id, Name, Last_Statement_Date__c, PRIN_Number__c, 
                                         External_Status_Description__c, Current_Balance__c, Email_Address__c,
                                         Customer__r.PersonHasOptedOutOfEmail, Customer__r.PersonEmail, Customer__r.PersonContactID
                                         from Product__c where RecordType.name = :recordType and
                                         Last_Statement_Date__c = YESTERDAY and
                                         PRIN_Number__c = 200 and
                                         External_Status_Description__c = :externalStatus and 
                                         Current_Balance__c > 0 and 
                                         Customer__r.PersonHasOptedOutOfEmail = false and 
                                         Customer__r.PersonEmail != null and                                          
                                         ((Stmt_Hold_Flag__c != null AND (Stmt_Hold_Flag__c = 'R' OR Stmt_Hold_Flag__c = 'W')) OR 
                                         (Stmt_Hold_Flag__c = null AND Paperless_Statement__c = true))]);
    }
    
    //Execute method
    public void execute(Database.BatchableContext bc, List<Product__c> listEligibleProducts){
        System.debug('In Execute method');
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        
        //Fetch Template
        EmailTemplate template = [SELECT ID, Body, HtmlValue, Subject FROM EmailTemplate WHERE Name = :TEMPLATE_NAME LIMIT 1];
        
        //Fetch 'From' Address
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :orgWideEmail];
        
        //Looping eligible records and sending mail
        for(Product__c prod:listEligibleProducts){
            
            mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(prod.Customer__r.PersonContactID); //To send Email to the Contact Email
            mail.setHtmlBody(template.HtmlValue);
            mail.setSubject(template.Subject);
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            
            emailMessages.add(mail);   
        }
        
        //Send Email
        if(!emailMessages.isEmpty() && !Test.isRunningTest()){
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emailMessages);
        }
    }
    
    //Finish method
    public void finish(Database.BatchableContext bc){
        //Do nothing
    }
}