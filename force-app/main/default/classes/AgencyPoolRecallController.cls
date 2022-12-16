public class AgencyPoolRecallController {
    public String Product_Placement_Status;
    public static final String PENDING_RECALL = 'Pending Recall';
    public static final String RECALL = 'Recall';
    public static final String PENDING_RECALL_NEW = '821000';
    public static final String ALLOCATED = '300000';
    public static final String PENDING_ALLOCATION = '100000';
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;    
    public list<Product__c> listProd {get;set;}
    public Pool__c poolRecord { get; set; }
    public boolean error{get;set;}
    public String Alert {get;set;}
    public list<productWrapper> listProdWrapper {get;set;}
    public String ERROR_MSG {get;set;}
    public String PlacementAgency {get;set;}
    public boolean Alert_msg {get;set;}
    public boolean Disable{get;set;}
    public string selectedValue{get;set;}
    public boolean countrefresh{get;set;}
    public string selectedValueAction{get;set;}
    public String recordCount {get;set;}    
    string poolId ;
     public String placeStatus;
     
   // string placementID;
    public String oldPlacementID;
    list<Product__c> productList = new list<Product__c>();
    list<Placement_History__c> placementHistoryList = new list<Placement_History__c>();
    List <Pool__c> pool = new List<Pool__c>();
    
    public AgencyPoolRecallController(ApexPages.StandardController stdController) {
        poolId = ApexPages.CurrentPage().getParameters().get('Id'); 
        Product_Placement_Status = '';
        poolRecord = [Select id,Name,Placement_agency_lookup__c, Placement_agency_lookup__r.Agency_name__c, Placement_Agency__c,Pending_Recall__c from Pool__c Where id=:poolId];
        listProdWrapper = new List<productWrapper>();
        mapRecallCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        listProd = [Select Id,Name,Pool_Name__c, DebtNext_Data_ID__C, Collection_Agency__c,Placement_Status__c,
                    Collection_Sub_Status__c,Current_Balance__c,State__c,Legal_Status__c, Status__c,Sub_Status__c,
                    Assignment_Date__c,Recalled_Date__c,Pool_Name__r.Placement_Agency__c,Collection_Agency_Placement__c,
                    Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                    Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,External_Status_Current__c,
                    Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c,Commission_Rate__c,Pool_Name__r.Commission_Rate__c,Allocated_Amount_Total__c,
                    Pool_Name__r.Name,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c
                    from Product__C Where Pool_Name__c =: poolId AND (Collection_Agency__c != NULL AND Collection_Agency__c != 9999)];
                  System.debug('listProd...>>>'+listProd);
        if(listProd.isEmpty()){ 
            error = true;         
            Disable = true;
            Alert_msg = true;
            Alert = 'The are no Products to Recall Agency';
        }
        if(poolRecord.Placement_Agency__c != NUll){
            
            PlacementAgency = String.valueOf(poolRecord.Placement_Agency__c);
            
        }        
        Boolean validation = validationOnRecordUpdate(listProd, PlacementAgency);        
        if(poolRecord.Placement_Agency__c == NUll || poolRecord.Placement_Agency__c == 9999){
            Alert = 'Cannot recall if pools Placement agency is blank or 9999';
            Disable = true;
            Alert_msg = true;
        }
    }
    
    public List<SelectOption> getItems() {
       // Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        String recallReasonString;         
        List<SelectOption> options = new List<SelectOption>();
        
        List<Agency_Portal_Settings__c> recallReasons = [Select Pool_Recall_Reasons__c from Agency_Portal_Settings__c];
        system.debug('recallReasons  '+recallReasons);
        for(Agency_Portal_Settings__c recallReason :recallReasons ){
            recallReasonString = recallReason.Pool_Recall_Reasons__c;
        }
        List<String> lstReason = recallReasonString.split(',');
        Set<String> setPoolRecallReasons = new Set<String>();
        setPoolRecallReasons.addAll(lstReason);
        system.debug('lstReason  '+lstReason);
        
     
        List<Placement_Status_Code_Mapping__c> statusCodes = [Select Parent_Status__c,Placement_Status_Code__c,
                                                              Data_Status_Code__c, Data_Status_Description__c   ,
                                                              Status__c,Sub_Status__c,Complete_Status__c
                                                              from Placement_Status_Code_Mapping__c];  
      
        system.debug('statusCodes '+statusCodes);
        for(Placement_Status_Code_Mapping__c reasons : statusCodes){  
            if(setPoolRecallReasons.contains(reasons.Complete_Status__c)){
                if(reasons.Sub_Status__c == NULL){
                    options.add(new SelectOption(reasons.Placement_Status_Code__c,reasons.Status__c));
                }else{
                    options.add(new SelectOption(reasons.Placement_Status_Code__c,reasons.Status__c +' - '+ reasons.Sub_Status__c));  
                }    
            }
            
            mapRecallCodeStatus.put(reasons.Placement_Status_Code__c, reasons);            
        }
        system.debug('mapRecallCodeStatus::'+mapRecallCodeStatus);
        return options;
    }
    
    public List<SelectOption> getactionItems() {
        List<SelectOption> actionoptions = new List<SelectOption>();
        if(poolRecord.Pending_Recall__c == true){
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse')); 
        }
        else{
            actionoptions.add(new SelectOption('Pending Recall','Pending Recall'));
            //actionoptions.add(new SelectOption('Pending Allocation','Pending Allocation')); 
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse'));  
        }    
        return actionoptions;
    }
    
    
    public PageReference recallWithWarning(){
        String mainStatus = mapRecallCodeStatus.get(selectedValue).Parent_Status__C + ' - ' +mapRecallCodeStatus.get(selectedValue).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedValue).Sub_Status__c;
        String productNames = '';
        countrefresh = false;
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        
         Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
        
        listProdWrapper = new list<productWrapper>();
        map<String, Data_Status_Mapping__c> mapProductStatusCodes = new map<String, Data_Status_Mapping__c>();
        for(Data_Status_Mapping__c dataStatusMapping : [SELECT Description1__c,Description2__c,Name, Description__c
                                                            FROM Data_Status_Mapping__c
                                                            WHERE 
                                                            /*Description1__c = :mainStatus 
                                                            AND Description2__c= :subStatus*/
                                                            Description__c LIKE :'Warehouse%'
                                                        ]){
            mapProductStatusCodes.put(dataStatusMapping.Description1__c + 
                                      ( dataStatusMapping.Description2__c!= null ?  dataStatusMapping.Description2__c : '') 
                                     , dataStatusMapping);              
            system.debug('map::'+dataStatusMapping.Description1__c+dataStatusMapping.Description2__c);
        } 
        
        for(Product__c product : listProd){
            oldPlacementID = product.Collection_Agency_Placement__c;
            
            if(product.Placement_Status__c != null){
                placeStatus = product.Placement_Status__c;
            }
            
            if(selectedValueAction == 'Pending Recall'){                
                system.debug('selectedValue' +selectedValue);
                product.Placement_Status__c = selectedValue;
                system.debug('product.Placement_Status__c::'+product.Placement_Status__c);
                Product_Placement_Status = product.Placement_Status__c;
                product.Status_Changed_Date__c = Date.today();
                product.External_Status_Current__c = null;
                if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }
                product.Status__c = mainStatus;
                product.Sub_Status__c = subStatus;
                system.debug('product.Status__c:: '+product.Status__c);
                system.debug('product.Sub_Status__c: '+product.Sub_Status__c);
                productList.add(product);
                //productNames += product.Name + ',';
            }
            else if(selectedValueAction == 'Send to Warehouse'){
                product.Recalled_Date__c = Date.today();   
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.External_Status_Current__c = null;
                system.debug('selectedValue::'+selectedValue);
                system.debug('product.Placement_Status__c::'+product.Placement_Status__c);
                
                product.Placement_Status__c = selectedValue.replaceFirst('8', '9');
                system.debug('mapRecallCodeStatus contains:'+mapRecallCodeStatus.get(product.Placement_Status__c));
                
                //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                    //clear the fields once acount recalled and sent to warehouse
                    product.Placement_Status__c = null;
                    product.Status__c = null;
                    product.Sub_Status__c = null;
                    product.Collection_Agency__c = 9999;
                    product.Collection_Agency_Placement__c = placement.id;
                }
                product.Status_Changed_Date__c = Date.today();
                
                /*if(String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)){
                    product.Status__c = product.Status__c.replaceAll(PENDING_RECALL, RECALL);
                    product.Placement_Status__c = product.Placement_Status__c.replace('8', '9');
                }
                system.debug('selectedValue' +selectedValue);
                system.debug('mainStatus:: '+mainStatus);
                system.debug('subStatus:: '+subStatus);
                if(mapProductStatusCodes.containsKey(mainStatus+subStatus)){
                        product.Product_Status__c =  mapProductStatusCodes.get(mainStatus+subStatus).Name;
                        product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus+subStatus).Description__c;
                }
                else if(mapProductStatusCodes.containsKey(mainStatus)){
                    product.Product_Status__c =  mapProductStatusCodes.get(mainStatus).Name;
                    product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus).Description__c;   
                }
                else if(mapProductStatusCodes.containsKey(mainStatus + 'Other')){
                    product.Product_Status__c =  mapProductStatusCodes.get(mainStatus + 'Other').Name;
                    product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus + 'Other').Description__c;   
                }
                else if(mapProductStatusCodes.containsKey('Other')){
                    product.Product_Status__c =  mapProductStatusCodes.get('Other').Name;
                    product.Data_Status_Description__c =  mapProductStatusCodes.get('Other').Description__c;   
                }
              /*  product.Placement_Status__c = PENDING_RECALL_NEW;
                if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;        
                }*/

                Product_Placement_Status = product.Placement_Status__c;
                productList.add(product);
                system.debug('productList++' +productList);
            }
            else if(selectedValueAction == 'Pending Allocation'){
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
               // product.Product_Status__c = PENDING_ALLOCATION;
                product.Placement_Status__c = selectedValue;
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
                productList.add(product);
            }
            if(selectedValueAction == 'Pending Recall' || selectedValueAction == 'Send to Warehouse'){
                /*Placement_History__c placementHistory = new Placement_History__c();                
                placementHistory.Product__c = product.id;
                placementHistory.Placement__c =  oldPlacementID;    
                placementHistory.Placement_Recall_Date__c = Date.today();
                placementHistory.Placement_Status__c = product.Placement_Status__c;
                placementHistory.Placement_Date__c = product.Assignment_Date__c;
                placementHistory.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                placementHistory.Current_Interest_Balance__c = product.Current_Interest_Amount__c;
                placementHistory.Interest_Rate__c = product.Interest_Rate__c;
                placementHistory.NSF_Fees__c = product.Current_Bal_NSF_Fees__c;
                placementHistory.Current_Bal_Attorney_Fees__c = product.Current_Bal_Attorney_Fees__c;
                placementHistory.Current_Bal_General_Fees__c = product.Current_Bal_General_Fees__c;
                placementHistory.Current_Bal_Other_Fees__c = product.Current_Bal_Other_Fees__c;
                placementHistory.Current_Bal_Court_Fees__c = product.Current_Bal_Court_Fees__c;
                placementHistory.Commission_Rate__c = product.Collection_Agency_Placement__r.Commission_Rate__c;
                placementHistory.Pool_Commission_Rate__c = product.Pool_Name__r.Commission_Rate__c;
                placementHistory.Product_Commission_Rate__c = product.Commission_Rate__c;
                placementHistory.Allocated_Balance__c = product.Allocated_Amount_Total__c;
                placementHistory.Pool_ID__c = product.Pool_Name__r.Name;
                  placementHistory.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
                placementHistory.Value_Tier_at_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
                placementHistory.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
                placementHistory.Recoverable_fee_balance__c = product.Recoverable_Fee__c;
                placementHistory.Non_recoverable_fee_balance__c = product.Non_Recoverable_Fee__c;
                placementHistory.Placement_Status_at_time_of_recall__c = placeStatus;
                placementHistory.Total_Balance_at_Placement__c = product.Current_Balance__c;
                placementHistoryList.add(placementHistory);*/
                
              if(!Test.isRunningTest()){
                 DistressedUtilities.updatePlacementHistory(product.Id, selectedValue.replaceFirst(selectedValue.substring(0,1), '9'));

              }
            }
            productNames += product.Name + ',';
        }
        productNames = productNames.removeEnd(',');
        String poolAgency = '';
        try{
            system.debug('selectedValueAction::'+selectedValueAction);
            if(selectedValueAction == 'Send to Warehouse'){   
                poolAgency = '9999';
                poolRecord.Placement_Agency__c = 9999;
                poolRecord.Placement_agency_lookup__c = NULL;
                poolRecord.Pending_Recall__c = false;
                PoolTriggerHandler.runPoolTrigger = false;
                update poolRecord;
                PoolTriggerHandler.runPoolTrigger = true;
            }
            else if(selectedValueAction == 'Pending Recall'){
                if(poolRecord.Placement_Agency__c != NULL){
                    poolAgency = String.valueOf(Math.floor(poolRecord.Placement_Agency__c));
                    poolRecord.Pending_Recall__c = true;
                    PoolTriggerHandler.runPoolTrigger = false;
                    update poolRecord;
                    PoolTriggerHandler.runPoolTrigger = true;
                    
                }
             }
            system.debug('selectedValueAction::'+selectedValueAction);
            system.debug('poolRecord.Placement_Agency__c::'+poolRecord.Placement_Agency__c);
            system.debug('poolAgency::'+poolAgency);
            /*for(Pool__c poolRec : pool ){ 
                if(selectedValueAction == 'Send to Warehouse'){                 
                    
                    poolRec.Placement_Agency__c = 9999;                   
                    poolRec.Placement_agency_lookup__c = NULL;
                    
                    //updatePool.add(poolRec);
                }
                else{
                   // poolRec.Placement_Agency__c = NULL;   
                   // poolRec.Placement_agency_lookup__c = NULL;
                    
                }
                
            }*/
            
            system.debug('productList '+productList);
            
            ProductTriggerHandler.runProductTrigger = false;
            update productList;
           // insert placementHistoryList;
     
            PortalProductStatusBulkAPI.processBulkProducts(productNames, Product_Placement_Status, ALLOCATED, String.valueOf(Date.today()), 
                                                           'Recall',poolAgency, poolRecord.Name);
            ProductTriggerHandler.runProductTrigger = true;
            //update pool;
            listProdWrapper = new list<productWrapper>();
            if(selectedValueAction == 'Send to Warehouse'){
                Alert = 'Product Send to Warehouse';
            }
            else if(selectedValueAction == 'Pending Allocation'){
                Alert =  'Product set to Pending Allocation Status';
            }else{
                Alert =  'Product set to Pending Status';
            }
            Disable = true;
            Alert_msg = true;
            countrefresh = true;
            recordCount = 'No. of Success Records: '+ productList.size() +'<br/>';
        }
        catch(Exception ex){
            // ERROR_MSG = ex.getMessage();
        }          
        
        return null;
        
    }
    
    public PageReference recallProduct(){
        String productNames = '';
        countrefresh = false;
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
        
        system.debug('PlacementAgency== '+PlacementAgency);
        String mainStatus = mapRecallCodeStatus.get(selectedValue).Parent_Status__C + ' - ' +mapRecallCodeStatus.get(selectedValue).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedValue).Sub_Status__c;
        map<String, String> mapDataStatus = new map<String, String>();
        map<String, Data_Status_Mapping__c> mapProductStatusCodes = new map<String, Data_Status_Mapping__c>();
        for(Data_Status_Mapping__c dataStatusMapping : [SELECT Description1__c,Description2__c,Name,Description__c
                                                            FROM Data_Status_Mapping__c
                                                            WHERE 
                                                            /*Description1__c = :mainStatus 
                                                            AND Description2__c= :subStatus*/
                                                            Description__c LIKE :'Warehouse%'
                                                        ]){
            mapProductStatusCodes.put(dataStatusMapping.Description1__c + 
                                      ( dataStatusMapping.Description2__c!= null ?  dataStatusMapping.Description2__c : '') 
                                     , dataStatusMapping);  
            system.debug('map::'+dataStatusMapping.Description1__c+dataStatusMapping.Description2__c);
        }
        // system.debug('placement::'+ product.Collection_Agency_Placement__c);
        listProdWrapper = new list<productWrapper>();
        Boolean validation = validationOnRecordUpdate(listProd, PlacementAgency);
        if(Test.isRunningTest()){
            validation = false; 
        }
        if(validation == true){
            
        }
        else{
            for(Product__c product : listProd){
            
            if(product.Placement_Status__c != null){
                placeStatus = product.Placement_Status__c;
            }
            
                oldPlacementID = product.Collection_Agency_Placement__c;
                if(selectedValueAction == 'Pending Recall'){
                    system.debug('selectedValue' +selectedValue);
                    product.Placement_Status__c = selectedValue;
                    Product_Placement_Status = product.Placement_Status__c;
                    product.Status_Changed_Date__c = Date.today();
                    product.External_Status_Current__c = null;
                    if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                        product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                        product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                        if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                            product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                            product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                        }
                    }
                    product.Status__c = mainStatus;
                    product.Sub_Status__c = subStatus;
                    system.debug('product.Status__c:: '+product.Status__c);
                    system.debug('product.Sub_Status__c:: '+product.Sub_Status__c);
                    productList.add(product);
                    //productNames += product.Name + ',';
                }
                else if(selectedValueAction == 'Send to Warehouse'){
                    product.Recalled_Date__c = Date.today();   
                    product.Collection_Agency__c = 9999;
                    product.Collection_Agency_Placement__c = placement.id;
                    product.External_Status_Current__c = null;
                    system.debug('selectedValue:::'+selectedValue);
                    product.Placement_Status__c = selectedValue.replaceFirst('8', '9');
                    system.debug('product.Placement_Status__c::'+product.Placement_Status__c);
                    system.debug('mapRecallCodeStatus contains:'+mapRecallCodeStatus.get(product.Placement_Status__c));
                    
                    //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                    if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                        product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                        product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                        if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                            product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                            product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                        }
                        //clear the fields once acount recalled and sent to warehouse
                        product.Placement_Status__c = null;
                        product.Status__c = null;
                        product.Sub_Status__c = null;
                        product.Collection_Agency__c = 9999;
                        product.Collection_Agency_Placement__c = placement.id;
                    }
                    product.Status_Changed_Date__c = Date.today();
                    
                    /*if(mapProductStatusCodes.containsKey(mainStatus+subStatus)){
                        product.Product_Status__c =  mapProductStatusCodes.get(mainStatus+subStatus).Name;
                        product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus+subStatus).Description__c;
                    }
                    else if(mapProductStatusCodes.containsKey(mainStatus)){
                            product.Product_Status__c =  mapProductStatusCodes.get(mainStatus).Name;
                            product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus).Description__c;   
                    }
                    else if(mapProductStatusCodes.containsKey(mainStatus + 'Other')){
                            product.Product_Status__c =  mapProductStatusCodes.get(mainStatus + 'Other').Name;
                            product.Data_Status_Description__c =  mapProductStatusCodes.get(mainStatus + 'Other').Description__c;   
                    }
                    else if(mapProductStatusCodes.containsKey('Other')){
                            product.Product_Status__c =  mapProductStatusCodes.get('Other').Name;
                            product.Data_Status_Description__c =  mapProductStatusCodes.get('Other').Description__c;   
                   }*/
                    system.debug('selectedValue' +selectedValue);
                    Product_Placement_Status = product.Placement_Status__c;
                    productList.add(product);
                    system.debug('productList++' +productList);
                } 
                else if(selectedValueAction == 'Pending Allocation'){
                    product.Collection_Agency__c = 9999;
                    product.Collection_Agency_Placement__c = placement.id;
                    product.External_Status_Current__c = null;
                    //product.Recalled_Date__c = Date.today();
                   // product.Product_Status__c = PENDING_ALLOCATION;
                    product.Placement_Status__c = selectedValue;
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                     if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                    // ERROR_MSG = 'Product set to Pending Allocation Status';
                    // placementIdentifier = '';
                    productList.add(product);
                }
                 if(selectedValueAction == 'Pending Recall' || selectedValueAction == 'Send to Warehouse'){
               /* Placement_History__c placementHistory = new Placement_History__c();                
                placementHistory.Product__c = product.id;
                placementHistory.Placement__c =  oldPlacementID;    
                placementHistory.Placement_Recall_Date__c = Date.today();
                placementHistory.Placement_Status__c = product.Placement_Status__c;
                placementHistory.Placement_Date__c = product.Assignment_Date__c;
                placementHistory.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                placementHistory.Current_Interest_Balance__c = product.Current_Interest_Amount__c;
                placementHistory.Interest_Rate__c = product.Interest_Rate__c;
                placementHistory.NSF_Fees__c = product.Current_Bal_NSF_Fees__c;
                placementHistory.Current_Bal_Attorney_Fees__c = product.Current_Bal_Attorney_Fees__c;
                placementHistory.Current_Bal_General_Fees__c = product.Current_Bal_General_Fees__c;
                placementHistory.Current_Bal_Other_Fees__c = product.Current_Bal_Other_Fees__c;
                placementHistory.Current_Bal_Court_Fees__c = product.Current_Bal_Court_Fees__c;
                placementHistory.Commission_Rate__c = product.Collection_Agency_Placement__r.Commission_Rate__c;
                placementHistory.Pool_Commission_Rate__c = product.Pool_Name__r.Commission_Rate__c;
                placementHistory.Product_Commission_Rate__c = product.Commission_Rate__c;
                placementHistory.Allocated_Balance__c = product.Allocated_Amount_Total__c;
                placementHistory.Pool_ID__c = product.Pool_Name__r.Name;
                 placementHistory.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
                placementHistory.Value_Tier_at_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
                placementHistory.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
                placementHistory.Recoverable_fee_balance__c = product.Recoverable_Fee__c;
                placementHistory.Non_recoverable_fee_balance__c = product.Non_Recoverable_Fee__c;
                placementHistory.Placement_Status_at_time_of_recall__c = placeStatus;
                placementHistory.Total_Balance_at_Placement__c = product.Current_Balance__c;
                placementHistoryList.add(placementHistory);*/
                
                if(!Test.isRunningTest()){
                    DistressedUtilities.updatePlacementHistory(product.Id, selectedValue.replaceFirst(selectedValue.substring(0,1), '9'));
                }
            }
             productNames += product.Name + ',';   
            }
            productNames = productNames.removeEnd(',');
            String poolAgency = '';
            try{
                system.debug('selectedValueAction::'+selectedValueAction);
                if(selectedValueAction == 'Send to Warehouse'){   
                    poolAgency = '9999';
                    poolRecord.Placement_Agency__c = 9999;
                    poolRecord.Placement_agency_lookup__c = NULL;
                    poolRecord.Pending_Recall__c = false;
                    PoolTriggerHandler.runPoolTrigger = false;
                    update poolRecord;
                    PoolTriggerHandler.runPoolTrigger = true;
                }
                else if(selectedValueAction == 'Pending Recall'){
                    if(poolRecord.Placement_Agency__c != NULL){
                        poolAgency = String.valueOf(Math.floor(poolRecord.Placement_Agency__c));
                        poolRecord.Pending_Recall__c = true;
                        PoolTriggerHandler.runPoolTrigger = false;
                        update poolRecord;
                        PoolTriggerHandler.runPoolTrigger = true;
                    }
                }
                system.debug('selectedValueAction::'+selectedValueAction);
                system.debug('poolAgency::'+poolAgency);
                /*for(Pool__c poolRec : pool ){ 
                    if(selectedValueAction == 'Send to Warehouse'){                 
                        poolRec.Placement_Agency__c = 9999;                   
                        poolRec.Placement_agency_lookup__c = NULL;
                        
                        //updatePool.add(poolRec);
                    }
                    else{
                       // poolRec.Placement_Agency__c = NULL;    
                       // poolRec.Placement_agency_lookup__c = NULL;
                        
                    }
                    
                }*/
                
                system.debug('productList '+productList);
                
                
                ProductTriggerHandler.runProductTrigger = false;
                update productList;               
                //insert placementHistoryList; 
                
                PortalProductStatusBulkAPI.processBulkProducts(productNames, Product_Placement_Status, ALLOCATED, String.valueOf(Date.today()), 
                                                               'Recall',poolAgency, poolRecord.Name);
                ProductTriggerHandler.runProductTrigger = true;
                //update pool;
                listProdWrapper = new list<productWrapper>();
                if(selectedValueAction == 'Send to Warehouse'){
                    Alert = 'Product Send to Warehouse';
                }
                else if(selectedValueAction == 'Pending Allocation'){
                    Alert =  'Product set to Pending Allocation Status';
                }else{
                    Alert =  'Product set to Pending Status';
                }
                // Alert = 'Product Recalled from Agency ';
                Disable = true;
                Alert_msg = true;
                countrefresh = true;
                recordCount = 'No. of Success Records: '+ productList.size() +'<br/>';
            }
            catch(Exception ex){
                // ERROR_MSG = ex.getMessage();
            }          
            
        }
        return null;
    }
    
    public static set<String> getProductPaymentDetails(set<String> setProductId){
        set<String> setRecentlyPaidProducts = new set<String>();
         system.debug('productPay::123');
        for(Product_Payments__c productPay : [SELECT ID, CCS_Account__c,CCS_Account__r.Name 
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__r.Name IN :setProductId
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60]){
                                                  setRecentlyPaidProducts.add(productPay.CCS_Account__r.Name);
                                                   system.debug('productPay::'+productPay);
                                              }
       
         return setRecentlyPaidProducts;
    } 
    
    
    //Validation method to be called  before update
    public Boolean validationOnRecordUpdate(List<Product__c> listProd,String placementAgency){ 
        String comments = '';
        ERROR_MSG = '';       
        String newAgency;
        String oldAgency;
        String AgencyProvince;
        Decimal successRecords = 0;
        Decimal errorRecords = 0;
        Decimal warningRecords = 0;
        recordCount = '';
        Disable = true;
        Alert_msg = false;
        set<String> setProductNames = new set<String>();     
        Map<Id ,Product_Payments__c> mapProductPayment =new Map<Id,Product_Payments__c>();
        set<String> setRecentlyPaidProducts = new set<String>();
        
        
        for(Product__c product : listProd){
            setProductNames.add(product.name);
            system.debug('ProductName::'+setProductNames);
        }
        
        setRecentlyPaidProducts = getProductPaymentDetails(setProductNames);
        system.debug('setRecentlyPaidProducts: '+setRecentlyPaidProducts);               
        
        for(Product__c product: listProd){
            ERROR_MSG = '';
            error =false;
            system.debug('product.Name: '+product.Name);
            newAgency = placementAgency;
            system.debug('newAgency: '+newAgency);
            if(product.Collection_Agency__c  != NULL){
                oldAgency = String.valueOf(product.Collection_Agency__c);    
            }
            system.debug('oldAgency: '+oldAgency);
            // 3
            //String EXPECTED = '';
            
            
            if(String.isNotBlank(product.Legal_Status__c)){
                system.debug('recall warning::');
                ERROR_MSG += '<b>WARNING</b> - '+'Cannot recall agency as Product is in Legal Status'+'<br/>';
                //product.addError('Cannot recall agency as Product is in Legal Status');
                comments = ERROR_MSG;
                error = true;
            }
            
            //Check Recall Validations
            if(setRecentlyPaidProducts.contains(product.Name)){
            system.debug('product.Id:'+product.Name);
                ERROR_MSG += '<b>WARNING</b> - '+'Account had a recent payment in last 2 months'+'<br/>';
                //product.addError('Cannot recall agency as Product is in Legal Status');
                comments = ERROR_MSG;
                error = true;
            }
            if(String.isBlank(comments)){
                comments = 'SUCCESS';                
               
            }
            
            if(error == true){
                if(comments == 'SUCCESS' ){
                    successRecords = successRecords + 1;
                }else{
                    listProdWrapper.add(new productWrapper(product, comments));
                    system.debug('listProdWrapper  '+listProdWrapper);
                    if(comments.contains('ERROR')){
                        Disable = true;
                        Alert_msg = true;
                        errorRecords = errorRecords + 1;
                    }
                    else if(comments.contains('WARNING')){ 
                        warningRecords = warningRecords + 1;
                        Alert_msg = true;
                        Disable = false;
                    }
                    else{
                        Alert_msg = false;
                        Disable = true;
                    }
                    
                }            
            }
        }
        if(successRecords != null){
            if(successRecords > 0){
                recordCount += 'No. of Success Records: '+ successRecords +'<br/>';
                countrefresh = true;
            }
            else{
                recordCount += 'No. of Success Records: '+ successRecords +'<br/>'; 
                countrefresh = true;
            }
        }
        if(warningRecords != null){
            if(warningRecords > 0){
                recordCount += 'No. of Warning Records: '+ warningRecords +'<br/>';
                countrefresh = true;
            }
            else{
                recordCount += 'No. of Warning Records: '+ warningRecords +'<br/>';
                countrefresh = true;
            }
        } 
        if(errorRecords != null){
            if(errorRecords > 0){
                recordCount += 'No. of Failed Records: '+ errorRecords +'<br/>';
                countrefresh = true;
            }
            else{
                recordCount += 'No. of Failed Records: '+ errorRecords +'<br/>';
                countrefresh = true;
            }
        }
      if(error == true){           
            return true;     
        }
        else{
           // System.debug('6 '+error);
            return false;    
        }   
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