public with sharing class creditBureauClass {
    @AuraEnabled
    public static void getcreditBureauClass(String batchName) {
        system.debug('batchName check' + batchName);
        if (batchName == 'Equifax') {
            Database.executeBatch(new CustomerProcessingBatch(), 80);
        } else if (batchName == 'TransUnion') {
            Database.executeBatch(new CustomerProcessingBatchTU(), 80);
        } else if (batchName == 'CreditBureau') {
            Database.executeBatch(new CreditBureauReportingTUBatch(), 200);
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getWorkAssignment() {
        List<Work_Assignment__c> cimlWS = [
            SELECT Id
            FROM Work_Assignment__c
            WHERE RecordType.DeveloperName = 'Credit_Bureau_Reporting_Files'
            ORDER BY CreatedDate
            LIMIT 1
        ];
        if (!cimlWS.isEmpty()) {
            return cimlWS[0].Id;
        }
        return null;
    }
}
