/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : Class to create Product Payment Staging records and check ProductPayment validtaions
 *  @author : A5E Consulting
 *  @date : 15/08/2022
 /**************************************************************************************************/

public class BalanceAdjustmentExcelFileProcessing {
    //balance adjustment transaction type codes
    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_REVERSAL = '1003';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';

    public boolean RogersFile = false;

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

    list<Document_Storage__c> listDocuments;
    List<paymentRecordsWrapper> listPaymentRecordWrapper = new List<paymentRecordsWrapper>();
    public static Map<String, Placement_History__c> mapProductPreviouslyPlacedCheck;
    public map<ID, ID> mapProductJudgmentClaimIssuedID;
    @testVisible
    map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    @testVisible
    map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();
    map<ID, Decimal> mapAgencyCommissionRate = new Map<ID, Decimal>();
    set<String> setValidPaymentSource = new Set<String>{ '1', '2', '3' };
    set<String> setValidDirectPaymentType = new Set<String>{ 'Direct Payment', 'Equipment Return Payment', 'Balance adjustment due for Equipment Return' };

    public BalanceAdjustmentExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId) {
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

            mapProductJudgmentClaimIssuedID = new Map<ID, ID>();
            map<String, Decimal> mapValueTierCommissionRate = getCommissionRateValues();

            for (PaymentRecordsWrapper wrapRecord : listPaymentRecordWrapper) {
                accountNumberList.add(wrapRecord.data_id);
            }

            /*if(String.isNotBlank(workAssignmentPlacement)){
              list<Placement__c> listPlacement = [SELECT ID, Commission_rate__c FROM Placement__c WHERE Name= :workAssignmentPlacement];
                if(!listPlacement.isEmpty() && listPlacement[0].Commission_rate__c != NULL){
                    agencyCommissionrate = listPlacement[0].Commission_rate__c;
                }
            }*/

            //
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
                    Previous_Primary_Account_Number__c
                FROM Product__C
                WHERE name IN :accountNumberList
            ]) {
                mapAccountNumberID.put(product.name, product.id);
                mapProduct.put(product.id, product);
            }

            for (Account_Judgment__c accountJudgment : [
                SELECT ID, Name, Product__c, Judgment__c, Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
                FROM Account_Judgment__c
                WHERE Product__c IN :mapProduct.keySet()
            ]) {
                if (
                    accountJudgment.Judgment__r.Legal_Status__c == 'Judgment' ||
                    accountJudgment.Judgment__r.Legal_Status__c == 'Post-Judgment' ||
                    accountJudgment.Judgment__r.Legal_Status__c == 'Pre-Judgment'
                ) {
                    /*&& (accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Media Requested awaiting'
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Settlement Proposal Accepted' 
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Action Rejected'))){*/
                    mapProductJudgmentClaimIssuedID.put(accountJudgment.Product__c, accountJudgment.Judgment__c);
                }
            }

            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;

            //Tax rate mapping by Province Acronym
            for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
                mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
            }

            for (PaymentRecordsWrapper wrapRecord : listPaymentRecordWrapper) {
                Product_Payments__c prodPayment = new Product_Payments__c();
                //prodPayment.Payment_Agency__c = workAssignmentPlacement;

                if (String.isNotBlank(wrapRecord.data_id)) {
                    wrapRecord.data_id = wrapRecord.data_id.trim();
                    if (wrapRecord.data_id.contains('.')) {
                        wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                }

                prodPayment.CCS_Account__c = mapAccountNumberID.get(wrapRecord.data_id);
                prodPayment.CCS_Account_Name__c = wrapRecord.data_id;

                if (String.isNotBlank(wrapRecord.tran_amount)) {
                    wrapRecord.tran_amount = wrapRecord.tran_amount.trim();
                    Boolean negativeAmnt = false;
                    if (wrapRecord.tran_amount.contains(',')) {
                        wrapRecord.tran_amount = wrapRecord.tran_amount.remove(',');
                    }

                    if (
                        wrapRecord.tran_amount.contains('.') &&
                        (wrapRecord.tran_amount.substringAfter('.') == '0' ||
                        wrapRecord.tran_amount.substringAfter('.') == '00')
                    ) {
                        wrapRecord.tran_amount = wrapRecord.tran_amount.subStringBefore('.');
                    }
                    prodPayment.Payment_Amount__c = Decimal.valueOf(wrapRecord.tran_amount);
                }

                if (String.isNotBlank(wrapRecord.pay_principal)) {
                    wrapRecord.pay_principal = wrapRecord.pay_principal.trim();
                    Boolean negativeAmnt = false;
                    if (wrapRecord.pay_principal.contains(',')) {
                        wrapRecord.pay_principal = wrapRecord.pay_principal.remove(',');
                    }

                    if (
                        wrapRecord.pay_principal.contains('.') &&
                        (wrapRecord.pay_principal.substringAfter('.') == '0' ||
                        wrapRecord.pay_principal.substringAfter('.') == '00')
                    ) {
                        wrapRecord.pay_principal = wrapRecord.pay_principal.subStringBefore('.');
                    }
                    prodPayment.Principal_Payment_Amount__c = Decimal.valueOf(wrapRecord.pay_principal);
                }

                if (String.isNotBlank(wrapRecord.pay_interest)) {
                    wrapRecord.pay_interest = wrapRecord.pay_interest.trim();
                    Boolean negativeAmnt = false;
                    if (wrapRecord.pay_interest.contains(',')) {
                        wrapRecord.pay_interest = wrapRecord.pay_interest.remove(',');
                    }

                    if (
                        wrapRecord.pay_interest.contains('.') &&
                        (wrapRecord.pay_interest.substringAfter('.') == '0' ||
                        wrapRecord.pay_interest.substringAfter('.') == '00')
                    ) {
                        wrapRecord.pay_interest = wrapRecord.pay_interest.subStringBefore('.');
                    }
                    prodPayment.Interest_Payment_Amount__c = Decimal.valueOf(wrapRecord.pay_interest);
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
                if (String.isNotBlank(wrapRecord.pay_source)) {
                    if (wrapRecord.pay_source.contains('.')) {
                        wrapRecord.pay_source = wrapRecord.pay_source.subStringBefore('.');
                    }
                    prodPayment.Payment_Source__c = wrapRecord.pay_source;
                }
                if (String.isNotBlank(wrapRecord.agency_allocation)) {
                    wrapRecord.agency_allocation = wrapRecord.agency_allocation.trim();
                    prodPayment.Payment_Agency__c = wrapRecord.agency_allocation.subStringBefore('.');
                }

                if (String.isNotBlank(wrapRecord.commission_rate_override)) {
                    wrapRecord.commission_rate_override = wrapRecord.commission_rate_override.trim();
                    prodPayment.Commission_Rate_for_Payment__c = Decimal.valueOf(wrapRecord.commission_rate_override);
                }

                if (String.isNotBlank(wrapRecord.direct_payment_type)) {
                    wrapRecord.direct_payment_type = wrapRecord.direct_payment_type.trim();
                    prodPayment.Direct_Payment_Type__c = wrapRecord.direct_payment_type.subStringBefore('.');
                    RogersFile = true;
                }

                //prodPayment.Payment_Agency__c = workAssignmentPlacement;

                listProductsToInsert.add(prodPayment);
            }
            list<Product_Payment_Staging__c> listpayStaging = validationOnRecordUpdate(
                listProductsToInsert,
                mapProduct,
                listDocuments[0],
                mapAccountPrimaryNumber
            );
            Database.SaveResult[] sr = database.insert(listpayStaging);
        } catch (Exception ex) {
            exceptionMessage = String.valueOf(ex.getStackTraceString());
            system.debug('exceptionMessage::' + exceptionMessage);
            system.debug('exceptionMessage full::' + ex.getMessage());
        }

        String processingLink = '';
        Boolean stagingCreated = false;
        String processingStatus = '';

        if (String.isBlank(exceptionMessage)) {
            processingLink = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/DisplayBalanceAdjustmentStaging?id=' + documentId;

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
            Balance_Adjustment__c = true,
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

    //Validation method to be called  before update
    public list<Product_Payment_Staging__c> validationOnRecordUpdate(
        List<Product_Payments__c> prodPayNew,
        map<Id, Product__c> mapProduct,
        Document_Storage__c docStorage,
        map<String, String> mapAccountPrimaryNumber
    ) {
        map<String, ID> setOldTransaction = new Map<String, ID>();
        map<String, Decimal> mapOldTransactionCount = new Map<String, Decimal>();

        set<ID> alreadyReversedPayments = new Set<ID>();
        list<Product_Payment_Staging__c> listProdPayStaging = new List<Product_Payment_Staging__c>();
        Product_Payment_Staging__c payStaging = new Product_Payment_Staging__c();

        map<String, Placement__C> mapPlacementNames = new Map<String, Placement__C>();
        for (Placement__C place : [SELECT Name, ID, Commission_rate__c FROM Placement__c]) {
            mapPlacementNames.put(place.Name, place);
        }
        for (Product_Payments__c oldPay : [
            SELECT ID, CCS_Account__r.Name, Payment_Type__c, Payment_Amount__c, Payment_Posting_Date__c, Payment_Posting_Date_Text__c
            FROM Product_Payments__c
            WHERE CCS_Account__c IN :mapProduct.keySet()
        ]) {
            String payAmount = '';
            if (oldPay.Payment_Amount__c != null) {
                oldPay.Payment_Amount__c = oldPay.Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
                payAmount = String.valueOf(oldPay.Payment_Amount__c);
            }

            setOldTransaction.put(payAmount + '' + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c + oldPay.CCS_Account__c, oldPay.ID);
        }

        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        list<String> validPaymentTypes = new List<String>();

        map<Id, Decimal> mapProductPaymentAmount = new Map<ID, Decimal>();
        //set hacing product name and payment amount
        map<String, Decimal> mapProductNameAmount = new Map<String, Decimal>();

        validPaymentTypes = portalSettings.Valid_Payment_Types__c.split(',');
        set<Id> setProductNames = new Set<Id>();

        for (Product_Payments__c prodPayment : prodPayNew) {
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
        }

        //direct payment history
        map<ID, Placement_History__c> mapProductPreviouslyPlaced = getDirectPlacementHistoryDetails(setProductNames);
        String prodPayStatus = '';
        String productAgency = '';
        String ERROR_MSG = '';
        String EXPECTED = '';
        ID productAgencyID = null;
        for (Product_Payments__c prodPayment : prodPayNew) {
            ERROR_MSG = '';
            EXPECTED = '';

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

            if (
                setOldTransaction.containsKey(
                    prodPayment.Payment_Amount__c + '' + prodPayment.Payment_Type__c + prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c
                )
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

            if (prodPayment.Payment_Agency__c != null && !mapPlacementNames.containsKey(prodPayment.Payment_Agency__c)) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Agency Allocation.\n';
                //EXPECTED += 'Payment Date cannot be in future.<br/>';
            }

            if (String.isBlank(prodPayment.Payment_Type__c)) {
                ERROR_MSG += '<b>ERROR</b> - Payment Type cannot Blank.<br/>';
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

            if (RogersFile == false && prodPayment.Payment_Type__c != '3000') {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type.<br/>';
            }

            //Transaction type is incorrect
            if (
                RogersFile == true &&
                String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                prodPayment.Direct_Payment_Type__c == 'Direct Payment' &&
                prodPayment.Payment_Type__c != '1000'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type.<br/>';
            }

            //Transaction type is incorrect
            if (
                RogersFile == true &&
                String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                prodPayment.Direct_Payment_Type__c == 'Balance adjustment due for Equipment Return' &&
                prodPayment.Payment_Type__c != '8000'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type for Balance adjustment due for Equipment Return.<br/>';
            }

            //Transaction type is incorrect
            if (
                RogersFile == true &&
                String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                prodPayment.Direct_Payment_Type__c == 'Equipment Return Payment' &&
                prodPayment.Payment_Type__c != '1000'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type for Equipment Return Payment.<br/>';
            }

            if (RogersFile == true && String.isBlank(prodPayment.Direct_Payment_Type__c)) {
                ERROR_MSG += '<b>ERROR</b> - Direct Payment Type cannot be blank<br/>';
            }

            if (
                RogersFile == true &&
                String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                !setValidDirectPaymentType.contains(prodPayment.Direct_Payment_Type__c)
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Direct Payment Type<br/>';
            }

            if (RogersFile == true && String.isNotBlank(prodPayment.Direct_Payment_Type__c) && prodPayment.Direct_Payment_Type__c != 'Direct Payment') {
                ERROR_MSG += '<b>WARNING</b> - Commission Paid will be 0<br/>';
            }

            //Must be positive
            /*if(prodPayment.Payment_Type__c == PAYTYPE_REGULAR && prodPayment.Payment_Amount__c < 0 ){
                ERROR_MSG += '<b>ERROR</b> - Negative amount received with incorrect type (1000).<br/>';
            }*/

            if (prodPayment.Payment_Amount__c == null) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Amount<br/>';
            } else if (
                //cannot be negative
                /*if(prodPayment.Payment_Amount__c < 0 ){
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Amount.<br/>';
            }*/
                prodPayment.Principal_Payment_Amount__c == null &&
                prodPayment.Interest_Payment_Amount__c == null
            ) {
                ERROR_MSG += '<b>ERROR</b> - Pay Principal and Pay Interest both cannot be blank.<br/>';
            }

            if (prodPayment.Principal_Payment_Amount__c != null) {
                prodPayment.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
            }
            if (prodPayment.Interest_Payment_Amount__c != null) {
                prodPayment.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
            }
            if (prodPayment.Payment_Amount__c != null) {
                prodPayment.Payment_Amount__c = prodPayment.Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
            }
            if (prodPayment.Principal_Payment_Amount__c != null && prodPayment.Interest_Payment_Amount__c != null && prodPayment.Payment_Amount__c != null) {
                if ((prodPayment.Principal_Payment_Amount__c + prodPayment.Interest_Payment_Amount__c) != prodPayment.Payment_Amount__c) {
                    ERROR_MSG += '<b>ERROR</b> - Total of Pay Principal and Pay Interest does not match Transaction Amount.<br/>';
                }
            }
            if (prodPayment.Payment_Amount__c != null && prodPayment.Principal_Payment_Amount__c != null && prodPayment.Interest_Payment_Amount__c == null) {
                if ((prodPayment.Principal_Payment_Amount__c) != prodPayment.Payment_Amount__c) {
                    ERROR_MSG += '<b>ERROR</b> - Total of Pay Principal and Pay Interest does not match Transaction Amount.<br/>';
                }
            }

            if (prodPayment.Payment_Amount__c != null && prodPayment.Principal_Payment_Amount__c == null && prodPayment.Interest_Payment_Amount__c != null) {
                if ((prodPayment.Interest_Payment_Amount__c) != prodPayment.Payment_Amount__c) {
                    ERROR_MSG += '<b>ERROR</b> - Total of Pay Principal and Pay Interest does not match Transaction Amount.<br/>';
                }
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

                //Check if payment amount matches tolerance amount percents on Placement
                if (prodPayment.Payment_Amount__c <> toleranceAmount) {
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
            // PAYTYPE_SETTLED_IN_FULL
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
                outStandingBalance = (prodPayment.Payment_Amount__c / mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c) * 100;

                /*outStandingBalance = (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c *
                 5 /100);*/

                outStandingBalance = outStandingBalance.setScale(2, RoundingMode.HALF_UP);

                //Check if payment amount matches outStandingBalance amount percents on Placement
                if (outStandingBalance < 95) {
                    ERROR_MSG += '<b>WARNING</b> - Transaction amount is not within 5% of the total oustanding balance' + '<br/>';
                    EXPECTED +=
                        'Total Balance on Product= ' +
                        mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c.setScale(2, RoundingMode.HALF_UP) +
                        '<br/>';
                }
            }
            if (docStorage != null && String.isBlank(prodPayment.Payment_Source__c)) {
                ERROR_MSG += '<b>ERROR</b> - Payment Source cannot be blank<br/>';
            }

            if (docStorage != null && String.isNotBlank(prodPayment.Payment_Source__c) && !setValidPaymentSource.contains(prodPayment.Payment_Source__c)) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Source<br/>';
            }

            Decimal CommissionRate;
            if (prodPayment.Payment_Agency__c == null) {
                prodPayment.Payment_Provided_Agency__c = productAgencyID;
                prodPayment.Payment_Agency__c = productAgency;
            }

            //By product Commission Rate
            if (mapProduct.containsKey(prodPayment.CCS_Account__c) && mapProduct.get(prodPayment.CCS_Account__c).Commission_Rate__c != null) {
                prodPayment.Product_Commission_Rate__c = mapProduct.get(prodPayment.CCS_Account__c).Commission_Rate__c;
            }
            //By Agency Commission Rate
            if (
                String.isNotBlank(prodPayment.Payment_Agency__c) &&
                mapPlacementNames.containsKey(prodPayment.Payment_Agency__c) &&
                mapPlacementNames.get(prodPayment.Payment_Agency__c).Commission_Rate__c != null
            ) {
                prodPayment.Agency_Commission_Rate__c = mapPlacementNames.get(prodPayment.Payment_Agency__c).Commission_Rate__c;
            }

            //By pool Commission Rate
            if (
                mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__c != null &&
                mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c != null
            ) {
                prodPayment.Pool_Commission_Rate__c = mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c;
            }

            if (
                docStorage.Document_Type__c == 'Balance Adjustment Upload File' &&
                String.isNotBlank(prodPayment.Payment_Source__c) &&
                prodPayment.Payment_Source__c != '3' &&
                prodPayment.Payment_Source__c != '2'
            ) {
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Source for Balance Adjustment Upload File<br/>';
                EXPECTED += 'Payment Source Should be 2 OR 3.<br/>';
            }

            //DIRECT PAYMENT USECASES for commission
            if (
                prodPayment.Commission_Rate_for_Payment__c != null &&
                prodPayment.Payment_Amount__c != null &&
                mapProduct.containsKey(prodPayment.CCS_Account__c)
            ) {
                if (prodPayment.Commission_Rate_for_Payment__c == 0) {
                    prodPayment.Commission_Amount__c = 0;
                    prodPayment.Tax_Amount__c = 0;
                } else {
                    if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                        CommissionRate = prodPayment.Commission_Rate_for_Payment__c + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                    }
                    prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * prodPayment.Commission_Rate_for_Payment__c) / 100;
                }
            } else if (
                prodPayment.Commission_Rate_for_Payment__c == null &&
                prodPayment.Payment_Amount__c != null &&
                mapProduct.containsKey(prodPayment.CCS_Account__c)
            ) {
                if (prodPayment.Product_Commission_Rate__c != null) {
                    CommissionRate = prodPayment.Product_Commission_Rate__c;
                } else if (prodPayment.Agency_Commission_Rate__c != null) {
                    CommissionRate = prodPayment.Agency_Commission_Rate__c;
                } else if (prodPayment.Pool_Commission_Rate__c != null) {
                    CommissionRate = prodPayment.Pool_Commission_Rate__c;
                }
                //if commission adjustment is added to product, adjust Commission Rate
                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                }
                if (CommissionRate != null) {
                    prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                }
                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
            }
            if (prodPayment.Payment_Source__c == '2' || prodPayment.Payment_Source__c == '3' && prodPayment.Payment_Amount__c != null) {
                //This account is recalled within 15 days and is currently warehoused
                if (
                    mapProduct.containsKey(prodPayment.CCS_Account__c) &&
                    (productAgency == '9999' || String.isBlank(productAgency)) &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != null &&
                    mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(Date.today()) <= 15
                ) {
                    if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                        //CommissionRate = prodPayment.Commission_Rate_for_Payment__c;
                        if (CommissionRate == null) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                        }
                        if (CommissionRate == null) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                        }
                        if (CommissionRate == null) {
                            CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                        }
                        if (CommissionRate != null) {
                            //if commission adjustment is added to product, adjust Commission Rate
                            if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                            }
                            prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                            prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                            //prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).COllection_Agency_placement__c;
                        }
                        if (prodPayment.Payment_Agency__c == null) {
                            prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                            prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                        }
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                        if (
                            !(RogersFile == true &&
                            String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                            prodPayment.Direct_Payment_Type__c != 'Direct Payment')
                        ) {
                            EXPECTED += 'Commission Amount ' + prodPayment.Pay_Due__c + ' will be paid to Agency ' + prodPayment.Payment_Agency__c + '<br/>';
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
                    //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                    EXPECTED += 'Commission Amount paid will be 0 on this payment. ' + '<br/>';
                    prodPayment.Pay_Due__c = 0;
                    if (prodPayment.Payment_Agency__c == null) {
                        prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                        prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                    }
                    //prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).COllection_Agency_placement__c;
                }

                //assigned to agency
                if (mapProduct.containsKey(prodPayment.CCS_Account__c) && (productAgency != '9999' && String.isNotBlank(productAgency))) {
                    //&& mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 15){
                    //This account is recalled before 15 days
                    if (!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) && prodPayment.Payment_Agency__c == null) {
                        prodPayment.Payment_Provided_Agency__c = productAgencyID;
                        prodPayment.Payment_Agency__c = productAgency;
                    } else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15
                    ) {
                        if (prodPayment.Payment_Agency__c == null) {
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                        }
                        //prodPayment.Product_Agency__c = productAgencyID;
                        if (
                            !(RogersFile == true &&
                            String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                            prodPayment.Direct_Payment_Type__c != 'Direct Payment')
                        ) {
                            EXPECTED +=
                                'Commission Amount ' +
                                prodPayment.Pay_Due__c.setScale(2, RoundingMode.HALF_UP) +
                                ' will be paid to Agency ' +
                                prodPayment.Payment_Agency__c +
                                '<br/>';
                        }
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency ' + productAgency + '.<br/>';
                    }
                    //This account is recalled within 15 days and
                    else if (
                        mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) &&
                        mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15
                    ) {
                        if (mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            //CommissionRate = prodPayment.Commission_Rate_for_Payment__c;
                            // Use commission rate from excel file if provided
                            if (prodPayment.Commission_Rate_for_Payment__c != null) {
                                CommissionRate = prodPayment.Commission_Rate_for_Payment__c;
                            }
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                            }
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                            }
                            if (CommissionRate == null) {
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                            }
                            if (CommissionRate != null) {
                                //if commission adjustment is added to product, adjust Commission Rate
                                if (mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != null) {
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                prodPayment.Pay_Due__c = (prodPayment.Payment_Amount__c * CommissionRate) / 100;
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                if (prodPayment.Payment_Agency__c == null) {
                                    prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c;
                                    prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                }
                            }
                            if (
                                !(RogersFile == true &&
                                String.isNotBlank(prodPayment.Direct_Payment_Type__c) &&
                                prodPayment.Direct_Payment_Type__c != 'Direct Payment')
                            ) {
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

            if (prodPayment.Pay_Due__c != null && prodPayment.Pay_Due__c != 0) {
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
                if (!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)) {
                    if (ontarioTaxRate != null) {
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

                        prodPayment.Legal_Product_Identifier__c = 'Yes';
                        prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c * (DebtorProvinceTaxRate + CanadaTaxRate)) / 100;
                    }
                }
                //calculate tax amount ends
            }

            //------------------Direct Payment Validations Ends-------------------//

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
                payStaging.Pool_Lookup__c = mapProduct.get(prodPayment.CCS_Account__c).Pool_Name__c;
            }
            if (prodPayment.Agency_Calculated_Comm__c != null) {
                payStaging.Agency_Calculated_Comm__c = String.valueOF(prodPayment.Agency_Calculated_Comm__c);
            }
            payStaging.Direct_Payment_Type__c = prodPayment.Direct_Payment_Type__c;
            payStaging.Original_Of_Payment_Reversal__c = prodPayment.Original_Of_Payment_Reversal__c;
            payStaging.Payment_Amount__c = prodPayment.Payment_Amount__c;
            payStaging.Cheque_Number__c = docStorage.Document_Name__c;
            payStaging.Placement_Agency__c = prodPayment.Payment_Agency__c;
            if (mapPlacementNames.containsKey(payStaging.Placement_Agency__c)) {
                payStaging.Product_Payment_Agency__c = mapPlacementNames.get(payStaging.Placement_Agency__c).ID;
            }
            payStaging.Payment_Source__c = prodPayment.Payment_Source__c;
            payStaging.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c;
            payStaging.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c;
            //payStaging.Product_Payment_Agency__c = prodPayment.Payment_Provided_Agency__c;
            payStaging.Payment_Type__c = prodPayment.Payment_Type__c;
            payStaging.Payment_Posting_Date__c = prodPayment.Payment_Posting_Date_Text__c;
            if (prodPayment.Payment_Posting_Date__c != null) {
                payStaging.Pay_Posting_Date__c = prodPayment.Payment_Posting_Date__c;
            }
            payStaging.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c;
            payStaging.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c;
            payStaging.Commission_Rate_for_Payment__c = prodPayment.Commission_Rate_for_Payment__c;
            payStaging.Commission_Amount__c = prodPayment.Pay_Due__c;
            payStaging.Tax_Amount__c = prodPayment.Tax_Amount__c;
            payStaging.Tax_Type__c = prodPayment.Tax_Type__c;
            payStaging.Tax_Province__c = prodPayment.Tax_Province__c;
            payStaging.Tax_Province_Rate__c = prodPayment.Tax_Province_Rate__c;
            payStaging.Legal_Product_Identifier__c = prodPayment.Legal_Product_Identifier__c;
            payStaging.Comment__c = ERROR_MSG;
            payStaging.Status__c = 'Pending';
            payStaging.Identifier__c = documentId;
            payStaging.Document_Storage__c = documentId;
            payStaging.Fee_Type__c = prodPayment.Fee_Type__c;
            payStaging.Billing_Entity__c = prodPayment.Billing_Entity__c;
            paySTaging.Direct_Payment_Type__c = prodPayment.Direct_Payment_Type__c;

            if (String.isBlank(ERROR_MSG)) {
                payStaging.Comment__c = 'SUCCESS';
            }
            if (String.isNotBlank(EXPECTED)) {
                payStaging.Expected_Value__c = EXPECTED;
            }

            listProdPayStaging.add(payStaging);
            ERROR_MSG = '';
        }
        return listProdPayStaging;
    }

    //Wrapper class for insolvency payment records
    public class paymentRecordsWrapper {
        public String data_id { get; set; }
        //public String netPayment{get;set;}
        public String tran_type { get; set; }
        public String tran_date { get; set; }
        public String tran_amount { get; set; }
        public String pay_principal { get; set; }
        public String pay_interest { get; set; }
        public String agency_allocation { get; set; }
        public String commission_rate_override { get; set; }
        public String pay_source { get; set; }
        public String direct_payment_type { get; set; }
    }
}
