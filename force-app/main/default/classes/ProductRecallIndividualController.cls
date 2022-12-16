/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to recall agency individually from Product record
*  @author : A5E Consulting
*  @date : 11/03/2022

*************************************************************************************************/
public with sharing class ProductRecallIndividualController {
    public map<String, Data_Status_Mapping__c> dataStatusMap = Data_Status_Mapping__c.getAll();
    public map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public list<SelectOption> listRecallReasonOptions {get;set;}
    public String profileNameUserInfo {get;set;}
    public static final String PENDING_RECALL = 'Pending Recall';
    public static final String RECALL = 'Recall';
    public static final String PENDING_ALLOCATION = '100000';
    public static final String PENDING_ALLOCATION_RECALLED_CODE = '110000';
    public static final String NEW_ALLOCATION = 'New Allocation - New Allocation';
    public static final String READY = 'Ready';
    public static final String PENDING_ALLOCATION_RECALLED = 'Pending Allocation (1); Recalled';
    
    public String ERROR_MSG {get;set;}
    public String productID {get;set;}
    public String NewPlacementAgency {get;set;}
    public String recallReason {get;set;}
    public String selectedRecallReason {get;set;}
    public String selectedValueAction {get;set;}
    public ID warehousePlacementId;
    public String placeStatus;
    public List<Product__c> listProduct = new List<Product__c>();
    public Product__c product {get;set;}
    public Placement__c placement;
    String oldPlacementID;
    //String oldPlacementStatusCode = '';
    
    public ProductRecallIndividualController(ApexPages.StandardController stdController) {
         placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
        
        productID =  ApexPages.currentPage().getParameters().get('id');
        
        product = [SELECT ID, Name, State__c, Placement_Status__c, Status__c,Collection_Agency__c,Assignment_Date__c,
                   Collection_Agency_Placement__c,Collection_Agency_Placement__r.Agency_Name__c, Collection_Sub_Status__c, Invalid_Submission__c, Pool_Name__r.Name,
                   Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Rate__c,Current_Bal_NSF_Fees__c,
                   Current_Bal_Attorney_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,External_Status_Current__c,
                   Current_Bal_Court_Fees__c,Collection_Agency_Placement__r.Commission_Rate__c, Product_Status__c,
                   Commission_Rate__c,Pool_Name__r.Commission_Rate__c,Allocated_Amount_Total__c,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Current_Balance__c
                   FROM Product__c WHERE ID= :productID];
        system.debug('product: '+product);
        
        if(product.Placement_Status__c != null){
            placeStatus = product.Placement_Status__c;
        }
        
        if((product.Collection_Agency__c != NULL
        || product.Invalid_Submission__c == true
           ) 
        ){
            if(product.Collection_Agency__c == 9999){
                ERROR_MSG = 'Product is in Warehouse.';
            }
            else{
                ERROR_MSG = '';
                NewPlacementAgency = String.valueOf(product.Collection_Agency__c);
                oldPlacementID = product.Collection_Agency_Placement__c;  
            }
            
        }
        else{
            //ERROR_MSG = 'Product is already Recalled.';
        }
        system.debug('111');
        profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        System.debug('Profile name with User info in Query: ' + profileNameUserInfo);
        
        mapRecallCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        List<Placement_Status_Code_Mapping__c> listStatusCodes = [Select Parent_Status__c,Placement_Status_Code__c,
                                                                         Status__c,Sub_Status__c, Data_Status_Code__c,
                                                                        Data_Status_Description__c,Include_in_Recall__c
                                                                  FROM Placement_Status_Code_Mapping__c
                                                                  //where Parent_Status__c = :PENDING_RECALL 
                                                                  //OR Parent_Status__c
                                                                  ORDER BY Status__c ASC NULLS LAST];  
        system.debug('222');
        listRecallReasonOptions = new list<SelectOption>();
        system.debug('listStatusCodes: '+listStatusCodes);
        
        for(Placement_Status_Code_Mapping__c mapping : listStatusCodes){
            if(mapping.Parent_Status__c == PENDING_RECALL && mapping.Include_in_Recall__c == TRUE){
                if(String.isBlank(mapping.Sub_Status__c)){
                    listRecallReasonOptions.add(new SelectOption(mapping.Placement_Status_Code__c,mapping.Status__c));
                }
                else{
                    listRecallReasonOptions.add(new SelectOption(mapping.Placement_Status_Code__c,mapping.Status__c +' - '+ mapping.Sub_Status__c));  
                }    
            }
            
            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
            
        }
        
        system.debug('placementStatusMap::'+placementStatusMap);
    }
    
    public PageReference recallWithWarning(){
        String updateType = RECALL;
        String placementIdentifier = '';
        
        product.Invalid_Submission__c = false;
        product.Timestamp_Of_Invalid_Submission__c = null;
        product.Invalid_Submission_Reason__c = null;
        product.Invalid_Submission_Initiated_By__c = null;
        system.debug('selectedValueAction:: '+selectedValueAction);
        String mainStatus = mapRecallCodeStatus.get(selectedRecallReason).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedRecallReason).Sub_Status__c;
        map<String, String> mapDataStatus = new map<String, String>();
        
        if(selectedValueAction == PENDING_RECALL){ 
            ERROR_MSG = 'Product set to Pending Recall Status from Agency:' +NewPlacementAgency;
            placementIdentifier = String.valueOf(product.Collection_Agency__c);
            product.Placement_Status__c = selectedRecallReason;
            product.Status_Changed_Date__c = Date.today();
            product.External_Status_Current__c = null;
            product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
            product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
            if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
            }
        }
        else if(selectedValueAction == 'Send To Warehouse'){
            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Recalled_Date__c = Date.today();
            product.External_Status_Current__c = null;
            ERROR_MSG = 'Product sent to Warehouse Agency:' + product.Collection_Agency__c;
            //If status is already in pending recall, update it to corresponding Recall Status
            if(String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)){
                product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //else update the status to the selected reason from list and then to corresponding recall status
            else{
                product.Placement_Status__c = selectedRecallReason;
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
            if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
             //clear the fields once acount recalled and sent to warehouse
            product.Placement_Status__c = null;
            product.Status__c = null;
            product.Sub_Status__c = null;
            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Status_Changed_Date__c = Date.today();
            product.Invalid_Submission_Initiated_By__c = null;
            placementIdentifier = String.valueOf(product.Collection_Agency__c);
        }
        else if(selectedValueAction == 'Pending Allocation'){
            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Recalled_Date__c = Date.today();
            product.External_Status_Current__c = null;
            ERROR_MSG = 'Product set to Pending Allocation Status';
            //If status is already in pending recall, update it to corresponding Recall Status
            if(String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)){
                product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //else update the status to the selected reason from list and then to corresponding recall status
            else{
                product.Placement_Status__c = selectedRecallReason;
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
            if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
            product.Status_Changed_Date__c = Date.today(); 
            product.Status__c = null;
            product.Sub_Status__c = null;
            product.Placement_Status__c = null;
            placementIdentifier = String.valueOf(product.Collection_Agency__c);
        }
         List<Id> prodId =new List<Id>();
            prodId.add(product.id);
        try{
            system.debug('product:: '+product);
            
           DistressedUtilities.UpdateSettlement(prodId);
            ProductTriggerHandler.runProductTrigger = false;
            update product;
            
            if(selectedValueAction == 'Pending Allocation' 
            || selectedValueAction == 'Send To Warehouse'){
            
            //system.debug('placeStatus::'+placeStatus);
            DistressedUtilities.updatePlacementHistory(product.id, selectedRecallReason.replaceFirst(selectedRecallReason.substring(0,1), '9'));
                /* Placement_History__c placementHistory = new Placement_History__c();
                placementHistory.Product__c = product.id;
                placementHistory.Placement__c =  oldPlacementID;    
                placementHistory.Placement_Recall_Date__c = Date.today();
                placementHistory.Placement_Date__c = product.Assignment_Date__c;
                placementHistory.Placement_Status__c = product.Placement_Status__c;
                system.debug('placementHistory.Placement_Status__c::'+placementHistory.Placement_Status__c);
                if(placementStatusMap.containsKey( placementHistory.Placement_Status__c)){
                    placementHistory.Placement_Status_Description__c = placementStatusMap.get( placementHistory.Placement_Status__c).Description__c;    
                }
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
                insert placementHistory;*/
            }
            
            //if(selectedValueAction == PENDING_RECALL){
            
            //Added by satyajit
            Map<Id,String> placeStatus = new Map<Id,String>();
            placeStatus.put(product.id,product.Placement_Status__c);
            
            List<Id> prodListId = new List<Id>();
            prodListId.add(product.Id);
            //Commented by satyajit
              //PortalProductStatusBulkAPI.processBulkProducts(product.Name, product.Placement_Status__c, PENDING_ALLOCATION, 
                                                              // String.valueOf(Date.today()), 
                                          // updateType , placementIdentifier, product.Pool_Name__r.Name); 
            //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Account Status Update File'), 200);
            //Database.BatchProcessForProdScreen.processProductRecallBulk(prodListId,placeStatus,'Account Status Update File');
            
            //}
            ProductTriggerHandler.runProductTrigger = true;
        }
        catch(Exception ex){
            ERROR_MSG = ex.getMessage();
            system.debug('----'+ex.getStackTraceString());
        }
            
        return null;
    }
    
    //Recall Product  
    public PageReference recallProduct(){
        system.debug('placement::'+ product.Collection_Agency_Placement__c);
        String updateType = RECALL;
        String placementIdentifier = '';
        Boolean error = validationOnRecordUpdate(product, NewPlacementAgency);
        system.debug('mapRecallCodeStatusLL'+mapRecallCodeStatus);
        
        system.debug('product.Placement_Status__c:'+product.Placement_Status__c);
        system.debug('selectedRecallReason: '+selectedRecallReason);
        String mainStatus = mapRecallCodeStatus.get(selectedRecallReason).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedRecallReason).Sub_Status__c;
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
            system.debug('map::'+dataStatusMapping.Description1__c+dataStatusMapping.Description2__c);
        }
        
        
        
        system.debug('mapProductStatusCodes::'+mapProductStatusCodes);
        if(error == false){
            product.Invalid_Submission__c = false;
            product.Timestamp_Of_Invalid_Submission__c = null;
            product.Invalid_Submission_Reason__c = null;
            product.Invalid_Submission_Initiated_By__c = null;
            
            if(selectedValueAction == PENDING_RECALL){
                ERROR_MSG = 'Product set to Pending Recall Status from Agency:' +NewPlacementAgency;
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
                product.External_Status_Current__c = null;
                product.Placement_Status__c = selectedRecallReason;
                product.Status_Changed_Date__c = Date.today();
                product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
            else if(selectedValueAction == 'Send To Warehouse'){
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
                ERROR_MSG = 'Product sent to Warehouse Agency:' + product.Collection_Agency__c;
                //If status is already in pending recall, update it to corresponding Recall Status
                if(String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)){
                    product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //else update the status to the selected reason from list and then to corresponding recall status
                else{
                    product.Placement_Status__c = selectedRecallReason;
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }
                
                 //clear the fields once acount recalled and sent to warehouse
                product.Placement_Status__c = null;
                product.Status__c = null;
                product.Sub_Status__c = null;
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Status_Changed_Date__c = Date.today();
                product.Status_Changed_Date__c = Date.today();
                product.Invalid_Submission_Initiated_By__c = null;
                
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
            }
            else if(selectedValueAction == 'Pending Allocation'){
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
                ERROR_MSG = 'Product set to Pending Allocation Status';
                if(String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)){
                    product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //else update the status to the selected reason from list and then to corresponding recall status
                else{
                    product.Placement_Status__c = selectedRecallReason;
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                if(mapRecallCodeStatus.containsKey(product.Placement_Status__c)){
                    product.Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +' - ' +mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if(mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != NULL){
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }
                product.Status_Changed_Date__c = Date.today();
                product.Status__c = null;
                product.Sub_Status__c = null;
                product.Placement_Status__c = null;
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
            }
            
            //Remove Pool from Product on Recall
            product.Pool_Name__c = null;
            List<Id> prodId =new List<Id>();
            prodId.add(product.id);
            try{
                DistressedUtilities.UpdateSettlement(prodId);
                ProductTriggerHandler.runProductTrigger = false;
                update product;
                
                if(selectedValueAction == 'Pending Allocation' 
                   || selectedValueAction == 'Send To Warehouse'){
                   
                   system.debug('placeStatus::'+placeStatus);
                    DistressedUtilities.updatePlacementHistory(product.id, selectedRecallReason.replaceFirst(selectedRecallReason.substring(0,1), '9'));
                      /* Placement_History__c placementHistory = new Placement_History__c();
                       placementHistory.Product__c = product.id;
                       placementHistory.Placement__c =  oldPlacementID;    
                       placementHistory.Placement_Recall_Date__c = Date.today();
                       placementHistory.Placement_Date__c = product.Assignment_Date__c;
                       placementHistory.Placement_Status__c = product.Placement_Status__c;
                       
                       system.debug('placementHistory.Placement_Status__c::'+placementHistory.Placement_Status__c);
                       if(placementStatusMap.containsKey( placementHistory.Placement_Status__c)){
                        placementHistory.Placement_Status_Description__c = placementStatusMap.get( placementHistory.Placement_Status__c).Description__c;    
                       }
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
                       insert placementHistory;*/
                   }
                system.debug('placementIdentifier::'+placementIdentifier);
                
                //Added by satyajit
            Map<Id,String> placeStatus = new Map<Id,String>();
            placeStatus.put(product.id,product.Placement_Status__c);
            
            List<Id> prodListId = new List<Id>();
            prodListId.add(product.Id);
                
                //Commented by satyajit
                   // PortalProductStatusBulkAPI.processBulkProducts(product.Name, product.Placement_Status__c, PENDING_ALLOCATION_RECALLED_CODE, String.valueOf(Date.today()), 
                                              // updateType,placementIdentifier, product.Pool_Name__r.Name);    
                                              // 
                                              // 
           //Added by satyajit
          //ProcessProductStatusUpdateBatchRecall.processProductRecallBulk(prodListId,placeStatus,'Account Status Update File');
          //
           //Added by satyajit
            Database.executeBatch(new BatchProcessForProdScreen(prodListId,placeStatus,'Account Status Update File'), 200);
                
                ProductTriggerHandler.runProductTrigger = true;
            }
            catch(Exception ex){
                ERROR_MSG = ex.getMessage();
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
        ERROR_MSG = '';
        Map<String ,Placement__c> mapPlacement =new Map<String,Placement__c>();
        Map<Id ,Product_Payments__c> mapProductPayment =new Map<Id,Product_Payments__c>();
      
        List<Product_Payments__c> listProductPayments = [SELECT ID, CCS_Account__c,CCS_Account__r.Name 
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__c= :product.ID
                                              AND Payment_Agency__c = :newPlacement
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60];
                                          
        if(String.isNotBlank(product.Collection_Sub_Status__c) && product.Collection_Sub_Status__c == 'Legal'){
            system.debug('recall warning::');
            ERROR_MSG += '<b>WARNING</b> - '+'Product is in Legal Status'+'<br/>';
        }
            
        //Check Recall Validations
        if(!listProductPayments.isEmpty()){
            ERROR_MSG += '<b>WARNING</b> - '+'Account had a recent payment in last 2 months'+'<br/>';
            //product.addError('Cannot recall agency as Product is in Legal Status');
        }
                
     
        if(String.isNotBlank(ERROR_MSG)){
            return true;
        }
        else{
            return false;
        }
    }
        
    public List<SelectOption> getactionItems() {
        List<SelectOption> actionoptions = new List<SelectOption>();
        //actionoptions.add(new SelectOption('--Action--','--Action--'));
        if(product.Collection_Agency__c!= null
         && product.Collection_Agency__c != 9999 
         && ( String.isBlank(product.Status__c) || (String.isNotBlank(product.Status__c) && !product.Status__c.contains(PENDING_RECALL)))){
            actionoptions.add(new SelectOption(PENDING_RECALL,PENDING_RECALL));    
        }
        if(product.Collection_Agency__c != NULL && product.Collection_Agency__c != 9999){
            actionoptions.add(new SelectOption('Pending Allocation','Pending Allocation'));     
        }
        if(product.Collection_Agency__c != 9999){
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse'));    
        }
             
        if(product.Collection_Agency__c == 9999){
            actionoptions.add(new SelectOption('Pending Allocation','Pending Allocation')); 
            actionoptions.add(new SelectOption('Send to Warehouse','Send to Warehouse'));
            actionoptions.add(new SelectOption('Pending Allocation','Pending Allocation'));  
        }
        
        return actionoptions;
    }
    
    public pageReference redirectToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}