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
            switch on fileIdentifier {
                when 'System.Label.CTB_Insolvency_Account' {
                    // parseCSVToStringList(documentStorage);
                }
                when 'System.Label.CTB_Payment' {
                    // createAndInsertRecordList(recordListString, startingIndex, documentStorage);
                }
            }
        } catch (Exception e) {
            System.debug('Exception in CTBFileProcessingQueueable ' + e.getStackTraceString());
        }
    }

    public static void processInsolvencyAccounts(String csvContents, Document_Storage__c docStorage) {
        List<String> csvRows = csvContents.split('\n');
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            // List<String> csvColumns = csvRows[i].split(',');
            System.debug(csvRows[i]);
        }
    }
}
