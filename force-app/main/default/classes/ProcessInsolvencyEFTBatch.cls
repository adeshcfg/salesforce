/**************************************************************************************************
*
*  Class:       
*
*  @description : This is a batch class takes list of payment as input and assign accounts to payments
    and store it to unallocated file and allocated file
*  @author : A5E Consulting
*  @date : 18th August 2020
*
*************************************************************************************************/

public Class ProcessInsolvencyEFTBatch implements Database.Batchable<EFTUtil.paymentRecordsWrapper>, Database.Stateful{
    
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public Attachment allocatedPayment = new Attachment();
    public Attachment unallocatedPayment = new Attachment();
    Integer TotalCount = 0;
    Decimal totalAmount = 0;
    List<EFTUtil.paymentRecordsWrapper> paymentRecordList = new List<EFTUtil.paymentRecordsWrapper>();
    
    public ProcessInsolvencyEFTBatch(List<EFTUtil.paymentRecordsWrapper> paymentRecordList, EFT_Files__c eftRecord){
        system.debug('constructor');
        this.paymentRecordList.addAll(paymentRecordList);
        this.eftRecord = eftRecord;
    }
    
    public List<EFTUtil.paymentRecordsWrapper> start(Database.BatchableContext BC){
        system.debug('start');
        blob blob1;
        allocatedPayment.parentid = eftRecord.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        allocatedPayment.Body = 
        Blob.valueOf('AccountNumber,accountID,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber,estateNumber,debtorName');
        insert allocatedPayment;
        
        unallocatedPayment.parentid = eftRecord.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        unallocatedPayment.Body = 
            Blob.valueOf('AccountNumber,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber,estateNumber,debtorName');
        insert unallocatedPayment;
        
        eftRecord.File_Processing_Status__c = 'In Progress';
        update eftRecord;
        system.debug('paymentRecordList: '+paymentRecordList);
        return paymentRecordList;
    }
    
    public void execute(Database.BatchableContext BC, List<EFTUtil.paymentRecordsWrapper> wrapList){
        system.debug('execute');
        String paymentSource='';
        String paymentType='';
        try{
            allocatedPayment = [select id, name, body from attachment where name = 'Allocated Payments.csv' and parentId = :eftRecord.id];
            unallocatedPayment = [select id, name, body from attachment where name = 'Un-allocated Payments.csv' and parentId = :eftRecord.id];
            
            //get data into string from attachments
            String allocatedData = (allocatedPayment.body).toString();
            String unallocatedData = (unallocatedPayment.body).toString();
            
            List<EFTUtil.paymentRecordsWrapper> unallocatedWrapList = new List<EFTUtil.paymentRecordsWrapper>();
            
            //list of accounts in a list to query data
            Set<String> setAccountNumbers = new Set<String>();
            for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
                setAccountNumbers.add(wrapRecord.accountNumber);
            }
            
            //Fetch canaccede and fidem accounts
            List<Insolvency_Account__c> listAccount = [select id, Name,Previous_Account_Reference__c 
                                                       from Insolvency_Account__c 
                                                       where (name in :setAccountNumbers OR 
                                                             (Previous_Account_Reference__c != NULL and Previous_Account_Reference__c IN : setAccountNumbers)  )
                                                       and (client_identifier__c = 'Canaccede' or client_identifier__c = 'Fidem')];
            
            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            Map<String, ID> mapAlternateAccountNumberID = new Map<String, ID>();
            
            for(Insolvency_Account__c accountRecord : listAccount ){
                //Check if insolvency account present with matching Account Number
                if(setAccountNumbers.contains(accountRecord.Name)){
                	mapAccountNumberID.put(accountRecord.name, accountRecord.id);    
                }
                //Else Check if insolvency account present with matching Alternate Account Number
                else if(setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)){
                    mapAlternateAccountNumberID.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                }
            }
            
            //Populate the data from Canaccede accounts and Fidem account into allocated file
            for(EFTUtil.paymentRecordsWrapper wrapRecord : wrapList){
                String accountID = '';
                accountID = mapAccountNumberID.get(wrapRecord.accountNumber);
                //if no record found with matching account number, get matching alternate account number
                if(String.isBlank(accountID)){
                    accountID = mapAlternateAccountNumberID.get(wrapRecord.accountNumber);
                }
				system.debug('accountID: '+accountID);
                if(String.valueOf(wrapRecord.accountNumber) != null){
                    system.debug('acc no not null');
                    if(String.valueOf(wrapRecord.paymentSource) != null){
                    	system.debug('paysource not null');
                        paymentSource = String.valueOf(wrapRecord.paymentSource).replace('.0','');
                        system.debug('paymentSource: '+paymentSource);
                    }
                    if(String.valueOf(wrapRecord.paymentType) != null){
                        	system.debug('paymentType not null');
                      		paymentType = String.valueOf(wrapRecord.paymentType).replace('.0','');     
                        	system.debug('paymentType: '+paymentType);
                    }
                    system.debug('');
                    if(null != Decimal.valueOf(wrapRecord.netPayment)){
                    	totalAmount += Decimal.valueOf(wrapRecord.netPayment);
                    }
                    TotalCount = TotalCount+1;
                    if(String.isBlank(accountID)){
                        setAccountNumbers.add(wrapRecord.accountNumber);
                        unallocatedWrapList.add(wrapRecord);
                        system.debug('unallocatedWrapList1: '+unallocatedWrapList);
                    }else{
                        allocatedData += '\n';
                        allocatedData += wrapRecord.accountNumber+','+accountID+','+wrapRecord.netPayment+','
                            		  +String.valueOf(eftRecord.Posting_Date__c)+','+eftRecord.Short_URL__c+','
                            		  +paymentSource+','+paymentType+','+eftRecord.Cheque_Number__c+','
                            		  +wrapRecord.estateNumber+','+'"'+wrapRecord.debtorName+'"';
                        system.debug('allocatedData1: '+allocatedData);
                    }
                }
            }
            
            //Fetch Non Canaccede and non Fidem accounts which are purchased 
            //i.e. asset status is Purchased, Bulk Purchased or Debt Purchase
            //listAccount = [select id, name from Insolvency_Account__c where name in :accountNumberList and client_identifier__c != 'Canaccede' and client_identifier__c != 'Fidem' and asset_status__c in ('Purchased', 'Bulk Purchased', 'Debt Purchase')];
            
            /*Ticket#904 - Remove Insolvency Account 'Asset Status' filter from matching criteria while allocating payments from EFT file upload*/
            listAccount = [SELECT ID, Name,Previous_Account_Reference__c 
                           FROM Insolvency_Account__c 
                           WHERE (Name IN :setAccountNumbers OR (Previous_Account_Reference__c!= NULL and Previous_Account_Reference__c IN :setAccountNumbers) )
                           and Client_Identifier__c != 'Canaccede' and Client_Identifier__c != 'Fidem'];
            system.debug('listAccount: '+listAccount);
            
            map<String,Id> mapAccountNumberIDAll = new map<String,Id>();
            map<String,Id> mapAlternateAccountNumberIDAll = new map<String,Id>();
            
            for(Insolvency_Account__c accountRecord : listAccount ){
                //Check if insolvency account present with matching Account Number
                //Check if account numbers from file are not found in non-canaccede and non fidem accounts
                if(!mapAccountNumberID.containsKey(accountRecord.Name) && !mapAlternateAccountNumberIDAll.containsKey(accountRecord.Name)){
                	if(setAccountNumbers.contains(accountRecord.Name)){
                		mapAccountNumberIDAll.put(accountRecord.name, accountRecord.id);    
                    }
                    //Else Check if insolvency account present with matching Alternate Account Number
                    else if(setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)){
                        mapAlternateAccountNumberIDAll.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                    }    
                }
                
            }
            system.debug('mapAccountNumberIDAll: '+mapAccountNumberIDAll);
            system.debug('mapAlternateAccountNumberIDAll: '+mapAlternateAccountNumberIDAll);
            
            //Populate the data from purchased non Canaccede accounts and non Fidem account into allocated file
            for(EFTUtil.paymentRecordsWrapper wrapRecord : unallocatedWrapList){
                String accountID = '';
                accountID = mapAccountNumberIDAll.get(wrapRecord.accountNumber);
                
                //if no record found with matching account number, get matching alternate account number
                if(String.isBlank(accountID)){
                    accountID = mapAlternateAccountNumberIDAll.get(wrapRecord.accountNumber);
                }
                system.debug('accountID 2 : '+accountID);
                
                if(String.valueOf(wrapRecord.accountNumber) != null){
                    if(String.valueOf(wrapRecord.paymentSource) != null){
                    	paymentSource = String.valueOf(wrapRecord.paymentSource).replace('.0','');
                    }
                    if(String.valueOf(wrapRecord.paymentType) != null){
                    	paymentType = String.valueOf(wrapRecord.paymentType).replace('.0','');
                    }
                    if(String.isBlank(accountID)){
                        unallocatedData += '\n';
                        unallocatedData += wrapRecord.accountNumber+','+wrapRecord.netPayment+','
                            			+String.valueOf(eftRecord.Posting_Date__c)+','+wrapRecord.shortURL
                            			+','+paymentSource+','+paymentType+','+eftRecord.Cheque_Number__c
                            			+','+((wrapRecord.estateNumber <> null && wrapRecord.estateNumber != 'null') ? wrapRecord.estateNumber : '')
                            			+','+'"'+((wrapRecord.debtorName <> null && wrapRecord.debtorName != 'null') ? wrapRecord.debtorName : '')+'"';
                        system.debug('unallocatedData: '+unallocatedData);
                    }else{
                        allocatedData += '\n';
                        system.debug('wrapRecord.estateNumber: '+wrapRecord.estateNumber);
                        allocatedData += wrapRecord.accountNumber+','+accountID+','+wrapRecord.netPayment
                            		  +','+String.valueOf(eftRecord.Posting_Date__c)+','+eftRecord.Short_URL__c
                            		  +','+paymentSource+','+paymentType+','+eftRecord.Cheque_Number__c
                            		  +','+ ((wrapRecord.estateNumber <> null || wrapRecord.estateNumber != 'null') ? wrapRecord.estateNumber : '')
                                      +','+'"'+((wrapRecord.debtorName <> null) ? wrapRecord.debtorName : '')+'"';
                        system.debug('allocatedData: '+allocatedData);
                    }
                }
            }
            
            allocatedPayment.body = Blob.valueof(allocatedData);
            system.debug('allocatedPayment.body: '+allocatedPayment.body);
            update allocatedPayment;
            
            unallocatedPayment.body = Blob.valueof(unallocatedData);
            system.debug('unallocatedPayment.body: '+unallocatedPayment.body);
            update unallocatedPayment;
        
        }catch(Exception e){
            system.debug('exception : '+e);
            eftRecord.File_Processing_Status__c = 'Error';
            update eftRecord;
            system.debug('eftRecordeftRecord: '+eftRecord);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        eftRecord.File_Processing_Status__c = 'Completed';
        eftRecord.Total_Record_Count__c = TotalCount;
        eftRecord.Total_Payments_Amount__c = totalAmount;
        update eftRecord;
        InsertInsolvencyPaymentsBatch batchInstance = new InsertInsolvencyPaymentsBatch(eftRecord);
        database.executeBatch(batchInstance, 40);
    }
}