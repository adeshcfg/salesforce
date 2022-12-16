public class AgencyUserTriggerHandler {
    public static boolean runAgencyUserTrigger = true;
    public static Map<String, Id> agencyRTypeIdMap = new Map<String, Id>();
    static{
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Agency_User__c' ]){
            agencyRTypeIdMap.put(rType.DeveloperName, rType.Id);            
        }
    }
    
    
    public static void handleBeforeInsert(List<Agency_User__c> agencyUser) {
        system.debug('inside before insert trigger');
        list<Agency_User__c> listInternalNewAgencyUser = new list<Agency_User__c>();
        list<Agency_User__c> listExternalNewAgencyUser = new list<Agency_User__c>();
        
        DateTime dT = System.now();        
        for(Agency_User__c aagncyuser : agencyUser){
            
            aagncyuser.Created_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.Name; 
            
            if(aagncyuser.Placement__c <> NULL ){
                listInternalNewAgencyUser.add(aagncyuser);
            }            
            
        }
        
         
        //method calls once record created in CFG
        getAgencyUserRelatedData(listInternalNewAgencyUser);
    }
    
    //Method to handle after insert of record
    public static void handleAfterInsert(list<Agency_User__c> listNewAgencyUser){
        system.debug('after insert');      
        for(Agency_User__c agencyUsers: listNewAgencyUser){
            //call API
            if(agencyRTypeIdMap.get('Portal_User') == agencyUsers.RecordTypeId || 
               agencyRTypeIdMap.get('Agnecy_Contact_Portal_User') == agencyUsers.RecordTypeId){
                 PortalAgencyUserProcessingAPI.processAgencyUser(agencyUsers.ID);    
            } 
        }
    } 
    
    //Method to handle after update of record
    public static void handleAfterUpdate(list<Agency_User__c> listNewAgencyUser){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        system.debug('listNewAgencyUser'+listNewAgencyUser);
        for(Agency_User__c agencyUser: listNewAgencyUser){
            if(config.Run_Agency_User_Update_API_for_Portal__c){
                system.debug('run api');          
                //call API
                if(agencyRTypeIdMap.get('Portal_User') == agencyUser.RecordTypeId || 
                   agencyRTypeIdMap.get('Agnecy_Contact_Portal_User') == agencyUser.RecordTypeId){
                       PortalAgencyUserProcessingAPI.processAgencyUser(agencyUser.ID);    
                }
            }
        }
    }
    
    //this inner method to handle before update functionality
    public static void handleBeforeUpdate(List<Agency_User__c> agncyusr, Map<Id, Agency_User__c> oldMap) { 
        
        list<Agency_User__c> listInternalNewAgencyUser = new list<Agency_User__c>();
        list<Agency_User__c> listExternalNewAgencyUser = new list<Agency_User__c>();
        
        DateTime dT = System.now();
        
        for(Agency_User__c agusr : agncyusr){
            
            Boolean identifierRemovalFlag = false;
            
            Agency_User__c agencyUserOld= oldMap.get(agusr.id);
            
            agusr.Last_Modified_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.name;
            
            if(agusr.Placement__c != NULL){
                if(agusr.Placement__c != agencyUserOld.Placement__c ){
                    listInternalNewAgencyUser.add(agusr);
                }
            }
            else{
                agusr.Placement_Identifier__c  = NULL;
            }
            
        }
        
        //method calls once record created/update in CFG
        getAgencyUserRelatedData(listInternalNewAgencyUser);
    }
    
    
    
    //using this inner method populate the identifier fields using CFG data.
    public static void getAgencyUserRelatedData(list<Agency_User__c> listAgencyUser){     
        
        
        set<Id> setPlacementID = new set<Id>();
        
        map<Id, String> mapPlacementNames = new map<Id, String>();
        
        
        for(Agency_User__c agencyUserObj : listAgencyUser){
            
            setPlacementID.add(agencyUserObj.Placement__c);
            
        }
        
        
        for(Placement__c Placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE ID IN :setPlacementID]){
                                          mapPlacementNames.put(Placement.ID, Placement.Name);
                                          
                                      }
        
        for(Agency_User__c agencyUserObj : listAgencyUser){
            
            agencyUserObj.Placement_Identifier__c = mapPlacementNames.get(agencyUserObj.Placement__c);
             //system.debug('ABC** '+mapPlacementNames);
        }
        
    }
    
    
 
    
}