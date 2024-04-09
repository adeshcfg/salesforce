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
    public List<User> systemName= new list<User>();
    public Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public static Map<String,Provice_Name_Map_with_Abbreviations__mdt> mapProviceAbbreviations = Provice_Name_Map_with_Abbreviations__mdt.getAll();
    public static Map<String, String> mapProvinceAcronym = new Map<String, String>();
    
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
            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
        }
        
        listProdWrapper = new List<productWrapper>();
        
        listProd = [Select Id,Name,Pool_Name__c, DebtNext_Data_ID__C, Collection_Agency__c,Placement_Status__c,Fee_Recovery__c,
                    Collection_Sub_Status__c, Data_Status_Description__c, Current_Balance__c,State__c,Legal_Status__c, Status__c,Sub_Status__c,
                    Assignment_Date__c,Recalled_Date__c,Pool_Name__r.Placement_Agency__c,Collection_Agency_Placement__c,
                    Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                    Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,Allocated_Amount_Total__c,Pool_Name__r.Name,
                    Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c,Commission_Rate__c,Pool_Name__r.Commission_Rate__c,
                    Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,Purchase_Province__c,
                    Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,OwnerId,Previous_Ownership__c,RecordTypeId                                       
                    from Product__C
                    WHERE Pool_Name__c =: poolId AND (Collection_Agency__c = NULL OR Collection_Agency__c = 9999)]; 
        if(poolRecord.Placement_Agency__c == 9999){
            Alert_msg = ' ';
            
        }
        if(listProd.isEmpty() && poolRecord.Placement_Agency__c != NULL){ 
                error = true;        
                allocatebtndisable = true;
                warningbtndisable = true;
                Alert = 'Pool is already placed with another agency to place agency please recall the previous one.<br/> The are no Products to Allocate Agency';
            }
        else if(listProd.isEmpty()){
            error = true;       
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
            Alert = 'Products will be allocated to Agency: '+poolRecord.Placement_Agency__c;
        }
        if(poolRecord.Placement_Agency__c == NULL){
            Alert_msg = ' ';
            warningbtndisable = true;
            poolRecord.Placement_agency_lookup__c = null;
        }
  
        placement = new Placement__c();   
        
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
        NewPlacementAgency = poolRecord.Placement_agency_lookup__c; 
        listProdWrapper = new list<productWrapper>();
        list<Product__c> productList = new list<Product__c>();
        list<Id> prodIdList = new list<Id>();
        Map<Id,String> placeStatusMap = new Map<Id,String>();
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
       
        map<string,string> validation =  validationOnRecordUpdate(listProd,NewPlacementAgency);
		String checkValid = '';
        for(Product__C product : listProd ){
            if(product.Placement_Status__c != null){
                placeStatus = product.Placement_Status__c;
            }
            
            checkValid = validation.get(product.name);
            if(checkValid.contains('SUCCESS')){ 
                oldPlacementID = product.Collection_Agency_Placement__c;
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
                product.Collection_Agency_Placement__c = NewPlacementAgency;
                product.Assignment_Date__c = Date.today();
                product.Assignment_Accepted_Date__c = NULL;
                product.Recalled_Date__c = NULL;
                product.Product_Status__c = ALLOCATED;
                product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
                product.Placement_Status__c = NEW_ALLOCATION_READY;
                product.Status_Changed_Date__c = Date.today();
                product.Collection_Sub_Status__c = null;
                product.Run_Identifier_Check_On__c = System.today();
                productList.add(product);
                prodIdList.add(product.id);
                
                placeStatusMap.put(product.id,product.Placement_Status__c);
                productNames += product.Name + ',';
                if(!mapRecallCodeStatus.isEmpty()){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                }
                if(product.Allocated_Amount_Fees__c == NULL){
                    product.Allocated_Amount_Fees__c = 0;
                }
                if(product.Allocated_Amount_Principal__c == NULL){
                    product.Allocated_Amount_Principal__c = 0;
                }
                if(product.Allocated_Amount_Interest__c == NULL){
                    product.Allocated_Amount_Interest__c = 0;
                }
                if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                   && Decimal.valueOf(placement.Name) != product.Collection_Agency__c){
                       Id oldOwnerId = product.OwnerId;
                       // Assign System API to Owner
                       if(!systemName.isEmpty()){
                           product.OwnerId = systemName[0].Id;      
                       }
                       //Also Assign the last owner to the previous ownership field
                       if(oldOwnerId != product.OwnerId && oldOwnerId != NULL){
                           product.Previous_Ownership__c = oldOwnerId;
                       }
                }
            }
        }
        productNames = productNames.removeEnd(',');

        try{
            if(!checkValid.contains('Allocate Agency is not Active')){ 
                for(Pool__c poolRec : pool ){                  
                    poolRec.Placement_Agency__c = Decimal.valueOf(placement.Name);    
                    poolRec.Placement_agency_lookup__c = poolRecord.Placement_agency_lookup__c;
                    
                }
            }
            ProductTriggerHandler.runProductTrigger = false;
            update productList;
            
            DistressedUtilities.createPlacementHistory(productList, newPlacementAgency,placement.Commission_Rate__c);
            
            //Commented by satyajit
            //PortalProductStatusBulkAPI.processBulkProducts(productNames, NEW_ALLOCATION_READY, ALLOCATED, String.valueOf(Date.today()), 
            //'Allocation',placement.Name, poolRecord.Name);
            
            //Added by satyajit for ticket 4307
            Database.executeBatch(new BatchProcessForProdScreen(prodIdList,placeStatusMap,'Account Status Update File'), 200);  
            
            update pool;
            getSnapshortRecords(productList);
            ProductTriggerHandler.runProductTrigger = true;
            
            countrefresh = true;
            recordCount = 'No. of Success Records: '+ productList.size() +'<br/>';
            Alert = 'Products Allocated to Agency : ' +placement.Name + ' - ' + placement.Agency_Name__c;                    
        }
        catch(Exception ex){
            system.debug('exception***: '+ex);
        }
        return null;
    }
    
    public PageReference allocateWithWarning(){
        countrefresh = false;
        String productNames = '';
        NewPlacementAgency = poolRecord.Placement_agency_lookup__c; 
        listProdWrapper = new list<productWrapper>();
        
        list<Product__c> productList = new list<Product__c>(); 
        list<Id> prodIdList = new list<Id>();
        Map<Id,String> placeStatusMap = new Map<Id,String>();
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        
        map<string,string> validation =  validationOnRecordUpdate(listProd,NewPlacementAgency);
        String checkValid = '';
        for(Product__C product : listProd ){
            
            if(product.Placement_Status__c != null){
                placeStatus = product.Placement_Status__c;
            }
            
            checkValid = validation.get(product.name);
            if(checkValid.contains('WARNING') && !checkValid.contains('ERROR')){
                oldPlacementID = product.Collection_Agency_Placement__c;
                if(product.Current_Bal_NSF_Fees__c == NULL){
                    product.Current_Bal_NSF_Fees__c = 0;
                }
                if(product.Recoverable_Fee__c == NULL){
                    product.Recoverable_Fee__c = 0;
                }
                product.Allocated_Amount_Fees__c = product.Recoverable_Fee__c + product.Current_Bal_NSF_Fees__c; 
                //satyajit Comments the below line based on Ankur discussion 
                //product.Allocated_Amount_Fees__c = product.Fee_Recovery__c;
                product.Allocated_Amount_Principal__c = product.Current_Principal_Balance__c;
                product.Allocated_Amount_Interest__c = product.Current_Interest_Amount__c;
                product.Collection_Agency__c = Decimal.valueOf(placement.Name);
                product.Collection_Agency_Placement__c = NewPlacementAgency;
                product.Assignment_Date__c = Date.today();
                product.Assignment_Accepted_Date__c = NULL;
                product.Recalled_Date__c = NULL;
                product.Product_Status__c = ALLOCATED;
                product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
                product.Placement_Status__c = NEW_ALLOCATION_READY;
                product.Status_Changed_Date__c = Date.today();
                product.Collection_Sub_Status__c = null;
                product.Run_Identifier_Check_On__c = System.today();
                productList.add(product);
                prodIdList.add(product.id);
                placeStatusMap.put(product.id,product.Placement_Status__c);
                productNames += product.Name + ',';
                if(!mapRecallCodeStatus.isEmpty()){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                }
                if(product.Allocated_Amount_Fees__c == NULL){
                    product.Allocated_Amount_Fees__c = 0;
                }
                if(product.Allocated_Amount_Principal__c == NULL){
                    product.Allocated_Amount_Principal__c = 0;
                }
                if(product.Allocated_Amount_Interest__c == NULL){
                    product.Allocated_Amount_Interest__c = 0;
                }
                if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                   && Decimal.valueOf(placement.Name) != product.Collection_Agency__c){
                       Id oldOwnerId = product.OwnerId;
                       // Assign System API to Owner
                       if(!systemName.isEmpty()){
                           product.OwnerId = systemName[0].Id;      
                       }
                       //Also Assign the last owner to the previous ownership field
                       if(oldOwnerId != product.OwnerId && oldOwnerId != NULL){
                       		product.Previous_Ownership__c = oldOwnerId;
                       }
                }
            }
        }
        try{
            if(!checkValid.contains('Allocate Agency is not Active')){ 
                for(Pool__c poolRec : pool ){                  
                    poolRec.Placement_Agency__c = Decimal.valueOf(placement.Name);    
                    poolRec.Placement_agency_lookup__c = poolRecord.Placement_agency_lookup__c;
                }
            }
            
            ProductTriggerHandler.runProductTrigger = false;
            update productList;
            
            DistressedUtilities.createPlacementHistory(productList, newPlacementAgency,placement.Commission_Rate__c);
            
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
            system.debug('exception***: '+ex);
        }
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
        map<string,string> mapProductUpdate = new map<string,string>();
        set<String> setPreviousPlacedProductNames = new set<String>();

        placement = [SELECT ID, Name, Serviceable_Province__c,Agency_Name__c,Commission_Rate__c,Active__c
                     FROM Placement__c 
                     WHERE ID= :placementAgency
                    ][0];
        
        for(Provice_Name_Map_with_Abbreviations__mdt metaData : mapProviceAbbreviations.values()){
            mapProvinceAcronym.put(metaData.Province_Acronym__c,metaData.Province_Name__c);
        }
        
        for(Product__c product : listProd){
            setProductNames.add(product.name);  
        }
        setPreviousPlacedProductNames = getPlacementHistoryDetails(setProductNames);
        for(Product__c product: listProd){
            ERROR_MSG = '';
            error = false;
            newAgency = placementAgency ;
            oldAgency = '';
            if(product.Collection_Agency__c  != NULL){
                oldAgency = String.valueOf(product.Collection_Agency__c);    
            }
            if(placement != NULL
               && String.isNotBlank(placement.Serviceable_Province__c)){
                   AgencyProvince = placement.Serviceable_Province__c; 
               }
            if(String.isBlank(product.Purchase_Province__c) && !Test.isRunningTest()){
                ERROR_MSG += '<b>ERROR</b> - '+'Purchase Province Required'+'<br/>';
            }
            if(String.isNotBlank(newAgency)
               && String.isNotBlank(AgencyProvince) 
               && String.isNotBlank(product.Purchase_Province__c) 
               && ( (!mapProvinceAcronym.containsKey(product.Purchase_Province__c) && !AgencyProvince.contains(product.Purchase_Province__c))
                   ||   (mapProvinceAcronym.containsKey(product.Purchase_Province__c)  &&!AgencyProvince.contains(mapProvinceAcronym.get(product.Purchase_Province__c))))){
                       ERROR_MSG += '<b>ERROR</b> - '+'Product cannot be placed with agency as Product Purchase Province is Non Serviceable for Agency'+'<br/>';
                       comments = ERROR_MSG;
                   }          
            
            if(setPreviousPlacedProductNames.contains(product.Name+ newAgency)){
                ERROR_MSG += '<b>WARNING</b> - '+'Product is placed with the agency in last 6 months'+'<br/>';
                comments = ERROR_MSG;
                error = true;
            }
            if(placement.Active__c == False){
                ERROR_MSG += '<b>ERROR</b> - Allocate Agency is not Active <br/>';
                comments = ERROR_MSG;
            }
            if(String.isNotBlank(newAgency)){
                if(String.isNotBlank(product.Collection_Sub_Status__c)){
                    String collectionSubStatus = product.Collection_Sub_Status__c;
                    if(collectionSubStatus == 'Credit Counselling'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                        comments = ERROR_MSG;
                    }
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
                    if(dataStatus.contains('Closed')){
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

            mapProductUpdate.put(product.name,comments);

            if(comments == 'SUCCESS' ){
                successRecords = successRecords + 1;                   
            }else{                    
                listProdWrapper.add(new productWrapper(product, comments));
                if(comments.contains('ERROR')){
                    allocatebtndisable = true;
                    errorRecords = errorRecords + 1;
                    warningbtndisable = true;
                }
                else if(comments.contains('WARNING')){
                    warningRecords = warningRecords + 1;
                    warningbtndisable = false;
                    allocatebtndisable = true;
                }
                else{
                    warningbtndisable = true;
                    allocatebtndisable = false;
                }
            }
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
                  recordCount += 'No. of Error Records: '+ errorRecords +'<br/>';
            }
        }
        String validationResponse = '';
        if(comments == 'SUCCESS'){
            validationResponse = 'SUCCESS';
        }
        if(comments.contains('WARNING') && !comments.contains('ERROR')){
            validationResponse = 'WARNING';
        }
        if(comments.contains('ERROR')){
            validationResponse = 'ERROR';
        }
        
        return mapProductUpdate;
    }
    
    public class productWrapper{
        public Product__c product {get;set;}
        public String  comments {get;set;}   
        public productWrapper(Product__c prod, String comment ){
            product = prod;            
            comments = comment;
        }
    }
    
    public pageReference redirectToPool(){
        PageReference pageRef = new PageReference('/'+poolId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}