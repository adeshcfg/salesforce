public class StriplistInsolPaymentUploadController {
    public String outputJSON{get;set;}
    public boolean showallocated{get;set;}
    public boolean showunallocated{get;set;}
    public boolean showButtons{get;set;}
    public boolean showStriplistTab{get;set;}
    public boolean showFileUpload{get;set;}
    public Remittance__c remittanceInstance{get;set;}
    public String postingDate{get;set;}
    public String fileUploadStatus {get;set;}
    String Status;
    
    //EFT_Processing_Config__c eftConfigInstance;
    
    public StriplistInsolPaymentUploadController(ApexPages.StandardController stdController){
        showButtons = false;
        showStriplistTab = false;
        Id dividendId = ApexPages.currentPage().getParameters().get('id');
        remittanceInstance = new Remittance__c();
       	
        if(dividendId != NULL){
            
            remittanceInstance = [SELECT Id, Name ,Unallocated_Payment_Processing_Status__c, Allocated_Payment_Processing_Status__c,
                                      Payment_Posting_Date__c, Allocated_Payments_Count__c, Unallocated_Payments_Count__c,
                                      Total_Record_Count__c,Total_Payments_Amount__c,
                                      Allocated_Payments_Amount__c,
                                      Unallocated_Payments_Amount__c,File_Processing_Status__c,Status__c,
                                      Cheque_Payment_Reference_Number__c, Cheque_Amount__c
                               	  FROM Remittance__c
                                  WHERE Id= :dividendId][0];
            
        if(remittanceInstance.File_Processing_Status__c == 'Completed'){
                showButtons = true;
           }
        if(remittanceInstance.Status__c == 'Processed'){
            	showStriplistTab = true;
            	showButtons = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Insolvency Payments for this Dividend are already processed.'));
        }
        if(remittanceInstance.Status__c == 'Payment Reversed'){
            	showStriplistTab = true;
            	showButtons = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Cannot upload striplist for Dividend after Payment is Reversed!'));
        }
         //postingDate = String.valueOf(remittanceInstance.Posting_Date__c);
        }
        outputJSON = '';
        showFileUpload = true;
        
    }
    
    public PageReference importDatatoApex(){
        system.debug('_fileUploadStatus_:'+fileUploadStatus);
        if(fileUploadStatus == 'error'){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Invalid file uploaded. Please refresh the page to upload another file.'));
            return null;
        }
        List<StriplistUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<StriplistUtil.paymentRecordsWrapper>();
        
        StriplistUtil striplistUtilInstance = new StriplistUtil();        
        try{
          String outputJSON1 = outputJSON.remove('\\n');
          system.debug('outputJSON: '+outputJSON1);
          Decimal totalAmount=0;
          listPaymentRecordWrapper = striplistUtilInstance.deSerializeJSON(outputJSON1); 
            for(StriplistUtil.paymentRecordsWrapper payInstance : listPaymentRecordWrapper){
                system.debug('--'+payInstance.debtorName +payInstance.accountNumber);
                if((String.isNotBlank(payInstance.amount)
                || (String.isNotBlank(payInstance.accountID))
                || String.isNotBlank(payInstance.debtorName)
                || String.isNotBlank(payInstance.estateNumber))
                && (String.isBlank(payInstance.accountNumber))){
                    system.debug('1');
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Account Number cannot be blank. Please check the file headers and upload valid file.'));
                    return null;
                }
                if(String.isNotBlank(payInstance.accountNumber)
                 &&(String.isBlank(payInstance.amount)
                || payInstance.amount == String.valueOf(0)
                || payInstance.amount == String.valueOf(0.00)
                || payInstance.amount == String.valueOf(0.0))){
                    system.debug('2');
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Amount cannot be blank or 0. Please check the file headers and upload valid file'));
                    return null;
                }
                else{
                    system.debug('3');
                    if(String.isNotBlank(payInstance.amount)){
                    	totalAmount += decimal.valueOf(payInstance.amount);   
                    }
                    system.debug('4');
                }
            }
            if(totalAmount <> remittanceInstance.Cheque_Amount__c){
                system.debug('5');
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Total Amount in excel file does not match with the Dividend Amount.'));
                return null;
            }
            remittanceInstance.File_Processing_Status__c = 'In Progress';
            remittanceInstance.Status__c = 'In Progress';
            remittanceInstance.Striplist_User_ID__c = String.valueOf(UserInfo.getUserId());
            system.debug('RemittanceInstance:'+remittanceInstance);
                
            update remittanceInstance;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'File is being processed. You will receive email once processing is completed.'));
            system.debug('6');
            ProcessInsolvencyStriplistBatch batchInstance = new ProcessInsolvencyStriplistBatch(listPaymentRecordWrapper, remittanceInstance);
                database.executeBatch(batchInstance);    
            }
            catch(Exception ex){
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,ex.getMessage()));    
            }
        	system.debug('7');
        return null;
    }
    
    public pageReference showAllocatedProductPayments(){
        PageReference retURL = new PageReference('/apex/DisplayStriplistInsolAllocatedPayments?id='+remittanceInstance.Id);
        retURL.setRedirect(true);
    return retURL;
    }
    
    public PageReference ShowUnallocatedProductPayments(){
        PageReference retURL;
        retURL = new PageReference('/apex/DisplayStriplistUnallocatedPayments?id='+remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }
    
    public PageReference backToDividend(){
        PageReference retURL;
        retURL = new PageReference('/'+remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }
    

}