/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to send notification to Customers on the future payments 
 *  @author : A5E Consulting
 *  @date : 26/07/2021
 
 *************************************************************************************************/
public class NotifyCustomerForPendingRequestFunds implements Database.Batchable<sObject> {
    private static final String REQUEST_FUNDS_ONE_TIME =  'Request_Funds_One_Time';
    private static final String REQUEST_FUNDS_RECURRING =  'Request_Funds_Recurring';
    static String EMAIL_TEMPLATE_NAME = 'Payment Processor Pending Request Funds';
    Customer_Payment_Processor_Settings__c config = Customer_Payment_Processor_Settings__c.getOrgDefaults();
	
    
	public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        
        return Database.getQueryLocator(
            [SELECT Id, Product__r.Customer__c, Product__r.Customer__r.PersonContactID, Customer_Email_Address__c,
             		Product__r.Name, Site_ConnectURL__c, Amount__c, Connect_URL__c,
             		(SELECT Parent__c FROM Payment_Transactions__r) 
             FROM Payment_Transaction__c 
             WHERE (RecordType.developerName= :REQUEST_FUNDS_ONE_TIME
                    OR RecordType.developerName= :REQUEST_FUNDS_RECURRING)
             		AND CreatedDate = YESTERDAY]
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
            system.debug('payTransaction: '+payTransaction.Id);
            if(payTransaction.Payment_Transactions__r.isEmpty()){
                mail = new Messaging.SingleEmailMessage();
                system.debug('template: '+template);
            	emailBody = template.HtmlValue;   
                if(String.valueOf(payTransaction.Product__r.Name) != NULL){
                    emailBody = emailBody.replace('{!Payment_Transaction__c.Product__c}', 
                                                  String.valueOf(payTransaction.Product__r.Name));
                }
                if(String.valueOf(payTransaction.Amount__c) != NULL){
                    emailBody = emailBody.replace('{!Payment_Transaction__c.Amount__c}', 
                                                  String.valueOf(payTransaction.Amount__c));
                }
                if(String.valueOf(payTransaction.Site_ConnectURL__c) != NULL){
                    emailBody = emailBody.replace('{!Payment_Transaction__c.Site_ConnectURL__c}', 
                                                  String.valueOf(payTransaction.Site_ConnectURL__c));
                }
                if(String.valueOf(payTransaction.Connect_URL__c) != NULL){
                    emailBody = emailBody.replace('{!Payment_Transaction__c.Connect_URL__c}', 
                                                  String.valueOf(payTransaction.Connect_URL__c));
                }
                
                //emailBody = emailBody.replace('{!Account.Name}', payTransaction.Product__r.Customer__c);
                //emailBody = emailBody.replace('{!Payment_Transaction__c.Amount__c}', String.valueOf(payTransaction.Amount__c));
                sendTo = new List<String>();
                sendTo.add(payTransaction.Customer_Email_Address__c);
                mail.setToAddresses(sendTo);
                    if(!Test.isRunningTest()){
                        mail.setOrgWideEmailAddressId(OrgWideAddress.Id);   
                    }
                    mail.setSaveAsActivity(true);   // Set activity true to create activity once email is send
                    mail.setWhatId(payTransaction.Id);
                    system.debug('::'+payTransaction.Product__r.Customer__r.PersonContactID);
                	mail.setTargetObjectId(payTransaction.Product__r.Customer__r.PersonContactID); //To send Email to the Contact Email
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(template.Subject);                    
                    mails.add(mail);
			}            
        }
        if(!Test.isRunningTest()) {
            Messaging.sendEmail(mails);
        }
    }    
    public void finish(Database.BatchableContext bc){
		
    }
}