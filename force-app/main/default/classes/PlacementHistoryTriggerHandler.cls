public class PlacementHistoryTriggerHandler {
    public static boolean runPlacementHistoryTrigger = true;
    static Distress_Setting__c drsetting = Distress_Setting__c.getOrgDefaults();
    public static Map<String, Placement_Status_Mapping__c> placeStatusMap = Placement_Status_Mapping__c.getAll();

    //Handle before insert
    public static void handleBeforeInsert(List<Placement_History__c> placeNew) {
        if(drsetting.Run_Placement_History_Trigger__c == true){
            linkPlacementID(placeNew);
            //drsetting.Run_Placement_History_Trigger__c = false;
        }
      }
    
    //Handle before insert
    public static void handleAfterInsert(List<Placement_History__c> placeNew) {
        if(drsetting.Run_Placement_History_Trigger__c == true){
            ArchiveUnarchiveUtility.assignExternalCorID(placeNew);
            runPlacementHistoryTrigger = false;
        }
      }
    
    //Handle before update
    public static void handleBeforeUpdate(List<Placement_History__c> placementNew, Map<Id, Placement_History__c> oldMap) {
        
        //Code to populate Assignment_Date__c of Product__c when Placement_Date__c field of Placement_History__c is updtaed
        List<Product__c> listProduct = new List<Product__c>();
        for(Placement_History__c placementHis : placementNew){
            Product__c pr1 = new Product__c();
            pr1.id = placementHis.Product__c;
            pr1.Assignment_Date__c = placementHis.Placement_Date__c;
            listProduct.add(pr1);
        }
        Update listProduct;
        
        if(drsetting.Run_Placement_History_Trigger__c == true){
                linkPlacementID(placementNew);
        }        
    }

   
    public static void linkPlacementID(List<Placement_History__c> placeNew){
        List<String> placementIds = new List<String>();
        map<ID, String> mapProductNames = new map<ID, String>();
        set<ID> setProductIDS = new set<ID>();
        Map<String,ID> placementMap = new Map<String,ID>();
        
        for(Placement_History__c plch : placeNew){
            placementIds.add(plch.Placement_ID_Text__c);
            setProductIDs.add(plch.Product__c);
        }
        
        List<Placement__c> plcmntHistory = [SELECT ID, Name from Placement__c where Name IN :placementIds]; 
        for(Placement__c pl : plcmntHistory){
            placementMap.put(pl.Name,pl.id);
        }
        
       List<Product__c> prod = [SELECT ID, Name FROM Product__c WHERE ID IN :setProductIDs];
        for(Product__c p : prod){
            mapProductNames.put(p.ID, p.Name);
        }  
 
       
      /* for(Placement__c pl : [select id, Name from Placement__c where Name in :placementIds]){
            placementMap.put(pl.Name,pl.id);
        }*/
        

        
       
        
        for(Placement_History__c plch : placeNew){
            if(plch.Placement_ID_Text__c <> null && plch.Placement__c == null){
                plch.Placement__c = placementMap.get(plch.Placement_ID_Text__c);
            }
            
            plch.Product_identifier__c = mapProductNames.get(plch.Product__c);
            
            if(String.isNotBlank(plch.Placement_Status__c)){
                if(null != placeStatusMap.get(plch.Placement_Status__c)){
                    plch.Placement_Status_Description__c = placeStatusMap.get(plch.Placement_Status__c).Description__c;
                }else{
                    plch.Placement_Status_Description__c = '';
                }
            }else{
                plch.Placement_Status_Description__c = '';
            }
        }
    }
}