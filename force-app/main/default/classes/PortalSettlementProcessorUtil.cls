/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for  Settlement Processing API
*  @author : A5E Consulting
*  @date : 

*************************************************************************************************/
public class PortalSettlementProcessorUtil {
     
    static String COUNTER_OFFER_ACCEPTED = 'Counter offer accepted';
    static String APPROVED = 'Approved';
    
    public static String processSettlement(Map<String,String> paramMap, Settlement__c settlement){
        //Create temporary Settlement instance to store request values settlementInstance
     
      List<Agency_Portal_Fields_Mapping__c> fieldmapping = Agency_Portal_Fields_Mapping__c.getall().values();
      String SettlementStatus = settlement.Status__c;
      
      for(Agency_Portal_Fields_Mapping__c mapping : fieldmapping){
          if(mapping.Object_Name__c == 'Settlement'){
              system.debug('mapping.Field_JSON_Tag__c '+mapping.Field_JSON_Tag__c);
              system.debug('tag:: '+paramMap.get(mapping.Field_JSON_Tag__c));
              //settlement.put(mapping.Field_API__c, paramMap.get(mapping.Field_JSON_Tag__c));
              if(mapping.Field_Type__c == 'Currency'){
                  if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                     settlement.put(mapping.Field_API__c,Decimal.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                  }                  
              }
              else if(mapping.Field_Type__c == 'Date'){
                 if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                     settlement.put(mapping.Field_API__c,Date.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                  }      
              }
              
              else if(mapping.Field_Type__c == 'DateTime'){
                        if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                            
                            String str = '"2013-01-30T07:38:44.268Z"';
                            system.debug(JSON.deserialize(str, DateTime.class));
                            system.debug(DateTime.valueOf(JSON.deserialize(str, DateTime.class)));
                            String ss = '"'+paramMap.get(mapping.Field_JSON_Tag__c)+'"';
                            system.debug('ssss'+ss);
                            DateTime convertedDateTime = DateTime.valueOf(JSON.deserialize(ss, DateTime.class));
                            system.debug('convertedDateTime::'+convertedDateTime);
                            settlement.put(mapping.Field_API__c,convertedDateTime); 
                            system.debug('convertedDateTime::'+convertedDateTime);
                            //settlement.put(mapping.Field_API__c,DateTime.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));    
                        }      
                    }
              
              else{
                  settlement.put(mapping.Field_API__c, paramMap.get(mapping.Field_JSON_Tag__c));
              } 
             
          }
      }
      settlement.Monthly_Expenses_Comments__c = paramMap.get('Monthly_Expenses_Comments');
      settlement.Monthly_Income_Comments__c = paramMap.get('Monthly_Income_Comments');
      settlement.Total_Wealth_Comments__c = paramMap.get('Total_Wealth_Comments');
        
