/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class for Settlement object to calculate Collection Agency identifiers 
 *                 from related Product and Judgement
 *  @author : A5E Consulting
 *  @date : 06/09/2020
 
 *************************************************************************************************/
public class SettlementIdentifierBatch implements Database.Batchable<sObject> {
    public static final string SEPARATOR = 'A';
    public static final string UNPLACED = 'unplaced';
    public static final string POST_JUDGMENT_VACATED = 'Post_Judgment_Vacated';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of Settlement records or objects to be passed to execute
        return Database.getQueryLocator(
            [
                SELECT
                    ID,
                    Judgment__r.Collection_Agency_Identifier__c,
                    Judgment__r.RecordTypeId,
                    Product__r.Collection_Agency__c,
                    Judgment_Collection_Agency_Identifier__c,
                    External_Collection_Agency_Identifier__c,
                    Product_Collection_Agency_Identifier__c
                FROM Settlement__c
                WHERE Product__r.Run_Identifier_Check_On__c = TODAY OR Judgment__r.Run_Identifier_Check_On__c = TODAY
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Settlement__c> listSettlements) {
        list<Settlement__c> listSettlememtsToUpdate = new List<Settlement__c>();
        RecordType vacatedRecordType = [
            SELECT ID
            FROM RecordType
            WHERE SObjectType = 'Judgment__c' AND DeveloperName = :POST_JUDGMENT_VACATED
        ][0];

        Id devRecordTypeId = vacatedRecordType.Id;
        for (Settlement__c settlementObj : listSettlements) {
            //Check if Product Collection Agency is not null and set Settlement Product Collection Identifier
            if (settlementObj.Product__c != null) {
                if (settlementObj.Product__r.Collection_Agency__c != null && settlementObj.Product__r.Collection_Agency__c != 9999) {
                    settlementObj.Product_Collection_Agency_Identifier__c =
                        SEPARATOR +
                        String.valueOf((integer) settlementObj.Product__r.Collection_Agency__c) +
                        SEPARATOR;
                } else {
                    settlementObj.Product_Collection_Agency_Identifier__c = SEPARATOR + UNPLACED + SEPARATOR;
                }
                settlementObj.External_Collection_Agency_Identifier__c = settlementObj.Product_Collection_Agency_Identifier__c;
            }
            //Else set Judgement Product Collection Identifier from Judgment
            else {
                if (settlementObj.Judgment__c != null) {
                    if (String.isNotBlank(settlementObj.Judgment__r.Collection_Agency_Identifier__c)) {
                        settlementObj.Judgment_Collection_Agency_Identifier__c = settlementObj.Judgment__r.Collection_Agency_Identifier__c;
                    } else {
                        settlementObj.Judgment_Collection_Agency_Identifier__c = SEPARATOR + UNPLACED + SEPARATOR;
                    }
                    settlementObj.External_Collection_Agency_Identifier__c = settlementObj.Judgment_Collection_Agency_Identifier__c;
                }
            }
            //Update the external Collection Agency Identifier for Agency Group Sharing Rule
            settlementObj.External_Collection_Agency_Identifier__c = settlementObj.External_Collection_Agency_Identifier__c.replace('A68A', '')
                .replace('A6A', '')
                .replace(SEPARATOR + UNPLACED + SEPARATOR, '')
                .replace(',', '');
            if (settlementObj.Judgment__r.RecordTypeId != devRecordTypeId) {
                listSettlememtsToUpdate.add(settlementObj);
            }
        }

        //Update Settlements
        if (!listSettlememtsToUpdate.isEmpty()) {
            SettlementTriggerHandler.runSettlementTrigger = false;
            update listSettlememtsToUpdate;
            SettlementTriggerHandler.runSettlementTrigger = true;
        }
    }
    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}
