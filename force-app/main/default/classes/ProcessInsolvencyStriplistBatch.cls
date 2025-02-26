/**************************************************************************************************
*
*  Class:       
*
*  @description : This is a batch class takes list of payment as input and assign accounts to payments
    and store it to unallocated file and allocated file
*  @author : A5E Consulting
*  @date : 
*
*************************************************************************************************/

public class ProcessInsolvencyStriplistBatch implements Database.Batchable<StriplistUtil.paymentRecordsWrapper>, Database.Stateful {
    Integer TotalCount = 0;
    Decimal totalAmount = 0;

    public Remittance__c dividendRecord = new Remittance__c();
    public Attachment allocatedPayment = new Attachment();
    public Attachment unallocatedPayment = new Attachment();

    list<StriplistUtil.paymentRecordsWrapper> paymentRecordList = new List<StriplistUtil.paymentRecordsWrapper>();

    //Constructor
    public ProcessInsolvencyStriplistBatch(List<StriplistUtil.paymentRecordsWrapper> paymentRecordList, Remittance__c dividendRecord) {
        this.paymentRecordList.addAll(paymentRecordList);
        this.dividendRecord = dividendRecord;
    }

    //Start method to create CSV and insert to dividend
    public List<StriplistUtil.paymentRecordsWrapper> start(Database.BatchableContext BC) {
        blob blob1;
        allocatedPayment.parentid = dividendRecord.id;
        allocatedPayment.name = 'Allocated Payments.csv';
        allocatedPayment.Body = Blob.valueOf('AccountNumber,accountID,debtorName,estateNumber,amount');
        insert allocatedPayment;

        unallocatedPayment.parentid = dividendRecord.id;
        unallocatedPayment.name = 'Un-allocated Payments.csv';
        unallocatedPayment.Body = Blob.valueOf('AccountNumber,debtorName,estateNumber,amount');
        insert unallocatedPayment;
        return paymentRecordList;
    }

