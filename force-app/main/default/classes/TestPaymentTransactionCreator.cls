/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PaymentTransactionCreator
 *  @author : A5E Consulting
 *  @date : 30/07/2021
 
 *************************************************************************************************/
@isTest
public class TestPaymentTransactionCreator {
    public static testMethod void oneTimeRequestFundCreationTest(){
        Test.setMock(HttpCalloutMock.class, new PaymentTransactionCreatorMockResponse());

        Customer_Payment_Processor_Settings__c settings = new Customer_Payment_Processor_Settings__c();
        settings.Name = 'Test Setting';
        settings.End_Point__c = 'https://test.com/api/';
        insert settings;
        
        Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        productInstance.Customer__c = customerInstance.Id;
        update productInstance;
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringRequestFund();
        payTransaction.Product__c = productInstance.Id;
        update payTransaction;
        
        PaymentTransactionCreator.postPaymentToZumrails(payTransaction.Id);
    }
    

}