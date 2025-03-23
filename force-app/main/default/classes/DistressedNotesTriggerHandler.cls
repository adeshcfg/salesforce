/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for Distressed Notes object. The code is not bulkified. 
*  @author : A5E Consulting
*  @date : 11/02/2022
*************************************************************************************************/
public class DistressedNotesTriggerHandler {
    
    public static boolean runDistressedNotesTrigger = true;
    
    

    //this inner method populate the comment, comment history and user name.
    public static void handleBeforeInsert(List<Distressed_notes__c> distressedNotes) {
        system.debug('inside before insert trigger');
        list<Distressed_notes__c> listInternalNewDistressedNotes = new list<Distressed_notes__c>();
        list<Distressed_notes__c> listExternalNewDistressedNotes = new list<Distressed_notes__c>();
        
        DateTime dT = System.now();        
        for(Distressed_notes__c distNotes : distressedNotes){
            
            distNotes.Created_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.Name; 
           
            if(distNotes.Customer__c <> NULL ){
                listInternalNewDistressedNotes.add(distNotes);
            }
            
             if(distNotes.Judgment__c <> NULL ){
                listInternalNewDistressedNotes.add(distNotes);
            }
            
            if(distNotes.Product__c <> NULL ){
                listInternalNewDistressedNotes.add(distNotes);
            }
            
            if(distNotes.Settlement__c <> NULL ){
                listInternalNewDistressedNotes.add(distNotes);
            } 
            
          
        }
        
        //method calls once record created in CFG
        getDistressedNotesRelatedData(listInternalNewDistressedNotes);
        //populateAgencyId(listInternalNewDistressedNotes);
    }
    
    /*public static void populateAgencyId(List<Distressed_notes__c> listDistressedNotes){
        set<Id> parentId = new set<Id>();
        //this set is Stores the product id
        for(Distressed_notes__c disNotes : listDistressedNotes){
           if(disNotes.Product__c != null){
                parentId.add(disNotes.Product__c);
            }else if(disNotes.Judgment__c != null){
                parentId.add(disNotes.Judgment__c);
            }else if(disNotes.Settlement__c != null){
                parentId.add(disNotes.Settlement__c);
            }
           system.debug('parentId::'+parentId);
            if(parentId != null){
                
            } 
        }
            
       List<Product__c> prod = [Select id,name,Collection_Agency__c from product__c where id =: parentId];
       /* for(Product__c prodAgency : prod){
            distNotes.Agency_ID__c = prodAgency.Collection_Agency__c;
        }
    }*/
    
    //Method to handle after insert of record
    public static void handleAfterInsert(list<Distressed_notes__c> listNewDistressedNotes){
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = false;
        ArchiveUnarchiveUtility.assignExternalCorID(listNewDistressedNotes);
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;
        /*for(Distressed_notes__c distressedNotes: listNewDistressedNotes){
            //call API
            PortalDistressedNotesProcessingAPI.processDistressedNotes(distressedNotes.ID);    
        }*/
    
    } 
    
    //Method to handle after update of record
   public static void handleAfterUpdate(list<Distressed_notes__c> listNewDistressedNotes,  Map<Id, Distressed_notes__c> oldMap){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        if(config.Run_Distressed_Notes_API_for_Portal__c){
            system.debug('run api');
            for(Distressed_notes__c distressedNotes: listNewDistressedNotes){
                //call API
                 String method = '';
                Distressed_notes__c distressedNotesOld= oldMap.get(distressedNotes.id);
                if(distressedNotesOld.Distressed_Notes_Number__c == Null && distressedNotes.Distressed_Notes_Number__c != Null){
                    method = 'PUT';
                    PortalDistressedNotesProcessingAPI.processDistressedNotes(distressedNotes.ID, method);
                }else{
                    method = 'PATCH';
                    PortalDistressedNotesProcessingAPI.processDistressedNotes(distressedNotes.ID, method);
                }
                    
            }
        }
    }
    
    //this inner method to handle before update functionality
    public static void handleBeforeUpdate(List<Distressed_notes__c> distressedNotes, Map<Id, Distressed_notes__c> oldMap) { 
        
        list<Distressed_notes__c> listInternalNewDistressedNotes = new list<Distressed_notes__c>();
        list<Distressed_notes__c> listExternalNewDistressedNotes = new list<Distressed_notes__c>();
       
        DateTime dT = System.now();
        
        for(Distressed_notes__c distNotes : distressedNotes){
            
            Boolean identifierRemovalFlag = false;
            
            Distressed_notes__c distressedNotesOld= oldMap.get(distNotes.id);
            
            distNotes.Last_Modified_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.name;
            
            if(distNotes.Customer__c != NULL){
                if(distNotes.Customer__c != distressedNotesOld.Customer__c){
                     listInternalNewDistressedNotes.add(distNotes);
                }
            }
            else{
                distNotes.Customer_Identifier__c  = NULL;
            }

            if(distNotes.Judgment__c  != NULL){
                if(distNotes.Judgment__c  != distressedNotesOld.Judgment__c ){
                     listInternalNewDistressedNotes.add(distNotes);
                }
            }
            else{
                distNotes.Judgment_Identifier__c  = NULL;
            }

            if(distNotes.Product__c != NULL){
                if(distNotes.Product__c  != distressedNotesOld.Product__c ){
                     listInternalNewDistressedNotes.add(distNotes);
                }
            }
            else{
                distNotes.Product_Identifier__c  = NULL;
            }
            if(distNotes.Settlement__c != NULL){
                if(distNotes.Settlement__c  != distressedNotesOld.Settlement__c){
                     listInternalNewDistressedNotes.add(distNotes);
                }
            }
            else{
                distNotes.Settlement_Identifier__c  = NULL;
            }
            
            if(distNotes.Title__c != distressedNotesOld.Title__c || distNotes.Body__c != distressedNotesOld.Body__c
              || distNotes.Product__c != distressedNotesOld.Product__c){
               distNotes.addError('Title Name, Body, Account ID can not be updated'); 
            }
            
            
        }
        
        //method calls once record created/update in CFG
        getDistressedNotesRelatedData(listInternalNewDistressedNotes);
    }
    
