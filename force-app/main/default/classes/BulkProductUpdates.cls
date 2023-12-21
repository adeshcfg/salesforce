global class BulkProductUpdates implements Database.Batchable<Product__c> {
    global List<Product__c> prodList = new List<Product__c>();
    global BulkProductUpdates(List<Product__c> prodList) {
        this.prodList = prodList;
    }

    global Iterable<Product__c> start(Database.BatchableContext bc) {
        return prodList;
    }

    global void execute(Database.BatchableContext bc, List<Product__c> prodList) {
        ProductTriggerHandler.runProductTrigger = false;
        update prodList;
        ProductTriggerHandler.runProductTrigger = true;
    }

    global void finish(Database.BatchableContext bc) {
    }
}
