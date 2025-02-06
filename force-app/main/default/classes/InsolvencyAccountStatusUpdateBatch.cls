/**
 * @description       : Batch class to update Insolvency status on Insolvency accounts
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-28-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class InsolvencyAccountStatusUpdateBatch implements Database.Batchable<SObject> {
    Set<String> correlationIdSet = new Set<String>();
    public InsolvencyAccountStatusUpdateBatch(Set<String> correlationIdSet) {
        this.correlationIdSet = correlationIdSet;
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Insolvency_Account__c WHERE Correlation_Id__c IN :correlationIdSet AND Insolvency_Status__c = \'New\'');
    }

    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> records) {
        for (Insolvency_Account__c acc : records) {
            acc.Insolvency_Status__c = 'For Owner Review';
        }
        try {
            Database.update(records);
        } catch (DmlException de) {
            System.debug('Exception during record updation ' + de.getDmlMessage(0));
            Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getDmlMessage(0));
            insert error;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
