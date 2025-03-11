public class DisplayStriplistInsolUnallocController {
    public Remittance__c remittanceInstance { get; set; }
    public Map<Integer, StriplistUtil.paymentRecordsWrapper> wrapperMap { get; set; }
    StriplistUtil eftUtilInstance;
    public boolean disableSave { get; set; }
    public boolean showTable { get; set; }

    public DisplayStriplistInsolUnallocController() {
        wrapperMap = new Map<Integer, StriplistUtil.paymentRecordsWrapper>();
        List<List<StriplistUtil.paymentRecordsWrapper>> paymentRecordList = new List<List<StriplistUtil.paymentRecordsWrapper>>();
        List<StriplistUtil.paymentRecordsWrapper> paymentRecordListInner = new List<StriplistUtil.paymentRecordsWrapper>();
        disableSave = false;
        showTable = true;
        String dividendId = ApexPages.currentPage().getParameters().get('id');
        remittanceInstance = new Remittance__c();
        if (dividendId != null) {
            remittanceInstance = [
                SELECT
                    ID,
                    Unallocated_Payment_Processing_Status__c,
                    Striplist_User_ID__c,
                    Cheque_Payment_Reference_Number__c,
                    Payment_Posting_Date__c,
                    Allocated_Payments_Amount__c,
                    Allocated_Payments_Count__c
                FROM Remittance__c
                WHERE ID = :dividendId
            ][0];
            if (remittanceInstance.Unallocated_Payment_Processing_Status__c == 'Completed') {
                disableSave = true;
            }
            list<Attachment> unallocatedPayment = [
                SELECT id, name, body
                FROM attachment
                WHERE Name = 'Un-allocated Payments.csv' AND parentId = :dividendId
            ];
            Blob csvFileBody = unallocatedPayment[0].body;
            String dataAsString = csvFileBody.toString();
            eftUtilInstance = new StriplistUtil();
            paymentRecordList = eftUtilInstance.readCSVFile(dataAsString);
            if (paymentRecordList.isEmpty()) {
                showTable = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no Unallocated Insolvency Payments to display!'));
                return;
            }
            for (List<StriplistUtil.paymentRecordsWrapper> payWrap : paymentRecordList) {
                paymentRecordListInner.addAll(payWrap);
            }
            for (Integer i = 0; i < paymentRecordListInner.size(); i++) {
                wrapperMap.put(i, paymentRecordListInner[i]);
            }
        }
    }

    public pageReference Save() {
        Id insolvencyPaymentRecordTypeID = Schema.SObjectType.Insolvency_Payment__c.getRecordTypeInfosByName().get('Remittance').getRecordTypeId();
        List<StriplistUtil.paymentRecordsWrapper> listUnallocatedPayment = new List<StriplistUtil.paymentRecordsWrapper>();
        List<Insolvency_Payment__c> listInsolvencyPayment = new List<Insolvency_Payment__c>();
        for (Integer key : wrapperMap.keySet()) {
            StriplistUtil.paymentRecordsWrapper wrapRecord = wrapperMap.get(key);
            if (wrapRecord.insolvencyAccInstance.Insolvency_Account__c == null) {
                listUnallocatedPayment.add(wrapRecord);
            } else {
                Insolvency_Payment__c paymentInstance = new Insolvency_Payment__c();
                paymentInstance.Created_by_Striplist_Parsing__c = true;
                if (remittanceInstance.Payment_Posting_Date__c != null) {
                    paymentInstance.Payment_Posting_Date__c = remittanceInstance.Payment_Posting_Date__c;
                } else {
                    paymentInstance.Payment_Posting_Date__c = system.today();
                }
                paymentInstance.Cheque_Payment_Reference_Number__c = remittanceInstance.Cheque_Payment_Reference_Number__c;
                if (wrapRecord.amount != null && wrapRecord.amount != 'null') {
                    paymentInstance.Payment_Amount__c = Decimal.valueOf(wrapRecord.amount);
                }
                paymentInstance.Insolvency_Account__c = wrapRecord.insolvencyAccInstance.Insolvency_Account__c;
                paymentInstance.Remittance__c = remittanceInstance.Id;
                paymentInstance.RecordTypeId = insolvencyPaymentRecordTypeID;
                listInsolvencyPayment.add(paymentInstance);
            }
        }
        try {
            if (!listInsolvencyPayment.isEmpty()) {
                insert listInsolvencyPayment;
            }
        } catch (Exception ex) {
            system.debug('Exception ex: ' + ex);
        }
        InsertUnallocatedPaymentsStriplistBatch instance = new InsertUnallocatedPaymentsStriplistBatch(
            listUnallocatedPayment,
            remittanceInstance,
            'Insolvency'
        );
        database.executeBatch(instance);
        disableSave = true;
        showTable = false;
        Apexpages.addMessage(
            new ApexPages.message(Apexpages.Severity.INFO, 'Your file is being processed. You will receive email once processing is completed.')
        );
        return null;
    }

    public pageReference Cancel() {
        PageReference retURL = new PageReference('/apex/StriplistInsolvencyPaymentUpload?id=' + remittanceInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }
}
