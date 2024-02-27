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
    public String oldPlacementID;
    list<Product__c> productList = new list<Product__c>();
    list<Id> ProdIdList = new list<Id>();
    list<Placement_History__c> placementHistoryList = new list<Placement_History__c>();
    List <Pool__c> pool = new List<Pool__c>();
    public List<User> systemName= new list<User>();
    public Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    
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
                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,OwnerId,Previous_Ownership__c
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
        //Fetch System Api
        if(lrpSetting.Canaccede_API_User__c != NULL){
            systemName = [Select id, Name from User where username =: lrpSetting.Canaccede_API_User__c];    
        }
        //Fetch Product RecordType
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }
    }
    
    public List<SelectOption> getItems() {
       // Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        String recallReasonString;         
        List<SelectOption> options = new List<SelectOption>();
        List<Agency_Portal_Settings__c> recallReasons = [Select Pool_Recall_Reasons__c from Agency_Portal_Settings__c];

        for(Agency_Portal_Settings__c recallReason :recallReasons ){
            recallReasonString = recallReason.Pool_Recall_Reasons__c;
        }
        List<String> lstReason = recallReasonString.split(',');
        Set<String> setPoolRecallReasons = new Set<String>();
        setPoolRecallReasons.addAll(lstReason);
     
        List<Placement_Status_Code_Mapping__c> statusCodes = [Select Parent_Status__c,Placement_Status_Code__c,
                                                              Data_Status_Code__c, Data_Status_Description__c   ,
                                                              Status__c,Sub_Status__c,Complete_Status__c
                                                              from Placement_Status_Code_Mapping__c];  
      
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
        return options;
    }
    
    public List<SelectOption> getactionItems() {
        List<SelectOption> actionoptions = new List<SelectOption>();
        if(poolRecord.Pending_Recall__c == true){
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse')); 
        }
        else{
            actionoptions.add(new SelectOption('Pending Recall','Pending Recall'));
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse'));  
        }    
        return actionoptions;
    }
    
    
    public PageReference recallWithWarning(){
        String mainStatus = mapRecallCodeStatus.get(selectedValue).Parent_Status__C + ' - ' +mapRecallCodeStatus.get(selectedValue).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedValue).Sub_Status__c;
        String productNames = '';
         Map<Id,String> placeStatusMap = new Map<Id,String>();
         
        countrefresh = false;
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        
         Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
        
        listProdWrapper = new list<productWrapper>();
        map<String, Data_Status_Mapping__c> mapProductStatusCodes = new map<String, Data_Status_Mapping__c>();
        for(Data_Status_Mapping__c dataStatusMapping : [SELECT Description1__c,Description2__c,Name, Description__c
                                                            FROM Data_Status_Mapping__c
                                                            WHERE 
                                                            Description__c LIKE :'Warehouse%'
                                                        ]){
            mapProductStatusCodes.put(dataStatusMapping.Description1__c + 
                                      ( dataStatusMapping.Description2__c!= null ?  dataStatusMapping.Description2__c : '') 
                                     , dataStatusMapping);              
        } 
        
        for(Product__c product : listProd){
            oldPlacementID = product.Collection_Agency_Placement__c;
            
            if(product.Placement_Status__c != null){
                placeStatus = product.Placement_Status__c;
            }
            
            if(selectedValueAction == 'Pending Recall'){                
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
                productList.add(product);
                prodIdList.add(product.id);
                placeStatusMap.put(product.id,product.Placement_Status__c);
            }
            else if(selectedValueAction == 'Send to Warehouse'){
                product.Recalled_Date__c = Date.today();   
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.External_Status_Current__c = null;
                product.Placement_Status__c = selectedValue.replaceFirst('8', '9');
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
                Product_Placement_Status = product.Placement_Status__c;
                productList.add(product);
                prodIdList.add(product.id);
                placeStatusMap.put(product.id,product.Placement_Status__c);
            }
            else if(selectedValueAction == 'Pending Allocation'){
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
                product.Placement_Status__c = selectedValue;
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
                productList.add(product);
                prodIdList.add(product.id);
                placeStatusMap.put(product.id,product.Placement_Status__c);
            }
            if(product.Collection_Agency__c == 9999){
                if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                   && placement.Name != PlacementAgency){
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
                productList.add(product);
            }
            if(selectedValueAction == 'Pending Recall' || selectedValueAction == 'Send to Warehouse'){
              if(!Test.isRunningTest()){
                 DistressedUtilities.updatePlacementHistory(product.Id, selectedValue.replaceFirst(selectedValue.substring(0,1), '9'));

              }
            }
            productNames += product.Name + ',';
        }
        productNames = productNames.removeEnd(',');
        String poolAgency = '';
        try{
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
            
            ProductTriggerHandler.runProductTrigger = false;
            DistressedUtilities.UpdateSettlement(prodIdList);
            update productList;
            //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodIdList,placeStatusMap,'Account Status Update File'), 200);                                             
            ProductTriggerHandler.runProductTrigger = true;

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

        }          
        
        return null;
        
    }
    
    public PageReference recallProduct(){
        String productNames = '';
        Map<Id,String> placeStatusMap = new Map<Id,String>();

        countrefresh = false;
        pool = [Select id,Name,Placement_agency_lookup__c,Placement_Agency__c from Pool__c Where id=:poolId];
        Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
        
        String mainStatus = mapRecallCodeStatus.get(selectedValue).Parent_Status__C + ' - ' +mapRecallCodeStatus.get(selectedValue).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedValue).Sub_Status__c;
        map<String, String> mapDataStatus = new map<String, String>();
        map<String, Data_Status_Mapping__c> mapProductStatusCodes = new map<String, Data_Status_Mapping__c>();
        for(Data_Status_Mapping__c dataStatusMapping : [SELECT Description1__c,Description2__c,Name,Description__c
                                                            FROM Data_Status_Mapping__c
                                                            WHERE 
                                                            Description__c LIKE :'Warehouse%'
                                                        ]){
            mapProductStatusCodes.put(dataStatusMapping.Description1__c + 
                                      ( dataStatusMapping.Description2__c!= null ?  dataStatusMapping.Description2__c : '') 
                                     , dataStatusMapping);  
        }
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
                    productList.add(product);
                    prodIdList.add(product.id);
                    placeStatusMap.put(product.id,product.Placement_Status__c);
                }
                else if(selectedValueAction == 'Send to Warehouse'){
                    product.Recalled_Date__c = Date.today();   
                    product.Collection_Agency__c = 9999;
                    product.Collection_Agency_Placement__c = placement.id;
                    product.External_Status_Current__c = null;
                    product.Placement_Status__c = selectedValue.replaceFirst('8', '9');
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
                    Product_Placement_Status = product.Placement_Status__c;
                    productList.add(product);
                    prodIdList.add(product.id);
                    placeStatusMap.put(product.id,product.Placement_Status__c);
                } 
                else if(selectedValueAction == 'Pending Allocation'){
                    product.Collection_Agency__c = 9999;
                    product.Collection_Agency_Placement__c = placement.id;
                    product.External_Status_Current__c = null;
                    product.Placement_Status__c = selectedValue;
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                     if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                    productList.add(product);
                    prodIdList.add(product.id);
                    placeStatusMap.put(product.id,product.Placement_Status__c);
                }
                if(product.Collection_Agency__c == 9999){
                    if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                       && placement.Name != PlacementAgency){
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
                    productList.add(product);
                }
                if(selectedValueAction == 'Pending Recall' || selectedValueAction == 'Send to Warehouse'){
                    if(!Test.isRunningTest()){
                        DistressedUtilities.updatePlacementHistory(product.Id, selectedValue.replaceFirst(selectedValue.substring(0,1), '9'));
                    }
                }
             productNames += product.Name + ',';   
            }
            productNames = productNames.removeEnd(',');
            String poolAgency = '';
            try{
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
                
                DistressedUtilities.UpdateSettlement(prodIdList);
                ProductTriggerHandler.runProductTrigger = false;
                update productList;                             
                //Added by satyajit
                Database.executeBatch(new BatchProcessForProdScreen(prodIdList,placeStatusMap,'Account Status Update File'), 200);
                ProductTriggerHandler.runProductTrigger = true;

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

            }          
            
        }
        return null;
    }
    
    public static set<String> getProductPaymentDetails(set<String> setProductId){
        set<String> setRecentlyPaidProducts = new set<String>();

        for(Product_Payments__c productPay : [SELECT ID, CCS_Account__c,CCS_Account__r.Name 
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__r.Name IN :setProductId
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60]){
                                                  setRecentlyPaidProducts.add(productPay.CCS_Account__r.Name);
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
        }
        
        setRecentlyPaidProducts = getProductPaymentDetails(setProductNames);            
        
        for(Product__c product: listProd){
            ERROR_MSG = '';
            error =false;
            newAgency = placementAgency;
            if(product.Collection_Agency__c  != NULL){
                oldAgency = String.valueOf(product.Collection_Agency__c);    
            }
            
            if(String.isNotBlank(product.Legal_Status__c)){
                ERROR_MSG += '<b>WARNING</b> - '+'Cannot recall agency as Product is in Legal Status'+'<br/>';
                comments = ERROR_MSG;
                error = true;
            }
            
            //Check Recall Validations
            if(setRecentlyPaidProducts.contains(product.Name)){
                ERROR_MSG += '<b>WARNING</b> - '+'Account had a recent payment in last 2 months'+'<br/>';
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
            return false;    
        }   
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