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
    
    public String ERROR_MSG {get;set;}
    public String Blank_Agency {get;set;}
    public String productID {get;set;}
    public String NewPlacementAgency {get;set;}
    String oldPlacementID;
    public Product__c product {get;set;}
    public List<Product__c> listProduct = new List<Product__c>();
    public Placement__c placement;
    public String placeStatus;
    
    public ProductAllocationIndividualController(ApexPages.StandardController stdController) {
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, State__c, Collection_Agency__c, Collection_Agency_Placement__c,Fee_Recovery__c,
                          Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                          Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,
                          Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c,
                          Collection_Sub_Status__c, Data_Status_Description__c,Commission_Rate__c,Pool_Name__r.Commission_Rate__c,
                          Placement_Status__c, Pool_Name__r.Name, RecordTypeID,Allocated_Amount_Total__c,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Current_Balance__c,Purchase_Status__c
                   FROM Product__c WHERE ID= :productID];
        system.debug('product: '+product);
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
            system.debug('mapping.Status__c: '+mapping.Status__c);
            system.debug('mapping.Sub_Status__c: '+mapping.Sub_Status__c);
            system.debug('mapping.Placement_Status_Code__c: '+mapping.Placement_Status_Code__c);
            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
        }
        
        system.debug('placementStatusMap::'+placementStatusMap);
    }
    
    public static void getSnapshortRecords(List<Product__c> prodNew){
        Map<Id, List<Id>> agencyTo_ProductIdsMap = new Map<Id, List<Id>>();
        List<Id> productIds = new List<Id>();
            for(Product__c prod : prodNew){
                productIds.add(prod.Id);
                system.debug('productIds' +productIds);
                agencyTo_ProductIdsMap.put(prod.Collection_Agency_Placement__c, productIds );
                system.debug('agencyTo_ProductIdsMap' +agencyTo_ProductIdsMap);
            }
            if(!agencyTo_ProductIdsMap.isEmpty()){
                for(Id agencyId : agencyTo_ProductIdsMap.keySet()){
                    system.debug('agencyId' +agencyId);
                System.enqueueJob(new SnapshotQueueableClass(productIds, agencyId));
                //System.enqueueJob(new SnapshotQueueableClassForExcel(agencyTo_ProductIdsMap.get(agencyId), agencyId));
                    
                }
            }
    }
    
    public PageReference allocateWithWarning(){
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
        //product.Invalid_Submission_Initiated_By__c = null;
        oldPlacementID = product.Collection_Agency_Placement__c; 
        if(!mapRecallCodeStatus.isEmpty()){
            product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
            product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
        }
        
        try{
            ProductTriggerHandler.runProductTrigger = false;
            update product;            
            listProduct.add(product);
            
            DistressedUtilities.createPlacementHistory(listProduct,oldPlacementID,placement.Commission_Rate__c);
            
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
                judgment.Placed_Agency__c = placement.Name;
                updateJudgments.put(judgment.id,judgment);
            }
            update updateJudgments.values();
            
            //Commented by satyajit
            //PortalProductProcessingAPI.processProduct(product.ID);
            
            //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Product Allocation File'), 200);
            
            ProductTriggerHandler.runProductTrigger = true;
            getSnapshortRecords(new List<Product__c>{product});
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
            oldPlacementID = product.Collection_Agency_Placement__c; 
            
            if(!mapRecallCodeStatus.isEmpty()){
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
            }
            
            try{
                ProductTriggerHandler.runProductTrigger = false;
                update product;
                
                 listProduct.add(product);
            
                DistressedUtilities.createPlacementHistory(listProduct,oldPlacementID,placement.Commission_Rate__c);
                
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
                    judgment.Placed_Agency__c = placement.Name;
                    updateJudgments.put(judgment.id,judgment);
                }
                update updateJudgments.values();
                
                //Commented by satyajit
                //PortalProductProcessingAPI.processProduct(product.ID);
                
                //Added by satyajit
                Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Product Allocation File'), 200);
                
                getSnapshortRecords(new List<Product__c>{product});
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
        Map<String, String> mapProvinceNames = new Map<String, String>();
        
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
        mapProvinceNames.put('NS', 'Nova Scotia');
        mapProvinceNames.put('NB', 'New Brunswick');
        mapProvinceNames.put('MB', 'Manitoba');
        mapProvinceNames.put('BC', 'British Columbia');
        mapProvinceNames.put('PE', 'Prince Edward Island');
        mapProvinceNames.put('SK', 'Saskatchewan');
        mapProvinceNames.put('AB',  'Alberta');
        mapProvinceNames.put('NL', 'Newfoundland and Labrador');
        mapProvinceNames.put('QC', 'Quebec');
        mapProvinceNames.put('ON', 'Ontario');  
        
        ERROR_MSG = '';
        
        /*if(!mapPlacement.containsKey(newPlacement)){
            ERROR_MSG += '<b>ERROR</b> - '+'Enter valid Collection Agency Number'+'<br/>';
        }
        else */if(product.Collection_Agency__c != NULL && product.Collection_Agency__c != 9999){
            ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with another agency'+'<br/>';
            EXPECTED += 'Current Agency- ' + product.Collection_Agency__c +'<br/>';
            system.debug('already placed error');
        }
        
        
        if(placement != NULL
             && String.isNotBlank(placement.Serviceable_Province__c)){
                AgencyProvince = placement.Serviceable_Province__c; 
        }
        
        system.debug('AgencyProvince: '+AgencyProvince);
        system.debug('product.State__c: '+product.State__c);
        
        if(String.isNotBlank(newPlacement)
        && String.isNotBlank(AgencyProvince)
        && String.isNotBlank(product.State__c) 
        && (!AgencyProvince.contains(product.State__c))
        && ( (!mapProvinceNames.containsKey(product.State__c) && !AgencyProvince.contains(product.State__c))
        ||   (mapProvinceNames.containsKey(product.State__c)  &&!AgencyProvince.contains(mapProvinceNames.get(product.State__c))))){
               system.debug('error');
               ERROR_MSG += '<b>ERROR</b> - '+'Product cannot be placed with agency as Product Province is Non Serviceable for Agency'+'<br/>';
               EXPECTED += 'Product Province - ' + product.State__c +'<br/>';
               system.debug('province error');
        } 
        
        if(!placementHistory.isEmpty()){
            ERROR_MSG = '<b>WARNING</b> - '+'Product is placed with the agency in last 6 months'+'<br/>';
            system.debug('previously placed');
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
        system.debug('ERROR_MSG:: '+ERROR_MSG);
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