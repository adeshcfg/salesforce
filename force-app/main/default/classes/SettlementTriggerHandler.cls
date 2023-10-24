/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Trigger Handler Class for Settlement__c object 
*  @author : A5E Consulting
*  @date : 06/09/2020
* 
*************************************************************************************************/
public class SettlementTriggerHandler {
    
    public static final string SEPARATOR = 'A';
    public static final string UNPLACED = 'unplaced';
    public static Map<String, Id> collectionAgency = new Map<String, Id>();
    public static boolean runSettlementTrigger = true;
    Public static Boolean firstcall=false;
    
    
    static{
        
        for(Placement__c place : [select id, Name, Agency_Name__c from Placement__c]){
            
            collectionAgency.put(place.Name, place.Id);
          //  system.debug('Collection ' +collectionAgency);    
        }
    }
    
    public static void handleAfterInsert(list<Settlement__c> listNewSettlements){
        updateSettlementIdentifiers(listNewSettlements);
        /* for(Settlement__c settlement: listNewSettlements){
//call API
PortalSettlementProcessingAPI.processSettlement(settlement.ID);    
}*/
    }
    
    public static void handleBeforeInsert(List<Settlement__c> listNewSettlements) {
        // list<String> listSettlementStatus = new list<String>();
        set<ID> setProductID = new set<ID>();
        set<ID> setJudgmentID = new set<ID>();
        
        Map<Id,list<Settlement__c>> mapProductSettlements =new Map<Id,list<Settlement__c>>();
        Map<Id,list<Settlement__c>> mapJudgmentSettlements =new Map<Id,list<Settlement__c>>();
        
        system.debug('before insert ::::');
                
        for(Settlement__c settlemnt : listNewSettlements){
         //   listSettlementStatus.add(settlemnt.Status__c);
            setProductID.add(settlemnt.Product__c);
            setJudgmentID.add(settlemnt.Judgment__c);
            settlemnt.Last_Modified_By__c = UserInfo.getName();
        }
        system.debug('setProductID::::' +setProductID);
        system.debug('setJudgmentID::::' +setJudgmentID);
        //Added Status != Not completed in below SOQL Query as part of #5145
        for(Settlement__c newSettle: [SELECT Id, Status__c ,Product__c, Judgment__c
                                    FROM Settlement__c 
                                    WHERE ((Judgment__c IN :setJudgmentID AND Judgment__c != NULL)
                                    OR (Product__c IN :setProductID AND Product__c != NULL))
                                    AND (Status__c != 'Rejected' AND Status__c  != 'Withdraw' AND Status__c  != 'Not completed') ]){
             system.debug('newSettle: '+newSettle);
             if(newSettle.Judgment__c != NULL && mapJudgmentSettlements.containsKey(newSettle.Judgment__c)) {
                 //system.debug('Judgment Block 1 run::::');
                List<Settlement__c> listJudgSettlement = mapJudgmentSettlements.get(newSettle.Judgment__c);
                listJudgSettlement.add(newSettle);
                mapJudgmentSettlements.put(newSettle.Judgment__c, listJudgSettlement);
            }
            else{//system.debug('Judgment Block 2 run::::');
                if(newSettle.Judgment__c != NULL){
                    mapJudgmentSettlements.put(newSettle.Judgment__c, new List<Settlement__c> {newSettle});    
                }
            }
             if(newSettle.Product__c != NULL && mapProductSettlements.containsKey(newSettle.Product__c)) {
                 //system.debug('Product Block 1 run::::');
                List<Settlement__c> listSettlement = mapProductSettlements.get(newSettle.Product__c);
                listSettlement.add(newSettle);
                mapProductSettlements.put(newSettle.Product__c, listSettlement);
            }
            else{
                if(newSettle.Product__c != NULL){
                    mapProductSettlements.put(newSettle.Product__c, new List<Settlement__c> {newSettle});    
                }
                
            }
                                       
        }
        
        system.debug('mapProduct::::' +mapProductSettlements);
        system.debug('mapJudgment::::' +mapJudgmentSettlements);
        
        for(Settlement__c settlement : listNewSettlements){
            system.debug('mapJudgmentSettlements::::' +mapJudgmentSettlements.containsKey(settlement.Judgment__c));
            system.debug('mapProductSettlements::::' +mapProductSettlements.containsKey(settlement.Product__c));
            if(settlement.Judgment__c != NULL &&  mapJudgmentSettlements.containsKey(settlement.Judgment__c)){
                settlement.addError('Their is already active settlement present for Judgment');
            }
            else if(settlement.Product__c != NULL && mapProductSettlements.containsKey(settlement.Product__c)){
                 settlement.addError('Their is already active settlement present for Product');
            }
        }
       //  updateProductStatusesOnSettlement(listNewSettlements,listSettlementStatus);        
    }
    
