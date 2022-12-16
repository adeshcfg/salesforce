/*------------------------------------------------------------------------------------------------------------------
* Class : ProcessingUnallocatedProductController
* @description : This class contains unit tests for validating behavior of InlineInsolvencyAccountsCntrl
* @author : A5E Consulting
* @date : 03/04/2019
---------------------------------------------------------------------------------------------------------------------*/

@isTest
public class TestProcessingUnallocatedProductctlr{
    
    @testSetup
    static void testData(){
       
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Remittance_Validation__c = false,Run_Remittance_Trigger__c  = true,Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
                                                                                   Run_Insolvency_Trigger__c = false,Run_Insolvency_Account_Duplicate_Check__c = True,Run_Insolvency_Account_Trigger__c=false,
                                                                                   Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',Run_Insolvency_Status_Validations__c = True,
                                                                                   Bank_Eligible_for_Duplicate_Check__c = 'SPL',Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
                                                                                   Do_Not_Run_Payment_Validation__c = false);
        insert config;
        Remittance__c remit = new Remittance__c(Cheque_Payment_Reference_Number__c = '1234', 
                                                Cheque_Amount__c = 12.00,
                                                Total_Unallocated_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                recordTypeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%Insolvency%'].id,
                                                Status__c = 'New' );
        insert remit;       
        
        Product__c prod = new Product__c();
        prod.name='124567';
        prod.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        //Deposit Slip Record creation
        Deposit_Slip__c ds=new Deposit_Slip__c();
        ds.recordTypeid = [select id from RecordType where SobjectType = 'Deposit_Slip__c' and name like '%ccs%'].id;
        insert ds;
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Remittance__c = remit.Id, Allocated__c = FALSE,Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        
        
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c= 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';
        
        insert depAcc;
        remit.Deposit_Account_Name__c='CIML';
        update remit;
        
        //Payments
        Product_Payments__C payment1 = new Product_Payments__C();
        payment1.Payment_Source__c='2';
        payment1.Dividend__c = remit.Id;
        payment1.Payment_Amount__c = 1123.00;
        payment1.CCS_Account__C =prod.id;
        payment1.Unallocated_Payment__c=unAloccPay.id;
        payment1.Deposit_Account_Type__c = 'CIH';
        insert payment1;
        //ETC
        
        
    }
    
    //Test Controller
    /*static testMethod void testController(){
        Unallocated_Payment__c unAloccPay = [SELECT Id FROM Unallocated_Payment__c LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__C LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
        
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
       
        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__C LIMIT 1].Id;
        obj.save();
    }*/
    
    static testMethod void testController1(){
        
        Product__c prod2 = new Product__c();
        prod2.name='123456';
        //prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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
        
                
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown', Allocated__c = FALSE,Deposit_Slip__c=ds.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay;
        
        Unallocated_Payment__c unAloccPay1 = new Unallocated_Payment__c(Account_Number__c = 'unknown', Allocated__c = FALSE,Deposit_Slip__c=ds.id,Remittance__c=remit.id,Cheque_Number__c='12345',Is_Payment_Remitted__c=false);
        unAloccPay1.recordTypeId = [select id from RecordType where SobjectType = 'unallocated_Payment__C' and name like '%Insolvency%'].id;
        insert unAloccPay1;
        /*unAloccPay.Account_Number__c = prod2.name;
        unAloccPay.Allocated__c = true;
        update unAloccPay;*/
        
        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c='2';
        payment2.Dividend__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C =prod2.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CCL';
        insert payment2;
        
        
        
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
		
		/*unAloccPay.Remittance__c = NULL;
        unAloccPay.Allocated__c = true;
       
        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.save(); */       
    }
    
    static testMethod void testController2(){
        Product__c prod2 = new Product__c();
        prod2.name='123456';
        prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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
        
        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c='2';
        payment2.Dividend__c = remit.Id;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C =prod2.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'ETC';
        insert payment2;
                
        ApexPages.currentPage().getParameters().put('id', unAloccPay.Id);
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        
        obj.save();
        
        unAloccPay.Account_Number__c = '123456';
        unAloccPay.Unallocated_Amount__c = 12.00;
        unAloccPay.Remittance__c = NULL;
        unAloccPay.Allocated__c = true;
       
        obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay));
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.save();
        
    }
 	
    static testMethod void testController3(){
        Product__c prod2 = new Product__c();
        prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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

        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C =Prod2.id;
        payment2.Unallocated_Payment__c=unAloccPay.id;
        payment2.Deposit_Account_Type__c = 'CIH';
        insert payment2;
        
        Product_Payments__C payment3 = new Product_Payments__C();
        payment3.Payment_Source__c = '2';
        payment3.Dividend__c = unAloccPay.Remittance__c;
        payment3.Payment_Amount__c = 1123.00;
        payment3.CCS_Account__C =Prod2.id;
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
        
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
    
    static testMethod void testController4(){
        Product__c prod2 = new Product__c();
        prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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
        
        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C =prod2.id;
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
        
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
    
    static testMethod void testController5(){
        Product__c prod2 = new Product__c();
        prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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
        
        
        
        Product_Payments__C payment2 = new Product_Payments__C();
        payment2.Payment_Source__c = '2';
        payment2.Dividend__c = unAloccPay.Remittance__c;
        payment2.Payment_Amount__c = 1123.00;
        payment2.CCS_Account__C =prod2.id;
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
        
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
    
    static testMethod void testController6(){
        Product__c prod2 = new Product__c();
        prod2.Portfolio_Group_Name__c='AAL001';
        prod2.RecordTypeId=[select id from RecordType where SobjectType = 'product__c' and name like '%CCS%'].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        insert prod2;
        
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
        
        ProcessingUnallocatedProductController obj = new ProcessingUnallocatedProductController(new ApexPages.StandardController(unAloccPay2));
        
        obj.insolvPay.CCS_Account__C = [SELECT Id FROM Product__c LIMIT 1].Id;
        obj.isAllocated = false;
        obj.save();
       
    }
}