/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class for Judgment object to calculate Collection Agency identifier 
 *            based on related Products
 *  @author : A5E Consulting
 *  @date : 06/09/2020
 
 *************************************************************************************************/
global class JudgmentIdentifierBatch implements Database.Batchable<sObject> {
    public static string SEPARATOR = 'A';
    public static string UNPLACED = 'unplaced';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator('SELECT ID, Product__c, Judgment__C FROM Account_Judgment__C WHERE Product__r.Run_Identifier_Check_On__c = TODAY');
    }

    global void execute(Database.BatchableContext bc, List<Account_Judgment__c> prodJudgList) {
        Map<Id, String> placementIDMap = new Map<Id, String>();
        Set<ID> judgmentSet = new Set<ID>();
        Set<ID> productSet = new Set<ID>();
        Map<ID, Judgment__C> judgmentMap = new Map<ID, Judgment__C>();
        Map<ID, Product__C> ProductMap = new Map<Id, Product__C>();

        for (Account_Judgment__c prodJudg : prodJudgList) {
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }

        //Fetch all related products
        //Fetch all accounts judgments related to Judgments
        List<Account_Judgment__c> listAccountJudgment = [SELECT id, Judgment__C, Product__c FROM Account_Judgment__c WHERE Judgment__C IN :judgmentSet];
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }

        List<Product__c> listProduct = [SELECT id, Collection_Agency__C FROM Product__C WHERE id IN :productSet];
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            for (Product__C prod : listProduct) {
                if (prod.id == prodJudg.Product__C) {
                    productMap.put(prodJudg.id, prod);
                }
            }
        }

        //recalculate the Collection agency identifer for all related judgmets
        Map<ID, String> judgmentUpdate = new Map<Id, String>();
        String collectionAgencyidentifier = '';
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            Product__c prod = productMap.get(prodJudg.id);
            if (prod == null) {
                continue;
            }
            if (prod.Collection_Agency__c == null || prod.Collection_Agency__c == 9999) {
                collectionAgencyidentifier = SEPARATOR + UNPLACED + SEPARATOR;
            } else {
                collectionAgencyidentifier = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
            }

            String IdentifierList = '';
            IdentifierList = judgmentUpdate.get(prodJudg.Judgment__c);
            if (String.isBlank(IdentifierList)) {
                IdentifierList = collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            } else if ((IdentifierList).contains(collectionAgencyidentifier)) {
                //Do Nothing
            } else {
                IdentifierList += collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            }
        }

        //Save the Judgments
        List<Judgment__C> listJudgment = new List<Judgment__c>();
        if (judgmentUpdate.size() > 0) {
            for (ID judgmentID : judgmentUpdate.keySet()) {
                Judgment__c judge = new Judgment__c();
                judge.Collection_Agency_Identifier__c = judgmentUpdate.get(judgmentID);
                //Update the external Collection Agency Identifier for Agency Group Sharing Rule
                judge.External_Collection_Agency_Identifier__c = judge.Collection_Agency_Identifier__c.replace('A68A', '')
                    .replace('A6A', '')
                    .replace(SEPARATOR + UNPLACED + SEPARATOR, '')
                    .replace(',', '');
                judge.id = judgmentID;
                if (null != judge.id) {
                    listJudgment.add(judge);
                }
            }
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            update listJudgment;
            JudgmentTriggerHandler.runJudgmentTrigger = true;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
        // Call Settlement Batch
        Database.executeBatch(new SettlementIdentifierBatch(), 200);
    }
}
