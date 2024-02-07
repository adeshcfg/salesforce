/**************************************************************************************************
*
*  Class:   
*  @description : This is a webservice class(provide) to create/update Judgment Record from 
*            Salesforce to Portal DB
*  @author : A5E Consulting
*  @date : 17/01/2022

*************************************************************************************************/
public class PortalJudgmentProcessingAPI {
    
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    static List<Agency_Portal_Fields_Mapping__c> fieldMapping = Agency_Portal_Fields_Mapping__c.getall().values();
    public static List<API_Error__c> listAPIErrors = new List<API_Error__c>();
    public static map<String, Agency_Portal_Fields_Mapping__c> mapAgencyField = Agency_Portal_Fields_Mapping__c.getAll();
    public static map<String, object> mapAgencyJudgFieldData = new map<String, object>();

    @future (callout=true)
    public static void processJudgment(ID judgmentId){ 
                            
        String Query = 'SELECT ID,Name,Writ_Renewal_Date_Formula__c,Garnishment_Renewal_Date_Formula__c, ';
        for(Agency_Portal_Fields_Mapping__c fieldMappingInstance : fieldMapping){
            if(fieldMappingInstance.Object_Name__c == 'Judgment'){
                Query += fieldMappingInstance.Field_API__c + ', ';
            }
            
        }
        Query = Query.removeEnd(', ');
        Query+= ' FROM Judgment__c WHERE ID=: judgmentId';
        list<Judgment__c> listJudgment= Database.query(Query);
                                    
        String JudgmentJSONRequest;
        Judgment__c judgmentInstance;
        if(!listJudgment.isEmpty()){
            //Create JSON request for customer update
            judgmentInstance = listJudgment[0];
            for(Agency_Portal_Fields_Mapping__c agencyFieldData : mapAgencyField.values()){
                if(agencyFieldData.Object_Name__c == 'Judgment'){
                    mapAgencyJudgFieldData.put(agencyFieldData.Field_JSON_Tag__c, judgmentInstance.get(agencyFieldData.Field_API__c)); 
                }
            }
            mapAgencyJudgFieldData.put('Writ_Renewal_Date', judgmentInstance.get('Writ_Renewal_Date_Formula__c'));
            mapAgencyJudgFieldData.put('Garnishment_Renewal_Date', judgmentInstance.get('Garnishment_Renewal_Date_Formula__c'));
            JudgmentJSONRequest = JSON.serialize(mapAgencyJudgFieldData);
            
        }
        List<string> JudgmentJSONRequestList = new List<string>();
        JudgmentJSONRequestList.add(JudgmentJSONRequest);
        List<Judgment__c> judList = new List<Judgment__c>();
        judList.add(judgmentInstance);
        
        AzureUtility.apiCallToPortal('Agency Portal API',JudgmentJSONRequestList, 'SFJudgement',judList, 'Judgment');
        
    }
    
}