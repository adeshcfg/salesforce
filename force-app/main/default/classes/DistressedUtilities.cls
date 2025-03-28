/**************************************************************************************************
*
*  Class:  DistressedUtilities 
*
*  @description : Utility class for common Functions distressed Products record.
*  @author : A5E Consulting
*  @date : 23/01/2022

*************************************************************************************************/

public class DistressedUtilities {
    public static map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll(); 
    
    public static Map<Id, String>  placementHistoryIDMap;
    public static Map<Id, Decimal>  productIDMap;
    public static Map<Id, String> settlementIDMap;
    public static Map<String, ID> mapProductJudgment = new Map<String, ID>();
    public static Map<String,Provice_Name_Map_with_Abbreviations__mdt> mapProviceAbbreviations = Provice_Name_Map_with_Abbreviations__mdt.getAll();
    public static Map<String, String> mapProvinceAcronym = new Map<String, String>();
    // Fetching and updating Placement History Map
    public static void loadPlacementHistoryIDMap(List<id> prodIdList){
        placementHistoryIDMap = new Map<Id, String>();
        productIDMap = new Map<Id, Decimal>();
        
        // Iterate and push statute date values to a map
        for(Placement_history__c m :[Select id,name,Product__c,Product__r.Current_Balance__c from Placement_history__c where Product__c in: prodIdList AND Placement_Recall_Date__c = null ORDER By CreatedDate DESC]){
            if(!placementHistoryIDMap.containsKey(m.Product__c)){
                placementHistoryIDMap.put(m.Product__c, m.id);
                productIDMap.put(m.Product__c,m.Product__r.Current_Balance__c);
            }
        }
    }
    //Method calls for Allocation using Pool and Product screen.
    public static void createPlacementHistory(List<Product__c> prodList, String oldPlacementID,Decimal placement,map<id,string> prodAgency){
        List<Placement_History__c> PlaceHistoryList = new List<Placement_History__c>(); 
        for(Product__c product : prodList){
            decimal recoverableFee = 0;
            decimal allocatedAmountPrincipal = 0;
            decimal allocatedAmountInterest = 0;
            decimal currentBalNSFFees = 0;
            
            decimal totalAllocatedBalance = 0;
            
            //Placement__c plceID = [select id,name,Commission_Rate__c from Placement__c where name =: String.valueOf(product.Collection_Agency__c) limit 1];
            Placement_History__c placementHistory = new Placement_History__c();
            placementHistory.Product__c = product.id;
            
            if(prodAgency != NULL && prodAgency.containsKey(product.id)){
                placementHistory.Placement__c =  prodAgency.get(product.id);
            }else{
                placementHistory.Placement__c =  oldPlacementID;
            }
                
            //placementHistory.Placement_Recall_Date__c = Date.today();
            placementHistory.Placement_Date__c = product.Assignment_Date__c;
            placementHistory.Placement_Status__c = product.Placement_Status__c;
            if(placementStatusMap.containskey(placementHistory.Placement_Status__c)){
                placementHistory.Placement_Status_Description__c = placementStatusMap.get(placementHistory.Placement_Status__c).Description__c;
            }
            placementHistory.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
            placementHistory.Current_Interest_Balance__c = product.Current_Interest_Amount__c;
            placementHistory.Interest_Rate__c = product.Interest_Rate__c;
            placementHistory.NSF_Fees__c = product.Current_Bal_NSF_Fees__c;
            placementHistory.Current_Bal_Attorney_Fees__c = product.Current_Bal_Attorney_Fees__c;
            placementHistory.Current_Bal_General_Fees__c = product.Current_Bal_General_Fees__c;
            placementHistory.Current_Bal_Other_Fees__c = product.Current_Bal_Other_Fees__c;
            placementHistory.Current_Bal_Court_Fees__c = product.Current_Bal_Court_Fees__c;
            // placementHistory.Commission_Rate__c = product.Collection_Agency_Placement__r.Commission_Rate__c;
            placementHistory.Commission_Rate__c =placement;
            placementHistory.Pool_Commission_Rate__c = product.Pool_Name__r.Commission_Rate__c;
            placementHistory.Product_Commission_Rate__c = product.Commission_Rate__c;
            placementHistory.Pool_ID__c = product.Pool_Name__r.Name;

            //placementHistory.Allocated_Balance__c = product.Allocated_Amount_Total__c;
            //
            if(product.Recoverable_Fee__c != null){
                recoverableFee = product.Recoverable_Fee__c;
            }
            if(product.Allocated_Amount_Principal__c != null){
                allocatedAmountPrincipal = product.Allocated_Amount_Principal__c;
            }
            if(product.Allocated_Amount_Interest__c != null){
                allocatedAmountInterest = product.Allocated_Amount_Interest__c;
            }
            if(product.Current_Bal_NSF_Fees__c != null){
                currentBalNSFFees = product.Current_Bal_NSF_Fees__c;
            }
            
            totalAllocatedBalance = recoverableFee + 
                allocatedAmountPrincipal + 
                allocatedAmountInterest + 
                currentBalNSFFees;
            
            placementHistory.Allocated_Balance__c = totalAllocatedBalance;
                
            placementHistory.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
            placementHistory.Value_Tier_at_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
            placementHistory.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
            placementHistory.Recoverable_fee_balance__c = product.Recoverable_Fee__c;
            placementHistory.Non_recoverable_fee_balance__c = product.Non_Recoverable_Fee__c;
            placementHistory.Total_Balance_at_Placement__c = totalAllocatedBalance;
            
            PlaceHistoryList.add(placementHistory);
            
        }
        insert PlaceHistoryList;
    }
    
    //Method calls for Allocation using excel processing.
    public static void createPlaceHistoryAlloExcel(Product_Staging__c productStaging1, Product__c productToRefer,map<String,Placement__c> mapPlacement, map<ID, Pool__c> mapPoolRecords){
        List<Placement_History__c> PlaceHistoryList = new List<Placement_History__c>(); 
        decimal recoverableFee = 0;
        decimal allocatedAmountPrincipal = 0;
        decimal allocatedAmountInterest = 0;
        decimal currentBalNSFFees = 0;
        
       decimal totalAllocatedBalance = 0;
        
        //Placement__c plceID = [select id,name,Commission_Rate__c from Placement__c where name =: String.valueOf(product.Collection_Agency__c) limit 1];
        Placement_History__c placementHistory = new Placement_History__c();
        placementHistory.Product__c = productToRefer.Id;
        
        placementHistory.Placement__c = productStaging1.Placement_Agency_ID__c; 
        placementHistory.Product_Commission_Rate__c = productStaging1.Current_Commission_Rate__c; 
        placementHistory.Placed_Commission_Rate__c = productStaging1.Placed_Commission_Rate__c;
        placementHistory.Value_Tier_at_Placement__c = productStaging1.Value_Tier_at_Time_of_Placement__c;
        placementHistory.Placed_Settlement_Rate__c = productStaging1.Placed_Settlement_Rate__c;
        
        placementHistory.Placement_Date__c = Date.today();
        placementHistory.Placement_Status_Description__c = 'New Allocation (1.0); Ready';
        placementHistory.Placement_Status__c = '100000';
        placementHistory.Current_Principal_Balance__c = productToRefer.Current_Principal_Balance__c;
        placementHistory.Current_Interest_Balance__c = productToRefer.Current_Interest_Amount__c;
        placementHistory.Interest_Rate__c = productToRefer.Interest_Rate__c;
        placementHistory.NSF_Fees__c = productToRefer.Current_Bal_NSF_Fees__c;
        placementHistory.Current_Bal_Attorney_Fees__c = productToRefer.Current_Bal_Attorney_Fees__c;
        placementHistory.Current_Bal_General_Fees__c = productToRefer.Current_Bal_General_Fees__c;
        placementHistory.Current_Bal_Other_Fees__c = productToRefer.Current_Bal_Other_Fees__c;
        placementHistory.Current_Bal_Court_Fees__c = productToRefer.Current_Bal_Court_Fees__c;
        if(mapPlacement.containsKey(productStaging1.Placement_Agency__c) &&
           mapPlacement.get(productStaging1.Placement_Agency__c).Commission_rate__c != NULL){
               placementHistory.Commission_Rate__c = mapPlacement.get(productStaging1.Placement_Agency__c).Commission_rate__c;  
           }
        if(mapPoolRecords.containsKey(productStaging1.Pool_Name_ID__c)){
            if(mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Commission_rate__c != NULL){
                placementHistory.Pool_Commission_Rate__c = mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Commission_rate__c;
            }
            if(mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Name != NULL){
                placementHistory.Pool_ID__c =  mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Name;
            }
        }
        //placementHistory.Product_Commission_Rate__c = productToRefer.Commission_Rate__c;
        
        placementHistory.Recoverable_fee_balance__c = productToRefer.Recoverable_Fee__c;
        placementHistory.Non_recoverable_fee_balance__c =productToRefer.Non_Recoverable_Fee__c;
        
        if(productToRefer.Recoverable_Fee__c != null){
            recoverableFee = productToRefer.Recoverable_Fee__c;
        }
        if(productToRefer.Current_Principal_Balance__c != null){
            allocatedAmountPrincipal = productToRefer.Current_Principal_Balance__c;
        }
        if(productToRefer.Current_Interest_Amount__c != null){
            allocatedAmountInterest = productToRefer.Current_Interest_Amount__c;
        }
        if(productToRefer.Current_Bal_NSF_Fees__c != null){
            currentBalNSFFees = productToRefer.Current_Bal_NSF_Fees__c;
        }
        
        totalAllocatedBalance = recoverableFee + 
            allocatedAmountPrincipal + 
            allocatedAmountInterest + 
            currentBalNSFFees;
        
        placementHistory.Allocated_Balance__c = totalAllocatedBalance;
            
        placementHistory.Total_Balance_at_Placement__c = totalAllocatedBalance;
        
        PlaceHistoryList.add(placementHistory);
        
        insert PlaceHistoryList;
    }
    
