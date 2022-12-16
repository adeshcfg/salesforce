/**************************************************************************************************
*
*  Class:   
*
*  @description : Utility class for creating payment CSV file.   
*  @author : A5E Consulting
*  @date : 17/06/2021   

*************************************************************************************************/
public Class PaymentTransactionCSVUtil{
    
    private static final String TRANSACTION_STATUS = 'Completed';
    private static final String ONE_TIME_PAYMENT =  'One_time_Payment';
    private static final String RECURRENT_PAYMENT_CHILD =  'Recurring_Payment_Child';
    static List<Payment_Transaction__c> listPaymentTransaction;
    
    //fetch All Eligible Payment Transaction Records
    public static List<Payment_Transaction__c> fecthPaymentTransaction(){        
        //Check if Product is present on transaction to exclude Withdra Transactions
        listPaymentTransaction = [SELECT Id, Name, Amount__c, Payment_Processor_Id__c, CreatedDate, Portal_ID__c, 
                                         Payment_Type__c,
                                         Product__r.DebtNext_Data_ID__c, Product__r.Previous_Primary_Account_Number__c
                                  FROM Payment_Transaction__c 
                                  WHERE CSV_Export_Completed__c = false
                                  AND Status__c = :TRANSACTION_STATUS
                                  AND (Record_Type_Name__c = :ONE_TIME_PAYMENT
                                       OR Record_Type_Name__c = :RECURRENT_PAYMENT_CHILD)
                                  AND Product__c != NULL];
        System.debug('listPaymentTransaction=='+listPaymentTransaction);
        return listPaymentTransaction;                                                                   
    }
    
    //fetch All Eligible Payment Transaction Records
    public static boolean createPaymentCSV(){
        String finalPaymentCSV = 'data_id' + ','
                                + 'pay_type'+',' 
                                + 'pay_date' +','                
                                + 'pri_acctno' +','
                                + 'pay_amount' +',' 
                                + '' +''
                                + '\n'; 
        String codeValue = '';
        
        List<Payment_Transaction__c> listPaymentTransaction = fecthPaymentTransaction();
        for(Payment_Transaction__c payTransactionObj : listPaymentTransaction){         
            String paymentDate='';
            //if (payTransactionObj.Portal_ID__c != null){
                paymentDate = convertDateToString(payTransactionObj.CreatedDate);
            //}
            String payCSV = '';
            payCSV = checkComma((payTransactionObj.Product__r.DebtNext_Data_ID__c != null) ? payTransactionObj.Product__r.DebtNext_Data_ID__c : '')+',' 
                                + checkComma((payTransactionObj.Payment_Type__c == 'Payment in Full') ? '1001' : '1000')+',' 
                                + checkComma(paymentDate) +','
                                + checkComma(payTransactionObj.Product__r.Previous_Primary_Account_Number__c) +',' 
                                + checkComma(String.valueOf(payTransactionObj.Amount__c)) +','
                                + '' +''
                                + '\n'; 
            
            if(String.isNotBlank(payCSV)){
                finalPaymentCSV += payCSV;
            }              
        }
        Boolean CSVCreated = createPaymentTransactionCSVRecord(finalPaymentCSV);
        return CSVCreated;
        //return finalPaymentCSV;
    }
    
    //Create Payment Transaction CSV Record
    public static boolean createPaymentTransactionCSVRecord(String versaPayCSV){
        //Payment Trassanction CSV record
        Payment_Transaction_CSV__c payTransactionCSV = new Payment_Transaction_CSV__c();
        insert payTransactionCSV;
        
        //Payment CSV Attachment
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(versaPayCSV);
        attachment.Name = 'Payment Transaction-CSV-' + convertDateToString(system.Now()) + '.csv';
        attachment.ParentId = payTransactionCSV.Id; 
        
        try{
			insert attachment;   
            updatePayTransactionRecords();
            return true;
        }
        catch(Exception ex){
            system.debug('Exception ex : '+ex);
            return false;
        }
    }
    
    //update Payment Transaction records and return result
    public static Boolean updatePayTransactionRecords(){
        system.debug('listPaymentTransaction in update'+listPaymentTransaction);
        List<Payment_Transaction__c> listPayTransactionUpdate = New List<Payment_Transaction__c>();
        for(Payment_Transaction__c prodPay : listPaymentTransaction){
            prodPay.CSV_Export_Completed__c = true;    
            listPayTransactionUpdate.add(prodPay);
        }
        
        update listPayTransactionUpdate;
        return true;
    }
    
    //Convert Date to String
    @testvisible
    private static String convertDateToString(DateTime dt){
        if(dt != null){
            //Date dte = dt.Date();
            //return String.valueof(dte.month()+'/'+dte.day()+'/'+dte.year());
            return (dt.formatGMT('MM/dd/yyyy'));
        }
        else{
            return '';
        }
    }
    
    //if value contains comma',' , append quote in trailing and heading
    @testvisible
    private static String checkComma(String str){

        if(String.isNotBlank(str) && str.contains(',')){
                return +' \"'+str+'\" ';
        }
        else{
            return str;
        }
    }
}