@IsTest
public class TestProcessRecordsDeletionBatch {
    @testSetup
    private static void setup() {
        List<Deleted_Records__c> deletedRecordsList = new List<Deleted_Records__c>();
        for (Integer i = 0;i<100 ;i++) {
            deletedRecordsList.add(new Deleted_Records__c(Object_Name__c ='Error for testing '+i,
                                     CreatedDate = Date.Today() - 10));
        }
        insert deletedRecordsList;
    }
    
    @isTest
    private static void deleteRecordProcess_PositiveTest() {
        Test.startTest();
        Id batchId = Database.executeBatch(new ProcessRecordsDeletionBatch(), 200);
        Test.stopTest();
        System.assertEquals(0, [select count() from Deleted_Records__c]);
    }
    @isTest
    private static void deleteRecordProcess_SendEmailTest() {
        Test.startTest();
        ProcessRecordsDeletionBatch.errorRecIdandErrorMsgMap.put('Error_Rec_Id', 'Error Generated to Evaluate Test Class');
        ProcessRecordsDeletionBatch processRecord = new ProcessRecordsDeletionBatch();
        processRecord.sendExceptionEmail();
        Test.stopTest();
    }
    
   	@isTest
    private static void deleteRecordProcess_CreateExceptionRecordTest() {
        Test.startTest();
        ProcessRecordsDeletionBatch.errorRecIdandErrorMsgMap.put('Error_Rec_Id', 'Error Generated to Evaluate Test Class');
        ProcessRecordsDeletionBatch processRecord = new ProcessRecordsDeletionBatch();
        processRecord.createExceptionRecords();
        Test.stopTest();
    }
}