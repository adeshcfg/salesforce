/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of InlineInsolvencyAccountsCntrl
*  @author : A5E Consulting
*  @date : 03/09/2018
* 
*************************************************************************************************/

@isTest
public class TestUnallocatedPaymentControllerNew{
    
    @testSetup
    static void testData(){
       
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Remittance_Validation__c = false,Run_Remittance_Trigger__c  = true,Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
                                                                                   Run_Insolvency_Trigger__c = false,Run_Insolvency_Account_Duplicate_Check__c = True,Run_Insolvency_Account_Trigger__c=false,
                                                                                   Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',Run_Insolvency_Status_Validations__c = True,
                                                                                   Bank_Eligible_for_Duplicate_Check__c = 'SPL',Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
                                                                                   Final_Deposit_Slip__c = System.Today().addDays(-2));
        insert config;
        Remittance__c remit = new Remittance__c(Cheque_Payment_Reference_Number__c = '1234', 
                                                Cheque_Amount__c = 12.00,
                                                Total_Unallocated_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id,
                                                Status__c = 'New' );
        insert remit;       
        
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Remittance__c = remit.Id, Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod.Product_Status__c = 'Test';
        insert prod;
        
        //Insolvency 
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insolv.Insolvency_Status__c = 'For Owner Review';
        insert insolv;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c= 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';
        
        insert depAcc;
        remit.Deposit_Account_Name__c='CIML';
        update remit;
              
        //insolvency account creation//
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Is_Duplicate_Resolved__c = false;
        insolAcct.RecordTypeId = scotiabank;
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        //insolAcct.Portfolio_Group_Name__c = 'AAL001';
        insert insolAcct;
        
