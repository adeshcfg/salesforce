@isTest
public class TestTrusteeFollowUpSetupBatch {
    
    @isTest
    public static void TestTrusteeFollowUpSetup(){
        
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id, name from RecordType where name ='Trustee Office']);
        Account acc = new Account();
        acc.Name = 'Test-001';
        acc.Last_Trustee_Followup_Sent_Date__c = System.today();
        acc.RecordTypeId = recordTypeList[0].Id;
        insert acc;
        
        TrusteeFollowUpSetupBatch obj = new TrusteeFollowUpSetupBatch();
        DataBase.executeBatch(obj);
        
    }

}