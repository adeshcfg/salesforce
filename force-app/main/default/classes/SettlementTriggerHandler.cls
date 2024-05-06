/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This is a Trigger Handler Class for Settlement__c object
 *  @author : A5E Consulting
 *  @date : 06/09/2020
 *
 *************************************************************************************************/
public class SettlementTriggerHandler {
    public static final string SEPARATOR = 'A';
    public static final string UNPLACED = 'unplaced';
    public static Map<String, Id> collectionAgency = new Map<String, Id>();
    public static boolean runSettlementTrigger = true;
    public static Boolean firstcall = false;

    static {
        for (Placement__c place : [SELECT id, Name, Agency_Name__c FROM Placement__c]) {
            collectionAgency.put(place.Name, place.Id);
        }
    }

    public static void handleAfterInsert(list<Settlement__c> listNewSettlements) {
        updateSettlementIdentifiers(listNewSettlements);
    }

    public static void handleBeforeInsert(List<Settlement__c> listNewSettlements) {
        // list<String> listSettlementStatus = new list<String>();
        set<ID> setProductID = new Set<ID>();
        set<ID> setJudgmentID = new Set<ID>();
        Map<Id, list<Settlement__c>> mapProductSettlements = new Map<Id, list<Settlement__c>>();
        Map<Id, list<Settlement__c>> mapJudgmentSettlements = new Map<Id, list<Settlement__c>>();

        for (Settlement__c settlemnt : listNewSettlements) {
            setProductID.add(settlemnt.Product__c);
            setJudgmentID.add(settlemnt.Judgment__c);
            settlemnt.Last_Modified_By__c = UserInfo.getName();
        }
        //Added Status != Not completed in below SOQL Query as part of #5145
        for (Settlement__c newSettle : [
            SELECT Id, Status__c, Product__c, Judgment__c
            FROM Settlement__c
            WHERE
                ((Judgment__c IN :setJudgmentID
                AND Judgment__c != NULL)
                OR (Product__c IN :setProductID
                AND Product__c != NULL))
                AND Status__c != 'Rejected'
                AND Status__c != 'Withdraw'
                AND Status__c != 'Not completed'
        ]) {
            if (newSettle.Judgment__c != null && mapJudgmentSettlements.containsKey(newSettle.Judgment__c)) {
                List<Settlement__c> listJudgSettlement = mapJudgmentSettlements.get(newSettle.Judgment__c);
                listJudgSettlement.add(newSettle);
                mapJudgmentSettlements.put(newSettle.Judgment__c, listJudgSettlement);
            } else {
                if (newSettle.Judgment__c != null) {
                    mapJudgmentSettlements.put(newSettle.Judgment__c, new List<Settlement__c>{ newSettle });
                }
            }
            if (newSettle.Product__c != null && mapProductSettlements.containsKey(newSettle.Product__c)) {
                List<Settlement__c> listSettlement = mapProductSettlements.get(newSettle.Product__c);
                listSettlement.add(newSettle);
                mapProductSettlements.put(newSettle.Product__c, listSettlement);
            } else {
                if (newSettle.Product__c != null) {
                    mapProductSettlements.put(newSettle.Product__c, new List<Settlement__c>{ newSettle });
                }
            }
        }

        for (Settlement__c settlement : listNewSettlements) {
            if (settlement.Judgment__c != null && mapJudgmentSettlements.containsKey(settlement.Judgment__c)) {
                settlement.addError('Their is already active settlement present for Judgment');
            } else if (settlement.Product__c != null && mapProductSettlements.containsKey(settlement.Product__c)) {
                settlement.addError('Their is already active settlement present for Product');
            }
        }
    }

    public static void handleAfterUpdate(list<Settlement__c> listNewSettlments, map<id, Settlement__c> mapOldSettlments) {
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        list<Settlement__c> listSettlmentsForIdentifier = new List<Settlement__c>();
        list<Work_Assignment__c> listWorkAssignments = new List<Work_Assignment__c>();
        if (!firstcall) {
            firstcall = true;
            if (config.Run_Settlement_Update_API_for_Portal__c) {
                //call API
                PortalSettlementProcessingAPI.processSettlement(listNewSettlments[0].ID);
            }
        }
        for (Settlement__c settlmentObj : listNewSettlments) {
            if (config.Run_Settlement_Update_API_for_Portal__c) {
                //call API
                PortalSettlementProcessingAPI.processSettlement(settlmentObj.ID);
            }
            if (
                settlmentObj.Product__c != mapOldSettlments.get(settlmentObj.Id).Product__c ||
                settlmentObj.Judgment__c != mapOldSettlments.get(settlmentObj.Id).Judgment__c
            ) {
                listSettlmentsForIdentifier.add(settlmentObj);
            }
        }
        if (!listSettlmentsForIdentifier.isEmpty()) {
            updateSettlementIdentifiers(listSettlmentsForIdentifier);
        }
    }
    //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)

