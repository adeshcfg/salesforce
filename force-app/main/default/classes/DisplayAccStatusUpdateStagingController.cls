/**************************************************************************************************
    *
    *  Class:   
    *
    *  @description : Controller class to display Product records from Staging and create success
    *                  and failure files for status updates
    *  @author : A5E Consulting
    *  @date : 08/02/2022

    *************************************************************************************************/
    
    public class DisplayAccStatusUpdateStagingController {
       // Set <String> failedStringSet = new Set <String>();
        //Set <String> successStringSet = new Set <String>();
        public transient list<Product_Staging__c> listAccountStaging {get;set;}
        public transient list<productStagingWrapper> listProductStagingWrapper;
        public Integer pageNumber{get;set;}    
        public static final String PROCESSED = 'Processed';
        public static final String ERROR = 'ERROR';
        public static final String SUCCESS_STR = 'SUCCESS';
        public static final String FAILED_STR = 'FAILED';
        List<id> prodIdList;
        
        public boolean showButton {get;set;}
        public boolean displayPanel {get;set;}
        public Id workAssignmentId{get;set;}
        public Decimal successRecords;
        public Decimal failedRecords;
        String placementAgency = '';
        
        Id documentID;
        public static final Integer PAGE_SIZE = 20;
        Map<Id, productStagingWrapper> mapHoldingSelectedRecords = new Map<Id, productStagingWrapper>();
        public boolean isSelected{get;set;}
        private  List<Product_Staging__c> listAccountStagingNew = new List<Product_Staging__c>();
        Set<Product_Staging__c> accountStagingSet = new Set<Product_Staging__c>();
        public List<Product_Staging__c> prodList;
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        Set<Id> uncheckedProdAccSet = new Set<Id>();
        public Map<Id, String> PlacementStatus= new Map<Id, String>();
        /** Instantiate the StandardSetController from a query locater*/
        public ApexPages.StandardSetController setCon {
            get {
                system.debug('CPU Time1**' + Limits.getCpuTime());    
                system.debug('Inside setcon**');
                if(setCon == null) {
                    setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT ID,Name, Product_Status__c,Name__c,Status__c, Document_Storage__c,Placement_Status_Code__c,
                                                                                           Status_Changed_Date__c,Comment__c, Document_Storage__r.Work_Assignment_Identifier__c, Placement_Agency__c,
                                                                                           Document_Storage__r.Work_Assignment__c,Product_ID__c,Document_Storage__r.File_Processing_Status__c,
                                                                                            Placement_Agency_ID__c, Status_Changed_Date_Text__c//,Placement_Main_Status__c, Placement_Sub_Status__C
                                                                                           FROM Product_Staging__c
                                                                                           WHERE Identifier__c = :recordIdentfier limit 6000                                                                                           
                                                                                          ]));
                    // sets the number of records to show in each page view
                    setCon.setPageSize(PAGE_SIZE);
                }
                system.debug('CPU Time2**' + Limits.getCpuTime());    
                return setCon;
            }
            set;
        }
        
        public DisplayAccStatusUpdateStagingController(){
            system.debug('Inside FixController**');
            
            list<Product_Staging__c> prodstglist = [SELECT ID,Name,Status_Changed_Date_Text__c 
                                                    FROM Product_Staging__c WHERE Identifier__c = :recordIdentfier
                                                    And status__c= :PROCESSED
                                                    limit 1];
                 
            
            if(prodstglist.size()>0){
                  showButton = true;
                displayPanel = true;  
                }else{
                    showButton = false;
                    displayPanel = false;
                }
            
            system.debug('Block run1');
            
        }
        
        
        public List<productStagingWrapper> getlistProductStagingWrapper(){
            Integer successRecCount = 0;
            //List<id> errorRecs = new List<Id>();
            listAccountStaging = (List<Product_Staging__c>)setCon.getRecords();
             if(listAccountStaging.isEmpty()){
                displayPanel = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Payments to display'));
            }
            else{
                listProductStagingWrapper = new list<productStagingWrapper>();
               if (isSelected == true || Test.isRunningTest()) {
                    for(Product_Staging__c accStaging : listAccountStaging){
                        Boolean showMessage = false;
                        
                        Product_Staging__c accStaging1 = new Product_Staging__c();
                            accStaging1.Id = accStaging.Id;
                            accStaging1.Name__c = accStaging.Name__c;
                            accStaging1.Placement_Status_Code__c = accStaging.Placement_Status_Code__c;
                            accStaging1.Status_Changed_Date_Text__c = accStaging.Status_Changed_Date_Text__c;
                            accStaging1.Comment__c = accStaging.Comment__c;
                            accStaging1.Status__c = accStaging.Status__c;
                            accStaging1.Product_ID__c = accStaging.Product_ID__c;
                        if(accStaging.Comment__c.contains(ERROR)) {
                            listProductStagingWrapper.add(new productStagingWrapper(accStaging1, true));
                        } else {
                            listProductStagingWrapper.add(new productStagingWrapper(accStaging1, false));
                        }
                        if(accStaging.Status__c != PROCESSED && !accStaging.Comment__c.contains(ERROR)){
                            successRecCount++;
                            //showButton = true;
                        } 
                        if (successRecCount > 0) {
                            showButton = true;
                        } else {
                            //errorRecs.
                            showButton = false;
                        }
                        /*else {
                           showButton = false;
                       }*/
                    }
                    for(productStagingWrapper psw : listProductStagingWrapper) {
                        if(psw.accStaging.Status__c != PROCESSED && !uncheckedProdAccSet.contains(psw.accStaging.id)) {
                            psw.selected = true;
                        }
                        if(!Test.isRunningTest()){
                            if(psw.accStaging.Status__c != PROCESSED && psw.accStaging.comment__c.contains(ERROR)){
                                psw.selected = false;
                                
                            } 
                        }
                        
                    }
                } else {
                   for(Product_Staging__c accStaging : listAccountStaging){
                       Boolean showMessage = false;
                        Product_Staging__c accStaging2 = new Product_Staging__c();
                        accStaging2.Id = accStaging.Id;
                        accStaging2.Name__c = accStaging.Name__c;
                        accStaging2.Placement_Status_Code__c = accStaging.Placement_Status_Code__c;
                        accStaging2.Status_Changed_Date_Text__c = accStaging.Status_Changed_Date_Text__c;
                        accStaging2.Comment__c = accStaging.Comment__c;
                        accStaging2.Status__c = accStaging.Status__c;
                        accStaging2.Product_ID__c = accStaging.Product_ID__c;
                       if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(accStaging.id)){

                           if(accStaging.Comment__c.contains(ERROR)) {
                               mapHoldingSelectedRecords.get(accStaging.id).disabled = true;
                           }
                           mapHoldingSelectedRecords.get(accStaging.id).accStaging = accStaging2;
                           listProductStagingWrapper.add(mapHoldingSelectedRecords.get(accStaging.id));
                       }
                        else{
                            if(accStaging.Comment__c.contains(ERROR)) {
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging2, true));
                            } else {
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging2, false));
                            }
                        }
                    
                    
                       if(accStaging.Status__c != PROCESSED && !accStaging.Comment__c.contains(ERROR)){
                           successRecCount++;
                       } 
                   } 
                    if (successRecCount > 0) {
                        showButton = true;
                    } else {
                           //errorRecs.
                           showButton = false;
                    }
                }
                
                
                placementAgency = listAccountStaging[0].Placement_Agency__c;
                documentID = listAccountStaging[0].Document_Storage__c;
                List<Product_Staging__c> prodStagingPending = [SELECT ID FROM Product_Staging__c where Identifier__c=: recordIdentfier and status__c= 'Pending' LIMIT 1];
                if(showButton == false && prodStagingPending.size()==0){
                //if(prodStagingPending.size()==0){
                    //showButton == false;
                    if(listAccountStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){                    
                        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
                    }
                    else{
                        showButton = false;
                    }
                }
                
            }
            
            pageNumber = setCon.getPageNumber();
            return listProductStagingWrapper;
        }
        
        public pageReference Save(){
            system.debug('@@isSelected Save '+isSelected);
            prodIdList=new List<Id>();
            if (isSelected == true) {
              saveAllRecords();  
            } else {
               saveSelectiveRecords(); 
            }
            return null;
        }
        
        public PageReference saveSelectiveRecords() {
            list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
            Set<String> productNames = new Set<String>();
            String placementIdentifier = '9999';
            String ALLOCATED = '300000';
            String Product_Placement_Status = '';
            String poolName = '';
            set<string> failedStringSet = new set<string>();
            Set <String> successStringSet = new Set <String>();
            list<Product__c> listProd = new list<Product__c>();
            
            //Create Success and Failure file headers
            String success = 'data_id,status_code,status_date,success';
            String failed = 'data_id,status_code,status_date,error';
            
            Map<Id,Product_Staging__c> prodStagingMap = new Map<Id,Product_Staging__c>(getAllRecords());
            updateSearchItemsMap();
            //Get warehouse placement ID
            Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
            
            //Get Placement ID
            transient list<Placement__c> listPlacements = [SELECT ID FROM Placement__c WHERE Name= :placementAgency LIMIT 1];
            Id placementID;
            if(!listPlacements.isEmpty()){
                placementID = listPlacements[0].ID;
            }
            successRecords = 0;
            failedRecords = 0;
            List<Id> listProdIds = new List<Id>();
            Set<Id> setProductIDs = new Set<Id>();
            transient List<Product_Staging__c> psAllRec = getAllRecords();
            transient map<String, Placement_Status_Code_Mapping__c> codeMapping = new map<String, Placement_Status_Code_Mapping__c>();
            for(Placement_Status_Code_Mapping__c mapping : [SELECT ID, Name, Data_Status_Code__c, Data_Status_Description__C
                                                            FROM Placement_Status_Code_Mapping__c
                                                            /*WHERE Name LIKE : '9%'*/]){
                                                                codeMapping.put(mapping.Name, mapping);
                                                            }
            transient map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
            for(Product_Staging__c prodStagingWrapper1 : psAllRec){
                  setProductIDs.add(prodStagingWrapper1.Product_ID__c);  
            }
            system.debug('setProductIDs::'+setProductIDs);
            map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, Collection_Agency_Placement__c, Placement_Status__c,
                                                                   Current_Principal_Balance__c, Current_Interest_Amount__c,
                                                                   Interest_Rate__c, Current_Bal_NSF_Fees__c, Current_Bal_Attorney_Fees__c,
                                                                   Current_Bal_General_Fees__c, Current_Bal_Other_Fees__c,Assignment_Date__c,
                                                                   Current_Bal_Court_Fees__c, Collection_Agency_Placement__r.Commission_Rate__c,Pool_name__r.Commission_rate__c,
                                                                   Allocated_Amount_Total__c,Pool_Name__r.Name,Commission_Rate__c,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                                                                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Current_Balance__c
                                                                   FROM Product__c WHERE ID IN :setProductIDs]);
            for(productStagingWrapper prodStagingWrapper : mapHoldingSelectedRecords.values()){
                Product_Staging__c accStaging= new Product_Staging__c();
                accStaging = prodStagingMap.get(prodStagingWrapper.accStaging.id);
                system.debug('accStaging::'+accStaging);
                String comment = '';
                if(String.isNotBlank(accStaging.Comment__c)){
                    comment = accStaging.Comment__c;
                }
              if (prodStagingWrapper.selected == true || Test.isRunningTest()){
                        for (Product_Staging__c accStageRec : listAccountStaging) {
                            if (accStageRec.id == prodStagingWrapper.accStaging.id) {
                                accStageRec.Status__c = PROCESSED;
                                break;
                            }
                        }
                       accStaging.Status__c = PROCESSED;
                       Product__c prod = new Product__c();
                       prod.id = accStaging.Product_ID__c;
                       prod.Placement_Status__c = accStaging.Placement_Status_Code__c;
                       prod.Status__c = accStaging.Placement_Main_Status__c;
                       prod.Sub_Status__c = accStaging.Placement_Sub_Status__c;
                       prod.Status_Changed_Date__c = Date.valueOf(accStaging.Status_Changed_Date__c);
                       //prod.Collection_Agency_Placement__c = placementID;
                       if(accStaging.Product_ID__c!=null)listProdIds.add(accStaging.Product_ID__c);
                       if(String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('9') || Test.isRunningTest()){
                           if(codeMapping.containsKey(prod.Placement_Status__c)){
                               if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                   prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                   prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                               }
                           }
                           
                           prod.Placement_Status__c = null;
                           prod.Status__c = null;
                           prod.Sub_Status__c = null;   
                           //prod.Collection_Sub_Status__c = null; Rasmitha : 27-Dec as per #4177 Collection Sub Status should not get blank on recall
                           prod.External_Status_Current__c = null;
                           prod.Collection_Agency__c = 9999;
                           prod.Collection_Agency_Placement__c = placement.id;
                           prod.Recalled_Date__c = Date.today();
                           prod.External_Status_Current__c = null;
                           system.debug('prod.Assignment_Date__c'+prod.Assignment_Date__c);
                           
                           //productNames += accStaging.Name__c + ',';
                           productNames.add(accStaging.Name__c );
                           //Create Placement History
                           if(!accStaging.Comment__c.contains('ERROR')){
                               /*Placement_History__c placementHistory = new Placement_History__c();
                               placementHistory.Product__c = prod.id;
                               placementHistory.Placement__c =  accStaging.Placement_Agency_ID__c;    
                               placementHistory.Placement_Recall_Date__c = Date.today();
                               if(mapProduct.ContainsKey(accStaging.Product_ID__c) &&
                                  mapProduct.get(accStaging.Product_ID__c).Assignment_Date__c != NULL){
                                      placementHistory.Placement_Date__c = mapProduct.get(accStaging.Product_ID__c).Assignment_Date__c;
                                }
                               //placementHistory.Placement_Date__c = prod.Assignment_Date__c;
                               system.debug('placementHistory.Placement_Date__c'+placementHistory.Placement_Date__c);
                               placementHistory.Placement_Status__c = prod.Placement_Status__c;
                               if(placementStatusMap.containsKey( placementHistory.Placement_Status__c)){
                                   placementHistory.Placement_Status_Description__c = placementStatusMap.get( placementHistory.Placement_Status__c).Description__c;    
                               }
                               placementHistory.Current_Principal_Balance__c = mapProduct.get(accStaging.Product_ID__c).Current_Principal_Balance__c;
                               placementHistory.Current_Interest_Balance__c = mapProduct.get(accStaging.Product_ID__c).Current_Interest_Amount__c;
                               placementHistory.Interest_Rate__c = mapProduct.get(accStaging.Product_ID__c).Interest_Rate__c;
                               placementHistory.NSF_Fees__c = mapProduct.get(accStaging.Product_ID__c).Current_Bal_NSF_Fees__c;
                               placementHistory.Current_Bal_Attorney_Fees__c = prod.Current_Bal_Attorney_Fees__c;
                               placementHistory.Current_Bal_General_Fees__c = prod.Current_Bal_General_Fees__c;
                               placementHistory.Current_Bal_Other_Fees__c = prod.Current_Bal_Other_Fees__c;
                               placementHistory.Current_Bal_Court_Fees__c = prod.Current_Bal_Court_Fees__c;
                               placementHistory.Commission_Rate__c = mapProduct.get(accStaging.Product_ID__c).Collection_Agency_Placement__r.Commission_Rate__c;
                               placementHistory.Pool_Commission_Rate__c = mapProduct.get(accStaging.Product_ID__c).Pool_Name__r.Commission_Rate__c;
                               placementHistory.Product_Commission_Rate__c = mapProduct.get(accStaging.Product_ID__c).Commission_Rate__c;
                               placementHistory.Pool_ID__c = mapProduct.get(accStaging.Product_ID__c).Pool_Name__r.Name;
                               placementHistory.Allocated_Balance__c = mapProduct.get(accStaging.Product_ID__c).Allocated_Amount_Total__c;
                               placementHistory.Placed_Commission_Rate__c = mapProduct.get(accStaging.Product_ID__c).Commission_Rate_at_Time_of_Placement__c;
                                placementHistory.Value_Tier_at_Placement__c = mapProduct.get(accStaging.Product_ID__c).Value_Tier_at_Time_of_Placement__c;
                                placementHistory.Placed_Settlement_Rate__c = mapProduct.get(accStaging.Product_ID__c).Placed_Settlement_Rate__c;
                                placementHistory.Recoverable_fee_balance__c = mapProduct.get(accStaging.Product_ID__c).Recoverable_Fee__c;
                                placementHistory.Non_recoverable_fee_balance__c = mapProduct.get(accStaging.Product_ID__c).Non_Recoverable_Fee__c;
                                placementHistory.Placement_Status_at_time_of_recall__c = mapProduct.get(accStaging.Product_ID__c).Placement_Status__c;
                               placementHistory.Total_Balance_at_Placement__c = mapProduct.get(accStaging.Product_ID__c).Current_Balance__c;
                               listPlacementHistory.add(placementHistory);*/
                               PlacementStatus.put(prod.id,accStaging.Placement_Status_Code__c);
                               if(!Test.isRunningTest()){
                                   prodIdList.add(prod.id);
                               }
                               
                               //DistressedUtilities.updatePlacementHistory(prod.id,mapProduct.get(accStaging.Product_ID__c).Placement_Status__c);
                           }
                       }
                       if((String.isNotBlank(prod.Placement_Status__c) &&  prod.Placement_Status__c.startsWith('8')) || Test.isRunningTest()){
                           if(codeMapping.containsKey(prod.Placement_Status__c)){
                               if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                   prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                   prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                                   prod.External_Status_Current__c = null;
                               }
                           }
                       }
                       
                    if(accStaging.Comment__c=='SUCCESS' || accStaging.Comment__c.contains('WARNING')){
                       successStringSet.add(accStaging.Name__c+','+accStaging.Placement_Status_Code__c+','
                           + '"'+(accStaging.Status_Changed_Date__c!= null ? accStaging.Status_Changed_Date__c : NULL)+'"'+','+SUCCESS_STR);
                       successRecords = successRecords + 1;
                         accountStagingSet.add(accStaging);
                        listProd.add(prod);
                    }
                  
                  string CommentError;
                    if(accStaging.Comment__c!= 'SUCCESS' && accStaging.Comment__c.contains('ERROR')){
                    CommentError = accStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                    failedRecords = failedRecords + 1;
                    failedStringSet.add(accStaging.Name__c+','+accStaging.Placement_Status_Code__c+','
                        + '"'+(accStaging.Status_Changed_Date__c!= null ? accStaging.Status_Changed_Date__c : NULL)+'"'+','+(accStaging.comment__c!= null ? CommentError : Null));
                    
                  }
                  
                      
                 }
                
            }
            for(Product_Staging__c prodStagingWrapperFailed : getAllRecords()) {          
                if (!(mapHoldingSelectedRecords.containsKey(prodStagingWrapperFailed.id) || prodStagingWrapperFailed.Status__c == PROCESSED)) {
                    String CommentError;
                    if(prodStagingWrapperFailed.Comment__c!= null){
                    CommentError = prodStagingWrapperFailed.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                }
                    failedStringSet.add(prodStagingWrapperFailed.Name__c+','+prodStagingWrapperFailed.Placement_Status_Code__c+','
                        + '"'+(prodStagingWrapperFailed.Status_Changed_Date__c!= null ? prodStagingWrapperFailed.Status_Changed_Date__c : NULL)+'"'
                                +','+(prodStagingWrapperFailed.Comment__c!= null ? CommentError : NULL));
                    failedRecords = failedRecords + 1;
                }

            }
             ProductTriggerHandler.runProductTrigger = false;
             Database.executeBatch(new PortalProductStatusBulkAPIBatch(documentID,null, 
                                             workAssignmentID,successRecords,failedRecords,failedStringSet,
                                           successStringSet,true,null,null,null),1);  
           Database.executeBatch(new ProcessRecordsBatchClass(listProd,listProdIds,false),150); 
            if(!Test.isRunningTest()){
                PortalProductStatusBulkAPI.processBulkProductsForPagination(productNames, Product_Placement_Status, ALLOCATED, String.valueOf(Date.today()), 
                                                               'Recall',placementIdentifier, poolName);    
            }
             if (listProdIds.size() > 0 && !Test.isRunningTest()) {
                // PortalProductProcessingAPI.processProductBulkBatch(listProdIds);
              // Database.executeBatch(new PortalProductProcessingBatch(listProdIds), 40); 
            }
             
            PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
            system.debug('plistPlacementHistory'+listPlacementHistory);
             if(!Test.isRunningTest()){
            //DistressedUtilities.updatePlacementHistory_New(prodIdList,mapProduct,PlacementStatus);
            }
             //Reject active settlement when product is recall
              if(!Test.isRunningTest()){
            DistressedUtilities.UpdateSettlement(prodIdList);
            }
            //insert listPlacementHistory;
            PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
            
            ProductTriggerHandler.runProductTrigger = true; 
            
            //Create Task record and assign it to Agency
            //Update the existing Task record (as per new req) 
            Work_Assignment__c workAssignment = new Work_Assignment__c();
            workAssignment.ID = listAccountStaging[0].Document_Storage__r.Work_Assignment__c;
            workAssignmentId = workAssignment.Id;
            workAssignment.Comment_Reply__c = '';
            workAssignment.Status__c = 'Completed';
            if(failedRecords > 0){
                workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
            }
            if(successRecords > 0){
                workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
            }            
            //bug:4743 : changes starts
            WorkAssignmentTriggerHandler.updateCommentHistoryField=FALSE;
            //bug:4743 : changes ends       
            update workAssignment;        
            WorkAssignmentTriggerHandler.updateCommentHistoryField=TRUE;//Added part of bug #4743
            ProductTriggerHandler.runProductAPI = false;
            List<Product_Staging__c> accStagingLists = new List<Product_Staging__c>(accountStagingSet);
            if(accStagingLists.size()>0){
            update accStagingLists;
            }
            ProductTriggerHandler.runProductAPI = true;
            
            
            //update new Work_Assignment__c(Id = listAccountStaging[0].Document_Storage__r.Work_Assignment__c, 
            //                              Status__c = 'Completed');
            
            showButton = true;
            displayPanel = true;
            PageReference pr = new PageReference('/apex/DisplayAccountStatusUpdateStaging?id='+recordIdentfier+'&processed=true');
            pr.setRedirect(true);
            return pr;
        }
        
        public PageReference saveAllRecords() {
            system.debug('inside saveAllRecords');
            String success;
            String failed;
            set<string> failedStringSet = new set<string>();
            Set <String> successStringSet = new Set <String>();
            list<Product__c> listProd = new list<Product__c>();
            list<productStagingWrapper> listProductStagingWrapperFailedRecords = new list<productStagingWrapper>();
            list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
            set<String> setProdutNames = new set<String>();
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            Set<String>productNames = new Set<String>();
            String placementIdentifier = '9999';
            String ALLOCATED = '300000';
            String Product_Placement_Status = '';
            String poolName = '';
            //Create Success and Failure file headers
            success = 'data_id,status_code,status_date,success';
            failed = 'data_id,status_code,status_date,error';

            updateSet(); 
            transient List<Product_Staging__c> psAllRec = getAllRecords();
            List<Product_Staging__c> removedProductStagingList = new List<Product_Staging__c>();
            transient List<Integer> indexes = new List<Integer>();
            for(Integer i = 0; i < psAllRec.size(); i++){
                if (uncheckedProdAccSet.contains(psAllRec[i].id)) {
                    indexes.add(i);
                }
            }
            for(Integer i = 0; i < indexes.size(); i++){
                if(i==0){
                    removedProductStagingList.add(psAllRec.remove(indexes[i]));
                }
                else{
                    indexes[i] = indexes[i]-i;
                    removedProductStagingList.add(psAllRec.remove(indexes[i]));

                }
                
            }
            
            //Get warehouse placement ID
            Placement__c placement = [SELECT ID, Name
                   FROM Placement__c WHERE Name= :'9999' limit 1];
            
            //Get Placement ID
            list<Placement__c> listPlacements = [SELECT ID FROM Placement__c WHERE Name= :placementAgency LIMIT 1];
            Id placementID;
            if(!listPlacements.isEmpty()){
                placementID = listPlacements[0].ID;
            }
            successRecords = 0;
            failedRecords = 0;
            List<Id> listProdIds = new List<Id>();
            set<id> setProductIDs = new set<id>();
            map<String, Placement_Status_Code_Mapping__c> codeMapping = new map<String, Placement_Status_Code_Mapping__c>();
            for(Placement_Status_Code_Mapping__c mapping : [SELECT ID, Name, Data_Status_Code__c, Data_Status_Description__C
                                                            FROM Placement_Status_Code_Mapping__c
                                                            ]){
                                                                codeMapping.put(mapping.Name, mapping);
                                                            }
            map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
            for(Product_Staging__c prodStagingWrapper1 : psAllRec){
                  setProductIDs.add(prodStagingWrapper1.Product_ID__c);  
            }
            map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, Collection_Agency_Placement__c, Placement_Status__c,
                                                                   Current_Principal_Balance__c, Current_Interest_Amount__c,
                                                                   Interest_Rate__c, Current_Bal_NSF_Fees__c, Current_Bal_Attorney_Fees__c,
                                                                   Current_Bal_General_Fees__c, Current_Bal_Other_Fees__c,Assignment_Date__c,
                                                                   Current_Bal_Court_Fees__c, Collection_Agency_Placement__r.Commission_Rate__c,Pool_name__r.Commission_rate__c,
                                                                   Allocated_Amount_Total__c,Pool_Name__r.Name,Commission_Rate__c,Commission_Rate_at_Time_of_Placement__c,Value_Tier_at_Time_of_Placement__c,
                                                                   Placed_Settlement_Rate__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Current_Balance__c
                                                                   FROM Product__c WHERE ID IN :setProductIDs]);
            for(Product_Staging__c prodStagingWrapper : psAllRec){
            
                String comment = '';
                if(String.isNotBlank(prodStagingWrapper.Comment__c)){
                    comment = prodStagingWrapper.Comment__c;
                }
                if (prodStagingWrapper.Status__c == 'Pending' || Test.isRunningTest()){
                        for (Product_Staging__c accStageRec : listAccountStaging) {
                            if (accStageRec.id == prodStagingWrapper.id) {
                                accStageRec.Status__c = PROCESSED;
                                break;
                            }
                        }
                    system.debug('prodStagingWrapper'+prodStagingWrapper);
                       prodStagingWrapper.Status__c = PROCESSED;
                       Product__c prod = new Product__c();
                       prod.id = prodStagingWrapper.Product_ID__c;
                       prod.Placement_Status__c = prodStagingWrapper.Placement_Status_Code__c;
                       prod.Status__c = prodStagingWrapper.Placement_Main_Status__c;
                       prod.Sub_Status__c = prodStagingWrapper.Placement_Sub_Status__c;
                       prod.Status_Changed_Date__c = Date.valueOf(prodStagingWrapper.Status_Changed_Date__c);
                       //prod.Collection_Agency_Placement__c = placementID;
                    if(prodStagingWrapper.Product_ID__c!=null)
                       listProdIds.add(prodStagingWrapper.Product_ID__c);
                       if(String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('9') || Test.isRunningTest()){
                           if(codeMapping.containsKey(prod.Placement_Status__c)){
                               if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                   prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                   prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                               }
                           }
                           
                           prod.Placement_Status__c = null;
                           prod.Status__c = null;
                           prod.Sub_Status__c = null;   
                           //prod.Collection_Sub_Status__c = null; Rasmitha : 27-Dec as per #4177 Collection Sub Status should not get blank on recall
                           prod.External_Status_Current__c = null;
                           prod.Collection_Agency__c = 9999;
                           system.debug('prod.Collection_Agency__c '+prod.Collection_Agency__c);
                           prod.Collection_Agency_Placement__c = placement.id;
                           prod.Recalled_Date__c = Date.today();
                           prod.External_Status_Current__c = null;
                           //system.debug('prod.Assignment_Date__c::'+prod.Assignment_Date__c);
                           //system.debug('prod.Assignment_Date__c::'+mapProduct.get(prodStagingWrapper.Product_ID__c).Assignment_Date__c);
                           //;
                           system.debug('prod.name::'+prod.name); 
                           productNames.add(prodStagingWrapper.Name__c);
                           //Create Placement History
                           if(!prodStagingWrapper.Comment__c.contains('ERROR')){
                               /*Placement_History__c placementHistory = new Placement_History__c();
                               placementHistory.Product__c = prod.id;
                               placementHistory.Placement__c =  prodStagingWrapper.Placement_Agency_ID__c;    
                               placementHistory.Placement_Recall_Date__c = Date.today();
                               if(mapProduct.ContainsKey(prodStagingWrapper.Product_ID__c) &&
                                  mapProduct.get(prodStagingWrapper.Product_ID__c).Assignment_Date__c != NULL){
                                      placementHistory.Placement_Date__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Assignment_Date__c;
                                  }
                               //placementHistory.Placement_Date__c = prod.Assignment_Date__c;
                               system.debug('placementHistory.Placement_Date__c::'+placementHistory.Placement_Date__c); 
                               placementHistory.Placement_Status__c = prod.Placement_Status__c;
                               
                               if(placementStatusMap.containsKey( placementHistory.Placement_Status__c)){
                                   placementHistory.Placement_Status_Description__c = placementStatusMap.get( placementHistory.Placement_Status__c).Description__c;    
                               }
                               if(mapProduct.containsKey(prodStagingWrapper.Product_ID__c)){
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Principal_Balance__c != NULL){
                                       placementHistory.Current_Principal_Balance__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Principal_Balance__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Interest_Amount__c != NULL ){
                                       placementHistory.Current_Interest_Balance__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Interest_Amount__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Interest_Rate__c != NULL){
                                       placementHistory.Interest_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Interest_Rate__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Bal_NSF_Fees__c != NULL){
                                       placementHistory.NSF_Fees__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Bal_NSF_Fees__c; 
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Collection_Agency_Placement__r.Commission_Rate__c != NULL){
                                       placementHistory.Commission_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Collection_Agency_Placement__r.Commission_Rate__c; 
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Pool_Name__r.Commission_Rate__c != NULL){
                                       placementHistory.Pool_Commission_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Pool_Name__r.Commission_Rate__c; 
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Commission_Rate__c != NULL){
                                       placementHistory.Product_Commission_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Commission_Rate__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Pool_Name__r.Name != NULL){
                                       placementHistory.Pool_ID__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Pool_Name__r.Name;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Allocated_Amount_Total__c != NULL){
                                       placementHistory.Allocated_Balance__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Allocated_Amount_Total__c;
                                   }
                                   
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Commission_Rate_at_Time_of_Placement__c!= NULL){
                                      placementHistory.Placed_Commission_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Commission_Rate_at_Time_of_Placement__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Value_Tier_at_Time_of_Placement__c!= NULL){
                                       placementHistory.Value_Tier_at_Placement__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Value_Tier_at_Time_of_Placement__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Placed_Settlement_Rate__c!= NULL){
                                       placementHistory.Placed_Settlement_Rate__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Placed_Settlement_Rate__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Recoverable_Fee__c!= NULL){
                                       placementHistory.Recoverable_fee_balance__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Recoverable_Fee__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Non_Recoverable_Fee__c!= NULL){
                                       placementHistory.Non_recoverable_fee_balance__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Non_Recoverable_Fee__c;
                                   }
                                   if(mapProduct.get(prodStagingWrapper.Product_ID__c).Placement_Status__c != NULL){
                                        placementHistory.Placement_Status_at_time_of_recall__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Placement_Status__c ;
                                   }
                                  if(mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Balance__c != NULL){
                                        placementHistory.Total_Balance_at_Placement__c = mapProduct.get(prodStagingWrapper.Product_ID__c).Current_Balance__c;
                                   }
                               }
                               
                               
                               placementHistory.Current_Bal_Attorney_Fees__c = prod.Current_Bal_Attorney_Fees__c;
                               placementHistory.Current_Bal_General_Fees__c = prod.Current_Bal_General_Fees__c;
                               placementHistory.Current_Bal_Other_Fees__c = prod.Current_Bal_Other_Fees__c;
                               placementHistory.Current_Bal_Court_Fees__c = prod.Current_Bal_Court_Fees__c;
                               
                               listPlacementHistory.add(placementHistory);*/
                               PlacementStatus.put(prod.id,prodStagingWrapper.Placement_Status_Code__c);
                                if(!Test.isRunningTest()){
                               prodIdList.add(prod.id);
                               }
                               //DistressedUtilities.updatePlacementHistory(prod.id,mapProduct.get(prodStagingWrapper.Product_ID__c).Placement_Status__c);
                           }
                       }
                       if(String.isNotBlank(prod.Placement_Status__c) &&  prod.Placement_Status__c.startsWith('8') || Test.isRunningTest()){
                           if(codeMapping.containsKey(prod.Placement_Status__c)){
                               if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                   prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                   prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                                   prod.External_Status_Current__c = null;
                               }
                           }
                       }
                     
                    if(prodStagingWrapper.Comment__c=='SUCCESS' || prodStagingWrapper.Comment__c.contains('WARNING')){
                      successStringSet.add(prodStagingWrapper.Name__c+','+prodStagingWrapper.Placement_Status_Code__c+','
                                         + '"'+(prodStagingWrapper.Status_Changed_Date__c!= null ? prodStagingWrapper.Status_Changed_Date__c : NULL)+'"'+','+SUCCESS_STR);
                    
                      listProd.add(prod);
                        accountStagingSet.add(prodStagingWrapper);
                       successRecords = successRecords + 1;
                    }
                  String CommentError;
                  if(prodStagingWrapper.Comment__c!= 'SUCCESS' && prodStagingWrapper.Comment__c.contains('ERROR')){
                    CommentError = prodStagingWrapper.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                    failedRecords = failedRecords + 1;
                    failedStringSet.add(prodStagingWrapper.Name__c+','+prodStagingWrapper.Placement_Status_Code__c+','
                        + '"'+(prodStagingWrapper.Status_Changed_Date__c!= null ? prodStagingWrapper.Status_Changed_Date__c : NULL)+'"'+','+(prodStagingWrapper.comment__c!= null ? CommentError : Null));
                    
                  }
                      

                   }
            }
            for(Product_Staging__c prodStagingWrapperFailed : removedProductStagingList) {
                if (!(mapHoldingSelectedRecords.containsKey(prodStagingWrapperFailed.id) || prodStagingWrapperFailed.Status__c == PROCESSED)) {
                    String CommentError;
                    if(prodStagingWrapperFailed.Comment__c!= null){
                    CommentError = prodStagingWrapperFailed.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                }
                    failedStringSet.add(prodStagingWrapperFailed.Name__c+','+prodStagingWrapperFailed.Placement_Status_Code__c+','
                        + '"'+(prodStagingWrapperFailed.Status_Changed_Date__c!= null ? prodStagingWrapperFailed.Status_Changed_Date__c : NULL)+'"'+','+(prodStagingWrapperFailed.comment__c!= null ? CommentError : Null));
                    
                    failedRecords = failedRecords + 1;
                }

            }

            ProductTriggerHandler.runProductTrigger = false;
            
             //Create Task record and assign it to Agency
            //Update the existing Task record (as per new req) 
            Work_Assignment__c workAssignment = new Work_Assignment__c();
            workAssignment.ID = listAccountStaging[0].Document_Storage__r.Work_Assignment__c;
            workAssignmentId = workAssignment.Id;
            workAssignment.Comment_Reply__c = '';
            workAssignment.Status__c = 'Completed';
            if(failedRecords > 0){
                workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
            }
            if(successRecords > 0){
                workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
            }            
            //bug:4743 : changes starts
            String oldComments = '';
            if(workAssignment.Comments_History__c !=null){
            oldComments = workAssignment.Comments_History__c;
            }
            DateTime dT = System.now();
            workAssignment.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' +' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
            if(oldComments != null){
                workAssignment.Comments_History__c += oldComments;
            }
            WorkAssignmentTriggerHandler.updateCommentHistoryField=FALSE;
            //bug:4743 : changes ends             
            Database.executeBatch(new PortalProductStatusBulkAPIBatch(documentID,accountStagingSet, 
                                             workAssignmentID,successRecords,failedRecords,failedStringSet,
                                                                     successStringSet,true,null,null,null),1); 
            system.debug('listProd::'+listProd.size()); 
           Database.executeBatch(new ProcessRecordsBatchClass(listProd,listProdIds,false),70); 
            if(!Test.isRunningTest()){
              PortalProductStatusBulkAPI.processBulkProductsForPagination(productNames, Product_Placement_Status, ALLOCATED, String.valueOf(Date.today()), 
                                                           'Recall',placementIdentifier, poolName);    
            }
            if (listProdIds.size() > 0 ) {
               //PortalProductProcessingAPI.processProductBulk(listProdIds); 
               //PortalProductProcessingAPI.processProductBulkBatch(listProdIds); 
               //Database.executeBatch(new PortalProductProcessingBatch(listProdIds), 40); 
            }
            PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
            system.debug('listPlacementHistory'+listPlacementHistory);
             if(!Test.isRunningTest()){
            //DistressedUtilities.updatePlacementHistory_New(prodIdList,mapProduct,PlacementStatus);
            }
             if(!Test.isRunningTest()){
            //Reject active settlement when product is recall
            DistressedUtilities.UpdateSettlement(prodIdList);
            }
            //insert listPlacementHistory;
            PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
           
            //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger=false;
            update workAssignment;        
            WorkAssignmentTriggerHandler.updateCommentHistoryField=TRUE;//Added part of #4743
           // update new Work_Assignment__c(Id = listAccountStaging[0].Document_Storage__r.Work_Assignment__c, 
            //                              Status__c = 'Completed');
            
             ProductTriggerHandler.runProductAPI = false;
            List<Product_Staging__c> accStagingLists = new List<Product_Staging__c>(accountStagingSet);
            if(accStagingLists.size()>0){
            update accStagingLists;
            }
            ProductTriggerHandler.runProductAPI = true;
            
              showButton = true;
              displayPanel = true;   
             //WorkAssignmentTriggerHandler.runWorkAssignmentTrigger=true;
             ProductTriggerHandler.runProductTrigger = true; 
             PageReference pr = new PageReference('/apex/DisplayAccountStatusUpdateStaging?id='+recordIdentfier+'&processed=true');
            pr.setRedirect(true);
            return pr;
        }
        
        public List<Product_Staging__c> getAllRecords(){
            if(listAccountStagingNew.size() == 0) {
                listAccountStagingNew = [SELECT ID,Name, Product_Status__c,Name__c,Status__c,Placement_Status_Code__c,
                                         Status_Changed_Date__c,Comment__c,Placement_Agency__c, Document_Storage__r.Work_Assignment_Identifier__c, 
                                         Document_Storage__r.File_Processing_Status__c,Document_Storage__r.Work_Assignment__c,Product_ID__c,
                                         Placement_Main_Status__c, Placement_Sub_Status__C, Placement_Agency_ID__c
                                         FROM Product_Staging__c WHERE Identifier__c = :recordIdentfier and status__c
                                         ='Pending' limit 6000];
            }
            if(Test.isRunningTest()){
                listAccountStagingNew = [SELECT ID,Name, Product_Status__c,Name__c,Status__c,Placement_Status_Code__c,
                                         Status_Changed_Date__c,Comment__c,Placement_Agency__c, Document_Storage__r.Work_Assignment_Identifier__c, 
                                         Document_Storage__r.File_Processing_Status__c,Document_Storage__r.Work_Assignment__c,Product_ID__c,
                                         Placement_Main_Status__c, Placement_Sub_Status__C, Placement_Agency_ID__c
                                         FROM Product_Staging__c limit 5];
            }
            
            
            return listAccountStagingNew;
        }
        
          public static void postDocumentAPIBatch(id documentID,Set<Product_Staging__c> accountStagingSet, 
                                            id workAssignmentID,
                                            decimal successRecords,decimal failedRecords,set<string> failedStringSet,
                                            set<string> successStringSet){
            Map<String,Object> rawObj;
            Map<String,Object> rawObj1;
            String failedStr='data_id,status_code,status_date,error';
            String successStr = 'data_id,status_code,status_date,success';
             Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
           // system.debug(' failedRecords'+failedRecords+' Failed Records'+ failedStringSet);
            if(failedRecords > 0){
                failedStr += '\n';
                for (String str : failedStringSet) {
                    failedStr += str + '\n';
                }
            }
            successStr += '\n';
            for (String strSuccess : successStringSet) {
                successStr += strSuccess + '\n';
            }
            //Failed CSV API
            DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
            Blob fileBlob = Blob.valueOf(failedStr);
            if(failedRecords > 0){
                if(!Test.isRunningTest()) {
                parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Failed.csv', 'Task');
                rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response);  
                }else{
                    parsedResponse.DocUrl = 'Test';
                    parsedResponse.docId = 'Test';
                }     
            }            
            //Success CSV API
            DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
            Blob fileBlobSuccess = Blob.valueOf(successStr);
            if(successRecords > 0){
                if(!Test.isRunningTest()) {
                parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Success.csv', 'Task');
                rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response);
                }else{
                    parsedResponse1.DocUrl = 'Test';
                    parsedResponse1.docId = 'Test';
                }    
            }
          DocumentStorageTriggerHandler.runDocumentStorageTrigger=false;
            
            //Create Failed CSV Document Storage
            Document_Storage__c  failedDocStorage = new Document_Storage__c();
            
            if(null != parsedResponse 
               ){
                   
                   system.debug('task creation');
                   failedDocStorage.Work_Assignment__c = workAssignmentID;    
                   
                   failedDocStorage.Document_Name__c = 'Product Failed.csv';
                   failedDocStorage.Document_Extension__c = 'csv';
                   failedDocStorage.Document_ID__c =  parsedResponse.docId;
                   failedDocStorage.Document_Type__C = 'Account Status Update File';
                   failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
                   failedDocStorage.Document_URL__c =  parsedResponse.DocUrl;
                   failedDocStorage.Uploaded_By__c = 'Internal User';
                   failedDocStorage.Creator__c = UserInfo.getName();
                   failedDocStorage.Document_Related_To__c = 'Task';
                   failedDocStorage.File_Processed_By__c = UserInfo.getName();
                   failedDocStorage.File_Processing_Date__c = Date.today();
                   insert failedDocStorage;
                 }
            
            //Create Success CSV Document Storage
            Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
            
            if(null != parsedResponse1 
              ){
                   
                   system.debug('task creation');
                   SuccessDocStorage.Work_Assignment__c = workAssignmentID;    
                   
                   SuccessDocStorage.Document_Name__c = 'Product Success.csv';
                   SuccessDocStorage.Document_Extension__c = 'csv';
                   SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
                   SuccessDocStorage.Document_Type__C = 'Account Status Update File';
                   //failedDocStorage.Content_Type__c = contentType;
                   SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
                   SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
                   SuccessDocStorage.Uploaded_By__c = 'Internal User';
                   SuccessDocStorage.Creator__c = UserInfo.getName();
                   SuccessDocStorage.Document_Related_To__c = 'Task';
                   SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
                   SuccessDocStorage.File_Processing_Date__c = Date.today();
                   
                   insert SuccessDocStorage;
               }
            
           

            Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
            update docStorageToUpdate;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger=true;
          
        }
        
        /** returns the first page of the page set*/
        public void first() {
            if(isSelected != true){
                updateSearchItemsMap();
                uncheckedProdAccSet.clear();
            } else {
                mapHoldingSelectedRecords.clear();
                updateSet();
            }
            system.debug('Inside first**');
            setCon.first();
        }
        
        /** returns the last page of the page set*/
        public void last() {
            if(isSelected != true){
                updateSearchItemsMap();
                uncheckedProdAccSet.clear();
            } else {
                mapHoldingSelectedRecords.clear();
                updateSet();
            }
            system.debug('Inside last**');
            setCon.last();
            //init();
        }
        
        /** returns the previous page of the page set*/
        public void previous() {
            system.debug('Inside previous**');
           // setCon.save();
            if(isSelected != true){
                updateSearchItemsMap();
                uncheckedProdAccSet.clear();
            } else {
                mapHoldingSelectedRecords.clear();
                updateSet();
            } 
            setCon.previous();
            //init();
            
        }
        
        /** returns the next page of the page set*/
        public void next() {
            //setCon.save();
            system.debug('Inside next**');
            if(isSelected != true){
                updateSearchItemsMap();
                uncheckedProdAccSet.clear();
            } else {
                mapHoldingSelectedRecords.clear();
                updateSet();
            }
            setCon.next();
           // setCon.save();
            
        }
        
        public Boolean hasNext {
            get {
                system.debug('Inside hasNext**');
               
                return setCon.getHasNext();
            }
            set;
        }
        
        /** indicates whether there are more records before the current page set.*/
        public Boolean hasPrevious {
            get {
                system.debug('Inside hasPrevious**');
                 
                return setCon.getHasPrevious();
            }
            set;
        }

        /** return total number of pages for page set*/
        public Integer getTotalPages(){
            Decimal totalSize = setCon.getResultSize();
            Decimal pageSize = setCon.getPageSize();
            Decimal pages = totalSize/pageSize;
            return (Integer)pages.round(System.RoundingMode.CEILING);
        }
        
        //This is the method which manages to remove the deselected records, and keep the records which are selected in map.
        public void updateSearchItemsMap() {
            system.debug('updateSearchItemsMap called===');
            for(productStagingWrapper wrp : listProductStagingWrapper){
                if(wrp.selected){
                    mapHoldingSelectedRecords.put(wrp.accStaging.id, wrp);
                }
                if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.accStaging.id)){
                    mapHoldingSelectedRecords.remove(wrp.accStaging.id);
                }
            }
        }
        
        
        public void selectAll() {
            
            for(productStagingWrapper wrapper : listProductStagingWrapper ){
                if(isSelected == true){
                    if(wrapper.disabled != true && wrapper.accStaging.Status__c != PROCESSED){
                        system.debug('wrapper**'+wrapper);
                        wrapper.selected = true;
                    }   
                }
                else{
                    wrapper.selected = false;
                }   
            }
            
            updateListWrapper(isSelected);
        }
      
        public void updateListWrapper(Boolean isSelected) {
            List<productStagingWrapper> listProductStagingWrapperAll = new List<productStagingWrapper>();
        }
        
        public void updateSet() {
            for (productStagingWrapper prodSW : listProductStagingWrapper) {
                if (prodSW.selected == false) {
                    uncheckedProdAccSet.add(prodSW.accStaging.id);
                } else {
                    uncheckedProdAccSet.remove(prodSW.accStaging.id);
                }
                
            }
        }
        
        public class productStagingWrapper{
            public Product_Staging__c accStaging {get;set;}
            public boolean selected {get;set;}
            public boolean disabled {get;set;}
            public productStagingWrapper(Product_Staging__c pay, Boolean disable ){
                accStaging = pay;
                selected = false;
                disabled = disable;
            }
        }
    }