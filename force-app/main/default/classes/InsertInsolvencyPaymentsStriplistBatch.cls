/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : Batch class to insert Allocated insolvency payments from Striplist parsing
 *  @author : A5E Consulting
 *  @date : 19/10/2020
 *
 *************************************************************************************************/

public class InsertInsolvencyPaymentsStriplistBatch implements Database.Batchable<List<StriplistUtil.paymentRecordsWrapper>>, Database.Stateful {
    ID insolvencyPaymentRecordTypeID;
    String exceptionMessage;
    Integer allocatedCount = 0;
    Decimal allocatedAmount = 0;
    StriplistUtil striplistUtilInstance;

    public Remittance__c dividendRecord = new Remittance__c();

    list<Attachment> allocatedPayment = new List<Attachment>();
    list<list<StriplistUtil.paymentRecordsWrapper>> paymentRecordList = new List<list<StriplistUtil.paymentRecordsWrapper>>();

    public InsertInsolvencyPaymentsStriplistBatch(Remittance__c dividendRecord) {
        //constructor
        this.dividendRecord = dividendRecord;
        insolvencyPaymentRecordTypeID = Schema.SObjectType.Insolvency_Payment__c.getRecordTypeInfosByName().get('Remittance').getRecordTypeId();
    }

    public List<List<StriplistUtil.paymentRecordsWrapper>> start(Database.BatchableContext bc) {
        //start
        allocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Allocated Payments.csv' AND parentId = :dividendRecord.id];
        Blob csvFileBody = allocatedPayment[0].body;
        String DataAsString = csvFileBody.toString();
        striplistUtilInstance = new StriplistUtil();
        paymentRecordList = striplistUtilInstance.readFromFile(DataAsString);
        return paymentRecordList;
    }

    public void execute(Database.BatchableContext BC, List<List<StriplistUtil.paymentRecordsWrapper>> wrapperList) {
        list<Insolvency_Payment__c> listInsolvencyPayment = new List<Insolvency_Payment__c>();
        for (List<StriplistUtil.paymentRecordsWrapper> wrapList : WrapperList) {
            for (StriplistUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                Insolvency_Payment__c paymentInstance = new Insolvency_Payment__c();
                paymentInstance.Created_by_Striplist_Parsing__c = true;
                if (dividendRecord.Payment_Posting_Date__c != null) {
                    paymentInstance.Payment_Posting_Date__c = dividendRecord.Payment_Posting_Date__c;
                } else {
                    paymentInstance.Payment_Posting_Date__c = system.today();
                }
                paymentInstance.Cheque_Payment_Reference_Number__c = dividendRecord.Cheque_Payment_Reference_Number__c;
                paymentInstance.Remittance__c = dividendRecord.Id;
                paymentInstance.Insolvency_Account__c = wrapRecord.accountID;
                paymentInstance.Payment_Amount__c = Decimal.valueOf(wrapRecord.amount);
                allocatedAmount += paymentInstance.Payment_Amount__c;
                if (insolvencyPaymentRecordTypeID != null) {
                    paymentInstance.RecordTypeId = insolvencyPaymentRecordTypeID;
                }

                listInsolvencyPayment.add(paymentInstance);
            }
        }
        try {
            Database.insert(listInsolvencyPayment);
            allocatedCount += listInsolvencyPayment.size();
        } catch (Exception ex) {
            dividendRecord.Allocated_Payment_Processing_Status__c = 'Error';
            update dividendRecord;
            system.debug('exception in insert insolvency :' + ex);
            exceptionMessage = ex.getMessage() + ' ' + ex.getStackTraceString();
        }
    }

    public void finish(Database.BatchableContext bc) {
        dividendRecord.Allocated_Payment_Processing_Status__c = 'Completed';
        if (String.isBlank(exceptionMessage)) {
            dividendRecord.Allocated_Payments_Count__c = allocatedCount;
            dividendRecord.Allocated_Payments_Amount__c = allocatedAmount;
            if (dividendRecord.Total_Record_Count__c == dividendRecord.Allocated_Payments_Count__c) {
                striplistUtilInstance.assignBankInformation(dividendRecord.Id);
                dividendRecord.Status__c = 'Processed';
                dividendRecord.Payment_Posting_Date__c = system.today();
            }
        }
        update dividendRecord;
        //Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(dividendRecord.Striplist_User_ID__c);
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Allocated Insolvency Payments Upload Status';
        if (String.isBlank(exceptionMessage)) {
            if (dividendRecord.Status__c != 'Processed') {
                message.plainTextBody =
                    'Allocated Insolvency Payments are processed. Please click the link below to view records: \n' +
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/apex/StriplistInsolvencyPaymentUpload?id=' +
                    dividendRecord.Id;
            } else {
                message.plainTextBody =
                    'Allocated Insolvency Payments are processed. Please click the link below to view records: \n' +
                    URL.getSalesforceBaseUrl().toExternalForm() +
                    '/' +
                    dividendRecord.Id;
            }
        } else {
            message.plainTextBody =
                'Allocated Insolvency Payment Processing failed! \nReason: ' +
                exceptionMessage +
                '\n\n' +
                'Please click the link below to view page :\n' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/StriplistInsolvencyPaymentUpload?id=' +
                dividendRecord.Id;
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
