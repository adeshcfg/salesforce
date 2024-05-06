/**************************************************************************************************
*
*  Class:       
*
*  @description : This is a batch class takes list of payment as input and assign accounts to payments
    and store it to unallocated file and allocated file
*  @author : A5E Consulting
*  @date : 20th August 2020
*
*************************************************************************************************/

public Class ProcessCCSEFTBatch implements Database.Batchable<EFTUtil.paymentRecordsWrapper>, Database.Stateful{
    
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public Attachment allocatedPayment = new Attachment();
    public Attachment unallocatedPayment = new Attachment();
    List<EFTUtil.paymentRecordsWrapper> paymentRecordList = new List<EFTUtil.paymentRecordsWrapper>();
    Integer TotalCount = 0;
    Decimal totalAmount = 0;
    public ProcessCCSEFTBatch(List<EFTUtil.paymentRecordsWrapper> paymentRecordList, EFT_Files__c eftRecord){
        
        this.paymentRecordList.addAll(paymentRecordList);
        this.eftRecord = eftRecord;
    }
    
    public List<EFTUtil.paymentRecordsWrapper> start(Database.BatchableContext BC){
        blob blob1;
        allocatedPayment.parentid = eftRecord.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        allocatedPayment.Body = Blob.valueOf('AccountNumber,accountID,netPayment,fairsharepayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber,debtorName');
        insert allocatedPayment;
        
        unallocatedPayment.parentid = eftRecord.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        unallocatedPayment.Body = Blob.valueOf('AccountNumber,netPayment,fairsharepayment,postingDate,shortURL,paymentSource,paymentType,chequeNumber,debtorName');
        insert unallocatedPayment;
        
        eftRecord.File_Processing_Status__c = 'In Progress';
        update eftRecord;
        return paymentRecordList;
    }
    
    public void execute(Database.BatchableContext BC, List<EFTUtil.paymentRecordsWrapper> wrapList){
        String paymentSource='';
        try{
            allocatedPayment = [select id, name, body from attachment where name = 'Allocated Payments.csv' and parentId = :eftRecord.id];
            unallocatedPayment = [select id, name, body from attachment where name = 'Un-allocated Payments.csv' and parentId = :eftRecord.id];
            
            //get data into string from attachments
            String allocatedData = (allocatedPayment.body).toString();
            String unallocatedData = (unallocatedPayment.body).toString();
            
            List<EFTUtil.paymentRecordsWrapper> unallocatedWrapList = new List<EFTUtil.paymentRecordsWrapper>();
            
            //list of accounts in a list to query data
            List<String> accountNumberList = new List<String>();
            for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
                accountNumberList.add(wrapRecord.accountNumber);
            }

            //Fetch canaccede and fidem accounts
            List<Product__C> listAccount = [select id, name, DebtNext_Data_ID__C  from Product__C where name in :accountNumberList and RecordType.name = 'CCS Account'];

            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            for(Product__C accountRecord : listAccount ){
                mapAccountNumberID.put(accountRecord.name, accountRecord.id);
            }
            
            accountNumberList.clear();
            //Populate the data from Canaccede accounts and Fidem account into allocated file
            for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
                String accountID;
                if(mapAccountNumberID.containsKey(wrapRecord.accountNumber)){
                    accountID = mapAccountNumberID.get(wrapRecord.accountNumber);
                }
                if(String.isNotBlank(wrapRecord.accountNumber)){
                    if(null != Decimal.valueOf(wrapRecord.netPayment)){
                    	totalAmount += Decimal.valueOf(wrapRecord.netPayment);
                    }
                    
					TotalCount = TotalCount+1;
                    if(String.valueOf(wrapRecord.paymentSource) != null){
                    	paymentSource = String.valueOf(wrapRecord.paymentSource).replace('.0','');
                    }
                    if(String.isBlank(accountID)) {
                    	unallocatedData += '\n';
                    	unallocatedData += wrapRecord.accountNumber+','+wrapRecord.netPayment+','
                            			+wrapRecord.fairsharePayment+','+String.valueOf(eftRecord.posting_Date__c)+','
                            			+wrapRecord.shortURL+','+paymentSource+','+wrapRecord.paymentType+','
                            			+ eftRecord.Cheque_Number__c
                            			+','+'"'+((wrapRecord.debtorName <> null) ? wrapRecord.debtorName : '')+'"';
                	}else{
                    	allocatedData += '\n';
                    	allocatedData += wrapRecord.accountNumber+','+accountID+','+wrapRecord.netPayment+','
                            		  +wrapRecord.fairsharePayment+','+String.valueOf(eftRecord.Posting_Date__c)+','
                            		  +eftRecord.Short_URL__c+','+paymentSource+','+wrapRecord.paymentType+','
                            		  +eftRecord.Cheque_Number__c
                            		  +','+'"'+((wrapRecord.debtorName <> null) ? wrapRecord.debtorName : '')+'"';
                    }
                    paymentSource = '';
                }
            }
            
            allocatedPayment.body = Blob.valueof(allocatedData);
            update allocatedPayment;
            
            unallocatedPayment.body = Blob.valueof(unallocatedData);
            update unallocatedPayment;
        
        }catch(Exception e){
            eftRecord.File_Processing_Status__c = 'Error';
            update eftRecord;
        }
    }
    
    public void finish(Database.BatchableContext BC){
        eftRecord.File_Processing_Status__c = 'Completed';
        eftRecord.Total_Record_Count__c = TotalCount;
        eftRecord.Total_Payments_Amount__c = totalAmount;
        update eftRecord;
        InsertProductPaymentsBatch batchInstance = new InsertProductPaymentsBatch(eftRecord);
        database.executeBatch(batchInstance, 1);
    }
}