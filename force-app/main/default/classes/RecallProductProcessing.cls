/**************************************************************************************************
*
* Class: AllocationProductProcessing
*
* @description : This class is used for to recall/Account status update of product.

* @author : A5E Consulting
* @date : 13/03/2023

*************************************************************************************************/
public class RecallProductProcessing {
    public static decimal successRecords = 0;
    public static decimal failedRecords = 0;
    public static List<User> systemName = new List<User>();
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public static Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults();

    //Recall/Account status update of product.
    public static ProdIdsJudgListWrapper recallProducts(List<Product_Staging__c> prodStagingList, String workAssignmentId) {
        List<Product__c> prodList = new List<Product__c>();
        Map<String, Id> PlacementMap = new Map<String, Id>();
        Map<Id, String> PlacementStatusMap = new Map<Id, String>();
        List<Id> prodIds = new List<Id>();
        set<id> setProductIDs = new Set<id>();
        Map<String, Account_Judgment__c> accJudgStatusUpdateMap = new Map<String, Account_Judgment__c>();
        Map<String, ID> mapProductJudgment = new Map<String, ID>();
        Map<String, Map<String, String>> productIdAgencyInfoMap = new Map<String, Map<String, String>>();
        List<Judgment__c> judgmentToUpdateList;
        ProdIdsJudgListWrapper wrapperData = new ProdIdsJudgListWrapper();
        Set<String> recallProdIds = new Set<String>();
        Map<id, String> allProdToRecallList = new Map<id, String>();
        List<Product_Staging__c> prodIdsNewList = new List<Product_Staging__c>();
        String statusChangedDate = '';
        String statusChangedDateText = '';
        String placementStatusCode = '';
        String placementMainStatus = '';
        String placementSubStatus = '';

        //Fetch System Api
        if (lrpSetting.Canaccede_API_User__c != null) {
            systemName = [SELECT id, Name FROM User WHERE username = :lrpSetting.Canaccede_API_User__c];
        }
        //Fetch Product RecordType
        for (RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c']) {
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }

        List<Product_Staging__c> listproductstaging = new List<Product_Staging__c>();
        map<String, Placement_Status_Code_Mapping__c> codeMapping = new Map<String, Placement_Status_Code_Mapping__c>();
        for (Placement_Status_Code_Mapping__c mapping : [
            SELECT ID, Name, Data_Status_Code__c, Data_Status_Description__C
            FROM Placement_Status_Code_Mapping__c
            /*WHERE Name LIKE : '9%'*/
        ]) {
            codeMapping.put(mapping.Name, mapping);
        }
        for (Placement__c placeList : [SELECT id, name FROM Placement__c]) {
            PlacementMap.put(placeList.name, placeList.Id);
        }
        Map<string, Product_Staging__c> prodStagingMap = new Map<string, Product_Staging__c>();
        for (Product_Staging__c productStaging : prodStagingList) {
            setProductIDs.add(productStaging.Product_ID__c);
            if ((String.isNotBlank(productStaging.Placement_Status_Code__c) && productStaging.Placement_Status_Code__c.startsWith('9'))) {
                recallProdIds.add(productStaging.Product_ID__c);
                prodStagingMap.put(productStaging.Product_ID__c, productStaging);
            }
        }
        ProductRecallIndividualController.prodStatusAccJudgStatus prodStatusWapper = ProductRecallIndividualController.getActiveProdIdsFromJudg(recallProdIds);
        allProdToRecallList = prodStatusWapper.prodIdsProductStatus;

        for (Id productIds : allProdToRecallList.keySet()) {
            setProductIDs.add(productIds);

            if (prodStagingMap.containsKey(productIds)) {
                if (prodStagingMap.get(productIds).Status_Changed_Date__c != null) {
                    statusChangedDate = prodStagingMap.get(productIds).Status_Changed_Date__c;
                }
                if (prodStagingMap.get(productIds).Placement_Status_Code__c != null) {
                    placementStatusCode = prodStagingMap.get(productIds).Placement_Status_Code__c;
                }
                if (prodStagingMap.get(productIds).Placement_Main_Status__c != null) {
                    placementMainStatus = prodStagingMap.get(productIds).Placement_Main_Status__c;
                }
                if (prodStagingMap.get(productIds).Placement_Sub_Status__c != null) {
                    placementSubStatus = prodStagingMap.get(productIds).Placement_Sub_Status__c;
                }
                if (prodStagingMap.get(productIds).Status_Changed_Date_Text__c != null) {
                    statusChangedDateText = prodStagingMap.get(productIds).Status_Changed_Date_Text__c;
                }
            }
        }
        for (Id productRecallIds : allProdToRecallList.keySet()) {
            Product_Staging__c stagingNewRecord = new Product_Staging__c();
            if (!prodStagingMap.containsKey(productRecallIds)) {
                stagingNewRecord.Product_ID__c = productRecallIds;
                if (statusChangedDate != null) {
                    stagingNewRecord.Status_Changed_Date__c = statusChangedDate;
                }
                if (placementStatusCode != null) {
                    stagingNewRecord.Placement_Status_Code__c = placementStatusCode;
                }
                if (placementMainStatus != null) {
                    stagingNewRecord.Placement_Main_Status__c = placementMainStatus;
                }
                if (placementSubStatus != null) {
                    stagingNewRecord.Placement_Sub_Status__c = placementSubStatus;
                }
                if (statusChangedDateText != null) {
                    stagingNewRecord.Status_Changed_Date_Text__c = statusChangedDateText;
                }
                stagingNewRecord.Identifier__c = prodStagingList[0].Identifier__c;
                stagingNewRecord.Include_in_Processing__c = true;
            }
            if (stagingNewRecord.Product_ID__c != null) {
                prodIdsNewList.add(stagingNewRecord);
            }
        }
        if (!prodIdsNewList.isEmpty()) {
            Database.insert(prodIdsNewList);
        }
        prodStagingList.addAll(prodIdsNewList);

        for (Account_Judgment__c accJudgment : [
            SELECT ID, Judgment__c, Product__c, Product__r.Name
            FROM Account_Judgment__c
            WHERE Product__c IN :setProductIDs AND Status__c = 'Active'
        ]) {
            mapProductJudgment.put(accJudgment.Product__c, accJudgment.id);
        }
        map<ID, Product__c> mapProduct = new Map<ID, Product__c>(
            [
                SELECT ID, Name, RecordTypeId, OwnerId, Collection_Agency__c, Placement_Status__c,Refer_to_Legal__c
                FROM Product__c
                WHERE ID IN :setProductIDs
            ]
        );
        mapProductJudgment = prodStatusWapper.prodIdsAcctJudId;

        try {
            Map<String, Product__c> placementMainStatusMap = JudgmentTriggerHandler.updatePlacementMainStatus(setProductIDs);

            for (Product_Staging__c productStaging : prodStagingList) {
                //Regex to check MM/DD/YYYY (text format in excel)
                String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4})$';

                //Regex to check YYYY/MM/DD (Date format in excel)
                String dateRegex2 = '^([0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';

                String dateRegex3 = '^([0-9]{4}|[0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
                Pattern MyPattern3 = Pattern.compile(dateRegex3);

                Pattern MyPattern1 = Pattern.compile(dateRegex);

                Pattern MyPattern2 = Pattern.compile(dateRegex2);

                Matcher MyMatcher1;
                date myDate;
                if (String.isNotBlank(productStaging.Status_Changed_Date__c)) {
                    //list<String> datelist = productStaging.Status_Changed_Date__c.split('/');
                    //Bug:5438 - Commented above line and changes Starts
                    list<String> datelist = new List<string>();
                    if (productStaging.Status_Changed_Date__c.contains('/')) {
                        datelist = productStaging.Status_Changed_Date__c.split('/');
                    }
                    if (productStaging.Status_Changed_Date__c.contains('-')) {
                        datelist = productStaging.Status_Changed_Date__c.split('-');
                    }
                    //Bug:5438 Changes Ends
                    MyMatcher1 = MyPattern1.matcher(productStaging.Status_Changed_Date__c);
                    Matcher MyMatcher2 = MyPattern2.matcher(productStaging.Status_Changed_Date__c);
                    Matcher MyMatcher3 = MyPattern3.matcher(productStaging.Status_Changed_Date__c);

                    if (MyMatcher1.matches() == true) {
                        myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    }
                    //matching of date when entered in Date format in excel file  product.Status_Changed_Date__c
                    else if (MyMatcher2.matches() == true) {
                        myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    } else if (MyMatcher3.matches() == true) {
                        myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    }
                }

                Product__c prod = new Product__c();
                Product_Staging__c productStaging1 = new Product_Staging__c();
                //productStaging1 = productStaging;
                String comment = '';
                if (String.isNotBlank(productStaging1.Comment__c))
                    comment = productStaging1.Comment__c;

                //If No error found, update product record from staging
                if (productStaging.Status__c != 'Processed' || Test.isRunningTest()) {
                    productStaging1.id = productStaging.id;
                    productStaging1.Status__c = 'Processed';

                    //Ticket 6430 : Point 2
                    if (
                        System.Label.Exclude_Judgment_Codes.contains(mapProduct.get(productStaging.Product_ID__c).Placement_Status__c) &&
                        mapProductJudgment.containsKey(productStaging.Product_ID__c)
                    ) {
                        accJudgStatusUpdateMap = JudgmentTriggerHandler.inactiveAcctJudStatus(mapProductJudgment);
                        if(mapProduct.get(productStaging.Product_ID__c).Refer_to_Legal__c == 'Approved'){
                            prod.Refer_to_Legal__c = '';
                            prod.Reason_for_Legal__c = '';
                        }
                    }
                    prod.id = productStaging.Product_ID__c;
                    prod.Placement_Status__c = productStaging.Placement_Status_Code__c;
                    prod.Status__c = productStaging.Placement_Main_Status__c;
                    prod.Sub_Status__c = productStaging.Placement_Sub_Status__c;
                    prod.Status_Changed_Date__c = myDate;
                    prod.Run_Identifier_Check_On__c = System.today();
                    if ((String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('9')) || Test.isRunningTest()) {
                        if (codeMapping.containsKey(prod.Placement_Status__c)) {
                            if (codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != null) {
                                prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                            }
                        }

                        if (placementMainStatusMap.containskey(productStaging.Product_ID__c)) {
                            prod.Status__c = placementMainStatusMap.get(productStaging.Product_ID__c).Status__c;
                            prod.Sub_Status__c = placementMainStatusMap.get(productStaging.Product_ID__c).Sub_Status__c;
                            prod.Placement_Status__c = placementMainStatusMap.get(productStaging.Product_ID__c).Placement_Status__c;
                            productStaging1.Placement_Main_Status__c = placementMainStatusMap.get(productStaging.Product_ID__c).Status__c;
                            productStaging1.Placement_Sub_Status__c = placementMainStatusMap.get(productStaging.Product_ID__c).Sub_Status__c;
                            productStaging1.Placement_Status_Code__c = placementMainStatusMap.get(productStaging.Product_ID__c).Placement_Status__c;
                        } else {
                            prod.Placement_Status__c = null;
                            prod.Status__c = null;
                            prod.Sub_Status__c = null;
                        }

                        //prod.Collection_Sub_Status__c = null; Rasmitha : 27-Dec as per #4177 Collection Sub Status should not get blank on recall
                        prod.External_Status_Current__c = null;
                        prod.Collection_Agency__c = 9999;
                        prod.Collection_Agency_Placement__c = PlacementMap.get(String.valueOf(prod.Collection_Agency__c));
                        prod.Recalled_Date__c = Date.today();
                        prod.External_Status_Current__c = null;

                        if ((String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('8'))) {
                            if (codeMapping.containsKey(prod.Placement_Status__c)) {
                                if (codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != null) {
                                    prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                    prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                                    prod.External_Status_Current__c = null;
                                }
                            }
                        }
                        if (prod.Collection_Agency__c == 9999) {
                            prodIds.add(Prod.Id);
                            wrapperData.productIds = prodIds;
                            PlacementStatusMap.put(Prod.Id, productStaging.Placement_Status_Code__c);
                            if (
                                prodRTypeIdMap.get('Distressed_Account') == mapProduct.get(productStaging.Product_ID__c).RecordTypeId &&
                                prod.Collection_Agency__c != mapProduct.get(productStaging.Product_ID__c).Collection_Agency__c
                            ) {
                                ID oldOwnerId = mapProduct.get(productStaging.Product_ID__c).OwnerId;
                                // Assign System API to Owner
                                if (!systemName.isEmpty()) {
                                    prod.OwnerId = systemName[0].Id;
                                }
                                //Also Assign the last owner to the previous ownership field
                                if (oldOwnerId <> null && oldOwnerId <> prod.OwnerId) {
                                    prod.Previous_Ownership__c = oldOwnerId;
                                }
                            }
                            productIdAgencyInfoMap.put(
                                prod.Id,
                                new Map<String, String>{
                                    'Agency' => String.valueOf(prod.Collection_Agency__c),
                                    'AgencyPlacement' => prod.Collection_Agency_Placement__c
                                }
                            );
                        }
                        if (prod.Product_Status__c == '297000' || prod.Product_Status__c == '298000') {
                            prod.Purchase_Status__c = 'Buyback/Putback Initiated';
                            prod.Buyback_Putback_Status_Change_Date__c = System.today();
                        }
                    } else {
                        failedRecords = failedRecords + 1;
                    }
                }
                listproductstaging.add(productStaging1);
                prodList.add(prod);
            }
            try {
                if (prodList.size() > 0) {
                    ProductTriggerHandler.runProductTrigger = false;
                    applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = false;
                	update applicationConfigSetting;
                    update prodList;
                    ProductTriggerHandler.runProductTrigger = true;
                    applicationConfigSetting.Bypass_Refer_To_Legal_Validation__c = true;
                	update applicationConfigSetting;

                    if (productIdAgencyInfoMap.values() <> null) {
                        Map<string, Judgment__c> judgMapValues = new Map<string, Judgment__c>();
                        judgmentToUpdateList = ProductRecallIndividualController.updateJudgmentAgency(productIdAgencyInfoMap);
                        if (!judgmentToUpdateList.isEmpty()) {
                            for (Judgment__c judgData : judgmentToUpdateList) {
                                judgMapValues.put(judgData.id, judgData);
                            }
                            JudgmentTriggerHandler.runJudgmentTrigger = false;
                            JudgmentTriggerHandler.runJudgmentValidation = false;
                            //bypass judgment validation rule
                            applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                            update applicationConfigSetting;
                            Database.update(judgMapValues.values());
                            //bypass judgment validation rule
                            applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                            JudgmentTriggerHandler.runJudgmentValidation = true;
                            JudgmentTriggerHandler.runJudgmentTrigger = true;
                            update applicationConfigSetting;
                            wrapperData.judgmentList = judgMapValues.values();
                        }
                    }

                    AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
                    update accJudgStatusUpdateMap.values();
                    AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;
                }

                // Added by satyajit for ticket: 4217
                if (prodIds.size() > 0) {
                    //Update Placement history when product is recalled.
                    DistressedUtilities.updatePlacementHistory_New(ProdIds, PlacementStatusMap);
                }
            } catch (Exception ex) {
                listproductstaging = AllocationProductProcessing.errorHandling(listproductstaging, ex.getMessage());
            }
            if (listproductstaging.size() > 0) {
                update listproductstaging;
            }
        } catch (Exception ex) {
            listproductstaging = AllocationProductProcessing.errorHandling(listproductstaging, ex.getMessage());
            if (listproductstaging.size() > 0) {
                update listproductstaging;
            }
            system.debug('exception success file--+--' + ex.getLineNumber());
            system.debug('exception success file--+--' + ex.getMessage());
        }
        return wrapperData;
    }

    public class ProdIdsJudgListWrapper {
        public List<String> productIds { get; set; }
        public List<Judgment__c> judgmentList { get; set; }
    }
}