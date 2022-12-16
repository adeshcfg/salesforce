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
        Map<String, String> dataIDs = new Map<String,String>();
        ProductStagingResponse prResponse = (ProductStagingResponse)JSON.deserialize(jsonString, ProductStagingResponse.class); 
       string documentStorageId = prResponse.DocumentStorageId;
        
        dataIDs = getDataIds(prResponse);
        
        //Add and update comment on product staging record based on the parsed response.
        if(!documentStorageId.contains('DS_ACC')){
             updateProductStagings( dataIDs, documentStorageId );
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
    
   /* @future(Callout = true)
    public static void createDocumentStorage(String docID){
        String failedData = 'data_id,place_id,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,error';
        failedData += '\n';
      
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
                                          (Include_in_Processing__c = false
                                           OR
                                          Status__c = 'Pending')
                                          AND
                                          Identifier__c=:docID]; 
        List<Product_Staging__c> prodStagingErrorList = new List<Product_Staging__c>();
        for(Product_Staging__c prodStag : pstgs){
            if(prodStag.Comment__c.contains('ERROR')){
                
                prodStagingErrorList.add(prodStag);
            }
        }
        
        //List<Product_Staging__c> successCount = new List<Product_Staging__c>();
        Integer successCount = 0;
       
        Integer successCountList = [SELECT count() FROM Product_Staging__c 
                                WHERE
                                Identifier__c=:docID];
       
        successCount = successCountList - pstgs.size();
       
        String documentID;
        String workAssignmentID;
        
        //Create Error file
        if(!pstgs.isEmpty()){
            
             documentID = pstgs[0].Identifier__c;
             workAssignmentID = pstgs[0].Document_Storage__r.Work_Assignment__c;
            
            for(Product_Staging__c prodStag: prodStagingErrorList){
                
                String CommentError;  
                if(prodStag.Comment__c!= null){
                    CommentError = prodStag.Comment__c;
                   
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                }
               
                failedData = failedData+ prodStag.Name__c+','+prodStag.Placement_Agency__c
                    +','+prodStag.Pool_Name__c+','+prodStag.Current_Commission_Rate__c
                    +','+prodStag.Placed_Commission_Rate__c+','+prodStag.Current_Settlement_Rate__c
                    +','+prodStag.Placed_Settlement_Rate__c+','+prodStag.Value_Tier_at_Time_of_Placement__c
                    +','+(prodStag.Comment__c!= null ? CommentError : NULL);
                
                failedData = failedData + '\n';
            }    
           
           
        }else{
            documentID = docID;
           	document_storage__c docData = [Select id,work_assignment__c from document_storage__c where id = :docID];
            workAssignmentID = docData.work_assignment__c;
        }
        //Send Document to Azure
         DistressedUtilities.postDocumentAPI(documentID, workAssignmentID, successCount, pstgs.size() ,null,
                                                                    null,failedData, null,null,null);
        
    }*/
   
    public class ProductStagingResponse{
        public string DocumentStorageId {get;set;}
        public List<AllocationsClass> Allocations {get;set;}
    }
    
    public class AllocationsClass{
        public string Agency {get;set;}
        public ErrorsClass[]Errors ;
    }
    
    public class ErrorsClass{
        public string DataId {get;set;}
        public String Detail {get;set;}
    }
}