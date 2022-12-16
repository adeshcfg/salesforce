/**************************************************************************************************
*
* Class: 
*
* @description : Controller class to display Product records from Staging and create success
* and failure files for product allocation
* @author : A5E Consulting
* @date : 25/02/2022

*************************************************************************************************/
public class DisplayProductAllocateStagingController{
    
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public boolean isSelected{get;set;}
    Set<Id> uncheckedProdAccSet = new Set<Id>();
    public static final String PROCESSED = 'Processed';
    public static final String INPROGRESS = 'In Progress';
    Map<Id, productStagingWrapper> mapHoldingSelectedRecords = new Map<Id, productStagingWrapper>();
    Map<Id, Product_Staging__c> mapHoldingStageSelectedRecords = new Map<Id, Product_Staging__c>();
    public list<Product_Staging__c> listAccountStaging {get;set;}
    public static final String ERROR = 'ERROR';
    public static final String SUCCESS_STR = 'SUCCESS'; 
    public static final String FAILED_STR = 'FAILED';
    public id workAssingmentIdDoc;
    public list<Product_Staging__c> listProductStaging {get;set;}
    public list<productStagingWrapper> listProductStagingWrapper;
    public String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
    
    //Get document type to set headers on VF page. Developer: satyajit patil
    public String documentType{get;set;}// = ApexPages.currentPage().getParameters().get('docType');
    
