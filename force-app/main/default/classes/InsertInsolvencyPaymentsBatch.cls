/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This is a batch class gets the list of parsed payments and inserts Allocated Insolvency Payments
 *  @author : A5E Consulting
 *  @date :
 *
 *************************************************************************************************/

public class InsertInsolvencyPaymentsBatch implements Database.Batchable<List<EFTUtil.paymentRecordsWrapper>>, Database.Stateful {
    public EFT_Files__c eftRecord = new EFT_Files__c();
    public list<Attachment> allocatedPayment = new List<Attachment>();
    EFT_Processing_Config__c eftConfigInstance;
    String exceptionMessage;
    List<List<EFTUtil.paymentRecordsWrapper>> paymentRecordList = new List<List<EFTUtil.paymentRecordsWrapper>>();
    Integer allocatedCount = 0;
    Decimal allocatedAmount = 0;

    public InsertInsolvencyPaymentsBatch(EFT_Files__c eftRecord) {
        this.eftRecord = eftRecord;
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
    }

    public List<List<EFTUtil.paymentRecordsWrapper>> start(Database.BatchableContext bc) {
        allocatedPayment = [SELECT id, name, body FROM attachment WHERE name = 'Allocated Payments.csv' AND parentId = :eftRecord.id];
        Blob csvFileBody = allocatedPayment[0].body;
        String DataAsString = csvFileBody.toString();
        EFTUtil eftUtilInstance = new EFTUtil();
        paymentRecordList = eftUtilInstance.readFromFile(DataAsString);
        return paymentRecordList;
    }

    public void execute(Database.BatchableContext BC, List<List<EFTUtil.paymentRecordsWrapper>> wrapperList) {
        list<Insolvency_Payment__c> listInsolvencyPayment = new List<Insolvency_Payment__c>();
        for (List<EFTUtil.paymentRecordsWrapper> wrapList : WrapperList) {
            for (EFTUtil.paymentRecordsWrapper wrapRecord : wrapList) {
                Insolvency_Payment__c paymentInstance = new Insolvency_Payment__c();
                paymentInstance.Created_by_EFT_Processing__c = true;
                paymentInstance.Source_File_Link__c = eftRecord.Text_URL__c;

                if (wrapRecord.postingDate != null && wrapRecord.postingDate != 'null' && Date.valueOf(wrapRecord.postingDate) != null) {
                    paymentInstance.Payment_Posting_Date__c = Date.valueOf(wrapRecord.postingDate);
                }
                if (String.valueOf(wrapRecord.paymentSource) != 'null') {
                    paymentInstance.Payment_Source__c = String.valueOf(wrapRecord.paymentSource);
                }
                if (String.valueOf(wrapRecord.paymentType) != 'null') {
                    paymentInstance.Payment_Type__c = wrapRecord.paymentType;
                }
                paymentInstance.Cheque_Payment_Reference_Number__c = wrapRecord.chequeNumber;
                paymentInstance.Insolvency_Account__c = wrapRecord.accountID;
                if (String.isnotBlank(wrapRecord.netPayment) && wrapRecord.netPayment != 'null') {
                    paymentInstance.Payment_Amount__c = Decimal.valueOf(wrapRecord.netPayment);
                    allocatedAmount += paymentInstance.Payment_Amount__c;
                }

                paymentInstance.EFT_Files__c = eftRecord.Id;
                if (String.isNotBlank(eftConfigInstance.Insolvency_Payment_Record_TypeID__c)) {
                    paymentInstance.RecordTypeId = eftConfigInstance.Insolvency_Payment_Record_TypeID__c;
                }
                listInsolvencyPayment.add(paymentInstance);
            }
        }
        try {
            Database.insert(listInsolvencyPayment);
            allocatedCount += listInsolvencyPayment.size();
        } catch (Exception ex) {
            eftRecord.Allocated_Processing_Status__c = 'Error';
            update eftRecord;
            system.debug('exception in insert insolvency :' + ex);
            exceptionMessage = ex.getMessage() + ' ' + ex.getStackTraceString();
        }
    }

    public void finish(Database.BatchableContext bc) {
        eftRecord.Allocated_Processing_Status__c = 'Completed';
        if (String.isBlank(exceptionMessage)) {
            eftRecord.Allocated_Payments_Count__c = allocatedCount;
            eftRecord.Allocated_Payments_Amount__c = allocatedAmount;
        }
        update eftRecord;
        //Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        //message.toAddresses = new String[] {eftRecord.User_ID__c};
        message.setTargetObjectId(eftRecord.User_ID__c);
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Allocated Insolvency Payments Upload Status';
        if (String.isBlank(exceptionMessage)) {
            message.plainTextBody =
                'Allocated Insolvency Payments are processed. Please click the link below to view records: \n' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/InsolvencyPaymentUpload?id=' +
                eftRecord.Id;
        } else {
            message.plainTextBody =
                'Allocated Insolvency Payment Processing failed! \nReason: ' +
                exceptionMessage +
                '\n\n' +
                'Please click the link below to view page :\n' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/apex/InsolvencyPaymentUpload?id=' +
                eftRecord.Id;
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
