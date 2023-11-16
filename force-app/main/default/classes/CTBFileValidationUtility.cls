public with sharing class CTBFileValidationUtility {
    /* public static void validateInsolvencyAccountRecords(String fileName) {
        CTB_Staging__c[] listSuccessStagingRecords = [
            SELECT
                Debtor_1_First_Name__c,
                Debtor_1_Last_Name__c,
                CTB_Date_of_Birth__c,
                Correlation_ID__c,
                CTB_Reject_Reason_Code__c,
                CTB_Update_Filename__c,
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
    } */

    public static CTB_Staging__c validateCTBStagingRecord(List<String> csvColumns) {
        CTB_Staging__c stagingRecord = new CTB_Staging__c();
        stagingRecord.Error_Message__c = '';
        System.debug(csvColumns[26]);
        if (String.isBlank(csvColumns[26])) {
            stagingRecord.Error_Message__c = 'No Correlation Id provided';
            stagingRecord.Status__c = 'Error';
        }
        if (String.isBlank(csvColumns[30])) {
            stagingRecord.Error_Message__c += ' No Current Balance owed provided';
            stagingRecord.Status__c = 'Error';
        }
        stagingRecord.Name = csvColumns[4];
        stagingRecord.Debtor_1_First_Name__c = csvColumns[7];
        stagingRecord.Debtor_1_Last_Name__c = csvColumns[8];
        stagingRecord.CTB_Date_of_Birth__c = parseDateString(csvColumns[8], 'CTB_Date_of_Birth__c', stagingRecord);
        stagingRecord.Correlation_ID__c = csvColumns[26];
        stagingRecord.CTB_Reject_Reason_Code__c = csvColumns[28];
        stagingRecord.Open_Date__c = parseDateString(csvColumns[29], 'Open_Date__c', stagingRecord);
        stagingRecord.Balance_Owed__c = parseDoubleString(csvColumns[30], 'Balance_Owed__c', stagingRecord);
        stagingRecord.Claim_Amount__c = parseDoubleString(csvColumns[30], 'Claim_Amount__c', stagingRecord);
        stagingRecord.Accounts_Validation_Date__c = parseDateTimeString(csvColumns[31], 'Accounts_Validation_Date__c', stagingRecord);
        stagingRecord.Interest_Rate__c = parseDoubleString(csvColumns[32], 'Interest_Rate__c', stagingRecord);
        stagingRecord.Last_Payment_Date__c = parseDateString(csvColumns[33], 'Last_Payment_Date__c', stagingRecord);
        stagingRecord.Last_Payment_Amount__c = parseDoubleString(csvColumns[34], 'Last_Payment_Amount__c', stagingRecord);
        stagingRecord.Last_Payment_Date_2__c = parseDateString(csvColumns[35], 'Last_Payment_Date_2__c', stagingRecord);
        stagingRecord.Last_Payment_Amount__c = parseDoubleString(csvColumns[36], 'Last_Payment_Amount__c', stagingRecord);
        stagingRecord.Last_Payment_Date_3__c = parseDateString(csvColumns[37], 'Last_Payment_Date_3__c', stagingRecord);
        stagingRecord.Last_Payment_Amount_3__c = parseDoubleString(csvColumns[38], 'Last_Payment_Amount_3__c', stagingRecord);
        stagingRecord.Last_Statement_Date__c = parseDateString(csvColumns[39], 'Last_Statement_Date__c', stagingRecord);
        stagingRecord.Last_Statement_Amount__c = parseDoubleString(csvColumns[40], 'Last_Statement_Amount__c', stagingRecord);
        stagingRecord.Last_Statement_Date_2__c = parseDateString(csvColumns[41], 'Last_Statement_Date_2__c', stagingRecord);
        stagingRecord.Last_Statement_Amount_2__c = parseDoubleString(csvColumns[42], 'Last_Statement_Amount_2__c', stagingRecord);
        stagingRecord.Last_Statement_Date_3__c = parseDateString(csvColumns[43], 'Last_Statement_Date_3__c', stagingRecord);
        stagingRecord.Last_Statement_Amount_3__c = parseDoubleString(csvColumns[44], 'Last_Statement_Amount_3__c', stagingRecord);
        stagingRecord.Previous_Account_Reference__c = csvColumns[46];
        stagingRecord.Additional_Info__c = csvColumns[47];
        System.debug(stagingRecord);
        return stagingRecord;
    }

    public static Date parseDateString(String input, String fieldName, CTB_Staging__c stagingRecord) {
        if (String.isBlank(input)) {
            return null;
        }
        try {
            return Date.parse(input);
        } catch (Exception ex) {
            stagingRecord.Status__c = 'Error';
            stagingRecord.Error_Message__c += ' Invalid Date format for ' + fieldName;
            return null;
        }
    }

    public static DateTime parseDateTimeString(String input, String fieldName, CTB_Staging__c stagingRecord) {
        if (String.isBlank(input)) {
            return null;
        }
        try {
            return DateTime.parse(input);
        } catch (Exception ex) {
            stagingRecord.Status__c = 'Error';
            stagingRecord.Error_Message__c += ' Invalid DateTime format for ' + fieldName;
            return null;
        }
    }

    public static Double parseDoubleString(String input, String fieldName, CTB_Staging__c stagingRecord) {
        if (String.isBlank(input)) {
            return null;
        }
        try {
            return Double.valueOf(input);
        } catch (Exception ex) {
            stagingRecord.Status__c = 'Error';
            stagingRecord.Error_Message__c += ' Invalid Number format for ' + fieldName;
            return null;
        }
    }
}
