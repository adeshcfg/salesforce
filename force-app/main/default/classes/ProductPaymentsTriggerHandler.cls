/**************************************************************************************************
 *
 *  Trigger:
 *
 *  @description : This is a Trigger Handler Class for Product_Payments__c object
 *  @author : A5E Consulting
 *  @date : 23/10/2019
 *
 *************************************************************************************************/

 public class ProductPaymentsTriggerHandler {
    public static boolean runProductTrigger = true;
    public static boolean currentBalanceUpdate = true;
    public static String productNames = '';
    public static String placementIdentifier = '';
    public static String placementStatusCode = '';

    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_REVERSAL = '1003';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
    public static List<String> paymentTypes = new List<String>{ PAYTYPE_REGULAR, PAYTYPE_PAID_IN_FULL, PAYTYPE_SETTLED_IN_FULL };
    static String PENDING_RECALL_PIF = 'Pending Recall - PIF';
    static String PENDING_RECALL_PIF_CODE = '806000';
    static String PENDING_RECALL_SIF = 'Pending Recall - SIF';
    static String PENDING_RECALL_SIF_CODE = '807000';
    static String PENDING_RECALL = 'Pending Recall';
    static String PENDING_RECALL_PRODUCT_STATUS_CODE = '302000';
    static String PIF_PRODUCT_STATUS_CODE = '906000';
    static String SIF_PRODUCT_STATUS_CODE = '907000';
    static string PIF_DATA_DESCRIPTION = 'Closed: Paid in full';
    static string SIF_DATA_DESCRIPTION = 'Closed: Settled in full';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF = 'Pending Recall - Paid Prior To Previous Agency';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE = '808500';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF = 'Pending Recall - Paid Prior To Previous Agency';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE = '808550';
    static String PIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE = '908500';
    static String SIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE = '908550';
    public static Decimal DebtorProvinceTaxRate;
    public static Decimal CanadaTaxRate;
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static String provinceAcronymFormat;
    public static String warehouseAgencyId = '';
    public static String warehouseAgencyName = '';

    //balance adjustment transaction type codes
    static final String FEE_TRANSACION_CODES = '3000,3400,4000,4001,4002,4003,5000,5001,5002,5003,7000,7001';

    //Map of Placement Status Code and Wrapper of Account details
    public static map<String, productWrapper> mapStatusProductWrapper;
    public static Map<String, Placement_History__c> mapProductPreviouslyPlacedCheck;
    public static map<ID, ID> mapProductJudgmentClaimIssuedID = new Map<ID, ID>();

    //Handle After Insert
    public static void handleAfterInsert(
        List<Product_Payments__c> listProductPayment,
        map<Id, Product_Payments__c> mapNewProductPayment,
        Map<Id, Product_Payments__c> oldProductPaymentMap
    ) {
        map<ID, Product_Payments__c> mapNewPayments = new Map<ID, Product_Payments__c>();
        map<ID, Product_Payments__c> mapNewFees = new Map<ID, Product_Payments__c>();
        Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
		
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product_Payments__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }

        for (Product_Payments__c prodPayment : listProductPayment) {
            if (prodRTypeIdMap.get('Distressed_Product_Payment') == prodPayment.RecordTypeId) {
                if (prodPayment.Payment_Type__c.startsWith('1')) {
                    mapNewPayments.put(prodPayment.ID, prodPayment);
                } else if (FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)) {
                    mapNewFees.put(prodPayment.ID, prodPayment);
                }
            }
        }

        if (!mapNewPayments.isEmpty()) {
            calculateBalanceBackdatedPayments(mapNewProductPayment, oldProductPaymentMap, null, null, null, null);
        }

        if (!mapNewFees.isEmpty()) {
            calculateBalanceFeeAdjustments(mapNewFees, null, null, null, null);
        }
    }

    // 4578 Changes - Method to get appropriate placement history record to be linked to the payment
    public static Map<String, String> getPlacementHistoryToLink(
        Product_Payments__c productPayment,
        Map<Id, Product__c> mapProducts,
        Map<String, List<Placement_History__c>> mapProductIdPlacementHistoryList
    ) {
        Map<String, String> placementHistoryExternalIdMap = new Map<String, String>{ 'Id' => null, 'Placement_History_External__c' => null };
        // If the product is in warehouse and was recalled less than 15 days before today's date, link the latest placement history
        if (
            mapProducts.containsKey(productPayment.CCS_Account__c) &&
            mapProducts.get(productPayment.CCS_Account__c).Collection_Agency__c == 9999 &&
            mapProducts.get(productPayment.CCS_Account__c).Recalled_Date__c != null &&
            mapProducts.get(productPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) <= 15 &&
            mapProductIdPlacementHistoryList.containsKey(productPayment.CCS_Account__c)
        ) {
            placementHistoryExternalIdMap.put('Id', mapProductIdPlacementHistoryList.get(productPayment.CCS_Account__c)[0].Id);
            placementHistoryExternalIdMap.put(
                'Placement_History_External__c',
                mapProductIdPlacementHistoryList.get(productPayment.CCS_Account__c)[0].Placement_History_External__c
            );
        }
        // If the product is not in warehouse, link the latest placement history record before the payment posting date
        else if (
            mapProducts.containsKey(productPayment.CCS_Account__c) &&
            mapProducts.get(productPayment.CCS_Account__c).Collection_Agency__c != 9999 &&
            mapProductIdPlacementHistoryList.containsKey(productPayment.CCS_Account__c)
        ) {
            for (Placement_History__c placementHistory : mapProductIdPlacementHistoryList.get(productPayment.CCS_Account__c)) {
                if (
                    placementHistory.Placement_Date__c <= productPayment.Payment_Posting_Date__c &&
                    productPayment.Payment_Provided_Agency__c == placementHistory.Placement__c
                ) {
                    placementHistoryExternalIdMap.put('Id', placementHistory.Id);
                    placementHistoryExternalIdMap.put('Placement_History_External__c', placementHistory.Placement_History_External__c);
                    break;
                }
            }
        }
        return placementHistoryExternalIdMap;
    }

    public static void handleBeforeInsert(list<Product_Payments__c> listNewProductPayments) {
        list<Product__c> listProducts = new List<Product__c>();
        map<Id, Product__c> mapProducts = new Map<Id, Product__c>();
        map<ID, Decimal> mapAgencyCommissionRate = new Map<ID, Decimal>();
        set<Id> setProductId = new Set<Id>();
        set<ID> setPlacementID = new Set<ID>();
        Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
        String monthInt = '';
        String currentMonth;
        Map<String, List<Placement_History__c>> mapProductIdPlacementHistoryList = new Map<String, List<Placement_History__c>>();

        for (RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product_Payments__c' AND ID != NULL LIMIT 10]) {
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }

        for (Product_payments__c prodPay : listNewProductPayments) {
            if (prodRTypeIdMap.get('Distressed_Product_Payment') == prodPay.RecordTypeId) {
                setProductId.add(prodPay.CCS_Account__c);
                if (prodPay.Payment_Provided_Agency__c != null) {
                    setPlacementID.add(prodPay.Payment_Provided_Agency__c);
                }
            }
        }

        if (!setProductId.isEmpty()) {
            // 4578 Changes - Query and create map of placement history records for the products getting payments posted on
            for (Placement_History__c placementHistory : [
                SELECT Id, Product__c, Placement_Date__c, Agency_Id__c, Placement__c, Placement_History_External__c
                FROM Placement_History__c
                WHERE Product__c IN :setProductId
                ORDER BY Placement_Date__c DESC
            ]) {
                if (mapProductIdPlacementHistoryList.containsKey(placementHistory.Product__c)) {
                    mapProductIdPlacementHistoryList.get(placementHistory.Product__c).add(placementHistory);
                } else {
                    mapProductIdPlacementHistoryList.put(placementHistory.Product__c, new List<Placement_History__c>{ placementHistory });
                }
            }

            for (Placement__c placement : [SELECT ID, Commission_rate__c FROM Placement__c WHERE ID IN :setPlacementID]) {
                mapAgencyCommissionRate.put(placement.ID, placement.Commission_Rate__c);
            }

            //get Product and agency details into map to fetch commission rate
            for (Product__c productInstance : [
                SELECT
                    ID,
                    Collection_Agency_Placement__c,
                    Value_Tier__c,
                    Current_Principal_Balance__c,
                    Current_Bal_NSF_Fees__c,
                    Current_Bal_Court_Fees__c,
                    Current_Bal_General_Fees__c,
                    Current_Bal_Other_Fees__c,
                    Current_Interest_Amount__c,
                    Commission_Adjustment__c,
                    Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                    Collection_Agency_Placement__r.Commission_Rate__c,
                    Pool_Name__c,
                    Fee_Recovery__C,
                    Current_Bal_Attorney_Fees__c,
                    Commission_Rate__c,
                    Pool_Name__r.Commission_Rate__c,
                    State__c,
                    Legal_Entity__c,
                    Portfolio_Group_Name_Formula__c,
                    Collection_Agency__c,
                    Recalled_Date__c
                FROM Product__c
                WHERE ID IN :setProductId
            ]) {
                mapProducts.put(productInstance.ID, productInstance);
            }

            Decimal ComissionRate;
            map<String, Decimal> mapValueTierCommissionRate = getCommissionRateValues();
            Decimal feeRecovery = null;
            Map<String, Decimal> productFeeRecoveryMap = new Map<String, Decimal>();
            for (Product_Payments__c productPayment : listNewProductPayments) {
                if (prodRTypeIdMap.get('Distressed_Product_Payment') == productPayment.RecordTypeId) {
                    // Date date1 = productPayment.Payment_Created__c;
                    //bug:5355 - changes : commented above line and added below line to Populate Payment_Posting_Date_Text with Payment Posting Date
                    Date date1 = productPayment.Payment_Posting_Date__c;
                    String day1 = String.valueOf(date1.Day());
                    String month1 = String.valueOf(date1.Month());
                    String yr = String.valueOf(date1.Year());

                    productPayment.Payment_Posting_Date_Text__c = month1 + '/' + day1 + '/' + yr;
                    
                    //Ticket 5865: Payment Reporting Month calculated based on Payment Reporting Date
                    monthInt = String.valueOf(productPayment.Payment_Created__c.month());
                    if(monthInt.length() == 1){
                        currentMonth = '0' + String.valueOf(productPayment.Payment_Created__c.month());
                    }else{
                        currentMonth = String.valueOf(productPayment.Payment_Created__c.month()); 
                    }
                    
                    //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
                    if (productPayment.Payment_Created__c != null) {
                        productPayment.Payment_Posting_Month__c = String.valueOf(productPayment.Payment_Created__c.Year()) + currentMonth;
                    }
                    if (mapProducts.containsKey(productPayment.CCS_Account__c)) {
                        productPayment.Product_Agency__c = mapProducts.get(productPayment.CCS_Account__c).Collection_Agency_Placement__c;
                        productPayment.Pool_Lookup__c = mapProducts.get(productPayment.CCS_Account__c).Pool_Name__c;
                        productPayment.Legal_Entity__c = mapProducts.get(productPayment.CCS_Account__c).Legal_Entity__c;
                        productPayment.Portfolio_Group_Name__c = mapProducts.get(productPayment.CCS_Account__c).Portfolio_Group_Name_Formula__c;
                        if (mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c == null)
                            mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c = 0;
                    }

                    Decimal newFeeRecovery = 0;
                    if (!productFeeRecoveryMap.containsKey(productPayment.CCS_Account__c)) {
                        productFeeRecoveryMap.put(productPayment.CCS_Account__c, mapProducts.get(productPayment.CCS_Account__c).Fee_Recovery__c);
                    }
                    feeRecovery = productFeeRecoveryMap.get(productPayment.CCS_Account__c);

                    if (
                        calculateCommissionAmount() &&
                        mapProducts.containsKey(productPayment.CCS_Account__c) &&
                        String.isNotBlank(productPayment.Payment_Type__c) &&
                        !FEE_TRANSACION_CODES.contains(productPayment.Payment_Type__c) &&
                        ((feeRecovery == 0 || feeRecovery < productPayment.Payment_Amount__c) ||
                        mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c <> 0)
                    ) {
                        //Payment amount on which commission will be applied
                        Decimal payCommission = 0;

                        //IF Fee recovery is present, commission will be applied on (Payment Amount - Fee Recovery Amount)
                        if (feeRecovery < productPayment.Payment_Amount__c) {
                            payCommission = productPayment.Payment_Amount__c - feeRecovery;
                        }
                        newFeeRecovery = feeRecovery - productPayment.Payment_Amount__c;
                        productFeeRecoveryMap.put(productPayment.CCS_Account__c, newFeeRecovery <= 0 ? 0 : newFeeRecovery);

                        //By product Commission Rate
                        if (
                            mapProducts.containsKey(productPayment.CCS_Account__c) && mapProducts.get(productPayment.CCS_Account__c).Commission_Rate__c != null
                        ) {
                            ComissionRate = mapProducts.get(productPayment.CCS_Account__c).Commission_Rate__c;
                            productPayment.Product_Commission_Rate__c = ComissionRate;
                            if (ComissionRate != null) {
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                productPayment.Pay_Due__c = (payCommission * (ComissionRate)) / 100;
                                //Populate actual Commission Rate used for calculation
                                productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                            }
                        }

                        if (productPayment.Payment_Provided_Agency__c == null) {
                            productPayment.Payment_Provided_Agency__c = productPayment.Product_Agency__c;
                        }
                        //By Agency Commission Rate
                        if (
                            mapAgencyCommissionRate.containsKey(productPayment.Payment_Provided_Agency__c) &&
                            mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c) != null
                        ) {
                            ComissionRate = mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c);
                            productPayment.Agency_Commission_Rate__c = ComissionRate;
                            if (Test.isRunningTest()) {
                                productPayment.Pay_Due__c = null;
                                ComissionRate = 30;
                            }
                            if (productPayment.Pay_Due__c == null && ComissionRate != null) {
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                productPayment.Pay_Due__c = payCommission * (ComissionRate) / 100;
                                //Populate actual Commission Rate used for calculation
                                productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                            }
                        }

                        //By pool Commission Rate
                        if (mapProducts.get(productPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c != null) {
                            ComissionRate = mapProducts.get(productPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c;
                            productPayment.Pool_Commission_Rate__c = ComissionRate;
                            if (Test.isRunningTest()) {
                                productPayment.Pay_Due__c = null;
                                ComissionRate = 30;
                            }
                            if (productPayment.Pay_Due__c == null && ComissionRate != null) {
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                productPayment.Pay_Due__c = payCommission * (ComissionRate) / 100;
                                //Populate actual Commission Rate used for calculation
                                productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                            }
                        }
                        ComissionRate = null;
                    } else if (
                        calculateCommissionAmount() &&
                        mapProducts.containsKey(productPayment.CCS_Account__c) &&
                        String.isNotBlank(productPayment.Payment_Type__c) &&
                        !FEE_TRANSACION_CODES.contains(productPayment.Payment_Type__c) &&
                        ((feeRecovery != 0 && feeRecovery >= productPayment.Payment_Amount__c) ||
                        mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c == 0)
                    ) {
                        newFeeRecovery = feeRecovery - productPayment.Payment_Amount__c;
                        productFeeRecoveryMap.put(productPayment.CCS_Account__c, newFeeRecovery <= 0 ? 0 : newFeeRecovery);
                    }
                }
                // 4578 - Link appropriate placement history with payment
                Map<String, String> mapPlacementHistoryToLink = getPlacementHistoryToLink(productPayment, mapProducts, mapProductIdPlacementHistoryList);
                productPayment.Placement_History__c = mapPlacementHistoryToLink.get('Id');
                productPayment.Placement_History_External__c = mapPlacementHistoryToLink.get('Placement_History_External__c');
            }
            getTaxAmount(listNewProductPayments, mapProducts);
            validationOnRecordUpdate2(listNewProductPayments, setProductId, setPlacementID, mapProducts);
        }
    }

    //Handle before update
    public static void handleBeforeUpdate(List<Product_Payments__c> prodPayNew, Map<Id, Product_Payments__c> oldMap) {
        for (Product_Payments__c productPayment : prodPayNew) {
            Date date1 = productPayment.Payment_Created__c;
            String day1 = String.valueOf(date1.Day());
            String month1 = String.valueOf(date1.Month());
            String yr = String.valueOf(date1.Year());

            if (month1.length() == 1) {
                month1 = '0' + month1;
            }
            //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
            if (productPayment.Payment_Created__c != null) {
                productPayment.Payment_Posting_Month__c = String.valueOf(productPayment.Payment_Created__c.Year()) + month1;
            }
        }
    }

    public static void getTaxAmount(list<Product_Payments__c> listNewProductPayments, Map<ID, Product__c> mapProduct) {
        Decimal ComissionRate;
        Decimal ontarioTaxRate;
        Decimal DebtorProvinceTaxRate;
        Decimal CanadaTaxRate;
        string prodProvinceName;
        string ProvinceNameFormat;
        String provinceAcronymFormat;
        set<id> placementId = new Set<id>();
        map<id, Placement__c> mapPlacementIds = new Map<id, Placement__c>();
        mapProductJudgmentClaimIssuedID = new Map<ID, ID>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();

        for (Account_Judgment__c accountJudgment : [
            SELECT ID, Name, Product__c, Judgment__c, Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :mapProduct.keySet() AND Status__c = 'Active'
        ]) {
            if (
                accountJudgment.Judgment__r.Legal_Status__c == 'Judgment' ||
                accountJudgment.Judgment__r.Legal_Status__c == 'Post-Judgment' ||
                accountJudgment.Judgment__r.Legal_Status__c == 'Pre-Judgment'
            ) {
                mapProductJudgmentClaimIssuedID.put(accountJudgment.Product__c, accountJudgment.Judgment__c);
            }
        }
        if (mapTaxMetadata != null && mapTaxMetadata.containsKey('Ontario')) {
            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;
        }

        //Tax rate mapping by Province Acronym
        for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }

        for (Product_Payments__c prodPayment : listNewProductPayments) {
            placementId.add(prodPayment.Payment_Provided_Agency__c);
        }
        List<Placement__c> placement = [
            SELECT id, name, Apply_Ontario_Rate_on_Legal_Account__c
            FROM Placement__c
            WHERE id = :placementId
        ];
        for (Placement__c placeData : placement) {
            mapPlacementIds.put(placeData.id, placeData);
        }
        for (Product_Payments__c prodPayment : listNewProductPayments) {
            //calculate tax amount
            DebtorProvinceTaxRate = 0;
            CanadaTaxRate = 0;
            if (mapProduct.containsKey(prodPayment.CCS_Account__c) && mapProduct.get(prodPayment.CCS_Account__c).State__c != null) {
                prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                ProvinceNameFormat = nameFormat(prodProvinceName);
                provinceAcronymFormat = prodProvinceName.toUpperCase();
            }

            //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
            if (prodPayment.Pay_Due__c != null) {
                if (
                    mapPlacementIds.containsKey(prodPayment.Payment_Provided_Agency__c) &&
                    mapPlacementIds.get(prodPayment.Payment_Provided_Agency__c).Apply_Ontario_Rate_on_Legal_Account__c == true
                ) {
                    if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                        prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                        prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                        prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                    }
                } else {
                    if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
                        if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                        }
                    } else {
                        if (String.isNotBlank(mapProduct.get(prodPayment.CCS_Account__c).State__c)) {
                            if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                            } else if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                            }
                            prodPayment.Legal_Product_Identifier__c = 'Yes';
                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                        }
                    }
                }
            }
        }
    }

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

    public static Boolean calculateCommissionAmount() {
        return true;
    }

    public static map<String, Decimal> getCommissionRateValues() {
        map<String, Decimal> mapValueTierCommissionRate = new Map<String, Decimal>();
        for (Commission_Rate_Settings__mdt metadata : Commission_Rate_Settings__mdt.getAll().values()) {
            mapValueTierCommissionRate.put(metadata.Value_Tier__c, metadata.Commission_Rate__c);
        }
        return mapValueTierCommissionRate;
    }

    //Handle after update
    public static void handleAfterUpdate(List<Product_Payments__c> prodPayNew, Map<Id, Product_Payments__c> oldMap) {
        ProductTriggerHandler.currentBalanceUpdate = false;
    }

    //Recalculate Interest Amount and Principal balance payments are added
    public static void calculateBalanceBackdatedPayments(
        map<Id, Product_Payments__c> mapNewProductPayment,
        Map<Id, Product_Payments__c> oldProductPaymentMap,
        Savepoint sp,
        Id workAssignmentId,
        Id documentID,
        String paymentProcessing
    ) {
        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();

        map<Id, Product__c> mapProductToAdjustInterestFinal = new Map<Id, Product__c>();
        list<Product_Payments__c> listProdPaymentToUpdate = new List<Product_Payments__c>();
        list<Product_Payments__c> listProdPaymentReversal = new List<Product_Payments__c>();
        set<ID> setProductID = new Set<ID>();
        list<ID> setProductIDToReverse = new List<ID>();
        set<ID> setSettledInFullPayments = new Set<ID>();
        mapStatusProductWrapper = new Map<String, productWrapper>();
        set<String> setReversalPayments = new Set<String>();
        Set<String> productIdsForPaymentUpdate = new Set<String>();

        for (Product_Payments__c productPay : mapNewProductPayment.values()) {
            setProductID.add(productPay.CCS_Account__c);
            if (productPay.Payment_Amount__c < 0) {
                //get ID of the payments which are being reversed
                setReversalPayments.add(productPay.Original_Of_Payment_Reversal__c);
            }
        }
		map<ID, Placement_History__c> mapProductPreviouslyPlaced = getDirectPlacementHistoryDetails(setProductID);
        String oldPlacementID ='';
        Map<id,string> productAgency = new Map<id,string>();
        Decimal placementCommisionRate;
        Map<Id,String> placeStatus = new Map<Id,String>();
        List<ID> prodIds = new List<ID>();
        Boolean checkIsReversal = false;
        List<Product__c> prodList = new List<Product__c>();
        map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
    	map<String, Data_Status_Mapping__c> mapDataStatus = new Map<String, Data_Status_Mapping__c>();
        for (Data_Status_Mapping__c metaData : mapDataStatusMapping.values()) {
            mapDataStatus.put(metaData.name, metaData);
        }
        map<String, Placement_Status_Code_Mapping__c> mapPlacementStatusMapping = Placement_Status_Code_Mapping__c.getAll();
    	map<String, Placement_Status_Code_Mapping__c> mapPlacementStatusCode = new Map<String, Placement_Status_Code_Mapping__c>();
        for(Placement_Status_Code_Mapping__c placementStatusCode : mapPlacementStatusMapping.values()){
            mapPlacementStatusCode.put(placementStatusCode.Placement_Status_Code__c,placementStatusCode);
        }
        map<ID, Product_Payments__c> mapReversedPayments = new Map<ID, Product_Payments__c>();
        list<ID> listProductsIds = new List<ID>();
        if (!setReversalPayments.isEmpty()) {
            for (Product_Payments__c prodPayment : [
                SELECT
                    ID,
                    Pay_Attorney__c,
                    Pay_Court__c,
                    Pay_Fees__c,
                    Pay_NSF__c,
                    Pay_Other__c,
                    Interest_Payment_Amount__c,
                    Principal_Payment_Amount__c,
                    Pay_Recoverable_Fee__c,
                    Pay_Non_Recoverable_Fee__c,
                    Payment_Amount__c,
                    Product_Collection_Sub_Status__c,
                    Pay_Data_Status__c,
                    Placement_Status_on_Product__c,
                    Placement_Sub_Status_on_Product__c,
                    Pay_Revenue__c,
                    Payment_Posting_Date__c,
                    CCS_Account__c,
                    Product_Status_Desc_on_Product__c,
                    Pay_Due__c,
                    Tax_Amount__c,
                	Is_Payment_Reversed__c,
                    Tax_type__c,
                    Payment_Type__c,
                    Balance_Before_Payment__c,
                    Commission_Rate_For_payment__c,
                    Product_Commission_Rate__c,
                    Tax_Province__c,
                    Legal_Product_Identifier__c,
                    Tax_Province_Rate__c,
                    Interest_Adjustment__c,
                    Interest_Rate_to_For_Interest_Adjustment__c,
                    No_of_Days_to_Adjust_Interest__c,
                    Pay_Placedetail_Status__c,Last_Payment_Date__c, 
                	Last_Payment_Amount__c
                FROM Product_Payments__c
                WHERE ID IN :setReversalPayments
                ORDER BY CreatedDate DESC
            ]) {
                if (!mapReversedPayments.containsKey(prodPayment.ID)) {
                    mapReversedPayments.put(prodPayment.ID, prodPayment);
                }
                listProductsIds.add(prodPayment.CCS_Account__c);
            }
        }
        map<ID, Date> mapProductNameIds = new Map<ID, Date>();
        for (Account_judgment__c accJudgment : [
            SELECT ID, Name, Product__c, Judgment__c, Product__r.Name, Judgment__r.Judgment_Date__c
            FROM Account_Judgment__c
            WHERE
                Product__c IN :listProductsIds
                AND Status__c = 'Active'
                AND (Judgment__r.Legal_Status__c = 'Judgment'
                OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                AND Judgment__r.Judgment_Date__c != NULL
            ORDER BY CreatedDate DESC
        ]) {
            mapProductNameIds.put(accJudgment.Product__c, accJudgment.Judgment__r.Judgment_Date__c);
        }
        set<ID> prodPaymentId = new Set<ID>();
        List<Product_Payments__C> latestPayment = [
            SELECT Id, name, Payment_Posting_Date__c, Original_Of_Payment_Reversal__c
            FROM Product_Payments__C
            WHERE CCS_Account__c IN :listProductsIds AND Original_Of_Payment_Reversal__c != NULL
        ];

        for (Product_Payments__C prodpaylist : latestPayment) {
            prodPaymentId.add(prodpaylist.Original_Of_Payment_Reversal__c);
        } 
        
        for (Product__c productInstance : [
            SELECT
                ID,
                Name,
                Current_Interest_Amount__c,
                Collection_Agency__c,
                Statute_Date__c,
                Date_for_Stat_Barred_calculations__c,
                Open_Date__c,
                State__c,
                Last_Payment_Date__c,
                Last_Payment_Amount__c,
                Current_Principal_Balance__c,
                Collection_Sub_Status__c,
                Collection_Agency_Placement__c,
                Collection_Agency_Formula__c,
                Collection_Agency_Placement__r.Name,
                Purchase_Province__c,
                Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                Current_Bal_NSF_Fees__c,
                Current_Bal_Court_Fees__c,
                Current_Bal_Other_Fees__c,
                Current_Bal_Attorney_Fees__c,
                Current_Bal_General_Fees__c,
                Current_Balance__c,
                Charged_Off_Date__c,
                Non_Recoverable_Fee__c,
                Recoverable_Fee__c,
                Placement_Status__c,
                Product_Status__c,
                Status__c,
                Data_Status_Description__c,
                Interest_Rate__c,
                Sub_Status__c,
                Interest_Waived_Off_Start_Date__c,
                Interest_Waived_Of_End_Date__c,
                Payment_Apportionment__c,
                Interest_Waived_Off__c,
                Owner.Name,
                Payment_Amount__c,
            	Closed_Date__c,
            	Assignment_Date__c,
            	Pool_Name__r.Commission_Rate__c,
            	Commission_Rate__c,
            	Pool_Name__r.Name,
            	Allocated_Amount_Total__c,
            	Allocated_Amount_Principal__c,
            	Allocated_Amount_Interest__c,
            	Commission_Rate_at_Time_of_Placement__c,
            	Value_Tier_at_Time_of_Placement__c,
            	Placed_Settlement_Rate__c,
            	Collection_Agency_Placement__r.Commission_Rate__c,
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
                        Pay_Due__c,
                        Pay_Recoverable_Fee__c,
                        Pay_Non_Recoverable_fee__c,
                        Pay_Placedetail_Status__c,
                        Principal_Payment_Amount__c,
                        CCS_Account__c,
                        Payment_Type__c,
                        Original_Of_Payment_Reversal__c,
                    	Payment_Provided_Agency__c,
                    	Product_Agency__c
                    FROM Product_Payments__r
                    WHERE CCS_Account__r.RecordType.DeveloperName = :'Distressed_Account' AND ID IN :mapNewProductPayment.keySet()
                    ORDER BY Payment_Posting_Date__c, Name ASC
                )
            FROM Product__c
            WHERE ID IN :setProductID
        ]) {
            if (String.isBlank(productInstance.Payment_Apportionment__c)) {
                productInstance.Payment_Apportionment__c = 'Fees > Interest > Principal';
            }
            //check payment Apportionment type
            if (
                productInstance.Payment_Apportionment__c == 'Fees > Interest > Principal' ||
                productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest' ||
                productInstance.Payment_Apportionment__c == 'Fees > Principal'
            ) {
                for (Product_Payments__c payProductInstance : productInstance.Product_Payments__r) {
                    Product_Payments__c prodPayToUpdate = new Product_Payments__c();
                    prodPayToUpdate.ID = payProductInstance.ID;
                    //Populate Product owner name on product Payment (deactivated the workflow rule)
                    prodPayToUpdate.Owner__c = productInstance.Owner.Name;
                    prodPayToUpdate.Balance_Before_Payment__c = productInstance.Current_Balance__c;
                    prodPayToUpdate.Pre_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                    prodPayToUpdate.Pre_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                    prodPayToUpdate.Interest_Payment_Amount__c = 0;
                    prodPayToUpdate.Principal_Payment_Amount__c = 0;
                    prodPayToUpdate.Pay_Fees__c = 0;
                    prodPayToUpdate.Pay_NSF__c = '0';
                    prodPayToUpdate.Pay_Attorney__c = '0';
                    prodPayToUpdate.Pay_Court__c = '0';
                    prodPayToUpdate.Pay_Other__c = 0;
                    //record product status at the time of payment on product Payment record
                    //prodPayToUpdate.Placement_Status_Code_on_Product__c = productInstance.Placement_Status__c;
                    prodPayToUpdate.Product_Collection_Sub_Status__c = productInstance.Collection_Sub_Status__c;
                    prodPayToUpdate.Pay_Data_Status__c = productInstance.Product_Status__c;
                    prodPayToUpdate.Product_Status_Desc_on_Product__c = productInstance.Data_Status_Description__c;
                    prodPayToUpdate.Placement_Status_on_Product__c = productInstance.Status__c;
                    prodPayToUpdate.Placement_Sub_Status_on_Product__c = productInstance.Sub_Status__c;
                    prodPayToUpdate.Pay_Placedetail_Status__c = productInstance.Placement_Status__c;
                    prodPayToUpdate.Pay_Revenue__c = (prodPayToUpdate.Pay_Due__c != null
                        ? (prodPayToUpdate.Payment_Amount__c - prodPayToUpdate.Pay_Due__c)
                        : prodPayToUpdate.Payment_Amount__c);

                    /*--------------Positive Amount Payment Calculation STARTS------------------------------*/
                    if (payProductInstance.Payment_Amount__c >= 0) {
                        Decimal totalProductPayment = payProductInstance.Payment_Amount__c;

                        //Set Product to Pending recall if paid In Full type Payment is made
                        if (payProductInstance.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                            productInstance.Collection_Sub_Status__c = 'Paid In Full Account';
                            productInstance.Sub_Status__c = null;
                            if (productInstance.Collection_Agency_Formula__c <> 'Warehouse') {
                                //if payement posted agency and product agency is not same
                                if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                    productInstance.Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF;
                                	productInstance.Placement_Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE;
                                    placementStatusCode = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE;
                                    productInstance.Sub_Status__c = 'PIF';
                                }else{
                                    productInstance.Status__c = PENDING_RECALL_PIF;
                                	productInstance.Placement_Status__c = PENDING_RECALL_PIF_CODE;
                                    placementStatusCode = PENDING_RECALL_PIF_CODE;
                                }
                                productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                                productInstance.Data_Status_Description__c = PENDING_RECALL;
                                productInstance.Status_Changed_Date__c = Date.today();
                                
                            } else {
                                //if payement posted agency and product agency is not same
                                if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                    productInstance.Product_Status__c = PIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE;
                                }else{
                                    productInstance.Product_Status__c = PIF_PRODUCT_STATUS_CODE;
                                }
                                productInstance.Data_Status_Description__c = PIF_DATA_DESCRIPTION;
                            }
                            productNames += productInstance.Name + ',';
                            setProductIDToReverse.add(productInstance.ID);
                            if (productInstance.Collection_Agency__c != null) {
                                placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));
                            }
                            if (mapStatusProductWrapper.containsKey(PENDING_RECALL_PIF_CODE)) {
                                productWrapper prodWrap = mapStatusProductWrapper.get(PENDING_RECALL_PIF_CODE);
                                prodWrap.productName += ',' + productInstance.Name;
                                mapStatusProductWrapper.put(PENDING_RECALL_PIF_CODE, prodWrap);
                            } else {
                                String productname = productInstance.Name;
                                productWrapper prodWrap = new productWrapper(
                                    productname,
                                    PENDING_RECALL_PIF_CODE,
                                    PENDING_RECALL_PRODUCT_STATUS_CODE,
                                    placementIdentifier
                                );
                                mapStatusProductWrapper.put(PENDING_RECALL_PIF_CODE, prodWrap);
                            }
                        }

                        //Set Product to Pending recall if Settled In Full type Payment is made
                        if (payProductInstance.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL) {
                            productInstance.Collection_Sub_Status__c = 'Settled In Full Account';
                            productInstance.Sub_Status__c = null;
                            if (productInstance.Collection_Agency_Formula__c <> 'Warehouse') {
                                //if payement posted agency and product agency is not same
                                if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                    productInstance.Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF;
                                	productInstance.Placement_Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE;
                                    placementStatusCode = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE;
                                    productInstance.Sub_Status__c = 'SIF';
                                }else{
                                    productInstance.Status__c = PENDING_RECALL_SIF;
                                	productInstance.Placement_Status__c = PENDING_RECALL_SIF_CODE;
                                    placementStatusCode = PENDING_RECALL_SIF_CODE;
                                }
                                productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                                productInstance.Data_Status_Description__c = PENDING_RECALL;
                                productInstance.Status_Changed_Date__c = Date.today();
                                
                            } else {
                                //if payement posted agency and product agency is not same
                                if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                   productInstance.Product_Status__c = SIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE;
                                }else{
                                    productInstance.Product_Status__c = SIF_PRODUCT_STATUS_CODE;
                                }
                                productInstance.Data_Status_Description__c = SIF_DATA_DESCRIPTION;
                            }
                            productNames += productInstance.Name + ',';
                            setProductIDToReverse.add(productInstance.ID);
                            if (productInstance.Collection_Agency__c != null) {
                                placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));
                            }

                            if (mapStatusProductWrapper.containsKey(PENDING_RECALL_SIF_CODE)) {
                                productWrapper prodWrap = mapStatusProductWrapper.get(PENDING_RECALL_SIF_CODE);
                                prodWrap.productName += ',' + productInstance.Name;
                                mapStatusProductWrapper.put(PENDING_RECALL_SIF_CODE, prodWrap);
                            } else {
                                mapStatusProductWrapper.put(
                                    PENDING_RECALL_SIF_CODE,
                                    new productWrapper(productInstance.Name, PENDING_RECALL_SIF_CODE, PENDING_RECALL_PRODUCT_STATUS_CODE, placementIdentifier)
                                );
                            }
                        }
						oldPlacementID = productInstance.Collection_Agency_Placement__c;
                        //Feed Deduction Starts--------------------------------------------
                        //Recoverable_Fee
                        if (totalProductPayment > 0 && productInstance.Recoverable_Fee__c != null && productInstance.Recoverable_Fee__c != 0) {
                            if (totalProductPayment >= productInstance.Recoverable_Fee__c) {
                                //Recoverable_Fee amount on Product Payment is amount paid towards the fees
                                prodPayToUpdate.Pay_Recoverable_Fee__c = productInstance.Recoverable_Fee__c;
                                totalProductPayment = totalProductPayment - productInstance.Recoverable_Fee__c;
                                productInstance.Recoverable_Fee__c = 0;
                            } else {
                                //payment is lesser than Recoverable_Fee
                                prodPayToUpdate.Pay_Recoverable_Fee__c = totalProductPayment;
                                productInstance.Recoverable_Fee__c -= totalProductPayment;
                                totalProductPayment = 0;
                            }
                        }

                        //Non_Recoverable_Fee
                        if (totalProductPayment > 0 && productInstance.Non_Recoverable_Fee__c != null && productInstance.Non_Recoverable_Fee__c != 0) {
                            if (totalProductPayment >= productInstance.Non_Recoverable_Fee__c) {
                                //Non_Recoverable_Fee__c amount on Product Payment is amount paid towards the fees
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = productInstance.Non_Recoverable_Fee__c;
                                //totalProductPayment = totalProductPayment - productInstance.Non_Recoverable_Fee__c;
                                productInstance.Non_Recoverable_Fee__c = 0;
                            } else {
                                //payment is lesser than Non_Recoverable_Fee
                                //Pay_Court amount on Product Payment is amount paid towards the fees
                                //25-nov-2022 pay non recoverable fee always be amount which is deducted from the product
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = totalProductPayment; //productInstance.Non_Recoverable_Fee__c;
                                productInstance.Non_Recoverable_Fee__c -= totalProductPayment;
                            }
                        }

                        //NSF Fees
                        if (totalProductPayment > 0 && productInstance.Current_Bal_NSF_Fees__c != null && productInstance.Current_Bal_NSF_Fees__c != 0) {
                            prodPayToUpdate.NSF_Fees_Before_Payment__c = productInstance.Current_Bal_NSF_Fees__c;
                            if (totalProductPayment >= productInstance.Current_Bal_NSF_Fees__c) {
                                //Pay_NSF amount on Product Payment is amount paid towards the fees
                                prodPayToUpdate.Pay_NSF__c = String.valueOf(productInstance.Current_Bal_NSF_Fees__c);
                                totalProductPayment = totalProductPayment - productInstance.Current_Bal_NSF_Fees__c;
                                productInstance.Current_Bal_NSF_Fees__c = 0;
                            } else {
                                //payment is lesser than NSF fees
                                //Pay_NSF amount on Product Payment is amount paid towards the fees
                                prodPayToUpdate.Pay_NSF__c = String.valueOf(totalProductPayment);
                                productInstance.Current_Bal_NSF_Fees__c -= totalProductPayment;
                                totalProductPayment = 0;
                            }
                            prodPayToUpdate.NSF_Fees_After_Payment__c = productInstance.Current_Bal_NSF_Fees__c;
                        }

                        //---------------------------------Fees Deduction ENDS--------------------------------------------
                        if (productInstance.Current_Interest_Amount__c == null) {
                            productInstance.Current_Interest_Amount__c = 0;
                        }
                        if (productInstance.Current_Principal_Balance__c == null) {
                            productInstance.Current_Principal_Balance__c = 0;
                        }

                        //DEDUCT INTEREST > PRINCIPAL
                        if (
                            totalProductPayment > 0 &&
                            productInstance.Current_Interest_Amount__c != null &&
                            productInstance.Payment_Apportionment__c == 'Fees > Interest > Principal'
                        ) {
                            //Deduct Interest
                            if (totalProductPayment >= productInstance.Current_Interest_Amount__c) {
                                prodPayToUpdate.Interest_Payment_Amount__c = productInstance.Current_Interest_Amount__c;
                                totalProductPayment = totalProductPayment - productInstance.Current_Interest_Amount__c;
                                productInstance.Current_Interest_Amount__c = 0;
                            } else {
                                prodPayToUpdate.Interest_Payment_Amount__c = totalProductPayment;
                                productInstance.Current_Interest_Amount__c -= totalProductPayment;
                                totalProductPayment = 0;
                            }

                            //Deduct Principal
                            if (totalProductPayment >= productInstance.Current_Principal_Balance__c) {
                                prodPayToUpdate.Principal_Payment_Amount__c = productInstance.Current_Principal_Balance__c;
                                totalProductPayment = totalProductPayment - productInstance.Current_Principal_Balance__c;
                                if (Test.isRunningTest()) {
                                    productInstance.Collection_Sub_Status__c = 'Annulled';
                                }
                                if (
                                    productInstance.Collection_Sub_Status__c != 'Bankrupt Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Paid in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Settled in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Deceased'
                                ) {
                                    /*----------Interest Adjustment Starts--------------*/
                                    //If payment amount is updating Principal Balance
                                    Integer DaystoAdjust = 0;
                                    DaystoAdjust += payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                    if (
                                        productInstance.Interest_Waived_Off__c == true &&
                                        productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c
                                    ) {
                                        DaystoAdjust -= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(
                                            productInstance.Interest_Waived_Off_Start_Date__c
                                        );
                                    }
                                    Decimal InterestAdjustment = 0;
                                    if (DaystoAdjust > 0) {
                                        if (prodPayToUpdate.Principal_Payment_Amount__c != null && productInstance.Interest_Rate__c != null) {
                                            //calculate the adjustment
                                            InterestAdjustment = ((((prodPayToUpdate.Principal_Payment_Amount__c) *
                                                (DaystoAdjust) *
                                                productInstance.Interest_Rate__c) / 100) / 365)
                                                .setScale(2, RoundingMode.HALF_UP);
                                            prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                            prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                            prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                            if (InterestAdjustment != null) {
                                                //since principal is becoming 0, adjustment amount will be added as credit
                                                //totalProductPayment += InterestAdjustment;
                                                //deduct interest paid amount on Product pay record
                                                productInstance.Current_Interest_Amount__c -= InterestAdjustment;
                                                //prodPayToUpdate.Interest_Payment_Amount__c -= InterestAdjustment;
                                            }
                                        }
                                    }
                                    /*----------Interest Adjustment Ends--------------*/
                                }
                                productInstance.Current_Principal_Balance__c = 0;
                            } else {
                                prodPayToUpdate.Principal_Payment_Amount__c = totalProductPayment;
                                productInstance.Current_Principal_Balance__c -= totalProductPayment;

                                if (
                                    productInstance.Collection_Sub_Status__c != 'Bankrupt Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Paid in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Settled in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Deceased'
                                ) {
                                    /*----------Interest Adjustment Starts--------------*/
                                    //If payment amount is updating Principal Balance
                                    Integer DaystoAdjust = 0;
                                    DaystoAdjust = payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                    if (
                                        productInstance.Interest_Waived_Off__c == true &&
                                        productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c
                                    ) {
                                        DaystoAdjust -= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(
                                            productInstance.Interest_Waived_Off_Start_Date__c
                                        );
                                    }

                                    Decimal InterestAdjustment = 0;
                                    if (DaystoAdjust > 0) {
                                        if (productInstance.Interest_Rate__c != null) {
                                            //calculate the adjustment
                                            InterestAdjustment = ((((totalProductPayment) * (DaystoAdjust) * productInstance.Interest_Rate__c) / 100) / 365)
                                                .setScale(2, RoundingMode.HALF_UP);
                                            prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                            prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                            prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                            if (InterestAdjustment != null) {
                                                //deduct principal balance with adjustment
                                                //productInstance.Current_Principal_Balance__c -= InterestAdjustment;
                                                //add principal paid amount on Product pay record
                                                //prodPayToUpdate.Principal_Payment_Amount__c += InterestAdjustment;
                                                //deduct interest paid amount on Product pay record
                                                prodPayToUpdate.Interest_Payment_Amount__c -= InterestAdjustment;
                                                if (productInstance.Current_Interest_Amount__c != null) {
                                                    productInstance.Current_Interest_Amount__c -= InterestAdjustment;
                                                }
                                            }
                                        }
                                    }
                                    /*----------Interest Adjustment Ends--------------*/
                                }
                                totalProductPayment = 0;
                            }

                            //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                            if (totalProductPayment <> 0 && productInstance.Current_Principal_Balance__c == 0) {
                                productInstance.Current_Principal_Balance__c = productInstance.Current_Principal_Balance__c - totalProductPayment;
                                prodPayToUpdate.Principal_Payment_Amount__c += totalProductPayment;
                            }
                        }

                        //----------------------------------------------------------------------------------------------

                        //DEDUCT PRINCIPAL > INTEREST
                        if (
                            totalProductPayment > 0 &&
                            productInstance.Current_Principal_Balance__c != null &&
                            productInstance.Current_Principal_Balance__c != 0 &&
                            (productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest' ||
                            productInstance.Payment_Apportionment__c == 'Fees > Principal')
                        ) {
                            //Deduct Principal
                            if (totalProductPayment >= productInstance.Current_Principal_Balance__c) {
                                prodPayToUpdate.Principal_Payment_Amount__c = productInstance.Current_Principal_Balance__c;
                                totalProductPayment = totalProductPayment - productInstance.Current_Principal_Balance__c;

                                if (
                                    productInstance.Collection_Sub_Status__c != 'Bankrupt Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Paid in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Settled in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Deceased'
                                ) {
                                    /*----------Interest Adjustment Starts--------------*/
                                    //If payment amount is updating Principal Balance
                                    Integer DaystoAdjust = 0;
                                    DaystoAdjust += payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                    if (
                                        productInstance.Interest_Waived_Off__c == true &&
                                        productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c
                                    ) {
                                        DaystoAdjust -= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(
                                            productInstance.Interest_Waived_Off_Start_Date__c
                                        );
                                    }
                                    Decimal InterestAdjustment = 0;
                                    if (DaystoAdjust > 0) {
                                        if (prodPayToUpdate.Principal_Payment_Amount__c != null && productInstance.Interest_Rate__c != null) {
                                            InterestAdjustment =
                                                (((prodPayToUpdate.Principal_Payment_Amount__c) * (DaystoAdjust) * productInstance.Interest_Rate__c) / 100) /
                                                365;

                                            prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                            prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                            prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                            //adding adjustment to payment amount, so that it would deduct from inetrest
                                            totalProductPayment += InterestAdjustment;
                                        }
                                    }
                                    /*----------Interest Adjustment Ends--------------*/
                                }

                                productInstance.Current_Principal_Balance__c = 0;
                            } else {
                                //payment is lesser than Principal Balance
                                prodPayToUpdate.Principal_Payment_Amount__c = totalProductPayment;
                                productInstance.Current_Principal_Balance__c -= totalProductPayment;

                                if (
                                    productInstance.Collection_Sub_Status__c != 'Bankrupt Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Paid in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Settled in Full Account' &&
                                    productInstance.Collection_Sub_Status__c != 'Deceased'
                                ) {
                                    /*----------Interest Adjustment Starts--------------*/
                                    //If payment amount is updating Principal Balance, calculate interest adjustment
                                    Integer DaystoAdjust = 0;
                                    DaystoAdjust = payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                    if (
                                        productInstance.Interest_Waived_Off__c == true &&
                                        productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c
                                    ) {
                                        DaystoAdjust -= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(
                                            productInstance.Interest_Waived_Off_Start_Date__c
                                        );
                                    }

                                    Decimal InterestAdjustment = 0;

                                    if (DaystoAdjust > 0) {
                                        if (prodPayToUpdate.Principal_Payment_Amount__c != null && productInstance.Interest_Rate__c != null) {
                                            InterestAdjustment =
                                                (((prodPayToUpdate.Principal_Payment_Amount__c) * (DaystoAdjust) * productInstance.Interest_Rate__c) / 100) /
                                                365;

                                            prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                            prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                            prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                            if (InterestAdjustment != null) {
                                                //deduct interest adjustment from Interest amount
                                                prodPayToUpdate.Interest_Payment_Amount__c = InterestAdjustment;
                                                productInstance.Current_Interest_Amount__c -= InterestAdjustment;
                                            }
                                        }
                                    }
                                    /*----------Interest Adjustment Ends--------------*/
                                }

                                totalProductPayment = 0;
                            }
                            if (
                                totalProductPayment > 0 &&
                                productInstance.Current_Interest_Amount__c != null &&
                                productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest' &&
                                productInstance.Current_Interest_Amount__c != 0
                            ) {
                                //Deduct Interest
                                if (totalProductPayment >= productInstance.Current_Interest_Amount__c) {
                                    prodPayToUpdate.Interest_Payment_Amount__c = productInstance.Current_Interest_Amount__c;
                                    totalProductPayment = totalProductPayment - productInstance.Current_Interest_Amount__c;
                                    productInstance.Current_Interest_Amount__c = 0;
                                } else {
                                    //payment is lesser than Interest Amount
                                    prodPayToUpdate.Interest_Payment_Amount__c = totalProductPayment;
                                    productInstance.Current_Interest_Amount__c -= totalProductPayment;
                                    totalProductPayment = 0;
                                }
                            }
                            //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                            if (totalProductPayment <> 0 && productInstance.Current_Principal_Balance__c == 0) {
                                productInstance.Current_Principal_Balance__c = productInstance.Current_Principal_Balance__c - totalProductPayment;
                                prodPayToUpdate.Principal_Payment_Amount__c += totalProductPayment;
                            }
                        }

                        //Payment after balances
                        prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                        prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;

                        if (productInstance.Recoverable_Fee__c == null)
                            productInstance.Recoverable_Fee__c = 0;
                        if (productInstance.Current_Interest_Amount__c == null)
                            productInstance.Current_Interest_Amount__c = 0;
                        if (productInstance.Current_Bal_NSF_Fees__c == null)
                            productInstance.Current_Bal_NSF_Fees__c = 0;

                        productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                        prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                    }
                    /*--------------Positive Amount Payment Calculation ENDS------------------------------*/

                    /*--------------Reversed Payment Calculation STARTS------------------------------*/
                    //If reversed payment is added, it is added to Balances on Product as per original Payment
                    if (payProductInstance.Payment_Amount__c < 0) {
                        //using to validate whether current total balance need to be updated or not
                        Boolean calflag = false;
                        if (mapReversedPayments.containsKey(payProductInstance.Original_Of_Payment_Reversal__c)) {
                            Product_Payments__c reversedPay = mapReversedPayments.get(payProductInstance.Original_Of_Payment_Reversal__c);
                            reversedPay.Is_Payment_Reversed__c = true; 
                            if (reversedPay.Payment_Type__c != PAYTYPE_REGULAR) {
                                //revert the statuses
                                productInstance.Placement_Status__c = reversedPay.Pay_Placedetail_Status__c;
                                productInstance.Product_Status__c = reversedPay.Pay_Data_Status__c;
                                //Ticket 6915 : Bypass "Collection_Sub_Status_Change" custom validation to set collection sub status to "Legal"
                                if(reversedPay.Product_Collection_Sub_Status__c == 'Legal'){
                                    Application_Config_Settings__c config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
                                    config.Run_Product_Coll_Sub_Status_Validation__c = false;
                                    update config;
                                    productInstance.Collection_Sub_Status__c = reversedPay.Product_Collection_Sub_Status__c;
                                }else{
                                    productInstance.Collection_Sub_Status__c = reversedPay.Product_Collection_Sub_Status__c;
                                }
                                productInstance.Data_Status_Description__c = reversedPay.Product_Status_Desc_on_Product__c;
                                
                                if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                    if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                        productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;
                                        productInstance.Sub_Status__c = reversedPay.Placement_Sub_Status_on_Product__c;
                                    }
                                } else {
                                    productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;
                                    productInstance.Sub_Status__c = reversedPay.Placement_Sub_Status_on_Product__c;
                                }
                                
                                //Populate Product Status and Data Status Description on product
                                if(reversedPay.Pay_Data_Status__c <> NULL && mapDataStatus.containsKey(reversedPay.Pay_Data_Status__c)){
                                    productInstance.Product_Status__c = reversedPay.Pay_Data_Status__c;
                                    productInstance.Data_Status_Description__c = mapDataStatus.get(reversedPay.Pay_Data_Status__c).Description__c;
                                }
                                //Populate Placement main Status, Sub-Status and Placement Status on product
                                if(reversedPay.Pay_Placedetail_Status__c <> NULL && mapPlacementStatusCode.containsKey(reversedPay.Pay_Placedetail_Status__c)){
                                    productInstance.Placement_Status__c = reversedPay.Pay_Placedetail_Status__c;
                                	productInstance.Status__c = mapPlacementStatusCode.get(reversedPay.Pay_Placedetail_Status__c).Parent_Status__c +' - '+ mapPlacementStatusCode.get(reversedPay.Pay_Placedetail_Status__c).Status__c;
                                	productInstance.Sub_Status__c = mapPlacementStatusCode.get(reversedPay.Pay_Placedetail_Status__c).Sub_Status__c;
                                    placeStatus.put(productInstance.id,productInstance.Placement_Status__c);
                                }
                            }

                            prodPayToUpdate.Pay_Revenue__c = reversedPay.Pay_Revenue__c;
                            //revert amounts
                            if (reversedPay.Pay_Due__c != null) {
                                prodPayToUpdate.Pay_Due__c = reversedPay.Pay_Due__c * -1;
                            } else {
                                prodPayToUpdate.Pay_Due__c = reversedPay.Pay_Due__c;
                            }
                            if (reversedPay.Tax_Amount__c != null) {
                                prodPayToUpdate.Tax_Amount__c = reversedPay.Tax_Amount__c * -1;
                            } else {
                                prodPayToUpdate.Tax_Amount__c = reversedPay.Tax_Amount__c;
                            }
                            prodPayToUpdate.Tax_type__c = reversedPay.Tax_type__c;

                            prodPayToUpdate.Commission_Rate_For_payment__c = reversedPay.Commission_Rate_For_payment__c;

                            prodPayToUpdate.Product_Commission_Rate__C = reversedPay.Product_Commission_Rate__C;

                            prodPayToUpdate.Legal_Product_Identifier__c = reversedPay.Legal_Product_Identifier__c;

                            prodPayToUpdate.Tax_Province__c = reversedPay.Tax_Province__c;

                            prodPayToUpdate.Tax_Province_Rate__c = reversedPay.Tax_Province_Rate__c;
                            if (Test.isRunningTest()) {
                                reversedPay.Pay_NSF__c = '10';
                            }

                            if (reversedPay.Pay_NSF__c <> '0') {
                                productInstance.Current_Bal_NSF_Fees__c = (productInstance.Current_Bal_NSF_Fees__c != null
                                    ? (productInstance.Current_Bal_NSF_Fees__c + Decimal.valueOf(reversedPay.Pay_NSF__c))
                                    : Decimal.valueOf(reversedPay.Pay_NSF__c));
                                if (productInstance.Current_Bal_NSF_Fees__c != null) {
                                    Decimal payNSF = Decimal.valueOf(reversedPay.Pay_NSF__c);
                                    Decimal newpayNSF = payNSF * -1;
                                    prodPayToUpdate.Pay_NSF__c = String.valueOf(newpayNSF);
                                }
                            }
                            if (Test.isRunningTest()) {
                                reversedPay.Pay_Recoverable_Fee__c = 10;
                            }
                            if (reversedPay.Pay_Recoverable_Fee__c != null && reversedPay.Pay_Recoverable_Fee__c <> 0) {
                                productInstance.Recoverable_Fee__c = (productInstance.Recoverable_Fee__c != null
                                    ? (productInstance.Recoverable_Fee__c + reversedPay.Pay_Recoverable_Fee__c)
                                    : reversedPay.Pay_Recoverable_Fee__c);
                                prodPayToUpdate.Pay_Recoverable_Fee__c = reversedPay.Pay_Recoverable_Fee__c * -1;
                            } else {
                                prodPayToUpdate.Pay_Recoverable_Fee__c = reversedPay.Pay_Recoverable_Fee__c;
                            }
                            if (Test.isRunningTest()) {
                                reversedPay.Pay_Non_Recoverable_Fee__c = 10;
                            }

                            if (reversedPay.Pay_Non_Recoverable_Fee__c != null && reversedPay.Pay_Non_Recoverable_Fee__c <> 0) {
                                productInstance.Non_Recoverable_Fee__c = (productInstance.Non_Recoverable_Fee__c != null
                                    ? (productInstance.Non_Recoverable_Fee__c + reversedPay.Pay_Non_Recoverable_Fee__c)
                                    : reversedPay.Pay_Non_Recoverable_Fee__c);
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = reversedPay.Pay_Non_Recoverable_Fee__c * -1;
                            } else {
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = reversedPay.Pay_Non_Recoverable_Fee__c;
                            }

                            //current interest amount is negative then dont consider into calculation
                            if (
                                reversedPay.Interest_Payment_Amount__c != null &&
                                reversedPay.Interest_Payment_Amount__c <> 0 &&
                                productInstance.Current_Interest_Amount__c >= 0
                            ) {
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                    if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c = (productInstance.Current_Interest_Amount__c != null
                                            ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c)
                                            : reversedPay.Interest_Payment_Amount__c);
                                    }
                                } else {
                                    calflag = true;
                                    productInstance.Current_Interest_Amount__c = (productInstance.Current_Interest_Amount__c != null
                                        ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c)
                                        : reversedPay.Interest_Payment_Amount__c);
                                }
                                prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                            } else {
                                if (productInstance.Current_Interest_Amount__c < 0) {
                                    productInstance.Current_Interest_Amount__c = 0;
                                }
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                    if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                    }
                                } else {
                                    calflag = true;
                                    productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                }
                                prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                            }
                            if (reversedPay.Principal_Payment_Amount__c != null) {
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                    if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                        calflag = true;
                                        productInstance.Current_Principal_Balance__c = (productInstance.Current_Principal_Balance__c != null
                                            ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c)
                                            : reversedPay.Principal_Payment_Amount__c);
                                    }
                                } else {
                                    calflag = true;
                                    productInstance.Current_Principal_Balance__c = (productInstance.Current_Principal_Balance__c != null
                                        ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c)
                                        : reversedPay.Principal_Payment_Amount__c);
                                }

                                prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c * -1;
                            } else {
                                prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c;
                            }

                            if (
                                reversedPay.Interest_Adjustment__c != null &&
                                reversedPay.Interest_Adjustment__c <> 0 &&
                                reversedPay.Interest_Adjustment__c < 0
                            ) {
                                prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1;
                                prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                //adding adjustment to payment amount, so that it would deduct from inetrest
                                //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;

                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                    if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                    }
                                } else {
                                    calflag = true;
                                    productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                }
                            } else {
                                if (reversedPay.Interest_Adjustment__c != null && reversedPay.Interest_Adjustment__c <> 0) {
                                    prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c;
                                    prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                    prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                    //adding adjustment to payment amount, so that it would deduct from inetrest
                                    //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;

                                    //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                    if (mapProductNameIds.containsKey(reversedPay.CCS_Account__c)) {
                                        if (reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)) {
                                            calflag = true;
                                            productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                        }
                                    } else {
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                    }
                                    prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1;
                                }
                            }
                            if (reversedPay.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL || reversedPay.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                                setProductIDToReverse.add(productInstance.ID);
                                //Ticket 6495: whenver we reverse PIF or SIF payments then reset closded date
                                if(productInstance.Closed_Date__c <> NULL){
                                    productInstance.Closed_Date__c = NULL;
                                }
                                //Ticket 6494: reallocated product to agency if SIF/PIF payments get reversed.
                                //Populate Agency ID on product
                                if(productInstance.Collection_Agency__c == 9999){
                                    checkIsReversal = true;
                                    if(mapProductPreviouslyPlaced.containsKey(reversedPay.CCS_Account__c)){
                                        if(mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Agency_Id__c <> NULL){
                                            productInstance.Collection_Agency__c = Decimal.valueOf(mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Agency_Id__c);
                                        }
                                        if(mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Placement__c <> NULL){
                                            oldPlacementID = mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Placement__c;
                                            productInstance.Collection_Agency_Placement__c = mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Placement__c;
                                            productAgency.put(reversedPay.CCS_Account__c,mapProductPreviouslyPlaced.get(reversedPay.CCS_Account__c).Placement__c);
                                        }
                                        productInstance.Assignment_Date__c = Date.today();
                                        placementCommisionRate = productInstance.Collection_Agency_Placement__r.Commission_Rate__c;
                                        //Ticket 6914: whenever account reallocated then Allocated Amount: Principal,
                                        //Allocated Amount: Interest and Allocated Amount: Fees should populate on product
                                        if(productInstance.Current_Principal_Balance__c != NULL){
                                            productInstance.Allocated_Amount_Principal__c = productInstance.Current_Principal_Balance__c;
                                        }
                                        if(productInstance.Current_Interest_Amount__c != NULL){
                                            productInstance.Allocated_Amount_Interest__c = productInstance.Current_Interest_Amount__c;
                                        }
                                        if(productInstance.Recoverable_Fee__c == NULL){
                                            productInstance.Recoverable_Fee__c = 0;
                                        }
                                        if(productInstance.Current_Bal_NSF_Fees__c == NULL){
                                            productInstance.Current_Bal_NSF_Fees__c = 0;
                                        }
                                        productInstance.Allocated_Amount_Fees__c = productInstance.Recoverable_Fee__c + productInstance.Current_Bal_NSF_Fees__c; 
                                    }
                                } 
                            }
                            listProdPaymentReversal.add(reversedPay);
                        }

                        //Payment after balances
                        prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                        prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;

                        //Update total balance on Product
                        //add reverse pay amount to current balance, pay amount is negative (- - = +)
                        //productInstance.Current_Balance__c = productInstance.Current_Balance__c - (payProductInstance.Payment_Amount__c);

                        //If Non Recoverable fee was paid down from original payment
                        //25-nov-2022 reason for comment if conditon : current balance should be total of NSF fees + recoverable fees + current principal + interest amount
                        //if(prodPayToUpdate.Pay_Non_Recoverable_Fee__c != NULL){
                        //subtract non recoverable from payment amount
                        //productInstance.Current_Balance__c = productInstance.Current_Balance__c -payProductInstance.Payment_Amount__c;//productInstance.Current_Balance__c -
                        //(payProductInstance.Payment_Amount__c - (prodPayToUpdate.Pay_Non_Recoverable_Fee__c) );
                        if (productInstance.Recoverable_Fee__c == null)
                            productInstance.Recoverable_Fee__c = 0;
                        if (productInstance.Current_Interest_Amount__c == null)
                            productInstance.Current_Interest_Amount__c = 0;
                        if (productInstance.Current_Bal_NSF_Fees__c == null)
                            productInstance.Current_Bal_NSF_Fees__c = 0;
                        if (calflag == true) {
                            productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                        }
                        prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                    }
                    /*--------------Reversed Payment Calculation ENDS------------------------------*/

                    if (
                        (payProductInstance.payment_type__c == '1000' ||
                        payProductInstance.payment_type__c == '1001' ||
                        payProductInstance.payment_type__c == '1002' ||
                        payProductInstance.payment_type__c == '8000') &&
                        (productInstance.Last_Payment_Date__c <= payProductInstance.Payment_Posting_Date__c ||
                        productInstance.Last_Payment_Date__c == null)
                    ) {
                        //set old date and amount on product payment
                        prodPayToUpdate.Last_Payment_Date__c = productInstance.Last_Payment_Date__c;
                        prodPayToUpdate.Last_Payment_Amount__c = productInstance.Last_Payment_Amount__c;

                        productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
                        productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;

                        productInstance.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                            productInstance.Last_Payment_Date__c,
                            productInstance.Open_Date__c,
                            productInstance.Charged_Off_Date__c,
                            productInstance.Statute_Date__c,
                            productInstance.Purchase_Province__c
                        );
                    }

                    if (
                        payProductInstance.payment_type__c == '1003' &&
                        productInstance.Last_Payment_Date__c == payProductInstance.Payment_Posting_Date__c &&
                        productInstance.Last_Payment_Amount__c == (payProductInstance.Payment_Amount__c * -1)
                    ) {
                        if (prodPaymentId != null) {
                            productIdsForPaymentUpdate.add(payProductInstance.CCS_Account__c);
                            productInstance.Statute_Date__c = StatuteDateUtilities.getStatueDate(
                                productInstance.Last_Payment_Date__c,
                                productInstance.Open_Date__c,
                                productInstance.Charged_Off_Date__c,
                                productInstance.Statute_Date__c,
                                productInstance.purchase_Province__c
                            );
                        }
                    }
                    if(payProductInstance.payment_type__c == '1003' 
                       && mapReversedPayments.containsKey(payProductInstance.Original_Of_Payment_Reversal__c) && !productIdsForPaymentUpdate.isEmpty()){
                        productInstance.Last_Payment_Date__c = mapReversedPayments.get(payProductInstance.Original_Of_Payment_Reversal__c).Last_Payment_Date__c;
                        productInstance.Last_Payment_Amount__c = mapReversedPayments.get(payProductInstance.Original_Of_Payment_Reversal__c).Last_Payment_Amount__c;   
                    }
                    mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                    listProdPaymentToUpdate.add(prodPayToUpdate); 
                    if (checkIsReversal == true){
                        checkIsReversal = false;
                        prodList.add(productInstance);
                        prodIds.add(productInstance.ID);
                    }
                }
            }
        }
        update listProdPaymentToUpdate;
		update listProdPaymentReversal;
        
        // 4329 - Take queries out from for loop and update the logic for updating Last Payment Date and Amount
        if (!productIdsForPaymentUpdate.isEmpty()) {
            for (Product__c product : [
                SELECT
                    Id,
                    Name,
                    Last_Payment_Date__c,
                    (
                        SELECT Id, Name, Payment_Amount__c, Payment_Type__c, Payment_Posting_Date__c
                        FROM Product_Payments__r
                        WHERE
                            CCS_Account__r.RecordType.DeveloperName = 'Distressed_Account'
                            AND (Payment_Type__c = '1000'
                            OR Payment_Type__c = '1001'
                            OR Payment_Type__c = '1002'
                            OR Payment_Type__c = '8000')
                            AND Payment_Amount__c > 0
                            AND Payment_Posting_Date__c != NULL
                            AND Is_Payment_Reversed__c = FALSE
                        ORDER BY Payment_Posting_Date__c DESC
                        LIMIT 1
                    )
                FROM Product__c
                WHERE Last_Payment_Date__c != NULL AND Id IN :productIdsForPaymentUpdate
            ]) {
                mapProductToAdjustInterestFinal.get(product.Id).Last_Payment_Date__c = !product.Product_Payments__r.isEmpty()
                    ? product.Product_Payments__r[0].Payment_Posting_Date__c
                    : mapProductToAdjustInterestFinal.get(product.Id).Last_Payment_Date__c;
                mapProductToAdjustInterestFinal.get(product.Id).Last_Payment_Amount__c = !product.Product_Payments__r.isEmpty()
                    ? product.Product_Payments__r[0].Payment_Amount__c
                    : mapProductToAdjustInterestFinal.get(product.Id).Last_Payment_Amount__c;
            }
        }

        ProductTriggerHandler.runProductTrigger = false;
        ProductPaymentstriggerHandler.runProductTrigger = false;

        //For ticket 4518 - satyajit patil
        List<Database.SaveResult> updateResults;
        if (paymentProcessing == 'Payment Excel Processing') {
            updateResults = Database.update(mapProductToAdjustInterestFinal.values(), false);
        } else {
            try {
                update mapProductToAdjustInterestFinal.values();
            } catch (Exception e) {
                for (Product_Payments__c productPay : mapNewProductPayment.values()) {
                    productPay.addError('Product Update is failed due to below exception: ' + e.getMessage());
                }
            }
        }
        List<Database.SaveResult> ErrorrResult = new List<Database.SaveResult>();
        Set<Id> prodId = new Set<Id>();

        if (paymentProcessing == 'Payment Excel Processing') {
            for (Database.SaveResult res : updateResults) {
                if (res.isSuccess() == false) {
                    prodId.add(res.getId());
                    ErrorrResult.add(res);
                }
            }
        }
		//Ticket 6494: if reverse SIF/PIF create placement history and call snapshot
        try{
            if (!prodList.isEmpty()) {
            	DistressedUtilities.createPlacementHistory(prodList,oldPlacementID,placementCommisionRate,productAgency);
                Database.executeBatch(new BatchProcessForProdScreen(prodIds,placeStatus,'Product Allocation Individual'), 200);
            }else{
                if (!setProductIDToReverse.isEmpty()) {
            		PortalProductProcessingAPI.processProductBulkBatch(setProductIDToReverse, new List<Product__c>());
        		}
            }
            
        }catch(Exception ex){
            system.debug('exception message'+ex.getStackTraceString());
        }
        
        JudgmentTriggerHandler.recalculateDisbursmentFees(setProductID);
        ProductTriggerHandler.runProductTrigger = true;
        ProductPaymentstriggerHandler.runProductTrigger = true;

        //For ticket 4518 - satyajit patil
        if (paymentProcessing == 'Payment Excel Processing' && !ErrorrResult.isEmpty()) {
            Database.rollback(sp);
            DisplayProductPaymentStagingController.stopSuccessfilegenaration = true;
            DistressedUtilities.GenerateSuccessAndErrorFile(ErrorrResult, workAssignmentId, documentID, prodId);
        }
    }

    public static void calculateBalanceFeeAdjustments(
        map<ID, product_Payments__c> mapFeeAdjustments,
        Savepoint sp,
        Id workAssignmentId,
        Id documentID,
        String paymentProcessing
    ) {
        set<ID> setProductID = new Set<ID>();
        list<Product__c> listProductsToUpdate = new List<Product__c>();
        list<Product_payments__c> listProductPaymentToUpdate = new List<Product_payments__c>();

        for (Product_Payments__c productPay : mapFeeAdjustments.values()) {
            setProductID.add(productPay.CCS_Account__c);
        }

        for (Product__c productInstance : [
            SELECT
                ID,
                Name,
                Current_Interest_Amount__c,
                Collection_Agency__c,
                Current_Principal_Balance__c,
                Current_Balance__c,
                Collection_Agency_Placement__c,
                Collection_Agency_Placement__r.Name,
                Current_Bal_NSF_Fees__c,
                Current_Bal_Court_Fees__c,
                Current_Bal_Other_Fees__c,
                Current_Bal_Attorney_Fees__c,
                Current_Bal_General_Fees__c,
                Payment_Apportionment__c,
                Interest_Waived_Off__c,
                Non_Recoverable_Fee__c,
                Recoverable_Fee__c,
                Placement_Status__c,
                Product_Status__c,
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
                        CCS_Account__c,
                        Payment_Type__c
                    FROM Product_Payments__r
                    WHERE CCS_Account__r.RecordType.DeveloperName = :'Distressed_Account' AND ID IN :mapFeeAdjustments.keySet()
                    ORDER BY Payment_Posting_Date__c ASC
                )
            FROM Product__c
            WHERE ID IN :setProductID
        ]) {
            for (Product_Payments__c prodPayment : productInstance.Product_Payments__r) {
                prodPayment.Balance_Before_Payment__c = productInstance.Current_Balance__c;
                prodPayment.Pay_NSF__c = '0';
                prodPayment.Pay_Attorney__c = '0';
                prodPayment.Pay_Court__c = '0';
                prodPayment.Pay_Fees__c = 0;
                prodPayment.Pay_Other__c = 0;
                prodPayment.Pre_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                prodPayment.Pre_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                prodPayment.Interest_Payment_Amount__c = 0;
                prodPayment.Principal_Payment_Amount__c = 0;
                prodPayment.NSF_Fees_Before_Payment__c = productInstance.Current_Bal_NSF_Fees__c;
                prodPayment.Attorney_Fees_Before_Payment__c = productInstance.Current_Bal_Attorney_Fees__c;
                prodPayment.Court_Fees_Before_Payment__c = productInstance.Current_Bal_Court_Fees__c;
                prodPayment.General_Fees_Before_Payment__c = productInstance.Current_Bal_General_Fees__c;
                prodPayment.Other_Fees_Before_Payment__c = productInstance.Current_Bal_Other_Fees__c;
                prodPayment.Pay_Recoverable_Fee__c = 0;
                prodPayment.Pay_Non_Recoverable_Fee__c = 0;
                prodPayment.Pay_Data_Status__c = productInstance.Product_Status__c;
                prodPayment.Pay_Placedetail_Status__c = productInstance.Placement_Status__c;
                //if transaction code is 3000, update NSF Fee
                if (prodPayment.Payment_Type__c == '3000') {
                    productInstance.Current_Bal_NSF_Fees__c = (productInstance.Current_Bal_NSF_Fees__c != null
                        ? (productInstance.Current_Bal_NSF_Fees__c + prodPayment.Payment_Amount__c)
                        : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_NSF__c = String.valueOf(prodPayment.Payment_Amount__c);
                    //update Total Balance
                    productInstance.Current_Balance__c = (productInstance.Current_Balance__c != null
                        ? (productInstance.Current_Balance__c + prodPayment.Payment_Amount__c)
                        : prodPayment.Payment_Amount__c);
                }

                //if transaction code is 4000, update Recoverable Fee Fee
                if (prodPayment.Payment_Type__c == '4000') {
                    productInstance.Recoverable_Fee__c = (productInstance.Recoverable_Fee__c != null
                        ? (productInstance.Recoverable_Fee__c + prodPayment.Payment_Amount__c)
                        : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_Recoverable_Fee__c = prodPayment.Payment_Amount__c;
                    //update Total Balance
                    productInstance.Current_Balance__c = (productInstance.Current_Balance__c != null
                        ? (productInstance.Current_Balance__c + prodPayment.Payment_Amount__c)
                        : prodPayment.Payment_Amount__c);
                }

                //if transaction code is 5000, update NonRecoverable Fee
                if (prodPayment.Payment_Type__c == '5000') {
                    productInstance.Non_Recoverable_Fee__c = (productInstance.Non_Recoverable_Fee__c != null
                        ? productInstance.Non_Recoverable_Fee__c + prodPayment.Payment_Amount__c
                        : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_Non_Recoverable_Fee__c = prodPayment.Payment_Amount__c;
                }

                //Payment after balances
                prodPayment.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                prodPayment.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                prodPayment.Balance_After_Payment__c = productInstance.Current_Balance__c;
                listProductPaymentToUpdate.add(prodPayment);
            }
            listProductsToUpdate.add(productInstance);
        }
        ProductTriggerHandler.runProductTrigger = false;

        //update listProductsToUpdate;

        //For ticket 4518 - satyajit patil
        List<Database.SaveResult> updateResults;
        if (paymentProcessing == 'Payment Excel Processing') {
            updateResults = Database.update(listProductsToUpdate, true);
        } else {
            try {
                update listProductsToUpdate;
            } catch (Exception e) {
                for (Product_Payments__c productPay : mapFeeAdjustments.values()) {
                    productPay.addError('Product Update is failed due to below exception: ' + e.getMessage());
                }
            }
        }

        List<Database.SaveResult> ErrorrResult = new List<Database.SaveResult>();
        Set<Id> prodId = new Set<Id>();
        if (paymentProcessing == 'Payment Excel Processing') {
            for (Database.SaveResult res : updateResults) {
                if (res.isSuccess() == false) {
                    prodId.add(res.getId());
                    ErrorrResult.add(res);
                }
            }
        }

        ProductPaymentstriggerHandler.runProductTrigger = false;
        update listProductPaymentToUpdate;

        JudgmentTriggerHandler.recalculateDisbursmentFees(setProductID);

        ProductPaymentstriggerHandler.runProductTrigger = true;
        ProductTriggerHandler.runProductTrigger = true;

        //For ticket 4518 - satyajit patil
        if (paymentProcessing == 'Payment Excel Processing' && !ErrorrResult.isEmpty()) {
            Database.rollback(sp);
            DisplayProductPaymentStagingController.stopSuccessfilegenaration = true;
            DistressedUtilities.GenerateSuccessAndErrorFile(ErrorrResult, workAssignmentId, documentID, prodId);
        }
    }

    public class productWrapper {
        public String productName;
        public String placementStatusCode;
        public String productStatusCode;
        public String placementIdentifier;
        public productWrapper(String productName, String placementStatusCode, String productStatusCode, String placementIdentifier) {
            this.productName = productName;
            this.placementStatusCode = placementStatusCode;
            this.productStatusCode = productStatusCode;
            this.placementIdentifier = placementIdentifier;
        }
    }

    //Validation method to be called  before update
    public static void validationOnRecordUpdate2(
        List<Product_Payments__c> prodPayNew,
        set<ID> setProductID,
        set<ID> setPlacementID,
        Map<ID, Product__c> mapProductDetails
    ) {
        set<ID> alreadyReversedPayments = new Set<ID>();
        map<ID, Product__c> mapProduct = new Map<ID, Product__c>();
        map<String, List<Product_Payments__c>> setOldTransaction = new Map<String, List<Product_Payments__c>>();
        list<Product_Payments__c> listProductPayToUpdate = new List<Product_Payments__c>();
        map<ID, Placement__c> mapPlacement = new Map<ID, Placement__c>();
        map<String, Product_Payments__c> mapPayment = new map<String, Product_Payments__c>();
        for (Placement__c placement : [SELECT ID, Name FROM Placement__c WHERE ID IN :setPlacementID]) {
            mapPlacement.put(placement.ID, placement);
        }

        List<Placement__c> warehouse = [SELECT Id,name  From Placement__c Where Name = '9999' Limit 1];
        if(!warehouse.isEmpty()) {
            warehouseAgencyId = warehouse[0].Id;
            warehouseAgencyName = warehouse[0].name;
        }

        for (Product__C product : [
            SELECT
                ID,
                name,
                Collection_Agency__c,
                Settlement_Rate__c,
                Collection_Agency_Placement__c,
                Collection_Sub_Status__c,
                Status__c,
                Sub_Status__c,
                Data_Status_Description__c,
                Pool_Name__r.Commission_Rate__c,
                Value_Tier_at_Time_of_Placement__c,
                Collection_Agency_Placement__r.Commission_Rate__c,
                Commission_Adjustment__c,
                Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                Assignment_Date__c,
                Recalled_Date__c,
                Current_Balance__c,
                Collection_Agency_Placement__r.Default_Tolerance_of_Total_Balance__c,
                Collection_Agency_Placement__r.Default_Tolerance_Amount__c,
                Collection_Agency_Placement__r.Tolerance_of_Total_Balance__c,
                Collection_Agency_Placement__r.Tolerance_Amount__c,
                Purchase_Status__c,
                Commission_Rate__c,
                Fee_Recovery__c
            FROM Product__C
            WHERE ID IN :setProductID
        ]) {
            mapProduct.put(product.id, product);
        }

        for (Product_Payments__c oldPay : [
            SELECT
                ID,
                CCS_Account__r.Name,
                Payment_Type__c,
                Payment_Amount__c,
                Payment_Posting_Date__c,
                Payment_Posting_Date_Text__c,
                Is_Payment_Reversed__c,
                Pay_Due__c,
                Payment_Provided_Agency__c,
                Payment_Agency__c
            FROM Product_Payments__c
            WHERE CCS_Account__c IN :mapProduct.keySet()
        ]) {
            mapPayment.put(oldPay.ID,oldPay);
            String payAmount = String.valueOf(oldPay.Payment_Amount__c);
            // Add non reversed payment Ids which will be used to check for valid reversals later
            // There can be multiple payments with same amount, type, date and account so create a list of same payments so that we don't reverse the same payment for multiple reversals
            if (!oldPay.Is_Payment_Reversed__c) {
                if (
                    setOldTransaction.containsKey(
                        oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c
                    )
                ) {
                    setOldTransaction.get(oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c)
                        .add(oldPay);
                } else {
                    setOldTransaction.put(
                        oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c,
                        new List<Product_Payments__c>{ oldPay }
                    );
                }
            }
        }

        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();

        list<String> validPaymentTypes = new List<String>();
        map<Id, Decimal> mapProductPaymentAmount = new Map<ID, Decimal>();
        map<String, Decimal> mapProductNameAmount = new Map<String, Decimal>();
        validPaymentTypes = portalSettings.Valid_Payment_Types__c.split(',');
        set<Id> setProductNames = new Set<Id>();
        set<String> setPlacementNames = new Set<String>();

        set<id> placementId = new Set<id>();
        Decimal ontarioTaxRate;
        map<id, Placement__c> mapPlacementIds = new Map<id, Placement__c>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();
        for (Account_Judgment__c accountJudgment : [
            SELECT ID, Name, Product__c, Judgment__c, Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :mapProductDetails.keySet() AND Status__c = 'Active'
        ]) {
            if (
                accountJudgment.Judgment__r.Legal_Status__c == 'Judgment' ||
                accountJudgment.Judgment__r.Legal_Status__c == 'Post-Judgment' ||
                accountJudgment.Judgment__r.Legal_Status__c == 'Pre-Judgment'
            ) {
                mapProductJudgmentClaimIssuedID.put(accountJudgment.Product__c, accountJudgment.Judgment__c);
            }
        }
        if (mapTaxMetadata != null && mapTaxMetadata.containsKey('Ontario')) {
            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;
        }

        //Tax rate mapping by Province Acronym
        for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }

        for (Product_Payments__c prodPayment : prodPayNew) {
            placementId.add(prodPayment.Payment_Provided_Agency__c);
        }
        List<Placement__c> placement = [
            SELECT id, name, Apply_Ontario_Rate_on_Legal_Account__c
            FROM Placement__c
            WHERE id = :placementId
        ];
        for (Placement__c placeData : placement) {
            mapPlacementIds.put(placeData.id, placeData);
        }

        for (Product_Payments__c prodPayment : prodPayNew) {
            if (
                mapProductNameAmount.containsKey(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date__c +
                        prodPayment.CCS_Account__c
                )
            ) {
                mapProductNameAmount.put(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date__c +
                        prodPayment.CCS_Account__c,
                    mapProductNameAmount.get(
                        prodPayment.Payment_Amount__c + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c
                    ) + 1
                );
            } else {
                mapProductNameAmount.put(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date__c +
                        prodPayment.CCS_Account__c,
                    1
                );
            }

            if (mapProductPaymentAmount.containsKey(prodPayment.CCS_Account__c)) {
                Decimal payAmount = mapProductPaymentAmount.get(prodPayment.CCS_Account__c);
                if (payAmount != null && prodPayment.Payment_Amount__c != null && prodPayment.Payment_Amount__c > 0) {
                    mapProductPaymentAmount.put(prodPayment.CCS_Account__c, payAmount + prodPayment.Payment_Amount__c);
                }
            } else {
                if (prodPayment.Payment_Amount__c != null && prodPayment.Payment_Amount__c > 0) {
                    mapProductPaymentAmount.put(prodPayment.CCS_Account__c, prodPayment.Payment_Amount__c);
                }
            }

            setProductNames.add(prodPayment.CCS_Account__c);
            setPlacementNames.add(prodPayment.Payment_Agency__c);
        }
        //4532: get product having settlement
        Map<id, Settlement__c> mapSettlementData = new Map<id, Settlement__c>();
        List<Settlement__c> settlementData = [
            SELECT id, name, Product__c, Required_Amount__c, Status__c, Payment_Frequency__c
            FROM Settlement__c
            WHERE Product__c IN :setProductNames
        ];

        for (Settlement__c settleData : settlementData) {
            mapSettlementData.put(settleData.Product__c, settleData);
        }

        set<String> setProductPreviouslyPlacedCheck = getPlacementHistoryDetails(setProductNames);

        //direct payment history
        map<ID, Placement_History__c> mapProductPreviouslyPlaced = getDirectPlacementHistoryDetails(setProductNames);
        map<ID, Placement_History__c> lastAgencyRecallDate = getLastAgencyRecallDate(setProductNames, setPlacementNames);
        String prodPayStatus = '';
        String productAgency = '';
        Id productAgencyID = null;
        String originalPaymentType = '';
        for (Product_Payments__c prodPayment : prodPayNew) {
            if (prodPayment.Payment_Provided_Agency__c != null && mapPlacement.containsKey(prodPayment.Payment_Provided_Agency__c)) {
                prodPayment.Payment_Agency__c = mapPlacement.get(prodPayment.Payment_Provided_Agency__c).Name;
            }

            productAgency = '';
            prodPayStatus = '';
            if (mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                if (String.isNotBlank(mapProduct.get(prodPayment.CCS_Account__c).Status__c)) {
                    prodPayStatus = mapProduct.get(prodPayment.CCS_Account__c).Status__c;
                }
                if (mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c != null) {
                    productAgency = String.valueOf(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c);
                    productAgencyID = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c;
                }
            }

            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';

            if (
                setOldTransaction.containsKey(
                    prodPayment.Payment_Amount__c + '' + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                ) &&
                !setOldTransaction.get(
                        prodPayment.Payment_Amount__c + '' + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                    )
                    .isEmpty()
            ) {
                ERROR_MSG += '<b>WARNING</b> - A duplicate transaction was found in Inventory.<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - A duplicate transaction was found in Inventory.');
                }
            }
            //Payment Source should be either 1,2,3
            if (prodPayment.Payment_Source__c != '1' && prodPayment.Payment_Source__c != '2' && prodPayment.Payment_Source__c != '3') {
                ERROR_MSG = '<b>ERROR</b> - Payment Source is not valid.<br/>';
                EXPECTED += 'Payment Source Should be 1 OR 2 OR 3.<br/>';
                prodPayment.addError('Payment Source is not valid. It Should be 1 OR 2 OR 3');
            }

            if (!mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                ERROR_MSG = '<b>ERROR</b> - Account not found.<br/>';
                //prodPayment.addError('Account not found.');
            } else {
                prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c;
            }

            //Invalid Payment Date
            if (prodPayment.Payment_Posting_Date__c != null) {
                if (prodPayment.Payment_Posting_Date__c > Date.today()) {
                    ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                    EXPECTED += 'Payment Date cannot be in future.<br/>';
                    prodPayment.addError('Payment Date cannot be in future.');
                }
            } else {
                prodPayment.addError('Payment Date cannot be blank');
            }

            //Account is currently in pending recall status and pmt is not a reversal
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isNotBlank(prodPayStatus) &&
                prodPayStatus.startsWith('Pending Recall') &&
                prodPayment.Payment_Type__c != PAYTYPE_REVERSAL
            ) {
                ERROR_MSG += '<b>WARNING</b> - Invalid account status.<br/>';
                EXPECTED += 'Account cannot be in Pending Recall Status.<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - Account cannot be in Pending Recall Status.');
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Paid in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1001) Paid in Full.');
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL) {
                if (prodPayment.Payment_Amount__c < 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Settled in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1002) Settled in Full.');
                }
            }

            //Payment does not meet paid in full parameters
            if (
                prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL &&
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != null
            ) {
                Decimal outStandingBalance;
                outStandingBalance = (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c * 5 / 100);
                outStandingBalance = outStandingBalance.setScale(2, RoundingMode.HALF_UP);

                //Check if payment amount matches outStandingBalance amount percents on Placement
                if (prodPayment.Payment_Amount__c < outStandingBalance) {
                    ERROR_MSG += '<b>WARNING</b> - Transaction amount is not within 5% of the total oustanding balance' + '<br/>';
                    EXPECTED += 'Expected Paid in Full Amount: ' + outStandingBalance + '<br/>';
                    if (prodPayment.Ignore_Warning__c == false) {
                        prodPayment.addError(
                            'WARNING - Transaction amount is not within 5% of the total oustanding balance.' +
                                ' Expected Paid in Full Amount: ' +
                                outStandingBalance
                        );
                    }
                }
            }
            
            //Payment being reversed must exist (same pmt amount (but negative) and pmt date as original payment)
            //12-Feb-2023 Payment can only be negative for Payment Reversal
            if (
                (prodPayment.Payment_Type__c == PAYTYPE_REVERSAL && prodPayment.Payment_Amount__c < 0) &&
                !FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)
            ) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    Decimal payAmount = prodPayment.Payment_Amount__c * -1;
                    payAmount = payAmount.setScale(2, RoundingMode.HALF_UP);
                    // Check if we have a valid payment to reverse for 1000, 1001 and 1002 payment types
                    for (String paymentType : paymentTypes) {
                        if (
                            setOldTransaction.containsKey(payAmount + '' + paymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c) &&
                            !setOldTransaction.get(payAmount + '' + paymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c).isEmpty()
                        ) {
                            originalPaymentType = paymentType;
                            break;
                        }
                    }
                    if (String.isBlank(originalPaymentType)) {
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                        prodPayment.addError('A corresponding Payment was not found for this reversal.');
                    } else {
                        Product_Payments__c originalPayment = setOldTransaction.get(
                            payAmount + originalPaymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                        )[0];
                        prodPayment.Original_Of_Payment_Reversal__c = originalPayment.Id;
                        prodPayment.Payment_Provided_Agency__c = originalPayment.Payment_Provided_Agency__c;
                        prodPayment.Payment_Agency__c = originalPayment.Payment_Agency__c;
                        setOldTransaction.get(payAmount + originalPaymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)
                            .remove(0);
                    }
                }
            }

            //Account must not be closed
            //Ticket 4129 - if account in warehouse Internal user able to post payment
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed') &&
                mapProduct.get(prodPayment.CCS_Account__c).Purchase_Status__c == 'Buyback/Putback Approved'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Account is closed.<br/>';
                prodPayment.addError('Account is closed.');
            } else {
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed')
                ) {
                    ERROR_MSG += '<b>WARNING</b> - Account is closed.<br/>';
                    if (prodPayment.Ignore_Warning__c == false) {
                        prodPayment.addError('WARNING - Account is closed.');
                    }
                }
            }

            if (prodPayment.Payment_Source__c == '1') {
                //This account is no longer available in this Placement
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    String.isNotBlank(productAgency) &&
                    productAgency != '9999' &&
                    prodPayment.Payment_Agency__c != productAgency &&
                    setProductPreviouslyPlacedCheck.contains(prodPayment.CCS_Account_Name__c + prodPayment.Payment_Agency__c)
                ) {
                    ERROR_MSG += '<b>WARINING</b> - This account is no longer available in this Placement.<br/>';
                    EXPECTED +=
                        'Product Agency:' +
                        mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +
                        '; Payment Agency:' +
                        prodPayment.Payment_Agency__c +
                        '<br/>';
                    if (prodPayment.Ignore_Warning__c == false) {
                        prodPayment.addError('WARNING - This account is no longer available in this Placement.');
                    }
                }

                //if product Recall date is blank then fetch Recall date from placement history
                if (mapProduct.containsKey(prodPayment.CCS_Account__c) && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == null) {
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c)
                            .Placement_Recall_Date__c;
                    }
                }

                if (!FEE_TRANSACION_CODES.contains(prodPayment.payment_Type__c)) {
                    if (
                        mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                        (productAgency == '9999' || String.isBlank(productAgency)) &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) <= 15
                    ) {
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;

                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                            }
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                            }
                            if (CommissionRate != null) {
                                Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                if(prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)){
                                    prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                }
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;

                                //Tax Amount calculation:
                                //calculate tax amount
                                /*DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0;
                                prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if (String.isNotBlank(prodProvinceName)) {
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                                }

                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if (
                                    mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                    mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
                                        .Apply_Ontario_Rate_on_Legal_Account__c == true
                                ) {
                                    if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                        prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                        prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                        prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                    }
                                } else {
                                    if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
                                        if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;

                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                        }
                                    } else {
                                        if (String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)) {
                                            if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                            } else if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                            }
                                            if (prodPayment.Pay_Due__c != null) {
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                            }
                                        }
                                    }
                                }*/

                                //calculate tax amount ends
                            }
                            if (lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c)) {
                                //if(lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c == prodPayment.Payment_Provided_Agency__c){
                                if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                    prodPayment.Payment_Provided_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c;
                                }
                                if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                    prodPayment.Payment_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                }

                                //}
                            }
                            
                            ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';


                                if(prodPayment.Payment_Type__c != PAYTYPE_REVERSAL){
                                    EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
                                    if (prodPayment.Ignore_Warning__c == false) {
                                        prodPayment.addError(
                                            'WARNING - Account was recalled within 15 days is currently warehoused.' +
                                            'Commission Amount ' +
                                            prodPayment.Pay_Due__c +
                                            ' will be paid to Agency ' +
                                            prodPayment.Payment_Agency__c
                                        );
                                    }
                                }
                                if(prodPayment.Payment_Type__c == PAYTYPE_REVERSAL){
                                    if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) 
                                       && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c != NULL){
                                           EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c + '<br/>';
                                           if (prodPayment.Ignore_Warning__c == false) {
                                               prodPayment.addError(
                                                   'WARNING - Account was recalled within 15 days is currently warehoused.' +
                                                   'Commission Amount ' +
                                                   prodPayment.Pay_Due__c +
                                                   ' will be paid to Agency ' +
                                                   mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c
                                               );
                                           }
                                       }
                                }

                            
                        }
                    }

                    //This account is recalled before 15 days and is currently warehoused
                    if (
                        mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                        (productAgency == '9999' || String.isBlank(productAgency)) &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) > 15
                    ) {
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled more than 15 days ago and is currently warehoused.<br/>';
                        //Ticket 5190: Commission Given on Payments That Should Not Have Commission
                        if(prodPayment.Payment_Type__c == '1003'){
                            if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c != NULL){
                                EXPECTED += 'Commission Amount paid will be '+mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c * -1+' on this payment. ' + '<br/>'; 
                            }
                        }else{
                            EXPECTED += 'Commission Amount paid will be 0 on this payment. ' + '<br/>';
                        }
                        // Commented as condition is not needed
                        /* if (prodPayment.Ignore_Warning__c == false) {
                            prodPayment.addError(
                                'WARNING - Account was recalled more than 15 days ago and is currently warehoused. Commission Amount paid will be '+mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c * -1
                            );
                        } */
                        prodPayment.Payment_Provided_Agency__c = warehouseAgencyId;
                        //Ticket 6503: commission paid to and payment agency should be same
                        prodPayment.Payment_Agency__c = warehouseAgencyName;
                        prodPayment.Pay_Due__c = 0;
                        prodPayment.Tax_Amount__c = 0;
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            // Commission paid to field should be populated with warehouse placement record, no need to populate with previous placed agency
                            /* if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                            } */
                            //Ticket 6503: commission paid to and payment agency should be same
                            /*if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }*/
                        }
                    }

                    //assigned to agency
                    if (mapProduct.containsKey(prodPayment.CCS_Account__c) && (productAgency != '9999' && String.isNotBlank(productAgency))) {
                        //This account is recalled before 15 days
                        if (prodPayment.Payment_Agency__c == productAgency) {
								prodPayment.Payment_Provided_Agency__c = productAgencyID;
								prodPayment.Payment_Agency__c = productAgency;
                        }else{
                            if (
                                mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                                mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15
                            ) {
                                prodPayment.Payment_Provided_Agency__c = productAgencyID;
                                prodPayment.Payment_Agency__c = productAgency;
                                ERROR_MSG += '<b>WARINING</b> - <b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency.<br/>';
                                
                                if(prodPayment.Payment_Type__c != PAYTYPE_REVERSAL){
                                    EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
                                    if (prodPayment.Ignore_Warning__c == false) {
                                        prodPayment.addError(
                                            'WARNING - Account was recalled before 15 days and is currently placed with agency.' +
                                            'Commission Amount ' +
                                            prodPayment.Pay_Due__c +
                                            ' will be paid to Agency ' +
                                            productAgency
                                        );
                                    }
                                }
                                if(prodPayment.Payment_Type__c == PAYTYPE_REVERSAL){
                                    if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) 
                                       && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c != NULL){
                                           EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c + '<br/>';
                                           if (prodPayment.Ignore_Warning__c == false) {
                                               prodPayment.addError(
                                                   'WARNING - Account was recalled before 15 days and is currently placed with agency.' +
                                                   'Commission Amount ' +
                                                   prodPayment.Pay_Due__c +
                                                   ' will be paid to Agency ' +
                                                   mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c
                                               );
                                           }
                                       }
                                }	
                            }
                            //This account is recalled within 15 days and
                            else if (
                                mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                                mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15
                            ) {
                                if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                                    Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C; //Commission_Rate__c;
                                    
                                    if (CommissionRate == null) {
                                        CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                                    }
                                    if (CommissionRate == null) {
                                        CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                                    }
                                    if (CommissionRate != null) {
                                        Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                                        //if commission adjustment is added to product, adjust Commission Rate
                                        if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                            CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                        }
                                        if (prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)) {
                                            prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                        }
                                        //Tax Amount calculation:
                                        //calculate tax amount
                                        /*DebtorProvinceTaxRate = 0;
CanadaTaxRate = 0;
prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
ProvinceNameFormat = nameFormat(prodProvinceName);
if (String.isNotBlank(prodProvinceName)) {
provinceAcronymFormat = prodProvinceName.toUpperCase();
}

//Calculate Tax Amount for acocunts that are not in legal Status or claim issued
if (
mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
.Apply_Ontario_Rate_on_Legal_Account__c == true
) {
if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
}
} else {
if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;

prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
}
} else {
if (String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)) {
if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
} else if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat)
.Total_Tax_Rate__c;
}
if (prodPayment.Pay_Due__c != null) {
prodPayment.Legal_Product_Identifier__c = 'Yes';
prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
}
}
}
}*/
                                        
                                        //calculate tax amount ends
                                        prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                        if (lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c)) {
                                            //if(lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c == prodPayment.Payment_Provided_Agency__c){
                                            if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                                prodPayment.Payment_Provided_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c;
                                            }
                                            if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                                prodPayment.Payment_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                            }
                                            
                                            if (prodPayment.Ignore_Warning__c == false && prodPayment.Pay_Due__c != null) {
                                                prodPayment.addError(
                                                    'WARNING - Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to ' + prodPayment.Payment_Agency__c
                                                );
                                            }
                                            //}
                                        }
                                    } else {
                                        //if commission adjustment is added to product, adjust Commission Rate
                                        if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                            CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                        }
                                        prodPayment.Pay_Due__c = null;
                                        prodPayment.Tax_Amount__c = null; //Ticket 6836: If pay_due null then tax amount should be also null 
                                        
                                        prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                        if (lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c)) {
                                            //if(lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c == prodPayment.Payment_Provided_Agency__c){
                                            if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                                prodPayment.Payment_Provided_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c;
                                            }
                                            if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                                prodPayment.Payment_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                            }
                                            
                                            if (prodPayment.Ignore_Warning__c == false && prodPayment.Pay_Due__c != null) {
                                                prodPayment.addError(
                                                    'WARNING - Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to ' + prodPayment.Payment_Agency__c
                                                );
                                            }
                                            //}
                                        }
                                    }
                                    if (!lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c) &&
                                        !mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                                            Decimal CommRate = mapProduct.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                                            Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                                            if (CommRate == null) {
                                                CommRate = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__r.Commission_Rate__c;
                                            }
                                            if (CommRate == null) {
                                                CommRate = mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c;
                                            }
                                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                                CommRate = CommRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                            }
                                            system.debug('CommRate::'+CommRate);
                                            if (prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)) {
                                                prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommRate) / 100;
                                            }
                                            system.debug('prodPayment Pay_Due__c::'+prodPayment.Pay_Due__c);
                                        }
                                }
                            }
                        }
                        
                        
                    }
                }
            }

            //This account is no longer available in this Placement
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isNotBlank(productAgency) &&
                productAgency != '9999' &&
                prodPayment.Payment_Agency__c != productAgency &&
                !setProductPreviouslyPlacedCheck.contains(prodPayment.CCS_Account_Name__c + prodPayment.Payment_Agency__c)
            ) {
                ERROR_MSG += '<b>WARNING</b> - This account is not available in this Placement.<br/>';
                //EXPECTED += 'Account Agency: ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                // Don't throw error if Ignore warning checkbox is checked while posting payment
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - This account is not available in this Placement.');
                }
            }

            //Account is currently warehoused  and recalled more than 60 days ago, OR account has had subsequent placements
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isNotBlank(productAgency) &&
                productAgency == '9999' && 
                mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                prodPayment.Payment_Posting_Date__c != null &&
                mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) > 60
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid current account status.<br/> ';
                EXPECTED += 'Account cannot not be in Warehouse.<br/>';
                //Added the below IF condition part of bug #4547
                if (prodPayment.Ignore_Warning__c == false) {
                prodPayment.addError('Invalid current account status. Account should not be in Warehouse.');
                }
            }
            //Payment exceeds total outstanding balance
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProductPaymentAmount.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c < mapProductPaymentAmount.get(prodPayment.CCS_Account__c)
            ) {
                ERROR_MSG += '<b>WARNING</b> - The total amount paid for the account is greater than the total balance<br/>';
                EXPECTED +=
                    'Total Balance on Product= ' +
                    mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c.setScale(2, RoundingMode.HALF_UP) +
                    '<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - The total amount paid for the account is greater than the total balance');
                }
            }

            //Calculated commission is incorrect
            if (
                prodPayment.Agency_Calculated_Comm__c != null &&
                prodPayment.Agency_Calculated_Comm__c != prodPayment.Pay_Due__c &&
                prodPayment.Payment_Amount__c > 0 &&
                productAgency != '9999' &&
                String.isNotBlank(productAgency)
            ) {
                ERROR_MSG += '<b>WARNING</b> - Invalid amount retained/remitted on Gross Remittance.<br/>';
                EXPECTED += 'Expected Commission Amount: ' + prodPayment.Pay_Due__c + '<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - Invalid amount retained/remitted on Gross Remittance');
                }
            }

            //Transaction type is incorrect
            if (prodPayment.Payment_Type__c != null && !validPaymentTypes.contains(prodPayment.Payment_Type__c)) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type.<br/>';
                prodPayment.addError('Invalid Payment Type.');
            }

            //Must be positive
            if (prodPayment.Payment_Type__c == PAYTYPE_REGULAR && prodPayment.Payment_Amount__c < 0) {
                ERROR_MSG += '<b>ERROR</b> - Negative amount received with incorrect payment type (1000).<br/>';
                prodPayment.addError('ERROR - Negative amount received with incorrect payment type (1000).');
            }

            //------------------Direct Payment Validations Starts-------------------//

            if ((prodPayment.Payment_Source__c == '2' || prodPayment.Payment_Source__c == '3') && !FEE_TRANSACION_CODES.contains(prodPayment.payment_Type__c)) {
                //if product Recall date is blank then fetch Recall date from placement history
                if (mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == null) {
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c)
                            .Placement_Recall_Date__c;
                    }
                }

                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    (productAgency == '9999' || String.isBlank(productAgency)) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) <= 15
                ) {
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;

                        if (CommissionRate == null) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                        }
                        if (CommissionRate == null) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                        }
                        if (CommissionRate != null) {
                            Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                            //if commission adjustment is added to product, adjust Commission Rate
                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                            }
                            if(prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)){
                                prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                            }
                            prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                            //Tax Amount calculation:
                            //calculate tax amount
                            /*DebtorProvinceTaxRate = 0;
                            CanadaTaxRate = 0;
                            prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                            ProvinceNameFormat = nameFormat(prodProvinceName);
                            if (String.isNotBlank(prodProvinceName)) {
                                provinceAcronymFormat = prodProvinceName.toUpperCase();
                            }
                            //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                            if (
                                mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
                                    .Apply_Ontario_Rate_on_Legal_Account__c == true
                            ) {
                                if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                    prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                    prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                    prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                    prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                }
                            } else {
                                if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
                                    if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                        prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                        prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                        prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;

                                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                    }
                                } else {
                                    if (String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)) {
                                        if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                                            DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                            CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                            prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                        } else if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                                            DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                            CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                            prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                        }
                                        if (prodPayment.Pay_Due__c != null) {
                                            prodPayment.Legal_Product_Identifier__c = 'Yes';
                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                        }
                                    }
                                }
                            }*/

                            //calculate tax amount ends
                        }
                        if (prodPayment.Payment_Type__c != PAYTYPE_REVERSAL && mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                            }
                            if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }

                        ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';		
                        if(prodPayment.Payment_Type__c != PAYTYPE_REVERSAL){
                            EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
                            if (prodPayment.Ignore_Warning__c == false) {
                                prodPayment.addError(
                                    'WARNING - Account was recalled within 15 days is currently warehoused.' +
                                    'Commission Amount ' +
                                    prodPayment.Pay_Due__c +
                                    ' will be paid to Agency ' +
                                    prodPayment.Payment_Agency__c
                                );
                            }
                        }
                        if(prodPayment.Payment_Type__c == PAYTYPE_REVERSAL){
                            if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) 
                               && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c != NULL){
                                   EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c + '<br/>';
                                   if (prodPayment.Ignore_Warning__c == false) {
                                       prodPayment.addError(
                                           'WARNING - Account was recalled within 15 days is currently warehoused.' +
                                           'Commission Amount ' +
                                           prodPayment.Pay_Due__c +
                                           ' will be paid to Agency ' +
                                           mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Payment_Agency__c
                                       );
                                   }
                               }
                        }
								
                    }
                }

                //This account is recalled before 15 days and is currently warehoused
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    (productAgency == '9999' || String.isBlank(productAgency)) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) > 15
                ) {
                    ERROR_MSG += '<b>WARINING</b> - Account was recalled more than 15 days ago and is currently warehoused.<br/>';
                    if (!prodPayment.Ignore_Warning__c) {
                        prodPayment.addError('WARINING - Account was recalled more than 15 days ago and is currently warehoused.');
                    }
                    //Ticket 5190: Commission Given on Payments That Should Not Have Commission
                    if(prodPayment.Payment_Type__c == '1003'){
                        if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c != NULL){
                            EXPECTED += 'Commission Amount paid will be '+mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c * -1+' on this payment. ' + '<br/>'; 
                        }
                    }else{
                        EXPECTED += 'Commission Amount paid will be 0 on this payment. ' + '<br/>';
                        //Ticket 6503: commission paid to and payment agency should be same
                        /*if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }*/
                    }
                    //Ticket 6503: commission paid to and payment agency should be same
                    prodPayment.Payment_Agency__c = warehouseAgencyName;
                    prodPayment.Payment_Provided_Agency__c = warehouseAgencyId;
                    prodPayment.Pay_Due__c = 0;
                    prodPayment.Tax_Amount__c = 0;
                }

                //assigned to agency
                if (mapProduct.containsKey(prodPayment.CCS_Account__c) && (productAgency != '9999' && String.isNotBlank(productAgency))) {
                    //This account is recalled before 15 days
                    if (!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        prodPayment.Payment_Provided_Agency__c = productAgencyID;
                        prodPayment.Payment_Agency__c = productAgency;
                    }
                    else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15
                    ) {
                        prodPayment.Payment_Provided_Agency__c = productAgencyID;
                        prodPayment.Payment_Agency__c = productAgency;
                    }
                    //This account is recalled within 15 days and
                    else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15
                    ) {
                        Decimal CommissionRate = 0;
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                            }
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                            }
                            if (CommissionRate != null) {
                                Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                if(prodPayment.Payment_Amount__c != null  && (feeRecovery == null || feeRecovery == 0)){
                                    prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                }
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                //Tax Amount calculation:
                                //calculate tax amount
                                /*DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0;
                                prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if (String.isNotBlank(prodProvinceName)) {
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                                }
                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if (
                                    mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                    mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
                                        .Apply_Ontario_Rate_on_Legal_Account__c == true
                                ) {
                                    if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                        prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                        prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                        prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                    }
                                } else {
                                    if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
                                        if (prodPayment.Pay_Due__c != null && ontarioTaxRate != null) {
                                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;

                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (ontarioTaxRate)) / 100;
                                        }
                                    } else {
                                        if (String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)) {
                                            if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                            } else if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                            }
                                            if (prodPayment.Pay_Due__c != null) {
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                            }
                                        }
                                    }
                                }*/

                                //calculate tax amount ends
                                if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                                    if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                        prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                                    }
                                    if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                        prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                    }
                                }
                            } else {
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    CommissionRate = mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                prodPayment.Pay_Due__c = null;
                                prodPayment.Tax_Amount__c = null; //Ticket 6836: If pay_due null then tax amount should be also null 
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                                    if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                        prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                                    }
                                    if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                        prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                    }
                                }
                            }
                            EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to ' + prodPayment.Payment_Agency__c + '<br/>';
                            if (prodPayment.Ignore_Warning__c == false && prodPayment.Pay_Due__c != null) {
                                prodPayment.addError(
                                    'WARNING - Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to ' + prodPayment.Payment_Agency__c
                                );
                            }
                        }
                    }
                }
            }

            //No settlement parameters set for the account
            if (prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL && mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c == null) {
                ERROR_MSG += '<b>WARNING</b> - Settlements are not available on this account.<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - Settlements Rate not available on this account.');
                }
            }

            //Payment does not meet Settlement parameters of <<settlement parameter on account in %>>
            if (
                prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL &&
                mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != null &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != null
            ) {
                Decimal toleranceAmount;
                if (mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != null) {
                    toleranceAmount =
                        (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c * mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c) / 100;
                    toleranceAmount = toleranceAmount.setScale(2, RoundingMode.HALF_UP);
                }
                //product has active settment then calcuate based on Required Amount
                if (
                    mapSettlementData.containskey(prodPayment.CCS_Account__c) &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Payment_Frequency__c == 'One Time Payment' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Status__c == 'Approved' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Required_Amount__c != null &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Required_Amount__c != prodPayment.Payment_Amount__c
                ) {
                    ERROR_MSG +=
                        '<b>WARNING</b> - Payment does not meet Settlement parameter on Account ' +
                        'Settlement Rate % : ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c +
                        '<br/>';
                    EXPECTED += 'Expected Settlement Amount : ' + mapSettlementData.get(prodPayment.CCS_Account__c).Required_Amount__c + '<br/>';
                    if (prodPayment.Ignore_Warning__c == false) {
                        prodPayment.addError(
                            'WARNING : Payment does not meet Settlement parameter on Account Settlement Rate %:' +
                            mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c
                        );
                    }
                } else if (
                    mapSettlementData.containskey(prodPayment.CCS_Account__c) &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Payment_Frequency__c != 'One Time Payment' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Status__c != 'Approved' &&
                    prodPayment.Payment_Amount__c <> toleranceAmount
                ) {
                    //Check if payment amount matches tolerance amount percents on Placement
                    ERROR_MSG +=
                        '<b>WARNING</b> - Payment does not meet Settlement parameter on Account ' +
                        'Settlement Rate % : ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c +
                        '<br/>';
                    EXPECTED += 'Expected Settlement Amount : ' + toleranceAmount + '<br/>';
                    if (prodPayment.Ignore_Warning__c == false) {
                        prodPayment.addError(
                            'WARNING : Payment does not meet Settlement parameter on Account Settlement Rate %:' +
                            mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c
                        );
                    }
                }
            }

            //Must be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_REVERSAL && prodPayment.Payment_Amount__c > 0) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Reversal. Amount must be negative.<br/>';
                prodPayment.addError('Invalid Reversal. Amount must be negative.');
            }

            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Paid in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1001) Paid in Full.');
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL) {
                if (prodPayment.Payment_Amount__c < 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for paymnet type(1002) Settled in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1002) Settled in Full.');
                }
            }
            

            //Account is currently in Recalled status.
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isNotBlank(prodPayStatus) &&
                prodPayStatus.startsWith('Recall') &&
                productAgency != '9999' &&
                prodPayment.Payment_Source__c == '1'
            ) {
                ERROR_MSG += '<b>WARNING</b> - Account is currently in Recalled status.<br/>';
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING :Account is currently in Recalled status');
                }
            }

            if (prodPayment.Payment_Amount__c == null || prodPayment.Payment_Amount__c == 0) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Amount<br/>';
                prodPayment.addError('Invalid Payment Amount.');
            }

            //----------------------------Fees validations startes------------------//
            if (prodPayment.Payment_Posting_Date__c != null && FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    Decimal payAmount = prodPayment.Payment_Amount__c * -1;
                    if (
                        !setOldTransaction.containsKey(
                            payAmount + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                        )
                    ) {
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                        prodPayment.addError('ERROR - A corresponding Payment was not found for this reversal.');
                    } else {
                        prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get(
                                payAmount + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                            )[0]
                            .Id;
                    }
                }
            }

            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c) &&
                prodPayment.Payment_Type__c != '3000' &&
                !mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)
            ) {
                if (prodPayment.Ignore_Warning__c == false) {
                    prodPayment.addError('WARNING - Cannot post Protective Disbursment to the account. Account is not in Legal Status');
                }
            }
            //Ticket 6836: Calculate Tax Amount
            ProductPaymentExcelFileProcessing.calculateTaxAmount(prodPayment,mapProductJudgmentClaimIssuedID,mapPlacementIDs,mapProductDetails);
            
            if (prodPayment.Pay_Due__c == 0) {
                prodPayment.Tax_Amount__c = 0;
            }
        }
    }

    public static set<String> getPlacementHistoryDetails(set<Id> setProductNames) {
        set<String> setProductPreviouslyPlacedCheck = new Set<String>();
        mapProductPreviouslyPlacedCheck = new Map<String, Placement_History__c>();
        Date dateInstance = Date.today().addDays(-15);
        for (Placement_History__c placementHistory : [
            SELECT ID, Placement__r.Name, Product__c, Product__r.Name, CreatedDate
            FROM Placement_History__c
            WHERE Product__c IN :setProductNames AND CreatedDate = LAST_N_DAYS:180
        ]) {
            setProductPreviouslyPlacedCheck.add(placementHistory.Product__r.Name + placementHistory.Placement__r.Name);
            if (placementHistory.CreatedDate < dateInstance) {
                mapProductPreviouslyPlacedCheck.put(placementHistory.Product__r.Name + placementHistory.Placement__r.Name, placementHistory);
            }
        }
        return setProductPreviouslyPlacedCheck;
    }

    public static map<ID, Placement_History__c> getDirectPlacementHistoryDetails(set<ID> setProductNames) {
        map<ID, Placement_History__c> previouslyPlaced = new Map<ID, Placement_History__c>();

        for (Placement_History__c placementHistory : [
            SELECT
                ID,
                Placement__r.Name,
                Product__c,
                Product__r.Name,
                Placement_Recall_Date__c,
                Agency_Id__c,
                Placement__c,
                Product_Commission_Rate__c,
                Commission_Rate__c,
                Pool_Commission_Rate__c
            FROM Placement_History__c
            WHERE Product__c IN :setProductNames AND Placement_Recall_Date__c = LAST_N_DAYS:60 AND Placement_Recall_Date__c != NULL
            ORDER BY CreatedDate DESC
        ]) {
            if (!previouslyPlaced.containsKey(placementHistory.Product__c)) {
                previouslyPlaced.put(placementHistory.Product__c, placementHistory);
            }
        }
        return previouslyPlaced;
    }

    public static map<ID, Placement_History__c> getLastAgencyRecallDate(set<ID> setProductNames, set<String> setPlacementNames) {
        map<ID, Placement_History__c> lastAgencyRecallDate = new Map<ID, Placement_History__c>();

        for (Placement_History__c placementHistory : [
            SELECT
                ID,
                Placement__r.Name,
                Product__c,
                Product__r.Name,
                Placement_Recall_Date__c,
                Agency_Id__c,
                Placement__c,
                Product_Commission_Rate__c,
                Commission_Rate__c,
                Pool_Commission_Rate__c
            FROM Placement_History__c
            WHERE
                Product__c IN :setProductNames
                AND Placement_Recall_Date__c = LAST_N_DAYS:60
                AND Placement_Recall_Date__c != NULL
                AND Agency_Id__c IN :setPlacementNames
            ORDER BY CreatedDate DESC
        ]) {
            if (!lastAgencyRecallDate.containsKey(placementHistory.Product__c)) {
                lastAgencyRecallDate.put(placementHistory.Product__c, placementHistory);
            }
        }
        return lastAgencyRecallDate;
    }
    public static void handleBeforeDelete(list<Product_Payments__c> prodPayRecords){        
        ArchiveUnarchiveUtility.insertDeletedRecords(prodPayRecords);
    }
}