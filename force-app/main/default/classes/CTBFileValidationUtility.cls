/**
 * @description       : Class to hold all validation methods for CTB Staging processing
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-23-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
public with sharing class CTBFileValidationUtility {
    /**
     * @description : Map and validate fields from csv to CTB Staging for Insolvency Account
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvColumns
     * @return CTB_Staging__c
     **/
    public static CTB_Staging__c validateAccountCTBStagingRecord(List<String> csvColumns) {
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

    /**
     * @description : Map and validate fields from csv to CTB Staging for Insolvency Payment
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvColumns
     * @return CTB_Staging__c
     **/
    public static CTB_Staging__c validatePaymentCTBStagingRecord(List<String> csvColumns) {
        CTB_Staging__c stagingRecord = new CTB_Staging__c();
        stagingRecord.Error_Message__c = '';
        stagingRecord.Name = csvColumns[3];
        stagingRecord.Payment_Posting_Date__c = parseDateString(csvColumns[6], 'Payment_Posting_Date__c', stagingRecord);
        stagingRecord.Transaction_Id__c = csvColumns[7];
        stagingRecord.Payment_Type__c = csvColumns[8];
        stagingRecord.Payment_Amount__c = parseDoubleString(csvColumns[9], 'Payment_Amount__c', stagingRecord);
        stagingRecord.Remitted_Date__c = parseDateString(csvColumns[10], 'Remitted_Date__c', stagingRecord);
        stagingRecord.Remitted_Cheque_Number__c = csvColumns[11];
        System.debug(stagingRecord);
        return stagingRecord;
    }

    /**
     * @description : Parse String to Date, return null and populate error message for invalid Date
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param input
     * @param fieldName
     * @param stagingRecord
     * @return Date
     **/
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

    /**
     * @description : Parse String to DateTime, return null and populate error message for invalid DateTime
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param input
     * @param fieldName
     * @param stagingRecord
     * @return DateTime
     **/
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

    /**
     * @description : Parse String to Double, return null and populate error message for invalid Double
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param input
     * @param fieldName
     * @param stagingRecord
     * @return Double
     **/
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
