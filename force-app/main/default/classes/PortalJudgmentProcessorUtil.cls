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
    public static Date garnishmentDate;
    public static Date judgmentDate;
    //Create Request Fund record 
    public static String processJudgment(Map<String,String> paramMap, Judgment__c judgment){
        //Create temporary account instance to store request values
        List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
        list<String> listJudgmentStatuses = new list<String>();
        list<Judgment__c> listNewJudgments = new list<Judgment__c>();
        List<ID> productId = new List<ID>();
        List<String> productNames = new List<String>();
        Map<id,Judgment__c> mapJudgment = new Map<id,Judgment__c>();
        mapJudgment.put(judgment.id,judgment);
        system.debug('mapJudgment before::'+mapJudgment);
        system.debug('judgment before::'+judgment);
        writRenewalDate = judgment.Writ_Renewal_Date__c;
        garnishmentDate = judgment.Garnishment_Date__c;
        judgmentDate = judgment.Judgment_Date__c;
        system.debug('judgmentDatecheck'+judgmentDate);
        LegalStatus = judgment.Legal_Status__c;
        LegalSubStatus = judgment.Legal_Sub_Status__c;
        for(Agency_Portal_Fields_Mapping__c mapping : fieldMapping){
            
            if(mapping.Object_Name__c == 'Judgment'){
                
                system.debug('tag:: '+paramMap.get(mapping.Field_JSON_Tag__c));
               
                if(mapping.Field_Type__c == 'Currency'){
                    if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                        judgment.put(mapping.Field_API__c, Decimal.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));
                    }
                }
                else if(mapping.Field_Type__c == 'Date'){
                    if(String.isNotBlank(paramMap.get(mapping.Field_JSON_Tag__c))){
                        judgment.put(mapping.Field_API__c, Date.valueOf(paramMap.get(mapping.Field_JSON_Tag__c)));
                    }
                }
                else{
                    judgment.put(mapping.Field_API__c, paramMap.get(mapping.Field_JSON_Tag__c));
                } 
            }
            
            
        }
        try{
            //to not run workassignment trigger
            JudgmentTriggerHandler.runJudgmentTrigger = false;
            
            //Populate identifier fields from handler method
            list<Judgment__c> listJudgment = new list<Judgment__c>();
            listJudgment.add(judgment);
            getJudgmentRelatedAgencyData(listJudgment);
            system.debug('listJudgment::'+listJudgment);
            judgment.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            judgment.Inbound_API_Response_Body__c = 'Successfully Created';
            system.debug('judgment.ID::'+judgment.ID);
             system.debug('listJudgmentUTIL::'+listJudgment);
            if(judgment.ID == NULL){
                insert judgment;
            }
            else{
                //system.debug('Block run');
                update judgment;
                writRenewalDate = judgment.Writ_Renewal_Date__c;
        		garnishmentDate = judgment.Garnishment_Date__c;
                if(writRenewalDate != null && garnishmentDate != null){
                   if(writRenewalDate != Date.valueOf(paramMap.get('Date_Writ_Issued')) || garnishmentDate != Date.valueOf(paramMap.get('Garnishment_Date'))){
                        system.debug('judgment.id'+judgment.id);
                        PortalJudgmentProcessingAPI.processJudgment(judgment.id);
                    } 
                }
                if(LegalStatus != null && LegalSubStatus != null){
                   if(LegalStatus != paramMap.get('Legal_Status') || LegalSubStatus != paramMap.get('Legal_Sub_Status')){
                       system.debug('inside legal sub status');
                       	listJudgmentStatuses.add(judgment.Legal_Status__c);
        				listNewJudgments.add(judgment);
                       JudgmentTriggerHandler.updateProductStatusesOnJudgment(listNewJudgments,listJudgmentStatuses);
                       system.debug('judgmentDate param'+paramMap.get('Judgment_Date'));
                       system.debug('judgmentDate'+judgmentDate);
                       system.debug('judgment.id'+judgment.id);
                       
                       JudgmentTriggerHandler.updateJudgmentInterestBalOnProduct(listNewJudgments, mapJudgment);
                    } 
                }
                
            }
            JudgmentTriggerHandler.runJudgmentTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in payment transaction insert :'+ex);
            judgment.Inbound_API_Response_Body__c = ex.getMessage();
            if(judgment.Id != NULL){
            update judgment;
        }
            JudgmentTriggerHandler.runJudgmentTrigger = true;
            return ex.getMessage();
        }
    }
     //using this inner method populate the Lookup fields using agency data.
    public static void getJudgmentRelatedAgencyData(list<Judgment__c> listJudgment){
        
        set<String> setSuperiorCourtID = new set<String>();
        set<String> setSmallCourtClaimID = new set<String>();
        set<String> setLegalAgencyID = new set<String>();
        set<String> setEnforcementCountyID = new set<String>();
        set<String> setCountyID = new set<String>();
        set<String> setAgencyInitiatedLegalID = new set<String>();
        
        map<String, Id> mapSuperiorCourtNames = new map<String, Id>();
        map<String, Id> mapSmallCourtClaimNames = new map<String, Id>();
        map<String, Id> mapLegalAgencyNames = new map<String, Id>();
        map<String, Id> mapEnforcementCountyNames = new map<String, Id>();
        map<String, Id> mapCountyNames = new map<String, Id>();
        map<String, Id> mapAgencyInitiatedLegalNames = new map<String, Id>();
        map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
        map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
           
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
        for(Judgment__c judgmentObj : listJudgment){
            
            setSuperiorCourtID.add(judgmentObj.Superior_Court_Identifier__c);
            setSmallCourtClaimID.add(judgmentObj.Small_Claims_Court_Identifier__c);
            setLegalAgencyID.add(judgmentObj.Legal_Agency__c);
            setEnforcementCountyID.add(judgmentObj.Enforcement_County_Identifier__c);
            setCountyID.add(judgmentObj.County_Identifier__c);
            setAgencyInitiatedLegalID.add(judgmentObj.Agency_Initiated_Legal_Action__c);
        }
        system.debug('setSuperiorCourtID:'+setSuperiorCourtID);
        for(Superior_Court__c sCourt : [SELECT ID, Name
                                        FROM Superior_Court__c
                                        WHERE Name IN : setSuperiorCourtID]){
                                            
                                            mapSuperiorCourtNames.put(sCourt.Name, sCourt.Id);
                                            
                                        }
        
        for(Small_Claims_Court__c smallCourt  : [SELECT ID, Name
                                                 FROM Small_Claims_Court__c
                                                 WHERE Name IN :setSmallCourtClaimID]){
                                                     mapSmallCourtClaimNames.put(smallCourt.Name, smallCourt.ID);
                                                     
                                                 }
        for(Placement__c placement : [SELECT ID, Name
                                      FROM Placement__c
                                      WHERE Name IN :setLegalAgencyID]){
                                          mapLegalAgencyNames.put(placement.Name, placement.ID);
                                          
                                      }
        for(Enforcement_County__c enforceCounty : [SELECT ID, Name
                                                   FROM Enforcement_County__c
                                                   WHERE Name IN :setEnforcementCountyID]){
                                                       mapEnforcementCountyNames.put(enforceCounty.Name, enforceCounty.ID);
                                                       
                                                   }
        for(Court__c county : [SELECT ID, Name
                               FROM Court__c
                               WHERE Name IN :setCountyID]){
                                   mapCountyNames.put(county.Name, county.ID);
                                   
                               }
        
        for(Placement__c agencyInitLegal : [SELECT ID, Name
                                            FROM Placement__c
                                            WHERE Name IN :setAgencyInitiatedLegalID]){
                                                mapAgencyInitiatedLegalNames.put(agencyInitLegal.Name, agencyInitLegal.ID);
                                                
                                            }
         
        for(Judgment__c JudgmentObj : listJudgment){
            
            JudgmentObj.Superior_Court__c = mapSuperiorCourtNames.get(JudgmentObj.Superior_Court_Identifier__c);
            JudgmentObj.Small_Claims_Court__c = mapSmallCourtClaimNames.get(JudgmentObj.Small_Claims_Court_Identifier__c);
            JudgmentObj.Legal_Agency_Placement__c = mapLegalAgencyNames.get(JudgmentObj.Legal_Agency__c);
            JudgmentObj.Enforcement_County__c = mapEnforcementCountyNames.get(JudgmentObj.Enforcement_County_Identifier__c);
            JudgmentObj.County__c = mapCountyNames.get(JudgmentObj.County_Identifier__c);
            JudgmentObj.Agency_Initiated_Legal_Action_Lookup__c = mapAgencyInitiatedLegalNames.get(JudgmentObj.Agency_Initiated_Legal_Action__c);
            prodProvinceName = JudgmentObj.Judgment_Province__c;
        }
         system.debug('prodProvinceName::'+prodProvinceName);
         ProvinceNameFormat = nameFormat(prodProvinceName);
        	
         provinceAcronymFormat = prodProvinceName.toUpperCase();
         for(Judgment__c JudgmentObj : listJudgment){
             if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                       JudgmentObj.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c; 
                        //system.debug('judgment.Placed_Province__c::'+judgment.Placed_Province__c);
                    }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                       JudgmentObj.Judgment_Province__c = ProvinceNameFormat; 
                    }
         }
         
        
    }  
    //get Province Name
    public static String nameFormat (String name) {
        String result = '';
        system.debug('name::'+name);
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
}