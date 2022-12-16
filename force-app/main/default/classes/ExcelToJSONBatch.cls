/**************************************************************************************************
*
*  Class:  ExcelToJSONBatch
*
*  @description : Get JSON of excel file that have uploaded by agency user
*  @author : A5E Consulting
*  @date : 29/03/2023

*************************************************************************************************/

public class ExcelToJSONBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    String documentID;
    String placement;
    ID documentStorageID;
    String documentType;
    String documentURL;
    String docDetails;
    Document_storage__c docStorageData = new Document_storage__c();
    
    public ExcelToJSONBatch(String documentID, String placement, ID documentStorageID, String documentType, String documentURL){
        system.debug('inside ExcelToJSONBatch::');
        this.documentID = documentID;
        this.placement = placement;
        this.documentStorageID = documentStorageID;
        this.documentType = documentType;
        this.documentURL = documentURL;
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select id,Document_URL__c,Placement_Identifier__c,Document_Type__c,Uploaded_By__c,Document_ID__c from Document_Storage__c where id =: documentStorageID]);
    }
    
    //Get document JSON
    public void execute(Database.BatchableContext BC, List<Document_Storage__c> scope){
        
        try{
            system.debug('inside ExcelToJSONBatch execute::');
            for(Document_Storage__c scp : scope){
                docDetails = DocumentAPIClient.getDocumentJSON(scp.Document_URL__c);
                docStorageData = scp;
            }
        }catch(exception e){
            system.debug('exception:'+e);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('docDetails::'+docDetails);
        
        //Deserialize the JSON and insert it to product staging.
        if(!Test.isRunningTest()){
            SavePortalAccStatusUpdateFile instance = new SavePortalAccStatusUpdateFile(docDetails, placement, documentStorageID,docStorageData);
        }
    }
}