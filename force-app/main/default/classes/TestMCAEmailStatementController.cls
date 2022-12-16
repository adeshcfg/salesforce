/**************************************************************************************************
 *
 *  Class:   Test clas for MCAEmailStatementController
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 27/05/2021
 
 *************************************************************************************************/
@isTest
public class TestMCAEmailStatementController {
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
        merchantAccount.Date_when_payments_loaded__c = Date.today().addMonths(-2);
      	merchantAccount.Current_Balance_When_Payments_Loaded__c = 5000;
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
        merchantAccPayment.TranDate__c = Date.today().toStartOfMonth().addDays(-1);
        merchantAccPayment.Amount__c = 20;
        merchantAccPayment.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment);
      
        Merchant_Account_Payment__c merchantAccPayment8 = new Merchant_Account_Payment__c();
        merchantAccPayment8.TranDate__c = Date.today().addMonths(-2);
        merchantAccPayment8.Amount__c = 20;
        merchantAccPayment8.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment8);
        //insert merchantAccPayment;
        
        Merchant_Account_Payment__c merchantAccPayment2 = new Merchant_Account_Payment__c();
        merchantAccPayment2.TranDate__c = Date.today().toStartOfMonth().addDays(-5);
        merchantAccPayment2.Amount__c = 20;
        merchantAccPayment2.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment2);
        //insert merchantAccPayment2;
        
        Merchant_Account_Payment__c merchantAccPayment5 = new Merchant_Account_Payment__c();
        merchantAccPayment5.TranDate__c = Date.today().toStartOfMonth().addDays(-1);
        merchantAccPayment5.Amount__c = 20;
        merchantAccPayment5.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment5);
        //insert merchantAccPayment5;
        
        Merchant_Account_Payment__c merchantAccPayment3 = new Merchant_Account_Payment__c();
        merchantAccPayment3.TranDate__c = Date.today().toStartOfMonth().addDays(-2);
        merchantAccPayment3.Amount__c = 20;
        merchantAccPayment3.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment3);
        //insert merchantAccPayment3;
        
        Merchant_Account_Payment__c merchantAccPayment4 = new Merchant_Account_Payment__c();
        merchantAccPayment4.TranDate__c = Date.today().toStartOfMonth().addDays(-5);
        merchantAccPayment4.Amount__c = 20;
        merchantAccPayment4.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment4);
        //insert merchantAccPayment4;
        
        Merchant_Account_Payment__c merchantAccPayment7 = new Merchant_Account_Payment__c();
        merchantAccPayment7.TranDate__c = Date.today().toStartOfMonth().addDays(-9);
        merchantAccPayment7.Amount__c = 20;
        merchantAccPayment7.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment7);
        //insert merchantAccPayment7;
        
        insert listMerchantAccPayment;
        
        Test.setCurrentPageReference(new PageReference('MCAEmailStatement')); 
    System.currentPageReference().getParameters().put('id', merchantAccount.Id);
        MCAEmailStatementController controller = new MCAEmailStatementController();
    }
    
    
    static testmethod void testDate2(){
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
        merchantAccount.Date_when_payments_loaded__c = Date.today().addMonths(-2);
      	merchantAccount.Current_Balance_When_Payments_Loaded__c = 5000;
        insert merchantAccount;
        
        Merchant_Account__c merchantAccount2 = new Merchant_Account__c();
        merchantAccount2.Name = '1922493';
        merchantAccount2.Current_Balance__c = 4000;
        merchantAccount2.Collective_Cash_Collections_CAD__c = 2000;
        merchantAccount2.Last_Pay_Amount__c = 60;
        merchantAccount2.Last_Payment_Date__c = system.today().addDays(-10);
        merchantAccount2.Merchant__c = account.Id;
        merchantAccount2.Date_when_payments_loaded__c = Date.today().addMonths(-2);
      	merchantAccount2.Current_Balance_When_Payments_Loaded__c = 5000;
        insert merchantAccount2;
        
        list<Merchant_Account_Payment__c> listMerchantAccPayment = new list<Merchant_Account_Payment__c>();
        
        Merchant_Account_Payment__c merchantAccPayment = new Merchant_Account_Payment__c();
        merchantAccPayment.TranDate__c = Date.today().toStartOfMonth().addDays(-32);
        merchantAccPayment.Amount__c = 20;
        merchantAccPayment.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment);
        //insert merchantAccPayment;
        
        Merchant_Account_Payment__c merchantAccPayment8 = new Merchant_Account_Payment__c();
        merchantAccPayment8.TranDate__c = Date.today().addMonths(-2);
        merchantAccPayment8.Amount__c = 20;
        merchantAccPayment8.LeadId__c = merchantAccount.ID;
        listMerchantAccPayment.add(merchantAccPayment8);
        
        Merchant_Account_Payment__c merchantAccPayment2 = new Merchant_Account_Payment__c();
        merchantAccPayment2.TranDate__c = Date.today().toStartOfMonth().addDays(5);
        merchantAccPayment2.Amount__c = 20;
        merchantAccPayment2.LeadId__c = merchantAccount2.ID;
        listMerchantAccPayment.add(merchantAccPayment2);
        //insert merchantAccPayment2;
        
        insert listMerchantAccPayment;
        
        Test.setCurrentPageReference(new PageReference('MCAEmailStatement')); 
    	System.currentPageReference().getParameters().put('id', merchantAccount2.Id);
        MCAEmailStatementController controller = new MCAEmailStatementController();
    }
    

}