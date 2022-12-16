/**************************************************************************************************
*
*  Class:   
*
*  @description : TestVersaPayListnerUtil for Versapay
*  @author : A5E Consulting
*  @date : 07/12/2016   

*************************************************************************************************/
@isTest
public class TestVersaPayListnerUtil{
         
    static {
        Payment_Processing_Settings__c payProcSettingsAffirm = new Payment_Processing_Settings__c(Name = 'Affirm');    
        payProcSettingsAffirm.VersaPay_Auth_Key_Credit__c='SjlnsdjKJ';
        payProcSettingsAffirm.VersaPay_Auth_Token_Credit__c='SGHJDKLDLKSL';
        payProcSettingsAffirm.VersaPay_Auth_Key_Debit__c='SjlnsdjKJ';
        payProcSettingsAffirm.VersaPay_Auth_Token_Debit__c='SGHJDKLDLKSL';
        payProcSettingsAffirm.VersaPay_End_Point__c='www.versapytest.com';
        payProcSettingsAffirm.VersaPay_Signing_Key__c='siging Key';
        payProcSettingsAffirm.Memo_Details__c = 'Affirm Financial TermLoan';
        insert payProcSettingsAffirm;
        
        Payment_Processing_Settings__c payProcSettingsFidem = new Payment_Processing_Settings__c(Name = 'Fidem');    
        payProcSettingsFidem.VersaPay_Auth_Key_Credit__c='SjlnsdjKJ';
        payProcSettingsFidem.VersaPay_Auth_Token_Credit__c='SGHJDKLDLKSL';
        payProcSettingsFidem.VersaPay_Auth_Key_Debit__c='SjlnsdjKJ';
        payProcSettingsFidem.VersaPay_Auth_Token_Debit__c='SGHJDKLDLKSL';
        payProcSettingsFidem.VersaPay_End_Point__c='www.versapytest.com';
        payProcSettingsFidem.VersaPay_Signing_Key__c='siging Key';
        payProcSettingsFidem.Memo_Details__c = 'Fidem Financial TermLoan';
        insert payProcSettingsFidem;
        
        Loan_ReEngineering__c loanReCS = new Loan_ReEngineering__c();
        loanReCS.Default_Company_Name__c = 'Fidem';
        insert loanReCS;    
    }
    
    static testMethod void createPaymentTestMethod(){
        
        VersaPayListnerUtil.mapVersaPayState();
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        //prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        prod.Source_System__c = 'Megasys';     
        insert prod;
        
        //VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        //vpPay.Product__c = prod.id;
        //vpPay.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        //insert vpPay;
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '12345');
        //req.addParameter('unique_reference', '12345');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'completed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductPaymentTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        
        insert prod;
        
        VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        vpPay.Product__c = prod.id;
       // vpPay.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        insert vpPay;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductPaymentWithAccountTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';        
        insert prod;
        
        VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        vpPay.Product__c = prod.id;
        insert vpPay;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '12345');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductNSFEDTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductCompletedNSFEDTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'completed_but_nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductErrorTestMethod(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'error');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaPayListner.listenWebHook();
    }
    
    /********** These are test methods for new VersaaPayListner **************/
    static testMethod void createPaymentTestMethod2(){
        
        VersaPayListnerUtil.mapVersaPayState();
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        //prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        prod.Source_System__c = 'Megasys';     
        insert prod;
        
        //VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        //vpPay.Product__c = prod.id;
        //vpPay.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        //insert vpPay;
                
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '12345');
        //req.addParameter('unique_reference', '12345');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'completed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductPaymentTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
        
        insert prod;
        
        VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        vpPay.Product__c = prod.id;
        //vpPay.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        insert vpPay;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductPaymentWithAccountTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';        
        insert prod;
        
        VersaPay_Product_Payment__c vpPay = new VersaPay_Product_Payment__c();
        vpPay.Product__c = prod.id;
        insert vpPay;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_debit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '12345');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductNSFEDTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductCompletedNSFEDTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
      //  prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'completed_but_nsfed');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
    
    static testMethod void updateProductErrorTestMethod2(){
        
        Product__c prod = new Product__c();
        prod.name = '12345';
       // prod.VersaPay_Token_Number__c = '1IXL5IX3D2IM';
        
        insert prod;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueof('Blob[0]');
        
        req.addParameter('amount_in_cents', '9175');
        req.addParameter('created_by_user','yujpqgPa_vscKNcz8Gkf');
        req.addParameter('email', '');
        req.addParameter('to_account', 'Canaccede');
        req.addParameter('to_fund', 'VersaPay Balance');
        req.addParameter('message', '');
        req.addParameter('process_on', '2016-11-20');
        req.addParameter('signature', 'chLtBK7zl7wBg8QCSceORjAyPydfUSj%2FpMOgaxlLgUI%3D%0A');
        req.addParameter('state', 'error');
        req.addParameter('type', 'transaction');
        req.addParameter('transaction_type', 'direct_credit');
        req.addParameter('token', '1IXL5IX3D2IM');
        req.addParameter('transaction_reference', '');
        req.addParameter('unique_reference', '');
        req.addParameter('link_url ', '');
        req.addParameter('auto_withdraw ', 'false');
        req.addParameter('auto_withdrawal_token', '');
        req.addParameter('from_account', 'KIMBERLY POND');
        req.addParameter('from_fund_token', 'BA9V6XLJD8TP');
                    
        req.requestURI = '/VersaPay';  
        req.httpMethod = 'POST';
        req.resourcePath = '/services/apexrest/VersaaPay/*';
        
        RestContext.request = req;
        RestContext.response = res;
        
        VersaaPayListner.listenWebHook();
    }
}