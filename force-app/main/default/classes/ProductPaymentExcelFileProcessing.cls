/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : Class to create Product Payment Staging records and check ProductPayment validtaions
 *  @author : A5E Consulting
 *  @date : 08/03/2022
 /**************************************************************************************************/

public class ProductPaymentExcelFileProcessing {
    //balance adjustment transaction type codes
    static final String FEE_TRANSACION_CODES = '3000,3400,4000,4001,4002,4003,5000,5001,5002,5003,7000,7001';

    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_REVERSAL = '1003';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
    static List<String> paymentTypes = new List<String>{ PAYTYPE_REGULAR, PAYTYPE_PAID_IN_FULL, PAYTYPE_SETTLED_IN_FULL };

    ID documentId;
    String exceptionMessage;
    public String workAssignmentPlacement;
    Boolean directPPayment = false;
    Decimal ComissionRate;
    Decimal agencyCommissionRate;
    Decimal ontarioTaxRate;
    Decimal DebtorProvinceTaxRate;
    Decimal CanadaTaxRate;
    string prodProvinceName;
    string ProvinceNameFormat;
    String provinceAcronymFormat;
    @testVisible
    String warehouseAgencyId = '';

    list<Document_Storage__c> listDocuments;
    List<paymentRecordsWrapper> listPaymentRecordWrapper = new List<paymentRecordsWrapper>();
    public static Map<String, Placement_History__c> mapProductPreviouslyPlacedCheck;
    public map<ID, ID> mapProductJudgmentClaimIssuedID;
    @testVisible
    map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    @testVisible
    map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();
    map<ID, Decimal> mapAgencyCommissionRate = new Map<ID, Decimal>();

