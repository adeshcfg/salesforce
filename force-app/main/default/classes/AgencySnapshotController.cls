public class AgencySnapshotController {
    public String agencyID {get;set;}
    public boolean SUCCESS_MSG {get;set;}
    public Placement__c agencyRecord { get; set; }
    
    public AgencySnapshotController(ApexPages.StandardController stdController) {
        agencyID =  ApexPages.currentPage().getParameters().get('id');
        system.debug('agencyID'+agencyID);
    }
    
    public PageReference agencySnapshotData(){
        SUCCESS_MSG = true;
        system.debug('agencyID testing'+agencyID);
        List<Product__c> product = [SELECT ID, Name,Collection_Agency__c,RecordTypeId,Collection_Agency_Placement__c                                    
                   FROM Product__c WHERE Collection_Agency_Placement__c= :agencyID];
        system.debug('product'+product);
        getSnapshortRecords(product);
        return null;
    }
    
    public static void getSnapshortRecords(List<Product__c> prodNew){
        Map<Id, List<Id>> agencyTo_ProductIdsMap = new Map<Id, List<Id>>();
        List<Id> productIds = new List<Id>();
            for(Product__c prod : prodNew){
                productIds.add(prod.Id);
                agencyTo_ProductIdsMap.put(prod.Collection_Agency_Placement__c, productIds );
            }
            if(!agencyTo_ProductIdsMap.isEmpty()){
                for(Id agencyId : agencyTo_ProductIdsMap.keySet()){
                    System.enqueueJob(new SnapshotQueueableClass(agencyTo_ProductIdsMap.get(agencyId), agencyId));
                }
            }
    }
    
    public pageReference redirectToAgency(){
        PageReference pageRef = new PageReference('/'+agencyID);
        pageRef.setRedirect(true);
        return pageRef;
    }

}