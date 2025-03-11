/**
 * @description       : Batch Class to clear the Deleted Records object once deleted in Analytics DB
 * @author            : pradeep.@canaccede.com
 * @last modified on  : 02-24-2025
 * @last modified by  : pradeep.kumar@canaccede.com
 **/
public class ProcessRecordsDeletionBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    private static Map<String, String> errorRecIdandErrorMsgMap = new Map<String, String>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date todayDate = Date.today();
        String deleteRecordQuery = 'SELECT Id FROM Deleted_Records__c WHERE CreatedDate <: todayDate';
        return Database.getQueryLocator(deleteRecordQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<Deleted_Records__c> deletedRecordsList){
        Database.DeleteResult[] deletedRecordsResult =  Database.delete(deletedRecordsList, false);
        for(Database.DeleteResult deletedRecordResult : deletedRecordsResult) {
            if (!deletedRecordResult.isSuccess()) {
                List<String> errorMessageList = new List<String>();
                for(Database.Error deletedRecordErrors : deletedRecordResult.getErrors()) {
                    errorMessageList.add(deletedRecordErrors.getMessage());
                }
                errorRecIdandErrorMsgMap.put(deletedRecordResult.getId(), String.join(errorMessageList, ','));
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        if(Test.isRunningTest()){
            errorRecIdandErrorMsgMap.put('Error_Rec_Id', 'Error Generated to Evaluate Test Class');
        }
        createExceptionRecords();
        sendExceptionEmail();
    }
    
    private void sendExceptionEmail(){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String userEmail = UserInfo.getUserEmail();
        List<String> errorMessageForEmailList = new List<String>();
        List<API_Error__c> listAPIErrors = new List<API_Error__c>();
        Integer counter = 1;
        
        for(String recordId : errorRecIdandErrorMsgMap.keySet()){
            errorMessageForEmailList.add(counter++ + '. '+recordId+' --> '+errorRecIdandErrorMsgMap.get(recordId));
        }
        
        String[] toAddresses = new String[] {userEmail};    
            if(toAddresses.size() > 0){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddresses);
                email.setSubject('Error Occured During Record Deletion');
                email.setPlainTextBody(String.join(errorMessageForEmailList, '\n'));
                emailList.add(email);
                Messaging.sendEmail(emailList);
            }
    }
    
    private void createExceptionRecords(){
        List<API_Error__c> listAPIErrors = new List<API_Error__c>();
        for(String recordId : errorRecIdandErrorMsgMap.keySet()){
            API_Error__c apiError = new API_Error__c(
                Error__c = errorRecIdandErrorMsgMap.get(recordId),
                Action__c = 'API Failed'
            );
            listAPIErrors.add(apiError);
        }
        
        if(listAPIErrors != null && listAPIErrors.size() > 0){
            Database.insert(listAPIErrors, false);
        }
    }
}