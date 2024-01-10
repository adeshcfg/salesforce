/**
 * @description       : Queueable class to insert more than 10000 records to avoid DML limit, can be modified for other DML operations and generalized more
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 01-10-2024
 * @last modified by  : adeshi@a5econsulting.net
 **/
public class BulkDmlQueueable implements Queueable {
    // Max number of records to be inserted in a single job, not 10000 as we have a update DML after records insertion
    public static final Integer MAX_NUMBER_OF_RECORDS_PER_JOB = 9999;
    // Max number of records that can be inserted overall, after this limit it will stop enqueueing jobs
    public static final Integer MAX_RECORD_LIMIT = 50000;
    public List<SObject> recordList = new List<SObject>();
    public Integer startingIndex = 0;
    public String operation = 'Insert';

    public BulkDmlQueueable(List<SObject> recordList, Integer startingIndex, String operation) {
        this.recordList = recordList;
        this.startingIndex = startingIndex;
        this.operation = operation;
    }

    public void execute(QueueableContext context) {
        List<SObject> recordsToInsert = new List<SObject>();
        // Generate end index for iteration on SObject list, end index can be greater than start index by 10000 at max due to DML limit
        Integer endingIndex = startingIndex + MAX_NUMBER_OF_RECORDS_PER_JOB < recordList.size()
            ? startingIndex + MAX_NUMBER_OF_RECORDS_PER_JOB
            : recordList.size();
        for (Integer i = startingIndex; i < endingIndex; i++) {
            recordsToInsert.add(recordList[i]);
        }
        switch on operation {
            when 'CustomerStagingExcelProcessing' {
                customerStagingExcelProcessing(recordsToInsert, endingIndex, recordList);
            }
            when 'Insert' {
                insertHelper(recordsToInsert, endingIndex, recordList);
            }
        }
    }

    /**
     * @description : Helper method to insert records
     * @author adeshi@a5econsulting.net | 01-10-2024
     * @param recordsToInsert
     * @param endingIndex
     **/
    public static void insertHelper(List<SObject> recordsToInsert, Integer endingIndex, List<SObject> recordList) {
        try {
            if (!recordsToInsert.isEmpty()) {
                ProductTriggerHandler.runProductTrigger = false;
                Database.insert(recordsToInsert);
                ProductTriggerHandler.runProductTrigger = true;
            }
        } catch (DmlException de) {
            System.debug('Exception during record insertion ' + de.getDmlMessage(0));
        }
        // If end index is >= MAX_RECORD_LIMIT or equal to the input record list we have inserted all records, can call final method
        if (!(endingIndex >= MAX_RECORD_LIMIT || endingIndex == recordList.size())) {
            if (!Test.isRunningTest()) {
                System.enqueueJob(new BulkDmlQueueable(recordList, endingIndex, 'Insert'));
            }
        }
    }

    /**
     * @description : Helper method for CustomerStagingExcelProcessing logic
     * @author adeshi@a5econsulting.net | 01-10-2024
     * @param recordsToInsert
     * @param endingIndex
     **/
    public static void customerStagingExcelProcessing(List<SObject> recordsToInsert, Integer endingIndex, List<SObject> recordList) {
        String documentId = '';
        String exceptionMessage = '';
        try {
            if (!recordsToInsert.isEmpty()) {
                documentId = (String) recordsToInsert[0].get('Document_Storage__c');
                Database.insert(recordsToInsert);
            }
        } catch (DmlException de) {
            exceptionMessage = de.getDmlMessage(0);
            System.debug('Exception during record insertion ' + de.getDmlMessage(0));
            CustomerStagingExcelFileProcessing.updateDocumentStorage(documentId, exceptionMessage);
        }
        // If end index is >= MAX_RECORD_LIMIT or equal to the input record list we have inserted all records, can call final method
        if (endingIndex >= MAX_RECORD_LIMIT || endingIndex == recordList.size()) {
            CustomerStagingExcelFileProcessing.updateDocumentStorage(documentId, exceptionMessage);
        } else {
            if (!Test.isRunningTest()) {
                System.enqueueJob(new BulkDmlQueueable(recordList, endingIndex, 'CustomerStagingExcelProcessing'));
            }
        }
    }
}