    //Create Placement history record when account is allocate to agency via excel processing.
    public static Placement_History__c createPlaceHistoryAlloExcel_New(Product_Staging__c productStaging1, Product__c productToRefer,map<String,Placement__c> mapPlacement, map<ID, Pool__c> mapPoolRecords){
        List<Placement_History__c> PlaceHistoryList = new List<Placement_History__c>(); 
        decimal recoverableFee = 0;
        decimal allocatedAmountPrincipal = 0;
        decimal allocatedAmountInterest = 0;
        decimal currentBalNSFFees = 0;
        
        decimal totalAllocatedBalance = 0;
        //Placement__c plceID = [select id,name,Commission_Rate__c from Placement__c where name =: String.valueOf(product.Collection_Agency__c) limit 1];
        Placement_History__c placementHistory = new Placement_History__c();
        placementHistory.Product__c = productToRefer.Id;
        
        placementHistory.Placement__c = productStaging1.Placement_Agency_ID__c; 
        placementHistory.Product_Commission_Rate__c = productStaging1.Current_Commission_Rate__c; 
        placementHistory.Placed_Commission_Rate__c = productStaging1.Placed_Commission_Rate__c;
        placementHistory.Value_Tier_at_Placement__c = productStaging1.Value_Tier_at_Time_of_Placement__c;
        placementHistory.Placed_Settlement_Rate__c = productStaging1.Placed_Settlement_Rate__c;
        
        placementHistory.Placement_Date__c = Date.today();
        
        if(productStaging1.Placement_Main_Status__c != NULL){
            placementHistory.Placement_Status_Description__c = productStaging1.Placement_Main_Status__c;
        }else{
            placementHistory.Placement_Status_Description__c = 'New Allocation (1.0); Ready';
        }
        if(productStaging1.Placement_Status_Code__c != NULL){
            placementHistory.Placement_Status__c = productStaging1.Placement_Status_Code__c;
        }else{
            placementHistory.Placement_Status__c = '100000';
        }
        
        placementHistory.Current_Principal_Balance__c = productToRefer.Current_Principal_Balance__c;
        placementHistory.Current_Interest_Balance__c = productToRefer.Current_Interest_Amount__c;
        placementHistory.Interest_Rate__c = productToRefer.Interest_Rate__c;
        placementHistory.NSF_Fees__c = productToRefer.Current_Bal_NSF_Fees__c;
        placementHistory.Current_Bal_Attorney_Fees__c = productToRefer.Current_Bal_Attorney_Fees__c;
        placementHistory.Current_Bal_General_Fees__c = productToRefer.Current_Bal_General_Fees__c;
        placementHistory.Current_Bal_Other_Fees__c = productToRefer.Current_Bal_Other_Fees__c;
        placementHistory.Current_Bal_Court_Fees__c = productToRefer.Current_Bal_Court_Fees__c;
        if(mapPlacement.containsKey(productStaging1.Placement_Agency__c) &&
           mapPlacement.get(productStaging1.Placement_Agency__c).Commission_rate__c != NULL){
               placementHistory.Commission_Rate__c = mapPlacement.get(productStaging1.Placement_Agency__c).Commission_rate__c;  
           }
        if(mapPoolRecords.containsKey(productStaging1.Pool_Name_ID__c)){
            if(mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Commission_rate__c != NULL){
                placementHistory.Pool_Commission_Rate__c = mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Commission_rate__c;
            }
            if(mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Name != NULL){
                placementHistory.Pool_ID__c =  mapPoolRecords.get(productStaging1.Pool_Name_ID__c).Name;
            }
        }
        //placementHistory.Product_Commission_Rate__c = productToRefer.Commission_Rate__c;
        placementHistory.Recoverable_fee_balance__c = productToRefer.Recoverable_Fee__c;
        placementHistory.Non_recoverable_fee_balance__c =productToRefer.Non_Recoverable_Fee__c;
        
        if(productToRefer.Recoverable_Fee__c != null){
            recoverableFee = productToRefer.Recoverable_Fee__c;
        }
        if(productToRefer.Current_Principal_Balance__c != null){
            allocatedAmountPrincipal = productToRefer.Current_Principal_Balance__c;
        }
        if(productToRefer.Current_Interest_Amount__c != null){
            allocatedAmountInterest = productToRefer.Current_Interest_Amount__c;
        }
        if(productToRefer.Current_Bal_NSF_Fees__c != null){
            currentBalNSFFees = productToRefer.Current_Bal_NSF_Fees__c;
        }
        
        totalAllocatedBalance = recoverableFee + 
            allocatedAmountPrincipal + 
            allocatedAmountInterest + 
            currentBalNSFFees;

        placementHistory.Allocated_Balance__c = totalAllocatedBalance;
        
        placementHistory.Total_Balance_at_Placement__c = totalAllocatedBalance;
        
        return placementHistory;
        // PlaceHistoryList.add(placementHistory);
        
        //insert PlaceHistoryList;
    }
    
    //Method is used for update placement history record at time of recall
    public static void updatePlacementHistory(id product, String placeStatus){  
        List<ID> prodID = new List<ID>();
        prodID.add(product);
        Placement_history__c placeHistory = [Select id,name,Product__r.Current_Balance__c from Placement_history__c where Product__c =: product AND Placement_Recall_Date__c = null ORDER By CreatedDate DESC limit 1 ];
        Placement_history__c updatePlaceHistory = new Placement_history__c();
        updatePlaceHistory.Id = placeHistory.Id;
        updatePlaceHistory.Placement_Recall_Date__c = Date.today();
        updatePlaceHistory.Placement_Status__c = placeStatus;
        updatePlaceHistory.Placement_Status_Description__c = placementStatusMap.get(placeStatus).Description__c;
        updatePlaceHistory.Placement_Status_at_time_of_recall__c = placeStatus;
        if(placeHistory.Product__r.Current_Balance__c != NULL){
           updatePlaceHistory.Current_Total_Bal_at_time_of_Recall__c = placeHistory.Product__r.Current_Balance__c; 
        }
        
        Update updatePlaceHistory;
        
        //Reject settlement when product is recall.
        // UpdateSettlement(prodID);
    }
    
    //Update placement history record when account recalled from agency.
    public static void updatePlacementHistory_New(List<id> prodIdList,map<ID, String> placeStatus){  
        loadPlacementHistoryIDMap(prodIdList);
        
        List<Placement_history__c> lstUpdateHis = new List<Placement_history__c>();
        //Placement_history__c placeHistory = [Select id,name from Placement_history__c where Product__c =: product AND Placement_Recall_Date__c = null limit 1];
        for(id pid:prodIdList){
            if(placementHistoryIDMap.get(pid)!=null){
                Placement_history__c updatePlaceHistory = new Placement_history__c();
                updatePlaceHistory.Id = placementHistoryIDMap.get(pid); //placeHistory.Id;
                updatePlaceHistory.Placement_Recall_Date__c = Date.today();
                updatePlaceHistory.Placement_Status__c = placeStatus.get(pid);
                if(placementStatusMap.containskey(updatePlaceHistory.Placement_Status__c)){
                    updatePlaceHistory.Placement_Status_Description__c = placementStatusMap.get(updatePlaceHistory.Placement_Status__c).Description__c;
                }
                updatePlaceHistory.Placement_Status_at_time_of_recall__c = placeStatus.get(pid);//placeStatus;
                if(productIDMap.containsKey(pid) && productIDMap.get(pid) != NULL){
                    updatePlaceHistory.Current_Total_Bal_at_time_of_Recall__c = productIDMap.get(pid);
                }
                lstUpdateHis.add(updatePlaceHistory);
                //Update updatePlaceHistory;
            }
        }
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
        update lstUpdateHis;
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
    }
    
