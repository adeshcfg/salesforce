/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is for Request Fund functionality
*  @author : A5E Consulting
*  @date : 14 July 2021  
*
*************************************************************************************************/
    public class RequestPaymentController {
    
    public Payment_Transaction__C transctRecord{get;set;}
    
    @AuraEnabled
    public static Product__C getproduct(String recordId){
        
        Product__c prodRecord = [select id, name, Customer__r.PersonEmail, Customer__r.Secondary_Email__pc, 
                                 Current_Balance__c, Collection_Agency__c, Portfolio_Name_Lookup__r.Name, 
                                 Purchase_ID_Formula__c, Placement_Status__c 
                                 from Product__c
                                 where id =: recordId];
        
        List<Payment_Transaction__C> listPayment = [select id, name, status__c, Amount__c 
                                                    from Payment_Transaction__c 
                                                    where ((Record_type_name__c = 'One_time_Payment' and Status__c = 'In Progress')
                                                    OR (Record_type_name__c = 'Recurring_Payment_Master' and (Status__c = 'In Progress' OR Status__c = 'New')))
                                                    and product__c =: recordId];
        
        Decimal effectiveBalance = prodRecord.Current_Balance__c;
        if(listPayment.size() > 0){
            for(Payment_Transaction__C pay : listPayment){
                effectiveBalance -= pay.Amount__c;
            }
        }
        prodRecord.Effective_Current_Balance__c = effectiveBalance;
        
        return prodRecord;
    }
    
    @AuraEnabled
    public static String eligibleProduct(String recordId){
    
        Product__c prodRecord = [select id, name, Customer__r.PersonEmail, Customer__r.Secondary_Email__pc, 
        Purchase_ID_Formula__c, Portfolio_Name_Lookup__r.Name, 
                                 		Collection_Agency__c, Current_Balance__c, Placement_Status__c  
                                from Product__c 
                                where id =: recordId];
        
        List<Payment_Transaction__C> listPayment = [select id, name, status__c, Amount__c 
                                                    from Payment_Transaction__c 
                                                    where 
                                                    ((Record_type_name__c = 'One_time_Payment' and Status__c = 'In Progress')
                                                     OR (Record_type_name__c = 'Recurring_payment_Master' and Status__c = 'In Progress'))
                                                    and product__c =: recordId];
        
        Decimal effectiveBalance = prodRecord.Current_Balance__c;
        if(listPayment.size() > 0){
            for(Payment_Transaction__C pay : listPayment){
                effectiveBalance -= pay.Amount__c;
            }
        }
        prodRecord.Effective_Current_Balance__c = effectiveBalance;
        
        Customer_Portal_Setting__c setting = Customer_Portal_Setting__c.getOrgDefaults();
        
        /*Set<Decimal> setPlacementsToInclude = new Set<Decimal>();
        for(Placement__c placement : [SELECT Name 
                                      FROM Placement__c 
                                      WHERE Include_In_Portal_Search__c = True]){
            setPlacementsToInclude.add(decimal.valueOf(placement.Name));                                              
        }*/
        
        list<String> listPlacementToInclude = String.isNotBlank(setting.Eligible_Placement_ID__c) ? 
                setting.Eligible_Placement_ID__c.split(',') : new list<String>{};
                    
        list<String> listPurchaseGroupToExclude = String.isNotBlank(setting.Exclude_Account_Purchase_Group__c) ? 
                setting.Exclude_Account_Purchase_Group__c.split(',') : new list<String>{};
            
        //get the Portfolio Names to exclude from Portal Search
        list<String> listPortfolioNameToExclude = String.isNotBlank(setting.Exclude_Portfolio_Name__c) ? 
                setting.Exclude_Portfolio_Name__c.split(',') : new list<String>{};
        
        String msg = '';
        if(!listPlacementToInclude.contains(String.valueOf(prodRecord.Collection_Agency__c)) 
            || (prodRecord.Purchase_ID_Formula__c != NULL 
              && listPurchaseGroupToExclude.contains(String.valueOf(prodRecord.Purchase_ID_Formula__c)))
            || ((prodRecord.Portfolio_Name_Lookup__r.Name != NULL 
              && listPortfolioNameToExclude.contains(String.valueOf(prodRecord.Portfolio_Name_Lookup__r.Name)))
            /*|| (prodRecord.Portfolio_Name_Lookup__r.Name != NULL 
              && listPortfolioNameToExclude.contains(String.valueOf(prodRecord.Portfolio_Name_Lookup__r.Name)))*/   
               )
            ){
            msg += 'Product record is not eligible for payment setup</br>';
            msg += 'Because Collection Agency is '+ (prodRecord.Collection_Agency__c == null? 'blank' : (String.valueOf(prodRecord.Collection_Agency__c))) + '<br/>';
            msg += 'Portfolio is ' + (prodRecord.Portfolio_Name_Lookup__r.Name == null ? 'blank': prodRecord.Portfolio_Name_Lookup__r.Name) + '<br/>';
            msg += 'Portfolio Group Name is '+ (prodRecord.Purchase_ID_Formula__c == null? 'blank': String.valueOf(prodRecord.Purchase_ID_Formula__c)) + '<br/>';
        }
        
        if(String.isBlank(prodRecord.Customer__r.PersonEmail) && String.isBlank(prodRecord.Customer__r.Secondary_Email__pc)){
            msg += '<br/>Email address is required';
        }
        
        if(null == prodRecord.Current_Balance__c || prodRecord.Current_Balance__c <= 0){
        	msg += '<br/>Current Balance is less than or equal to 0';
        }
        if(prodRecord.Placement_Status__c != NULL && prodRecord.Placement_Status__c.startsWith('2')){
        	msg += '<br/>Product has Invalid Placement Status';
        }
        
        if(msg == ''){
        	return 'None';    
        }
        
        return msg;
    }
    
    @AuraEnabled
    public static Boolean saveTransaction(String productrecordId, String transactionType, String recurranceType, Decimal paymentAmount, String dayOfWeek, String dayOfMonth, Date endDate, String NumberOfPayments, String emailAddress){
        system.debug('transactionType:'+transactionType);
        system.debug('recurranceType:'+recurranceType);
        system.debug('dayOfWeek:'+dayOfWeek);
        system.debug('dayOfMonth:'+dayOfMonth);
        system.debug('endDate:'+endDate);
        system.debug('NumberOfPayments:'+NumberOfPayments);
        Boolean paymentSuccessful = true;
        Payment_Transaction__C transactionRecord = new Payment_Transaction__C();
        
        transactionRecord.Product__c = ProductrecordId;
        transactionRecord.Payment_Type__c = transactionType;
        system.debug('transaction Type' + transactionType);
        Product__c prodRecord = [select id, Collection_Agency__c from Product__c where id =: ProductrecordId LIMIT 1][0];
        if(transactionType == 'Recurring Payment'){
            transactionRecord.RecordTypeId = Schema.SObjectType.Payment_Transaction__C.getRecordTypeInfosByName().get('Request Funds Recurring').getRecordTypeId();
        }else{
            transactionRecord.RecordTypeId = Schema.SObjectType.Payment_Transaction__C.getRecordTypeInfosByName().get('Request Funds One Time').getRecordTypeId();
        }
        transactionRecord.Amount__c = paymentAmount;
        transactionRecord.Recurrence_Type__c = recurranceType;
        transactionRecord.Day_Of_Month__c = dayOfMonth;
        transactionRecord.Day_Of_Week__c = dayOfWeek;
        transactionRecord.End_Date__c = (DateTime)endDate;
        transactionRecord.Payment_Initiated_By__c = 'Internal User';
        transactionRecord.Number_of_Payments__c = NumberOfPayments;
        transactionRecord.Customer_Email_Address__c = emailAddress;
        transactionRecord.Collection_Agency__c = prodRecord.Collection_Agency__c;
            
        try{
            insert transactionRecord;
            if(!Test.isRunningTest()){
            	PaymentTransactionCreator.postPaymentToZumrails(transactionRecord.id);    
            }
            paymentSuccessful = true;
        
        }catch(Exception e){
            paymentSuccessful = false;
        }
        
        return paymentSuccessful;
    }
    
}