    public static void handleAfterUpdate(list<Settlement__c> listNewSettlments, map<id, Settlement__c> mapOldSettlments){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        list<Settlement__c> listSettlmentsForIdentifier = new list<Settlement__c>();
        list<Work_Assignment__c> listWorkAssignments = new list<Work_Assignment__c>();
        if(!firstcall) {
            firstcall = true;
            if(config.Run_Settlement_Update_API_for_Portal__c){
                system.debug('run api');
                //call API
                PortalSettlementProcessingAPI.processSettlement(listNewSettlments[0].ID); 
            }
        }
        for(Settlement__c settlmentObj : listNewSettlments){
            
            if(config.Run_Settlement_Update_API_for_Portal__c){
                system.debug('run api');
                //call API
                PortalSettlementProcessingAPI.processSettlement(settlmentObj.ID); 
            }
            
            
            
            if(settlmentObj.Product__c != mapOldSettlments.get(settlmentObj.Id).Product__c
               || settlmentObj.Judgment__c != mapOldSettlments.get(settlmentObj.Id).Judgment__c){
                   listSettlmentsForIdentifier.add(settlmentObj);              
               }
            
            /*//Create Work Assignmnt record if Proposal Amount is changed
            if(settlmentObj.Proposal_Amount__c != mapOldSettlments.get(settlmentObj.ID).Proposal_Amount__c){
                Work_Assignment__c workAssignment = new Work_Assignment__c();
                workAssignment.Settlement__c = settlmentObj.Id;
                workAssignment.Purpose__c = 'Settlement Proposal';
                workAssignment.Status__c = 'Requested';
                workAssignment.Assign_To__c = 'Agency';
                workAssignment.Description__c = 'Settlemnt Proposal Amount Updated to '+settlmentObj.Proposal_Amount__c;
                workAssignment.Title__c = 'Settlement Proposal';
                workAssignment.Comment_Reply__c = 'Amount Proposed by '+UserInfo.getName();
                workAssignment.Priority__c = 'Medium';
                listWorkAssignments.add(workAssignment);
            }
            insert listWorkAssignments;*/
        }
        if(!listSettlmentsForIdentifier.isEmpty()){
            updateSettlementIdentifiers(listSettlmentsForIdentifier);
        }
        
    }
    //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
    
