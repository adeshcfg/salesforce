/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Product__c object 
*  @author : A5E Consulting
*  @date : 29/10/2021
*  Updates: 
1. BeforeInsert - Removed all except for phone formatting
2. handleBeforeUpdate - Removed all except for phone formatting, added logic for validation to check placmenthistory
3. Removed Commented code
4. Rearranged variable declaration to be at top
5. Renamed collectionAgency to mapCollectionAgency
*************************************************************************************************/
public class ProductTriggerHandler {
    //Line Break
    public static String ACCEPTED_BY_AGENCY_PLACEMENT_CODE = '100010';
    public static Id customerAccountRecordTypeId;

    public static String lBrk = '</br>';

    public static final String MANUAL_REVIEW_REASON = 'Multiple Matches';

    public static String profileName { get; set; }

    public static boolean runProductTrigger = true;
    public static boolean runProductAPITrigger = true;

    public static boolean runPaymentProcessing = true;

    public static boolean currentBalanceUpdate = true;

    public static boolean runProductAPI = true;

    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();

    public static Map<String, Data_Status_Mapping__c> dataStatusMap = Data_Status_Mapping__c.getAll();

    //public static Map<String, Id> mapCollectionAgency = new Map<String, Id>();
    public static Map<String, Placement__c> mapCollectionAgency = new Map<String, Placement__c>();
    
    public static Application_Config_Settings__c applConfSetting = Application_Config_Settings__c.getOrgDefaults();

    public static Map<Id, String> prodRecorTypeMap;

    public static Map<String, Id> prodRTypeIdMap = new Map<String, Id>();

    public static Map<Id, String> prodRTypeIdNameMap = new Map<Id, String>();

    //Stored  Field Name and Labels of Product__c FieldSet
    public static Map<String, String> fieldSetLabelNameMap = new Map<String, String>();

    //Map Customer Id with list of FDR, Megasys Products, used to check if any existing product presence for Customer
    public static Map<Id, List<Product__c>> customerWithOldProductsMap = new Map<Id, List<Product__c>>();

    // This is used whle creating task to get info about Customer, and also used to update Customer Address field
    public static Map<Id, Account> existingCustomer;

    //List of Customers which has Address field updates
    public static List<Account> customersToUpdate;

    // List of customer Id's used to fetch related Customer data, also used to fetch existing Tasks related to this Customers
    public static List<Id> customerIds = new List<Id>();

    // This gives exising active Task that has been created before for a Customer stating product updaes
    public static Map<Id, Task> activeAddressChangedTask = new Map<Id, Task>();

    // Used to store all new Tasks creating to notify CSR about Customer address field changes
    public static List<Task> tasksList;

    // Group Id of CSR Role users, used to assign new Tasks
    public static Set<Id> customersLockedForUpdate;

    //map of Placement Code and Placement Status
    public static map<String, Placement_Status_Code_Mapping__c> mapPlacementCodeStatus;

    //map of Placement Status and Placement Code
    public static map<String, String> mapPlacementStatus;

    public static map<String, Integer> mapPortfolioNamesCounter = new Map<String, Integer>();
    public static Map<String, Decimal> mapProductNameDetails = new Map<String, Decimal>();
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();
    //map of Placement Status and Placement Code
    public static Agency_Portal_Settings__c agencyPortalSettings;

    public static void UtilityMethod() {
        //fill Collection Agency Map
        list<Placement__c> list1 = [SELECT id, Name, Agency_Name__c, Serviceable_Province__c FROM Placement__c];
        for (Placement__c place : list1) {
            mapCollectionAgency.put(place.Name, place);
        }
        //Get profile Name
        profileName = Utilities.getUserProfile();

        //Get ProductRecordtype Id, Name Map
        prodRecorTypeMap = Utilities.getProdRecorTypeMap();
        customerAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Customer Salesforce' LIMIT 1].Id;

        for (RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c']) {
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
            prodRTypeIdNameMap.put(rType.Id, rType.name);
        }
        agencyPortalSettings = Agency_Portal_Settings__c.getOrgDefaults();

        //Tax rate mapping by Province Acronym
        for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
    }

    // 4951 - Get existing products having same name or record type
    public static Set<String> getMatchingProducts(List<Product__c> listNewProducts) {
        List<Product__c> duplicateCandidates = new List<Product__c>();
        Set<String> nameRecordTypeIdKey = new Set<String>();
        Set<String> names = new Set<String>();
        try {
            for (Product__c prod : listNewProducts) {
                names.add(prod.Name);
            }
            if (!names.isEmpty()) {
                duplicateCandidates = [SELECT Name, RecordTypeId FROM Product__c WHERE Name IN :names];
                for (Product__c product : duplicateCandidates) {
                    nameRecordTypeIdKey.add(product.RecordTypeId + '-' + product.Name);
                }
            }
        } catch (Exception ex) {
            System.debug('Exception in getMatchingProducts ' + ex.getStackTraceString());
        }
        return nameRecordTypeIdKey;
    }

    public static Set<String> getPlacementHistoryDetails(set<Id> setProductId) {
        set<Id> setPreviousPlacedProduct = new Set<Id>();
        map<Id, Id> mapAllProductAgency = new Map<Id, Id>();
        set<String> setProductAgencyName = new Set<String>();
        //Get Placement History for new Distressed Products
        if (Test.isRunningTest()) {
            List<Placement_History__c> placementHistory = [
                SELECT ID, Agency_Id__c, Product_Identifier__c
                FROM Placement_History__c
                WHERE Product__c IN :setProductId AND CreatedDate = LAST_N_DAYS:180
                LIMIT 1
            ];

            for (Placement_History__c platHistory : placementHistory) {
                //Combine Product name + Placement Agency
                setProductAgencyName.add(platHistory.Product_Identifier__c + platHistory.Agency_Id__c);
            }
        }
        if (!Test.isRunningTest()) {
            for (Placement_History__c placementHistory : [
                SELECT ID, Agency_Id__c, Product_Identifier__c
                FROM Placement_History__c
                WHERE Product__c IN :setProductId AND CreatedDate = LAST_N_DAYS:180
            ]) {
                //Combine Product name + Placement Agency
                setProductAgencyName.add(placementHistory.Product_Identifier__c + placementHistory.Agency_Id__c);
            }
        }
        return setProductAgencyName;
    }

    public static set<Id> getProductPaymentDetails(set<Id> setProductId) {
        set<Id> setRecentlyPaidProducts = new Set<Id>();
        List<Product_Payments__c> productPay = [
            SELECT ID, CCS_Account__c
            FROM Product_Payments__c
            WHERE CCS_Account__c IN :setProductId AND Payment_Posting_Date__c = LAST_N_DAYS:60
        ];
        for (Product_Payments__c prodPayment : productPay) {
            setRecentlyPaidProducts.add(prodPayment.CCS_Account__c);
        }
        return setRecentlyPaidProducts;
    }

    public static map<String, Placement_Status_Code_Mapping__c> getPlacementStatusCodes() {
        mapPlacementCodeStatus = new Map<String, Placement_Status_Code_Mapping__c>();
        mapPlacementStatus = new Map<String, String>();
        for (Placement_Status_Code_Mapping__c reasons : [
            SELECT Parent_Status__c, Placement_Status_Code__c, Status__c, Sub_Status__c, Complete_Status__c
            FROM Placement_Status_Code_Mapping__c
            ORDER BY Status__c
        ]) {
            mapPlacementCodeStatus.put(reasons.Placement_Status_Code__c, reasons);
            if (String.isNotBlank(reasons.Status__c)) {
                if (String.isBlank(reasons.Sub_Status__c)) {
                    reasons.Sub_Status__c = '';
                }
                mapPlacementStatus.put(reasons.Complete_Status__c, reasons.Placement_Status_Code__c);
            }
        }

        return mapPlacementCodeStatus;
    }

