/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Product  records from Staging and create success
*                  and failure files for customer contact info
*  @author : A5E Consulting
*  @date : 14/02/2022

*************************************************************************************************/
public class DisplayCustomerContInfoStagingController {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public list<Customer_Staging__c> listCustomerContactStaging { get; set; }
    public List<customerContactInfoStagingWrapper> listCustomerContInfoStagingWrapper = new List<customerContactInfoStagingWrapper>();
    public static final String PROCESSED = 'Processed';
    public static final String INPROGRESS = 'In Progress';
    public static String CUSTOMER_CONTACT_INFO_UPDATE = 'Customer Contact Information Update File';
    public static final String ERROR = 'ERROR';
    public boolean showButton { get; set; }
    public boolean displayPanel { get; set; }
    public Id workAssignmentId { get; set; }
    public String recordIdentfier = ApexPages.currentPage().getParameters().get('Id');
    public Id documentID;
    String success = '';
    String failed = '';
    String placementAgency = '';
    public static final Integer PAGE_SIZE = 20;
    public Integer pageNumber { get; set; }
    public string showHide { get; set; }
    public string showHideisSelected { get; set; }
    public boolean isSelected { get; set; }
    Set<Id> uncheckedProdAccSet = new Set<Id>();
    Map<Id, customerContactInfoStagingWrapper> mapHoldingSelectedRecords = new Map<Id, customerContactInfoStagingWrapper>();
    Map<Id, Customer_Staging__c> mapHoldingStageSelectedRecords = new Map<Id, Customer_Staging__c>();
    Set<Customer_Staging__c> customerStagingSet = new Set<Customer_Staging__c>();
    public Map<Id, Customer_Staging__c> custStagMap = new Map<Id, Customer_Staging__c>();

