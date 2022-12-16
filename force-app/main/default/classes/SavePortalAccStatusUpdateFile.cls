/**************************************************************************************************
*
*  Class:  SavePortalAccStatusUpdateFile
*
*  @description : deserialize JSON and send records to batch for insert into staging
*  @author : A5E Consulting
*  @date : 29/03/2023

*************************************************************************************************/
public class SavePortalAccStatusUpdateFile {
    
 public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<accountRecordsWrapper> listAccountRecordWrapper = new List<accountRecordsWrapper>();
    list<Document_Storage__c> listDocuments = new list<Document_Storage__c>();
    Document_storage__c docStorage;
    public static map<String, ID> mapProductJudgment = new map<String, ID>();
    
         public SavePortalAccStatusUpdateFile (String data, String workAssignmentPlacement, ID documentId,Document_storage__c docStorage) {
        exceptionMessage = '';
        listAccountRecordWrapper = deSerializeJSON(data);
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.documentId = documentId;
        this.docStorage = docStorage;
        processExcelFileRecords();
    }      
     public List<accountRecordsWrapper> deSerializeJSON(String dataAsString) {
        List<accountRecordsWrapper>  listAccountRecordWrapper = (List<accountRecordsWrapper>)JSON.deserialize(dataAsString, List<accountRecordsWrapper>.class);
        return listAccountRecordWrapper;
    }
    
