/**************************************************************************************************
 *
 *  Class:   Test clas to update Merchant Account fields
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 01/04/2021
 
 *************************************************************************************************/
@isTest
public class TestMerchantAccountPaymentUpdatesBatch {
	static testmethod void TestBatch() {
        Account account = new Account();
        account.LastName = 'Test';
        insert account;
        Merchant_Account__c merchantAccount1 = new Merchant_Account__c();
        merchantAccount1.Merchant__c = account.ID;
        merchantAccount1.Current_Balance__c = 3000;
        merchantAccount1.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount1.Last_Payment_Date__c = system.today().addDays(-5);
        insert merchantAccount1;
        
        Merchant_Account_Payment__c merchantAccountPayment3 = new Merchant_Account_Payment__c();
        merchantAccountPayment3.Amount__c = 25;
        merchantAccountPayment3.TranDate__c = system.today().addDays(-7);
        merchantAccountPayment3.LeadId__c = merchantAccount1.ID;
        insert merchantAccountPayment3;
        
        Merchant_Account__c merchantAccount = new Merchant_Account__c();
        merchantAccount.Merchant__c = account.ID;
        merchantAccount.Current_Balance__c = 3000;
        merchantAccount.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount.Last_Payment_Date__c = system.today().addDays(-5);
        insert merchantAccount;
        
        Merchant_Account_Payment__c merchantAccountPayment = new Merchant_Account_Payment__c();
        merchantAccountPayment.Amount__c = 25;
        merchantAccountPayment.TranDate__c = system.today().addDays(-5);
        merchantAccountPayment.LeadId__c = merchantAccount.ID;
        insert merchantAccountPayment;
        
        Merchant_Account_Payment__c merchantAccountPayment2 = new Merchant_Account_Payment__c();
        merchantAccountPayment2.Amount__c = 25;
        merchantAccountPayment2.TranDate__c = system.today().addDays(-3);
        merchantAccountPayment2.LeadId__c = merchantAccount.ID;
        insert merchantAccountPayment2;
        
        Test.startTest();
        MerchantAccountPaymentUpdatesBatch c = new MerchantAccountPaymentUpdatesBatch();
        Database.executeBatch(c);
        
        MerchantAccountUpdatesSchedular testsche = new MerchantAccountUpdatesSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
    }
}