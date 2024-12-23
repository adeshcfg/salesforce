public class SettlementWidgetOnProductController {
    @AuraEnabled 
    public static Settlement__c getproductName(String parentId){
        Account_Judgment__c accJudg = [select id,judgment__c from Account_Judgment__c where product__c =: parentId];
        Settlement__c settle = new Settlement__c();
        if(accJudg.judgment__c <> NULL){
            settle = [SELECT id,Name,Status__c,Proposal_Amount__c
                      from Settlement__c where Judgment__c =: accJudg.judgment__c];
        }
        return settle; 
    }
}