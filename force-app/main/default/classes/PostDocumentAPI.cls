public class PostDocumentAPI implements Queueable, Database.AllowsCallouts {
    String failed;
    String success;
    Integer failedRecords;
    Integer successRecords;
    Id workAssignmentId;
    String visiblity;
    Id documentID;
    String DocType;
    public static Boolean stopSuccessfilegenaration = true;
    public Document_Storage__c docData;
    
    public PostDocumentAPI(String DocType,String failed,String success,Integer failedRecords,Integer successRecords,Id workAssignmentId,String visiblity,Id documentID) {
        system.debug('run bacth');
        this.failed = failed;
        this.success = success;
        this.failedRecords = failedRecords;
        this.successRecords = successRecords;
        this.workAssignmentId = workAssignmentId;
        this.visiblity = visiblity;
        this.documentID = documentID;
        this.DocType = DocType;

        docData = [select id,Visibility__c,Placement_Agency__c,Placement_Agency__r.name from Document_Storage__c where id =: documentID];
    }
    public void execute(QueueableContext context) {
        //Database.executeBatch(new ErrorCSVFileGenerationBatch(DocType,failed,success,failedRecords,successRecords,workAssignmentId,visiblity,documentID),2000);                                              
        Map<String,Object> rawObj;
        Map<String,Object> rawObj1;
        DateTime dT = System.now();
        String oldComments = '';
		
        Work_Assignment__c workAssignment = [select id,name,title__c,Task_Number__c,Created_By__c,Status__c,Latest_Comment__c,Comments_History__c,Comment_Reply__c from Work_Assignment__c where id = : workAssignmentId];
        
        //Failed CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();

        Blob fileBlob = Blob.valueOf(failed);

        if(failedRecords > 0){
            if(String.isNotBlank(DocType)){
                if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File' ||
                   DocType == 'Balance Adjustment Upload File'){
                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Payment Failed.csv', 'Task');
                   }else if(DocType == 'Customer Contact Information Update File'){
                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Customer Contact Information Failed.csv', 'Task');
                   }else if(DocType == 'Account Status (having Judgment) Update File'){
                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Account Judgment Failed.csv', 'Task');
                   }else if(DocType == 'Account Status Update File'){
                       parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Account Status Failed.csv', 'Task');
                   }
            }
            rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
        }
        
        //Success CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        Blob fileBlobSuccess = Blob.valueOf(success);

        if(successRecords > 0){
            if(String.isNotBlank(DocType)){
                if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File'||
                   DocType == 'Balance Adjustment Upload File'){
                       parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Payment Success.csv', 'Task');
                   }else if(DocType == 'Customer Contact Information Update File'){
                       parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Customer Contact Information Success.csv', 'Task');
                   }else if(DocType == 'Account Status (having Judgment) Update File'){
                       parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Account Judgment Success.csv', 'Task');
                   }else if(DocType == 'Account Status Update File'){
                       parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Account Status Success.csv', 'Task');
                   }
            }
            rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response); 
        }

        //Create Failed CSV Document Storage
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=false;
        if(null != parsedResponse && failedRecords > 0){
            failedDocStorage.Work_Assignment__c = workAssignmentID;
            if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File' ||
               DocType == 'Balance Adjustment Upload File'){
                   failedDocStorage.Document_Name__c = 'Product Payment Failed.xls';
                   failedDocStorage.Document_Type__C = 'Product Payment Upload File';
               }else if(DocType == 'Customer Contact Information Update File'){
                   failedDocStorage.Document_Name__c = 'Customer Contact Information Failed.xls';
                   failedDocStorage.Document_Type__C = 'Customer Contact Information Update File';
               }else if(DocType == 'Account Status (having Judgment) Update File'){
                   failedDocStorage.Document_Name__c = 'Account Judgment Failed.xls';
                   failedDocStorage.Document_Type__C = 'Account Judgment Processing File';
               }else if(DocType == 'Account Status Update File'){
                   failedDocStorage.Document_Name__c = 'Account Status Failed.csv';
                   failedDocStorage.Document_Type__C = 'Account Status Update';
               }
            
            failedDocStorage.Document_Extension__c = 'xls';
            failedDocStorage.Document_ID__c = parsedResponse.docId;
            //Ticket 4097: visibility should be same as uploaded document
            failedDocStorage.Visibility__c = docData.Visibility__c;
            failedDocStorage.Document_URL__c = parsedResponse.DocUrl;
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            failedDocStorage.File_Processing_Status__c = 'Processed';
            failedDocStorage.Placement_Agency__c = docData.Placement_Agency__c;
            failedDocStorage.Placement_Identifier__c = docData.Placement_Agency__r.name;
            failedDocStorage.Work_Assignment_Identifier__c = workAssignment.Task_Number__c;
            insert failedDocStorage;
        }
        //API call to portal to visisble failure file on portal
        if(DocType == 'Product Payment Upload File' || DocType == 'Account Status Update File'
          || DocType == 'Customer Contact Information Update File'){
              if(failedDocStorage.ID != NULL){
                  PortalDocumentStorageProcessingAPI.processDocumentStorage(failedDocStorage.ID); 
              }
        }
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1 && successRecords > 0){
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;
            if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File' ||
               DocType == 'Balance Adjustment Upload File'){
                   SuccessDocStorage.Document_Name__c = 'Product Payment Success.xls';
                   SuccessDocStorage.Document_Type__C = 'Product Payment Upload File';
               }else if(DocType == 'Customer Contact Information Update File'){
                   SuccessDocStorage.Document_Name__c = 'Customer Contact Information Success.xls';
                   SuccessDocStorage.Document_Type__C = 'Customer Contact Information Update File';
               }else if(DocType == 'Account Status (having Judgment) Update File'){
                   SuccessDocStorage.Document_Name__c = 'Account Judgment Success.xls';
                   SuccessDocStorage.Document_Type__C = 'Account Judgment Processing File';
               }else if(DocType == 'Account Status Update File'){
                   SuccessDocStorage.Document_Name__c = 'Account Status Success.csv';
                   SuccessDocStorage.Document_Type__C = 'Account Status Update';
               }

            SuccessDocStorage.Document_Extension__c = 'xls';
            SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
            //Ticket 4097: visibility should be same as uploaded document
            SuccessDocStorage.Visibility__c = docData.Visibility__c;
            SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            SuccessDocStorage.File_Processing_Status__c = 'Processed';
            SuccessDocStorage.Placement_Agency__c = docData.Placement_Agency__c;
            SuccessDocStorage.Placement_Identifier__c = docData.Placement_Agency__r.name;
            SuccessDocStorage.Work_Assignment_Identifier__c = workAssignment.Task_Number__c;
            insert SuccessDocStorage;
        }
        //API call to portal to visisble failure file on portal
        if(DocType == 'Product Payment Upload File' || DocType == 'Account Status Update File'
          || DocType == 'Customer Contact Information Update File'){
              if(SuccessDocStorage.ID != NULL){
                  PortalDocumentStorageProcessingAPI.processDocumentStorage(SuccessDocStorage.ID); 
              }
        }
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;
        
        workAssignment.Status__c = 'Completed';
        
        if(DocType == 'Product Payment Upload File' && failedRecords > 0 && successRecords == 0){
            stopSuccessfilegenaration = false;
        }
        workAssignment.Comment_Reply__c = '';
        if(stopSuccessfilegenaration == true){
            if(failedRecords > 0){
                workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
            }else{
                workAssignment.Comment_Reply__c = 'No. of Records Failed: 0'+'\n';
            }
            if(successRecords > 0){
                workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
            }else{
                workAssignment.Comment_Reply__c += 'No. of Records Succeeded: 0';
            }
        }else if(stopSuccessfilegenaration == false){
            workAssignment.Comment_Reply__c += 'Whole transaction is failed because of exception please check the error file and share with support team';
        }
        
        if(workAssignment.Comments_History__c !=null){
            oldComments = workAssignment.Comments_History__c;
        }
        workAssignment.Latest_Comment__c = workAssignment.Comment_Reply__c;
        //Bug: 4743 - changes starts
        workAssignment.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
        //Bug: 4743 - changes ends
        if(oldComments != null){
            workAssignment.Comments_History__c += oldComments;
        }
        
        workAssignment.Comment_Reply__c = '';
        
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        update workAssignment;
        stopSuccessfilegenaration = true;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=true; 
        
        //Changes are done by ticket: 4496
        if(!Test.isRunningTest()){
            system.enqueueJob(new CFG_ProcessWorkAssignment(workAssignment.Id));
        }
    }
}