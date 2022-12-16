/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for UnsubscribeEmailsController
 *  @author : A5E Consulting
 *  @date : 07/09/2021
 
 *************************************************************************************************/
@isTest
public class TestCancelPaymentTransactionController {
    public static testMethod void CancelPaymentTransactionTest(){
        
        Test.setMock(HttpCalloutMock.class, new PaymentTransactionCreatorMockResponse());
        Customer_Payment_Processor_Settings__c settings = new Customer_Payment_Processor_Settings__c();
        settings.Name = 'Test Setting';
        settings.End_Point__c = 'https://test.com/api/';
        insert settings;
        
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentMaster();
        payTransaction.Product__c = productInstance.Id;
        payTransaction.Status__c = 'In progress';
        update payTransaction;
        PageReference pageRef = Page.CancelPaymentTransaction;
        pageRef.getParameters().put('id', String.valueOf(payTransaction.Id));
        Test.setCurrentPage(pageRef);   
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(payTransaction);
        CancelPaymentTransactionController controller = new CancelPaymentTransactionController(sc);
        controller.cancelTransaction();
        controller.redirect();
        Test.stopTest();
    }
}