    //Handle before insert
    public static void handleBeforeInsert(List<Product__c> prodNew) {
        Boolean isCommunityUser = false;
        if (!Test.isRunningTest()) {
            UtilityMethod();
        }

        //Ticket 4558: Interest Waiver functionality checking Accuring Interest
        populateAccuringInterest(prodNew);

        //Ticket 4758: Populate Closed date on Distressed product based on product status
        calculateClosedDateOnDistressedProduct(prodNew);

        isCommunityUser = InsolvencyUtil.isCommunityUser();
        ID productSource;
        for (Product__c prodData : prodNew) {
            if (prodData.isClone() || Test.isRunningTest()) {
            if(Test.isRunningTest()){
                productSource = prodData.id;
            }else{
                productSource = prodData.getCloneSourceId();
            }                
                if (productSource <> null) {
                    Product__c prodCustomer1 = [
                        SELECT
                            id,
                            name,
                            Customer__c,
                            First_Name__c,
                            Last_Name__c,
                            Date_of_Birth__c,
                            SIN__c,
                            CID_number__c,
                            Phone_Home__c,
                            Phone_Work__c,
                            Phone_Other__c,
                            Address_Line1__c,
                            Address_Line2__c,
                            City__c,
                            Zip_Code__c,
                            Provinces__c,
                            Country__c,
                            Reason_for_Proposal__c,
                            Initial_Proposal_Date__c,
                            Second_Proposal_Date__c,
                            Third_Proposal_Date__c,
                            Fourth_Proposal_Date__c
                        FROM product__c
                        WHERE id = :productSource
                    ];
                    prodData.First_Name__c = prodCustomer1.First_Name__c;
                    prodData.Last_Name__c = prodCustomer1.Last_Name__c;
                    prodData.Date_of_Birth__c = prodCustomer1.Date_of_Birth__c;
                    prodData.SIN__c = prodCustomer1.SIN__c;
                    prodData.CID_number__c = prodCustomer1.CID_number__c;
                    prodData.Phone_Home__c = prodCustomer1.Phone_Home__c;
                    prodData.Phone_Work__c = prodCustomer1.Phone_Work__c;
                    prodData.Phone_Other__c = prodCustomer1.Phone_Other__c;
                    prodData.Address_Line1__c = prodCustomer1.Address_Line1__c;
                    prodData.Address_Line2__c = prodCustomer1.Address_Line2__c;
                    prodData.City__c = prodCustomer1.City__c;
                    prodData.Zip_Code__c = prodCustomer1.Zip_Code__c;
                    prodData.Provinces__c = prodCustomer1.Provinces__c;
                    prodData.Country__c = prodCustomer1.Country__c;
                    prodData.Reason_for_Proposal__c = prodCustomer1.Reason_for_Proposal__c;
                    prodData.Initial_Proposal_Date__c = prodCustomer1.Initial_Proposal_Date__c;
                    prodData.Second_Proposal_Date__c = prodCustomer1.Second_Proposal_Date__c;
                    prodData.Third_Proposal_Date__c = prodCustomer1.Third_Proposal_Date__c;
                    prodData.Fourth_Proposal_Date__c = prodCustomer1.Fourth_Proposal_Date__c;
                }
            }
            //Comminity user cannot create new record
            if (isCommunityUser) {
                if (!prodData.isClone()) {
                    productSource = prodData.getCloneSourceId();
                    if (productSource == null) {
                        prodData.addError('Please use Clone Button to Create New Record');
                    }
                }
            }
            //Ticket 7242 : interest rate should not be greater than 35% after 1 Jan 2025
            interestRateValidation(prodData,prodData.Interest_Rate__c,null);
            interestRateValidation(prodData,prodData.Current_Interest_Rate__c,null);
            interestRateValidation(prodData,prodData.Judgment_Rate__c,null);
        }

        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();

        getPlacementStatusCodes();
        Integer i = 0;
        Set<String> nameRecordTypeIdKey = ProductTriggerHandler.getMatchingProducts(prodNew);
        map<String, Decimal> mapAccountPurchaseGroupCount = new Map<String, Decimal>();
        set<String> setAccountPortfolioID = new Set<String>();
        List<ID> poolplacementName = new List<ID>();
        map<ID, Pool__c> mapPool = new Map<ID, Pool__c>();
        list<Product__c> listDistressedProduct = new List<Product__c>();

        for (Product__c prod : prodNew) {
            if (!nameRecordTypeIdKey.isEmpty() && nameRecordTypeIdKey.contains(prod.RecordTypeId + '-' + prod.Name)) {
                prod.addError(System.Label.Duplicate_Account_ID_Validation_Error);
            }
            //for Ticket 4834 - populating bank account number based on Account ID
            //Ticket 8546 -  Delete “Bank Account number” field.
            /*if (prod.name <> null) {
                prod.Bank_Refence_Number__c = prod.name;
            }*/

            //for Ticket 4895 - populating Payment Missed
            if (prod.Proposed_Payment_Amount__c <> null && prod.Proposed_Payment_Amount__c > 0 && prod.Amount_of_payments_missed__c <> null) {
                prod.Payment_Missed__c = (prod.Amount_of_payments_missed__c / prod.Proposed_Payment_Amount__c);
            }

            prod.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                prod.Last_Payment_Date__c,
                prod.Open_Date__c,
                prod.Charged_Off_Date__c,
                prod.Statute_Date__c,
                prod.Purchase_Province__c
            );
            if (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId && lrpSetting.EnableNewAccountNameCreationLogic__c == true) {
                if (prod.Purchase_ID_Formula__c != null) {
                    setAccountPortfolioID.add(String.valueof(prod.Purchase_ID_Formula__c));

                    if (mapPortfolioNamesCounter.containsKey(String.valueof(prod.Purchase_ID_Formula__c))) {
                        mapPortfolioNamesCounter.put(String.valueof(prod.Purchase_ID_Formula__c), mapPortfolioNamesCounter.get(String.valueof(prod.Purchase_ID_Formula__c)) + 1);
                    } else {
                        mapPortfolioNamesCounter.put(String.valueof(prod.Purchase_ID_Formula__c), 1);
                    }
                } else {
                    prod.addError('Account Portfolio ID is mandatory to populate Account ID');
                }
            }
            if (prod.Pool_Name__c != null) {
                poolplacementName.add(prod.Pool_Name__c);
            }
            //Ticket 8531 - default set donation rate to 8% for flexiti CCS account
            if(prodRTypeIdMap.get('Flexiti_CCS_Account') == prod.RecordTypeId){
                prod.Accepted_Donation_Rate__c = 8;
            }
        }

        for (Pool__c pool : [SELECT id, Name, Placement_Agency__c FROM Pool__c WHERE id IN :poolplacementName]) {
            mapPool.put(pool.id, pool);
        }

        Map<String, ID> mapProducNameIDS = new Map<String, ID>();
        for (Product_Name_Details__c prodName : [
            SELECT Id, Name, Last_Product_Number_in_the_Group__c
            FROM Product_Name_Details__c
            WHERE Name IN :setAccountPortfolioID
        ]) {
            mapProductNameDetails.put(prodName.Name, prodName.Last_Product_Number_in_the_Group__c);
            mapProducNameIDS.put(prodName.Name, prodName.ID);
        }

        for (Product__c prod : prodNew) {
            if (mapPool.containsKey(prod.Pool_Name__c)) {
                prod.Pool_Name_Text__c = mapPool.get(prod.Pool_Name__c).Name;
            }
            if (String.isNotBlank(prod.Placement_Status__c) && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)) {
                prod.Status__c =
                    mapPlacementCodeStatus.get(prod.Placement_Status__c).Parent_Status__c +
                    ' - ' +
                    mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                prod.Sub_Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Sub_Status__c;
            }

            if (
                String.isNotBlank(prod.Status__c) &&
                String.isNotBlank(prod.Sub_Status__c) &&
                mapPlacementStatus.containsKey(prod.Status__c + prod.Sub_Status__c)
            ) {
                prod.Placement_Status__c = mapPlacementStatus.get(prod.Status__c + prod.Sub_Status__c);
            }
            if (lrpSetting.Run_Product_Before_Trigger__c == true) {
                if (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId || prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId) {
                    prod.Run_Identifier_Check_On__c = Date.today();

                    //Data status mapping
                    if (String.isNotBlank(prod.product_status__C)) {
                        if (null != dataStatusMap.get(prod.product_status__C)) {
                            prod.Data_Status_Description__c = dataStatusMap.get(prod.product_status__C).Description__c;
                        } else {
                            prod.Data_Status_Description__c = '';
                        }
                        if (prod.Product_Status__c == '297000' || prod.Product_Status__c == '298000') {
                            prod.Purchase_Status__c = 'Buyback/Putback Initiated';
                            prod.Buyback_Putback_Status_Change_Date__c = System.today();
                        }
                    } else {
                        prod.Data_Status_Description__c = '';
                    }
                }

                //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
                if (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId) {
                    if (String.isNotBlank(String.valueOf(prod.Collection_Agency__c))) {
                        prod.Collection_Agency_Placement__c = mapCollectionAgency.get(String.valueOf(Math.floor(prod.Collection_Agency__c))).ID;
                    } else {
                        prod.Collection_Agency_Placement__c = null;
                    }
                    //Generate Product Name with Portfolio Number
                    //Count the no of products against purchase group:
                    listDistressedProduct.add(prod);

                    if (agencyPortalSettings.Run_Product_Name_Logic__c == true) {
                        String purchaseGroup = '';
                        if (prod.Purchase_ID_Formula__c != null) {
                            purchaseGroup = String.valueOf(prod.Purchase_ID_Formula__c);
                        }

                        Integer counterlength;
                        if (String.isNotBlank(purchaseGroup)) {
                            if (mapPortfolioNamesCounter.get(purchaseGroup) != null) {
                                counterlength = String.valueOf(mapPortfolioNamesCounter.get(purchaseGroup)).length();
                            }
                            if (mapProductNameDetails.containsKey(purchaseGroup)) {
                                Decimal counter = mapProductNameDetails.get(purchaseGroup);
                                Decimal Name1 = Math.floor(counter + 1);
                                if (lrpSetting.EnableNewAccountNameCreationLogic__c == true) {
                                    prod.Name = purchaseGroup + 'P' + String.valueOf(Name1).leftPad(counterlength, '0');
                                }
                                prod.DebtNext_Data_ID__c = prod.Name;
                                mapProductNameDetails.put(purchaseGroup, Name1);
                            } else {
                                mapProductNameDetails.put(purchaseGroup, 1);
                                String Name1 = '1';
                                if (lrpSetting.EnableNewAccountNameCreationLogic__c == true) {
                                    prod.Name = purchaseGroup + 'P' + String.valueOf(Name1).leftPad(counterlength, '0');
                                }
                                prod.DebtNext_Data_ID__c = prod.Name;
                            }
                        }
                    }
                }
            }

            // Added record type check for Loan Account OR Credit Card Account
            if (
                prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId ||
                prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId ||
                prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId
            ) {
                //Format Phone Numbers
                prod.Phone_Home__c = Utilities.formatPhone(prod.Phone_Home__c);
                prod.Phone_Other__c = Utilities.formatPhone(prod.Phone_Other__c);
                prod.Phone_Work__c = Utilities.formatPhone(prod.Phone_Work__c);
            }

