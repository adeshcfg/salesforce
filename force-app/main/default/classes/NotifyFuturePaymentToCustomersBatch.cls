/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to send notification to Customers on the future payments 
 *  @author : A5E Consulting
 *  @date : 19/07/2021
 
 *************************************************************************************************/
public class NotifyFuturePaymentToCustomersBatch implements Database.Batchable<sObject> {
    static String EMAIL_TEMPLATE_NAME = 'Payment Processor Future Payment Notification';
    static String RECURRING_PAYMENT_MASTER = 'Recurring_Payment_Master';
    Customer_Payment_Processor_Settings__c config = Customer_Payment_Processor_Settings__c.getOrgDefaults();
	 
	public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
        return Database.getQueryLocator(
            [SELECT ID, Amount__c, Next_Payment_Date__c, Product__r.Customer__c, Recurrence_Type__c,Product__r.Name,
             		Customer_Email_Address__c, Product__r.Customer__r.PersonContactID, Product__r.Customer__r.Future_Payment_Reminder__c,
             		Product__r.Customer__r.PersonHasOptedOutOfEmail	
             FROM Payment_Transaction__c	
             WHERE RecordType.developerName= :RECURRING_PAYMENT_MASTER
             AND Next_Payment_Date__c= TOMORROW]
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Payment_Transaction__c> listPaymentTransactions){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail;
        List<String> sendTo = new List<String>();
        String emailBody;
        
        EmailTemplate template = [SELECT ID, Body, HtmlValue, Subject
                                    FROM EmailTemplate 
                                    WHERE Name = :EMAIL_TEMPLATE_NAME LIMIT 1];
        
        OrgWideEmailAddress OrgWideAddress;
        if(!Test.isRunningTest()){
            OrgWideAddress = [SELECT ID
                              FROM OrgWideEmailAddress 
                              WHERE Address= :config.Org_Wide_From_Address__c
                              LIMIT 1];    
        }
        
        list<Product__c> listProductsToUpdate = new list<Product__c>();
        for(Payment_Transaction__c payTransaction : listPaymentTransactions){
            if(payTransaction.Product__r.Customer__r.Future_Payment_Reminder__c
            && payTransaction.Product__r.Customer__r.PersonHasOptedOutOfEmail == false){
            	system.debug('payTransaction: '+payTransaction.Id);
                mail = new Messaging.SingleEmailMessage();
                emailBody = template.HtmlValue;
                //emailBody = emailBody.replace('{!Account.Name}', payTransaction.Product__r.Customer__c);
                emailBody = emailBody.replace('{!Payment_Transaction__c.Amount__c}', String.valueOf(payTransaction.Amount__c));
                emailBody = emailBody.replace('{!Payment_Transaction__c.Recurrence_Type__c}', String.valueOf(payTransaction.Recurrence_Type__c));
                emailBody = emailBody.replace('{!Payment_Transaction__c.Product__c}', String.valueOf(payTransaction.Product__r.Name));
                DateTime payDate = payTransaction.Next_Payment_Date__c;
                system.debug('payDate: '+payDate);
                String dt = payDate.formatGMT('dd-MMMM-YYYY');
                system.debug('dt: '+dt);
                emailBody = emailBody.replace('{!Payment_Transaction__c.Next_Payment_Date__c}', dt);
            	sendTo = new List<String>();
            	sendTo.add(payTransaction.Customer_Email_Address__c);
            	mail.setToAddresses(sendTo);
                if(!Test.isRunningTest()){
                    mail.setOrgWideEmailAddressId(OrgWideAddress.Id);   
                }
                mail.setHtmlBody(emailBody);
                mail.setSubject(template.Subject);
                //Need to replace logic for adding contactid for template use
                mail.setTargetObjectId(payTransaction.Product__r.Customer__r.PersonContactID); //To send Email to the Contact Email
                mail.setSaveAsActivity(true);
                mail.setWhatId(payTransaction.Id);
                mails.add(mail);    
            }
        }
        if(!Test.isRunningTest()){
            system.debug('test');
			Messaging.sendEmail(mails);   
        }
    }    
    public void finish(Database.BatchableContext bc){
		
    }
}