/**************************************************************************************************
*  Class:   
*
*  @description : This is a controller class to process excel file for EFT Payments
*  @author : A5E Consulting
*  @date : 08 July 2020
*************************************************************************************************/

public class PaymentUploadController{
    public String outputJSON{get;set;}
    public boolean showButtons{get;set;}
    public boolean showFileUpload{get;set;}
    public EFT_Files__c eftInstance{get;set;}
    public String postingDate{get;set;}
    public String fileUploadStatus {get;set;}
    EFT_Processing_Config__c eftConfigInstance;
    
    public PaymentUploadController(){
        showButtons = false;
        Id EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        eftInstance = new EFT_Files__c();
        if(EFTRecordId != NULL){
            eftInstance = [SELECT Id, Unallocated_Processing_Status__c, Allocated_Processing_Status__c, User_ID__c,
                           Posting_Date__c, Text_URL__c, Allocated_Payments_Count__c, Unallocated_payments_Count__c,
                           Total_Record_Count__c, Allocated_Payments_Amount__c, Unallocated_Payments_Amount__c,
                           Total_Payments_Amount__c
                           FROM EFT_Files__c
                           WHERE Id= :EFTRecordId][0];
            showButtons = true;
            postingDate = String.valueOf(eftInstance.Posting_Date__c);
        }
        outputJSON = '';
        showFileUpload = true;
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
        
    }
    
    public PageReference importDatatoApex(){
        if(fileUploadStatus == 'error'){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Invalid file uploaded. Please refresh the page to upload another file.'));
            return null;
        }
        List<EFTUtil.paymentRecordsWrapper> listPaymentRecordWrapper = new List<EFTUtil.paymentRecordsWrapper>();
        EFTUtil eftUtilInstance = new EFTUtil();        
        try{
            String outputJSON1 = outputJSON.replaceAll('ClientName','DebtorName');
			system.debug('outputJSON: '+outputJSON1);
        	listPaymentRecordWrapper = eftUtilInstance.deSerializeJSON(outputJSON1);    
            for(EFTUtil.paymentRecordsWrapper payInstance : listPaymentRecordWrapper){
                if((String.isNotBlank(payInstance.netPayment)
                || (String.isNotBlank(payInstance.fairsharePayment))
                || String.isNotBlank(payInstance.paymentSource)
                || String.isNotBlank(payInstance.paymentType))
                && (String.isBlank(payInstance.accountNumber))){
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,
					'Account Number cannot be blank. Please check the file headers and upload valid file.'));
                    return null;
                }
                if(String.isNotBlank(payInstance.accountNumber)
                 &&(String.isBlank(payInstance.netPayment)
                || payInstance.netPayment == String.valueOf(0)
                || payInstance.netPayment == String.valueOf(0.00)
                || payInstance.netPayment == String.valueOf(0.0))){
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,'Net Payment cannot be blank or 0. Please check the file headers and upload valid file.'));
                    return null;
                }
            }
            if(String.isBlank(postingDate)){
            	eftInstance.Posting_Date__c = system.Today();
        	}
        	else{
                list<String> dateValue = postingDate.split('-');
                eftInstance.Posting_Date__c = date.newInstance(Integer.valueOf(dateValue[0]), Integer.valueOf(dateValue[1]), Integer.valueOf(dateValue[2]));
	        }
            eftInstance.File_Processing_Status__c = 'In Progress';
            eftInstance.Name = 'CCS Payments ' + system.now();
            eftInstance.User_ID__c = String.valueOf(UserInfo.getUserId());
            if(String.isNotBlank(eftInstance.Text_URL__c)){
                eftInstance.Text_URL__c = eftInstance.Text_URL__c.trim();
            }
            system.debug('eftInstance: '+eftInstance.Text_URL__c);
            if(String.isNotBlank(eftConfigInstance.CCS_EFT_RecordTypeID__c)){
            	eftInstance.RecordTypeId = eftConfigInstance.CCS_EFT_RecordTypeID__c;    
            }
            if(!listPaymentRecordWrapper.isEmpty()){
                eftInstance.Total_Record_Count__c = listPaymentRecordWrapper.size();
            }
            insert eftInstance;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'File is being processed.  You will receive email once processing is completed.'));
            ProcessCCSEFTBatch batchInstance = new ProcessCCSEFTBatch(listPaymentRecordWrapper, eftInstance);
            database.executeBatch(batchInstance);    
        }
        catch(Exception ex){
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,ex.getMessage()));
                
        }
        return null;
    }

    public pageReference showAllocatedProductPayments(){
        PageReference retURL = new PageReference('/apex/DisplayAllocatedProductPayments?id='+eftInstance.Id);
        retURL.setRedirect(true);
		return retURL;
    }
    
    public PageReference ShowUnallocatedProductPayments(){
        PageReference retURL;
        if(eftInstance.Unallocated_Processing_Status__c == 'Completed'){
            retURL = new PageReference('/apex/DisplayUnallocatedProcessed?id='+eftInstance.Id+'&rt=CCS');
        }
        else{
        	retURL = new PageReference('/apex/DisplayCCSUnallocatedPayments?id='+eftInstance.Id);    
        }
        retURL.setRedirect(true);
        return retURL;
    }
}