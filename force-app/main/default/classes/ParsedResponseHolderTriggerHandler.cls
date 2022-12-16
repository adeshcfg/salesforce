/**************************************************************************************************
 *
 *  Trigger:    ParsedResponseHolderTrigger
 *
 *  @description : Trigger when a new record is insteres with JSON string under Parsed Response Holder Object
 *  @author : A5E Consulting
 *  @date : 05/28/2020
 
 *************************************************************************************************/
public with sharing class ParsedResponseHolderTriggerHandler {
    public static void initializeParsing(Map<Id, Parsed_Response_Holder__c> newMap) {
        for(Id key: newMap.keySet()){
            DocumentResponseParser.parseResponse(key);
        }
    }
}