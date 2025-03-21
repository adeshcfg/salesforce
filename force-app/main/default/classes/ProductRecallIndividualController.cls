/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to recall agency individually from Product record
*  @author : A5E Consulting
*  @date : 11/03/2022

*************************************************************************************************/
public without sharing class ProductRecallIndividualController {
    public map<String, Data_Status_Mapping__c> dataStatusMap = Data_Status_Mapping__c.getAll();
    public map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
    public map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public list<SelectOption> listRecallReasonOptions { get; set; }
    public String profileNameUserInfo { get; set; }
    public static final String PENDING_RECALL = 'Pending Recall';
    public static final String RECALL = 'Recall';
    public static final String PENDING_ALLOCATION = '100000';
    public static final String PENDING_ALLOCATION_RECALLED_CODE = '110000';
    public static final String NEW_ALLOCATION = 'New Allocation - New Allocation';
    public static final String READY = 'Ready';
    public static final String PENDING_ALLOCATION_RECALLED = 'Pending Allocation (1); Recalled';
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults();
    public String ERROR_MSG { get; set; }
    public String productID { get; set; }
    public String NewPlacementAgency { get; set; }
    public String recallReason { get; set; }
    public String selectedRecallReason { get; set; }
    public String selectedValueAction { get; set; }
    public ID warehousePlacementId;
    public String placeStatus;
    public List<Product__c> listProduct = new List<Product__c>();
    public Product__c product { get; set; }
    public Placement__c placement;
    String oldPlacementID;
    public map<String, Data_Status_Mapping__c> mapDataStatusMapping = Data_Status_Mapping__c.getAll();
    public map<String, Data_Status_Mapping__c> mapDataStatusMap = new Map<String, Data_Status_Mapping__c>();
    public List<User> systemName = new List<User>();
    public Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public List<Account_Judgment__c> accJudgStatusUpdateList = new List<Account_Judgment__c>();
    public Map<String, ID> mapProductJudgment = new Map<String, ID>();
    public Map<String, Account_Judgment__c> accJudgStatusUpdateMap = new Map<String, Account_Judgment__c>();

    public ProductRecallIndividualController(ApexPages.StandardController stdController) {
        placement = [
            SELECT ID, Name
            FROM Placement__c
            WHERE Name = :'9999'
            LIMIT 1
        ];

        productID = ApexPages.currentPage().getParameters().get('id');

        product = [
            SELECT
                ID,
                Name,
                State__c,
                Placement_Status__c,
                Status__c,
                Collection_Agency__c,
                Assignment_Date__c,
                Collection_Agency_Placement__c,
                Collection_Agency_Placement__r.Agency_Name__c,
                Collection_Sub_Status__c,
                Invalid_Submission__c,
                Pool_Name__r.Name,
                Current_Principal_Balance__c,
                Current_Interest_Amount__c,
                Interest_Rate__c,
                Current_Bal_NSF_Fees__c,
                Current_Bal_Attorney_Fees__c,
                Current_Bal_General_Fees__c,
                Current_Bal_Other_Fees__c,
                External_Status_Current__c,
                Current_Bal_Court_Fees__c,
                Collection_Agency_Placement__r.Commission_Rate__c,
                Product_Status__c,
                Commission_Rate__c,
                Pool_Name__r.Commission_Rate__c,
                Allocated_Amount_Total__c,
                Commission_Rate_at_Time_of_Placement__c,
                Value_Tier_at_Time_of_Placement__c,
                Placed_Settlement_Rate__c,
                Recoverable_Fee__c,
                Non_Recoverable_Fee__c,
                Current_Balance__c,
                OwnerId,
                Previous_Ownership__c,
                RecordTypeId,
            	Refer_to_Legal__c,
            	Reason_for_Legal__c
            FROM Product__c
            WHERE ID = :productID
        ];

        if (product.Placement_Status__c != null) {
            placeStatus = product.Placement_Status__c;
        }

        if ((product.Collection_Agency__c != null || product.Invalid_Submission__c == true)) {
            if (product.Collection_Agency__c == 9999) {
                ERROR_MSG = 'Product is in Warehouse.';
            } else {
                ERROR_MSG = '';
                NewPlacementAgency = String.valueOf(product.Collection_Agency__c);
                oldPlacementID = product.Collection_Agency_Placement__c;
            }
        } else {
            //ERROR_MSG = 'Product is already Recalled.';
        }

        profileNameUserInfo = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;

        mapRecallCodeStatus = new Map<String, Placement_Status_Code_Mapping__c>();
        List<Placement_Status_Code_Mapping__c> listStatusCodes = [
            SELECT Parent_Status__c, Placement_Status_Code__c, Status__c, Sub_Status__c, Data_Status_Code__c, Data_Status_Description__c, Include_in_Recall__c
            FROM Placement_Status_Code_Mapping__c
            //where Parent_Status__c = :PENDING_RECALL
            //OR Parent_Status__c
            ORDER BY Status__c ASC NULLS LAST
        ];

        listRecallReasonOptions = new List<SelectOption>();

        for (Placement_Status_Code_Mapping__c mapping : listStatusCodes) {
            if (mapping.Parent_Status__c == PENDING_RECALL && mapping.Include_in_Recall__c == true) {
                if (String.isBlank(mapping.Sub_Status__c)) {
                    listRecallReasonOptions.add(new SelectOption(mapping.Placement_Status_Code__c, mapping.Status__c));
                } else {
                    listRecallReasonOptions.add(new SelectOption(mapping.Placement_Status_Code__c, mapping.Status__c + ' - ' + mapping.Sub_Status__c));
                }
            }

            mapRecallCodeStatus.put(mapping.Placement_Status_Code__c, mapping);
        }

        for (Data_Status_Mapping__c metaData : mapDataStatusMapping.values()) {
            mapDataStatusMap.put(metaData.name, metaData);
        }
        //Fetch System Api
        if (lrpSetting.Canaccede_API_User__c != null) {
            systemName = [SELECT id, Name FROM User WHERE username = :lrpSetting.Canaccede_API_User__c];
        }
        //Fetch Product RecordType
        for (RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c']) {
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }

        for (Account_Judgment__c accJudgment : [
            SELECT ID, Judgment__c, Product__c, Product__r.Name
            FROM Account_Judgment__c
            WHERE Product__c = :productID AND Status__c = 'Active'
        ]) {
            mapProductJudgment.put(accJudgment.Product__c, accJudgment.id);
        }
    }

    /**
     * @description : Method to copy field data to all products which need to be recalled
     * @author adesh.ikhar@canaccede.com | 09-24-2024
     * @param productId
     * @param originalProduct
     * @return Product__c
     **/
    public Product__c populateProductData(String productId, Product__c originalProduct) {
        List<String> fieldsToCopy = new List<String>{
            'Placement_Status__c',
            'Status__c',
            'Sub_Status__c',
            'Collection_Agency_Placement__c',
            'Product_Status__c',
            'Data_Status_Description__c'
        };
        Product__c newProduct = new Product__c();
        newProduct.Id = productId;
        newProduct.Status_Changed_Date__c = Date.today();
        newProduct.Recalled_Date__c = originalProduct.Recalled_Date__c;
        newProduct.Collection_Agency__c = originalProduct.Collection_Agency__c;
        for (String field : fieldsToCopy) {
            newProduct.put(field, String.valueOf(originalProduct.get(field)));
        }
        return newProduct;
    }

    public PageReference recallWithWarning() {
        Map<String, Map<String, String>> productIdAgencyInfoMap = new Map<String, Map<String, String>>();
        String updateType = RECALL;
        String placementIdentifier = '';
        Set<String> recallProdIds = new Set<String>();
        List<ID> prodToRecallList = new List<ID>();
        product.Invalid_Submission__c = false;
        product.Timestamp_Of_Invalid_Submission__c = null;
        product.Invalid_Submission_Reason__c = null;
        product.Invalid_Submission_Initiated_By__c = null;
        product.Run_Identifier_Check_On__c = System.today();
        List<Product__c> prodNewRecordList = new List<Product__c>();
        String mainStatus = mapRecallCodeStatus.get(selectedRecallReason).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedRecallReason).Sub_Status__c;
        map<String, String> mapDataStatus = new Map<String, String>();
        Set<id> setProductIDs = new Set<id>();
        setProductIDs.add(product.id);
        Map<id, String> allProdToRecallList = new Map<id, String>();
        prodStatusAccJudgStatus wrapperData = new prodStatusAccJudgStatus();
        Set<Id> prodListId = new Set<Id>();
        recallProdIds.add(product.Id);
        wrapperData = getActiveProdIdsFromJudg(recallProdIds);
        mapProductJudgment = wrapperData.prodIdsAcctJudId;
        allProdToRecallList = wrapperData.prodIdsProductStatus;

        Map<String, Product__c> placementMainStatusMap = JudgmentTriggerHandler.updatePlacementMainStatus(setProductIDs);

        if (selectedValueAction == PENDING_RECALL) {
            ERROR_MSG = 'Product set to Pending Recall Status from Agency:' + NewPlacementAgency;
            if(product.Collection_Agency__c <> NULL){
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
            }
            product.Placement_Status__c = selectedRecallReason;
            product.Status_Changed_Date__c = Date.today();
            product.External_Status_Current__c = null;
            if(product.Placement_Status__c <> NULL){
                product.Status__c =
                    mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                    ' - ' +
                    mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
            
            if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                product.Purchase_Status__c = 'Buyback/Putback Initiated';
                product.Buyback_Putback_Status_Change_Date__c = System.today();
            }
            prodNewRecordList.add(product);
        } else if (selectedValueAction == 'Send To Warehouse') {
            //Ticket 6430 : Point 2
            if (
                !Test.isRunningTest() &&
                product.Placement_Status__c <> NULL &&
                System.Label.Exclude_Judgment_Codes.contains(product.Placement_Status__c) &&
                mapProductJudgment.containsKey(product.id)
            ) {
                accJudgStatusUpdateMap = JudgmentTriggerHandler.inactiveAcctJudStatus(mapProductJudgment);
                if(product.Refer_to_Legal__c == 'Approved'){
                    product.Refer_to_Legal__c = '';
                    product.Reason_for_Legal__c = '';
                }
            }
            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Recalled_Date__c = Date.today();
            product.External_Status_Current__c = null;
            ERROR_MSG = 'Product sent to Warehouse Agency:' + product.Collection_Agency__c;
            //If status is already in pending recall, update it to corresponding Recall Status
            if (String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)) {
                product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //else update the status to the selected reason from list and then to corresponding recall status
            else {
                product.Placement_Status__c = selectedRecallReason;
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
            if (product.Placement_Status__c <> NULL &&
                mapRecallCodeStatus.containsKey(product.Placement_Status__c)) {
                product.Status__c =
                    mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                    ' - ' +
                    mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
            //clear the fields once acount recalled and sent to warehouse
            if (placementMainStatusMap.containskey(product.id)) {
                product.Status__c = placementMainStatusMap.get(product.id).Status__c;
                product.Sub_Status__c = placementMainStatusMap.get(product.id).Sub_Status__c;
                product.Placement_Status__c = placementMainStatusMap.get(product.id).Placement_Status__c;
            } else {
                product.Placement_Status__c = null;
                product.Status__c = null;
                product.Sub_Status__c = null;
            }

            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Status_Changed_Date__c = Date.today();
            product.Invalid_Submission_Initiated_By__c = null;
            //4758: Populate Closed date on Distressed product based on product status
            if (
                mapDataStatusMap.containskey(product.Product_Status__c) &&
                mapDataStatusMap.get(product.Product_Status__c).Bureau_Reporting_Account_Status__c == 'Closed'
            ) {
                product.Closed_Date__c = Date.today();
            }
            placementIdentifier = String.valueOf(product.Collection_Agency__c);
            if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                product.Purchase_Status__c = 'Buyback/Putback Initiated';
                product.Buyback_Putback_Status_Change_Date__c = System.today();
            }
            prodNewRecordList.add(product);
            for (Id prodIds : allProdToRecallList.keySet()) {
                prodToRecallList.add(prodIds);
                prodListId.add(prodIds);
                if (!recallProdIds.contains(prodIds)) {
                    prodNewRecordList.add(populateProductData(prodIds, product));
                }
            }
        } else if (selectedValueAction == 'Pending Allocation') {
            // Deactivate account judgment for recalled products
            if (product.Placement_Status__c <> NULL &&
                System.Label.Exclude_Judgment_Codes.contains(product.Placement_Status__c) && 
                mapProductJudgment.containsKey(product.id)) {
                accJudgStatusUpdateMap = JudgmentTriggerHandler.inactiveAcctJudStatus(mapProductJudgment);
                if(product.Refer_to_Legal__c == 'Approved'){
                    product.Refer_to_Legal__c = '';
                    product.Reason_for_Legal__c = '';
                }
            }
            product.Collection_Agency__c = 9999;
            product.Collection_Agency_Placement__c = placement.id;
            product.Recalled_Date__c = Date.today();
            product.External_Status_Current__c = null;
            ERROR_MSG = 'Product set to Pending Allocation Status';
            //If status is already in pending recall, update it to corresponding Recall Status
            if (String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)) {
                product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //else update the status to the selected reason from list and then to corresponding recall status
            else {
                product.Placement_Status__c = selectedRecallReason;
                product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
            }
            //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
            if (product.Placement_Status__c <> NULL &&
                mapRecallCodeStatus.containsKey(product.Placement_Status__c)) {
                product.Status__c =
                    mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                    ' - ' +
                    mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                    product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                    product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                }
            }
            product.Status_Changed_Date__c = Date.today();
            product.Status__c = null;
            product.Sub_Status__c = null;
            product.Placement_Status__c = null;
            if(product.Collection_Agency__c <> NULL){
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
            }
            
            if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                product.Purchase_Status__c = 'Buyback/Putback Initiated';
                product.Buyback_Putback_Status_Change_Date__c = System.today();
            }
            prodNewRecordList.add(product);
            for (Id prodId : allProdToRecallList.keySet()) {
                prodToRecallList.add(prodId);
                prodListId.add(prodId);
                if (!recallProdIds.contains(prodId)) {
                    prodNewRecordList.add(populateProductData(prodId, product));
                }
            }
        }
        if (product.Collection_Agency__c == 9999) {
            productIdAgencyInfoMap.put(
                product.Id,
                new Map<String, String>{ 'Agency' => placementIdentifier, 'AgencyPlacement' => product.Collection_Agency_Placement__c }
            );
            if (prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId && placement.Name != NewPlacementAgency) {
                Id oldOwnerId = product.OwnerId;
                // Assign System API to Owner
                if (!systemName.isEmpty()) {
                    product.OwnerId = systemName[0].Id;
                }
                //Also Assign the last owner to the previous ownership field
                if (oldOwnerId != product.OwnerId && oldOwnerId != null) {
                    product.Previous_Ownership__c = oldOwnerId;
                }
            }
        }
        List<Id> prodId = new List<Id>();
        prodId.add(product.id);
        try {
            DistressedUtilities.UpdateSettlement(prodId);
            ProductTriggerHandler.runProductTrigger = false;
            //update product;
            applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = false;
            update applicationConfigSetting;
            	update prodNewRecordList;
            applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = true;
            update applicationConfigSetting;

            List<Judgment__c> judgmentToUpdateList = updateJudgmentAgency(productIdAgencyInfoMap);
            if (!judgmentToUpdateList.isEmpty()) {
                JudgmentTriggerHandler.runJudgmentTrigger = false;
                JudgmentTriggerHandler.runJudgmentValidation = false;
                //bypass judgment validation rule
                applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                update applicationConfigSetting;
                Database.update(judgmentToUpdateList);
                applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                JudgmentTriggerHandler.runJudgmentValidation = true;
                JudgmentTriggerHandler.runJudgmentTrigger = true;
                update applicationConfigSetting;
            }

            AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
            update accJudgStatusUpdateMap.values();
            AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;

            if (selectedValueAction == 'Pending Allocation' || selectedValueAction == 'Send To Warehouse' && !allProdToRecallList.containsKey(product.id)) {
                DistressedUtilities.updatePlacementHistory(product.id, selectedRecallReason.replaceFirst(selectedRecallReason.substring(0, 1), '9'));
            }

            if (selectedValueAction == 'Pending Allocation' || selectedValueAction == 'Send To Warehouse' && allProdToRecallList.containsKey(product.id)) {
                DistressedUtilities.updatePlacementHistory_New(prodToRecallList, allProdToRecallList);
            }

            Map<Id, String> placeStatus = new Map<Id, String>();
            placeStatus.put(product.id, product.Placement_Status__c);
            prodListId.add(product.Id);
            //call product API
            Database.executeBatch(new BatchProcessForProdScreen(new List<Id>(prodListId), placeStatus, 'Account Status Update File'), 200);

            //call judgment API call and notify to portal
            Database.executeBatch(new JudgmentAPIBatch(judgmentToUpdateList, null, null, 'Account Status Update File'), 50);

            ProductTriggerHandler.runProductTrigger = true;
        } catch (Exception ex) {
            ERROR_MSG = ex.getMessage();
            system.debug('exception::----' + ex.getStackTraceString());
        }

        return null;
    }

    //Recall Product
    public PageReference recallProduct() {
        Map<String, Map<String, String>> productIdAgencyInfoMap = new Map<String, Map<String, String>>();
        String updateType = RECALL;
        String placementIdentifier = '';
        Boolean error = validationOnRecordUpdate(product, NewPlacementAgency);
        String mainStatus = mapRecallCodeStatus.get(selectedRecallReason).Status__c;
        String subStatus = mapRecallCodeStatus.get(selectedRecallReason).Sub_Status__c;
        map<String, String> mapDataStatus = new Map<String, String>();
        map<String, Data_Status_Mapping__c> mapProductStatusCodes = new Map<String, Data_Status_Mapping__c>();
        Set<String> recallProdIds = new Set<String>();
        Map<id, String> allProdToRecallList = new Map<id, String>();
        List<ID> prodToRecallList = new List<ID>();
        List<Product__c> prodNewRecordList = new List<Product__c>();
        prodStatusAccJudgStatus wrapperData = new prodStatusAccJudgStatus();
        Set<Id> prodListId = new Set<Id>();
        recallProdIds.add(product.Id);
        wrapperData = getActiveProdIdsFromJudg(recallProdIds);
        mapProductJudgment = wrapperData.prodIdsAcctJudId;
        allProdToRecallList = wrapperData.prodIdsProductStatus;

        for (Data_Status_Mapping__c dataStatusMapping : [
            SELECT Description1__c, Description2__c, Name, Description__c
            FROM Data_Status_Mapping__c
            WHERE Description__c LIKE :'Warehouse%'
        ]) {
            mapProductStatusCodes.put(
                dataStatusMapping.Description1__c + (dataStatusMapping.Description2__c != null ? dataStatusMapping.Description2__c : ''),
                dataStatusMapping
            );
        }

        Set<id> setProductIDs = new Set<id>();
        setProductIDs.add(product.id);
        Map<String, Product__c> placementMainStatusMap = JudgmentTriggerHandler.updatePlacementMainStatus(setProductIDs);

        if (error == false) {
            product.Invalid_Submission__c = false;
            product.Timestamp_Of_Invalid_Submission__c = null;
            product.Invalid_Submission_Reason__c = null;
            product.Invalid_Submission_Initiated_By__c = null;
            product.Run_Identifier_Check_On__c = System.today();
            if (selectedValueAction == PENDING_RECALL) {
                ERROR_MSG = 'Product set to Pending Recall Status from Agency:' + NewPlacementAgency;
                if(product.Collection_Agency__c <> NULL){
                    placementIdentifier = String.valueOf(product.Collection_Agency__c);
                }
                
                product.External_Status_Current__c = null;
                product.Placement_Status__c = selectedRecallReason;
                product.Status_Changed_Date__c = Date.today();
                if(product.Placement_Status__c <> NULL){
                    product.Status__c =
                    mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                    ' - ' +
                    mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }
                
                if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                    product.Purchase_Status__c = 'Buyback/Putback Initiated';
                    product.Buyback_Putback_Status_Change_Date__c = System.today();
                }
                prodNewRecordList.add(product);
            } else if (selectedValueAction == 'Send To Warehouse') {
                //Ticket 6430 : Point 2
                if (product.Placement_Status__c <> NULL &&
                    System.Label.Exclude_Judgment_Codes.contains(product.Placement_Status__c) &&
                    mapProductJudgment.containsKey(product.id)) {
                    accJudgStatusUpdateMap = JudgmentTriggerHandler.inactiveAcctJudStatus(mapProductJudgment);
                    if(product.Refer_to_Legal__c == 'Approved'){
                        product.Refer_to_Legal__c = '';
                        product.Reason_for_Legal__c = '';
                    }
                }
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
                ERROR_MSG = 'Product sent to Warehouse Agency:' + product.Collection_Agency__c;
                //If status is already in pending recall, update it to corresponding Recall Status
                if (String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)) {
                    product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //else update the status to the selected reason from list and then to corresponding recall status
                else {
                    product.Placement_Status__c = selectedRecallReason;
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                if (product.Placement_Status__c <> NULL &&
                    mapRecallCodeStatus.containsKey(product.Placement_Status__c)) {
                    product.Status__c =
                        mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                        ' - ' +
                        mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }

                //clear the fields once acount recalled and sent to warehouse
                if (placementMainStatusMap.containskey(product.id)) {
                    product.Status__c = placementMainStatusMap.get(product.id).Status__c;
                    product.Sub_Status__c = placementMainStatusMap.get(product.id).Sub_Status__c;
                    product.Placement_Status__c = placementMainStatusMap.get(product.id).Placement_Status__c;
                } else {
                    product.Placement_Status__c = null;
                    product.Status__c = null;
                    product.Sub_Status__c = null;
                }
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Status_Changed_Date__c = Date.today();
                product.Status_Changed_Date__c = Date.today();
                product.Invalid_Submission_Initiated_By__c = null;
                //4758: Populate Closed date on Distressed product based on product status
                if (
                    mapDataStatusMap.containskey(product.Product_Status__c) &&
                    mapDataStatusMap.get(product.Product_Status__c).Bureau_Reporting_Account_Status__c == 'Closed'
                ) {
                    product.Closed_Date__c = Date.today();
                }
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
                if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                    product.Purchase_Status__c = 'Buyback/Putback Initiated';
                    product.Buyback_Putback_Status_Change_Date__c = System.today();
                }
                prodNewRecordList.add(product);
                for (Id prodIds : allProdToRecallList.keySet()) {
                    prodToRecallList.add(prodIds);
                    prodListId.add(prodIds);
                    if (!recallProdIds.contains(prodIds)) {
                        prodNewRecordList.add(populateProductData(prodIds, product));
                    }
                }
            } else if (selectedValueAction == 'Pending Allocation') {
                // Deactivate account judgment for recalled products
                if (product.Placement_Status__c <> NULL &&
                    System.Label.Exclude_Judgment_Codes.contains(product.Placement_Status__c) && 
                    mapProductJudgment.containsKey(product.id)) {
                    accJudgStatusUpdateMap = JudgmentTriggerHandler.inactiveAcctJudStatus(mapProductJudgment);
                    if(product.Refer_to_Legal__c == 'Approved'){
                        product.Refer_to_Legal__c = '';
                        product.Reason_for_Legal__c = '';
                    }
                }
                product.Collection_Agency__c = 9999;
                product.Collection_Agency_Placement__c = placement.id;
                product.Recalled_Date__c = Date.today();
                product.External_Status_Current__c = null;
                ERROR_MSG = 'Product set to Pending Allocation Status';
                if (String.isNotBlank(product.Status__c) && product.Status__c.startsWith(PENDING_RECALL)) {
                    product.Status__c = product.Status__c.replace(PENDING_RECALL, RECALL);
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //else update the status to the selected reason from list and then to corresponding recall status
                else {
                    product.Placement_Status__c = selectedRecallReason;
                    product.Placement_Status__c = product.Placement_Status__c.replaceFirst('8', '9');
                }
                //upadate placment status and data status description from custom setting for the corresponding Placement Status Code
                if (product.Placement_Status__c <> NULL &&
                    mapRecallCodeStatus.containsKey(product.Placement_Status__c)) {
                    product.Status__c =
                        mapRecallCodeStatus.get(product.Placement_Status__c).Parent_Status__c +
                        ' - ' +
                        mapRecallCodeStatus.get(product.Placement_Status__c).Status__c;
                    product.Sub_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Sub_Status__c;
                    if (mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c != null) {
                        product.Product_Status__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Code__c;
                        product.Data_Status_Description__c = mapRecallCodeStatus.get(product.Placement_Status__c).Data_Status_Description__c;
                    }
                }
                product.Status_Changed_Date__c = Date.today();
                product.Status__c = null;
                product.Sub_Status__c = null;
                product.Placement_Status__c = null;
                placementIdentifier = String.valueOf(product.Collection_Agency__c);
                if (product.Product_Status__c == '297000' || product.Product_Status__c == '298000') {
                    product.Purchase_Status__c = 'Buyback/Putback Initiated';
                    product.Buyback_Putback_Status_Change_Date__c = System.today();
                }
                prodNewRecordList.add(product);
                for (Id prodId : allProdToRecallList.keySet()) {
                    prodToRecallList.add(prodId);
                    prodListId.add(prodId);
                    if (!recallProdIds.contains(prodId)) {
                        prodNewRecordList.add(populateProductData(prodId, product));
                    }
                }
            }
            if (product.Collection_Agency__c == 9999) {
                productIdAgencyInfoMap.put(
                    product.Id,
                    new Map<String, String>{ 'Agency' => placementIdentifier, 'AgencyPlacement' => product.Collection_Agency_Placement__c }
                );
                if (prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId && placement.Name != NewPlacementAgency) {
                    Id oldOwnerId = product.OwnerId;
                    // Assign System API to Owner
                    if (!systemName.isEmpty()) {
                        product.OwnerId = systemName[0].Id;
                    }
                    //Also Assign the last owner to the previous ownership field
                    if (oldOwnerId != product.OwnerId && oldOwnerId != null) {
                        product.Previous_Ownership__c = oldOwnerId;
                    }
                }
            }
            //Remove Pool from Product on Recall
            product.Pool_Name__c = null;
            List<Id> prodId = new List<Id>();
            prodId.add(product.id);
            try {
                DistressedUtilities.UpdateSettlement(prodId);
                ProductTriggerHandler.runProductTrigger = false;
                //update product;
                applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = false;
                update applicationConfigSetting;
                	update prodNewRecordList;
                applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = true;
                update applicationConfigSetting;

                List<Judgment__c> judgmentToUpdateList = updateJudgmentAgency(productIdAgencyInfoMap);
                if (!judgmentToUpdateList.isEmpty()) {
                    JudgmentTriggerHandler.runJudgmentTrigger = false;
                    JudgmentTriggerHandler.runJudgmentValidation = false;
                    //bypass judgment validation rule
                    applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                    update applicationConfigSetting;
                    Database.update(judgmentToUpdateList);
                    applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                    JudgmentTriggerHandler.runJudgmentValidation = true;
                    JudgmentTriggerHandler.runJudgmentTrigger = true;
                    update applicationConfigSetting;
                }

                AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
                update accJudgStatusUpdateMap.values();
                AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;

                if (
                    (selectedValueAction == 'Pending Allocation' || selectedValueAction == 'Send To Warehouse') && !allProdToRecallList.containsKey(product.id)
                ) {
                    DistressedUtilities.updatePlacementHistory(product.id, selectedRecallReason.replaceFirst(selectedRecallReason.substring(0, 1), '9'));
                }

                if (
                    (selectedValueAction == 'Pending Allocation' || selectedValueAction == 'Send To Warehouse') && allProdToRecallList.containsKey(product.id)
                ) {
                    DistressedUtilities.updatePlacementHistory_New(prodToRecallList, allProdToRecallList);
                }

                Map<Id, String> placeStatus = new Map<Id, String>();
                placeStatus.put(product.id, product.Placement_Status__c);
                prodListId.add(product.Id);

                //call product API
                Database.executeBatch(new BatchProcessForProdScreen(new List<Id>(prodListId), placeStatus, 'Account Status Update File'), 200);

                //call judgment API call and notify to portal
                Database.executeBatch(new JudgmentAPIBatch(judgmentToUpdateList, null, null, 'Account Status Update File'), 50);

                ProductTriggerHandler.runProductTrigger = true;
            } catch (Exception ex) {
                ERROR_MSG = ex.getMessage();
                system.debug('exception::----' + ex.getStackTraceString());
            }
        } else {
            system.debug('ERROR_MSG: ' + ERROR_MSG);
        }
        return null;
    }

    //Validation method to be called  before update
    public Boolean validationOnRecordUpdate(Product__c product, String newPlacement) {
        Boolean error;
        String EXPECTED;
        String AgencyProvince;
        ERROR_MSG = '';
        Map<String, Placement__c> mapPlacement = new Map<String, Placement__c>();
        Map<Id, Product_Payments__c> mapProductPayment = new Map<Id, Product_Payments__c>();

        List<Product_Payments__c> listProductPayments = [
            SELECT ID, CCS_Account__c, CCS_Account__r.Name
            FROM Product_Payments__c
            WHERE CCS_Account__c = :product.ID AND Payment_Agency__c = :newPlacement AND Payment_Posting_Date__c = LAST_N_DAYS:60
        ];

        //Check Recall Validations
        if (!listProductPayments.isEmpty()) {
            ERROR_MSG += '<b>WARNING</b> - ' + 'Account had a recent payment in last 2 months' + '<br/>';
        }

        if (String.isNotBlank(ERROR_MSG)) {
            return true;
        } else {
            return false;
        }
    }

    public List<SelectOption> getactionItems() {
        List<SelectOption> actionoptions = new List<SelectOption>();
        if (
            product.Collection_Agency__c != null &&
            product.Collection_Agency__c != 9999 &&
            (String.isBlank(product.Status__c) || (String.isNotBlank(product.Status__c) && !product.Status__c.contains(PENDING_RECALL)))
        ) {
            actionoptions.add(new SelectOption(PENDING_RECALL, PENDING_RECALL));
        }
        if (product.Collection_Agency__c != null && product.Collection_Agency__c != 9999) {
            actionoptions.add(new SelectOption('Pending Allocation', 'Pending Allocation'));
        }
        if (product.Collection_Agency__c != 9999) {
            actionoptions.add(new SelectOption('Send to Warehouse', 'Send to Warehouse'));
        }

        if (product.Collection_Agency__c == 9999) {
            actionoptions.add(new SelectOption('Pending Allocation', 'Pending Allocation'));
            actionoptions.add(new SelectOption('Send to Warehouse', 'Send to Warehouse'));
            actionoptions.add(new SelectOption('Pending Allocation', 'Pending Allocation'));
        }

        return actionoptions;
    }

    /**
     * @description : Method to get list of judgments to update once agency on product is updated
     * @author adesh.ikhar@canaccede.com | 06-27-2024
     * @param productIdAgencyInfoMap
     * @return List<Judgment__c>
     **/
    public static List<Judgment__c> updateJudgmentAgency(Map<String, Map<String, String>> productIdAgencyInfoMap) {
        List<Judgment__c> judgmentToUpdateList = new List<Judgment__c>();
        for (Account_Judgment__c activeProductJudgment : [
            SELECT Judgment__c, Product__c
            FROM Account_Judgment__c
            WHERE Product__c IN :productIdAgencyInfoMap.keySet() AND Status__c = 'Active'
        ]) {
            judgmentToUpdateList.add(
                new Judgment__c(
                    Id = activeProductJudgment.Judgment__c,
                    Legal_Agency__c = productIdAgencyInfoMap.get(activeProductJudgment.Product__c).get('Agency'),
                    Legal_Agency_Placement__c = productIdAgencyInfoMap.get(activeProductJudgment.Product__c).get('AgencyPlacement')
                )
            );
        }
        return judgmentToUpdateList;
    }

    public static prodStatusAccJudgStatus getActiveProdIdsFromJudg(Set<String> prodIds) {
        Map<ID, String> prodIdsProdStatus = new Map<ID, String>();
        Map<String, String> prodIdsAcctJudIds = new Map<String, String>();
        Set<String> prodNames = new Set<String>();
        prodStatusAccJudgStatus wrapperData = new prodStatusAccJudgStatus();

        for (Account_Judgment__c prodPresentOnJudg : [
            SELECT Judgment__c, Judgment__r.Product_1__c, Judgment__r.Product_2__c, Judgment__r.Product_3__c, Judgment__r.Product_4__c, Judgment__r.Product_5__c
            FROM Account_Judgment__c
            WHERE Product__c IN :prodIds AND Status__c = 'Active'
        ]) {
            if (prodPresentOnJudg.Judgment__r.Product_1__c <> null) {
                prodNames.add(prodPresentOnJudg.Judgment__r.Product_1__c);
            }
            if (prodPresentOnJudg.Judgment__r.Product_2__c <> null) {
                prodNames.add(prodPresentOnJudg.Judgment__r.Product_2__c);
            }
            if (prodPresentOnJudg.Judgment__r.Product_3__c <> null) {
                prodNames.add(prodPresentOnJudg.Judgment__r.Product_3__c);
            }
            if (prodPresentOnJudg.Judgment__r.Product_4__c <> null) {
                prodNames.add(prodPresentOnJudg.Judgment__r.Product_4__c);
            }
            if (prodPresentOnJudg.Judgment__r.Product_5__c <> null) {
                prodNames.add(prodPresentOnJudg.Judgment__r.Product_5__c);
            }
        }

        List<Account_Judgment__c> activeProductJudgment = [
            SELECT Judgment__c, Product__c, Product__r.Placement_Status__c
            FROM Account_Judgment__c
            WHERE Product__r.name IN :prodNames AND Status__c = 'Active'
        ];

        for (Account_Judgment__c accJud : activeProductJudgment) {
            prodIdsProdStatus.put(accJud.Product__c, accJud.Product__r.Placement_Status__c);
            prodIdsAcctJudIds.put(accJud.Product__c, accJud.id);
        }
        wrapperData.prodIdsProductStatus = prodIdsProdStatus;
        wrapperData.prodIdsAcctJudId = prodIdsAcctJudIds;
        return wrapperData;
    }

    public class prodStatusAccJudgStatus {
        public Map<ID, String> prodIdsProductStatus { get; set; }
        public Map<String, String> prodIdsAcctJudId { get; set; }
    }

    public pageReference redirectToProduct() {
        PageReference pageRef = new PageReference('/' + productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
}