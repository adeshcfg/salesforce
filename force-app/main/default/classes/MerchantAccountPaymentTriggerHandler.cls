/**************************************************************************************************
 *
 *  Class:   Trigger handler class for Merchant Account Payment object
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 17/03/2021
 
*************************************************************************************************/
public class MerchantAccountPaymentTriggerHandler { 
    public static void handleAfterInsert(list<Merchant_Account_payment__c> listNewMerchantPayment){
        //Call batch to update balance amounts on Merchant Account Payments
        Database.executeBatch(new MerchantAccountPaymentUpdatesBatch(), 200);
    }
}