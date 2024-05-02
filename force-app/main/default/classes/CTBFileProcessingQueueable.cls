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
            System.debug('Exception in CTBFileProcessingQueueable ' + e.getMessage() + e.getStackTraceString());
            createInsolvencyError(e.getMessage(), e.getStackTraceString());
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
        Set<String> correlationIdSet = new Set<String>();
        Map<String, Insolvency_Account__c> mapCorrelationIdAccount = new Map<String, Insolvency_Account__c>();
        List<String> csvRows = csvContents.split('\n');
        Boolean invalidFile = false;
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = csvRows[i].split('","');
            // Check for row length/double quotations
            if (csvColumns.size() != 48) {
                docStorage.File_Processing_Status__c = 'Failed';
                docStorage.File_Processing_Error__c =
                    'Invalid number of columns or missing double quotes for all the cells of row number ' +
                    (i + 1) +
                    ', please check the file';
                invalidFile = true;
                break;
            }
            // Get all correlation Ids
            correlationIdSet.add(csvColumns[CTBFileValidationUtility.CORRELATION_ID]);
            CTB_Staging__c recordToCreate = CTBFileValidationUtility.validateAccountCTBStagingRecord(csvColumns);
            recordToCreate.CTB_Update_Filename__c = docStorage.Document_Name__c;
            stagingRecordsToCreate.add(recordToCreate);
        }
        // Query existing account with the correlation Ids from the csv and create map with correlation id and account
        if (!correlationIdSet.isEmpty() && !stagingRecordsToCreate.isEmpty() && !invalidFile) {
            for (Insolvency_Account__c acc : [SELECT Id, Correlation_Id__c FROM Insolvency_Account__c WHERE Correlation_Id__c IN :correlationIdSet]) {
                mapCorrelationIdAccount.put(acc.Correlation_Id__c, acc);
            }
        }
        if (!stagingRecordsToCreate.isEmpty() && !invalidFile) {
            for (CTB_Staging__c stagingAcc : stagingRecordsToCreate) {
                // If no account exists with correlation Id provided in the csv
                if (!mapCorrelationIdAccount.containsKey(stagingAcc.Correlation_Id__c) && !stagingAcc.Error_Message__c.contains('No Correlation Id provided')) {
                    stagingAcc.Status__c = 'Error';
                    stagingAcc.Error_Message__c += '; No Account with given Correlation Id found in SF';
                }
                // Remove ; from start of the string if it starts with ;
                if (String.isNotBlank(stagingAcc.Error_Message__c)) {
                    stagingAcc.Error_Message__c = stagingAcc.Error_Message__c.removeStart(';');
                }
                // If validation was successfull
                if (stagingAcc.Status__c != 'Error') {
                    Insolvency_Account__c accountToUpdate = CTBFileValidationUtility.updateInsolvencyAccount(stagingAcc);
                    accountToUpdate.Id = mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Id;
                    accountToUpdate.CTB_Update_Filename__c = docStorage.Document_Name__c;
                    accountRecordsToUpdate.add(accountToUpdate);
                }
            }
            try {
                Database.insert(stagingRecordsToCreate);
            } catch (DmlException dex) {
                System.debug('Error updating stging records ' + dex.getDmlMessage(0));
                createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
            }
        }
        if (!accountRecordsToUpdate.isEmpty()) {
            try {
                update accountRecordsToUpdate;
                docStorage.File_Processing_Status__c = 'Processed';
            } catch (DmlException dex) {
                System.debug('Error updating account records ' + dex.getDmlMessage(0));
                createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
            }
        }
        // Update doc storage with processing status and error message if failed
        update docStorage;
        // Query and delete successfull records
        List<CTB_Staging__c> stagingRecordsToDelete = [SELECT Id FROM CTB_Staging__c WHERE Status__c != 'Error'];
        if (!stagingRecordsToDelete.isEmpty()) {
            System.enqueueJob(new BulkDmlQueueable(stagingRecordsToDelete, 0, 'Delete'));
        }
    }

    public static void createInsolvencyError(String errorMsg, String stackTrace) {
        Insolvency_Error__c insolErrorData = new Insolvency_Error__c();
        insolErrorData.Error__c = 'Record failed due to' + ' ' + errorMsg + ' ' + stackTrace;
        Database.insert(insolErrorData);
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