    //Reject settlement when product is recall.
    public static void UpdateSettlement(List<id> prodIdList){   
        Database.executeBatch(new updateSettlementStatusBatch(prodIdList), 1);
    }
    
    // Fetching and updating active Settlement Map
    public static void loadSettlementIDMap(List<id> prodIdList){
        settlementIDMap = new Map<Id, String>();
        
        // Iterate and push statute date values to a map
        for(Settlement__c m :[Select id,name,Product__c from Settlement__c where Product__c in: prodIdList AND (Status__c != 'Withdraw' OR Status__c != 'Rejected')]){
            settlementIDMap.put(m.Product__c, m.id);
        }
    }

    public static List<Product_Staging__c> validatePutbackBuybackRecords(
        List<Product_Staging__c> batchScope,
        Map<String, Product__c> mapProductName,
        String documentStorageId
    ) {
        List<String> validProductStatuses = new List<String> {'297000', '298000'};
        for (Product_Staging__c productStaging : batchScope) {
            String expected = '';
            String errorMsg = '';
            if (productStaging.Data_Id__c == null && productStaging.Name__c == null) {
                errorMsg += '<b>ERROR</b> - Invalid Account Number.<br/>';
                expected += 'Account Number cannot be blank<br/>';
            } else {
                if (!mapProductName.containsKey(productStaging.Data_Id__c)) {
                    errorMsg = '<b>ERROR</b> - Invalid Account Number.' + '<br/>';
                }
                if (mapProductName.containsKey(productStaging.Data_Id__c) && !validProductStatuses.contains(mapProductName.get(productStaging.Data_Id__c).Product_Status__c)) {
                    errorMsg += '<b>ERROR</b> - Invalid current Product Status.' + '<br/>';
                    expected += 'Current Product status should be either 297000 or 298000<br/>';
                }
                if (String.isBlank(productStaging.Purchase_Status__c)) {
                    errorMsg += '<b>ERROR</b> - Invalid Purchase Status.' + '<br/>';
                    expected += 'Purchase status should be either ' + DisplayBuybackPutbackStagingController.BUYBACK_APPROVED + ' or ' + DisplayBuybackPutbackStagingController.BUYBACK_REJECTED + '<br/>';
                }
                if (String.isNotBlank(productStaging.Purchase_Status__c) && productStaging.Purchase_Status__c == DisplayBuybackPutbackStagingController.BUYBACK_REJECTED && String.isBlank(productStaging.Rejection_Reason__c)) {
                    errorMsg += '<b>ERROR</b> - Rejection reason is mandatory.' + '<br/>';
                    expected += 'Rejection reason is mandatory when purchase status is ' + DisplayBuybackPutbackStagingController.BUYBACK_REJECTED + '<br/>';
                }
                if (String.isNotBlank(productStaging.Rejection_Reason__c) && productStaging.Rejection_Reason__c == 'Field length exceeded') {
                    productStaging.Rejection_Reason__c = null;
                    errorMsg += '<b>ERROR</b> - Rejection reason length exceeded.' + '<br/>';
                    expected += 'Rejection reason cannot be longer than 255 characters<br/>';
                }
                if (String.isNotBlank(productStaging.Purchase_Status__c) && productStaging.Purchase_Status__c == DisplayBuybackPutbackStagingController.BUYBACK_APPROVED && productStaging.Putback_Buyback_Amount__c == null) {
                    errorMsg += '<b>ERROR</b> - Buyback/Putback Amount is mandatory.' + '<br/>';
                    expected += 'Buyback/Putback Amount is mandatory when purchase status is ' + DisplayBuybackPutbackStagingController.BUYBACK_APPROVED + '<br/>';
                }
            }
            if (String.isBlank(errorMsg) && productStaging.Purchase_Status__c == DisplayBuybackPutbackStagingController.BUYBACK_APPROVED) {
                productStaging.Product_Status__c = mapProductName.get(productStaging.Data_Id__c).Product_Status__c.replaceFirst('2', '9');
            }
            productStaging.External_Id__c = productStaging.Data_Id__c + '_' + documentStorageId;
            productStaging.Name__c = productStaging.Data_Id__c;
            if (errorMsg.length() > 254) {
                productStaging.Comment__c = errorMsg.substring(0, 253);
            } else {
                productStaging.Comment__c = errorMsg;
            }
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentStorageId;
            productStaging.Expected_Value__c = expected;
            productStaging.Document_Storage__c = documentStorageId;
            productStaging.Is_Record_Process__c = true;
            if (String.isBlank(errorMsg)) {
                productStaging.Comment__c = 'SUCCESS';
                productStaging.Include_in_Processing__c = true;
            }
        }
        return batchScope;
    }

    public static List<Product_Staging__c> validateProductStatusUpdateRecords(
        List<Product_Staging__c> batchScope,
        Map<String, Product__c> mapProductName,
        String documentStorageId
    ) {
        Map<String, String> statusDescriptionMap = new Map<String, String>();
        for (Data_Status_Mapping__c statusMapping : [SELECT Name, Description__c FROM Data_Status_Mapping__c]) {
            statusDescriptionMap.put(statusMapping.Name, statusMapping.Description__c);
        }
        for (Product_Staging__c productStaging : batchScope) {
            String expected = '';
            String errorMsg = '';
            if (productStaging.Data_Id__c == null && productStaging.Name__c == null) {
                errorMsg += '<b>ERROR</b> - Invalid Account Number.<br/>';
                expected += 'Account Number cannot be blank<br/>';
            } else {
                if (!mapProductName.containsKey(productStaging.Data_Id__c)) {
                    errorMsg += '<b>ERROR</b> - Invalid Account Number.' + '<br/>';
                }
                else {
                    Product__c product = mapProductName.get(productStaging.Data_Id__c);
                    if (product.Collection_Agency__c != null && product.Collection_Agency__c != 9999) {
                        errorMsg += '<b>ERROR</b> - Please initiate recall process.' + '<br/>';
                    }
                }
                if (!statusDescriptionMap.containsKey(productStaging.Product_Status__c)) {
                    errorMsg += '<b>ERROR</b> - Invalid Product Status.' + '<br/>';
                }
            }
            productStaging.External_Id__c = productStaging.Data_Id__c + '_' + documentStorageId;
            productStaging.Name__c = productStaging.Data_Id__c;
            if (errorMsg.length() > 254) {
                productStaging.Comment__c = errorMsg.substring(0, 253);
            } else {
                productStaging.Comment__c = errorMsg;
            }
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentStorageId;
            productStaging.Expected_Value__c = expected;
            productStaging.Document_Storage__c = documentStorageId;
            productStaging.Is_Record_Process__c = true;
            if (String.isBlank(errorMsg)) {
                productStaging.Comment__c = 'SUCCESS';
                productStaging.Include_in_Processing__c = true;
            }
        }
        return batchScope;
    }
    
