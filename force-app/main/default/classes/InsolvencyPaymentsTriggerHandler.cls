/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Insolvency Payment object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 
 *************************************************************************************************/
public class InsolvencyPaymentsTriggerHandler {
    public static boolean runInsolvencyPaymentsTrigger = true;
    public static void handleBeforeInsert(List<Insolvency_Payment__c> insolvPaymentsNew) {
        Map<String, Insolvency_Account__c> acctsToUpdateMap = new Map<String, Insolvency_Account__c>();
        // Migrate 2 workflows to trigger
        for (Insolvency_Payment__c payment : insolvPaymentsNew) {
            // Update Insolvency last Payment Date
            if (payment.Payment_Created__c != null) {
                acctsToUpdateMap.put(
                    payment.Insolvency_Account__c,
                    new Insolvency_Account__c(Id = payment.Insolvency_Account__c, Insolvency_Last_Payment_Date__c = payment.Payment_Created__c)
                );
            }
            // Update Insolvency Last Payment Amount on Insolvency Account
            if (
                payment.Payment_Amount__c != null
            ) {
                if (acctsToUpdateMap.containsKey(payment.Insolvency_Account__c)) {
                    acctsToUpdateMap.get(payment.Insolvency_Account__c).Insolvency_Last_Payment_Amount__c = payment.Payment_Amount__c;
                } else {
                    acctsToUpdateMap.put(
                        payment.Insolvency_Account__c,
                        new Insolvency_Account__c(Id = payment.Insolvency_Account__c, Insolvency_Last_Payment_Amount__c = payment.Payment_Amount__c)
                    );
                }
            }
            updatePaymentReversalDate(payment, null);
        }
        if (!acctsToUpdateMap.values().isEmpty()) {
            update acctsToUpdateMap.values();
        }
    }

    public static void handleBeforeUpdate(List<Insolvency_Payment__c> insolvPaymentsNew, Map<Id, Insolvency_Payment__c> oldMap) {
        for (Insolvency_Payment__c payment : insolvPaymentsNew) {
            updatePaymentReversalDate(payment, oldMap.get(payment.Id));
        }
    }

    public static void updatePaymentReversalDate(Insolvency_Payment__c newPayment, Insolvency_Payment__c oldPayment) {
        // Migrate 1 workflow to trigger
        // Update Insolvency last Payment Date
        if (
            newPayment.Payment_Reversal_Date__c == null &&
            String.isNotBlank(newPayment.Payment_Reversed__c) &&
            (oldPayment == null || (oldPayment != null && newPayment.Payment_Reversed__c != oldPayment.Payment_Reversed__c))
        ) {
            newPayment.Payment_Reversal_Date__c = System.today();
        }
    }

    public static void handleBeforeDelete(List<Insolvency_Payment__c> insolvPaymentRecords) {
        list<Deleted_Records__c> deletedRecords = new List<Deleted_Records__c>();
        for (Insolvency_Payment__c insolvPayment : insolvPaymentRecords) {
            ID recordID = insolvPayment.ID;
            Deleted_Records__c deletedRec = new Deleted_Records__c();
            deletedRec.Object_Name__c = recordId.getSObjectType().getDescribe().getName();
            deletedRec.Salesforce_Record_Id__c = insolvPayment.External_Correlation_ID__c;
            deletedRecords.add(deletedRec);
        }
        if (!deletedRecords.isEmpty()) {
            insert deletedRecords;
        }
    }

    //After Insert
    public static void handleAfterInsert(List<Insolvency_Payment__c> insolvPaymentsNew) {
        map<id, Insolvency_Payment__c> insolvPaymentMap = new Map<id, Insolvency_Payment__c>();
        for (Insolvency_Payment__c insolvPayment : [
            SELECT ID, Name, External_Correlation_ID__c, Insolvency_Payment_Name_Original__c
            FROM Insolvency_Payment__c
            WHERE ID IN :insolvPaymentsNew
        ]) {
            insolvPayment.External_Correlation_ID__c = insolvPayment.ID;
            insolvPayment.Insolvency_Payment_Name_Original__c = insolvPayment.Name;
            insolvPaymentMap.put(insolvPayment.ID, insolvPayment);
        }
        if (!insolvPaymentMap.isEmpty()) {
            InsolvencyPaymentsTriggerHandler.runInsolvencyPaymentsTrigger = false;
            update insolvPaymentMap.values();
        }
    }
}
