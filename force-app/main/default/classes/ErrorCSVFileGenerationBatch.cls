/**************************************************************************************************
*
* Class: ErrorCSVFileGenerationBatch
*
* @description : This class can be used to generate and attach the Error CSV file during allocation/recall

* @author : A5E Consulting
* @date : 23/03/2023

*************************************************************************************************/
public class ErrorCSVFileGenerationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public string csvHeaderSuccess;
    public string csvHeaderError;
    //public string finalstr;
    public integer failedRecords;
    public integer successRecords;
    //public string DocType;
    //public String failed;
    //public String success;
    //public Id workAssignmentId;
    //public String visiblity;
    //public Id documentID;
    public String documentStorageId;
    //public String documentType;
    public String SUCCESS_STR = 'SUCCESS';
    public String workAssignmentID;
     public String documentType;
    public static String allocate = 'Product Allocation File';
    public static String recall = 'Account Status Update File';
    
    public ErrorCSVFileGenerationBatch(String documentStorageId, String documentType){ 
        this.documentStorageId = documentStorageId;
        this.documentType = documentType;
        successRecords = 0;
        failedRecords = 0;
        //this.documentType = documentType;
        if(documentType == recall){
           csvHeaderError = 'data_id,placement_status_code,status_changed_date,error'+'\n'; 
        }else{
            csvHeaderError = 'data_id,place_id,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,error'+'\n';
        }
        csvHeaderSuccess = 'data_id,placement_status_code,status_changed_date,success'+'\n';
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT id,name,Status__c,Include_in_Processing__c,Placement_Agency__c,Pool_Name__c,Current_Commission_Rate__c,Placed_Commission_Rate__c,placement_status_code__c,Placed_Settlement_Rate__c,Current_Settlement_Rate__c,Value_Tier_at_Time_of_Placement__c,status_changed_date__c,name__c,comment__c,Identifier__c,Document_Storage__r.Work_Assignment__c FROM Product_Staging__c where Identifier__c =:documentStorageId LIMIT 50000]);
    }
    
    public void execute(Database.BatchableContext BC, List<Product_Staging__c> scope){
        string description;
        workAssignmentID = scope[0].Document_Storage__r.Work_Assignment__c;
        for(Product_Staging__c ps:scope){
            //fetch failed Records
            if((ps.Include_in_Processing__c == false || ps.Status__c == 'Pending') && documentType == recall){
                description = ps.comment__c.replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('<br/>', '');
                csvHeaderError +='"'+ps.Name__c+'","'+ps.placement_status_code__C+'","'+ps.status_changed_date__c+'","'+description +'"\n';
                failedRecords = failedRecords + 1;
            }else if((ps.Include_in_Processing__c == false || ps.Status__c == 'Pending') && documentType == allocate){
                description = ps.comment__c.replaceAll('<b>', '').replaceAll('</b>', '').replaceAll('<br/>', '');
                csvHeaderError +='"'+ps.Name__c+'","'+ps.Placement_Agency__c+'","'+ps.Pool_Name__c+'","'+ps.Current_Commission_Rate__c+'","'+ps.Placed_Commission_Rate__c+'","'+ps.Current_Settlement_Rate__c+'","'+ps.Placed_Settlement_Rate__c+'","'+ps.Value_Tier_at_Time_of_Placement__c+'","'+description +'"\n';
                failedRecords = failedRecords + 1;
            }
            
            //fetch Success Records
            if(ps.Include_in_Processing__c == true && ps.Status__c == 'Processed' && documentType != allocate){
                csvHeaderSuccess +='"'+ps.Name__c+'","'+ps.placement_status_code__C+'","'+ps.status_changed_date__c+'","'+SUCCESS_STR +'"\n';
                successRecords = successRecords + 1;
            }
        }  
    }
    public void finish(Database.BatchableContext BC) {
        
        Map<String,Object> rawObj;
        Map<String,Object> rawObj1;
              system.debug('workAssignmentID%%%'+workAssignmentID);  
        //Failed CSV API Call
        system.debug('csvHeaderError: '+csvHeaderError);
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+csvHeaderError);
        Blob fileBlob = Blob.valueOf(csvHeaderError);
        
        if(failedRecords > 0 && !test.isRunningTest()){
            parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Failed.csv', 'Task');
            rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response);
        }
        
        //Success CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        Blob fileBlobSuccess = Blob.valueOf(csvHeaderSuccess);
        if(successRecords > 0 && !test.isRunningTest()){
            parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Success.csv', 'Task');
            rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response);
        }
        
        //Create Failed CSV Document Storage
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=false;
        if(null != parsedResponse && failedRecords > 0){
            failedDocStorage.Work_Assignment__c = workAssignmentID;
            failedDocStorage.Document_Name__c = 'Product Failed.xls';
            if(documentType == recall){
                failedDocStorage.Document_Type__C = 'Account Status Update File';
            }else if(documentType == allocate){
               failedDocStorage.Document_Type__C = allocate; 
            }
            
            failedDocStorage.Document_Extension__c = 'xls';
            failedDocStorage.Document_ID__c = parsedResponse.docId;
            failedDocStorage.Visibility__c = 'CFG Only';
            failedDocStorage.Document_URL__c = parsedResponse.DocUrl;
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            failedDocStorage.File_Processing_Status__c = 'Processed';
            insert failedDocStorage;
        }
        
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1 && successRecords > 0){
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;
            SuccessDocStorage.Document_Name__c = 'Product Success.xls';
            SuccessDocStorage.Document_Type__C = 'Account Status Update File';
            SuccessDocStorage.Document_Extension__c = 'xls';
            SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
            SuccessDocStorage.Visibility__c = 'CFG Only';
            SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            SuccessDocStorage.File_Processing_Status__c = 'Processed';
            insert SuccessDocStorage;
        }
        
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentStorageId, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;
        
        DateTime dT = System.now();
        String oldComments = '';
        system.debug('workAssignmentID%%%'+workAssignmentID);
        Work_Assignment__c workAssignment = [select id,name,title__c,Created_By__c,Status__c,Latest_Comment__c,Comments_History__c,Comment_Reply__c from Work_Assignment__c where id = : workAssignmentID];
        workAssignment.Status__c = 'Completed';
        if(failedRecords > 0){
            workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
        }else{
            workAssignment.Comment_Reply__c = 'No. of Records Failed: 0'+'\n';
        }
        if(successRecords == 0 && documentType == allocate){
            successRecords = [SELECT count() FROM Product_Staging__c 
                                WHERE
                                Identifier__c=:documentStorageId];
            successRecords = successRecords - failedRecords;
        }
        if(successRecords > 0){
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
        }else{
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: 0';
        }
        if(workAssignment.Comments_History__c !=null){
            oldComments = workAssignment.Comments_History__c;
        }
        workAssignment.Latest_Comment__c = workAssignment.Comment_Reply__c;
        //bug:4743 : changes starts
        workAssignment.Comments_History__c = 'System Generated Comment on behalf off' + ' ' +UserInfo.getName()+' '+ 'on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
        //bug:4743 : changes ends
        if(oldComments != null){
            workAssignment.Comments_History__c += oldComments;
        }
        
        workAssignment.Comment_Reply__c = '';
        
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        update workAssignment;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=true; 
        
        //Added by satyajit for ticket: 4424
        if(documentType == recall) {
            // Database.executeBatch(new CFG_ProcessWorkAssignment(workAssignmentId),200);
            
            // Call the work Assignment API to update portal.
            system.enqueueJob(new CFG_ProcessWorkAssignment(workAssignment.Id));
        }
        
        Document_Storage__c docStorage = [select id,name,uploaded_By__c,Created_By__c from Document_Storage__c where id = : documentStorageId];

        if(!Test.isRunningTest() && docStorage.uploaded_By__c != 'External User'){
            CFG_EmailNotification.sendEmailNotificationOnErrorFile(docStorage.Created_By__c,workAssignment.Latest_Comment__c,workAssignment.name,workAssignment.title__c,workAssignment.id,documentType);
       }
    }
}