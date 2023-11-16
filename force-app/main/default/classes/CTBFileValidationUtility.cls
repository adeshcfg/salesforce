public with sharing class CTBFileValidationUtility {
    public static void validateInsolvencyAccountRecords(String fileName) {
        CTB_Staging__c[] listSuccessStagingRecords = [
            SELECT
                Debtor_1_First_Name__c,
                Debtor_1_Last_Name__c,
                CTB_Date_of_Birth__c,
                Correlation_ID__c,
                CTB_Reject_Reason_Code__c,
                Open_Date__c,
                Balance_Owed__c,
                Claim_Amount__c,
                Accounts_Validation_Date__c,
                Interest_Rate__c,
                Last_Payment_Date__c,
                Last_Payment_Amount__c,
                Last_Payment_Date_2__c,
                Last_Payment_Amount_2__c,
                Last_Payment_Date_3__c,
                Last_Payment_Amount_3__c,
                Last_Statement_Date__c,
                Last_Statement_Amount__c,
                Last_Statement_Date_2__c,
                Last_Statement_Amount_2__c,
                Last_Statement_Date_3__c,
                Last_Statement_Amount_3__c,
                Previous_Account_Reference__c,
                Additional_Info__c
            FROM CTB_Staging__c
        ];
    }
}