    public static void SetPlacementAgency(list<Settlement__c> listNewSettlements) {
        list<Settlement__c> listInternalNewSettlements = new List<Settlement__c>();
        list<Settlement__c> listExternalNewSettlements = new List<Settlement__c>();
        list<String> listSettlementStatus = new List<String>();
        Map<Id, Product__c> mapProduct = new Map<Id, Product__c>();
        Map<Id, Judgment__c> mapJudgment = new Map<Id, Judgment__c>();
        set<ID> setProductID = new Set<ID>();
        set<ID> setJudgmentID = new Set<ID>();
        for (Settlement__c settl : listNewSettlements) {
            listSettlementStatus.add(settl.Status__c);
            setProductID.add(settl.Product__c);
            setJudgmentID.add(settl.Judgment__c);
        }
        for (Product__c prod : [
            SELECT ID, Name, Collection_Agency_Placement__c
            FROM Product__c
            WHERE id IN :setProductID
        ]) {
            mapProduct.put(prod.id, prod);
        }
        for (Judgment__c Judg : [
            SELECT ID, Name, Legal_Agency_Placement__c
            FROM Judgment__c
            WHERE id IN :setJudgmentID
        ]) {
            mapJudgment.put(Judg.id, Judg);
        }

        for (Settlement__c settlemnt : listNewSettlements) {
            //setProductID.add(settlemnt.Product__c);
            if (settlemnt.Placement__c == null) {
                if (settlemnt.Product__c != null) {
                    settlemnt.Placement__c = mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c;
                } else if (settlemnt.Judgment__c != null) {
                    settlemnt.Placement__c = mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c;
                } else if (String.isNotBlank(settlemnt.Placement_Text_Id__c)) {
                    settlemnt.Placement__c = collectionAgency.get(settlemnt.Placement_Text_Id__c);
                }
            }

            DateTime dT = System.now();
            if (settlemnt.Placement__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Product__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Judgment__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Approved_By__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Rejected_By__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Approved_Date__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Rejected_Date__c <> null) {
                listInternalNewSettlements.add(settlemnt);
            }
            if (settlemnt.Comment__c != null) {
                settlemnt.Comments_History__c =
                    UserInfo.getName() +
                    ' ' +
                    'added on' +
                    ' ' +
                    dT.month() +
                    '/' +
                    dT.day() +
                    '/' +
                    dT.year() +
                    ';' +
                    ' ' +
                    ' ' +
                    settlemnt.Comment__c;
            }
        }

        updateProductStatusesOnSettlement(listNewSettlements, listSettlementStatus);
        //method calls once record created/update in CFG
        getSettlementRelatedData(listInternalNewSettlements);
    }

    //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)

