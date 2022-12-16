/**************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product Recall Staging records and check Product recall validtaions
*  @author : A5E Consulting
*  @date : 27/05/2022
/**************************************************************************************************/
public class ProductBulkPoolExcelFileProcessing {

    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<productWrapper> listProductWrapper = new List<productWrapper>();
    
    public ProductBulkPoolExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId){
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
            List<String> poolNumberList = new List<String>();
            for(ProductWrapper wrapRecord : listProductWrapper){
                if(String.isNotBlank(wrapRecord.data_id)){
                    if(wrapRecord.data_id.contains('.') ){
                        wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                    wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                    accountNumberList.add(wrapRecord.data_id);
                }
                if(String.isNotBlank(wrapRecord.pool_name)){
                    if(wrapRecord.pool_name.contains('.') ){
                        wrapRecord.pool_name = wrapRecord.pool_name.substringBefore('.');
                    }
                    poolNumberList.add(wrapRecord.pool_name);
                        
               }
            }
            
            
            
            system.debug('poolNumberList '+poolNumberList);
            //map of account number to the Salesforce record ID
            Map<String, Product__c> mapProductName= new Map<String, Product__c>();
            set<ID> setProdutID = new set<ID>();
            set<String> setPlacementNames = new set<String>();
            Map<String ,Pool__C> mapPoolName =new Map<String,Pool__C>();
            //Map<ID ,Pool__C> mapPoolID =new Map<ID,Pool__C>();
            
            for(Pool__C pool : [SELECT ID, Name,Placement_Agency__c
                                       FROM Pool__C 
                                        where Name =: poolNumberList
                                      ]){
                       mapPoolName.put(pool.Name, pool);
                       //mapPoolID.put(pool.ID, pool);
                       //product.Pool_Name__c = mapPool.get(wrapRecord.pool_name).Id;
                    }
            
            for(Product__C accountRecord : [SELECT ID, Name, Collection_Agency__c,Collection_Sub_Status__c,State__c,
                                            Assignment_Date__c,Pool_Name__c, Customer__c,Pool_Name__r.Name   
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
                
                if(String.isNotBlank(wrapRecord.pool_name)){
                    if(wrapRecord.pool_name.contains('.') ){
                        wrapRecord.pool_name = wrapRecord.pool_name.substringBefore('.');
                    }
                    product.Pool_Name_Text__c = wrapRecord.pool_name;
                system.debug('wrapRecord.pool_name testing::' +wrapRecord.pool_name);
                      
               }
                
               system.debug('product testing::: '+product);
                //if(String.isNotBlank(product.Name) && product.Pool_Name_Text__c != NULL){
                    listProductsToInsert.add(product);    
                //}
            }
            
            system.debug('listProductsToInsert: '+listProductsToInsert);
            
            list<Product_Staging__c> listProductStaging = validationOnRecordUpdate(listProductsToInsert, mapProductName,
                                                              documentID,mapPoolName);
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
        message.subject = 'Product Bulk Pool Status';
        String processingLink = '';
        String processingStatus = '';
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Product Pool records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductBulkPoolStaging?id='+documentID;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductBulkPoolStaging?id='+documentID;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'Product Pool processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductBulkPoolStaging?id='+documentID;
            processingStatus = 'Staging Table Creation Failed';
            if(exceptionMessage.length() > 250){
                exceptionMessage = exceptionMessage.substring(0, 250);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
        }
        /*if(!Test.isRunningTest()){
            Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                      + results[0].errors[0].message);
            }    
        }*/

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
                                                ID documentID, Map<String ,Pool__C> mapPoolName
                                                ){
        Map<String ,Pool__c> mapPool =new Map<String,Pool__c>();                                            
        system.debug('listProducts test: '+listProducts);
        String poolAgency = '';
        String prodAgency = '';
        String poolName = '';
        for(Pool__c pool : [SELECT ID, Name,Placement_Agency__c
                                       FROM Pool__c 
                                      ]){
           mapPool.put(pool.Name, pool);
        }  
        system.debug('mapPool testing: '+mapPool);
        list<Product_Staging__c> listProdBulkUpload = new list<Product_Staging__c>();
        Product_Staging__c productStaging = new Product_Staging__c();
        
        for(Product__c product: listProducts){
            system.debug('product testing: '+product);
            system.debug('product pool testing: '+product.Pool_Name_Text__c);
            
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Collection_Agency__c != NULL){
                    prodAgency = String.valueOf(Math.floor(mapProductName.get(product.Name).Collection_Agency__c));    
            }
            if(mapPoolName.containsKey(product.Pool_Name_Text__c)){
                if(mapProductName.containsKey(product.Name)
                   && mapPool.get(product.Pool_Name_Text__c) != NULL
                   && mapPoolName.get(product.Pool_Name_Text__c).Placement_Agency__c != NULL){
                     poolAgency = String.valueOf(mapPoolName.get(product.Pool_Name_Text__c).Placement_Agency__c);  
                    
                }
            }
            String EXPECTED = '';
            String ERROR_MSG = '';
            
            if(!mapProductName.containsKey(product.Name) && String.isNotBlank(product.Name)){
                ERROR_MSG = '<b>ERROR</b> - Invalid Account Number.'+'<br/>';
            }
            if(String.isBlank(product.Name)){
                ERROR_MSG += '<b>ERROR</b> - No Account Number is assigned.<br/>';
            }
            if(String.isNotBlank(prodAgency) && String.isNotBlank(poolAgency)){
                if(poolAgency != '9999' && prodAgency != '9999'){
                    if(prodAgency != poolAgency){
                    ERROR_MSG += '<b>ERROR</b> - This account cannot be assigned to Pool.<br/>';
                    EXPECTED += 'Pool Agency = ' +poolAgency+'.<br/>Product Agency = ' +prodAgency+'.<br/>';
                    }
                }
            }
            if(string.isBlank(product.Pool_Name_Text__c)){
                ERROR_MSG += '<b>ERROR</b> - No pool is assigned.<br/>';
            }
            if(mapPool.get(product.Pool_Name_Text__c) == NULL && !string.isBlank(product.Pool_Name_Text__c)){
                ERROR_MSG += '<b>ERROR</b> - This Pool is not available in system.<br/>';
            }
            if(mapProductName.containsKey(product.Name) && mapProductName.get(product.Name).Pool_Name__c != NULL){
                ERROR_MSG += '<b>ERROR</b> - Product is already mapped with other pool.<br/>';
            }
            system.debug('poolAgency testing: '+poolAgency);
            productStaging = new Product_Staging__c();
            productStaging.Name__c = product.Name;
            productStaging.Comment__c = ERROR_MSG;
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentID;
            productStaging.Expected_Value__c = EXPECTED;
            productStaging.Document_Storage__c = productStaging.Identifier__c;
            productStaging.Pool_Name__c = String.valueOf(product.Pool_Name_Text__c);
            if(product.Pool_Name_Text__c != NULL && mapPool.get(product.Pool_Name_Text__c) != NULL){
                productStaging.Pool_Name_ID__c = mapPool.get(productStaging.Pool_Name__c).ID;
            }
            if(mapProductName.containsKey(productStaging.Name__c)){
                productStaging.Product_ID__c = mapProductName.get(productStaging.Name__c).ID;
                productStaging.Assignment_Date__c = mapProductName.get(productStaging.Name__c).Assignment_Date__c;
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
        public String pool_name{get;set;}

    }
}