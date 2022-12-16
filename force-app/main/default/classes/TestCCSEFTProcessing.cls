@isTest
public class TestCCSEFTProcessing {
    @testSetup
    public static void testSetup(){
        EFT_Processing_Config__c  config = new EFT_Processing_Config__c();
        config.CCS_EFT_RecordTypeID__c = Schema.SObjectType.EFT_Files__c.getRecordTypeInfosByName().get('CCS EFT').getRecordTypeId();
        insert config;
        
        Product__C productCustom = new Product__C();
        productCustom.Name = '4537049889659';
        productCustom.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('CCS Account').getRecordTypeId();
        insert productCustom;
    }
    public static testMethod void TestPaymentUpload(){
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_EmailMessage_Trigger__c = false;
        insert config;
        
        String testOutputJSON = '';
        PaymentUploadController controller = new PaymentUploadController();
        //upload error
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'error';
        controller.importDatatoApex();
        
        //account no null
        testOutputJSON = '[{'+
      		'"AccountNumber":null,'+
      		'"ClientID":254801.0,'+
      		'"ClientName":"LEBLANC, JUSTIN ",'+
      		'"NetPayment":390.0,'+
      		'"FairSharePayment":110.0,'+
      		'"GrossPayment":500.0'+
       	'}]';
        controller = new PaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        //net payment null
        testOutputJSON = '[{'+
      		'"AccountNumber":"4537049889659",'+
      		'"ClientID":254801.0,'+
      		'"ClientName":"LEBLANC, JUSTIN ",'+
      		'"NetPayment":null,'+
      		'"FairSharePayment":110.0,'+
      		'"GrossPayment":500.0'+
       	'}]';
        controller = new PaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        //success
        testOutputJSON = '[{'+
          	'"AccountNumber":"4537049889659",'+
          	'"ClientID":254801.0,'+
          	'"ClientName":"LEBLANC, JUSTIN ",'+
          	'"NetPayment":390.0,'+
          	'"FairSharePayment":110.0,'+
          	'"GrossPayment":500.0'+
       	'},'+
       	'{'+
          	'"AccountNumber":"4537049851733",'+
          	'"ClientID":257269.0,'+
          	'"ClientName":"URINTSOV, OLGA ",'+
          	'"NetPayment":50.7,'+
          	'"FairSharePayment":14.3,'+
          	'"GrossPayment":65.0'+
       	'}]';
        controller = new PaymentUploadController();
        controller.outputJSON = testOutputJSON; 
        controller.fileUploadStatus = 'success';
        controller.importDatatoApex();
        
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        system.debug('eftInstance: '+eftInstance);
        Test.setCurrentPageReference(new PageReference('PaymentUpload')); 
		System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new PaymentUploadController();
        controller.showAllocatedProductPayments();
        controller.ShowUnallocatedProductPayments();
        
    }
    
    public static testMethod void testProcessBatch(){
        
        List<EFTUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<EFTUtil.paymentRecordsWrapper>();
        EFTUtil.paymentRecordsWrapper wrapper = new EFTUtil.paymentRecordsWrapper();
        wrapper.accountNumber = '4537049889659';
        wrapper.chequeNumber = 'TestFile';
        wrapper.fairsharePayment = '50.7';
        wrapper.netPayment = '65.0';
        wrapper.postingDate = string.valueOf(system.today());
       	listPaymentRecordWrapper.add(wrapper);
        
        EFT_Files__c eft = new EFT_Files__c();
        eft.Posting_Date__c = system.today();
        insert eft;
        
        ProcessCCSEFTBatch batch1 = new ProcessCCSEFTBatch(listPaymentRecordWrapper, eft);
        database.executeBatch(batch1);        
    }
    
