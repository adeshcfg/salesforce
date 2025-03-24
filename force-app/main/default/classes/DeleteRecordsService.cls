/**
* @description       : Web Service to ADF Job to initiate records deletion in Deleted_Records__c object
* @author            : pradeep.@canaccede.com
* @last modified on  : 02-24-2025
* @last modified by  : pradeep.kumar@canaccede.com
**/
@RestResource(urlMapping='/v1/deleteRecords/*')
global class DeleteRecordsService {
    
    private final static String SUCCESS_FLAG = 'SUCCESS';
    public final static String SUCCESS_MSG = 'The deletion request is received. The Deletion Job will be processed Asynchronously.';
    
    @HttpDelete 
    global static Response deleteRecords() {
        Response responseMessage;
        String requestAsString = '';
        if(RestContext.request.requestBody != null){
            requestAsString = RestContext.request.requestBody.toString();
        }
        
        Map<String, Object> mapJSONRequestBody = (Map<String, Object>)JSON.deserializeUntyped(requestAsString);
        String adfRecordsDeletionResult = String.valueOf(mapJSONRequestBody.get('Result'));
        
        if(String.isNotBlank(adfRecordsDeletionResult) && adfRecordsDeletionResult.equalsIgnoreCase(SUCCESS_FLAG)){
            Database.executeBatch(new ProcessRecordsDeletionBatch(), 200);
            responseMessage = new Response(SUCCESS_MSG);
        }
        return responseMessage;
    }
    
    global class Response {
        public String responseMessage;
        
        Response(String responseMessage){
            this.responseMessage = responseMessage;
        }
    }
}