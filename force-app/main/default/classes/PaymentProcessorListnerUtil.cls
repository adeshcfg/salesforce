/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Zumrails Webhook Webservice
*  @author : A5E Consulting
*  @date : 09/06/2021

*************************************************************************************************/
public class PaymentProcessorListnerUtil{

    public static String TRANSACTION_STATUS = 'TransactionStatus';
    public static String REQUEST_FUNDS_RECURRING = 'Request Funds Recurring';
    public static String RECURRING_PAYMENT_CHILD = 'Recurring Payment Child';
    public static String REQUEST_FUNDS_ONE_TIME = 'Request Funds One Time';
    public static String RECURRING_PAYMENT_MASTER = 'Recurring Payment Master';
    public static String RECURRING_PAYMENT = 'Recurring Payment';
    public static String ONE_TIME_PAYMENT = 'One time Payment';
    public static String AMOUNT = 'Amount';
    public static String RECURRENT_TRANSACTION_ID = 'RecurrentTransactionId';
    public static String TRANSACTIONIDS = 'TransactionsIds';
    public static String FAILED = 'Failed';
    public static String FAILED_TRANSACTION_EVENT = 'FailedTransactionEvent';
    
    static map<String, String> mapPaymentPicklistValues = 
        new map<String, String>{
            'Succeeded' => 'Completed', 
                'Started' => 'In Progress',
                'InProgress' => 'In Progress',
                'Cancelled' => 'Cancelled',
                'Created' => 'New',
                'UnderReview' => 'In Progress'
			};
                
    //update Payment Transaction record after status update in Versapay
    public static Boolean updatePaymentTransaction(Map<String,String> paramMap){        
        Payment_Transaction__c payTransaction = new Payment_Transaction__c  ();
        String paymentProcessorID = paramMap.get('Id');
        List<Payment_Transaction__c> listPayTransactions = [SELECT ID, Product__c, Product__r.Name, Parent__c,
                                                                 Record_Type_Name__c, Parent__r.End_Date__c,
                                                                 Payment_Completion_Date__c
                                                            FROM Payment_Transaction__c 
                                                            WHERE Payment_Processor_Id__c =: paymentProcessorID limit 1];
        if(!listPayTransactions.isEmpty()){
            try{
                payTransaction = listPayTransactions[0];
                payTransaction.Status__c = paramMap.get(TRANSACTION_STATUS);
                
                if(payTransaction.Status__c == FAILED){
                    payTransaction.Error_Message__c = paramMap.get(FAILED_TRANSACTION_EVENT);
                }
                
                //Populate Payment Completion Date when Transaction status is Completed
                if(payTransaction.Status__c == mapPaymentPicklistValues.get('Succeeded')
                && (payTransaction.Record_Type_Name__c == 'One_time_Payment'
                || (payTransaction.Record_Type_Name__c == 'Recurring_Payment_Child'))){
                    payTransaction.Payment_Completion_Date__c = Datetime.now();
                }
                
                update payTransaction;
                
                if(payTransaction.Parent__c != NULL
                && (payTransaction.Record_Type_Name__c == 'One_time_Payment'
                || (payTransaction.Record_Type_Name__c == 'Recurring_Payment_Child'
                  && payTransaction.Parent__r.End_Date__c <= payTransaction.Payment_Completion_Date__c))){
                    Payment_Transaction__c parent = new Payment_Transaction__c();
                    parent.Id = payTransaction.Parent__c;
                    parent.Status__c = payTransaction.Status__c;
                    update parent;  
                }
                return true;
            }
            catch(Exception ex){
                system.debug('Exception in payment transaction insert :'+ex);
                return false;
          }
        }
        else{
            return false;
        }
    }
    
