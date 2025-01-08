/**************************************************************************************************
*  Class:   
*  @description : This class can be call Money Mart automation batch class based on parameter.
*  @author : tejal.vidhate@canaccede.com
*  @date :  07-01-2025

*************************************************************************************************/
public class MoneyMartGeneratorScheduler implements Schedulable, Database.Batchable<SObject> {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MoneyMartGeneratorScheduler());
    }

    public Database.Querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id From Insolvency_Account__c WHERE RecordType.DeveloperName = \'Money_Mart_Insolvency_Account\' AND Correlation_Id__c = NULL ORDER BY CreatedDate'
        );
    }

    /**
     * @description : Method to update the Correlation Id of the all Money Mart Accounts which have it set as null
     * @author tejal.vidhate@canaccede.com | 07-01-2025
     * @param bc
     * @param mmAccountsWithoutCorrelationId
     **/
    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> mmAccountsWithoutCorrelationId) {
        List<Insolvency_Error__c> insolvencyErrorList = new List<Insolvency_Error__c>();
        String correlationId = InsolvencyAccountTriggerHandler.getLatestCorrelationId();
        // Increment and assign new correlation Id
        for (Insolvency_Account__c ctbAccount : mmAccountsWithoutCorrelationId) {
            ctbAccount.Correlation_Id__c = String.valueOf(Integer.valueOf(correlationId) + 1).leftPad(15, '0');
            correlationId = ctbAccount.Correlation_Id__c;
        }
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        Database.SaveResult[] srList = Database.update(mmAccountsWithoutCorrelationId, false);
        // Iterate through each returned result
        for (Integer i = 0; i < srList.size(); i++) {
            if (!srList.get(i).isSuccess()) {
                // Create insolvency error record for failed records
                Database.Error error = srList.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                Insolvency_Error__c insolvencyError = new Insolvency_Error__c();
                insolvencyError.Insolvency_Account__c = srList.get(i).getId();
                insolvencyError.Error__c = failedDML;
                insolvencyErrorList.add(insolvencyError);
            }
        }
        if (!insolvencyErrorList.isEmpty() || Test.isRunningTest()) {
            Database.insert(insolvencyErrorList);
        }
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
    }

    public void finish(Database.BatchableContext bc) {
        Database.executeBatch(new MoneyMartFileGenerator(System.Label.Money_Mart_Insolvency_Account), 200);
    }
}