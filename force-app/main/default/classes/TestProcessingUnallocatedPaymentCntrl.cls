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
public class TestProcessingUnallocatedPaymentCntrl{
    
    @testSetup
    static void testData(){
       
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Remittance_Validation__c = false,Run_Remittance_Trigger__c  = true,Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
                                                                                   Run_Insolvency_Trigger__c = false,Run_Insolvency_Account_Duplicate_Check__c = True,Run_Insolvency_Account_Trigger__c=false,
                                                                                   Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',Run_Insolvency_Status_Validations__c = True,
                                                                                   Bank_Eligible_for_Duplicate_Check__c = 'SPL',Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm');
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
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Remittance__c = remit.Id, Allocated__c = FALSE,Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
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
        //ETC
        
        
    }
    
    //Test Controller
    static testMethod void testController(){
        Unallocated_Payment__c unAloccPay = [SELECT Id FROM Unallocated_Payment__c LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
        
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
       
        obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.save();
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
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Allocated__c = FALSE,Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
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
        //payment2.Remittance__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.Insolvency_Account__c =insolAcct1.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CCL';
        insert payment2;
        
        Insolvency_Payment__c payment3 = new Insolvency_Payment__c();
        //payment2.Remittance__c = remit.Id;
        payment3.Payment_Amount__c = 1123.00;
        payment3.Insolvency_Account__c =insolAcct1.id;
        payment3.Unallocated_Payment__c=unAloccPay.id;
        payment3.Deposit_Account_Type__c = 'CIA';
        insert payment3;
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
        
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
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Remittance__c = remit.Id, Allocated__c = FALSE,Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
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
                
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
        
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
       
        obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.save();
        
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
        unAloccPay.Allocated__c = FALSE;
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
        unAloccPay2.Allocated__c = FALSE;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
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
        unAloccPay.Allocated__c = FALSE;
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
        unAloccPay2.Allocated__c = FALSE;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
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
        unAloccPay.Allocated__c = FALSE;
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
        unAloccPay2.Allocated__c = FALSE;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
    
    static testMethod void testController6(){
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
        unAloccPay.Allocated__c = FALSE;
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
        unAloccPay2.Allocated__c = FALSE;
        unAloccPay2.Remittance__c = remit.id;
        unAloccPay2.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay2;
        
        ProcessingUnallocatedPaymentCntrl obj = new ProcessingUnallocatedPaymentCntrl(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.Insolvency_Account__c = [SELECT Id FROM Insolvency_Account__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
}