/**
 * @description       : Web Service to ADF Job to initiate records deletion in Deleted_Records__c object
 * @author            : pradeep.@canaccede.com
 * @last modified on  : 02-24-2025
 * @last modified by  : pradeep.kumar@canaccede.com
 **/
@RestResource(urlMapping='/v1/deleteRecords/*')
global class DeleteRecordsService {
    
    private final static String SUCCESS_FLAG = 'SUCCESS';
    @TestVisible
    private static Boolean isBatchStarted = false;
    
    @HttpDelete 
    global static void deleteRecords() {
        String requestAsString = '';
        if(RestContext.request.requestBody != null){
            requestAsString = RestContext.request.requestBody.toString();
        }
        
        Map<String, Object> mapJSONRequestBody = (Map<String, Object>)JSON.deserializeUntyped(requestAsString);
        String adfRecordsDeletionResult = String.valueOf(mapJSONRequestBody.get('Result'));
        
        if(String.isNotBlank(adfRecordsDeletionResult) && adfRecordsDeletionResult.equalsIgnoreCase(SUCCESS_FLAG)){
            Database.executeBatch(new ProcessRecordsDeletionBatch(), 200);
            isBatchStarted = true;
        }
    }
}