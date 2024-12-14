/**************************************************************************************************
*
*  Class:    
*
*  @description : This is a Utility class for Data Archival/Un-Archival features
*  @author : A5E Consulting
*  @date : 11/26/2024

*************************************************************************************************/
public class ArchiveUnarchiveUtility {
    //This is a Generic method that Adds the External_Correlation_ID__c value for the List of records sent
    public static void assignExternalCorID(List<sObject> listOfRecords){
        String sObjectType = listOfRecords.getSObjectType().getDescribe().getName();
        List<sObject> recordsToUpdate = new List<sObject>();
        String soql = 'SELECT Id, External_Correlation_ID__c FROM ' + sObjectType + ' WHERE ID IN : listOfRecords';
        List<sObject> queryResult = Database.query(soql);
        for(sObject record : queryResult){
            record.put('External_Correlation_ID__c', record.get('ID'));
            recordsToUpdate.add(record);
        }        
        if(!recordsToUpdate.isEmpty()){
            try{
                recordsToUpdate.sort();
                UPDATE recordsToUpdate;
                
              
            }catch(DmlException de){
                Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
                INSERT error;
            }        
        }
    }
    
    //This is a Generic method that Inserts the sent deleted records in the Deleted_Records__c object
    public static void insertDeletedRecords(List<sObject> deletedRecords){
        String sobjectType = deletedRecords.getSObjectType().getDescribe().getName();
        List<sObject> recordsToInsert = new List<sObject>();
        
        for(sObject records: deletedRecords){
            Deleted_Records__c deletedRec = new Deleted_Records__c();
            deletedRec.Object_Name__c = sobjectType;
            deletedRec.Salesforce_Record_Id__c = (String) records.get('External_Correlation_ID__c');
            recordsToInsert.add(deletedRec);
        }
        if(!recordsToInsert.isEmpty()){
            try{
                recordsToInsert.sort();
                INSERT recordsToInsert;
            }catch(DmlException de){
                Insolvency_Error__c error = new Insolvency_Error__c(Error__c = de.getMessage());
                INSERT error;
            }            
        }        
    }
}