    public static void SetPlacementAgency(list<Settlement__c> listNewSettlements){
        list<Settlement__c> listInternalNewSettlements = new list<Settlement__c>();
        list<Settlement__c> listExternalNewSettlements = new list<Settlement__c>();
          list<String> listSettlementStatus = new list<String>();
  Map<Id,Product__c> mapProduct =new Map<Id,Product__c>();
        Map<Id,Judgment__c> mapJudgment =new Map<Id,Judgment__c>();
        set<ID> setProductID = new set<ID>();
        set<ID> setJudgmentID = new set<ID>();
        for(Settlement__c settl : listNewSettlements){
             listSettlementStatus.add(settl.Status__c);
            setProductID.add(settl.Product__c);
            setJudgmentID.add(settl.Judgment__c);
            system.debug('setProductID '+setProductID);
            system.debug('setJudgmentID '+setJudgmentID);
        }
        for(Product__c prod : [Select ID,Name,Collection_Agency_Placement__c                                    
                               From Product__c 
                               Where id in: setProductID]){
                                   mapProduct.put(prod.id, prod);
                                   system.debug('mapProduct '+mapProduct);
                               }
        for(Judgment__c Judg : [Select ID,Name,Legal_Agency_Placement__c                                    
                               From Judgment__c 
                               Where id in: setJudgmentID]){
                                   mapJudgment.put(Judg.id, Judg);
                                   system.debug('mapJudgment '+mapJudgment);
                               }
 
      
        for(Settlement__c settlemnt : listNewSettlements){
            //setProductID.add(settlemnt.Product__c);
            if(settlemnt.Placement__c == Null){
                if(settlemnt.Product__c != Null){
                    system.debug('prod.Collection_Agency_Placement__c  --' +mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c);
                    settlemnt.Placement__c = mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c;
                }
                else if(settlemnt.Judgment__c != Null){
                    system.debug('judg.Legal_Agency__c--' +mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c);
                    settlemnt.Placement__c = mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c;
                }
               else if(String.isNotBlank(settlemnt.Placement_Text_Id__c)){
                    system.debug('Block Run');
                    settlemnt.Placement__c = collectionAgency.get(settlemnt.Placement_Text_Id__c);
                    
                }
                //else{
                //    settlemnt.Placement__c = Null;
               // }
            }
            
            //system.debug('inside before insert trigger');
            
            
            DateTime dT = System.now();
            
            
            
            system.debug('listNewSettlements' +settlemnt);
            
            if(settlemnt.Placement__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
                System.debug('Block Run');
            }
            
            if(settlemnt.Product__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }         
            
            if(settlemnt.Judgment__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }
            
           if(settlemnt.Approved_By__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }
            if(settlemnt.Rejected_By__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }
            if(settlemnt.Approved_Date__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }
            if(settlemnt.Rejected_Date__c <> NULL ){
                listInternalNewSettlements.add(settlemnt);
            }
            
           if(settlemnt.Comment__c != null){
                settlemnt.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' +  settlemnt.Comment__c;
            } 

        }
        
        
        updateProductStatusesOnSettlement(listNewSettlements,listSettlementStatus);
        //method calls once record created/update in CFG
        getSettlementRelatedData(listInternalNewSettlements);
        
        
    }
    
    
    
    
    //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
    
