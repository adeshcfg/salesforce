public class PortalAgencyUserProcessorUtil {    
    public static String processAgencyUser(Map<String,String> paramMap, Agency_User__c agencyUser){
        //Create temporary account instance to store request values
        //agencyUser.Name = paramMap.get('Name');
        agencyUser.First_Name__c = paramMap.get('First_Name');
        agencyUser.Last_Name__c = paramMap.get('Last_Name');
        // agencyUser.Is_Active__c = paramMap.get('Is_Active');
        agencyUser.Email_Address__c = paramMap.get('Email_Address');
        agencyUser.Contact_Number__c = paramMap.get('Contact_Number');
        //agencyUser.Role__c = paramMap.get('Role');
        //agencyUser.Placement_Identifier__c = paramMap.get('Placement_Identifier');
        //agencyUser.Created_By__c = paramMap.get('Created_By');
        agencyUser.Last_Modified_By__c = paramMap.get('Last_Modified_By'); 
        /*
         * if(String.isNotBlank(paramMap.get('Is_Active'))){
            agencyUser.Is_Active__c = Boolean.valueOf(paramMap.get('Is_Active'));    
        }
		*/ 
        
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        try{
            //to not run agency user trigger
            AgencyUserTriggerHandler.runAgencyUserTrigger = false;
            list<Agency_User__c> listagencyUser = new list<Agency_User__c>();
            listagencyUser.add(agencyUser);
            getagencyUserRelatedAgencyData(listagencyUser);
            agencyUser.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            agencyUser.Inbound_API_Response_Body__c = 'Successfully Created';
            system.debug('agencyUser: '+agencyUser);
            if(agencyUser.ID == NULL){
                //documentStorage.RecordTypeID = portalSettings.Agency_Document_Storage_RecordTypeID__c;
                //insert agencyUser;
            }
            else{
                update agencyUser;
            }
            AgencyUserTriggerHandler.runAgencyUserTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in document storage processing :'+ex);
            agencyUser.Inbound_API_Response_Body__c = ex.getMessage();
            update agencyUser;
            AgencyUserTriggerHandler.runAgencyUserTrigger = true;
            return ex.getMessage();
        }
    }
    
       //using this inner method populate the Lookup fields using agency data.
    public static void getagencyUserRelatedAgencyData(list<Agency_User__c> listAgencyUser){      
        
        
        set<String> setPlacementID = new set<String>();       
        
        
        map<String, Id> mapPlacementNames = new map<String, Id>();
        
        
        for(Agency_User__c agencyUserObj : listAgencyUser){
            
            
          
            setPlacementID.add(agencyUserObj.Placement_Identifier__c);
            
        }
        
        
     for(Placement__c placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE Name IN : setPlacementID]){
                                          mapPlacementNames.put(placement.Name, placement.Id);
                                          
                                      }
        
        for(Agency_User__c agencyUserObj : listAgencyUser){
            
            agencyUserObj.Placement__c = mapPlacementNames.get(agencyUserObj.Placement_Identifier__c);
           // agencyUserObj.Placement_Identifier__c = mapPlacementNames.get(agencyUserObj.Placement__c);
           // system.debug('ABC** '+mapPlacementNames);
            
        }
    }
    
    
}