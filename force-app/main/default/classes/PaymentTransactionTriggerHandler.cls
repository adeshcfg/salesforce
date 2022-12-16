/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Product_Payments__C object 
*  @author : A5E Consulting
*  @date : 05/07/2022
* 
***********************************************	**************************************************/

public class PaymentTransactionTriggerHandler {
    static String COMPLETED = 'Completed';
    static ID DistressedProductPayID;
    static  boolean stopRecurrsion = false;
    public static void handleAFterUpdate(list<Payment_Transaction__c> listPaymentTransaction, 
                                          map<ID, Payment_Transaction__c> mapOldPaymentTransactions){
		
        list<Payment_Transaction__c> listPaymentTransactionToProcess = new list<Payment_Transaction__c>();
		map<ID, Payment_Transaction__c> mapPaymentTransactions = new Map<ID, Payment_Transaction__c>();
        set<ID> setProductID = new set<ID>();
        //stopRecurrsion = false;                                      
		for(Payment_Transaction__c payTransaction : listPaymentTransaction){    
            if((payTransaction.Record_Type_Name__c == 'One_time_payment' 
            || payTransaction.Record_Type_Name__c == 'Recurring_Payment_Child')
            && String.isNotBlank(payTransaction.Status__c)
            && stopRecurrsion == false
            && (payTransaction.Status__c == COMPLETED && mapOldPaymentTransactions.get(payTransaction.ID).Status__c != COMPLETED)){
                system.debug('payTransaction here'+payTransaction);
				listPaymentTransactionToProcess.add(payTransaction);
                mapPaymentTransactions.put(payTransaction.ID, payTransaction);
                setProductID.add(payTransaction.Product__c);
                stopRecurrsion = true;
            }
        }
        //Call createProductPayments
        system.debug('listPaymentTransactionToProcess::'+listPaymentTransactionToProcess);
        createProductPayments(mapPaymentTransactions.values(), setProductID);
		
    }
    
    //handleBefore insert functionality
    public static void handleBeforeInsert(list<Payment_Transaction__c> listPaymentTransaction){
        list<Payment_Transaction__c> listPaymentTransactionToProcess = new list<Payment_Transaction__c>();
        set<ID> setProductID = new set<ID>();
        
        //map<ID, Product__c> mapProductAGency = 
		for(Payment_Transaction__c payTransaction : listPaymentTransaction){  
            system.debug('payTransaction.Record_Type_Name__c:'+payTransaction.Record_Type_Name__c);
            system.debug('payTransaction.Status__c :0'+payTransaction.Status__c );
            
            if((payTransaction.Record_Type_Name__c == 'One_time_payment' 
            || payTransaction.Record_Type_Name__c == 'Recurring_Payment_Child')
            && String.isNotBlank(payTransaction.Status__c)
            && (payTransaction.Status__c == COMPLETED)){
				system.debug('payTransaction::'+payTransaction);
                listPaymentTransactionToProcess.add(payTransaction);
                setProductID.add(payTransaction.Product__c);
            }
        }
        
        createProductPayments(listPaymentTransactionToProcess, setProductID);
    }
    
    //Create Prodct Payment records
    public static void createProductPayments(list<Payment_Transaction__c> listPaymentTransaction, set<ID> setProductID){
        list<Product_Payments__c> listProductPaymentsToInsert = new list<Product_Payments__c>();
		DistressedProductPayID =  Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId();
            
        system.debug('DistressedProductPayID::'+DistressedProductPayID);
        
		for(Payment_Transaction__c payTransaction : listPaymentTransaction){
            system.debug('payTransaction::'+payTransaction);
            Product_Payments__c productPayment = new Product_Payments__c();
            productPayment.CCS_Account__c = payTransaction.Product__c;
            productPayment.Payment_Amount__c = payTransaction.Amount__c;
            productPayment.Payment_Posting_Date__c = Date.valueOf(payTransaction.Payment_Completion_Date__c);
            productPayment.Payment_Source__c = '2';
            productPayment.Payment_Type__c = '1000';
            productPayment.Payment_Agency__c = String.valueOf(payTransaction.Collection_Agency__c);
            productPayment.Ignore_Warning__c = true;
            productPayment.RecordTypeId = DistressedProductPayID;
            system.debug('productPayment::'+productPayment);
            listProductPaymentsToInsert.add(productPayment);
        }
                                              
		//ProductPaymentsTriggerHandler.runTrigger = false;
		system.debug('listProductPaymentsToInsert::'+listProductPaymentsToInsert);
        if(!Test.isRunningTest()){
        	insert listProductPaymentsToInsert;		    
        }
		//ProductPaymentsTriggerHandler.runTrigger = true;
    }
}