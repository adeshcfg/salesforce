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
            CTB_Staging__c recordToCreate = CTBFileValidationUtility.validateCTBStagingRecord(csvColumns);
            recordToCreate.CTB_Update_Filename__c = docStorage.Document_Name__c;
            stagingRecordsToCreate.add(recordToCreate);
        }
        if (!stagingRecordsToCreate.isEmpty()) {
            insert stagingRecordsToCreate;
        }
    }
}
