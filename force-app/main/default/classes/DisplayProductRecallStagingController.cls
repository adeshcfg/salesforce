/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Product  records from Staging and create success
*                  and failure files for product allocation
*  @author : A5E Consulting
*  @date : 25/02/2022

*************************************************************************************************/
public class DisplayProductRecallStagingController {
    public static final String RECALLED_PLACEMENT_STATUS_CODE = '900000';
    public static final String PENDING_ALLOCATION_RECALLED_CODE = '110000';
    public static final String RECALL_CLIENT_REQUEST_PLACEMENT_STATUS = 'Recall - Client Request';
    public static final String READY = 'Ready';
    public static final String PENDING_ALLOCATION_RECALLED = 'Pending Allocation (1); Recalled';
    
    public static final String PROCESSED = 'PROCESSED';
    public static final String SUCCESS_STR = 'SUCCESS';
    public static final String ERROR = 'ERROR';
    
    public list<Product_Staging__c> listProductStaging {get;set;}
    public list<productStagingWrapper> listProductStagingWrapper {get;set;}
    set<ID> setProductID = new set<ID>();
    
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    
    public boolean showButton {get;set;}
    public boolean displayPanel {get;set;}
    public boolean executeWarning {get;set;}
    public Id workAssignmentId {get;set;}
    public Decimal successRecords;
    public Decimal failedRecords;
    
    String placementAgency = '';
    public String success;
    public String failed;
    String productNames = '';
   	Id documentID;
    
    //Constructor
    public DisplayProductRecallStagingController(){
        showButton = false;
        displayPanel = false;
        system.debug('Block run1');
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listProductStaging = [SELECT ID, Name__c, Comment__c, Placement_Agency__c, Status__c, Expected_Value__c,Document_Storage__c,
                              Document_Storage__r.File_Processing_Status__c, Product_ID__c, Identifier__c,Assignment_Date__c,
                              Document_Storage__r.Work_Assignment_Identifier__c, Document_Storage__r.Work_Assignment__c, Placement_Agency_ID__c
                                 FROM Product_Staging__c
                                WHERE Identifier__c = :recordIdentfier
                                //order by Comment__c DESC
                             ];
        if(listProductStaging.isEmpty()){
            //showButton = false;
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no records to display'));
        }
        else{
            listProductStagingWrapper = new list<productStagingWrapper>();
            for(Product_Staging__c productStaging : listProductStaging){
                setProductID.add(productStaging.Product_ID__c);
                Boolean disabled = false;
                if(productStaging.Comment__c.contains(ERROR) || (productStaging.Status__c == PROCESSED && productStaging.Comment__c == SUCCESS_STR)){
                    disabled = true;
                }
                listProductStagingWrapper.add(new productStagingWrapper(productStaging, disabled));
                if(productStaging.Status__c != PROCESSED && !productStaging.Comment__c.contains(ERROR)){
                    showButton = true;
                }
            }
            
            placementAgency = listProductStaging[0].Placement_Agency__c;
            documentID = listProductStaging[0].Document_Storage__c;
            system.debug('documentID: '+documentID);
            if(listProductStaging[0].Document_Storage__r.File_Processing_Status__c == 'Processed'){
                showButton = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
            }
            /*else{
                showButton = true;
            }*/
            
        }
    }
    
