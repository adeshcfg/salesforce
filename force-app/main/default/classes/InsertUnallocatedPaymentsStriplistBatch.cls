/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : Batch class to insert Unallocated insolvency payments from Striplist parsing
 *  @author : A5E Consulting
 *  @date : 19/10/2020
 *
 *************************************************************************************************/

public class InsertUnallocatedPaymentsStriplistBatch implements Database.Batchable<StriplistUtil.paymentRecordsWrapper>, Database.Stateful {
    String unallocatedPaymentType;
    String exceptionMessage;
    ID unallocatedPaymentRecordTypeID;
    Integer unallocatedCount = 0;
    Decimal unallocatedAmount = 0;

    StriplistUtil striplistUtilInstance;

    public Remittance__c dividendRecord = new Remittance__C();

    list<Attachment> unallocatedPayment = new List<Attachment>();
    list<StriplistUtil.paymentRecordsWrapper> paymentRecordList = new List<StriplistUtil.paymentRecordsWrapper>();

    //Constructor
    public InsertUnallocatedPaymentsStriplistBatch(
        List<StriplistUtil.PaymentRecordsWrapper> listUnallocatedPayment,
        Remittance__C dividendRecord,
        String UnAllocatedType
    ) {
        unallocatedPaymentType = UnAllocatedType;
        this.paymentRecordList.addAll(listUnallocatedPayment);
        this.dividendRecord = dividendRecord;
        unallocatedPaymentRecordTypeID = Schema.SObjectType.Unallocated_Payment__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId();
    }

    //Start method to return list of parsed payments wrapper
    public List<StriplistUtil.paymentRecordsWrapper> start(Database.BatchableContext bc) {
        striplistUtilInstance = new StriplistUtil();
        return paymentRecordList;
    }

    //execute method to insert Unallocated Payments
    public void execute(Database.BatchableContext BC, List<StriplistUtil.paymentRecordsWrapper> wrapList) {
        List<StriplistUtil.paymentRecordsWrapper> unallocatedWrapList = new List<StriplistUtil.paymentRecordsWrapper>();
        List<Unallocated_Payment__c> listUnallocatedPayment = new List<Unallocated_Payment__c>();
        for (StriplistUtil.paymentRecordsWrapper wrapRecord : wrapList) {
            Unallocated_Payment__c paymentInstance = new Unallocated_Payment__c();
            paymentInstance.Created_by_Striplist_Parsing__c = true;
            paymentInstance.Remittance__C = dividendRecord.Id;
            paymentInstance.Account_Number__c = wrapRecord.accountNumber;
            paymentInstance.Estate_Number__c = wrapRecord.estateNumber;
            paymentInstance.Unallocated_Amount__c = Decimal.valueOf(wrapRecord.amount);
            paymentInstance.Debtor_Name__c = wrapRecord.debtorName;
            unallocatedAmount += paymentInstance.Unallocated_Amount__c;
            paymentInstance.Cheque_Number__c = dividendRecord.Cheque_Payment_Reference_Number__c;
            if (dividendRecord.Payment_Posting_Date__c != null) {
                paymentInstance.Payment_Posting_Date__c = dividendRecord.Payment_Posting_Date__c;
            } else {
                paymentInstance.Payment_Posting_Date__c = system.today();
            }
            if (unallocatedPaymentType == 'Insolvency' && String.isNotBlank(unallocatedPaymentRecordTypeID)) {
                paymentInstance.RecordTypeId = unallocatedPaymentRecordTypeID;
            }
            listUnallocatedPayment.add(paymentInstance);
        }
        try {
            insert listUnallocatedPayment;
            unallocatedCount += listUnallocatedPayment.size();
        } catch (Exception ex) {
            system.debug('Exception ex: ' + ex);
            exceptionMessage = ex.getMessage() + ' ' + ex.getStackTraceString();
        }
    }

    //FInish method to update dividend and send email to user
    public void finish(Database.BatchableContext bc) {
        //Update Unallocated payments details in Dividend record
        if (String.isBlank(exceptionMessage)) {
            Remittance__c updatedDividenRecord = new Remittance__c(Id = dividendRecord.Id);
            updatedDividenRecord.Unallocated_Payments_Count__c = unallocatedCount;
            try {
                striplistUtilInstance.assignBankInformation(dividendRecord.Id);
                updatedDividenRecord.Status__c = 'Processed';
                updatedDividenRecord.Payment_Posting_Date__c = system.today();
                updatedDividenRecord.Unallocated_Payment_Processing_Status__c = 'Completed';
                updatedDividenRecord.Unallocated_Payments_Amount__c = unallocatedAmount;
                update updatedDividenRecord;
            } catch (Exception ex) {
                exceptionMessage = ex.getMessage() + ' ' + ex.getStackTraceString();
            }
        }
        //Send process completion email to user
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.toAddresses = new String[] {dividendRecord.User_ID__c};
        message.setTargetObjectId(dividendRecord.Striplist_User_ID__c);
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Unallocated Insolvency Payments Upload Status';
        if (unallocatedPaymentType == 'Insolvency') {
            if (String.isBlank(exceptionMessage)) {
                message.plainTextBody =
                    'Unallocated Insolvency Payments are processed. Please click the link below to view records: \n' +
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/' +
                    dividendRecord.Id;
            } else {
                message.plainTextBody =
                    'Unallocated Insolvency Payment Processing failed! \nReason: ' +
                    exceptionMessage +
                    '\n\n' +
                    'Please click the link below to view page :\n' +
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/' +
                    dividendRecord.Id;
            }
        }
        if (!Test.isRunningTest()) {
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
}
