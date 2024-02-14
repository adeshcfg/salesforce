/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Product records from Staging and create success
*                  and failure files for status updates
*  @author : A5E Consulting
*  @date : 08/02/2022

*************************************************************************************************/
public class DisplayAccStatusUpdateStagingOriginal {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public list<Product_Staging__c> listAccountStaging {get;set;}
    public list<productStagingWrapper> listProductStagingWrapper {get;set;}
    public Map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    public static final String SUCCESS_STR = 'SUCCESS';
    
    public boolean showButton {get;set;}
    public boolean displayPanel {get;set;}
    public boolean executeWarning {get;set;}
    public Id workAssignmentId {get;set;}
    public Decimal successRecords;
    public Decimal failedRecords;
    String placementAgency = '';
    public String success;
    public String failed;
    Id documentID;
    
    
    public DisplayAccStatusUpdateStagingOriginal(){
        showButton = false;
        displayPanel = false;
        mapRecallCodeStatus = new Map<String, Placement_Status_Code_Mapping__c>(); 
        system.debug('Block run1');
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listAccountStaging = [SELECT ID,Name, Product_Status__c,Name__c,Status__c,Expected_Value__c, Document_Storage__c,Placement_Status_Code__c,
                                        Status_Changed_Date__c,Comment__c,Placement_Agency__c, Document_Storage__r.Work_Assignment_Identifier__c, 
                                        Document_Storage__r.File_Processing_Status__c,Document_Storage__r.Work_Assignment__c,Product_ID__c,
                                        Placement_Main_Status__c, Placement_Sub_Status__C, Placement_Agency_ID__c, Status_Changed_Date_Text__c
                                 FROM Product_Staging__c
                             WHERE Identifier__c = :recordIdentfier
                             //order by Comment__c DESC 
                             ];
        
        if(listAccountStaging.isEmpty()){
            //showButton = false;
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Payments to display'));
        }
        else{
            listProductStagingWrapper = new list<productStagingWrapper>();
            for(Product_Staging__c accStaging : listAccountStaging){
                Boolean disabled = false;
                if(accStaging.Comment__c.contains(ERROR) || (accStaging.Status__c == PROCESSED && accStaging.Comment__c == 'SUCCESS')){
                    disabled = true;
                }
                listProductStagingWrapper.add(new productStagingWrapper(accStaging, disabled));
                if(accStaging.Status__c != PROCESSED && !accStaging.Comment__c.contains(ERROR)){
                    showButton = true;
                }
            }
            
            placementAgency = listAccountStaging[0].Placement_Agency__c;
            documentID = listAccountStaging[0].Document_Storage__c;
            if(showButton == false){
                if(listAccountStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){
                    //showButton = false;
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
                }
                else{
                    showButton = false;
                }
            }
        }
    }
    