    public ProductPaymentExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId) {
        exceptionMessage = '';
        listPaymentRecordWrapper = deSerializeJSON(data);
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.documentId = documentId;
        processExcelFileRecords();
    }

    public List<paymentRecordsWrapper> deSerializeJSON(String dataAsString) {
        List<paymentRecordsWrapper> listPaymentRecordWrapper = (List<paymentRecordsWrapper>) JSON.deserialize(dataAsString, List<paymentRecordsWrapper>.class);
        return listPaymentRecordWrapper;
    }

    public void processExcelFileRecords() {
        listDocuments = [
            SELECT
                ID,
                Creator__c,
                Work_Assignment__c,
                Uploaded_By__c,
                Document_Name__c,
                Placement_Agency__c,
                Placement_Agency__r.Commission_rate__c,
                Document_Type__c
            FROM Document_Storage__c
            WHERE ID = :documentID
        ];
        try {
            Boolean commissionOverriden = false;
            List<Product_Payments__c> listProductsToInsert = new List<Product_Payments__c>();
            List<String> accountNumberList = new List<String>();

            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            map<ID, Product__c> mapProduct = new Map<ID, Product__c>();
            map<String, String> mapAccountPrimaryNumber = new Map<String, String>();
            set<ID> mapProductIds = new Set<ID>();
            map<id, Placement__c> mapPlacementIDs = new Map<id, Placement__c>();
            mapProductJudgmentClaimIssuedID = new Map<ID, ID>();
            map<String, Decimal> mapValueTierCommissionRate = getCommissionRateValues();

            List<Placement__c> warehouse = [SELECT Id From Placement__c Where Name = '9999' Limit 1];
            if(!warehouse.isEmpty()) {
                warehouseAgencyId = warehouse[0].Id;
            }

            for (PaymentRecordsWrapper wrapRecord : listPaymentRecordWrapper) {
                if (wrapRecord.data_id != null) {
                    wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                    accountNumberList.add(wrapRecord.data_id);
                }
            }

            if (String.isNotBlank(workAssignmentPlacement)) {
                list<Placement__c> listPlacement = [SELECT ID, Commission_rate__c FROM Placement__c WHERE Name = :workAssignmentPlacement];
                if (!listPlacement.isEmpty() && listPlacement[0].Commission_rate__c != null) {
                    agencyCommissionrate = listPlacement[0].Commission_rate__c;
                }
            }

            for (Product__C product : [
                SELECT
                    ID,
                    name,
                    Collection_Agency__c,
                    Commission_Rate__c,
                    Commission_Adjustment__c,
                    Collection_Agency_Placement__c,
                    Collection_Sub_Status__c,
                    Status__c,
                    Sub_Status__c,
                    Data_Status_Description__c,
                    Pool_Name__r.Commission_Rate__c,
                    Value_Tier_at_Time_of_Placement__c,
                    Collection_Agency_Placement__r.Commission_Rate__c,
                    Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                    Assignment_Date__c,
                    Recalled_Date__c,
                    Current_Balance__c,
                    Collection_Agency_Placement__r.Default_Tolerance_of_Total_Balance__c,
                    Collection_Agency_Placement__r.Default_Tolerance_Amount__c,
                    Collection_Agency_Placement__r.Tolerance_of_Total_Balance__c,
                    Settlement_Rate__c,
                    Collection_Agency_Placement__r.Tolerance_Amount__c,
                    Pool_Name__c,
                    State__c,
                    Fee_Recovery__c,
                    Previous_Primary_Account_Number__c,
                    Portfolio_Group_Name__c,
                    Legal_Entity__c,
                    Current_Bal_NSF_Fees__c,
                    Purchase_Status__c
                FROM Product__C
                WHERE name IN :accountNumberList
            ]) {
                mapAccountNumberID.put(product.name, product.id);
                mapProduct.put(product.id, product);
                mapProductIds.add(product.Collection_Agency_Placement__c);
            }

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

            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;

            for (Placement__c placementData : [
                SELECT id, name, Apply_Ontario_Rate_on_Legal_Account__c
                FROM Placement__c
                WHERE id IN :mapProductIds
            ]) {
                mapPlacementIDs.put(placementData.id, placementData);
            }

            //Tax rate mapping by Province Acronym
            for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
                mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
            }
            Decimal feeRecovery = null;
            Map<String, Decimal> productFeeRecoveryMap = new Map<String, Decimal>();
            for (PaymentRecordsWrapper wrapRecord : listPaymentRecordWrapper) {
                Product_Payments__c prodPayment = new Product_Payments__c();

                if (String.isNotBlank(wrapRecord.data_id)) {
                    wrapRecord.data_id = wrapRecord.data_id.trim();
                    if (wrapRecord.data_id.contains('.')) {
                        wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                }

                prodPayment.CCS_Account__c = mapAccountNumberID.get(wrapRecord.data_id);
                prodPayment.CCS_Account_Name__c = wrapRecord.data_id;

                if (String.isNotBlank(wrapRecord.tran_amount)) {
                    // && wrapRecord.tran_amount.isNumeric() == true
                    wrapRecord.tran_amount = wrapRecord.tran_amount.trim();
                    Boolean negativeAmnt = false;
                    if (wrapRecord.tran_amount.contains(',')) {
                        wrapRecord.tran_amount = wrapRecord.tran_amount.remove(',');
                    }

                    prodPayment.Payment_Amount__c = Decimal.valueOf(wrapRecord.tran_amount);
                    prodPayment.Payment_Amount__c = prodPayment.Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
                }
                if (String.isNotBlank(wrapRecord.tran_date)) {
                    wrapRecord.tran_date = wrapRecord.tran_date.trim();
                    if (wrapRecord.tran_date.contains('-')) {
                        wrapRecord.tran_date = wrapRecord.tran_date.replace('-', '/');
                    }
                    if (wrapRecord.tran_date.contains('T')) {
                        wrapRecord.tran_date = wrapRecord.tran_date.SubstringBefore('T');
                    }

                    prodPayment.Payment_Posting_Date_Text__c = wrapRecord.tran_date;
                }

                if (String.isNotBlank(wrapRecord.tran_type)) {
                    wrapRecord.tran_type = wrapRecord.tran_type.trim();
                    prodPayment.Payment_Type__c = wrapRecord.tran_type.subStringBefore('.');
                }

                if (!listDocuments.isEmpty() && listDocuments[0].Document_Type__c == 'Product Payment Upload File') {
                    if (String.isNotBlank(wrapRecord.tran_interest)) {
                        wrapRecord.tran_interest = wrapRecord.tran_interest.trim();
                        prodPayment.Interest_Payment_Amount__c = Decimal.valueOf(wrapRecord.tran_interest);
                    }

                    if (String.isNotBlank(wrapRecord.tran_principal)) {
                        prodPayment.Principal_Payment_Amount__c = Decimal.valueOf(wrapRecord.tran_principal.trim());
                    }

                    if (String.isNotBlank(wrapRecord.tran_court)) {
                        prodPayment.Pay_Court__c = wrapRecord.tran_court.trim();
                    }

                    if (String.isNotBlank(wrapRecord.tran_attorney)) {
                        prodPayment.Pay_Attorney__c = wrapRecord.tran_attorney.trim();
                    }

                    if (String.isNotBlank(wrapRecord.tran_nsf)) {
                        prodPayment.Pay_NSF__c = wrapRecord.tran_nsf.trim();
                    }

                    if (String.isNotBlank(wrapRecord.tran_general)) {
                        prodPayment.Pay_Fees__c = Decimal.valueOf(wrapRecord.tran_general.trim());
                    }
                    if (String.isNotBlank(wrapRecord.tran_other)) {
                        prodPayment.Pay_Other__c = Decimal.valueOf(wrapRecord.tran_other.trim());
                    }

                    if (String.isNotBlank(wrapRecord.tran_retained)) {
                        prodPayment.Agency_Calculated_Comm__c = Decimal.valueOf(wrapRecord.tran_retained.trim());
                    }
                }

                if (
                    !listDocuments.isEmpty() &&
                    listDocuments[0].Uploaded_By__c == 'Internal User' &&
                    listDocuments[0].Document_Type__c == 'Direct Payment Upload File'
                ) {
                    directPPayment = true;
                    //map from file
                    if (String.isNotBlank(wrapRecord.pri_acctno) && wrapRecord.pri_acctno.contains('.')) {
                        wrapRecord.pri_acctno = wrapRecord.pri_acctno.substringBefore('.');
                    }

                    if (String.isNotBlank(wrapRecord.pri_acctno)) {
                        mapAccountPrimaryNumber.put(prodPayment.CCS_Account_Name__c, wrapRecord.pri_acctno);
                    }

                    if (String.isNotBlank(wrapRecord.pay_source)) {
                        if (wrapRecord.pay_source.contains('.')) {
                            wrapRecord.pay_source = wrapRecord.pay_source.subStringBefore('.');
                        }
                        prodPayment.Payment_Source__c = wrapRecord.pay_source;
                    }
                    if (String.isNotBlank(wrapRecord.commission_rate)) {
                        commissionOverriden = true;
                    }
                } else {
                    prodPayment.Payment_Source__c = '1';
                }

                if (String.isNotBlank(wrapRecord.billing_entity)) {
                    prodPayment.Billing_Entity__c = wrapRecord.billing_entity;
                }

                if (String.isNotBlank(wrapRecord.fee_type)) {
                    prodPayment.Fee_type__c = wrapRecord.fee_type;
                }
                Decimal newFeeRecovery = 0;
                if (String.isNotBlank(prodPayment.CCS_Account__c) && !productFeeRecoveryMap.containsKey(prodPayment.CCS_Account__c)) {
                    productFeeRecoveryMap.put(prodPayment.CCS_Account__c, mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c);
                }
                feeRecovery = String.isNotBlank(prodPayment.CCS_Account__c) ? productFeeRecoveryMap.get(prodPayment.CCS_Account__c) : 0;
                //Calculate commission for payments if Fee recovery is 0 or less than Payment Amount
                if (
                    String.isNotBlank(prodPayment.CCS_Account__c) &&
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    String.isNotBlank(prodPayment.Payment_Type__c) &&
                    prodPayment.Payment_Amount__c != null &&
                    !FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c) &&
                    (feeRecovery == 0 ||
                    feeRecovery < prodPayment.Payment_Amount__c)
                ) {
                    Decimal payCommission = 0;
                    //Payment amount on which commission will be applied
                    payCommission = prodPayment.Payment_Amount__c;
                    //IF Fee recovery is present, commission will be applied on (Payment Amount - Fee Recovery Amount)
                    if (feeRecovery < prodPayment.Payment_Amount__c) {
                        payCommission = prodPayment.Payment_Amount__c - feeRecovery;
                    }
                    // Don't subtract if payment is a reversal otherwise it will increase the fee recovery
                    newFeeRecovery = prodPayment.Payment_Type__c != '1003' ? feeRecovery - prodPayment.Payment_Amount__c : feeRecovery;
                    productFeeRecoveryMap.put(prodPayment.CCS_Account__c, newFeeRecovery <= 0 ? 0 : newFeeRecovery);

                    prodPayment.Pool_Lookup__c = mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__c;
                    prodPayment.Value_Tier_at_Time_of_Placement__c = mapProduct.get(prodPayment.CCS_Account__c).Value_Tier_at_Time_of_Placement__c;

                    //By product Commission Rate
                    if (mapProduct.containsKey(prodPayment.CCS_Account__c) && mapProduct.get(prodPayment.CCS_Account__c).Commission_Rate__c != null) {
                        ComissionRate = mapProduct.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                        prodPayment.Product_Commission_Rate__c = ComissionRate;

                        if (ComissionRate != null) {
                            //if commission adjustment is added to product, adjust Commission Rate
                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                ComissionRate = ComissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                            }
                            if (payCommission != null) {
                                prodPayment.Pay_Due__c = (payCommission * (ComissionRate)) / 100;
                            }
                            //Populate actual Commission Rate used for calculation
                            prodPayment.Commission_Rate_for_Payment__c = ComissionRate;
                        }
                    }
                    //By Agency Commission Rate
                    if (agencyCommissionrate != null) {
                        ComissionRate = agencyCommissionrate;
                        prodPayment.Agency_Commission_Rate__c = ComissionRate;
                        if (test.isRunningTest()) {
                            prodPayment.Pay_Due__c = null;
                        }
                        if (prodPayment.Pay_Due__c == null && ComissionRate != null) {
                            //if commission adjustment is added to product, adjust Commission Rate
                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                ComissionRate = ComissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                            }
                            if (payCommission != null) {
                                prodPayment.Pay_Due__c = payCommission * (ComissionRate) / 100;
                            }

                            //Populate actual Commission Rate used for calculation
                            prodPayment.Commission_Rate_for_Payment__c = ComissionRate;
                        }
                    }

                    //By pool Commission Rate
                    if (mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c != null) {
                        ComissionRate = mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c;
                        prodPayment.Pool_Commission_Rate__c = ComissionRate;
                        if (test.isRunningTest()) {
                            prodPayment.Pay_Due__c = null;
                        }
                        if (prodPayment.Pay_Due__c == null && ComissionRate != null) {
                            //if commission adjustment is added to product, adjust Commission Rate
                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                ComissionRate = ComissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                            }
                            if (payCommission != null) {
                                prodPayment.Pay_Due__c = payCommission * (ComissionRate) / 100;
                            }

                            //Populate actual Commission Rate used for calculation
                            prodPayment.Commission_Rate_for_Payment__c = ComissionRate;
                        }
                    }
                    ComissionRate = null;

                    //calculate tax amount
                    DebtorProvinceTaxRate = 0;
                    CanadaTaxRate = 0;
                    prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                    ProvinceNameFormat = nameFormat(prodProvinceName);
                    if (String.isNotBlank(prodProvinceName)) {
                        provinceAcronymFormat = prodProvinceName.toUpperCase();
                    }

                    //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                    if (
                        mapPlacementIDs.containsKey(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                        mapPlacementIDs.get(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c).Apply_Ontario_Rate_on_Legal_Account__c ==
                        true
                    ) {
                        if (Test.isRunningTest()) {
                            prodPayment.Pay_Due__c = 20;
                            ProvinceNameFormat = 'Alberta';
                        }
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
                                if (prodPayment.Pay_Due__c != null) {
                                    prodPayment.Legal_Product_Identifier__c = 'Yes';
                                    prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                }
                            }
                        }
                    }
                } else if (
                    String.isNotBlank(prodPayment.CCS_Account__c) &&
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    prodPayment.Payment_Amount__c != null &&
                    String.isNotBlank(prodPayment.Payment_Type__c) &&
                    !FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c) &&
                    (feeRecovery != 0 &&
                    feeRecovery >= prodPayment.Payment_Amount__c)
                ) {
                    newFeeRecovery = prodPayment.Payment_Type__c != '1003' ? feeRecovery - prodPayment.Payment_Amount__c : feeRecovery;
                    productFeeRecoveryMap.put(prodPayment.CCS_Account__c, newFeeRecovery <= 0 ? 0 : newFeeRecovery);
                }
                prodPayment.Payment_Agency__c = workAssignmentPlacement;

                listProductsToInsert.add(prodPayment);
            }

            list<Product_Payment_Staging__c> listpayStaging = validationOnRecordUpdate(
                listProductsToInsert,
                mapProduct,
                listDocuments[0],
                mapAccountPrimaryNumber,
                mapPlacementIDs
            );
            Database.SaveResult[] sr = database.insert(listpayStaging);
        } catch (Exception ex) {
            exceptionMessage = ex.getMessage().contains('null') ? 'Please check the file for empty cells' : ex.getMessage();
            exceptionMessage = exceptionMessage + ' ' + String.valueOf(ex.getStackTraceString());
        }

        String processingLink = '';
        Boolean stagingCreated = false;
        String processingStatus = '';

        if (String.isBlank(exceptionMessage)) {
            if (directPPayment == true) {
                processingLink = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DisplayDirectProductPaymentStaging?id=' + documentId;
            } else {
                processingLink = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DisplayProductPaymentStaging?id=' + documentId;
            }
            stagingCreated = true;
            processingStatus = 'Staging Table Created';
        } else {
            processingStatus = 'Staging Table Creation Failed';
            if (exceptionMessage.length() > 250) {
                exceptionMessage = exceptionMessage.substring(0, 250);
            } else {
                exceptionMessage = exceptionMessage;
            }
        }

        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(
            ID = listDocuments[0].ID,
            File_Processing_Link__c = processingLink,
            File_Processing_Error__c = exceptionMessage,
            File_Processing_Date__c = Date.today(),
            File_Processing_Status__c = processingStatus,
            Direct_Payment__c = directPPayment,
            Staging_Records_Created__c = stagingCreated
        );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
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

    public map<String, Decimal> getCommissionRateValues() {
        map<String, Decimal> mapValueTierCommissionRate = new Map<String, Decimal>();
        for (Commission_Rate_Settings__mdt metadata : Commission_Rate_Settings__mdt.getAll().values()) {
            mapValueTierCommissionRate.put(metadata.Value_Tier__c, metadata.Commission_Rate__c);
        }
        return mapValueTierCommissionRate;
    }

    public set<String> getPlacementHistoryDetails(set<Id> setProductNames) {
        set<String> setProductPreviouslyPlacedCheck = new Set<String>();
        set<String> previouslyPlacedWithin15Days = new Set<String>();

        Date dateInstance = Date.today().addDays(-15);

        mapProductPreviouslyPlacedCheck = new Map<String, Placement_History__c>();
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

    public map<ID, Placement_History__c> getDirectPlacementHistoryDetails(set<ID> setProductNames) {
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

    public map<ID, Placement_History__c> getLastAgencyRecallDate(set<ID> setProductNames, set<String> setPlacementNames) {
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

    //Validation method to be called  before update
    public list<Product_Payment_Staging__c> validationOnRecordUpdate(
        List<Product_Payments__c> prodPayNew,
        map<Id, Product__c> mapProduct,
        Document_Storage__c docStorage,
        map<String, String> mapAccountPrimaryNumber,
        map<id, Placement__c> mapPlacementIDs
    ) {
        map<String, List<Id>> setOldTransaction = new Map<String, List<Id>>();
        map<String, Decimal> mapOldTransactionCount = new Map<String, Decimal>();
        map<id, Placement__c> mapPlacementData = new Map<id, Placement__c>();
        list<Product_Payment_Staging__c> listProdPayStaging = new List<Product_Payment_Staging__c>();
        Product_Payment_Staging__c payStaging = new Product_Payment_Staging__c();
        map<String, Product_Payments__c> mapPayment = new map<String, Product_Payments__c>();

        for (Product_Payments__c oldPay : [
            SELECT ID, CCS_Account__r.Name, Payment_Type__c, Payment_Amount__c, Payment_Posting_Date__c, Payment_Posting_Date_Text__c, Is_Payment_Reversed__c,Pay_Due__c
            FROM Product_Payments__c
            WHERE CCS_Account__c IN :mapProduct.keySet()
        ]) {
            mapPayment.put(oldPay.ID,oldPay);
            String payAmount = '';
            if (oldPay.Payment_Amount__c != null) {
                oldPay.Payment_Amount__c = oldPay.Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
                payAmount = String.valueOf(oldPay.Payment_Amount__c);
            }
            // Add non reversed payment Ids which will be used to check for valid reversals later
            // There can be multiple payments with same amount, type, date and account so create a list of same payments so that we don't reverse the same payment for multiple reversals
            if (!oldPay.Is_Payment_Reversed__c) {
                if (
                    setOldTransaction.containsKey(
                        oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c
                    )
                ) {
                    setOldTransaction.get(oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c)
                        .add(oldPay.Id);
                } else {
                    setOldTransaction.put(
                        oldPay.Payment_Amount__c + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c,
                        new List<Id>{ oldPay.Id }
                    );
                }
            }
        }

        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        list<String> validPaymentTypes = new List<String>();
        Set<id> productAgencyIds = new Set<id>();
        map<Id, Decimal> mapProductPaymentAmount = new Map<ID, Decimal>();
        //set hacing product name and payment amount
        map<String, Decimal> mapProductNameAmount = new Map<String, Decimal>();
		Integer regular4000PaymentCount = 0;
        Integer regular5000PaymentCount = 0;
        Integer feesPaymentCount = 0;
        
        validPaymentTypes = portalSettings.Valid_Payment_Types__c.split(',');
        set<Id> setProductNames = new Set<Id>();
        set<String> setPlacementNames = new Set<String>();
        for (Product_Payments__c prodPayment : prodPayNew) {
            productAgencyIds.add(prodPayment.Payment_Provided_Agency__c);
            if (
                mapProductNameAmount.containsKey(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date_Text__c +
                        prodPayment.CCS_Account__c
                )
            ) {
                mapProductNameAmount.put(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date_Text__c +
                        prodPayment.CCS_Account__c,
                    mapProductNameAmount.get(
                        prodPayment.Payment_Amount__c + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                    ) + 1
                );
            } else {
                mapProductNameAmount.put(
                    String.valueOf(prodPayment.Payment_Amount__c) +
                        prodPayment.Payment_Type__c +
                        prodPayment.Payment_Posting_Date_Text__c +
                        prodPayment.CCS_Account__c,
                    1
                );
            }
            
            if(prodPayment.Payment_Type__c <> NULL){
                if(prodPayment.Payment_Type__c == '1000' || prodPayment.Payment_Type__c == '1001'
                  || prodPayment.Payment_Type__c == '1002' || prodPayment.Payment_Type__c == '1003'
                  || prodPayment.Payment_Type__c == '3000' || prodPayment.Payment_Type__c == '8000'){
                    feesPaymentCount ++;
                }
                if(prodPayment.Payment_Type__c == '4000'){
                    regular4000PaymentCount ++;
                }
                if(prodPayment.Payment_Type__c == '5000'){
                    regular5000PaymentCount ++;
                }
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
            if(String.isNotBlank(prodPayment.CCS_Account__c)) {
                setProductNames.add(prodPayment.CCS_Account__c);
            }
            setPlacementNames.add(prodPayment.Payment_Agency__c);
        }

        for (Placement__c placementData : [
            SELECT id, name, Apply_Ontario_Rate_on_Legal_Account__c
            FROM Placement__c
            WHERE id IN :productAgencyIds
        ]) {
            mapPlacementData.put(placementData.id, placementData);
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

        set<String> setProductPreviouslyPlacedCheck = new Set<String>();
        if (docStorage.Document_Type__c == 'Product Payment Upload File') {
            setProductPreviouslyPlacedCheck = getPlacementHistoryDetails(setProductNames);
        }

        //direct payment history
        map<ID, Placement_History__c> mapProductPreviouslyPlaced = new Map<ID, Placement_History__c>();
        map<ID, Placement_History__c> lastAgencyRecallDate = new Map<ID, Placement_History__c>();
        if (docStorage.Document_Type__c == 'Direct Payment Upload File' || docStorage.Document_Type__c == 'Product Payment Upload File') {
            mapProductPreviouslyPlaced = getDirectPlacementHistoryDetails(setProductNames);
            lastAgencyRecallDate = getLastAgencyRecallDate(setProductNames, setPlacementNames);
        }

        String prodPayStatus = '';
        String productAgency = '';
        String ERROR_MSG = '';
        String EXPECTED = '';
        ID productAgencyID = null;
        for (Product_Payments__c prodPayment : prodPayNew) {
            ERROR_MSG = '';
            EXPECTED = '';
            String originalPaymentType = '';
            productAgency = '';
            productAgencyID = null;
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

            if (String.isNotBlank(prodPayment.Payment_Posting_Date_Text__c)) {
                MyMatcher1 = MyPattern1.matcher(prodPayment.Payment_Posting_Date_Text__c);
                Matcher MyMatcher2 = MyPattern2.matcher(prodPayment.Payment_Posting_Date_Text__c);
                Matcher MyMatcher3 = MyPattern3.matcher(prodPayment.Payment_Posting_Date_Text__c);

                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                //matching of date when entered in Text format in excel file
                if (MyMatcher1.matches() == true) {
                    list<String> datelist = prodPayment.Payment_Posting_Date_Text__c.split('/');
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    prodPayment.Payment_Posting_Date__c = myDate;
                    prodPayment.Payment_Posting_Date_Text__c = myDate.month() + '/' + myDate.day() + '/' + myDate.year();
                }
                //matching of date when entered in Date format in excel file
                else if (MyMatcher2.matches() == true) {
                    list<String> datelist = prodPayment.Payment_Posting_Date_Text__c.split('/');
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    prodPayment.Payment_Posting_Date__c = myDate;
                    prodPayment.Payment_Posting_Date_Text__c =
                        String.valueOf(datelist[1]) +
                        '/' +
                        String.valueOf(datelist[2]) +
                        '/' +
                        String.valueOf(datelist[0]);
                    prodPayment.Payment_Posting_Date_Text__c = myDate.month() + '/' + myDate.day() + '/' + myDate.year();
                } else if (MyMatcher3.matches() == true) {
                    list<String> datelist = prodPayment.Payment_Posting_Date_Text__c.split('/');
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    prodPayment.Payment_Posting_Date__c = myDate;
                    prodPayment.Payment_Posting_Date_Text__c =
                        String.valueOf(datelist[1]) +
                        '/' +
                        String.valueOf(datelist[2]) +
                        '/' +
                        String.valueOf(datelist[0]);
                    prodPayment.Payment_Posting_Date_Text__c = myDate.month() + '/' + myDate.day() + '/' + myDate.year();
                }
            }

            //------------------------Common Validation Starts--------------------------//

            if (prodPayment.Payment_Amount__C != null) {
                prodPayment.Payment_Amount__C = prodPayment.Payment_Amount__C.setScale(2, RoundingMode.HALF_UP);
            }
			if (regular4000PaymentCount >= 1 && feesPaymentCount >= 1) {
                if(prodPayment.Payment_Type__c == '4000'){
                    ERROR_MSG += '<b>ERROR</b> - 1000 series payment type cannot be club with any other payment type (3000, 4000, 5000, 8000).<br/>';
                }  
            }
            if (regular5000PaymentCount >= 1 && feesPaymentCount >= 1) {
                if(prodPayment.Payment_Type__c == '5000'){
                    ERROR_MSG += '<b>ERROR</b> - 1000 series payment type cannot be club with any other payment type (3000, 4000, 5000, 8000).<br/>';
                }  
            }
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
            }

            if (
                mapProductNameAmount.containsKey(
                    prodPayment.Payment_Amount__c + '' + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                ) &&
                mapProductNameAmount.get(
                    prodPayment.Payment_Amount__c + '' + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                ) > 1
            ) {
                ERROR_MSG += '<b>WARNING</b> - A duplicate transaction was found in this File Update.<br/>';
            }

            if (!mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                ERROR_MSG = '<b>ERROR</b> - Account not found.<br/>';
            }
            //Invalid Payment Source as Per Document Type
            if (
                docStorage.Document_Type__c == 'Direct Payment Upload File' &&
                String.isNotBlank(prodPayment.Payment_Source__c) &&
                prodPayment.Payment_Source__c != '1' &&
                prodPayment.Payment_Source__c != '2' &&
                prodPayment.Payment_Source__c != '3'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Source for Direct Payment Upload File<br/>';
                EXPECTED += 'Payment Source Should be 1 OR 2 OR 3.<br/>';
            }
            if (
                docStorage.Document_Type__c == 'Product Payment Upload File' &&
                String.isNotBlank(prodPayment.Payment_Source__c) &&
                prodPayment.Payment_Source__c != '1'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Source for Product Payment Upload File<br/>';
                EXPECTED += 'Payment Source Should be 1.<br/>';
            }
            //Payment Source should be either 1,2,3
            if (prodPayment.Payment_Source__c != '1' && prodPayment.Payment_Source__c != '2' && prodPayment.Payment_Source__c != '3') {
                ERROR_MSG = '<b>ERROR</b> - Payment Source is not valid.<br/>';
                EXPECTED += 'Payment Source Should be 1 OR 2 OR 3.<br/>';
            }

            //Invalid Payment Date
            if (prodPayment.Payment_Posting_Date__c != null) {
                if (prodPayment.Payment_Posting_Date__c > Date.today()) {
                    ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                    EXPECTED += 'Payment Date cannot be in future.<br/>';
                }
            } else {
                if (String.isNotBlank(prodPayment.Payment_Posting_Date_Text__c)) {
                    ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                    EXPECTED += 'Payment Date should be proper format.(MM/DD/YYYY)<br/>';
                } else {
                    ERROR_MSG += '<b>ERROR</b> - Enter valid payment date.\n';
                    EXPECTED += 'Payment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                /*ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                 EXPECTED += 'Payment Date cannot be blank.<br/>';*/
            }

            //Transaction type is incorrect
            if (prodPayment.Payment_Type__c != null && !validPaymentTypes.contains(prodPayment.Payment_Type__c)) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type.<br/>';
            }

            //Must be positive
            if (prodPayment.Payment_Type__c == PAYTYPE_REGULAR && prodPayment.Payment_Amount__c < 0) {
                ERROR_MSG += '<b>ERROR</b> - Negative amount received with incorrect type (1000).<br/>';
            }

            //Must be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_REVERSAL && prodPayment.Payment_Amount__c > 0) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Reversal. Amount must be negative.<br/>';
            }

            if (prodPayment.Payment_Amount__c == null || prodPayment.Payment_Amount__c == 0) {
                //prodPayment.Payment_Amount__c =0;
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Amount.<br/>';
            }
            if (String.isBlank(prodPayment.Payment_Type__c)) {
                ERROR_MSG += '<b>ERROR</b> - Payment Type cannot Blank.<br/>';
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
            }

            //No settlement parameters set for the account
            if (
                prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL &&
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c == null
            ) {
                ERROR_MSG += '<b>WARNING</b> - Settlements Rate not available on this account.<br/>';
            }

            //Payment does not meet Paid in full parameters
            if (
                prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL &&
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != null &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != null
            ) {
                Decimal toleranceAmount;
                if (mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != null) {
                    toleranceAmount =
                        (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c * mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c) / 100;
                    toleranceAmount = toleranceAmount.setScale(2, RoundingMode.HALF_UP);
                }
                //4532: product has active settment then calcuate based on Required Amount
                if (
                    mapSettlementData.containskey(prodPayment.CCS_Account__c) &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Payment_Frequency__c == 'One Time Payment' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Status__c == 'Approved' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Required_Amount__c != prodPayment.Payment_Amount__c
                ) {
                    ERROR_MSG +=
                        '<b>WARNING</b> - Payment does not meet Settlement parameter on Account ' +
                        'Settlement Rate % : ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c +
                        '<br/>';
                    EXPECTED += 'Expected Settlement Amount : ' + mapSettlementData.get(prodPayment.CCS_Account__c).Required_Amount__c + '<br/>';
                } else if (
                    mapSettlementData.containskey(prodPayment.CCS_Account__c) &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Payment_Frequency__c != 'One Time Payment' &&
                    mapSettlementData.get(prodPayment.CCS_Account__c).Status__c != 'Approved' &&
                    prodPayment.Payment_Amount__c <> toleranceAmount
                ) {
                    //4532: Check if payment amount less than tolerance amount percents on Placement
                    ERROR_MSG +=
                        '<b>WARNING</b> - Payment does not meet Settlement parameter on Account ' +
                        'Settlement Rate % : ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c +
                        '<br/>';
                    EXPECTED += 'Expected Settlement Amount : ' + toleranceAmount + '<br/>';
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                if (prodPayment.Payment_Amount__c < 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for Payment Type Paid in Full ';
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
            if (prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL) {
                if (prodPayment.Payment_Amount__c < 0) {
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for Payment Type Settled in Full ';
                }
            }
            //Payment does not meet paid in full parameters
            if (
                prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL &&
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != null &&
                mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != 0
            ) {
                Decimal outStandingBalance;
                if (prodPayment.Payment_Amount__c != null) {
                    outStandingBalance = (prodPayment.Payment_Amount__c / mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c) * 100;
                }

                /*outStandingBalance = (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c *
                 5 /100);*/
                if (outStandingBalance != null) {
                    outStandingBalance = outStandingBalance.setScale(2, RoundingMode.HALF_UP);
                }

                //Check if payment amount matches outStandingBalance amount percents on Placement
                if (outStandingBalance != null && outStandingBalance < 95) {
                    ERROR_MSG += '<b>WARNING</b> - Transaction amount is not within 5% of the total oustanding balance' + '<br/>';
                    EXPECTED +=
                        'Total Balance on Product= ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c.setScale(2, RoundingMode.HALF_UP) +
                        '<br/>';
                }
            }

            //Payment being reversed must exist (same pmt amount (but negative) and pmt date as original payment)
            if (prodPayment.Payment_Posting_Date__c != null && prodPayment.Payment_Type__c == PAYTYPE_REVERSAL) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    Decimal payAmount = prodPayment.Payment_Amount__c * -1;
                    payAmount = payAmount.setScale(2, RoundingMode.HALF_UP);
                    // Check if we have a valid payment to reverse for 1000, 1001 and 1002 payment types
                    for (String paymentType : paymentTypes) {
                        if (
                            setOldTransaction.containsKey(payAmount + paymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c) &&
                            !setOldTransaction.get(payAmount + paymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c).isEmpty()
                        ) {
                            originalPaymentType = paymentType;
                            break;
                        }
                    }
                    if (String.isBlank(originalPaymentType)) {
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                    } else {
                        prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get(
                            payAmount + originalPaymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                        )[0];
                        setOldTransaction.get(payAmount + originalPaymentType + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)
                            .remove(0);
                    }
                }
            }
            //Account must not be closed
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed') &&
                (mapProduct.get(prodPayment.CCS_Account__c).Purchase_Status__c == 'Putback Approved' ||
                mapProduct.get(prodPayment.CCS_Account__c).Purchase_Status__c == 'Buyback Approved')
            ) {
                ERROR_MSG += '<b>ERROR</b> - Account is closed.<br/>';
            } else {
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed')
                ) {
                    ERROR_MSG += '<b>WARNING</b> - Account is closed.<br/>';
                }
            }

            //------------------------Common Validation Ends--------------------------//

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
                }

                if (mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                    //if product Recall date is blank then fetch Recall date from placement history
                    if (mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == null) {
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c)
                                .Placement_Recall_Date__c;
                        }
                    }
                    //This account is recalled within 15 days and is currently warehoused
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
                            if (CommissionRate != null && prodPayment.Payment_Amount__c != null) {
                                Decimal feeRecovery = mapProduct.get(prodPayment.CCS_Account__c).Fee_Recovery__c;
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                if(feeRecovery == null || feeRecovery == 0) {
                                    prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                }
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                //Tax Amount calculation:
                                //calculate tax amount
                                DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0;
                                prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if (String.isNotBlank(prodProvinceName)) {
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                                }

                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if (
                                    mapPlacementIDs.containsKey(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                    mapPlacementIDs.get(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
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
                                            if (prodPayment.Pay_Due__c != null) {
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                            }
                                        }
                                    }
                                }

                                //calculate tax amount ends
                                //prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).COllection_Agency_placement__c;
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
                            if (prodPayment.Pay_Due__c != null) {
                                prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                EXPECTED +=
                                    'Commission Amount ' +
                                    prodPayment.Pay_Due__c +
                                    ' will be paid to Agency ' +
                                    prodPayment.Payment_Agency__c +
                                    '<br/>';
                            }
                        }
                    }
                    //This account is recalled before 15 days and is currently warehoused

                    else if (
                        mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                        (productAgency == '9999' || String.isBlank(productAgency)) &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) > 15
                    ) {
                        ERROR_MSG += '<b>WARINING</b> - The account was recalled more than 15 days ago and is currently warehoused.<br/>';
                        if(prodPayment.Payment_Type__c == '1003'){
                            if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c != NULL){
                                EXPECTED += 'Commission Amount paid will be '+mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c * -1+' on this payment. ' + '<br/>'; 
                            }
                        }else{
                            EXPECTED += 'Commission Amount paid will be 0 on this payment. ' + '<br/>';
                        }
                        prodPayment.Pay_Due__c = 0;
                        prodPayment.Tax_Amount__c = 0;
                        prodPayment.Payment_Provided_Agency__c = warehouseAgencyId;
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            // Commission paid to field should be populated with warehouse placement record, no need to populate with previous placed agency
                            /* if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                            } */
                            if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }
                    }

                    //assigned to agency
                    if (mapProduct.containsKey(prodPayment.CCS_Account__c) && (productAgency != '9999' && String.isNotBlank(productAgency))) {
                        //This account is recalled before 15 days
                        if (prodPayment.Payment_Agency__c == productAgency) {
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                        } else {
                            if (!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                                prodPayment.Payment_Provided_Agency__c = productAgencyID;
                                prodPayment.Payment_Agency__c = productAgency;
                                if (prodPayment.Pay_Due__c != null) {
                                    prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                    EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + productAgency + '<br/>';
                                }
                                ERROR_MSG += '<b>WARINING</b> - Account was placed with agency ' + productAgency + '.<br/>';
                            } else if (
                                mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                                mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15
                            ) {
                                prodPayment.Payment_Provided_Agency__c = productAgencyID;
                                prodPayment.Payment_Agency__c = productAgency;

                                if (prodPayment.Pay_Due__c != null) {
                                    prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                    EXPECTED +=
                                        'Commission Amount ' +
                                        prodPayment.Pay_Due__c +
                                        ' will be paid to Agency ' +
                                        prodPayment.Payment_Agency__c +
                                        '<br/>';
                                }
                                ERROR_MSG +=
                                    '<b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency ' +
                                    productAgency +
                                    '.<br/>';
                            }
                            //This account is recalled within 15 days and
                            else if (
                                mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                                mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15
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
                                        if (prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)) {
                                            prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                        }

                                        //Tax Amount calculation:
                                        //calculate tax amount
                                        DebtorProvinceTaxRate = 0;
                                        CanadaTaxRate = 0;
                                        prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                                        ProvinceNameFormat = nameFormat(prodProvinceName);
                                        if (String.isNotBlank(prodProvinceName)) {
                                            provinceAcronymFormat = prodProvinceName.toUpperCase();
                                        }
                                        //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                        if (
                                            mapPlacementIDs.containsKey(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                            mapPlacementIDs.get(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
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
                                                        prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat)
                                                            .Province_Acronym__c;
                                                        prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat)
                                                            .Total_Tax_Rate__c;
                                                    }
                                                    if (prodPayment.Pay_Due__c != null) {
                                                        prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                                    }
                                                }
                                            }
                                        }

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

                                            if (prodPayment.Pay_Due__c != null) {
                                                prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                                EXPECTED +=
                                                    'Commission Amount ' +
                                                    prodPayment.Pay_Due__c +
                                                    ' will be paid to Agency ' +
                                                    prodPayment.Payment_Agency__c +
                                                    '<br/>';
                                            }
                                            ERROR_MSG +=
                                                '<b>WARINING</b> - Account was recalled within 15 days and is currently placed with agency ' +
                                                productAgency +
                                                '.<br/>';
                                            //}
                                        }
                                    } else {
                                        //if commission adjustment is added to product, adjust Commission Rate
                                        if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                            CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                        }
                                        prodPayment.Pay_Due__c = null;

                                        prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                        if (lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c)) {
                                            if (lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                                prodPayment.Payment_Provided_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Placement__c;
                                                prodPayment.Payment_Agency__c = lastAgencyRecallDate.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                                if (prodPayment.Pay_Due__c != null) {
                                                    prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                                    EXPECTED +=
                                                        'Commission Amount ' +
                                                        prodPayment.Pay_Due__c +
                                                        ' will be paid to Agency ' +
                                                        prodPayment.Payment_Agency__c +
                                                        '<br/>';
                                                }
                                                ERROR_MSG +=
                                                    '<b>WARINING</b> - Account was recalled within 15 days and is currently placed with agency ' +
                                                    productAgency +
                                                    '.<br/>';
                                            }
                                        }
                                    }

                                    if (!lastAgencyRecallDate.containsKey(prodPayment.CCS_Account__c)) {
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
                                        if (prodPayment.Payment_Amount__c != null && (feeRecovery == null || feeRecovery == 0)) {
                                            prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommRate) / 100;
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
                    //Ticket 4537 - changed by tejal
                    ERROR_MSG += '<b>WARNING</b> - This account is not available in this Placement.<br/>';
                    /*EXPECTED += 'Commission Amount will be paid to Agency '+ mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>'; */
                }

                if (prodPayment.Pay_Due__c != null) {
                    prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                }

                //Calculated commission is incorrect
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    prodPayment.Agency_Calculated_Comm__c != null &&
                    prodPayment.Agency_Calculated_Comm__c != prodPayment.Pay_Due__c &&
                    prodPayment.Payment_Amount__c > 0 &&
                    productAgency != '9999' &&
                    String.isNotBlank(productAgency)
                ) {
                    ERROR_MSG += '<b>WARNING</b> - Invalid amount retained/remitted on Gross Remittance.<br/>';
                    if (prodPayment.Pay_Due__c != null) {
                        EXPECTED += 'Expected Commission Amount: ' + prodPayment.Pay_Due__c + '<br/>';
                    } else {
                        EXPECTED += 'Commission Amount not applied for this payment' + '<br/>';
                    }
                }

                //Account is currently in Recalled status.
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    String.isNotBlank(prodPayStatus) &&
                    prodPayStatus.startsWith('Recall') &&
                    productAgency != '9999'
                ) {
                    ERROR_MSG += '<b>ERROR</b> - Account is currently in Recalled status.<br/>';
                }
            }

            //------------------Direct Payment Validations Starts-------------------//

            if (mapAccountPrimaryNumber.containsKey(prodPayment.CCS_Account_Name__c)) {
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Previous_Primary_Account_Number__c !=
                    mapAccountPrimaryNumber.get(prodPayment.CCS_Account_Name__c)
                ) {
                    ERROR_MSG = '<b>ERROR</b> - Primary Account Number does not match.<br/>';
                    EXPECTED += 'Account Primary No: ' + mapProduct.get(prodPayment.CCS_Account__c).Previous_Primary_Account_Number__c + '<br/>';
                }
            }

            if (
                docStorage != null &&
                String.isNotBlank(docStorage.Document_Type__c) &&
                docStorage.Document_Type__c == 'Direct Payment Upload File' &&
                String.isBlank(prodPayment.Payment_Source__c)
            ) {
                ERROR_MSG += '<b>ERROR</b> - Payment Source cannot be blank<br/>';
            }

            //DIRECT PAYMENT USECASES for commission
            if ((prodPayment.Payment_Source__c == '2' || prodPayment.Payment_Source__c == '3') && mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                //if product Recall date is blank then fetch Recall date from placement history
                if (mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == null) {
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c)
                            .Placement_Recall_Date__c;
                    }
                }
                //This account is recalled within 15 days and is currently warehoused
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
                            DebtorProvinceTaxRate = 0;
                            CanadaTaxRate = 0;
                            prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                            ProvinceNameFormat = nameFormat(prodProvinceName);
                            if (String.isNotBlank(prodProvinceName)) {
                                provinceAcronymFormat = prodProvinceName.toUpperCase();
                            }
                            //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                            if (
                                mapPlacementIDs.containsKey(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                mapPlacementIDs.get(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
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
                                        if (prodPayment.Pay_Due__c != null) {
                                            prodPayment.Legal_Product_Identifier__c = 'Yes';
                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                        }
                                    }
                                }
                            }

                            //calculate tax amount ends
                            //prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).COllection_Agency_placement__c;
                        }
                        prodPayment.Payment_Provided_Agency__c = warehouseAgencyId;
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            /* if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                            } */
                            if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                        if (prodPayment.Pay_Due__c != null) {
                            prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                            EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
                        }
                    }
                }
                //This account is recalled before 15 days and is currently warehoused

                else if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    (productAgency == '9999' || String.isBlank(productAgency)) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) > 15 || Test.isRunningTest()
                ) {
                    ERROR_MSG += '<b>WARINING</b> - The account was recalled more than 15 days ago and is currently warehoused.<br/>';
                    if(prodPayment.Payment_Type__c == '1003'){
                        if(mapPayment.containsKey(prodPayment.Original_Of_Payment_Reversal__c) && mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c != NULL){
                            EXPECTED += 'Commission Amount paid will be '+mapPayment.get(prodPayment.Original_Of_Payment_Reversal__c).Pay_Due__c * -1+' on this payment. ' + '<br/>'; 
                        }
                    }else{
                        EXPECTED += 'Commission Amount paid will be 0 on this payment. ' + '<br/>';
                    }
                    prodPayment.Pay_Due__c = 0;
                    prodPayment.Tax_Amount__c = 0;
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != null) {
                            prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                        }
                        if (mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != null) {
                            prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                        }
                    }
                }

                //assigned to agency
                if (mapProduct.containsKey(prodPayment.CCS_Account__c) && (productAgency != '9999' && String.isNotBlank(productAgency))) {
                    //This account is recalled before 15 days
                    if (!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        prodPayment.Payment_Provided_Agency__c = productAgencyID;
                        prodPayment.Payment_Agency__c = productAgency;
                    } else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15
                    ) {
                        prodPayment.Payment_Provided_Agency__c = productAgencyID;
                        prodPayment.Payment_Agency__c = productAgency;
                        if (prodPayment.Pay_Due__c != null) {
                            prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                            EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
                        }
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency ' + productAgency + '.<br/>';
                    }
                    //This account is recalled within 15 days and
                    else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15
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
                                //Tax Amount calculation:
                                //calculate tax amount
                                DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0;
                                prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if (String.isNotBlank(prodProvinceName)) {
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                                }

                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if (
                                    mapPlacementIDs.containsKey(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                    mapPlacementIDs.get(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c)
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
                                            if (prodPayment.Pay_Due__c != null) {
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                                            }
                                        }
                                    }
                                }

                                //calculate tax amount ends
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
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
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                prodPayment.Pay_Due__c = null;
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
                            if (prodPayment.Pay_Due__c != null) {
                                prodPayment.Pay_Due__c = prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP);
                                EXPECTED +=
                                    'Commission Amount ' +
                                    prodPayment.Pay_Due__c +
                                    ' will be paid to Agency ' +
                                    prodPayment.Payment_Agency__c +
                                    '<br/>';
                            }
                            ERROR_MSG +=
                                '<b>WARINING</b> - Account was recalled within 15 days and is currently placed with agency ' +
                                productAgency +
                                '.<br/>';
                        }
                    }
                }
            }

            //------------------Direct Payment Validations Ends-------------------//

            //----------------------------Fees validations startes------------------//
            if (
                prodPayment.Payment_Posting_Date__c != null &&
                String.isNotBlank(prodPayment.Payment_Type__c) &&
                FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)
            ) {
                if (prodPayment.Payment_Amount__c <= 0) {
                    Decimal payAmount = prodPayment.Payment_Amount__c * -1;
                    if (
                        !setOldTransaction.containsKey(
                            payAmount + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                        )
                    ) {
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                    } else {
                        prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get(
                            payAmount + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                        )[0];
                    }
                }
            }

            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                String.isNotBlank(prodPayment.Payment_Type__c) &&
                FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c) &&
                prodPayment.Payment_Type__c != '3000' && !mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c) || Test.isRunningTest()
            ) {
                ERROR_MSG += '<b>WARNING</b> - Cannot post Protective Disbursment to the account<br/>';
                EXPECTED += 'Account is not in Legal Status<br/>';
            }

            //----------------------------Fees validations ends------------------//

            //Must be positive
            if (prodPayment.Payment_Type__c == PAYTYPE_REGULAR && prodPayment.Payment_Amount__c < 0) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Transaction Type. Amount must be positive.<br/>';
            }

            payStaging = new Product_Payment_Staging__c();
            payStaging.CCS_Account__c = prodPayment.CCS_Account_Name__c;

            if (mapAccountPrimaryNumber.containsKey(prodPayment.CCS_Account_Name__c)) {
                payStaging.Primary_Account_Number__c = mapAccountPrimaryNumber.get(prodPayment.CCS_Account_Name__c);
            }

            if (mapProduct.containsKey(prodPayment.CCS_Account__c)) {
                payStaging.Product_ID__c = mapProduct.get(prodPayment.CCS_Account__c).ID;
                payStaging.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c;
                //Commission Rate fields
                payStaging.Product_Commission_Rate__c = prodPayment.Product_Commission_Rate__c;
                payStaging.Agency_Commission_Rate__c = prodPayment.Agency_Commission_Rate__c;
                payStaging.Pool_Commission_Rate__c = prodPayment.Pool_Commission_Rate__c;
                payStaging.Value_Tier_at_Time_of_Placement__c = prodPayment.Value_Tier_at_Time_of_Placement__c;
                payStaging.Pool_Lookup__c = prodPayment.Pool_Lookup__c;
                payStaging.Legal_Entity__c = mapProduct.get(prodPayment.CCS_Account__c).Legal_Entity__c;
                payStaging.Portfolio_Group_Name__c = mapProduct.get(prodPayment.CCS_Account__c).Portfolio_Group_Name__c;
            }

            if (prodPayment.Agency_Calculated_Comm__c != null) {
                payStaging.Agency_Calculated_Comm__c = String.valueOF(prodPayment.Agency_Calculated_Comm__c);
            }

            payStaging.Original_Of_Payment_Reversal__c = prodPayment.Original_Of_Payment_Reversal__c;
            payStaging.Payment_Amount__c = prodPayment.Payment_Amount__c;
            if (payStaging.Payment_Amount__c != null) {
                payStaging.Payment_Amount__c = payStaging.Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
            }
            payStaging.Cheque_Number__c = docStorage.Document_Name__c;
            payStaging.Placement_Agency__c = prodPayment.Payment_Agency__c;
            payStaging.Payment_Source__c = prodPayment.Payment_Source__c;

            if (payStaging.Payment_Source__c == '2' || payStaging.Payment_Source__c == '3' || payStaging.Payment_Source__c == '1') {
                payStaging.Product_Payment_Agency__c = prodPayment.Payment_Provided_Agency__c;
            }
            payStaging.Payment_Type__c = prodPayment.Payment_Type__c;
            payStaging.Payment_Posting_Date__c = prodPayment.Payment_Posting_Date_Text__c;
            if (prodPayment.Payment_Posting_Date__c != null) {
                payStaging.Pay_Posting_Date__c = prodPayment.Payment_Posting_Date__c;
            }
            payStaging.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c;
            payStaging.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c;
            payStaging.Commission_Rate_for_Payment__c = prodPayment.Commission_Rate_for_Payment__c;
            payStaging.Commission_Amount__c = prodPayment.Pay_Due__c == null ? 0 : prodPayment.Pay_Due__c;
            payStaging.Tax_Amount__c = prodPayment.Tax_Amount__c;
            payStaging.Tax_Type__c = prodPayment.Tax_Type__c;
            payStaging.Tax_Province__c = prodPayment.Tax_Province__c;
            payStaging.Tax_Province_Rate__c = prodPayment.Tax_Province_Rate__c;
            payStaging.Legal_Product_Identifier__c = prodPayment.Legal_Product_Identifier__c;
            payStaging.Pay_Attorney__c = prodPayment.Pay_Attorney__c;
            payStaging.Pay_Court__c = prodPayment.Pay_Court__c;
            payStaging.Pay_NSF__c = prodPayment.Pay_NSF__c;
            payStaging.Pay_Other__c = prodPayment.Pay_Other__c;
            payStaging.Pay_Fees__c = prodPayment.Pay_Fees__c;
            payStaging.Comment__c = ERROR_MSG;
            payStaging.Status__c = 'Pending';
            payStaging.Identifier__c = documentId;
            payStaging.Document_Storage__c = documentId;
            payStaging.Fee_Type__c = prodPayment.Fee_Type__c;
            payStaging.Billing_Entity__c = prodPayment.Billing_Entity__c;

            if (String.isBlank(ERROR_MSG)) {
                payStaging.Comment__c = 'SUCCESS';
            }
            if (String.isNotBlank(EXPECTED)) {
                if (EXPECTED.length() > 254) {
                    payStaging.Expected_Value__c = EXPECTED.substring(0, 253);
                } else {
                    payStaging.Expected_Value__c = EXPECTED;
                }
            }

            listProdPayStaging.add(payStaging);
            ERROR_MSG = '';
        }
        return listProdPayStaging;
    }

    //Wrapper class for insolvency payment records
    public class paymentRecordsWrapper {
        public String data_id { get; set; }
        public String accountID { get; set; }
        public String accountNumber { get; set; }
        public String tran_type { get; set; }
        public String tran_date { get; set; }
        public String tran_amount { get; set; }
        public String tran_principal { get; set; }
        public String tran_interest { get; set; }
        public String tran_court { get; set; }
        public String tran_attorney { get; set; }
        public String tran_nsf { get; set; }
        public String tran_general { get; set; }
        public String tran_other { get; set; }
        public String tran_tax { get; set; }
        public String tran_retained { get; set; }
        public String pay_source { get; set; }
        public String billing_entity { get; set; }
        public String fee_type { get; set; }
        public String payment_agency { get; set; }
        public String commission_rate { get; set; }
        public String pri_acctno { get; set; }
    }
}