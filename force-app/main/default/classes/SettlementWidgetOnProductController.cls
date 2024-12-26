public class SettlementWidgetOnProductController {
    @AuraEnabled 
    public static Settlement__c getproductName(String parentId){
        Settlement__c settle = new Settlement__c();
        try{
            settle = [SELECT id,Name,Status__c,Proposal_Amount__c,Required_Amount__c,Product__r.name
                      from Settlement__c where Product__c =: parentId and Status__c != 'Rejected'
                      AND Status__c != 'Withdraw'
                      AND Status__c != 'Not completed'];
        }catch(Exception ex){
            Account_Judgment__c accJudg = [select id,judgment__c from Account_Judgment__c where product__c =: parentId and Status__c = 'Active'];
            
            if(accJudg.judgment__c <> NULL){
                settle = [SELECT id,Name,Status__c,Proposal_Amount__c,Required_Amount__c,Judgment__r.name
                          from Settlement__c where Judgment__c =: accJudg.judgment__c and Status__c != 'Rejected'
                          AND Status__c != 'Withdraw'
                          AND Status__c != 'Not completed'];
            }
        }
        return settle; 
    }
}