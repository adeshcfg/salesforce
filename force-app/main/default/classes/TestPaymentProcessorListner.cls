/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for CustomerProductSyncSchedule
 *  @author : A5E Consulting
 *  @date : 02/08/2021
 
 *************************************************************************************************/
@isTest
public class TestPaymentProcessorListner {
    public static testMethod void createPayChildTransactionTest(){
        Customer_Payment_Processor_Settings__c payProcSettings = new Customer_Payment_Processor_Settings__c();
        payProcSettings.Signing_Key__c = 'TestSigningKey';
        insert payProcSettings;
        
        Payment_Transaction__c requestFund = PaymentProcessorTestUtility.getRecurringRequestFund();
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentMaster();
        payTransaction.Parent__c = requestFund.Id;
        update payTransaction;
        
        Http h = new Http();
        // Instantiate a new HTTP request
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Data":{"Id":"11233", "CreatedAt": "2020-04-28T14:48:06.916779","RecurrentTransactionId": "1111111","Amount": 0.01,"TransactionStatus": "","Comment": "","RecurrenceType": "Monthly"}}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PaymentProcessorListner.listenWebHook();
    }


    public static testMethod void createRecurrentPayTransactionTest(){
        Customer_Payment_Processor_Settings__c payProcSettings = new Customer_Payment_Processor_Settings__c();
        payProcSettings.Signing_Key__c = 'TestSigningKey';
        insert payProcSettings;
        
        Payment_Transaction__c requestFund = PaymentProcessorTestUtility.getRecurringRequestFund();
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentMaster();
        payTransaction.Parent__c = requestFund.Id;
        update payTransaction;
        
        Http h = new Http();
        // Instantiate a new HTTP request
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Data":{"Id":"11233", "Comment": "","TransactionMethod":"eft", "CreatedAt": "2020-04-28T14:48:06.916779","Amount": 0.01, "EndDate": "2021-08-28T04:00:00", "StartDate": "2020-01-20T03:00:00","RecurrenceType": "Monthly","DayOfWeek": null,"DayOfMonth": 24,"TransactionStatus": "","TransactionsIds": ["47996650-...-0d082ee63b5e"]}}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PaymentProcessorListner.listenWebHook();
    }
    
    public static testMethod void updatePayTransactionTest(){
        Customer_Payment_Processor_Settings__c payProcSettings = new Customer_Payment_Processor_Settings__c();
        payProcSettings.Signing_Key__c = 'TestSigningKey';
        insert payProcSettings;
        
        Payment_Transaction__c requestFund = PaymentProcessorTestUtility.getRecurringRequestFund();
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentChild();
        payTransaction.Parent__c = requestFund.Id;
        update payTransaction;
        
        Http h = new Http();
        // Instantiate a new HTTP request
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Data":{"Id":"33333", "Comment": "","Amount": 0.01,"TransactionStatus": "Failed"}}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PaymentProcessorListner.listenWebHook();
    }
}