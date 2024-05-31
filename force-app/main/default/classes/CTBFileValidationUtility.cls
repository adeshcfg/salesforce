/**
 * @description       : Class to hold all validation methods for CTB Staging processing
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 05-31-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public with sharing class CTBFileValidationUtility {
    // Contants for csv column index mapping with staging object fields
    public static final Integer ACCOUNT_NUMBER = 4;
    public static final Integer FIRST_NAME = 7;
    public static final Integer LAST_NAME = 8;
    public static final Integer CTB_DOB = 17;
    public static final Integer CORRELATION_ID = 26;
    public static final Integer CTB_REJECT_REASON_CODE = 28;
    public static final Integer ACCOUNT_OPEN_DATE = 29;
    public static final Integer CLAIM_AMOUNT = 30;
    public static final Integer CTB_AS_OF_DATE = 31;
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
    public static Map<String, String> dateAmountFieldsMap = new Map<String, String>{
        'Last_Payment_Date__c' => 'Last_Payment_Amount__c',
        'Last_Payment_Date_2__c' => 'Last_Payment_Amount_2__c',
        'Last_Payment_Date_2__c' => 'Last_Payment_Amount_2__c'
    };
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
        if (String.isNotBlank(csvColumns[CTB_REJECT_REASON_CODE]) && csvColumns[CTB_REJECT_REASON_CODE] == 'NMAT') {
            stagingRecord.Error_Message__c += '; No Match found by CTB(duplicate account with different debtor)';
            stagingRecord.Status__c = 'Error';
        }
        stagingRecord.Name = csvColumns[ACCOUNT_NUMBER];
        stagingRecord.Debtor_1_First_Name__c = csvColumns[FIRST_NAME];
        stagingRecord.Debtor_1_Last_Name__c = csvColumns[LAST_NAME];
        stagingRecord.CTB_Date_of_Birth__c = parseDateString(csvColumns[CTB_DOB], 'CTB_Date_of_Birth__c', stagingRecord);
        stagingRecord.Correlation_Id__c = csvColumns[CORRELATION_ID];
        stagingRecord.CTB_Reject_Reason_Code__c = csvColumns[CTB_REJECT_REASON_CODE];
        stagingRecord.Account_Original_Open_Date__c = parseDateString(csvColumns[ACCOUNT_OPEN_DATE], 'Account_Original_Open_Date__c', stagingRecord);
        stagingRecord.Balance_Owed__c = parseDoubleString(csvColumns[CLAIM_AMOUNT], 'Balance_Owed__c', stagingRecord);
        stagingRecord.Claim_Amount__c = parseDoubleString(csvColumns[CLAIM_AMOUNT], 'Claim_Amount__c', stagingRecord);
        stagingRecord.CTB_Balance_as_of_date__c = parseDateString(csvColumns[CTB_AS_OF_DATE], 'CTB_Balance_as_of_date__c', stagingRecord);
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
        return stagingRecord;
    }

    /**
     * @description : Method to populate account info from staging record
     * @author adesh.ikhar@canaccede.com | 04-05-2024
     * @param stagingRecord
     * @return Insolvency_Account__c
     **/
    public static Insolvency_Account__c updateInsolvencyAccount(CTB_Staging__c stagingRecord) {
        List<String> optionalFields = new List<String>{ 'CTB_Reject_Reason_Code__c', 'Previous_Account_Reference__c', 'Additional_Info__c' };
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
        account.Account_Original_Open_Date__c = stagingRecord.Account_Original_Open_Date__c;
        account.Balance_Owed__c = stagingRecord.Balance_Owed__c;
        account.Claim_Amount__c = stagingRecord.Claim_Amount__c;
        account.CTB_Balance_as_of_date__c = stagingRecord.CTB_Balance_as_of_date__c;
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
        // If payment amount is null or less than 0 or payment date is null or future date, make both fields null
        for (String dateField : dateAmountFieldsMap.keySet()) {
            if (
                account.get(dateAmountFieldsMap.get(dateField)) == null ||
                account.get(dateField) == null ||
                Double.valueOf(account.get(dateAmountFieldsMap.get(dateField))) <= 0 ||
                Date.valueOf(account.get(dateField)) > System.today()
            ) {
                account.put(dateAmountFieldsMap.get(dateField), null);
                account.put(dateField, null);
            }
        }
        account.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Canadian_Tire_Insolvency_Account')
            .getRecordTypeId();
        return account;
    }

    /**
     * @description : Method to return document storage record with passed details
     * @author adesh.ikhar@canaccede.com | 05-03-2024
     * @param docStorage
     * @param status
     * @param errorMessage
     * @return Document_Storage__c
     **/
    public static Document_Storage__c updateDocStorageDetails(Document_Storage__c docStorage, String status, String errorMessage) {
        docStorage.File_Processing_Status__c = status;
        docStorage.File_Processing_Error__c = errorMessage;
        if (status == 'Failed') {
            CTBFileValidationUtility.sendEmail(
                'CTB Account file processing failed',
                'File processing failed for ' + docStorage.Document_Name__c + '\n' + 'Error - ' + errorMessage
            );
        }
        return docStorage;
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
     * @description : Method to validate header and trailer rows
     * @author adesh.ikhar@canaccede.com | 05-03-2024
     * @param header
     * @param trailer
     * @param numberOfRows
     * @return String
     **/
    public static String validateHeaderTrailer(String header, String trailer, Integer numberOfRows) {
        if (String.isBlank(header) || String.isBlank(trailer)) {
            return 'Empty Header/Trailer provided';
        }
        CTB_File_Automation__mdt fileMetadata = [
            SELECT Header_Record_Type__c, Trailer_Record_Type__c
            FROM CTB_File_Automation__mdt
            WHERE DeveloperName = 'Insolvency_Daily_Update'
        ];
        List<String> headerValues = parseCsv(header);
        String headerValidationMessage = validateHeader(headerValues, fileMetadata.Header_Record_Type__c);
        if (String.isNotBlank(headerValidationMessage)) {
            return headerValidationMessage;
        }
        List<String> trailerValues = parseCsv(trailer);
        String trailerValidationMessage = validatetrailer(trailerValues, fileMetadata.Trailer_Record_Type__c, numberOfRows);
        if (String.isNotBlank(trailerValidationMessage)) {
            return trailerValidationMessage;
        }
        if (headerValues[4] != trailerValues[5]) {
            return 'TrnDate for header and trailer should be same';
        }
        return null;
    }

    /**
     * @description : Validate header row
     * @author adesh.ikhar@canaccede.com | 05-03-2024
     * @param headerValues
     * @param headerRecType
     * @return string
     **/
    public static string validateHeader(List<String> headerValues, String headerRecType) {
        if (headerValues.size() != 8) {
            return 'Number of columns in header should be 8';
        }
        for (String value : headerValues) {
            if (String.isBlank(value)) {
                return 'Mandatory value absent in the header';
            }
        }
        if (headerValues[0].remove('"') != headerRecType) {
            return 'Invalid RecType in the header';
        }
        if (headerValues[1] != '2') {
            return 'Invalid MemType in the header';
        }
        if (headerValues[6] != 'T' && headerValues[6] != 'P') {
            return 'Invalid File Type in the header';
        }
        return null;
    }

    /**
     * @description : Validate trailer row
     * @author adesh.ikhar@canaccede.com | 05-03-2024
     * @param trailerValues
     * @param trailerRecType
     * @param numberOfRows
     * @return string
     **/
    public static string validatetrailer(List<String> trailerValues, String trailerRecType, Integer numberOfRows) {
        if (trailerValues.size() != 7) {
            return 'Number of columns in trailer should be 7';
        }
        for (String value : trailerValues) {
            if (String.isBlank(value)) {
                return 'Mandatory value absent in the trailer';
            }
        }
        if (trailerValues[0].remove('"') != trailerRecType) {
            return 'Invalid RecType in the trailer';
        }
        if (trailerValues[1] != '2') {
            return 'Invalid MemType in the trailer';
        }
        if (Integer.valueOf(trailerValues[3]) != numberOfRows) {
            return 'RecCount does not match with the number of rows in the file';
        }
        if (Integer.valueOf(trailerValues[4]) != numberOfRows - 2) {
            return 'TranCount does not match with the number of detail records in the file';
        }
        return null;
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
    /* public static DateTime parseDateTimeString(String input, String fieldName, CTB_Staging__c stagingRecord) {
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
    } */

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

    public static void sendEmail(String subject, String htmlBody) {
        String userEmail = UserInfo.getUserEmail() + ',' + System.Label.CTB_File_Processing_Emails;
        List<String> lstEmail = userEmail.split(',');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(lstEmail);
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject(subject);
        mail.setUseSignature(false);
        mail.setHtmlBody(htmlBody);
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (Exception e) {
            system.debug('Exception in sendEmail ' + e.getMessage());
        }
    }
}