    public static void SetPlacementAgencyBeforeUpdate(list<Settlement__c> listNewSettlements, map<id, Settlement__c> mapOldSettlments) {
        list<Settlement__c> listInternalNewSettlements = new List<Settlement__c>();
        list<Settlement__c> listExternalNewSettlements = new List<Settlement__c>();
        list<String> listSettlementStatus = new List<String>();
        Map<Id, Product__c> mapProduct = new Map<Id, Product__c>();
        Map<Id, Judgment__c> mapJudgment = new Map<Id, Judgment__c>();
        set<ID> setProductID = new Set<ID>();
        set<ID> setJudgmentID = new Set<ID>();
        DateTime dT1 = System.now();

        for (Settlement__c settl : listNewSettlements) {
            listSettlementStatus.add(settl.Status__c);
            Settlement__c settlementOld1 = mapOldSettlments.get(settl.id);
            setProductID.add(settl.Product__c);
            setJudgmentID.add(settl.Judgment__c);
            settl.Last_Modified_By__c = UserInfo.getName();
            if (settl.Comment__c != null && settl.Comment__c != settlementOld1.Comment__c) {
                try {
                    settl.Comments_History__c =
                        UserInfo.getName() +
                        ' ' +
                        'added on' +
                        ' ' +
                        dT1.month() +
                        '/' +
                        dT1.day() +
                        '/' +
                        dT1.year() +
                        ';' +
                        ' ' +
                        ' ' +
                        settl.Comment__c +
                        '\n' +
                        '\n';

                    if (settlementOld1.Comments_History__c != null) {
                        //settlemnt.Comments_History__c += '\n';
                        settl.Comments_History__c += settlementOld1.Comments_History__c;
                    }
                } catch (exception e) {
                }
            }
        }

        for (Product__c prod : [
            SELECT ID, Name, Collection_Agency_Placement__c
            FROM Product__c
            WHERE id IN :setProductID
        ]) {
            mapProduct.put(prod.id, prod);
        }

        for (Judgment__c Judg : [
            SELECT ID, Name, Legal_Agency_Placement__c
            FROM Judgment__c
            WHERE id IN :setJudgmentID
        ]) {
            mapJudgment.put(Judg.id, Judg);
        }

        for (Settlement__c settlemnt : listNewSettlements) {
            //setProductID.add(settlemnt.Product__c);
            if (settlemnt.Placement__c == null) {
                if (settlemnt.Product__c != null) {
                    settlemnt.Placement__c = mapProduct.get(settlemnt.Product__c).Collection_Agency_Placement__c;
                } else if (settlemnt.Judgment__c != null) {
                    settlemnt.Placement__c = mapJudgment.get(settlemnt.Judgment__c).Legal_Agency_Placement__c;
                } else if (String.isNotBlank(settlemnt.Placement_Text_Id__c)) {
                    settlemnt.Placement__c = collectionAgency.get(settlemnt.Placement_Text_Id__c);
                }
            }

            DateTime dT = System.now();
            Boolean identifierRemovalFlag = false;
            Settlement__c settlementOld = mapOldSettlments.get(settlemnt.id);
            if (settlemnt.Product__c != null) {
                if (settlemnt.Product__c != settlementOld.Product__c) {
                    listInternalNewSettlements.add(settlemnt);
                }
            } else {
                settlemnt.Product_Identifier__c = null;
            }
            if (settlemnt.Placement__c != null) {
                if (settlemnt.Placement__c != settlementOld.Placement__c) {
                    listInternalNewSettlements.add(settlemnt);
                }
            } else {
                settlemnt.Placement_Identifier__c = null;
            }
            if (settlemnt.Judgment__c != null) {
                if (settlemnt.Judgment__c != settlementOld.Judgment__c) {
                    listInternalNewSettlements.add(settlemnt);
                }
            } else {
                settlemnt.Judgment_Identifier__c = null;
            }
            if (settlemnt.Approved_By__c != null) {
                if (settlemnt.Approved_By__c != settlementOld.Approved_By__c) {
                    listInternalNewSettlements.add(settlemnt);
                }
            } else {
                settlemnt.Approved_By_text__c = null;
            }
            if (settlemnt.Rejected_By__c != null) {
                if (settlemnt.Rejected_By__c != settlementOld.Rejected_By__c) {
                    listInternalNewSettlements.add(settlemnt);
                }
            } else {
                settlemnt.Rejected_By_Text__c = null;
            }
            if (
                settlemnt.Required_Amount__c != mapOldSettlments.get(settlemnt.Id).Required_Amount__c &&
                settlemnt.Required_Amount__c != settlemnt.Proposal_Amount__c
            ) {
                settlemnt.Status__c = 'Counter offer proposed';
            }
        }

        updateProductStatusesOnSettlement(listNewSettlements, listSettlementStatus);
        //method calls once record created/update in CFG
        getSettlementRelatedData(listInternalNewSettlements);
    }

