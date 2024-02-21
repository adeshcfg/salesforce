public class DisplayInsolUnAllocatedPaymentController {
    public EFT_Files__c eftInstance { get; set; }
    public Map<Integer, EFTUtil.paymentRecordsWrapper> wrapperMap { get; set; }
    EFT_Processing_Config__c eftConfigInstance;
    public boolean disableSave { get; set; }
    public boolean showTable { get; set; }

    public DisplayInsolUnAllocatedPaymentController() {
        wrapperMap = new Map<Integer, EFTUtil.paymentRecordsWrapper>();
        List<List<EFTUtil.paymentRecordsWrapper>> paymentRecordList = new List<List<EFTUtil.paymentRecordsWrapper>>();
        List<EFTUtil.paymentRecordsWrapper> paymentRecordListInner = new List<EFTUtil.paymentRecordsWrapper>();
        eftConfigInstance = EFT_Processing_Config__c.getOrgDefaults();
        disableSave = false;
        showTable = true;
        String eftRecordId = ApexPages.currentPage().getParameters().get('id');
        eftInstance = new EFT_Files__c();
        if (eftRecordId != null) {
            eftInstance = [
                SELECT
                    ID,
                    Posting_Date__c,
                    Allocated_Payments_Count__c,
                    Unallocated_Processing_Status__c,
                    User_Id__c,
                    Allocated_Payments_Amount__c,
                    Total_Payments_Amount__c,
                    Text_URL__c
                FROM EFT_Files__c
                WHERE ID = :eftRecordId
            ][0];
            if (eftInstance.Unallocated_Processing_Status__c == 'Completed') {
                disableSave = true;
            }
            list<Attachment> unallocatedPayment = [
                SELECT id, name, body
                FROM attachment
                WHERE Name = 'Un-allocated Payments.csv' AND parentId = :eftRecordId
            ];
            Blob csvFileBody = unallocatedPayment[0].body;
            String dataAsString = csvFileBody.toString();
            EFTUtil eftUtilInstance = new EFTUtil();
            paymentRecordList = eftUtilInstance.readCSVFile(dataAsString);
            if (paymentRecordList.isEmpty()) {
                showTable = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no Unallocated Product Payments to display!'));
                return;
            }
            for (List<EFTUtil.paymentRecordsWrapper> payWrap : paymentRecordList) {
                paymentRecordListInner.addAll(payWrap);
            }
            for (Integer i = 0; i < paymentRecordListInner.size(); i++) {
                wrapperMap.put(i, paymentRecordListInner[i]);
            }
        }
    }

    public PageReference Save() {
        List<EFTUtil.paymentRecordsWrapper> listUnallocatedPayment = new List<EFTUtil.paymentRecordsWrapper>();
        List<Insolvency_Payment__c> listInsolvencyPayment = new List<Insolvency_Payment__c>();
        for (Integer key : wrapperMap.keySet()) {
            EFTUtil.paymentRecordsWrapper wrapRecord = wrapperMap.get(key);
            if (wrapRecord.prodLookup.Insolvency_Account__c == null) {
                listUnallocatedPayment.add(wrapRecord);
            } else {
                Insolvency_Payment__c paymentInstance = new Insolvency_Payment__c();
                paymentInstance.Created_by_EFT_Processing__c = true;
                paymentInstance.Source_File_Link__c = eftInstance.Text_URL__c;
                paymentInstance.Payment_Posting_Date__c = eftInstance.Posting_Date__c;
                if (wrapRecord.paymentSource != 'null') {
                    paymentInstance.Payment_Source__c = wrapRecord.paymentSource;
                }
                if (wrapRecord.paymentType != 'null') {
                    paymentInstance.Payment_Type__c = wrapRecord.paymentType;
                }
                paymentInstance.Cheque_Payment_Reference_Number__c = wrapRecord.chequeNumber;
                if (wrapRecord.netPayment != null && wrapRecord.netPayment != 'null') {
                    paymentInstance.Payment_Amount__c = Decimal.valueOf(wrapRecord.netPayment);
                    eftInstance.Allocated_Payments_Amount__c += paymentInstance.Payment_Amount__c;
                }
                paymentInstance.Insolvency_Account__c = wrapRecord.prodLookup.Insolvency_Account__c;
                paymentInstance.EFT_Files__c = eftInstance.Id;
                if (String.isNotBlank(eftConfigInstance.Insolvency_Payment_Record_TypeID__c)) {
                    paymentInstance.RecordTypeId = eftConfigInstance.Insolvency_Payment_Record_TypeID__c;
                }
                listInsolvencyPayment.add(paymentInstance);
            }
        }
        try {
            insert listInsolvencyPayment;
            eftInstance.Allocated_Payments_Count__c += listInsolvencyPayment.size();
            update eftInstance;
        } catch (Exception ex) {
            system.debug('Exception ex: ' + ex);
        }
        InsertUnallocatedPaymentsBatch instance = new InsertUnallocatedPaymentsBatch(listUnallocatedPayment, eftInstance, 'Insolvency');
        database.executeBatch(instance);
        //disableSave = true;
        showTable = false;
        Apexpages.addMessage(
            new ApexPages.message(Apexpages.Severity.INFO, 'Your file is being processed. You will receive email once processing is completed.')
        );
        return null;
    }

    public pageReference Cancel() {
        PageReference retURL = new PageReference('/apex/InsolvencyPaymentUpload?id=' + eftInstance.Id);
        retURL.setRedirect(true);
        return retURL;
    }
}
