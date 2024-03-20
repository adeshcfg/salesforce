/**
 * @description       : This is a Batch class for Judgment object to correct Collection Agency identifier based on related Products
 * @author            : adesh.ikhar@canaccede.com
 * @group             :
 * @last modified on  : 03-20-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CorrectJudgmentIdentifierBatch implements Database.Batchable<sObject> {
    public static final string SEPARATOR = 'A';
    public static final string UNPLACED = 'unplaced';

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT Id, Product__c, Judgment__C FROM Account_Judgment__c');
    }

    public void execute(Database.BatchableContext bc, List<Account_Judgment__c> prodJudgList) {
        Map<Id, String> placementIDMap = new Map<Id, String>();
        Set<Id> judgmentSet = new Set<Id>();
        Set<Id> productSet = new Set<Id>();
        Map<Id, Judgment__C> judgmentMap = new Map<Id, Judgment__C>();
        Map<Id, Product__C> productMap = new Map<Id, Product__C>();

        for (Account_Judgment__c prodJudg : prodJudgList) {
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }

        //Fetch all related products
        //Fetch all accounts judgments related to Judgments
        List<Account_Judgment__c> listAccountJudgment = [SELECT Id, Judgment__C, Product__c FROM Account_Judgment__c WHERE Judgment__C IN :judgmentSet];
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }

        List<Product__c> listProduct = [SELECT Id, Collection_Agency__C FROM Product__C WHERE Id IN :productSet];
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            for (Product__C prod : listProduct) {
                if (prod.Id == prodJudg.Product__C) {
                    productMap.put(prodJudg.Id, prod);
                }
            }
        }

        //recalculate the Collection agency identifer for all related judgmets
        Map<Id, String> judgmentUpdate = new Map<Id, String>();
        String collectionAgencyidentifier = '';
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            Product__c prod = productMap.get(prodJudg.Id);
            if (prod == null) {
                continue;
            }
            if (prod.Collection_Agency__c == null || prod.Collection_Agency__c == 9999) {
                collectionAgencyidentifier = SEPARATOR + UNPLACED + SEPARATOR;
            } else {
                collectionAgencyidentifier = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
            }

            String identifierList = '';
            identifierList = judgmentUpdate.get(prodJudg.Judgment__c);
            if (String.isBlank(identifierList)) {
                identifierList = collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, identifierList);
            } else if ((identifierList).contains(collectionAgencyidentifier)) {
                //Do Nothing
            } else {
                identifierList += collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, identifierList);
            }
        }

        //Save the Judgments
        List<Judgment__C> listJudgment = new List<Judgment__c>();
        if (judgmentUpdate.size() > 0) {
            for (Id judgmentID : judgmentUpdate.keySet()) {
                Judgment__c judge = new Judgment__c();
                judge.Collection_Agency_Identifier__c = judgmentUpdate.get(judgmentID);
                //Update the external Collection Agency Identifier for Agency Group Sharing Rule
                judge.External_Collection_Agency_Identifier__c = judge.Collection_Agency_Identifier__c.replace('A68A', '')
                    .replace('A6A', '')
                    .replace(SEPARATOR + UNPLACED + SEPARATOR, '')
                    .replace(',', '');
                judge.Id = judgmentID;
                if (null != judge.Id) {
                    listJudgment.add(judge);
                }
            }
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            update listJudgment;
            JudgmentTriggerHandler.runJudgmentTrigger = true;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
