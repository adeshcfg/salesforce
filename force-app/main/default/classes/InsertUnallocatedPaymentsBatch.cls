public class InsertUnallocatedPaymentsBatch implements Database.Batchable<EFTUtil.paymentRecordsWrapper>, Database.Stateful{
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public list<Attachment> unallocatedPayment = new list<Attachment>();
    List<EFTUtil.paymentRecordsWrapper> paymentRecordList = new List<EFTUtil.paymentRecordsWrapper>();
    EFT_Processing_Config__c eftConfigInstance;
	Integer unallocatedCount = 0;
    String UnallocatedPaymentType;
    Decimal unallocatedAmount = 0; 
        
    public InsertUnallocatedPaymentsBatch(List<EFTUtil.PaymentRecordsWrapper> listUnallocatedPayment, EFT_Files__c eftRecord,
                                         String UnAllocatedType){
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
        UnallocatedPaymentType = UnAllocatedType;
        this.paymentRecordList.addAll(listUnallocatedPayment);
        this.eftRecord = eftRecord;
    }
    public List<EFTUtil.paymentRecordsWrapper> start(Database.BatchableContext bc) {
        return paymentRecordList;
    }
    
    public void execute(Database.BatchableContext BC, List<EFTUtil.paymentRecordsWrapper> wrapList){        
        List<EFTUtil.paymentRecordsWrapper> unallocatedWrapList = new List<EFTUtil.paymentRecordsWrapper>();
        
        list<Unallocated_Payment__c> listUnallocatedPayment = new list<Unallocated_Payment__c>();
        for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
            Unallocated_Payment__c paymentInstance = new Unallocated_Payment__c();
            paymentInstance.Created_by_EFT_Processing__c = true;
			paymentInstance.EFT_Files__c = eftRecord.Id;
            paymentInstance.Source_File_Link__c = eftRecord.Text_URL__c;
            
            if(wrapRecord.postingDate != 'null'
            && String.isNotBlank(wrapRecord.postingDate)){
            	paymentInstance.Payment_Posting_Date__c = Date.valueOf(wrapRecord.postingDate);
            }
            if(wrapRecord.accountNumber != 'null'){
            	paymentInstance.Account_Number__c = wrapRecord.accountNumber;    
            }
            if(String.isBlank(wrapRecord.chequeNumber)){
                paymentInstance.Cheque_Number__c = eftRecord.Cheque_Number__c;
            }
            else{
            	paymentInstance.Cheque_Number__c = wrapRecord.chequeNumber;
            }
            
            if(String.isNotBlank(wrapRecord.debtorName)){
                paymentInstance.Debtor_Name__c = wrapRecord.debtorName;
            }
            
            if(String.isNotBlank(wrapRecord.estateNumber)){
                paymentInstance.Estate_Number__c = wrapRecord.estateNumber;
            }
            if(UnallocatedPaymentType == 'CCS'
               && (wrapRecord.fairsharePayment != null && wrapRecord.fairsharePayment != 'null')){
            	paymentInstance.Unallocated_Fairshare_Amount__c = Decimal.valueOf(wrapRecord.fairsharePayment);
            }
            if(String.isnotBlank(wrapRecord.netPayment) && wrapRecord.netPayment != 'null'){
            	paymentInstance.Unallocated_Amount__c = Decimal.valueOf(wrapRecord.netPayment);
                unallocatedAmount += paymentInstance.Unallocated_Amount__c;
            }
            if(UnallocatedPaymentType == 'CCS'
            && String.isNotBlank(eftConfigInstance.CCS_Unallocated_Payment_RecordTypeID__c)){
                paymentInstance.RecordTypeId = eftConfigInstance.CCS_Unallocated_Payment_RecordTypeID__c;
            }
            if(UnallocatedPaymentType == 'Insolvency'
            && String.isNotBlank(eftConfigInstance.Insolvency_Unallocated_RecordTypeId__c)){
                paymentInstance.RecordTypeId = eftConfigInstance.Insolvency_Unallocated_RecordTypeId__c;
            }
            listUnallocatedPayment.add(paymentInstance);
        }
        
        try{
            insert listUnallocatedPayment;    
            unallocatedCount+= listUnallocatedPayment.size();
        }
        catch(Exception ex){
            system.debug('Exception ex: '+ex);
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        eftRecord.Unallocated_Payments_count__c = unallocatedCount;
        eftRecord.Unallocated_Processing_Status__c = 'Completed';
        eftRecord.Unallocated_Payments_Amount__c = unallocatedAmount;
        update eftRecord;
        //Send process completion email to user
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.toAddresses = new String[] {eftRecord.User_ID__c};
        message.setTargetObjectId(eftRecord.User_ID__c);
        message.setSaveAsActivity(false);
        //message.optOutPolicy = 'FILTER';
        if(UnallocatedPaymentType == 'CCS'){
        	message.plainTextBody = 
            'Unallocated CCS Payments are processed. Please click the link below to view: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/PaymentUpload?id='+eftRecord.Id;    
            message.subject = 'Unallocated Product Payments Upload Status';
        }
        else{
            message.plainTextBody = 
            'Unallocated Insolvency Payments are processed. Please click the link below to view: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/InsolvencyPaymentUpload?id='+eftRecord.Id;
            message.subject = 'Unallocated Insolvency Payments Upload Status';
        }
        if(!Test.isRunningTest()){
        	Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                      + results[0].errors[0].message);
            }    
        }
    } 
}