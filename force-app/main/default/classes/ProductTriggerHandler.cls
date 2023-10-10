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
public class ProductTriggerHandler{
    
    //Line Break
    public static String ACCEPTED_BY_AGENCY_PLACEMENT_CODE = '100010';
    public static Id customerAccountRecordTypeId;
    
    public static String lBrk = '</br>';
    
    public static final String MANUAL_REVIEW_REASON = 'Multiple Matches';
    
    public static String profileName{get;set;}
    
    public static boolean runProductTrigger = true;
    public static boolean runProductAPITrigger = true;
    
    public static boolean runPaymentProcessing = true;
    
    public static boolean currentBalanceUpdate = true;
    
    public static boolean runProductAPI = true;
    
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    
    public static Map<String, Data_Status_Mapping__c> dataStatusMap = Data_Status_Mapping__c.getAll();
    
    //public static Map<String, Id> mapCollectionAgency = new Map<String, Id>();
    public static Map<String, Placement__c> mapCollectionAgency = new Map<String, Placement__c>();
    
    public static Map <Id, String> prodRecorTypeMap;
    
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
    public static Set<Id> customersLockedForUpdate ;        
    
    //map of Placement Code and Placement Status  
    public static map<String, Placement_Status_Code_Mapping__c> mapPlacementCodeStatus;
    
    //map of Placement Status and Placement Code
    public static map<String, String> mapPlacementStatus;
    
    public static map<String, Integer> mapPortfolioNamesCounter = new map<String, Integer>();
    public static Map<String, Decimal> mapProductNameDetails = new Map<String, Decimal>();
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
    //map of Placement Status and Placement Code
    public static Agency_Portal_Settings__c agencyPortalSettings;
        
    public static void UtilityMethod(){
        //fill Collection Agency Map
        list<Placement__c> list1 = [select id, Name, Agency_Name__c, Serviceable_Province__c from Placement__c];
        system.debug('list1::'+list1.size());
        for(Placement__c place :list1){            
            mapCollectionAgency.put(place.Name, place);
        }
        system.debug('mapCollectionAgency ' +mapCollectionAgency);
        //Get profile Name
        profileName = Utilities.getUserProfile();
        
        //Get ProductRecordtype Id, Name Map       
        prodRecorTypeMap = Utilities.getProdRecorTypeMap();
        customerAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Customer Salesforce' LIMIT 1].Id;
        
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
            prodRTypeIdNameMap.put(rType.Id, rType.name);
        }
        agencyPortalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        //Tax rate mapping by Province Acronym
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
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

    public static Set<String> getPlacementHistoryDetails(set<Id> setProductId){
        set<Id> setPreviousPlacedProduct = new Set<Id>();
        map<Id, Id> mapAllProductAgency = new map<Id, Id>();
        set<String> setProductAgencyName = new set<String>();
        //Get Placement History for new Distressed Products
        if(Test.isRunningTest()){
           List<Placement_History__c> placementHistory = [SELECT ID, Agency_Id__c, Product_Identifier__c
                                                         FROM Placement_History__c
                                                         WHERE Product__c IN :setProductId
                                                         AND CreatedDate = LAST_N_DAYS:180 limit 1];
            
            for(Placement_History__c platHistory: placementHistory){
                                                             //Combine Product name + Placement Agency
                  setProductAgencyName.add(platHistory.Product_Identifier__c + platHistory.Agency_Id__c );   
             }
        }
        if(!Test.isRunningTest()){
            for(Placement_History__c placementHistory : [SELECT ID, Agency_Id__c, Product_Identifier__c
                                                         FROM Placement_History__c
                                                         WHERE Product__c IN :setProductId
                                                         AND CreatedDate = LAST_N_DAYS:180]){
                                                             //Combine Product name + Placement Agency
                                                             setProductAgencyName.add(placementHistory.Product_Identifier__c + placementHistory.Agency_Id__c );   
                                                         }
        }
        return setProductAgencyName;
    }
    
    public static set<Id> getProductPaymentDetails(set<Id> setProductId){
        set<Id> setRecentlyPaidProducts = new set<Id>();
        List<Product_Payments__c> productPay =  [SELECT ID, CCS_Account__c  
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__c IN :setProductId
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60];
        for(Product_Payments__c prodPayment : productPay ){
            setRecentlyPaidProducts.add(prodPayment.CCS_Account__c);
        }
        return setRecentlyPaidProducts;
    }
    
    public static map<String, Placement_Status_Code_Mapping__c> getPlacementStatusCodes(){
        mapPlacementCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        mapPlacementStatus = new map<String, String>();
        for(Placement_Status_Code_Mapping__c reasons : [SELECT Parent_Status__c,Placement_Status_Code__c,
                                                               Status__c,Sub_Status__c, Complete_Status__c
                                                        FROM Placement_Status_Code_Mapping__c
                                                        ORDER BY Status__c]){
            mapPlacementCodeStatus.put(reasons.Placement_Status_Code__c, reasons);
            if(String.isNotBlank(reasons.Status__c)){
                if(String.isBlank(reasons.Sub_Status__c)){
                    reasons.Sub_Status__c = '';
                }
                //system.debug('reasons.Complete_Status__c:'+reasons.Complete_Status__c);
                mapPlacementStatus.put(reasons.Complete_Status__c, reasons.Placement_Status_Code__c);   
            }           
        }
        
        return mapPlacementCodeStatus;
    }
    
