global class PortalProductProcessingAPIBatch  implements Database.Batchable<SObject>,Database.AllowsCallouts,database.stateful {
    
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static String accTokenBulk;
    
    List<Id> productId;
    global PortalProductProcessingAPIBatch(List<Id> prodIds) {
        productId=prodIds;
    }
   global database.QueryLocator start(Database.BatchableContext BC) {                
       
        String Query = 'SELECT ID,Legal_Decision_by__r.Name,Customer_Identifier__c,Pool_Name__r.Pool_ID__c,Created_By__c,Allocated_Amount_Total__c,Employer_Name__c,Current_Fees__c,Portfolio_Name_Lookup__r.Purchase_ID__c, ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Product'){
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
         
        Query = Query.removeEnd(', ');
        Query+= ' FROM Product__c WHERE ID IN: productId';
         return database.getQueryLocator(Query);
       
    }
    global void execute(Database.BatchableContext BC, List<Product__c> listProduct) {
        String productJSONRequest;
        List<id> listProductids = new List<id>();
        List<Product__c> listProductUpdate = new List<Product__c>();
        if(!listProduct.isEmpty()){
            for(Product__c productInstance : listProduct ){
                listProductids.add(productInstance.id);
         }
        listProductUpdate = PortalProductProcessingAPI.processProductBulkBatchone(listProductids);
            system.debug(' list process API batch'+listProductUpdate);
            ProductTriggerHandler.runProductTrigger = false;
            if(listProductUpdate.size()>0)
            update listProductUpdate;
            ProductTriggerHandler.runProductTrigger = true;
        }    
       }
 global void finish(Database.BatchableContext BC){
     
 }
    
}