    public static testMethod void testInsertProductPaymentBatch(){
        Product__C CCSAccount = [SELECT ID FROM Product__C LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        insert eft;
        blob blob1;
        Attachment allocatedPayment = new Attachment();
        allocatedPayment.parentid = eft.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        String attachBody = 'AccountNumber,accountID,netPayment,fairsharepayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber';
        attachBody += '\n';
        attachBody += '4537049889659,'+CCSAccount.Id+',61.0,35.60,'+String.valueOf(system.today())+',null,null,null,TestCCSFileUpload';
        allocatedPayment.Body = Blob.valueOf(attachBody);
        insert allocatedPayment;
        
        InsertProductPaymentsBatch batch1 = new InsertProductPaymentsBatch(eft);
        database.executeBatch(batch1);
    }
    
    public static testMethod void testDisplayAllocatedCCSPayments(){
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        
        Product_Payments__c paymentInstance1 = new Product_Payments__c();
        paymentInstance1.CCS_Account__c = [SELECT ID FROM Product__c LIMIT 1][0].ID;
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Payment_Amount__c = 321.98;
        paymentInstance1.FairShare_Amount__c = 110.02;
        paymentInstance1.Cheque_Number__c = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;
        
        DisplayAllocatedProductController controller;
        Test.setCurrentPageReference(new PageReference('DisplayAllocatedProductPayments')); 
		System.currentPageReference().getParameters().put('id', eftInstance.Id);
        controller = new DisplayAllocatedProductController();
        controller.redirectPaymentUpload();
    }
    
    public static testMethod void testDisplayUnallocatedCCSPayments(){
		Product__C CCSAccount = [SELECT ID FROM Product__C LIMIT 1][0];
        EFT_Files__c eft = new EFT_Files__c();
        eft.Allocated_Payments_Amount__c = 0;
        insert eft;
        blob blob1;
        Attachment unallocatedPayment = new Attachment();
        unallocatedPayment.parentid = eft.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        String attachBody = 'AccountNumber,netPayment,fairsharepayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber';
        attachBody += '\n';
        attachBody += '4537049209659,'+'61.0,35.60,'+String.valueOf(system.today())+',null,null,null,TestCCSFileUpload';
        attachBody += '4537049889659,'+'61.0,35.60,'+String.valueOf(system.today())+',null,null,null,TestCCSFileUpload';
        unallocatedPayment.Body = Blob.valueOf(attachBody);
        insert unallocatedPayment;
        
        Test.setCurrentPageReference(new PageReference('DisplayCCSUnAllocatedPayments')); 
		System.currentPageReference().getParameters().put('id', eft.Id);
        DisplayUnAllocatedPaymentController controller = new DisplayUnAllocatedPaymentController();
        controller.paymentRecordListInner[0].prodLookup.Product_Custom__c = CCSAccount.Id;
        controller.Save();
        controller.Cancel();
        
        InsertUnallocatedPaymentsBatch batch2 = new InsertUnallocatedPaymentsBatch(controller.listUnallocatedPayment, eft, 'CCS');
        database.executeBatch(batch2);
    }
    
    public static testMethod void testDisplayUnAllocatedProcessedCCSPayments(){
        EFT_Files__c eftInstance = new EFT_Files__c();
        insert eftInstance;
        
        Unallocated_Payment__c paymentInstance1 = new Unallocated_Payment__c();
        paymentInstance1.Payment_Posting_Date__c = system.today();
        paymentInstance1.Unallocated_Amount__c = 321.98;
        paymentInstance1.Unallocated_Fairshare_Amount__c = 110.02;
        paymentInstance1.Cheque_Number__c = 'Test File Uploaded123456';
        paymentInstance1.EFT_Files__c = eftInstance.Id;
        insert paymentInstance1;
        
        DisplayUnallocatedProcessedController controller;
        Test.setCurrentPageReference(new PageReference('DisplayUnallocatedProcessed')); 
		System.currentPageReference().getParameters().put('id', eftInstance.Id);
        System.currentPageReference().getParameters().put('rt', 'CCS');
        controller = new DisplayUnallocatedProcessedController();
        controller.redirectPaymentUpload();
    }
}