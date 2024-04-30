/**
 * @description       : Class to hold all validation methods for CTB Staging processing
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-28-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
public with sharing class CTBFileValidationUtility {
    // Contants for csv column index mapping with staging object fields
    public static final Integer ACCOUNT_NUMBER = 4;
    public static final Integer FIRST_NAME = 7;
    public static final Integer LAST_NAME = 8;
    public static final Integer CTB_DOB = 17;
    public static final Integer CORRELATION_ID = 26;
    public static final Integer CTB_REJECT_REASON_CODE = 28;
    public static final Integer OPEN_DATE = 29;
    public static final Integer CLAIM_AMOUNT = 30;
    public static final Integer ACCOUNTS_VALIDATION_DATE = 31;
    public static final Integer INTEREST_RATE = 32;
    public static final Integer LAST_PAYMENT_DATE = 33;
    public static final Integer LAST_PAYMENT_AMOUNT = 34;
    public static final Integer LAST_PAYMENT_DATE_2 = 35;
    public static final Integer LAST_PAYMENT_AMOUNT_2 = 36;
    public static final Integer LAST_PAYMENT_DATE_3 = 37;
    public static final Integer LAST_PAYMENT_AMOUNT_3 = 38;
    public static final Integer LAST_STATEMENT_DATE = 39;
    public static final Integer LAST_STATEMENT_AMOUNT = 40;
    public static final Integer LAST_STATEMENT_DATE_2 = 41;
    public static final Integer LAST_STATEMENT_AMOUNT_2 = 42;
    public static final Integer LAST_STATEMENT_DATE_3 = 43;
    public static final Integer LAST_STATEMENT_AMOUNT_3 = 44;
    public static final Integer PREVIOUS_ACCOUNT_REFERENCE = 46;
    public static final Integer ADDITIONAL_INFO = 47;
    /**
     * @description : Map and validate fields from csv to CTB Staging for Insolvency Account
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvColumns
     * @return CTB_Staging__c
     **/
    public static CTB_Staging__c validateAccountCTBStagingRecord(List<String> csvColumns) {
        CTB_Staging__c stagingRecord = new CTB_Staging__c();
        stagingRecord.Error_Message__c = '';
        // If correlation Id is null
        if (String.isBlank(csvColumns[CORRELATION_ID])) {
            stagingRecord.Error_Message__c = 'No Correlation Id provided';
            stagingRecord.Status__c = 'Error';
        }
        // If Current Balance owed is null
        if (String.isBlank(csvColumns[CLAIM_AMOUNT])) {
            stagingRecord.Error_Message__c += '; No Current Balance owed provided';
            stagingRecord.Status__c = 'Error';
        }
        stagingRecord.Name = csvColumns[ACCOUNT_NUMBER];
        stagingRecord.Debtor_1_First_Name__c = csvColumns[FIRST_NAME];
        stagingRecord.Debtor_1_Last_Name__c = csvColumns[LAST_NAME];
        stagingRecord.CTB_Date_of_Birth__c = parseDateString(csvColumns[CTB_DOB], 'CTB_Date_of_Birth__c', stagingRecord);
        stagingRecord.Correlation_Id__c = csvColumns[CORRELATION_ID];
        stagingRecord.CTB_Reject_Reason_Code__c = csvColumns[CTB_REJECT_REASON_CODE];
        stagingRecord.Open_Date__c = parseDateString(csvColumns[OPEN_DATE], 'Open_Date__c', stagingRecord);
        stagingRecord.Balance_Owed__c = parseDoubleString(csvColumns[CLAIM_AMOUNT], 'Balance_Owed__c', stagingRecord);
        stagingRecord.Claim_Amount__c = parseDoubleString(csvColumns[CLAIM_AMOUNT], 'Claim_Amount__c', stagingRecord);
        stagingRecord.Accounts_Validation_Date__c = parseDateTimeString(csvColumns[ACCOUNTS_VALIDATION_DATE], 'Accounts_Validation_Date__c', stagingRecord);
        stagingRecord.Interest_Rate__c = parseDoubleString(csvColumns[INTEREST_RATE], 'Interest_Rate__c', stagingRecord);
        stagingRecord.Last_Payment_Date__c = parseDateString(csvColumns[LAST_PAYMENT_DATE], 'Last_Payment_Date__c', stagingRecord);
        stagingRecord.Last_Payment_Amount__c = parseDoubleString(csvColumns[LAST_PAYMENT_AMOUNT], 'Last_Payment_Amount__c', stagingRecord);
        stagingRecord.Last_Payment_Date_2__c = parseDateString(csvColumns[LAST_PAYMENT_DATE_2], 'Last_Payment_Date_2__c', stagingRecord);
        stagingRecord.Last_Payment_Amount_2__c = parseDoubleString(csvColumns[LAST_PAYMENT_AMOUNT_2], 'Last_Payment_Amount_2__c', stagingRecord);
        stagingRecord.Last_Payment_Date_3__c = parseDateString(csvColumns[LAST_PAYMENT_DATE_3], 'Last_Payment_Date_3__c', stagingRecord);
        stagingRecord.Last_Payment_Amount_3__c = parseDoubleString(csvColumns[LAST_PAYMENT_AMOUNT_3], 'Last_Payment_Amount_3__c', stagingRecord);
        stagingRecord.Last_Statement_Date__c = parseDateString(csvColumns[LAST_STATEMENT_DATE], 'Last_Statement_Date__c', stagingRecord);
        stagingRecord.Last_Statement_Amount__c = parseDoubleString(csvColumns[LAST_STATEMENT_AMOUNT], 'Last_Statement_Amount__c', stagingRecord);
        stagingRecord.Last_Statement_Date_2__c = parseDateString(csvColumns[LAST_STATEMENT_DATE_2], 'Last_Statement_Date_2__c', stagingRecord);
        stagingRecord.Last_Statement_Amount_2__c = parseDoubleString(csvColumns[LAST_STATEMENT_AMOUNT_2], 'Last_Statement_Amount_2__c', stagingRecord);
        stagingRecord.Last_Statement_Date_3__c = parseDateString(csvColumns[LAST_STATEMENT_DATE_3], 'Last_Statement_Date_3__c', stagingRecord);
        stagingRecord.Last_Statement_Amount_3__c = parseDoubleString(csvColumns[LAST_STATEMENT_AMOUNT_3], 'Last_Statement_Amount_3__c', stagingRecord);
        stagingRecord.Previous_Account_Reference__c = csvColumns[PREVIOUS_ACCOUNT_REFERENCE];
        stagingRecord.Additional_Info__c = csvColumns[ADDITIONAL_INFO];
        // Remove ; from start of the string if it starts with ;
        if (String.isNotBlank(stagingRecord.Error_Message__c)) {
            stagingRecord.Error_Message__c = stagingRecord.Error_Message__c.removeStart(';');
        }
        return stagingRecord;
    }

    /**
     * @description : Method to populate account info from staging record
     * @author adesh.ikhar@canaccede.com | 04-05-2024
     * @param stagingRecord
     * @return Insolvency_Account__c
     **/
    public static Insolvency_Account__c updateInsolvencyAccount(CTB_Staging__c stagingRecord) {
        List<String> optionalFields = new List<String>{
            'Debtor_1_First_Name__c',
            'Debtor_1_Last_Name__c',
            'CTB_Reject_Reason_Code__c',
            'Previous_Account_Reference__c',
            'Additional_Info__c'
        };
        Insolvency_Account__c account = new Insolvency_Account__c();
        // Check if optional field value was not null in csv, only update if it was not null
        for (String fieldApiName : optionalFields) {
            String fieldValue = stagingRecord.get(fieldApiName) != null ? String.valueOf(stagingRecord.get(fieldApiName)) : null;
            if (String.isNotBlank(fieldValue)) {
                account.put(fieldApiName, fieldValue);
            }
        }
        // account.Name = stagingRecord.Name;
        account.CTB_Date_of_Birth__c = stagingRecord.CTB_Date_of_Birth__c;
        account.Correlation_Id__c = stagingRecord.Correlation_Id__c;
        account.Open_Date__c = stagingRecord.Open_Date__c;
        account.Balance_Owed__c = stagingRecord.Balance_Owed__c;
        account.Claim_Amount__c = stagingRecord.Claim_Amount__c;
        account.Accounts_Validation_Date__c = stagingRecord.Accounts_Validation_Date__c;
        account.Interest_Rate__c = stagingRecord.Interest_Rate__c;
        account.Last_Payment_Date__c = stagingRecord.Last_Payment_Date__c;
        account.Last_Payment_Amount__c = stagingRecord.Last_Payment_Amount__c;
        account.Last_Payment_Date_2__c = stagingRecord.Last_Payment_Date_2__c;
        account.Last_Payment_Amount_2__c = stagingRecord.Last_Payment_Amount_2__c;
        account.Last_Payment_Date_3__c = stagingRecord.Last_Payment_Date_3__c;
        account.Last_Payment_Amount_3__c = stagingRecord.Last_Payment_Amount_3__c;
        account.Last_Statement_Date__c = stagingRecord.Last_Statement_Date__c;
        account.Last_Statement_Amount__c = stagingRecord.Last_Statement_Amount__c;
        account.Last_Statement_Date_2__c = stagingRecord.Last_Statement_Date_2__c;
        account.Last_Statement_Amount_2__c = stagingRecord.Last_Statement_Amount_2__c;
        account.Last_Statement_Date_3__c = stagingRecord.Last_Statement_Date_3__c;
        account.Last_Statement_Amount_3__c = stagingRecord.Last_Statement_Amount_3__c;
        account.Insolvency_Sub_Status__c = null;
        account.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        return account;
    }

    /**
     * @description : Method to parse csv, parses columns containing , as well
     * @author adesh.ikhar@canaccede.com | 04-30-2024
     * @param csvRow
     * @return List<String>
     **/
    public static List<String> parseCsv(String csvRow) {
        Integer startIndex = null;
        Integer endIndex = null;
        List<String> parsedColumns = new List<String>();
        while (csvRow.indexOf('"') > -1) {
            if (startIndex == null) {
                startIndex = csvRow.indexOf('"');
                csvRow = csvRow.substring(0, startIndex) + ':quotes:' + csvRow.substring(startIndex + 1, csvRow.length());
            } else {
                if (endIndex == null) {
                    endIndex = csvRow.indexOf('"');
                    csvRow = csvRow.substring(0, endIndex) + ':quotes:' + csvRow.substring(endIndex + 1, csvRow.length());
                }
            }
            if (startIndex != null && endIndex != null) {
                String sub = csvRow.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvRow = csvRow.substring(0, startIndex) + sub + csvRow.substring(endIndex, csvRow.length());
                startIndex = null;
                endIndex = null;
            }
        }
        for (String column : csvRow.split(',')) {
            column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',').trim();
            parsedColumns.add(column);
        }
        return parsedColumns;
    }

    /**
     * @description : Map and validate fields from csv to CTB Staging for Insolvency Payment
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvColumns
     * @return CTB_Staging__c
     **/
    /* public static CTB_Staging__c validatePaymentCTBStagingRecord(List<String> csvColumns) {
        CTB_Staging__c stagingRecord = new CTB_Staging__c();
        stagingRecord.Error_Message__c = '';
        stagingRecord.Name = csvColumns[3];
        stagingRecord.Payment_Posting_Date__c = parseDateString(csvColumns[6], 'Payment_Posting_Date__c', stagingRecord);
        stagingRecord.Transaction_Id__c = csvColumns[7];
        stagingRecord.Payment_Type__c = csvColumns[8];
        stagingRecord.Payment_Amount__c = parseDoubleString(csvColumns[9], 'Payment_Amount__c', stagingRecord);
        stagingRecord.Remitted_Date__c = parseDateString(csvColumns[10], 'Remitted_Date__c', stagingRecord);
        stagingRecord.Remitted_Cheque_Number__c = csvColumns[11];
        return stagingRecord;
    } */

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
            stagingRecord.Error_Message__c += '; Invalid Date format for ' + fieldName;
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
            return DateTime.newInstance(Date.parse(input), Time.newInstance(23, 59, 59, 59));
        } catch (Exception ex) {
            stagingRecord.Status__c = 'Error';
            stagingRecord.Error_Message__c += '; Invalid DateTime format for ' + fieldName;
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
            stagingRecord.Error_Message__c += '; Invalid Number format for ' + fieldName;
            return null;
        }
    }
}
