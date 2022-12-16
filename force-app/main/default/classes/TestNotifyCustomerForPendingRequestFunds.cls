/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for NotifyFuturePaymentToCustomersBatch
 *  @author : A5E Consulting
 *  @date : 30/07/2021
 
 *************************************************************************************************/
@isTest
public class TestNotifyCustomerForPendingRequestFunds{
    public static testMethod void notifyRequestFundToCustomerTest(){
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        productInstance.Customer__c = customerInstance.Id;
        update productInstance;
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringRequestFund();
        payTransaction.Product__c = productInstance.Id;
        payTransaction.Site_ConnectURL__c = 'www.test.com';
        update payTransaction;
        DateTime dt = DateTime.now().addDays(-1);
        Test.setCreatedDate(payTransaction.id, dt);
        Test.startTest();
        Database.executeBatch(new NotifyCustomerForPendingRequestFunds());
        Test.stopTest();
    }
    
    public static testMethod void testschedule() {
        Test.StartTest();
        NotifyPendingRequestFundsScheduler testsche = new NotifyPendingRequestFundsScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}