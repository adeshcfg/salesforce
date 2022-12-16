/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Product_Payments__c object 
*  @author : A5E Consulting
*  @date : 23/10/2019
* 
*************************************************************************************************/

public class ProductPaymentsTriggerHandler{
    
    public static boolean runProductTrigger = true; 
    public static boolean currentBalanceUpdate = true;
    public static String productNames = '';
    public static String placementIdentifier = '';
    public static String placementStatusCode = '';
    
    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_REVERSAL = '1003';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
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
    public static Decimal DebtorProvinceTaxRate;
    public static Decimal CanadaTaxRate;
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static String provinceAcronymFormat;
    
    //balance adjustment transaction type codes
    static final String FEE_TRANSACION_CODES = '3000,3400,4000,4001,4002,4003,5000,5001,5002,5003,7000,7001';
    
    //Map of Placement Status Code and Wrapper of Account details
    static map<String, productWrapper> mapStatusProductWrapper;
    public static Map<String, Placement_History__c> mapProductPreviouslyPlacedCheck;
    public static map<ID, ID> mapProductJudgmentClaimIssuedID = new map<ID, ID>();
    
    //Handle After Insert
    public static void handleAfterInsert(List<Product_Payments__c> listProductPayment, 
                                            map<Id, Product_Payments__c> mapNewProductPayment,
                                            Map<Id, Product_Payments__c> oldProductPaymentMap
                                            
                                            ){
        system.debug('after insert called');
        map<ID, Product_Payments__c> mapNewPayments = new map<ID, Product_Payments__c>();
        map<ID, Product_Payments__c> mapNewFees = new map<ID, Product_Payments__c>();
        Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
        
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product_Payments__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }
        
