/**************************************************************************************************
 *
 *  Class:   Test class for MerchantAccountPaymentTriggerHandler class
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 22/03/2021
 
*************************************************************************************************/
@isTest
public class TestMerchantAccountPaymentTriggerHandler {
    static testmethod void testDate(){
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    	config.Run_Merchant_Account_Payment_Trigger__c = true;
        insert config;
        
		Account account = new Account();
        account.LastName = 'Test';
        account.DBA__c = 'Test DBA';
        insert account;
        
        Merchant_Account__c merchantAccount = new Merchant_Account__c();
        merchantAccount.Name = '1922497';
        merchantAccount.Merchant__c = account.Id;
        merchantAccount.Current_Balance__c = 3000;
        merchantAccount.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount.Last_Pay_Amount__c = 20;
        merchantAccount.Last_Payment_Date__c = system.today().addDays(-10);
        insert merchantAccount;
        
        Merchant_Account__c merchantAccount2 = new Merchant_Account__c();
        merchantAccount2.Name = '1922493';
        merchantAccount2.Current_Balance__c = 4000;
        merchantAccount2.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount2.Last_Pay_Amount__c = 60;
        merchantAccount2.Last_Payment_Date__c = system.today().addDays(-10);
        merchantAccount2.Merchant__c = account.Id;
        insert merchantAccount2;
        
        list<Merchant_Account_Payment__c> listMerchantAccPayment = new list<Merchant_Account_Payment__c>();
        
        Merchant_Account_Payment__c merchantAccPayment = new Merchant_Account_Payment__c();
        merchantAccPayment.TranDate__c = system.today().addDays(-20);
        merchantAccPayment.Amount__c = 20;
        merchantAccPayment.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment);
        //insert merchantAccPayment;
        
        Merchant_Account_Payment__c merchantAccPayment2 = new Merchant_Account_Payment__c();
        merchantAccPayment2.TranDate__c = system.today().addDays(-3);
        merchantAccPayment2.Amount__c = 20;
        merchantAccPayment2.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment2);
        //insert merchantAccPayment2;
        
        Merchant_Account_Payment__c merchantAccPayment5 = new Merchant_Account_Payment__c();
        merchantAccPayment5.TranDate__c = system.today().addDays(-21);
        merchantAccPayment5.Amount__c = 20;
        merchantAccPayment5.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment5);
        //insert merchantAccPayment5;
        
        Merchant_Account_Payment__c merchantAccPayment3 = new Merchant_Account_Payment__c();
        merchantAccPayment3.TranDate__c = system.today().addDays(-10);
        merchantAccPayment3.Amount__c = 20;
        merchantAccPayment3.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment3);
        //insert merchantAccPayment3;
        
        Merchant_Account_Payment__c merchantAccPayment4 = new Merchant_Account_Payment__c();
        merchantAccPayment4.TranDate__c = system.today().addDays(-5);
        merchantAccPayment4.Amount__c = 20;
        merchantAccPayment4.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment4);
        //insert merchantAccPayment4;
        
        Merchant_Account_Payment__c merchantAccPayment7 = new Merchant_Account_Payment__c();
        merchantAccPayment7.TranDate__c = system.today().addDays(-2);
        merchantAccPayment7.Amount__c = 20;
        merchantAccPayment7.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment7);
        //insert merchantAccPayment7;
        
        insert listMerchantAccPayment;
    }
}