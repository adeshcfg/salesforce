/**
 * @description       : Queueable class to parse CSV and insert parsed records
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 03-18-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class BulkDataloadQueueable implements Queueable {
    // Max number of records to be inserted in a single job
    public static final Integer MAX_NUMBER_OF_RECORDS_PER_JOB = 10000;
    // Max number of records that can be inserted overall, after this limit it will stop enqueueing jobs
    public static final Integer MAX_RECORD_LIMIT = 50000;
    public static final String ALLOCATE_DOC_TYPE = 'Product Allocation File';
    public static final String RECALL_DOC_TYPE = 'Account Status Update File';
    public List<String> recordListString = new List<String>();
    public Integer startingIndex = 0;
    public Document_Storage__c documentStorage;
    public String typeOfOperation;

    public BulkDataloadQueueable(String typeOfOperation, List<String> recordListString, Integer startingIndex, Document_Storage__c documentStorage) {
        this.typeOfOperation = typeOfOperation;
        this.recordListString = recordListString;
        this.startingIndex = startingIndex;
        this.documentStorage = documentStorage;
    }

    public void execute(QueueableContext context) {
        try {
            switch on typeOfOperation {
                when 'PARSE_CSV' {
                    parseCSVToStringList(documentStorage);
                }
                when 'INSERT_DATA' {
                    createAndInsertRecordList(recordListString, startingIndex, documentStorage);
                }
            }
        } catch (Exception e) {
            System.debug('Exception in BulkDataloadQueueable ' + e.getMessage());
            Insolvency_Error__c error = new Insolvency_Error__c(Error__c = e.getMessage() + e.getStackTraceString());
            insert error;
        }
    }

    /**
     * @description : Convert CSV to List of Strings with every CSV row being an element of array, will be used further to create records
     * @author adeshi@a5econsulting.net | 03-22-2023
     * @param documentStorage
     **/
    public static void parseCSVToStringList(Document_Storage__c documentStorage) {
        ContentDocumentLink con = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :documentStorage.Id
            LIMIT 1
        ];
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId = :con.ContentDocumentId];
        String csvContents = cv.VersionData.toString();
        CSVIterator iterator = new CSVIterator(csvContents, '\n');
        List<String> csvStringList = new List<String>();
        // Add every row of CSV except the first header row into an array
        while (iterator.hasNext()) {
            String row = iterator.next().trim();
            if (!(row.containsIgnoreCase('Data_Id__c') || row.containsIgnoreCase('name__c'))) {
                csvStringList.add(row);
            }
        }
        delete [SELECT Id FROM ContentDocument WHERE Id = :con.ContentDocumentId];
        if (!csvStringList.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new BulkDataloadQueueable('INSERT_DATA', csvStringList, 0, documentStorage));
        }
    }

    /**
     * @description : Method to convert list of CSV rows to list of Product Staging records and insert in chunks of 10000 max
     * @author adeshi@a5econsulting.net | 03-22-2023
     * @param recordListString
     * @param startingIndex
     * @param documentStorage
     **/
    public static void createAndInsertRecordList(List<String> recordListString, Integer startingIndex, Document_Storage__c documentStorage) {
        List<Product_Staging__c> recordsToInsert = new List<Product_Staging__c>();
        // Generate end index for iteration on CSV String list, end index can be greater than start index by 10000 at max due to DML limit
        Integer endingIndex = startingIndex + MAX_NUMBER_OF_RECORDS_PER_JOB < recordListString.size()
            ? startingIndex + MAX_NUMBER_OF_RECORDS_PER_JOB
            : recordListString.size();
        // Execute different metohds based on Document type as CSV column mapping is different
        if (documentStorage.Document_Type__c == ALLOCATE_DOC_TYPE) {
            for (Integer i = startingIndex; i < endingIndex; i++) {
                // Split comma separated string of data into an array
                List<String> csvData = recordListString[i].split(',');
                // Check for empty row
                if (!csvData.isEmpty()) {
                    recordsToInsert.add(createAllocationRecord(csvData, documentStorage.Id));
                }
            }
        } else if (documentStorage.Document_Type__c == RECALL_DOC_TYPE) {
            for (Integer i = startingIndex; i < endingIndex; i++) {
                // Split comma separated string of data into an array
                List<String> csvData = recordListString[i].split(',');
                // Check for empty row
                if (!csvData.isEmpty()) {
                    recordsToInsert.add(createRecallRecord(csvData, documentStorage.Id));
                }
            }
        } else if (documentStorage.Document_Type__c == DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE) {
            for (Integer i = startingIndex; i < endingIndex; i++) {
                // Split comma separated string of data into an array
                List<String> csvData = recordListString[i].split(',');
                // Check for empty row
                if (!csvData.isEmpty()) {
                    recordsToInsert.add(createBuybackPutbackRecord(csvData, documentStorage.Id));
                }
            }
        } else if (documentStorage.Document_Type__c == DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE) {
            for (Integer i = startingIndex; i < endingIndex; i++) {
                // Split comma separated string of data into an array
                List<String> csvData = recordListString[i].split(',');
                // Check for empty row
                if (!csvData.isEmpty() && csvData.size() == 2) {
                    recordsToInsert.add(createProductStatusRecord(csvData, documentStorage.Id));
                }
            }
        }
        try {
            if (!recordsToInsert.isEmpty()) {
                Database.insert(recordsToInsert);
            }
        } catch (DmlException de) {
            System.debug('Exception during record insertion ' + de.getDmlMessage(0));
        }
        if (!Test.isRunningTest()) {
            // If end index is >= MAX_RECORD_LIMIT or equal to the input record list we have inserted all records, can enqueue the Batch now else enqueue job to insert remaining records
            if (endingIndex >= MAX_RECORD_LIMIT || endingIndex == recordListString.size()) {
                Database.executeBatch(
                    new CFG_ProcessBulkAPIResult('', documentStorage.Id, documentStorage.Work_Assignment__c, documentStorage.Document_Type__c, documentStorage)
                );
            } else {
                System.enqueueJob(new BulkDataloadQueueable('INSERT_DATA', recordListString, endingIndex, documentStorage));
            }
        }
    }

    /**
     * @description : Method to map csv columns to correct Product Staging fields in case of Allocation
     * @author adeshi@a5econsulting.net | 03-23-2023
     * @param csvData
     * @return List<Product_Staging__c>
     **/
    public static Product_Staging__c createAllocationRecord(List<String> csvData, String documentStorageId) {
        Product_Staging__c psRecord = new Product_Staging__c();
        // Map array indexes to Product Staging fields
        psRecord.Data_Id__c = csvData[0];
        if (csvData[1] != null || csvData[1] != '') {
            psRecord.Placement_Agency__c = csvData[1];
        } else {
            psRecord.Placement_Agency__c = '';
        }
        if (csvData[2] != null && csvData[2] != '') {
            psRecord.Pool_Name__c = csvData[2];
        } else {
            psRecord.Pool_Name__c = '';
        }
        if (csvData[3] != null && csvData[3] != '') {
            psRecord.Current_Commission_Rate__c = Decimal.valueOf(csvData[3]);
        } else {
            psRecord.Current_Commission_Rate__c = 0.00;
        }
        if (csvData[4] != null && csvData[4] != '') {
            psRecord.Placed_Commission_Rate__c = Decimal.valueOf(csvData[4]);
        } else {
            psRecord.Placed_Commission_Rate__c = 0.00;
        }
        if (csvData[5] != null && csvData[5] != '') {
            psRecord.Current_Settlement_Rate__c = Decimal.valueOf(csvData[5]);
        } else {
            psRecord.Current_Settlement_Rate__c = 0.00;
        }
        if (csvData[6] != null && csvData[6] != '') {
            psRecord.Placed_Settlement_Rate__c = Decimal.valueOf(csvData[6]);
        } else {
            psRecord.Placed_Settlement_Rate__c = 0.00;
        }
        if (csvData.size() >= 8) {
            psRecord.Value_Tier_at_Time_of_Placement__c = csvData[7];
        } else {
            psRecord.Value_Tier_at_Time_of_Placement__c = '';
        }
        psRecord.Identifier__c = documentStorageId;
        return psRecord;
    }

    /**
     * @description : Method to map csv columns to correct Product Staging fields in case of Recall
     * @author adeshi@a5econsulting.net | 03-23-2023
     * @param csvData
     * @return List<Product_Staging__c>
     **/
    public static Product_Staging__c createRecallRecord(List<String> csvData, String documentStorageId) {
        Product_Staging__c psRecord = new Product_Staging__c();
        // Map array indexes to Product Staging fields
        psRecord.Name__c = csvData[0];
        if (csvData[1] != null || csvData[1] != '') {
            psRecord.Placement_Status_Code__c = csvData[1];
        } else {
            psRecord.Placement_Status_Code__c = '';
        }
        if (csvData.size() >= 3) {
            psRecord.Status_Changed_Date__c = csvData[2];
        } else {
            psRecord.Status_Changed_Date__c = '';
        }
        psRecord.Identifier__c = documentStorageId;
        return psRecord;
    }

    public static Product_Staging__c createBuybackPutbackRecord(List<String> csvData, String documentStorageId) {
        List<String> validPurchaseStatuses = new List<String>{
            DisplayBuybackPutbackStagingController.BUYBACK_APPROVED,
            DisplayBuybackPutbackStagingController.BUYBACK_REJECTED
        };
        Product_Staging__c psRecord = new Product_Staging__c();
        // Map array indexes to Product Staging fields
        psRecord.Data_Id__c = csvData[0];
        if (String.isNotBlank(csvData[1])) {
            psRecord.Putback_Buyback_Amount__c = Decimal.valueOf(csvData[1]);
        }
        if (String.isNotBlank(csvData[2]) && validPurchaseStatuses.contains(csvData[2])) {
            psRecord.Purchase_Status__c = csvData[2];
        }
        if (csvData.size() > 3 && String.isNotBlank(csvData[3])) {
            psRecord.Product_Status__c = csvData[3];
        }
        if (csvData.size() > 4 && String.isNotBlank(csvData[4])) {
            if (csvData[4].length() <= 255) {
                psRecord.Rejection_Reason__c = csvData[4];
            } else {
                psRecord.Rejection_Reason__c = 'Field length exceeded';
            }
        }
        psRecord.Identifier__c = documentStorageId;
        return psRecord;
    }

    /**
     * @description : Method to map csv columns to correct Product Staging fields in case of Product Status update file
     * @author adesh.ikhar@canaccede.com | 01-06-2025
     * @param csvData
     * @param documentStorageId
     * @return Product_Staging__c
     **/
    public static Product_Staging__c createProductStatusRecord(List<String> csvData, String documentStorageId) {
        Product_Staging__c psRecord = new Product_Staging__c();
        // Map array indexes to Product Staging fields
        psRecord.Data_Id__c = csvData[0];
        if (String.isNotBlank(csvData[1])) {
            psRecord.Product_Status__c = csvData[1];
        }
        psRecord.Identifier__c = documentStorageId;
        return psRecord;
    }
}
