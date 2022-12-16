/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for CustomerProductSyncSchedule
 *  @author : A5E Consulting
 *  @date : 02/08/2021
 
 *************************************************************************************************/
@isTest
public class TestPortalPaymentProcessorListner {
    public static testMethod void updatePayTransactionTest(){
        Customer_Payment_Processor_Settings__c payProcSettings  = new Customer_Payment_Processor_Settings__c();
        payProcSettings.Base_URL_for_Payment_Page_Iframe__c = '/';
        payProcSettings.Payment_URL_To_Get_Param__c = 'connect/';
        insert payProcSettings;
        
        Payment_Transaction__c requestFund = PaymentProcessorTestUtility.getRecurringRequestFund();

        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Payment_Processor_Id":"111", "End_Date": "2020-04-28T14:48:06.916779",'+
                                    '"Record_Type_Name": "Request Funds Recurring","Amount": 0.01,"Connect_Url": "test.com",'+
                                    '"Status": "Completed","Payment_Type": "Recurring Payment","Recurrence_Type": "Monthly","Day_Of_Month": 24,"Payment_Processor_Id": 121}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalPaymentProcessor.createRequestFunds();
    }
    
    public static testMethod void createPayTransactionTest(){
        Customer_Payment_Processor_Settings__c payProcSettings  = new Customer_Payment_Processor_Settings__c();
        payProcSettings.Base_URL_for_Payment_Page_Iframe__c = '/';
        payProcSettings.Payment_URL_To_Get_Param__c = 'connect/';
        insert payProcSettings;
        
        Payment_Transaction__c requestFund = PaymentProcessorTestUtility.getRecurringRequestFund();

        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Payment_Processor_Id":"111", "End_Date": "2020-04-28T14:48:06.916779",'+
                                    '"Record_Type_Name": "Request Funds Recurring","Amount": 0.01,"Connect_Url": "test.com/connect/1d398774-deff-4a3f",'+
                                    '"Status": "Completed","Payment_Type": "Recurring Payment","Recurrence_Type": "Monthly","Day_Of_Month": 24,"Payment_Processor_Id": 111}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalPaymentProcessor.createRequestFunds();
    }
}