        //Addedn for Ticket: 4034 by Satyajit
        settlement.Employment_Comments__c = paramMap.get('Employment_Comments');
        settlement.HomeOwner_Status_Comments__c = paramMap.get('HomeOwner_Status_Comments');
      DateTime dT = System.now();
        if(String.isNotBlank(paramMap.get('Comment_Reply'))){
            if(settlement.Comment__c != paramMap.get('Comment_Reply')){
                system.debug('--Comments_History__c: '+settlement.Comments_History__c);
                system.debug('workAssignment.Comment__c: '+settlement.Comment__c);
                settlement.Comment__c = paramMap.get('Comment_Reply');
                String Comment = settlement.Last_Modified_By__c + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() 
                + '/' + dT.year() + ';' + ' ' + ' ' + settlement.Comment__c + '\n' + '\n';
                system.debug('Comment : '+Comment );
                
                if(String.isNotBlank(settlement.Comments_History__c)){
                    Comment  = Comment  + settlement.Comments_History__c;
                }
                //Comment  += (String.isNotBlank(settlement.Comments_History__c) ? settlement.Comments_History__c: '');
                system.debug('Comment  2:'+Comment);
                settlement.Comments_History__c = Comment ;
                system.debug('Comment History 3:' +settlement.Comments_History__c );
              }
        } 
     
      Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults(); 
      try{
          //to not run settlement trigger
          SettlementTriggerHandler.runSettlementTrigger = false;
          
          //Populate identifier fields from handler method
          list<Settlement__c> listsettlements = new list<Settlement__c>();
          listsettlements.add(settlement);
          list<String> listSettlementStatus = new list<String>();   
          for(Settlement__c settl : listsettlements){
              settl.Status__c = settl.Status__c.trim();
              listSettlementStatus.add(settl.Status__c);
          }
          getSettlementRelatedAgencyData(listsettlements);
          settlement.Inbound_API_Request_Body__c = String.valueOf(paramMap);
          settlement.Inbound_API_Response_Body__c = 'Successfully Created';
          if(settlement.ID == NULL){
              if(settlement.Judgment__c != NULL){
                settlement.RecordTypeID = portalSettings.Judgment_Settlement_RecordTypeID__c ;    
              }
              if(settlement.Product__c != NULL){
                  settlement.RecordTypeID = portalSettings.Product_Settlement_RecordTypeID__c ;
              }
              insert settlement;
          }
          else{
                //Check if API is sending 'Counter offer accepted' Status and previous Status on 
                //Settlement is not 'Counter offer accepted'
                system.debug('SettlementStatus::'+SettlementStatus);
                system.debug('settlement.Status__c::'+settlement.Status__c);
                if(String.isNotBlank(SettlementStatus)
                && settlement.Status__c == COUNTER_OFFER_ACCEPTED
                && SettlementStatus!= settlement.Status__c){
                    //update the Status to Approved
                    settlement.Status__c = APPROVED;
                    update settlement;
                    PortalSettlementProcessingAPI.processSettlement(settlement.ID);
                }
              else{
                  system.debug('settlement::'+settlement);
                  update settlement;
              }
          }
          SettlementTriggerHandler.runSettlementTrigger = true;
          SettlementTriggerHandler.updateProductStatusesOnSettlement(listsettlements,listSettlementStatus);
          return 'success';
      }
        catch(Exception ex){
            // system.debug('Exception in payment transaction insert :'+ex);
            settlement.Inbound_API_Response_Body__c = ex.getMessage();
            if(settlement.ID != NULL){
                update settlement;
            }
            SettlementTriggerHandler.runSettlementTrigger = true;
           

            return ex.getMessage();
        }
    }
    
        //using this inner method populate the Lookup fields using agency data.
    public static void getSettlementRelatedAgencyData(list<Settlement__c> listSettlements){
        set<String> setPlacementID = new set<String>();
        set<String> setProductID = new set<String>();       
        set<String> setJudgmentID = new set<String>();
        set<String> setApprovedByID = new set<String>();
        set<String> setRejectedByID = new set<String>();
        
        map<String, Id> mapPlacementNames = new map<String, Id>();
        map<String, Id> mapProductNames = new map<String, Id>();      
        map<String, Id> mapJudgmentNames = new map<String, Id>();
        map<String, Id> mapApprovedByNames = new map<String, Id>();
        map<String, Id> mapRejectedByNames = new map<String, Id>();
        map<String, Decimal> mapProductCollectionAgency = new map<String, Decimal>();     
        
        for(Settlement__c settlementObj : listSettlements){    
            setPlacementID.add(settlementObj.Placement_Identifier__c);
            setProductID.add(settlementObj.Product_Identifier__c);           
            setJudgmentID.add(settlementObj.Judgment_Identifier__c);
            setApprovedByID.add(settlementObj.Approved_By_text__c);
            setRejectedByID.add(settlementObj.Rejected_By_Text__c);
        }
        
        for(Placement__c placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE Name IN : setPlacementID]){
                                          mapPlacementNames.put(placement.Name, placement.Id);
                                          
                                      }
        
        for(Product__c product : [SELECT ID, Name,Collection_Agency__c
                                  FROM Product__c
                                  WHERE Name IN :setProductID]){
                                      mapProductNames.put(product.Name, product.ID);
                                      mapProductCollectionAgency.put(product.Name, product.Collection_Agency__c);
                                  }       
        
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c
                                    FROM Judgment__c
                                    WHERE Judgment_Number__c IN :setJudgmentID]){
                                        mapJudgmentNames.put(Judgment.Judgment_Number__c, Judgment.ID);
                                    }
                                        
       for(User users : [SELECT ID, Name
                                    FROM User
                                    WHERE Name IN :setApprovedByID]){
                                        mapApprovedByNames.put(users.Name, users.ID);
                                    }
        
           for(User users : [SELECT ID, Name
                                    FROM User
                                    WHERE Name IN :setRejectedByID]){
                                        mapRejectedByNames.put(users.Name, users.ID);
                                    }
     
        for(Settlement__c settlementObj : listSettlements){
            
            
            settlementObj.Placement__c = mapPlacementNames.get(settlementObj.Placement_Identifier__c);
            settlementObj.Product__c = mapProductNames.get(settlementObj.Product_Identifier__c);         
            settlementObj.Judgment__c = mapJudgmentNames.get(settlementObj.Judgment_Identifier__c);
            settlementObj.Approved_By__c = mapApprovedByNames.get(settlementObj.Approved_By_text__c);
            settlementObj.Rejected_By__c = mapRejectedByNames.get(settlementObj.Rejected_By_Text__c);
            settlementObj.External_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product_Identifier__c));
            settlementObj.Product_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product_Identifier__c));
            
            
        }
    } 
}