global class BulkProductUpdates implements Database.Batchable<Product__c>{
    global List<Product__c> prodList ; 
    global BulkProductUpdates(List<Product__c> prodList){
        this.prodList = prodList ;  
    }
    global Iterable<Product__c> start(Database.BatchableContext BC){
        return prodList;
    }

    global void execute(Database.BatchableContext BC, List<Product__c> prodList) {
        ProductTriggerHandler.runProductTrigger = false;
        update prodList;
        ProductTriggerHandler.runProductTrigger = true;
    }
    global void finish(Database.BatchableContext BC) {
        
	}

}