    public pageReference Save(){
        list<Product__c> listProductToUpdate = new list<Product__c>();
        list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
        //Create Success and Failure file headers
        success = 'data_id,place_id,assignment_date,place_status,success';
        failed = 'data_id,place_id,error';
        
        system.debug('debug 2');
        
        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        system.debug('executeWarning save: '+executeWarning);
        
        
        map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, Assignment_Date__c, Collection_Agency_Placement__c, Placement_Status__c,
                                                                   		  Current_Principal_Balance__c, Current_Interest_Amount__c,
                                                                   		  Interest_Rate__c, Current_Bal_NSF_Fees__c, Current_Bal_Attorney_Fees__c,
                                                                   		  Current_Bal_General_Fees__c, Current_Bal_Other_Fees__c,
                                                                   		  Current_Bal_Court_Fees__c, Collection_Agency_Placement__r.Commission_Rate__c
                                                                   		 FROM Product__c WHERE ID IN :setProductID]);
        
        successRecords = 0;
        failedRecords = 0;
        
        for(productStagingWrapper productStagingWrap : listProductStagingWrapper){
            system.debug('executeWarning:: '+executeWarning);
            Product_Staging__c productStaging = productStagingWrap.productStaging;
            String comment = '';
            if(String.isNotBlank(productStaging.Comment__c)){
                comment = productStaging.Comment__c;
            }
            system.debug('comment:: '+comment);
            
            //If No error found, update product record from staging
            if(productStaging.Status__c != PROCESSED
            && productStagingWrap.selected == true
            //&& !comment.contains('ERROR')
            //&& ((executeWarning == false && !comment.contains('WARNING') ) || executeWarning == true)
            ){
                system.debug('productStaging procesing: '+productStaging);
                system.debug('productStaging.CCS_Account__c: '+productStaging.Name__c);
                
                productStaging.Status__c = PROCESSED;
                Product__c product = new Product__c();
                product.Name = productStaging.Name__c;
                product.ID = productStaging.Product_ID__c;
                product.Product_Status__c = PENDING_ALLOCATION_RECALLED_CODE;
                product.Data_Status_Description__c = PENDING_ALLOCATION_RECALLED;
                product.Placement_Status__c = RECALLED_PLACEMENT_STATUS_CODE;
                product.Status_Changed_Date__c = Date.today();
				product.Status__c = RECALL_CLIENT_REQUEST_PLACEMENT_STATUS;
            	product.Sub_Status__c = null;
                product.Collection_Agency__c = null;
                product.Collection_Agency_Placement__c = null;
                product.Recalled_Date__c = Date.today();
                //set placement status for new recall
                listProductToUpdate.add(product);
				productNames += product.Name + ',';
                
                if(!mapProduct.keySet().isEmpty() && mapProduct.containsKey(productStaging.Product_ID__c)){
                	Product__c productToRefer = mapProduct.get(productStaging.Product_ID__c);
                    Placement_History__c placementHistory = new Placement_History__c();
                    placementHistory.Product__c = productStaging.Product_ID__c;
                    placementHistory.Placement__c =  productStaging.Placement_Agency_ID__c; 
                    placementHistory.Placement_Date__c = productStaging.Assignment_Date__c;
                    placementHistory.Placement_Recall_Date__c = Date.today();
                    placementHistory.Placement_Date__c = product.Assignment_Date__c;
                    placementHistory.Placement_Status__c = productToRefer.Placement_Status__c;
                    placementHistory.Placement_Status_Description__c = 'Recall (9); Client Request';
                    placementHistory.Current_Principal_Balance__c = productToRefer.Current_Principal_Balance__c;
                    placementHistory.Current_Interest_Balance__c = productToRefer.Current_Interest_Amount__c;
                    placementHistory.Interest_Rate__c = productToRefer.Interest_Rate__c;
                    placementHistory.NSF_Fees__c = productToRefer.Current_Bal_NSF_Fees__c;
                    placementHistory.Current_Bal_Attorney_Fees__c = productToRefer.Current_Bal_Attorney_Fees__c;
                    placementHistory.Current_Bal_General_Fees__c = productToRefer.Current_Bal_General_Fees__c;
                    placementHistory.Current_Bal_Other_Fees__c = productToRefer.Current_Bal_Other_Fees__c;
                    placementHistory.Current_Bal_Court_Fees__c = productToRefer.Current_Bal_Court_Fees__c;
                    placementHistory.Commission_Rate__c = productToRefer.Collection_Agency_Placement__r.Commission_Rate__c;
                    listPlacementHistory.add(placementHistory);
                }
                
                success += '\n';
                            success += productStaging.Name__c+','+productStaging.Placement_Agency__c+','
                                          + '"'+(product.Recalled_Date__c!= null ? product.Recalled_Date__c : NULL) 
                                          + '"'+','+(product.Placement_Status__c != null ? product.Placement_Status__c :NULL) 
                                		  + '"'+','+'SUCCESS' 
                                          ;
               //SuccessHasRecord = true;
               successRecords = successRecords + 1;
            }
            else{
                system.debug('');
                failed += '\n';
                String CommentError;
                if(productStaging.Comment__c!= null){
                    CommentError = productStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                    system.debug('CommentError test::' +CommentError);
                }
                            failed += productStaging.Name__c
                                   +','+productStaging.Placement_Agency__c
                                   + '"'+','+(productStaging.Comment__c!= null ? CommentError : NULL);
                //FailedHasRecord = true;
                failedRecords = failedRecords + 1;
            }
        }
        
        system.debug('listProductToUpdate: '+listProductToUpdate);
        //update product
        ProductTriggerHandler.runProductTrigger = false;
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
        update listProductToUpdate;
        insert listPlacementHistory;
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
        productNames.removeEnd(',');
        PortalProductStatusBulkAPI.processBulkProducts(productNames, RECALLED_PLACEMENT_STATUS_CODE, PENDING_ALLOCATION_RECALLED_CODE, 
                                                       String.valueOf(Date.today()), 
                                                       'Recall' , '', null); 
  		ProductTriggerHandler.runProductTrigger = true;      
        list<Work_Assignment__c> listWorkAssignmentToUpsert = new list<Work_Assignment__c>();
        //Create Task record and assign it to Agency
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.ID = listProductStaging[0].Document_Storage__r.Work_Assignment__c;
        workAssignmentId = workAssignment.ID;
        /*workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Recall Status ' + '[' + listProductStaging[0].Document_Storage__r.Work_Assignment_Identifier__c + ']';
        workAssignment.Description__c = 'Product Recall Status';
        workAssignment.Status__c = 'Requested';
        workAssignment.Assign_To__c = 'Agency';
        //workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Excel File Processing';
        workAssignment.Sub_Purpose__c = 'Product Recall File';
        workAssignment.Placement_Agency__c = placementID;
        workAssignment.Comment_Reply__c = '';
        workAssignment.RecordTypeID = portalSettings.AgencyExcelProcessingRecordTypeID__c;*/
        workAssignment.Comment_Reply__c = '';
        workAssignment.Status__c = 'Completed';
        if(failedRecords != NULL && failedRecords > 0){
            workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'';
        }
        if(successRecords!= NULL && successRecords > 0){
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
        }                
        //bug:4743 : changes starts
        DateTime dT = System.now();
        workAssignment.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' +' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
        WorkAssignmentTriggerHandler.updateCommentHistoryField=FALSE;
        //bug:4743 : changes ends          
        update workAssignment;
        WorkAssignmentTriggerHandler.updateCommentHistoryField=TRUE; //Added part of bug #4743
        system.debug('workAssignment: '+workAssignment);
        //workAssignmentId = workAssignment.Id;
        //WorkAssignmenttriggerHandler.runWorkAssignmentTrigger = false;
        update new Work_Assignment__c(Id = listProductStaging[0].Document_Storage__r.Work_Assignment__c, 
                                                              Status__c = 'Completed');
        //upsert listWorkAssignmentToUpsert;
        showButton = true;
        displayPanel = false;
        return null;
    }
    
    public PageReference postDocumentAPI(){
        Map<String,Object> rawObj;
        Map<String,Object> rawObj1;
        
        //Failed CSV API Call
        system.debug('failed: '+failed);
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+failed);
        Blob fileBlob = Blob.valueOf(failed);

        if(failedRecords > 0){
        	parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Recall Failed.csv', 'Task');
            system.debug('parsedResponse in controller: '+parsedResponse);
            rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response);    
        }
        
        //Success CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+success);
        Blob fileBlobSuccess = Blob.valueOf(success);
        if(successRecords > 0){
        	parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Recall Success.csv', 'Task');
            system.debug('parsedResponse in controller: '+parsedResponse1);
            rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response);    
        }
        
        
        //Create Failed CSV Document Storage
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse 
        && rawObj != NULL
        && String.isnotBlank(String.valueOf(rawObj.get('docId')))){
            
            system.debug('task creation');
            failedDocStorage.Work_Assignment__c = workAssignmentID;    
            failedDocStorage.Document_Name__c = 'Product Recall Failed.csv';
            failedDocStorage.Document_Extension__c = 'csv';
            failedDocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            failedDocStorage.Document_Type__C = 'Product Recall Processing File';
            //failedDocStorage.Content_Type__c = contentType;
            failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            failedDocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            system.debug('failedDocStorage.Document_Related_To__c: '+failedDocStorage.Document_Related_To__c);
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            failedDocStorage.File_Processing_Status__c = 'Processed';
            insert failedDocStorage;
            system.debug('failedDocStorage: '+failedDocStorage);
            //delete listProductStaging;
        }
        
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1 
        && rawObj1 != NULL
        && String.isnotBlank(String.valueOf(rawObj1.get('docId')))){
            
            system.debug('task creation');
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;                        
            SuccessDocStorage.Document_Name__c = 'Product Recall Success.csv';
            SuccessDocStorage.Document_Extension__c = 'csv';
            SuccessDocStorage.Document_ID__c = String.valueOf(rawObj1.get('docId'));
            SuccessDocStorage.Document_Type__C = 'Product Recall File';
            SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            SuccessDocStorage.Document_URL__c = String.valueOf(rawObj1.get('docUrl'));
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            system.debug('SuccessDocStorage.Document_Related_To__c: '+SuccessDocStorage.Document_Related_To__c);
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            SuccessDocStorage.File_Processing_Status__c = 'Processed';
            insert SuccessDocStorage;
            system.debug('SuccessDocStorage: '+SuccessDocStorage);
        }
        
        //update Staging records
        //ProductPaymentsTriggerHandler.runProductTrigger = false;
        ProductTriggerHandler.runProductAPI = false;
        update listProductStaging;
        ProductTriggerHandler.runProductAPI = true;
        //ProductPaymentsTriggerHandler.runProductTrigger = true;
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;

        //disable buttoms
        showButton = false;
        displayPanel = true;
        system.debug('showButton: '+showButton);
        system.debug('displayPanel: '+displayPanel);
        return null;
    } 
    
    public class productStagingWrapper{
        public Product_Staging__c productStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public productStagingWrapper(Product_Staging__c pay, Boolean disable ){
            productStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
}