    //using this inner method populate the identifier fields using CFG data.
    public static void getDistressedNotesRelatedData(list<Distressed_notes__c> listDistressedNotes){
     
        set<Id> setCustomerID = new set<Id>();
        set<Id> setJudgmentID = new set<Id>();
        set<Id> setProductID = new set<Id>();
        set<Id> setSettlementID = new set<Id>();
        set<String> setProductName = new set<String>();
        
        map<Id, String> mapCustomerNames = new map<Id, String>();
        map<Id, String> mapJudgmentNames = new map<Id, String>();
        map<Id, String> mapProductNames = new map<Id, String>();
        map<Id, String> mapSettlementNames = new map<Id, String>();
        map<Id, Decimal> mapProductPlaceId = new map<Id, Decimal>();
        map<Id, Decimal> mapsettlPlaceId = new map<Id, Decimal>();
        map<String, Decimal> mapJudgPlaceId = new map<String, Decimal>();
        for(Distressed_notes__c distressedNotesObj : listDistressedNotes){
     
            setCustomerID.add(distressedNotesObj.Customer__c);
            setJudgmentID.add(distressedNotesObj.Judgment__c);
            setProductID.add(distressedNotesObj.Product__c);
            setSettlementID.add(distressedNotesObj.Settlement__c);
        }
        
        for(Account Customer : [SELECT ID, Name, SF_ID__c
                                     FROM Account
                                     WHERE ID IN :setCustomerID]){
            mapCustomerNames.put(Customer.ID, Customer.SF_ID__c);
            
        }
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c,Product_1__c
                                     FROM Judgment__c
                                     WHERE ID IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
            setProductName.add(Judgment.Product_1__c);
                                         system.debug('Judgment.Product_1__c'+Judgment.Product_1__c);
        }
           /*for(Account_Judgment__c Judgment : [SELECT ID, Product__c
                                     FROM Account_Judgment__c
                                     WHERE ID IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
            
        }*/
        for(Product__c product : [SELECT ID, Name,collection_agency__c
                                     FROM Product__c
                                     WHERE ID IN :setProductID]){
            mapProductNames.put(product.ID, product.Name);
            mapProductPlaceId.put(product.ID, product.Collection_Agency__c);

        }
        for(Settlement__c Settlement : [SELECT ID, Settlement_Number__c,Product__r.Collection_Agency__c
                                     FROM Settlement__c
                                     WHERE ID IN :setSettlementID]){
            mapSettlementNames.put(Settlement.ID, Settlement.Settlement_Number__c);
             mapsettlPlaceId.put(Settlement.ID, Settlement.Product__r.Collection_Agency__c);
        
        }
        
        for(Distressed_notes__c distressedNotesObj : listDistressedNotes){
            distressedNotesObj.Customer_Identifier__c = mapCustomerNames.get(distressedNotesObj.Customer__c);
            distressedNotesObj.Judgment_Identifier__c = mapJudgmentNames.get(distressedNotesObj.Judgment__c);
            distressedNotesObj.Product_Identifier__c = mapProductNames.get(distressedNotesObj.Product__c);
            distressedNotesObj.Settlement_Identifier__c = mapSettlementNames.get(distressedNotesObj.Settlement__c);
             //Get collection agency of product populate on distressed note.
            if(mapProductPlaceId.get(distressedNotesObj.Product__c) != null){
               distressedNotesObj.Agency_ID__c = String.valueOf(mapProductPlaceId.get(distressedNotesObj.Product__c));
                
            }//Get collection agency of product based on settlement Product__C field and populate on distressed note.
            else if(mapsettlPlaceId.get(distressedNotesObj.Settlement__c) != null){
                distressedNotesObj.Agency_ID__c = String.valueOf(mapsettlPlaceId.get(distressedNotesObj.Settlement__c));
                
            }//Get collection agency of product based on judgment Product_1__c field and populate on distressed note.
            else if(setProductName != null){
                system.debug('Block run::'+distressedNotesObj.Judgment__r.Product_1__c);
                system.debug(setProductName);
                List<Product__c> prod = [select id,name,collection_agency__c from product__c where Name =: setProductName];
                if(prod.size()>0){
                    distressedNotesObj.Agency_ID__c = String.valueOf(prod[0].collection_agency__c);
                }
                    //String.valueOf(mapJudgPlaceId.get(distressedNotesObj.Judgment__r.Product_1__c));
            }
            
        }
    }
}