    public static void updateSettlementIdentifiers(list<Settlement__c> listSettlmentsForIdentifier) {
        list<Settlement__c> listSettlememtsToUpdate = new List<Settlement__c>();
        for (Settlement__c settlementObj : [
            SELECT ID, Product__r.Collection_Agency__c, Judgment__r.Collection_Agency_Identifier__c
            FROM Settlement__c
            WHERE ID IN :listSettlmentsForIdentifier
        ]) {
            //Check if Product Collection Agency is not null and set Settlement Product Collection Identifier
            if (settlementObj.Product__c != null) {
                if (settlementObj.Product__r.Collection_Agency__c != null && settlementObj.Product__r.Collection_Agency__c != 9999) {
                    settlementObj.Product_Collection_Agency_Identifier__c =
                        SEPARATOR +
                        String.valueOf((integer) settlementObj.Product__r.Collection_Agency__c) +
                        SEPARATOR;
                } else {
                    settlementObj.Product_Collection_Agency_Identifier__c = SEPARATOR + UNPLACED + SEPARATOR;
                }
                settlementObj.External_Collection_Agency_Identifier__c = settlementObj.Product_Collection_Agency_Identifier__c;
            }
            //Else set Judgement Product Collection Identifier from Judgment
            else {
                if (settlementObj.Judgment__c != null) {
                    if (
                        String.isNotBlank(settlementObj.Judgment__r.Collection_Agency_Identifier__c) &&
                        settlementObj.Judgment__r.Collection_Agency_Identifier__c != '9999'
                    ) {
                        settlementObj.Judgment_Collection_Agency_Identifier__c = settlementObj.Judgment__r.Collection_Agency_Identifier__c;
                    } else {
                        settlementObj.Judgment_Collection_Agency_Identifier__c = SEPARATOR + UNPLACED + SEPARATOR;
                    }
                    settlementObj.External_Collection_Agency_Identifier__c = settlementObj.Judgment_Collection_Agency_Identifier__c;
                }
            }
            //Update the external Collection Agency Identifier for Agency Group Sharing Rule
            settlementObj.External_Collection_Agency_Identifier__c = settlementObj.External_Collection_Agency_Identifier__c.replace('A68A', '')
                .replace('A6A', '')
                .replace(SEPARATOR + UNPLACED + SEPARATOR, '')
                .replace(',', '');
            listSettlememtsToUpdate.add(settlementObj);
        }

        //Update Settlements
        if (!listSettlememtsToUpdate.isEmpty()) {
            SettlementTriggerHandler.runSettlementTrigger = false;
            update listSettlememtsToUpdate;
            SettlementTriggerHandler.runSettlementTrigger = true;
        }
    }

