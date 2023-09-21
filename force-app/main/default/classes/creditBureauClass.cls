public with sharing class creditBureauClass {
    @AuraEnabled
    public static void getcreditBureauClass(String batchName) {
        system.debug('batchName check'+batchName);
        if(batchName == 'Equifax'){
            Database.executeBatch(New CustomerProcessingBatch(), 80);
        }
        else if(batchName == 'TransUnion'){
            Database.executeBatch(New CustomerProcessingBatchTU(), 80);
        }
        else if(batchName == 'CreditBureau'){
            Database.executeBatch(New CreditBureauReportingTUBatch(), 200);
        }
    }
}