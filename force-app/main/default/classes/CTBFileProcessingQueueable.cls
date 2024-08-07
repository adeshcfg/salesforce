/**
 * @description       : Queueable class to parse csv, validate fields and create CTB Staging records
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 08-07-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public with sharing class CTBFileProcessingQueueable implements Queueable, Database.AllowsCallouts {
    // List of file names to process
    public List<String> fileNames = new List<String>();
    // Identifier to know type of file, Account or Payment
    public String fileIdentifier = '';

    public CTBFileProcessingQueueable(List<String> fileNames, String fileIdentifier) {
        this.fileNames = fileNames;
        this.fileIdentifier = fileIdentifier;
    }

    /**
     * @description : Execute method to call correct method based on file type
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param context
     **/
    public void execute(QueueableContext context) {
        try {
            // Call SFTP API to get the file uploaded in SF as a content version record and get it's Id
            String documentId = CTBGetFileApiQueueable.getDocumentId(fileNames[0]);
            if (String.isBlank(documentId)) {
                return;
            }
            // Convert CSV to string
            Document fileToProccess = [SELECT Name, ContentType, Body FROM Document WHERE Id = :documentId];
            String csvContents = fileToProccess.Body.toString();
            // Create Doc storage record with received file details
            Document_Storage__c docStorage = createDocStorage(fileNames[0], fileToProccess.ContentType);
            if (fileIdentifier == System.Label.CTB_Insolvency_Account) {
                processCTBStagingAccounts(csvContents, docStorage);
            } /*  else if (fileIdentifier == System.Label.CTB_Payment) {
                processCTBStagingPayments(csvContents, docStorage);
                System.debug('Payment processing');
            } */
            // Remove the file which was processed
            fileNames.remove(0);
            delete fileToProccess;
            // This will be the last queueable in case of multiple unprocessed files
            if (fileNames.isEmpty()) {
                // Query and delete successfull records
                List<CTB_Staging__c> stagingRecordsToDelete = [SELECT Id FROM CTB_Staging__c WHERE Status__c != 'Error'];
                if (!stagingRecordsToDelete.isEmpty() && !Test.isRunningTest()) {
                    System.enqueueJob(new BulkDmlQueueable(stagingRecordsToDelete, 0, 'Delete'));
                }
                return;
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(new CTBFileProcessingQueueable(fileNames, System.Label.CTB_Insolvency_Account));
            }
        } catch (Exception e) {
            System.debug('Exception in CTBFileProcessingQueueable ' + e.getMessage() + e.getStackTraceString());
            createInsolvencyError(e.getMessage(), e.getStackTraceString());
        }
    }

    /**
     * @description : Method to create document storage record for incoming file
     * @author adesh.ikhar@canaccede.com | 05-07-2024
     * @param fileName
     * @param extension
     * @return Document_Storage__c
     **/
    public static Document_Storage__c createDocStorage(String fileName, String extension) {
        // Create document storage status associated to the file
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = 'Insolvency Daily Update';
        docInfo.Document_Extension__c = extension;
        docInfo.Document_Name__c = fileName;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('CTB').getRecordTypeId();
        try {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            Database.insert(docInfo);
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return docInfo;
        } catch (DmlException ex) {
            System.debug('DMLException in createDocStorage ' + ex.getDmlMessage(0));
            createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            return null;
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
        Map<Id, Insolvency_Account__c> accountRecordsToUpdateMap = new Map<Id, Insolvency_Account__c>();
        Set<String> correlationIdSet = new Set<String>();
        Map<String, Insolvency_Account__c> mapCorrelationIdAccount = new Map<String, Insolvency_Account__c>();
        List<String> validOldInsolvencyStatuses = System.Label.CTB_Valid_Insolvency_Statuses.split(',');
        Boolean invalidFile = false;
        List<String> csvRows = csvContents.split('\n');
        // Check for number of rows, should have atleast 3 rows
        if (csvRows.size() < 3) {
            docStorage = CTBFileValidationUtility.updateDocStorageDetails(
                docStorage,
                'Failed',
                'File should contain atleast 3 rows. Header, record detail and trailer.'
            );
            update docStorage;
            return;
        }
        // Validate header and trailer
        String headerTrailerValidationMsg = CTBFileValidationUtility.validateHeaderTrailer(csvRows[0], csvRows[csvRows.size() - 1], csvRows.size());
        if (String.isNotBlank(headerTrailerValidationMsg)) {
            docStorage = CTBFileValidationUtility.updateDocStorageDetails(docStorage, 'Failed', headerTrailerValidationMsg);
            update docStorage;
            return;
        }
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            List<String> csvColumns = CTBFileValidationUtility.parseCsv(csvRows[i]);
            if (csvColumns.size() != 48) {
                docStorage = CTBFileValidationUtility.updateDocStorageDetails(
                    docStorage,
                    'Failed',
                    'Invalid number of columns for row number ' + (i + 1) + ', please check the file'
                );
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
            for (Insolvency_Account__c acc : [
                SELECT Id, Correlation_Id__c, Insolvency_Status__c
                FROM Insolvency_Account__c
                WHERE Correlation_Id__c IN :correlationIdSet
            ]) {
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
                // Check if status can be updated to PoC Details Provided
                if (
                    stagingAcc.Status__c != 'Error' &&
                    !validOldInsolvencyStatuses.contains(mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Insolvency_Status__c)
                ) {
                    stagingAcc.Status__c = 'Error';
                    stagingAcc.Error_Message__c +=
                        '; Current Insolvency status is ' +
                        mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Insolvency_Status__c +
                        ', so cannot update the record';
                }
                // Remove ; from start of the string if it starts with ;
                if (String.isNotBlank(stagingAcc.Error_Message__c)) {
                    stagingAcc.Error_Message__c = stagingAcc.Error_Message__c.removeStart(';');
                }
                // If validation was successfull
                if (stagingAcc.Status__c != 'Error') {
                    String accountId = mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Id;
                    // Check for duplicate accounts and ignore current row if existing account was not rejected as NMAT
                    // This is only for duplicate account scenario for multiple debtors
                    if (
                        accountRecordsToUpdateMap.containsKey(accountId) &&
                        String.isBlank(accountRecordsToUpdateMap.get(accountId).CTB_Reject_Reason_Code__c) &&
                        stagingAcc.CTB_Reject_Reason_Code__c == 'NMAT'
                    ) {
                        continue;
                    }
                    Insolvency_Account__c accountToUpdate = new Insolvency_Account__c();
                    if (String.isBlank(stagingAcc.CTB_Reject_Reason_Code__c)) {
                        accountToUpdate = CTBFileValidationUtility.updateInsolvencyAccount(stagingAcc);
                    }
                    accountToUpdate.Id = accountId;
                    accountToUpdate.CTB_Update_File_Timestamp__c = Datetime.now();
                    accountToUpdate.CTB_Update_Filename__c = docStorage.Document_Name__c;
                    accountToUpdate.CTB_Reject_Reason_Code__c = stagingAcc.CTB_Reject_Reason_Code__c;
                    updateAccountStatusAndReason(accountToUpdate, mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Insolvency_Status__c);
                    accountRecordsToUpdateMap.put(accountToUpdate.Id, accountToUpdate);
                }
            }
            try {
                Database.insert(stagingRecordsToCreate);
            } catch (DmlException dex) {
                System.debug('Error updating stging records ' + dex.getDmlMessage(0));
                docStorage.File_Processing_Status__c = 'Failed';
                docStorage.File_Processing_Error__c = dex.getDmlMessage(0).length() > 255 ? dex.getDmlMessage(0).substring(0, 255) : dex.getDmlMessage(0);
                update docStorage;
                createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
            }
        }
        if (!accountRecordsToUpdateMap.values().isEmpty()) {
            try {
                update accountRecordsToUpdateMap.values();
            } catch (DmlException dex) {
                System.debug('Error updating account records ' + dex.getDmlMessage(0));
                docStorage.File_Processing_Status__c = 'Failed';
                docStorage.File_Processing_Error__c = dex.getDmlMessage(0).length() > 255 ? dex.getDmlMessage(0).substring(0, 255) : dex.getDmlMessage(0);
                update docStorage;
                createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
                return;
            }
        }
        Integer successRecordCount = accountRecordsToUpdateMap.size();
        Integer failedRecordCount = stagingRecordsToCreate.size() - successRecordCount;
        if (!invalidFile) {
            docStorage.File_Processing_Status__c = 'Processed';
        }
        docStorage.Comment__c = 'Success Records : ' + String.valueOf(successRecordCount) + '\n' + 'Failed Records : ' + String.valueOf(failedRecordCount);
        CTBFileValidationUtility.sendEmail(
            'CTB Account file successfully processed',
            'File ' + docStorage.Document_Name__c + ' was successfully processed',
            System.Label.CTB_File_Processing_Emails
        );
        // Update doc storage with processing status and error message if failed
        update docStorage;
    }

    /**
     * @description : Method to update correct account status as per criteria
     * @author adesh.ikhar@canaccede.com | 05-20-2024
     * @param accountToUpdate
     * @param currentStatus
     * @return Insolvency_Account__c
     **/
    public static Insolvency_Account__c updateAccountStatusAndReason(Insolvency_Account__c accountToUpdate, String currentStatus) {
        // Only update status to PoC Details Provided when reject code is null
        if (String.isBlank(accountToUpdate.CTB_Reject_Reason_Code__c)) {
            accountToUpdate.Insolvency_Status__c = 'PoC Details Provided';
        }
        if (accountToUpdate.Balance_Owed__c < 100) {
            accountToUpdate.Insolvency_Status__c = 'No PoC Required';
            accountToUpdate.Reason_for_No_PoC_Required_Dropdown__c = 'Below Threshold';
        }
        if (accountToUpdate.CTB_Reject_Reason_Code__c == 'SOLD') {
            accountToUpdate.Insolvency_Status__c = 'No PoC Required';
            accountToUpdate.Reason_for_No_PoC_Required_Dropdown__c = 'Account Sold';
        }
        if (accountToUpdate.CTB_Reject_Reason_Code__c == 'DDEC') {
            accountToUpdate.Insolvency_Status__c = 'No PoC Required';
            accountToUpdate.Reason_for_No_PoC_Required_Dropdown__c = 'Other';
            accountToUpdate.Reason_for_No_PoC_Required__c = 'Deceased';
        }
        if (accountToUpdate.CTB_Reject_Reason_Code__c == 'NMAT') {
            accountToUpdate.Insolvency_Status__c = 'For Owner Review';
            accountToUpdate.Insolvency_Sub_Status__c = 'No Match';
        }
        // Update status only if previous status was For Owner Review
        if (currentStatus != 'For Owner Review') {
            accountToUpdate.Insolvency_Status__c = currentStatus;
        }
        // Clear error message field whenever status of account was updated
        if (accountToUpdate.Insolvency_Status__c != currentStatus) {
            accountToUpdate.Error_Message__c = null;
        }
        return accountToUpdate;
    }

    /**
     * @description : Method to create Insolvency error record in case of exception
     * @author adesh.ikhar@canaccede.com | 05-20-2024
     * @param errorMsg
     * @param stackTrace
     **/
    public static void createInsolvencyError(String errorMsg, String stackTrace) {
        Insolvency_Error__c insolErrorData = new Insolvency_Error__c();
        insolErrorData.Error__c = 'File processing failed due to' + '\n' + errorMsg + ' ' + stackTrace;
        Database.insert(insolErrorData);
        CTBFileValidationUtility.sendEmail('CTB Account file processing failed', insolErrorData.Error__c, System.Label.CTB_File_Processing_Emails);
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