/**************************************************************************************************
*
*  Class:       
*
*  @description : This class will be the utility methods and wrapper classes for the EFT payment processing
*  @author : A5E Consulting
*  @date : 19th August 2020
*
*************************************************************************************************/
public class EFTUtil{
    
    //Wrapper class for insolvency payment records
    public class paymentRecordsWrapper{
        public String accountNumber{get;set;}
        public String accountID{get;set;}
        //public String netPayment{get;set;}
        public String netPayment{get;set;}
        public String fairsharePayment{get;set;}
        public String postingDate{get;set;}
        public String shortURL{get;set;}
        public String paymentSource{get;set;}
        public String paymentType{get;set;}
        public String chequeNumber{get;set;}
        public String debtorName{get;set;}
        public String estateNumber{get;set;}
        public EFT_Files__c prodLookup {get;set;}
    }
    
    public String documentName {get;set;}
    public boolean readSuccess {get;set;}
    public List<String> listFieldNames{get;set;}
    paymentRecordsWrapper payWrapRecord;
    
    String fieldValue;
    Integer fieldNumber;
    Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
    
    public List<paymentRecordsWrapper> deSerializeJSON(String dataAsString){
        List<paymentRecordsWrapper>  listPaymentRecordWrapper = (List<paymentRecordsWrapper>)JSON.deserialize(dataAsString, List<paymentRecordsWrapper>.class);
        //PaymentWrapper listPaymentRecordWrapper = (PaymentWrapper)JSON.deserialize(dataAsString, PaymentWrapper.class);
        return listPaymentRecordWrapper;
    }
    public List<List<paymentRecordsWrapper>> readFromFile(String dataAsString){
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        listFieldNames = new List<String>();
        readSuccess = FALSE;
        
        try{
            listWrapper = readCSVFile(DataAsString);
            return listWrapper;
        }
        catch(exception e){
            readSuccess = FALSE;
            system.debug('exception in reading file: '+e);
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file');
            //ApexPages.addMessage(errorMessage);
        }
        
        return null;
    }  
      
    public List<List<paymentRecordsWrapper>> readCSVFile(String dataAsString) {
        system.debug('csv called');
        List<List<paymentRecordsWrapper>> listWrapper = new List<List<paymentRecordsWrapper>>();
        List<paymentRecordsWrapper> listWrapperTemp = new List<paymentRecordsWrapper>();
        String[] DataLines = new String[] {};
        listFieldNames = new List<String>();
        DataLines = dataAsString.split('\n');
        system.debug('DataLines[0]: '+DataLines[0]);
        string[] csvFieldNames = DataLines[0].split(',');
        for (Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            listFieldNames.add(csvFieldNames[i].trim());
        }
        //system.debug('fieldNumberMap: '+fieldNumberMap);
        //system.debug('listFieldNames: '+listFieldNames);
        //system.debug('csvFieldNames: '+csvFieldNames);
        system.debug('DataLines.size(): '+DataLines.size());
        for (Integer i = 1; i < DataLines.size(); i++) {
            payWrapRecord = new paymentRecordsWrapper();
            string[] csvRecordData = DataLines[i].split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
            //system.debug('csvRecordData: '+csvRecordData);
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber];
                
                assignToWrapper(payWrapRecord, fieldValue, fieldName);
            }
            if(listWrapperTemp.size() < 40){
                payWrapRecord.prodLookup = new EFT_Files__c();
                listWrapperTemp.add(payWrapRecord);
                //system.debug('payWrapRecord: '+payWrapRecord);
            }else{
                system.debug('integer i in wrapper filling:'+i);
                payWrapRecord.prodLookup = new EFT_Files__c();
                listWrapperTemp.add(payWrapRecord);
                listWrapper.add(listWrapperTemp);
                system.debug('listWrapperTemp: '+listWrapperTemp.size());
                listWrapperTemp = new List<paymentRecordsWrapper>();
            }
            //system.debug('DataLines[586]: '+DataLines[586]);
        	//system.debug('DataLines[1]: '+DataLines[1]);
        }
        system.debug('listWrapperTemp size last : '+listWrapperTemp.size());
        if(listWrapperTemp.size() > 0){
            listWrapper.add(listWrapperTemp);
        }
        system.debug('');
        if(listWrapper.size() > 0){
            readSuccess = TRUE;
        }  
        
        return listWrapper;          
    }
    
    public paymentRecordsWrapper assignToWrapper(paymentRecordsWrapper prdWrp, String fieldValue, String fieldName){
        if(fieldName == 'accountID'){
        	system.assertEquals(true, fieldName.trim() == 'accountID');    
        }
        
        if(fieldName.trim() == 'accountNumber'){
            prdWrp.accountNumber = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'accountID'){
            prdWrp.accountID = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'netPayment'){
            prdWrp.netPayment = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'fairsharePayment'){
            prdWrp.fairsharePayment = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'postingDate'){
            prdWrp.postingDate = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'shortURL'){
            prdWrp.shortURL = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'paymentSource'){
            prdWrp.paymentSource = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'paymentType'){
            prdWrp.paymentType = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'chequeNumber'){
            prdWrp.chequeNumber = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'estateNumber'){
            prdWrp.estateNumber = fieldValue.trim();
        }
        
        if(fieldName.trim() == 'debtorName'){
            prdWrp.debtorName = fieldValue.trim().remove('"');
        }
        return prdWrp;
    }
}