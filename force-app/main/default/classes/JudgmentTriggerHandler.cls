/**************************************************************************************************
 *
 *  Trigger:
 *
 *  @description : This is a Trigger Handler Class for Judgment object
 *  @author : A5E Consulting
 *  @date : 21/08/2019
 *
 *************************************************************************************************/

 public class JudgmentTriggerHandler {
    public static Map<String, Id> collectionAgency = new Map<String, Id>();
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();
    public static map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new Map<String, Judgment_product_codes_mapping__c>();
    public static boolean runJudgmentTrigger = true;
    public static boolean runJudgmentValidation = true;
    //Bug: 5564 Changes Starts
    public static string SEPARATOR = 'A';
    public static string UNPLACED = 'unplaced';
    public static Agency_Portal_Settings__c configSetting = Agency_Portal_Settings__c.getOrgDefaults();
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults(); 
    //Bug: 5564 Changes Ends
    static {
        for (Placement__c place : [SELECT id, Name, Agency_Name__c FROM Placement__c]) {
            collectionAgency.put(place.Name, place.Id);
            //system.debug('Collection ' +collectionAgency);
        }
        //Tax rate mapping by Province Acronym
        for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
        
        for (Judgment_product_codes_mapping__c mapping : [
            SELECT Id, Name, Codes__c, Product_Status__c, Product_Sub_status__c, Judgment_Legal_Status__c, Judgment_Legal_Sub_Status__c
            FROM Judgment_product_codes_mapping__c
        ]) {
            mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c + mapping.Judgment_Legal_Sub_Status__c, mapping);
        }
    }

    public static void handleBeforeInsert(list<Judgment__c> listNewJudgments) {
        list<Judgment__c> listInternalNewJudgment = new List<Judgment__c>();
        list<String> listJudgmentStatuses = new List<String>();

        for (Judgment__c judgRecord : listNewJudgments) {
            listJudgmentStatuses.add(judgRecord.Legal_Status__c);
            if (judgRecord.Court__c == 'Small Claims Court' && judgRecord.Small_Claims_Court__c == null && runJudgmentValidation == true) {
                judgRecord.Small_Claims_Court__c.addError('Small Claims Court can not be blank');
            }
            if (judgRecord.Court__c == 'Superior Court of Justice' && judgRecord.Superior_Court__c == null && runJudgmentValidation == true) {
                judgRecord.Superior_Court__c.addError('Superior Court of Justice can not be blank');
            }

            judgRecord.Created_By__c = UserInfo.getName();

            if (judgRecord.Agency_Initiated_Legal_Action_Lookup__c <> null) {
                listInternalNewJudgment.add(judgRecord);
            }
            if (judgRecord.Superior_Court__c <> null) {
                listInternalNewJudgment.add(judgRecord);
            }
            if (judgRecord.Small_Claims_Court__c <> null) {
                listInternalNewJudgment.add(judgRecord);
            }
            if (judgRecord.Enforcement_County__c <> null) {
                listInternalNewJudgment.add(judgRecord);
            }
            if (judgRecord.County__c <> null) {
                listInternalNewJudgment.add(judgRecord);
            }
            
            if(judgRecord.Judgment_Date__c > Date.today()){
                judgRecord.addError('Judgment Date cannot be in future.');
            }
        }

        //method calls once record created in CFG
        getJudgmentRelatedData(listInternalNewJudgment);

        //update product Placement statuses
        updateProductStatusesOnJudgment(listNewJudgments, listJudgmentStatuses);

        //get Judgment Balance According to Product
        getJudgmentBalance(listNewJudgments);

        //Added below line part od Bug-5564
      	if (!test.isRunningTest())
            updateAgencyOnJudgment(listNewJudgments);
    }
    //Bug: 5564 - Updated the below method to remove reference of AccountJudgment records
    public static void updateAgencyOnJudgment(list<Judgment__c> listNewJudgments) {
        List<ID> JudId = new List<ID>();
        //recalculate the Collection agency identifer for all related judgmets
        Map<ID, String> judgmentUpdate = new Map<Id, String>();
        Map<ID, String> judgmentExternalIdentifierUpdate = new Map<Id, String>();
        String collectionAgencyidentifier = '';
        String externalCollectionAgency = '';
        list<string> prodNames = new List<string>();
        for (Judgment__c judgment : listNewJudgments) {
            JudId.add(judgment.id);
            if (judgment.Product_1__c != null) {
                prodNames.add(judgment.Product_1__c);
            } else if (judgment.Product_2__c != null) {
                prodNames.add(judgment.Product_2__c);
            } else if (judgment.Product_3__c != null) {
                prodNames.add(judgment.Product_3__c);
            } else if (judgment.Product_4__c != null) {
                prodNames.add(judgment.Product_4__c);
            } else if (judgment.Product_5__c != null) {
                prodNames.add(judgment.Product_5__c);
            }
            if (prodNames.size() == 0 && runJudgmentValidation == true) {
                judgment.addError('There should be atleast one product on Judgment');
                return;
            }
        }
        Product__c prod = [
            SELECT ID, Name, Collection_Agency__c, Collection_Agency_Placement__c, State__c, Status__c, Sub_Status__c, Account_Purchasing_Entity_Value__c
            FROM Product__c
            WHERE Name IN :prodNames
            LIMIT 1
        ];

        JudgmentTriggerHandler.runJudgmentTrigger = false;
        //Populate Agency from Product to Judgment.
        for (Judgment__c judgment : listNewJudgments) {
            if (prod.Collection_Agency__c != null) {
                judgment.Agency_Initiated_Legal_Action__c = String.valueOf(Math.floor(prod.Collection_Agency__c));
                judgment.Legal_Agency__c = judgment.Agency_Initiated_Legal_Action__c;
            }
            if (String.isNotBlank(judgment.Agency_Initiated_Legal_Action__c)) {
                judgment.Agency_Initiated_Legal_Action_Lookup__c = collectionAgency.get(judgment.Agency_Initiated_Legal_Action__c);
            } else {
                judgment.Agency_Initiated_Legal_Action_Lookup__c = null;
            }
            if (String.isNotBlank(String.ValueOf(judgment.Legal_Agency__c))) {
                judgment.Legal_Agency_Placement__c = collectionAgency.get(String.ValueOf(judgment.Legal_Agency__c));
            } else {
                judgment.Legal_Agency_Placement__c = null;
            }

            if (null == prod.Collection_Agency__C) {
                collectionAgencyidentifier = SEPARATOR + UNPLACED + SEPARATOR;
            } else {
                collectionAgencyidentifier = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                //populate External Collection Agency identifier
                if (prod.Collection_Agency__C != 6 && prod.Collection_Agency__C != 68) {
                    externalCollectionAgency = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                }
            }
            judgment.Collection_Agency_Identifier__c = collectionAgencyidentifier;
            judgment.External_Collection_Agency_Identifier__c = externalCollectionAgency;
        }
        JudgmentTriggerHandler.runJudgmentTrigger = true;
    }

    //method to update Placement Main Status and Sub STatus on Product based on Legal statuses
    public static void updateProductStatusesOnJudgment(list<Judgment__c> listNewJudgments, list<String> listLegalStatuses) {
        list<Product__c> listProduct = new List<Product__c>();
        Map<Id, Product__c> productMap = new Map<Id, Product__c>();
        Map<String, List<String>> judgmentIdProductListMap = new Map<String, List<String>>();
        list<Account_Judgment__c> listActiveJudgments = new List<Account_Judgment__c>();
        //map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new Map<String, Judgment_product_codes_mapping__c>();
        map<ID, ID> mapActiveAccountJudgments = new Map<ID, ID>();
        Map<String, Judgment__c> mapJudgmentIdJudgment = new Map<String, Judgment__c>();
        Set<ID> mapProdId = new Set<ID>();
        Map<String, Product__c> mapProd = new Map<String, Product__c>();
        map<String, ID> mapProductName = new Map<String, ID>();
        List<String> judgmentProductNames = new List<String>();

        /*for (Judgment_product_codes_mapping__c mapping : [
            SELECT Id, Name, Codes__c, Product_Status__c, Product_Sub_status__c, Judgment_Legal_Status__c, Judgment_Legal_Sub_Status__c
            FROM Judgment_product_codes_mapping__c
            WHERE Product_Parent__c IN :listLegalStatuses
        ]) {
            mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c + mapping.Judgment_Legal_Sub_Status__c, mapping);
        }*/

        for (Judgment__c judgment : listNewJudgments) {
            mapJudgmentIdJudgment.put(judgment.Id, judgment);
            // Check for Product field values on judgment
            for (Integer i = 1; i < 6; i++) {
                String productName = judgment.get('Product_' + i + '__c') != null ? String.valueOf(judgment.get('Product_' + i + '__c')) : null;
                // Get out of loop when any product field is null as product fields after this will also be null
                if (String.isBlank(productName)) {
                    break;
                }
                // Map judgment to list of product names linked to it
                if (String.isNotBlank(productName)) {
                    if (judgmentIdProductListMap.containsKey(judgment.Id)) {
                        judgmentIdProductListMap.get(judgment.Id).add(productName);
                    } else {
                        judgmentIdProductListMap.put(judgment.Id, new List<String>{ productName });
                    }
                    judgmentProductNames.add(productName);
                }
            }
        }

        for (Product__c prod : [
            SELECT Id, Name, Collection_Agency__c, Collection_Agency_Placement__c, State__c, Status__c, Sub_Status__c, Account_Purchasing_Entity_Value__c,
            Refer_to_Legal__c,Legal_Decision_Date__c ,Legal_Decision_by__c 
            FROM Product__c
            WHERE Name IN :judgmentProductNames
        ]) {
            mapProd.put(prod.Name, prod);
        }
        map<string,string> acctStatusOfProduct = new map<string,string>();
		for (Account_Judgment__c accJud : [ SELECT product__c,product__r.name,judgment__c,status__c from Account_Judgment__c
            WHERE judgment__c IN :mapJudgmentIdJudgment.keySet()
        ]){
            if(mapProd.containsKey(accJud.product__r.name)){
                acctStatusOfProduct.put(accJud.product__r.name,accJud.Status__c);
            }
        }
        
        // Loop on list of judgments
        for (String judgmentId : judgmentIdProductListMap.keySet()) {
            // Get the current judgment record in iteration
            Judgment__c currentJudgment = mapJudgmentIdJudgment.get(judgmentId);
            // Loop on products associated to current judgment
            for (String productId : judgmentIdProductListMap.get(judgmentId)) {
                // Get current product in iteration using the product name
                Product__c judgmentProduct = mapProd.get(productId);
                //Ticket 6993 - Update active judgment statues on product
                if(!Test.isRunningTest() && 
                   acctStatusOfProduct.get(judgmentProduct.name) != NULL &&
                   acctStatusOfProduct.containskey(judgmentProduct.name) && 
                   acctStatusOfProduct.get(judgmentProduct.name) == 'Active' ){
                    if (mapAccountJudgmentCodes.containsKey(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)) {
                        judgmentProduct.Status__c = mapAccountJudgmentCodes.get(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)
                            .Product_Status__c;
                    }
                    if (mapAccountJudgmentCodes.containsKey(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)) {
                        judgmentProduct.Sub_Status__c = mapAccountJudgmentCodes.get(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)
                            .Product_Sub_status__c;
                    }
                    if (mapAccountJudgmentCodes.containsKey(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)) {
                        judgmentProduct.Placement_Status__c = mapAccountJudgmentCodes.get(currentJudgment.Legal_Status__c + currentJudgment.Legal_Sub_Status__c)
                            .Codes__c;
                    }
                }
                //Ticket 7373 : if product in refer to legal state and we add existing judgment then refer to legal 
                //automatically get updated to Approved.
                if(!Test.isRunningTest() && judgmentProduct.Refer_to_Legal__c != '' && judgmentProduct.Refer_to_Legal__c != NULL &&
                    judgmentProduct.Refer_to_Legal__c != 'Declined' && judgmentProduct.Refer_to_Legal__c == 'For Review'){
                    judgmentProduct.Refer_to_Legal__c = 'Approved';
                    judgmentProduct.Legal_Decision_Date__c = System.now();
                    judgmentProduct.Legal_Decision_by__c = UserInfo.getUserId();
                }
                if (judgmentProduct != null) {
                    productMap.put(judgmentProduct.Id, judgmentProduct);
                }
            }
        }

        ProductTriggerHandler.runProductTrigger = false;
        update productMap.values();
        ProductTriggerHandler.runProductTrigger = true;
        //validation for Judgment Statuses
        validationRulesProductToJudgment(listNewJudgments, listLegalStatuses);
    }

    public static void handleBeforeUpdate(list<Judgment__c> listNewJudgments, map<Id, Judgment__c> mapOldJudgment) {
        list<Judgment__c> listInternalNewJudgment = new List<Judgment__c>();
        list<Judgment__c> listExternalNewJudgment = new List<Judgment__c>();
        Agency_Portal_Settings__c postJudgRcodtypId = Agency_Portal_Settings__c.getOrgDefaults();
        list<String> listJudgmentStatuses = new List<String>();

        for (Judgment__c judgmentObj : listNewJudgments) {
            listJudgmentStatuses.add(judgmentObj.Legal_Status__c);

            if (judgmentObj.Court__c == 'Small Claims Court' && judgmentObj.Small_Claims_Court__c == null && runJudgmentValidation == true) {
                judgmentObj.Small_Claims_Court__c.addError('Small Claims Court can not be blank');
            }
            if (judgmentObj.Court__c == 'Superior Court of Justice' && judgmentObj.Superior_Court__c == null && runJudgmentValidation == true) {
                judgmentObj.Superior_Court__c.addError('Superior Court of Justice can not be blank');
            }

            //set Run Identifier Check on Judgment if collection identifier is changed
            judgmentObj.Last_Modified_By__c = UserInfo.getName();
            Boolean identifierRemovalFlag = false;
            Judgment__c JudgmentOld = mapOldJudgment.get(judgmentObj.id);

            if (judgmentObj.Superior_Court__c != null) {
                if (judgmentObj.Superior_Court__c != JudgmentOld.Superior_Court__c) {
                    listInternalNewJudgment.add(judgmentObj);
                }
            } else {
                judgmentObj.Superior_Court_Identifier__c = null;
            }

            if (judgmentObj.Small_Claims_Court__c != null) {
                if (judgmentObj.Small_Claims_Court__c != JudgmentOld.Small_Claims_Court__c) {
                    listInternalNewJudgment.add(judgmentObj);
                }
            } else {
                judgmentObj.Small_Claims_Court_Identifier__c = null;
            }

            if (judgmentObj.Enforcement_County__c != null) {
                if (judgmentObj.Enforcement_County__c != JudgmentOld.Enforcement_County__c) {
                    listInternalNewJudgment.add(judgmentObj);
                }
            } else {
                judgmentObj.Enforcement_County_Identifier__c = null;
            }

            if (judgmentObj.County__c != null) {
                if (judgmentObj.County__c != JudgmentOld.County__c) {
                    listInternalNewJudgment.add(judgmentObj);
                }
            } else {
                judgmentObj.County_Identifier__c = null;
            }

            if (
                String.isNotBlank(judgmentObj.Collection_Agency_Identifier__c) &&
                judgmentObj.Collection_Agency_Identifier__c != mapOldJudgment.get(judgmentObj.Id).Collection_Agency_Identifier__c
            ) {
                judgmentObj.Run_Identifier_Check_On__c = Date.today();
            }
            //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
            if (String.isNotBlank(String.ValueOf(judgmentObj.Legal_Agency__c))) {
                judgmentObj.Legal_Agency_Placement__c = collectionAgency.get(String.ValueOf(judgmentObj.Legal_Agency__c));
            } else {
                judgmentObj.Legal_Agency_Placement__c = null;
            }

            //Converted 'Post-Judgment-Vacated' workflow rule into code.
            if (judgmentObj.Legal_Status__c == 'Post-Judgment' && judgmentObj.Legal_Sub_Status__c == 'Vacated') {
                judgmentObj.RecordTypeId = postJudgRcodtypId.Post_Judgment_RecordTypeId__c;
            }
            
            if(judgmentObj.Judgment_Date__c > Date.today()){
                judgmentObj.addError('Judgment Date cannot be in future.');
            } 
        }

        //method calls once record created/update in CFG
        getJudgmentRelatedData(listInternalNewJudgment);
        updateProductStatusesOnJudgment(listNewJudgments, listJudgmentStatuses);

        //get Judgment Balance According to Product
        getJudgmentBalance(listNewJudgments);
    }

    public static void getJudgmentBalance(list<Judgment__c> listNewJudgments) {
        Decimal Total = 0;
        for (Judgment__c judgmentObj : listNewJudgments) {
            if (judgmentObj.Balance_one__c <> null) {
                Total += judgmentObj.Balance_one__c;
            }
            if (judgmentObj.Balance_two__c <> null) {
                Total += judgmentObj.Balance_two__c;
            }
            if (judgmentObj.Balance_three__c <> null) {
                Total += judgmentObj.Balance_three__c;
            }
            if (judgmentObj.Balance_four__c <> null) {
                Total += judgmentObj.Balance_four__c;
            }
            if (judgmentObj.Balance_five__c <> null) {
                Total += judgmentObj.Balance_five__c;
            }
            judgmentObj.Judgment_Balance__c = Total;
        }
    }

    public static void setAccountJudgmentInactive(List<Judgment__c> judgmentList) {
        Set<Id> vacatedJudgments = new Set<Id>();
        for (Judgment__c judg : judgmentList) {
            if (judg.Legal_Sub_Status__c == 'Vacated') {
                vacatedJudgments.add(judg.Id);
            }
        }

        if (vacatedJudgments.isEmpty())
            return;
        List<Account_Judgment__c> accountJudgmentToInactive = new List<Account_Judgment__c>();
        for (Account_Judgment__c accJudg : [SELECT Id, Status__c FROM Account_Judgment__c WHERE Judgment__c IN :vacatedJudgments AND Status__c != 'Inactive']) {
            accJudg.Status__c = 'Inactive';
            accountJudgmentToInactive.add(accJudg);
        }

        if (!accountJudgmentToInactive.isEmpty()) {
            update accountJudgmentToInactive;
        }
    }

    public static void updateProductLegalStatus(Map<Id, Judgment__c> newJudgments, Map<Id, Judgment__c> oldJudgments) {
        Set<Id> judgmentIds = new Set<Id>();
        for (Id key : newJudgments.keySet()) {
            if (
                newJudgments.get(key).Legal_Status__c != oldJudgments.get(key).Legal_Status__c ||
                newJudgments.get(key).Legal_Sub_Status__c != oldJudgments.get(key).Legal_Sub_Status__c
            ) {
                judgmentIds.add(key);
            }
        }

        Map<Id, Id> productJudgmentMap = new Map<Id, Id>();
        for (Account_Judgment__c accJudg : [
            SELECT Product__c, Judgment__c
            FROM Account_Judgment__c
            WHERE Judgment__c IN :judgmentIds
        ]) {
            productJudgmentMap.put(accJudg.Product__c, accJudg.Judgment__c);
        }

        List<Product__c> prodList = new List<Product__c>();
        List<Product__c> prodData = [SELECT Id, Legal_Status__c FROM Product__c WHERE Id IN :productJudgmentMap.keySet()];
        for (Product__c prod : prodData) {
            Id judgmentId = productJudgmentMap.get(prod.Id);
            prod.Legal_Status__c = newJudgments.get(judgmentId).Legal_Status__c + ' - ' + newJudgments.get(judgmentId).Legal_Sub_Status__c;
            prodList.add(prod);
        }
        system.debug('prodList'+prodList);
        if (!prodList.isEmpty()) {
            ProductTriggerHandler.runProductTrigger = false;
            update prodList;
            ProductTriggerHandler.runProductTrigger = true;
        }
    }

    public static void handleAfterInsert(list<Judgment__c> judgment) {
        JudgmentTriggerHandler.updateAmountsOnJudgment(judgment);
        for (Judgment__c judgRecord : judgment) {
            Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
            config.Send_Notification__c = true;
            //call API
            if (judgRecord.Agency_Initiated_Legal_Action__c != null && judgRecord.Legal_Agency__c != null) {
                if (System.isBatch() && !Test.isRunningTest()) {
                    System.enqueueJob(new PortalJudgmentProcessingAPI(judgRecord.Id));
                } else {
                    PortalJudgmentProcessingAPI.processJudgment(judgRecord.Id);
                }
            }
            if (judgRecord.Legal_Agency__c != null && judgRecord.Name != null && config.Send_Notification__c == true) {
                notificationCallAPI(judgRecord.Legal_Agency__c, 'Judgment', 'Judgment Created', 'Judgment ' + judgRecord.Name + ' has been created.');
            }
        }
    }

    @future(callout=true)
    public static void notificationCallAPI(String placeId, String Type, String Title, String Message) {
        PortalNotificationAPI.sendPaymentNotification(placeId, Type, Title, '', Message);
    }

    public static void updateJudgmentInterestBalOnProduct(list<Judgment__c> listNewJudgments, Map<Id, Judgment__c> mapOldJudgments) {
        set<String> prodName = new Set<String>();
        map<String, Product__c> mapProductData = new Map<String, Product__c>();
        map<String, Product__c> mapProductDataDetails = new Map<String, Product__c>();
        set<id> ProductIds = new Set<id>();
        map<String, Product_Payments__c> ProductPaymentList = new Map<String, Product_Payments__c>();
        Map<Id, Product__c> productToUpdateMap = new Map<Id, Product__c>();
        Product__c productInstance;
        Date judgmentDate;
        for (Judgment__c judgment : listNewJudgments) {
            judgmentDate = judgment.Judgment_Date__c;
            if (judgment.Product_1__c != null) {
                prodName.add(judgment.Product_1__c);
            }
            if (judgment.Product_2__c != null) {
                prodName.add(judgment.Product_2__c);
            }
            if (judgment.Product_3__c != null) {
                prodName.add(judgment.Product_3__c);
            }
            if (judgment.Product_4__c != null) {
                prodName.add(judgment.Product_4__c);
            }
            if (judgment.Product_5__c != null) {
                prodName.add(judgment.Product_5__c);
            }
        }
        Date todayDate = Date.today();
        list<Product_Payments__c> listPayment = new List<Product_Payments__c>();
        String originalPayment = '';
        set<String> setReversalPayments = new Set<String>();
        for (Product_Payments__c productPay : [
            SELECT
                id,
                name,
                createdDate,
                CCS_Account__r.name,
                Principal_Payment_Amount__c,
                Interest_Payment_Amount__c,
                Payment_Posting_Date__c,
                Payment_Type__c,
                Original_Of_Payment_Reversal__c,
                Is_Payment_Reversed__c,
                Payment_Amount__c
            FROM Product_Payments__c
            WHERE CCS_Account__r.name = :prodName
        ]) {
            if (productPay.Payment_Amount__c < 0) {
                //get ID of the payments which are being reversed
                setReversalPayments.add(productPay.Original_Of_Payment_Reversal__c);
            }
        }
        map<ID, Product_Payments__c> mapReversedPayments = new Map<ID, Product_Payments__c>();
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
                    Product_Status_Desc_on_Product__c,
                    Pay_Due__c,
                    Tax_Amount__c,
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
                    Pay_Placedetail_Status__c
                FROM Product_Payments__c
                WHERE ID IN :setReversalPayments
            ]) {
                mapReversedPayments.put(prodPayment.ID, prodPayment);
            }
        }
        //Added for ticket 4495.
        Map<String, Boolean> prodPaymentMap = new Map<String, Boolean>();

        for (Product_Payments__c prodPaymentData : [
            SELECT
                id,
                name,
                createdDate,
                CCS_Account__r.name,
                Principal_Payment_Amount__c,
                Interest_Payment_Amount__c,
                Payment_Posting_Date__c,
                Payment_Type__c,
                Original_Of_Payment_Reversal__c,
                Is_Payment_Reversed__c,
                Payment_Amount__c
            FROM Product_Payments__c
            WHERE CCS_Account__r.name = :prodName
        ]) {
            if (!mapReversedPayments.containsKey(prodPaymentData.id) && prodPaymentData.Payment_Type__c != '1003') {
                system.debug('inside if condition' + prodPaymentData.name);
                if (prodPaymentData.Payment_Posting_Date__c >= judgmentDate && prodPaymentData.Payment_Posting_Date__c <= todayDate) {
                    system.debug('inside nested-if condition');
                    ProductIds.add(prodPaymentData.CCS_Account__c);
                    system.debug('ProductIds ***' + ProductIds);
                    ProductPaymentList.put(prodPaymentData.CCS_Account__r.name, prodPaymentData);
                    listPayment.add(prodPaymentData);

                    //Added for ticket 4495.
                    if (!prodPaymentMap.containsKey(prodPaymentData.CCS_Account__r.Name)) {
                        prodPaymentMap.put(prodPaymentData.CCS_Account__r.Name, true);
                    }
                }
            }
        }

        for (Product__c prodData : [
            SELECT
                id,
                name,
                interest_rate__c,
                Current_Principal_Balance__c,
                Current_Interest_Amount__c,
                Current_Balance__c,
                Previous_Principal_Balance__c,
                Previous_Interest_Rate__c,
                Judgment_Rate__c,
                Recoverable_Fee__c,
                Interest_Amount_Last_Calculated_Date__c
            FROM Product__c
            WHERE id = :ProductIds
        ]) {
            mapProductData.put(prodData.Name, prodData);
        }
        List<Product__c> ListProdctDetails = new List<Product__c>();

        for (Product__c prodDataDetails : [
            SELECT
                id,
                name,
                interest_rate__c,
                Current_Principal_Balance__c,
                Current_Interest_Amount__c,
                Current_Balance__c,
                Previous_Principal_Balance__c,
                Previous_Interest_Rate__c,
                Judgment_Rate__c,
                Recoverable_Fee__c,
                Interest_Amount_Last_Calculated_Date__c
            FROM Product__c
            WHERE name = :prodName
        ]) {
            mapProductDataDetails.put(prodDataDetails.Name, prodDataDetails);
            ListProdctDetails.add(prodDataDetails);
        }

        Decimal JudInterestRate = 0;
        Decimal JudBalance = 0;
        String JudProductName = '';
        String judgDate = '';

        //Added for ticket 4495.
        list<Product_Payments__c> listPayment1 = new List<Product_Payments__c>();
        for (Judgment__c judgment : listNewJudgments) {
            if (
                ((mapOldJudgments.get(judgment.ID).Legal_Status__c != 'Judgment' &&
                mapOldJudgments.get(judgment.ID).Legal_Status__c != 'Post-Judgment') &&
                (judgment.Legal_Status__c == 'Judgment' ||
                judgment.Legal_Status__c == 'Post-Judgment') &&
                judgment.Judgment_Date__c != null) ||
                ((judgment.Legal_Status__c == 'Judgment' || judgment.Legal_Status__c == 'Post-Judgment') &&
                (judgment.Judgment_Date__c != null &&
                mapOldJudgments.get(judgment.ID).Judgment_Date__c == null))
            ) {
                //Product 1 recalculation
                if (judgment.Product_1__c != null && judgment.Interest_Rate_one__c != null && judgment.Balance_one__c != null) {
                    JudProductName = judgment.Product_1__c;
                    JudBalance = judgment.Balance_one__c;
                    judgDate = String.valueOf(Judgment.Judgment_Date__c);
                    JudInterestRate = Judgment.Interest_Rate_one__c;
                    productToUpdateMap = calculateJudgmentInterestAdjustment(
                        listNewJudgments,
                        mapProductData,
                        JudProductName,
                        JudBalance,
                        JudInterestRate,
                        judgDate,
                        ProductPaymentList,
                        mapProductDataDetails
                    );
                    //Added for ticket 4495.
                    if (prodPaymentMap.containsKey(judgment.Product_1__c)) {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment, ListProdctDetails);
                    } else {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment1, ListProdctDetails);
                    }
                }

                //Product 2 recalculation
                if (judgment.Product_2__c != null && judgment.Interest_Rate_two__c != null && judgment.Balance_two__c != null) {
                    JudProductName = judgment.Product_2__c;
                    JudBalance = judgment.Balance_two__c;
                    judgDate = String.valueOf(Judgment.Judgment_Date__c);
                    JudInterestRate = Judgment.Interest_Rate_two__c;
                    productToUpdateMap = calculateJudgmentInterestAdjustment(
                        listNewJudgments,
                        mapProductData,
                        JudProductName,
                        JudBalance,
                        JudInterestRate,
                        judgDate,
                        ProductPaymentList,
                        mapProductDataDetails
                    );
                    //Added for ticket 4495.
                    if (prodPaymentMap.containsKey(judgment.Product_2__c)) {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment, ListProdctDetails);
                    } else {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment1, ListProdctDetails);
                    }
                } //Product 2 recalculation ends

                //Product 3 recalculation
                if (judgment.Product_3__c != null && judgment.Interest_Rate_three__c != null && judgment.Balance_three__c != null) {
                    JudProductName = judgment.Product_3__c;
                    JudBalance = judgment.Balance_three__c;
                    judgDate = String.valueOf(Judgment.Judgment_Date__c);
                    JudInterestRate = Judgment.Interest_Rate_three__c;
                    productToUpdateMap = calculateJudgmentInterestAdjustment(
                        listNewJudgments,
                        mapProductData,
                        JudProductName,
                        JudBalance,
                        JudInterestRate,
                        judgDate,
                        ProductPaymentList,
                        mapProductDataDetails
                    );
                    //Added for ticket 4495.
                    if (prodPaymentMap.containsKey(judgment.Product_3__c)) {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment, ListProdctDetails);
                    } else {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment1, ListProdctDetails);
                    }
                } //Product 3 recalculation ends

                //Product 4 recalculation
                if (judgment.Product_4__c != null && judgment.Interest_Rate_four__c != null && judgment.Balance_four__c != null) {
                    JudProductName = judgment.Product_4__c;
                    JudBalance = judgment.Balance_four__c;
                    judgDate = String.valueOf(Judgment.Judgment_Date__c);
                    JudInterestRate = Judgment.Interest_Rate_four__c;
                    productToUpdateMap = calculateJudgmentInterestAdjustment(
                        listNewJudgments,
                        mapProductData,
                        JudProductName,
                        JudBalance,
                        JudInterestRate,
                        judgDate,
                        ProductPaymentList,
                        mapProductDataDetails
                    );
                    //Added for ticket 4495.
                    if (prodPaymentMap.containsKey(judgment.Product_4__c)) {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment, ListProdctDetails);
                    } else {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment1, ListProdctDetails);
                    }
                } //Product 4 recalculation ends

                //Product 5 recalculation
                if (judgment.Product_5__c != null && judgment.Interest_Rate_five__c != null && judgment.Balance_five__c != null) {
                    JudProductName = judgment.Product_5__c;
                    JudBalance = judgment.Balance_five__c;
                    judgDate = String.valueOf(Judgment.Judgment_Date__c);
                    JudInterestRate = Judgment.Interest_Rate_five__c;
                    productToUpdateMap = calculateJudgmentInterestAdjustment(
                        listNewJudgments,
                        mapProductData,
                        JudProductName,
                        JudBalance,
                        JudInterestRate,
                        judgDate,
                        ProductPaymentList,
                        mapProductDataDetails
                    );
                    //Added for ticket 4495.
                    if (prodPaymentMap.containsKey(judgment.Product_5__c)) {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment, ListProdctDetails);
                    } else {
                        updateProductBalAndInterest(productToUpdateMap, judgmentDate, listPayment1, ListProdctDetails);
                    }
                } //Product 5 recalculation ends
            }
        }
    }

    public static void updateProductBalAndInterest(
        Map<Id, Product__c> productToUpdateMap,
        Date judgmentDate,
        list<Product_Payments__c> listPayment,
        List<Product__c> ListProdctDetails
    ) {
        Product__c ProductNewInstance = new Product__c();
        Date CurrentDate = Date.today();
        Decimal Current_Interest = 0;
        Decimal Principal_Payment_Amount = 0;
        Decimal Product_Current_Principal = 0;
        Decimal Product_Current_Interest = 0;
        Decimal Product_Current_Interest_Amount = 0;
        Decimal Interest_Payment_Amount = 0;
        Decimal InterestAmount = 0;
        Decimal InterestRate;
        Decimal Principal_Balance = 0;
        Decimal NoOfDays = 0;
        //set current Date to judgment Date
        CurrentDate = judgmentDate;

        //If Product has no Payments
        if (listPayment.isEmpty()) {
            for (Product__c prodDetails : ListProdctDetails) {
                Decimal interesttoAdjust;
                if (productToUpdateMap.containsKey(prodDetails.id)) {
                    ProductNewInstance.id = productToUpdateMap.get(prodDetails.id).id;
                    ProductNewInstance.Interest_Rate__c = productToUpdateMap.get(prodDetails.id).Interest_Rate__c;
                    ProductNewInstance.Judgment_Rate__c = productToUpdateMap.get(prodDetails.id).Judgment_Rate__c;
                    ProductNewInstance.Current_Principal_Balance__c = productToUpdateMap.get(prodDetails.id).Current_Principal_Balance__c;
                    ProductNewInstance.Interest_Amount_Last_Calculated_Date__c = Date.Today() - 1;
                    ProductNewInstance.Current_Interest_Amount__c = 0;
                    ProductNewInstance.Recoverable_Fee__c = productToUpdateMap.get(prodDetails.id).Recoverable_Fee__c;
                    Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2, RoundingMode.HALF_UP);

                    NoOfDays = (Date.valueOf(CurrentDate).daysBetween(Date.Today()));
                    //for include current date in interest calculation.
                    //as NoOfDays is one day less

                    NoOfDays = NoOfDays / 365;
                    //round of no of days to 4 decimal places
                    NoOfDays = NoOfDays.setScale(5, RoundingMode.HALF_UP);

                    //convert interest rate percent to decimal
                    InterestRate = ProductNewInstance.Interest_Rate__c;
                    InterestRate = InterestRate / 100;

                    interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                    //Round off Interest Amount accrued to 2 decimal places
                    interesttoAdjust = interesttoAdjust.setScale(2, RoundingMode.HALF_UP);

                    //Update Current Interest Amount
                    ProductNewInstance.Current_Interest_Amount__c = interesttoAdjust;

                    if (InterestRate != null && Principal_Balance != null) {
                        //Simplify no of days to 1/365;
                        Decimal NoOfDayss = 0.00273972;
                        //round of no of days to 5 decimal places
                        NoOfDayss = NoOfDayss.setScale(5, RoundingMode.HALF_UP);
                        //I=Prt
                        InterestAmount = Principal_Balance * InterestRate * NoOfDayss;
                        //Round off Interest Amount accrued to 2 decimal places
                        InterestAmount = InterestAmount.setScale(2, RoundingMode.HALF_UP);
                        //Populate Interest Amount Accrued for the Day
                        ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                    }
                    ProductNewInstance.Current_Balance__c =
                        (ProductNewInstance.Current_Principal_Balance__c != null ? ProductNewInstance.Current_Principal_Balance__c : 0) +
                        (ProductNewInstance.Current_Interest_Amount__c != null ? ProductNewInstance.Current_Interest_Amount__c : 0) +
                        (ProductNewInstance.Recoverable_Fee__c != null ? ProductNewInstance.Recoverable_Fee__c : 0);
                }
            }
            if (ProductNewInstance.id != null) {
                productToUpdateMap.put(ProductNewInstance.id, ProductNewInstance);
            }
        }

        //if product has payment 100x and 800x
        if (!listPayment.isEmpty()) {
            Date LastPaymentPostingDate;
            Map<ID, Boolean> prodPaymentMap = new Map<ID, Boolean>();
            for (Product_Payments__c prodPayment : listPayment) {
                if (!prodPaymentMap.containsKey(prodPayment.CCS_Account__c)) {
                    prodPaymentMap.put(prodPayment.CCS_Account__c, true);
                }
                if (productToUpdateMap.containsKey(prodPayment.CCS_Account__c)) {
                    if (prodPayment.Payment_Amount__c >= 0) {
                        Decimal interesttoAdjust = 0;
                        ProductNewInstance.id = productToUpdateMap.get(prodPayment.CCS_Account__c).id;
                        //Populate judgment interest rate on product
                        ProductNewInstance.Interest_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Interest_Rate__c;
                        ProductNewInstance.Judgment_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Judgment_Rate__c;

                        ProductNewInstance.Previous_Interest_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Previous_Interest_Rate__c;
                        ProductNewInstance.Previous_Principal_Balance__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Previous_Principal_Balance__c;
                        ProductNewInstance.Interest_Amount_Last_Calculated_Date__c = Date.today() - 1;
                        ProductNewInstance.Current_Principal_Balance__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Current_Principal_Balance__c;
                        //Round off Principal Balance accrued to 2 decimal places
                        Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2, RoundingMode.HALF_UP);
                        ProductNewInstance.Current_Interest_Amount__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Current_Interest_Amount__c;
                        //Round off Interest balance accrued to 2 decimal places
                        if(ProductNewInstance.Current_Interest_Amount__c != NULL){
                            Current_Interest = ProductNewInstance.Current_Interest_Amount__c.setScale(2, RoundingMode.HALF_UP);
                        }
                        if(prodPayment.Principal_Payment_Amount__c != NULL){
                           Principal_Payment_Amount = prodPayment.Principal_Payment_Amount__c.setScale(2, RoundingMode.HALF_UP); 
                        }
                        if(prodPayment.Interest_Payment_Amount__c != NULL){
                            Interest_Payment_Amount = prodPayment.Interest_Payment_Amount__c.setScale(2, RoundingMode.HALF_UP);
                        }
                        
                        NoOfDays = (Date.valueOf(CurrentDate).daysBetween(prodPayment.Payment_Posting_Date__c));
                        NoOfDays = NoOfDays / 365;
                        //round of no of days to 4 decimal places
                        NoOfDays = NoOfDays.setScale(5, RoundingMode.HALF_UP);

                        //convert interest rate percent to decimal
                        InterestRate = ProductNewInstance.Interest_Rate__c;
                        InterestRate = InterestRate / 100;

                        interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                        //Round off Interest Amount accrued to 2 decimal places
                        interesttoAdjust = interesttoAdjust.setScale(2, RoundingMode.HALF_UP);

                        //Update Current Interest Amount
                        if (ProductNewInstance.Current_Interest_Amount__c == null) {
                            ProductNewInstance.Current_Interest_Amount__c = interesttoAdjust;
                        } else {
                            ProductNewInstance.Current_Interest_Amount__c += interesttoAdjust;
                        }

                        prodPayment.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c != null ? prodPayment.Interest_Payment_Amount__c : 0;
                        prodPayment.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c != null ? prodPayment.Principal_Payment_Amount__c : 0;
                        Decimal totalProductPayment = prodPayment.Interest_Payment_Amount__c + prodPayment.Principal_Payment_Amount__c;
                        //Deduct Interest
                        if (totalProductPayment >= ProductNewInstance.Current_Interest_Amount__c) {
                            prodPayment.Interest_Payment_Amount__c = ProductNewInstance.Current_Interest_Amount__c;
                            totalProductPayment = totalProductPayment - ProductNewInstance.Current_Interest_Amount__c;
                            ProductNewInstance.Current_Interest_Amount__c = 0;
                        } else {
                            prodPayment.Interest_Payment_Amount__c = totalProductPayment;
                            ProductNewInstance.Current_Interest_Amount__c -= totalProductPayment;
                            totalProductPayment = 0;
                        }
                        //Deduct Principal
                        if (totalProductPayment >= ProductNewInstance.Current_Principal_Balance__c) {
                            prodPayment.Principal_Payment_Amount__c = ProductNewInstance.Current_Principal_Balance__c;
                            totalProductPayment = totalProductPayment - ProductNewInstance.Current_Principal_Balance__c;
                            ProductNewInstance.Current_Principal_Balance__c = 0;
                        } else {
                            prodPayment.Principal_Payment_Amount__c = totalProductPayment;
                            ProductNewInstance.Current_Principal_Balance__c -= totalProductPayment;
                            totalProductPayment = 0;
                        }
                        //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                        if (totalProductPayment <> 0 && ProductNewInstance.Current_Principal_Balance__c == 0) {
                            ProductNewInstance.Current_Principal_Balance__c = ProductNewInstance.Current_Principal_Balance__c - totalProductPayment;
                        }
                        //set currentDate to payment posting Date
                        CurrentDate = prodPayment.Payment_Posting_Date__c;
                    } //payment amount greater than zero
                    if (prodPayment.Payment_Posting_Date__c != null) {
                        LastPaymentPostingDate = prodPayment.Payment_Posting_Date__c;
                    }
                    Decimal DaysDiff;
                    if (LastPaymentPostingDate != null) {
                        DaysDiff = (Date.valueOf(LastPaymentPostingDate).daysBetween(Date.today()));
                    }
                    if (DaysDiff == 0) {
                        Decimal Last_Principal_Balance = 0;
                        Last_Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2, RoundingMode.HALF_UP);
                        if (InterestRate != null && Last_Principal_Balance != null) {
                            //Simplify no of days to 1/365;
                            Decimal NoOfDayss = 0.00273972;
                            //round of no of days to 5 decimal places
                            NoOfDayss = NoOfDayss.setScale(5, RoundingMode.HALF_UP);

                            //I=Prt
                            InterestAmount = Last_Principal_Balance * InterestRate * NoOfDayss;
                            //Round off Interest Amount accrued to 2 decimal places
                            InterestAmount = InterestAmount.setScale(2, RoundingMode.HALF_UP);

                            //Populate Interest Amount Accrued for the Day
                            ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                        }
                    }
                    if (ProductNewInstance.id != null) {
                        productToUpdateMap.put(ProductNewInstance.id, ProductNewInstance);
                    }
                } //end if
            } //end for loop

            for (product__c prodData : productToUpdateMap.values()) {
                //calculate interst between Last Payment Posting Date to currentDate
                Decimal interesttoAdjust;
                Principal_Balance = prodData.Current_Principal_Balance__c.setScale(2, RoundingMode.HALF_UP);
                if (LastPaymentPostingDate != null) {
                    NoOfDays = (Date.valueOf(LastPaymentPostingDate).daysBetween(Date.today()));
                }

                NoOfDays = NoOfDays / 365;
                //round of no of days to 4 decimal places
                NoOfDays = NoOfDays.setScale(5, RoundingMode.HALF_UP);

                //convert interest rate percent to decimal
                InterestRate = prodData.Interest_Rate__c;
                InterestRate = InterestRate / 100;

                interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                //Round off Interest Amount accrued to 2 decimal places
                interesttoAdjust = interesttoAdjust.setScale(2, RoundingMode.HALF_UP);

                //Update Current Interest Amount
                if (ProductNewInstance.Current_Interest_Amount__c == null) {
                    ProductNewInstance.Current_Interest_Amount__c = 0;
                }
                if (interesttoAdjust == null) {
                    interesttoAdjust = 0;
                }
                ProductNewInstance.Current_Interest_Amount__c += interesttoAdjust;
                ProductNewInstance.Current_Balance__c =
                    (ProductNewInstance.Current_Principal_Balance__c != null ? ProductNewInstance.Current_Principal_Balance__c : 0) +
                    (ProductNewInstance.Current_Interest_Amount__c != null ? ProductNewInstance.Current_Interest_Amount__c : 0) +
                    (ProductNewInstance.Recoverable_Fee__c != null ? ProductNewInstance.Recoverable_Fee__c : 0);

                Decimal Last_Principal_Balance = 0;

                //Added for ticket 4495.
                if (ProductNewInstance.Current_Principal_Balance__c != null) {
                    Last_Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2, RoundingMode.HALF_UP);
                }
                if (InterestRate != null && Last_Principal_Balance != null) {
                    //Simplify no of days to 1/365;
                    Decimal NoOfDayss = 0.00273972;
                    //round of no of days to 5 decimal places
                    NoOfDayss = NoOfDayss.setScale(5, RoundingMode.HALF_UP);

                    //I=Prt
                    InterestAmount = Last_Principal_Balance * InterestRate * NoOfDayss;
                    //Round off Interest Amount accrued to 2 decimal places
                    InterestAmount = InterestAmount.setScale(2, RoundingMode.HALF_UP);

                    //Populate Interest Amount Accrued for the Day
                    ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                }
                if (ProductNewInstance.id != null) {
                    productToUpdateMap.put(ProductNewInstance.id, ProductNewInstance);
                }
            }
        }
        ProductTriggerHandler.runProductTrigger = false;
        if (productToUpdateMap.containsKey(ProductNewInstance.ID) && ProductNewInstance.ID != null) {
            update productToUpdateMap.values();
        }
        ProductTriggerHandler.runProductTrigger = true;
    }
    /*****************************************************************************************************
Judgment Reversal Interest Calculation pseudo code
1) Pull list of 100x and 800x payments made between current date and Judgment Date

2)  a. Set Product Balance to be Judgment Balance
b. Set Product Current Interest Balance to $0
c. Set Product Current Interest Rate to be Judgement Rate
d. Set Interest Amount Last Calculated Date to Today

3) If no (100x and 800x) payments, Add daily interest from Judgment date to current date

Else{
CurDate = Judgment Date

For each payment P{

Add in/Accrue interest from CurDate to Payment Posting Date of P add to product current interest balance
- product Current Interest Balance = Product Current Principal Balance * ((no. of days * jud_interest_rate )/100)/365 + product Current Interest Balance

Deduct Balances according to Apportionment (Interest, Principal) 

Subtract the "Principal Payment Amount" on the Payment P from the Product Current Principal Balance
- Product Current Principal Balance = Product Current Principal Balance - Principal Payment Amount

Subtract the "Interest Payment Amount" from the Payment P from the Product Current Interest Balance
-   Product Current Interest Balance = Product Current Interest Balance - Interest Payment Amount
- interest will become will negative should will deduct from principal balance

CurDate = Payment Posting Date
}
Accure Interest from curDate (last payment's postoing date) to Today
}
4) Save final calculated values to Product Record
****************************************************************************************************/

    public static Map<Id, Product__c> calculateJudgmentInterestAdjustment(
        list<Judgment__c> listNewJudgments,
        map<String, Product__c> mapProductData,
        String JudProductName,
        Decimal JudBalance,
        Decimal JudInterestRate,
        String judgDate,
        Map<String, Product_Payments__c> ProductPaymentList,
        map<String, Product__c> mapProductDataDetails
    ) {
        Map<Id, Product__c> productToUpdateMap = new Map<Id, Product__c>();
        Product__c productInstance = new Product__c();

        // Step:2  d. Set Interest Amount Last Calculated Date to Today
        if (mapProductData.containsKey(JudProductName)) {
            productInstance = mapProductData.get(JudProductName);
            productInstance.Id = mapProductData.get(JudProductName).ID;
            productInstance.Name = mapProductData.get(JudProductName).Name;
            productInstance.Interest_Amount_Last_Calculated_Date__c = Date.today() - 1;
        }

        if (mapProductData.containsKey(productInstance.Name)) {
            if (
                mapProductData.get(productInstance.Name).Current_Principal_Balance__c != null &&
                mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0
            ) {
                //Step2 a. Set Product Balance to be Judgment Balance
                productInstance.Current_Principal_Balance__c = JudBalance;

                //Step2 b. Set Product Interest Balance to $0
                productInstance.Current_Interest_Amount__c = 0;

                if (mapProductData.containsKey(JudProductName)) {
                    ProductInstance.Previous_Interest_Rate__c = mapProductData.get(JudProductName).Interest_Rate__c;
                    ProductInstance.Previous_Principal_Balance__c = mapProductData.get(JudProductName).Current_Principal_Balance__c;
                }
                ProductInstance.Interest_Rate__c = JudInterestRate;
                productInstance.Judgment_Rate__c = JudInterestRate;
            }
        }
        //no payment foud for 100x and 800x then populate judgment interest rate and balance to product
        if (!mapProductData.containsKey(JudProductName) && String.isNotBlank(JudProductName)) {
            productInstance.ID = mapProductDataDetails.get(JudProductName).id;
            productInstance.Interest_Rate__c = JudInterestRate;
            productInstance.Current_Principal_Balance__c = JudBalance;
            productInstance.Current_Interest_Amount__c = mapProductDataDetails.get(JudProductName).Current_Interest_Amount__c;
            productInstance.Recoverable_Fee__c = mapProductDataDetails.get(JudProductName).Recoverable_Fee__c;
            productInstance.Judgment_Rate__c = JudInterestRate;
        }
        if (productInstance.ID != null) {
            productToUpdateMap.put(productInstance.id, productInstance);
        }
        return productToUpdateMap;
    }

    public static void handleAfterUpdate(list<Judgment__c> listNewJudgments, Map<Id, Judgment__c> mapOldJudgments) {
        map<String, ID> mapProductNameIds = new Map<String, ID>();
        map<String, Product__c> mapProductData = new Map<String, Product__c>();
        set<String> prodName = new Set<String>();
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        config.Send_Notification__c = true;
        JudgmentTriggerHandler.populateJudgmentWithPlacement(listNewJudgments);
        JudgmentTriggerHandler.updateAmountsOnJudgment(listNewJudgments);

        //Get active judgments related to product
        for (Judgment__c judgment : listNewJudgments) {
            if (judgment.Product_1__c != null) {
                prodName.add(judgment.Product_1__c);
            }
            if (judgment.Product_2__c != null) {
                prodName.add(judgment.Product_2__c);
            }
            if (judgment.Product_3__c != null) {
                prodName.add(judgment.Product_3__c);
            }
            if (judgment.Product_4__c != null) {
                prodName.add(judgment.Product_4__c);
            }
            if (judgment.Product_5__c != null) {
                prodName.add(judgment.Product_5__c);
            }
        }

        for (Account_judgment__c accJudgment : [
            SELECT ID, Name, Product__c, Judgment__c, Product__r.Name
            FROM Account_Judgment__c
            WHERE
                Judgment__c IN :listNewJudgments
                AND Status__c = 'Active'
                AND (Judgment__r.Legal_Status__c = 'Judgment'
                OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                AND Judgment__r.Judgment_Date__c != NULL
            ORDER BY CreatedDate DESC
        ]) {
            mapProductNameIds.put(accJudgment.Product__r.Name, accJudgment.Product__c);
        }

        for (Product__c prodData : [
            SELECT
                id,
                name,
                interest_rate__c,
                Current_Principal_Balance__c,
                Current_Interest_Amount__c,
                Current_Balance__c,
                Previous_Principal_Balance__c,
                Previous_Interest_Rate__c,
                Recoverable_Fee__c
            FROM Product__c
            WHERE Name = :prodName
        ]) {
            mapProductData.put(prodData.Name, prodData);
        }

        list<Product__c> listProductToUpdate = new List<product__c>();
        Map<Id, Product__c> productToUpdateMap = new Map<Id, Product__c>();
        //Update Current Pincipal Balance on Product from Judgment Balance wrt to Product when Judgment is updated to Active
        Product__c productInstance;
        updateJudgmentInterestBalOnProduct(listNewJudgments, mapOldJudgments);

        for (Judgment__c judgment : listNewJudgments) {
            if (config.Run_Judgment_Update_API_For_Portal__c) {
                //call API
                if (judgment.Agency_Initiated_Legal_Action__c != null && judgment.Legal_Agency__c != null) {
                    if(runJudgmentValidation == true){
                        if (System.isBatch() && !Test.isRunningTest()) {
                            System.enqueueJob(new PortalJudgmentProcessingAPI(judgment.Id));
                        } else {
                            PortalJudgmentProcessingAPI.processJudgment(judgment.ID);
                        }
                    }
                }
            }
        }
        update productToUpdateMap.values();
    }

    //using this inner method populate the identifier fields using CFG data.
    public static void getJudgmentRelatedData(list<Judgment__c> listJudgment) {
        set<Id> setSuperiorCourtID = new Set<Id>();
        set<Id> setSmallCourtClaimID = new Set<Id>();
        set<Id> setEnforcementCountyID = new Set<Id>();
        set<Id> setCountyID = new Set<Id>();

        map<Id, String> mapSuperiorCourtNames = new Map<Id, String>();
        map<Id, String> mapSmallCourtClaimNames = new Map<Id, String>();
        map<Id, String> mapEnforcementCountyNames = new Map<Id, String>();
        map<Id, String> mapCountyNames = new Map<Id, String>();

        for (Judgment__c judgmentObj : listJudgment) {
            setSuperiorCourtID.add(judgmentObj.Superior_Court__c);
            setSmallCourtClaimID.add(judgmentObj.Small_Claims_Court__c);
            setEnforcementCountyID.add(judgmentObj.Enforcement_County__c);
            setCountyID.add(judgmentObj.County__c);
        }

        for (Superior_Court__c sCourt : [
            SELECT ID, Name
            FROM Superior_Court__c
            WHERE ID IN :setSuperiorCourtID
        ]) {
            mapSuperiorCourtNames.put(sCourt.Id, sCourt.Name);
        }

        for (Small_Claims_Court__c smallCourt : [
            SELECT ID, Name
            FROM Small_Claims_Court__c
            WHERE ID IN :setSmallCourtClaimID
        ]) {
            mapSmallCourtClaimNames.put(smallCourt.ID, smallCourt.Name);
        }

        for (Enforcement_County__c enforceCounty : [
            SELECT ID, Name
            FROM Enforcement_County__c
            WHERE ID IN :setEnforcementCountyID
        ]) {
            mapEnforcementCountyNames.put(enforceCounty.ID, enforceCounty.Name);
        }
        List<Court__c> countyData = [
            SELECT ID, Name
            FROM Court__c
            WHERE ID IN :setCountyID
        ];

        for (Court__c county : countyData) {
            mapCountyNames.put(county.ID, county.Name);
        }

        for (Judgment__c JudgmentObj : listJudgment) {
            JudgmentObj.Superior_Court_Identifier__c = mapSuperiorCourtNames.get(JudgmentObj.Superior_Court__c);
            JudgmentObj.Small_Claims_Court_Identifier__c = mapSmallCourtClaimNames.get(JudgmentObj.Small_Claims_Court__c);
            JudgmentObj.Enforcement_County_Identifier__c = mapEnforcementCountyNames.get(JudgmentObj.Enforcement_County__c);
            JudgmentObj.County_Identifier__c = mapCountyNames.get(JudgmentObj.County__c);
        }
    }

    public static void validationRulesProductToJudgment(list<Judgment__c> listNewJudgments, list<String> listLegalStatuses) {
        ProductTriggerHandler.runPaymentProcessing = false;
        String Codes;
        String Product_1;
        String AgencyLegalAction = '';
        String Province = '';
        String Plaintiff = '';
        map<ID, ID> mapActiveAccountJudgments = new Map<ID, ID>();
        Set<ID> mapProdId = new Set<ID>();
        map<ID, Product__c> mapProd = new Map<ID, Product__c>();
        //map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new Map<String, Judgment_product_codes_mapping__c>();

        /*for (Judgment_product_codes_mapping__c mapping : [
            SELECT Id, Name, Codes__c, Product_Status__c, Product_Sub_status__c, Judgment_Legal_Status__c, Judgment_Legal_Sub_Status__c
            FROM Judgment_product_codes_mapping__c
            WHERE Product_Parent__c IN :listLegalStatuses
        ]) {
            mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c + mapping.Judgment_Legal_Sub_Status__c, mapping);
        }*/
        for (Account_Judgment__c accJudgment : [
            SELECT ID, Judgment__c, Product__c
            FROM Account_Judgment__c
            WHERE Judgment__c IN :listNewJudgments
        ]) {
            mapActiveAccountJudgments.put(accJudgment.Judgment__c, accJudgment.Product__c);
            mapProdId.add(accJudgment.Product__c);
        }
        for (Product__c prod : [
            SELECT ID, Name, Collection_Agency__c, Collection_Agency_Placement__c, State__c, Account_Purchasing_Entity_Value__c
            FROM Product__c
            WHERE ID = :mapProdId
        ]) {
            mapProd.put(prod.id, prod);
        }
        for (Judgment__c judg : listNewJudgments) {
            Product__c product = new Product__c();
            product.ID = mapActiveAccountJudgments.get(judg.ID);
            if (mapProd.get(product.ID) != null) {
                //Populate Agency from Product to Judgment.
                if (mapProd.get(product.ID).Collection_Agency__c != null) {
                    AgencyLegalAction = String.valueOf(Math.floor(mapProd.get(product.ID).Collection_Agency__c));
                }
                //Populate Province from Product to Judgment.
                if (mapProd.get(product.ID).State__c != null) {
                    prodProvinceName = mapProd.get(product.ID).State__c;
                    ProvinceNameFormat = nameFormat(prodProvinceName);
                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                    if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                        Province = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                    } else if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                        Province = ProvinceNameFormat;
                    }
                }
                Product_1 = mapProd.get(product.ID).Name;
                Plaintiff = mapProd.get(product.ID).Account_Purchasing_Entity_Value__c;
            }
            if (!(mapProd.isEmpty())) {
                if (mapAccountJudgmentCodes.containsKey(judg.Legal_Status__c + judg.Legal_Sub_Status__c)) {
                    codes = mapAccountJudgmentCodes.get(judg.Legal_Status__c + judg.Legal_Sub_Status__c).Codes__c;
                }
            }
            if (Test.isRunningTest()) {
                if (mapAccountJudgmentCodes.containsKey(judg.Legal_Status__c + judg.Legal_Sub_Status__c)) {
                    codes = mapAccountJudgmentCodes.get(judg.Legal_Status__c + judg.Legal_Sub_Status__c).Codes__c;
                }
            }

            if ((codes == '220000') || (codes == '220210') || (codes == '220700') || (codes == '220030') || (codes == '220040') || (codes == '220050')) {
                if (runJudgmentValidation == true && 
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction)
                )) {
                    judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true && (judg.Suit_Amount_2__c == null || judg.Interest_Rate_two__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true && (judg.Suit_Amount_3__c == null || judg.Interest_Rate_three__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true && (judg.Suit_Amount_4__c == null || judg.Interest_Rate_four__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true && (judg.Suit_Amount_5__c == null || judg.Interest_Rate_five__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if (
                (codes == '220020') ||
                (codes == '220220') ||
                (codes == '220900') ||
                (codes == '290400') ||
                (codes == '299100') ||
                (codes == '299999') ||
                (codes == '290020')
            ) {
                if (runJudgmentValidation == true && 
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction)
                )) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action'
                    );
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true && (judg.Suit_Amount_2__c == null || judg.Interest_Rate_two__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true && (judg.Suit_Amount_3__c == null || judg.Interest_Rate_three__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true && (judg.Suit_Amount_4__c == null || judg.Interest_Rate_four__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true && (judg.Suit_Amount_5__c == null || judg.Interest_Rate_five__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if (
                (codes == '290000') ||
                (codes == '290010') ||
                (codes == '290700') ||
                (codes == '291000') ||
                (codes == '290030') ||
                (codes == '290040') ||
                (codes == '290050') ||
                (codes == '293010') ||
                (codes == '293030') ||
                (codes == '293040') ||
                (codes == '293050') ||
                (codes == '295070') ||
                (codes == '295080') ||
                (codes == '295900')
            ) {
                if (runJudgmentValidation == true && 
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    judg.Judgment_Date__c == null ||
                    judg.Judgment_Amount__c == null ||
                    judg.Filing_Date__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction)
                )) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action'
                    );
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Balance_one__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_2__c == null ||
                    judg.Balance_two__c == null ||
                    judg.Interest_Rate_two__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_3__c == null ||
                    judg.Balance_three__c == null ||
                    judg.Interest_Rate_three__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_4__c == null ||
                    judg.Balance_four__c == null ||
                    judg.Interest_Rate_four__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_5__c == null ||
                    judg.Balance_five__c == null ||
                    judg.Interest_Rate_five__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if ((codes == '290005')) {
                if (runJudgmentValidation == true && 
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    judg.Judgment_Date__c == null ||
                    judg.Judgment_Amount__c == null ||
                    judg.Filing_Date__c == null)
                ) {
                    judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date');
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Balance_one__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_2__c == null ||
                    judg.Balance_two__c == null ||
                    judg.Interest_Rate_two__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_3__c == null ||
                    judg.Balance_three__c == null ||
                    judg.Interest_Rate_three__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_4__c == null ||
                    judg.Balance_four__c == null ||
                    judg.Interest_Rate_four__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_5__c == null ||
                    judg.Balance_five__c == null ||
                    judg.Interest_Rate_five__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if ((codes == '293000') || (codes == '294000')) {
                if (runJudgmentValidation == true &&
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    judg.Judgment_Date__c == null ||
                    judg.Judgment_Amount__c == null ||
                    judg.Filing_Date__c == null ||
                    String.isBlank(judg.Garnishment_Number__c) ||
                    judg.Garnishment_Date__c == null ||
                    judg.Garnishment_Amount__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction))
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action'
                    );
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Balance_one__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_2__c == null ||
                    judg.Balance_two__c == null ||
                    judg.Interest_Rate_two__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate2,Suit Amount 2'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_3__c == null ||
                    judg.Balance_three__c == null ||
                    judg.Interest_Rate_three__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_4__c == null ||
                    judg.Balance_four__c == null ||
                    judg.Interest_Rate_four__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_5__c == null ||
                    judg.Balance_five__c == null ||
                    judg.Interest_Rate_five__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if ((codes == '295000') || (codes == '295030') || (codes == '295060') || (codes == '295010') || (codes == '295040') || (codes == '295050')) {
                if (runJudgmentValidation == true &&
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    judg.Judgment_Date__c == null ||
                    judg.Judgment_Amount__c == null ||
                    judg.Filing_Date__c == null ||
                    String.isBlank(judg.Writ_Number__c) ||
                    judg.Writ_Amount__c == null ||
                    judg.Date_Writ_Issued__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction))
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action'
                    );
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Balance_one__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_2__c == null ||
                    judg.Balance_two__c == null ||
                    judg.Interest_Rate_two__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_3__c == null ||
                    judg.Balance_three__c == null ||
                    judg.Interest_Rate_three__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true && 
                    (judg.Suit_Amount_4__c == null ||
                    judg.Balance_four__c == null ||
                    judg.Interest_Rate_four__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_5__c == null ||
                    judg.Balance_five__c == null ||
                    judg.Interest_Rate_five__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
            if ((codes == '295020')) {
                if (runJudgmentValidation == true &&
                    (String.isBlank(judg.Case_Number__c) ||
                    String.isBlank(Province) ||
                    judg.Suit_Amount__c == null ||
                    judg.Date_Debtor_Served__c == null ||
                    judg.Judgment_Date__c == null ||
                    judg.Judgment_Amount__c == null ||
                    judg.Filing_Date__c == null ||
                    String.isBlank(judg.Writ_Number__c) ||
                    judg.Writ_Amount__c == null ||
                    judg.Date_Writ_Issued__c == null ||
                    judg.Garnishment_Amount__c == null ||
                    String.isBlank(judg.Garnishment_Number__c) ||
                    judg.Garnishment_Date__c == null ||
                    String.isBlank(judg.Court__c) ||
                    String.isBlank(judg.Legal_Firm__c) ||
                    String.isBlank(Plaintiff) ||
                    String.isBlank(judg.Attorney__c) ||
                    String.isBlank(AgencyLegalAction))
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action'
                    );
                }
                if (String.isNotBlank(Product_1) && runJudgmentValidation == true && (judg.Suit_Amount_1__c == null || judg.Balance_one__c == null || judg.Interest_Rate_one__c == null)) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_2__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_2__c == null ||
                    judg.Balance_two__c == null ||
                    judg.Interest_Rate_two__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_3__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_3__c == null ||
                    judg.Balance_three__c == null ||
                    judg.Interest_Rate_three__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_4__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_4__c == null ||
                    judg.Balance_four__c == null ||
                    judg.Interest_Rate_four__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4'
                    );
                }
                if (
                    String.isNotBlank(judg.Product_5__c) && runJudgmentValidation == true &&
                    (judg.Suit_Amount_5__c == null ||
                    judg.Balance_five__c == null ||
                    judg.Interest_Rate_five__c == null)
                ) {
                    judg.addError(
                        'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5'
                    );
                }
            }
        }
    }
    public static void validationRules(list<Judgment__c> listJudgment, Map<Id, Judgment__c> mapOldJudgment) {
        for (Judgment__c judg : listJudgment) {
            Judgment__c judgOld = mapOldJudgment.get(judg.id);

            if (judgOld.Legal_Status__c == 'Judgment' && judg.Legal_Status__c == 'Pre-Judgment' && runJudgmentValidation == true) {
                judg.addError('Invalid status received. The Judgment must be vacated prior to assigning a different status');
            }
            if (
                judg.Legal_Status__c == 'Post-Judgment' && runJudgmentValidation == true &&
                (judg.Date_Writ_Issued__c == null ||
                judg.Writ_Amount__c == null ||
                judg.Garnishment_Date__c == null ||
                judg.Garnishment_Amount__c == null)
            ) {
                judg.addError('A writ date is not found, A writ amount is not found, A garnishment date is not found, A garnishment amount is not found');
            }
            if (
                judg.Legal_Status__c == 'Pre-Judgment' && runJudgmentValidation == true &&
                (judg.Suit_Amount__c == null ||
                judg.Case_Number__c == null ||
                judg.Judgment_Province__c == null ||
                judg.Plaintiff__c == null) &&
                (judg.Enforcement_County_Address__c == null &&
                judg.Small_Claims_Court_Address__c == null &&
                judg.Superior_Court_Address__c == null)
            ) {
                judg.addError(
                    'A suit amount was not found, A case number was not found, A judgment province was not found, A court division was not found, A court location was not found, A plaintiff was not found'
                );
            }
            if (
                judg.Legal_Status__c == 'Pre-Legal' && runJudgmentValidation == true &&
                (judg.Judgment_Province__c == null ||
                judg.Suit_Amount__c == null ||
                judg.Case_Number__c == null ||
                judg.Plaintiff__c == null ||
                judg.County__c == null ||
                judg.Legal_Firm__c == null ||
                judg.Attorney__c == null) &&
                (judg.Superior_Court__c == null &&
                judg.Small_Claims_Court__c == null &&
                judg.Enforcement_County__c == null)
            ) {
                judg.addError(
                    'suit amount not found, case number not found, judgment geography not found, court not found, county not found, plaintiff not found, attorney not found and legal firm not found'
                );
            }
            if ((judg.Legal_Status__c != 'Judgment' && judg.Legal_Status__c != 'Post-Judgment') && judg.Legal_Sub_Status__c == 'Vacated' && runJudgmentValidation == true) {
                judg.addError('There is no judgment on this account to vacate');
            }
            if (
                (judgOld.Legal_Status__c != 'Judgment' ||
                judgOld.Legal_Status__c != 'Post-Judgment') &&
                (judg.Legal_Status__c == 'Judgment' ||
                judg.Legal_Status__c == 'Post-Judgment') &&
                (judg.Judgment_Amount__c == null ||
                judg.Judgment_Date__c == null) && runJudgmentValidation == true
            ) {
                judg.addError('Judgment Amount is required, Judgment Date is required');
            }
        }
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

    public static void recalculateDisbursmentFees(set<ID> productId) {
        List<String> prodId = new List<String>();
        List<Judgment__c> updateJudg = new List<Judgment__c>();
        Map<Id, Judgment__c> judgMap = new Map<Id, Judgment__c>();
        Decimal Nonrecoverable = 0;
        Decimal recoverable = 0;

        List<Account_Judgment__c> accJudgment = [
            SELECT
                ID,
                Judgment__c,
                Product__c,
                Product__r.name,
                Judgment__r.Product_1__c,
                Judgment__r.Product_2__c,
                Judgment__r.Product_3__c,
                Judgment__r.Product_4__c,
                Judgment__r.Product_5__c
            FROM Account_Judgment__c
            WHERE Product__c IN :productId AND Status__c = 'Active'
        ];

        for (Account_Judgment__c accJud : accJudgment) {
            if (accJud.Judgment__r.Product_1__c != null) {
                prodId.add(accJud.Judgment__r.Product_1__c);
            }
            if (accJud.Judgment__r.Product_2__c != null) {
                prodId.add(accJud.Judgment__r.Product_2__c);
            }
            if (accJud.Judgment__r.Product_3__c != null) {
                prodId.add(accJud.Judgment__r.Product_3__c);
            }
            if (accJud.Judgment__r.Product_4__c != null) {
                prodId.add(accJud.Judgment__r.Product_4__c);
            }
            if (accJud.Judgment__r.Product_5__c != null) {
                prodId.add(accJud.Judgment__r.Product_5__c);
            }
        }

        for (AggregateResult aggr : [
            SELECT Judgment__c, sum(Product__r.Non_Recoverable_Fee__c) totalNonRecov, sum(Product__r.Recoverable_Fee__c) totalRecov
            FROM Account_Judgment__c
            WHERE Product__r.Name IN :prodId AND Status__c = 'Active'
            GROUP BY Judgment__c
        ]) {
            Judgment__c judg = new Judgment__c();
            judg.id = (id) aggr.get('Judgment__c');
            judg.Balance_Adjusting_Disbursements__c = (decimal) aggr.get('totalRecov');
            judg.Non_Balance_Adjusting_Disbursements__c = (decimal) aggr.get('totalNonRecov');
            judgMap.put(judg.id, judg);
        }

        JudgmentTriggerHandler.runJudgmentTrigger = false;
        applicationConfigSetting.Bypass_Judgement_Validation__c = false;
        
        if(applicationConfigSetting.Id != NULL){ // Abhijeet (18/09/2024) - Null check on record Id prior to update
            update applicationConfigSetting;
        }
        update judgMap.values();
        applicationConfigSetting.Bypass_Judgement_Validation__c = true;
        JudgmentTriggerHandler.runJudgmentTrigger = true;
        if(applicationConfigSetting.Id != NULL){ // Abhijeet (18/09/2024) - Null check on record Id prior to update
            update applicationConfigSetting;
        }
    }
    //Bug: 5564 - Nagendra added below method
    //To Populate the Placement Ids on Judgment
    public static void populateJudgmentWithPlacement(List<Judgment__C> prodJudgList) {
        Map<Id, String> placementIDMap = new Map<Id, String>();
        Set<ID> judgmentSet = new Set<ID>();
        Set<ID> productSet = new Set<ID>();
        Map<ID, Judgment__C> judgmentMap = new Map<ID, Judgment__C>();
        Map<ID, Product__C> ProductMap = new Map<Id, Product__C>();

        for (Judgment__C prodJudg : prodJudgList) {
            judgmentSet.add(prodJudg.ID);
        }

        List<Account_Judgment__c> listAccountJudgment = [SELECT id, Judgment__C, Product__c FROM Account_Judgment__c WHERE Judgment__C IN :judgmentSet];

        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }

        List<Product__c> listProduct = [SELECT id, Collection_Agency__C FROM Product__C WHERE id IN :productSet];

        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            for (Product__C prod : listProduct) {
                if (prod.id == prodJudg.Product__C) {
                    productMap.put(prodJudg.id, prod);
                }
            }
        }

        //recalculate the Collection agency identifer for all related judgmets
        Map<ID, String> judgmentUpdate = new Map<Id, String>();
        Map<ID, String> judgmentExternalIdentifierUpdate = new Map<Id, String>();
        String collectionAgencyidentifier = '';
        String IdentifierList = '';
        String externalCollectionAgency = '';
        for (Account_Judgment__c prodJudg : listAccountJudgment) {
            Product__c prod = productMap.get(prodJudg.id);
            if (null == prod)
                continue;
            if (null == prod.Collection_Agency__C) {
                collectionAgencyidentifier = SEPARATOR + UNPLACED + SEPARATOR;
            } else {
                collectionAgencyidentifier = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                //populate External Collection Agency identifier
                if (prod.Collection_Agency__C != 6 && prod.Collection_Agency__C != 68) {
                    externalCollectionAgency = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                }
            }

            IdentifierList = judgmentUpdate.get(prodJudg.Judgment__c);

            if (String.isBlank(IdentifierList)) {
                IdentifierList = collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            } else if ((IdentifierList).contains(collectionAgencyidentifier)) {
                //Do Nothing
            } else {
                IdentifierList += collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            }
            if (String.isNotBlank(externalCollectionAgency)) {
                judgmentExternalIdentifierUpdate.put(prodJudg.Judgment__c, externalCollectionAgency);
            }
        }

        //Save the Judgments
        List<Judgment__C> listJudgment = new List<Judgment__c>();
        if (judgmentUpdate.size() > 0) {
            for (ID judgmentID : judgmentUpdate.keySet()) {
                Judgment__c judge = new Judgment__c();
                judge.Collection_Agency_Identifier__c = judgmentUpdate.get(judgmentID);
                //populate External Collection Agency identifier
                judge.External_Collection_Agency_Identifier__c = judgmentExternalIdentifierUpdate.get(judgmentID);
                judge.id = judgmentID;
                if (null != judge.id) {
                    listJudgment.add(judge);
                }
            }
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            update listJudgment;
            JudgmentTriggerHandler.runJudgmentTrigger = true;
        }
    }

    //Bug: 5476 changes starts
    public static void validationRuleonProductAgencies(list<Judgment__c> listNewJudgments, Map<Id, Judgment__c> mapOldJudgments) {
        set<String> prodNames = new Set<String>();
        for (Judgment__c judgment : listNewJudgments) {
            if (
                judgment.Product_1__c <> mapOldJudgments.get(judgment.id).Product_1__c ||
                judgment.Product_2__c <> mapOldJudgments.get(judgment.id).Product_2__c ||
                judgment.Product_3__c <> mapOldJudgments.get(judgment.id).Product_3__c ||
                judgment.Product_4__c <> mapOldJudgments.get(judgment.id).Product_4__c ||
                judgment.Product_5__c <> mapOldJudgments.get(judgment.id).Product_5__c
            ) {
                if (judgment.Product_1__c != null)
                    prodNames.add(judgment.Product_1__c);
                if (judgment.Product_2__c != null)
                    prodNames.add(judgment.Product_2__c);
                if (judgment.Product_3__c != null)
                    prodNames.add(judgment.Product_3__c);
                if (judgment.Product_4__c != null)
                    prodNames.add(judgment.Product_4__c);
                if (judgment.Product_5__c != null)
                    prodNames.add(judgment.Product_5__c);
            }
        }
        if (prodNames.size() > 1) {
            list<decimal> prodAgency2 = new List<decimal>();
            list<decimal> prodAgency3 = new List<decimal>();
            list<string> prodProvince2 = new List<string>();
            list<string> prodProvince3 = new List<string>();
            list<Product__c> prodList = [SELECT id, Collection_Agency__c,Purchase_Province__c FROM product__c WHERE name IN :(prodNames)];
            for (product__c p : prodList) {
                prodAgency2.add(p.Collection_Agency__C);
                prodAgency3.add(p.Collection_Agency__C);
                prodProvince2.add(p.Purchase_Province__c);
                prodProvince3.add(p.Purchase_Province__c);
            }
            for (Judgment__c judgment : listNewJudgments) {
                for (decimal pAgency : prodAgency2) {
                    for (decimal ProductAgency : prodAgency3) {
                        if (ProductAgency <> pAgency && runJudgmentValidation == true) {
                            judgment.addError('All Products in the Judgment should be in same agency.');
                        }
                    }
                }
                for (string province : prodProvince2) {
                    for (string ProductProvince : prodProvince3) {
                        if (ProductProvince <> province) {
                            judgment.addError('All Products in the Judgment should be in same province.');
                        }
                    }
                }
            }
        }
    }
    //Bug: 5476 changes ends
    //Bug: 5476 changes starts
    public static void validationRuleonProductAgencies(list<Judgment__c> listNewJudgments) {
        set<String> prodNames = new Set<String>();
        for (Judgment__c judgment : listNewJudgments) {
            if (judgment.Product_1__c != null) {
                prodNames.add(judgment.Product_1__c);
            }
            if (judgment.Product_2__c != null) {
                prodNames.add(judgment.Product_2__c);
            }
            if (judgment.Product_3__c != null) {
                prodNames.add(judgment.Product_3__c);
            }
            if (judgment.Product_4__c != null) {
                prodNames.add(judgment.Product_4__c);
            }
            if (judgment.Product_5__c != null) {
                prodNames.add(judgment.Product_5__c);
            }
        }
        if (prodNames.size() > 1) {
            list<decimal> prodAgency2 = new List<decimal>();
            list<decimal> prodAgency3 = new List<decimal>();
            list<Product__c> prodList = [SELECT id, Collection_Agency__c FROM product__c WHERE name IN :(prodNames)];
            for (product__c p : prodList) {
                prodAgency2.add(p.Collection_Agency__C);
                prodAgency3.add(p.Collection_Agency__C);
            }
            for (Judgment__c judgment : listNewJudgments) {
                for (decimal pAgency : prodAgency2) {
                    for (decimal ProductAgency : prodAgency3) {
                        if (ProductAgency <> pAgency && runJudgmentValidation == true) {
                            judgment.addError('All Products in the Judgment should be in same agency.');
                        }
                    }
                }
            }
        }
    }
    public static void updateAmountsOnJudgment(List<Judgment__c> prodJudgList) {
        Set<Id> judgmentIds = new Set<Id>();
        Set<Id> judgmentActiveIds = new Set<Id>();
        Map<Id, String> judgmentIdCompanyNameMap = new Map<Id, String>();
        Map<Id, String> judgmentIdPurchaseEntityMap = new Map<Id, String>();
        set<string> prodNames = new Set<string>();
        set<string> prodActiveNames = new Set<string>();
        map<String, String> prodJudgmap = new Map<String, String>();
        List<Product__c> activeProducts = new List<Product__c>();
        for (Judgment__c judgment : prodJudgList) {
            judgmentIds.add(judgment.ID);
            if (judgment.Product_1__c != null) {
                prodNames.add(judgment.Product_1__c);
            }
            if (judgment.Product_2__c != null) {
                prodNames.add(judgment.Product_2__c);
            }
            if (judgment.Product_3__c != null) {
                prodNames.add(judgment.Product_3__c);
            }
            if (judgment.Product_4__c != null) {
                prodNames.add(judgment.Product_4__c);
            }
            if (judgment.Product_5__c != null) {
                prodNames.add(judgment.Product_5__c);
            }
        }
        if (!prodNames.isEmpty()) {
            system.debug('Product Names before loop-->' + prodNames);
            for (Account_Judgment__c accJudgList : [
                SELECT
                    Judgment__c,
                    Status__c,
                    Product__r.Company_Name__c,
                    Product__r.Account_Purchasing_Entity_Value__c,
                    Product__r.name,
                    Product__r.Collection_Agency__c
                FROM Account_Judgment__c
                WHERE Judgment__c IN :judgmentIds
                ORDER BY Product__r.LastModifiedDate DESC
            ]) {
                if (accJudgList.Status__c == 'InActive') {
                    prodNames.remove(accJudgList.Product__r.name);
                }
                if (accJudgList.Status__c == 'Active') {
                    judgmentActiveIds.add(accJudgList.Judgment__c);
                    prodJudgmap.put(accJudgList.Product__r.name, accJudgList.Judgment__c);
                }
                if (!judgmentIdCompanyNameMap.containsKey(accJudgList.Judgment__c) && accJudgList.Product__r.Company_Name__c != null)
                    judgmentIdCompanyNameMap.put(accJudgList.Judgment__c, accJudgList.Product__r.Company_Name__c);

                if (!judgmentIdPurchaseEntityMap.containsKey(accJudgList.Judgment__c) && accJudgList.Product__r.Account_Purchasing_Entity_Value__c != null)
                    judgmentIdPurchaseEntityMap.put(accJudgList.Judgment__c, accJudgList.Product__r.Account_Purchasing_Entity_Value__c);

                system.debug(accJudgList.Judgment__c + '===' + accJudgList.Product__r.Company_Name__c);
            }
            prodActiveNames.addAll(prodNames);
        }
        if (!prodActiveNames.isEmpty()) {
            activeProducts = [
                SELECT Collection_Agency__c, State__c, Purchase_Province__c, Account_Purchasing_Entity_Value__c
                FROM Product__c
                WHERE Name IN :prodActiveNames AND Collection_Agency__c != NULL AND State__c != NULL
                LIMIT 1
            ];
            AggregateResult[] groupedResults = [
                SELECT SUM(Current_Principal_Balance__c) currentPrincipalBalance, SUM(Current_Interest_Amount__c) currentInterestBalance, Name
                FROM product__c
                WHERE Name IN :prodActiveNames
                GROUP BY Name
            ];
            String province = !activeProducts.isEmpty() ? mapProvinceAcronymTaxMetadata.get(activeProducts[0].Purchase_Province__c).Province_Name__c : '';
            String plaintiff = !activeProducts.isEmpty() ? activeProducts[0].Account_Purchasing_Entity_Value__c : '';
            List<Judgment__c> judgList = new List<Judgment__c>();
            List<Id> judgUpdate = new List<Id>();

            if (!judgmentActiveIds.isEmpty()) {
                for (AggregateResult aggRes : groupedResults) {
                    Judgment__c judg = new Judgment__c();
                    judg.Current_Principal_Balance__c = (Decimal) aggRes.get('currentPrincipalBalance');
                    judg.Current_Interest_Balance__c = (Decimal) aggRes.get('currentInterestBalance');
                    judg.Judgment_Province__c = province;
                    judg.Placed_Province__c = province;
                    judg.Id = prodJudgmap.get((String) aggRes.get('Name'));

                    if (judgmentIdCompanyNameMap.containsKey(judg.Id)) {
                        judg.Company_Name__c = judgmentIdCompanyNameMap.get(judg.Id);
                    }
                    if (judgmentIdPurchaseEntityMap.containsKey(judg.Id)) {
                        judg.Plaintiff__c = judgmentIdPurchaseEntityMap.get(judg.Id);
                    }
                    judgUpdate.add(judg.Id);
                }
            }
            judgmentIds.removeAll(judgUpdate);
            for (Id judgId : judgmentIds) {
                Judgment__c judg = new Judgment__c();
                judg.Id = judgId;
                judg.Judgment_Province__c = province;
                judg.Placed_Province__c = province;
                judg.Plaintiff__c = plaintiff;
                judg.Current_Principal_Balance__c = null;
                judg.Current_Interest_Balance__c = null;
                judgList.add(judg);
            }
            if (judgList.size() > 0) {
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                configSetting.Send_Notification__c = false;
                update judgList;
                configSetting.Send_Notification__c = true;
            }
        }
    }

    //Bug: 5476 changes ends
     public static Map<String, Product__c> updatePlacementMainStatus(Set<id> productIds) {
         system.debug('productIds::'+productIds);
         Map<String, Product__c> prodPlacementStatusUpdate = new Map<String, Product__c>();
         
        for (Account_Judgment__c activeProductJudgment : [
            SELECT Judgment__c, Judgment__r.Legal_Status__c,Judgment__r.Legal_Sub_Status__c,
            Product__c,Product__r.Status__c,Product__r.Sub_Status__c,
            Product__r.Placement_Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :productIds AND Status__c = 'Active'
        ]) {
                if(activeProductJudgment.Product__r.Placement_Status__c != NULL  && 
                   !System.Label.Exclude_Judgment_Codes.contains(activeProductJudgment.Product__r.Placement_Status__c)){
                    Product__c prodUpdate = new product__c();
                if (mapAccountJudgmentCodes.containsKey(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)) {
                    prodUpdate.Status__c = mapAccountJudgmentCodes.get(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)
                        .Product_Status__c;
                }
                if (mapAccountJudgmentCodes.containsKey(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)) {
                    prodUpdate.Sub_Status__c = mapAccountJudgmentCodes.get(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)
                        .Product_Sub_status__c;
                }
                if (mapAccountJudgmentCodes.containsKey(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)) {
                    prodUpdate.Placement_Status__c = mapAccountJudgmentCodes.get(activeProductJudgment.Judgment__r.Legal_Status__c + activeProductJudgment.Judgment__r.Legal_Sub_Status__c)
                        .Codes__c;
                }
                prodPlacementStatusUpdate.put(activeProductJudgment.Product__c,prodUpdate);
            }
        }
        return prodPlacementStatusUpdate;
     }
     
     public static Map<String, Account_Judgment__c> inactiveAcctJudStatus(Map<String,String> prodAccJudgIds) {
         Map<String,Account_Judgment__c> mapAcctJudg = new Map<String,Account_Judgment__c>();
         for(String prodId : prodAccJudgIds.keyset()){
             Account_Judgment__c accJudgment = new Account_Judgment__c();
             accJudgment.id =  prodAccJudgIds.get(prodId);  
             accJudgment.Status__c = 'Inactive';
             mapAcctJudg.put(accJudgment.id,accJudgment);
         }


         return mapAcctJudg;
     }
}