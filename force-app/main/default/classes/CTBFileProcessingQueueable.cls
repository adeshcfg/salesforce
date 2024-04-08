/**
 * @description       : Queueable class to parse csv, validate fields and create CTB Staging records
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 11-23-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
public with sharing class CTBFileProcessingQueueable implements Queueable {
    // Identifier to know type of file, Account or Payment
    public String fileIdentifier = '';
    // Salesforce document record Id where the csv is stored
    public String documentId = '';
    // Document storage record created after receiving file from CTB
    public Document_Storage__c docStorage = new Document_Storage__c();

    public CTBFileProcessingQueueable(String fileIdentifier, String documentId, Document_Storage__c docStorage) {
        this.fileIdentifier = fileIdentifier;
        this.documentId = documentId;
        this.docStorage = docStorage;
    }

    /**
     * @description : Execute method to call correct method based on file type
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param context
     **/
    public void execute(QueueableContext context) {
        try {
            Document fileToProccess = [SELECT Id, Body FROM Document WHERE Id = :documentId];
            String csvContents = fileToProccess.Body.toString();
            if (fileIdentifier == System.Label.CTB_Insolvency_Account) {
                System.debug('Account processing');
                processCTBStagingAccounts(csvContents, docStorage);
            } else if (fileIdentifier == System.Label.CTB_Payment) {
                processCTBStagingPayments(csvContents, docStorage);
                System.debug('Payment processing');
            }
        } catch (Exception e) {
            System.debug('Exception in CTBFileProcessingQueueable ' + e.getStackTraceString());
        }
    }

    /**
     * @description : Parse, validate and create Staging records for Insolvency Accounts
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvContents
     * @param docStorage
     **/
    public static void processCTBStagingAccounts(String csvContents, Document_Storage__c docStorage) {
        List<CTB_Staging__c> stagingRecordsToCreate = new List<CTB_Staging__c>();
        List<Insolvency_Account__c> accountRecordsToUpdate = new List<Insolvency_Account__c>();
        List<String> correlationIds = new List<String>();
        Map<String, String> mapCorrelationIdSfId = new Map<String, String>();
        List<String> csvRows = csvContents.split('\n');
        // This loop is to get all the correlation Ids which will be further used to check if these exist in sf
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split(',');
            // Store all correlation Ids to query if accounts exist for these correlation Ids
            if (String.isNotBlank(csvColumns[26])) {
                correlationIds.add(csvColumns[26]);
            }
        }
        // Query accounts with the correlation Ids
        for (Insolvency_Account__c acc : [SELECT Id, Correlation_ID__c FROM Insolvency_Account__c WHERE Correlation_ID__c IN :correlationIds]) {
            mapCorrelationIdSfId.put(acc.Correlation_ID__c, acc.Id);
        }
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split(',');
            CTB_Staging__c recordToCreate = CTBFileValidationUtility.validateAccountCTBStagingRecord(csvColumns);
            recordToCreate.CTB_Update_Filename__c = docStorage.Document_Name__c;
            // If no account exists with the correlation Id in sf
            if (String.isNotBlank(csvColumns[26]) && !mapCorrelationIdSfId.containsKey(csvColumns[26])) {
                recordToCreate.Status__c = 'Error';
                recordToCreate.Error_Message__c += 'No account found with the Correlation Id';
            }
            stagingRecordsToCreate.add(recordToCreate);
            // If validation was successfull
            if (recordToCreate.Status__c != 'Error') {
                Insolvency_Account__c accountToUpdate = CTBFileValidationUtility.updateInsolvencyAccount(recordToCreate);
                accountToUpdate.Id = mapCorrelationIdSfId.get(recordToCreate.Correlation_ID__c);
                accountRecordsToUpdate.add(accountToUpdate);
            }
        }
        if (!stagingRecordsToCreate.isEmpty()) {
            insert stagingRecordsToCreate;
        }
        if (!accountRecordsToUpdate.isEmpty()) {
            update accountRecordsToUpdate;
        }
    }

    /**
     * @description : Parse, validate and create Staging records for Insolvency Payments
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvContents
     * @param docStorage
     **/
    public static void processCTBStagingPayments(String csvContents, Document_Storage__c docStorage) {
        List<CTB_Staging__c> stagingRecordsToCreate = new List<CTB_Staging__c>();
        List<String> csvRows = csvContents.split('\n');
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split(',');
            CTB_Staging__c recordToCreate = CTBFileValidationUtility.validatePaymentCTBStagingRecord(csvColumns);
            recordToCreate.CTB_Update_Filename__c = docStorage.Document_Name__c;
            stagingRecordsToCreate.add(recordToCreate);
        }
        if (!stagingRecordsToCreate.isEmpty()) {
            insert stagingRecordsToCreate;
        }
    }
}