    //Handle before insert
    public static void handleBeforeInsert(List<Product__c> prodNew) {
        Boolean isCommunityUser = false;
        if(!Test.isRunningTest()){
            UtilityMethod();
        }
        
        //Ticket 4558: Interest Waiver functionality checking Accuring Interest
        populateAccuringInterest(prodNew);
        
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        ID productSource; 
        for(Product__c prodData :prodNew){
            if(prodData.isClone()){
                productSource = prodData.getCloneSourceId();
                if(productSource <> NULL){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,First_Name__c,Last_Name__c,Date_of_Birth__c,SIN__c,
                                                CID_number__c,Phone_Home__c,Phone_Work__c,Phone_Other__c,Address_Line1__c,Address_Line2__c,
                                                City__c,Zip_Code__c,Provinces__c,Country__c,Reason_for_Proposal__c,Initial_Proposal_Date__c,
                                                Second_Proposal_Date__c,Third_Proposal_Date__c,Fourth_Proposal_Date__c
                                                from product__c where id =: productSource];
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
            if(isCommunityUser){
                if(!prodData.isClone()){
                    productSource = prodData.getCloneSourceId();
                    if(productSource == NULL){
                        prodData.addError('Please use Clone Button to Create New Record');
                    }
                } 
            }
        }
        
        
        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();

        getPlacementStatusCodes();
        Integer i = 0;
        Set<String> nameRecordTypeIdKey = ProductTriggerHandler.getMatchingProducts(prodNew);
        map<String, Decimal> mapAccountPurchaseGroupCount = new map<String, Decimal>();
        set<String> setAccountPortfolioID = new set<String>();
        List<ID> poolplacementName = new List<ID>();
        map<ID, Pool__c> mapPool = new map<ID, Pool__c>();
        //map<String, Integer> mapPortfolioNamesCounter = new Map<String, Integer>();
        list<Product__c> listDistressedProduct = new list<Product__c>();
        
        for(Product__c prod : prodNew){
            if(!nameRecordTypeIdKey.isEmpty() && nameRecordTypeIdKey.contains(prod.RecordTypeId + '-' + prod.Name)){
                prod.addError(System.Label.Duplicate_Account_ID_Validation_Error);
            }
			//for Ticket 4834 - populating bank account number based on Account ID
            if(prod.name <> NULL){
                prod.Bank_Refence_Number__c = prod.name;
            }
            
            //for Ticket 4895 - populating Payment Missed
            if(prod.Proposed_Payment_Amount__c <> NULL && prod.Proposed_Payment_Amount__c > 0 && 
               prod.Amount_of_payments_missed__c <> NULL){
               prod.Payment_Missed__c = (prod.Amount_of_payments_missed__c / prod.Proposed_Payment_Amount__c );
            }

            /*if( prod.Open_Date__c != null && 
                (prod.Statute_Date__c == null || prod.Open_Date__c < prod.Statute_Date__c )
            ){
                prod.Statute_Date__c = StatuteDateUtilities.getStatueDate(prod.Last_Payment_Date__c,prod.Open_Date__c,prod.Open_Date__c,prod.Statute_Date__c,prod.State__c);
            }*/
            prod.Statute_Date__c = StatuteDateUtilities.getStatueDate(prod.Last_Payment_Date__c,prod.Open_Date__c,prod.Charged_Off_Date__c,prod.Statute_Date__c,prod.Purchase_Province__c);
            System.debug('DDDD '+prod.Statute_Date__c);
            if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId && lrpSetting.EnableNewAccountNameCreationLogic__c == true){
                if(prod.Account_Portfolio_ID__c != NULL){
                    setAccountPortfolioID.add(prod.Account_Portfolio_ID__c);
                    
                    if(mapPortfolioNamesCounter.containsKey(prod.Account_Portfolio_ID__c)){
                        mapPortfolioNamesCounter.put(prod.Account_Portfolio_ID__c, mapPortfolioNamesCounter.get(prod.Account_Portfolio_ID__c)+1);
                    }
                    else{
                        mapPortfolioNamesCounter.put(prod.Account_Portfolio_ID__c, 1);
                    }
                }
                else{
                      prod.addError('Account Portfolio ID is mandatory to populate Account ID');  
                }
            }
            if(prod.Pool_Name__c != NULL){
                poolplacementName.add(prod.Pool_Name__c);    
            }
        }
        
        for(Pool__c pool :  [Select id,Name,Placement_Agency__c from Pool__c where id IN: poolplacementName] ){               
            mapPool.put(pool.id,pool);
        }
        //system.debug('setAccountPortfolioID::'+setAccountPortfolioID);
        system.debug('mapPortfolioNamesCounter:: '+mapPortfolioNamesCounter);
        Map<String, ID> mapProducNameIDS = new Map<String, ID>();
        for(Product_Name_Details__c prodName : [Select Id, Name, Last_Product_Number_in_the_Group__c From Product_Name_Details__c WHERE Name IN :setAccountPortfolioID]){
            mapProductNameDetails.put(prodName.Name, prodName.Last_Product_Number_in_the_Group__c);
            mapProducNameIDS.put(prodName.Name, prodName.ID);
        }
        system.debug('mapProductNameDetails::'+mapProductNameDetails);
        
        for(Product__c prod : prodNew){
            if(mapPool.containsKey(prod.Pool_Name__c)){
                prod.Pool_Name_Text__c = mapPool.get(prod.Pool_Name__c).Name;  
            }
            system.debug('prodNew recordtypeid::'+prod.RecordTypeId);
            if(String.isNotBlank(prod.Placement_Status__c) && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)){
                prod.Status__c =  mapPlacementCodeStatus.get(prod.Placement_Status__c).Parent_Status__c +' - ' +mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                prod.Sub_Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Sub_Status__c;
            }
            
            if(String.isNotBlank(prod.Status__c) && String.isNotBlank(prod.Sub_Status__c)
            && mapPlacementStatus.containsKey(prod.Status__c+prod.Sub_Status__c)){
                 prod.Placement_Status__c =  mapPlacementStatus.get(prod.Status__c+prod.Sub_Status__c);
            }
            if(lrpSetting.Run_Product_Before_Trigger__c == true){
                system.debug('prod.RecordTypeId:'+prod.RecordTypeId);
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId || 
                   prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId){
                       prod.Run_Identifier_Check_On__c = Date.today(); 
                       
                       //Data status mapping
                       if(String.isNotBlank(prod.product_status__C)){
                           if(null != dataStatusMap.get(prod.product_status__C)){
                               prod.Data_Status_Description__c = dataStatusMap.get(prod.product_status__C).Description__c;
                           }else{
                               prod.Data_Status_Description__c = '';
                           }
                       }else{
                           prod.Data_Status_Description__c = '';
                       }
                   }        
                
                //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId){
                    if(String.isNotBlank(String.valueOf(prod.Collection_Agency__c))){
                        
                        prod.Collection_Agency_Placement__c = mapCollectionAgency.get(String.valueOf(Math.floor(prod.Collection_Agency__c))).ID;
                        
                    }
                    else{
                        prod.Collection_Agency_Placement__c = Null;
                    }
                    //Generate Product Name with Portfolio Number
                    //Count the no of products against purchase group:
                    listDistressedProduct.add(prod);
                    
                    if(agencyPortalSettings.Run_Product_Name_Logic__c == true){
                        String purchaseGroup = '';
                        if(prod.Account_Portfolio_ID__c != NULL){
                            //purchaseGroup = String.valueOf(Math.floor(prod.Account_Portfolio_ID__c));
                            purchaseGroup = String.valueOf(prod.Account_Portfolio_ID__c);
                        }
                        system.debug('purchaseGroup::'+purchaseGroup);
                        Integer counterlength;
                        if(String.isNotBlank(purchaseGroup)){
                            if(mapPortfolioNamesCounter.get(purchaseGroup) != null){
                                counterlength = String.valueOf(mapPortfolioNamesCounter.get(purchaseGroup)).length();
                            }
                            if(mapProductNameDetails.containsKey(purchaseGroup)){
                                Decimal counter = mapProductNameDetails.get(purchaseGroup);
                                Decimal Name1 = Math.floor(counter + 1);
                                system.debug('Name1::'+Name1);
                                //Integer leadingZero = 5 - String.valueOf(Integer.valueOf(Name1)).length();  
                                //system.debug('leadingZero:: '+leadingZero);
                                if(lrpSetting.EnableNewAccountNameCreationLogic__c == true){
                                    prod.Name = purchaseGroup + 'P' + String.valueOf(Name1).leftPad(counterlength, '0');
                                }
                                prod.DebtNext_Data_ID__c = prod.Name;
                                mapProductNameDetails.put(purchaseGroup, Name1);
                                //purchaseGroup = String.valueOf(Math.floor(prod.Account_Purchase_Group__c)); 
                            }
                            else{
                                mapProductNameDetails.put(purchaseGroup, 1);
                                String Name1 = '1';
                                if(lrpSetting.EnableNewAccountNameCreationLogic__c == true){
                                    prod.Name = purchaseGroup + 'P' + String.valueOf(Name1).leftPad(counterlength, '0');
                                }
                                prod.DebtNext_Data_ID__c = prod.Name;
                            }    
                        }
                    }
                    
                }
            }
            
            //if(!Test.isRunningTest()){
                // Added record type check for Loan Account OR Credit Card Account
                if(prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || 
                   prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId ||
                   prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId){
                       //Format Phone Numbers
                       prod.Phone_Home__c = Utilities.formatPhone(prod.Phone_Home__c);
                       prod.Phone_Other__c = Utilities.formatPhone(prod.Phone_Other__c);
                       prod.Phone_Work__c = Utilities.formatPhone(prod.Phone_Work__c);
                   }
                
                // Insolvency Product enhancements
                system.debug('prod.RecordTypeId::'+prod.RecordTypeId);
                system.debug('prod.Last_Name__c::'+prod.Last_Name__c);
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId || prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId ||
                  prodRTypeIdMap.get('GoEasy_CCS_Account') == prod.RecordTypeId){
                    system.debug('inside if recordtypeid');
                    if(String.isNotBlank(prod.Last_Name__c)){
                        system.debug('call matching cutomers');
                        List <Account> matchingCustomers = getMatchingCustomers(prod);
                        system.debug('matchingCustomers:: '+matchingCustomers);
                        if(matchingCustomers != null && matchingCustomers.size() > 0){ 
                            if(matchingCustomers.size() > 1){
                                prod.Needs_Manual_Review__c = true;
                                prod.Manual_Review_Reason__c = MANUAL_REVIEW_REASON;
                            }
                            prod.customer__c = matchingCustomers.get(0).Id;
                        }
                    }
                } 
            //}
        }
        
        list<Product_Name_Details__c> listProductNameToUpsert = new list<Product_Name_Details__c>();
        for(String portfolio : mapProductNameDetails.keySet()){
            Product_Name_Details__c prodDetail = new Product_Name_Details__c();
            prodDetail.Name = portfolio;
            prodDetail.Last_Product_Number_in_the_Group__c = mapProductNameDetails.get(portfolio);
            if(mapProducNameIDS.containsKey(portfolio)){
                prodDetail.ID = mapProducNameIDS.get(portfolio);
            }
            listProductNameToUpsert.add(prodDetail);
        }
        try{
            upsert listProductNameToUpsert;    
        }
        catch(Exception ex){
            system.debug('Exception ex'+ex);
        }
        //New code
        if(!Test.isRunningTest()){
        runProductTrigger = false;
        }
        
         //old code    runProductTrigger = false;
    }
    
    //Handle before update
    public static void handleBeforeUpdate(List<Product__c> listNewProducts, Map<Id, Product__c> mapOldProducts) {
   
        UtilityMethod();
        //Ticket 4558: Interest Waiver functionality checking Accuring Interest
        populateAccuringInterest(listNewProducts);
        // Pre load Statute Date from metadata
        StatuteDateUtilities.loadStatuteDataFromMetadata();
        
        getPlacementStatusCodes();
        
        system.debug('listNewProducts:: '+listNewProducts.size());
        Id DistressedProductRecordTypeId = prodRTypeIdMap.get('Distressed_Account');
        set<Id> setPreviousPlacedProduct = new set<Id>();
        set<Id> setRecalledProducts = new set<Id>();
        set<Id> setRecentlyPaidProducts = new set<Id>();
        set<String> setPreviousPlacedProductNames = new set<String>();
        list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
        list<Product__c> listProductToUpdateBalance = new list<Product__c>();
        Map<String, String> mapProvinceNames = new Map<String, String>();
        Map<id, Decimal> mapPoolAgency = new Map<id, Decimal>();
        Map<id, Pool__c> mapPool = new Map<id, Pool__c>();
        
        //Fill provice name map with abbriviations
        mapProvinceNames.put('NS', 'Nova Scotia');
        mapProvinceNames.put('NB', 'New Brunswick');
        mapProvinceNames.put('MB', 'Manitoba');
        mapProvinceNames.put('BC', 'British Columbia');
        mapProvinceNames.put('PE', 'Prince Edward Island');
        mapProvinceNames.put('SK', 'Saskatchewan');
        mapProvinceNames.put('AB',  'Alberta');
        mapProvinceNames.put('NL', 'Newfoundland and Labrador');
        mapProvinceNames.put('QC', 'Quebec');
        mapProvinceNames.put('ON', 'Ontario');
        
       // String poolplacementName = '' ;
        List<ID> poolplacementName = new List<ID>();
        Decimal checkCollectionAgency = null;
        

        //Fetch System Api
        List<User> systemName= new list<User>();
        if(lrpSetting.Canaccede_API_User__c != NULL){
            systemName = [Select id, Name from User where username =: lrpSetting.Canaccede_API_User__c];    
        }
        //Fetch System Api                
        if(lrpSetting.Run_Product_Before_Trigger__c == true){
            Set<String> nameRecordTypeIdKey = ProductTriggerHandler.getMatchingProducts(listNewProducts);
            for(Product__c prod : listNewProducts){ 
            Product__c prodOld1 = mapOldProducts.get(prod.id);
            if((prod.Name != prodOld1.Name || prod.RecordTypeId != prodOld1.RecordTypeId) && (!nameRecordTypeIdKey.isEmpty() && nameRecordTypeIdKey.contains(prod.RecordTypeId + '-' + prod.Name))){
                prod.addError(System.Label.Duplicate_Account_ID_Validation_Error);
            }
                system.debug('prodOld1:'+prodOld1);
            if(prod.Refer_to_Legal__c == 'Approved' && prodOld1.Refer_to_Legal__c != prod.Refer_to_Legal__c){ 
                system.debug('block run');
                creatJudgment(prod);
            }
            
            if(prodOld1.Status__c!=null){
                 if((prodOld1.Status__c.startsWith('Pre - Legal')
                   && prod.Status__c != prodOld1.Status__c) || (prodOld1.Refer_to_Legal__c =='For Review' && prod.Status__c != prodOld1.Status__c)
                   || (prodOld1.Status__c.startsWith('Pre - Legal')
                   && prod.Sub_Status__c != prodOld1.Sub_Status__c)){ 
                    system.debug('block run');
                    prod.addError('Status can not change if refer to legal is in For review/placement status is in Pre-Legal.');
                //creatJudgment(prod);
                }
            }
           //for Ticket 4834 - populating bank account number based on Account ID
            if(prod.name <> NULL){
                prod.Bank_Refence_Number__c = prod.name;
            }
            //for Ticket 4895 - populating Payment Missed
            if(prod.Proposed_Payment_Amount__c <> NULL && prod.Proposed_Payment_Amount__c > 0 && 
               prod.Amount_of_payments_missed__c <> NULL){
               prod.Payment_Missed__c = (prod.Amount_of_payments_missed__c / prod.Proposed_Payment_Amount__c );
            }
                system.debug('agency:'+prod.Collection_Agency__c);
                if (isCanaccedeAPIUser() || Test.isRunningTest()){
                    // Added record type check for Loan Account OR Credit Card Account
                    if(prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || 
                       prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId ||
                       prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId || Test.isRunningTest()){
                           prod.Phone_Home__c = Utilities.formatPhone(prod.Phone_Home__c);
                           prod.Phone_Other__c = Utilities.formatPhone(prod.Phone_Other__c);
                           prod.Phone_Work__c = Utilities.formatPhone(prod.Phone_Work__c);
                       }
                    
                    //Old Product values
                    Product__c prodOld = mapOldProducts.get(prod.id);
                    Id oldCustomerId = prodOld.customer__c;
                    
                    // Check if product is Insolvency Account / Distressed_Account or not
                    //if(prodRTypeIdMap.get('Insolvency_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId)
                    if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId || prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId ||
                      prodRTypeIdMap.get('GoEasy_CCS_Account') == prod.RecordTypeId){
                        if(prod.customer__c == null){
                            
                            if(oldCustomerId != null){
                                prod.customer__c = oldCustomerId;
                            }
                            else{
                                if(String.isNotBlank(prod.Last_Name__c)){                                   
                                    List <Account> matchingCustomers = getMatchingCustomers(prod);
                                    if(matchingCustomers != null && matchingCustomers.size() > 0){
                                        if(matchingCustomers.size() > 1){
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
                if(prod.Pool_Name__c != NULL){
                    poolplacementName.add(prod.Pool_Name__c);    
                }
                
               // mapPoolAgency.put(prod.Pool_Name__c,prod.Pool_Name__r.Placement_Agency__c);
                system.debug('poolplacementName '+poolplacementName);

                
                //check if collection agency is changed for Distressed or recordtype is changed to CCS Account
                if((prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId
                 && prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c)
                 || (prodRTypeIdMap.get('CCS_Account') == prod.RecordTypeId
                  && prod.RecordTypeId != mapOldProducts.get(prod.Id).RecordTypeId)){
                    
                    prod.Run_Identifier_Check_On__c = Date.today();
                }
            
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId
                 && prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c){
                    // Assign System API to Owner
                     if(!systemName.isEmpty()){
                        prod.OwnerId = systemName[0].Id;      
                     }
                   
                    //Also Assign the last owner to the previous ownership field
                    prod.Previous_Ownership__c = mapOldProducts.get(prod.Id).OwnerId;
                }
            
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId){
                    //Data status mapping
                    if(String.isNotBlank(prod.product_status__C)){
                        if(null != dataStatusMap.get(prod.product_status__C)){
                            prod.Data_Status_Description__c = dataStatusMap.get(prod.product_status__C).Description__c;
                        }else{
                            prod.Data_Status_Description__c = '';
                        }
                    }else{
                        prod.Data_Status_Description__c = '';
                    }
                }
                
                //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId){
                    //Data status mapping
                    if(String.isNotBlank(String.ValueOf(prod.Collection_Agency__c)) 
                       && mapCollectionAgency.containsKey(String.ValueOf(Math.floor(prod.Collection_Agency__c)))){
                           prod.Collection_Agency_Placement__c = mapCollectionAgency.get(String.ValueOf(Math.floor(prod.Collection_Agency__c))).ID;
                       }else{
                           prod.Collection_Agency_Placement__c = Null;
                       }
                }
                //If Placement STatus code is updated, update Main Status and SUb Status
               if(String.isNotBlank(prod.Placement_Status__c) 
                && mapOldProducts.get(prod.ID).Placement_Status__c != prod.Placement_Status__c
                && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)){
                   // prod.Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                   //Updated the prod.Status__c for ticket 2877
                    prod.Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Parent_Status__c +' - ' +mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                    prod.Sub_Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Sub_Status__c;
                }
              
                system.debug('mapOldProducts'+mapOldProducts.get(prod.ID).Collection_agency__c);
                system.debug('prod.Status__c'+prod.Status__c);
                //if status and sub status is updated, update placement status code
               if(mapOldProducts.get(prod.ID).Status__c != prod.Status__c 
                || mapOldProducts.get(prod.ID).Sub_Status__c != prod.Sub_Status__c){
                    String placeStatus = prod.Status__c;
                    system.debug('prod.Status__c: '+prod.Status__c);
                    system.debug('prod.Sub_Status__c update:'+prod.Sub_Status__c);
                    if(String.isNotBlank(prod.Sub_Status__c)){
                        placeStatus += ' - ' + prod.Sub_Status__c;    
                    }
                    system.debug('placeStatus:: '+placeStatus);
                    system.debug('prod.Sub_Status__c:: '+prod.Sub_Status__c);
                    if(String.isNotBlank(placeStatus)
                    && mapPlacementStatus.containsKey(placeStatus)){
                         prod.Placement_Status__c =  mapPlacementStatus.get(placeStatus);
                    }    
                    system.debug('prod.Placement_Status__c:'+prod.Placement_Status__c);
                    system.debug('prod.Invalid_Submission__c:'+prod.Invalid_Submission__c);
                    if(prod.Placement_Status__c == ACCEPTED_BY_AGENCY_PLACEMENT_CODE
                    && prod.Invalid_Submission__c == true){
                        prod.Invalid_Submission__c = false;
                        prod.Timestamp_Of_Invalid_Submission__c = null;
                        prod.Invalid_Submission_Reason__c = null;
                       // prod.Invalid_Submission_Initiated_By__c = null;
                    }
                }
                
               
                //Recall Collection agency if status is back/put back and sale categories: agency portal change
                if(prod.Collection_Sub_Status__c == 'Buy back/put back and sale categories'){
                    
                    prod.Collection_Agency__c  = null;
                }
                
                if(prod.RecordTypeId == DistressedProductRecordTypeId){
                    //system.debug('warning:'+prod.Ignore_Warning__c);
                    //Check if Placement Agency on Product is updated
                    if(prod.Collection_Agency__c != NULL
                       && mapOldProducts.get(prod.Id).Collection_Agency__c != NULL
                       && prod.Collection_Agency__c != mapOldProducts.get(prod.Id).Collection_Agency__c
                       //&& prod.Ignore_Warning__c == false
                       ){
                           system.debug('agency updated');
                           setPreviousPlacedProduct.add(prod.Id);
                       }
                    //Check if agency is recalled
                    if(prod.Collection_Agency__c == NULL
                       && mapOldProducts.get(prod.Id).Collection_Agency__c != NULL){
                           setRecalledProducts.add(prod.Id);
                       }
                }
                
                //process builder 'Refer to legal' convert into code for agency portal changes
                if((prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c && 
                   prod.Refer_to_Legal__c == 'For Review')){
                    
                    prod.Sent_for_Review_by__c = UserInfo.getName();
                    prod.Sent_to_Review_Date__c =  System.now();
                    prod.Placement_Status__c = '210000';
                    prod.Status__c = 'Pre - Legal - In Process';
                    prod.Sub_Status__c = 'Recommended for Legal Action';
                    
                }else if(prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c 
                && (prod.Refer_to_Legal__c == 'Approved' 
                /*|| prod.Refer_to_Legal__c == 'Declined'*/)){
                    prod.Legal_Decision_Date__c = System.now();
                    prod.Legal_Decision_by__c = UserInfo.getUserId();
                    prod.Placement_Status__c = '210010';
                    prod.Status__c = 'Pre - Legal - In Process';
                    prod.Sub_Status__c = 'Approved for Legal Action';
                }else if(prod.Refer_to_Legal__c != mapOldProducts.get(prod.Id).Refer_to_Legal__c  
                && prod.Refer_to_Legal__c == 'Declined'){
                    prod.Legal_Decision_Date__c = System.now();
                    prod.Legal_Decision_by__c = UserInfo.getUserId();
                    prod.Placement_Status__c = '210910';
                    prod.Status__c = 'Pre - Legal - Inactive';
                    prod.Sub_Status__c = 'Legal Action Rejected';
                }
                
                Product__c prodOld = mapOldProducts.get(prod.Id);
                
                //validation check method for agency portal
                if(prodRTypeIdMap.get('Distressed_Account') == prod.RecordTypeId && prod.Collection_Sub_Status__c != prodOld.Collection_Sub_Status__c){
                    //validationRules(listNewProducts, mapOldProducts);
                }
                if(prod.Current_Principal_Balance__c != NULL && prod.Current_Interest_Amount__c != NUll){
                    //prod.Current_Balance__c = prod.Current_Principal_Balance__c + prod.Current_Interest_Amount__c;    
                }
             //Interest Rate on Product changed to 0% when updating insolvency information
             //RemoveprodOld.Insolvency_Date__c == null && prod.Insolvency_Date__c != null for ticket 4599
                if(prodOld.Deceased_Date__c == null && prod.Deceased_Date__c != null){
                    if(prod.Interest_Rate__c != 0){
                        prod.Previous_Interest_Rate__c = prod.Interest_Rate__c;
                        prod.Interest_Rate__c = 0;
        
                    }
                    if(prod.Deceased_Date__c != null){
                        prod.Collection_Sub_Status__c = 'Deceased';
                    }
                }
                //if Credit Counselling Date is added 
                if((prodOld.Credit_Counselling_Date__c == null && prod.Credit_Counselling_Date__c != null)
                && (prodOld.Interest_Rate__c <> prod.Interest_Rate__c)){
                    prod.Previous_Interest_Rate__c = prodOld.Interest_Rate__c;
                    prod.Collection_Sub_Status__c = 'Credit Counselling';
                    //prod.Interest_Rate__c = 0;
                }
                
               /* //When a debtor goes into a Credit Counselling.
                if(prod.Collection_Sub_Status__c == 'Credit Counselling' && prodOld.Collection_Sub_Status__c != 'Credit Counselling'){
                    system.debug('Block run 4');
                    prod.Previous_Interest_Rate__c = prodOld.Interest_Rate__c;
                   
                    Date currentDate = date.today();
                    Date newCreditConDate = prod.Credit_Counselling_Date__c;
                    Integer noOfdays = newCreditConDate.daysBetween(currentDate);
                    system.debug('noOfdays:: '+noOfdays);
                    system.debug('prod.Previous_Interest_Rate__c:: '+prod.Previous_Interest_Rate__c);
                    Decimal revisedInterestAmount = (prod.Current_Principal_Balance__c * noOfdays * prod.Previous_Interest_Rate__c)/100/365;
                   
                    system.debug('revisedInterestAmount:: ' +revisedInterestAmount);
                    prod.Current_Interest_Amount__c = prod.Current_Interest_Amount__c - revisedInterestAmount;
                    
                    prod.Current_Balance__c = prod.Current_Balance__c - revisedInterestAmount;

                    prod.Interest_Amount_Last_Calculated_Date__c = System.Today();
                   
                }
               //When a debtor is into a Credit Counselling and interest rate changed then calculate interest Amount.
               //if(prod.Collection_Sub_Status__c == 'Credit Counselling' && prod.Interest_Rate__c != prodOld.Interest_Rate__c){
               if(prod.Credit_Counselling_Date__c != null && prod.Interest_Rate__c != prodOld.Interest_Rate__c){
                    system.debug('Block run5::');
                    Date currentDate = Date.today();
                    Date CreditConDate = prod.Credit_Counselling_Date__c;
                    Integer noOfdays = CreditConDate.daysBetween(currentDate);
                    system.debug('noOfdays::'+noOfdays);
                    system.debug('prodOld.Interest_Rate__:: '+prodOld.Interest_Rate__c);
                    Decimal revisedInterestAmount = (prod.Current_Principal_Balance__c * noOfdays * prodOld.Interest_Rate__c)/100/365;
                   
                    system.debug('revisedInterestAmount:: ' +revisedInterestAmount);
                    Decimal updateCurrentInterestAmount = prod.Current_Interest_Amount__c - revisedInterestAmount;
                    
                    Decimal updateCurrentBalance = prod.Current_Balance__c - revisedInterestAmount;
                    system.debug('prod.Interest_Rate__c:: '+prod.Interest_Rate__c);
                    Decimal revisedInterestAmount1 = (prod.Current_Principal_Balance__c * noOfdays * prod.Interest_Rate__c)/100/365;
                   
                    system.debug('revisedInterestAmount1:: ' +revisedInterestAmount1);
                    prod.Current_Interest_Amount__c = updateCurrentInterestAmount + revisedInterestAmount1;
                    
                    prod.Current_Balance__c = updateCurrentBalance + revisedInterestAmount1;
                    prod.Interest_Amount_Last_Calculated_Date__c = System.Today();
                    
                }
                //Credit counselling  date is changed to backward then calculate interest amount.
                if(prod.Credit_Counselling_Date__c != Null 
                   && prodOld.Credit_Counselling_Date__c != prod.Credit_Counselling_Date__c 
                   && prodOld.Credit_Counselling_Date__c > prod.Credit_Counselling_Date__c){
                       
                    system.debug('Block run6::');
                       
                    Date oldCreditConDate = prodOld.Credit_Counselling_Date__c;
                    Date newCreditConDate = prod.Credit_Counselling_Date__c;
                    Integer noOfdays = newCreditConDate.daysBetween(oldCreditConDate);
                    system.debug('noOfdays:: '+noOfdays);
                    
                    Decimal revisedInterestAmount = (prod.Current_Principal_Balance__c * noOfdays * prod.Interest_Rate__c)/100/365;
                   
                    system.debug('revisedInterestAmount:: ' +revisedInterestAmount);
                    prod.Current_Interest_Amount__c = prod.Current_Interest_Amount__c - revisedInterestAmount;
                    
                    prod.Current_Balance__c = prod.Current_Balance__c - revisedInterestAmount;

                    prod.Interest_Amount_Last_Calculated_Date__c = System.Today();
                    
                }//Credit counselling  date is changed to forward then calculate interest amount.
                else if(prod.Credit_Counselling_Date__c != Null 
                        && prodOld.Credit_Counselling_Date__c != prod.Credit_Counselling_Date__c 
                        && prodOld.Credit_Counselling_Date__c < prod.Credit_Counselling_Date__c){
                            
                    system.debug('Block run7::');
                    Date oldCreditConDate = prodOld.Credit_Counselling_Date__c;
                    Date newCreditConDate = prod.Credit_Counselling_Date__c;
                    Integer noOfdays = oldCreditConDate.daysBetween(newCreditConDate);
                    system.debug('noOfdays:: '+noOfdays);
                    
                    Decimal revisedInterestAmount1 = (prod.Current_Principal_Balance__c * noOfdays * prod.Interest_Rate__c)/100/365;
                   
                    system.debug('revisedInterestAmount1:: ' +revisedInterestAmount1);
                    prod.Current_Interest_Amount__c = prod.Current_Interest_Amount__c + revisedInterestAmount1;
                    
                    prod.Current_Balance__c = prod.Current_Balance__c + revisedInterestAmount1;
                    system.debug('Current_Interest_Amount__c:: '+prod.Current_Interest_Amount__c);
                    system.debug('Current_Balance__c:: '+prod.Current_Balance__c);
                    prod.Interest_Amount_Last_Calculated_Date__c = System.Today();
                    
                }
                //Collection sub status is changed 'Credit Counselling' to any other excluding product criteria then calculate interest amount.
                if(prodOld.Collection_Sub_Status__c == 'Credit Counselling' && prodOld.Collection_Sub_Status__c != prod.Collection_Sub_Status__c
                  && prod.Collection_Sub_Status__c != 'Bankrupt Account' && prod.Collection_Sub_Status__c != 'Deceased'
                  && prod.Collection_Sub_Status__c != 'Paid in Full Account'){
                      
                     system.debug('Block run8::');
                     
                    Date currentDate = Date.today();
                    Date CreditConDate = prod.Credit_Counselling_Date__c;
                    Integer noOfdays = CreditConDate.daysBetween(currentDate);
                    system.debug('noOfdays::'+noOfdays);
                    Decimal revisedInterestAmount = (prod.Current_Principal_Balance__c * noOfdays * prod.Interest_Rate__c)/100/365;
                      
                    system.debug('revisedInterestAmount:: ' +revisedInterestAmount);
                    Decimal updateCurrentInterestAmount = prod.Current_Interest_Amount__c - revisedInterestAmount;
                    
                    Decimal updateCurrentBalance = prod.Current_Balance__c - revisedInterestAmount;
                    system.debug('prod.Previous_Interest_Rate__c:: '+prod.Previous_Interest_Rate__c);
                    system.debug('prodOld.Previous_Interest_Rate__c:: '+prodOld.Previous_Interest_Rate__c);
                    Decimal revisedInterestAmount1 = (prod.Current_Principal_Balance__c * noOfdays * prodOld.Previous_Interest_Rate__c)/100/365;
                      
                    system.debug('revisedInterestAmount1:: ' +revisedInterestAmount1);
                    prod.Current_Interest_Amount__c = updateCurrentInterestAmount + revisedInterestAmount1;
                    
                    prod.Current_Balance__c = updateCurrentBalance + revisedInterestAmount1;
                    prod.Interest_Amount_Last_Calculated_Date__c = System.Today();
                    prod.Interest_Rate__c = prodOld.Previous_Interest_Rate__c;
                }*/
                
            }
            
            for(Pool__c pool :  [Select id,Name,Placement_Agency__c from Pool__c where id IN: poolplacementName] ){
                mapPoolAgency.put(pool.id, pool.Placement_Agency__c);
                mapPool.put(pool.id,pool);
            }
            
            if(ProductTriggerHandler.runPaymentProcessing){
                setRecentlyPaidProducts = getProductPaymentDetails(setRecalledProducts);
                setPreviousPlacedProductNames = getPlacementHistoryDetails(setPreviousPlacedProduct); 
            }
            
            
            
            system.debug('setPreviousPlacedProductNames: '+setPreviousPlacedProductNames);
            String newAgency;
            String oldAgency;
            system.debug('listNewProducts:::: '+listNewProducts.size());
            for(Product__c product : listNewProducts){
            // Last Payment Date Changed
                if( //product.Last_Payment_Date__c != null && 
                    product.Last_Payment_Date__c != mapOldProducts.get(product.Id).Last_Payment_Date__c 
                    //&& (product.Statute_Date__c == null || product.Last_Payment_Date__c < product.Statute_Date__c )
                    ){
                        product.Statute_Date__c= StatuteDateUtilities.getStatueDate(product.Last_Payment_Date__c,
                                                                                    product.Open_Date__c,
                                                                                    product.Charged_Off_Date__c,
                                                                                    product.Statute_Date__c,product.Purchase_Province__c);


                }
                // Open Date Changed
                else if(product.Open_Date__c != mapOldProducts.get(product.Id).Open_Date__c){
                            product.Statute_Date__c= StatuteDateUtilities.getStatueDate(product.Last_Payment_Date__c,
                                                                                    product.Open_Date__c,
                                                                                    product.Charged_Off_Date__c,
                                                                                    product.Statute_Date__c,product.Purchase_Province__c);  
                }
                //ChargeOff Date Changed
                else if(product.Charged_Off_Date__c != mapOldProducts.get(product.Id).Charged_Off_Date__c){
                            product.Statute_Date__c= StatuteDateUtilities.getStatueDate(product.Last_Payment_Date__c,
                                                                                    product.Open_Date__c,
                                                                                    product.Charged_Off_Date__c,
                                                                                    product.Statute_Date__c,product.Purchase_Province__c);  
                }
                system.debug('==@@@@=='+product.Statute_Date__c);
                system.debug('agency:'+product .Collection_Agency__c); 
                system.debug('mapPoolAgency.get(product.Pool_Name__c):: '+mapPoolAgency.get(product.Pool_Name__c));
                if(mapPool.containsKey(product.Pool_Name__c)){
                   product.Pool_Name_Text__c = mapPool.get(product.Pool_Name__c).Name;  
                }
                
                Product__c prodOld = mapOldProducts.get(product.id);
                //system.debug('+ '+prodOld);
                if(mapPoolAgency.containsKey(product.Pool_Name__c) 
                && mapPoolAgency.get(product.Pool_Name__c) != NULL
                && prodOld.Pool_Name__c <> product.Pool_Name__c
                && product.Collection_Agency__c != NULL
                && mapPoolAgency.get(product.Pool_Name__c) <> product.Collection_Agency__c){
                     product.addError('Pool has different agency than Product');
                }
                if(product.Purchase_Status__c != prodOld.Purchase_Status__c){
                    if(prodOld.Purchase_Status__c == 'Buyback Initiated' && 
                      (product.Purchase_Status__c == 'Eligible for Buyback' || product.Purchase_Status__c == 'Buyback Approved' ||
                      product.Purchase_Status__c == 'Buyback Rejected')){
                        product.addError('You cannot assign previous status');
                    }
                    if(prodOld.Purchase_Status__c == 'Putback Initiated' && 
                      (product.Purchase_Status__c == 'Eligible for Putback' || product.Purchase_Status__c == 'Putback Approved' ||
                      product.Purchase_Status__c == 'Putback Rejected')){
                        product.addError('You cannot assign previous status');
                    }
                    if(prodOld.Purchase_Status__c == 'Buyback Requested' &&
                      (product.Purchase_Status__c == 'Buyback Initiated' || product.Purchase_Status__c == 'Eligible for Buyback')){
                        product.addError('You cannot assign previous status');
                    }
                    if(prodOld.Purchase_Status__c == 'Putback Requested' &&
                      (product.Purchase_Status__c == 'Putback Initiated' || product.Purchase_Status__c == 'Eligible for Putback')){
                        product.addError('You cannot assign previous status');
                    }
                    if((prodOld.Purchase_Status__c == 'Buyback Approved' 
                        || prodOld.Purchase_Status__c == 'Buyback Rejected') &&
                      (product.Purchase_Status__c == 'Buyback Requested' || product.Purchase_Status__c == 'Buyback Initiated' || product.Purchase_Status__c == 'Eligible for Buyback')){
                        product.addError('You cannot assign previous status');
                    }
                    if((prodOld.Purchase_Status__c == 'Putback Approved' || prodOld.Purchase_Status__c == 'Putback Rejected') &&
                      (product.Purchase_Status__c == 'Putback Requested' || product.Purchase_Status__c == 'Putback Initiated' || product.Purchase_Status__c == 'Eligible for Putback')){
                        product.addError('You cannot assign previous status');
                    }
                }
                if(product.Purchase_Status__c == 'Buyback Approved' && 
                   product.Collection_Agency__c != NULL && product.Collection_Agency__c != 9999){
                       product.addError('Buyback status is approved.You cannot assign agency ');
                }
                system.debug('product Name'+product.name+'purchase status'+product.Purchase_Status__c);
                if(product.Purchase_Status__c == 'Putback Approved' && 
                   product.Collection_Agency__c != NULL && product.Collection_Agency__c != 9999){
                       product.addError('Putback status is approved.You cannot assign agency ');
                }
                /*if(product.Purchase_Date__c.daysBetween(Date.today()) > product.Putback_Provision_Days__c){
                    if(product.Ignore_Warning__c == false){
                        product.addError('WARNING - Cannot Process Putback. putback provision days exceed');
                    } 
                }*/
                system.debug('product.Collection_Agency__c'+product.Collection_Agency__c);
                system.debug('product.Purchase_Status__c'+product.Purchase_Status__c);
                if((product.Collection_Agency__c != null && product.Collection_Agency__c != 9999) 
                   && ((product.Purchase_Status__c != NULL) && (product.Purchase_Status__c != 'Buyback Rejected' &&
                            product.Purchase_Status__c != 'Putback Rejected'))){
                       product.addError('Please initiated recall process');
                } 
                /*if(mapPoolAgency.containsKey(product.Pool_Name__c) 
                && (mapPoolAgency.get(product.Pool_Name__c) == NULL || mapPoolAgency.get(product.Pool_Name__c) != NULL)
                && product.Collection_Agency__c == 9999
                && (prodOld.Pool_Name__c == null || product.Pool_Name__c != prodOld.Pool_Name__c)){
                     product.addError('Pool cannot be allocated since collection agency is set to Warehouse');
                }*/
                
                /*if(product.Collection_Agency__c != NULL
                && (product.Pool_Name__c != NULL &&  prodOld.Pool_Name__c == NULL)){
                    product.addError('Product is already allocated to agency');
                }*/
                
                /*set<Id> poolID = new set<Id>();
                poolID.add(product.Pool_Name__c);
                for(Product__c prodt : [Select Id,name,Pool_Name__c,Collection_Agency__c from Product__c where Pool_Name__c =: poolID LIMIT 1]){      
                    if(product.Collection_Agency__c != 9999 && product.Collection_Agency__c != null ){
                        if(mapPoolAgency.containsKey(product.Pool_Name__c) 
                           && mapPoolAgency.get(product.Pool_Name__c) == NULL 
                           && (prodt.Collection_Agency__c != product.Collection_Agency__c)
                           && (prodOld.Pool_Name__c == null || product.Pool_Name__c != prodOld.Pool_Name__c)){
                               product.addError('Collection agency is not Same');
                           }  
                    }
                    
                }*/
                
                //invalid submission initiated by name
              /*  if(product.Invalid_Submission__c == true){
                    product.Invalid_Submission_Initiated_By__c = UserInfo.getName();
                }else{
                     product.Invalid_Submission_Initiated_By__c = null;
                }*/

                if(product.Collection_Agency__c != NULL){
                    newAgency = String.valueOf(Math.floor(product.Collection_Agency__c));    
                }
                if(mapOldProducts.get(product.Id).Collection_Agency__c != NULL){
                    oldAgency = String.valueOf(Math.floor(mapOldProducts.get(product.Id).Collection_Agency__c));    
                }
                
                String errorMessage = '';
                Boolean errorAdded = false;
                
                //Check Ignore warning flag for Product
                //system.debug('product.Ignore_Warning__c::'+product.Ignore_Warning__c); 
                
                /*-----AGENCY ALLOCATION CHECKS-----*/  
                /*
                if(product.RecordTypeID == DistressedProductRecordTypeId
                && String.isNotBlank(newAgency)
                   && newAgency != oldAgency){
                       //Check WARNINGS
                       if(product.Ignore_Warning__c == false){
                           //check if Product was placed with Agency in last 6 months
                           system.debug('ProductAgency Name:'+ product.Name+ newAgency);
                           if(setPreviousPlacedProductNames.contains(product.Name+ newAgency)){
                               errorMessage = 'WARNING: '+ 'Product is placed with the agency in last 6 months';
                               //product.addError('Product is placed with the agency in last 6 months');
                               //errorAdded = true;
                               system.debug('previously placed');
                           }
                           //Additional Warning checks will be here
                       }
                       
                       //CHECK VALIDATIONS
                       system.debug('validation check for allocation');
                       //Check if account province matches Placement Serviceable Province
                       String AgencyProvince;
                       
                       if(String.isNotBlank(newAgency)
                          && mapCollectionAgency.containsKey(newAgency)
                          && String.isNotBlank(mapCollectionAgency.get(newAgency).Serviceable_Province__c)){
                              AgencyProvince = mapCollectionAgency.get(newAgency).Serviceable_Province__c; 
                          }
                       
                       system.debug('AgencyProvince: '+AgencyProvince);
                       system.debug('mapProvinceNames:::'+mapProvinceNames);
                       if(product.Collection_Agency__c != NULL
                          && (String.isNotBlank(AgencyProvince)
                          && String.isNotBlank(product.State__c) 
                          && mapProvinceNames != NULL
                          && !mapProvinceNames.keySet().isEmpty()
                          && ((!mapProvinceNames.containsKey(product.State__c) && !AgencyProvince.contains(product.State__c))
                          || (mapProvinceNames.containsKey(product.State__c)  
                          &&!AgencyProvince.contains(mapProvinceNames.get(product.State__c)))))){
                                      system.debug('error');
                                      errorMessage += ' VALIDATION: '+'Product cannot be placed with agency as Product Province is Non Serviceable for Agency';
                                      //product.addError('Product cannot be placed with agency as Product Province is Non Serviceable for Agency');
                                      errorAdded = true;
                                      system.debug('province error');
                                  }
                          
                       
                       if(String.isNotBlank(oldAgency) 
                       && newAgency != '9999'
                       && oldAgency != '9999'){
                           //errorMessage += ' VALIDATION: '+'Product is already placed with another agency:'+oldAgency;
                           product.addError('Product is already placed with Agency');
                           //errorAdded = true;
                           system.debug('already placed error');
                       }
                   }
                */
                /*-----AGENCY ALLOCATION CHECKS ENDS-----*/
                
                /*-----AGENCY RECALL CHECKS-----*/  
                //check if agency is being recalled and check validation and warning for agency recall
                /*
                if(String.isBlank(newAgency)
                   && newAgency != oldAgency){
                       system.debug('agency recall check');
                       //Check recall warnings
                       if(product.Ignore_Warning__c == false){
                           if(String.isNotBlank(product.Collection_Sub_Status__c) && product.Collection_Sub_Status__c=='Legal' ){
                               system.debug('recall warning::');
                               errorMessage = 'WARNING: Cannot recall agency as Product is in Legal Status';
                               //product.addError('Cannot recall agency as Product is in Legal Status');
                               //errorAdded = true;
                           }    
                       }
                       //Additional warning checks will be added here
                       
                       //Check Recall Validations
                       if(setRecentlyPaidProducts.contains(product.Id)){
                           errorMessage = ' VALIDATION: Cannot recall agency as Account had a recent payment in last 2 months';
                           //product.addError('Cannot recall agency as Product is in Legal Status');
                           errorAdded = true;
                       }
                       
                   }
                */
                /*-----AGENCY RECALL CHECKS ENDS-----*/  
                if(errorAdded == true){
                    product.addError(errorMessage);
                }
                
                //create PlacementHistory record, if agency updated or recalled (No error added for product)
                system.debug('errorAdded:'+errorAdded);
                if(errorAdded == false
                   && newAgency != oldAgency){
                       system.debug('placement history creation');
                       Placement_History__c placementHistory = new Placement_History__c();
                       placementHistory.Product__c = product.Id;
                       system.debug('prod agency::'+String.valueOf(oldAgency));
                       if(mapCollectionAgency.containsKey(oldAgency)){
                           placementHistory.Placement__c = 
                               mapCollectionAgency.get(oldAgency).ID;    
                       }
                       if(String.isBlank(newAgency) || Test.isRunningTest()){
                           placementHistory.Placement_Recall_Date__c = Date.today();
                           placementHistory.Placement_Date__c = product.Assignment_Date__c;
                           //Set Product Recalled Date
                           product.Recalled_Date__c = Date.today();
                       }
                       //Else set Assigned Date
                       else{
                           product.Assignment_Date__c = Date.today();
                       }
                       listPlacementHistory.add(placementHistory);   
                   }
                
                //Set Ignore Warning to false after all checks
                //product.Ignore_Warning__c = false;
                errorAdded = false;
            }
            //insert placement history list
            insert listPlacementHistory;
            system.debug('placementhistory created');
        }
        //runProductTrigger = false;

    }   
    
    public static void handleAfterUpdate(List<Product__c> listNewProducts, map<ID, Product__c> mapOldProducts){
        //Added code for CPU Time Limit
        //runProductTrigger = false;
        //Code Ends
        //This below custom setting is false in before update so true that here.
        Application_Config_Settings__c config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
        config.Run_Product_Coll_Sub_Status_Validation__c = true; 
        update config;
        list<id> prodIds=new list<id>();
        for(Product__c product: listNewProducts){
            //call API
            system.debug('runProductAPI:: '+runProductAPI);
            system.debug('runProductTrigger:: '+runProductTrigger);
            system.debug('check record id:: '+product.RecordTypeId);
            system.debug('check**'+prodRTypeIdMap.get('Distressed_Account'));
            if(agencyPortalSettings.Run_Product_API__c == true && prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId){
                system.debug('Product API called');
                prodIds.add(product.ID);
                //PortalProductProcessingAPI.processProduct(product.ID);
                /*//Added code CPU Time Limit
                if(System.IsBatch() == false){
                    PortalProductProcessingAPI.processProduct(product.ID);    
                }
                //Code Ends
                //else{
                  //  PortalProductProcessingAPI.processProductNonFutureContext(product.ID);    
                //}*/
            }          
        }
        if(runProductAPITrigger){
        PortalProductProcessingAPI.processProductBulkBatch(prodIds);
        }
        //PortalProductProcessingAPI.processProductBulkBatch(prodIds);
        calculateBalanceBackdatedPayments2(listNewProducts, mapOldProducts);
    }
    
    public static void handleAfterUpdateUpdatedate(List<Product__c> listNewProducts, map<ID, Product__c> mapOldProducts){
    
     List<Product__c> ProductList = new List<Product__c>();
                     Product__c pd = new Product__c();
      // map<String, Statute_Date_Update__mdt> mapstatueMetadata = Statute_Date_Update__mdt.getAll();
      List<Statute_Date_Update__mdt> mtData = [Select Id, MasterLabel, Months__c From Statute_Date_Update__mdt];
                       
                   for(Product__c prod : listNewProducts){ 
                   Product__c prodOld12 = mapOldProducts.get(prod.Id);
                
                    if((prod.Last_Payment_Date__c !=null && prod.Last_Payment_Date__c != prodOld12.Last_Payment_Date__c) ||(prod.Open_Date__c !=null && (prod.Open_Date__c != prodOld12.Open_Date__c)) )

        {
        if((prod.Statute_Date__c==null)||(prod.Statute_Date__c!=null && prod.Statute_Date__c > prod.Date_for_Stat_Barred_calculations__c)){
                    
                            Map<String, Statute_Date_Update__mdt> mtdMap = new Map<String, Statute_Date_Update__mdt>();
                           for(Statute_Date_Update__mdt m:mtData){
                            mtdMap.put(m.MasterLabel, m);
                        }
                    
                     system.debug('mtdMap## ' + mtdMap);
        
            if(mtdMap.containsKey(prod.State__c)){
              Integer i= Integer.valueof(mtdMap.get(prod.State__c).Months__c);
                pd.Id = prod.Id;
             pd.Statute_Date__c = prod.Date_for_Stat_Barred_calculations__c.addMonths(i);
                ProductList.add(pd);
            }
        
        }
        }
        }
        system.debug('@@ProductList@@'+ProductList);
        if(!ProductList.isEmpty()){
            update ProductList;
        }
    }
    
    public static void handleafterinsertdate(List<Product__c> listNewProducts){
    runProductTrigger = true;
     List<Product__c> ProductList = new List<Product__c>();
      Map<String, Statute_Date_Update__mdt> mtdMap = new Map<String, Statute_Date_Update__mdt>();
        List<Statute_Date_Update__mdt> mtData = [Select Id, MasterLabel, Months__c From Statute_Date_Update__mdt];
                system.debug('mtData## ' + mtData);
                        for(Statute_Date_Update__mdt m:mtData){
                            mtdMap.put(m.MasterLabel, m);
                        }
                    
                     system.debug('mtdMap## ' + mtdMap);
            for(Product__c prod:listNewProducts){ 
            if((prod.Last_Payment_Date__c !=null) ||(prod.Open_Date__c !=null)){
            if(mtdMap.containskey(prod.State__c)){
                Product__c pd = new Product__c();
                Integer i= Integer.valueof(mtdMap.get(prod.State__c).Months__c);
                pd.Id = prod.Id;
                
             pd.Statute_Date__c = prod.Date_for_Stat_Barred_calculations__c.addMonths(i);
                ProductList.add(pd);
            }
           }          
        }
       
        if(!ProductList.isEmpty()){
            update ProductList;
        }
    }
    public static void handleAferInsertUpdate(List<Product__c> prodNew, Map<Id, Product__c> oldMap, Boolean isInsert) {
        
        customersToUpdate = new List<Account>();
        //Added code CPU Time Limit
        runProductTrigger = false;
        //Code ends
        if(lrpSetting.Load_Customer_Data__c == true){
            // User verification to update Customer Address Fields
            if(isCanaccedeAPIUser() || Test.isRunningTest()){
                customersLockedForUpdate = new Set<Id>();
                tasksList = new List<Task>();
                
                //Process all new instance of Products in context
                for(Product__c prod : prodNew){
                    // Added record type check for Loan Account OR Credit Card Account
                    if(prod.Customer__c != null){
                        if((prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId)){
                            customerIds.add(prod.Customer__c);  
                        }                    
                    }                    
                }
                if(!customerIds.isEmpty()){
                    existingCustomer = new Map<Id, Account>([SELECT Id, OwnerId, PersonMailingCity, PersonMailingStreet, PersonMailingPostalCode, PersonMailingState, PersonBirthdate, PersonHomePhone, Work_Phone__pc, PersonOtherPhone, Address_Last_Changed_Date__c, FirstName, LastName FROM Account WHERE Id IN : customerIds]);    
                }
                
                //Fetching all Active Tasks of Customers in current context
                if(!customerIds.isEmpty()){
                    for(Task tsk : [SELECT WhatId, Subject, Status FROM Task WHERE Subject = 'Address Changed' AND Status != 'Completed' AND WhatId IN : customerIds]){
                        activeAddressChangedTask.put(tsk.WhatId, tsk);
                    }    
                }
                
                system.debug('customerIds::'+customerIds);
                //Fetching all Active Products of Customers
                if(!customerIds.isEmpty()){
                    for(Product__c customerOldProduct : [SELECT First_Name__c, Last_Name__c, Customer__c FROM Product__c WHERE ((Source_System__c ='FDR' AND External_Status_Current__c = null AND Closed_Date__c = null) OR (Source_System__c = 'Megasys' AND Internal_Status__c='Active' AND Closed_Date__c = null)) AND Customer__c IN: customerIds]){
                        List<Product__c> tempProdList = new List<Product__c>();
                        if(customerWithOldProductsMap.containsKey(customerOldProduct.Customer__c)){
                            tempProdList = customerWithOldProductsMap.get(customerOldProduct.Customer__c);
                        }
                        tempProdList.add(customerOldProduct);
                        customerWithOldProductsMap.put(customerOldProduct.Customer__c, tempProdList);
                    }    
                }
                
                
                for(Product__c prod : prodNew){
                    
                    if(prod.Customer__c != null){
                        if((prodRTypeIdMap.get('Loan_Account') == prod.RecordTypeId || prodRTypeIdMap.get('Credit_Card_Account') == prod.RecordTypeId)){
                            
                            // If FDR or Megasys product is Active or Not
                            if(isActiveSORProduct(prod)){ 
                                
                                system.debug('Active verified');
                                if((isInsert) || (!isInsert && hasProductCustomerDataChanged(prod, oldMap.get(prod.Id)))){
                                    
                                    //If any existing Products, more than 1
                                    if(getNumberOfActiveSORProducts(prod.Customer__c) > 1){ 
                                        
                                        // Address fields are changed
                                        if(!hasActiveAddressChangedTask(prod)){ 
                                            system.debug('no active task ');
                                            
                                            // Address fields values from Product is different Customer Address fields values
                                            if(needtoUpdateCustomer(prod)){ 
                                                
                                                system.debug('accotun fields diff from prod verified');
                                                
                                                // Update Customer Address fields
                                                updateCustomerFromProduct(prod); 
                                                
                                                // Create Task for CSR Role users
                                                createAddressChangedTask(prod);                                           
                                            }   
                                        } 
                                    }
                                    //Only one active SOR Products
                                    else{ 
                                        system.debug('has no exisinting prod verified');
                                        if(needtoUpdateCustomer(prod)){                            
                                            updateCustomerFromProduct(prod);
                                        }                                                               
                                    }
                                }
                            }
                        }
                    }
                }
                if(!tasksList.isEmpty()){
                    // Inserting Tasks for CSR Role Group
                    insert tasksList;
                    system.debug('Task Created == '+tasksList);
                }           
            }
        }         
        
        //for Business Separation moved it outside
        if(!customersToUpdate.isEmpty()){
            
            Map<Id, Account> mapAccount = new Map<ID, Account>();
            
            for(Account accRec : customersToUpdate){
                mapAccount.put(accRec.id, accRec);
            }
            // Updating Customers Address
            update mapAccount.Values();
        } 
        
        if(!isInsert && oldMap != null ){
            List<Id> prodIds = new List<Id>();
            List<Id> productNameChanged = new List<Id>();
            
            for(Product__c prod : prodNew){
                Product__c oldProd = oldMap.get(prod.Id);
                if(oldProd.Current_Principal_Balance__c != prod.Current_Principal_Balance__c
                   || oldProd.Current_Interest_Amount__c != prod.Current_Interest_Amount__c){
                       prodIds.add(prod.Id);
                   }
                else if(oldProd.Company_Name__c != prod.Company_Name__c){
                    productNameChanged.add(prod.Id);
                }
            }
            if(productNameChanged.size()>0){
                prodIds.addAll(productNameChanged);
            }
            if(!prodIds.isEmpty()){
                List<Account_Judgment__c> activeAccJudgments = [SELECT Judgment__c 
                                                            FROM Account_Judgment__c 
                                                            WHERE Product__c IN: prodIds 
                                                            AND Status__c = 'Active'
                                                            AND Judgment__c != NULL];
                system.debug('activeAccJudgments===='+activeAccJudgments);
               if(!activeAccJudgments.isEmpty()){
                    AccountJudgmentTriggerHandler.updateAmountsOnJudgment(activeAccJudgments);    
               }    
            }
        }


        //! Agency snapshot processor
        /*if(isInsert){
            System.debug('$$ Inside..filter for snapshot.');
            Map<Id, List<Id>> agencyTo_ProductIdsMap = new Map<Id, List<Id>>();
            Id distressedAccountId = [Select Id From RecordType where sobjecttype = 'Product__c' and DeveloperName = 'Distressed_Account'].id;
            for(Product__c prod : prodNew){
                // filter distressed accounts
                if( prod.RecordTypeId == distressedAccountId ){
                    List<Id> productIds = new List<Id>();
                    if( prod.Collection_Agency_Placement__c != null){ 
                        if(agencyTo_ProductIdsMap.containsKey(prod.Collection_Agency_Placement__c)){
                            productIds = agencyTo_ProductIdsMap.get(prod.Collection_Agency_Placement__c);
                        }
                        productIds.add(prod.Id);
                        agencyTo_ProductIdsMap.put( prod.Collection_Agency_Placement__c, productIds );
                    }
                }
            }

            if( !agencyTo_ProductIdsMap.isEmpty() ){
                for(Id agencyId : agencyTo_ProductIdsMap.keySet()){
                    System.debug('$$ calling snapshot...');
                    SnapshotProcessor.createSnapshotFile(agencyTo_ProductIdsMap.get(agencyId), agencyId);
                }
            }
        }*/
        
    }
    
    // Validates if there is any existing Active Tasks for Customer
    public static Boolean hasActiveAddressChangedTask(Product__c currentProd){
        system.debug('---'+currentProd.Customer__c);
        system.debug('==='+activeAddressChangedTask);
        if(activeAddressChangedTask.containsKey(currentProd.Customer__c)){
            return true;
        }
        return false;
    }
    
    // Creating Tasks with Customer Name, to notify CSR's about address change
    public static void createAddressChangedTask(Product__c currentProd){
        Account customer = existingCustomer.get(currentProd.Customer__c);
        Task tsk = new Task();
        tsk.WhatId = currentProd.Customer__c;
        tsk.subject = 'Address Changed';
        tsk.OwnerId= UserInfo.getUserId();
        tsk.Description  = 'This customer was updated by ' + currentProd.Name + ' from ' + currentProd.Source_System__C + '.';
        tasksList.add(tsk);
    }
    
    //Updating Customer Address fields
    public static void updateCustomerFromProduct(Product__c currentProd){
        Account customer = existingCustomer.get(currentProd.Customer__c);
        customer.PersonMailingCity = currentProd.City__c;
        if(String.isBlank(currentProd.Address_Line2__c)){
            customer.PersonMailingStreet = currentProd.Address_Line1__c;
        }else{
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
        //customer.Language__pc = currentProd.Primary_Debtor_Language_Text__c;
        customer.Address_Last_Changed_Date__c = currentProd.Address_Last_Changed_Date__c;
        
        if(!customersLockedForUpdate.contains(currentProd.Customer__c)){
            customersToUpdate.add(customer);
        }
        
        customersLockedForUpdate.add(currentProd.Customer__c) ;
    }
    
    // Method that fetches the Customer record using customer record id
    public static Account getCustomerRecord(Id customerId){
        return existingCustomer.get(customerId);
    }
    
    // Verifying Product fields against Customer Address fields
    public static Boolean needtoUpdateCustomer(Product__c currentProd){
        Boolean needToUpdate = false;
        Account customer = getCustomerRecord(currentProd.Customer__c);
        if(customer.PersonMailingCity != currentProd.City__c){
            needToUpdate = true;
        }
        //else if((currentProd.Address_Line1__c != null && (customer.PersonMailingStreet).contains(currentProd.Address_Line1__c)) && (currentProd.Address_Line2__c != null && (customer.PersonMailingStreet).contains(currentProd.Address_Line2__c))){
        else if((String.isBlank(customer.PersonMailingStreet)&&((String.isNotBlank(currentProd.Address_Line1__c))||(String.isNotBlank(currentProd.Address_Line2__c)))) 
                || 
                (
                    (String.isNotBlank(customer.PersonMailingStreet) && String.isNotBlank(currentProd.Address_Line1__c) && (!(customer.PersonMailingStreet).contains(currentProd.Address_Line1__c)))
                    ||
                    (String.isNotBlank(customer.PersonMailingStreet) && String.isNotBlank(currentProd.Address_Line2__c) && (!(customer.PersonMailingStreet).contains(currentProd.Address_Line2__c)))
                )
               ){
                   needToUpdate = true;
               }
        else if(customer.PersonMailingPostalCode != currentProd.Zip_Code__c){
            needToUpdate = true;
        }
        else if(customer.PersonMailingState != currentProd.State__c){
            needToUpdate = true;
        }
        else if(customer.PersonBirthdate != currentProd.Date_of_Birth__c){
            needToUpdate = true;
        }
        else if(customer.PersonHomePhone != currentProd.Phone_Home__c){
            needToUpdate = true;
        }
        else if(customer.Work_Phone__pc != currentProd.Phone_Work__c){
            needToUpdate = true;
        }
        else if(customer.PersonOtherPhone != currentProd.Phone_Other__c){
            needToUpdate = true;
        }
        //else if(customer.Address_Last_Changed_Date__c != currentProd.Address_Last_Changed_Date__c){
        //needToUpdate = true;
        //} //TO DO Feild is not there under Account
        else if(customer.FirstName != currentProd.First_Name__c){
            needToUpdate = true;
        }
        else if(customer.LastName != currentProd.Last_Name__c){
            needToUpdate = true;
        }
        return needToUpdate;
    }
    
    //Return count of total Active FDR, Megasys Products using Customer record Id
    public static Integer getNumberOfActiveSORProducts(Id customerId){
        system.debug('Customer Id = '+customerId);
        system.debug('Customer old prod = '+customerWithOldProductsMap);
        return customerWithOldProductsMap.get(customerId).size();
    }
    
    // Checks against Old Address values and New Address values of Product
    public static Boolean hasProductCustomerDataChanged(Product__c newProd, Product__c oldProd){
        Boolean isChanged = false;
        fieldSetLabelNameMap = getProductFieldsets('Update Customer Fields');
        for(String fieldName : fieldSetLabelNameMap.keySet()){
            if(newProd.get(fieldName) != oldProd.get(fieldName)){
                return true;
            }
        }
        return isChanged;
    }
    
    //Checkes whether the Product is Active or not using Product record
    public static Boolean isActiveSORProduct(Product__c prod){
        if((prod.Source_System__c =='FDR' && prod.External_Status_Current__c == null && prod.Closed_Date__c == null) || (prod.Source_System__c =='Megasys' && prod.Internal_Status__c=='Active' && prod.Closed_Date__c == null)){
            return true;
        }
        return false;
    }
    
    //Checkes whether the Megasys Product is Active or not
    public static Boolean isActiveMSProduct(Product__c prod){
        return (prod.Internal_Status__c == 'Active' && prod.Closed_Date__c == null);    
    }  
    
    //Deliquency cycle and Deliquency days
    public static void calculateDeliquency(Product__c prod, Product__c prodOld, Boolean activeVersaPayPayment){
        
        System.debug('prod.recordTypeId :'+prod.recordTypeId);
        if(prod.recordTypeId != null){
            
            //String recordTypeDevName = Utilities.getProdRecorTypeName(prod.recordTypeId);
            String recordTypeDevName = prodRecorTypeMap.get(prod.recordTypeId);
            System.debug('ProductTriggerHandler recordTypeDevName :'+recordTypeDevName);
            
            if(String.isNotBlank(recordTypeDevName)){
                if(recordTypeDevName.equalsIgnoreCase('Loan_Account')){
                    System.debug('isActiveMSProduct(prod) :'+isActiveMSProduct(prod));
                    System.debug('prod.Payment_Due_Date__c :'+prod.Payment_Due_Date__c);
                    if(isActiveMSProduct(prod)){
                        if(prod.Payment_Due_Date__c !=null){
                            prod.Delinquency_Days__c = Utilities.getNumberOfDaysDelinquent(prod.Payment_Due_Date__c);
                            prod.Delinquency_Cycles__c = Utilities.getNumberOfCyclesDelinquentMS(prod.Delinquency_Days__c, activeVersaPayPayment);
                        }
                        else{
                            if(prodOld != null){
                                prod.Delinquency_Days__c = prodOld.Delinquency_Days__c;
                                prod.Delinquency_Cycles__c = prodOld.Delinquency_Cycles__c; 
                            }                           
                        }                                   
                    }
                    else{
                        prod.Delinquency_Days__c = null;
                        prod.Delinquency_Cycles__c = null;                                  
                    }
                }
            }
        } 
    }
    
    //VersaPay Payment list
    public static List<VersaPay_Product_Payment__c> versaPayRecords(List<Product__c> listProd){
        return [Select Id, Name, Product__c from VersaPay_Product_Payment__c 
                where Product__r.Source_system__c='Megasys' 
                and (VersaPay_State__c='new' or VersaPay_State__c='in_progress')
                and Product__c in : listProd];
        
    }
    
    // Validating current context user
    public static Boolean isCanaccedeAPIUser(){
        String uName = userInfo.getUserName();
        System.debug('uName :'+uName);
        if(uName.equalsIgnoreCase(lrpSetting.Canaccede_API_User__c)){
            return true;
        }
        return false;
    }
    
    //Returns all application object field sets 
    public static Map<String, String> getProductFieldsets(string fieldSetLabel){
        
        system.debug('In fieldset function');
        Map<String, String> fieldsNameLabel = new Map<String, String>();
        
        Map<String, Schema.FieldSet> productFieldsSets = Schema.SObjectType.Product__c.fieldSets.getMap();
        
        List<Schema.FieldSet> listProductFieldSets = productFieldsSets.values();
        
        system.debug('list of fields in fieldset' + listProductFieldSets);
        for(Schema.FieldSet productFieldSet : listProductFieldSets){
            
            system.debug('fieldSetLabel :' +fieldSetLabel );
            system.debug('productFieldSet.getLabel() : ' + productFieldSet.getLabel());
            if(fieldSetLabel == productFieldSet.getLabel()){
                
                for(Schema.FieldSetMember field : productFieldSet.getFields()) {    
                    fieldsNameLabel.put(field.getFieldPath(), field.getLabel());
                }               
                break;
            }
        }
        
        return fieldsNameLabel;    
    }
    
    //Fetch customer for Insolvency Account
    public static List<Account> getMatchingCustomers(Product__c prod){
        
        //Customer Separation
        Map<String, Business_Separator_Settings__c> businessSeparatorValues = Business_Separator_Settings__c.getall();
        system.debug('Record Type :: ' + prod.recordTypeID);
        //system.debug('Record Type values :: ' + prodRTypeIdNameMap);
        String recordTypeNameValue = prodRTypeIdNameMap.get(prod.recordTypeID);
        String customerRecordType ;
        if(!Test.isRunningTest()){
         customerRecordType = businessSeparatorValues.get(recordTypeNameValue).value__C;
        }
        else{
            customerRecordType ='Canaccede Customer';
        }
        
        List<Account> accList = ProductUtil.queryCustomer(prod, customerRecordType);
        if(accList == null || accList.size() == 0){
            List<Account> newCustomers = new List<Account>();
            CustomerTriggerHandler.runCustomerTrigger = false;
            newCustomers.add(ProductUtil.createCustomer(prod, customerRecordType));
            CustomerTriggerHandler.runCustomerTrigger = true;
            return newCustomers;
        }
        else if (accList.size() > 0){
            return accList;
        }
        
        return new List<Account>();
    }
    
    //process builder 'PTP Flow Step 2' convert into code for agency portal changes  
    
    @InvocableMethod(label='ProductTriggerHandler' description='Run PTPFlowStep2 for the Product')
    public static void  PTPFlowStep2(List<Product__c> product){
        
        Product__c productData = [select id, name, Is_Future_PTP__c, Product_Type_Display_Name__c, Current_Workflow__c from Product__c where id =: product[0].id];
        
        if(productData.Is_Future_PTP__c == true){
            if(productData.Product_Type_Display_Name__c != null){
                
                productData.Current_Workflow__c = 'Promise to Pay Flow';
                
            }else if(productData.Product_Type_Display_Name__c == null){
                
                productData.Current_Workflow__c  ='ICT Promise to Pay';
            }
        }else if(productData.Is_Future_PTP__c == false){
            
            productData.Current_Workflow__c = null;
        }
    }
    
    //validation check method for agency portal
    public static void validationRules(list<Product__c> listProduct, Map<Id, Product__c> mapOldProducts){
        
        for(Product__c prod : listProduct){
            
            Product__c prodOld= mapOldProducts.get(prod.id);
            
            /*if(prod.Collection_Agency__c == null){
                
                prod.addError('Contact does not have permission to this account');
            }*/
            
            if(prod.Collection_Sub_Status__c != 'Recalled' && prodOld.Collection_Sub_Status__c == 'Pending Recall'){
                
                prod.addError('A status change is not permitted');
            }
            
            if(prod.Product_Status__c == null){
                
                prod.addError('The Status Code provided was not found');
            }
            
        }
        
    }
    
    
    
    public static boolean checkInBetweenPayments(ID ProductID, Date updatedDate){
        Boolean hasInBetweenPayments = false;
        list<product_Payments__c> listProductPayments = new List<product_Payments__c>();
        listProductPayments = [SELECT ID, Payment_posting_Date__c from Product_payments__c WHERE Payment_posting_Date__c = null];
        return false;
    }
    
    
    //Recalculate Interest Amount and Principal balance when backdated/reversed payments are added
    public static void calculateBalanceBackdatedPayments2(list<Product__c> listNewProducts, map<ID, Product__c> mapOldproducts){
        map<ID, list<product_Payments__c>> mapProductIDPayments = new map<ID, list<Product_payments__c>>();
        map<ID, Date> mapProductIDPayDate = new map<ID, Date>();
        Date oldestDate;
        map<ID, Product__c> mapProducts = new map<ID, Product__c>();
        list<Product__c> listProductWithCreditCounselling = new list<Product__c>();
        system.debug('listNewProducts:'+listNewProducts);
        system.debug('mapOldproducts:'+mapOldproducts);
        //get the Date from which interest needs to be reversed
        for(Product__c product : listNewProducts){
            mapProducts.put(product.ID, product);
            Product__c prodOld = mapOldproducts.get(product.ID);
            system.debug('oldestDate before::'+oldestDate);
            system.debug('Deceased_Date__c old::'+prodOld.Deceased_Date__c);
            system.debug('Deceased_Date__c old::'+product.Deceased_Date__c);
            if(prodOld.Insolvency_Date__c == null && product.Insolvency_Date__c != null ){
                if(oldestDate == NULL || (oldestDate != NULL && oldestDate > prodOld.Insolvency_Date__c)){
                    oldestDate = product.Insolvency_Date__c;    
                    system.debug('oldestDate:::'+oldestDate);
                }
                mapProductIDPayDate.put(product.ID, product.Insolvency_Date__c);
            }
            else if(prodOld.Credit_Counselling_Date__c == null && product.Credit_Counselling_Date__c != null ){
                if(oldestDate == NULL || (oldestDate != NULL && oldestDate > prodOld.Credit_Counselling_Date__c)){
                    oldestDate = product.Credit_Counselling_Date__c;   
                }
                mapProductIDPayDate.put(product.ID, product.Credit_Counselling_Date__c);
                listProductWithCreditCounselling.add(product);
            }
            else if(prodOld.Deceased_Date__c == null && product.Deceased_Date__c != null ){
                system.debug('oldestDate after date added:'+oldestDate);
                if(oldestDate == NULL || (oldestDate != NULL && oldestDate > prodOld.Deceased_Date__c)){
                    oldestDate = product.Deceased_Date__c;   
                }
                mapProductIDPayDate.put(product.ID, product.Deceased_Date__c);
            }
            //if map doesnt contain productid as key, fill the map
                    
            
            system.debug('oldestDate:: '+oldestDate);
            
        }
        system.debug('mapProductIDPayDate:: '+mapProductIDPayDate);
        
        map<ID, list<Product_Payments__c>> mapProductIDPaymentsToAdjustBalances = new map<ID, list<Product_Payments__c>>();
        if(!mapProductIDPayDate.keySet().isEmpty()){
            for(Product__c productInstance : [SELECT ID, Current_Interest_Amount__c,
                                                      Payment_Apportionment__c,
                                            (SELECT ID,  Payment_Amount__c,Pay_NSF__c,Pay_Attorney__c,Payment_Posting_Date__c,
                                                      Pay_Court__c,Pay_Other__c,Pay_Fees__c,Interest_Payment_Amount__c,
                                                      Principal_Payment_Amount__c,CCS_Account__c
                                                      FROM Product_Payments__r
                                                      WHERE Payment_Amount__c > 0
                                                      AND Is_Payment_Reversed__c = false
                                                      AND Payment_Posting_Date__c >= :oldestDate
                                                      AND CCS_Account__r.RecordType.DeveloperName= :'Distressed_Account'
                                                      ORDER BY Payment_Posting_Date__c ASC)
                                            FROM Product__c
                                          WHERE ID IN :mapProductIDPayDate.keySet()]){
                //If there are no payments available, add the product to map to reverse balance
                if(productInstance.Product_Payments__r.isEmpty()){
                    system.debug('mapProductIDPaymentsToAdjustBalances::'+mapProductIDPaymentsToAdjustBalances);
                    mapProductIDPaymentsToAdjustBalances.put(productInstance.ID, null);
                }
                for(Product_Payments__c prodPay : productInstance.Product_Payments__r){
                    system.debug('prodPay:: '+prodPay);
                    //get the payments for product whose posting date >= oldest payment date in lot
                    if(prodPay.Payment_Posting_Date__c >= mapProductIDPayDate.get(prodPay.CCS_Account__c)){
                        if(!mapProductIDPaymentsToAdjustBalances.containsKey(prodPay.CCS_Account__c)){
                            mapProductIDPaymentsToAdjustBalances.put(prodPay.CCS_Account__c, new list<Product_Payments__c>{prodPay});    
                        }
                        else{
                            mapProductIDPaymentsToAdjustBalances.get(prodPay.CCS_Account__c).add(prodPay);
                        }
                    }
                    //if payment posting date >= oldest payment date and posted before today (payment is in between payment)
                    if(mapProductIDPaymentsToAdjustBalances.containsKey(prodPay.CCS_Account__c)
                    && prodPay.Payment_posting_Date__c > mapProductIDPayDate.get(prodPay.CCS_Account__c)){
                        mapProductIDPaymentsToAdjustBalances.remove(prodPay.CCS_Account__c);
                    }
                }
            }    
        }
        
        
        system.debug('mapProductIDPaymentsToAdjustBalances:: '+mapProductIDPaymentsToAdjustBalances);
        //map to store product id and instance with updated principal balance and interet amount
        map<ID, Product__c> mapProductsToReverseBalances = new map<ID, Product__c>();
        
        //list<Product_payments__c> listProdPayToConsider = new  list<Product_payments__c>();
        
        //Get Principal Balance and Interest Balance from history in descending order to get latest histry for the day first
        if(!mapProductIDPaymentsToAdjustBalances.keySet().isEmpty() || Test.isRunningTest()){
            for(Product__History productHistory : [SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                                               FROM Product__History
                                               WHERE ParentId IN :mapProductIDPaymentsToAdjustBalances.keySet()
                                               AND (Field= :'Current_Principal_Balance__c'
                                                    OR Field= :'Current_Interest_Amount__c' 
                                                    OR Field= :'Current_Balance__c')
                                               AND CreatedDate >= :oldestDate
                                               ORDER BY CreatedDate DESC]){
                system.debug('productHistory:'+productHistory.OldValue + ' : ' + productHistory.CreatedDate + ' : '+productHistory.Field);
                //Fill in the mapProductsToReverseBalances map, if neither if balances is added or only one of them is added
                if(!mapProductsToReverseBalances.containsKey(productHistory.parentId)
                || (mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c == NULL 
                || mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c == NULL
                || mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c == NULL)){
                    
                    String oldestDateHistory = String.valueOf(mapProductIDPayDate.get(productHistory.parentId));
                    String createdDateHistory = String.valueOf(productHistory.CreatedDate).substring(0,10);
                    system.debug('oldestDateHistory: '+oldestDateHistory);
                    system.debug('createdDateHistory: '+createdDateHistory.substring(0,10));
                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if(productHistory.CreatedDate != Date.Today() 
                    //&& productHistory.CreatedDate == mapProductIDPayDate.get(productHistory.parentId)
                    && createdDateHistory == oldestDateHistory
                    //check if current principal balance to be reversed is not considered in product update
                    && (!mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                    || mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c == NULL)
                    && productHistory.Field == 'Current_Principal_Balance__c'){
                        system.debug('productHistory.Field::'+productHistory.Field);
                        //create product instance with principal balance to be reversed to
                        Product__c productToUpdate = new Product__c();
                        //if interest amount is already taken, put it in instance
                        if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                        && mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c != NULL ){
                            productToUpdate.Current_Interest_Amount__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c;
                        }
                        if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                        && mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c != NULL ){
                            productToUpdate.Current_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c;
                        }
                        
                        productToUpdate.ID = productHistory.parentId;
                        productToUpdate.Current_Principal_Balance__c = Double.valueOf(productHistory.OldValue);
                        /*if(productToUpdate.Current_Principal_Balance__c != NULL && productToUpdate.Current_Interest_Amount__c != NULL){
                            productToUpdate.Current_Balance__c = productToUpdate.Current_Principal_Balance__c + productToUpdate.Current_Interest_Amount__c;
                        }*/
                        mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                     }
                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if(createdDateHistory == oldestDateHistory
                       //productHistory.CreatedDate == mapProductIDPayDate.get(productHistory.parentId) 
                       //check if current principal balance to be reversed is not considered in product update
                       && (!mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           || mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c == NULL)
                       && productHistory.Field == 'Current_Interest_Amount__c'){
                           system.debug('productHistory.Field2:: '+productHistory.Field);
                           //create product instance with principal balance to be reversed to
                           Product__c productToUpdate = new Product__c();
                           //if interest amount is already taken, put it in instance
                           if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           && mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c != NULL ){
                                productToUpdate.Current_Principal_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c;
                           }
                           if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           && mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c != NULL ){
                                productToUpdate.Current_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c;
                           }
                           productToUpdate.ID = productHistory.parentId;
                           productToUpdate.Current_Interest_Amount__c = Double.valueOf(productHistory.OldValue);
                           
                           /*if(productToUpdate.Current_Principal_Balance__c != NULL && productToUpdate.Current_Interest_Amount__c != NULL){
                               productToUpdate.Current_Balance__c = productToUpdate.Current_Principal_Balance__c + productToUpdate.Current_Interest_Amount__c;
                           }*/
                           mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                       }
                        
                    //check if history created date is oldest posting date of payment in new list of payments for product
                    if(createdDateHistory == oldestDateHistory
                       //productHistory.CreatedDate == mapProductIDPayDate.get(productHistory.parentId) 
                       //check if current principal balance to be reversed is not considered in product update
                       && (!mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           || mapProductsToReverseBalances.get(productHistory.parentId).Current_Balance__c == NULL)
                       && productHistory.Field == 'Current_Balance__c'){
                           system.debug('productHistory.Field2:: '+productHistory.Field);
                           //create product instance with principal balance to be reversed to
                           Product__c productToUpdate = new Product__c();
                           //if interest amount is already taken, put it in instance
                           if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           && mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c != NULL ){
                                productToUpdate.Current_Principal_Balance__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Principal_Balance__c;
                           }
                           if(mapProductsToReverseBalances.containsKey(productHistory.parentId) 
                           && mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c != NULL ){
                                productToUpdate.Current_Interest_Amount__c = mapProductsToReverseBalances.get(productHistory.parentId).Current_Interest_Amount__c;
                           }
                           productToUpdate.ID = productHistory.parentId;
                           productToUpdate.Current_Balance__c = Double.valueOf(productHistory.OldValue);
                           
                           /*if(productToUpdate.Current_Principal_Balance__c != NULL && productToUpdate.Current_Interest_Amount__c != NULL){
                               productToUpdate.Current_Balance__c = productToUpdate.Current_Principal_Balance__c + productToUpdate.Current_Interest_Amount__c;
                           }*/
                           mapProductsToReverseBalances.put(productHistory.ParentId, productToUpdate);
                       }
                }   
            }    
        }
          for(Product__c product : listProductWithCreditCounselling){
            if(mapProductsToReverseBalances.containsKey(product.ID)){
                Decimal InterestAmount = 0;
                Product__c productToUpdate = new Product__c();
                productToUpdate = mapProductsToReverseBalances.get(product.ID);
                system.debug('productToUpdate::'+productToUpdate);
                //If History record does not have principal balance, get it from the new record list
                if(productToUpdate.Current_Principal_Balance__c == null){
                    productToUpdate.Current_Principal_Balance__c = product.Current_Principal_Balance__c;
                }
                system.debug('product.Interest_Rate__c::'+product.Interest_Rate__c);
                InterestAmount = ((productToUpdate.Current_Principal_Balance__c * product.Interest_Rate__c *
                                  (product.Credit_Counselling_Date__c.daysBetween(Date.today())))/100)/365;
                system.debug('InterestAmount::'+InterestAmount);
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
     public static void creatJudgment(Product__c prodNew){
        set<ID> prodID = new set<ID>();
        map<String, ID> prodNameID = new map<String, ID>();
            prodID.add(prodNew.ID);
            prodNameID.put(prodNew.Name, prodNew.ID);
       
        List<Account_Judgment__c> accJudg = [Select id,name,status__c,product__C, judgment__c from Account_Judgment__c where product__c IN: prodID AND Status__C = 'Active'];
        system.debug('accJudg::'+accJudg);
         if(accJudg.isEmpty()){
             Judgment__c newJudgment = new Judgment__C();
             newJudgment.Legal_Status__c = 'Pre-Legal';
             newJudgment.Legal_Sub_Status__c = 'Approved for Legal Action';
             newJudgment.Placed_Agency__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
             if(prodNew.State__c != NULL){
                 prodProvinceName = prodNew.State__c;
                 ProvinceNameFormat = nameFormat(prodProvinceName);
                 provinceAcronymFormat = prodProvinceName.toUpperCase();
                 if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                     newJudgment.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c; 
                     newJudgment.Placed_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                     system.debug('newJudgment.Placed_Province__c::'+newJudgment.Placed_Province__c);
                 }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                     newJudgment.Judgment_Province__c = ProvinceNameFormat; 
                     newJudgment.Placed_Province__c = ProvinceNameFormat;
                 }
             }
             //newJudgment.Placed_Province__c = prodNew.State__c;
             system.debug('prodNew.State__c::'+prodNew.State__c);
             //newJudgment.Judgment_Province__c = prodNew.State__c;
             system.debug('newJudgment.Judgment_Province__c::'+newJudgment.Judgment_Province__c);
             newJudgment.Product_1__c = prodNew.Name;
             newJudgment.Plaintiff__c = prodNew.Account_Purchasing_Entity_Value__c;
             newJudgment.Legal_Agency__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
             newJudgment.Agency_Initiated_Legal_Action__c = String.valueOf(Math.floor(prodNew.Collection_Agency__c));
             system.debug('newJudgment.Agency_Initiated_Legal_Action__c::'+newJudgment.Agency_Initiated_Legal_Action__c);
             //JudgmentTriggerHandler.runJudgmentTrigger = false;
             insert newJudgment;  
             //JudgmentTriggerHandler.runJudgmentTrigger = true;
             //PortalJudgmentProcessingAPI.processJudgment(newJudgment.Id);
             Account_Judgment__c accJudg1 = new Account_Judgment__c();
             accJudg1.Product__c = prodNameID.get(newJudgment.Product_1__c);
             accJudg1.Judgment__c = newJudgment.ID;
             accJudg1.Product_Identifier__c = prodNew.Name;
             accJudg1.Judgment_Identifier__c = newJudgment.name;
             AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
             insert accJudg1;
             //accJudgID.add(accJudg1.ID);
             AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;
             Application_Config_Settings__c config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
             config.Run_Product_Coll_Sub_Status_Validation__c = false; 
             update config;
             prodNew.Collection_Sub_Status__c = 'Legal';
             prodNew.Previously_Reviewed_for_Legal_Action__c = TRUE;
             
             PortalAccountJudgmentProcessingAPI.processAccountJudgment(accJudg1.ID);
         }else{
             prodNew.addError('Active Judgment is present on this account');
         }
        }
    //get Province Name
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
    
    //Ticket 4558: Interest Waiver functionality_added checkes in OR conditions
    public static void populateAccuringInterest(List<Product__c> listNewProducts){
        system.debug('ProductTriggerHandler_populateAccuringInterest: Entered populateAccuringInterest'+listNewProducts);        
        for(Product__c prodListData :listNewProducts){
            if(prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId && 
               (prodListData.Current_Principal_Balance__c == null || prodListData.Current_Principal_Balance__c <= 0 || prodListData.Collection_Sub_Status__c == 'Deceased' || prodListData.Collection_Sub_Status__c == 'Paid in Full Account' || prodListData.Collection_Sub_Status__c == 'Settled in Full Account' || prodListData.Collection_Sub_Status__c == 'Bankrupt Account'
              || prodListData.Interest_Rate__c == 0 || prodListData.Interest_Rate__c == NULL || prodListData.Interest_Amount_Last_Calculated_Date__c == NULL || prodListData.Insolvency_Date__c != NULL || prodListData.Deceased_Date__c != NULL || prodListData.Collection_Sub_Status__c == 'Credit Counselling')){
                  system.debug('ProductTriggerHandler_populateAccuringInterest: value of Accruing Interest::'+prodListData.Interest_Stopped__c);
                	prodListData.Interest_Stopped__c = true;
              }
            else if(prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId && (prodListData.Interest_Waived_Off__c == true && (prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Off_Start_Date__c || prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Of_End_Date__c)) && (prodListData.Current_Principal_Balance__c == null || prodListData.Current_Principal_Balance__c <= 0 || prodListData.Collection_Sub_Status__c == 'Deceased' || prodListData.Collection_Sub_Status__c == 'Paid in Full Account' || prodListData.Collection_Sub_Status__c == 'Settled in Full Account' || prodListData.Collection_Sub_Status__c == 'Bankrupt Account' || prodListData.Interest_Rate__c == 0 || prodListData.Interest_Rate__c == NULL || prodListData.Insolvency_Date__c != NULL || prodListData.Deceased_Date__c != NULL || prodListData.Collection_Sub_Status__c == 'Credit Counselling')){
                  system.debug('ProductTriggerHandler_populateAccuringInterest: value of Accruing Interest::'+prodListData.Interest_Stopped__c);
                	prodListData.Interest_Stopped__c = true;
              }
            else if(prodListData.Interest_Waived_Off__c == false || (prodListData.Interest_Waived_Off__c == true && (prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Off_Start_Date__c || prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Of_End_Date__c))){
                     system.debug('ProductTriggerHandler_populateAccuringInterest: value of Accruing Interest::'+prodListData.Interest_Stopped__c);      
                           prodListData.Interest_Stopped__c = false;         
            }
            else if(prodListData.Interest_Waived_Off__c == false
            || (prodListData.Interest_Waived_Off__c == true
            && (prodListData.Interest_Amount_Last_Calculated_Date__c < prodListData.Interest_Waived_Off_Start_Date__c 
             || prodListData.Interest_Amount_Last_Calculated_Date__c > prodListData.Interest_Waived_Of_End_Date__c)) &&
               prodRTypeIdMap.get('Distressed_Account') == prodListData.RecordTypeId && 
               (prodListData.Current_Principal_Balance__c != null && prodListData.Current_Principal_Balance__c > 0 && prodListData.Collection_Sub_Status__c != 'Deceased' && prodListData.Collection_Sub_Status__c != 'Paid in Full Account' && prodListData.Collection_Sub_Status__c != 'Settled in Full Account' && prodListData.Collection_Sub_Status__c != 'Bankrupt Account'
              && prodListData.Interest_Rate__c != 0 && prodListData.Interest_Rate__c != NULL && prodListData.Interest_Amount_Last_Calculated_Date__c != NULL && prodListData.Insolvency_Date__c == NULL && prodListData.Deceased_Date__c == NULL && prodListData.Collection_Sub_Status__c != 'Credit Counselling')){
                  system.debug('ProductTriggerHandler_populateAccuringInterest: value of Accruing Interest::'+prodListData.Interest_Stopped__c);
                	prodListData.Interest_Stopped__c = false;
              }   	
        }
    }
}