/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class will be the utility methods and wrapper classes for the EFT payment processing
 *  @author : A5E Consulting
 *  @date : 19th August 2020
 *
 *************************************************************************************************/
public class EFTUtil {
    //Wrapper class for insolvency payment records
    public class paymentRecordsWrapper {
        public String accountNumber { get; set; }
        public String accountID { get; set; }
        //public String netPayment{get;set;}
        public String netPayment { get; set; }
        public String fairsharePayment { get; set; }
        public String postingDate { get; set; }
        public String shortURL { get; set; }
        public String paymentSource { get; set; }
        public String paymentType { get; set; }
        public String chequeNumber { get; set; }
        public String debtorName { get; set; }
        public String estateNumber { get; set; }
        public EFT_Files__c prodLookup { get; set; }
    }

    public String documentName { get; set; }
    public boolean readSuccess { get; set; }
    public List<String> listFieldNames { get; set; }
    paymentRecordsWrapper payWrapRecord;

    String fieldValue;
    Integer fieldNumber;
    Map<String, Integer> fieldNumberMap = new Map<String, Integer>();

    public List<paymentRecordsWrapper> deSerializeJSON(String dataAsString) {
        List<paymentRecordsWrapper> listPaymentRecordWrapper = (List<paymentRecordsWrapper>) JSON.deserialize(dataAsString, List<paymentRecordsWrapper>.class);
        return listPaymentRecordWrapper;
    }

    public List<List<paymentRecordsWrapper>> readFromFile(String dataAsString) {
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        listFieldNames = new List<String>();
        readSuccess = false;
        try {
            listWrapper = readCSVFile(DataAsString);
            return listWrapper;
        } catch (exception e) {
            readSuccess = false;
            system.debug('exception in reading file: ' + e);
        }
        return null;
    }

    public List<List<paymentRecordsWrapper>> readCSVFile(String dataAsString) {
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        List<paymentRecordsWrapper> listWrapperTemp = new List<paymentRecordsWrapper>();
        String[] dataLines = new List<String>{};
        listFieldNames = new List<String>();
        Utility_RowIterator rowIterator = new Utility_RowIterator(dataAsString);
        Iterator<String> iterator = rowIterator.iterator();
        while (iterator.hasNext()) {
            dataLines.add(iterator.next());
        }
        String[] csvFieldNames = dataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            listFieldNames.add(csvFieldNames[i].trim());
        }
        for (Integer i = 1; i < dataLines.size(); i++) {
            payWrapRecord = new paymentRecordsWrapper();
            String[] csvRecordData = dataLines[i].split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
            for (String fieldName : csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber];
                assignToWrapper(payWrapRecord, fieldValue, fieldName);
            }
            if (listWrapperTemp.size() < 40) {
                payWrapRecord.prodLookup = new EFT_Files__c();
                listWrapperTemp.add(payWrapRecord);
            } else {
                payWrapRecord.prodLookup = new EFT_Files__c();
                listWrapperTemp.add(payWrapRecord);
                listWrapper.add(listWrapperTemp);
                listWrapperTemp = new List<paymentRecordsWrapper>();
            }
        }
        if (listWrapperTemp.size() > 0) {
            listWrapper.add(listWrapperTemp);
        }
        if (listWrapper.size() > 0) {
            readSuccess = true;
        }
        return listWrapper;
    }

    public paymentRecordsWrapper assignToWrapper(paymentRecordsWrapper prdWrp, String fieldValue, String fieldName) {
        if (fieldName == 'accountID') {
            system.assertEquals(true, fieldName.trim() == 'accountID');
        }
        if (fieldName.trim() == 'accountNumber') {
            prdWrp.accountNumber = fieldValue.trim();
        }
        if (fieldName.trim() == 'accountID') {
            prdWrp.accountID = fieldValue.trim();
        }
        if (fieldName.trim() == 'netPayment') {
            prdWrp.netPayment = fieldValue.trim();
        }
        if (fieldName.trim() == 'fairsharePayment') {
            prdWrp.fairsharePayment = fieldValue.trim();
        }
        if (fieldName.trim() == 'postingDate') {
            prdWrp.postingDate = fieldValue.trim();
        }
        if (fieldName.trim() == 'shortURL') {
            prdWrp.shortURL = fieldValue.trim();
        }
        if (fieldName.trim() == 'paymentSource') {
            prdWrp.paymentSource = fieldValue.trim();
        }
        if (fieldName.trim() == 'paymentType') {
            prdWrp.paymentType = fieldValue.trim();
        }
        if (fieldName.trim() == 'chequeNumber') {
            prdWrp.chequeNumber = fieldValue.trim();
        }
        if (fieldName.trim() == 'estateNumber') {
            prdWrp.estateNumber = fieldValue.trim();
        }
        if (fieldName.trim() == 'debtorName') {
            prdWrp.debtorName = fieldValue.trim().remove('"');
        }
        return prdWrp;
    }
}
