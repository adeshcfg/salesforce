global class PortalProductProcessingAPIBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.StateFul {
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static String accTokenBulk;
    List<Id> productId = new List<Id>();
    List<Product__c> productListToCreateJudgment = new List<Product__c>();
    global List<Product__c> listProductUpdate = new List<Product__c>();
    boolean createAccJudg = true;

    global PortalProductProcessingAPIBatch(List<Id> prodIds) {
        productId = prodIds;
    }

    global PortalProductProcessingAPIBatch(List<Id> prodIds, List<Product__c> productListToCreateJudgment) {
        productId = prodIds;
        this.productListToCreateJudgment = productListToCreateJudgment;
    }
    
    global PortalProductProcessingAPIBatch(List<Id> prodIds, List<Product__c> productListToCreateJudgment, boolean createAccJudg) {
        productId = prodIds;
        this.productListToCreateJudgment = productListToCreateJudgment;
        this.createAccJudg = createAccJudg;
    }

    global database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Product__c WHERE ID IN: productId';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Product__c> listProduct) {
        String productJSONRequest;
        Set<Id> setProductIds = new Set<Id>();
        if (!listProduct.isEmpty()) {
            for (Product__c productInstance : listProduct) {
                setProductIds.add(productInstance.Id);
            }
            listProductUpdate.addAll(PortalProductProcessingAPI.processProductBulkBatchone(setProductIds));
        }
    }

    global void finish(Database.BatchableContext bc) {
        ProductTriggerHandler.runProductTrigger = false;
        if (listProductUpdate.size() > 0) {
            update listProductUpdate;
        }
        ProductTriggerHandler.runProductTrigger = true;
        if (!productListToCreateJudgment.isEmpty() && createAccJudg) {
            System.enqueueJob(new BulkDmlQueueable(productListToCreateJudgment, 'AccountJudgmentProcessing'));
        }
    }
}