    public boolean showButton {get;set;}
    public boolean displayPanel {get;set;}
    public boolean executeWarning {get;set;}
    public Id workAssignmentId {get;set;}
    public Integer pageNumber {get;set;}
    public Decimal successRecords;
    public Decimal failedRecords;
    public static final Integer PAGE_SIZE = 20;
    public Map<id,Product_Staging__c> prodStagMap = new Map<id,Product_Staging__c>();
    String placementAgency = '';
    public String success;
    public String failed;
    Id documentID;
    Set<Product_Staging__c> accountStagingSet = new Set<Product_Staging__c>();
    public string showHide {get;set;}
    public string showHideisSelected {get;set;}
    
    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {  
        get {
            String rcdIdentifier = recordIdentfier;
            Document_Storage__c docData= [select id,name,File_Processing_Status__c from Document_Storage__c where id = : recordIdentfier]; 
            if(docData.File_Processing_Status__c == INPROGRESS || docData.File_Processing_Status__c == PROCESSED){
                rcdIdentifier = 'Do not bring record';
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Processing is in progress'));
                showButton = true;
                
            }
            
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Status_Changed_Date_Text__c,Placement_Status_Code__c,ID, Name__c, Comment__c, Placement_Agency__c, Status__c, Expected_Value__c,Document_Storage__c,Current_Principal_Balance__c,
                                                                                       Current_Interest_Balance__c,Fees__c,Document_Storage__r.File_Processing_Status__c, Product_ID__c, Identifier__c,Placement_Agency_ID__c,
                                                                                       Document_Storage__r.Work_Assignment_Identifier__c, Pool_Name__c, Document_Storage__r.Work_Assignment__c,
                                                                                       Record_Type_ID__c,Placed_Commission_Rate__c,Current_Commission_Rate__c,Pool_Name_ID__c,
                                                                                       Value_Tier_at_Time_of_Placement__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c,Data_Id__c,Status_Changed_Date__c
                                                                                       FROM Product_Staging__c WHERE Identifier__c = :rcdIdentifier AND Include_in_Processing__c = false limit 10000]));
                setCon.setPageSize(PAGE_SIZE);
            }
            //system.debug('setCon::'+setCon.size());
            return setCon;
        }
        set;
    }
    
    public DisplayProductAllocateStagingController(){
        documentType = ApexPages.currentPage().getParameters().get('docType');
        documentID = recordIdentfier;
        list<Product_Staging__c> prodstglist = [SELECT ID,Name,Status_Changed_Date_Text__c,Status_Changed_Date__c,Document_Storage__r.Work_Assignment__c FROM 
                                                Product_Staging__c WHERE Identifier__c = :recordIdentfier and Status__c =:PROCESSED
                                                limit 1];
        Product_Staging__c prodstgrec = [SELECT ID,Name,Status_Changed_Date_Text__c,Status_Changed_Date__c,Document_Storage__r.Work_Assignment__c FROM 
                                         Product_Staging__c WHERE Identifier__c = :recordIdentfier limit 1];
        
        if(prodstgrec!=null){
            workAssignmentId = prodstgrec.Document_Storage__r.Work_Assignment__c;
        }
        if(prodstglist.size()>0){
            showButton = true;
            showHideisSelected = 'hidden';
            displayPanel = true; 
        }else{
            showButton = false;
            displayPanel = false;
        }
    }
    
    public void selectAll() {
        for(productStagingWrapper wrapper : listProductStagingWrapper ){
            if(isSelected == true){
                if(wrapper.disabled != true && wrapper.productStaging.Status__c != PROCESSED){
                    wrapper.selected = true;
                } 
            }
            else{
                wrapper.selected = false;
            } 
        }
        updateListWrapper(isSelected);
    }
    //Use For Pagination
    public void first() {
        if(isSelected != true){
            updateSearchItemsMap();
            uncheckedProdAccSet.clear();
        } else {
            mapHoldingSelectedRecords.clear();
            mapHoldingStageSelectedRecords.clear();
            updateSet();
        }
        setCon.first();
    }
    
    public void updateSet() {
        for (productStagingWrapper prodSW : listProductStagingWrapper) {
            if (prodSW.selected == false) {
                uncheckedProdAccSet.add(prodSW.productStaging.id);
            } else {
                uncheckedProdAccSet.remove(prodSW.productStaging.id);
            }
        }
    }
    
    //Use For Pagination
    /** returns the last page of the page set*/
    public void last() {
        if(isSelected != true ){
            updateSearchItemsMap();
            uncheckedProdAccSet.clear();
        } else {
            mapHoldingSelectedRecords.clear();
            mapHoldingStageSelectedRecords.clear();
            updateSet();
        }
        setCon.last();
    }
    
    //Use For Pagination
    /** returns the previous page of the page set*/
    public void previous() {
        if(isSelected != true ){
            updateSearchItemsMap();
            uncheckedProdAccSet.clear();
        } else {
            mapHoldingSelectedRecords.clear();
            mapHoldingStageSelectedRecords.clear();
            updateSet();
        }
        setCon.previous();
    }
    
    public void updateSearchItemsMap() {
        for(productStagingWrapper wrp : listProductStagingWrapper){
            if(wrp.selected){
                mapHoldingSelectedRecords.put(wrp.productStaging.id, wrp);
                mapHoldingStageSelectedRecords.put(wrp.productStaging.id, wrp.productStaging);
            }
            if(wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.productStaging.id)){
                mapHoldingSelectedRecords.remove(wrp.productStaging.id);
                mapHoldingStageSelectedRecords.remove(wrp.productStaging.id);
            }
        }
    }
    
    //Use For Pagination
    /** returns the next page of the page set*/
    public void next() {
        if(isSelected != true){
            updateSearchItemsMap();
            uncheckedProdAccSet.clear();
        } else {
            mapHoldingSelectedRecords.clear();
            mapHoldingStageSelectedRecords.clear();
            updateSet();
        }
        setCon.next();
    }
    
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    /** indicates whether there are more records before the current page set.*/
    public Boolean hasPrevious {
        get {
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
    
    public void updateListWrapper(Boolean isSelected) {
        List<productStagingWrapper> listProductStagingWrapperAll = new List<productStagingWrapper>();
    }
    
    //fill wrapper class and handle process button show/hide
    public List<productStagingWrapper> getlistProductStagingWrapper(){
        Integer successRecCount = 0;
        listAccountStaging = (List<Product_Staging__c>)setCon.getRecords();
        Integer SuccessCount = 
            [SELECT count() FROM Product_Staging__c 
             WHERE 
             Include_in_Processing__c = true 
             AND
             Identifier__c=:recordIdentfier];
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Total Success Records = '+SuccessCount));
        
        if(listAccountStaging.isEmpty()){
            showHide = 'hidden';
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no error or warning records to display '));
        }
        else{
            listProductStagingWrapper = new list<productStagingWrapper>();
            if (isSelected == true ) {
                for(Product_Staging__c accStaging : listAccountStaging){
                    Boolean showMessage = false;
                    Product_Staging__c accStaging1 = new Product_Staging__c();
                    accStaging1 = accStaging;
                    
                    if(accStaging.Comment__c != NULL && accStaging.Comment__c.contains(ERROR)) {
                        listProductStagingWrapper.add(new productStagingWrapper(accStaging1, true));
                    } else{
                        listProductStagingWrapper.add(new productStagingWrapper(accStaging1, false));
                        successRecCount++;
                    }
                    
                    if(accStaging.Status__c != PROCESSED){
                        if (successRecCount + SuccessCount > 0) {
                            showButton = false;
                        } else {
                            showButton = true;
                        }
                    }
                }
                system.debug('successRecCount::'+successRecCount);
                for(productStagingWrapper psw : listProductStagingWrapper) {
                    if(psw.productStaging.Status__c != PROCESSED && !uncheckedProdAccSet.contains(psw.productStaging.id)) {
                        psw.selected = true;
                    }
                    if(psw.productStaging.Status__c != PROCESSED && psw.productStaging.comment__c.contains(ERROR)){
                        psw.selected = false;  
                    } 
                }
            } else {
                for(Product_Staging__c accStaging : listAccountStaging){
                    Boolean showMessage = false;
                    Product_Staging__c accStaging2 = new Product_Staging__c();
                    accStaging2 = accStaging;
                    if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(accStaging.id)){
                        if(accStaging.Comment__c.contains(ERROR)) {
                            mapHoldingSelectedRecords.get(accStaging.id).disabled = true;
                        }
                        mapHoldingSelectedRecords.get(accStaging.id).productStaging = accStaging2;
                        listProductStagingWrapper.add(mapHoldingSelectedRecords.get(accStaging.id));
                    }
                    else{
                        if(accStaging.Comment__c!=null){
                            if(accStaging.Comment__c.contains(ERROR)) {
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging2, true));
                            } else { 
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging2, false));
                                successRecCount++;
                            }
                        }
                        else{
                            listProductStagingWrapper.add(new productStagingWrapper(accStaging2, false));
                            successRecCount++;
                        }
                        
                    }
                    if(accStaging.Status__c != PROCESSED){
                        if (successRecCount + SuccessCount > 0) {
                            showButton = false;
                        } 
                        else {
                            showButton = true;
                        }
                    }
                } 
            }
           
            if (SuccessCount == 0 && successRecCount == 0) {
                showHideisSelected = 'hidden';
            }
            placementAgency = listAccountStaging[0].Placement_Agency__c;
            
            list<Product_Staging__c> prodStagingPending = [SELECT ID FROM Product_Staging__c where 
                                                           Identifier__c=: recordIdentfier 
                                                           and status__c= 'Pending' LIMIT 1];
            if(prodStagingPending.size()==0){
                if(listAccountStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){ 
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
                }
                else{ 
                    showButton = false;
                }
            }
        } 
        pageNumber = setCon.getPageNumber();
        //system.debug('listProductStagingWrapper::'+listProductStagingWrapper.size());
        return listProductStagingWrapper;
    }
    
    public List<Product_Staging__c> getAllRecords(){
        List<Product_Staging__c> listAccountStagingNew = [SELECT Status_Changed_Date_Text__c,Placement_Status_Code__c,ID, Name__c, Comment__c, Placement_Agency__c, Status__c, Expected_Value__c,Document_Storage__c,Current_Principal_Balance__c,
                                                          Current_Interest_Balance__c,Fees__c,Document_Storage__r.File_Processing_Status__c, Product_ID__c, Identifier__c,Placement_Agency_ID__c,
                                                          Document_Storage__r.Work_Assignment_Identifier__c, Pool_Name__c, Document_Storage__r.Work_Assignment__c,
                                                          Record_Type_ID__c,Placed_Commission_Rate__c,Current_Commission_Rate__c,Pool_Name_ID__c,Status_Changed_Date__c,
                                                          Value_Tier_at_Time_of_Placement__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c, Data_Id__c 
                                                          FROM Product_Staging__c WHERE Identifier__c = :recordIdentfier and status__c='Pending' and Include_in_Processing__c = false limit 5000];
        system.debug('listAccountStagingNew::'+listAccountStagingNew);
        system.debug('listAccountStagingNew.Size::'+listAccountStagingNew.size());
        return listAccountStagingNew;
    }
    
    //Process records
    public pageReference SaveRecords() {
        transient List<Product_Staging__c> psAllRec = getAllRecords();
        Integer SuccessCount = 
            [SELECT count() FROM Product_Staging__c 
             WHERE 
             Include_in_Processing__c = true 
             AND
             Identifier__c=:recordIdentfier];
        if(isSelected == TRUE){
            Product_Staging__c prodStaging = new Product_Staging__c();
            for(Product_Staging__c prodStagingWrapper : psAllRec){
                if(prodStagingWrapper.Comment__c != NULL && !prodStagingWrapper.Comment__c.contains('ERROR')){
                    prodStagingWrapper.Include_in_Processing__c = true;
                    SuccessCount +=1;
                    accountStagingSet.add(prodStagingWrapper);
                }
                
            }
            List<Product_Staging__c> accStagingLists = new List<Product_Staging__c>(accountStagingSet);
            if(accStagingLists.size()>0){
                update accStagingLists;
            }
        }
        else{
            Product_Staging__c prodStaging = new Product_Staging__c();
            if(mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.size() > 0){
                for(productStagingWrapper prodStagingWrapper : mapHoldingSelectedRecords.values()) {
                    prodStaging = prodStagingWrapper.productStaging;
                    prodStaging.Id = prodStaging.Id;
                    if(prodStagingWrapper.selected == true){
                        prodStaging.Include_in_Processing__c = true;
                        SuccessCount +=1;
                    }
                    prodStagMap.Put(prodStaging.id,prodStaging);
                }
                update prodStagMap.values();
            }
            else{
                if(listProductStagingWrapper != null){
                    for(productStagingWrapper prodStagingWrapper : listProductStagingWrapper) {
                        prodStaging = prodStagingWrapper.productStaging;
                        prodStaging.Id = prodStaging.Id;
                        if(prodStagingWrapper.selected == true){
                            prodStaging.Include_in_Processing__c = true;
                            SuccessCount +=1;
                        }
                        prodStagMap.Put(prodStaging.id,prodStaging);
                    }
                    update prodStagMap.values();
                }
            }
        }
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=false;
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = INPROGRESS);
        update docStorageToUpdate;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=true;
        showButton = true;
        system.debug('SuccessCount::'+SuccessCount);
        //Call Product Update batch for allocation and recall.
        Database.executeBatch(new CFG_ProcessSuccessRecords(workAssignmentId,recordIdentfier,documentType),200);
        
        
        if(listProductStagingWrapper != null){
            listProductStagingWrapper.clear();  
        }
        if(accountstagingset != null){
            accountstagingset.clear();
        }
        listAccountStaging=new list<product_staging__c>();
        portalSettings = new Agency_Portal_Settings__c();
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM,'Bulk Record Processing Has Started and running in background. You will receive an email notification once process is completed.'));
        
        
        displayPanel = true;
        return null;
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
                If( Limits.getQueueableJobs() == 0) System.enqueueJob(new SnapshotQueueableClass(agencyTo_ProductIdsMap.get(agencyId), agencyId));
            }
        }
        
    }
    public static void getSnapshortRecordsTwo(List<Product__c> prodNew){
        Map<Id, List<Id>> agencyTo_ProductIdsMap = new Map<Id, List<Id>>();
        List<Id> productIds = new List<Id>();
        for(Product__c prod : prodNew){
            productIds.add(prod.Id);
            agencyTo_ProductIdsMap.put(prod.Collection_Agency_Placement__c, productIds );
        }
        if(!agencyTo_ProductIdsMap.isEmpty()){
            for(Id agencyId : agencyTo_ProductIdsMap.keySet()){
                If( Limits.getQueueableJobs() == 0)System.enqueueJob(new SnapshotQueueableClassForExcel(agencyTo_ProductIdsMap.get(agencyId), agencyId));
            }
        }
        
    }
    public class productStagingWrapper{
        public Product_Staging__c productStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public productStagingWrapper(Product_Staging__c pay, Boolean disable ){
            productStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
  
}