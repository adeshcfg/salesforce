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

public class ProcessInsolvencyEFTBatch implements Database.Batchable<EFTUtil.paymentRecordsWrapper>, Database.Stateful {
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public Attachment allocatedPayment = new Attachment();
    public Attachment unallocatedPayment = new Attachment();
    Integer TotalCount = 0;
    Decimal totalAmount = 0;
    public String selectedBankName;
    List<EFTUtil.paymentRecordsWrapper> paymentRecordList = new List<EFTUtil.paymentRecordsWrapper>();

    public ProcessInsolvencyEFTBatch(List<EFTUtil.paymentRecordsWrapper> paymentRecordList, EFT_Files__c eftRecord, String selectedBankName) {
        this.paymentRecordList.addAll(paymentRecordList);
        this.eftRecord = eftRecord;
        this.selectedBankName = selectedBankName;
    }

    public List<EFTUtil.paymentRecordsWrapper> start(Database.BatchableContext BC) {
        blob blob1;
        allocatedPayment.parentid = eftRecord.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        allocatedPayment.Body = Blob.valueOf(
            'AccountNumber,accountID,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber,estateNumber,debtorName'
        );
        insert allocatedPayment;

        unallocatedPayment.parentid = eftRecord.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        unallocatedPayment.Body = Blob.valueOf('AccountNumber,NetPayment,postingDate,shortURL,paymentSource,paymentType,ChequeNumber,estateNumber,debtorName');
        insert unallocatedPayment;

        eftRecord.File_Processing_Status__c = 'In Progress';
        update eftRecord;
        return paymentRecordList;
    }

    public void execute(Database.BatchableContext BC, List<EFTUtil.paymentRecordsWrapper> wrapList) {
        String paymentSource = '';
        String paymentType = '';
        try {
            allocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Allocated Payments.csv' AND parentId = :eftRecord.id];
            unallocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Un-allocated Payments.csv' AND parentId = :eftRecord.id];

            //get data into string from attachments
            String allocatedData = (allocatedPayment.body).toString();
            String unallocatedData = (unallocatedPayment.body).toString();

            List<EFTUtil.paymentRecordsWrapper> unallocatedWrapList = new List<EFTUtil.paymentRecordsWrapper>();

            //list of accounts in a list to query data
            Set<String> setAccountNumbers = new Set<String>();
            for (EFTUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                setAccountNumbers.add(wrapRecord.accountNumber);
            }

            //Fetch canaccede and fidem accounts
            List<Insolvency_Account__c> listAccount = [
                SELECT id, Name, Previous_Account_Reference__c, recordtype.DeveloperName, Debtor_1_Estate_Number__c
                FROM Insolvency_Account__c
                WHERE
                    (name IN :setAccountNumbers
                    OR (Previous_Account_Reference__c != NULL
                    AND Previous_Account_Reference__c IN :setAccountNumbers))
                    AND (client_identifier__c = 'Canaccede'
                    OR client_identifier__c = 'Fidem')
            ];

            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            Map<String, ID> mapAlternateAccountNumberID = new Map<String, ID>();

            for (Insolvency_Account__c accountRecord : listAccount) {
                //Check if insolvency account present with matching Account Number
                if (accountRecord.recordtype.DeveloperName == selectedBankName) {
                    if (setAccountNumbers.contains(accountRecord.Name)) {
                        mapAccountNumberID.put(accountRecord.name, accountRecord.id);
                    }
                    //Else Check if insolvency account present with matching Alternate Account Number
                    else if (setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)) {
                        mapAlternateAccountNumberID.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                    }
                } else if (selectedBankName == 'Trustee Payment Files') {
                    if (setAccountNumbers.contains(accountRecord.Name)) {
                        mapAccountNumberID.put(accountRecord.name, accountRecord.id);
                    }
                    //Else Check if insolvency account present with matching Alternate Account Number
                    else if (setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)) {
                        mapAlternateAccountNumberID.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                    }
                }
            }

