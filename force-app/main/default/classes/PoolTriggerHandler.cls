/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for Pool object.
*  @author : A5E Consulting
*  @date : 28/03/2022

*************************************************************************************************/
public class PoolTriggerHandler {
    public static boolean runPoolTrigger = true;
        
    public static void handleBeforeInsert(List<Pool__c> listNewPool) {
        list<Pool__c> listOfNewPool = new list<Pool__c>();
        
        for(Pool__c poolRec : listNewPool){
            if(poolRec.Placement_agency_lookup__c <> NULL ){
                listOfNewPool.add(poolRec);
            }
        }
        getPoolLookupData(listOfNewPool); 
    }
    
    public static void handleBeforeUpdate(List<Pool__c> listNewPool, Map<Id, Pool__c> oldMap) {
        list<Pool__c> listOfNewPool = new list<Pool__c>();
        for(Pool__c poolObj : listNewPool){
            Pool__c poolOld = oldMap.get(poolObj.id);
            if(poolObj.Placement_agency_lookup__c != poolOld.Placement_agency_lookup__c
               && poolObj.Placement_agency_lookup__c != NULL){
                   listOfNewPool.add(poolObj);
               }
            else if(poolObj.Placement_agency_lookup__c == Null){
                listOfNewPool.add(poolObj);
            }
        }
        getPoolLookupData(listOfNewPool); 
    }
    
    public static void getPoolLookupData(List<Pool__c> newPoolList){
        set<ID> setPlacementID = new set<ID>();     
        map<ID, String> mapPlacementNames = new map<ID, String>();
        
        for(Pool__c poolObj : newPoolList){
            //setPlacementID.add(String.valueOf(poolObj.Placement_Agency__c)); 
            setPlacementID.add(poolObj.Placement_agency_lookup__c);
        }
        for(Placement__c placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE ID IN : setPlacementID]){
                                          mapPlacementNames.put(placement.Id, placement.Name);
                                          
                                      }
        for(Pool__c poolObject : newPoolList){
            system.debug('newPoolList '+newPoolList);
            if(poolObject.Placement_agency_lookup__c == null){
                 poolObject.Placement_Agency__c = null;
            }else{
                 poolObject.Placement_Agency__c = decimal.ValueOf(mapPlacementNames.get(poolObject.Placement_agency_lookup__c));
            }
           
            
        }
    }
    
}