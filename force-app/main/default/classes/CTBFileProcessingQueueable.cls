public with sharing class CTBFileProcessingQueueable implements Queueable {
    public String fileIdentifier = '';
    public String documentId = '';
    public Document_Storage__c docStorage = new Document_Storage__c();

    public CTBFileProcessingQueueable(String fileIdentifier, String documentId, Document_Storage__c docStorage) {
        this.fileIdentifier = fileIdentifier;
        this.documentId = documentId;
        this.docStorage = docStorage;
    }

    public void execute(QueueableContext context) {
        try {
            Document fileToProccess = [SELECT Id, Body FROM Document WHERE Id = :documentId];
            String csvContents = fileToProccess.Body.toString();
            if (fileIdentifier == System.Label.CTB_Insolvency_Account) {
                System.debug('Account processing');
                processInsolvencyAccounts(csvContents, null);
            } else if (fileIdentifier == System.Label.CTB_Payment) {
                System.debug('Payment processing');
            }
        } catch (Exception e) {
            System.debug('Exception in CTBFileProcessingQueueable ' + e.getStackTraceString());
        }
    }

    public static void processInsolvencyAccounts(String csvContents, Document_Storage__c docStorage) {
        List<CTB_Staging__c> stagingRecordsToCreate = new List<CTB_Staging__c>();
        List<String> csvRows = csvContents.split('\n');
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split(',');
            CTB_Staging__c stagingRecord = new CTB_Staging__c();
            stagingRecord.Error_Message__c = '';
            stagingRecord.CTB_Update_Filename__c = docStorage.Document_Name__c;
            System.debug(csvColumns[26]);
            if (String.isBlank(csvColumns[26])) {
                stagingRecord.Error_Message__c = 'No Correlation Id provided';
                stagingRecord.Status__c = 'Error';
                System.debug(stagingRecord);
                stagingRecordsToCreate.add(stagingRecord);
                continue;
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
            stagingRecordsToCreate.add(stagingRecord);
        }
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
