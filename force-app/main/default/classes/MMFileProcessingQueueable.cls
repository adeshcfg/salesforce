/**
 * @description       : Queueable class to parse csv, validate fields and create CTB Staging records for MM accounts
 * @author            : adeshi@a5econsulting.net
 * @last modified on  : 01-07-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class MMFileProcessingQueueable implements Queueable, Database.AllowsCallouts {
    // List of file names to process
    public List<String> fileNames = new List<String>();
    // Identifier to know type of file, Account or Payment
    public String fileIdentifier = '';

    public MMFileProcessingQueueable(List<String> fileNames, String fileIdentifier) {
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
                processMMStagingAccounts(csvContents, docStorage);
            }
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
                System.enqueueJob(new MMFileProcessingQueueable(fileNames, System.Label.CTB_Insolvency_Account));
            }
        } catch (Exception e) {
            System.debug('Exception in MMFileProcessingQueueable ' + e.getMessage() + e.getStackTraceString());
            CTBFileProcessingQueueable.createInsolvencyError(e.getMessage(), e.getStackTraceString());
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
            CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
            return null;
        }
    }

    /**
     * @description : Parse, validate and create Staging records for Insolvency Accounts
     * @author adeshi@a5econsulting.net | 11-23-2023
     * @param csvContents
     * @param docStorage
     **/
    public static void processMMStagingAccounts(String csvContents, Document_Storage__c docStorage) {
        List<CTB_Staging__c> stagingRecordsToCreate = new List<CTB_Staging__c>();
        Map<Id, Insolvency_Account__c> accountRecordsToUpdateMap = new Map<Id, Insolvency_Account__c>();
        Map<String, Insolvency__c> insolvencyRecordsToUpdateMap = new Map<String, Insolvency__c>();
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
            if (csvColumns.size() != 51) {
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
                SELECT Id, Correlation_Id__c, Insolvency_Status__c, Debtor_1_Estate_Number__c, Debtor_2_Estate_Number__c, Debtor__c, Co_Debtor__c, Insolvency__c
                FROM Insolvency_Account__c
                WHERE Correlation_Id__c IN :correlationIdSet
            ]) {
                mapCorrelationIdAccount.put(acc.Correlation_Id__c, acc);
            }
        }
        if (!stagingRecordsToCreate.isEmpty() && !invalidFile) {
            for (CTB_Staging__c stagingAcc : stagingRecordsToCreate) {
                Insolvency_Account__c accountToUpdate = new Insolvency_Account__c();
                String accountId = '';
                // If no account exists with correlation Id provided in the csv
                if (!mapCorrelationIdAccount.containsKey(stagingAcc.Correlation_Id__c) && !stagingAcc.Error_Message__c.contains('No Correlation Id provided')) {
                    stagingAcc.Status__c = 'Error';
                    stagingAcc.Error_Message__c += '; No Account with given Correlation Id found in SF';
                } else {
                    accountId = mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Id;
                }
                // Check if status can be updated to PoC Details Provided
                if (
                    stagingAcc.Status__c != 'Error' &&
                    !validOldInsolvencyStatuses.contains(mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Insolvency_Status__c)
                ) {
                    accountToUpdate.Id = accountId;
                    accountToUpdate.CTB_Update_File_Timestamp__c = Datetime.now();
                    accountToUpdate.CTB_Update_Filename__c = docStorage.Document_Name__c;
                    accountRecordsToUpdateMap.put(accountToUpdate.Id, accountToUpdate);
                    continue;
                }
                // Remove ; from start of the string if it starts with ;
                if (String.isNotBlank(stagingAcc.Error_Message__c)) {
                    stagingAcc.Error_Message__c = stagingAcc.Error_Message__c.removeStart(';');
                }
                // If validation was successfull
                if (stagingAcc.Status__c != 'Error') {
                    // Check for duplicate accounts and ignore current row if existing account was not rejected as NMAT
                    // This is only for duplicate account scenario for multiple debtors
                    if (
                        accountRecordsToUpdateMap.containsKey(accountId) &&
                        String.isBlank(accountRecordsToUpdateMap.get(accountId).CTB_Reject_Reason_Code__c) &&
                        stagingAcc.CTB_Reject_Reason_Code__c == 'NMAT'
                    ) {
                        CTBFileProcessingQueueable.checkNoMatchDebtor(
                            accountRecordsToUpdateMap.get(accountId),
                            mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c),
                            stagingAcc
                        );
                        continue;
                    }
                    if (String.isBlank(stagingAcc.CTB_Reject_Reason_Code__c)) {
                        accountToUpdate = CTBFileValidationUtility.updateMmInsolvencyAccount(stagingAcc);
                    }
                    accountToUpdate.Id = accountId;
                    accountToUpdate.CTB_Update_File_Timestamp__c = Datetime.now();
                    accountToUpdate.CTB_Update_Filename__c = docStorage.Document_Name__c;
                    accountToUpdate.CTB_Reject_Reason_Code__c = stagingAcc.CTB_Reject_Reason_Code__c;
                    if (String.isBlank(accountToUpdate.CTB_Reject_Reason_Code__c)) {
                        accountToUpdate.Insolvency_Status__c = 'PoC Details Provided';
                    }
                    // Only update no match fields if account has co debtor
                    if (
                        accountToUpdate.CTB_Reject_Reason_Code__c == 'NMAT' &&
                        String.isNotBlank(mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Co_Debtor__c)
                    ) {
                        // Default fields to false
                        accountToUpdate.No_Match_Debtor__c = false;
                        accountToUpdate.No_Match_Co_Debtor__c = false;
                        CTBFileProcessingQueueable.checkNoMatchDebtor(accountToUpdate, mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c), stagingAcc);
                    }
                    // When duplicate account with NMAT reject code is already processed preserve it's no match fields
                    if (
                        accountRecordsToUpdateMap.containsKey(accountId) &&
                        String.isNotBlank(accountRecordsToUpdateMap.get(accountId).CTB_Reject_Reason_Code__c) &&
                        accountRecordsToUpdateMap.get(accountId).CTB_Reject_Reason_Code__c == 'NMAT'
                    ) {
                        // If current row is also NMAT then don't mark any debtor as no match
                        if (accountToUpdate.CTB_Reject_Reason_Code__c == 'NMAT') {
                            accountToUpdate.No_Match_Debtor__c = false;
                            accountToUpdate.No_Match_Co_Debtor__c = false;
                        } else {
                            accountToUpdate.No_Match_Debtor__c = accountRecordsToUpdateMap.get(accountId).No_Match_Debtor__c;
                            accountToUpdate.No_Match_Co_Debtor__c = accountRecordsToUpdateMap.get(accountId).No_Match_Co_Debtor__c;
                        }
                    }
                    accountRecordsToUpdateMap.put(accountToUpdate.Id, accountToUpdate);
                    if (stagingAcc.CTB_Date_of_Birth__c != null) {
                        String insolvencyId = mapCorrelationIdAccount.get(stagingAcc.Correlation_Id__c).Insolvency__c;
                        insolvencyRecordsToUpdateMap.put(
                            insolvencyId,
                            new Insolvency__c(Id = insolvencyId, Debtor_1_Date_of_Birth__c = stagingAcc.CTB_Date_of_Birth__c)
                        );
                    }
                }
            }
            try {
                Database.insert(stagingRecordsToCreate);
            } catch (DmlException dex) {
                System.debug('Error updating stging records ' + dex.getDmlMessage(0));
                docStorage.File_Processing_Status__c = 'Failed';
                docStorage.File_Processing_Error__c = dex.getDmlMessage(0).length() > 255 ? dex.getDmlMessage(0).substring(0, 255) : dex.getDmlMessage(0);
                update docStorage;
                CTBFileProcessingQueueable.createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
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
                CTBFileProcessingQueueable.createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
                return;
            }
        }
        if (!insolvencyRecordsToUpdateMap.values().isEmpty()) {
            try {
                InsolvencyTriggerHandler.runInsolvencyTrigger = false;
                update insolvencyRecordsToUpdateMap.values();
                InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            } catch (DmlException dex) {
                System.debug('Error updating Insolvency records ' + dex.getDmlMessage(0));
                docStorage.File_Processing_Status__c = 'Failed';
                docStorage.File_Processing_Error__c = dex.getDmlMessage(0).length() > 255 ? dex.getDmlMessage(0).substring(0, 255) : dex.getDmlMessage(0);
                update docStorage;
                CTBFileProcessingQueueable.createInsolvencyError(dex.getDmlMessage(0), dex.getStackTraceString());
                return;
            }
        }
        Integer successRecordCount = accountRecordsToUpdateMap.size();
        Integer failedRecordCount = stagingRecordsToCreate.size() - successRecordCount;
        if (!invalidFile) {
            docStorage.File_Processing_Status__c = 'Processed';
            CTBFileValidationUtility.sendEmail(
                'Account file successfully processed',
                'File ' + docStorage.Document_Name__c + ' was successfully processed',
                System.Label.CTB_File_Processing_Emails
            );
        }
        docStorage.Comment__c = 'Success Records : ' + String.valueOf(successRecordCount) + '\n' + 'Failed Records : ' + String.valueOf(failedRecordCount);
        // Update doc storage with processing status and error message if failed
        update docStorage;
    }
}
