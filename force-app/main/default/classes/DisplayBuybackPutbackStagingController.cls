public class DisplayBuybackPutbackStagingController {
	Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public list<Product_Staging__c> listProductStaging {get;set;}
    public list<productStagingWrapper> listProductStagingWrapper {get;set;}
    public Map<String, Placement_Status_Code_Mapping__c> mapRecallCodeStatus;
    public List<Id> prodIdList = new List<Id>();
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    
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
    String productNames = '';
    
    //Constructor
    public DisplayBuybackPutbackStagingController(){
        showButton = false;
        displayPanel = false;
        system.debug('Block run1');
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listProductStaging = [SELECT ID, Name__c, Comment__c, Placement_Agency__c, Status__c, Expected_Value__c,Document_Storage__c,
                              Document_Storage__r.File_Processing_Status__c, Product_ID__c, Identifier__c,Putback_Buyback_Amount__c,
                              Document_Storage__r.Work_Assignment_Identifier__c, Document_Storage__r.Work_Assignment__c
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
                Boolean disabled = false;
                if(productStaging.Comment__c.contains(ERROR) || (productStaging.Status__c == PROCESSED && productStaging.Comment__c == 'SUCCESS')){
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
        success = 'data_id,buyback_putback_amount';
        failed = 'data_id,buyback_putback_amount,error';
        
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
        
        successRecords = 0;
        failedRecords = 0;
        system.debug('listProductStagingWrapper test::'+listProductStagingWrapper);
        for(productStagingWrapper productStagingWrap : listProductStagingWrapper){
            system.debug('executeWarning:: '+executeWarning);
            system.debug('productStagingWrap.productStaging test::'+productStagingWrap.productStaging);
            Product_Staging__c productStaging = productStagingWrap.productStaging;
            system.debug('productStaging test::'+productStaging);
            String comment = '';
            if(String.isNotBlank(productStaging.Comment__c)){
                comment = productStaging.Comment__c;
            }
            system.debug('comment:: '+comment);
            
            //If No error found, update product record from staging
            if(productStaging.Status__c != PROCESSED
            && productStagingWrap.selected == true){
                system.debug('productStaging procesing: '+productStaging);
                system.debug('productStaging.Name: '+productStaging.Name__c);
                
                productStaging.Status__c = PROCESSED;
                Product__c product = new Product__c();
                product.Name = productStaging.Name__c;
                product.ID = productStaging.Product_ID__c;
				product.Putback_Buyback_Amount__c = productStaging.Putback_Buyback_Amount__c;
            	
                //set placement status for new recall
                listProductToUpdate.add(product);
				productNames += product.Name + ',';
                
                
                
                success += '\n';
                            success += productStaging.Name__c+','+productStaging.Putback_Buyback_Amount__c;
                                          
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
                                   +','+productStaging.Putback_Buyback_Amount__c
                                   +','+(productStaging.Comment__c!= null ? CommentError : NULL);
                //FailedHasRecord = true;
                failedRecords = failedRecords + 1;
            }
        }
        
        system.debug('listProductToUpdate: '+listProductToUpdate);
        //update product
        ProductTriggerHandler.runProductTrigger = false;
        
        
        update listProductToUpdate;
        for(Product__c prodUpdateList : listProductToUpdate){
            prodIdList.add(prodUpdateList.Id);
        }
        productNames.removeEnd(',');
       
  		ProductTriggerHandler.runProductTrigger = true;      
        list<Work_Assignment__c> listWorkAssignmentToUpsert = new list<Work_Assignment__c>();
        //Create Task record and assign it to Agency
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.ID = listProductStaging[0].Document_Storage__r.Work_Assignment__c;
        workAssignmentId = workAssignment.ID;
        /*workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Buyback/Putback Status ' + '[' + listProductStaging[0].Document_Storage__r.Work_Assignment_Identifier__c + ']';
        workAssignment.Description__c = 'Product Buyback/Putback Status';
        workAssignment.Status__c = 'Requested';
        workAssignment.Assign_To__c = 'Agency';
        //workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Excel File Processing';
        workAssignment.Sub_Purpose__c = 'Product Buyback/Putback File';
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
        //bug:4743 : changes ends           
        update workAssignment;
        system.debug('workAssignment: '+workAssignment);
        //workAssignmentId = workAssignment.Id;
        //WorkAssignmenttriggerHandler.runWorkAssignmentTrigger = false;
        system.debug('listProductStaging[0] test: '+listProductStaging[0]);
        system.debug('listProductStaging[0]Document_Storage__r test: '+listProductStaging[0].Document_Storage__r.Work_Assignment__c);
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
            if(!Test.isRunningTest()) {
        		parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Product Buyback/Putback Failed.csv', 'Task');
                rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response);
            }else{
                parsedResponse.DocUrl = 'Test';
                parsedResponse.docId = 'Test';
            }
            system.debug('parsedResponse in controller: '+parsedResponse);
        }
        
        //Success CSV API Call
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+success);
        Blob fileBlobSuccess = Blob.valueOf(success);
        if(successRecords > 0){
            if(!Test.isRunningTest()) {
        		parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Product Buyback/Putback Success.csv', 'Task');
                rawObj1 = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse1.response);   
             }else{
                parsedResponse.DocUrl = 'Test';
                parsedResponse.docId = 'Test';
            }   
            system.debug('parsedResponse in controller: '+parsedResponse1);
        }
        
        
        //Create Failed CSV Document Storage
        Document_Storage__c  failedDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse ){
            
            system.debug('task creation');
            failedDocStorage.Work_Assignment__c = workAssignmentID;    
            failedDocStorage.Document_Name__c = 'Product Buyback/Putback Failed.csv';
            failedDocStorage.Document_Extension__c = 'csv';
            //failedDocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            failedDocStorage.Document_ID__c = parsedResponse.docId;
            failedDocStorage.Document_Type__C = 'Product Buyback/Putback Processing File';
            failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            //failedDocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            failedDocStorage.Document_URL__c = parsedResponse.DocUrl;
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            failedDocStorage.File_Processing_Status__c = 'Processed';
            insert failedDocStorage;
            system.debug('failedDocStorage: '+failedDocStorage);          
        }
        
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1){
            system.debug('task creation');
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;                        
            SuccessDocStorage.Document_Name__c = 'Product Buyback/Putback Success.csv';
            SuccessDocStorage.Document_Extension__c = 'csv';
            //SuccessDocStorage.Document_ID__c = String.valueOf(rawObj1.get('docId'));
            SuccessDocStorage.Document_ID__c = parsedResponse1.docId;
            SuccessDocStorage.Document_Type__C = 'Product Buyback/Putback File';
            SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            //SuccessDocStorage.Document_URL__c = String.valueOf(rawObj1.get('docUrl'));
            SuccessDocStorage.Document_URL__c = parsedResponse1.DocUrl;
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            SuccessDocStorage.File_Processing_Status__c = 'Processed';
            insert SuccessDocStorage;
            system.debug('SuccessDocStorage: '+SuccessDocStorage);
        }
        
        //update Staging records        
        ProductTriggerHandler.runProductAPI = false;
        update listProductStaging;
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