    //execute method to fill the csv files and update
    public void execute(Database.BatchableContext BC, List<StriplistUtil.paymentRecordsWrapper> wrapList) {
        try {
            allocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Allocated Payments.csv' AND parentId = :dividendRecord.id];
            unallocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Un-allocated Payments.csv' AND parentId = :dividendRecord.id];

            //get data into string from attachments
            String allocatedData = (allocatedPayment.body).toString();
            String unallocatedData = (unallocatedPayment.body).toString();

            List<StriplistUtil.paymentRecordsWrapper> unallocatedWrapList = new List<StriplistUtil.paymentRecordsWrapper>();
            list<String> listEstateNumbers = new List<String>();
            list<String> listDebtorNames = new List<String>();
            //list of accounts in a list to query data
            Set<String> setAccountNumbers = new Set<String>();

            for (StriplistUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                if (wrapRecord.accountNumber != null) {
                    setAccountNumbers.add(wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK'));
                }
                /*  //IF condition added by Nagendra part of #5430
                if(wrapRecord.debtorName != null){
                    listDebtorNames.add(wrapRecord.debtorName.deleteWhitespace().remove('BNSBK'));
                }
                */
                //IF condition added by Nagendra part of #5430
                if (wrapRecord.estateNumber != null) {
                    listEstateNumbers.add(wrapRecord.estateNumber.deleteWhitespace());
                }
            }

            //Fetch Insolvency Accounts with matching Account Number,Estate Number and Debtor Name
            //Ticket#944 -Remove Asset Status criteria from Insolvency Account Matching in Striplist Payment Processing
            //Task #5430 - Updated the SOQL query to include Insolvency__r.Name while fetching Insolvency Accounts
            List<Insolvency_Account__c> listAccount = [
                SELECT
                    id,
                    Name,
                    Debtor_1_Estate_Number__c,
                    Debtor_Name_Formula__c,
                    Account_Number_Without_Space__c,
                    Account_No_without_Prefix__c,
                    Previous_Account_Reference__c
                FROM Insolvency_Account__c
                WHERE
                    (Account_No_without_Prefix__c IN :setAccountNumbers
                    OR (Previous_Account_Reference__c != NULL
                    AND Previous_Account_Reference__c IN :setAccountNumbers))
                    // AND Debtor_Name_Formula__c IN: listDebtorNames
                    AND Insolvency__r.name IN :listEstateNumbers
                /*AND (Asset_Status__c = 'Purchased'
                                                       OR Asset_Status__c = 'De-securitized by Seller'
                                                       OR Asset_Status__c = 'Debt Purchase'
                                                       OR Asset_Status__c = 'Bulk Purchased'
                                                       OR Asset_Status__c = 'De-securitization Requested')*/
            ];
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            //map with combination for AccNumber,EstateNumber,DebtorName as Key and Account Id as value
            Map<String, ID> mapAccountId = new Map<String, ID>();
            Map<String, ID> mapAccountwithDebtor = new Map<String, ID>();

            Map<String, ID> mapPreviousAccountNumberId = new Map<String, ID>();
            Map<String, ID> mapPreviousAccountNumberwithDebtor = new Map<String, ID>();

            for (Insolvency_Account__c accountRecord : listAccount) {
                if (setAccountNumbers.contains(accountRecord.Account_No_without_Prefix__c)) {
                    if (mapAccountId.containsKey(accountRecord.Account_No_without_Prefix__c + ':' + accountRecord.Debtor_1_Estate_Number__c)) {
                        mapAccountId.remove(accountRecord.Account_No_without_Prefix__c + ':' + accountRecord.Debtor_1_Estate_Number__c);
                        mapAccountwithDebtor.put(
                            accountRecord.Account_No_without_Prefix__c +
                                ':' +
                                accountRecord.Debtor_1_Estate_Number__c +
                                ':' +
                                accountRecord.Debtor_Name_Formula__c.toLowerCase().trim(),
                            accountRecord.id
                        );
                    } else {
                        mapAccountId.put(accountRecord.Account_No_without_Prefix__c + ':' + accountRecord.Debtor_1_Estate_Number__c, accountRecord.id);
                    }
                }

                //Ticket#944 -Remove Asset Status criteria from Insolvency Account Matching in Striplist Payment Processing.docx
                if (setAccountNumbers.contains(accountRecord.Previous_Account_Reference__c)) {
                    if (mapPreviousAccountNumberId.containsKey(accountRecord.Previous_Account_Reference__c + ':' + accountRecord.Debtor_1_Estate_Number__c)) {
                        mapPreviousAccountNumberId.remove(accountRecord.Previous_Account_Reference__c + ':' + accountRecord.Debtor_1_Estate_Number__c);
                        mapPreviousAccountNumberwithDebtor.put(
                            accountRecord.Previous_Account_Reference__c +
                                ':' +
                                accountRecord.Debtor_1_Estate_Number__c +
                                ':' +
                                accountRecord.Debtor_Name_Formula__c.toLowerCase().trim(),
                            accountRecord.id
                        );
                    } else {
                        mapPreviousAccountNumberId.put(
                            accountRecord.Previous_Account_Reference__c + ':' + accountRecord.Debtor_1_Estate_Number__c,
                            accountRecord.id
                        );
                    }
                }
            }

            //accountNumberList.clear();
            //Populate the data from accounts into allocated and unallocated files
            Integer i = 0;
            for (StriplistUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                if (String.isNotBlank(wrapRecord.accountNumber)) {
                    /*system.debug('keys :'+wrapRecord.accountNumber.deleteWhitespace()  + ':' + 
                                         wrapRecord.estateNumber.deleteWhitespace()  + ':' +
                                         wrapRecord.debtorName.toLowerCase().trim());*/
                    String accountID = '';
                    if (wrapRecord.estateNumber != null) {
                        if (
                            mapAccountId.containsKey(
                                wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') + ':' + wrapRecord.estateNumber.deleteWhitespace()
                            )
                        ) {
                            accountID = mapAccountID.get(
                                wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') + ':' + wrapRecord.estateNumber.deleteWhitespace()
                            );
                        } else {
                            accountID = mapAccountwithDebtor.get(
                                wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') +
                                    ':' +
                                    wrapRecord.estateNumber.deleteWhitespace() +
                                    ':' +
                                    wrapRecord.debtorName.toLowerCase().trim()
                            );
                        }
                        if (accountID == null) {
                            if (
                                mapAccountId.containsKey(
                                    wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') + ':' + wrapRecord.estateNumber.deleteWhitespace()
                                )
                            ) {
                                accountID = mapPreviousAccountNumberId.get(
                                    wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') + ':' + wrapRecord.estateNumber.deleteWhitespace()
                                );
                            } else {
                                accountID = mapPreviousAccountNumberwithDebtor.get(
                                    wrapRecord.accountNumber.deleteWhitespace().remove('BNSBK') +
                                        ':' +
                                        wrapRecord.estateNumber.deleteWhitespace() +
                                        ':' +
                                        wrapRecord.debtorName.toLowerCase().trim()
                                );
                            }
                        }
                    }

                    if (String.valueOf(wrapRecord.accountNumber) != null) {
                        TotalCount = TotalCount + 1;
                        i += 1;
                        totalAmount += decimal.valueOf(wrapRecord.amount);
                        if (String.isBlank(accountID)) {
                            unallocatedData += '\n';
                            unallocatedData +=
                                wrapRecord.accountNumber.deleteWhitespace() +
                                ',' +
                                '"' +
                                (wrapRecord.debtorName != null ? wrapRecord.debtorName : '') +
                                '"' +
                                ',' +
                                (wrapRecord.estateNumber != null ? wrapRecord.estateNumber.deleteWhitespace() : '') +
                                ',' +
                                wrapRecord.amount.deleteWhitespace();
                        } else {
                            allocatedData += '\n';
                            allocatedData +=
                                wrapRecord.accountNumber.deleteWhitespace() +
                                ',' +
                                accountID +
                                ',' +
                                '"' +
                                (wrapRecord.debtorName != null ? wrapRecord.debtorName : '') +
                                '"' +
                                ',' +
                                (wrapRecord.estateNumber != null ? wrapRecord.estateNumber.deleteWhitespace() : '') +
                                ',' +
                                wrapRecord.amount.deleteWhitespace();
                        }
                    }
                }
            }
            allocatedPayment.body = Blob.valueof(allocatedData);
            update allocatedPayment;

            unallocatedPayment.body = Blob.valueof(unallocatedData);
            update unallocatedPayment;
        } catch (Exception e) {
            system.debug('exception: ' + e);
            //dividendRecord.File_Processing_Status__c = 'Error';
            update dividendRecord;
        }
    }

    //Finish method to update total count & amount on Dividend and call to insert payment batch
    public void finish(Database.BatchableContext BC) {
        dividendRecord.File_Processing_Status__c = 'Completed';
        dividendRecord.Total_Record_Count__c = TotalCount;
        dividendRecord.Total_Payments_Amount__c = totalAmount;
        update dividendRecord;
        InsertInsolvencyPaymentsStriplistBatch batchInstance = new InsertInsolvencyPaymentsStriplistBatch(dividendRecord);
        database.executeBatch(batchInstance, 10);
    }
}
