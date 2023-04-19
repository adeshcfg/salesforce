/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to allocate Placement to product   from Pool record
*  @author : A5E Consulting
*  @date : 05/03/2022

*************************************************************************************************/
public class AgencyPoolAllocationController {
    
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    
    public static final String NEW_ALLOCATION_READY = '100000';
    public static final String NEW_ALLOCATION_READY_STR = 'New Allocation (1.0); Ready';
    public static final String ALLOCATED = '300000';
    public static final String PLACEMENT_ALLOCATED = 'Placement (3); Allocated';
    
    public Pool__c poolRecord { get; set; }
    public String NewPlacementAgency {get;set;}  
    public list<Product__c> listProd {get;set;}
    public list<productWrapper> listProdWrapper {get;set;}
    public String ERROR_MSG {get;set;}
    public String Alert_msg {get;set;}
    public String Alert {get;set;}
    public String recordCount {get;set;}
    public Placement__c placement;
    List <Pool__c> updatePool = new List<Pool__c>();
    List <Pool__c> pool = new List<Pool__c>();
    string poolId ;    
    public boolean countrefresh{get;set;}
    public boolean error{get;set;}
    public boolean allocatebtndisable{get;set;}
    public boolean warningbtndisable{get;set;}
    public String oldPlacementID;
    public String placeStatus;
    list<Placement_History__c> placementHistoryList = new list<Placement_History__c>(); 
    public AgencyPoolAllocationController(ApexPages.StandardController stdController){
        poolId = ApexPages.CurrentPage().getParameters().get('Id'); 
        poolRecord = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        
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
        
        listProdWrapper = new List<productWrapper>();
    
        system.debug('ID  '+poolId);
        
        listProd = [Select Id,Name,Pool_Name__c, DebtNext_Data_ID__C, Collection_Agency__c,Placement_Status__c,Fee_Recovery__c,
                    Collection_Sub_Status__c, Data_Status_Description__c, Current_Balance__c,State__c,Legal_Status__c, Status__c,Sub_Status__c,
                    Assignment_Date__c,Recalled_Date__c,Pool_Name__r.Placement_Agency__c,Collection_Agency_Placement__c,
                    Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                    Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,Allocated_Amount_Total__c,Pool_Name__r.Name,
                    Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c,Commission_Rate__c,Pool_Name__r.Commission_Rate__c,
                    Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c                                       
                    from Product__C
                    WHERE Pool_Name__c =: poolId AND (Collection_Agency__c = NULL OR Collection_Agency__c = 9999)]; 
        if(poolRecord.Placement_Agency__c == 9999){
            Alert_msg = ' ';
            
        }
        if(listProd.isEmpty() && poolRecord.Placement_Agency__c != NULL){ 
            //if(poolRecord.Placement_Agency__c != NULL){
                error = true;
              //  Alert = ' ';           
                allocatebtndisable = true;
                warningbtndisable = true;
                Alert = 'Pool is already placed with another agency to place agency please recall the previous one.<br/> The are no Products to Allocate Agency';
            }
        else if(listProd.isEmpty()){
            error = true;
          //  Alert = ' ';           
            allocatebtndisable = true;
            warningbtndisable = true;
            Alert = 'The are no Products to Allocate Agency';
        }
        if(poolRecord.Placement_Agency__c == 9999){
            Alert_msg = ' ';
            warningbtndisable = true;
        }
        else if(!listProd.isEmpty() && poolRecord.Placement_Agency__c != NULL){ 
            warningbtndisable = true;
            // allocatebtndisable = false;
            Alert = 'Products will be allocated to Agency: '+poolRecord.Placement_Agency__c;
        }
        if(poolRecord.Placement_Agency__c == NULL){
            Alert_msg = ' ';
            warningbtndisable = true;
            poolRecord.Placement_agency_lookup__c = null;
        }
  
        placement = new Placement__c();        
        system.debug('Product List1  '+listProd);
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
                    System.enqueueJob(new SnapshotQueueableClass(productIds, agencyId));
                    
                    //As Discussed with ankur satyajit commented this class
                    //System.enqueueJob(new SnapshotQueueableClassForExcel(agencyTo_ProductIdsMap.get(agencyId), agencyId));
                }
            }
    }
    
    public PageReference allocateAgencyToProduct(){
        countrefresh = false;
        String productNames = '';
        system.debug('poolRecord  '+poolRecord);
        NewPlacementAgency = poolRecord.Placement_agency_lookup__c; 
        listProdWrapper = new list<productWrapper>();
        system.debug('NewPlacementAgency  '+NewPlacementAgency);
        list<Product__c> productList = new list<Product__c>();
        list<Id> prodIdList = new list<Id>();
        Map<Id,String> placeStatusMap = new Map<Id,String>();
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        system.debug('Pool ID   '+poolId);
        system.debug('Product List  '+listProd);
       
        map<string,string> validation =  validationOnRecordUpdate(listProd,NewPlacementAgency);
        system.debug('placement  '+placement.Name);
        //system.debug('validation  '+validationOnRecordUpdate(listProd,NewPlacementAgency));
        //if(validation == 'SUCCESS'){
           system.debug('inside validation ');
        //}
        //else{
            system.debug('inside else ');
            for(Product__C product : listProd ){
            
                if(product.Placement_Status__c != null){
                    placeStatus = product.Placement_Status__c;
                }

                String checkValid = validation.get(product.name);
                if(checkValid.contains('SUCCESS')){
                    
                system.debug('inside checkValid'+checkValid);
                system.debug('inside product success'+product.name);    
                if(checkValid.contains('ERROR')){
                    system.debug('inside error');
                }else{
                    system.debug('outside error');
                }
                oldPlacementID = product.Collection_Agency_Placement__c;
                if(product.Current_Bal_NSF_Fees__c == NULL){
                    product.Current_Bal_NSF_Fees__c = 0;
                }
                //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c + product.Current_Bal_NSF_Fees__c;       
                 product.Allocated_Amount_Fees__c = product.Recoverable_Fee__c + product.Current_Bal_NSF_Fees__c; 
                //satyajit Comments the below line based on Ankur discussion.         
                //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c;
                product.Allocated_Amount_Principal__c = product.Current_Principal_Balance__c;
                product.Allocated_Amount_Interest__c = product.Current_Interest_Amount__c;
                product.Collection_Agency__c = Decimal.valueOf(placement.Name);
                product.Collection_Agency_Placement__c = NewPlacementAgency;
                //system.debug('On update call   '+ product.Collection_Agency__c);
                product.Assignment_Date__c = Date.today();
                product.Assignment_Accepted_Date__c = NULL;
                product.Recalled_Date__c = NULL;
                product.Product_Status__c = ALLOCATED;
                product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
                product.Placement_Status__c = NEW_ALLOCATION_READY;
                product.Status_Changed_Date__c = Date.today();
                
                product.Collection_Sub_Status__c = null;
                
                productList.add(product);
                prodIdList.add(product.id);
                
                placeStatusMap.put(product.id,product.Placement_Status__c);
                productNames += product.Name + ',';
                if(!mapRecallCodeStatus.isEmpty()){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                }
                //List<Product__c> prodNewList = new  List<Product__c>();
                //prodNewList.add(product);
                /*Placement_History__c placementHistory = new Placement_History__c();                
                placementHistory.Product__c = product.id;
                placementHistory.Placement__c =  newPlacementAgency;    
                //placementHistory.Placement_Recall_Date__c = Date.today();
                placementHistory.Placement_Status__c = product.Placement_Status__c;
                placementHistory.Placement_Status_Description__c = NEW_ALLOCATION_READY_STR;
                placementHistory.Placement_Date__c = product.Assignment_Date__c;
                placementHistory.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                placementHistory.Current_Interest_Balance__c = product.Current_Interest_Amount__c;
                placementHistory.Interest_Rate__c = product.Interest_Rate__c;
                placementHistory.NSF_Fees__c = product.Current_Bal_NSF_Fees__c;
                placementHistory.Current_Bal_Attorney_Fees__c = product.Current_Bal_Attorney_Fees__c;
                placementHistory.Current_Bal_General_Fees__c = product.Current_Bal_General_Fees__c;
                placementHistory.Current_Bal_Other_Fees__c = product.Current_Bal_Other_Fees__c;
                placementHistory.Current_Bal_Court_Fees__c = product.Current_Bal_Court_Fees__c;
               // placementHistory.Commission_Rate__c = product.Collection_Agency_Placement__r.Commission_Rate__c;
                placementHistory.Commission_Rate__c = placement.Commission_Rate__c;
                placementHistory.Pool_Commission_Rate__c = product.Pool_Name__r.Commission_Rate__c;
                placementHistory.Product_Commission_Rate__c = product.Commission_Rate__c;
                placementHistory.Pool_ID__c = product.Pool_Name__r.Name;
                placementHistory.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
                placementHistory.Value_Tier_at_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
                placementHistory.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
                placementHistory.Recoverable_fee_balance__c = product.Recoverable_Fee__c;
                placementHistory.Non_recoverable_fee_balance__c = product.Non_Recoverable_Fee__c;
                placementHistory.Placement_Status_at_time_of_recall__c = placeStatus;
                placementHistory.Total_Balance_at_Placement__c = product.Current_Balance__c;*/
               //placementHistory.Allocated_Balance__c = product.Allocated_Amount_Total__c;
                if(product.Allocated_Amount_Fees__c == NULL){
                    product.Allocated_Amount_Fees__c = 0;
                }
                if(product.Allocated_Amount_Principal__c == NULL){
                    product.Allocated_Amount_Principal__c = 0;
                }
                if(product.Allocated_Amount_Interest__c == NULL){
                    product.Allocated_Amount_Interest__c = 0;
                }
                //placementHistory.Allocated_Balance__c = product.Allocated_Amount_Fees__c + product.Allocated_Amount_Principal__c + product.Allocated_Amount_Interest__c;
                //System.debug('commission Rate '+placement.Commission_Rate__c);
                //placementHistoryList.add(placementHistory);
                }
            }
            productNames = productNames.removeEnd(',');
          try{
              system.debug('Pool Record '+poolRecord); 
              for(Pool__c poolRec : pool ){                  
                  poolRec.Placement_Agency__c = Decimal.valueOf(placement.Name);    
                  poolRec.Placement_agency_lookup__c = poolRecord.Placement_agency_lookup__c;
               
              }
              system.debug('updatePool' +updatePool);
              ProductTriggerHandler.runProductTrigger = false;
              update productList;
              
              DistressedUtilities.createPlacementHistory(productList, newPlacementAgency,placement.Commission_Rate__c);
              //insert placementHistoryList;
              system.debug('API 1 ');
              
              //Commented by satyajit
              //PortalProductStatusBulkAPI.processBulkProducts(productNames, NEW_ALLOCATION_READY, ALLOCATED, String.valueOf(Date.today()), 
                                           //'Allocation',placement.Name, poolRecord.Name);
                                           
            //Added by satyajit for ticket 4307
            Database.executeBatch(new BatchProcessForProdScreen(prodIdList,placeStatusMap,'Account Status Update File'), 200);  
            
              system.debug('API 2 ');
              update pool;
              getSnapshortRecords(productList);
              ProductTriggerHandler.runProductTrigger = true;
             
              countrefresh = true;
               recordCount = 'No. of Success Records: '+ productList.size() +'<br/>';
              Alert = 'Products Allocated to Agency : ' +placement.Name + ' - ' + placement.Agency_Name__c;                    
            }
            catch(Exception ex){
                system.debug('exception***: '+ex);
                //Alert = ex.getMessage();
            }
        //}
        return null;
    }
    
    public PageReference allocateWithWarning(){
        countrefresh = false;
        system.debug('poolRecord  '+poolRecord);
        String productNames = '';
        NewPlacementAgency = poolRecord.Placement_agency_lookup__c; 
        listProdWrapper = new list<productWrapper>();
        
        system.debug('NewPlacementAgency  '+NewPlacementAgency);
        
        list<Product__c> productList = new list<Product__c>(); 
        list<Id> prodIdList = new list<Id>();
        Map<Id,String> placeStatusMap = new Map<Id,String>();
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        
        system.debug('Pool ID   '+poolId);
        system.debug('Product List  '+listProd); 
        
        map<string,string> validation =  validationOnRecordUpdate(listProd,NewPlacementAgency);
        
        system.debug('validation  '+validation);
        system.debug('placement  '+placement.Name);        
        //system.debug('validation  '+validationOnRecordUpdate(listProd,NewPlacementAgency));
      
            for(Product__C product : listProd ){
            
                if(product.Placement_Status__c != null){
                    placeStatus = product.Placement_Status__c;
                }

                String checkValid = validation.get(product.name);
                if(checkValid.contains('WARNING') && !checkValid.contains('ERROR')){
                system.debug('inside checkValid'+checkValid);
                if(checkValid.contains('ERROR')){
                    system.debug('inside error');
                }else{
                    system.debug('outside error');
                }
                oldPlacementID = product.Collection_Agency_Placement__c;
                if(product.Current_Bal_NSF_Fees__c == NULL){
                    product.Current_Bal_NSF_Fees__c = 0;
                }
               // product.Allocated_Amount_Fees__c = product.Fee_Recovery__c + product.Current_Bal_NSF_Fees__c;
                 product.Allocated_Amount_Fees__c = product.Recoverable_Fee__c + product.Current_Bal_NSF_Fees__c; 
                //satyajit Comments the below line based on Ankur discussion 
                //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c;
                product.Allocated_Amount_Principal__c = product.Current_Principal_Balance__c;
                product.Allocated_Amount_Interest__c = product.Current_Interest_Amount__c;
                product.Collection_Agency__c = Decimal.valueOf(placement.Name);
                product.Collection_Agency_Placement__c = NewPlacementAgency;
                //system.debug('On update call   '+ product.Collection_Agency__c);
                product.Assignment_Date__c = Date.today();
                product.Assignment_Accepted_Date__c = NULL;
                product.Recalled_Date__c = NULL;
                product.Product_Status__c = ALLOCATED;
                product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
                product.Placement_Status__c = NEW_ALLOCATION_READY;
                product.Status_Changed_Date__c = Date.today();
                
                product.Collection_Sub_Status__c = null;
                
                productList.add(product);
                prodIdList.add(product.id);
                placeStatusMap.put(product.id,product.Placement_Status__c);
                productNames += product.Name + ',';
                if(!mapRecallCodeStatus.isEmpty()){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                }
                /*Placement_History__c placementHistory = new Placement_History__c();                
                placementHistory.Product__c = product.id;
                placementHistory.Placement__c =  NewPlacementAgency;    
                //placementHistory.Placement_Recall_Date__c = Date.today();
                placementHistory.Placement_Status__c = product.Placement_Status__c;
                placementHistory.Placement_Status_Description__c = NEW_ALLOCATION_READY_STR;
                placementHistory.Placement_Date__c = product.Assignment_Date__c;
                placementHistory.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                placementHistory.Current_Interest_Balance__c = product.Current_Interest_Amount__c;
                placementHistory.Interest_Rate__c = product.Interest_Rate__c;
                placementHistory.NSF_Fees__c = product.Current_Bal_NSF_Fees__c;
                placementHistory.Current_Bal_Attorney_Fees__c = product.Current_Bal_Attorney_Fees__c;
                placementHistory.Current_Bal_General_Fees__c = product.Current_Bal_General_Fees__c;
                placementHistory.Current_Bal_Other_Fees__c = product.Current_Bal_Other_Fees__c;
                placementHistory.Current_Bal_Court_Fees__c = product.Current_Bal_Court_Fees__c;
               // placementHistory.Commission_Rate__c = product.Collection_Agency_Placement__r.Commission_Rate__c;
                placementHistory.Commission_Rate__c = placement.Commission_Rate__c;
                 placementHistory.Pool_Commission_Rate__c = product.Pool_Name__r.Commission_Rate__c;
                placementHistory.Product_Commission_Rate__c = product.Commission_Rate__c;
                placementHistory.Pool_ID__c = product.Pool_Name__r.Name;
                placementHistory.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
                placementHistory.Value_Tier_at_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
                placementHistory.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
                placementHistory.Recoverable_fee_balance__c = product.Recoverable_Fee__c;
                placementHistory.Non_recoverable_fee_balance__c = product.Non_Recoverable_Fee__c;
                placementHistory.Placement_Status_at_time_of_recall__c = placeStatus;
                 placementHistory.Total_Balance_at_Placement__c = product.Current_Balance__c;*/
                //placementHistory.Allocated_Balance__c = product.Allocated_Amount_Total__c;
                if(product.Allocated_Amount_Fees__c == NULL){
                    product.Allocated_Amount_Fees__c = 0;
                }
                if(product.Allocated_Amount_Principal__c == NULL){
                    product.Allocated_Amount_Principal__c = 0;
                }
                if(product.Allocated_Amount_Interest__c == NULL){
                    product.Allocated_Amount_Interest__c = 0;
                }
                //placementHistory.Allocated_Balance__c = product.Allocated_Amount_Fees__c + product.Allocated_Amount_Principal__c + product.Allocated_Amount_Interest__c;
                //System.debug('commission Rate '+placement.Commission_Rate__c);
                //placementHistoryList.add(placementHistory);
                }
            }
          try{
              system.debug('Pool Record '+poolRecord); 
              for(Pool__c poolRec : pool ){                  
                  poolRec.Placement_Agency__c = Decimal.valueOf(placement.Name);    
                  poolRec.Placement_agency_lookup__c = poolRecord.Placement_agency_lookup__c;
                  //updatePool.add(poolRec);
              }
              system.debug('updatePool' +updatePool);
            
                ProductTriggerHandler.runProductTrigger = false;
              update productList;
              
              DistressedUtilities.createPlacementHistory(productList, newPlacementAgency,placement.Commission_Rate__c);
              
             // insert placementHistoryList;
             
               //Commented by satyajit
             // PortalProductStatusBulkAPI.processBulkProducts(productNames, NEW_ALLOCATION_READY, ALLOCATED, String.valueOf(Date.today()), 
                                          // 'Allocation',placement.Name, poolRecord.Name);
              //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodIdList,placeStatusMap,'Account Status Update File'), 200);  
            
              update pool;
              getSnapshortRecords(productList);
              ProductTriggerHandler.runProductTrigger = true;
              warningbtndisable = true;
              allocatebtndisable = true;
              countrefresh = true;
              recordCount = 'No. of Success Records: '+ productList.size() +'<br/>';
              Alert = 'Products Allocated to Agency : ' +placement.Name + ' - ' + placement.Agency_Name__c;        
               
            }
            catch(Exception ex){
                //Alert_msg = ex.getMessage();
            }
        //}
        return null;
    }
    
    public static Set<String> getPlacementHistoryDetails(set<String> setProductName){
        set<String> setProductAgencyName = new set<String>();
        //Get Placement History for new Distressed Products
        for(Placement_History__c placementHistory : [SELECT ID, Agency_Id__c, Product__c, Product__r.Name,Placement__c
                                                     FROM Placement_History__c
                                                     WHERE Product__r.Name IN :setProductName
                                                     AND CreatedDate = LAST_N_DAYS:180]){
            setProductAgencyName.add(placementHistory.Product__r.Name + placementHistory.Placement__c );  
        }
        system.debug('setProductAgencyName::'+setProductAgencyName);
        return setProductAgencyName;
    }
    
    //Validation method to be called  before update
    public map<string,string> validationOnRecordUpdate(List<Product__c> listProd,String placementAgency ){
        ERROR_MSG = '';
        String comments = '';
        String newAgency;
        String oldAgency;
        String AgencyProvince;
        Decimal successRecords = 0;
        Decimal errorRecords = 0;
        Decimal warningRecords = 0;
        recordCount = '';
        warningbtndisable = true;
        allocatebtndisable = true;
        set<String> setProductNames = new set<String>();
        Map<String, String> mapProvinceNames = new Map<String, String>();
        map<string,string> mapProductUpdate = new map<string,string>();
        set<String> setPreviousPlacedProductNames = new set<String>();
        system.debug('String placement '+placementAgency);

        placement = [SELECT ID, Name, Serviceable_Province__c,Agency_Name__c,Commission_Rate__c
                     FROM Placement__c 
                     WHERE ID= :placementAgency
                    ][0];
        
        system.debug(' placement Name '+placement.Name);
        
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
        
        for(Product__c product : listProd){
            setProductNames.add(product.name);  
        }
        setPreviousPlacedProductNames = getPlacementHistoryDetails(setProductNames);
        for(Product__c product: listProd){
            // listProdWrapper = new list<productWrapper>();
            ERROR_MSG = '';
            error = false;
            System.debug('1 '+error);
            system.debug('product.Name: '+product.Name);
            newAgency = placementAgency ;
            oldAgency = '';
            system.debug('newAgency: '+newAgency);
            if(product.Collection_Agency__c  != NULL){
                oldAgency = String.valueOf(product.Collection_Agency__c);    
            }
            if(placement != NULL
               && String.isNotBlank(placement.Serviceable_Province__c)){
                   AgencyProvince = placement.Serviceable_Province__c; 
               }
            
            system.debug('AgencyProvince: '+AgencyProvince);
            system.debug('product.State__c: '+product.State__c);
            if(String.isNotBlank(newAgency)
               && String.isNotBlank(AgencyProvince) 
               && String.isNotBlank(product.State__c) 
               && ( (!mapProvinceNames.containsKey(product.State__c) && !AgencyProvince.contains(product.State__c))
                   ||   (mapProvinceNames.containsKey(product.State__c)  &&!AgencyProvince.contains(mapProvinceNames.get(product.State__c))))){
                       system.debug('error');
                       ERROR_MSG += '<b>ERROR</b> - '+'Product cannot be placed with agency as Product Province is Non Serviceable for Agency'+'<br/>';
                       //  EXPECTED += 'Product Province - ' + mapProductName.get(product.Name).State__c +'<br/>';
                       //error = true;
                       system.debug('province error');
                       comments = ERROR_MSG;
                       System.debug('2 '+error);
                       //oldAgency = '';
                   }          
            
            if(setPreviousPlacedProductNames.contains(product.Name+ newAgency)){
                ERROR_MSG += '<b>WARNING</b> - '+'Product is placed with the agency in last 6 months'+'<br/>';
                //product.addError('Product is placed with the agency in last 6 months');
                system.debug('previously placed');
                comments = ERROR_MSG;
                error = true;
                System.debug('3 '+error);
            }
            
            if(String.isNotBlank(newAgency)){
                if(String.isNotBlank(product.Collection_Sub_Status__c)){
                    String collectionSubStatus = product.Collection_Sub_Status__c;
                    if(collectionSubStatus == 'Credit Counselling'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
                    /*else if(collectionSubStatus == 'Credit Counselling'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                    }*/
                    else if(collectionSubStatus == 'Cease and Desist – In Writing'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Cease and Desist – In Writing Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
                    else if(collectionSubStatus == 'Buy back/put back and sale categories'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Buy back/put back and sale categories Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
                    else if(collectionSubStatus == 'Paid in Full Account'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Paid in Full Account Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
                    else if(collectionSubStatus == 'Fraud Claimed'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Fraud Claimed Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
                }
                
                
                if(String.isNotBlank(product.Data_Status_Description__c)){
                    String dataStatus = product.Data_Status_Description__c;
                    system.debug('dataStatus'+dataStatus);
                    if(dataStatus.contains('Closed')){
                        system.debug('inside closed');
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Closed Status'+'<br/>';  
                        comments = ERROR_MSG;
                    }
                    else if(dataStatus.contains('Insolvency') 
                         || dataStatus.contains('Insolvent')){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is Insolveny Status'+'<br/>';
                        comments = ERROR_MSG;     
                    } 
                }
            }
            
            
            if(String.isBlank(ERROR_MSG)){
                ERROR_MSG = 'SUCCESS';                
                comments = ERROR_MSG;
            } 
         system.debug('comments check***'+Comments);
            mapProductUpdate.put(product.name,comments);
            system.debug('mapProductUpdate check'+mapProductUpdate);
            //if(error == true){
                if(comments == 'SUCCESS' ){
                    successRecords = successRecords + 1;                   
                }else{                    
                    listProdWrapper.add(new productWrapper(product, comments));
                    //failedRecords = failedRecords + 1;
                  system.debug('listProdWrapper check'+listProdWrapper);
                    if(comments.contains('ERROR')){
                        // allocatebtndisable = true;
                       // Alert = '';
                        allocatebtndisable = true;
                        errorRecords = errorRecords + 1;
                        warningbtndisable = true;
                    }
                    else if(comments.contains('WARNING')){
                        warningRecords = warningRecords + 1;
                        //Alert = ' ';
                         warningbtndisable = false;
                         allocatebtndisable = true;
                    }
                    else{
                         warningbtndisable = true;
                         allocatebtndisable = false;
                    }
                }
            //} 
        }
        if(successRecords != null){
            if(successRecords > 0){
                countrefresh = true;
                recordCount += 'No. of Success Records: '+ successRecords +'<br/>';
            }
            else{
               countrefresh = true;
                recordCount += 'No. of Success Records: '+ successRecords +'<br/>'; 
            }
        }
        if(warningRecords != null){
            if(warningRecords > 0){
                countrefresh = true;
                recordCount += 'No. of Warning Records: '+ warningRecords +'<br/>';
            }
            else{
                 countrefresh = true;
                  recordCount += 'No. of Warning Records: '+ warningRecords +'<br/>';
            }
        } 
        if(errorRecords != null){
            if(errorRecords > 0){
                countrefresh = true;
                recordCount += 'No. of Error Records: '+ errorRecords +'<br/>';
            }
            else{
                 // countrefresh = true;
                  recordCount += 'No. of Error Records: '+ errorRecords +'<br/>';
            }
        }
        String validationResponse = '';
        System.debug('4 '+error);
        if(comments == 'SUCCESS'){
            validationResponse = 'SUCCESS';
        }
        if(comments.contains('WARNING') && !comments.contains('ERROR')){
            validationResponse = 'WARNING';
        }
        if(comments.contains('ERROR')){
            validationResponse = 'ERROR';
        }
        system.debug('validationResponse check**'+validationResponse);
        //return validationResponse;
        return mapProductUpdate;
        /*if(comments.contains('WARNING')){
          //  System.debug('5 '+error);
            return true;     
        }
        else{
           // System.debug('6 '+error);
                return false;
        }*/
    }
    
    public class productWrapper{
        public Product__c product {get;set;}
        public String  comments {get;set;}   
        public productWrapper(Product__c prod, String comment ){
            product = prod;            
            comments = comment;
            system.debug('product  '+product);
            system.debug('comments  '+comments);
        }
    }
    
    public pageReference redirectToPool(){
        PageReference pageRef = new PageReference('/'+poolId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}