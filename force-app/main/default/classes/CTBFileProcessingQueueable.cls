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
            } /*  else if (fileIdentifier == System.Label.CTB_Payment) {
                processCTBStagingPayments(csvContents, docStorage);
                System.debug('Payment processing');
            } */
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
        List<Insolvency_Account__c> accountRecordsToUpsert = new List<Insolvency_Account__c>();
        List<String> csvRows = csvContents.split('\n');
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = CTBFileValidationUtility.parseCsv(csvRows[i]);
            CTB_Staging__c recordToCreate = CTBFileValidationUtility.validateAccountCTBStagingRecord(csvColumns);
            recordToCreate.CTB_Update_Filename__c = docStorage.Document_Name__c;
            stagingRecordsToCreate.add(recordToCreate);
            // If validation was successfull
            if (recordToCreate.Status__c != 'Error') {
                Insolvency_Account__c accountToUpdate = CTBFileValidationUtility.updateInsolvencyAccount(recordToCreate);
                accountToUpdate.CTB_Update_Filename__c = docStorage.Document_Name__c;
                accountRecordsToUpsert.add(accountToUpdate);
            }
        }
        if (!stagingRecordsToCreate.isEmpty()) {
            Database.insert(stagingRecordsToCreate);
        }
        if (!accountRecordsToUpsert.isEmpty()) {
            try {
                upsert accountRecordsToUpsert Correlation_Id__c;
                docStorage.File_Processing_Status__c = 'Processed';
                update docStorage;
            } catch (DmlException dex) {
                System.debug('Error upserting account records ' + dex.getDmlMessage(0));
            }
        }
        // Query and delete successfull records
        List<CTB_Staging__c> stagingRecordsToDelete = [SELECT Id FROM CTB_Staging__c WHERE Status__c != 'Error'];
        if (!stagingRecordsToDelete.isEmpty()) {
            System.enqueueJob(new BulkDmlQueueable(stagingRecordsToDelete, 0, 'Delete'));
        }
    }

    /**
     * @description : Parse, validate and create Staging records for Insolvency Payments
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvContents
     * @param docStorage
     **/
    /* public static void processCTBStagingPayments(String csvContents, Document_Storage__c docStorage) {
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
    } */
}
