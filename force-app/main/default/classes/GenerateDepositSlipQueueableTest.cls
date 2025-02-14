/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a test class for Generate Deposit Slip Queueable class. 
*  @author : A5E Consulting
*  @date : 02/13/2025

*************************************************************************************************/

@isTest
private class GenerateDepositSlipQueueableTest {
    
    @testSetup
    static void testData(){
       
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Remittance_Trigger__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = true,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;     
         
        Deposit_Slip__c depSlip1 = new Deposit_Slip__c();
        depSlip1.Total_Accounts__c = 5;
        depSlip1.recordTypeId = [select id from RecordType where SobjectType = 'Deposit_Slip__C' and name like '%Insolvency%'].id;
        INSERT depSlip1; 
        
        
    }

    @isTest
    static void testExecuteMethod() {
        Deposit_Accounts__c depAcc = new Deposit_Accounts__c();
        depAcc.Name = 'CIML';
        depAcc.Account_Number__c = '1004-156';
        depAcc.Bank_Name__c = 'CIML Billing ';
        depAcc.Entity_Name__c= 'Canaccede International Management Ltd';
        depAcc.Transit_Number__c = '32162';
        insert depAcc;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem3 = new Remittance__c();
        rem3.recordTypeid = recordTypeListDividend[0].id;
        rem3.Cheque_Amount__c = 345.08;
        rem3.Cheque_Payment_Reference_Number__c = 'Ref654';
        rem3.Status__c = 'Processed';
        rem3.Payment_Posting_Date__c = System.today();
        rem3.Bank_Account_Number__c = 'CIML Billing';
        rem3.Deposit_Account_Name__c = 'CIML';
        insert rem3;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem3.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem3.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment', true, true
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    @isTest
    static void testExecuteMethod1() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'updatePayments', true, true
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod2() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'skipNcontinue', true, true
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod3() {
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'AFSI';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        insert dep;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem2 = new Remittance__c();
        rem2.recordTypeid = recordTypeListDividend[0].id;
        rem2.Cheque_Amount__c = 909.89;
        rem2.Cheque_Payment_Reference_Number__c = 'Ref456';
        rem2.Status__c = 'Processed';
        rem2.Payment_Posting_Date__c = System.today();
        rem2.Deposit_Account_Name__c = 'AFSI';
        insert rem2;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem2.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem2.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment'
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    @isTest
    static void testExecuteMethod4() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'updatePayments'
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod5() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'skipNcontinue'
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod6() {
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'AAL';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        insert dep;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem1 = new Remittance__c();
        rem1.recordTypeid = recordTypeListDividend[0].id;
        rem1.Cheque_Amount__c = 909.89;
        rem1.Cheque_Payment_Reference_Number__c = 'Ref321';
        rem1.Status__c = 'Processed';
        rem1.Payment_Posting_Date__c = System.today();
        rem1.Deposit_Account_Name__c = 'AAL';
        insert rem1;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem1.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem1.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    @isTest
    static void testExecuteMethod7() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'updatePayments', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod8() {
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'skipNcontinue', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testSendNotification() {
        Deposit_Slip__c depositSlip = [SELECT Id, Name FROM Deposit_Slip__c LIMIT 1];
        
        Test.startTest();
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, depositSlip, DateTime.now(), 
            [SELECT Id FROM Application_Config_Settings__c LIMIT 1], 'updatePayments'
        );
        job.sendNotification();
        Test.stopTest();
        
        // Validate email sent (you can use mock callout for email if necessary)
    }
    
    @isTest
    static void testSkipNcontinue() {
        Deposit_Slip__c depositSlip = [SELECT Id, Name FROM Deposit_Slip__c LIMIT 1];
        
        Test.startTest();
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, depositSlip, DateTime.now(), 
            [SELECT Id FROM Application_Config_Settings__c LIMIT 1], 'updatePayments'
        );
        job.skipNcontinue();
        Test.stopTest();
        
        // Validate email sent (you can use mock callout for email if necessary)
    }
    
    @isTest
    static void testUpdatePayments() {
        Deposit_Slip__c depositSlip = [SELECT Id, Name FROM Deposit_Slip__c LIMIT 1];
        
        Test.startTest();
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, depositSlip, DateTime.now(), 
            [SELECT Id FROM Application_Config_Settings__c LIMIT 1], 'updatePayments'
        );
        job.updatePayments();
        Test.stopTest();
        
        // Validate email sent (you can use mock callout for email if necessary)
    }
    
    @isTest
    static void testExecuteMethod9() {
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'ETC';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        insert dep;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem = new Remittance__c();
        rem.recordTypeid = recordTypeListDividend[0].id;
        rem.Cheque_Amount__c = 460.90;
        rem.Cheque_Payment_Reference_Number__c = 'Ref123';
        rem.Status__c = 'Processed';
        rem.Bank_Account_Number__c = 'Canaccede Credit LP Blocked';
        rem.Deposit_Account_Name__c = 'ETC';
        rem.Payment_Posting_Date__c = System.today();
        insert rem;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod10() {
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'AFL';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        insert dep;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem4 = new Remittance__c();
        rem4.recordTypeid = recordTypeListDividend[0].id;
        rem4.Cheque_Amount__c = 600;
        rem4.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem4.Status__c = 'Processed';
        rem4.Payment_Posting_Date__c = System.today();
        rem4.Deposit_Account_Name__c = 'AFL';
        insert rem4;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem4.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem4.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__C 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
    @isTest
    static void testExecuteMethod11() {
        Deposit_Accounts__c dep = new Deposit_Accounts__c();
        dep.Name = 'CAL';
        dep.Account_Number__c = '1993-130';
        dep.Bank_Name__c = 'Canaccede Credit LP Blocked ';
        dep.Entity_Name__c= 'Canaccede Credit LP';
        dep.Transit_Number__c = '03482';
        insert dep;
        
        list<RecordType> recordTypeListDividend = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='remittance__c' and name like 'Insolvency%' ]);
        Remittance__c rem5 = new Remittance__c();
        rem5.recordTypeid = recordTypeListDividend[0].id;
        rem5.Cheque_Amount__c = 600;
        rem5.Cheque_Payment_Reference_Number__c = 'Ref789';
        rem5.Status__c = 'Processed';
        rem5.Payment_Posting_Date__c = System.today();
        rem5.Deposit_Account_Name__c = 'CAL';
        insert rem5;
        
        //Insolvency Record
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Insolvency_Type__c = 'Bankruptcy';
        
        
        insolvList.add(insolv1);
        INSERT insolvlist;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        portfolioName.name = 'AFSCARDS';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = recordTypeList[1].Id;
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'New';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Insolvency__c = insolv1.Id;
        ia1.Account_Number_Without_Space__c = 'Test-001';
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        insert ia1;
        
        List<Insolvency_payment__c> payList = new List<Insolvency_payment__c>();
        Insolvency_payment__c insolPay =new Insolvency_payment__c();
        insolPay.Cheque_Payment_Reference_Number__c = 'Ref123';
        insolPay.Insolvency_Account__c = ia1.id;
        insolPay.Payment_Amount__c = 460.90;
        insolPay.Remittance__c = rem5.Id;
        insolPay.Payment_Posting_Date__c = System.today();
        insert insolPay;
        
        List<Unallocated_Payment__c> unallocPayList = new List<Unallocated_Payment__c>();
        Unallocated_Payment__c unallocPay = new Unallocated_Payment__c();
        unallocPay.Unallocated_Amount__c = 100;
        unallocPay.Remittance__c = rem5.Id;
        insert unallocPay;
        
        Deposit_Slip__c deposit = [SELECT Id FROM Deposit_Slip__c LIMIT 1];
        Application_Config_Settings__c appConfig = [SELECT Id FROM Application_Config_Settings__c LIMIT 1];
        
        List<AggregateResult> listAggregateResults = [select count(id) total, sum(Cheque_Amount__c) amount, Deposit_Account_Name__c
                                              from remittance__c 
                                              where Status__c = 'Processed'
                                              AND recordType.Developername = 'Insolvency_Dividend' AND Do_Not_Process__c = false
                                              group by Deposit_Account_Name__c ];
        
        System.debug('listAggregateResults:: '+listAggregateResults);
        // Create instance of the queueable class
        GenerateDepositSlipQueueable job = new GenerateDepositSlipQueueable(
            listAggregateResults, deposit, DateTime.now(), appConfig, 'createPdfAttachment', false, false
        );
        
        // Execute the queueable job
        Test.startTest();
        System.enqueueJob(job);
        Test.stopTest();
    }
    
}