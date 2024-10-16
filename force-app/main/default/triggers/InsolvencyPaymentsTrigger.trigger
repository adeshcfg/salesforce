/**************************************************************************************************
 *
 *  Trigger:
 *
 *  @description : This is a trigger for Insolvency_Payment__c object
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 *
 *************************************************************************************************/

trigger InsolvencyPaymentsTrigger on Insolvency_Payment__c(after insert, before insert, before delete, before update) {
    list<Insolvency_Payment__c> insolPaymentRecords = new List<Insolvency_Payment__c>();
    //On-Off switch for trigger
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    Boolean runTrigger = config.Run_Insolvency_Payment_Trigger__c;

    if (runTrigger && InsolvencyPaymentsTriggerHandler.runInsolvencyPaymentsTrigger) {
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                InsolvencyPaymentsTriggerHandler.handleBeforeInsert(Trigger.new);
            }
            if (Trigger.isUpdate) {
                InsolvencyPaymentsTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
            if (Trigger.isDelete) {
                user u = [SELECT id, name FROM User WHERE name = :System.label.DataArchiverUser LIMIT 1];
                if (userinfo.getUserId() != u.id) {
                    InsolvencyPaymentsTriggerHandler.handleBeforeDelete(Trigger.old);
                }
            }
        }
        //After Insert Trigger
        if (Trigger.isAfter && Trigger.isInsert) {
            for (Insolvency_Payment__c insolPayment : Trigger.new) {
                if (insolPayment.External_Correlation_ID__c == null) {
                    insolPaymentRecords.add(insolPayment);
                }
            }
            if (!insolPaymentRecords.isEmpty()) {
                InsolvencyPaymentsTriggerHandler.handleAfterInsert(insolPaymentRecords);
            }
        }
    }
}