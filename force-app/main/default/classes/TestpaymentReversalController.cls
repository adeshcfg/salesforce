/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for paymentReversal
*  @author : A5E Consulting
*  @date : 09/04/2020
* 
*************************************************************************************************/
@isTest
public class TestpaymentReversalController {
    @testSetup
    static void testthis(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Remittance_Validation__c = false,Run_Remittance_Trigger__c  = true,Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
                                                                                   Run_Insolvency_Trigger__c = false,Run_Insolvency_Account_Duplicate_Check__c = True,Run_Insolvency_Account_Trigger__c=false,
                                                                                   Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',Run_Insolvency_Status_Validations__c = True,
                                                                                   Bank_Eligible_for_Duplicate_Check__c = 'SPL',Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm');
        insert config;
    }
    static testmethod void TestData(){
        //CCS Agency 
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        insert prod;
        
        /*Account acc1= new Account( Name='krishna');
        acc1.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc1;*/
        //Dividend for CCS//
        Remittance__c remittance2 = new Remittance__c();
        remittance2.Status__c = 'New';
        remittance2.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'CCS_Dividend' and sobjecttype ='Remittance__C'].Id;
        remittance2.Cheque_Amount__c = 145.25;
        remittance2.Fairshare_Amount__c =100.25;
        remittance2.Deposit_Account_Name__c='CIHL';
       // remittance2.CCS_Agency__c = acc1.Id;//
        insert remittance2;
        
        // Dividend for insolvency//
        Id accountTrusteeCompanyRtypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Trustee Company').getRecordTypeId();
        Account acc = new Account(Name='test', RecordTypeID = accountTrusteeCompanyRtypeId);
        insert acc;
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.recordTypeid = [SELECT id FROM RecordType WHERE DeveloperName = 'Insolvency_Dividend' and sobjecttype ='Remittance__C'].Id;
        remittance1.Cheque_Amount__c = 145.25;
        remittance1.Deposit_Account_Name__c='CIHL';
        remittance1.Trustee_name__c = acc.Id;
        insert remittance1;
        //Insolvency Account Record
        Insolvency_Account__c insAcc2 = new Insolvency_Account__c();
        insAcc2.Insolvency_Status__c = 'For Owner Review';
        insAcc2.Client_Identifier__c='Scotia Bank';
        insAcc2.Claim_Type__c = 'Unsecured';
        /*sAcc2.Insolvency__c = insolv1.id;*/
        insAcc2.Name = 'Test- 002';
        insAcc2.Account_Number_Without_Space__c='Test-002';
        insert insAcc2;       
        
        
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = remittance2.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        //unAloccPay.Remittance__c=divid.Id;
        insert unAloccPay;
        
        
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=remittance2.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        insert prodpay;
        // insolvency payments
        //Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.Insolvency_Account__c = insAcc2.Id;
        insert payment1;
        
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(remittance2.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(remittance2);
        PaymentReversalController payment=new PaymentReversalController(sc);
        
                
                payment.submit();
                
                payment.ccspayments();
                payment.insonlencypayments();
                payment.Unallocated();
                payment.getItems();
                
            }
        }