    public static void SetPlacementAgencyBeforeUpdate(list<Settlement__c> listNewSettlements, map<id, Settlement__c> mapOldSettlments){
        list<Settlement__c> listInternalNewSettlements = new list<Settlement__c>();
        list<Settlement__c> listExternalNewSettlements = new list<Settlement__c>();
        list<String> listSettlementStatus = new list<String>();
        Map<Id,Product__c> mapProduct =new Map<Id,Product__c>();
        Map<Id,Judgment__c> mapJudgment =new Map<Id,Judgment__c>();
        set<ID> setProductID = new set<ID>();
        set<ID> setJudgmentID = new set<ID>();
        DateTime dT1 = System.now();
       
        for(Settlement__c settl : listNewSettlements){
             listSettlementStatus.add(settl.Status__c);
            system.debug('Status '+listSettlementStatus);
            Settlement__c settlementOld1= mapOldSettlments.get(settl.id);
            setProductID.add(settl.Product__c);
            setJudgmentID.add(settl.Judgment__c);
            settl.Last_Modified_By__c = UserInfo.getName();
             if(settl.Comment__c != null && settl.Comment__c != settlementOld1.Comment__c){
                
               try{
                   settl.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT1.month() + '/' + dT1.day() + '/' + dT1.year() + ';' + ' ' + ' ' + settl.Comment__c + '\n' + '\n';
                    
                    if(settlementOld1.Comments_History__c !=null){
                        //settlemnt.Comments_History__c += '\n';
                         settl.Comments_History__c += settlementOld1.Comments_History__c;
                    
                    }
                }catch(exception e){
                    
               }
            } 
           
        }
        system.debug('setProductID '+setProductID);
        system.debug('setJudgmentID '+setJudgmentID);
        
        for(Product__c prod : [Select ID,Name,Collection_Agency_Placement__c                                    
                               From Product__c 
                               Where id in: setProductID]){
            mapProduct.put(prod.id, prod);
        }
        
        system.debug('mapProduct '+mapProduct);
        
        for(Judgment__c Judg : [Select ID,Name,Legal_Agency_Placement__c                                    
                               From Judgment__c 
                               Where id in: setJudgmentID]){
                                   mapJudgment.put(Judg.id, Judg);
        }
        system.debug('mapJudgment '+mapJudgment);
      
        for(Settlement__c settlemnt : listNewSettlements){
            
            //setProductID.add(settlemnt.Product__c);
            if(settlemnt.Placement__c == Null){
                if(settlemnt.Product__c != Null){
                    system.debug('product present');
                    system.debug('prod.Collection_Agency_Placement__c  --' +mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c);
                    settlemnt.Placement__c = mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c;
                }
                else if(settlemnt.Judgment__c != Null){
                    system.debug('judgment present');
                    system.debug('judg.Legal_Agency__c--' +mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c);
                    settlemnt.Placement__c = mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c;
                }
               else if(String.isNotBlank(settlemnt.Placement_Text_Id__c)){
                    system.debug('Block Run');
                    settlemnt.Placement__c = collectionAgency.get(settlemnt.Placement_Text_Id__c);
                    
                }
                //else{
                //    settlemnt.Placement__c = Null;
               // }
            }
            
            DateTime dT = System.now();
            
            Boolean identifierRemovalFlag = false;
            
            Settlement__c settlementOld= mapOldSettlments.get(settlemnt.id);
            
            if(settlemnt.Product__c != NULL){
                if(settlemnt.Product__c != settlementOld.Product__c){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Product_Identifier__c  = NULL;
            }
            
            if(settlemnt.Placement__c  != NULL){
                if(settlemnt.Placement__c  != settlementOld.Placement__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Placement_Identifier__c  = NULL;
            }            
            
            if(settlemnt.Judgment__c != NULL){
                if(settlemnt.Judgment__c != settlementOld.Judgment__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Judgment_Identifier__c = NULL;
            }  
           if(settlemnt.Approved_By__c != NULL){
                if(settlemnt.Approved_By__c != settlementOld.Approved_By__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Approved_By_text__c = NULL;
            }              
            if(settlemnt.Rejected_By__c != NULL){
                if(settlemnt.Rejected_By__c != settlementOld.Rejected_By__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Rejected_By_Text__c = NULL;
            } 
      /*      if(settlemnt.Approved_Date__c != NULL){
                if(settlemnt.Approved_Date__c != settlementOld.Approved_Date__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Approved_Date_Text__c = NULL;
            } 
            if(settlemnt.Rejected_Date__c != NULL){
                if(settlemnt.Rejected_Date__c != settlementOld.Rejected_Date__c ){
                    listInternalNewSettlements.add(settlemnt);
                }
            }
            else{
                settlemnt.Rejected_Date_Text__c = NULL;
            } */
            
            if(settlemnt.Required_Amount__c != mapOldSettlments.get(settlemnt.Id).Required_Amount__c 
               && settlemnt.Required_Amount__c != settlemnt.Proposal_Amount__c){
            //system.debug('Block run'+mapOldSettlments.get(settlemnt.Id).Required_Amount__c);
                settlemnt.Status__c = 'Counter offer proposed';
            }

        }
        
        updateProductStatusesOnSettlement(listNewSettlements,listSettlementStatus);
        //method calls once record created/update in CFG
        getSettlementRelatedData(listInternalNewSettlements);        
        
    }
    
    
    public static void updateSettlementIdentifiers(list<Settlement__c> listSettlmentsForIdentifier){
        list<Settlement__c> listSettlememtsToUpdate = new list<Settlement__c>();
        for(Settlement__c settlementObj : [SELECT ID, Product__r.Collection_Agency__c, Judgment__r.Collection_Agency_Identifier__c
                                           FROM Settlement__c
                                           WHERE ID IN :listSettlmentsForIdentifier]){
                                               //Check if Product is related to settlment and set Collection Agency Identifier on settlement
                                               if(settlementObj.Product__c != NULL
                                                  && settlementObj.Product__r.Collection_Agency__c != NULL){
                                                      settlementObj.Product_Collection_Agency_Identifier__c = 
                                                          SEPARATOR + String.valueOf((integer) settlementObj.Product__r.Collection_Agency__c) + SEPARATOR;
                                                  }
                                               //Else set Judgement Collection Identifier from Judgment
                                               else if(settlementObj.Judgment__c != NULL
                                                       && String.isNotBlank(settlementObj.Judgment__r.Collection_Agency_Identifier__c)){
                                                           settlementObj.Judgment_Collection_Agency_Identifier__c = 
                                                               settlementObj.Judgment__r.Collection_Agency_Identifier__c;
                                                       }
                                               listSettlememtsToUpdate.add(settlementObj);
                                           }
        
        //Update Settlements
        
        if(!listSettlememtsToUpdate.isEmpty()){
            SettlementTriggerHandler.runSettlementTrigger = false;
            update listSettlememtsToUpdate;
            SettlementTriggerHandler.runSettlementTrigger = true;
        }
    }
    
    //using this inner method populate the identifier fields using CFG data.
   public static void getSettlementRelatedData(list<Settlement__c> listSettlements){
        
        
       set<Id> setPlacementID = new set<Id>();
       set<Id> setProductID = new set<Id>();       
       set<Id> setJudgmentID = new set<Id>();
       set<Id> setApprovedByID = new set<Id>();
       set<Id> setRejectedByID = new set<Id>();
       set<Id> setApprovedDateID = new set<Id>();
       set<Id> setRejectedDateID = new set<Id>();
       
       map<Id, String> mapPlacementNames = new map<Id, String>();
       map<Id, String> mapProductNames = new map<Id, String>();     
       map<Id, String> mapJudgmentNames = new map<Id, String>();
       map<Id, String> mapApprovedByNames = new map<Id, String>();
       map<Id, String> mapRejectedByNames = new map<Id, String>();
       map<Id, String> mapApprovedDateNames = new map<Id, String>();
       map<Id, String> mapRejectedDateNames = new map<Id, String>();
       map<Id, Decimal> mapProductCollectionAgency = new map<Id, Decimal>();   
       
       for(Settlement__c settlementObj : listSettlements){
           
           setPlacementID.add(settlementObj.Placement__c);
           setProductID.add(settlementObj.Product__c);           
           setJudgmentID.add(settlementObj.Judgment__c);
           setApprovedByID.add(settlementObj.Approved_By__c); 
           setRejectedByID.add(settlementObj.Rejected_By__c);
         //  setApprovedDateID.add(settlementObj.Approved_Date__c); 
          // setRejectedDateID.add(settlementObj.Rejected_Date__c);
           
       }
        System.debug('setPlacementID: ' +setPlacementID);
        
        for(Placement__c placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE ID IN : setPlacementID]){
                                          mapPlacementNames.put(placement.Id, placement.Name);
                                          
                                      }
        System.debug('mapPlacementNames: ' +mapPlacementNames);
        
        for(Product__c product : [SELECT ID, Name,Collection_Agency__c
                                  FROM Product__c
                                  WHERE ID IN :setProductID]){
                                      mapProductNames.put(product.ID, product.Name);
                                      mapProductCollectionAgency.put(product.ID, product.Collection_Agency__c);
                                      
                                  }       
        for(Judgment__c Judgment : [SELECT ID, Name, Judgment_Number__c
                                    FROM Judgment__c
                                    WHERE ID IN :setJudgmentID]){
                                        mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
                                        
                                    }
       for(User users : [SELECT ID, Name
                          FROM User
                          WHERE ID IN :setApprovedByID]){
                              mapApprovedByNames.put(users.ID, users.Name);
                              
                          }
        for(User users : [SELECT ID, Name
                          FROM User
                          WHERE ID IN :setRejectedByID]){
                              mapRejectedByNames.put(users.ID, users.Name);
                              
                          }
    /*    for(Settlement__c dUsers : [SELECT ID,Approved_Date__c
                          FROM Settlement__c
                          WHERE ID IN :setApprovedDateID]){
                              mapApprovedDateNames.put(dUsers.ID, dUsers.Approved_Date__c);
                              
                          }*/
        
        for(Settlement__c settlementObj : listSettlements){
            settlementObj.Placement_Identifier__c = mapPlacementNames.get(settlementObj.Placement__c);
            settlementObj.Product_Identifier__c = mapProductNames.get(settlementObj.Product__c);            
            settlementObj.Judgment_Identifier__c = mapJudgmentNames.get(settlementObj.Judgment__c);
            settlementObj.Approved_By_text__c = mapApprovedByNames.get(settlementObj.Approved_By__c);
            settlementObj.Rejected_By_Text__c = mapRejectedByNames.get(settlementObj.Rejected_By__c);
            settlementObj.External_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product__c));
            settlementObj.Product_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product__c));
            
        }
        
    }
    
    
    //method to update Placement  Status of Product based on Settlement Status
    public static void updateProductStatusesOnSettlement(list<Settlement__c> listNewSettlement, list<String> listOfStatus){
        system.debug('updateProductStatusesOnSettlement called::');
        list<Product__c> listProduct = new list<Product__c>();
        //list<Account_Judgment__c> listActiveJudgments = new list<Account_Judgment__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountSettlementCodes = new map<String, Judgment_product_codes_mapping__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>();
        Set<ID> ProductIDs = new Set<ID>();
        list<String> listJudgmentStatuses = new list<String>();
        for(Settlement__c settlementData : listNewSettlement){
            ProductIDs.add(settlementData.Product__c);
        }
        List <Account_Judgment__c> accJudgment = [SELECT ID, Judgment__c, Product__c,Product__r.name,
                                                  Judgment__r.Legal_Status__c,Judgment__r.Legal_Sub_Status__c
                                               FROM Account_Judgment__c
                                               WHERE Product__c IN :ProductIDs
                                               AND Status__c= 'Active'
                                              ];
        Map<id,Account_Judgment__c> mapAccJudg = new Map<id,Account_Judgment__c>();
        for(Account_Judgment__c accJud : accJudgment){
            mapAccJudg.put(accJud.Product__c,accJud);
            listJudgmentStatuses.add(accJud.Judgment__r.Legal_Status__c);
        }
        
        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                         WHERE Product_Parent__c IN :listJudgmentStatuses ]){
            mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);
        }
        
        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,Product_Parent__c,
                                                                Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                Judgment_Legal_Sub_Status__c,Settlement_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                         WHERE Product_Parent__c IN: listOfStatus ]){
            mapAccountSettlementCodes.put(mapping.Settlement_Status__c, mapping);
        }
        
        system.debug('mapAccountJudgmentCodes'+mapAccountJudgmentCodes);
        for(Settlement__c settlement : listNewSettlement){
            system.debug('settlement::'+settlement);
            system.debug('mapAccountSettlementCodes.containsKey(settlement.Status__c):'+mapAccountSettlementCodes.containsKey(settlement.Status__c));             
            
            if(mapAccountSettlementCodes.containsKey(settlement.Status__c)){
                Product__c product = new Product__c();
                product.ID = settlement.Product__c;
                system.debug('123=+' +settlement.Status__c);
                if(mapAccJudg.containsKey(product.ID)){
                    if(mapAccountJudgmentCodes.containsKey(mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c+mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c)){
                        product.Status__c = mapAccountJudgmentCodes.get(mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c+mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c).Product_Status__c;    
                        product.Sub_Status__c = mapAccountJudgmentCodes.get(mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c+mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c).Product_Sub_status__c;    
                        product.Placement_Status__c = mapAccountJudgmentCodes.get(mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c+mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c).Codes__c; 
                    }   
                    system.debug('listProduct::'+product.Status__c);
                }else{
                    product.Status__c = mapAccountSettlementCodes.get(settlement.Status__c).Product_Status__c;
                    system.debug('listProduct::'+product.Status__c);
                    product.Sub_Status__c = null;
                    product.Placement_Status__c = mapAccountSettlementCodes.get(settlement.Status__c).Codes__c;
                }
                listProduct.add(product);
                system.debug('listProduct::'+listProduct);
            }
        }
        
        //update product list
        ProductTriggerHandler.runProductTrigger = false;
        update listProduct;
        ProductTriggerHandler.runProductTrigger = true;
        
    }
    
    
    
   
}