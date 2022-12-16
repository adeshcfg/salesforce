@isTest
public class TestInsolvencyEFTProcessing {
    @testSetup
    public static void testSetup(){
        EFT_Processing_Config__c  config = new EFT_Processing_Config__c();
        config.Insolvency_EFT_RecordTypeID__c = Schema.SObjectType.EFT_Files__c.getRecordTypeInfosByName().get('Insolvency EFT').getRecordTypeId();
        config.Insolvency_Payment_Record_TypeID__c   = Schema.SObjectType.Insolvency_Payment__c.getRecordTypeInfosByName().get('Insolvency Payment').getRecordTypeId();
        insert config;
        
        Application_Config_Settings__c config1 =  new Application_Config_Settings__c();
        config1.Run_EmailMessage_Trigger__c = false;
        config1.Run_Insolvency_Account_Trigger__c = true;
        insert config1;
        Account Truscomp=new Account();
        Id Recrdid =[SELECT Id FROM RecordType WHERE SobjectType='Account' and name like 'Trustee Company'].id;
        Truscomp.RecordTypeId=Recrdid;
        Truscomp.name='Test';
        insert Truscomp;
        
        // Trustee Office Record
        Account Trusoff=new Account();
        Id Recordid =[SELECT Id FROM RecordType WHERE SobjectType='Account' and name like 'Trustee Office'].id;
        Trusoff.RecordTypeId=Recordid;
        Trusoff.name='Testrecord';
        Trusoff.Trustee_ID__c=Truscomp.id;
        Trusoff.Is_Active__c=True;
        Trusoff.Follow_up_Email__c='Test@test.com';
        insert Trusoff;
        
        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insolv1.Trustee__c=Trusoff.id;
        insert insolv1;
        
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARDS';
        portfolioName.Account_Purchasing_Entity_ID__c = 'test';
        insert portfolioName;
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and name like '%SPL%']);
        
        //Insolvency Account records
        Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.RecordTypeId = recordTypeList[0].Id;
        insolvencyAccount.Name = '4537049889659';
        insolvencyAccount.Insolvency_Status__c = 'No PoC Required';
        insolvencyAccount.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Insolvency__c = insolv1.Id;
        insolvencyAccount.Account_Number_Without_Space__c = '4537049889659';
        insolvencyAccount.Portfolio_Group_Name__c = 'CCL001';
        insolvencyAccount.Investment_Group__c = 'AFFIRM';
        insolvencyAccount.Portfolio_Name_Lookup__c = portfolioName.id;
        insert insolvencyAccount;
    }
    public static testMethod void TestPaymentUpload(){
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        //insert config;
        
        String testOutputJSON = '';
        InsolvencyPaymentUploadController controller = new InsolvencyPaymentUploadController();
        //upload error
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'error';
        controller.importDatatoApex();
        
        //account no null
        testOutputJSON = '[{'+
            '"AccountNumber":null,'+
            '"ClientID":254801.0,'+
            '"ClientName":"LEBLANC, JUSTIN ",'+
            '"PaymentSource":3,'+
            '"PaymentType":1000,'+
            '"NetPayment":390.0,'+
            '"FairSharePayment":110.0,'+
            '"GrossPayment":500.0'+
        '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        //net payment null
        testOutputJSON = '[{'+
            '"AccountNumber":"4537049889659",'+
            '"ClientID":254801.0,'+
            '"ClientName":"LEBLANC, JUSTIN ",'+
            '"PaymentSource":3,'+
            '"PaymentType":1000,'+
            '"NetPayment":null,'+
            '"FairSharePayment":110.0,'+
            '"GrossPayment":500.0'+
        '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        //success
        testOutputJSON = '[{'+
            '"AccountNumber":"4537049889659",'+
            '"ClientID":254801.0,'+
            '"ClientName":"LEBLANC, JUSTIN ",'+
            '"PaymentSource":3,'+
            '"PaymentType":1000,'+
            '"NetPayment":390.0,'+
            '"FairSharePayment":110.0,'+
            '"GrossPayment":500.0'+
        '},'+
        '{'+
            '"AccountNumber":"4537049851733",'+
            '"ClientID":257269.0,'+
            '"ClientName":"URINTSOV, OLGA ",'+
            '"PaymentSource":3,'+
            '"PaymentType":1000,'+
            '"NetPayment":50.7,'+
            '"FairSharePayment":14.3,'+
            '"GrossPayment":65.0'+
        '}]';
        controller = new InsolvencyPaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        system.debug('eftInstance: '+eftInstance);
        Test.setCurrentPageReference(new PageReference('InsolvencyPaymentUpload')); 
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new InsolvencyPaymentUploadController();
        controller.showAllocatedProductPayments();
        controller.ShowUnallocatedProductPayments();   
    }
    
    public static testMethod void testProcessBatch(){
        
        List<EFTUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<EFTUtil.paymentRecordsWrapper>();
        EFTUtil.paymentRecordsWrapper wrapper = new EFTUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '4537049889659';
        wrapper.chequeNumber = 'TestFile';
        wrapper.paymentSource = '3';
        wrapper.paymentType = '1000';
        wrapper.netPayment = '65.0';
        wrapper.postingDate = string.valueOf(system.today());
        listPaymentRecordWrapper.add(wrapper);
        
        EFT_Files__c eft = new EFT_Files__c();
        eft.Posting_Date__c = system.today();
        insert eft;
        
        ProcessInsolvencyEFTBatch batch1 = new ProcessInsolvencyEFTBatch(listPaymentRecordWrapper, eft);
        database.executeBatch(batch1);        
    }
    
    public static testMethod void testInsertInsolvencyPaymentBatch(){
        Insolvency_Account__c insolvencyAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        insert eft;
        blob blob1;
        Attachment allocatedPayment = new Attachment();
        allocatedPayment.parentid = eft.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,netPayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber';
        attachBody += '\n';
        attachBody += '4537049889659,'+insolvencyAccount.Id+',35.60,'+String.valueOf(system.today())+',null,null,null,TestCCSFileUpload';
        allocatedPayment.Body = Blob.valueOf(attachBody);
        insert allocatedPayment;
        
        InsertInsolvencyPaymentsBatch batch1 = new InsertInsolvencyPaymentsBatch(eft);
        database.executeBatch(batch1);
    }
    
    public static testMethod void testDisplayAllocatedInsolvencyPayments(){
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        
        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c  ();
        paymentInstance1.Insolvency_Account__c = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0].ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c  = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;
        
        DisplayAllocatedInsolvencyController controller;
        Test.setCurrentPageReference(new PageReference('DisplayAllocatedInsolvencyPayments')); 
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new DisplayAllocatedInsolvencyController();
        controller.Save();
    }
    
    public static testMethod void testDisplayUnallocatedInsolvencyPayments(){
        Insolvency_Account__c insoAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        eft.Allocated_Payments_Amount__c = 0;
        insert eft;
        blob blob1;
        Attachment unallocatedPayment = new Attachment();
        unallocatedPayment.parentid = eft.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        String attachBody = 'AccountNumber,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber';
        attachBody += '\n';
        attachBody += '4537049209659,'+'61.0,'+String.valueOf(system.today())+',www.google.com,,3,1000,TestInsolvencyFileUpload';
        attachBody += '4537049889659,'+'61.0,'+String.valueOf(system.today())+',www.google.com,3,1000,TestInsolvencyFileUpload';
        unallocatedPayment.Body = Blob.valueOf(attachBody);
        insert unallocatedPayment;
        
        Test.setCurrentPageReference(new PageReference('DisplayInsolvencyUnallocatedPayments')); 
        System.currentPageReference().getParameters().put('id', eft.Id);
        DisplayInsolUnAllocatedPaymentController controller = new DisplayInsolUnAllocatedPaymentController();
        controller.paymentRecordListInner[0].prodLookup.Insolvency_Account__c = insoAccount.Id;
        controller.Save();
        controller.Cancel();
        
        InsertUnallocatedPaymentsBatch batch2 = new InsertUnallocatedPaymentsBatch(controller.listUnallocatedPayment, eft, 'Insolvency');
        database.executeBatch(batch2);
    }
    
    public static testMethod void testDisplayUnAllocatedProcessedInsoPayments(){
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        
        Unallocated_Payment__c paymentInstance1 = new Unallocated_Payment__c();
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Unallocated_Amount__c = 321.98;
        paymentInstance1.Cheque_Number__c = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;
        
        DisplayUnallocatedProcessedController controller;
        Test.setCurrentPageReference(new PageReference('DisplayUnallocatedProcessed')); 
        System.currentPageReference().getParameters().put('id', eftInstance.Id);
        System.currentPageReference().getParameters().put('rt', 'Insolvency');
        controller = new DisplayUnallocatedProcessedController();
        controller.redirectPaymentUpload();
    }
}