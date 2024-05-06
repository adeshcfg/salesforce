/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
public class PortalJudgmentProcessorUtil {
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    public static string LegalStatus;
    public static string LegalSubStatus;
    public static string PlacementStatus;
    public static Date writRenewalDate;
    public static Date garnishmentRenewalDate;
    public static Date judgmentDate;
    public static Map<id, Judgment__c> mapJudgment = new Map<id, Judgment__c>();
    //Create Request Fund record
    public static String processJudgment(Map<String, String> paramMap, Judgment__c judgment) {
        //Create temporary account instance to store request values
        List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
        list<String> listJudgmentStatuses = new List<String>();
        list<Judgment__c> listNewJudgments = new List<Judgment__c>();
        List<ID> productId = new List<ID>();
        List<String> productNames = new List<String>();
        Map<String, Agency_Portal_Fields_Mapping__c> fieldNameMappingMap = new Map<String, Agency_Portal_Fields_Mapping__c>();

        Judgment__c judgmentnew = new Judgment__c();
        judgmentnew.id = judgment.id;
        judgmentnew.Legal_Status__c = judgment.Legal_Status__c;
        judgmentnew.Legal_Sub_Status__c = judgment.Legal_Sub_Status__c;
        judgmentnew.Judgment_Date__c = judgment.Judgment_Date__c;

        //judgmentnew = judgment;

        if (!mapJudgment.containsKey(judgmentnew.id)) {
            mapJudgment.put(judgmentnew.id, judgmentnew);
        }

        writRenewalDate = judgment.Writ_Renewal_Date_Formula__c;
        garnishmentRenewalDate = judgment.Garnishment_Renewal_Date_Formula__c;
        judgmentDate = judgment.Judgment_Date__c;
        LegalStatus = judgment.Legal_Status__c;
        LegalSubStatus = judgment.Legal_Sub_Status__c;

        // Create map of Field JSON tag and Agency_Portal_Fields_Mapping__c metadata
        for (Agency_Portal_Fields_Mapping__c mapping : fieldMapping) {
            if (mapping.Object_Name__c == 'Judgment') {
                fieldNameMappingMap.put(mapping.Field_JSON_Tag__c, mapping);
            }
        }

        // Loop over reponse JSON from portal and populate correct Judgment fields
        for (String fieldName : paramMap.keySet()) {
            if (fieldNameMappingMap.containsKey(fieldName)) {
                if (fieldNameMappingMap.get(fieldName).Field_Type__c == 'Currency') {
                    judgment.put(
                        fieldNameMappingMap.get(fieldName).Field_API__c,
                        String.isNotBlank(paramMap.get(fieldName)) ? Decimal.valueOf(paramMap.get(fieldName)) : null
                    );
                } else if (fieldNameMappingMap.get(fieldName).Field_Type__c == 'Date') {
                    judgment.put(
                        fieldNameMappingMap.get(fieldName).Field_API__c,
                        String.isNotBlank(paramMap.get(fieldName)) ? Date.valueOf(paramMap.get(fieldName)) : null
                    );
                } else {
                    judgment.put(fieldNameMappingMap.get(fieldName).Field_API__c, paramMap.get(fieldName));
                }
            }
        }

        try {
            //to not run workassignment trigger
            JudgmentTriggerHandler.runJudgmentTrigger = false;

            //Populate identifier fields from handler method
            list<Judgment__c> listJudgment = new List<Judgment__c>();
            listJudgment.add(judgment);
            getJudgmentRelatedAgencyData(listJudgment);
            judgment.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            judgment.Inbound_API_Response_Body__c = 'Successfully Created';
            if (judgment.ID == null) {
                insert judgment;
            } else {
                update judgment;
                // Re query formula fields to get updated value
                Judgment__c updatedJudgment = [
                    SELECT Writ_Renewal_Date_Formula__c, Garnishment_Renewal_Date_Formula__c
                    FROM Judgment__c
                    WHERE Id = :judgment.Id
                ];
                if (writRenewalDate != null && garnishmentRenewalDate != null) {
                    if (
                        writRenewalDate != updatedJudgment.Writ_Renewal_Date_Formula__c ||
                        garnishmentRenewalDate != updatedJudgment.Garnishment_Renewal_Date_Formula__c
                    ) {
                        PortalJudgmentProcessingAPI.processJudgment(judgment.id);
                    }
                }
                listNewJudgments.add(judgment);
                JudgmentTriggerHandler.updateJudgmentInterestBalOnProduct(listNewJudgments, mapJudgment);
                if (LegalStatus != null && LegalSubStatus != null) {
                    if (LegalStatus != paramMap.get('Legal_Status') || LegalSubStatus != paramMap.get('Legal_Sub_Status')) {
                        listJudgmentStatuses.add(judgment.Legal_Status__c);
                        JudgmentTriggerHandler.updateProductStatusesOnJudgment(listNewJudgments, listJudgmentStatuses);
                    }
                }
            }
            JudgmentTriggerHandler.runJudgmentTrigger = true;
            return 'success';
        } catch (Exception ex) {
            system.debug('Exception in payment transaction insert :' + ex);
            judgment.Inbound_API_Response_Body__c = ex.getMessage();
            if (judgment.Id != null) {
                update judgment;
            }
            JudgmentTriggerHandler.runJudgmentTrigger = true;
            return ex.getMessage();
        }
    }
    //using this inner method populate the Lookup fields using agency data.
    public static void getJudgmentRelatedAgencyData(list<Judgment__c> listJudgment) {
        set<String> setSuperiorCourtID = new Set<String>();
        set<String> setSmallCourtClaimID = new Set<String>();
        set<String> setLegalAgencyID = new Set<String>();
        set<String> setEnforcementCountyID = new Set<String>();
        set<String> setCountyID = new Set<String>();
        set<String> setAgencyInitiatedLegalID = new Set<String>();

        map<String, Id> mapSuperiorCourtNames = new Map<String, Id>();
        map<String, Id> mapSmallCourtClaimNames = new Map<String, Id>();
        map<String, Id> mapLegalAgencyNames = new Map<String, Id>();
        map<String, Id> mapEnforcementCountyNames = new Map<String, Id>();
        map<String, Id> mapCountyNames = new Map<String, Id>();
        map<String, Id> mapAgencyInitiatedLegalNames = new Map<String, Id>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new Map<String, Province_Tax_Rate_Mapping__mdt>();

        for (Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()) {
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
        for (Judgment__c judgmentObj : listJudgment) {
            setSuperiorCourtID.add(judgmentObj.Superior_Court_Identifier__c);
            setSmallCourtClaimID.add(judgmentObj.Small_Claims_Court_Identifier__c);
            setLegalAgencyID.add(judgmentObj.Legal_Agency__c);
            setEnforcementCountyID.add(judgmentObj.Enforcement_County_Identifier__c);
            setCountyID.add(judgmentObj.County_Identifier__c);
            setAgencyInitiatedLegalID.add(judgmentObj.Agency_Initiated_Legal_Action__c);
        }

        for (Superior_Court__c sCourt : [
            SELECT ID, Name
            FROM Superior_Court__c
            WHERE Name IN :setSuperiorCourtID
        ]) {
            mapSuperiorCourtNames.put(sCourt.Name, sCourt.Id);
        }

        for (Small_Claims_Court__c smallCourt : [
            SELECT ID, Name
            FROM Small_Claims_Court__c
            WHERE Name IN :setSmallCourtClaimID
        ]) {
            mapSmallCourtClaimNames.put(smallCourt.Name, smallCourt.ID);
        }
        for (Placement__c placement : [
            SELECT ID, Name
            FROM Placement__c
            WHERE Name IN :setLegalAgencyID
        ]) {
            mapLegalAgencyNames.put(placement.Name, placement.ID);
        }
        for (Enforcement_County__c enforceCounty : [
            SELECT ID, Name
            FROM Enforcement_County__c
            WHERE Name IN :setEnforcementCountyID
        ]) {
            mapEnforcementCountyNames.put(enforceCounty.Name, enforceCounty.ID);
        }
        for (Court__c county : [
            SELECT ID, Name
            FROM Court__c
            WHERE Name IN :setCountyID
        ]) {
            mapCountyNames.put(county.Name, county.ID);
        }

        for (Placement__c agencyInitLegal : [
            SELECT ID, Name
            FROM Placement__c
            WHERE Name IN :setAgencyInitiatedLegalID
        ]) {
            mapAgencyInitiatedLegalNames.put(agencyInitLegal.Name, agencyInitLegal.ID);
        }

        for (Judgment__c JudgmentObj : listJudgment) {
            JudgmentObj.Superior_Court__c = mapSuperiorCourtNames.get(JudgmentObj.Superior_Court_Identifier__c);
            JudgmentObj.Small_Claims_Court__c = mapSmallCourtClaimNames.get(JudgmentObj.Small_Claims_Court_Identifier__c);
            JudgmentObj.Legal_Agency_Placement__c = mapLegalAgencyNames.get(JudgmentObj.Legal_Agency__c);
            JudgmentObj.Enforcement_County__c = mapEnforcementCountyNames.get(JudgmentObj.Enforcement_County_Identifier__c);
            JudgmentObj.County__c = mapCountyNames.get(JudgmentObj.County_Identifier__c);
            JudgmentObj.Agency_Initiated_Legal_Action_Lookup__c = mapAgencyInitiatedLegalNames.get(JudgmentObj.Agency_Initiated_Legal_Action__c);
            prodProvinceName = JudgmentObj.Judgment_Province__c;
        }

        ProvinceNameFormat = nameFormat(prodProvinceName);

        provinceAcronymFormat = prodProvinceName.toUpperCase();
        for (Judgment__c JudgmentObj : listJudgment) {
            if (mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)) {
                JudgmentObj.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
            } else if (mapTaxMetadata.containsKey(ProvinceNameFormat)) {
                JudgmentObj.Judgment_Province__c = ProvinceNameFormat;
            }
        }
    }
    //get Province Name
    public static String nameFormat(String name) {
        String result = '';
        system.debug('name::' + name);
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
}