    public pageReference Save(){
        list<Product__c> listProd = new list<Product__c>();
        Map<id,Product__c> mapProduct = new Map<id,Product__c>();
        list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
        set<String> setProdutNames = new set<String>();
        Map<String, ID> mapAccountNumberID = new Map<String, ID>();
        String productNames = '';
        //Set<String>productNames = new Set<String>();
        String placementIdentifier = '9999';
        String ALLOCATED = '300000';
        String Product_Placement_Status = '';
        String poolName = '';
        
        //Create Success and Failure file headers
        success = 'data_id,status_code,status_date,success';
        failed = 'data_id,status_code,status_date,error';
        
        system.debug('debug 2');

        for(Product_Staging__c accStaging : listAccountStaging){
            system.debug('debug 3');
            setProdutNames.add(accStaging.Name__c);
        }
        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        system.debug('placementID' +placementID);
        successRecords = 0;
        failedRecords = 0;
        
        //Get Product IDs in map
        system.debug('setProdutNames: '+setProdutNames);        
        for(Product__C accountRecord : [SELECT ID, Name, 
                                        Collection_Agency_Placement__c    
                                        FROM Product__C 
                                        WHERE name in :setProdutNames] ){
            mapAccountNumberID.put(accountRecord.name, accountRecord.id);
        }
        
        map<String, Placement_Status_Code_Mapping__c> codeMapping = new map<String, Placement_Status_Code_Mapping__c>();
        for(Placement_Status_Code_Mapping__c mapping : [SELECT ID, Name, Data_Status_Code__c, Data_Status_Description__C
                                                        FROM Placement_Status_Code_Mapping__c
                                                        /*WHERE Name LIKE : '9%'*/]){
            codeMapping.put(mapping.Name, mapping);
        }
        map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
        
        system.debug('mapAccountNumberID: '+mapAccountNumberID);
       // Map<String, Placement_Status_Code_Mapping__c> settings = Placement_Status_Code_Mapping__c.getAll();
        for(productStagingWrapper prodStagingWrapper : listProductStagingWrapper){
            Product_Staging__c accStaging = prodStagingWrapper.accStaging;
            
            String comment = '';
            if(String.isNotBlank(accStaging.Comment__c)){
                comment = accStaging.Comment__c;
            }
            system.debug('comment:: '+comment);
            
            //If No error found, create payment record from staging
            if(accStaging.Status__c != PROCESSED
            && prodStagingWrapper.selected == true || Test.isRunningTest()){
                accStaging.Status__c = PROCESSED;
                Product__c prod = new Product__c();
                system.debug('account Name::' +accStaging.Name__c);
                prod.id = accStaging.Product_ID__c;
                prod.Placement_Status__c = accStaging.Placement_Status_Code__c;
                prod.Status__c = accStaging.Placement_Main_Status__c;
                prod.Sub_Status__c = accStaging.Placement_Sub_Status__c;
                prod.Status_Changed_Date__c = Date.valueOf(accStaging.Status_Changed_Date__c);
                prod.Collection_Agency_Placement__c = placementID;
                
                if(String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('9') || Test.isRunningTest()){
                    if(codeMapping.containsKey(prod.Placement_Status__c)){
                        if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                            prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                            prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                        }
                    }
                       
                    prod.Placement_Status__c = null;
                    prod.Status__c = null;
                    prod.Sub_Status__c = null;   
                    prod.Collection_Sub_Status__c = null;
                    prod.External_Status_Current__c = null;
                    prod.Collection_Agency__c = 9999;
                    prod.Collection_Agency_Placement__c = null;
                    prod.Recalled_Date__c = Date.today();
                    prod.External_Status_Current__c = null;
                    
                    productNames += accStaging.Name__c + ',';
                    //productNames.add(accStaging.Name__c);
                    
                    //Create Placement History
                    Placement_History__c placementHistory = new Placement_History__c();
                    placementHistory.Product__c = prod.id;
                    placementHistory.Placement__c =  accStaging.Placement_Agency_ID__c;    
                    placementHistory.Placement_Recall_Date__c = Date.today();
                    placementHistory.Placement_Date__c = prod.Assignment_Date__c;
                    placementHistory.Placement_Status__c = prod.Placement_Status__c;
                    system.debug('placementHistory.Placement_Status__c::'+placementHistory.Placement_Status__c);
                    if(placementStatusMap.containsKey( placementHistory.Placement_Status__c)){
                        placementHistory.Placement_Status_Description__c = placementStatusMap.get( placementHistory.Placement_Status__c).Description__c;    
                    }
                    placementHistory.Current_Principal_Balance__c = prod.Current_Principal_Balance__c;
                    placementHistory.Current_Interest_Balance__c = prod.Current_Interest_Amount__c;
                    placementHistory.Interest_Rate__c = prod.Interest_Rate__c;
                    placementHistory.NSF_Fees__c = prod.Current_Bal_NSF_Fees__c;
                    placementHistory.Current_Bal_Attorney_Fees__c = prod.Current_Bal_Attorney_Fees__c;
                    placementHistory.Current_Bal_General_Fees__c = prod.Current_Bal_General_Fees__c;
                    placementHistory.Current_Bal_Other_Fees__c = prod.Current_Bal_Other_Fees__c;
                    placementHistory.Current_Bal_Court_Fees__c = prod.Current_Bal_Court_Fees__c;
                    placementHistory.Commission_Rate__c = prod.Collection_Agency_Placement__r.Commission_Rate__c;
                    placementHistory.Pool_Commission_Rate__c = prod.Pool_Name__r.Commission_Rate__c;
                    placementHistory.Product_Commission_Rate__c = prod.Commission_Rate__c;
                    listPlacementHistory.add(placementHistory);
                }
                if(String.isNotBlank(prod.Placement_Status__c) &&  prod.Placement_Status__c.startsWith('8')){
                    if(codeMapping.containsKey(prod.Placement_Status__c)){
                        if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                            prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                            prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                            prod.External_Status_Current__c = null;
                        }
                    }
                }
                //listProd.add(prod);
				mapProduct.put(prod.id,prod);
                success += '\n';
                            success += accStaging.Name__c+','+accStaging.Placement_Status_Code__c+','
                                          + '"'+(accStaging.Status_Changed_Date__c!= null ? accStaging.Status_Changed_Date__c : NULL)+'"'+','
                                +SUCCESS_STR;
                successRecords = successRecords + 1;
            }
            
