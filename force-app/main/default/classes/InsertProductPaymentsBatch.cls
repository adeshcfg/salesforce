/**************************************************************************************************
*
*  Class:       
*
*  @description : This is a batch class gets the list of parsed payments and inserts Allocated Product Payments
*  @author : A5E Consulting
*  @date : 
*
*************************************************************************************************/

public class InsertProductPaymentsBatch implements Database.Batchable<List<EFTUtil.paymentRecordsWrapper>>, Database.Stateful{
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public list<Attachment> allocatedPayment = new list<Attachment>();
    EFT_Processing_Config__c eftConfigInstance;
    String exceptionMessage;
    Integer wrapCount=0;
    List<List<EFTUtil.paymentRecordsWrapper>> paymentRecordList = new List<List<EFTUtil.paymentRecordsWrapper>>();
    Integer allocatedCount = 0; 
    Decimal allocatedAmount = 0; 
    
    public InsertProductPaymentsBatch(EFT_Files__c eftRecord){
        system.debug('constructor');
        this.eftRecord = eftRecord;
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
    }
    public List<List<EFTUtil.paymentRecordsWrapper>> start(Database.BatchableContext bc) {
        system.debug('start');
        allocatedPayment = [select id, name, body from attachment where name = 'Allocated Payments.csv' and parentId = :eftRecord.id];
        Blob csvFileBody = allocatedPayment[0].body;
        String DataAsString = csvFileBody.toString();
        EFTUtil eftUtilInstance = new EFTUtil();
        paymentRecordList = eftUtilInstance.readFromFile(DataAsString);
        return paymentRecordList;
    }
    
    public void execute(Database.BatchableContext BC, List<List<EFTUtil.paymentRecordsWrapper>> wrapperList){        
        system.debug('execute');
        list<Product_Payments__c> listProductPayment = new list<Product_Payments__c>();
        for(List<EFTUtil.paymentRecordsWrapper> wrapList : WrapperList){
            for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
                Product_Payments__c paymentInstance = new Product_Payments__c();
                paymentInstance.Created_by_EFT_Processing__c = true;
                paymentInstance.Source_File_Link__c = eftRecord.Text_URL__c;
                if(Date.valueOf(wrapRecord.postingDate) != Null){
                    paymentInstance.Payment_Posting_Date__c = Date.valueOf(wrapRecord.postingDate);    
                }
                if(String.isNotBlank(wrapRecord.paymentSource)
                && String.valueOf(wrapRecord.paymentSource) != null
                && String.valueOf(wrapRecord.paymentSource) != 'null'){
                    paymentInstance.Payment_Source__c = String.valueOf(wrapRecord.paymentSource);   
                }
                if(wrapRecord.netPayment != Null && wrapRecord.netPayment != 'null'){
                    paymentInstance.Payment_Amount__c  = Decimal.valueOf(wrapRecord.netPayment);   
                    allocatedAmount += paymentInstance.Payment_Amount__c;
                }
                if(String.isBlank(wrapRecord.chequeNumber)){
                    paymentInstance.Cheque_Number__c = eftRecord.Cheque_Number__c;
                }
                else{
                    paymentInstance.Cheque_Number__c = wrapRecord.chequeNumber;   
                }
                paymentInstance.CCS_Account__c = wrapRecord.accountID;
                if(wrapRecord.fairsharePayment != null && wrapRecord.fairsharePayment != 'null'){
                    paymentInstance.FairShare_Amount__c  = Decimal.valueOf(wrapRecord.fairsharePayment);    
                }
                
                paymentInstance.EFT_Files__c = eftRecord.Id;
                if(String.isNotBlank(eftConfigInstance.Product_Payment_RecordTypeID__c)){
                    paymentInstance.RecordTypeId = eftConfigInstance.Product_Payment_RecordTypeID__c;
                }
                listProductPayment.add(paymentInstance);
            }
        }
        try{
            ProductTriggerHandler.runProductAPITrigger=false;
            insert listProductPayment;
             ProductTriggerHandler.runProductAPITrigger=true;
            allocatedCount+= listProductPayment.size();
        }
        catch(Exception ex){
            eftRecord.Allocated_Processing_Status__c = 'Error';
            
            update eftRecord;
            exceptionMessage = ex.getMessage() + ' ' + ex.getStackTraceString();
            system.debug('ex in insertprod batch: '+ex);
        }
    }
    
    public void finish(Database.BatchableContext bc){
        system.debug('allocatedCount: '+allocatedCount);
	    eftRecord.Allocated_Processing_Status__c = 'Completed';
        if(String.isBlank(exceptionMessage)){
        	eftRecord.Allocated_Payments_Count__c = allocatedCount;
        	eftRecord.Allocated_Payments_Amount__c = allocatedAmount;    
        }
        system.debug('allocatedCount: '+allocatedCount);
        update eftRecord;
        //send email about file process completed        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.toAddresses = new String[] {eftRecord.User_ID__c};
        message.setTargetObjectId(eftRecord.User_ID__c);
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Allocated Product Payments Upload Status';
        if(String.isBlank(exceptionMessage)){
        	message.plainTextBody = 
            'Allocated CCS Payments are processed. Please click the link below to view records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/PaymentUpload?id='+eftRecord.Id;
        }
        else{
            message.plainTextBody = 'Allocated CCS Payment Processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/PaymentUpload?id='+eftRecord.Id;
        }
        system.debug('message: '+message);
        Messaging.SendEmailResult[] results;
        if(!Test.isRunningTest()){
        	Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            results = Messaging.sendEmail(messages);
             if (results[0].success) {
            System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                      + results[0].errors[0].message);
            }
        }
    } 
}