            // Insolvency Product enhancements
            if (
                prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId ||
                prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId ||
                prodRTypeIdMap.get('GoEasy_CCS_Account') == prod.RecordTypeId ||
                prodRTypeIdMap.get('Flexiti_CCS_Account') == prod.RecordTypeId
            ) {
                if (String.isNotBlank(prod.Last_Name__c)) {
                    List<Account> matchingCustomers = getMatchingCustomers(prod);
                    if (matchingCustomers != null && matchingCustomers.size() > 0) {
                        if (matchingCustomers.size() > 1) {
                            prod.Needs_Manual_Review__c = true;
                            prod.Manual_Review_Reason__c = MANUAL_REVIEW_REASON;
                        }
                        prod.customer__c = matchingCustomers.get(0).Id;
                    }
                }
            }
        }

        list<Product_Name_Details__c> listProductNameToUpsert = new List<Product_Name_Details__c>();
        for (String portfolio : mapProductNameDetails.keySet()) {
            Product_Name_Details__c prodDetail = new Product_Name_Details__c();
            prodDetail.Name = portfolio;
            prodDetail.Last_Product_Number_in_the_Group__c = mapProductNameDetails.get(portfolio);
            if (mapProducNameIDS.containsKey(portfolio)) {
                prodDetail.ID = mapProducNameIDS.get(portfolio);
            }
            listProductNameToUpsert.add(prodDetail);
        }
        try {
            upsert listProductNameToUpsert;
        } catch (Exception ex) {
            system.debug('Exception ex' + ex);
        }
        //New code
        if (!Test.isRunningTest()) {
            runProductTrigger = false;
        }

        //old code    runProductTrigger = false;
    }

    //Handle before update
    public static void handleBeforeUpdate(List<Product__c> listNewProducts, Map<Id, Product__c> mapOldProducts) {
        UtilityMethod();
        //Ticket 4558: Interest Waiver functionality checking Accuring Interest
        populateAccuringInterest(listNewProducts);

        //Ticket 4758: Populate Closed date on Distressed product based on product status
        calculateClosedDateOnDistressedProduct(listNewProducts);

        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();

        getPlacementStatusCodes();

        Id DistressedProductRecordTypeId = prodRTypeIdMap.get('Distressed_Account');
        set<Id> setPreviousPlacedProduct = new Set<Id>();
        set<Id> setRecalledProducts = new Set<Id>();
        set<Id> setRecentlyPaidProducts = new Set<Id>();
        set<String> setPreviousPlacedProductNames = new Set<String>();
        list<Placement_History__c> listPlacementHistory = new List<Placement_History__c>();
        list<Product__c> listProductToUpdateBalance = new List<Product__c>();
        Map<id, Decimal> mapPoolAgency = new Map<id, Decimal>();
        Map<id, Pool__c> mapPool = new Map<id, Pool__c>();
        List<ID> poolplacementName = new List<ID>();
        Decimal checkCollectionAgency = null;

        //Fetch System Api
        List<User> systemName = new List<User>();
        if (lrpSetting.Canaccede_API_User__c != null) {
            systemName = [SELECT id, Name FROM User WHERE username = :lrpSetting.Canaccede_API_User__c];
        }
        //Fetch System Api
        if (lrpSetting.Run_Product_Before_Trigger__c == true) {
            Set<String> nameRecordTypeIdKey = ProductTriggerHandler.getMatchingProducts(listNewProducts);
            for (Product__c prod : listNewProducts) {
                Product__c prodOld1 = mapOldProducts.get(prod.id);
                if (
                    (prod.Name != prodOld1.Name || prod.RecordTypeId != prodOld1.RecordTypeId) &&
                    (!nameRecordTypeIdKey.isEmpty() && nameRecordTypeIdKey.contains(prod.RecordTypeId + '-' + prod.Name))
                ) {
                    prod.addError(System.Label.Duplicate_Account_ID_Validation_Error);
                }

                if (prod.Refer_to_Legal__c == 'Approved' && prodOld1.Refer_to_Legal__c != prod.Refer_to_Legal__c) {
                    Application_Config_Settings__c config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
                    config.Run_Product_Coll_Sub_Status_Validation__c = false;
                    update config;
                    prod.Collection_Sub_Status__c = 'Legal';
                    prod.Previously_Reviewed_for_Legal_Action__c = true;
                }

                if (prodOld1.Status__c != null) {
                    //Ticket 6993: commented Refer_to_Legal__c == 'For Review' condition.
                    if (
                        (prodOld1.Status__c.startsWith('Pre - Legal') && prod.Status__c != prodOld1.Status__c) ||
                        /*(prodOld1.Refer_to_Legal__c == 'For Review' &&
                        prod.Status__c != prodOld1.Status__c) ||*/
                        (prodOld1.Status__c.startsWith('Pre - Legal') && prod.Sub_Status__c != prodOld1.Sub_Status__c)
                    ) {
                        prod.addError('Status can not change if refer to legal is in For review/placement status is in Pre-Legal.');
                    }
                }
                //for Ticket 4834 - populating bank account number based on Account ID
                //Ticket 8546 -  Delete “Bank Account number” field.
                /*if (prod.name <> null) {
                    prod.Bank_Refence_Number__c = prod.name;
                }*/
                //for Ticket 4895 - populating Payment Missed
                if (prod.Proposed_Payment_Amount__c <> null && prod.Proposed_Payment_Amount__c > 0 && prod.Amount_of_payments_missed__c <> null) {
                    prod.Payment_Missed__c = (prod.Amount_of_payments_missed__c / prod.Proposed_Payment_Amount__c);
                }

                if (isCanaccedeAPIUser() || Test.isRunningTest()) {
                    // Added record type check for Loan Account OR Credit Card Account
                    if (
                        prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId ||
                        prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId ||
                        prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId ||
                        Test.isRunningTest()
                    ) {
                        prod.Phone_Home__c = Utilities.formatPhone(prod.Phone_Home__c);
                        prod.Phone_Other__c = Utilities.formatPhone(prod.Phone_Other__c);
                        prod.Phone_Work__c = Utilities.formatPhone(prod.Phone_Work__c);
                    }

                    //Old Product values
                    Product__c prodOld = mapOldProducts.get(prod.id);
                    Id oldCustomerId = prodOld.customer__c;

                    // Check if product is Insolvency Account / Distressed_Account or not
                    //if(prodRTypeIdMap.get('Insolvency_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId)
                    if (
                        prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId ||
                        prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId ||
                        prodRTypeIdMap.get('GoEasy_CCS_Account') == prod.RecordTypeId ||
                        prodRTypeIdMap.get('Flexiti_CCS_Account') == prod.RecordTypeId
                    ) {
                        if (prod.customer__c == null) {
                            if (oldCustomerId != null) {
                                prod.customer__c = oldCustomerId;
                            } else {
                                if (String.isNotBlank(prod.Last_Name__c)) {
                                    List<Account> matchingCustomers = getMatchingCustomers(prod);
                                    if (matchingCustomers != null && matchingCustomers.size() > 0) {
                                        if (matchingCustomers.size() > 1) {
                                            prod.Needs_Manual_Review__c = true;
                                            prod.Manual_Review_Reason__c = MANUAL_REVIEW_REASON;
                                        }
                                        prod.customer__c = matchingCustomers.get(0).Id;
                                    }
                                }
                            }
                        }
                    }
                }
                if (prod.Pool_Name__c != null) {
                    poolplacementName.add(prod.Pool_Name__c);
                }

                //check if collection agency is changed for Distressed or recordtype is changed to CCS Account
                if (
                    (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId &&
                    prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c) ||
                    (prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId &&
                    prod.RecordTypeId != mapOldProducts.get(prod.Id).RecordTypeId)
                ) {
                    prod.Run_Identifier_Check_On__c = Date.today();
                }

                if (
                    prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId &&
                    prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c
                ) {
                    Id oldOwnerId = mapOldProducts.get(prod.Id).OwnerId;
                    // Assign System API to Owner
                    if (!systemName.isEmpty()) {
                        prod.OwnerId = systemName[0].Id;
                    }

                    //Also Assign the last owner to the previous ownership field
                    if (oldOwnerId != prod.OwnerId && oldOwnerId != null) {
                        prod.Previous_Ownership__c = oldOwnerId;
                    }
                }

                if (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId) {
                    if (prod.Purchase_Status__c != prodOld1.Purchase_Status__c && prod.Purchase_Status__c == DisplayBuybackPutbackStagingController.BUYBACK_APPROVED) {
                        prod.Buyback_Putback_Status_Change_Date__c = System.today();
                        prod.Putback_buyback_Completed_Date__c = System.today();
                        prod.Product_Status__c = prodOld1.Product_Status__c.replaceFirst('2', '9');
                    }
                    //Data status mapping
                    if (String.isNotBlank(prod.product_status__c) && prodOld1.Product_Status__c != prod.Product_Status__c) {
                        if (null != dataStatusMap.get(prod.product_status__C)) {
                            prod.Data_Status_Description__c = dataStatusMap.get(prod.product_status__C).Description__c;
                        } else {
                            prod.Data_Status_Description__c = '';
                        }
                        if (prod.Product_Status__c == '297000' || prod.Product_Status__c == '298000') {
                            prod.Purchase_Status__c = 'Buyback/Putback Initiated';
                            prod.Buyback_Putback_Status_Change_Date__c = System.today();
                        }
                    } else {
                        prod.Data_Status_Description__c = '';
                    }
                }

                //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
                if (prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId) {
                    //Data status mapping
                    if (
                        String.isNotBlank(String.ValueOf(prod.Collection_Agency__c)) &&
                        mapCollectionAgency.containsKey(String.ValueOf(Math.floor(prod.Collection_Agency__c)))
                    ) {
                        prod.Collection_Agency_Placement__c = mapCollectionAgency.get(String.ValueOf(Math.floor(prod.Collection_Agency__c))).ID;
                    } else {
                        prod.Collection_Agency_Placement__c = null;
                    }
                }
                //If Placement STatus code is updated, update Main Status and SUb Status
                if (
                    String.isNotBlank(prod.Placement_Status__c) &&
                    mapOldProducts.get(prod.ID).Placement_Status__c != prod.Placement_Status__c &&
                    mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)
                ) {
                    //Updated the prod.Status__c for ticket 2877
                    prod.Status__c =
                        mapPlacementCodeStatus.get(prod.Placement_Status__c).Parent_Status__c +
                        ' - ' +
                        mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                    prod.Sub_Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Sub_Status__c;
                }

                //if status and sub status is updated, update placement status code
                if (mapOldProducts.get(prod.ID).Status__c != prod.Status__c || mapOldProducts.get(prod.ID).Sub_Status__c != prod.Sub_Status__c) {
                    String placeStatus = prod.Status__c;
                    if (String.isNotBlank(prod.Sub_Status__c)) {
                        placeStatus += ' - ' + prod.Sub_Status__c;
                    }
                    if (String.isNotBlank(placeStatus) && mapPlacementStatus.containsKey(placeStatus)) {
                        prod.Placement_Status__c = mapPlacementStatus.get(placeStatus);
                    }
                    if (prod.Placement_Status__c == ACCEPTED_BY_AGENCY_PLACEMENT_CODE && prod.Invalid_Submission__c == true) {
                        prod.Invalid_Submission__c = false;
                        prod.Timestamp_Of_Invalid_Submission__c = null;
                        prod.Invalid_Submission_Reason__c = null;
                    }
                }

                //Recall Collection agency if status is back/put back and sale categories: agency portal change
                if (prod.Collection_Sub_Status__c == 'Buy back/put back and sale categories') {
                    prod.Collection_Agency__c = null;
                }

                if (prod.RecordTypeId == DistressedProductRecordTypeId) {
                    //Check if Placement Agency on Product is updated
                    if (
                        prod.Collection_Agency__c != null &&
                        mapOldProducts.get(prod.Id).Collection_Agency__c != null &&
                        prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c
                    ) {
                        setPreviousPlacedProduct.add(prod.Id);
                    }
                    //Check if agency is recalled
                    if (prod.Collection_Agency__c == null && mapOldProducts.get(prod.Id).Collection_Agency__c != null) {
                        setRecalledProducts.add(prod.Id);
                    }
                }

                //process builder 'Refer to legal' convert into code for agency portal changes
                if ((prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c && prod.Refer_to_Legal__c == 'For Review')) {
                    prod.Sent_for_Review_by__c = UserInfo.getName();
                    prod.Sent_to_Review_Date__c = System.now();
                    prod.Placement_Status__c = '210000';
                    prod.Status__c = 'Pre - Legal - In Process';
                    prod.Sub_Status__c = 'Recommended for Legal Action';
                } else if (prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c && (prod.Refer_to_Legal__c == 'Approved')) {
                    prod.Legal_Decision_Date__c = System.now();
                    prod.Legal_Decision_by__c = UserInfo.getUserId();
                    prod.Placement_Status__c = '210010';
                    prod.Status__c = 'Pre - Legal - In Process';
                    prod.Sub_Status__c = 'Approved for Legal Action';
                } else if (prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c && prod.Refer_to_Legal__c == 'Declined') {
                    prod.Legal_Decision_Date__c = System.now();
                    prod.Legal_Decision_by__c = UserInfo.getUserId();
                    prod.Placement_Status__c = '210910';
                    prod.Status__c = 'Pre - Legal - Inactive';
                    prod.Sub_Status__c = 'Legal Action Rejected';
                }

                Product__c prodOld = mapOldProducts.get(prod.Id);

                //Interest Rate on Product changed to 0% when updating insolvency information
                //RemoveprodOld.Insolvency_Date__c == null && prod.Insolvency_Date__c != null for ticket 4599
                if (prodOld.Deceased_Date__c == null && prod.Deceased_Date__c != null) {
                    if (prod.Interest_Rate__c != 0) {
                        prod.Previous_Interest_Rate__c = prod.Interest_Rate__c;
                        prod.Interest_Rate__c = 0;
                    }
                    if (prod.Deceased_Date__c != null) {
                        prod.Collection_Sub_Status__c = 'Deceased';
                    }
                }
                //if Credit Counselling Date is added
                if (
                    (prodOld.Credit_Counselling_Date__c == null && prod.Credit_Counselling_Date__c != null) &&
                    (prodOld.Interest_Rate__c <> prod.Interest_Rate__c)
                ) {
                    prod.Previous_Interest_Rate__c = prodOld.Interest_Rate__c;
                    prod.Collection_Sub_Status__c = 'Credit Counselling';
                }
            }

            for (Pool__c pool : [SELECT id, Name, Placement_Agency__c FROM Pool__c WHERE id IN :poolplacementName]) {
                mapPoolAgency.put(pool.id, pool.Placement_Agency__c);
                mapPool.put(pool.id, pool);
            }

            if (ProductTriggerHandler.runPaymentProcessing) {
                setRecentlyPaidProducts = getProductPaymentDetails(setRecalledProducts);
                setPreviousPlacedProductNames = getPlacementHistoryDetails(setPreviousPlacedProduct);
            }

            String newAgency;
            String oldAgency;

            for (Product__c product : listNewProducts) {
                //Ticket 7242 : interest rate should not be greater than 35% after 1 Jan 2025
                interestRateValidation(product,product.Interest_Rate__c,mapOldProducts.get(product.Id).Interest_Rate__c);
                interestRateValidation(product,product.Current_Interest_Rate__c,mapOldProducts.get(product.Id).Current_Interest_Rate__c);
                interestRateValidation(product,product.Judgment_Rate__c,mapOldProducts.get(product.Id).Judgment_Rate__c);
                
                // Last Payment Date Changed
                if (product.Last_Payment_Date__c != mapOldProducts.get(product.Id).Last_Payment_Date__c) {
                    product.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                        product.Last_Payment_Date__c,
                        product.Open_Date__c,
                        product.Charged_Off_Date__c,
                        product.Statute_Date__c,
                        product.Purchase_Province__c
                    );
                }
                // Open Date Changed
                else if (product.Open_Date__c != mapOldProducts.get(product.Id).Open_Date__c) {
                    product.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                        product.Last_Payment_Date__c,
                        product.Open_Date__c,
                        product.Charged_Off_Date__c,
                        product.Statute_Date__c,
                        product.Purchase_Province__c
                    );
                }
                //ChargeOff Date Changed
                else if (product.Charged_Off_Date__c != mapOldProducts.get(product.Id).Charged_Off_Date__c) {
                    product.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                        product.Last_Payment_Date__c,
                        product.Open_Date__c,
                        product.Charged_Off_Date__c,
                        product.Statute_Date__c,
                        product.Purchase_Province__c
                    );
                }
                if (mapPool.containsKey(product.Pool_Name__c)) {
                    product.Pool_Name_Text__c = mapPool.get(product.Pool_Name__c).Name;
                }

                Product__c prodOld = mapOldProducts.get(product.id);

                if (
                    mapPoolAgency.containsKey(product.Pool_Name__c) &&
                    mapPoolAgency.get(product.Pool_Name__c) != null &&
                    prodOld.Pool_Name__c <> product.Pool_Name__c &&
                    product.Collection_Agency__c != null &&
                    mapPoolAgency.get(product.Pool_Name__c) <> product.Collection_Agency__c
                ) {
                    product.addError('Pool has different agency than Product');
                }
                if (product.Purchase_Status__c != prodOld.Purchase_Status__c) {
                    if (
                        prodOld.Purchase_Status__c == 'Buyback/Putback Approved' && product.Purchase_Status__c == 'Buyback/Putback Initiated'
                    ) {
                        product.addError('You cannot assign previous status');
                    }
                }
                if (product.Purchase_Status__c == 'Buyback/Putback Approved' && product.Collection_Agency__c != null && product.Collection_Agency__c != 9999) {
                    product.addError('Buyback/Putback status is approved.You cannot assign agency ');
                }
                if (
                    (product.Collection_Agency__c != null && product.Collection_Agency__c != 9999) &&
                    ((product.Purchase_Status__c != null) &&
                    product.Purchase_Status__c != 'Buyback/Putback Rejected')
                ) {
                    product.addError('Please initiated recall process');
                }
                if (product.Collection_Agency__c != null) {
                    newAgency = String.valueOf(Math.floor(product.Collection_Agency__c));
                }
                if (mapOldProducts.get(product.Id).Collection_Agency__c != null) {
                    oldAgency = String.valueOf(Math.floor(mapOldProducts.get(product.Id).Collection_Agency__c));
                }

                String errorMessage = '';
                Boolean errorAdded = false;

                if (errorAdded == true) {
                    product.addError(errorMessage);
                }

                //create PlacementHistory record, if agency updated or recalled (No error added for product)
                if (errorAdded == false && newAgency != oldAgency) {
                    Placement_History__c placementHistory = new Placement_History__c();
                    placementHistory.Product__c = product.Id;
                    if (mapCollectionAgency.containsKey(oldAgency)) {
                        placementHistory.Placement__c = mapCollectionAgency.get(oldAgency).ID;
                    }
                    if (String.isBlank(newAgency) || Test.isRunningTest()) {
                        placementHistory.Placement_Recall_Date__c = Date.today();
                        placementHistory.Placement_Date__c = product.Assignment_Date__c;
                        if (product.Current_Balance__c != null) {
                            placementHistory.Current_Total_Bal_at_time_of_Recall__c = product.Current_Balance__c;
                        }
                        //Set Product Recalled Date
                        product.Recalled_Date__c = Date.today();
                    }
                    //Else set Assigned Date
                    else {
                        product.Assignment_Date__c = Date.today();
                    }
                    listPlacementHistory.add(placementHistory);
                }

                //Set Ignore Warning to false after all checks
                errorAdded = false;
            }
            //insert placement history list
            insert listPlacementHistory;
        }
    }

    public static void handleAfterUpdate(List<Product__c> listNewProducts, map<ID, Product__c> mapOldProducts) {
        //Added code for CPU Time Limit
        //runProductTrigger = false;
        //Code Ends
        //This below custom setting is false in before update so true that here.
        Application_Config_Settings__c config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        update config;
        list<id> prodIds = new List<id>();
        List<Product__c> productListToCreateJudgment = new List<Product__c>();
        List<String> legalProdIds = new List<String>();
        Map<String, Account_Judgment__c> activeJudgmentMap = new Map<String, Account_Judgment__c>();

        for (Product__c product : listNewProducts) {
            Product__c prodOld = mapOldProducts.get(product.id);
            // Create Judgment records if refer to legal approved
            if (product.Refer_to_Legal__c == 'Approved' && prodOld.Refer_to_Legal__c != product.Refer_to_Legal__c) {
                // creatJudgment(product);
                legalProdIds.add(product.Id);
                productListToCreateJudgment.add(product);
            }
            //call API
            if (agencyPortalSettings.Run_Product_API__c == true && prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId) {
                prodIds.add(product.ID);
            }
        }
        for (Account_Judgment__c accJudg : [SELECT id, product__c FROM Account_Judgment__c WHERE product__c IN :legalProdIds AND Status__C = 'Active']) {
            activeJudgmentMap.put(accJudg.Product__c, accJudg);
        }

        for (Product__c prodLegal : productListToCreateJudgment) {
            if (prodLegal.Purchase_Province__c == null) {
                prodLegal.addError('Product Province is required');
            }
            if (activeJudgmentMap.containsKey(prodLegal.Id)) {
                prodLegal.addError('Active Judgment is present on this account');
            }
        }
        //Bug: 5142 - Added !system.isBatch() to below IF loop
        if (runProductAPITrigger && !system.isBatch()) {
            PortalProductProcessingAPI.processProductBulkBatch(prodIds, productListToCreateJudgment);
        }
        calculateBalanceBackdatedPayments2(listNewProducts, mapOldProducts);
    }

    public static void handleAfterUpdateUpdatedate(List<Product__c> listNewProducts, map<ID, Product__c> mapOldProducts) {
        List<Product__c> ProductList = new List<Product__c>();
        Product__c pd = new Product__c();
        List<Statute_Date_Update__mdt> mtData = [SELECT Id, MasterLabel, Months__c FROM Statute_Date_Update__mdt];

        for (Product__c prod : listNewProducts) {
            Product__c prodOld12 = mapOldProducts.get(prod.Id);

            if (
                (prod.Last_Payment_Date__c != null && prod.Last_Payment_Date__c != prodOld12.Last_Payment_Date__c) ||
                (prod.Open_Date__c != null && (prod.Open_Date__c != prodOld12.Open_Date__c))
            ) {
                if ((prod.Statute_Date__c == null) || (prod.Statute_Date__c != null && prod.Statute_Date__c > prod.Date_for_Stat_Barred_calculations__c)) {
                    Map<String, Statute_Date_Update__mdt> mtdMap = new Map<String, Statute_Date_Update__mdt>();
                    for (Statute_Date_Update__mdt m : mtData) {
                        mtdMap.put(m.MasterLabel, m);
                    }

                    if (mtdMap.containsKey(prod.State__c)) {
                        Integer i = Integer.valueof(mtdMap.get(prod.State__c).Months__c);
                        pd.Id = prod.Id;
                        pd.Statute_Date__c = prod.Date_for_Stat_Barred_calculations__c.addMonths(i);
                        ProductList.add(pd);
                    }
                }
            }
        }
        if (!ProductList.isEmpty()) {
            update ProductList;
        }
    }

    public static void handleafterinsertdate(List<Product__c> listNewProducts) {
        runProductTrigger = true;
        List<Product__c> ProductList = new List<Product__c>();
        Map<String, Statute_Date_Update__mdt> mtdMap = new Map<String, Statute_Date_Update__mdt>();
        List<Statute_Date_Update__mdt> mtData = [SELECT Id, MasterLabel, Months__c FROM Statute_Date_Update__mdt];
        for (Statute_Date_Update__mdt m : mtData) {
            mtdMap.put(m.MasterLabel, m);
        }

        for (Product__c prod : listNewProducts) {
            if ((prod.Last_Payment_Date__c != null) || (prod.Open_Date__c != null)) {
                if (mtdMap.containskey(prod.State__c)) {
                    Product__c pd = new Product__c();
                    Integer i = Integer.valueof(mtdMap.get(prod.State__c).Months__c);
                    pd.Id = prod.Id;

                    pd.Statute_Date__c = prod.Date_for_Stat_Barred_calculations__c.addMonths(i);
                    ProductList.add(pd);
                }
            }
        }

        if (!ProductList.isEmpty()) {
            update ProductList;
        }
    }
    public static void handleAferInsertUpdate(List<Product__c> prodNew, Map<Id, Product__c> oldMap, Boolean isInsert) {
        customersToUpdate = new List<Account>();
        //Added code CPU Time Limit
        runProductTrigger = false;
        //Code ends
        if (lrpSetting.Load_Customer_Data__c == true) {
            // User verification to update Customer Address Fields
            if (isCanaccedeAPIUser() || Test.isRunningTest()) {
                customersLockedForUpdate = new Set<Id>();
                tasksList = new List<Task>();

                //Process all new instance of Products in context
                for (Product__c prod : prodNew) {
                    // Added record type check for Loan Account OR Credit Card Account
                    if (prod.Customer__c != null) {
                        if ((prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId)) {
                            customerIds.add(prod.Customer__c);
                        }
                    }
                }
                if (!customerIds.isEmpty()) {
                    existingCustomer = new Map<Id, Account>(
                        [
                            SELECT
                                Id,
                                OwnerId,
                                PersonMailingCity,
                                PersonMailingStreet,
                                PersonMailingPostalCode,
                                PersonMailingState,
                                PersonBirthdate,
                                PersonHomePhone,
                                Work_Phone__pc,
                                PersonOtherPhone,
                                Address_Last_Changed_Date__c,
                                FirstName,
                                LastName
                            FROM Account
                            WHERE Id IN :customerIds
                        ]
                    );
                }

                //Fetching all Active Tasks of Customers in current context
                if (!customerIds.isEmpty()) {
                    for (Task tsk : [
                        SELECT WhatId, Subject, Status
                        FROM Task
                        WHERE Subject = 'Address Changed' AND Status != 'Completed' AND WhatId IN :customerIds
                    ]) {
                        activeAddressChangedTask.put(tsk.WhatId, tsk);
                    }
                }

                //Fetching all Active Products of Customers
                if (!customerIds.isEmpty()) {
                    for (Product__c customerOldProduct : [
                        SELECT First_Name__c, Last_Name__c, Customer__c
                        FROM Product__c
                        WHERE
                            ((Source_System__c = 'FDR'
                            AND External_Status_Current__c = NULL
                            AND Closed_Date__c = NULL)
                            OR (Source_System__c = 'Megasys'
                            AND Internal_Status__c = 'Active'
                            AND Closed_Date__c = NULL))
                            AND Customer__c IN :customerIds
                    ]) {
                        List<Product__c> tempProdList = new List<Product__c>();
                        if (customerWithOldProductsMap.containsKey(customerOldProduct.Customer__c)) {
                            tempProdList = customerWithOldProductsMap.get(customerOldProduct.Customer__c);
                        }
                        tempProdList.add(customerOldProduct);
                        customerWithOldProductsMap.put(customerOldProduct.Customer__c, tempProdList);
                    }
                }

                for (Product__c prod : prodNew) {
                    if (prod.Customer__c != null) {
                        if ((prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId)) {
                            // If FDR or Megasys product is Active or Not
                            if (isActiveSORProduct(prod)) {
                                if ((isInsert) || (!isInsert && hasProductCustomerDataChanged(prod, oldMap.get(prod.Id)))) {
                                    //If any existing Products, more than 1
                                    if (getNumberOfActiveSORProducts(prod.Customer__c) > 1) {
                                        // Address fields are changed
                                        if (!hasActiveAddressChangedTask(prod)) {
                                            // Address fields values from Product is different Customer Address fields values
                                            if (needtoUpdateCustomer(prod)) {
                                                // Update Customer Address fields
                                                updateCustomerFromProduct(prod);

                                                // Create Task for CSR Role users
                                                createAddressChangedTask(prod);
                                            }
                                        }
                                    }
                                    //Only one active SOR Products
                                    else {
                                        if (needtoUpdateCustomer(prod)) {
                                            updateCustomerFromProduct(prod);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (!tasksList.isEmpty()) {
                    // Inserting Tasks for CSR Role Group
                    insert tasksList;
                }
            }
        }

        //for Business Separation moved it outside
        if (!customersToUpdate.isEmpty()) {
            Map<Id, Account> mapAccount = new Map<ID, Account>();

            for (Account accRec : customersToUpdate) {
                mapAccount.put(accRec.id, accRec);
            }
            // Updating Customers Address
            update mapAccount.Values();
        }

        if (!isInsert && oldMap != null) {
            List<Id> prodIds = new List<Id>();
            List<Id> productNameChanged = new List<Id>();

            for (Product__c prod : prodNew) {
                Product__c oldProd = oldMap.get(prod.Id);
                if (
                    oldProd.Current_Principal_Balance__c != prod.Current_Principal_Balance__c ||
                    oldProd.Current_Interest_Amount__c != prod.Current_Interest_Amount__c
                ) {
                    prodIds.add(prod.Id);
                } else if (oldProd.Company_Name__c != prod.Company_Name__c) {
                    productNameChanged.add(prod.Id);
                }
            }
            if (productNameChanged.size() > 0) {
                prodIds.addAll(productNameChanged);
            }
            if (!prodIds.isEmpty()) {
                List<Account_Judgment__c> activeAccJudgments = [
                    SELECT Judgment__c
                    FROM Account_Judgment__c
                    WHERE Product__c IN :prodIds AND Status__c = 'Active' AND Judgment__c != NULL
                ];
                if (!activeAccJudgments.isEmpty()) {
                    AccountJudgmentTriggerHandler.updateAmountsOnJudgment(activeAccJudgments);
                }
            }
        }
    }

    // Validates if there is any existing Active Tasks for Customer
    public static Boolean hasActiveAddressChangedTask(Product__c currentProd) {
        if (activeAddressChangedTask.containsKey(currentProd.Customer__c)) {
            return true;
        }
        return false;
    }

    // Creating Tasks with Customer Name, to notify CSR's about address change
    public static void createAddressChangedTask(Product__c currentProd) {
        Account customer = existingCustomer.get(currentProd.Customer__c);
        Task tsk = new Task();
        tsk.WhatId = currentProd.Customer__c;
        tsk.subject = 'Address Changed';
        tsk.OwnerId = UserInfo.getUserId();
        tsk.Description = 'This customer was updated by ' + currentProd.Name + ' from ' + currentProd.Source_System__C + '.';
        tasksList.add(tsk);
    }

    //Updating Customer Address fields
    public static void updateCustomerFromProduct(Product__c currentProd) {
        Account customer = existingCustomer.get(currentProd.Customer__c);
        customer.PersonMailingCity = currentProd.City__c;
        if (String.isBlank(currentProd.Address_Line2__c)) {
            customer.PersonMailingStreet = currentProd.Address_Line1__c;
        } else {
            customer.PersonMailingStreet = currentProd.Address_Line1__c + ' ' + currentProd.Address_Line2__c;
        }
        customer.PersonMailingPostalCode = currentProd.Zip_Code__c;
        customer.PersonMailingState = currentProd.State__c;
        customer.PersonBirthdate = currentProd.Date_of_Birth__c;
        customer.PersonHomePhone = currentProd.Phone_Home__c;
        customer.Work_Phone__pc = currentProd.Phone_Work__c;
        customer.PersonOtherPhone = currentProd.Phone_Other__c;
        customer.FirstName = currentProd.First_Name__c;
        customer.LastName = currentProd.Last_Name__c;
        customer.Address_Last_Changed_Date__c = currentProd.Address_Last_Changed_Date__c;

        if (!customersLockedForUpdate.contains(currentProd.Customer__c)) {
            customersToUpdate.add(customer);
        }

        customersLockedForUpdate.add(currentProd.Customer__c);
    }

    // Method that fetches the Customer record using customer record id
    public static Account getCustomerRecord(Id customerId) {
        return existingCustomer.get(customerId);
    }

    // Verifying Product fields against Customer Address fields
    public static Boolean needtoUpdateCustomer(Product__c currentProd) {
        Boolean needToUpdate = false;
        Account customer = getCustomerRecord(currentProd.Customer__c);
        if (customer.PersonMailingCity != currentProd.City__c) {
            needToUpdate = true;
        } else if (
            (String.isBlank(customer.PersonMailingStreet) &&
            ((String.isNotBlank(currentProd.Address_Line1__c)) || (String.isNotBlank(currentProd.Address_Line2__c)))) ||
            ((String.isNotBlank(customer.PersonMailingStreet) &&
            String.isNotBlank(currentProd.Address_Line1__c) &&
            (!(customer.PersonMailingStreet).contains(currentProd.Address_Line1__c))) ||
            (String.isNotBlank(customer.PersonMailingStreet) &&
            String.isNotBlank(currentProd.Address_Line2__c) &&
            (!(customer.PersonMailingStreet).contains(currentProd.Address_Line2__c))))
        ) {
            needToUpdate = true;
        } else if (customer.PersonMailingPostalCode != currentProd.Zip_Code__c) {
            needToUpdate = true;
        } else if (customer.PersonMailingState != currentProd.State__c) {
            needToUpdate = true;
        } else if (customer.PersonBirthdate != currentProd.Date_of_Birth__c) {
            needToUpdate = true;
        } else if (customer.PersonHomePhone != currentProd.Phone_Home__c) {
            needToUpdate = true;
        } else if (customer.Work_Phone__pc != currentProd.Phone_Work__c) {
            needToUpdate = true;
        } else if (customer.PersonOtherPhone != currentProd.Phone_Other__c) {
            needToUpdate = true;
        } else if (customer.FirstName != currentProd.First_Name__c) {
            needToUpdate = true;
        } else if (customer.LastName != currentProd.Last_Name__c) {
            needToUpdate = true;
        }
        return needToUpdate;
    }

    //Return count of total Active FDR, Megasys Products using Customer record Id
    public static Integer getNumberOfActiveSORProducts(Id customerId) {
        return customerWithOldProductsMap.get(customerId).size();
    }

    // Checks against Old Address values and New Address values of Product
    public static Boolean hasProductCustomerDataChanged(Product__c newProd, Product__c oldProd) {
        Boolean isChanged = false;
        fieldSetLabelNameMap = getProductFieldsets('Update Customer Fields');
        for (String fieldName : fieldSetLabelNameMap.keySet()) {
            if (newProd.get(fieldName) != oldProd.get(fieldName)) {
                return true;
            }
        }
        return isChanged;
    }

    //Checkes whether the Product is Active or not using Product record
    public static Boolean isActiveSORProduct(Product__c prod) {
        if (
            (prod.Source_System__c == 'FDR' && prod.External_Status_Current__c == null && prod.Closed_Date__c == null) ||
            (prod.Source_System__c == 'Megasys' &&
            prod.Internal_Status__c == 'Active' &&
            prod.Closed_Date__c == null)
        ) {
            return true;
        }
        return false;
    }

    //Checkes whether the Megasys Product is Active or not
    public static Boolean isActiveMSProduct(Product__c prod) {
        return (prod.Internal_Status__c == 'Active' && prod.Closed_Date__c == null);
    }

    //Deliquency cycle and Deliquency days
    public static void calculateDeliquency(Product__c prod, Product__c prodOld, Boolean activeVersaPayPayment) {
        if (prod.recordTypeId != null) {
            String recordTypeDevName = prodRecorTypeMap.get(prod.recordTypeId);
            if (String.isNotBlank(recordTypeDevName)) {
                if (recordTypeDevName.equalsIgnoreCase('Loan_Account')) {
                    if (isActiveMSProduct(prod)) {
                        if (prod.Payment_Due_Date__c != null) {
                            prod.Delinquency_Days__c = Utilities.getNumberOfDaysDelinquent(prod.Payment_Due_Date__c);
                            prod.Delinquency_Cycles__c = Utilities.getNumberOfCyclesDelinquentMS(prod.Delinquency_Days__c, activeVersaPayPayment);
                        } else {
                            if (prodOld != null) {
                                prod.Delinquency_Days__c = prodOld.Delinquency_Days__c;
                                prod.Delinquency_Cycles__c = prodOld.Delinquency_Cycles__c;
                            }
                        }
                    } else {
                        prod.Delinquency_Days__c = null;
                        prod.Delinquency_Cycles__c = null;
                    }
                }
            }
        }
    }

    //VersaPay Payment list
    public static List<VersaPay_Product_Payment__c> versaPayRecords(List<Product__c> listProd) {
        return [
            SELECT Id, Name, Product__c
            FROM VersaPay_Product_Payment__c
            WHERE Product__r.Source_system__c = 'Megasys' AND (VersaPay_State__c = 'new' OR VersaPay_State__c = 'in_progress') AND Product__c IN :listProd
        ];
    }

    // Validating current context user
    public static Boolean isCanaccedeAPIUser() {
        String uName = userInfo.getUserName();
        System.debug('uName :' + uName);
        if (uName.equalsIgnoreCase(lrpSetting.Canaccede_API_User__c)) {
            return true;
        }
        return false;
    }

    //Returns all application object field sets
    public static Map<String, String> getProductFieldsets(string fieldSetLabel) {
        Map<String, String> fieldsNameLabel = new Map<String, String>();
        Map<String, Schema.FieldSet> productFieldsSets = Schema.SObjectType.Product__c.fieldSets.getMap();
        List<Schema.FieldSet> listProductFieldSets = productFieldsSets.values();

        for (Schema.FieldSet productFieldSet : listProductFieldSets) {
            if (fieldSetLabel == productFieldSet.getLabel()) {
                for (Schema.FieldSetMember field : productFieldSet.getFields()) {
                    fieldsNameLabel.put(field.getFieldPath(), field.getLabel());
                }
                break;
            }
        }

        return fieldsNameLabel;
    }

    //Fetch customer for Insolvency Account
    public static List<Account> getMatchingCustomers(Product__c prod) {
        //Customer Separation
        Map<String, Business_Separator_Settings__c> businessSeparatorValues = Business_Separator_Settings__c.getall();
        String recordTypeNameValue = prodRTypeIdNameMap.get(prod.recordTypeID);
        String customerRecordType;
        if (!Test.isRunningTest()) {
            customerRecordType = businessSeparatorValues.get(recordTypeNameValue).value__C;
        } else {
            customerRecordType = 'Canaccede Customer';
        }

        List<Account> accList = ProductUtil.queryCustomer(prod, customerRecordType);
        if (accList == null || accList.size() == 0) {
            List<Account> newCustomers = new List<Account>();
            CustomerTriggerHandler.runCustomerTrigger = false;
            newCustomers.add(ProductUtil.createCustomer(prod, customerRecordType));
            CustomerTriggerHandler.runCustomerTrigger = true;
            return newCustomers;
        } else if (accList.size() > 0) {
            return accList;
        }

        return new List<Account>();
    }

    //process builder 'PTP Flow Step 2' convert into code for agency portal changes

    @InvocableMethod(label='ProductTriggerHandler' description='Run PTPFlowStep2 for the Product')
    public static void PTPFlowStep2(List<Product__c> product) {
        Product__c productData = [
            SELECT id, name, Is_Future_PTP__c, Product_Type_Display_Name__c, Current_Workflow__c
            FROM Product__c
            WHERE id = :product[0].id
        ];

        if (productData.Is_Future_PTP__c == true) {
            if (productData.Product_Type_Display_Name__c != null) {
                productData.Current_Workflow__c = 'Promise to Pay Flow';
            } else if (productData.Product_Type_Display_Name__c == null) {
                productData.Current_Workflow__c = 'ICT Promise to Pay';
            }
        } else if (productData.Is_Future_PTP__c == false) {
            productData.Current_Workflow__c = null;
        }
    }

    //validation check method for agency portal
    public static void validationRules(list<Product__c> listProduct, Map<Id, Product__c> mapOldProducts) {
        for (Product__c prod : listProduct) {
            Product__c prodOld = mapOldProducts.get(prod.id);
            if (prod.Collection_Sub_Status__c != 'Recalled' && prodOld.Collection_Sub_Status__c == 'Pending Recall') {
                prod.addError('A status change is not permitted');
            }
            if (prod.Product_Status__c == null) {
                prod.addError('The Status Code provided was not found');
            }
        }
    }

    public static boolean checkInBetweenPayments(ID ProductID, Date updatedDate) {
        Boolean hasInBetweenPayments = false;
        list<product_Payments__c> listProductPayments = new List<product_Payments__c>();
        listProductPayments = [SELECT ID, Payment_posting_Date__c FROM Product_payments__c WHERE Payment_posting_Date__c = NULL];
        return false;
    }

    //Recalculate Interest Amount and Principal balance when backdated/reversed payments are added
    public static void calculateBalanceBackdatedPayments2(list<Product__c> listNewProducts, map<ID, Product__c> mapOldproducts) {
        map<ID, list<product_Payments__c>> mapProductIDPayments = new Map<ID, list<Product_payments__c>>();
        map<ID, Date> mapProductIDPayDate = new Map<ID, Date>();
        Date oldestDate;
        map<ID, Product__c> mapProducts = new Map<ID, Product__c>();
        list<Product__c> listProductWithCreditCounselling = new List<Product__c>();

        //get the Date from which interest needs to be reversed
        for (Product__c product : listNewProducts) {
            mapProducts.put(product.ID, product);
            Product__c prodOld = mapOldproducts.get(product.ID);
            if (prodOld.Insolvency_Date__c == null && product.Insolvency_Date__c != null) {
                if (oldestDate == null || (oldestDate != null && oldestDate > prodOld.Insolvency_Date__c)) {
                    oldestDate = product.Insolvency_Date__c;
                }
                mapProductIDPayDate.put(product.ID, product.Insolvency_Date__c);
            } else if (prodOld.Credit_Counselling_Date__c == null && product.Credit_Counselling_Date__c != null) {
                if (oldestDate == null || (oldestDate != null && oldestDate > prodOld.Credit_Counselling_Date__c)) {
                    oldestDate = product.Credit_Counselling_Date__c;
                }
                mapProductIDPayDate.put(product.ID, product.Credit_Counselling_Date__c);
                listProductWithCreditCounselling.add(product);
            } else if (prodOld.Deceased_Date__c == null && product.Deceased_Date__c != null) {
                if (oldestDate == null || (oldestDate != null && oldestDate > prodOld.Deceased_Date__c)) {
                    oldestDate = product.Deceased_Date__c;
                }
                mapProductIDPayDate.put(product.ID, product.Deceased_Date__c);
            }
        }

        map<ID, list<Product_Payments__c>> mapProductIDPaymentsToAdjustBalances = new Map<ID, list<Product_Payments__c>>();
        if (!mapProductIDPayDate.keySet().isEmpty()) {
            for (Product__c productInstance : [
                SELECT
                    ID,
                    Current_Interest_Amount__c,
                    Payment_Apportionment__c,
                    (
                        SELECT
                            ID,
                            Payment_Amount__c,
                            Pay_NSF__c,
                            Pay_Attorney__c,
                            Payment_Posting_Date__c,
                            Pay_Court__c,
                            Pay_Other__c,
                            Pay_Fees__c,
                            Interest_Payment_Amount__c,
                            Principal_Payment_Amount__c,
                            CCS_Account__c
                        FROM Product_Payments__r
                        WHERE
                            Payment_Amount__c > 0
                            AND Is_Payment_Reversed__c = FALSE
                            AND Payment_Posting_Date__c >= :oldestDate
                            AND CCS_Account__r.RecordType.DeveloperName = :'Distressed_Account'
                        ORDER BY Payment_Posting_Date__c ASC
                    )
                FROM Product__c
                WHERE ID IN :mapProductIDPayDate.keySet()
            ]) {
                //If there are no payments available, add the product to map to reverse balance
                if (productInstance.Product_Payments__r.isEmpty()) {
                    mapProductIDPaymentsToAdjustBalances.put(productInstance.ID, null);
                }
                for (Product_Payments__c prodPay : productInstance.Product_Payments__r) {
                    //get the payments for product whose posting date >= oldest payment date in lot
                    if (prodPay.Payment_Posting_Date__c >= mapProductIDPayDate.get(prodPay.CCS_Account__c)) {
                        if (!mapProductIDPaymentsToAdjustBalances.containsKey(prodPay.CCS_Account__c)) {
                            mapProductIDPaymentsToAdjustBalances.put(prodPay.CCS_Account__c, new List<Product_Payments__c>{ prodPay });
                        } else {
                            mapProductIDPaymentsToAdjustBalances.get(prodPay.CCS_Account__c).add(prodPay);
                        }
                    }
                    //if payment posting date >= oldest payment date and posted before today (payment is in between payment)
                    if (
                        mapProductIDPaymentsToAdjustBalances.containsKey(prodPay.CCS_Account__c) &&
                        prodPay.Payment_posting_Date__c > mapProductIDPayDate.get(prodPay.CCS_Account__c)
                    ) {
                        mapProductIDPaymentsToAdjustBalances.remove(prodPay.CCS_Account__c);
                    }
                }
            }
        }

        //map to store product id and instance with updated principal balance and interet amount
        map<ID, Product__c> mapProductsToReverseBalances = new Map<ID, Product__c>();

        //Get Principal Balance and Interest Balance from history in descending order to get latest histry for the day first
        if (!mapProductIDPaymentsToAdjustBalances.keySet().isEmpty() || Test.isRunningTest()) {
            for (Product__History productHistory : [
                SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate
                FROM Product__History
                WHERE
                    ParentId IN :mapProductIDPaymentsToAdjustBalances.keySet()
                    AND (Field = :'Current_Principal_Balance__c'
                    OR Field = :'Current_Interest_Amount__c'
                    OR Field = :'Current_Balance__c')
                    AND CreatedDate >= :oldestDate
                ORDER BY CreatedDate DESC
            ]) {
                //Fill in the mapProductsToReverseBalances map, if neither if balances is added or only one of them is added
                if (
                    !mapProductsToReverseBalances.containsKey(productHistory.parentId) ||
                    (mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c == null ||
                    mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c == null ||
                    mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c == null)
                ) {
                    String oldestDateHistory = String.valueOf(mapProductIDPayDate.get(productHistory.parentId));
                    String createdDateHistory = String.valueOf(productHistory.CreatedDate).substring(0, 10);
                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if (
                        productHistory.CreatedDate != Date.Today() &&
                        createdDateHistory == oldestDateHistory &&
                        //check if current principal balance to be reversed is not considered in product update
                        (!mapProductsToReverseBalances.containsKey(productHistory.parentId) ||
                        mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c == null) &&
                        productHistory.Field == 'Current_Principal_Balance__c'
                    ) {
                        //create product instance with principal balance to be reversed to
                        Product__c productToUpdate = new Product__c();
                        //if interest amount is already taken, put it in instance
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c != null
                        ) {
                            productToUpdate.Current_Interest_Amount__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c;
                        }
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c != null
                        ) {
                            productToUpdate.Current_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c;
                        }

                        productToUpdate.ID = productHistory.parentId;
                        productToUpdate.Current_Principal_Balance__c = Double.valueOf(productHistory.OldValue);
                        mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                    }
                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if (
                        createdDateHistory == oldestDateHistory &&
                        //check if current principal balance to be reversed is not considered in product update
                        (!mapProductsToReverseBalances.containsKey(productHistory.parentId) ||
                        mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c == null) &&
                        productHistory.Field == 'Current_Interest_Amount__c'
                    ) {
                        //create product instance with principal balance to be reversed to
                        Product__c productToUpdate = new Product__c();
                        //if interest amount is already taken, put it in instance
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c != null
                        ) {
                            productToUpdate.Current_Principal_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId)
                                .Current_Principal_Balance__c;
                        }
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c != null
                        ) {
                            productToUpdate.Current_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c;
                        }
                        productToUpdate.ID = productHistory.parentId;
                        productToUpdate.Current_Interest_Amount__c = Double.valueOf(productHistory.OldValue);
                        mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                    }

                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if (
                        createdDateHistory == oldestDateHistory &&
                        //productHistory.CreatedDate == mapProductIDPayDate.get(productHistory.parentId)
                        //check if current principal balance to be reversed is not considered in product update
                        (!mapProductsToReverseBalances.containsKey(productHistory.parentId) ||
                        mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c == null) &&
                        productHistory.Field == 'Current_Balance__c'
                    ) {
                        //create product instance with principal balance to be reversed to
                        Product__c productToUpdate = new Product__c();
                        //if interest amount is already taken, put it in instance
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c != null
                        ) {
                            productToUpdate.Current_Principal_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId)
                                .Current_Principal_Balance__c;
                        }
                        if (
                            mapProductsToReverseBalances.containsKey(productHistory.parentId) &&
                            mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c != null
                        ) {
                            productToUpdate.Current_Interest_Amount__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c;
                        }
                        productToUpdate.ID = productHistory.parentId;
                        productToUpdate.Current_Balance__c = Double.valueOf(productHistory.OldValue);
                        mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                    }
                }
            }
        }
        for (Product__c product : listProductWithCreditCounselling) {
            if (mapProductsToReverseBalances.containsKey(product.ID)) {
                Decimal InterestAmount = 0;
                Product__c productToUpdate = new Product__c();
                productToUpdate = mapProductsToReverseBalances.get(product.ID);
                //If History record does not have principal balance, get it from the new record list
                if (productToUpdate.Current_Principal_Balance__c == null) {
                    productToUpdate.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                }
                InterestAmount =
                    ((productToUpdate.Current_Principal_Balance__c *
                    product.Interest_Rate__c *
                    (product.Credit_Counselling_Date__c.daysBetween(Date.today()))) / 100) / 365;
                productToUpdate.Current_Interest_Amount__c = productToUpdate.Current_Interest_Amount__c + InterestAmount;
                productToUpdate.Current_Balance__c = productToUpdate.Current_Balance__c + InterestAmount;
                mapProductsToReverseBalances.put(productToUpdate.ID, productToUpdate);
            }
        }

        ProductTriggerHandler.runProductTrigger = false;
        update mapProductsToReverseBalances.values();
        ProductTriggerHandler.runProductTrigger = true;
    }

    //When refer to legal is Approved in salesforce then create judgment on that account.
    public static void creatJudgment(List<Product__c> prodList) {
        List<Judgment__c> judgmentListToInsert = new List<Judgment__c>();
        List<Account_Judgment__c> accountJudgmentListToInsert = new List<Account_Judgment__c>();
        set<ID> prodID = new Set<ID>();
        map<String, ID> prodNameID = new Map<String, ID>();
        List<String> newJudgmentIds = new List<String>();
        List<String> newAccountJudgmentIds = new List<String>();
        Map<String, Judgment__c> mapProductNameJudgment = new Map<String, Judgment__c>();

        for (Product__c prodNew : prodList) {
            prodID.add(prodNew.ID);
            prodNameID.put(prodNew.Name, prodNew.ID);
        }

        for (Product__c prodNew : prodList) {
            Judgment__c newJudgment = new Judgment__C();
            newJudgment.Legal_Status__c = 'Pre-Legal';
            newJudgment.Legal_Sub_Status__c = 'Approved for Legal Action';
            newJudgment.Legal_Agency__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
            if (prodNew.State__c != null) {
                prodProvinceName = prodNew.State__c;
                ProvinceNameFormat = nameFormat(prodProvinceName);
                provinceAcronymFormat = prodProvinceName.toUpperCase();
                if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                    newJudgment.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                    newJudgment.Placed_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                } else if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                    newJudgment.Judgment_Province__c = ProvinceNameFormat;
                    newJudgment.Placed_Province__c = ProvinceNameFormat;
                }
            }
            newJudgment.Product_1__c = prodNew.Name;
            newJudgment.Plaintiff__c = prodNew.Account_Purchasing_Entity_Value__c;
            newJudgment.Legal_Agency__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
            if (String.isNotBlank(newJudgment.Legal_Agency__c)) {
                newJudgment.Legal_Agency_Placement__c = mapCollectionAgency.get(newJudgment.Legal_Agency__c).id;
            } else {
                newJudgment.Legal_Agency_Placement__c = null;
            }
            newJudgment.Agency_Initiated_Legal_Action__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
            newJudgment.Legal_Agency__c = newJudgment.Agency_Initiated_Legal_Action__c;
            if (String.isNotBlank(newJudgment.Agency_Initiated_Legal_Action__c)) {
                newJudgment.Agency_Initiated_Legal_Action_Lookup__c = mapCollectionAgency.get(newJudgment.Agency_Initiated_Legal_Action__c).id;
            } else {
                newJudgment.Agency_Initiated_Legal_Action_Lookup__c = null;
            }
            judgmentListToInsert.add(newJudgment);
        }
        newJudgmentIds = getInsertedIds(judgmentListToInsert);
        for (Judgment__c judgment : [SELECT Id, Name, Product_1__c FROM Judgment__c WHERE Id IN :newJudgmentIds]) {
            Account_Judgment__c accJudg1 = new Account_Judgment__c();
            accJudg1.Product__c = prodNameID.get(judgment.Product_1__c);
            accJudg1.Judgment__c = judgment.ID;
            accJudg1.Product_Identifier__c = judgment.Product_1__c;
            accJudg1.Judgment_Identifier__c = judgment.Name;
            accountJudgmentListToInsert.add(accJudg1);
        }
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
        newAccountJudgmentIds = getInsertedIds(accountJudgmentListToInsert);
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;
        for (String accJudgId : newAccountJudgmentIds) {
            PortalAccountJudgmentProcessingAPI.processAccountJudgment(accJudgId);
        }
    }

    public static List<String> getInsertedIds(List<SObject> listToInsert) {
        List<String> insertedIds = new List<String>();
        Database.SaveResult[] saveResults = Database.insert(listToInsert);
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                insertedIds.add(saveResult.getId());
            }
        }
        return insertedIds;
    }

    //get Province Name
    public static String nameFormat(String name) {
        String result = '';
        if (name != null && name != '') {
            name = name.toLowercase();
            for (String iter : name.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1) {
                        result += iter.substring(0, 1).toUpperCase() + iter.substring(1, iter.length()) + ' ';
                    } else {
                        result += iter.substring(0, 1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }

    //Ticket 4558: Interest Waiver functionality_added checkes in OR conditions
    public static void populateAccuringInterest(List<Product__c> listNewProducts) {
        for (Product__c prodListData : listNewProducts) {
            if (
                prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId &&
                (prodListData.Current_Principal_Balance__c == null ||
                prodListData.Current_Principal_Balance__c <= 0 ||
                prodListData.Collection_Sub_Status__c == 'Deceased' ||
                prodListData.Collection_Sub_Status__c == 'Paid in Full Account' ||
                prodListData.Collection_Sub_Status__c == 'Settled in Full Account' ||
                prodListData.Collection_Sub_Status__c == 'Bankrupt Account' ||
                prodListData.Interest_Rate__c == 0 ||
                prodListData.Interest_Rate__c == null ||
                prodListData.Interest_Amount_Last_Calculated_Date__c == null ||
                prodListData.Insolvency_Date__c != null ||
                prodListData.Deceased_Date__c != null ||
                prodListData.Collection_Sub_Status__c == 'Credit Counselling')
            ) {
                prodListData.Interest_Stopped__c = true;
            } else if (
                prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId &&
                (prodListData.Interest_Waived_Off__c == true &&
                (prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Off_Start_Date__c ||
                prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Of_End_Date__c)) &&
                (prodListData.Current_Principal_Balance__c == null ||
                prodListData.Current_Principal_Balance__c <= 0 ||
                prodListData.Collection_Sub_Status__c == 'Deceased' ||
                prodListData.Collection_Sub_Status__c == 'Paid in Full Account' ||
                prodListData.Collection_Sub_Status__c == 'Settled in Full Account' ||
                prodListData.Collection_Sub_Status__c == 'Bankrupt Account' ||
                prodListData.Interest_Rate__c == 0 ||
                prodListData.Interest_Rate__c == null ||
                prodListData.Insolvency_Date__c != null ||
                prodListData.Deceased_Date__c != null ||
                prodListData.Collection_Sub_Status__c == 'Credit Counselling')
            ) {
                prodListData.Interest_Stopped__c = true;
            } else if (
                prodListData.Interest_Waived_Off__c == false ||
                (prodListData.Interest_Waived_Off__c == true &&
                (prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Off_Start_Date__c ||
                prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Of_End_Date__c))
            ) {
                prodListData.Interest_Stopped__c = false;
            } else if (
                prodListData.Interest_Waived_Off__c == false ||
                (prodListData.Interest_Waived_Off__c == true &&
                (prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Off_Start_Date__c ||
                prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Of_End_Date__c)) &&
                prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId &&
                (prodListData.Current_Principal_Balance__c != null &&
                prodListData.Current_Principal_Balance__c > 0 &&
                prodListData.Collection_Sub_Status__c != 'Deceased' &&
                prodListData.Collection_Sub_Status__c != 'Paid in Full Account' &&
                prodListData.Collection_Sub_Status__c != 'Settled in Full Account' &&
                prodListData.Collection_Sub_Status__c != 'Bankrupt Account' &&
                prodListData.Interest_Rate__c != 0 &&
                prodListData.Interest_Rate__c != null &&
                prodListData.Interest_Amount_Last_Calculated_Date__c != null &&
                prodListData.Insolvency_Date__c == null &&
                prodListData.Deceased_Date__c == null &&
                prodListData.Collection_Sub_Status__c != 'Credit Counselling')
            ) {
                system.debug('ProductTriggerHandler_populateAccuringInterest: value of Accruing Interest::' + prodListData.Interest_Stopped__c);
                prodListData.Interest_Stopped__c = false;
            }
        }
    }

    //4758: Populate Closed date on Distressed product based on product status
    public static void calculateClosedDateOnDistressedProduct(List<Product__c> listNewProducts) {
        map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
        map<String, Data_Status_Mapping__c> mapDataStatus = new Map<String, Data_Status_Mapping__c>();

        for (Data_Status_Mapping__c metaData : mapDataStatusMapping.values()) {
            mapDataStatus.put(metaData.name, metaData);
        }
        for (Product__c prodData : listNewProducts) {
            if (
                prodRTypeIdMap.get('Distressed_Account') == prodData.RecordTypeId &&
                mapDataStatus.containskey(prodData.Product_Status__c) &&
                mapDataStatus.get(prodData.Product_Status__c).Bureau_Reporting_Account_Status__c == 'Closed' &&
                prodData.Closed_Date__c == null
            ) {
                prodData.Closed_Date__c = Date.today();
            }
        }
    }
    //Ticket 7242 : interest rate should not be greater than 35% after 1 Jan 2025 and
    // before 1 Jan 2025 interest rate should not be greater than 60%
    public static void interestRateValidation(Product__c prodData,Decimal interestRateField, Decimal oldInterestRate ){
        if(prodData.Open_Date__c != NULL && interestRateField != oldInterestRate){
            if(interestRateField != NULL && prodData.Open_Date__c < applConfSetting.Interest_Rate_Valid_Date__c && interestRateField > applConfSetting.Interest_Rate_Less_Than_60__c){
                prodData.addError('Interest rate should be less than 60%');
            }else{
                if(interestRateField != NULL && prodData.Open_Date__c >= applConfSetting.Interest_Rate_Valid_Date__c && interestRateField > applConfSetting.Interest_Rate_Less_Than_35__c){
                    prodData.addError('Interest rate should be less than 35%');
                }
            }
        }else if(prodData.Purchase_Date_Formula__c != NULL && interestRateField != oldInterestRate){
            if(interestRateField != NULL && prodData.Purchase_Date_Formula__c < applConfSetting.Interest_Rate_Valid_Date__c && interestRateField > applConfSetting.Interest_Rate_Less_Than_60__c){
                prodData.addError('Interest rate should be less than 60%');
            }else{
                if(interestRateField != NULL && prodData.Purchase_Date_Formula__c >= applConfSetting.Interest_Rate_Valid_Date__c && interestRateField > applConfSetting.Interest_Rate_Less_Than_35__c){
                    prodData.addError('Interest rate should be less than 35%');
                }
            }
        }else{
            if(interestRateField > applConfSetting.Interest_Rate_Less_Than_35__c && interestRateField != oldInterestRate){
                prodData.addError('Interest rate should be less than 35%');
            }
        }
    }
}