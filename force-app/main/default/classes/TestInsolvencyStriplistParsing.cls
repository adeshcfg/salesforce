@isTest
public class TestInsolvencyStriplistParsing {
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
        
        
        Deposit_Accounts__c depositeAcc = new Deposit_Accounts__c();
        depositeAcc.Name = 'CCL';
        depositeAcc.Account_Number__c = '1993-130';
        depositeAcc.Bank_Name__c = 'Canaccede Credit LP Blocked';
        depositeAcc.Entity_Name__c = 'Canaccede Credit LP';
        depositeAcc.Account_Name_on_Clearing_Account__c = 'CCLP - 130';
        depositeAcc.Transit_Number__c    = '03482';
        insert depositeAcc;
        
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
        //insolvencyAccount.Investment_Group__c = 'AFFIRM';
        //insolvencyAccount.Portfolio_Name_Lookup__c = portfolioName.id;
        insolvencyAccount.Debtor_1_Estate_Number__c = '00-000001';
        
        insert insolvencyAccount;
    }
    public static testMethod void TestPaymentUpload(){
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        //insert config;
        
        String testOutputJSON = '';
        Remittance__c remittanceInstance = new Remittance__c ();
        remittanceInstance.Cheque_Amount__c = 390;
        insert remittanceInstance;
        ApexPages.StandardController sc = new ApexPages.StandardController(remittanceInstance);
        StriplistInsolPaymentUploadController controller = new StriplistInsolPaymentUploadController(sc);
        //upload error
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'error';
        controller.importDatatoApex();
        
        //account no null
        testOutputJSON = '[{'+
            '"AccountNumber":null,'+
            '"ClientID":254801.0,'+
            '"ClientName":"LEBLANC, JUSTIN ",'+
            '"EstateNumber":00-000001,'+
            '"Amount":390.0,'+
        '}]';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        //net payment null
        testOutputJSON = '[{'+
            '"AccountNumber":"4537049889659",'+
            '"ClientID":254801.0,'+
            '"DebtorName":"LEBLANC JUSTIN ",'+
            '"EstateNumber":00-000001,'+
            '"Amount":null,'+
        '}]';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        remittanceInstance.Cheque_Amount__c = 313.53;
        update remittanceInstance;
        //success
        testOutputJSON = '['+
          '{'+
            '"EstateNumber": "00-000001",'+
            '"DebtorName": "WHALEN, BERNARD",'+
            '"Amount": 245.94,'+
            '"AccountNumber": "4537049889659"'+
          '},'+
          '{'+
            '"EstateNumber": "51-2397556",'+
            '"DebtorName": "WHEATLEY, KEVIN Michael",'+
            '"Amount": 67.59,'+
            '"AccountNumber": "438930122025"'+
          '}'+
        ']';
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        controller.backToDividend();
        
        Test.setCurrentPageReference(new PageReference('InsolvencyPaymentUpload')); 
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        controller = new StriplistInsolPaymentUploadController(sc);
        controller.showAllocatedProductPayments();
        controller.ShowUnallocatedProductPayments();   
    }
    
    public static testMethod void testProcessBatch(){
        Remittance__c remittance = new Remittance__c();
        insert remittance;
        List<StriplistUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<StriplistUtil.paymentRecordsWrapper>();
        StriplistUtil.paymentRecordsWrapper wrapper = new StriplistUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '4537049889659';
        wrapper.debtorName = 'TestFile';
        wrapper.estateNumber = '00-000001';
        wrapper.amount = '65.0';
        listPaymentRecordWrapper.add(wrapper);
        wrapper = new StriplistUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '111';
        wrapper.debtorName = 'TestFile';
        wrapper.estateNumber = '00-000001';
        wrapper.amount = '65.0';
        listPaymentRecordWrapper.add(wrapper);
        
        ProcessInsolvencyStriplistBatch batch1 = new ProcessInsolvencyStriplistBatch(listPaymentRecordWrapper, remittance);
        database.executeBatch(batch1);        
    }
    
    public static testMethod void testInsertInsolvencyPaymentBatch(){
        Insolvency_Account__c insolvencyAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        Remittance__c remittance = new Remittance__c();
        insert remittance;
        blob blob1;
        Attachment allocatedPayment = new Attachment();
        allocatedPayment.parentid = remittance.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,debtorName,estateNumber,amount';
        attachBody += '\n';
        attachBody += '4537049889659,'+insolvencyAccount.Id+',TestName,00-000001,100';
        allocatedPayment.Body = Blob.valueOf(attachBody);
        insert allocatedPayment;
        
        InsertInsolvencyPaymentsStriplistBatch batch1 = new InsertInsolvencyPaymentsStriplistBatch(remittance);
        database.executeBatch(batch1);
    }
    
    public static testMethod void testDisplayAllocatedInsolvencyPayments(){
        Remittance__c remittanceInstance = new Remittance__c();
        insert remittanceInstance;
        
        Insolvency_Payment__c paymentInstance1 = new Insolvency_Payment__c  ();
        paymentInstance1.Insolvency_Account__c = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0].ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.Cheque_Payment_Reference_Number__c  = 'Test File Uploaded123456';
        paymentInstance1.Remittance__c = remittanceInstance.Id;
        insert paymentInstance1;
        
        DisplayStriplistInsolAllocatedController controller;
        Test.setCurrentPageReference(new PageReference('DisplayStriplistInsolAllocatedPayments')); 
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        controller = new DisplayStriplistInsolAllocatedController();
        controller.Save();
        controller.Redirect();
    }
    
    public static testMethod void testDisplayUnallocatedInsolvencyPayments(){
        Insolvency_Account__c insoAccount = [SELECT ID FROM Insolvency_Account__c LIMIT 1][0];
        Remittance__c remittanceInstance = new Remittance__c();
        remittanceInstance.Allocated_Payments_Amount__c = 130;
        insert remittanceInstance;
        blob blob1;
        Attachment unallocatedPayment = new Attachment();
        unallocatedPayment.parentid = remittanceInstance.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,debtorName,estateNumber,amount';
        attachBody += '\n';
        attachBody += '4537049889659,'+insoAccount.Id+',TestName,00-000001,100';
        unallocatedPayment.Body = Blob.valueOf(attachBody);
        insert unallocatedPayment;
        
        Test.setCurrentPageReference(new PageReference('DisplayStriplistUnallocatedPayments')); 
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        DisplayStriplistInsolUnallocController controller = new DisplayStriplistInsolUnallocController();
        controller.paymentRecordListInner[0].insolvencyAccInstance.Insolvency_Account__c = insoAccount.Id;
        controller.Save();
        controller.Cancel();
        
        InsertUnallocatedPaymentsStriplistBatch batch2 = new InsertUnallocatedPaymentsStriplistBatch(controller.listUnallocatedPayment, remittanceInstance, 'Insolvency');
        database.executeBatch(batch2);
    }
    
    public static testMethod void testFileUploadErrors(){
        Remittance__c remittanceInstance = new Remittance__c ();
        remittanceInstance.Cheque_Amount__c = 390;
        remittanceInstance.File_Processing_Status__c = 'Completed';
        remittanceInstance.Status__c = 'Processed';
        insert remittanceInstance;
        Test.setCurrentPageReference(new PageReference('StriplistInsolvencyPaymentUpload')); 
        System.currentPageReference().getParameters().put('id', remittanceInstance.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(remittanceInstance);
        StriplistInsolPaymentUploadController controller = new StriplistInsolPaymentUploadController(sc);
        remittanceInstance.Status__c = 'Payment Reversed';
        update remittanceInstance;
        controller = new StriplistInsolPaymentUploadController(sc);
        //upload error        
    }
}