    //using this inner method populate the identifier fields using CFG data.
    public static void getSettlementRelatedData(list<Settlement__c> listSettlements) {
        set<Id> setPlacementID = new Set<Id>();
        set<Id> setProductID = new Set<Id>();
        set<Id> setJudgmentID = new Set<Id>();
        set<Id> setApprovedByID = new Set<Id>();
        set<Id> setRejectedByID = new Set<Id>();
        set<Id> setApprovedDateID = new Set<Id>();
        set<Id> setRejectedDateID = new Set<Id>();

        map<Id, String> mapPlacementNames = new Map<Id, String>();
        map<Id, String> mapProductNames = new Map<Id, String>();
        map<Id, String> mapJudgmentNames = new Map<Id, String>();
        map<Id, String> mapApprovedByNames = new Map<Id, String>();
        map<Id, String> mapRejectedByNames = new Map<Id, String>();
        map<Id, String> mapApprovedDateNames = new Map<Id, String>();
        map<Id, String> mapRejectedDateNames = new Map<Id, String>();
        map<Id, Decimal> mapProductCollectionAgency = new Map<Id, Decimal>();

        for (Settlement__c settlementObj : listSettlements) {
            setPlacementID.add(settlementObj.Placement__c);
            setProductID.add(settlementObj.Product__c);
            setJudgmentID.add(settlementObj.Judgment__c);
            setApprovedByID.add(settlementObj.Approved_By__c);
            setRejectedByID.add(settlementObj.Rejected_By__c);
        }

        for (Placement__c placement : [
            SELECT ID, Name
            FROM Placement__c
            WHERE ID IN :setPlacementID
        ]) {
            mapPlacementNames.put(placement.Id, placement.Name);
        }

        for (Product__c product : [
            SELECT ID, Name, Collection_Agency__c
            FROM Product__c
            WHERE ID IN :setProductID
        ]) {
            mapProductNames.put(product.ID, product.Name);
            mapProductCollectionAgency.put(product.ID, product.Collection_Agency__c);
        }
        for (Judgment__c Judgment : [
            SELECT ID, Name, Judgment_Number__c
            FROM Judgment__c
            WHERE ID IN :setJudgmentID
        ]) {
            mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
        }
        for (User users : [
            SELECT ID, Name
            FROM User
            WHERE ID IN :setApprovedByID
        ]) {
            mapApprovedByNames.put(users.ID, users.Name);
        }
        for (User users : [
            SELECT ID, Name
            FROM User
            WHERE ID IN :setRejectedByID
        ]) {
            mapRejectedByNames.put(users.ID, users.Name);
        }

        for (Settlement__c settlementObj : listSettlements) {
            settlementObj.Placement_Identifier__c = mapPlacementNames.get(settlementObj.Placement__c);
            settlementObj.Product_Identifier__c = mapProductNames.get(settlementObj.Product__c);
            settlementObj.Judgment_Identifier__c = mapJudgmentNames.get(settlementObj.Judgment__c);
            settlementObj.Approved_By_text__c = mapApprovedByNames.get(settlementObj.Approved_By__c);
            settlementObj.Rejected_By_Text__c = mapRejectedByNames.get(settlementObj.Rejected_By__c);
            settlementObj.External_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product__c));
            settlementObj.Product_Collection_Agency_Identifier__c = String.ValueOf(mapProductCollectionAgency.get(settlementObj.Product__c));
        }
    }

    //method to update Placement  Status of Product based on Settlement Status
    public static void updateProductStatusesOnSettlement(list<Settlement__c> listNewSettlement, list<String> listOfStatus) {
        list<Product__c> listProduct = new List<Product__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountSettlementCodes = new Map<String, Judgment_product_codes_mapping__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new Map<String, Judgment_product_codes_mapping__c>();
        map<ID, ID> mapActiveAccountJudgments = new Map<ID, ID>();
        Set<ID> ProductIDs = new Set<ID>();
        list<String> listJudgmentStatuses = new List<String>();
        for (Settlement__c settlementData : listNewSettlement) {
            ProductIDs.add(settlementData.Product__c);
        }
        List<Account_Judgment__c> accJudgment = [
            SELECT ID, Judgment__c, Product__c, Product__r.name, Judgment__r.Legal_Status__c, Judgment__r.Legal_Sub_Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :ProductIDs AND Status__c = 'Active'
        ];
        Map<id, Account_Judgment__c> mapAccJudg = new Map<id, Account_Judgment__c>();
        for (Account_Judgment__c accJud : accJudgment) {
            mapAccJudg.put(accJud.Product__c, accJud);
            listJudgmentStatuses.add(accJud.Judgment__r.Legal_Status__c);
        }

        for (Judgment_product_codes_mapping__c mapping : [
            SELECT Id, Name, Codes__c, Product_Status__c, Product_Sub_status__c, Judgment_Legal_Status__c, Judgment_Legal_Sub_Status__c
            FROM Judgment_product_codes_mapping__c
            WHERE Product_Parent__c IN :listJudgmentStatuses
        ]) {
            mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c + mapping.Judgment_Legal_Sub_Status__c, mapping);
        }

        for (Judgment_product_codes_mapping__c mapping : [
            SELECT
                Id,
                Name,
                Codes__c,
                Product_Status__c,
                Product_Parent__c,
                Product_Sub_status__c,
                Judgment_Legal_Status__c,
                Judgment_Legal_Sub_Status__c,
                Settlement_Status__c
            FROM Judgment_product_codes_mapping__c
            WHERE Product_Parent__c IN :listOfStatus
        ]) {
            mapAccountSettlementCodes.put(mapping.Settlement_Status__c, mapping);
        }

        for (Settlement__c settlement : listNewSettlement) {
            if (mapAccountSettlementCodes.containsKey(settlement.Status__c)) {
                Product__c product = new Product__c();
                product.ID = settlement.Product__c;
                if (mapAccJudg.containsKey(product.ID)) {
                    if (
                        mapAccountJudgmentCodes.containsKey(
                            mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c + mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c
                        )
                    ) {
                        product.Status__c = mapAccountJudgmentCodes.get(
                                mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c + mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c
                            )
                            .Product_Status__c;
                        product.Sub_Status__c = mapAccountJudgmentCodes.get(
                                mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c + mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c
                            )
                            .Product_Sub_status__c;
                        product.Placement_Status__c = mapAccountJudgmentCodes.get(
                                mapAccJudg.get(product.ID).Judgment__r.Legal_Status__c + mapAccJudg.get(product.ID).Judgment__r.Legal_Sub_Status__c
                            )
                            .Codes__c;
                    }
                } else {
                    product.Status__c = mapAccountSettlementCodes.get(settlement.Status__c).Product_Status__c;
                    product.Sub_Status__c = null;
                    product.Placement_Status__c = mapAccountSettlementCodes.get(settlement.Status__c).Codes__c;
                }
                listProduct.add(product);
            }
        }

        //update product list
        ProductTriggerHandler.runProductTrigger = false;
        update listProduct;
        ProductTriggerHandler.runProductTrigger = true;
    }
}
