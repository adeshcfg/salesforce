/**************************************************************************************************
 *
 *  Trigger:    ParsedResponseHolderTrigger
 *
 *  @description : Trigger when a new record is insteres with JSON string under Parsed Response Holder Object
 *  @author : A5E Consulting
 *  @date : 05/28/2020
 
 *************************************************************************************************/
trigger ParsedResponseHolderTrigger on Parsed_Response_Holder__c (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        ParsedResponseHolderTriggerHandler.initializeParsing((Map<Id, Parsed_Response_Holder__c>)Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        ParsedResponseHolderTriggerHandler.initializeParsing((Map<Id, Parsed_Response_Holder__c>)Trigger.newMap);
    }
}