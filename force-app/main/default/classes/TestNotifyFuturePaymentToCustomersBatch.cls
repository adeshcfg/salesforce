/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for NotifyFuturePaymentToCustomersBatch
 *  @author : A5E Consulting
 *  @date : 29/07/2021
 
 *************************************************************************************************/
@isTest
public class TestNotifyFuturePaymentToCustomersBatch {
    public static testMethod void notifyCustomerTest(){
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        productInstance.Customer__c = customerInstance.Id;
        update productInstance;
        
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentMaster();
        payTransaction.Product__c = productInstance.Id;
        Datetime yesterday = Datetime.now().addDays(-1);
        update payTransaction;
        
        Test.setCreatedDate(payTransaction.Id, yesterday);
        
        Test.startTest();        
        Database.executeBatch(new NotifyFuturePaymentToCustomersBatch());
        Test.stopTest();
    }
    
    public static testMethod void testschedule() {
        Test.StartTest();
        NotifyFuturePaymentToCustomersScheduler testsche = new NotifyFuturePaymentToCustomersScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}