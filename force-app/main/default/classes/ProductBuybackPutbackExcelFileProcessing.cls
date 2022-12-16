/*******************************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product BuybackPutback Staging records and check Product BuybackPutback validtaions
*  @author : A5E Consulting
*  @date : 29/07/2022
/******************************************************************************************************************/
public class ProductBuybackPutbackExcelFileProcessing {

    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<productWrapper> listProductWrapper = new List<productWrapper>();
    
    public ProductBuybackPutbackExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId){
        system.debug('class called');
        exceptionMessage = '';
        listProductWrapper = deSerializeJSON(data); 
        if(String.isNotBlank(workAssignmentPlacement)){
            this.workAssignmentPlacement = workAssignmentPlacement;    
        }
        this.documentId = documentId;
        processExcelFileRecords();
    }
    
    public List<productWrapper> deSerializeJSON(String dataAsString){
        List<productWrapper>  listProductWrapper = (List<productWrapper>)JSON.deserialize(dataAsString, List<productWrapper>.class);
        return listProductWrapper;
    }
    
    public void processExcelFileRecords(){
        try{
            system.debug('listProductWrapper: '+listProductWrapper);
            List<Product__c> listProductsToInsert = new List<Product__c>();
    
            List<String> accountNumberList = new List<String>();
            
            for(ProductWrapper wrapRecord : listProductWrapper){
                if(String.isNotBlank(wrapRecord.data_id)){
                    if(wrapRecord.data_id.contains('.') ){
                        wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                    wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                    accountNumberList.add(wrapRecord.data_id);
                }

            }
            
            
            
          
            //map of account number to the Salesforce record ID
            Map<String, Product__c> mapProductName= new Map<String, Product__c>();
            set<ID> setProdutID = new set<ID>();
            set<String> setPlacementNames = new set<String>();
           
          
            
           
            
            for(Product__C accountRecord : [SELECT ID, Name, Collection_Agency__c,Purchase_Status__c,State__c,
                                            Buyback_Putback_Status_Change_Date__c,Putback_Buyback_Amount__c  
                                            FROM Product__C 
                                            WHERE name in :accountNumberList] ){
                mapProductName.put(accountRecord.name, accountRecord);
            }
            
            for(ProductWrapper wrapRecord : listProductWrapper){
                Product__c product = new Product__c();
                system.debug('wrapRecord.data_id testing::: '+wrapRecord.data_id);
                if(String.isNotBlank(wrapRecord.data_id)){
                    if(wrapRecord.data_id.contains('.') ){
                    wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                    product.Name = wrapRecord.data_id;    
                }
                system.debug('product.Name testing::' +product.Name);
                if(String.isNotBlank(wrapRecord.buyback_putback_amount)){
                    wrapRecord.buyback_putback_amount = wrapRecord.buyback_putback_amount.trim();
                    
                    if(wrapRecord.buyback_putback_amount.contains('.') ){
                        wrapRecord.buyback_putback_amount = wrapRecord.buyback_putback_amount.remove('.');
                    }
                    /*if(wrapRecord.buyback_putback_amount.contains('.')
                    && (wrapRecord.buyback_putback_amount.substringAfter('.') == '0'
                    || wrapRecord.buyback_putback_amount.substringAfter('.') == '00')){
                        wrapRecord.buyback_putback_amount = wrapRecord.buyback_putback_amount.subStringBefore('.');    
                    }*/
                    system.debug('wrapRecord.buyback_putback_amount:: '+wrapRecord.buyback_putback_amount);
                    product.Putback_Buyback_Amount__c = Decimal.valueOf(wrapRecord.buyback_putback_amount);
                }
                
                
               system.debug('product testing::: '+product);
                //if(String.isNotBlank(product.Name) && product.Pool_Name_Text__c != NULL){
                    listProductsToInsert.add(product);    
                //}
            }
            
            system.debug('listProductsToInsert: '+listProductsToInsert);
            
            list<Product_Staging__c> listProductStaging = validationOnRecordUpdate(listProductsToInsert, mapProductName,
                                                              documentID);
            Database.SaveResult[] sr = database.insert(listProductStaging);    
        }
        catch(Exception ex){
            system.debug('exceptionMessage::'+exceptionMessage);
            exceptionMessage = String.valueOf(ex.getStackTraceString());
        }
        
        list<Document_Storage__c> listDocuments = [Select ID, Creator__c, Work_Assignment__c, Uploaded_By__c 
                                                        FROM Document_Storage__c 
                                                        WHERE ID= :documentID];
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
        message.subject = 'Product Buyback/Putback Status';
        String processingLink = '';
        String processingStatus = '';
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Product Pool records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductBulkPoolStaging?id='+documentID;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayBuybackPutbackStaging?id='+documentID;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'Product Pool processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayBuybackPutbackStaging?id='+documentID;
            processingStatus = 'Staging Table Creation Failed';
            if(exceptionMessage.length() > 250){
                exceptionMessage = exceptionMessage.substring(0, 250);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
        }
        
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(ID = listDocuments[0].ID,
                                                          File_Processing_Link__c = processingLink,
                                                          File_Processing_Date__c = Date.today(),
                                                          File_processing_Error__c = exceptionMessage,
                                                          File_Processing_Status__c = processingStatus
                                                         );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
    
    
    //Validation method to be called  before update
    public static list<Product_Staging__c> validationOnRecordUpdate(List<Product__c> listProducts, map<String, Product__c> mapProductName,
                                                ID documentID
                                                ){
        system.debug('listProducts test: '+listProducts);
        String prodAgency = '';
        list<Product_Staging__c> listProdBulkUpload = new list<Product_Staging__c>();
        Product_Staging__c productStaging = new Product_Staging__c();
        
        for(Product__c product: listProducts){
            system.debug('product testing: '+product);
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Collection_Agency__c != NULL){
               prodAgency = String.valueOf(Math.floor(mapProductName.get(product.Name).Collection_Agency__c));    
            }
            system.debug('prodAgency**'+prodAgency);
            String EXPECTED = '';
            String ERROR_MSG = '';
            
            if(!mapProductName.containsKey(product.Name) && String.isNotBlank(product.Name)){
                ERROR_MSG = '<b>ERROR</b> - Invalid Account Number.'+'<br/>';
            }
            if(String.isBlank(product.Name)){
                ERROR_MSG += '<b>ERROR</b> - No Account Number is assigned.<br/>';
            }
            if(String.isNotBlank(prodAgency)){
                if(prodAgency != '9999'){
                    ERROR_MSG += '<b>ERROR</b> - Please initiate recall process.<br/>';
                    EXPECTED += 'Product should not mapped to any agency.<br/>';
                }
            }
            if(product.Putback_Buyback_Amount__c == NULL){
                ERROR_MSG += '<b>ERROR</b> - No Amount is assigned.<br/>';
            }
            system.debug('product testing: '+product);
            system.debug('product testing: '+product.Putback_Buyback_Amount__c);
            productStaging = new Product_Staging__c();
            productStaging.Name__c = product.Name;
            productStaging.Comment__c = ERROR_MSG;
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentID;
            productStaging.Expected_Value__c = EXPECTED;
            productStaging.Document_Storage__c = productStaging.Identifier__c;
            if(mapProductName.containsKey(product.Name)){
                if(product.Putback_Buyback_Amount__c != NULL){
            		productStaging.Putback_Buyback_Amount__c = product.Putback_Buyback_Amount__c ;       
                }
            }
            if(mapProductName.containsKey(product.Name)){
                productStaging.Product_ID__c = mapProductName.get(product.Name).ID;
            }
            if(String.isBlank(ERROR_MSG)){
                productStaging.Comment__c = 'SUCCESS';
            }
            listProdBulkUpload.add(productStaging);
            ERROR_MSG = '';
        }
        system.debug('listProdBulkUpload: '+listProdBulkUpload);
        return listProdBulkUpload;
    }
    
    //Wrapper class for insolvency payment records
    public class productWrapper{
        public String data_id{get;set;}
        public String buyback_putback_amount{get;set;}

    }
}