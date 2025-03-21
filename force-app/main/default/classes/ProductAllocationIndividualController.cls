/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to allocate Products individually from Product record
*  @author : A5E Consulting
*  @date : 05/03/2022

*************************************************************************************************/
public with sharing class ProductAllocationIndividualController {
    
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
    public static final String NEW_ALLOCATION_READY = '100000';
    public static final String ALLOCATED = '300000';
    public static final String PLACEMENT_ALLOCATED = 'Placement (3); Allocated';
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults(); 
    public String ERROR_MSG {get;set;}
    public String Blank_Agency {get;set;}
    public String productID {get;set;}
    public String NewPlacementAgency {get;set;}
    String oldPlacementID;
    public Product__c product {get;set;}
    public List<Product__c> listProduct = new List<Product__c>();
    public Placement__c placement;
    public String placeStatus;
    public List<User> systemName= new list<User>();
    public Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public static Map<String,Provice_Name_Map_with_Abbreviations__mdt> mapProviceAbbreviations = Provice_Name_Map_with_Abbreviations__mdt.getAll();
    public static Map<String, String> mapProvinceAcronym = new Map<String, String>();
    
    public ProductAllocationIndividualController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, State__c, Collection_Agency__c, Collection_Agency_Placement__c,Fee_Recovery__c,
                          Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                          Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,
                          Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c,Purchase_Province__c,
                          Collection_Sub_Status__c, Data_Status_Description__c,Commission_Rate__c,Pool_Name__r.Commission_Rate__c,
                          Placement_Status__c, Pool_Name__r.Name, RecordTypeID,Allocated_Amount_Total__c,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                          Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Current_Balance__c,Purchase_Status__c,OwnerId,Previous_Ownership__c
                   FROM Product__c WHERE ID= :productID];
        if(product.Collection_Agency_Placement__c == NULL || product.Collection_Agency__c == 9999){
            ERROR_MSG = '';
        }
        else{
            ERROR_MSG = 'Product is already placed with another agency. Please recall the existing agency first.';
        }
        
        placement = new Placement__c();
        
        List<Placement_Status_Code_Mapping__c> listStatusCodes = [SELECT Parent_Status__c,Placement_Status_Code__c,
                                                                         Status__c,Sub_Status__c 
                                                                  FROM Placement_Status_Code_Mapping__c
                                                                  WHERE Placement_Status_Code__c = :NEW_ALLOCATION_READY
                                                                  ORDER BY Status__c ASC NULLS LAST];
        mapRecallCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        for(Placement_Status_Code_Mapping__c mapping : listStatusCodes){
            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
        }

        //Fetch System Api
        if(lrpSetting.Canaccede_API_User__c != NULL){
            systemName = [Select id, Name from User where username =: lrpSetting.Canaccede_API_User__c];    
        }
        //Fetch Product RecordType
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }
    }
    
    public static void getSnapshortRecords(List<Product__c> prodNew){
        System.enqueueJob(new SnapshotQueueableClass(prodNew));
    }
    
    public PageReference allocateWithWarning(){
        Set<id> setProductIDs = new Set<id>();
        setProductIDs.add(product.id);
		Map<String,Product__c> placementMainStatusMap = JudgmentTriggerHandler.updatePlacementMainStatus(setProductIDs);
        
        if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
           && Decimal.valueOf(placement.Name) != product.Collection_Agency__c){
               Id oldOwnerId = product.OwnerId;
               // Assign System API to Owner
               if(!systemName.isEmpty()){
                   product.OwnerId = systemName[0].Id;      
               }
               //Also Assign the last owner to the previous ownership field
               if(oldOwnerId != product.OwnerId && product.OwnerId != NULL){
                   product.Previous_Ownership__c = oldOwnerId;
               }
        }
        if(product.Current_Bal_NSF_Fees__c == NULL){
            product.Current_Bal_NSF_Fees__c = 0;
        }
        //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c + product.Current_Bal_NSF_Fees__c;
         if(product.Recoverable_Fee__c == NULL){
            product.Recoverable_Fee__c = 0;
        }
        product.Allocated_Amount_Fees__c = product.Recoverable_Fee__c + product.Current_Bal_NSF_Fees__c;  
        product.Allocated_Amount_Principal__c = product.Current_Principal_Balance__c;
        product.Allocated_Amount_Interest__c = product.Current_Interest_Amount__c;
        product.Collection_Agency__c = Decimal.valueOf(placement.Name);
        product.Collection_Agency_Placement__c = placement.ID;
        product.Assignment_Date__c = Date.today();
        product.Assignment_Accepted_Date__c = NULL;
        product.Recalled_Date__c = NULL;
        product.Product_Status__c = ALLOCATED;
        product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
        product.Placement_Status__c = NEW_ALLOCATION_READY ;
        product.Status_Changed_Date__c = Date.today();
        product.Invalid_Submission__c = false;
        product.Timestamp_Of_Invalid_Submission__c = null;
        product.Invalid_Submission_Reason__c = null;
        product.Collection_Sub_Status__c = null;
        product.Run_Identifier_Check_On__c = System.today();
        oldPlacementID = product.Collection_Agency_Placement__c; 
        /*if(!mapRecallCodeStatus.isEmpty()){
            product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
            product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
        }*/
        if(placementMainStatusMap.containskey(product.id)){
            product.Status__c = placementMainStatusMap.get(product.id).Status__c;
            product.Sub_Status__c = placementMainStatusMap.get(product.id).Sub_Status__c;
            product.Placement_Status__c = placementMainStatusMap.get(product.id).Placement_Status__c;
        }else{
            if(!mapRecallCodeStatus.isEmpty()){
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
            }
            product.Placement_Status__c = NEW_ALLOCATION_READY;
        }
        try{
            ProductTriggerHandler.runProductTrigger = false;
            update product;            
            listProduct.add(product);
            
            DistressedUtilities.createPlacementHistory(listProduct,oldPlacementID,placement.Commission_Rate__c,null);
            
            //Added by satyajit
            Map<Id,String> placeStatus = new Map<Id,String>();
            placeStatus.put(product.id,product.Placement_Status__c);
            
            List<Id> prodListId = new List<Id>();
            prodListId.add(product.Id);
            //5198:product reallocated to agency then judgment should be visible to respective agency
			map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>();
        	map<ID, Judgment__c> updateJudgments = new map<ID, Judgment__c>();
            for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c,Product__r.name
                                                   FROM Account_Judgment__c
                                                   WHERE Product__c= :productID
                                                   AND Status__c= 'Active'
                                                  ]){
                                                      mapActiveAccountJudgments.put(accJudgment.Product__c,accJudgment.Judgment__c);                             
                                                  }

            Judgment__c judgment = new Judgment__c();
            if(mapActiveAccountJudgments.containsKey(product.id) && mapActiveAccountJudgments.get(product.id) != NULL){
                judgment.id = mapActiveAccountJudgments.get(product.id);
                judgment.Legal_Agency__c = placement.Name;
                judgment.Legal_Agency_Placement__c = product.Collection_Agency_Placement__c;
                updateJudgments.put(judgment.id,judgment);
            }
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            JudgmentTriggerHandler.runJudgmentValidation = false;
            //bypass judgment validation rule
            applicationConfigSetting.Bypass_Judgement_Validation__c = false;
            update applicationConfigSetting;
            update updateJudgments.values();
            applicationConfigSetting.Bypass_Judgement_Validation__c = true;
            JudgmentTriggerHandler.runJudgmentValidation = true;
            JudgmentTriggerHandler.runJudgmentTrigger = true;
            update applicationConfigSetting;
            //Commented by satyajit
            //PortalProductProcessingAPI.processProduct(product.ID);
            
            //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Product Allocation Individual'), 200);
            
            //call judgment API call and notify to portal
            if(!Test.isRunningTest()){
                Database.executeBatch(new JudgmentAPIBatch(updateJudgments.values(),null,null,'Product Allocation Individual'), 50);
            }
            
            
            ProductTriggerHandler.runProductTrigger = true;
            ERROR_MSG = 'Product Allocated to Agency : ' +placement.Name + ' - ' + placement.Agency_Name__c;
        }
        catch(Exception ex){
            ERROR_MSG = ex.getMessage();
            system.debug('exception message'+ex.getStackTraceString());
        }
            
        return null;
    }
    
    //Allocate Product
    public PageReference allocateProduct(){
        Set<id> setProductIDs = new Set<id>();
        setProductIDs.add(product.id);
		Map<String,Product__c> placementMainStatusMap = JudgmentTriggerHandler.updatePlacementMainStatus(setProductIDs);
        
        NewPlacementAgency = product.Collection_Agency_Placement__c;  
        if(String.isBlank(NewPlacementAgency)){
            Blank_Agency = 'Please enter agency to allocate';
            return null;
        }
        Blank_Agency = '';
        Boolean error = validationOnRecordUpdate(product, NewPlacementAgency);
        if(error == false){
            if(product.Current_Bal_NSF_Fees__c == NULL){
                product.Current_Bal_NSF_Fees__c = 0;
            }
            if(product.Recoverable_Fee__c == NULL){
                product.Recoverable_Fee__c = 0;
            }

            if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                && Decimal.valueOf(placement.Name) != product.Collection_Agency__c){
                Id oldOwnerId = product.OwnerId;
                // Assign System API to Owner
                if(!systemName.isEmpty()){
                    product.OwnerId = systemName[0].Id;      
                }
                //Also Assign the last owner to the previous ownership field
                if(oldOwnerId != product.OwnerId && product.OwnerId != NULL){
                    product.Previous_Ownership__c = oldOwnerId;
                }
            }

            product.Allocated_Amount_Fees__c = product.Recoverable_Fee__c + product.Current_Bal_NSF_Fees__c; 
            //satyajit Comments the below line based on Ankur discussion.       
            //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c;
            product.Allocated_Amount_Principal__c = product.Current_Principal_Balance__c;
            product.Allocated_Amount_Interest__c = product.Current_Interest_Amount__c;
            product.Collection_Agency__c = Decimal.valueOf(placement.Name);
            product.Collection_Agency_Placement__c = placement.ID;
            product.Assignment_Date__c = Date.today();
            product.Assignment_Accepted_Date__c = NULL;
            product.Recalled_Date__c = NULL;
            product.Product_Status__c = ALLOCATED ;
            product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
            product.Placement_Status__c = NEW_ALLOCATION_READY;
            product.Status_Changed_Date__c = Date.today();
            product.Invalid_Submission__c = false;
            product.Timestamp_Of_Invalid_Submission__c = null;
            product.Invalid_Submission_Reason__c = null;
            product.Collection_Sub_Status__c = null;
            product.Run_Identifier_Check_On__c = System.today();
            oldPlacementID = product.Collection_Agency_Placement__c; 
            
            /*if(!mapRecallCodeStatus.isEmpty()){
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
            }*/
            if(placementMainStatusMap.containskey(product.id)){
                product.Status__c = placementMainStatusMap.get(product.id).Status__c;
                product.Sub_Status__c = placementMainStatusMap.get(product.id).Sub_Status__c;
                product.Placement_Status__c = placementMainStatusMap.get(product.id).Placement_Status__c;
            }else{
                if(!mapRecallCodeStatus.isEmpty()){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                }
                product.Placement_Status__c = NEW_ALLOCATION_READY;
            }
            try{
                ProductTriggerHandler.runProductTrigger = false;
                update product;
                
                 listProduct.add(product);
            
                DistressedUtilities.createPlacementHistory(listProduct,oldPlacementID,placement.Commission_Rate__c,null);
                
                //Added by satyajit
                Map<Id,String> placeStatus = new Map<Id,String>();
                placeStatus.put(product.id,product.Placement_Status__c);
                
                List<Id> prodListId = new List<Id>();
                prodListId.add(product.Id);
                //5198:product reallocated to agency then judgment should be visible to respective agency
                map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>();
                map<ID, Judgment__c> updateJudgments = new map<ID, Judgment__c>();
                for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c,Product__r.name
                                                       FROM Account_Judgment__c
                                                       WHERE Product__c= :productID
                                                       AND Status__c= 'Active'
                                                      ]){
                                                          mapActiveAccountJudgments.put(accJudgment.Product__c,accJudgment.Judgment__c);                             
                                                      }
                Judgment__c judgment = new Judgment__c();
                if(mapActiveAccountJudgments.containsKey(product.id) && mapActiveAccountJudgments.get(product.id) != NULL){
                    judgment.id = mapActiveAccountJudgments.get(product.id);
                    judgment.Legal_Agency__c = placement.Name;
                    judgment.Legal_Agency_Placement__c = product.Collection_Agency_Placement__c;
                    updateJudgments.put(judgment.id,judgment);
                }
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                JudgmentTriggerHandler.runJudgmentValidation = false;
                //bypass judgment validation rule
                applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                update applicationConfigSetting;
                update updateJudgments.values();
                applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                JudgmentTriggerHandler.runJudgmentValidation = true;
                JudgmentTriggerHandler.runJudgmentTrigger = true;
                update applicationConfigSetting;
                
                //call product API
                Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Product Allocation Individual'), 200);
                
                //call judgment API call and notify to portal
                if(!Test.isRunningTest()){
            		Database.executeBatch(new JudgmentAPIBatch(updateJudgments.values(),null,null,'Product Allocation Individual'), 50);
                }
                
                ProductTriggerHandler.runProductTrigger = true;
                ERROR_MSG = 'Product Allocated to Agency : ' +placement.Name + ' - ' + placement.Agency_Name__c;
            }
            catch(Exception ex){
                ERROR_MSG = ex.getMessage();
                system.debug('---'+ex.getStackTraceString());
            }
            
        }
        else{
            system.debug('ERROR_MSG: '+ERROR_MSG);
        }
        return null;
    }
    
    //Validation method to be called  before update
    public Boolean validationOnRecordUpdate(Product__c product, String newPlacement){
        Boolean error;
        String EXPECTED;
        String AgencyProvince;
        Set<String> setProductAgencyName = new Set<String>();
        
        placement = [SELECT ID, Name, Agency_Name__c, Serviceable_Province__c,Commission_Rate__c,Active__c
                     FROM Placement__c 
                     WHERE ID= :newPlacement
                     ][0];
        
        //Get Placement History for new Distressed Products for last 6months
        list<Placement_History__c> placementHistory = [SELECT ID, Placement__c, Product__c, Product__r.Name
                                                     FROM Placement_History__c
                                                     WHERE Product__r.Name = :product.Name
                                                     AND Placement__c = :newPlacement
                                                     AND CreatedDate = LAST_N_DAYS:180];
        
        //Fill provice name map with abbriviations                                            
        for(Provice_Name_Map_with_Abbreviations__mdt metaData : mapProviceAbbreviations.values()){
            mapProvinceAcronym.put(metaData.Province_Acronym__c,metaData.Province_Name__c);
        }
        
        ERROR_MSG = '';
        
		if(product.Collection_Agency__c != NULL && product.Collection_Agency__c != 9999){
            ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with another agency'+'<br/>';
            EXPECTED += 'Current Agency- ' + product.Collection_Agency__c +'<br/>';
        }
        if(String.isNotBlank(product.Purchase_Status__c) && product.Purchase_Status__c != 'Buyback/Putback Rejected'){
            ERROR_MSG += '<b>ERROR</b> - '+'Product is in Buyback/Putback state'+'<br/>';
        }
        if(placement != NULL
             && String.isNotBlank(placement.Serviceable_Province__c)){
                AgencyProvince = placement.Serviceable_Province__c; 
        }
        if(String.isBlank(product.Purchase_Province__c) && !Test.isRunningTest()){
             ERROR_MSG += '<b>ERROR</b> - '+'Purchase Province Required'+'<br/>';
        }
        if(String.isNotBlank(newPlacement)
        && String.isNotBlank(AgencyProvince)
        && String.isNotBlank(product.Purchase_Province__c) 
        && (!AgencyProvince.contains(product.Purchase_Province__c))
        && ( (!mapProvinceAcronym.containsKey(product.Purchase_Province__c) && !AgencyProvince.contains(product.Purchase_Province__c))
        ||   (mapProvinceAcronym.containsKey(product.Purchase_Province__c)  &&!AgencyProvince.contains(mapProvinceAcronym.get(product.Purchase_Province__c))))){
               ERROR_MSG += '<b>ERROR</b> - '+'Product cannot be placed with agency as Product Purchase Province is Non Serviceable for Agency'+'<br/>';
               EXPECTED += 'Product Purchase Province should be either - ' + AgencyProvince +'<br/>';
        } 
        if(!placementHistory.isEmpty()){
            ERROR_MSG += '<b>WARNING</b> - '+'Product is placed with the agency in last 6 months'+'<br/>';
        }
        if(String.isNotBlank(newPlacement)){
            if(String.isNotBlank(product.Collection_Sub_Status__c)){
                String collectionSubStatus = product.Collection_Sub_Status__c;
                if(collectionSubStatus == 'Credit Counselling'){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                }
                else if(collectionSubStatus == 'Cease and Desist – In Writing'){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Cease and Desist – In Writing Collection Sub Status'+'<br/>';
                }
                else if(collectionSubStatus == 'Buy back/put back and sale categories'){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Buy back/put back and sale categories Collection Sub Status'+'<br/>';
                }
                else if(collectionSubStatus == 'Paid in Full Account'){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Paid in Full Account Collection Sub Status'+'<br/>';
                }
                else if(collectionSubStatus == 'Fraud Claimed'){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Fraud Claimed Collection Sub Status'+'<br/>';
                }
            }   
            if(String.isNotBlank(product.Data_Status_Description__c)){
                String dataStatus = product.Data_Status_Description__c;
                if(dataStatus.contains('Closed')){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is in Closed Status'+'<br/>';    
                }
                else if(dataStatus.contains('Insolvency') 
                || dataStatus.contains('Insolvent')){
                    ERROR_MSG += '<b>ERROR</b> - '+'Product is Insolveny Status'+'<br/>';    
                } 
            }
            if(placement.Active__c == False){
                ERROR_MSG += '<b>ERROR</b> - Allocate Agency is not Active <br/>';
            }
        }

        if(String.isNotBlank(ERROR_MSG)){
            return true;
        }
        else{
            return false;
        }
    }
    
    public pageReference redirectToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}