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
        Map<Integer, String> indexFieldMap = new Map<Integer, String>{
            4 => 'Name',
            7 => 'Debtor_1_First_Name__c',
            8 => 'Debtor_1_Last_Name__c',
            16 => 'CTB_Date_of_Birth__c',
            26 => 'Correlation_ID__c',
            28 => 'CTB_Reject_Reason_Code__c',
            29 => 'Open_Date__c',
            30 => 'Balance_Owed__c',
            31 => 'Accounts_Validation_Date__c',
            32 => 'Interest_Rate__c',
            33 => 'Last_Payment_Date__c',
            34 => 'Last_Payment_Amount__c',
            35 => 'Last_Payment_Date_2__c',
            36 => 'Last_Payment_Amount_2__c',
            37 => 'Last_Payment_Date_3__c',
            38 => 'Last_Payment_Amount_3__c',
            39 => 'Last_Statement_Date__c',
            40 => 'Last_Statement_Amount__c',
            41 => 'Last_Statement_Date_2__c',
            42 => 'Last_Statement_Amount_2__c',
            43 => 'Last_Statement_Date_3__c',
            44 => 'Last_Statement_Amount_3__c',
            45 => 'Claim_Amount__c'
        };
        List<CTB_Staging__c> stagingRecordsToCreate = new List<CTB_Staging__c>();
        List<String> csvRows = csvContents.split('\n');
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split(',');
            CTB_Staging__c stagingRecord = new CTB_Staging__c();
            // System.debug(csvRows[i]);
            for (Integer j = 4; j <= 45; j++) {
                if (indexFieldMap.containsKey(j)) {
                    stagingRecord.put(indexFieldMap.get(j), csvColumns[j]);
                }
            }
            System.debug(stagingRecord);
            stagingRecordsToCreate.add(stagingRecord);
        }
    }
}
