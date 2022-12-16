/**************************************************************************************************
 *
 *  Class:   Batch clas to update Merchant Account fields
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 11/03/2021
 
 *************************************************************************************************/
global class MerchantAccountUpdatesBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Boolean todayHoliday = false;
        system.debug('Today : '+Date.today());
        system.debug('holiday: '+[Select h.Name, h.ActivityDate,h.IsRecurrence, h.RecurrenceDayOfMonth, 
                               h.RecurrenceMonthOfYear From Holiday h]);
        for(Holiday holiday :[Select h.Name, h.ActivityDate,h.IsRecurrence, h.RecurrenceDayOfMonth, 
                               h.RecurrenceMonthOfYear From Holiday h]){
            if((holiday.IsRecurrence == true 
                && holiday.ActivityDate.Day() == Date.today().Day() 
                && holiday.ActivityDate.Month() == Date.today().Month())
            || (holiday.IsRecurrence == false && holiday.ActivityDate == Date.today())){
                todayHoliday = true;
            }            
        }
        system.debug('todayHoliday: '+todayHoliday);
        if(todayHoliday == false){
            // collect the batches of records or objects to be passed to execute
            return Database.getQueryLocator(
            'SELECT ID, Days_Delinquent__c, Max_Days_Delinquent__c FROM Merchant_Account__c'
            );   
        }
        else{
            return null;                           
        }
    }
    
    global void execute(Database.BatchableContext bc, List<Merchant_Account__c> listMerchantAccounts){ 
        list<Merchant_Account__c> listMerchantAccountsToUpdate = new list<Merchant_Account__c>();
        system.debug('listMerchantAccounts: '+listMerchantAccounts);
        for(Merchant_Account__c merchantAccount : listMerchantAccounts){
            //Update Max Dats Delinquent
            if(merchantAccount.Days_Delinquent__c > merchantAccount.Max_Days_Delinquent__c){
                merchantAccount.Max_Days_Delinquent__c = merchantAccount.Days_Delinquent__c;
                listMerchantAccountsToUpdate.add(merchantAccount);
            }
        }
        update listMerchantAccountsToUpdate;
    }
    
    global void finish(Database.BatchableContext bc){
		//Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(UserInfo.getUserId());
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Merchant Account Updates Completed';
        message.plainTextBody = 'Merchant Account Updates job execution is completed in Salesforce org. You may check the updated Merchant Accounts.';
        system.debug('message: '+message);
        if(!Test.isRunningTest()){
            Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);   
        }
    }
}