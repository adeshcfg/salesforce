/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller for PaymentTransactionCSV
*  @author : A5E Consulting
*  @date : 09/07/2021

*************************************************************************************************/
public class PaymentTransactionCSVController {
    private static final String TRANSACTION_STATUS = 'Completed';
    private static final String ONE_TIME_PAYMENT =  'One_time_Payment';
    private static final String RECURRENT_PAYMENT_CHILD =  'Recurring_Payment_Child';
    
    public boolean disableButton {get;set;}
    public PaymentTransactionCSVController(ApexPages.StandardController controller){
        //Check if Product is present on transaction to exclude Withdra Transactions
         List<Payment_Transaction__c> listPaymentTransaction = [SELECT Id
                                  								FROM Payment_Transaction__c 
                                  								WHERE CSV_Export_Completed__c = false
                                                                AND Status__c = 'Completed'
                                                                AND (Record_Type_Name__c = :ONE_TIME_PAYMENT
                  												OR Record_Type_Name__c = :RECURRENT_PAYMENT_CHILD)
                                                                AND Product__c != NULL
                                                                LIMIT 1];
        if(!listPaymentTransaction.isEmpty()){
            disableButton = false;
        }
        else{
            disableButton = true;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'All Payment Transactions are exported !'));
        }
        
    }
    
    public list<Payment_Transaction__c> getPaymentTransactions(){
        return [SELECT ID, Name, Amount__c, Parent__c, Status__c, CreatedDate, Payment_type__c
                FROM Payment_Transaction__c 
                WHERE CSV_Export_Completed__c = false
                AND Status__c = 'Completed'
                AND (Record_Type_Name__c = 'One_time_Payment'
                  OR Record_Type_Name__c = 'Recurring_payment_Child')
               ORDER BY CreatedDate DESC];
    }
    
    public list<Payment_Transaction_CSV__c> getPaymentTransactionsCSV(){
        return [SELECT ID, Name, CreatedDate, CreatedBy.Name
                FROM Payment_Transaction_CSV__c 
                ORDER BY CreatedDate DESC
                LIMIT 50000];
    }
    public void generateCSV(){
        if(PaymentTransactionCSVUtil.createPaymentCSV()){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Payment Transaction CSV Created!'));
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Payment Transaction CSV Creation Failed!'));
        }
        
        
        //return new PageReference('/Generate_Transaction_CSV');
        
    }    
}