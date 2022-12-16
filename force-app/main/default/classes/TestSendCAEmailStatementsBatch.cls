/**************************************************************************************************
 *
 *  Class:   Test clas to update Merchant Account fields
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 05/04/2021
 
 *************************************************************************************************/
@isTest
public class TestSendCAEmailStatementsBatch {
	static testmethod void TestBatch() {
        Account account = new Account();
        account.LastName = 'Test';
        account.Business_Email__c = 'test@test.com';
        insert account;
        
        Merchant_Account__c merchantAccount = new Merchant_Account__c();
        merchantAccount.Merchant__c = account.ID;
        merchantAccount.Current_Balance__c = 3000;
        merchantAccount.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount.Last_Payment_Date__c = system.today().addDays(-5);
        merchantAccount.Email__c = 'test1@test.com';
        insert merchantAccount;
        
        Merchant_Account_Payment__c merchantAccountPayment = new Merchant_Account_Payment__c();
        merchantAccountPayment.Amount__c = 25;
        merchantAccountPayment.TranDate__c = system.today().addDays(-5);
        merchantAccountPayment.LeadId__c = merchantAccount.ID;
        insert merchantAccountPayment;
        
        Test.startTest();
        SendMCAEmailStatementsBatch batch = new SendMCAEmailStatementsBatch();
        Database.executeBatch(batch);
        
        SendMCAEmailStatementsBatchSchedular testsche = new SendMCAEmailStatementsBatchSchedular();
		String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
    }
}