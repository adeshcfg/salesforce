/**************************************************************************************************
*
*  Class:   
*
*  @description : Test class for RequestPaymentController
*  @author : A5E Consulting
*  @date : 02/08/2021
*
*************************************************************************************************/
@isTest
public class TestRequestPaymentController {
    public static testMethod void createRequestFunds(){
        Placement__c placement = new Placement__c(Name = '68', Include_In_Portal_Search__c = True);
        insert placement;
        
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
                
        RequestPaymentController.getproduct(productInstance.Id);
        RequestPaymentController.eligibleProduct(productInstance.Id);
        RequestPaymentController.saveTransaction(String.valueOf(productInstance.Id), 'Recurring Payment', 'Monthly', 10, '', '10', system.today().addMonths(4), '4', 'testuser@testorg.com');
    }
    
    public static testMethod void errorInCreateRequestFunds(){       
        Product__c productInstance = PaymentProcessorTestUtility.getDistressedProduct();
                
        RequestPaymentController.getproduct(productInstance.Id);
        RequestPaymentController.eligibleProduct(productInstance.Id);
        RequestPaymentController.saveTransaction(String.valueOf(productInstance.Id), 'One Time Payment', '', 10, '', '', null, '', 'testuser@testorg.com');
    }
}