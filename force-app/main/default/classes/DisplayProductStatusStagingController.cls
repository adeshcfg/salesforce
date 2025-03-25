public class DisplayProductStatusStagingController {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public List<Product_Staging__c> listProductStaging { get; set; }
    public List<productStagingWrapper> listProductStagingWrapper;
    public Map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public List<String> prodIdList = new List<String>();
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
    public Boolean isSelected { get; set; }
    public Boolean showButton { get; set; }
    public String showHideisSelected { get; set; }
    public String showHide { get; set; }
    public Boolean displayPanel { get; set; }
    public Boolean executeWarning { get; set; }
    public String workAssignmentId { get; set; }
    public Decimal successRecords;
    public Decimal failedRecords;
    String placementAgency = '';
    public String success;
    public String failed;
    String productNames = '';
    Map<String, productStagingWrapper> mapHoldingSelectedRecords = new Map<String, productStagingWrapper>();
    Map<String, Product_Staging__c> mapHoldingStageSelectedRecords = new Map<String, Product_Staging__c>();
    public List<Product_Staging__c> listAccountStaging { get; set; }
    public Integer pageNumber { get; set; }
    public static final Integer PAGE_SIZE = 20;
    public Map<String, Product_Staging__c> prodStagMap = new Map<String, Product_Staging__c>();
    Set<Product_Staging__c> accountStagingSet = new Set<Product_Staging__c>();
    Set<String> uncheckedProdAccSet = new Set<String>();

    public ApexPages.StandardSetController setCon {
        get {
            String rcdIdentifier = recordIdentfier;
            Document_Storage__c docData = [SELECT id, name, File_Processing_Status__c FROM Document_Storage__c WHERE id = :recordIdentfier];
            if (docData.File_Processing_Status__c == DisplayProductAllocateStagingController.INPROGRESS) {
                rcdIdentifier = 'Do not bring record';
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Processing is in progress'));
                showButton = true;
            }
            if (docData.File_Processing_Status__c == PROCESSED) {
                rcdIdentifier = 'Do not bring record';
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Processing is completed'));
                showButton = true;
            }
            if (setCon == null) {
                setCon = new ApexPages.StandardSetController(
                    Database.getQueryLocator(
                        [
                            SELECT
                                ID,
                                Name__c,
                                Comment__c,
                                Placement_Agency__c,
                                Status__c,
                                Expected_Value__c,
                                Document_Storage__c,
                                Document_Storage__r.File_Processing_Status__c,
                                Product_ID__c,
                                Identifier__c,
                                Putback_Buyback_Amount__c,
                                Document_Storage__r.Work_Assignment_Identifier__c,
                                Document_Storage__r.Work_Assignment__c,
                                Purchase_Status__c,
                                Rejection_Reason__c,
                                Product_Status__c
                            FROM Product_Staging__c
                            WHERE Identifier__c = :recordIdentfier AND Include_in_Processing__c = FALSE
                            LIMIT 10000
                        ]
                    )
                );
                setCon.setPageSize(PAGE_SIZE);
            }
            return setCon;
        }
        set;
    }

    //Constructor
    public DisplayProductStatusStagingController() {
        list<Product_Staging__c> prodstglist = [
            SELECT ID, Name, Status_Changed_Date_Text__c, Status_Changed_Date__c, Document_Storage__r.Work_Assignment__c
            FROM Product_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Status__c = :PROCESSED
            LIMIT 1
        ];
        Product_Staging__c prodstgrec = [
            SELECT ID, Name, Status_Changed_Date_Text__c, Status_Changed_Date__c, Document_Storage__r.Work_Assignment__c
            FROM Product_Staging__c
            WHERE Identifier__c = :recordIdentfier
            LIMIT 1
        ];

        if (prodstgrec != null) {
            workAssignmentId = prodstgrec.Document_Storage__r.Work_Assignment__c;
        }
        if (prodstglist.size() > 0) {
            showButton = true;
            showHideisSelected = 'hidden';
            displayPanel = true;
        } else {
            showButton = false;
            displayPanel = false;
        }
    }

    public void selectAll() {
        for (productStagingWrapper wrapper : listProductStagingWrapper) {
            if (isSelected == true) {
                if (wrapper.disabled != true && wrapper.productStaging.Status__c != PROCESSED) {
                    wrapper.selected = true;
                }
            } else {
                wrapper.selected = false;
            }
        }
        updateListWrapper(isSelected);
    }

    //Use For Pagination
    public void first() {
        if (isSelected != true) {
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
        if (isSelected != true) {
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
        if (isSelected != true) {
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
        for (productStagingWrapper wrp : listProductStagingWrapper) {
            if (wrp.selected) {
                mapHoldingSelectedRecords.put(wrp.productStaging.id, wrp);
                mapHoldingStageSelectedRecords.put(wrp.productStaging.id, wrp.productStaging);
            }
            if (wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.productStaging.id)) {
                mapHoldingSelectedRecords.remove(wrp.productStaging.id);
                mapHoldingStageSelectedRecords.remove(wrp.productStaging.id);
            }
        }
    }

    //Use For Pagination
    /** returns the next page of the page set*/
    public void next() {
        if (isSelected != true) {
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
    public Integer getTotalPages() {
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize / pageSize;
        return (Integer) pages.round(System.RoundingMode.CEILING);
    }

    public void updateListWrapper(Boolean isSelected) {
        List<productStagingWrapper> listProductStagingWrapperAll = new List<productStagingWrapper>();
    }

    //fill wrapper class and handle process button show/hide
    public List<productStagingWrapper> getlistProductStagingWrapper() {
        Integer successRecCount = 0;
        listAccountStaging = (List<Product_Staging__c>) setCon.getRecords();
        Integer successCount = [
            SELECT COUNT()
            FROM Product_Staging__c
            WHERE Include_in_Processing__c = TRUE AND Identifier__c = :recordIdentfier
        ];
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Total Success Records = ' + successCount));

        if (listAccountStaging.isEmpty()) {
            showHide = 'hidden';
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no error or warning records to display '));
        } else {
            listProductStagingWrapper = new List<productStagingWrapper>();
            if (isSelected == true) {
                for (Product_Staging__c accStaging : listAccountStaging) {
                    Boolean showMessage = false;
                    if (accStaging.Comment__c != null && accStaging.Comment__c.contains(ERROR)) {
                        listProductStagingWrapper.add(new productStagingWrapper(accStaging, true));
                    } else {
                        listProductStagingWrapper.add(new productStagingWrapper(accStaging, false));
                        successRecCount++;
                    }
                    if (accStaging.Status__c != PROCESSED) {
                        if (successRecCount + successCount > 0) {
                            showButton = false;
                        } else {
                            showButton = true;
                        }
                    }
                }
                for (productStagingWrapper psw : listProductStagingWrapper) {
                    if (psw.productStaging.Status__c != PROCESSED && !uncheckedProdAccSet.contains(psw.productStaging.id)) {
                        psw.selected = true;
                    }
                    if (psw.productStaging.Status__c != PROCESSED && psw.productStaging.comment__c.contains(ERROR)) {
                        psw.selected = false;
                    }
                }
            } else {
                for (Product_Staging__c accStaging : listAccountStaging) {
                    Boolean showMessage = false;
                    if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(accStaging.id)) {
                        if (accStaging.Comment__c.contains(ERROR)) {
                            mapHoldingSelectedRecords.get(accStaging.id).disabled = true;
                        }
                        mapHoldingSelectedRecords.get(accStaging.id).productStaging = accStaging;
                        listProductStagingWrapper.add(mapHoldingSelectedRecords.get(accStaging.id));
                    } else {
                        if (accStaging.Comment__c != null) {
                            if (accStaging.Comment__c.contains(ERROR)) {
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging, true));
                            } else {
                                listProductStagingWrapper.add(new productStagingWrapper(accStaging, false));
                                successRecCount++;
                            }
                        } else {
                            listProductStagingWrapper.add(new productStagingWrapper(accStaging, false));
                            successRecCount++;
                        }
                    }
                    if (accStaging.Status__c != PROCESSED) {
                        if (successRecCount + successCount > 0) {
                            showButton = false;
                        } else {
                            showButton = true;
                        }
                    }
                }
            }

            if (successCount == 0 && successRecCount == 0) {
                showHideisSelected = 'hidden';
            }

            List<Product_Staging__c> prodStagingPending = [
                SELECT ID
                FROM Product_Staging__c
                WHERE Identifier__c = :recordIdentfier AND Status__c = 'Pending'
                LIMIT 1
            ];
            if (prodStagingPending.size() == 0) {
                if (listAccountStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED) {
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Records are already processed'));
                } else {
                    showButton = false;
                }
            }
        }
        pageNumber = setCon.getPageNumber();
        return listProductStagingWrapper;
    }

    public List<Product_Staging__c> getAllRecords() {
        List<Product_Staging__c> listAccountStagingNew = [
            SELECT
                ID,
                Name__c,
                Comment__c,
                Placement_Agency__c,
                Status__c,
                Expected_Value__c,
                Document_Storage__c,
                Document_Storage__r.File_Processing_Status__c,
                Product_ID__c,
                Identifier__c,
                Putback_Buyback_Amount__c,
                Document_Storage__r.Work_Assignment_Identifier__c,
                Document_Storage__r.Work_Assignment__c,
                Purchase_Status__c,
                Rejection_Reason__c,
                Product_Status__c
            FROM Product_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Status__c = 'Pending' AND Include_in_Processing__c = FALSE
            LIMIT 5000
        ];
        return listAccountStagingNew;
    }

    public pageReference save() {
        transient List<Product_Staging__c> psAllRec = getAllRecords();
        Integer successCount = [
            SELECT COUNT()
            FROM Product_Staging__c
            WHERE Include_in_Processing__c = TRUE AND Identifier__c = :recordIdentfier
        ];
        if (isSelected == true) {
            Product_Staging__c prodStaging = new Product_Staging__c();
            for (Product_Staging__c prodStagingWrapper : psAllRec) {
                if (prodStagingWrapper.Comment__c != null && !prodStagingWrapper.Comment__c.contains('ERROR')) {
                    prodStagingWrapper.Include_in_Processing__c = true;
                    successCount += 1;
                    accountStagingSet.add(prodStagingWrapper);
                }
            }
            List<Product_Staging__c> accStagingLists = new List<Product_Staging__c>(accountStagingSet);
            if (accStagingLists.size() > 0) {
                update accStagingLists;
            }
        } else {
            Product_Staging__c prodStaging = new Product_Staging__c();
            if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.size() > 0) {
                for (productStagingWrapper prodStagingWrapper : mapHoldingSelectedRecords.values()) {
                    prodStaging = prodStagingWrapper.productStaging;
                    prodStaging.Id = prodStaging.Id;
                    if (prodStagingWrapper.selected == true) {
                        prodStaging.Include_in_Processing__c = true;
                        successCount += 1;
                    }
                    prodStagMap.put(prodStaging.id, prodStaging);
                }
                update prodStagMap.values();
            } else {
                if (listProductStagingWrapper != null) {
                    for (productStagingWrapper prodStagingWrapper : listProductStagingWrapper) {
                        prodStaging = prodStagingWrapper.productStaging;
                        prodStaging.Id = prodStaging.Id;
                        if (prodStagingWrapper.selected == true) {
                            prodStaging.Include_in_Processing__c = true;
                            successCount += 1;
                        }
                        prodStagMap.put(prodStaging.id, prodStaging);
                    }
                    update prodStagMap.values();
                }
            }
        }

        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(
            Id = recordIdentfier,
            File_Processing_Status__c = DisplayProductAllocateStagingController.INPROGRESS
        );
        update docStorageToUpdate;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        showButton = true;
        Database.executeBatch(new CFG_ProcessSuccessRecords(workAssignmentId, recordIdentfier, DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE), 100);
        if (listProductStagingWrapper != null) {
            listProductStagingWrapper.clear();
        }
        if (accountstagingset != null) {
            accountstagingset.clear();
        }
        listAccountStaging = new List<Product_Staging__c>();
        portalSettings = new Agency_Portal_Settings__c();
        Apexpages.addMessage(
            new ApexPages.message(
                Apexpages.Severity.CONFIRM,
                'Bulk Record Processing Has Started and running in background. You will receive an email notification once process is completed.'
            )
        );
        displayPanel = true;
        return null;
    }

    public static List<String> processRecords(List<Product_Staging__c> listProductStagingToProcess) {
        Set<String> setProdutNames = new Set<String>();
        Map<String, String> mapProductNameId = new Map<String, String>();
        List<Product__c> listProductToUpdate = new List<Product__c>();
        List<String> productIdsToUpdate = new List<String>();
        Map<String, String> statusDescriptionMap = new Map<String, String>();
        List<String> putbackStatuses = new List<String>{ '297000', '298000' };
        for (Data_Status_Mapping__c statusMapping : [SELECT Name, Description__c FROM Data_Status_Mapping__c]) {
            statusDescriptionMap.put(statusMapping.Name, statusMapping.Description__c);
        }
        for (Product_Staging__c productStaging : listProductStagingToProcess) {
            setProdutNames.add(productStaging.Data_Id__c);
        }
        for (Product__c prod : [SELECT Id, Name FROM Product__c WHERE Name IN :setProdutNames]) {
            mapProductNameId.put(prod.Name, prod.Id);
        }
        for (Product_Staging__c productStaging : listProductStagingToProcess) {
            if (productStaging.Status__c != PROCESSED && productStaging.Include_in_Processing__c == true) {
                Product__c prod = new Product__c();
                prod.Id = mapProductNameId.get(productStaging.Data_Id__c);
                prod.Product_Status__c = productStaging.Product_Status__c;
                if (putbackStatuses.contains(prod.Product_Status__c)) {
                    prod.Purchase_Status__c = 'Buyback/Putback Initiated';
                    prod.Buyback_Putback_Status_Change_Date__c = System.today();
                }
                prod.Data_Status_Description__c = statusDescriptionMap.get(prod.Product_Status__c);
                productIdsToUpdate.add(prod.Id);
                listProductToUpdate.add(prod);
            }
        }
        try {
            if (!listProductToUpdate.isEmpty()) {
                ProductTriggerHandler.runProductTrigger = false;
                Database.update(listProductToUpdate);
                ProductTriggerHandler.runProductTrigger = true;
            }
        } catch (DmlException ex) {
            for (Product_Staging__c productStaging : listProductStagingToProcess) {
                String msg = '<b>ERROR</b>-' + ex.getDmlMessage(0);
                if (msg.length() > 254) {
                    msg = msg.substring(0, 254);
                }
                productStaging.Comment__c = msg;
                productStaging.Status__c = 'Pending';
            }
            Database.update(listProductStagingToProcess);
        }
        return productIdsToUpdate;
    }

    /* public static void generateSuccessErrorFiles(String documentStorageId, String workAssignmentId) {
        List<Product_Staging__c> processedStagingRecords = new List<Product_Staging__c>();
        String success = 'data_id,product_status';
        String failed = 'data_id,product_status,error';
        Integer successRecords = 0;
        Integer failedRecords = 0;
        for (Product_Staging__c prodStaging : [
            SELECT
                Status__c,
                Include_in_Processing__c,
                Product_Status__c,
                Data_Id__c,
                Putback_Buyback_Amount__c,
                Purchase_Status__c,
                Rejection_Reason__c,
                Comment__c
            FROM Product_Staging__c
            WHERE Identifier__c = :documentStorageId AND Status__c != 'Processed'
            ORDER BY Include_in_Processing__c
        ]) {
            if (prodStaging.Include_in_Processing__c) {
                prodStaging.Status__c = PROCESSED;
                success += '\n';
                success += prodStaging.Data_Id__c + ',' + prodStaging.Product_Status__c;
                successRecords = successRecords + 1;
                processedStagingRecords.add(prodStaging);
            } else {
                failed += '\n';
                String commentError = '';
                if (String.isNotBlank(prodStaging.Comment__c)) {
                    commentError = prodStaging.Comment__c;
                    commentError = commentError.replaceAll('<br/>', '');
                    commentError = commentError.replaceAll('</b>', '');
                    commentError = commentError.replaceAll('<b>', '');
                }
                failed +=
                    prodStaging.Data_Id__c +
                    ',' +
                    prodStaging.Product_Status__c +
                    ',' +
                    (String.isNotBlank(prodStaging.Comment__c) ? commentError : null);
                failedRecords = failedRecords + 1;
            }
        }
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        system.enqueueJob(
            new PostDocumentAPI(
                DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE,
                failed,
                success,
                failedRecords,
                successRecords,
                workAssignmentId,
                portalSettings.Document_Storage_Default_Visibility__c,
                documentStorageId
            )
        );
    } */

    public class productStagingWrapper {
        public Product_Staging__c productStaging { get; set; }
        public boolean selected { get; set; }
        public boolean disabled { get; set; }
        public productStagingWrapper(Product_Staging__c pay, Boolean disable) {
            productStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
}
