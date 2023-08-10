@isTest
public class TestProductPaymentProcessingController {
    @testSetup
    static void testthis(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Remittance_Validation__c = false);
        insert config;
    }
    static testmethod void TestData(){
        
        //CCS Agency 
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        //Dividend
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid.recordTypeid = cssDividendREcordTYpeId;
        insert divid;
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        //Product record creation
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CIA');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='AAL');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;  
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 0;
        prodpay3.Payment_Amount__c=0;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CIML';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        //Custom setting
        Deposit_Accounts__c depAcc = New Deposit_Accounts__c();
        depAcc.name = 'AAL';
        depAcc.Account_Number__c = '123';
        depAcc.Bank_Name__c = 'AAL';
        depAcc.Transit_Number__c = '123';
        depacc.Entity_Name__c = 'test';
        insert depAcc;
        
       	Unallocated_Payment__c unAllocPay = new Unallocated_Payment__c();
        unAllocPay.Account_Number__c = '12345';
        unAllocPay.Estate_Number__c = '4567';
        unAllocPay.Bank_Name__c = 'MBNA';
        insert unAllocPay;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(divid);
        ProductPaymentProcessingController pppc=new ProductPaymentProcessingController(sc);
        ProductPaymentProcessingController.Wrapper ccisw = new ProductPaymentProcessingController.Wrapper();
        ccisw.productAcc = prod1;
        ccisw.setProdAcc();
        ccisw.getproductAcc();
        ccisw.productPay = prodpay; 
        pppc.checkAndAddToWrapperList(ccisw);
        pppc.isDuplicateWithInsolvnecyPayment(unAllocPay);
        id productId=[Select Id From Product__c Limit 1].Id;

        pppc.showSearch=false;
        pppc.insolvencyAccNumbers='5367852529639289';
        List<Product_Payments__c> prodpaylist = [Select CCS_Account__c from Product_Payments__c Limit 10 ];
        Set<Id> prodIdset = new Set<Id>();
        For(Product_Payments__c p:prodpaylist){
            Id prodId=p.CCS_Account__c;
            prodIdset.add(prodId);            
        }
        
        pppc.ProdAccIds=prodIdset;//prodAccIds is a Set of product Ids
        pppc.remit=divid;
        
        //Methods for ProductPaymentProcessingController
        pppc.searchExistingPaymentRecords();
        pppc.addUnallocatedPayment();
        pppc.searchInsolvencyAccounts();
        pppc.filterSearchResults();   
        pppc.calculateTotal();
        ProductPaymentProcessingController.assignBankInformation(divid.id);
        pppc.getTotalFairshareAmount();
        pppc.getunAllocAmountIsNotEmpty();
        pppc.getUnallocatedAmount();
        pppc.getUnallocatedFairshareAmount();
        pppc.getwrapIsNotEmpty();
        pppc.saveUnAllocatedAmount(); 
        pppc.saveInsolveyncyPayments();
        pppc.getAttachIsNotEmpty();        
        pppc.getShowSaveButton();
        pppc.getwrapListWithAmountNotEmpty();
        pppc.getwrapListWithZeroAmountNotEmpty();
        
        sc = new ApexPages.StandardController(dividWihtouCheque);
        pppc=new ProductPaymentProcessingController(sc);
        
        dividWihtouCheque.Cheque_Payment_Reference_Number__c = '1430';
        dividWihtouCheque.Fairshare_Amount__c = null;
        update dividWihtouCheque;
        pppc=new ProductPaymentProcessingController(sc);
        
        Remittance__c remitance = new Remittance__c(
            Cheque_Payment_Reference_Number__c = NULL,
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert remitance;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(remitance);
        ProductPaymentProcessingController pppc1=new ProductPaymentProcessingController(sc1);
    }
    
    static testMethod void testController(){
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Portfolio_Group_Name__c ='CLP';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(divid);
        ProductPaymentProcessingController pppc=new ProductPaymentProcessingController(sc);
        
        divid.Cheque_Amount__c = 500.00;
        divid.Fairshare_Amount__c = 50.00;
        divid.status__C = 'Processed';
        update divid;
        
        prodpay.Dividend__c=divid.Id;
        prodpay.Payment_Source__c='2';
        update prodpay;
        
        id productId=[Select Id From Product__c Limit 1].Id;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(divid);
        ProductPaymentProcessingController pppc1=new ProductPaymentProcessingController(sc1);        
        
       	pppc1.searchExistingPaymentRecords();
        pppc1.addUnallocatedPayment();
        pppc1.searchInsolvencyAccounts();
        pppc1.filterSearchResults();   
        pppc1.calculateTotal();
        //ProductPaymentProcessingController.assignBankInformation(divid.id);
        pppc1.getTotalFairshareAmount();
        pppc1.getunAllocAmountIsNotEmpty();
        pppc1.getUnallocatedAmount();
        pppc1.getUnallocatedFairshareAmount();
        pppc1.getwrapIsNotEmpty();
        pppc1.saveUnAllocatedAmount(); 
        pppc1.saveInsolveyncyPayments();
        pppc1.getAttachIsNotEmpty();        
        pppc1.getShowSaveButton();
        pppc1.getwrapListWithAmountNotEmpty();
        pppc1.getwrapListWithZeroAmountNotEmpty();
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Deposit_Accounts__c depAcc1 = New Deposit_Accounts__c();
        depAcc1.name = 'CCL';
        depAcc1.Account_Number__c = '123';
        depAcc1.Bank_Name__c = 'CCL';
        depAcc1.Transit_Number__c = '123';
        depAcc1.Entity_Name__c = 'test';
        insert depAcc1;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
    }
    
    static testMethod void testController1(){
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Portfolio_Group_Name__c ='CLP';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
       
        insert unAloccPay;
       
        divid.Cheque_Amount__c = 500.00;
        divid.Fairshare_Amount__c = 50.00;
        divid.status__C = 'Processed';
        update divid;
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Deposit_Accounts__c depAcc1 = New Deposit_Accounts__c();
        depAcc1.name = 'CCL';
        depAcc1.Account_Number__c = '123';
        depAcc1.Bank_Name__c = 'CCL';
        depAcc1.Transit_Number__c = '123';
        depAcc1.Entity_Name__c = 'test';
        insert depAcc1;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
        prod.Portfolio_Group_Name__c ='CFL';
        update prod;
        
        depAcc1.name = 'CFL';
        depAcc1.Account_Number__c = '123';
        depAcc1.Bank_Name__c = 'CFL';
        update depAcc1;
        
        prodpay1.CCS_Account__c=prod.Id;
        update prodpay1;
    }
    
    static testMethod void testController2(){
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Portfolio_Group_Name__c ='CIA';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today());
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Portfolio_Group_Name__c ='CFL';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insolv.Insolvency_Status__c = 'For Owner Review';
        insert insolv;
        
        Case assignment = new Case();
        assignment.Status = 'New';
        assignment.Insolvency__c = insolv.id; 
        insert assignment;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Email_to_Case_Reference_Number__c = assignment.id,
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Remittance__c divid2 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Email_to_Case_Reference_Number__c = assignment.id,
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque1 = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque1;
        divid2.recordTypeid = cssDividendREcordTYpeId;
        insert divid2;
        dividWihtouCheque1.id = divid2.id;
        update dividWihtouCheque1;
        
        Deposit_Accounts__c depAcc1 = New Deposit_Accounts__c();
        depAcc1.name = 'CIH';
        depAcc1.Account_Number__c = '123';
        depAcc1.Bank_Name__c = 'CIH';
        depAcc1.Transit_Number__c = '123';
        depAcc1.Entity_Name__c = 'test';
        insert depAcc1;
        
        String failed = '';
        Blob fileBlob = Blob.valueOf(failed);
        
        EMailMessage emaiMsg = new EMailMessage();
        emaiMsg.relatedToid = divid1.Email_to_Case_Reference_Number__c;
        insert emaiMsg;
            
        Attachment attachement = new Attachment();
        attachement.Name = 'test';
        attachement.Description = 'test';
        attachement.Body = fileBlob;
        attachement.ParentId = emaiMsg.id;
        attachement.CreatedDate = datetime.newInstance(2022, 7, 15, 12, 30, 0);
        attachement.LastModifiedDate = datetime.newInstance(2022, 8, 15, 12, 30, 0);
        insert attachement;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.AttachWrap ccisw = new ProductPaymentProcessingController.AttachWrap(attachement);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
        prodpay1.CCS_Account__c=prod1.Id;
        update prodpay1;
        prod.Portfolio_Group_Name__c ='CAL';
        update prod;
        depAcc1.name = 'CAL';
        depAcc1.Account_Number__c = '123';
        depAcc1.Bank_Name__c = 'CAL';
        update depAcc1;
        prodpay1.CCS_Account__c=prod.Id;
        update prodpay1;
        
    }
    
    static testMethod void testController3(){
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        //Dividend
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid.recordTypeid = cssDividendREcordTYpeId;
        insert divid;
        
        //Unallocated Payment
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        //Product record creation
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CIH');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CCL');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        Product__c prod2 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='ETC');
        prod2.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Customer__c = accInstance1.id;
        prod2.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod2.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod2.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod2.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod2.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod2.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod2;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid.Id;
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        Product_Payments__c prodpay4=new Product_Payments__c();
        prodpay4.CCS_Account__c=prod2.Id;
        prodpay4.Dividend__c=divid.Id;
        prodpay4.Cheque_Number__c='Test2021';
        prodpay4.fairshare_amount__C = 0;
        prodpay4.Payment_Amount__c=0;
        prodpay4.Payment_Source__c='1';
        insert prodpay4;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CIML';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
                
        //Custom setting
        Deposit_Accounts__c depAcc = New Deposit_Accounts__c();
        depAcc.name = 'AAL';
        depAcc.Account_Number__c = '123';
        depAcc.Bank_Name__c = 'AAL';
        depAcc.Transit_Number__c = '123';
        depacc.Entity_Name__c = 'test';
        insert depAcc;
        
       	Unallocated_Payment__c unAllocPay = new Unallocated_Payment__c();
        unAllocPay.Account_Number__c = '12345';
        unAllocPay.Estate_Number__c = '4567';
        unAllocPay.Bank_Name__c = 'MBNA';
        insert unAllocPay;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(divid);
        ProductPaymentProcessingController pppc=new ProductPaymentProcessingController(sc);
        ProductPaymentProcessingController.Wrapper ccisw = new ProductPaymentProcessingController.Wrapper();
        ccisw.productAcc = prod1;
        ccisw.setProdAcc();
        ccisw.getproductAcc();
        ccisw.productPay = prodpay; 
        pppc.checkAndAddToWrapperList(ccisw);
        pppc.isDuplicateWithInsolvnecyPayment(unAllocPay);
        id productId=[Select Id From Product__c Limit 1].Id;

        pppc.showSearch=false;
        pppc.insolvencyAccNumbers='5367852529639289';
        List<Product_Payments__c> prodpaylist = [Select CCS_Account__c from Product_Payments__c Limit 10 ];
        Set<Id> prodIdset = new Set<Id>();
        For(Product_Payments__c p:prodpaylist){
            Id prodId=p.CCS_Account__c;
            prodIdset.add(prodId);            
        }
        
        pppc.ProdAccIds=prodIdset;//prodAccIds is a Set of product Ids
        pppc.remit=divid;
        pppc.searchExistingPaymentRecords();
        pppc.addUnallocatedPayment();
        pppc.filterSearchResults();   
        pppc.calculateTotal();
        ProductPaymentProcessingController.assignBankInformation(divid.id);
        pppc.getTotalFairshareAmount();
        pppc.getunAllocAmountIsNotEmpty();
        pppc.getUnallocatedAmount();
        pppc.getUnallocatedFairshareAmount();
        pppc.getwrapIsNotEmpty();
        pppc.saveUnAllocatedAmount(); 
        pppc.saveInsolveyncyPayments();
        pppc.getAttachIsNotEmpty();        
        pppc.getShowSaveButton();
        pppc.getwrapListWithAmountNotEmpty();
        pppc.getwrapListWithZeroAmountNotEmpty();
        
        sc = new ApexPages.StandardController(dividWihtouCheque);
        pppc=new ProductPaymentProcessingController(sc);
        
        dividWihtouCheque.Cheque_Payment_Reference_Number__c = '1430';
        dividWihtouCheque.Fairshare_Amount__c = null;
        update dividWihtouCheque;
        pppc=new ProductPaymentProcessingController(sc);
        
        Remittance__c remitance = new Remittance__c(
            Cheque_Payment_Reference_Number__c = NULL,
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert remitance;
        ApexPages.StandardController sc1 = new ApexPages.StandardController(remitance);
        ProductPaymentProcessingController pppc1=new ProductPaymentProcessingController(sc1);
       
    }
    
    static testMethod void testController4(){
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CIH');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CCL');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        Product__c prod2 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='ETC');
        prod2.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Customer__c = accInstance1.id;
        prod2.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod2.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod2.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod2.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod2.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod2.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod2;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid1.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid1.Id;
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        Product_Payments__c prodpay4=new Product_Payments__c();
        prodpay4.CCS_Account__c=prod2.Id;
        prodpay4.Dividend__c=divid1.Id;//
        prodpay4.Cheque_Number__c='Test2021';
        prodpay4.fairshare_amount__C = 0;
        prodpay4.Payment_Amount__c=0;
        prodpay4.Payment_Source__c='1';
        insert prodpay4;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CIML';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
    }
    
    static testMethod void testController5(){
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay; 
                
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CCL');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CLP');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid1.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid1.Id;//
        //prodpay.Unallocated_Payment__c=unAloccPay.Id;//
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
       
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CCL';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
    }
    
    static testMethod void testController6(){
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='AFF');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='ETC');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid1.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid1.Id;//
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='ETC';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
    }
    
    static testMethod void testController7(){
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
        
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CFL');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CAL');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid1.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        //Product Payment    //
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid1.Id;
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CIML';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
    }
    
    static testMethod void testController8(){
        Remittance__c divid = new Remittance__c(Cheque_Payment_Reference_Number__c = NULL,
                                                Cheque_Amount__c = NULL,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=NULL,
                                                CCS_Agency__c=NULL,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        insert divid;
        
        Unallocated_Payment__c unAloccPay = new Unallocated_Payment__c(Account_Number__c = 'unknown',Remittance__c = divid.Id, Allocated__c = FALSE,Unallocated_Amount__c=12.00,Unallocated_Fairshare_Amount__c=20.00);
        unAloccPay.recordTypeid = [select id from RecordType where SobjectType = 'unallocated_payment__c' and name like '%ccs%'].id;
        insert unAloccPay;
                
        Account acc= new Account( Name='vamshi');
        acc.recordTypeid = [select id from RecordType where SobjectType = 'Account' and name like '%Agency%'].id;
        insert acc;
        
        Id cssDividendREcordTYpeId = [select id from RecordType where SobjectType = 'remittance__C' and name like '%CCS%' ].id;
        Remittance__c divid1 = new Remittance__c(Cheque_Payment_Reference_Number__c = '1430',
                                                Cheque_Amount__c = 12.00,
                                                //Total_Unallocated_Amount__c = 16.00,
                                                Payment_Posting_Date__c = System.Today().addDays(-2),
                                                Fairshare_Amount__c=20.00,
                                                CCS_Agency__c=acc.id,
                                                Status__c = 'New',
                                                Deposit_Account_Name__c='CIML');
        
        Remittance__c dividWihtouCheque = new Remittance__c(
            
            Payment_Posting_Date__c = System.Today().addDays(-2),
            Fairshare_Amount__c=20.00,
            CCS_Agency__c=acc.id,
            Status__c = 'New',
            Deposit_Account_Name__c='CIML', RecordTypeId = cssDividendREcordTYpeId);
        insert dividWihtouCheque;
        
        divid1.recordTypeid = cssDividendREcordTYpeId;
        insert divid1;
        
        dividWihtouCheque.id = divid1.id;
        update dividWihtouCheque;
        
        Account accInstance1 = new Account();
        string recrdid3= [SELECT id from RecordType where sobjecttype='Account' 
                          AND RecordType.Name='Canaccede Customer'].id;
        accInstance1.RecordTypeId=recrdid3;
        accInstance1.FirstName = 'Ana';
        accInstance1.LastName = 'Starrk';
        accInstance1.Number_Of_Open_Complaint__c = 6;
        accInstance1.Phone_Number__pc = '123' ;
        insert accInstance1;
        
        Product__c prod = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CIA');
        prod.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Customer__c = accInstance1.id;
        prod.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod;
        
        //Product record creation
        Product__c prod1 = new Product__c(Name='Test8965412300023',Account_Purchase_Date__c=System.today(), Portfolio_Group_Name__c='CFL');
        prod1.recordTypeid = [select id from RecordType where SobjectType = 'product__c' and name like '%ccs%' limit 1].id;
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Customer__c = accInstance1.id;
        prod1.Initial_Proposal_Date__c = Date.newInstance(2023, 08, 01);
        prod1.Second_Proposal_Date__c = Date.newInstance(2023, 08, 02);
        prod1.Third_Proposal_Date__c = Date.newInstance(2023, 08, 03);
        prod1.Fourth_Proposal_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Proposal_Received_Date__c = Date.newInstance(2023, 08, 04);
        prod1.Expected_First_disbursement_date__c  = Date.newInstance(2023, 08, 05);
        insert prod1;
        
        //Product Payment    
        Product_Payments__c prodpay=new Product_Payments__c();
        prodpay.CCS_Account__c=prod.Id;
        prodpay.Dividend__c=divid1.Id;
        prodpay.Unallocated_Payment__c=unAloccPay.Id;
        prodpay.Cheque_Number__c='Test2021';
        prodpay.fairshare_amount__C = 12.00;
        prodpay.Payment_Amount__c=20.00;
        prodpay.Payment_Source__c='1';
        insert prodpay;
        
        //Product Payment
        Product_Payments__c prodpay3=new Product_Payments__c();
        prodpay3.CCS_Account__c=prod1.Id;
        prodpay3.Dividend__c=divid1.Id;
        prodpay3.Cheque_Number__c='Test2021';
        prodpay3.fairshare_amount__C = 32.00;
        prodpay3.Payment_Amount__c=22.00;
        prodpay3.Payment_Source__c='1';
        insert prodpay3;
        
        //Deposit Account
        Deposit_Accounts__c dp=new Deposit_Accounts__c();
        dp.Name='CIML';
        dp.Account_Number__c='1004-156';
        dp.Transit_Number__c='32162';
        dp.Entity_Name__c='Canaccede International Management Ltd';
        insert dp;
        
        ApexPages.currentPage().getParameters().put('Id', String.valueOf(divid1.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(divid1);
        ProductPaymentProcessingController pppc2=new ProductPaymentProcessingController(sc2);
        ProductPaymentProcessingController.assignBankInformation(divid1.id);
        
        Product_Payments__c prodpay1=new Product_Payments__c();
        prodpay1.CCS_Account__c=prod.Id;
        prodpay1.Dividend__c=dividWihtouCheque.Id;
        prodpay1.Unallocated_Payment__c=unAloccPay.Id;
        prodpay1.Cheque_Number__c='Test2021';
        prodpay1.fairshare_amount__C = 12.00;
        prodpay1.Payment_Amount__c=20.00;
        prodpay1.Payment_Source__c='1';
        insert prodpay1;
        
    }
    
}