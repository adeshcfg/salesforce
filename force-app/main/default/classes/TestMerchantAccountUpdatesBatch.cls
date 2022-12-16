/**************************************************************************************************
 *
 *  Class:   Test clas to update Merchant Account fields
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 11/03/2021
 
 *************************************************************************************************/
@isTest
public class TestMerchantAccountUpdatesBatch {
    static testmethod void TestBatch() {
        Account account = new Account();
        account.LastName = 'Test';
        insert account;
        
        Merchant_Account__c merchantAccount = new Merchant_Account__c();
        merchantAccount.Merchant__c = account.ID;
        merchantAccount.Last_Payment_Date__c = system.today().addDays(-5);
        merchantAccount.Max_Days_Delinquent__c = 3;
        insert merchantAccount;
        system.debug('Days_Delinquent__c'+merchantAccount.Days_Delinquent__c);        
        Merchant_Account_Payment__c merchantAccountPayment = new Merchant_Account_Payment__c();
        merchantAccountPayment.Amount__c = 25;
        merchantAccountPayment.TranDate__c = system.today().addDays(-5);
        merchantAccountPayment.LeadId__c = merchantAccount.ID;
        insert merchantAccountPayment;
        
        Test.startTest();
        MerchantAccountUpdatesBatch c = new MerchantAccountUpdatesBatch();
        Database.executeBatch(c);
        
        MerchantAccountUpdatesSchedular testsche = new MerchantAccountUpdatesSchedular();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
    }
    
    /*
    static testmethod void testBatch2() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= 'standarduser121@testorg.com');
        system.debug('u'+u.username);
        Datetime DtTym = DateTime.now();
        String str = DtTym.format('MMMMM');
        System.debug('Month : ' + str);
        
        Holiday holiday = new Holiday();
        holiday.Name='Test holiday';
        holiday.activityDate = Date.Today();
        holiday.IsRecurrence = true;
        holiday.RecurrenceStartDate = Date.today();
        holiday.RecurrenceType = 'RecursYearly';
        holiday.RecurrenceDayOfMonth = Date.today().month();
        holiday.RecurrenceMonthOfYear = str;
        insert holiday;
        System.runAs(u) {
            Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Merchant').getRecordTypeId();
            system.debug('devRecordTypeId'+devRecordTypeId);
            Account account = new Account();
            account.Name = 'Test';
            account.recordtypeID = devRecordTypeId;
            insert account;
            
            Merchant_Account__c merchantAccount = new Merchant_Account__c();
            merchantAccount.Merchant__c = account.ID;
            merchantAccount.Last_Payment_Date__c = Date.today().addDays(-20);
            merchantAccount.Max_Days_Delinquent__c = 1;
            insert merchantAccount;
            system.debug('Days_Delinquent__c'+merchantAccount.Days_Delinquent__c);        
            Merchant_Account_Payment__c merchantAccountPayment = new Merchant_Account_Payment__c();
            merchantAccountPayment.Amount__c = 25;
            merchantAccountPayment.TranDate__c = system.today().addDays(-5);
            merchantAccountPayment.LeadId__c = merchantAccount.ID;
            insert merchantAccountPayment;
            
            Test.startTest();
            MerchantAccountUpdatesBatch c = new MerchantAccountUpdatesBatch();
            Database.executeBatch(c);
            
            MerchantAccountUpdatesSchedular testsche = new MerchantAccountUpdatesSchedular();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
            Test.stopTest();
        }
    }
    */
}