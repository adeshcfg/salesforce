/*========================================================================
*
* Class: PortalSnapshotCompletionProcessor
*
* @description : This used to for allocation process to create error file.
* @author : A5E Consulting
* @date : 03/02/2023
* @Developer Name: Satyajit Patil
========================================================================*/

@RestResource(urlMapping='/PortalSnapshotCompletionProcessor')


global with sharing class PortalSnapshotCompletionProcessor {
    
    @HttpPost
    global static void doPost() {
        String jsonString = RestContext.request.requestBody.toString();
        parseJson(jsonString);    
    }
    
    public static void parseJson(string jsonString ){
        string documentStorageId ;
        Map<String, String> dataIDs = new Map<String,String>();
        String replaceIllegal= jsonString.replaceAll('\n','').replaceAll('\r','');
        
        ProductStagingResponse prResponse;
        prResponse = (ProductStagingResponse)JSON.deserialize(replaceIllegal, ProductStagingResponse.class); 
        system.debug('prResponse::'+prResponse);
        
        //Added for ticket 4458.
        productError prodErr;
        if(prResponse.Allocations == null || Test.isRunningTest()){
            //String replaceIllegal= jsonString.replaceAll('\n','').replaceAll('\r','');
            DateTime dT = System.now();
            String oldComments = '';
            system.debug('replaceIllegal::'+replaceIllegal);
            prodErr = (productError)JSON.deserialize(replaceIllegal, productError.class); 
            documentStorageId = prodErr.DocumentStorageId;
            document_storage__c docData = [select id,Work_Assignment__c,Work_Assignment__r.Created_By__c ,File_Processing_Status__c from document_storage__c where id = :documentStorageId];
            
            Work_Assignment__c updateWorkAssign  = new Work_Assignment__c();
            updateWorkAssign.id = docData.Work_Assignment__c;
            
            if(prodErr.Error != null && prodErr.Error.length() > 1200){
                updateWorkAssign.Comment_Reply__c = prodErr.Error.subString(0,1199);
            }else{
                updateWorkAssign.Comment_Reply__c = prodErr.Error;
            }
            if(updateWorkAssign.Comments_History__c !=null){
                oldComments = updateWorkAssign.Comments_History__c;
            }
            updateWorkAssign.Latest_Comment__c = updateWorkAssign.Comment_Reply__c;
            updateWorkAssign.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + updateWorkAssign.Comment_Reply__c + '\n' + '\n';
            
            if(oldComments != null){
                updateWorkAssign.Comments_History__c += oldComments;
            }
            
            updateWorkAssign.Comment_Reply__c = '';
            
            updateWorkAssign.Status__c = 'Completed';
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
            update updateWorkAssign;
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            
            // String userName = UserInfo.getUserName();
            system.debug('docData.Work_Assignment__r.Created_By__c::'+docData.Work_Assignment__r.Created_By__c);
            //send failed error file notification.
            CFG_EmailNotification.snapshotFailedEmailNotification(docData.Work_Assignment__r.Created_By__c,prodErr.Error,documentStorageId);
        }
        
      
        if(prResponse.Allocations != null){
            documentStorageId = prResponse.DocumentStorageId;
            dataIDs = getDataIds(prResponse);
            //Bug:4459 changes starts
            set<string> docIDs=new set<string>();
            map<id,document_storage__c> docMap=new map<id,document_storage__c>();
          if(documentStorageId!=NULL) {
           document_storage__c docStorageData = [select id,Work_Assignment__c,Work_Assignment__r.Created_By__c ,File_Processing_Status__c from document_storage__c where id = :documentStorageId];
            if(docStorageData.Work_Assignment__c!=NULL){
            for(AllocationsClass result:prResponse.Allocations){
                docIDs.add(result.DocumentStorageNumber);
            }
            list<document_storage__c> docStoragetoUpdate = [select id,Work_Assignment__c from document_storage__c where Document_Storage_Number__c IN :docIDs];
            for(document_storage__c document:docStoragetoUpdate){
                document.Work_Assignment__c=docStorageData.Work_Assignment__c;
                docMap.put(document.id,document);
            }
            if(!docMap.keySet().isEmpty()){
            update docMap.values();
            }
           }
        }
            //Bug:4459 changes ends
            //Add and update comment on product staging record based on the parsed response.
            if(!documentStorageId.contains('DS_ACC')){
                updateProductStagings( dataIDs, documentStorageId );
            }
        }
        
        
    }
    
    // Updating Product Staging records
    public static void updateProductStagings(Map<String, String> dataIDs, String documentStorageId ){
        
        List<Product_Staging__c> pstgs = [SELECT Id, Identifier__c, Comment__c, 
                                          Document_Storage__r.Work_Assignment__c,
                                          Document_Storage__r.Document_Id__c,
                                          Document_Storage__r.Document_URL__c,
                                          Name__c,Data_Id__c,
                                          Placement_Agency__c,
                                          Pool_Name__c,
                                          Current_Commission_Rate__c,
                                          Placed_Commission_Rate__c,
                                          Current_Settlement_Rate__c,
                                          Placed_Settlement_Rate__c,
                                          Value_Tier_at_Time_of_Placement__c
                                          FROM Product_Staging__c 
                                          WHERE 
                                          Data_Id__c IN: dataIDs.keySet() 
                                          AND 
                                          Identifier__c=:documentStorageId ]; 
        
        for(Product_Staging__c pstg: pstgs){
            String msg = '';
            if(pstg.Comment__c == null){
                //pstg.Comment__c = dataIDs.get(pstg.Data_Id__c);
                msg = dataIDs.get(pstg.Data_Id__c);
            }
            else{
                //pstg.Comment__c = '<b>ERROR</b>- '+ dataIDs.get(pstg.Data_Id__c)+';'+pstg.Comment__c;
                msg = '<b>ERROR</b>- '+ dataIDs.get(pstg.Data_Id__c)+';'+pstg.Comment__c;
            }
            
            if(msg.length() > 254){
                msg = msg.substring(0,254);
            }
            
            pstg.Comment__c = msg;
            pstg.Include_in_Processing__c = false;
        }
        if(!pstgs.isEmpty()){
            update pstgs;
        } 
        
        //Create error file
        //Commented by satyajit
        //createDocumentStorage(documentStorageId);
        
        //Added by satyajit
        Database.executeBatch(new ErrorCSVFileGenerationBatch(documentStorageId,'Product Allocation File'),200);
        
    }
    
    // Prepare DataID Map with Comments from Request
    public static Map<String, String> getDataIds( ProductStagingResponse prResponse ){
        Map<String, String> dataIDs = new Map<String,String>();
        for(AllocationsClass result : prResponse.Allocations){
            for(ErrorsClass error : result.Errors){
                dataIDs.put(error.DataId, error.Detail);
            }
        }
        return dataIDs;
    }
    
    public class ProductStagingResponse{
        public string DocumentStorageId {get;set;}
        public List<AllocationsClass> Allocations {get;set;}
    }
    
    public class AllocationsClass{
        public string Agency {get;set;}
        //Added below line part of bug-4459
        public string DocumentStorageNumber{get;set;}
        public ErrorsClass[]Errors ;
    }
    
    public class ErrorsClass{
        public string DataId {get;set;}
        public String Detail {get;set;}
    }
    
    public class productError{
        public string DocumentStorageId {get;set;}
        public String Error {get;set;}
    }
}