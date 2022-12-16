public class DisplayUnAllocatedPaymentController {
    public list<EFTUtil.paymentRecordsWrapper> listUnallocatedPayment {get;set;}
    public EFT_Files__c eftInstance{get;set;}
    EFT_Processing_Config__c eftConfigInstance;
    public List<List<EFTUtil.paymentRecordsWrapper>> paymentRecordList {get;set;}
    public List<EFTUtil.paymentRecordsWrapper> paymentRecordListInner {get;set;}
    public list<Product_Payments__c> listProductPayment {get;set;}
    public list<Unallocated_Payment__c> listUnallocatedPayments {get;set;}
    public boolean disableSave {get;set;}
    public boolean showTable {get;set;}
    
    public DisplayUnAllocatedPaymentController(){
        listUnallocatedPayment = new list<EFTUtil.paymentRecordsWrapper>();
        paymentRecordList = new List<List<EFTUtil.paymentRecordsWrapper>>();
        paymentRecordListInner = new List<EFTUtil.paymentRecordsWrapper>();
        listUnallocatedPayments = new list<Unallocated_Payment__c>();
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
        disableSave = false;
        showTable = true;
        Id EFTRecordId = ApexPages.currentPage().getParameters().get('id');
        eftInstance = new EFT_Files__c();
        if(EFTRecordId != null){
            eftInstance = [SELECT ID, Unallocated_Processing_Status__c, User_Id__c, Allocated_Payments_Count__c,
                           	 	  Unallocated_Payments_count__c, Allocated_Payments_Amount__c,Posting_Date__c,
                           		  Text_URL__c
                           FROM EFT_Files__c 
                           WHERE ID= :EFTRecordId][0];
            if(eftInstance.Unallocated_Processing_Status__c == 'Completed'){
                listUnallocatedPayments = [SELECT ID, Payment_Posting_Date__c, Account_Number__c,
                                                                        Cheque_Number__c, Unallocated_Fairshare_Amount__c, 
                                                                        Unallocated_Amount__c
                                                                        FROM Unallocated_Payment__c
                                                                        WHERE EFT_Files__c= :EFTRecordId];
                disableSave = true;
            } 
            list<Attachment> unallocatedPayment = [SELECT id, name, body 
                                                   FROM attachment 
                                                   WHERE Name = 'Un-allocated Payments.csv' and parentId = :EFTRecordId];
            Blob csvFileBody = unallocatedPayment[0].body;
            String DataAsString = csvFileBody.toString();
            EFTUtil eftUtilInstance = new EFTUtil();
            try{
            	paymentRecordList = eftUtilInstance.readCSVFile(DataAsString);    
            }
            catch(Exception ex){
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,ex.getMessage()));
            }
            if(!paymentRecordList.isEmpty()){
                for(List<EFTUtil.paymentRecordsWrapper> payWrap : paymentRecordList){
                    paymentRecordListInner.addAll(payWrap);
                }
            }
            if(paymentRecordListInner.isEmpty()){
                showTable = false;
            	Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Unallocated Product Payments to display!'));
        	}
        }
    }
    
    public PageReference Save(){
        listProductPayment = new list<Product_Payments__c>();
        for(EFTUtil.paymentRecordsWrapper wrapRecord : paymentRecordListInner){
            if(wrapRecord.prodLookup.Product_Custom__c == null){
                listUnallocatedPayment.add(wrapRecord);    
            }
            else{
            	Product_Payments__c paymentInstance = new Product_Payments__c();
                paymentInstance.Created_by_EFT_Processing__c = true;
                paymentInstance.Source_File_Link__c = eftInstance.Text_URL__c;
                if(null != wrapRecord.postingDate && wrapRecord.postingDate != 'null'){
                	paymentInstance.Payment_Posting_Date__c = Date.valueOf(wrapRecord.postingDate);
                }
                if(String.isNotBlank( wrapRecord.paymentSource)
                && wrapRecord.paymentSource != 'null'){
                   paymentInstance.Payment_Source__c = wrapRecord.paymentSource;       
                }
                if(wrapRecord.netPayment != null && wrapRecord.netPayment != 'null'){
					paymentInstance.Payment_Amount__c  = Decimal.valueOf(wrapRecord.netPayment);  
                    eftInstance.Allocated_Payments_Amount__c +=paymentInstance.Payment_Amount__c;
                }
                paymentInstance.Cheque_Number__c = wrapRecord.chequeNumber;
                paymentInstance.CCS_Account__c = wrapRecord.prodLookup.Product_Custom__c;
                if(String.isNotBlank(wrapRecord.fairsharePayment)
                && wrapRecord.fairsharePayment != 'null'){
                	paymentInstance.FairShare_Amount__c  = Decimal.valueOf(wrapRecord.fairsharePayment);       
				}
                paymentInstance.EFT_Files__c = eftInstance.Id;
                if(String.isNotBlank(eftConfigInstance.Product_Payment_RecordTypeID__c)){
                    paymentInstance.RecordTypeId = eftConfigInstance.Product_Payment_RecordTypeID__c;
                }
                listProductPayment.add(paymentInstance);
            }
        }
        
        try{
            insert listProductPayment;
            eftInstance.Allocated_Payments_Count__c += listProductPayment.size();
            update eftInstance;
        }
        catch(Exception ex){
            system.debug('Exception ex');
        }
        InsertUnallocatedPaymentsBatch instance = new InsertUnallocatedPaymentsBatch(listUnallocatedPayment, eftInstance,
                        'CCS');
        database.executeBatch(instance);
		eftInstance.Unallocated_Processing_Status__c = 'Completed';        
        //disableSave = true;
        showTable = false;
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Your file is being processed. You will receive email once processing is completed.'));
        return null;
    }
    
    public pageReference Cancel(){
        PageReference retURL = new PageReference('/apex/PaymentUpload?id='+eftInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    } 
}