    //This method runs the validation for product allocation process.
    public static list<Product_staging__c> allocationValidationOnRecordUpdate(List<Product_Staging__c> batchScope,
                                                                              List<Product__c> listProducts,
                                                                              Map<String, Product__c> mapProductName,
                                                                              String documentStorageId,
                                                                              Map<String ,Pool__C> mapPoolName)
    {   
        Map<String ,Placement__c> mapPlacement =new Map<String,Placement__c>();
        Map<String ,Pool__c> mapPool =new Map<String,Pool__c>();                                                
        Map<Id ,Product_Payments__c> mapProductPayment =new Map<Id,Product_Payments__c>();
        list<Product_Staging__c> listProductAllocateStaging = new list<Product_Staging__c>();
        set<String> setPreviousPlacedProductNames = getPlacementHistoryDetails(mapProductName.keySet());
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>(); 
        
        Map<String, Product_Staging__c> insertedProductStaging = new Map<String, Product_Staging__c>();
        if(batchScope != null && !batchScope.isEmpty()) {
            for(Product_Staging__c p:batchScope) {
                insertedProductStaging.put(p.Data_Id__c, p);
            }
        }
        for(Product_Staging__c prodList:batchScope) {
            if(mapProductNameAmount.containsKey(String.valueOf(prodList.Data_Id__c))){
                mapProductNameAmount.put(String.valueOf(prodList.Data_Id__c), mapProductNameAmount.get(prodList.Data_Id__c)+1);
            }else {
                mapProductNameAmount.put(String.valueOf(prodList.Data_Id__c), 1);
            }
        }                                    
        for(Placement__c placement : [Select ID, Name, Serviceable_Province__c,Active__c From Placement__c]){
            mapPlacement.put(placement.Name, placement);
        }
        
        for(Pool__c pool : [SELECT ID, Name,Placement_Agency__c FROM Pool__c ]){
            mapPool.put(pool.Name, pool);
        }   
        //Fill provice name map with abbriviations
        for(Provice_Name_Map_with_Abbreviations__mdt metaData : mapProviceAbbreviations.values()){
            mapProvinceAcronym.put(metaData.Province_Acronym__c,metaData.Province_Name__c);
        }
        
        String newAgency = '';
        String oldAgency;
        String prodAgency = '';
        String poolAgency = '';
        //Decimal commissionAdjustment = 0;                                            
        for(Product_Staging__c product: batchScope){
            
            if(insertedProductStaging.get(product.Data_Id__c).Placement_Agency__c != NULL){
                newAgency = insertedProductStaging.get(product.Data_Id__c).Placement_Agency__c;    
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Collection_Agency__c != NULL){
                oldAgency = String.valueOf(Math.floor(mapProductName.get(product.Data_Id__c).Collection_Agency__c));    
            }
            // 3
            String EXPECTED = '';
            String ERROR_MSG = '';
            
             if(product.Data_Id__c == null && product.Name__c == null){
                 ERROR_MSG += '<b>ERROR</b> - Invalid account number.<br/>';
                 EXPECTED += 'Account number cannot be blank<br/>'; 
            }
             if(product.Data_Id__c != null || product.Name__c != null){
              
            if(setPreviousPlacedProductNames.contains(product.Data_Id__c+ newAgency)){
                ERROR_MSG+= '<b>WARNING</b>-'+'Product is placed with the agency in last 6 months'+'<br/>';
                //product.addError('Product is placed with the agency in last 6 months');
            }
            if(!mapProductName.containsKey(product.Data_Id__c)){
                ERROR_MSG = '<b>ERROR</b>-Invalid Account Number.'+'<br/>';
            }
            if((String.isNotBlank(newAgency) && !mapPlacement.containsKey(newAgency))){
                ERROR_MSG = '<b>ERROR</b>-Invalid Agency Number.'+'<br/>';
            }
            if(mapPlacement.containsKey(newAgency) && mapPlacement.get(newAgency).Active__c == False){
                ERROR_MSG += '<b>ERROR</b> - Allocate Agency is not Active <br/>';
            }
            if( String.isBlank(newAgency)){
                ERROR_MSG = '<b>ERROR</b>- Enter Agency Number to allocate.'+'<br/>';
            }
            if(mapPool.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c) == NULL && String.isNotBlank(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c)){
                ERROR_MSG += '<b>ERROR</b>- This Pool is not available in system.<br/>';
            }
            
            if(mapProductNameAmount.get(product.Data_Id__c) > 1){
                ERROR_MSG += '<b>ERROR</b>- A duplicate transaction was found in this File Update.<br/>';    
            }
            
            String AgencyProvince;
            if(String.isNotBlank(newAgency)
               && mapPlacement.containsKey(newAgency)
               && String.isNotBlank(mapPlacement.get(newAgency).Serviceable_Province__c)){
                   AgencyProvince = mapPlacement.get(newAgency).Serviceable_Province__c; 
               }
            if(String.isBlank(mapProductName.get(product.Data_Id__c).Purchase_Province__c)){
                     ERROR_MSG += '<b>ERROR</b> - '+'Purchase Province Required'+'<br/>';
            }
            if(String.isNotBlank(newAgency)
               && String.isNotBlank(AgencyProvince)
               && mapProductName.containsKey(product.Data_Id__c)
               && String.isNotBlank(mapProductName.get(product.Data_Id__c).Purchase_Province__c)
               && ( (!mapProvinceAcronym.containsKey(mapProductName.get(product.Data_Id__c).Purchase_Province__c) && !AgencyProvince.contains(mapProductName.get(product.Data_Id__c).Purchase_Province__c))
                   ||   (mapProvinceAcronym.containsKey(mapProductName.get(product.Data_Id__c).Purchase_Province__c)  &&!AgencyProvince.contains(mapProvinceAcronym.get(mapProductName.get(product.Data_Id__c).Purchase_Province__c))))){
                       ERROR_MSG += '<b>ERROR</b>- '+'Product cannot be placed with agency as Product Purchase Province is Non Serviceable for Agency'+'<br/>';
                       EXPECTED += 'Product Purchase Province should be either - ' + AgencyProvince +'<br/>';
                   }
            
            if(newAgency == oldAgency){
                //commented by tejal ERROR to WARNING
                ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with Same agency'+'<br/>'; 
            }
            else if(String.isNotBlank(oldAgency) && oldAgency != '9999'){
                ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with another agency'+'<br/>';
                EXPECTED += 'Current Agency- ' + oldAgency +'<br/>';
                //errorMessage += ' VALIDATION: '+'Product is already placed with another agency:'+oldAgency;
                //product.addError('Product is allready placed with Agency');
                //errorAdded = true;
            }
            
            
            //Changes
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Collection_Agency__c != NULL){
                prodAgency = String.valueOf(Math.floor(mapProductName.get(product.Data_Id__c).Collection_Agency__c));    
            }
            if(mapPoolName.containsKey(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c)){
                if(mapProductName.containsKey(product.Data_Id__c) && mapPool.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c) != NULL 
                   && mapPoolName.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c).Placement_Agency__c != NULL)
                {
                    poolAgency = String.valueOf(mapPoolName.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c).Placement_Agency__c);
                }
            }
            if(Test.isRunningTest()){
                poolAgency = '30';
            }
            if(mapPoolName.containsKey(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c) && mapPoolName.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c).Placement_Agency__c != null) {
                if(prodAgency != poolAgency){ // Here We should put a check of prod agency not equal 9999 by Nirmallya
                    //commented by tejal ERROR to WARNING
                    ERROR_MSG += '<b>ERROR</b> - Pool cannot be mapped to account.<br/>';
                    EXPECTED += 'Pool Agency is different to account collection agency.<br/>';  
                }
            }
            
            if(String.isNotBlank(prodAgency) && String.isNotBlank(poolAgency)){
                if(poolAgency != '9999' && prodAgency != '9999'){
                    if(prodAgency != poolAgency){
                        ERROR_MSG += '<b>ERROR</b> - This account cannot be assigned to Pool.<br/>';
                        EXPECTED += 'Pool Agency = ' +poolAgency+'.<br/>Product Agency = ' +prodAgency+'.<br/>';
                    }
                }
            }
            
            //Buyback/Putback Validation
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Purchase_Status__c != null){
            if(mapProductName.get(product.Data_Id__c).Purchase_Status__c != 'Buyback/Putback Rejected'){
                ERROR_MSG += '<b>ERROR</b> - '+'Product is in Buyback/Putback state'+'<br/>';
                EXPECTED += 'Cannot allocate Product when Buyback/Putback Status is - ' + mapProductName.get(product.Data_Id__c).Purchase_Status__c + '<br/>';
            }
            }
            //4658 -  Validation for value tier at time of placement
            String valueTireRegex = '^[a-zA-Z!@#$&?!*%()\\-`.+,/\"]*$';   
            Pattern MyPattern2 = Pattern.compile(valueTireRegex);
            Matcher MyMatcher2;
            
            String valueTireAlphabetRegex = '^[!@#$&?!*%()\\-`.+,/\"]*$';
            Pattern MyPattern3 = Pattern.compile(valueTireAlphabetRegex);
            Matcher MyMatcher3;
                 
            String valueTireFirstLetterAlphabetRegex = '[a-zA-Z]{1}.*';
            Pattern MyPattern4 = Pattern.compile(valueTireFirstLetterAlphabetRegex);
            Matcher MyMatcher4;
                 
            if(product.Value_Tier_at_Time_of_Placement__c != NULL){
               MyMatcher2 = MyPattern2.matcher(product.Value_Tier_at_Time_of_Placement__c); 
               MyMatcher3 = MyPattern3.matcher(product.Value_Tier_at_Time_of_Placement__c);
               MyMatcher4 = MyPattern4.matcher(product.Value_Tier_at_Time_of_Placement__c);
            }
            if(MyMatcher2 != NULL){
                if(MyMatcher2.matches() == false || MyMatcher3.matches() == True || MyMatcher4.matches() == false){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Value tier at the time of placement.<br/>';
                    EXPECTED += 'Only alphabetical with/without special characters allowed.<br/>';
                }
            }
            
                     
            if(String.isNotBlank(newAgency) && mapProductName.containsKey(product.Data_Id__c)){
                if(String.isNotBlank(mapProductName.get(product.Data_Id__c).Collection_Sub_Status__c)){
                    String collectionSubStatus = mapProductName.get(product.Data_Id__c).Collection_Sub_Status__c;
                    if(collectionSubStatus == 'Credit Counselling'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                    }
                    /*else if(collectionSubStatus == 'Credit Counselling'){
ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
}*/
                    else if(collectionSubStatus == 'Cease and Desist â€“ In Writing'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Cease and Desist â€“ In Writing Collection Sub Status'+'<br/>';
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
                
                if(String.isNotBlank(mapProductName.get(product.Data_Id__c).Data_Status_Description__c)){
                    String dataStatus = mapProductName.get(product.Data_Id__c).Data_Status_Description__c;
                    if(dataStatus.contains('Closed')){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Closed Status'+'<br/>';    
                    }
                    else if(dataStatus.contains('Insolvency') || dataStatus.contains('Insolvent')){
                                //commented by tejal ERROR to WARNING
                                ERROR_MSG += '<b>ERROR</b> - '+'Product is Insolveny Status'+'<br/>';    
                            } 
                }
            }
             }

            Product_Staging__c productStaging = new Product_Staging__c();
            productStaging.Id = product.Id;
            productStaging.External_Id__c = product.Data_Id__c + '_' +documentStorageId;
            productStaging.Name__c = product.Data_Id__c;
            // Comment Changes - 19 Jan
            if(ERROR_MSG.length() > 254) {
                productStaging.Comment__c = ERROR_MSG.substring(0, 253);
            }else {
                productStaging.Comment__c = ERROR_MSG;
            }
            // Comment Changes - 19 Jan
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentStorageId;
            productStaging.Expected_Value__c = EXPECTED;
            productStaging.Placement_Status_Code__c = '100000';
            productStaging.Data_Status_Code__c = '300000';
            productStaging.Document_Storage__c = documentStorageId;
            productStaging.Is_Record_Process__c = true;
            if(mapProductName.containsKey(product.Data_Id__c)){
                if(mapProductName.get(product.Data_Id__c).Current_Principal_Balance__c != NULL){
                    productStaging.Current_Principal_Balance__c = mapProductName.get(product.Data_Id__c).Current_Principal_Balance__c ;       
                }
                if(mapProductName.get(product.Data_Id__c).Current_Interest_Amount__c != NULL){
                    productStaging.Current_Interest_Balance__c = mapProductName.get(product.Data_Id__c).Current_Interest_Amount__c;       
                }
                Decimal NSF = 0;
                if(mapProductName.get(product.Data_Id__c).Current_Bal_NSF_Fees__c != NULL){
                    NSF = mapProductName.get(product.Data_Id__c).Current_Bal_NSF_Fees__c;
                }
                if(mapProductName.get(product.Data_Id__c).Fee_Recovery__c != NULL){
                    productStaging.Fees__c = mapProductName.get(product.Data_Id__c).Fee_Recovery__c + NSF;        
                }
                /*if(mapProductName.get(product.Name).Commission_Adjustment__c != NULL){
commissionAdjustment = mapProductName.get(product.Name).Commission_Adjustment__c;
}*/
            }
            /*if(product.Pool_Name__r.Name != NULL ){
productStaging.Pool_Name__c = product.Pool_Name__r.Name;
}*/
            
            // Change 15 Jan
            if(mapProductName.containsKey(product.Data_Id__c)){
                //productStaging.Placement_Agency__c = String.valueOf(product.Collection_Agency__c);
                if(mapPlacement.containsKey(insertedProductStaging.get(product.Data_Id__c).Placement_Agency__c) && insertedProductStaging.get(product.Data_Id__c).Placement_Agency__c != null){
                    productStaging.Placement_Agency_ID__c = mapPlacement.get(insertedProductStaging.get(product.Data_Id__c).Placement_Agency__c).ID;    
                }
            }
            // Change 15 Jan
            
            if(mapProductName.containsKey(product.Data_Id__c)){
                productStaging.Product_ID__c = mapProductName.get(productStaging.Name__c).ID;
            }
            if(mapProductName.containsKey(product.Data_Id__c)){
                productStaging.Record_Type_ID__c = mapProductName.get(productStaging.Name__c).RecordTypeId;
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Commission_Rate_at_Time_of_Placement__c != NULL ){
                productStaging.Placed_Commission_Rate__c = mapProductName.get(product.Data_Id__c).Commission_Rate_at_Time_of_Placement__c;
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Commission_Rate__c != NULL ){
                productStaging.Current_Commission_Rate__c = mapProductName.get(product.Data_Id__c).Commission_Rate__c;
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Settlement_Rate__c != NULL ){
                productStaging.Current_Settlement_Rate__c = mapProductName.get(product.Data_Id__c).Settlement_Rate__c;
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Value_Tier_at_Time_of_Placement__c != NULL ){
                productStaging.Value_Tier_at_Time_of_Placement__c = mapProductName.get(product.Data_Id__c).Value_Tier_at_Time_of_Placement__c;
            }
            if(mapProductName.containsKey(product.Data_Id__c) && mapProductName.get(product.Data_Id__c).Placed_Settlement_Rate__c != NULL ){
                productStaging.Placed_Settlement_Rate__c = mapProductName.get(product.Data_Id__c).Placed_Settlement_Rate__c;
            }
            //productStaging.Pool_Name__c = String.valueOf(product.Pool_Name_Text__c);
            if(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c != NULL && mapPool.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c) != NULL){
                if(mapPool.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c) != null) {
                    productStaging.Pool_Name_ID__c = mapPool.get(insertedProductStaging.get(product.Data_Id__c).Pool_Name__c).ID;
                }
            }
            if(String.isBlank(ERROR_MSG)){
                productStaging.Comment__c = 'SUCCESS';
                productStaging.Include_in_Processing__c = true;
            }
            /*else{
productStaging.Comment__c = '';
productStaging.Include_in_Processing__c = true;
}
if(ERROR_MSG.contains('WARNING') && !ERROR_MSG.contains('ERROR ')){
productStaging.Include_in_Processing__c = true;
}*/

            listProductAllocateStaging.add(productStaging);
            ERROR_MSG = '';
            newAgency = '';
            oldAgency = '';
        }

        return listProductAllocateStaging;
    }
    
    //This method runs the validation for product recall process.
    public static list<Product_staging__c> recallValidationOnRecordUpdate(List<Product_Staging__c> batchScope,List<Product__c> listProduct, 
                                                                          map<String,Product__c> mapProduct, ID documentId,
                                                                          String workAssignmentPlacement/* ,map<String,String> mapFilingDate */,
                                                                          Document_Storage__c docStorage)
    {
   
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>();
        map<String, Judgment_product_codes_mapping__c> mapJudgment = Judgment_product_codes_mapping__c.getAll();
        map<String, Judgment_product_codes_mapping__c> mapJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();                                            
        for(Judgment_product_codes_mapping__c judgmentCodes : mapJudgment.values()){
            mapJudgmentCodes.put(judgmentCodes.Codes__c, judgmentCodes);
        }
        
        set<String> setRecentlyPaidProducts = new set<String>();
        setRecentlyPaidProducts = AccountStatusUpdateExcelFileProcessing.getProductPaymentDetails(mapProduct.keySet());
                
        for(Product_Staging__c product : batchScope){
            if(mapProductNameAmount.containsKey(String.valueOf(product.Name__c))){
                mapProductNameAmount.put(String.valueOf(product.Name__c), 
                                         mapProductNameAmount.get(product.Name__c)+1);
            }
            else{
                mapProductNameAmount.put(String.valueOf(product.Name__c), 1);
            }
        }
        
        list<Product_Staging__c> listAccStaging = new list<Product_Staging__c>();                                          
        Product_Staging__c accStaging = new Product_Staging__c();
        
        Map<String, Placement_Status_Code_Mapping__c> settings = Placement_Status_Code_Mapping__c.getAll();
        
        //Ticket 5081
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c, Product__r.Name FROM Account_Judgment__c
                                                  WHERE Product__r.name IN :mapProduct.keySet()
                                                  AND Status__c = 'Active']){
                mapProductJudgment.put(accJudgment.Product__r.Name, accJudgment.Judgment__c);
        }
        
        for(Product_Staging__c product : batchScope){
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';
            String newAgency = '';
            
            //Regex to check MM/DD/YYYY (text format in excel)
            String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4})$';
            //String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4}|[0-9]{2})$';
            
            //Regex to check YYYY/MM/DD (Date format in excel)
            String dateRegex2 = '^([0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
            
            String dateRegex3 = '^([0-9]{4}|[0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
            Pattern MyPattern3 = Pattern.compile(dateRegex3);
            
            
            
            Pattern MyPattern1 = Pattern.compile(dateRegex);
            
            Pattern MyPattern2 = Pattern.compile(dateRegex2);
            
            Matcher MyMatcher1;
            date myDate;
            // Added product.Status_Changed_Date__c.contains('-') to if loop part of Bug 4932
            if(String.isNotBlank(product.Status_Changed_Date__c) && (product.Status_Changed_Date__c.contains('/') || product.Status_Changed_Date__c.contains('-'))){
                MyMatcher1 = MyPattern1.matcher(product.Status_Changed_Date__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(product.Status_Changed_Date__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(product.Status_Changed_Date__c);
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                //matching of date when entered in Text format in excel file
                
                if(MyMatcher1.matches() == true || Test.isRunningTest()){
                    list<String> datelist =new list<String>();
                    //Added below IF loops  part of bug 4932
                    if(product.Status_Changed_Date__c.contains('/')){
                        datelist = product.Status_Changed_Date__c.split('/');
                    } 
                    if(product.Status_Changed_Date__c.contains('-')){
                        datelist = product.Status_Changed_Date__c.split('-');
                    }
                    myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    product.Status_Changed_Date_Text__c = myDate.month() + '/'+ myDate.day()+'/'+myDate.year();
                }
                //matching of date when entered in Date format in excel file  product.Status_Changed_Date__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist =new list<String>();
                    //Added below IF loops  part of bug 4932
                    if(product.Status_Changed_Date__c.contains('/')){
                        datelist = product.Status_Changed_Date__c.split('/');
                    } 
                    if(product.Status_Changed_Date__c.contains('-')){
                        datelist = product.Status_Changed_Date__c.split('-');
                    }                    
                    myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    //product.Status_Changed_Date__C = String.valueOf(myDate);
					product.Status_Changed_Date_Text__c = myDate.month() + '/'+ myDate.day()+'/'+myDate.year();                   
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist =new list<String>();
                    //Added below IF loops  part of bug 4932
                    if(product.Status_Changed_Date__c.contains('/')){
                        datelist = product.Status_Changed_Date__c.split('/');
                    } 
                    if(product.Status_Changed_Date__c.contains('-')){
                        datelist = product.Status_Changed_Date__c.split('-');
                    }
                    myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    //product.Status_Changed_Date__C = String.valueOf(myDate);
                   product.Status_Changed_Date_Text__c = myDate.month() + '/'+ myDate.day()+'/'+myDate.year(); 
                }
            }
            
             if(product.Data_Id__c == null && product.Name__c == null){
                 ERROR_MSG += '<b>ERROR</b> - Invalid account number.<br/>';
                 EXPECTED += 'Account number cannot be blank<br/>'; 
            }
            
            if(product.Data_Id__c != null || product.Name__c != null){
            //If user enters dd/mm/yyyy formate then shows the below error
            // Added product.Status_Changed_Date__c.contains('-') to if loop part of Bug 4932
            if(product.Status_Changed_Date__C != NULL && (product.Status_Changed_Date__C.contains('/') || product.Status_Changed_Date__C.contains('-'))){
                Integer statusChangedDate = Integer.valueOf(product.Status_Changed_Date_Text__c.substring(0,1));
                // Added product.Status_Changed_Date__c.contains('-') to if loop part of Bug 4932
                if(statusChangedDate > 12){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Status Changed date.<br/>';
                    EXPECTED += 'Status Changed Date should be in proper format.(MM/DD/YYYY or MM-DD-YYYY)<br/>'; // Added or MM-DD-YYYY as part of bug #4932
                }
            }
            if(!mapProduct.containsKey(product.Name__c)){
                ERROR_MSG += '<b>ERROR</b> : Account not found<br/>';
            }
            //Commented out the below IF Loop part of bug 4932
            //Invalid Status_Changed_Date__C
            //added validation for ticket 4469 - satyajit patil
           /*  if(product.Status_Changed_Date__C != null && product.Status_Changed_Date__C != '' && (!product.Status_Changed_Date__C.contains('/') || !product.Status_Changed_Date__C.contains('-'))){
                system.debug('If loop9--->'+product.Status_Changed_Date__C);
                system.debug('Incorrect Date');
                ERROR_MSG += '<b>ERROR</b> : Invalid status changed date.<br/>';
                    EXPECTED += 'Status Changed Date should be in proper format.(MM/DD/YYYY or MM-DD-YYYY)<br/>'; 
               
             }     */       
            if(product.Status_Changed_Date__C != NULL){
                if(myDate > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid date.<br/>';
                    EXPECTED += 'Status Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isBlank(product.Status_Changed_Date_Text__c)){
                    ERROR_MSG += '<b>ERROR</b> - Status Changed date cannot be blank.<br/>';
                    EXPECTED += 'Status Changed date cannot be blank<br/>';
                }
            } 
                
			//Ticket 5081: User cannot update status if product with judgment
            String placementStatus;
            if (mapProduct.containsKey(product.Name__c) && mapProduct.get(product.Name__c).Placement_Status__c!=NULL && mapProduct.get(product.Name__c).Placement_Status__c!=''){
                placementStatus=mapProduct.get(product.Name__c).Placement_Status__c;
            }
            if(docStorage != NULL /*&& docStorage.Uploaded_By__c == 'External User'*/ && mapProductJudgment.containsKey(product.Name__c) && (placementStatus!=NULL && placementStatus!='') && System.Label.Judgment_Codes.contains(placementStatus)){
                ERROR_MSG += '<b>ERROR</b> : Can\'t change account in Legal status<br/>';
                EXPECTED += 'User cannot update the status on Product with Judgment<br/>';
            }
            if(mapProduct.containsKey(product.Name__c)
               && mapProduct.get(product.Name__c).Collection_Agency__c != NULL){
                   newAgency = String.valueOf(Math.floor(mapProduct.get(product.Name__c).Collection_Agency__c));  
               }
            
            //Check Recall Validations
            if(setRecentlyPaidProducts.contains(product.Name__c)){
                ERROR_MSG += '<b>WARNING</b> - '+': Account had payment in last 2 months'+'<br/>';
            }
            
            if(mapProduct.containsKey(product.Name__c) 
                && mapProduct.get(product.Name__c).Placement_Status__c <> NULL){
                    if(System.Label.Exclude_Judgment_Codes.contains(mapProduct.get(product.Name__c).Placement_Status__c) && docStorage.Uploaded_By__c == 'External User'){
                        ERROR_MSG += '<b>ERROR</b> : Legal Status, cannot update from judgment code<br/>';
                    }
            }
            
            if(mapProduct.containsKey(product.Name__c)
               && String.isNotBlank(mapProduct.get(product.Name__c).Placement_Status__c)
               && String.isNotBlank(product.Placement_Status_Code__c)){
                   if(product.Placement_Status_Code__c.startsWith('9') 
                      && mapProduct.get(product.Name__c).Placement_Status__c.startsWith('8')){
                          if(product.Placement_Status_Code__c.subStringAfter('9') <> mapProduct.get(product.Name__c).Placement_Status__c.subStringAfter('8')){
                              ERROR_MSG += '<b>ERROR</b> :  Confirmation doesn’t match pending recall code<br/>';
                              EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name__c).Placement_Status__c+'.<br/>';
                          }
                      }
               }
            
            //Validation User can not update status from pending recall to any other status instead of confirm recall.
            if(mapProduct.containsKey(product.Name__c)
               && String.isNotBlank(mapProduct.get(product.Name__c).Placement_Status__c)
               && String.isNotBlank(product.Placement_Status_Code__c))
            {
                
                if(mapProduct.get(product.Name__c).Placement_Status__c.startsWith('8') && !product.Placement_Status_Code__c.startsWith('9') && docStorage != NULL /*&& docStorage.Uploaded_By__c == 'External User'*/){
                    ERROR_MSG += '<b>ERROR</b> : Pending recall cannot change to other status<br/>';
                    //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }
                
                //agency can not change from any other status to recall status.
                
                /*if(!mapProduct.get(product.Name__c).Placement_Status__c.startsWith('8') && product.Placement_Status_Code__c.startsWith('9') && docStorage != NULL && docStorage.Uploaded_By__c == 'External User'){
                    ERROR_MSG += '<b>ERROR</b> : Account not in pending recall status<br/>';
                    //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }*/
                
                //agency can not change status when refer to legal is in for review/main status is in pregal.
                //Ticket 6922: check product placement status present  in EXCLUDE_JUD_CODES
                if(mapProduct.get(product.Name__c).Status__c != null && !System.Label.Exclude_Judgment_Codes.contains(mapProduct.get(product.Name__c).Placement_Status__c)){
                    if((mapProduct.get(product.Name__c).Status__c.startsWith('Pre - Legal') && mapProduct.get(product.Name__c).Placement_Status__c != product.Placement_Status_Code__c) || (mapProduct.get(product.Name__c).Refer_to_Legal__c == 'For Review' && mapProduct.get(product.Name__c).Placement_Status__c != product.Placement_Status_Code__c)){
                        ERROR_MSG += '<b>ERROR</b> : Account in Refer to Legal status<br/>';
                        //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                    }
                }
                
            }
            if(docStorage != NULL && docStorage.Uploaded_By__c == 'External User'){
                if(product.Placement_Status_Code__c != Null && product.Placement_Status_Code__c.startsWith('8')){
                    ERROR_MSG += '<b>ERROR</b> : Status can not change from any other to recall status.<br/>';
                    //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }
                if(mapProduct.containsKey(product.Name__c)
                   && String.isNotBlank(mapProduct.get(product.Name__c).Placement_Status__c)
                   && String.isNotBlank(product.Placement_Status_Code__c)
                   && !(mapProduct.get(product.Name__c).Placement_Status__c.startsWith('8'))
                   && product.Placement_Status_Code__c.startsWith('9')){
                       ERROR_MSG += '<b>ERROR</b> : Account not in pending recall status<br/>';
                       EXPECTED += 'Account is not in Pending Recall Status' +'.<br/>'; 
                   }
                if(String.isnotblank(workAssignmentPlacement) 
                   && workAssignmentPlacement != newAgency 
                   && newAgency != '9999'){
                       ERROR_MSG += '<b>ERROR</b> : This account is not available in this Placement<br/>';
                       EXPECTED += 'Product Agency = ' +newAgency+'.<br/>';        
                   }
                /*else if(mapProduct.containsKey(product.Name)
&& (String.isBlank(newAgency) || newAgency == '9999')){
ERROR_MSG += '<b>ERROR</b> - Contact does not have permission to this account.<br/>';
EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 

} */  
                
            }
            
            if(mapProduct.containsKey(product.Name__c)
               && (String.isBlank(newAgency) || newAgency == '9999')){
                   ERROR_MSG += '<b>ERROR</b> - Account is already recalled.<br/>';
                   EXPECTED += '<br/>Product Agency = ' +newAgency+'.<br/>'; 
                   
               }  
            
            /*if(workAssignmentPlacement != newAgency && newAgency != '9999'){
ERROR_MSG += '<b>ERROR</b> - This account is not available in this Placement.<br/>';
EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 

}

else if(mapProduct.containsKey(product.Name)
&& (mapProduct.get(product.Name).Collection_Agency__c == NULL || mapProduct.get(product.Name).Collection_Agency__c == 9999)){
ERROR_MSG += '<b>ERROR</b> - Contact does not have permission to this account.<br/>';
EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 

}*/
            
            /*for(String ss : settings.keySet()){
}*/
            if(!settings.keySet().Contains(product.Placement_Status_Code__c)){
                ERROR_MSG += '<b>ERROR</b> : status code does not exist<br/>';
                EXPECTED += 'Invalid Status Code.'+'<br/>'; 
            }
            
            if(mapProductNameAmount.containsKey(product.Name__c )
               && mapProductNameAmount.get(product.Name__c) > 1){
                   ERROR_MSG += '<b>ERROR</b> - A duplicate transaction was found in this File Update.<br/>';    
               }
            
            if(mapProduct.containsKey(product.Name__c)
               && mapProduct.get(product.Name__c).Data_Status_Description__c != null
               && mapProduct.get(product.Name__c).Data_Status_Description__c.startswith('Closed')){
                   ERROR_MSG = '<b>ERROR</b> : Account is closed<br/>';
               }
            /*if(mapProduct.containsKey(product.Name)
&& mapProduct.get(product.Name).Status__c != null
&& mapProduct.get(product.Name).Status__c.startswith('Pending Recall')){
ERROR_MSG = '<b>ERROR</b> - Account in Pending Recall.<br/>';
}*/

                if(mapProduct.containsKey(product.Name__c) && mapProduct.get(product.Name__c).Assignment_Date__c <> null){
                    if(mapProduct.get(product.Name__c).Assignment_Date__c > myDate){    
                        ERROR_MSG += '<b>ERROR</b> : Status Date is less than account Placement Date<br/>';
                        EXPECTED += 'Status Date must be >= account Placement Date<br/>';
                    }
                    
                    /* //Added for ticket 4406 by satyajit
if(mapProduct.get(product.Name__c).Assignment_Date__c >= Date.valueOf(product.Status_Changed_Date__c) ||
(mapProduct.get(product.Name__c).Assignment_Date__c <= myDate && Date.valueOf(product.Status_Changed_Date__c) > myDate)){
ERROR_MSG += '<b>ERROR</b> : Invalid Status Date found. Must be after account Placement Date.<br/>';
EXPECTED += 'Status Date must be >= account Placement Date<br/>';  
}*/
                }
            
            //Added validation when account is in putback/buyback - developer: satyajit for ticket: 4377
            /* if(mapProduct.containsKey(product.Name__c) && mapProduct.get(product.Name__c).Purchase_Status__c != null){
            if(mapProduct.get(product.Name__c).Purchase_Status__c == 'Buyback/Putback Initiated' || mapProduct.get(product.Name__c).Purchase_Status__c == 'Buyback/Putback Approved'){
                ERROR_MSG += '<b>ERROR</b> : Account is in Buyback / Putback status<br/>';
            }
            } */
            }
            
            
            accStaging = new Product_Staging__c();
            // To do
            accStaging.Id = product.Id;
            accStaging.Data_Id__c = product.Name__c;
            accStaging.Placement_Agency__c = workAssignmentPlacement;
            accStaging.Comment__c = ERROR_MSG;
            if(accStaging.Comment__c.length() > 254){
                accStaging.Comment__c = accStaging.Comment__c.substring(0, 254);  
            }else{
                accStaging.Comment__c = accStaging.Comment__c;
            }
            accStaging.Status__c = 'Pending';
            accStaging.Identifier__c = documentId;
            accStaging.Document_Storage__c = documentId;
            //accStaging.Placement_Status_Code__c = product.Placement_Status_c;
            if(ERROR_MSG.contains('SUCCESS')){
                accStaging.Include_in_Processing__c = true; 
            }            
            
            if(mapProduct.containsKey(product.Name__c)){
                accStaging.Product_ID__c = mapProduct.get(product.Name__c).ID;
                accStaging.Placement_Agency_ID__c = mapProduct.get(product.Name__c).Collection_Agency_Placement__c;
            }
            
            if(settings.containsKey(product.Placement_Status_Code__c)){
                accStaging.Placement_Main_Status__c = settings.get(product.Placement_Status_Code__c).Parent_Status__c +' - ' +settings.get(product.Placement_Status_Code__c).Status__c;
                accStaging.Placement_Sub_Status__c = settings.get(product.Placement_Status_Code__c).Sub_Status__c;
            }
            if(product.Status_Changed_Date__c != null){
                accStaging.Status_Changed_Date__c = String.valueOf(product.Status_Changed_Date__c);
            }
            accStaging.Status_Changed_Date_Text__c = product.Status_Changed_Date_Text__c;
            
            /*else if(mapFilingDate.get(product.Name) != null){
accStaging.Status_Changed_Date__c = mapFilingDate.get(product.Name);
}*/
            if(String.isBlank(ERROR_MSG)){
                accStaging.Comment__c = 'SUCCESS';
                accStaging.Include_in_Processing__c = true; 
            }
            if(String.isNotBlank(EXPECTED)){
                accStaging.Expected_Value__c = EXPECTED;
            }
            listAccStaging.add(accStaging);
            ERROR_MSG = '';
        }

        return listAccStaging;
        
    }
    
    public static Set<String> getPlacementHistoryDetails(set<String> setProductName){
        set<String> setProductAgencyName = new set<String>();
        //Get Placement History for new Distressed Products
        for(Placement_History__c placementHistory : [SELECT ID, Placement__r.Name, Product__c, Product__r.Name
                                                     FROM Placement_History__c
                                                     WHERE Product__r.Name IN :setProductName
                                                     AND Placement_Recall_Date__c != null AND Placement_Recall_Date__c = LAST_N_DAYS:180 order by Placement_Recall_Date__c limit 45000 ]){
                                                         //Combine Product name + Placement Agency
                                                         setProductAgencyName.add(placementHistory.Product__r.Name + placementHistory.Placement__r.Name );   
                                                     }
        return setProductAgencyName;
    }
    
    //Created Document Storage record for Error and Success file and Update WorkAssignment Comment_Reply__c field 
    public static void postDocumentAPI(id documentID,id workAssignmentID, decimal successRecords,decimal failedRecords,set<string> failedStringSet,
                                       set<string> successStringSet,string failed, string success, list<Product_Staging__c> listproductstaging,String docType){
                                           Map<String,Object> rawObj;
                                           Map<String,Object> rawObj1;
                                           Blob fileBlob = Blob.valueOf(failed);
                                           //Failed CSV API Call
                                           DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
                                           if(test.isRunningTest()){
                                               Document_Storage__c dc= [select id from Document_Storage__c limit 1];
                                               documentID = dc.id;
                                               parsedResponse.docId=documentid;
                                               parsedResponse.DocUrl='google.com';
                                               parsedResponse.request='ssss';
                                               parsedResponse.response='{"data": [{"docId": "ooooa", "i": 1}]}';
                                               parsedResponse.response= parsedResponse.response.replace('ooooa',documentID);
                                           } 
                                           if(failedRecords > 0){ 
                                               if(!test.isRunningTest()){
                                                   if(docType == 'Account Status Update File'){
                                                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Account Status Failed.csv', 'Task');
                                                   }else{
                                                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Allocation Failed.csv', 'Task');
                                                   }
                                               }
                                               rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
                                           }
                                           //Success CSV API Call
                                           DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
                                           
                                           if(test.isRunningTest()){
                                               parsedResponse1.docId=documentid;
                                               parsedResponse1.DocUrl='google.com';
                                               parsedResponse1.request='ssss';
                                               parsedResponse1.response='{"data": [{"docId": "ooooa", "i": 1}]}';
                                               parsedResponse1.response= parsedResponse1.response.replace('ooooa',documentID);
                                           } 
                                           Blob fileBlobSuccess; 
                                           if(success != null){
                                               fileBlobSuccess = Blob.valueOf(success); 
                                               
                                               if(successRecords > 0){ 
                                                   if(!test.isRunningTest()){
                                                       parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Account Status Success.csv', 'Task');
                                                       
                                                   }
                                                   rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response); 
                                               }
                                           }
                                           
                                           //Create Failed CSV Document Storage
                                           Document_Storage__c failedDocStorage = new Document_Storage__c();
                                           DocumentStorageTriggerHandler.runDocumentStorageTrigger=false;
                                           Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
                                           if((null != parsedResponse && rawObj != NULL && String.isnotBlank(String.valueOf(rawObj.get('docId')))) || Test.isRunningTest()){
                                               failedDocStorage.Work_Assignment__c = workAssignmentID; 
                                               if(docType == 'Account Status Update File'){
                                                   failedDocStorage.Document_Name__c = 'Account Status Failed.csv';
                                               }else{
                                                   failedDocStorage.Document_Name__c = 'Product Allocation Failed.csv';
                                               }
                                               
                                               failedDocStorage.Document_Extension__c = 'csv'; 
                                               failedDocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
                                               if(docType == 'Account Status Update File'){
                                                   failedDocStorage.Document_Type__C = 'Account Status Processing File';
                                               }else{
                                                   failedDocStorage.Document_Type__C = 'Product Allocation Processing File';
                                               }
                                               failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
                                               failedDocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
                                               failedDocStorage.Uploaded_By__c = 'Internal User';
                                               failedDocStorage.Creator__c = UserInfo.getName();
                                               failedDocStorage.Document_Related_To__c = 'Task';
                                               failedDocStorage.File_Processed_By__c = UserInfo.getName();
                                               failedDocStorage.File_Processing_Date__c = Date.today();
                                               failedDocStorage.File_Processing_Status__c = 'Processed';
                                               insert failedDocStorage;
                                           } 
                                           
                                           //Create Success CSV Document Storage
                                           Document_Storage__c SuccessDocStorage = new Document_Storage__c();
                                           if(successRecords > 0){ 
                                               if(test.isRunningTest() || ( null != parsedResponse1 && rawObj1 != NULL && String.isnotBlank(String.valueOf(rawObj1.get('docId'))))){
                                                   
                                                   SuccessDocStorage.Work_Assignment__c = workAssignmentID; 
                                                   SuccessDocStorage.Document_Name__c = 'Account Status Success.csv';
                                                   SuccessDocStorage.Document_Extension__c = 'csv';
                                                   SuccessDocStorage.Document_ID__c = String.valueOf(rawObj1.get('docId'));
                                                   SuccessDocStorage.Document_Type__C = 'Account Status Update File';
                                                   SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
                                                   SuccessDocStorage.Document_URL__c = String.valueOf(rawObj1.get('docUrl'));
                                                   SuccessDocStorage.Uploaded_By__c = 'Internal User';
                                                   SuccessDocStorage.Creator__c = UserInfo.getName();
                                                   SuccessDocStorage.Document_Related_To__c = 'Task';
                                                   SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
                                                   SuccessDocStorage.File_Processing_Date__c = Date.today();
                                                   SuccessDocStorage.File_Processing_Status__c = 'Processed';
                                                   insert SuccessDocStorage;
                                               }
                                           }                             
                                           Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
                                           update docStorageToUpdate;
                                           
                                           DateTime dT = System.now();
                                           
                                           String oldComments = '';
                                           Work_Assignment__c workAssignment = [select id,name,title__c,Created_By__c,Status__c,Latest_Comment__c,Comments_History__c,Comment_Reply__c from Work_Assignment__c where id = : workAssignmentID];
                                           workAssignment.Status__c = 'Completed';
                                           if(failedRecords > 0){
                                               workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
                                           }else{
                                               workAssignment.Comment_Reply__c = 'No. of Records Failed: 0'+'\n';
                                           }
                                           if(successRecords > 0){
                                               workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
                                           }else{
                                               workAssignment.Comment_Reply__c += 'No. of Records Succeeded: 0';
                                           }
                                           if(workAssignment.Comments_History__c !=null){
                                               oldComments = workAssignment.Comments_History__c;
                                           }
                                           workAssignment.Latest_Comment__c = workAssignment.Comment_Reply__c;
                                            //bug:4743 : changes starts
                                           workAssignment.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' +' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
                                            //bug:4743 : changes ends
                                           if(oldComments != null){
                                               workAssignment.Comments_History__c += oldComments;
                                           }
                                           
                                           workAssignment.Comment_Reply__c = '';
                                           
                                           WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                                           update workAssignment;
                                           WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
                                           
                                           DocumentStorageTriggerHandler.runDocumentStorageTrigger=true;
                                           
                                           if(!Test.isRunningTest()){
                                               //CFG_EmailNotification.sendEmailNotificationOnErrorFile(workAssignment.Created_By__c,workAssignment.Latest_Comment__c,workAssignment.name,workAssignment.title__c,workAssignment.id);
                                           }
                                       } 
   
     //Added for ticket 4518 - satyajit (Product update is failed at the time of payment processing then creating the error file)
     public Static void GenerateSuccessAndErrorFile(List<Database.SaveResult> errResult,Id workAssignment,Id documentStorage, set<Id> prodIdList){          
        String failed;  
        //Integer failedRecords = 0; 
        failed = 'data_id,Error';    
        
            List<Product__c> prodDataList = new List<Product__c>();
            Map<Id, String> prodName = new Map<Id, String>();
            if(prodIdList != null){
                
               prodDataList = [Select id,name from product__c where id IN: prodIdList]; 
            }
            if(!prodDataList.isEmpty()){
                for(Product__c prod : prodDataList){
                    prodName.put(prod.id,prod.Name);
                } 
            }   
            
        for(Database.SaveResult res : errResult){
            failed += '\n';
            failed += '"'+prodName.get(res.getId())+'","'+res.getErrors() +'"\n';
                
            
            //failedRecords = failedRecords + 1;
        }
        Integer prodSatgingCount = [select count() from product_payment_staging__c where identifier__c  =: documentStorage]; 
       	system.enqueueJob(new PostDocumentAPI('Product Payment Upload File',failed,'',prodSatgingCount,0,workAssignment,'CFG + Requesting Agency',documentStorage));                                              
      
        }
    
}