/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PaymentTransactionCSVController
 *  @author : A5E Consulting
 *  @date : 29/07/2021
 
 *************************************************************************************************/
@isTest
public class TestPaymentTransactionCSVController {
    public static testMethod void CSVGenerationTest(){
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
        Payment_Transaction__c payTransaction = PaymentProcessorTestUtility.getRecurringPaymentChild();
       	payTransaction.Product__c = productInstance.Id;
        update payTransaction;
        system.debug('sss'+[select id, Record_Type_Name__c, RecordType.DeveloperName, status__c from Payment_Transaction__c]);
        
        
        PageReference pageRef = Page.PaymentTransactionCSV;
        pageRef.getParameters().put('id', String.valueOf(payTransaction.Id));
        Test.setCurrentPage(pageRef);   
        
        ApexPages.StandardController sc = new ApexPages.StandardController(payTransaction);
        PaymentTransactionCSVController controller = new PaymentTransactionCSVController(sc);
        controller.generateCSV();
        controller.getPaymentTransactionsCSV();
        controller.getPaymentTransactions();
        payTransaction.Product__c = productInstance.Id;
        update payTransaction;
        controller = new PaymentTransactionCSVController(sc);
    }
	 
}