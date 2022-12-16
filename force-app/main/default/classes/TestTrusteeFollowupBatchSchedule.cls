@isTest
public class TestTrusteeFollowupBatchSchedule {
    public static testMethod void TrusteeFollowupBatchSchedule(){
        
        TrusteeFollowupSetupBatchSchedule trusteeFollowupBatch = new TrusteeFollowupSetupBatchSchedule();
        string sch = '24 00 * * * ?'; 
        System.schedule('Test', sch, trusteeFollowupBatch);
    }

}