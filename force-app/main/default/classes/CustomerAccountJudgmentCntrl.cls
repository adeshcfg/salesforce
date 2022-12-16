public class CustomerAccountJudgmentCntrl {
	@AuraEnabled
    public static List<Account_Judgment__c> fetchAccountJudgments(Id customerId){
        return [SELECT Id, Product__c, Product__r.Name, Judgment__c, Judgment__r.Name, Status__c FROM Account_Judgment__c WHERE Product__r.Customer__c =: customerId];
    }
}