            //Populate the data from Canaccede accounts and Fidem account into allocated file
            for (EFTUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                String accountID = '';
                accountID = mapAccountNumberID.get(wrapRecord.accountNumber);
                //if no record found with matching account number, get matching alternate account number
                if (String.isBlank(accountID)) {
                    accountID = mapAlternateAccountNumberID.get(wrapRecord.accountNumber);
                }
                if (String.isNotBlank(wrapRecord.accountNumber)) {
                    if (String.valueOf(wrapRecord.paymentSource) != null) {
                        paymentSource = String.valueOf(wrapRecord.paymentSource).replace('.0', '');
                    }
                    if (String.valueOf(wrapRecord.paymentType) != null) {
                        paymentType = String.valueOf(wrapRecord.paymentType).replace('.0', '');
                    }
                    if (null != Decimal.valueOf(wrapRecord.netPayment)) {
                        totalAmount += Decimal.valueOf(wrapRecord.netPayment);
                    }
                    TotalCount = TotalCount + 1;
                    if (String.isBlank(accountID)) {
                        setAccountNumbers.add(wrapRecord.accountNumber);
                        unallocatedWrapList.add(wrapRecord);
                    } else {
                        allocatedData += '\n';
                        allocatedData +=
                            wrapRecord.accountNumber +
                            ',' +
                            accountID +
                            ',' +
                            wrapRecord.netPayment +
                            ',' +
                            String.valueOf(eftRecord.Posting_Date__c) +
                            ',' +
                            eftRecord.Short_URL__c +
                            ',' +
                            paymentSource +
                            ',' +
                            paymentType +
                            ',' +
                            eftRecord.Cheque_Number__c +
                            ',' +
                            wrapRecord.estateNumber +
                            ',' +
                            '"' +
                            wrapRecord.debtorName +
                            '"';
                    }
                }
            }

            //Fetch Non Canaccede and non Fidem accounts which are purchased
            //i.e. asset status is Purchased, Bulk Purchased or Debt Purchase
            //listAccount = [select id, name from Insolvency_Account__c where name in :accountNumberList and client_identifier__c != 'Canaccede' and client_identifier__c != 'Fidem' and asset_status__c in ('Purchased', 'Bulk Purchased', 'Debt Purchase')];

            /*Ticket#904 - Remove Insolvency Account 'Asset Status' filter from matching criteria while allocating payments from EFT file upload*/
            listAccount = [
                SELECT ID, Name, Previous_Account_Reference__c, recordtype.DeveloperName, Debtor_1_Estate_Number__c
                FROM Insolvency_Account__c
                WHERE
                    (Name IN :setAccountNumbers
                    OR (Previous_Account_Reference__c != NULL
                    AND Previous_Account_Reference__c IN :setAccountNumbers))
                    AND Client_Identifier__c != 'Canaccede'
                    AND Client_Identifier__c != 'Fidem'
            ];

            map<String, Id> mapAccountNumberIDAll = new Map<String, Id>();
            map<String, Id> mapAlternateAccountNumberIDAll = new Map<String, Id>();