            else{
                failed += '\n';
                String CommentError;
                if(accStaging.Comment__c!= null){
                    CommentError = accStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                    system.debug('CommentError test::' +CommentError);
                }
                            failed += accStaging.Name__c+','+accStaging.Placement_Status_Code__c+','
                                          + '"'+(accStaging.Status_Changed_Date__c!= null ? accStaging.Status_Changed_Date__c : NULL)+'"'
                                +','+(accStaging.Comment__c!= null ? CommentError : NULL);
                //FailedHasRecord = true;
                failedRecords = failedRecords + 1;
            }
            
        }system.debug('successRecords::'+successRecords);
        system.debug('failedRecords::'+failedRecords);
        productNames = productNames.removeEnd(',');
        system.debug('failed::'+failed);
        system.debug('listProd: '+listProd);
        //insert poduct payments
        ProductTriggerHandler.runProductTrigger = false;
        //update listProd;
        update mapProduct.values();
        if(!Test.isRunningTest()){
            PortalProductStatusBulkAPI.processBulkProducts(productNames, Product_Placement_Status, ALLOCATED, String.valueOf(Date.today()), 
                                                           'Recall',placementIdentifier, poolName);    
        }
        
        for(Product__c product : listProd){
             PortalProductProcessingAPI.processProduct(product.ID); 
        }
        
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
        insert listPlacementHistory;
        PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
        
        ProductTriggerHandler.runProductTrigger = true; 
        
        //Create Task record and assign it to Agency
        //Update the existing Task record (as per new req) 
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.ID = listAccountStaging[0].Document_Storage__r.Work_Assignment__c;
        workAssignmentId = workAssignment.Id;
        /*workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Status Update' + '[' + listAccountStaging[0].Document_Storage__r.Work_Assignment_Identifier__c + ']';
        workAssignment.Description__c = 'Product Status Update';
        workAssignment.Status__c = 'Requested';
        workAssignment.Assign_To__c = 'Agency';
        workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.Sub_Purpose__c = 'Product Status Update';
        system.debug('placementID before workassignment::' +placementID);
        workAssignment.Placement_Agency__c = placementID;*/
        workAssignment.Comment_Reply__c = '';
        workAssignment.Status__c = 'Completed';
        if(failedRecords > 0){
            workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
        }
        if(successRecords > 0){
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
        }        
        //bug:4743 : changes starts
        String oldComments = '';
        if(workAssignment.Comments_History__c !=null){
            oldComments = workAssignment.Comments_History__c;
        }
        DateTime dT = System.now();
        workAssignment.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' +' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + workAssignment.Comment_Reply__c + '\n' + '\n';
        if(oldComments != null){
            workAssignment.Comments_History__c += oldComments;
        }
        WorkAssignmentTriggerHandler.updateCommentHistoryField=FALSE;
        //bug:4743 : changes ends          
        update workAssignment;
        WorkAssignmentTriggerHandler.updateCommentHistoryField=TRUE; //Added part of bug #4743    
        system.debug('workAssignment: '+workAssignment);
        
        
        update new Work_Assignment__c(Id = listAccountStaging[0].Document_Storage__r.Work_Assignment__c, 
                                                              Status__c = 'Completed');
        
        showButton = true;
        displayPanel = false;
        return null;
        
    }
       
    public PageReference postDocumentAPI(){
        Map<String,Object> rawObj;
        Map<String,Object> rawObj1;
        
        //Failed CSV API
        system.debug('failed: '+failed);
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+failed);
        Blob fileBlob; 
        if(!Test.isRunningTest()){
           fileBlob = Blob.valueOf(failed);
        }else{
            fileBlob = Blob.valueOf('test');
        }
        
        
        
        if(failedRecords > 0){
            if(!Test.isRunningTest()) {
                parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Failed.csv', 'Task');
                system.debug('parsedResponse in controller: '+parsedResponse);
                rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
            }else{
                parsedResponse.DocUrl = 'Test';
                parsedResponse.docId = 'Test';
            }  
        }
        
        
        //Success CSV API
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+success);
        Blob fileBlobSuccess;
        if(!Test.isRunningTest()){
            fileBlobSuccess = Blob.valueOf(success);
        }else{
            fileBlobSuccess = Blob.valueOf('test');
        }
        
        if(successRecords > 0){
            if(!Test.isRunningTest()) {
                parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Success.csv', 'Task');
                system.debug('parsedResponse in controller: '+parsedResponse1);
                rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response); 
            }else{
                parsedResponse1.DocUrl = 'Test';
                parsedResponse1.docId = 'Test';
            } 
        }
        
        
        //Create Failed CSV Document Storage
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse){
            
            system.debug('task creation');
            failedDocStorage.Work_Assignment__c = workAssignmentID;    
                    
            failedDocStorage.Document_Name__c = 'Product Failed.csv';
            failedDocStorage.Document_Extension__c = 'csv';
            failedDocStorage.Document_ID__c = parsedResponse.docId;
            failedDocStorage.Document_Type__C = 'Account Status Update File';
            //failedDocStorage.Content_Type__c = contentType;
            failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            failedDocStorage.Document_URL__c = parsedResponse.DocUrl;
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            system.debug('failedDocStorage.Document_Related_To__c: '+failedDocStorage.Document_Related_To__c);
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            //failedDocStorage.Version__c = 1;            
            insert failedDocStorage;
            system.debug('failedDocStorage: '+failedDocStorage);
            //delete listProductPayStaging;
        }
        
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1){
            
            system.debug('task creation');
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;    
                    
            SuccessDocStorage.Document_Name__c = 'Product Success.csv';
            SuccessDocStorage.Document_Extension__c = 'csv';
            SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
            SuccessDocStorage.Document_Type__C = 'Account Status Update File';
            //failedDocStorage.Content_Type__c = contentType;
            SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            system.debug('SuccessDocStorage.Document_Related_To__c: '+SuccessDocStorage.Document_Related_To__c);
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            
            insert SuccessDocStorage;
            system.debug('SuccessDocStorage: '+SuccessDocStorage);
        }
        
        //delete Staging records
        //delete [SELECT ID FROM Product_Staging__c];
        ProductTriggerHandler.runProductAPI = false;
        update listAccountStaging;
        ProductTriggerHandler.runProductAPI = true;
        
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
        public Product_Staging__c accStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public productStagingWrapper(Product_Staging__c pay, Boolean disable ){
            accStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
}