        //Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remit.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.Insolvency_Account__c =insolAcct.id;
        payment1.Unallocated_Payment__c=unAloccPay.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        
        Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'CIH';
        insert prodPayments;
    }
    
    
    //Test Controller
    static testMethod void testController(){
        Unallocated_Payment__c unAloccPay = [SELECT Id FROM Unallocated_Payment__c LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
        obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
    }
    
    static testMethod void testController1(){
        
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
        
        Remittance__c remit = new Remittance__c(Cheque_Payment_Reference_Number__c = '1234', 
                                                Cheque_Amount__c = 12.00,
                                                Total_Unallocated_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id,
                                                Status__c = 'New' );
        insert remit;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CCL';
        insert payment2;
        
        Insolvency_Payment__c payment3 = new Insolvency_Payment__c();
        payment3.Payment_Amount__c = 1123.00;
        payment3.Insolvency_Account__c =insolAcct1.id;
        payment3.Unallocated_Payment__c=unAloccPay.id;
        payment3.Deposit_Account_Type__c = 'CIA';
        insert payment3;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'CCL';
        insert prodPayments;
        
        Product_Payments__c prodPayments1 = new Product_Payments__c();
        prodPayments1.Dividend__c = remit.Id;
        prodPayments1.Payment_Amount__c = 1123.00;
        prodPayments1.CCS_Account__c =prod1.id;
        prodPayments1.Unallocated_Payment__c=unAloccPay.id;
        prodPayments1.Deposit_Account_Type__c = 'CIA';
        insert prodPayments1;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);       
    }
    
    static testMethod void testController2(){
        Remittance__c remit = new Remittance__c(Cheque_Payment_Reference_Number__c = '1234', 
                                                Cheque_Amount__c = 12.00,
                                                Total_Unallocated_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id,
                                                Status__c = 'New' );
        insert remit;       
        
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Remittance__c = remit.Id, Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'ETC';
        insert payment2;
        
		Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'ETC';
        insert prodPayments;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.insolpaysave();
        obj.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
       
        obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        unAloccPay.Unallocated_Amount__c = 12.00;
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.insolpaysave();
        UnallocatedPaymentControllerNew obj1 = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay));
        obj1.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj1.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
    }
 	
    static testMethod void testController3(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Allocated__c =false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CIH';
        insert payment2;
        
        Insolvency_Payment__c payment3 = new Insolvency_Payment__c();
        payment3.Remittance__c = unAloccPay.Remittance__c;
        payment3.Payment_Amount__c = 1123.00;
        payment3.Insolvency_Account__c =insolAcct1.id;
        payment3.Unallocated_Payment__c=unAloccPay.id;
        payment3.Deposit_Account_Type__c = 'CIA';
        insert payment3;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'CIH';
        insert prodPayments;
        
        Product_Payments__c prodPayments1 = new Product_Payments__c();
        prodPayments1.Dividend__c = remit.Id;
        prodPayments1.Payment_Amount__c = 1123.00;
        prodPayments1.CCS_Account__c =prod1.id;
        prodPayments1.Unallocated_Payment__c=unAloccPay.id;
        prodPayments1.Deposit_Account_Type__c = 'CIA';
        insert prodPayments1;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.insolpaysave();
        UnallocatedPaymentControllerNew obj1 = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        obj1.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj1.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
    }
    
    static testMethod void testController4(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Allocated__c =false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'ETC';
        insert payment2;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'ETC';
        insert prodPayments;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.insolpaysave();
        UnallocatedPaymentControllerNew obj1 = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        obj1.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj1.prodpaysave();
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
    }
    
    static testMethod void testController5(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Allocated__c =false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'AAL';
        insert payment2;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'AAL';
        insert prodPayments;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.insolpaysave();
        UnallocatedPaymentControllerNew obj1 = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        obj1.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        obj.selected = 'Insolvency';
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
    }
    
    static testMethod void testController6(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%inso%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%inso%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%inso%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%inso%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%inso%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        obj.selected = 'Insolvency';
        unAloccPay.Unallocated_Amount__c = 12.00;
        update unAloccPay;
        
        apexpages.currentPage().getparameters().put('insolvAcc', insolAcct1.id);
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.insolpaysave();
        obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj = new UnallocatedPaymentControllerNew (new ApexPages.StandardController(unAloccPay));
        obj.check();
        apexpages.currentPage().getparameters().put('check', null);
        obj.sorSave();
        apexpages.currentPage().getparameters().put('sor', null);
        
    }
    
    static testMethod void testController7(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%inso%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%inso%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%inso%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%inso%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%inso%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
        obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.prodpaysave();
    }
    
    static testMethod void testController8(){
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
               
        Remittance__c remit = new Remittance__c();
        remit.Cheque_Payment_Reference_Number__c = '1234'; 
        remit.Cheque_Amount__c = 12.00;
        remit.Total_Unallocated_Amount__c = 12.00;
        remit.Payment_Posting_Date__c = System.Today().addDays(-2);
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        insert remit;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c();
        unAloccPay.Account_Number__c = 'unknown';
        unAloccPay.Deposit_Slip__c=ds.id;
        unAloccPay.Cheque_Number__c='12345';
        unAloccPay.Is_Payment_Remitted__c=false;
        unAloccPay.Allocated__c =false;
        unAloccPay.Remittance__c = remit.id;
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Scotia_Bank_Insolvency_Account').getRecordTypeId();
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Line of Credit';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        
        Insolvency_Payment__c payment2 = new Insolvency_Payment__c();
        payment2.Remittance__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'AAL';
        insert payment2;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%'].id;
        prod1.Product_Status__c = 'Test';
        insert prod1;
        
		Product_Payments__c prodPayments = new Product_Payments__c();
        prodPayments.Dividend__c = remit.Id;
        prodPayments.Payment_Amount__c = 1123.00;
        prodPayments.CCS_Account__c =prod1.id;
        prodPayments.Unallocated_Payment__c=unAloccPay.id;
        prodPayments.Deposit_Account_Type__c = 'AAL';
        insert prodPayments;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        
        remit.id = unAloccPay.Remittance__c; 
        remit.recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id;
        remit.Status__c = 'New';
        update remit;
        
        Unallocated_Payment__c unAloccPay2 = new Unallocated_Payment__c();
        unAloccPay2.Account_Number__c = 'unknown';
        unAloccPay2.Deposit_Slip__c=ds.id;
        unAloccPay2.Cheque_Number__c='12345';
        unAloccPay2.Is_Payment_Remitted__c=false;
        unAloccPay2.Allocated__c =false;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        UnallocatedPaymentControllerNew obj = new UnallocatedPaymentControllerNew(new ApexPages.StandardController(unAloccPay2));
		obj.prodPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.prodpaysave();  
    }
}