            for (Insolvency_Account__c accountRecord : listAccount) {
                //Check if insolvency account present with matching Account Number
                //Check if account numbers from file are not found in non-canaccede and non fidem accounts
                if (accountRecord.recordtype.DeveloperName == selectedBankName) {
                    if (!mapAccountNumberID.containsKey(accountRecord.Name) && !mapAlternateAccountNumberIDAll.containsKey(accountRecord.Name)) {
                        if (setAccountNumbers.contains(accountRecord.Name)) {
                            mapAccountNumberIDAll.put(accountRecord.name, accountRecord.id);
                        }
                        //Else Check if insolvency account present with matching Alternate Account Number
                        else if (setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)) {
                            mapAlternateAccountNumberIDAll.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                        }
                    }
                } else if (selectedBankName == 'Trustee Payment Files') {
                    if (!mapAccountNumberID.containsKey(accountRecord.Name) && !mapAlternateAccountNumberIDAll.containsKey(accountRecord.Name)) {
                        if (setAccountNumbers.contains(accountRecord.Name)) {
                            mapAccountNumberIDAll.put(accountRecord.name, accountRecord.id);
                        }
                        //Else Check if insolvency account present with matching Alternate Account Number
                        else if (setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)) {
                            mapAlternateAccountNumberIDAll.put(accountRecord.Previous_Account_Reference__c, accountRecord.id);
                        }
                    }
                }
            }

            //Populate the data from purchased non Canaccede accounts and non Fidem account into allocated file
            for (EFTUtil.paymentRecordsWrapper wrapRecord : unallocatedWrapList) {
                String accountID = '';
                accountID = mapAccountNumberIDAll.get(wrapRecord.accountNumber);

                //if no record found with matching account number, get matching alternate account number
                if (String.isBlank(accountID)) {
                    accountID = mapAlternateAccountNumberIDAll.get(wrapRecord.accountNumber);
                }

                if (String.valueOf(wrapRecord.accountNumber) != null) {
                    if (String.valueOf(wrapRecord.paymentSource) != null) {
                        paymentSource = String.valueOf(wrapRecord.paymentSource).replace('.0', '');
                    }
                    if (String.valueOf(wrapRecord.paymentType) != null) {
                        paymentType = String.valueOf(wrapRecord.paymentType).replace('.0', '');
                    }
                    if (String.isBlank(accountID)) {
                        unallocatedData += '\n';
                        unallocatedData +=
                            wrapRecord.accountNumber +
                            ',' +
                            wrapRecord.netPayment +
                            ',' +
                            String.valueOf(eftRecord.Posting_Date__c) +
                            ',' +
                            wrapRecord.shortURL +
                            ',' +
                            paymentSource +
                            ',' +
                            paymentType +
                            ',' +
                            eftRecord.Cheque_Number__c +
                            ',' +
                            ((wrapRecord.estateNumber <> null && wrapRecord.estateNumber != 'null') ? wrapRecord.estateNumber : '') +
                            ',' +
                            '"' +
                            ((wrapRecord.debtorName <> null && wrapRecord.debtorName != 'null') ? wrapRecord.debtorName : '') +
                            '"';
                    } else {
                        allocatedData += '\n';
                        allocatedData +=
                            wrapRecord.accountNumber +
                            ',' +
                            accountID +
                            ',' +
                            wrapRecord.netPayment +
                            ',' +
                            String.valueOf(eftRecord.Posting_Date__c) +
                            ',' +
                            eftRecord.Short_URL__c +
                            ',' +
                            paymentSource +
                            ',' +
                            paymentType +
                            ',' +
                            eftRecord.Cheque_Number__c +
                            ',' +
                            ((wrapRecord.estateNumber <> null || wrapRecord.estateNumber != 'null') ? wrapRecord.estateNumber : '') +
                            ',' +
                            '"' +
                            ((wrapRecord.debtorName <> null) ? wrapRecord.debtorName : '') +
                            '"';
                    }
                }
            }

            allocatedPayment.body = Blob.valueof(allocatedData);
            update allocatedPayment;

            unallocatedPayment.body = Blob.valueof(unallocatedData);
            update unallocatedPayment;
        } catch (Exception e) {
            system.debug('exception : ' + e);
            eftRecord.File_Processing_Status__c = 'Error';
            update eftRecord;
        }
    }

    public void finish(Database.BatchableContext BC) {
        eftRecord.File_Processing_Status__c = 'Completed';
        eftRecord.Total_Record_Count__c = TotalCount;
        eftRecord.Total_Payments_Amount__c = totalAmount;
        update eftRecord;
        InsertInsolvencyPaymentsBatch batchInstance = new InsertInsolvencyPaymentsBatch(eftRecord);
        database.executeBatch(batchInstance, 10);
    }
}