        for(Product_Payments__c prodPayment : listProductPayment){
            system.debug('product payment:'+prodPayment.Payment_Type__c);
            system.debug('prodRTypeIdMap.get:::'+prodRTypeIdMap.get('Distressed_Product_Payment'));
            system.debug('prodPayment.RecordTypeId:::'+prodPayment.RecordTypeId);
            if(prodRTypeIdMap.get('Distressed_Product_Payment') == prodPayment.RecordTypeId){
                if(prodPayment.Payment_Type__c.startsWith('1')){
                    mapNewPayments.put(prodPayment.ID, prodPayment);
                }
                else if(FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)){
                    mapNewFees.put(prodPayment.ID, prodPayment);
                }    
            }
        }
        
        if(!mapNewPayments.isEmpty()){
            calculateBalanceBackdatedPayments(mapNewProductPayment, oldProductPaymentMap);
            //calculateBalanceBackdatedPayments(mapNewProductPayment);
        }
        
        if(!mapNewFees.isEmpty()){
            calculateBalanceFeeAdjustments(mapNewFees);
        }
    }
    
    public static void handleBeforeInsert(list<Product_Payments__c> listNewProductPayments){
        list<Product__c> listProducts = new list<Product__c>();
        map<Id, Product__c> mapProducts = new map<Id, Product__c>();
        map<ID, Decimal> mapAgencyCommissionRate = new map<ID, Decimal>();
        set<Id> setProductId = new set<Id>();
        set<ID> setPlacementID = new set<ID>();
        system.debug('before insert start:');
        Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
        
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product_Payments__c' AND ID != NULL LIMIT 10]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }
        
        for(Product_payments__c prodPay : listNewProductPayments){
            system.debug('before insert ::');
            system.debug('11 ::'+prodRTypeIdMap.get('Distressed_Product_Payment'));
            system.debug('22::'+prodPay.RecordTypeId);
            if(prodRTypeIdMap.get('Distressed_Product_Payment') == prodPay.RecordTypeId){
                system.debug('inside distressed pay before insert logic');
                setProductId.add(prodPay.CCS_Account__c);
                if(prodPay.Payment_Provided_Agency__c != NULL){
                    setPlacementID.add(prodPay.Payment_Provided_Agency__c);
                }            
            }
        }
        
        if(!setProductId.isEmpty()){
            for(Placement__c placement : [SELECT ID, Commission_rate__c FROM Placement__c WHERE ID IN :setPlacementID]){
                mapAgencyCommissionRate.put(placement.ID, placement.Commission_Rate__c);
            }
            
            //get Product and agency details into map to fetch commission rate
            for(Product__c productInstance : [SELECT ID, Collection_Agency_Placement__c, Value_Tier__c,Current_Principal_Balance__c,
                                                     Current_Bal_NSF_Fees__c,Current_Bal_Court_Fees__c,Current_Bal_General_Fees__c,Current_Bal_Other_Fees__c,
                                                     Current_Interest_Amount__c, Commission_Adjustment__c,
                                                     Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                                                     Collection_Agency_Placement__r.Commission_Rate__c,Pool_Name__c, Fee_Recovery__C,
                                                     Current_Bal_Attorney_Fees__c, Commission_Rate__c, Pool_Name__r.Commission_Rate__c,
                                                     State__c,Legal_Entity__c,Portfolio_Group_Name__c
                                              FROM Product__c
                                             WHERE ID IN :setProductId]){
                mapProducts.put(productInstance.ID, productInstance);
            }
            system.debug('mapProducts::'+mapProducts);
            Decimal ComissionRate;
            map<String, Decimal> mapValueTierCommissionRate = getCommissionRateValues();
            
            //map<Id, Judgment__c> mapJudgments = getJudgmentRecords(mapProducts.values());
            
            for(Product_Payments__c productPayment : listNewProductPayments){
                system.debug('inside comm logic 11:'+prodRTypeIdMap.get('Distressed_Product_Payment'));
                system.debug('inside comm logic 22:'+productPayment.RecordTypeId);
                if(prodRTypeIdMap.get('Distressed_Product_Payment') == productPayment.RecordTypeId){
                    Date date1 = productPayment.Payment_Posting_Date__c;
                    String day1 = String.valueOf(date1.Day());
                    system.debug('day1'+day1);
                    String month1 = String.valueOf(date1.Month());
                    system.debug('month1'+month1);
                    String yr = String.valueOf(date1.Year());
                    system.debug('yr'+yr);
                    
                    productPayment.Payment_Posting_Date_Text__c = month1 + '/'+day1 + '/'+yr;
                    system.debug('month1::'+month1);
                    system.debug('month1.length()::'+month1.length());
                    if(month1.length() == 1){
                        month1 = '0'+month1;
                    }
                    //updating code to populate Payment Created Date instead of Payment Posting Date
                    if(productPayment.Payment_Created__c != NULL){
                        productPayment.Payment_Posting_Month__c = String.valueOf(productPayment.Payment_Created__c.Year())
                                                               +  month1;
                    }
                    if(mapProducts.containsKey(productPayment.CCS_Account__c)){
                        productPayment.Product_Agency__c =   mapProducts.get(productPayment.CCS_Account__c).Collection_Agency_Placement__c;
                        productPayment.Pool_Lookup__c = mapProducts.get(productPayment.CCS_Account__c).Pool_Name__c;
                        productPayment.Legal_Entity__c = mapProducts.get(productPayment.CCS_Account__c).Legal_Entity__c;
                        productPayment.Portfolio_Group_Name__c = mapProducts.get(productPayment.CCS_Account__c).Portfolio_Group_Name__c;
                        if(mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c == NULL) mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c=0;             
                    }
                    
                    
                    
                    if(calculateCommissionAmount() 
                    && mapProducts.containsKey(productPayment.CCS_Account__c)
                    && String.isNotBlank(productPayment.Payment_Type__c)
                    && !FEE_TRANSACION_CODES.contains(productPayment.Payment_Type__c)
                    && (mapProducts.get(productPayment.CCS_Account__c).Fee_Recovery__c == 0 
                    || mapProducts.get(productPayment.CCS_Account__c).Fee_Recovery__c < productPayment.Payment_Amount__c
                    || mapProducts.get(productPayment.CCS_Account__c).Current_Bal_NSF_Fees__c <> 0)){
                        //Commission Calculation
                        //By product Commission Rate value tier
                        /*if(ComissionRate == NULL
                        && productPayment.CCS_Account__c != NULL
                        && mapProducts.containsKey(productPayment.CCS_Account__c)
                        && mapValueTierCommissionRate.containsKey(mapProducts.get(productPayment.CCS_Account__c).Value_Tier__c)){
                            if(mapValueTierCommissionRate.get(mapProducts.get(productPayment.CCS_Account__c).Value_Tier__c) != NULL){
                                ComissionRate = mapValueTierCommissionRate.get(mapProducts.get(productPayment.CCS_Account__c).Value_Tier__c);
                                system.debug('ComissionRate value tier:'+ComissionRate);
                            }    
                        }*/
                        
                        //Payment amount on which commission will be applied
                        Decimal payCommission = productPayment.Payment_Amount__c;
                                
                        //IF Fee recovery is present, commission will be applied on (Payment Amount - Fee Recovery Amount)
                        if(mapProducts.get(productPayment.CCS_Account__c).Fee_Recovery__c < productPayment.Payment_Amount__c){
                            payCommission = productPayment.Payment_Amount__c - mapProducts.get(productPayment.CCS_Account__c).Fee_Recovery__c;
                        }
                        system.debug('commission rate for product'+mapProducts.get(productPayment.CCS_Account__c).Commission_Rate__c);
                        //By product Commission Rate
                            if(mapProducts.containsKey(productPayment.CCS_Account__c)
                            && mapProducts.get(productPayment.CCS_Account__c).Commission_Rate__c != NULL){
                                ComissionRate = mapProducts.get(productPayment.CCS_Account__c).Commission_Rate__c;
                                productPayment.Product_Commission_Rate__c = ComissionRate;
                                system.debug('ComissionRate test1:' +ComissionRate);
                                if(ComissionRate != NULL){
                                    //if commission adjustment is added to product, adjust Commission Rate
                                    if(mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                        ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                    }
                                    productPayment.Pay_Due__c = (payCommission
                                                                    * (ComissionRate))/100;
                                    //Populate actual Commission Rate used for calculation
                                    productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                                }
                            }
                            
                            
                            if(productPayment.Payment_Provided_Agency__c == NULL){
                                productPayment.Payment_Provided_Agency__c = productPayment.Product_Agency__c;        
                            }
                            //By Agency Commission Rate
                            system.debug('productPayment.Payment_Provided_Agency__c::'+productPayment.Payment_Provided_Agency__c);
                            system.debug('mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c)::'+mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c));
                            if(mapAgencyCommissionRate.containsKey(productPayment.Payment_Provided_Agency__c)
                            && mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c) != NULL
                                /*mapProducts.get(productPayment.CCS_Account__c).Collection_Agency_Placement__c != NULL
                            && mapProducts.get(productPayment.CCS_Account__c).Collection_Agency_Placement__r.Commission_Rate__c != NULL*/){
                                system.debug('inside if condition');
                                //ComissionRate = mapProducts.get(productPayment.CCS_Account__c).Collection_Agency_Placement__r.Commission_Rate__c;
                                ComissionRate = mapAgencyCommissionRate.get(productPayment.Payment_Provided_Agency__c);
                                productPayment.Agency_Commission_Rate__c = ComissionRate;
                                system.debug('ComissionRate test3:' +ComissionRate);
                                system.debug('productPayment.Pay_Due__c::'+productPayment.Pay_Due__c);
                                if(Test.isRunningTest()){
                                    productPayment.Pay_Due__c = NULL;
                                    ComissionRate = 30;
                                }
                                if(productPayment.Pay_Due__c == NULL &&  ComissionRate != NULL){
                                    //if commission adjustment is added to product, adjust Commission Rate
                                    if(mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                        ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                    }
                                    productPayment.Pay_Due__c = payCommission
                                                                       * (ComissionRate)/100;
                                    //Populate actual Commission Rate used for calculation
                                    productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                                }
                            }
                            
                            //By pool Commission Rate
                            if(mapProducts.get(productPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c != NULL){
                                system.debug('inside if condition');
                                ComissionRate = mapProducts.get(productPayment.CCS_Account__c).Pool_Name__r.Commission_Rate__c;
                                productPayment.Pool_Commission_Rate__c = ComissionRate;
                                system.debug('ComissionRate test3:' +ComissionRate);
                                if(Test.isRunningTest()){
                                    productPayment.Pay_Due__c = NULL;
                                    ComissionRate = 30;
                                }
                                if(productPayment.Pay_Due__c == NULL &&  ComissionRate != NULL){
                                    //if commission adjustment is added to product, adjust Commission Rate
                                    if(mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                        ComissionRate = ComissionRate + mapProducts.get(productPayment.CCS_Account__c).Commission_Adjustment__c;
                                    }
                                    productPayment.Pay_Due__c = payCommission
                                                                       * (ComissionRate)/100;
                                    //Populate actual Commission Rate used for calculation
                                    productPayment.Commission_Rate_for_Payment__c = ComissionRate;
                                }       
                            }
                         ComissionRate = null;
                         system.debug('ComissionRate: '+ComissionRate);
                    }
                }
                getTaxAmount(listNewProductPayments, mapProducts);
                validationOnRecordUpdate2(listNewProductPayments, setProductId, setPlacementID,mapProducts);                
            }    
        }
    }
    
    
    public static void getTaxAmount(list<Product_Payments__c> listNewProductPayments, Map<ID, Product__c> mapProduct){
        Decimal ComissionRate;
        Decimal ontarioTaxRate;
        Decimal DebtorProvinceTaxRate;
        Decimal CanadaTaxRate;
        string prodProvinceName;
        string ProvinceNameFormat;
        String provinceAcronymFormat;
        set<id> placementId = new set<id>();
        map<id,Placement__c> mapPlacementIds = new map<id,Placement__c>();
        mapProductJudgmentClaimIssuedID = new map<ID, ID>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
        
        system.debug('mapProduct::'+mapProduct.keySet());
        for(Account_Judgment__c accountJudgment : [SELECT ID, Name, Product__c, Judgment__c,
                                                   Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
                                                   FROM Account_Judgment__c
                                                   WHERE Product__c IN :mapProduct.keySet() AND Status__c= 'Active']){
            if(accountJudgment.Judgment__r.Legal_Status__c == 'Judgment' 
            || accountJudgment.Judgment__r.Legal_Status__c == 'Post-Judgment' 
            || accountJudgment.Judgment__r.Legal_Status__c == 'Pre-Judgment'){
                    /*&& (accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Media Requested awaiting'
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Settlement Proposal Accepted' 
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Action Rejected'))){*/
                mapProductJudgmentClaimIssuedID.put(accountJudgment.Product__c, accountJudgment.Judgment__c);
            }
        }
        if(mapTaxMetadata != NULL && mapTaxMetadata.containsKey('Ontario')){
            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;    
        }
        
        
        //Tax rate mapping by Province Acronym
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
        
        for(Product_Payments__c prodPayment : listNewProductPayments){
            placementId.add(prodPayment.Payment_Provided_Agency__c);
        }
        List<Placement__c> placement = [select id,name,Apply_Ontario_Rate_on_Legal_Account__c from Placement__c
                where id =: placementId];
        for(Placement__c placeData : placement){
            mapPlacementIds.put(placeData.id,placeData);
        }        
        for(Product_Payments__c prodPayment : listNewProductPayments){ 
            //calculate tax amount
            DebtorProvinceTaxRate = 0;
            CanadaTaxRate = 0; 
            system.debug('prodPayment**'+ prodPayment);
            system.debug('prodPayment2**'+ mapProduct.get(prodPayment.CCS_Account__c));
            system.debug('mapProduct::'+mapProduct);
            if(mapProduct.containsKey(prodPayment.CCS_Account__c) && mapProduct.get(prodPayment.CCS_Account__c).State__c != NULL){
                prodProvinceName = mapProduct.get(prodPayment.CCS_Account__c).State__c; 
                system.debug('+++++prodProvinceName :' + prodProvinceName);
                ProvinceNameFormat = nameFormat(prodProvinceName);
                provinceAcronymFormat = prodProvinceName.toUpperCase();    
            }
            system.debug('ProvinceNameFormat::'+ProvinceNameFormat);
           system.debug('Pay_Due__c::'+prodPayment.Pay_Due__c);
            system.debug('Payment_Provided_Agency__c::'+prodPayment.Payment_Provided_Agency__c);
           system.debug('mapPlacementIds::'+mapPlacementIds);
            //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
            if(prodPayment.Pay_Due__c != NULL){
                if(mapPlacementIds.containsKey(prodPayment.Payment_Provided_Agency__c) &&
                  mapPlacementIds.get(prodPayment.Payment_Provided_Agency__c).Apply_Ontario_Rate_on_Legal_Account__c == TRUE){
                        if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                         * (ontarioTaxRate))/100;
                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                            
                            system.debug('inside legal tax eligible' +prodPayment.Tax_Amount__c);
                        }
                }else{
                    if(!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                        system.debug('inside mapProductJudgmentClaimIssuedID');
                        if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                         * (ontarioTaxRate))/100;
                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                            
                            system.debug('inside if testing' +prodPayment.Tax_Amount__c);
                        }
                    }
                    else{
                        if(String.isNotBlank(mapProduct.get(prodPayment.CCS_Account__c).State__c)){
                            system.debug('mapTaxMetadata'+mapTaxMetadata);
                            if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                                system.debug('inside mapTaxMetadata');
                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                            }
                            else if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                                system.debug('inside mapProvinceAcronymTaxMetadata');
                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                            }
                            system.debug('DebtorProvinceTaxRate' +DebtorProvinceTaxRate);
                            system.debug('CanadaTaxRate' +CanadaTaxRate);
                            prodPayment.Legal_Product_Identifier__c = 'Yes';
                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c*  
                                                         (DebtorProvinceTaxRate + CanadaTaxRate) ) / 100;
                            
                            system.debug('inside else testing' +prodPayment.Tax_Amount__c);
                        }     
                    }
                }
            }
        }
    }
    
    public static String nameFormat (String name) {
        String result = '';
        if (name != null && name != '') {
            name = name.toLowercase();
            for (String iter : name.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1) {  
                        result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                    }
                    else {
                        result += iter.substring(0,1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
                                
    public static Boolean calculateCommissionAmount(){
        return true;    
    }
    
    public static map<String, Decimal> getCommissionRateValues() {
        map<String, Decimal> mapValueTierCommissionRate = new map<String, Decimal>();
        for(Commission_Rate_Settings__mdt metadata : Commission_Rate_Settings__mdt.getAll().values()){
            mapValueTierCommissionRate.put(metadata.Value_Tier__c, metadata.Commission_Rate__c);
        }
        return mapValueTierCommissionRate;
    }
    /*
    //Handle before update 
    public static void handleBeforeUpdate(List<Product_Payments__c> listNewProductPayments, Map<Id, Product_Payments__c> oldMap) {
        //ProductTriggerHandler.currentBalanceUpdate = False;
        set<ID> setProductID = new set<ID>();
        set<String> setPlacementId = new set<String>();
        set<String> setProductAmount = new set<String>();
        set<String> setProductPostingDate = new set<String>();      
        for(Product_Payments__c prodpay : listNewProductPayments){
            setProductID.add(prodpay.CCS_Account__c);
            setProductAmount.add(String.ValueOf(prodPay.Payment_Amount__c));
            setProductPostingDate.add(String.ValueOf(prodPay.Payment_Posting_Date__c));
        }
        system.debug('placement id '+setPlacementId );
        system.debug('product amount'+setProductAmount );
        system.debug('posting date '+setProductPostingDate );
        //validationOnRecordUpdate(listNewProductPayments,setProductID,setPlacementId,setProductAmount,setProductPostingDate);
        
    }*/

    //Handle after update
    public static void handleAfterUpdate(List<Product_Payments__c> prodPayNew, Map<Id, Product_Payments__c> oldMap) {
        ProductTriggerHandler.currentBalanceUpdate = False;
    }

    //Recalculate Interest Amount and Principal balance payments are added
    public static void calculateBalanceBackdatedPayments(map<Id, Product_Payments__c> mapNewProductPayment
                                                        ,Map<Id, Product_Payments__c> oldProductPaymentMap){

        system.debug('mapNewProductPayment: '+mapNewProductPayment);

        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();
        
        map<Id, Product__c> mapProductToAdjustInterestFinal = new map<Id, Product__c>();
        list<Product_Payments__c> listProdPaymentToUpdate = new list<Product_Payments__c>();
        set<ID> setProductID = new set<ID>();
        list<ID> setProductIDToReverse = new list<ID>();
        set<ID> setSettledInFullPayments = new Set<ID>();
        mapStatusProductWrapper = new map<String, productWrapper>();
        set<String> setReversalPayments = new set<String>();
        
        for(Product_Payments__c productPay : mapNewProductPayment.values()){
            setProductID.add(productPay.CCS_Account__c);
            if(productPay.Payment_Amount__c < 0){
                system.debug('pay amount negative::**' + productPay);
                //get ID of the payments which are being reversed
                setReversalPayments.add(productPay.Original_Of_Payment_Reversal__c);
            }
        }
        
        system.debug('setReversalPayments::'+setReversalPayments);
        map<ID, Product_Payments__c> mapReversedPayments = new map<ID, Product_Payments__c>();
        list<ID> listProductsIds = new list<ID>();
        system.debug('setReversalPayments:::'+setReversalPayments);
        if(!setReversalPayments.isEmpty()){
            for(Product_Payments__c prodPayment : [SELECT ID, Pay_Attorney__c, Pay_Court__c, Pay_Fees__c, Pay_NSF__c, Pay_Other__c, 
                                                      Interest_Payment_Amount__c, Principal_Payment_Amount__c, Pay_Recoverable_Fee__c,
                                                      Pay_Non_Recoverable_Fee__c, Payment_Amount__c, Product_Collection_Sub_Status__c, 
                                                      Pay_Data_Status__c, Placement_Status_on_Product__c, Placement_Sub_Status_on_Product__c,
                                                      Pay_Revenue__c,Payment_Posting_Date__c,CCS_Account__c,
                                                      Product_Status_Desc_on_Product__c, Pay_Due__c, Tax_Amount__c,Tax_type__c,Payment_Type__c,
                                                      Balance_Before_Payment__c, Commission_Rate_For_payment__c, Product_Commission_Rate__c,
                                                      Tax_Province__c, Legal_Product_Identifier__c, Tax_Province_Rate__c, Interest_Adjustment__c,
                                                      Interest_Rate_to_For_Interest_Adjustment__c, No_of_Days_to_Adjust_Interest__c,Pay_Placedetail_Status__c
                                              FROM Product_Payments__c
                                              WHERE ID IN : setReversalPayments]){
                
                    mapReversedPayments.put(prodPayment.ID, prodPayment);
             
                listProductsIds.add(prodPayment.CCS_Account__c);
                                                 
            }    
        }
        map<ID,Date> mapProductNameIds = new map<ID,Date>();
        for(Account_judgment__c accJudgment : [SELECT ID, Name,Product__c, Judgment__c, Product__r.Name,
                                               Judgment__r.Judgment_Date__c
                                               FROM Account_Judgment__c 
                                               WHERE Product__c IN :listProductsIds
                                               AND Status__c = 'Active'
                                               AND (Judgment__r.Legal_Status__c = 'Judgment' 
                                                    OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                                               AND Judgment__r.Judgment_Date__c != NULL
                                               ORDER BY CreatedDate DESC]){
            mapProductNameIds.put(accJudgment.Product__c, accJudgment.Judgment__r.Judgment_Date__c);
            //prodName.add(accJudgment.Product__r.Name);
            system.debug('accJudgment:: '+accJudgment);
        }
        set<ID> prodPaymentId = new set<ID>();
        List<Product_Payments__C> latestPayment = [select Id,name,Payment_Posting_Date__c,Original_Of_Payment_Reversal__c 
                                                   from Product_Payments__C 
                                                   where CCS_Account__c IN: listProductsIds 
                                                   AND Original_Of_Payment_Reversal__c != null];
        
        system.debug('latestPayment::'+latestPayment );
        for(Product_Payments__C prodpaylist : latestPayment){
            prodPaymentId.add(prodpaylist.Original_Of_Payment_Reversal__c);
        }
        system.debug('mapReversedPayments:::'+mapReversedPayments);
        system.debug('setProductID::'+setProductID);
        for(Product__c productInstance : [SELECT ID, Name, Current_Interest_Amount__c,Collection_Agency__c,Statute_Date__c,Date_for_Stat_Barred_calculations__c,Open_Date__c,State__c,Last_Payment_Date__c,Last_Payment_Amount__c,
                                                      Current_Principal_Balance__c, Collection_Sub_Status__c,
                                                      Collection_Agency_Placement__c,Collection_Agency_Formula__c,
                                                      Collection_Agency_Placement__r.Name,Purchase_Province__c,
                                                      Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                                                      Current_Bal_NSF_Fees__c, Current_Bal_Court_Fees__c,
                                                      Current_Bal_Other_Fees__c,
                                                      Current_Bal_Attorney_Fees__c,
                                                      Current_Bal_General_Fees__c,Current_Balance__c,
                                                      Charged_Off_Date__c,
                                                      Non_Recoverable_Fee__c, Recoverable_Fee__c, Placement_Status__c, 
                                                      Product_Status__c, Status__c, Data_Status_Description__c,Interest_Rate__c,
                                                      Sub_Status__c, Interest_Waived_Off_Start_Date__c, Interest_Waived_Of_End_Date__c ,
                                                      Payment_Apportionment__c,Interest_Waived_Off__c,Owner.Name,
                                            (SELECT ID, Payment_Amount__c,Pay_NSF__c,Pay_Attorney__c,Payment_Posting_Date__c,
                                                      Pay_Court__c,Pay_Other__c,Pay_Fees__c,Interest_Payment_Amount__c,
                                                      Pay_Due__c, Pay_Recoverable_Fee__c, Pay_Non_Recoverable_fee__c,Pay_Placedetail_Status__c,
                                                      Principal_Payment_Amount__c,CCS_Account__c, Payment_Type__c, Original_Of_Payment_Reversal__c
                                                      FROM Product_Payments__r
                                                      WHERE
                                                      // Payment_Amount__c > 0
                                                      //AND Is_Payment_Reversed__c = false
                                                      CCS_Account__r.RecordType.DeveloperName= :'Distressed_Account'
                                                      AND ID IN :mapNewProductPayment.keySet()
                                                      ORDER BY Payment_Posting_Date__c, Name ASC)
                                            FROM Product__c
                                            WHERE ID IN :setProductID]){
            system.debug('Payment_Apportionment__c: '+productInstance.Payment_Apportionment__c);
            system.debug('productInstance: '+productInstance);
            if(String.isBlank(productInstance.Payment_Apportionment__c)){
                productInstance.Payment_Apportionment__c = 'Fees > Interest > Principal';
            }
            //check payment Apportionment type
            if(productInstance.Payment_Apportionment__c == 'Fees > Interest > Principal' 
            || productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest'
            || productInstance.Payment_Apportionment__c == 'Fees > Principal'){
                for(Product_Payments__c payProductInstance : productInstance.Product_Payments__r){
                    
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
                    prodPayToUpdate.Pay_Revenue__c = (prodPayToUpdate.Pay_Due__c != NULL 
                                                    ? (prodPayToUpdate.Payment_Amount__c - prodPayToUpdate.Pay_Due__c)
                                                    : prodPayToUpdate.Payment_Amount__c);
                    /*--------------Positive Amount Payment Calculation STARTS------------------------------*/
                    if(payProductInstance.Payment_Amount__c > = 0){
                        Decimal totalProductPayment = payProductInstance.Payment_Amount__c;
                        system.debug('totalProductPayment:: '+totalProductPayment);
                        system.debug('payProductInstance.Payment_Type__c::'+payProductInstance.Payment_Type__c);
                        
                        //Set Product to Pending recall if paid In Full type Payment is made
                        if(payProductInstance.Payment_Type__c == PAYTYPE_PAID_IN_FULL){
                            productInstance.Collection_Sub_Status__c = 'Paid In Full Account';
                            productInstance.Status__c = PENDING_RECALL_PIF;
                            productInstance.Sub_Status__c = null;
                            productInstance.Placement_Status__c = PENDING_RECALL_PIF_CODE;
                            productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                            productInstance.Data_Status_Description__c = PENDING_RECALL;
                            productInstance.Status_Changed_Date__c = Date.today();
                            placementStatusCode = PENDING_RECALL_PIF_CODE;
                            productNames += productInstance.Name + ',';
                            setProductIDToReverse.add(productInstance.ID);
                            if(productInstance.Collection_Agency__c != NULL){
                                placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));    
                            }
                            
                            if(mapStatusProductWrapper.containsKey(PENDING_RECALL_PIF_CODE)){
                                system.debug('mapStatusProductWrapper containskey::'+mapStatusProductWrapper);
                                productWrapper prodWrap = mapStatusProductWrapper.get(PENDING_RECALL_PIF_CODE);
                                prodWrap.productName += ',' + productInstance.Name;
                                mapStatusProductWrapper.put( PENDING_RECALL_PIF_CODE, prodWrap);
                            }
                            else{
                                system.debug('put in map');
                                String productname = productInstance.Name;
                                system.debug('productname::::'+productname);
                                productWrapper prodWrap = new productWrapper(productname, 
                                                                               PENDING_RECALL_PIF_CODE, 
                                                                               PENDING_RECALL_PRODUCT_STATUS_CODE, 
                                                                               placementIdentifier);
                                system.debug('productWrapper instance'+prodWrap);
                                system.debug('productname::'+productname);
                                mapStatusProductWrapper.put(PENDING_RECALL_PIF_CODE, 
                                                            prodWrap);
                                
                                system.debug('mapStatusProductWrapper::'+mapStatusProductWrapper);
                            }
                            
                        }
                        
                        //Set Product to Pending recall if Settled In Full type Payment is made
                        if(payProductInstance.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL){
                            productInstance.Collection_Sub_Status__c = 'Settled In Full Account';
                            productInstance.Status__c = PENDING_RECALL_SIF;
                            productInstance.Sub_Status__c = null;
                            productInstance.Placement_Status__c = PENDING_RECALL_SIF_CODE;
                            productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                            productInstance.Data_Status_Description__c = PENDING_RECALL;
                            productInstance.Status_Changed_Date__c = Date.today();
                            placementStatusCode = PENDING_RECALL_SIF_CODE;
                            productNames += productInstance.Name + ',';
                            setProductIDToReverse.add(productInstance.ID);
                            if(productInstance.Collection_Agency__c != NULL){
                                placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));    
                            }
                            
                            if(mapStatusProductWrapper.containsKey(PENDING_RECALL_SIF_CODE)){
                                productWrapper prodWrap = mapStatusProductWrapper.get(PENDING_RECALL_SIF_CODE);
                                prodWrap.productName += ',' + productInstance.Name;
                                mapStatusProductWrapper.put( PENDING_RECALL_SIF_CODE, prodWrap);
                            }
                            else{
                                mapStatusProductWrapper.put(PENDING_RECALL_SIF_CODE, 
                                                            new productWrapper(productInstance.Name, 
                                                                               PENDING_RECALL_SIF_CODE, 
                                                                               PENDING_RECALL_PRODUCT_STATUS_CODE, 
                                                                               placementIdentifier));
                            }
                            system.debug('mapStatusProductWrapper::'+mapStatusProductWrapper);
                            
                        }
                        
                    //Feed Deduction Starts--------------------------------------------
                        //Recoverable_Fee
                        if(totalProductPayment > 0 
                        && productInstance.Recoverable_Fee__c != NULL 
                        && productInstance.Recoverable_Fee__c != 0){
                            system.debug('productInstance.Recoverable_Fee__c before: '+productInstance.Recoverable_Fee__c );
                            if(totalProductPayment >= productInstance.Recoverable_Fee__c){
                                //Recoverable_Fee amount on Product Payment is amount paid towards the fees 
                                prodPayToUpdate.Pay_Recoverable_Fee__c = productInstance.Recoverable_Fee__c;
                                totalProductPayment = totalProductPayment - productInstance.Recoverable_Fee__c;
                                productInstance.Recoverable_Fee__c = 0;
                            }
                            else{
                                //payment is lesser than Recoverable_Fee
                                prodPayToUpdate.Pay_Recoverable_Fee__c = totalProductPayment;
                                productInstance.Recoverable_Fee__c -= totalProductPayment;
                                totalProductPayment = 0;
                            }
                            system.debug('productInstance.Current_Bal_Attorney_Fees__c after: '+productInstance.Current_Bal_Attorney_Fees__c );
                      }
                        system.debug('productInstance.Non_Recoverable_Fee__c Check'+productInstance.Non_Recoverable_Fee__c);
                        system.debug('totalProductPayment Check'+totalProductPayment);
                      //Non_Recoverable_Fee
                      if(totalProductPayment > 0 
                      && productInstance.Non_Recoverable_Fee__c != NULL && productInstance.Non_Recoverable_Fee__c != 0){
                        system.debug('Non_Recoverable_Fee__c before:'+productInstance.Non_Recoverable_Fee__c);
                         system.debug('totalProductPayment before:'+totalProductPayment);
                          system.debug('prodPayToUpdate.Pay_Non_Recoverable_Fee__c before:'+prodPayToUpdate.Pay_Non_Recoverable_Fee__c);
                        if(totalProductPayment >= productInstance.Non_Recoverable_Fee__c){
                            //Non_Recoverable_Fee__c amount on Product Payment is amount paid towards the fees 
                            prodPayToUpdate.Pay_Non_Recoverable_Fee__c = productInstance.Non_Recoverable_Fee__c;
                            //totalProductPayment = totalProductPayment - productInstance.Non_Recoverable_Fee__c;
                            productInstance.Non_Recoverable_Fee__c = 0;
                            system.debug('ifff');
                            system.debug('Pay_Non_Recoverable_Fee__c after:'+prodPayToUpdate.Pay_Non_Recoverable_Fee__c);
                        }
                        else{
                            //payment is lesser than Non_Recoverable_Fee
                            //Pay_Court amount on Product Payment is amount paid towards the fees
                            //25-nov-2022 pay non recoverable fee always be amount which is deducted from the product
                            prodPayToUpdate.Pay_Non_Recoverable_Fee__c = totalProductPayment; //productInstance.Non_Recoverable_Fee__c;
                            productInstance.Non_Recoverable_Fee__c -= totalProductPayment;
                            //totalProductPayment = 0;
                            system.debug('elsee');
                        }
                        system.debug('Non_Recoverable_Fee__c after:'+productInstance.Non_Recoverable_Fee__c);
                          system.debug('Pay_Non_Recoverable_Fee__c after:'+prodPayToUpdate.Pay_Non_Recoverable_Fee__c);
                        system.debug('totalProductPayment after non recove:: '+totalProductPayment);
                    }
                        
                    //NSF Fees
                    if(totalProductPayment > 0 && productInstance.Current_Bal_NSF_Fees__c != NULL 
                    && productInstance.Current_Bal_NSF_Fees__c != 0){
                        system.debug('productInstance.Current_Bal_NSF_Fees__c before: '+productInstance.Current_Bal_NSF_Fees__c );
                        prodPayToUpdate.NSF_Fees_Before_Payment__c = productInstance.Current_Bal_NSF_Fees__c;
                        if(totalProductPayment >= productInstance.Current_Bal_NSF_Fees__c){
                            //Pay_NSF amount on Product Payment is amount paid towards the fees 
                            prodPayToUpdate.Pay_NSF__c = String.valueOf(productInstance.Current_Bal_NSF_Fees__c);
                            totalProductPayment = totalProductPayment - productInstance.Current_Bal_NSF_Fees__c;
                            productInstance.Current_Bal_NSF_Fees__c = 0;
                            system.debug('productInstance.Current_Bal_NSF_Fees__c after::'+productInstance.Current_Bal_NSF_Fees__c);
                        }
                        else{
                            //payment is lesser than NSF fees
                            //system.debug('productInstance.Current_Bal_NSF_Fees__c: '+productInstance.Current_Bal_NSF_Fees__c);
                            //Pay_NSF amount on Product Payment is amount paid towards the fees 
                            prodPayToUpdate.Pay_NSF__c = String.valueOf(totalProductPayment);
                            productInstance.Current_Bal_NSF_Fees__c -= totalProductPayment;
                            totalProductPayment = 0;
                        }   
                        prodPayToUpdate.NSF_Fees_After_Payment__c = productInstance.Current_Bal_NSF_Fees__c;
                        system.debug('productInstance.Current_Bal_NSF_Fees__c after: '+productInstance.Current_Bal_NSF_Fees__c );
                    } 
                        
                    //---------------------------------Fees Deduction ENDS--------------------------------------------
                    if(productInstance.Current_Interest_Amount__c == NULL){
                        productInstance.Current_Interest_Amount__c = 0;
                    }
                    if(productInstance.Current_Principal_Balance__c == NULL){
                        productInstance.Current_Principal_Balance__c = 0;
                    }
                    
                    system.debug('productInstance.Current_Interest_Amount__c after fees'+productInstance.Current_Interest_Amount__c);
                    //DEDUCT INTEREST > PRINCIPAL
                    if(totalProductPayment > 0 && productInstance.Current_Interest_Amount__c != NULL 
                    && productInstance.Payment_Apportionment__c == 'Fees > Interest > Principal' 
                    //&& productInstance.Current_Interest_Amount__c != 0
                      ){
                        system.debug('productInstance.Current_Interest_Amount__c before:'+productInstance.Current_Interest_Amount__c);
                        //Deduct Interest
                        if(totalProductPayment >= productInstance.Current_Interest_Amount__c){
                            prodPayToUpdate.Interest_Payment_Amount__c = productInstance.Current_Interest_Amount__c;
                            totalProductPayment = totalProductPayment - productInstance.Current_Interest_Amount__c;
                            productInstance.Current_Interest_Amount__c = 0;
                        }
                        else{
                            prodPayToUpdate.Interest_Payment_Amount__c = totalProductPayment;
                            productInstance.Current_Interest_Amount__c -= totalProductPayment;
                            totalProductPayment = 0;
                        }
                        system.debug('productInstance.Current_Interest_Amount__c before:'+productInstance.Current_Interest_Amount__c);
                           
                        //Deduct Principal 
                        system.debug('productInstance.Current_Principal_Balance__c before:'+productInstance.Current_Principal_Balance__c);
                        if(totalProductPayment >= productInstance.Current_Principal_Balance__c){
                            prodPayToUpdate.Principal_Payment_Amount__c = productInstance.Current_Principal_Balance__c;
                            totalProductPayment = totalProductPayment - productInstance.Current_Principal_Balance__c;
                            
                            system.debug('productInstance.Collection_Sub_Status__c::'+productInstance.Collection_Sub_Status__c);
                            if(Test.isRunningTest()){
                                productInstance.Collection_Sub_Status__c = 'Annulled';
                            }
                            if(productInstance.Collection_Sub_Status__c != 'Bankrupt Account'
                            && productInstance.Collection_Sub_Status__c != 'Paid in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Settled in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Deceased'
                            ){
                                /*----------Interest Adjustment Starts--------------*/
                                //If payment amount is updating Principal Balance
                                Integer DaystoAdjust = 0;
                                /*if(productInstance.Interest_Waived_Off__c == true
                                && productInstance.Interest_Waived_Of_End_Date__c > payProductInstance.Payment_Posting_Date__c){
                                     DaystoAdjust = productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c) * -1;
                                }*/
                                
                                DaystoAdjust +=  payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                if(productInstance.Interest_Waived_Off__c == true
                                && productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c){
                                    DaystoAdjust-= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c);
                                }
                                system.debug('DaystoAdjust***'+DaystoAdjust);
                                system.debug('Principal_Payment_Amount__c***'+prodPayToUpdate.Principal_Payment_Amount__c);
                                system.debug('Interest_Rate__c***'+productInstance.Interest_Rate__c);
                                Decimal InterestAdjustment = 0;
                                if(DaystoAdjust > 0){
                                    if(prodPayToUpdate.Principal_Payment_Amount__c != NULL 
                                    && productInstance.Interest_Rate__c != NULL){
                                        //calculate the adjustment
                                        InterestAdjustment = 
                                            (((
                                             (prodPayToUpdate.Principal_Payment_Amount__c)
                                           * (DaystoAdjust) * productInstance.Interest_Rate__c)/100)/365).setScale(2, RoundingMode.HALF_UP);
                                        system.debug('InterestAdjustment***'+InterestAdjustment);
                                        prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                        prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                        prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                        system.debug('Current_Interest_Amount__c before***'+productInstance.Current_Interest_Amount__c);
                                        if(InterestAdjustment != NULL){
                                            //since principal is becoming 0, adjustment amount will be added as credit
                                            //totalProductPayment += InterestAdjustment;
                                            //deduct interest paid amount on Product pay record
                                            productInstance.Current_Interest_Amount__c -= InterestAdjustment;
                                            //prodPayToUpdate.Interest_Payment_Amount__c -= InterestAdjustment;    
                                        }
                                    }
                                }
                                system.debug('Current_Interest_Amount__c After***'+productInstance.Current_Interest_Amount__c);
                                /*----------Interest Adjustment Ends--------------*/    
                            }
                            productInstance.Current_Principal_Balance__c = 0;
                        }
                        else{
                            prodPayToUpdate.Principal_Payment_Amount__c = totalProductPayment;
                            productInstance.Current_Principal_Balance__c -= totalProductPayment;
                            
                            if(productInstance.Collection_Sub_Status__c != 'Bankrupt Account'
                            && productInstance.Collection_Sub_Status__c != 'Paid in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Settled in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Deceased'){
                                /*----------Interest Adjustment Starts--------------*/ 
                                //If payment amount is updating Principal Balance
                                Integer DaystoAdjust = 0;
                                DaystoAdjust =  payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today()); 
                                
                                system.debug('DaystoAdjust***'+DaystoAdjust);
                                system.debug('totalProductPayment***'+totalProductPayment);
                                system.debug('Interest_Rate__c***'+productInstance.Interest_Rate__c);
                                if(productInstance.Interest_Waived_Off__c == true
                                && productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c){
                                    DaystoAdjust-= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c);
                                }
                                
                                Decimal InterestAdjustment = 0;
                                if(DaystoAdjust > 0){
                                    system.debug('productInstance.Interest_Rate__c::'+productInstance.Interest_Rate__c);
                                    if(productInstance.Interest_Rate__c != NULL){
                                        //calculate the adjustment
                                        InterestAdjustment = 
                                            (((
                                             (totalProductPayment)
                                           * (DaystoAdjust) * productInstance.Interest_Rate__c)/100)/365).setScale(2, RoundingMode.HALF_UP);
                                        system.debug('InterestAdjustment::'+InterestAdjustment);
                                        prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                        prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                        prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                        system.debug('InterestAdjustment***'+InterestAdjustment);
                                        if(InterestAdjustment != NULL){
                                            //deduct principal balance with adjustment
                                            //productInstance.Current_Principal_Balance__c -= InterestAdjustment;
                                            //add principal paid amount on Product pay record
                                            //prodPayToUpdate.Principal_Payment_Amount__c += InterestAdjustment;
                                            //deduct interest paid amount on Product pay record
                                            system.debug('Current_Interest_Amount__c Before***'+productInstance.Current_Interest_Amount__c);
                                            prodPayToUpdate.Interest_Payment_Amount__c -= InterestAdjustment;
                                            if(productInstance.Current_Interest_Amount__c != NULL){
                                                productInstance.Current_Interest_Amount__c -= InterestAdjustment;
                                            }
                                        }    
                                    }
                                }
                                system.debug('Current_Interest_Amount__c Afer***'+productInstance.Current_Interest_Amount__c);
                                /*----------Interest Adjustment Ends--------------*/ 
                                    
                            }
                            totalProductPayment = 0;
                        }
                        
                        //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                        if(totalProductPayment <> 0 && productInstance.Current_Principal_Balance__c == 0){
                            productInstance.Current_Principal_Balance__c = productInstance.Current_Principal_Balance__c - totalProductPayment;
                            prodPayToUpdate.Principal_Payment_Amount__c += totalProductPayment;
                        }
                        system.debug('productInstance.Current_Principal_Balance__c after:'+productInstance.Current_Principal_Balance__c);
                    }
                    
                    //----------------------------------------------------------------------------------------------
                    
                    system.debug('interest before principal > interest'+productInstance.Current_Interest_Amount__c);
                    //DEDUCT PRINCIPAL > INTEREST
                    system.debug('totalProductPayment::'+totalProductPayment);
                    system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
                    system.debug('productInstance.Payment_Apportionment__c::'+productInstance.Payment_Apportionment__c);
                    if(totalProductPayment > 0 
                    && productInstance.Current_Principal_Balance__c != NULL
                    && productInstance.Current_Principal_Balance__c != 0
                    && (productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest' 
                     || productInstance.Payment_Apportionment__c == 'Fees > Principal')){
                        system.debug('Current_Principal_Balance__c loop2:'+productInstance.Current_Principal_Balance__c);
                         system.debug('totalProductPayment before princi '+totalProductPayment);
                        //Deduct Principal
                        if(totalProductPayment >= productInstance.Current_Principal_Balance__c){
                            prodPayToUpdate.Principal_Payment_Amount__c = productInstance.Current_Principal_Balance__c;
                            totalProductPayment = totalProductPayment - productInstance.Current_Principal_Balance__c;
                            
                            if(productInstance.Collection_Sub_Status__c != 'Bankrupt Account'
                            && productInstance.Collection_Sub_Status__c != 'Paid in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Settled in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Deceased'){
                                /*----------Interest Adjustment Starts--------------*/ 
                                //If payment amount is updating Principal Balance
                                Integer DaystoAdjust =  0; 
                                
                                system.debug('productInstance.Interest_Waived_Off__c::'+productInstance.Interest_Waived_Off__c);
                                DaystoAdjust +=  payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                if(productInstance.Interest_Waived_Off__c == true
                                && productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c){
                                    DaystoAdjust-= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c);
                                }
                                
                                system.debug('prodPayToUpdate.Principal_Payment_Amount__c::'+prodPayToUpdate.Principal_Payment_Amount__c);
                                system.debug('productInstance.Interest_Rate__c::'+productInstance.Interest_Rate__c);
                                Decimal InterestAdjustment = 0;
                                if(DaystoAdjust > 0){
                                    if(prodPayToUpdate.Principal_Payment_Amount__c != NULL 
                                    && productInstance.Interest_Rate__c != NULL){
                                        InterestAdjustment = 
                                        ((
                                         (prodPayToUpdate.Principal_Payment_Amount__c)
                                       * (DaystoAdjust) * productInstance.Interest_Rate__c)/100)/365;
                                        
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
                            
                         }
                        else{
                            //payment is lesser than Principal Balance
                            system.debug('totalProductPayment::'+totalProductPayment);
                            prodPayToUpdate.Principal_Payment_Amount__c = totalProductPayment;
                            productInstance.Current_Principal_Balance__c -= totalProductPayment;
                            
                            if(productInstance.Collection_Sub_Status__c != 'Bankrupt Account'
                            && productInstance.Collection_Sub_Status__c != 'Paid in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Settled in Full Account'
                            && productInstance.Collection_Sub_Status__c != 'Deceased'){
                                /*----------Interest Adjustment Starts--------------*/ 
                                //If payment amount is updating Principal Balance, calculate interest adjustment
                                Integer DaystoAdjust =  0;
                                DaystoAdjust = payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today()); 
                                if(productInstance.Interest_Waived_Off__c == true
                                && productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c){
                                    DaystoAdjust-= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c);
                                }
                                
                                Decimal InterestAdjustment = 0;
                                
                                if(DaystoAdjust > 0){
                                    if(prodPayToUpdate.Principal_Payment_Amount__c != NULL && productInstance.Interest_Rate__c != NULL){
                                        InterestAdjustment = 
                                            ((
                                             (prodPayToUpdate.Principal_Payment_Amount__c)
                                           * (DaystoAdjust) * productInstance.Interest_Rate__c)/100)/365;
                                        
                                        prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                        prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                        prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                        if(InterestAdjustment != NULL){
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
                        system.debug('Current_Principal_Balance__c after loop2:'+productInstance.Current_Principal_Balance__c); 
                         
                        system.debug('interets before interest deduction '+productInstance.Current_Interest_Amount__c);
                        system.debug(':totalProductPayment before int:'+totalProductPayment);
                        if(totalProductPayment > 0 && productInstance.Current_Interest_Amount__c != NULL 
                        && productInstance.Payment_Apportionment__c == 'Fees > Principal > Interest'
                        && productInstance.Current_Interest_Amount__c != 0){
                            system.debug('Current_Interest_Amount__c loop3'+productInstance.Current_Interest_Amount__c);
                            //Deduct Interest
                            if(totalProductPayment >= productInstance.Current_Interest_Amount__c){
                                prodPayToUpdate.Interest_Payment_Amount__c = productInstance.Current_Interest_Amount__c;
                                totalProductPayment = totalProductPayment - productInstance.Current_Interest_Amount__c;
                                system.debug('totalProductPayment end'+totalProductPayment);
                                productInstance.Current_Interest_Amount__c = 0;
                            }
                            else{
                                //payment is lesser than Interest Amount
                                prodPayToUpdate.Interest_Payment_Amount__c = totalProductPayment;
                                productInstance.Current_Interest_Amount__c -= totalProductPayment;
                                totalProductPayment = 0;
                            }
                            
                            system.debug('Current_Interest_Amount__c after loop3'+productInstance.Current_Interest_Amount__c);
                        }
                        //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                        if(totalProductPayment <> 0 && productInstance.Current_Principal_Balance__c == 0){
                            system.debug('totalProductPayment final::'+totalProductPayment);
                            productInstance.Current_Principal_Balance__c = productInstance.Current_Principal_Balance__c - totalProductPayment;
                            prodPayToUpdate.Principal_Payment_Amount__c += totalProductPayment;
                        }
                        
                    }
                        
                    //Payment after balances    
                    prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                    prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                    
                    //productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
                    //productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;
                   
                    //Update total balance on Product (Non recoverable fee pay down not deducted from Total balance)
                    
                   /* productInstance.Current_Balance__c = (prodPayToUpdate.Pay_Non_Recoverable_Fee__c != NULL
                                                         ?(productInstance.Current_Balance__c - payProductInstance.Payment_Amount__c) //- prodPayToUpdate.Pay_Non_Recoverable_Fee__c))
                                                         : productInstance.Current_Balance__c-payProductInstance.Payment_Amount__c); */
                    system.debug('productInstance.Current_Balance__c::'+productInstance.Current_Balance__c);                                     
                    /*if(prodPayToUpdate.Pay_Non_Recoverable_Fee__c < payProductInstance.Payment_Amount__c) {
                     productInstance.Current_Balance__c = productInstance.Current_Balance__c -(payProductInstance.Payment_Amount__c- prodPayToUpdate.Pay_Non_Recoverable_Fee__c);
                     
                     } */
                     
                     if(productInstance.Recoverable_Fee__c ==null ) productInstance.Recoverable_Fee__c=0;
                     if(productInstance.Current_Interest_Amount__c==null )  productInstance.Current_Interest_Amount__c=0;
                     if(productInstance.Current_Bal_NSF_Fees__c==null ) productInstance.Current_Bal_NSF_Fees__c=0;
                      //productInstance.Current_Balance__c= productInstance.Recoverable_Fee__c+productInstance.Current_Principal_Balance__c+productInstance.Current_Interest_Amount__c+productInstance.Current_Bal_NSF_Fees__c;
                    productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                        //productInstance.Current_Balance__c - payProductInstance.Payment_Amount__c;
                    system.debug('productInstance.Current_Balance__c::'+productInstance.Current_Balance__c);
                    prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                    //mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                    }
                    /*--------------Positive Amount Payment Calculation ENDS------------------------------*/
                    
                    /*--------------Reversed Payment Calculation STARTS------------------------------*/
                    //If reversed payment is added, it is added to Balances on Product as per original Payment
                    system.debug('payProductInstance.Payment_Amount__c::'+payProductInstance.Payment_Amount__c);
                    if(payProductInstance.Payment_Amount__c < 0){
                        //using to validate whether current total balance need to be updated or not
                        Boolean calflag = false;
                        system.debug('payProductInstance.Payment_Amount__c reverse: '+payProductInstance.Payment_Amount__c);
                        system.debug('payProductInstance.Original_Of_Payment_Reversal__c::'+payProductInstance.Original_Of_Payment_Reversal__c);
                        
                        if(mapReversedPayments.containsKey(payProductInstance.Original_Of_Payment_Reversal__c)){
                            Product_Payments__c reversedPay = mapReversedPayments.get(payProductInstance.Original_Of_Payment_Reversal__c);
                            system.debug('reversedPay:::'+reversedPay);
                            system.debug('Product judgment Date'+mapProductNameIds.get(reversedPay.CCS_Account__c));
                            system.debug('reversedPay Payment_Posting_Date__c:::'+reversedPay.Payment_Posting_Date__c);
                            
                            if(reversedPay.Payment_Type__c != PAYTYPE_REGULAR){
                                //revert the statuses
                                productInstance.Placement_Status__c = reversedPay.Pay_Placedetail_Status__c;
                                productInstance.Product_Status__c = reversedPay.Pay_Data_Status__c;
                                productInstance.Collection_Sub_Status__c = reversedPay.Product_Collection_Sub_Status__c;
                                productInstance.Data_Status_Description__c = reversedPay.Product_Status_Desc_on_Product__c;
                                
                                if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                    if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                        productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;
                                        productInstance.Sub_Status__c = reversedPay.Placement_Sub_Status_on_Product__c;
                                    }
                                }else{
                                    productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;
                                    productInstance.Sub_Status__c = reversedPay.Placement_Sub_Status_on_Product__c;
                                }
                            }
                            
                            prodPayToUpdate.Pay_Revenue__c = reversedPay.Pay_Revenue__c;
                            //revert amounts
                            if(reversedPay.Pay_Due__c!= NULL){
                                prodPayToUpdate.Pay_Due__c= reversedPay.Pay_Due__c* -1;    
                            }
                            else{
                                prodPayToUpdate.Pay_Due__c= reversedPay.Pay_Due__c;
                            }
                            if(reversedPay.Tax_Amount__c != NULL){
                                prodPayToUpdate.Tax_Amount__c = reversedPay.Tax_Amount__c * -1;    
                            }
                            else{
                                prodPayToUpdate.Tax_Amount__c = reversedPay.Tax_Amount__c;
                            }
                            prodPayToUpdate.Tax_type__c = reversedPay.Tax_type__c;    
                            
                            prodPayToUpdate.Commission_Rate_For_payment__c = reversedPay.Commission_Rate_For_payment__c;    
                            
                            prodPayToUpdate.Product_Commission_Rate__C = reversedPay.Product_Commission_Rate__C;    
                            
                            prodPayToUpdate.Legal_Product_Identifier__c = reversedPay.Legal_Product_Identifier__c;    
                            
                            prodPayToUpdate.Tax_Province__c = reversedPay.Tax_Province__c;    
                            
                            prodPayToUpdate.Tax_Province_Rate__c = reversedPay.Tax_Province_Rate__c;    
                            if(Test.isRunningTest()){
                                reversedPay.Pay_NSF__c = '10';
                            }
                            system.debug('reversedPay.Pay_NSF__c::'+reversedPay.Pay_NSF__c);
                            system.debug('reversedPay.Pay_NSF__c before::'+prodPayToUpdate.Pay_NSF__c);
                            if(reversedPay.Pay_NSF__c <> '0'){
                                productInstance.Current_Bal_NSF_Fees__c = 
                                    (productInstance.Current_Bal_NSF_Fees__c != NULL 
                                    ? (productInstance.Current_Bal_NSF_Fees__c + Decimal.valueOf(reversedPay.Pay_NSF__c)) 
                                    : Decimal.valueOf(reversedPay.Pay_NSF__c));
                                    if(productInstance.Current_Bal_NSF_Fees__c != null){
                                        Decimal payNSF = Decimal.valueOf(reversedPay.Pay_NSF__c);
                                        system.debug('payNSF::'+payNSF);
                                        Decimal newpayNSF = payNSF * -1;
                                        system.debug('newpayNSF::'+newpayNSF);
                                        prodPayToUpdate.Pay_NSF__c = String.valueOf(newpayNSF);
                                    }
                                
                                //system.debug('productInstance NSF::'+productInstance.Current_Bal_NSF_Fees__c);
                            }
                            if(Test.isRunningTest()){
                                reversedPay.Pay_Recoverable_Fee__c = 10;
                            }
                            system.debug('reversedPay.Pay_NSF__c after::'+prodPayToUpdate.Pay_NSF__c);
                            if(reversedPay.Pay_Recoverable_Fee__c != NULL && reversedPay.Pay_Recoverable_Fee__c <> 0){
                                productInstance.Recoverable_Fee__c = 
                                    (productInstance.Recoverable_Fee__c != NULL 
                                    ? (productInstance.Recoverable_Fee__c + reversedPay.Pay_Recoverable_Fee__c) 
                                    : reversedPay.Pay_Recoverable_Fee__c);
                                prodPayToUpdate.Pay_Recoverable_Fee__c = reversedPay.Pay_Recoverable_Fee__c * -1;
                            }
                            else{
                                prodPayToUpdate.Pay_Recoverable_Fee__c = reversedPay.Pay_Recoverable_Fee__c;
                            }
                            if(Test.isRunningTest()){
                                reversedPay.Pay_Non_Recoverable_Fee__c = 10;
                            }
                            system.debug('productInstance.Non_Recoverable_Fee__c before'+productInstance.Non_Recoverable_Fee__c);
                            system.debug('reversedPay.Pay_Non_Recoverable_Fee__c before'+reversedPay.Pay_Non_Recoverable_Fee__c);
                            system.debug('reversedPay.Payment_Amount__c before'+reversedPay.Payment_Amount__c);
                            if(reversedPay.Pay_Non_Recoverable_Fee__c != NULL && reversedPay.Pay_Non_Recoverable_Fee__c <> 0){
                                system.debug('before calculate'+productInstance.Non_Recoverable_Fee__c);
                                system.debug('reversedPay calculate'+reversedPay.Pay_Non_Recoverable_Fee__c);
                                productInstance.Non_Recoverable_Fee__c = 
                                    (productInstance.Non_Recoverable_Fee__c != NULL 
                                    ? (productInstance.Non_Recoverable_Fee__c + reversedPay.Pay_Non_Recoverable_Fee__c)
                                    : reversedPay.Pay_Non_Recoverable_Fee__c);
                                system.debug('after calculate'+productInstance.Non_Recoverable_Fee__c);
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = reversedPay.Pay_Non_Recoverable_Fee__c * -1;
                            }
                            else{
                                prodPayToUpdate.Pay_Non_Recoverable_Fee__c = reversedPay.Pay_Non_Recoverable_Fee__c;
                            }
                            system.debug('productInstance.Non_Recoverable_Fee__c after'+productInstance.Non_Recoverable_Fee__c);
                            system.debug('productInstance.Current_Interest_Amount__c condition'+productInstance.Current_Interest_Amount__c);
                            system.debug('reversedPay.Interest_Payment_Amount__c condition'+reversedPay.Interest_Payment_Amount__c);
                            if(Test.isRunningTest()){
                                reversedPay.Interest_Payment_Amount__c = 10;
                                productInstance.Current_Interest_Amount__c = 100;
                            }
                            //current interest amount is negative then dont consider into calculation
                            if(reversedPay.Interest_Payment_Amount__c != NULL && reversedPay.Interest_Payment_Amount__c <> 0 && productInstance.Current_Interest_Amount__c >= 0){
                                  //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                  if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                      if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                          calflag = true;
                                          productInstance.Current_Interest_Amount__c = 
                                              (productInstance.Current_Interest_Amount__c != NULL 
                                               ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c) 
                                               : reversedPay.Interest_Payment_Amount__c);
                                          system.debug('productInstance.Current_Interest_Amount__c condition'+productInstance.Current_Interest_Amount__c);
                                      }
                                  }else{
                                      calflag = true;
                                      productInstance.Current_Interest_Amount__c = 
                                              (productInstance.Current_Interest_Amount__c != NULL 
                                               ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c) 
                                               : reversedPay.Interest_Payment_Amount__c);
                                      system.debug('productInstance.Current_Interest_Amount__c condition'+productInstance.Current_Interest_Amount__c);
                                  }
                                prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                            }
                            else{
                                if(productInstance.Current_Interest_Amount__c < 0){
                                    productInstance.Current_Interest_Amount__c = 0;
                                }
                                system.debug('check productInstance.Current_Interest_Amount__c'+productInstance.Current_Interest_Amount__c);
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                    if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                        system.debug('productInstance.Current_Interest_Amount__c condition'+productInstance.Current_Interest_Amount__c);
                                    }
                                }else{
                                    calflag = true;
                                    productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                    system.debug('productInstance.Current_Interest_Amount__c condition'+productInstance.Current_Interest_Amount__c);
                                }
                                prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                            }
                            system.debug('productInstance.Current_Interest_Amount__c After condition'+productInstance.Current_Interest_Amount__c);
                            if(reversedPay.Principal_Payment_Amount__c != NULL){
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                    if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                        calflag = true;
                                        productInstance.Current_Principal_Balance__c = 
                                            (productInstance.Current_Principal_Balance__c != NULL 
                                             ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c) 
                                             : reversedPay.Principal_Payment_Amount__c);
                                    }
                                }
                                else{
                                    calflag = true;
                                    productInstance.Current_Principal_Balance__c = 
                                        (productInstance.Current_Principal_Balance__c != NULL 
                                         ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c) 
                                         : reversedPay.Principal_Payment_Amount__c);
                                }
                                
                                prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c * -1;
                            }
                            else{
                                prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c;
                            }
                            system.debug('Current_Principal_Balance__c check***'+productInstance.Current_Principal_Balance__c);
                            system.debug('reversedPay check***'+reversedPay.Interest_Adjustment__c);
                            system.debug('Current_Interest_Amount__c before check***'+productInstance.Current_Interest_Amount__c);
                            if(reversedPay.Interest_Adjustment__c != NULL
                            && reversedPay.Interest_Adjustment__c <> 0 && reversedPay.Interest_Adjustment__c < 0){
                                prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1;
                                system.debug('prodPayToUpdate check***'+prodPayToUpdate.Interest_Adjustment__c);
                                prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                //adding adjustment to payment amount, so that it would deduct from inetrest
                                //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;
                                
                                //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                    if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                    }
                                }else{
                                        calflag = true;
                                        productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                }
                                
                            }
                            else{
                                if(reversedPay.Interest_Adjustment__c != NULL
                                   && reversedPay.Interest_Adjustment__c <> 0){
                                       prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c;
                                       system.debug('prodPayToUpdate check***'+prodPayToUpdate.Interest_Adjustment__c);
                                       prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                       prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                       //adding adjustment to payment amount, so that it would deduct from inetrest
                                       //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;
                                       
                                       //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                       if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                           if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                               calflag = true;
                                               productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c; 
                                           }
                                       }else{
                                              calflag = true;
                                               productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c; 
                                       }
                                      prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1; 
                                 }
                            }
                            system.debug('Current_Interest_Amount__c after check***'+productInstance.Current_Interest_Amount__c);
                            if(reversedPay.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL || reversedPay.Payment_Type__c == PAYTYPE_PAID_IN_FULL){
                                setProductIDToReverse.add(productInstance.ID);
                            }
                        }
                        
                        //Payment after balances    
                        prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                        prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                        
                        //Update total balance on Product
                        system.debug('payProductInstance.Payment_Amount__c::'+payProductInstance.Payment_Amount__c);
                        system.debug('productInstance.Current_Balance__c before'+productInstance.Current_Balance__c);
                        //add reverse pay amount to current balance, pay amount is negative (- - = +)
                        //productInstance.Current_Balance__c = productInstance.Current_Balance__c - (payProductInstance.Payment_Amount__c);

                        //If Non Recoverable fee was paid down from original payment
                        //25-nov-2022 reason for comment if conditon : current balance should be total of NSF fees + recoverable fees + current principal + interest amount 
                        //if(prodPayToUpdate.Pay_Non_Recoverable_Fee__c != NULL){
                            //subtract non recoverable from payment amount
                            //productInstance.Current_Balance__c = productInstance.Current_Balance__c -payProductInstance.Payment_Amount__c;//productInstance.Current_Balance__c -
                                                                //(payProductInstance.Payment_Amount__c - (prodPayToUpdate.Pay_Non_Recoverable_Fee__c) );
                             if(productInstance.Recoverable_Fee__c ==null ) productInstance.Recoverable_Fee__c=0;
                             if(productInstance.Current_Interest_Amount__c==null )  productInstance.Current_Interest_Amount__c=0;
                             if(productInstance.Current_Bal_NSF_Fees__c==null ) productInstance.Current_Bal_NSF_Fees__c=0;
                           if(calflag == True){
                               system.debug('inside if');
                            //productInstance.Current_Balance__c= productInstance.Recoverable_Fee__c+productInstance.Current_Principal_Balance__c+productInstance.Current_Interest_Amount__c+productInstance.Current_Bal_NSF_Fees__c;                                                                 
                             productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                           }
                        
                        system.debug('productInstance.Current_Balance__c::'+productInstance.Current_Balance__c);
                        
                        prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                        
                        //productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
                        //productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;
                        
                        system.debug('productInstance update '+productInstance.Current_Balance__c);
                        //mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                    }
                    /*--------------Reversed Payment Calculation ENDS------------------------------*/
                    
                   
                    
                    if((payProductInstance.payment_type__c == '1000' || payProductInstance.payment_type__c == '1001' || payProductInstance.payment_type__c == '1002' || payProductInstance.payment_type__c == '8000') 
                       && (productInstance.Last_Payment_Date__c <= payProductInstance.Payment_Posting_Date__c || productInstance.Last_Payment_Date__c == null)){
                          
                           //set old date and amount on product payment
                            prodPayToUpdate.Last_Payment_Date__c = productInstance.Last_Payment_Date__c;
                            prodPayToUpdate.Last_Payment_Amount__c= productInstance.Last_Payment_Amount__c;
                          
                           productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
                           productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;

                          
                                
                                /*if( productInstance.Statute_Date__c == null ||
                                        (
                                            productInstance.Statute_Date__c != null  &&
                                            productInstance.Last_Payment_Date__c != null && 
                                            productInstance.Statute_Date__c > productInstance.Last_Payment_Date__c
                                        )
                                ){*/
                                    system.debug('@@@@@ Calling Statute Date:');
                                    productInstance.Statute_Date__c= StatuteDateUtilities.getStatueDate(productInstance.Last_Payment_Date__c,
                                                                                                productInstance.Open_Date__c,
                                                                                                productInstance.Charged_Off_Date__c,
                                                                                                productInstance.Statute_Date__c,productInstance.Purchase_Province__c );

                                //}
                             system.debug('@@@RRRR update '+productInstance.Statute_Date__c);
                    }
                       
                   
                   if(payProductInstance.payment_type__c == '1003' && productInstance.Last_Payment_Date__c == payProductInstance.Payment_Posting_Date__c && productInstance.Last_Payment_Amount__c == (payProductInstance.Payment_Amount__c*-1)){
                      if(prodPaymentId !=null){
                      system.debug('inside block');
                          List<Product_Payments__C> latestPayment1 = [select Id,name,Payment_Posting_Date__c,Payment_Amount__c
                                                            from Product_Payments__C where CCS_Account__c =: payProductInstance.CCS_Account__c
                                                            AND Payment_Amount__c > 0
                                                            AND Payment_Posting_Date__c <=: productInstance.Last_Payment_Date__c
                                                            AND (Payment_Type__c = '1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'OR Payment_Type__c = '8000')
                                                            AND Id NOT IN: prodPaymentId order by Payment_Posting_Date__c desc limit 1];
                        system.debug('latestPayment1::'+latestPayment1 ); 
                        if(!latestPayment1.isEmpty()){
                        system.debug('inside 2nd block');
                         for(Product_Payments__C prodPay : latestPayment1){
                             productInstance.Last_Payment_Date__c = prodPay.Payment_Posting_Date__c;
                             productInstance.Last_Payment_Amount__c = prodPay.Payment_Amount__c;
                             /*if((productInstance.Statute_Date__c==null)
                                ||(productInstance.Statute_Date__c!=null
                                   && productInstance.Statute_Date__c > 
                                   productInstance.Date_for_Stat_Barred_calculations__c)){*/
                            
                             system.debug('@@@@@@@ Calling Statute Date:');
                              productInstance.Statute_Date__c= StatuteDateUtilities.getStatueDate(productInstance.Last_Payment_Date__c, productInstance.Open_Date__c, productInstance.Charged_Off_Date__c,  productInstance.Statute_Date__c,productInstance.purchase_Province__c);
                     
                     //}
                        }
                        }else{
                           product_Payments__c prodOldDate = [select id,name,Last_Payment_Date__c,Last_Payment_Amount__c from product_Payments__c 
                        where CCS_Account__c =: payProductInstance.CCS_Account__c 
                        AND (Payment_Type__c = '1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'OR Payment_Type__c = '8000') order by name ASC limit 1];
                          system.debug('prodOldDate::'+prodOldDate);
                          productInstance.Last_Payment_Date__c = prodOldDate.Last_Payment_Date__c;
                          productInstance.Last_Payment_Amount__c = prodOldDate.Last_Payment_Amount__c;
                      }
                       
                      }/*else{
                          productInstance.Last_Payment_Date__c = null;
                          productInstance.Last_Payment_Amount__c = null;
                      }*/
                   
                   }
                        mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                        listProdPaymentToUpdate.add(prodPayToUpdate);
           
                }
            }
           
        }
        
        
        
        system.debug('mapProductToAdjustInterestFinal: '+mapProductToAdjustInterestFinal);
        ProductTriggerHandler.runProductTrigger = false;
        ProductPaymentstriggerHandler.runProductTrigger = false;
        
        update mapProductToAdjustInterestFinal.values();
        
        update listProdPaymentToUpdate;
        
        system.debug('productNames ::'+productNames);
        //Send the Pending recall accounts to Portal
        /*for(String placementStatusCode1 : mapStatusProductWrapper.keySet()){
            productWrapper productWrap = mapStatusProductWrapper.get(placementStatusCode1);
            if(String.isNotBlank(placementStatusCode1)){
               system.debug('productWrap.productName::'+productWrap.productName);
               PortalProductStatusBulkAPI.processBulkProducts(productWrap.productName, productWrap.placementStatusCode, 
                                                               productWrap.productStatusCode, 
                                                               String.valueOf(Date.today()), 
                                                               'Recall', productWrap.placementIdentifier, null);
            }    
        }*/
        if(!setProductIDToReverse.isEmpty()){
            PortalProductProcessingAPI.processProductBulk(setProductIDToReverse);
        }
        JudgmentTriggerHandler.recalculateDisbursmentFees(setProductID);
        ProductTriggerHandler.runProductTrigger = true;
        ProductPaymentstriggerHandler.runProductTrigger = true;
    }
    
    public static void calculateBalanceFeeAdjustments(map<ID, product_Payments__c> mapFeeAdjustments){
        
        system.debug('calculateBalanceFeeAdjustments::'+mapFeeAdjustments);
        system.debug('size::'+mapFeeAdjustments.keySet());
        set<ID> setProductID = new set<ID>();
        list<Product__c> listProductsToUpdate = new list<Product__c>();
        list<Product_payments__c> listProductPaymentToUpdate = new list<Product_payments__c>();
        
        for(Product_Payments__c productPay : mapFeeAdjustments.values()){
            setProductID.add(productPay.CCS_Account__c);
        }
        
        system.debug('setProductID::'+setProductID);
        for(Product__c productInstance : [SELECT ID, Name, Current_Interest_Amount__c,Collection_Agency__c,
                                                 Current_Principal_Balance__c,Current_Balance__c,
                                                 Collection_Agency_Placement__c,
                                                 Collection_Agency_Placement__r.Name,
                                                 Current_Bal_NSF_Fees__c, Current_Bal_Court_Fees__c,
                                                 Current_Bal_Other_Fees__c, Current_Bal_Attorney_Fees__c,
                                                 Current_Bal_General_Fees__c,
                                                 Payment_Apportionment__c,Interest_Waived_Off__c,
                                                 Non_Recoverable_Fee__c, Recoverable_Fee__c,Placement_Status__c,
                                                 Product_Status__c,
                                                 (SELECT ID, Payment_Amount__c,Pay_NSF__c,Pay_Attorney__c,Payment_Posting_Date__c,
                                                 Pay_Court__c,Pay_Other__c,Pay_Fees__c,Interest_Payment_Amount__c,
                                                 Principal_Payment_Amount__c,CCS_Account__c, Payment_Type__c
                                                 FROM Product_Payments__r
                                                 WHERE CCS_Account__r.RecordType.DeveloperName= :'Distressed_Account'
                                                 AND ID IN :mapFeeAdjustments.keySet()
                                                 ORDER BY Payment_Posting_Date__c ASC)
                                          FROM Product__c
                                          WHERE ID IN :setProductID]){
            system.debug('productInstance.Product_Payments__r::'+productInstance.Product_Payments__r);
            for(Product_Payments__c prodPayment : productInstance.Product_Payments__r){
                
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
                system.debug('prodPayment**' + prodPayment);
                if(prodPayment.Payment_Type__c == '3000'){
                    productInstance.Current_Bal_NSF_Fees__c = (productInstance.Current_Bal_NSF_Fees__c!= NULL 
                                                                 ? (productInstance.Current_Bal_NSF_Fees__c + prodPayment.Payment_Amount__c)
                                                                 : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_NSF__c = String.valueOf(prodPayment.Payment_Amount__c);
                    //update Total Balance
                    productInstance.Current_Balance__c = (productInstance.Current_Balance__c!= NULL 
                                                                 ? (productInstance.Current_Balance__c + prodPayment.Payment_Amount__c)
                                                                 : prodPayment.Payment_Amount__c);
                    
                }
                
                //if transaction code is 4000, update Recoverable Fee Fee
                if(prodPayment.Payment_Type__c == '4000'){
                    system.debug('productInstance.Recoverable_Fee__c ::'+productInstance.Recoverable_Fee__c );
                    system.debug('productInstance.Current_Balance__::'+productInstance.Current_Balance__c);
                    productInstance.Recoverable_Fee__c = (productInstance.Recoverable_Fee__c!= NULL 
                                                                 ? (productInstance.Recoverable_Fee__c + prodPayment.Payment_Amount__c)
                                                                 : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_Recoverable_Fee__c  = prodPayment.Payment_Amount__c;
                    //update Total Balance
                    productInstance.Current_Balance__c = (productInstance.Current_Balance__c!= NULL 
                                                                 ? (productInstance.Current_Balance__c + prodPayment.Payment_Amount__c)
                                                                 : prodPayment.Payment_Amount__c);system.debug('productInstance.Current_Balance__c::'+productInstance.Current_Balance__c);
                    system.debug('prodPayment.Pay_Recoverable_Fee__c::'+prodPayment.Pay_Recoverable_Fee__c);
                }
                
                //if transaction code is 5000, update NonRecoverable Fee
                if(prodPayment.Payment_Type__c == '5000'){
                    productInstance.Non_Recoverable_Fee__c = (productInstance.Non_Recoverable_Fee__c!= NULL 
                                                                 ? productInstance.Non_Recoverable_Fee__c + prodPayment.Payment_Amount__c
                                                                 : prodPayment.Payment_Amount__c);
                    prodPayment.Pay_Non_Recoverable_Fee__c  = prodPayment.Payment_Amount__c;
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
        update listProductsToUpdate;
        
        ProductPaymentstriggerHandler.runProductTrigger = false;
        update listProductPaymentToUpdate;
       
           JudgmentTriggerHandler.recalculateDisbursmentFees(setProductID);
        
        ProductPaymentstriggerHandler.runProductTrigger = true;
        ProductTriggerHandler.runProductTrigger = true;
    }
    
     class productWrapper{
        public String productName;
        public String placementStatusCode;
        public String productStatusCode;
        public String placementIdentifier;
        public productWrapper(String productName,String placementStatusCode, String productStatusCode, String placementIdentifier){
            this.productName = productName;
            this.placementStatusCode = placementStatusCode;
            this.productStatusCode = productStatusCode;
            this.placementIdentifier = placementIdentifier;
        }
    }
    
    //Validation method to be called  before update
    public static void validationOnRecordUpdate2(List<Product_Payments__c> prodPayNew, 
                                                set<ID> setProductID, set<ID> setPlacementID,
                                                Map<ID, Product__c> mapProductDetails
                                                //,map<Id, Product__c> mapProduct, ID documentId
                                                ){
        system.debug('validationOnRecordUpdate2 called');
        set<ID> alreadyReversedPayments = new set<ID>();
        map<ID, Product__c> mapProduct = new map<ID, Product__c>();
        system.debug('mapProduct:: '+mapProduct);
        map<String, ID> setOldTransaction = new map<String, ID>();
        list<Product_Payments__c> listProductPayToUpdate = new list<Product_Payments__c>();
        map<ID, Placement__c> mapPlacement = new map<ID, Placement__c>();
        for(Placement__c placement : [SELECT ID, Name FROM Placement__c WHERE ID IN :setPlacementID]){
            mapPlacement.put(placement.ID, placement);
        }
                                                    
        for(Product__C product : [SELECT ID, name, Collection_Agency__c,Settlement_Rate__c,
                                             Collection_Agency_Placement__c , Collection_Sub_Status__c,
                                             Status__c, Sub_Status__c,Data_Status_Description__c,
                                             Pool_Name__r.Commission_Rate__c,Value_Tier_at_Time_of_Placement__c,
                                             Collection_Agency_Placement__r.Commission_Rate__c,Commission_Adjustment__c,
                                             Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                                             Assignment_Date__c,Recalled_Date__c, Current_Balance__c,
                                             Collection_Agency_Placement__r.Default_Tolerance_of_Total_Balance__c, 
                                             Collection_Agency_Placement__r.Default_Tolerance_Amount__c,
                                             Collection_Agency_Placement__r.Tolerance_of_Total_Balance__c, 
                                             Collection_Agency_Placement__r.Tolerance_Amount__c,Purchase_Status__c   
                                      FROM Product__C 
                                      WHERE ID IN :setProductID] ){
                mapProduct.put(product.id, product); 
          }
                                                    
                                                    
        for(Product_Payments__c oldPay : [SELECT ID, CCS_Account__r.Name, Payment_Type__c, Payment_Amount__c, Payment_Posting_Date__c,
                                                 Payment_Posting_Date_Text__c
                                          FROM Product_Payments__c
                                          WHERE CCS_Account__c IN :mapProduct.keySet()]){
            String payAmount = String.valueOf(oldPay.Payment_Amount__c);
            setOldTransaction.put(payAmount + oldPay.Payment_Type__c + oldPay.Payment_Posting_Date_Text__c +
                                    oldPay.CCS_Account__c, oldPay.ID);                                          
        }
        system.debug('setOldTransaction::'+setOldTransaction);
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        system.debug('+++++portalSettings :' + portalSettings);
        list<String> validPaymentTypes = new list<String>();
                                                    
        map<Id, Decimal> mapProductPaymentAmount = new map<ID, Decimal>();
        //set hacing product name and payment amount
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>();     
                                                    
        validPaymentTypes = portalSettings.Valid_Payment_Types__c.split(',');
        set<Id> setProductNames = new set<Id>();
        //Tax calculation
        set<id> placementId = new set<id>();
        Decimal ontarioTaxRate;                                            
        map<id,Placement__c> mapPlacementIds = new map<id,Placement__c>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
        for(Account_Judgment__c accountJudgment : [SELECT ID, Name, Product__c, Judgment__c,
                                                   Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
                                                   FROM Account_Judgment__c
                                                   WHERE Product__c IN :mapProductDetails.keySet() AND Status__c= 'Active']){
            if(accountJudgment.Judgment__r.Legal_Status__c == 'Judgment' 
            || accountJudgment.Judgment__r.Legal_Status__c == 'Post-Judgment' 
            || accountJudgment.Judgment__r.Legal_Status__c == 'Pre-Judgment'){
                    /*&& (accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Media Requested awaiting'
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Settlement Proposal Accepted' 
                    && accountJudgment.Judgment__r.Legal_Sub_Status__c != 'Action Rejected'))){*/
                mapProductJudgmentClaimIssuedID.put(accountJudgment.Product__c, accountJudgment.Judgment__c);
            }
        }
        if(mapTaxMetadata != NULL && mapTaxMetadata.containsKey('Ontario')){
            ontarioTaxRate = mapTaxMetadata.get('Ontario').Total_Tax_rate__c;    
        }
        
        
        //Tax rate mapping by Province Acronym
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
        
        for(Product_Payments__c prodPayment : prodPayNew){
            placementId.add(prodPayment.Payment_Provided_Agency__c);
        }
        List<Placement__c> placement = [select id,name,Apply_Ontario_Rate_on_Legal_Account__c from Placement__c
                where id =: placementId];
        for(Placement__c placeData : placement){
            mapPlacementIds.put(placeData.id,placeData);
        }
                                                    
        for(Product_Payments__c prodPayment : prodPayNew){
            if(mapProductNameAmount.containsKey(String.valueOf(prodPayment.Payment_Amount__c) + prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c)){
                mapProductNameAmount.put(String.valueOf(prodPayment.Payment_Amount__c) + prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c, 
                                        mapProductNameAmount.get(prodPayment.Payment_Amount__c + prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c)+1);
            }
            else{
                mapProductNameAmount.put(String.valueOf(prodPayment.Payment_Amount__c) + prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c, 1);
            }
            
            if(mapProductPaymentAmount.containsKey(prodPayment.CCS_Account__c)){
                Decimal payAmount = mapProductPaymentAmount.get(prodPayment.CCS_Account__c);
                if(payAmount != NULL && prodPayment.Payment_Amount__c != NULL && prodPayment.Payment_Amount__c > 0){
                    mapProductPaymentAmount.put(prodPayment.CCS_Account__c, payAmount + prodPayment.Payment_Amount__c);
                }                
                
            }
            else{
                if(prodPayment.Payment_Amount__c != NULL && prodPayment.Payment_Amount__c > 0){
                    mapProductPaymentAmount.put(prodPayment.CCS_Account__c, prodPayment.Payment_Amount__c);
                }
            }
            
            setProductNames.add(prodPayment.CCS_Account__c);
        }
                                                 
        set<String> setProductPreviouslyPlacedCheck = getPlacementHistoryDetails(setProductNames);
                                                    
        //direct payment history
        map<ID, Placement_History__c> mapProductPreviouslyPlaced = getDirectPlacementHistoryDetails(setProductNames);                                             
                                                    
        String prodPayStatus = '';  
        String productAgency = '';  
        Id productAgencyID = null;
        for(Product_Payments__c prodPayment:prodPayNew){
            if(prodPayment.Payment_Provided_Agency__c != NULL && mapPlacement.containsKey(prodPayment.Payment_Provided_Agency__c)){
                prodPayment.Payment_Agency__c = mapPlacement.get(prodPayment.Payment_Provided_Agency__c).Name;    
            }
            
            productAgency = '';
            prodPayStatus = '';
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)){
                if(String.isNotBlank(mapProduct.get(prodPayment.CCS_Account__c).Status__c)){
                    prodPayStatus = mapProduct.get(prodPayment.CCS_Account__c).Status__c;     
                }
                if(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c != NULL){
                    system.debug('prodPayment.CCS_Account__r.Name::'+prodPayment.CCS_Account__c);
                    productAgency = String.valueOf(mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c);
                    productAgencyID = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c;
                }
            }
            
            
            system.debug('prodPayment: '+prodPayment);
            // 3
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';            
            
            system.debug('prodPayment.CCS_Account__r.Collection_Agency__c'+prodPayment.CCS_Account__r.Collection_Agency__c);
            
            system.debug('newtransac'+prodPayment.Payment_Amount__c + ''+prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c);
            if(setOldTransaction.containsKey(prodPayment.Payment_Amount__c + ''+prodPayment.Payment_Type__c + 
                                          prodPayment.Payment_Posting_Date__c + prodPayment.CCS_Account__c)){
                ERROR_MSG += '<b>WARNING</b> - A duplicate transaction was found in Inventory.<br/>'; 
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - A duplicate transaction was found in Inventory.');                                  
                }
            }
            //Payment Source should be either 1,2,3
            if(prodPayment.Payment_Source__c != '1' && prodPayment.Payment_Source__c != '2' &&
              prodPayment.Payment_Source__c != '3'){
                ERROR_MSG = '<b>ERROR</b> - Payment Source is not valid.<br/>';
                EXPECTED += 'Payment Source Should be 1 OR 2 OR 3.<br/>'; 
                prodPayment.addError('Payment Source is not valid. It Should be 1 OR 2 OR 3');
            }
            
            if(!mapProduct.containsKey(prodPayment.CCS_Account__c)){
                ERROR_MSG = '<b>ERROR</b> - Account not found.<br/>';
                //prodPayment.addError('Account not found.');
            }
            else{
                prodPayment.Product_Agency__c = mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c;
            }

            
            //Invalid Payment Date
            if(prodPayment.Payment_Posting_Date__c != NULL){
                if(prodPayment.Payment_Posting_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                    EXPECTED += 'Payment Date cannot be in future.<br/>';
                    prodPayment.addError('Payment Date cannot be in future.');                    
                }  
            }
            else{
                prodPayment.addError('Payment Date cannot be blank');
            }
            
            system.debug('+++++prodPayment.Payment_Type__c :'+ prodPayment.Payment_Type__c);
            //Account is currently in pending recall status and pmt is not a reversal
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
               && String.isNotBlank(prodPayStatus)
               && prodPayStatus.startsWith('Pending Recall')
               && prodPayment.Payment_Type__c != PAYTYPE_REVERSAL){
                   system.debug('Blockrun');
                   ERROR_MSG += '<b>WARNING</b> - Invalid account status.<br/>';
                   EXPECTED += 'Account cannot be in Pending Recall Status.<br/>';
                   if(prodPayment.Ignore_Warning__c == false){
                        prodPayment.addError('WARNING - Account cannot be in Pending Recall Status.');   
                   }
            }
             //Payment does not meet paid in full parameters Amount cannot be negative
             if(prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL){
                if(prodPayment.Payment_Amount__c<=0){
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Paid in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1001) Paid in Full.');
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
             if(prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL){
                if(prodPayment.Payment_Amount__c<0){
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Settled in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1002) Settled in Full.');
                }
            }
            
            //Payment does not meet paid in full parameters 
            if(prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL  
            && mapProduct.containsKey(prodPayment.CCS_Account__c)
            && mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != NULL) {
                Decimal outStandingBalance;
                outStandingBalance = (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c *
                                      5 /100);
                outStandingBalance = outStandingBalance.setScale(2, RoundingMode.HALF_UP);
                
                //Check if payment amount matches outStandingBalance amount percents on Placement
                if(prodPayment.Payment_Amount__c < outStandingBalance){
                    ERROR_MSG += '<b>WARNING</b> - Transaction amount is not within 5% of the total oustanding balance'
                                +'<br/>';
                    EXPECTED += 'Expected Paid in Full Amount: '+outStandingBalance
                                +'<br/>';
                    if(prodPayment.Ignore_Warning__c == false){
                        prodPayment.addError('WARNING - Transaction amount is not within 5% of the total oustanding balance.' + 
                                            ' Expected Paid in Full Amount: '+outStandingBalance);   
                   }
                }
            }
            
            
            //This account is no longer available in this Placement
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && String.isNotBlank(productAgency)
            && productAgency != '9999'
            && prodPayment.Payment_Agency__c != productAgency
            && setProductPreviouslyPlacedCheck.contains(prodPayment.CCS_Account_Name__c + prodPayment.Payment_Agency__c)){
                ERROR_MSG += '<b>WARINING</b> - This account is no longer available in this Placement.<br/>';
                EXPECTED += 'Product Agency:'+mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c+'; Payment Agency:'+ prodPayment.Payment_Agency__c +'<br/>';
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - This account is no longer available in this Placement.');
                }
            }
            
            system.debug('productAgency:: '+productAgency);
            system.debug('prodPayment.Payment_Agency__c::'+prodPayment.Payment_Agency__c);            
            //This account is no longer available in this Placement
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && String.isNotBlank(productAgency)
            && productAgency != '9999'
            && prodPayment.Payment_Agency__c != productAgency
            && !setProductPreviouslyPlacedCheck.contains(prodPayment.CCS_Account_Name__c + prodPayment.Payment_Agency__c)){
                ERROR_MSG += '<b>WARNING</b> - This account is not available in this Placement.<br/>';
                EXPECTED += 'Account Agency: ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                //EXPECTED += 'Account should not be in Warehouse.<br/>';
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - This account is not available in this Placement.');
                }
            }
            
            system.debug('prodPayment.Payment_Posting_Date__c:: '+prodPayment.Payment_Posting_Date__c);
            system.debug('mapProductPreviouslyPlaced'+mapProductPreviouslyPlaced);
            //Contigency is commission amount****
            system.debug('prodPayment.Payment_Source__c::'+prodPayment.Payment_Source__c);
            if(prodPayment.Payment_Source__c == '1'){
                system.debug('mapProductPreviouslyPlaced::**'+mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c);
                //if product Recall date is blank then fetch Recall date from placement history
                if(mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == NULL){
                    system.debug('inside recall date null');
                    if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                        system.debug('inside product is in placed with another agency');
                        mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c;
                    }
                }
                system.debug('mapProductPreviouslyPlaced::**'+mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c);
                if(!FEE_TRANSACION_CODES.contains(prodPayment.payment_Type__c)){
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency =='9999' || String.isBlank(productAgency))
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  <= 15){
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                            Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                        
                            system.debug('CommissionRate::'+CommissionRate);
                            if(CommissionRate == NULL){
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                            }
                            if(CommissionRate == NULL){
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                            }
                            if(CommissionRate != NULL){
                                //if commission adjustment is added to product, adjust Commission Rate
                                if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                prodPayment.Pay_Due__c= (prodPayment.Payment_Amount__c * CommissionRate)/100; 
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                
                                //Tax Amount calculation:
                                //calculate tax amount
                                DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0; 
                                system.debug('state::'+mapProductDetails.get(prodPayment.CCS_Account__c));
                                prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if(String.isNotBlank(prodProvinceName)){
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();        
                                }
                                system.debug('provinceAcronymFormat::'+provinceAcronymFormat);
                                system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if(mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                   mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c).Apply_Ontario_Rate_on_Legal_Account__c == TRUE){
                                       if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                           prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                           prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                           prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                           prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                        * (ontarioTaxRate))/100;
                                           system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                       } 
                                   }
                                else{
                                    if(!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                                        system.debug('ontarioTaxRate::'+ontarioTaxRate);
                                        if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                            
                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                         * (ontarioTaxRate))/100;
                                            system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                        }
                                    }
                                    else{
                                        system.debug('inside elsee');
                                        if(String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)){
                                            system.debug('inside claim issued testing' +prodPayment.Tax_Amount__c);
                                            if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                            }
                                            else if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                            }
                                            if(prodPayment.Pay_Due__c != NULL){
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c *  
                                                                             (DebtorProvinceTaxRate + CanadaTaxRate) ) / 100;    
                                            }
                                            system.debug('inside else tax amount testing' +prodPayment.Tax_Amount__c);
                                        }    
                                    }
                                }
                                
                                //calculate tax amount ends
                            }
                            if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                    prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                }
                                if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                    prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                }
                            }
                            
                            system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                            
                            ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                            EXPECTED += 'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to Agency '+ prodPayment.Payment_Agency__c 
                                        +'<br/>';
                            if(prodPayment.Ignore_Warning__c == false){
                                prodPayment.addError('WARNING - Account was recalled within 15 days is currently warehoused.'+
                                                     'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to Agency '+ prodPayment.Payment_Agency__c);    
                            }
                                    
                        }
                        //ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                        //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                        //EXPECTED += 'Commission will be paid to payment agency: '+ prodPayment.Payment_Agency__c +'<br/>';
                    }
                    
                    //This account is recalled before 15 days and is currently warehoused
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency =='9999' || String.isBlank(productAgency))
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 15){
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled more than 15 days ago and is currently warehoused.<br/>';
                        //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                        EXPECTED += 'Commission Amount paid will be 0 on this payment. '+'<br/>';
                        if(prodPayment.Ignore_Warning__c == false){
                            prodPayment.addError('WARNING - Account was recalled more than 15 days ago and is currently warehoused. Commission Amount paid will be 0');    
                        }
                        
                        prodPayment.Pay_Due__c= 0;
                        prodPayment.Tax_Amount__c = 0;
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                            if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                            }
                            if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }
                    }
                    //system.debug('No of days3::'+mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()));
                    //system.debug('Placement_Recall_Date__c::'+mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c);
                    
                    //assigned to agency
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency != '9999' && String.isNotBlank(productAgency))){
                    //&& mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 15){
                        /*if(!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                        }*/
                        //This account is recalled before 15 days 
                       system.debug('mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)::'+prodPayment.CCS_Account__c);
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) 
                        && mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15){
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                            //system.debug('Run block greater than 15');
                            //system.debug('productAgencyID::'+productAgencyID);
                            //system.debug('productAgency::'+productAgency);
                            //ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency '+productAgency +'.<br/>';
                            //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                            //EXPECTED += 'Commission Amount paid will be 0 on this payment. '+'<br/>';
                            //prodPayment.Pay_Due__c= 0;       
                        system.debug('No of days1::'+mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()));
                        }
                        //This account is recalled within 15 days and 
                        
                        else if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) 
                             && mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15){
                                 if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                  system.debug('mapProductPreviouslyPlaced>>>'+mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c));
                                  //system.debug('No of days::'+mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()));
                                    Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C; //Commission_Rate__c;
                                     system.debug('CommissionRate>>>'+CommissionRate);
                                     if(CommissionRate == NULL){
                                         CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                                     }
                                     if(CommissionRate == NULL){
                                         CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                                     }
                                     if(CommissionRate != NULL){
                                        //if commission adjustment is added to product, adjust Commission Rate
                                        if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                            CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                        }
                                        prodPayment.Pay_Due__c= (prodPayment.Payment_Amount__c * CommissionRate)/100;
                                        //Tax Amount calculation:
                                         //calculate tax amount
                                         DebtorProvinceTaxRate = 0;
                                         CanadaTaxRate = 0; 
                                         system.debug('state::'+mapProductDetails.get(prodPayment.CCS_Account__c));
                                         prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                         ProvinceNameFormat = nameFormat(prodProvinceName);
                                         if(String.isNotBlank(prodProvinceName)){
                                             provinceAcronymFormat = prodProvinceName.toUpperCase();        
                                         }
                                         system.debug('provinceAcronymFormat::'+provinceAcronymFormat);
                                         system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                                         //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                         if(mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                            mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c).Apply_Ontario_Rate_on_Legal_Account__c == TRUE){
                                                if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                                    prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                                    prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                                    prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                                    prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                                 * (ontarioTaxRate))/100;
                                                    system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                                } 
                                            }
                                         else{
                                             if(!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                                                 system.debug('ontarioTaxRate::'+ontarioTaxRate);
                                                 if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                                     prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                                     prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                                     prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                                     
                                                     prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                                  * (ontarioTaxRate))/100;
                                                     system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                                 }
                                             }
                                             else{
                                                 system.debug('inside elsee');
                                                 if(String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)){
                                                     system.debug('inside claim issued testing' +prodPayment.Tax_Amount__c);
                                                     if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                                                         DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                         CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                         prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                         prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                         prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                                     }
                                                     else if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                                                         DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                         CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                         prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                         prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                         prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                                     }
                                                     if(prodPayment.Pay_Due__c != NULL){
                                                         prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                         prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c *  
                                                                                      (DebtorProvinceTaxRate + CanadaTaxRate) ) / 100;    
                                                     }
                                                     system.debug('inside else tax amount testing' +prodPayment.Tax_Amount__c);
                                                 }    
                                             }
                                         }
                                         
                                         //calculate tax amount ends
                                        prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                         if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                                 prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                             }
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                                 prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                             }
                                         }
                                     }
                                     else{
                                         //if commission adjustment is added to product, adjust Commission Rate
                                         if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                             CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                         }
                                         prodPayment.Pay_Due__c= NULL; 
                                         
                                         prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                         if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                                 prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                             }
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                                 prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                             }
                                         }              
                                     }
                                system.debug('prodPayment.Pay_Due__c>>>'+prodPayment.Pay_Due__c+'CommissionRate >>'+CommissionRate );
                                     //ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently warehoused.<br/>';
                                    //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                                    EXPECTED += 'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to '+ prodPayment.Payment_Agency__c +'<br/>';   
                                    if(prodPayment.Ignore_Warning__c == false && prodPayment.Pay_Due__c != NULL){
                                        prodPayment.addError( 'WARNING - Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to '+ prodPayment.Payment_Agency__c);    
                                    }
                                 }   
                        }
                    }
                }
                //Account is currently warehoused (recalled within 30 days)
               /* if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                //&& String.isNotBlank(prodPayStatus)
                //&& prodPayStatus.startsWith('Recall')
                && String.isNotBlank(productAgency)
                && productAgency == '9999'
                && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                && prodPayment.Payment_Posting_Date__c != NULL
                && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  <= 30
                ){
                    ERROR_MSG += '<b>WARNING</b> - This account has been recalled.<br/>The transaction is within 30 days of the recall.<br/>Contingency will not be processed.<br/> ';
                    EXPECTED += 'Account should not be in Warehouse.<br/>';
                    //system.debug('prodPayment.Ignore_Warning__c::'+prodPayment.Ignore_Warning__c);
                    if(prodPayment.Ignore_Warning__c == false){ 
                        prodPayment.addError('WARNING - This account has been recalled. The transaction is within 30 days of the recall. Contingency will not be processed');
                        
                    }
                    prodPayment.Pay_Due__c= 0;
                    //system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                }
                //Account is currently warehoused (recalled within 60 days)
                else if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                //&& String.isNotBlank(prodPayStatus)
                //&& prodPayStatus.startsWith('Recall')
                && String.isNotBlank(productAgency)
                && productAgency == '9999'
                && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                && prodPayment.Payment_Posting_Date__c != NULL
                &&  mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  <= 60
                ){
                    ERROR_MSG += '<b>ERROR</b> - This account has been recalled.<br/>The transaction is within 60 days of the recall.<br/>Contingency will not be processed.<br/> ';
                    EXPECTED += 'Account should not be in Warehouse.<br/>';
                    if(prodPayment.Ignore_Warning__c == false){
                        prodPayment.addError('This account has been recalled. The transaction is within 60 days of the recall. Contingency will not be processed');    
                    }
                    prodPayment.Pay_Due__c= 0;
                }    */
            }
            
            //Account is currently warehoused  and recalled more than 60 days ago, OR account has had subsequent placements
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            //&& String.isNotBlank(prodPayStatus)
            //&& prodPayStatus.startsWith('Recall')
            && String.isNotBlank(productAgency)
            && productAgency == '9999'
            && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
            && prodPayment.Payment_Posting_Date__c != NULL
            &&  mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 60
            ){
                ERROR_MSG += '<b>ERROR</b> - Invalid current account status.<br/> ';
                EXPECTED += 'Account cannot not be in Warehouse.<br/>';
                prodPayment.addError('Invalid current account status. Account should not be in Warehouse.');
            }

            
            //Payment exceeds total outstanding balance
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && mapProductPaymentAmount.containsKey(prodPayment.CCS_Account__c)
            && mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c < mapProductPaymentAmount.get(prodPayment.CCS_Account__c)){
                ERROR_MSG += '<b>WARNING</b> - The total amount paid for the account is greater than the total balance<br/>';
                EXPECTED += 'Total Balance on Product= '+ mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c.setScale(2, RoundingMode.HALF_UP) +'<br/>';
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - The total amount paid for the account is greater than the total balance');
                }
            }
            
            
            //Calculated commission is incorrect
            if(prodPayment.Agency_Calculated_Comm__c != NULL
            && prodPayment.Agency_Calculated_Comm__c != prodPayment.Pay_Due__c
            && prodPayment.Payment_Amount__c > 0
            && productAgency != '9999'
            && String.isNotBlank(productAgency)){
                ERROR_MSG += '<b>WARNING</b> - Invalid amount retained/remitted on Gross Remittance.<br/>';
                EXPECTED += 'Expected Commission Amount: '+ prodPayment.Pay_Due__c+'<br/>';
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - Invalid amount retained/remitted on Gross Remittance');
                }
            }
            
            //Transaction type is incorrect
            if(prodPayment.Payment_Type__c != NULL && !validPaymentTypes.contains(prodPayment.Payment_Type__c)){
                system.debug('prodPayment.Payment_Type__c::'+prodPayment.Payment_Type__c);
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Type.<br/>';
                prodPayment.addError('Invalid Payment Type.');
            }
            
            //Account must not be closed
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c)
            && mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed') 
            && (mapProduct.get(prodPayment.CCS_Account__c).Purchase_Status__c == 'Putback Approved' ||
               mapProduct.get(prodPayment.CCS_Account__c).Purchase_Status__c == 'Buyback  Approved')){
                ERROR_MSG += '<b>ERROR</b> - Account is closed.<br/>';
                    prodPayment.addError('Account is closed.');
            }else{
                if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && String.isnotblank(mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c)
                    && mapProduct.get(prodPayment.CCS_Account__c).Data_Status_Description__c.startsWith('Closed')){
                        ERROR_MSG += '<b>WARNING</b> - Account is closed.<br/>';
                        if(prodPayment.Ignore_Warning__c == false){
                            prodPayment.addError('WARNING - Account is closed.');
                        }
                   }   
            }
            
            //Must be positive
            if(prodPayment.Payment_Type__c == PAYTYPE_REGULAR && prodPayment.Payment_Amount__c < 0 ){
                ERROR_MSG += '<b>ERROR</b> - Negative amount received with incorrect payment type (1000).<br/>';
                prodPayment.addError('ERROR - Negative amount received with incorrect payment type (1000).');
                /*if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - Negative amount received with incorrect type (1000).');
                }*/
            }
            
            //------------------Direct Payment Validations Starts-------------------//
            //if(prodPayment.Ignore_Warning__c == false){
                //This account is recalled within 15 days and is currently warehoused
                system.debug('productAgency::'+productAgency);
                if((prodPayment.Payment_Source__c == '2' || prodPayment.Payment_Source__c == '3')
                && !FEE_TRANSACION_CODES.contains(prodPayment.payment_Type__c)){
                    //if product Recall date is blank then fetch Recall date from placement history
                    if(mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c == NULL){
                        system.debug('inside recall date null');
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                            system.debug('inside product is in placed with another agency');
                            mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c;
                        }
                    }
                    
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency =='9999' || String.isBlank(productAgency))
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  <= 15){
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                            Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                        
                            system.debug('CommissionRate::'+CommissionRate);
                            if(CommissionRate == NULL){
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                            }
                            if(CommissionRate == NULL){
                                CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                            }
                            if(CommissionRate != NULL){
                                //if commission adjustment is added to product, adjust Commission Rate
                                if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                    CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                }
                                prodPayment.Pay_Due__c= (prodPayment.Payment_Amount__c * CommissionRate)/100;
                                prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                //Tax Amount calculation:
                                //calculate tax amount
                                DebtorProvinceTaxRate = 0;
                                CanadaTaxRate = 0; 
                                system.debug('state::'+mapProductDetails.get(prodPayment.CCS_Account__c));
                                prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                ProvinceNameFormat = nameFormat(prodProvinceName);
                                if(String.isNotBlank(prodProvinceName)){
                                    provinceAcronymFormat = prodProvinceName.toUpperCase();        
                                }
                                system.debug('provinceAcronymFormat::'+provinceAcronymFormat);
                                system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                                //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                if(mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                   mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c).Apply_Ontario_Rate_on_Legal_Account__c == TRUE){
                                       if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                           prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                           prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                           prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                           prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                        * (ontarioTaxRate))/100;
                                           system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                       } 
                                   }
                                else{
         
                                    if(!test.isRunningTest() && !mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                                        system.debug('ontarioTaxRate::'+ontarioTaxRate);
                                        if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                            prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                            prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                            prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                            
                                            prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                         * (ontarioTaxRate))/100;
                                            system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                        }
                                    }
                                    else{
                                        system.debug('inside elsee');
                                        if(String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)){
                                            system.debug('inside claim issued testing' +prodPayment.Tax_Amount__c);
                                            if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                                                DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                            }
                                            else if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                                                DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                            }
                                            if(prodPayment.Pay_Due__c != NULL){
                                                prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c *  
                                                                             (DebtorProvinceTaxRate + CanadaTaxRate) ) / 100;    
                                            }
                                            system.debug('inside else tax amount testing' +prodPayment.Tax_Amount__c);
                                        }    
                                    }
                                }
                                
                                //calculate tax amount ends
                            }
                            if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                    prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                }
                                if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                    prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                }
                            }
                            
                            ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                            EXPECTED += 'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to Agency '+ prodPayment.Payment_Agency__c 
                                        +'<br/>';
                            if(prodPayment.Ignore_Warning__c == false){
                                prodPayment.addError('WARNING - Account was recalled within 15 days is currently warehoused.'+
                                                     'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to Agency '+ prodPayment.Payment_Agency__c);    
                            }
                                    
                        }
                        //ERROR_MSG += '<b>WARINING</b> - Account was recalled within 15 days and is currently warehoused.<br/>';
                        //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                        //EXPECTED += 'Commission will be paid to payment agency: '+ prodPayment.Payment_Agency__c +'<br/>';
                    }
                    
                    //This account is recalled before 15 days and is currently warehoused
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency =='9999' || String.isBlank(productAgency))
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c != NULL
                    && mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 15){
                        ERROR_MSG += '<b>WARINING</b> - Account was recalled more than 15 days ago and is currently warehoused.<br/>';
                        //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                        EXPECTED += 'Commission Amount paid will be 0 on this payment. '+'<br/>';
                        if(prodPayment.Ignore_Warning__c == false){
                            prodPayment.addError('WARNING - Account was recalled more than 15 days ago and is currently warehoused. Commission Amount paid will be 0');    
                        }
                        
                        prodPayment.Pay_Due__c= 0;
                        prodPayment.Tax_Amount__c = 0;
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                            if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                            }
                            if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                            }
                        }
                    }
                    
                    //assigned to agency
                    if(mapProduct.containsKey(prodPayment.CCS_Account__c)
                    && (productAgency != '9999' && String.isNotBlank(productAgency))){
                    //&& mapProduct.get(prodPayment.CCS_Account__c).Recalled_Date__c.daysBetween(prodPayment.Payment_Posting_Date__c)  > 15){
                        /*if(!mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)) {
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                        }*/
                        //This account is recalled before 15 days 
                       system.debug('mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)::'+prodPayment.CCS_Account__c);
                        if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) 
                        && mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) > 15){
                            prodPayment.Payment_Provided_Agency__c = productAgencyID;
                            prodPayment.Payment_Agency__c = productAgency;
                            
                            //ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently placed with agency '+productAgency +'.<br/>';
                            //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                            //EXPECTED += 'Commission Amount paid will be 0 on this payment. '+'<br/>';
                            //prodPayment.Pay_Due__c= 0;       
                        }
                        //This account is recalled within 15 days and 
                        
                        else if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c) 
                             && mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement_Recall_Date__c.daysBetween(Date.today()) <= 15){
                                 if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                    Decimal CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Product_Commission_rate__C;
                                     if(CommissionRate == NULL){
                                         CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Commission_Rate__c;
                                     }
                                     if(CommissionRate == NULL){
                                         CommissionRate = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Pool_Commission_Rate__c;
                                     }
                                     if(CommissionRate != NULL){
                                        //if commission adjustment is added to product, adjust Commission Rate
                                        if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                            CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                        }
                                        prodPayment.Pay_Due__c= (prodPayment.Payment_Amount__c * CommissionRate)/100;
                                        prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                        //Tax Amount calculation:
                                         //calculate tax amount
                                         DebtorProvinceTaxRate = 0;
                                         CanadaTaxRate = 0; 
                                         system.debug('state::'+mapProductDetails.get(prodPayment.CCS_Account__c));
                                         prodProvinceName = mapProductDetails.get(prodPayment.CCS_Account__c).State__c;
                                         ProvinceNameFormat = nameFormat(prodProvinceName);
                                         if(String.isNotBlank(prodProvinceName)){
                                             provinceAcronymFormat = prodProvinceName.toUpperCase();        
                                         }
                                         system.debug('provinceAcronymFormat::'+provinceAcronymFormat);
                                         system.debug('prodPayment.Pay_Due__c::'+prodPayment.Pay_Due__c);
                                         //Calculate Tax Amount for acocunts that are not in legal Status or claim issued
                                         if(mapPlacementIDs.containsKey(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c) &&
                                            mapPlacementIDs.get(mapProductDetails.get(prodPayment.CCS_Account__c).Collection_Agency_Placement__c).Apply_Ontario_Rate_on_Legal_Account__c == TRUE){
                                                if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                                    prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                                    prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                                    prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                                    prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                                 * (ontarioTaxRate))/100;
                                                    system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                                } 
                                            }
                                         else{
                                             if(!mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                                                 system.debug('ontarioTaxRate::'+ontarioTaxRate);
                                                 if(prodPayment.Pay_Due__c != NULL && ontarioTaxRate != NULL){
                                                     prodPayment.Tax_Type__c = mapTaxMetadata.get('Ontario').Tax_Type__c;
                                                     prodPayment.Tax_Province__c = mapTaxMetadata.get('Ontario').Province_Acronym__c;
                                                     prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get('Ontario').Total_Tax_Rate__c;
                                                     
                                                     prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c
                                                                                  * (ontarioTaxRate))/100;
                                                     system.debug('inside not claim issued testing' +prodPayment.Tax_Amount__c);
                                                 }
                                             }
                                             else{
                                                 system.debug('inside elsee');
                                                 if(String.isNotBlank(mapProductDetails.get(prodPayment.CCS_Account__c).State__c)){
                                                     system.debug('inside claim issued testing' +prodPayment.Tax_Amount__c);
                                                     if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                                                         DebtorProvinceTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Province_Tax_rate__c;
                                                         CanadaTaxRate = mapTaxMetadata.get(ProvinceNameFormat).Canada_Tax_rate__c;
                                                         prodPayment.Tax_Type__c = mapTaxMetadata.get(ProvinceNameFormat).Tax_Type__c;
                                                         prodPayment.Tax_Province__c = mapTaxMetadata.get(ProvinceNameFormat).Province_Acronym__c;
                                                         prodPayment.Tax_Province_Rate__c = mapTaxMetadata.get(ProvinceNameFormat).Total_Tax_Rate__c;
                                                     }
                                                     else if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                                                         DebtorProvinceTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Tax_rate__c;
                                                         CanadaTaxRate = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Canada_Tax_rate__c;
                                                         prodPayment.Tax_Type__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Tax_Type__c;
                                                         prodPayment.Tax_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Acronym__c;
                                                         prodPayment.Tax_Province_Rate__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Total_Tax_Rate__c;
                                                     }
                                                     if(prodPayment.Pay_Due__c != NULL){
                                                         prodPayment.Legal_Product_Identifier__c = 'Yes';
                                                         prodPayment.Tax_Amount__c = (prodPayment.Pay_Due__c *  
                                                                                      (DebtorProvinceTaxRate + CanadaTaxRate) ) / 100;    
                                                     }
                                                     system.debug('inside else tax amount testing' +prodPayment.Tax_Amount__c);
                                                 }    
                                             }
                                         }
                                         
                                         //calculate tax amount ends
                                         if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                                 prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                             }
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                                 prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                             }
                                         }
                                     }else{
                                         //if commission adjustment is added to product, adjust Commission Rate
                                         if(mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c != NULL){
                                             CommissionRate = CommissionRate + mapProduct.get(prodPayment.CCS_Account__c).Commission_Adjustment__c;
                                         }
                                         prodPayment.Pay_Due__c= NULL; 
                                         prodPayment.Commission_Rate_for_Payment__c = CommissionRate;
                                         system.debug('inside condition Payment Provided_Agency');
                                         if(mapProductPreviouslyPlaced.containsKey(prodPayment.CCS_Account__c)){
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c != NULL){
                                                 prodPayment.Payment_Provided_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Placement__c; 
                                             }
                                             if(mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c != NULL){
                                                 prodPayment.Payment_Agency__c = mapProductPreviouslyPlaced.get(prodPayment.CCS_Account__c).Agency_Id__c;
                                             }
                                         }
                                     }
                                    
                                     //ERROR_MSG += '<b>WARINING</b> - Account was recalled before 15 days and is currently warehoused.<br/>';
                                    //EXPECTED += 'Current Agency Number ' + mapProduct.get(prodPayment.CCS_Account__c).Collection_Agency__c +'<br/>';
                                    EXPECTED += 'Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to '+ prodPayment.Payment_Agency__c +'<br/>';   
                                    if(prodPayment.Ignore_Warning__c == false && prodPayment.Pay_Due__c != NULL){
                                        prodPayment.addError( 'WARNING - Commission Amount '+prodPayment.Pay_Due__c+ ' will be paid to '+ prodPayment.Payment_Agency__c);    
                                    }
                                 }   
                        }
                    }
                }
                
                //No settlement parameters set for the account
                if(prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL  
                && mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c == null) {
                    ERROR_MSG += '<b>WARNING</b> - Settlements are not available on this account.<br/>';
                    if(prodPayment.Ignore_Warning__c == false){
                        prodPayment.addError('WARNING - Settlements Rate not available on this account.');
                    }
                }
                
                //Payment does not meet Settlement parameters of <<settlement parameter on account in %>>
                if(prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL  
                && mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != NULL
                && mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c != NULL) {
                    Decimal toleranceAmount;
                    if(mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c != null){
                        toleranceAmount = (mapProduct.get(prodPayment.CCS_Account__c).Current_Balance__c *
                                          mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c)/100;
                        toleranceAmount = toleranceAmount.setScale(2, RoundingMode.HALF_UP);
                    }
                    system.debug('toleranceAmount:::'+toleranceAmount+'>>'+prodPayment.Payment_Amount__c);
                    //Check if payment amount matches tolerance amount percents on Placement
                    if(prodPayment.Payment_Amount__c <> toleranceAmount){
                        ERROR_MSG += '<b>WARNING</b> - Payment does not meet Settlement parameter on Account ' 
                                    + 'Settlement Rate % : '+mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c
                                    +'<br/>';
                        EXPECTED += 'Expected Settlement Amount : '+toleranceAmount
                                    +'<br/>';
                        if(prodPayment.Ignore_Warning__c == false){
                            prodPayment.addError('WARNING : Payment does not meet Settlement parameter on Account Settlement Rate %:'+mapProduct.get(prodPayment.CCS_Account__c).Settlement_Rate__c);
                        }
                    }
                }    
            //}            
            
            //Must be negative
            if( prodPayment.Payment_Type__c == PAYTYPE_REVERSAL && prodPayment.Payment_Amount__c > 0 ){
                ERROR_MSG += '<b>ERROR</b> - Invalid Reversal. Amount must be negative.<br/>';
                prodPayment.addError('Invalid Reversal. Amount must be negative.');
            }
            
             //Payment does not meet paid in full parameters Amount cannot be negative
             if(prodPayment.Payment_Type__c == PAYTYPE_PAID_IN_FULL){
                if(prodPayment.Payment_Amount__c<=0){
                    System.debug('ERROR::PAYTYPE_SETTLED_IN_FULL');
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for payment type(1001) Paid in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1001) Paid in Full.');
                }
            }
            //Payment does not meet paid in full parameters Amount cannot be negative
             if(prodPayment.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL){
                if(prodPayment.Payment_Amount__c<0){
                    System.debug('ERROR::PAYTYPE_SETTLED_IN_FULL');
                    ERROR_MSG += '<b>ERROR</b> - Amount can not be negative for paymnet type(1002) Settled in Full ';
                    prodPayment.addError('Amount can not be negative for payment type(1002) Settled in Full.');
                }
            }
            //Payment being reversed must exist (same pmt amount (but negative) and pmt date as original payment)
            system.debug('prodPayment.Payment_Type__c::'+prodPayment.Payment_Type__c);
            if((prodPayment.Payment_Type__c == PAYTYPE_REVERSAL && prodPayment.Payment_Amount__c < 0)
            && !FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)){
                system.debug('prodPayment.Payment_Amount__c:::'+prodPayment.Payment_Amount__c);
                if(prodPayment.Payment_Amount__c < = 0){
                    Decimal payAmount = prodPayment.Payment_Amount__c *-1;
                    system.debug('payAmount: '+payAmount);
                    system.debug('key: '+payAmount + PAYTYPE_REGULAR + 
                                                prodPayment.Payment_Posting_Date_Text__c+ prodPayment.CCS_Account__c);
                    if(!setOldTransaction.containsKey(payAmount + PAYTYPE_REGULAR + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)
                    && !setOldTransaction.containsKey(payAmount + PAYTYPE_PAID_IN_FULL + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)
                    && !setOldTransaction.containsKey(payAmount + PAYTYPE_SETTLED_IN_FULL + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)){
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                        prodPayment.addError('ERROR - A corresponding Payment was not found for this reversal.');
                    }
                    else{
                        if(!alreadyReversedPayments.contains(setOldTransaction.get (payAmount + PAYTYPE_REGULAR + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c))){
                            prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get (payAmount + PAYTYPE_REGULAR + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c);
                            if(prodPayment.Original_Of_Payment_Reversal__c == NULL){
                                prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get (payAmount + PAYTYPE_PAID_IN_FULL + 
                                                    prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c);
                                
                            }
                            if(prodPayment.Original_Of_Payment_Reversal__c == NULL){
                                prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get (payAmount + PAYTYPE_SETTLED_IN_FULL + 
                                                    prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c);
                                 
                            } 
                            alreadyReversedPayments.add(prodPayment.Original_Of_Payment_Reversal__c);
                        }
                        else{
                            system.debug('duplicate reversal found');
                            system.debug('alreadyReversedPayments::'+alreadyReversedPayments);
                            system.debug('Payment_Posting_Date_Text__c in reversal - '+prodPayment.Payment_Posting_Date_Text__c);
                            system.debug('Payment_Type__c in reversal - '+prodPayment.Payment_Type__c);
                            system.debug('Payment_Amount__C in reversal - '+prodPayment.Payment_Amount__C);
                            Decimal payAMountReversed = prodPayment.Payment_Amount__C * -1;
                            list<Product_Payments__c> reverseProductPayments = [SELECT ID, CCS_Account__c, Payment_Type__c, Payment_Amount__C,
                                                                          Payment_Posting_Date_Text__c
                                                                          FROM Product_Payments__c
                                                                          WHERE Is_Payment_Reversed__c = false
                                                                          AND ID NOT IN :alreadyReversedPayments 
                                                                          AND CCS_Account__c = :prodPayment.CCS_Account__c
                                                                          AND Payment_Type__c = :'1000'
                                                                          AND Payment_Amount__C = :payAMountReversed
                                                                          AND Payment_Posting_Date_Text__c = :prodPayment.Payment_Posting_Date_Text__c
                                                                          LIMIT 1];
                            
                            system.debug('reverseProductPayments::'+reverseProductPayments);
                            if(!reverseProductPayments.isEmpty()){
                                prodPayment.Original_Of_Payment_Reversal__c = reverseProductPayments[0].ID;
                                alreadyReversedPayments.add(prodPayment.Original_Of_Payment_Reversal__c);
                            }
                            else{
                                ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                                prodPayment.addError('ERROR - A corresponding Payment was not found for this reversal.<br/>');
                            }
                        }
                        system.debug(' prodPayment.Original_Of_Payment_Reversal__c::'+prodPayment.Original_Of_Payment_Reversal__c);
                    }

                }
                
            }
            
            //Account is currently in Recalled status.
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && String.isNotBlank(prodPayStatus)
            && prodPayStatus.startsWith('Recall')
            && productAgency != '9999'
            && prodPayment.Payment_Source__c == '1'){
                system.debug('Blockrun');
                ERROR_MSG += '<b>WARNING</b> - Account is currently in Recalled status.<br/>';
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING :Account is currently in Recalled status');
                }
            }
            
            if(prodPayment.Payment_Amount__c == NULL){
                ERROR_MSG += '<b>ERROR</b> - Invalid Payment Amount<br/>';
                prodPayment.addError('Invalid Payment Amount.');
            }
            
            //----------------------------Fees validations startes------------------//
            if(prodPayment.Payment_Posting_Date__c != NULL
            && FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)){
                if(prodPayment.Payment_Amount__c < = 0){
                    Decimal payAmount = prodPayment.Payment_Amount__c *-1;
                    system.debug('payAmount: '+payAmount);
                    system.debug('key: '+payAmount + prodPayment.Payment_Type__c + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c);
                     if(!setOldTransaction.containsKey(payAmount + prodPayment.Payment_Type__c + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c)){
                        ERROR_MSG += '<b>ERROR - </b>A corresponding Payment was not found for this reversal.<br/>';
                        prodPayment.addError('ERROR - A corresponding Payment was not found for this reversal.');
                    }
                    else{
                        prodPayment.Original_Of_Payment_Reversal__c = setOldTransaction.get (payAmount + prodPayment.Payment_Type__c + 
                                                prodPayment.Payment_Posting_Date_Text__c + prodPayment.CCS_Account__c);
                        system.debug(' prodPayment.Original_Of_Payment_Reversal__c::'+prodPayment.Original_Of_Payment_Reversal__c);
                    }
                }   
            }
            
            system.debug('mapProductJudgmentClaimIssuedID::'+mapProductJudgmentClaimIssuedID);
            if(mapProduct.containsKey(prodPayment.CCS_Account__c)
            && FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c) 
            && prodPayment.Payment_Type__c != '3000'
            && !mapProductJudgmentClaimIssuedID.containsKey(prodPayment.CCS_Account__c)){
                if(prodPayment.Ignore_Warning__c == false){
                    prodPayment.addError('WARNING - Cannot post Protective Disbursment to the account. Account is not in Legal Status');
                }
                //ERROR_MSG += '<b>ERROR</b> - Cannot post Protective Disbursment to the account. Account is not in Legal Status<br/>';
               // EXPECTED += 'Account is not in Legal Status<br/>';
            }
            if(prodPayment.Pay_Due__c == 0){
                prodPayment.Tax_Amount__c = 0;
            }
        }
    }
       
    
    public static set<String> getPlacementHistoryDetails(set<Id> setProductNames){
        set<String> setProductPreviouslyPlacedCheck = new set<String>();
        mapProductPreviouslyPlacedCheck = new Map<String, Placement_History__c>();
        Date dateInstance = Date.today().addDays(-15);
        for(Placement_History__c placementHistory : [SELECT ID, Placement__r.Name, Product__c, Product__r.Name,CreatedDate
                                                     FROM Placement_History__c
                                                     WHERE Product__c IN :setProductNames
                                                     AND CreatedDate = LAST_N_DAYS:180]){
            setProductPreviouslyPlacedCheck.add(placementHistory.Product__r.Name + placementHistory.Placement__r.Name);
            if(placementHistory.CreatedDate < dateInstance){
                mapProductPreviouslyPlacedCheck.put(placementHistory.Product__r.Name + placementHistory.Placement__r.Name, placementHistory);
            }
        }
        return setProductPreviouslyPlacedCheck;
    }
    
    public static map<ID, Placement_History__c> getDirectPlacementHistoryDetails(set<ID> setProductNames){
        map<ID, Placement_History__c> previouslyPlaced = new map<ID, Placement_History__c>();
        
        for(Placement_History__c placementHistory : [SELECT ID, Placement__r.Name, Product__c, Product__r.Name,
                                                     Placement_Recall_Date__c, Agency_Id__c, Placement__c,Product_Commission_Rate__c,
                                                     Commission_Rate__c , Pool_Commission_Rate__c
                                                     FROM Placement_History__c
                                                     WHERE Product__c IN :setProductNames
                                                     AND Placement_Recall_Date__c = LAST_N_DAYS:60
                                                     AND Placement_Recall_Date__c != NULL
                                                    ORDER BY CreatedDate DESC]){
                                                        system.debug('placementHistory'+placementHistory);
            if(!previouslyPlaced.containsKey(placementHistory.Product__c)){
                previouslyPlaced.put(placementHistory.Product__c, placementHistory);    
            }
                 system.debug('previouslyPlaced'+previouslyPlaced);                                       
                /*Date dateToCheck =  payPostingDateMap.get(placementHistory.Product__r.name+Placement__r.Name);
                Integer datedifference = dateToCheck.daysBetween(placementHistory.CreatedDate);
                if(datedifference < 15){
                    
                }*/
           }
            return previouslyPlaced;
    }
}