    public void processExcelFileRecords() {
        listDocuments = [SELECT ID, Creator__c, Work_Assignment__c, Uploaded_By__c 
                         FROM Document_Storage__c 
                         WHERE ID= :documentID];

        try{
            List<Product__c> listProductsToInsert = new List<Product__c>();
            List<String> accountNumberList = new List<String>();
            for(AccountRecordsWrapper wrapRecord : listAccountRecordWrapper){
                wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                accountNumberList.add(wrapRecord.data_id);
            }
            list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :workAssignmentPlacement];
            Id placementID;
            if(!listPlacements.isEmpty()){
                placementID = listPlacements[0].ID;
            }
            
            //map of account number to the Salesforce record ID
            Map<String, ID> mapAccountNumberID = new Map<String, ID>();
            map<String,Product__C> mapProduct = new map<String,Product__C>();
            set<String> setPlacementNames = new set<String>();
            
            for(Product__C prodList : [select id, name, Current_Balance__c, Collection_Agency_Placement__c,
                                       Collection_Sub_Status__c, Collection_Agency__c,Status_Changed_Date_Text__c,
                                       Placement_Status__c, Sub_Status__c, Status__C,Data_Status_Description__c,
                                       Assignment_Date__c,Recalled_Date__c,Product_Status__c,Refer_to_Legal__c
                                       from Product__C 
                                            where name in :accountNumberList]){
                mapAccountNumberID.put(prodList.name, prodList.id);
                mapProduct.put(prodList.Name, prodList);
                setPlacementNames.add(String.valueOf(prodList.Collection_Agency__c));
            }
            system.debug('listAccountRecordWrapper to test: '+listAccountRecordWrapper);
            map<String,String> mapFilingDate = new map<String,String>();
            mapProductJudgment = new map<String, ID>();
            
            for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c, Product__r.Name FROM Account_Judgment__c
                                                  WHERE Product__r.name IN :mapProduct.keySet()
                                                  AND Status__c = 'Active']){
                mapProductJudgment.put(accJudgment.Product__r.Name, accJudgment.Judgment__c);
            }
            
            for(AccountRecordsWrapper wrapRecord : listAccountRecordWrapper){
                Product__c prod = new Product__c();
                prod.Name = wrapRecord.data_id;
                if(String.isNotBlank(wrapRecord.status_code)){
                    //prod.Product_Status__c    = wrapRecord.status_code.subStringBefore('.');
                    prod.Placement_Status__c = wrapRecord.status_code.subStringBefore('.').trim();
                }
                system.debug('wrapRecord.status_date: '+wrapRecord.status_date);
                if(String.isNotBlank(wrapRecord.status_date)){
                    wrapRecord.status_date = wrapRecord.status_date.trim();
                    if(wrapRecord.status_date.contains('-')){
                        wrapRecord.status_date= wrapRecord.status_date.replace('-','/');
                    }
                    if(wrapRecord.status_date.contains('T')){
                        wrapRecord.status_date = wrapRecord.status_date.SubstringBefore('T');
                    }
                    try{
                        prod.Status_Changed_Date_Text__c = wrapRecord.status_date; //String.valueOf(wrapRecord.status_date);
                       // prod.Status_Changed_Date__c = Date.valueof(wrapRecord.status_date);
                       System.debug('Block Run ' + prod.Status_Changed_Date_Text__c);
                    }
                    catch(exception e){
                        mapFilingDate.put(prod.Name, wrapRecord.status_date);
                    }    
                }
                system.debug('testing final prod' +prod);  
                listProductsToInsert.add(prod);
            }
            system.debug('listProductsToInsert: '+listProductsToInsert);
            /*list<Product_Staging__c> listpayStaging = validationOnRecordUpdate(listProductsToInsert, 
                                                                               mapProduct, documentId, 
                                                                               workAssignmentPlacement,mapFilingDate,
                                                                               listDocuments[0]
                                                                             );*/
            list<Product_Staging__c> listpayStaging = createStagingRecords(listProductsToInsert, 
                                                                               documentId, 
                                                                               placementID
                                                                             );
            
            system.debug('listpayStaging'+listpayStaging);
            
            //added by satyajit - Insert staging record batch
            Database.executeBatch(new savePortalAccStatusUpdateFileBatch(listpayStaging,docStorage),200);
            
            //system.enqueueJob(new savePortalAccStatusUpdateFileBatch(listpayStaging));
            
            //commented by satyajit
           //Database.SaveResult[] sr = database.insert(listpayStaging);
        }
        catch(Exception ex){
            system.debug('exceptionMessage::'+exceptionMessage);
            exceptionMessage = ex.getStackTraceString();
            system.debug('exception::'+ex.getStackTraceString());
        }

        system.debug('listDocuments:: '+listDocuments);
        //Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(!listDocuments.isEmpty() && listDocuments[0].Uploaded_By__c == 'External User' && String.isnotblank(listDocuments[0].Creator__c)){
            message.toAddresses = new String[] {listDocuments[0].Creator__c};  
        }
        else{
            message.setTargetObjectId(UserInfo.getUserId());    
        }
        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Product Status Update';
        String processingLink = '';
        Boolean stagingCreated = false;
        String processingStatus = '';
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Product records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/displayaccountstatusupdatestaging?id='+documentId;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/displayaccountstatusupdatestaging?id='+documentId; 
            stagingCreated  = true;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'Product Processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/displayaccountstatusupdatestaging?id='+documentId;
            processingStatus = 'Staging Table Creation Failed';
            if(exceptionMessage.length() > 250){
                exceptionMessage = exceptionMessage.substring(0, 250);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
        }
        
        
    }
    
      //Added by satyajit - Create list of staging record to insert
    public static list<Product_Staging__c> createStagingRecords(List<Product__c> listProduct,String documentId,Id placementId){
        
        list<Product_staging__c> listProdStaging = new list<Product_staging__c>();
        
        for(Product__c product : listProduct){
             Product_staging__c prodStaging = new Product_staging__c();
            prodStaging.Name__c = product.name;
            prodStaging.Placement_Status_Code__c = product.Placement_Status__c;
            prodStaging.Status_Changed_Date__c = product.Status_Changed_Date_Text__c;
            prodStaging.Data_Id__c = product.name;
            prodStaging.Identifier__c = documentId;
            prodStaging.Placement_Agency__c = placementId;    
            listProdStaging.add(prodStaging);
        }
        //Insert listProdStaging;
       return listProdStaging;
    }
    
    //Wrapper class for insolvency payment records
    public class accountRecordsWrapper{
        public String accountID{get;set;}
        public String accountNumber{get;set;}
        public String data_id{get;set;}
        public String status_code{get;set;}
        public String status_date{get;set;}
    }
}