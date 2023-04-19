public class PostDocumentAPI implements Queueable, Database.AllowsCallouts {
    String failed;
    String success;
    Integer failedRecords;
    Integer successRecords;
    Id workAssignmentId;
    String visiblity;
    Id documentID;
    String DocType;
    
    public PostDocumentAPI(String DocType,String failed,String success,Integer failedRecords,Integer successRecords,Id workAssignmentId,String visiblity,Id documentID) {
        this.failed = failed;
        this.success = success;
        this.failedRecords = failedRecords;
        this.successRecords = successRecords;
        this.workAssignmentId = workAssignmentId;
        this.visiblity = visiblity;
        this.documentID = documentID;
        this.DocType = DocType;
    }
    public void execute(QueueableContext context) {
        Map<String,Object> rawObj;
        Map<String,Object> rawObj1;
        
        //Failed CSV API Call
        system.debug('failed: '+failed);
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+failed);
        Blob fileBlob = Blob.valueOf(failed);
        system.debug('fileBlob::'+fileBlob);
        if(failedRecords > 0){
                if(String.isNotBlank(DocType)){
                    if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File' ||
                       DocType == 'Balance Adjustment Upload File'){
                        parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Payment Failed.csv', 'Task');
                    }else if(DocType == 'Customer Contact Information Update File'){
                        parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Customer Contact Information Failed.csv', 'Task');
                    }else if(DocType == 'Account Status (having Judgment) Update File'){
                        parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Account Judgment Failed.csv', 'Task');
                    }
                }
                
                rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
        }
        
        //Success CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        Blob fileBlobSuccess = Blob.valueOf(success);
        system.debug('fileBlobSuccess::'+fileBlobSuccess.size());
        if(successRecords > 0){
                if(String.isNotBlank(DocType)){
                    if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File'||
                       DocType == 'Balance Adjustment Upload File'){
                        parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Payment Success.csv', 'Task');
                    }else if(DocType == 'Customer Contact Information Update File'){
                        parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Customer Contact Information Success.csv', 'Task');
                    }else if(DocType == 'Account Status (having Judgment) Update File'){
                        parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Account Judgment Success.csv', 'Task');
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
                failedDocStorage.Document_Type__C = 'Payment Processing File';
            }else if(DocType == 'Customer Contact Information Update File'){
                failedDocStorage.Document_Name__c = 'Customer Contact Information Failed.xls';
                failedDocStorage.Document_Type__C = 'Payment Processing File';
            }else if(DocType == 'Account Status (having Judgment) Update File'){
                failedDocStorage.Document_Name__c = 'Account Judgment Failed.xls';
                failedDocStorage.Document_Type__C = 'Account Judgment Processing File';
            }
            failedDocStorage.Document_Extension__c = 'xls';
            failedDocStorage.Document_ID__c = parsedResponse.docId;
            failedDocStorage.Visibility__c = visiblity;
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
            if(DocType == 'Product Payment Upload File' || DocType == 'Direct Payment Upload File' ||
               DocType == 'Balance Adjustment Upload File'){
            	SuccessDocStorage.Document_Name__c = 'Product Payment Success.xls';
                SuccessDocStorage.Document_Type__C = 'Payment Processing File';
            }else if(DocType == 'Customer Contact Information Update File'){
                SuccessDocStorage.Document_Name__c = 'Customer Contact Information Success.xls';
                SuccessDocStorage.Document_Type__C = 'Payment Processing File';
            }else if(DocType == 'Account Status (having Judgment) Update File'){
                SuccessDocStorage.Document_Name__c = 'Account Judgment Success.xls';
                SuccessDocStorage.Document_Type__C = 'Account Judgment Processing File';
            }
            SuccessDocStorage.Document_Extension__c = 'xls';
            SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
            SuccessDocStorage.Visibility__c = visiblity;
            SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            SuccessDocStorage.File_Processing_Status__c = 'Processed';
            insert SuccessDocStorage;
        }
        
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;
        
        DateTime dT = System.now();
        String oldComments = '';
        system.debug('workAssignmentId%%%'+workAssignmentId);
        Work_Assignment__c workAssignment = [select id,name,title__c,Created_By__c,Status__c,Latest_Comment__c,Comments_History__c,Comment_Reply__c from Work_Assignment__c where id = : workAssignmentId];
        workAssignment.Status__c = 'Completed';
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
        if(workAssignment.Comments_History__c !=null){
            oldComments = workAssignment.Comments_History__c;
        }
        workAssignment.Latest_Comment__c = workAssignment.Comment_Reply__c;
        workAssignment.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
        
        if(oldComments != null){
            workAssignment.Comments_History__c += oldComments;
        }
        
        workAssignment.Comment_Reply__c = '';
        
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        update workAssignment;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger=true; 
    }
}