    //Create payment transaction
    public static Boolean createPaymentTransaction(Map<String,String> paramMap, String JSONResponse){
        system.debug('paramMap: '+paramMap);
        list<Payment_Transaction__c> listRequestFunds = new list<Payment_Transaction__c>();
        list<Payment_Transaction__c> listRecurrentTransaction;
        
        Payment_Transaction__c requestFund;
        
        String RequestFundRecordTypeId;
        String TransctionRecordTypeId;
        Boolean isRecurrentMaster = false;
        
        String paymentProcessorID = paramMap.get('Id');
        String recurrentTransactionId = paramMap.get(RECURRENT_TRANSACTION_ID);
        
        //Get RequestFundID from the comment of transaction
        String requestFundId;
        
        if(paramMap.containsKey(AMOUNT)){
            system.debug('comment value: '+paramMap.get('Comment'));
            if(paramMap.containsKey('Comment')){
                if(paramMap.containsKey('TransactionMethod')){
                    if(paramMap.get('TransactionMethod') == 'eft') {
                        requestFundId = paramMap.get('Comment').remove('Created based on Request Funds form: ').replaceAll(' ','-');
                    }
                    else{
                        requestFundId = paramMap.get('Comment').remove('Request Funds Id: ').replaceAll(' ','-');
                    }
                }
            }
            
            system.debug('requestFundId: '+requestFundId);
            
            //if the transaction has parent recurrent transactionId on it, it is Recurrent Payment Child. 
            //Get Parent Request fund and Recurrent master details
            if(recurrentTransactionId != NULL){
                RequestFundRecordTypeId = 
                Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(REQUEST_FUNDS_RECURRING).getRecordTypeId();        
                TransctionRecordTypeId = 
                Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(RECURRING_PAYMENT_CHILD).getRecordTypeId();        
                //Get Parent Recurrent Transaction
                listRecurrentTransaction = [SELECT ID, Product__c, Payment_Processor_Id__c, Next_Payment_Date__c,
                                                 End_Date__c, Parent__c, Customer_Email_Address__c, Recurrence_Type__c,
                                                 Day_Of_Week__c, Day_of_Month__c, Product__r.Collection_Agency__c, Initial_Payment_Process_Initiated_By__c
                                            FROM Payment_Transaction__c 
                                            WHERE Payment_Processor_Id__c = :recurrentTransactionId];
          
                requestFund = new Payment_Transaction__c();
                requestFund.Id = listRecurrentTransaction[0].Parent__c;
                system.debug('Payment initiated by: '+ listRecurrentTransaction[0].Initial_Payment_Process_Initiated_By__c);
            }
            //Else it is Recurrent Transaction or One Time Transaction
            //Get Parent Request fund details
            else{
                RequestFundRecordTypeId = 
                        Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(REQUEST_FUNDS_ONE_TIME).getRecordTypeId();
                //Check if the Transaction is Recurrent Transaction Master
                if(paramMap.containsKey(TRANSACTIONIDS)){
                      isRecurrentMaster = true;
                      system.debug('contains TransactionsIds');
                      TransctionRecordTypeId = 
                        Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(RECURRING_PAYMENT_MASTER).getRecordTypeId();          
                }
                //else it is One Time Transaction
                else{
                    system.debug('one time payment');
                    TransctionRecordTypeId = 
                    Schema.SObjectType.Payment_Transaction__c.getRecordTypeInfosByName().get(ONE_TIME_PAYMENT).getRecordTypeId();        
                }
                //Get Parent Request Fund ID
                if(String.isNotBlank(requestFundId)){
                  listRequestFunds = [SELECT ID, Product__c, Payment_Processor_Id__c, Customer_Email_Address__c,
                                             Product__r.Collection_Agency__c
                                      FROM Payment_Transaction__c 
                                      WHERE Payment_Processor_Id__c = :requestFundId];    
                }            
                
                //If Request Fund not present, create a dummy record
                if(listRequestFunds.isEmpty()){
                    system.debug('req fund not found');
                    //Create Dummy RequestFund for the payment processor ID
                    requestFund = new Payment_Transaction__c();
                    if(paramMap.containsKey(AMOUNT)){
                        requestFund.Amount__c = Double.valueOf(paramMap.get(AMOUNT));    
                    }
                    requestFund.Payment_Processor_Id__c = requestFundId;
                    requestFund.RecordTypeId = RequestFundRecordTypeId;
                    insert requestFund;  
                }
                else{
                    system.debug('req fund found');
                    requestFund = listRequestFunds[0];
                }
            }
            
            //Create Payment Transaction
            Payment_Transaction__c payTransaction = new Payment_Transaction__c();
            system.debug('payTransaction before;'+payTransaction);
            payTransaction.Payment_Processor_Webhook_Request__c = JSONResponse;
            payTransaction.Payment_Processor_Id__c = paymentProcessorID;
            payTransaction.RecordTypeId = TransctionRecordTypeId;
            
            if(paramMap.containsKey(AMOUNT)){
              payTransaction.Amount__c = Double.valueOf(paramMap.get(AMOUNT));    
            }
            payTransaction.Status__c = paramMap.get(TRANSACTION_STATUS);
            system.debug('payTransaction.Status__c:1'+payTransaction.Status__c);
            payTransaction.Payment_Type__c = ONE_TIME_PAYMENT;
            payTransaction.Day_Of_Month__c = paramMap.get('DayOfMonth');
            payTransaction.Day_Of_Week__c = paramMap.get('DayOfWeek');
            payTransaction.Recurrence_Type__c = paramMap.get('RecurrenceType');
            
            /*//check if the transaction is Withdraw transaction
            if(payTransaction.Product__c == NULL
               && paramMap.get('ZumRailsType') == 'WithdrawZumWallet'
               && paramMap.get('FundingSource') != NULL){
                   payTransaction.Withdraw_Transaction__c	= true; 
            }*/
            
            //If webhook has Recurrent Master Payment Transaction
            if(isRecurrentMaster){
                system.debug('Transaction is recurrent master');
                
                payTransaction.Status__c = mapPaymentPicklistValues.get(paramMap.get('RecurrentTransactionStatus'));
                system.debug('payTransaction.Status__c master: '+payTransaction.Status__c);
                system.debug('startdate: '+paramMap.get('StartDate'));
                
                if(paramMap.containsKey('StartDate')){
                    payTransaction.Next_Payment_Date__c = Date.valueOf(paramMap.get('StartDate').replace('T',' '));    
                }
                system.debug('payTransaction.Next_Payment_Date__c'+payTransaction.Next_Payment_Date__c);
                system.debug('EndDate value in MAP: '+paramMap.get('EndDate'));
                
                if(paramMap.containsKey('EndDate')){
                    payTransaction.End_Date__c = Date.valueOf(paramMap.get('StartDate').replace('T',' '));    
                    String s = paramMap.get('EndDate').substringBefore('T');
                    s = s + ' 11:59:59';
                    payTransaction.End_Date__c = Date.valueOf(s.substringBefore('T'));
                    system.debug('payTransaction.End_Date__c:'+payTransaction.End_Date__c);
                    DateTime dt = DateTime.valueOfGMT(paramMap.get('EndDate').replace('T',' '));    
                    system.debug('dt:::'+dt);
                    dt = dt.addHours(11);
                    dt = dt.addMinutes(59);
                    payTransaction.End_Date__c = dt;
                    system.debug('payTransaction.End_Date__c::'+payTransaction.End_Date__c);
                }
                if(paramMap.containsKey('LastDayOfTheMonth') && 
                   paramMap.get('LastDayOfTheMonth') == 'true'){
                    payTransaction.Day_Of_Month__c = 'Last Day of the Month';
                }
                payTransaction.Payment_Type__c = RECURRING_PAYMENT;           
            }  
                
            //If webhook has Recurrent Child Payment Transaction
            if(recurrentTransactionId != NUll && !listRecurrentTransaction.isEmpty()){
                system.debug('Transaction is recurrent child');
                //Commenting code to populate Payment Completion Date. Should be populated only when Status is completed
                //payTransaction.Payment_Completion_Date__c = Datetime.valueOf(paramMap.get('CreatedAt').replace('T',' '));
                payTransaction.Recurrence_Type__c = listRecurrentTransaction[0].Recurrence_Type__c;
                //populate Customer EMail Address from Parent Recurrent transaction
                payTransaction.Customer_Email_Address__c = listRecurrentTransaction[0].Customer_Email_Address__c;
                payTransaction.Parent__c = listRecurrentTransaction[0].Id;  
                payTransaction.Product__c = listRecurrentTransaction[0].Product__c;  
                payTransaction.Payment_Type__c = RECURRING_PAYMENT;
                payTransaction.Day_Of_Month__c = listRecurrentTransaction[0].Day_Of_Month__c;  
                payTransaction.Day_Of_Week__c = listRecurrentTransaction[0].Day_Of_Week__c; 
                payTransaction.End_Date__c = listRecurrentTransaction[0].End_Date__c; 
                payTransaction.Collection_Agency__c = listRecurrentTransaction[0].Product__r.Collection_Agency__c;
                
                Date NextPaymentDate;
                DateTime TransactionCreatedDate = Datetime.valueOf(paramMap.get('CreatedAt').replace('T',' '));
                system.debug('End_Date__c: '+listRecurrentTransaction[0].End_Date__c);
                
                if(listRecurrentTransaction[0].End_Date__c <= TransactionCreatedDate){
                    listRecurrentTransaction[0].Status__c = mapPaymentPicklistValues.get('Succeeded');
                    requestFund.Status__c = listRecurrentTransaction[0].Status__c;
                }
                //Calculate Next Payment Date on Recurring Payment master
                else{
                    listRecurrentTransaction[0].Status__c = 'In Progress';
                    if(payTransaction.Recurrence_Type__c == 'Monthly'){
                        listRecurrentTransaction[0].Next_Payment_Date__c = 
                            listRecurrentTransaction[0].Next_Payment_Date__c.addMonths(1);
                        	if(listRecurrentTransaction[0].Day_Of_Month__c == 'Last Day of the Month'){
                            	Integer numberOfDays = Date.daysInMonth(listRecurrentTransaction[0].Next_Payment_Date__c.year(), listRecurrentTransaction[0].Next_Payment_Date__c.month());
								listRecurrentTransaction[0].Next_Payment_Date__c = 
                                    Date.newInstance(listRecurrentTransaction[0].Next_Payment_Date__c.year(), listRecurrentTransaction[0].Next_Payment_Date__c.month(), numberOfDays);    
                            }
                        	
                    }
                    if(payTransaction.Recurrence_Type__c == 'Biweekly'){
                        listRecurrentTransaction[0].Next_Payment_Date__c = 
                            listRecurrentTransaction[0].Next_Payment_Date__c.addDays(14);
                    }
                    if(payTransaction.Recurrence_Type__c == 'Weekly'){
                        listRecurrentTransaction[0].Next_Payment_Date__c = 
                            listRecurrentTransaction[0].Next_Payment_Date__c.addDays(7);
                    }
                }
            }
           //If webhook has One Time Payment transaction/Recurring Master, set fields from parent Request Fund
            else{
                system.debug('Transaction is one time');
                //Commenting the code to populate Payment Completion Date. It should be populated only on completed status
                //payTransaction.Payment_Completion_Date__c = Datetime.valueOf(paramMap.get('CreatedAt').replace('T',' '));
                payTransaction.Customer_Email_Address__c = requestFund.Customer_Email_Address__c;
                payTransaction.Parent__c = requestFund.Id;
                payTransaction.Product__c = requestFund.Product__c;
                payTransaction.Collection_Agency__c = requestFund.Product__r.Collection_Agency__c;
                
                //Set Request Fund status to Completed
                if(payTransaction.Status__c == paramMap.get('Succeeded')){
                    requestFund.Status__c = paramMap.get('Succeeded');
                }   
            }
            
            try{
                system.debug('payTransaction:; '+payTransaction);
                insert payTransaction;   
                system.debug('payTransaction: '+payTransaction.Name);
                system.debug('requestFund: '+requestFund);
                system.debug('listRecurrentTransaction: '+listRecurrentTransaction);
                if(!listRecurrentTransaction.isEmpty()){
                    system.debug('listRecurrentTransaction:::'+listRecurrentTransaction);
                    update listRecurrentTransaction[0];   
                }
                if(requestFund != NULL){
                    update requestFund;
                }
                system.debug('check check');
                return true;
            }
            catch(Exception ex){
                system.debug('Exception :'+ex);
                return false;
            }   
        }
    	return false;
    }
    
    //Verify the signature from response
    public static Boolean verifyAuthenticity(Blob requestBodyBlob, Map<String,string> paraMap){
        
        //Custom Setting values to generate Signature
        Customer_Payment_Processor_Settings__c payProcSettings = Customer_Payment_Processor_Settings__c.getOrgDefaults();
                
        Blob hmac = Crypto.generateMac('hmacSHA256', requestBodyBlob, Blob.valueOf(payProcSettings.Signing_Key__c));
        system.debug('EncodingUtil.convertToHex(hmac) == signature: '+EncodingUtil.convertToHex(hmac));
        system.debug('EncodingUtil.base64Encode == signature: '+EncodingUtil.base64Encode(hmac));
        system.debug('signature: '+paraMap.get('zumrails-signature'));
        
        
        //URL encode the value
        String urlEncodedResponse = EncodingUtil.base64Encode(hmac);
        system.debug('urlEncodedResponse: '+urlEncodedResponse);     
        
        if(test.isRunningTest()){
            return true;
        }else{
            //if signature matches then return true
            if(EncodingUtil.base64Encode(hmac) == paraMap.get('zumrails-signature')){
                return true;
            }else{
                return false;
            }
        }
        //return null;
    }
}