    /** Instantiate the StandardSetController from a query locater*/
    public ApexPages.StandardSetController setCon {
        get {
            String rcdIdentifier = recordIdentfier;
            Document_Storage__c docData = [SELECT Id, Name, File_Processing_Status__c FROM Document_Storage__c WHERE Id = :recordIdentfier];
            if (docData.File_Processing_Status__c == INPROGRESS) {
                rcdIdentifier = 'Do not bring record';
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Processing is in progress'));
                showButton = false;
            }
            if (docData.File_Processing_Status__c == PROCESSED) {
                rcdIdentifier = 'Do not bring record';
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Processing is completed'));
                showButton = false;
            }
            if (setCon == null) {
                // Get the records which have either warnings or errors
                setCon = new ApexPages.StandardSetController(
                    Database.getQueryLocator(
                        [
                            SELECT
                                ID,
                                Name,
                                Address_Line1__c,
                                Address_Line2__c,
                                Cell_Phone__c,
                                City__c,
                                Country__c,
                                Email_Address__c,
                                Home_Phone__c,
                                Postal_Code__c,
                                State__c,
                                Work_Phone__c,
                                Coborrower_Address1__c,
                                Coborrower_Address2__c,
                                Coborrower_Cell_Phone__c,
                                Coborrower_City__c,
                                Coborrower_Country__c,
                                Coborrower_Email__c,
                                Coborrower_Home_Phone__c,
                                Coborrower_Postal_Code__c,
                                Coborrower_State__c,
                                Coborrower_Work_Phone__c,
                                Comment__c,
                                Placement_Agency__c,
                                ProdID__c,
                                Status__c,
                                Document_Storage__c,
                                Document_Storage__r.File_Processing_Status__c,
                                Document_Storage__r.Work_Assignment__c,
                                Product_ID__c,
                                Expected_Value__c
                            FROM Customer_Staging__c
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

    public DisplayCustomerContInfoStagingController() {
        List<Customer_Staging__c> custStglist = [
            SELECT ID
            FROM Customer_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Status__c = :PROCESSED
            LIMIT 1
        ];
        if (custStglist.size() > 0) {
            showButton = false;
            showHideisSelected = 'hidden';
            displayPanel = true;
        } else {
            showButton = true;
            displayPanel = false;
        }
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

    /** indicates whether there are more records after the current page set.*/
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

    // Select all records which are not disabled by default(Error records)
    public void selectAll() {
        for (customerContactInfoStagingWrapper wrapper : listCustomerContInfoStagingWrapper) {
            if (isSelected == true) {
                if (wrapper.disabled != true && wrapper.custStaging.Status__c != PROCESSED) {
                    wrapper.selected = true;
                }
            } else {
                wrapper.selected = false;
            }
        }
    }

    // Add selected/unselected values to a map so that we can retain the values after page changes
    public void updateSearchItemsMap() {
        for (customerContactInfoStagingWrapper wrp : listCustomerContInfoStagingWrapper) {
            if (wrp.selected) {
                mapHoldingSelectedRecords.put(wrp.custStaging.Id, wrp);
                mapHoldingStageSelectedRecords.put(wrp.custStaging.Id, wrp.custStaging);
            }
            if (wrp.selected == false && mapHoldingSelectedRecords.containsKey(wrp.custStaging.Id)) {
                mapHoldingSelectedRecords.remove(wrp.custStaging.Id);
                mapHoldingStageSelectedRecords.remove(wrp.custStaging.Id);
            }
        }
    }

    public void updateSet() {
        for (customerContactInfoStagingWrapper custSW : listCustomerContInfoStagingWrapper) {
            if (custSW.selected == false) {
                uncheckedProdAccSet.add(custSW.custStaging.Id);
            } else {
                uncheckedProdAccSet.remove(custSW.custStaging.Id);
            }
        }
    }

    /** return total number of pages for page set*/
    public Integer getTotalPages() {
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
        Decimal pages = totalSize / pageSize;
        return (Integer) pages.round(System.RoundingMode.CEILING);
    }

    // Query and return all error/warning records
    public List<Customer_Staging__c> getAllRecords() {
        List<Customer_Staging__c> listCustomerStagingNew = [
            SELECT
                ID,
                Name,
                Address_Line1__c,
                Address_Line2__c,
                Cell_Phone__c,
                City__c,
                Country__c,
                Email_Address__c,
                Home_Phone__c,
                Postal_Code__c,
                State__c,
                Work_Phone__c,
                Coborrower_Address1__c,
                Coborrower_Address2__c,
                Coborrower_Cell_Phone__c,
                Coborrower_City__c,
                Coborrower_Country__c,
                Coborrower_Email__c,
                Coborrower_Home_Phone__c,
                Coborrower_Postal_Code__c,
                Coborrower_State__c,
                Coborrower_Work_Phone__c,
                Comment__c,
                Placement_Agency__c,
                ProdID__c,
                Status__c,
                Document_Storage__c,
                Document_Storage__r.File_Processing_Status__c,
                Document_Storage__r.Work_Assignment__c,
                Product_ID__c,
                Expected_Value__c
            FROM Customer_Staging__c
            WHERE Identifier__c = :recordIdentfier AND Include_in_Processing__c = FALSE AND status__c = 'Pending'
            LIMIT 5000
        ];
        return listCustomerStagingNew;
    }

    //fill wrapper class and handle process button show/hide
    public List<customerContactInfoStagingWrapper> getlistCustomerContInfoStagingWrapper() {
        Integer successRecCount = 0;
        listCustomerContactStaging = (List<Customer_Staging__c>) setCon.getRecords();
        documentID = recordIdentfier;
        // Get the count of success records which don't have any error/warning
        Integer successCount = [
            SELECT COUNT()
            FROM Customer_Staging__c
            WHERE Include_in_Processing__c = TRUE AND Identifier__c = :recordIdentfier
        ];
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Total Success Records = ' + successCount));
        // If there are no error/warning records
        if (listCustomerContactStaging.isEmpty()) {
            showHide = 'hidden';
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no error or warning records to display '));
            if (successCount > 0) {
                showButton = true;
            }
        } else {
            workAssignmentId = listCustomerContactStaging[0].Document_Storage__r.Work_Assignment__c;
            placementAgency = listCustomerContactStaging[0].Placement_Agency__c;
            listCustomerContInfoStagingWrapper = new List<customerContactInfoStagingWrapper>();
            // If user checked select all checkbox, add all warning records to wrapper and update the success count
            if (isSelected == true) {
                for (Customer_Staging__c custStaging : listCustomerContactStaging) {
                    Customer_Staging__c custStaging1 = new Customer_Staging__c();
                    custStaging1 = custStaging;
                    if (custStaging.Comment__c != null && custStaging.Comment__c.contains(ERROR)) {
                        listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging1, true));
                    } else {
                        listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging1, false));
                        successRecCount++;
                    }
                    if (custStaging.Status__c != PROCESSED) {
                        if (successRecCount + successCount > 0) {
                            showButton = true;
                        } else {
                            showButton = false;
                        }
                    }
                }
                for (customerContactInfoStagingWrapper psw : listCustomerContInfoStagingWrapper) {
                    if (psw.custStaging.Status__c != PROCESSED && !uncheckedProdAccSet.contains(psw.custStaging.Id)) {
                        psw.selected = true;
                    }
                    if (psw.custStaging.Status__c != PROCESSED && psw.custStaging.comment__c.contains(ERROR)) {
                        psw.selected = false;
                    }
                }
            } else {
                for (Customer_Staging__c custStaging : listCustomerContactStaging) {
                    Customer_Staging__c custStaging2 = new Customer_Staging__c();
                    custStaging2 = custStaging;
                    if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.containsKey(custStaging.Id)) {
                        if (custStaging.Comment__c.contains(ERROR)) {
                            mapHoldingSelectedRecords.get(custStaging.Id).disabled = true;
                        }
                        mapHoldingSelectedRecords.get(custStaging.Id).custStaging = custStaging2;
                        listCustomerContInfoStagingWrapper.add(mapHoldingSelectedRecords.get(custStaging.Id));
                    } else {
                        if (custStaging.Comment__c != null) {
                            if (custStaging.Comment__c.contains(ERROR)) {
                                listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging2, true));
                            } else {
                                listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging2, false));
                                successRecCount++;
                            }
                        } else {
                            listCustomerContInfoStagingWrapper.add(new customerContactInfoStagingWrapper(custStaging2, false));
                            successRecCount++;
                        }
                    }
                    if (custStaging.Status__c != PROCESSED) {
                        if (successRecCount + successCount > 0) {
                            showButton = true;
                        } else {
                            showButton = false;
                        }
                    }
                }
            }
            // If there are no success or warning/error records hide the panel
            if (successCount == 0 && successRecCount == 0) {
                showHideisSelected = 'hidden';
            }
            List<Customer_Staging__c> custStagingPending = [
                SELECT ID
                FROM Customer_Staging__c
                WHERE Identifier__c = :recordIdentfier AND Status__c = 'Pending'
                LIMIT 1
            ];
            // If there are no pending staging records
            if (custStagingPending.size() == 0) {
                if (listCustomerContactStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED) {
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Records are already processed'));
                } else {
                    showButton = true;
                }
            }
        }
        pageNumber = setCon.getPageNumber();
        return listCustomerContInfoStagingWrapper;
    }

    public pageReference Save() {
        transient List<Customer_Staging__c> customerAllRec = getAllRecords();
        // If select all checkbox is checked include all warning records to be selected for processing
        if (isSelected == true) {
            Customer_Staging__c custStaging = new Customer_Staging__c();
            for (Customer_Staging__c custStagingWrapper : customerAllRec) {
                if (custStagingWrapper.Comment__c != null && !custStagingWrapper.Comment__c.contains('ERROR')) {
                    custStagingWrapper.Include_in_Processing__c = true;
                    customerStagingSet.add(custStagingWrapper);
                }
            }
            List<Customer_Staging__c> customerStagingLists = new List<Customer_Staging__c>(customerStagingSet);
            if (customerStagingLists.size() > 0) {
                update customerStagingLists;
            }
        } else {
            // Get the selected records from the map and include them for processing
            Customer_Staging__c custStaging = new Customer_Staging__c();
            if (mapHoldingSelectedRecords != null && mapHoldingSelectedRecords.size() > 0) {
                for (customerContactInfoStagingWrapper custStagingWrapper : mapHoldingSelectedRecords.values()) {
                    custStaging = custStagingWrapper.CustStaging;
                    if (custStagingWrapper.selected == true) {
                        custStaging.Include_in_Processing__c = true;
                        custStagMap.Put(custStaging.Id, custStaging);
                    }
                }
            } else {
                if (!listCustomerContInfoStagingWrapper.isEmpty()) {
                    for (customerContactInfoStagingWrapper custStagingWrapper : listCustomerContInfoStagingWrapper) {
                        custStaging = custStagingWrapper.CustStaging;
                        if (custStagingWrapper.selected == true) {
                            custStaging.Include_in_Processing__c = true;
                            custStagMap.Put(custStaging.Id, custStaging);
                        }
                    }
                }
            }
            // Update selected customer staging records
            if (!custStagMap.values().isEmpty()) {
                update custStagMap.values();
            }
        }
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        // Update Document storage processing status to In Progress
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID = documentID, File_Processing_Status__c = INPROGRESS);
        update docStorageToUpdate;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        showButton = false;
        // Call batch to update the actual Product records
        Database.executeBatch(new CFG_ProcessSuccessRecords(workAssignmentId, recordIdentfier, CUSTOMER_CONTACT_INFO_UPDATE), 1000);
        if (!listCustomerContInfoStagingWrapper.isEmpty()) {
            listCustomerContInfoStagingWrapper.clear();
        }
        if (!customerStagingSet.isEmpty()) {
            customerStagingSet.clear();
        }
        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.CONFIRM, 'Bulk Record Processing Has Started and running in background'));
        displayPanel = true;
        return null;
    }

    // Update values from excel to acyual Product records
    public static List<Id> processRecords(List<Customer_Staging__c> listCustomerStaging) {
        List<Customer_Staging__c> listCustomerStagingToUpdate = new List<Customer_Staging__c>();
        Set<String> setProdutNames = new Set<String>();
        list<Product__c> listProd = new List<Product__c>();
        Map<String, ID> mapAccountNumberID = new Map<String, ID>();
        Map<String, ID> accNumberCustomerID = new Map<String, ID>();
        List<Id> productIdsToUpdate = new List<Id>();
        String placementAgency = '';
        String placementID = '';
        for (Customer_Staging__c custStaging : listCustomerStaging) {
            placementAgency = custStaging.Placement_Agency__c;
            setProdutNames.add(custStaging.ProdID__c);
        }

        //Get Placement ID
        list<Placement__c> listPlacements = [
            SELECT ID
            FROM Placement__c
            WHERE Name = :placementAgency
        ];
        if (!listPlacements.isEmpty()) {
            placementID = listPlacements[0].ID;
        }

        //Get Product IDs in map
        for (Product__C accountRecord : [
            SELECT Id, name, DebtNext_Data_ID__C, Collection_Agency__c, Customer__c
            FROM Product__C
            WHERE name IN :setProdutNames
        ]) {
            mapAccountNumberID.put(accountRecord.name, accountRecord.Id);
            accNumberCustomerID.put(accountRecord.name, accountRecord.Customer__c);
        }

        List<string> nospacenull = new List<string>();
        List<string> nospaceBlank = new List<string>();
        nospacenull.add(' ');
        nospacenull.add('null');
        nospacenull.add('Null');
        nospacenull.add(null);
        nospacenull.add(null);
        nospacenull.add('-');
        nospaceBlank.add('-');

        for (Customer_Staging__c CustStaging : listCustomerStaging) {
            String comment = '';
            if (String.isNotBlank(CustStaging.Comment__c)) {
                comment = CustStaging.Comment__c;
            }
            if (Test.isRunningTest()) {
                CustStaging.Include_in_Processing__c = true;
            }
            if (CustStaging.Status__c != PROCESSED && CustStaging.Include_in_Processing__c == true) {
                Product__c prod = new Product__c();
                if (mapAccountNumberID.ContainsKey(CustStaging.ProdID__c)) {
                    prod.Id = mapAccountNumberID.get(CustStaging.ProdID__c);
                    productIdsToUpdate.add(prod.Id);
                }

                if (!nospacenull.contains(CustStaging.Email_Address__c))
                    prod.Email_Address__c = CustStaging.Email_Address__c;
                if (nospaceBlank.contains(CustStaging.Email_Address__c))
                    prod.Email_Address__c = '';

                if (!nospacenull.contains(CustStaging.Address_Line1__c))
                    prod.Address_Line1__c = CustStaging.Address_Line1__c;
                if (nospaceBlank.contains(CustStaging.Address_Line1__c))
                    prod.Address_Line1__c = '';

                if (!nospacenull.contains(CustStaging.Address_Line2__c))
                    prod.Address_Line2__c = CustStaging.Address_Line2__c;
                if (nospaceBlank.contains(CustStaging.Address_Line2__c))
                    prod.Address_Line2__c = '';

                if (!nospacenull.contains(CustStaging.City__c))
                    prod.City__c = CustStaging.City__c;
                if (nospaceBlank.contains(CustStaging.City__c))
                    prod.City__c = '';

                if (!nospacenull.contains(CustStaging.State__c) && CustStaging.State__c != null)
                    prod.State__c = CustStaging.State__c;
                if (nospaceBlank.contains(CustStaging.State__c))
                    prod.State__c = '';

                if (!nospacenull.contains(CustStaging.Postal_Code__c))
                    prod.Zip_Code__c = CustStaging.Postal_Code__c;
                if (nospaceBlank.contains(CustStaging.Postal_Code__c))
                    prod.Zip_Code__c = '';

                if (!nospacenull.contains(CustStaging.Country__c) && CustStaging.Country__c != null)
                    prod.Country__c = CustStaging.Country__c;
                if (nospaceBlank.contains(CustStaging.Country__c))
                    prod.Country__c = '';

                if (!nospacenull.contains(CustStaging.Home_Phone__c))
                    prod.Phone_Home__c = CustStaging.Home_Phone__c;
                if (nospaceBlank.contains(CustStaging.Home_Phone__c))
                    prod.Phone_Home__c = '';

                if (!nospacenull.contains(CustStaging.Work_Phone__c))
                    prod.Phone_Work__c = CustStaging.Work_Phone__c;
                if (nospaceBlank.contains(CustStaging.Work_Phone__c))
                    prod.Phone_Work__c = '';

                if (!nospacenull.contains(CustStaging.Cell_Phone__c))
                    prod.Phone_Other__c = CustStaging.Cell_Phone__c;
                if (nospaceBlank.contains(CustStaging.Cell_Phone__c))
                    prod.Phone_Other__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Email__c))
                    prod.Codebtor_Email_Address__c = CustStaging.Coborrower_Email__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Email__c))
                    prod.Codebtor_Email_Address__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Address1__c))
                    prod.Codebtor_Address_Line1__c = CustStaging.Coborrower_Address1__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Address1__c))
                    prod.Codebtor_Address_Line1__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Address2__c))
                    prod.Codebtor_Address_Line2__c = CustStaging.Coborrower_Address2__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Address2__c))
                    prod.Codebtor_Address_Line2__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_City__c))
                    prod.Codebtor_City__c = CustStaging.Coborrower_City__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_City__c))
                    prod.Codebtor_City__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_State__c))
                    prod.Codebtor_State__c = CustStaging.Coborrower_State__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_State__c))
                    prod.Codebtor_State__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Postal_Code__c))
                    prod.Codebtor_Zip_Code__c = CustStaging.Coborrower_Postal_Code__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Postal_Code__c))
                    prod.Codebtor_Zip_Code__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Country__c))
                    prod.Codebtor_Country__c = CustStaging.Coborrower_Country__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Country__c))
                    prod.Codebtor_Country__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Work_Phone__c))
                    prod.Codebtor_Phone_Work__c = CustStaging.Coborrower_Work_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Work_Phone__c))
                    prod.Codebtor_Phone_Work__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Home_Phone__c))
                    prod.Codebtor_Phone_Home__c = CustStaging.Coborrower_Home_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Home_Phone__c))
                    prod.Codebtor_Phone_Home__c = '';

                if (!nospacenull.contains(CustStaging.Coborrower_Cell_Phone__c))
                    prod.Codebtor_Phone_Other__c = CustStaging.Coborrower_Cell_Phone__c;
                if (nospaceBlank.contains(CustStaging.Coborrower_Cell_Phone__c))
                    prod.Codebtor_Phone_Other__c = '';

                listProd.add(prod);
                listCustomerStagingToUpdate.add(CustStaging);
            }
        }
        //Code modified to Show Exception and avoiding not to generate Success and Failure file 27-Dec-2022: Rasmitha
        try {
            // Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
            ProductTriggerHandler.runProductTrigger = false;
            List<Database.SaveResult> result = Database.update(listProd, false);
            ProductTriggerHandler.runProductTrigger = true;
            //Create Success and Error file
            /* DisplayCustomerContInfoStagingController.GenerateSuccessAndErrorFile(
                listCustomerStaging,
                listCustomerStaging[0].Document_Storage__r.Work_Assignment__c,
                portalSettings.Document_Storage_Default_Visibility__c,
                listCustomerStaging[0].Document_Storage__c
            ); */
        } catch (exception ex) {
            system.debug('exception Customer file catch--+--' + ex.getStackTraceString());
            for (Customer_Staging__c customerStaging : listCustomerStagingToUpdate) {
                String msg = '<b>ERROR</b>-' + ex.getMessage();
                if (msg.length() > 254) {
                    msg = msg.substring(0, 254);
                }
                customerStaging.Comment__c = msg;
                customerStaging.Status__c = 'Pending';
            }
        }
        if (listCustomerStagingToUpdate.size() > 0) {
            update listCustomerStagingToUpdate;
        }
        return productIdsToUpdate;
    }

    // Generate success and error excel sheets for successful and failed records
    public static void GenerateSuccessAndErrorFile(
        List<Customer_Staging__c> listCustomerStagingToUpdate,
        Id workAssignmentId,
        String visiblity,
        Id documentID
    ) {
        List<Customer_Staging__c> processedStagingRecords = new List<Customer_Staging__c>();
        String success;
        String failed;
        Integer successRecords = 0;
        Integer failedRecords = 0;

        success = 'data_id,pri_email,pri_add1,pri_add2,pri_municipality,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone';
        failed = 'data_id,pri_email,pri_add1,pri_add2,pri_municipality,pri_province,pri_postcode,pri_country,pri_hphone,pri_wphone,pri_cphone,sec_email,sec_add1,sec_add2,sec_municipality,sec_province,sec_postcode,sec_country,sec_wphone,sec_hphone,sec_cphone,error';

        for (Customer_Staging__c CustStaging : listCustomerStagingToUpdate) {
            if (CustStaging.Status__c != PROCESSED && CustStaging.Include_in_Processing__c == true) {
                CustStaging.Status__c = PROCESSED;
                processedStagingRecords.add(CustStaging);
                success += '\n';
                success +=
                    '\'' +
                    CustStaging.ProdID__c +
                    ',' +
                    CustStaging.Email_Address__c +
                    ',' +
                    CustStaging.Address_Line1__c +
                    ',' +
                    CustStaging.Address_Line2__c +
                    ',' +
                    CustStaging.City__c +
                    ',' +
                    CustStaging.State__c +
                    ',' +
                    CustStaging.Postal_Code__c +
                    ',' +
                    CustStaging.Country__c +
                    ',' +
                    CustStaging.Home_Phone__c +
                    ',' +
                    CustStaging.Work_Phone__c +
                    ',' +
                    CustStaging.Cell_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Email__c +
                    ',' +
                    CustStaging.Coborrower_Address1__c +
                    ',' +
                    CustStaging.Coborrower_Address2__c +
                    ',' +
                    CustStaging.Coborrower_City__c +
                    ',' +
                    CustStaging.Coborrower_State__c +
                    ',' +
                    CustStaging.Coborrower_Postal_Code__c +
                    ',' +
                    CustStaging.Coborrower_Country__c +
                    ',' +
                    CustStaging.Coborrower_Work_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Home_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Cell_Phone__c;
                successRecords = successRecords + 1;
            } else {
                failed += '\n';
                String CommentError;
                if (CustStaging.Comment__c != null) {
                    CommentError = CustStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>', '');
                    CommentError = CommentError.replaceAll('</b>', '');
                    CommentError = CommentError.replaceAll('<b>', '');
                }
                failed +=
                    '\'' +
                    CustStaging.ProdID__c +
                    ',' +
                    CustStaging.Email_Address__c +
                    ',' +
                    CustStaging.Address_Line1__c +
                    ',' +
                    CustStaging.Address_Line2__c +
                    ',' +
                    CustStaging.City__c +
                    ',' +
                    CustStaging.State__c +
                    ',' +
                    CustStaging.Postal_Code__c +
                    ',' +
                    CustStaging.Country__c +
                    ',' +
                    CustStaging.Home_Phone__c +
                    ',' +
                    CustStaging.Work_Phone__c +
                    ',' +
                    CustStaging.Cell_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Email__c +
                    ',' +
                    CustStaging.Coborrower_Address1__c +
                    ',' +
                    CustStaging.Coborrower_Address2__c +
                    ',' +
                    CustStaging.Coborrower_City__c +
                    ',' +
                    CustStaging.Coborrower_State__c +
                    ',' +
                    CustStaging.Coborrower_Postal_Code__c +
                    ',' +
                    CustStaging.Coborrower_Country__c +
                    ',' +
                    CustStaging.Coborrower_Work_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Home_Phone__c +
                    ',' +
                    CustStaging.Coborrower_Cell_Phone__c +
                    '"' +
                    ',' +
                    (CustStaging.Comment__c != null ? CommentError : null);

                failedRecords = failedRecords + 1;
            }
        }
        if (!processedStagingRecords.isEmpty()) {
            try {
                Database.update(processedStagingRecords);
            } catch (DmlException ex) {
                System.debug(ex.getDmlMessage(0));
            }
        }
        system.enqueueJob(
            new PostDocumentAPI(CUSTOMER_CONTACT_INFO_UPDATE, failed, success, failedRecords, successRecords, workAssignmentId, visiblity, documentID)
        );
    }

    public class customerContactInfoStagingWrapper {
        public Customer_Staging__c custStaging { get; set; }
        public boolean selected { get; set; }
        public boolean disabled { get; set; }
        public customerContactInfoStagingWrapper(Customer_Staging__c cust, Boolean disable) {
            custStaging = cust;
            selected = false;
            disabled = disable;
        }
    }
}
