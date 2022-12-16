/**************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product Recall Staging records and check Product recall validtaions
*  @author : A5E Consulting
*  @date : 09/03/2022
/**************************************************************************************************/

public class ProductRecallExcelFileProcessing {
    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<productWrapper> listProductWrapper = new List<productWrapper>();
    
    public ProductRecallExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId){
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
            
            for(Product__C accountRecord : [SELECT ID, Name, Collection_Agency__c,Collection_Sub_Status__c,State__c,
                                            Assignment_Date__c,Collection_Agency_Placement__r.Serviceable_Province__c, Customer__c   
                                            FROM Product__C 
                                            WHERE name in :accountNumberList] ){
                mapProductName.put(accountRecord.name, accountRecord);
            }
            
            for(ProductWrapper wrapRecord : listProductWrapper){
                Product__c product = new Product__c();
                if(String.isNotBlank(wrapRecord.data_id)){
                    if(wrapRecord.data_id.contains('.') ){
                    wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                    }
                    product.Name = wrapRecord.data_id;    
                }
                
                if(String.isNotBlank(wrapRecord.place_id)){
                    if(wrapRecord.place_id.contains('.') ){
                        wrapRecord.place_id = wrapRecord.place_id.substringBefore('.');
                    }
                    product.Collection_Agency__c = Decimal.valueOf(wrapRecord.place_id);
                        
                }
                system.debug('wrapRecord: '+wrapRecord);
                if(String.isNotBlank(product.Name) && product.Collection_Agency__c != NULL){
                    listProductsToInsert.add(product);    
                }
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
        message.subject = 'Product Recall Status';
        String processingLink = '';
        String processingStatus = '';
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Product Recall records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductRecallStaging?id='+documentID;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductRecallStaging?id='+documentID;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'Product Recall processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductRecallStaging?id='+documentID;
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
    
    
    public static set<String> getProductPaymentDetails(set<String> setProductId){
        set<String> setRecentlyPaidProducts = new set<String>();
        for(Product_Payments__c productPay : [SELECT ID, CCS_Account__c,CCS_Account__r.Name 
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__c IN :setProductId
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60]){
            setRecentlyPaidProducts.add(productPay.CCS_Account__r.Name);
        }
        return setRecentlyPaidProducts;
    }
    
    //Validation method to be called  before update
    public static list<Product_Staging__c> validationOnRecordUpdate(List<Product__c> listProducts, map<String, Product__c> mapProductName,
                                                ID documentID
                                                ){
        
        Map<String ,Placement__c> mapPlacement =new Map<String,Placement__c>();
        Map<Id ,Product_Payments__c> mapProductPayment =new Map<Id,Product_Payments__c>();
        set<String> setRecentlyPaidProducts = new set<String>();
        setRecentlyPaidProducts = getProductPaymentDetails(mapProductName.keySet());
        system.debug('setRecentlyPaidProducts: '+setRecentlyPaidProducts);               
        system.debug('mapProduct:: '+mapProductName);
        
         for(Placement__c placement : [SELECT ID, Name, Serviceable_Province__c
                                       FROM Placement__c 
                                      ]){
           mapPlacement.put(placement.Name, placement);
        }
                                                    
        system.debug('mapPlacement: '+mapPlacement);
                                                    
        list<Product_Staging__c> listProductAllocateStaging = new list<Product_Staging__c>();
        Product_Staging__c productStaging = new Product_Staging__c();
        String newAgency = '';
        String oldAgency = '';
        for(Product__c product: listProducts){
            system.debug('product.Name: '+product.Name);
            newAgency = String.valueOf(Math.floor(product.Collection_Agency__c));
            system.debug('newAgency: '+newAgency);
            
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Collection_Agency__c != NULL){
                    oldAgency = String.valueOf(Math.floor(mapProductName.get(product.Name).Collection_Agency__c));    
            }
            system.debug('oldAgency: '+oldAgency);
            // 3
            String EXPECTED = '';
            String ERROR_MSG = '';
            
            
            if(!mapProductName.containsKey(product.Name)){
                ERROR_MSG = '<b>ERROR</b> - Invalid Account Number.'+'<br/>';
            }
            
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Collection_Agency__C == NULL){
                ERROR_MSG = '<b>ERROR</b> - Product is already Recalled.'+'<br/>';
            }
            
            if(mapProductName.containsKey(product.Name) 
            && String.isNotBlank(mapProductName.get(product.Name).Collection_Sub_Status__c)
            && mapProductName.get(product.Name).Collection_Sub_Status__c == 'Legal'){
                system.debug('recall warning::');
                ERROR_MSG += '<b>WARNING</b> - '+'Product is in Legal Status'+'<br/>';
                //product.addError('Cannot recall agency as Product is in Legal Status');
            }
            
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Assignment_Date__c != NULL
            && mapProductName.get(product.Name).Assignment_Date__c.daysBetween(Date.today())  <= 180){
                ERROR_MSG += '<b>WARNING</b> - '+'Product has been placed with this collection agency for a minimum amount of time(6 months)'+'<br/>';
                //EXPECTED += 'Product Placement Date - ' + Date.valueOf(mapProductName.get(product.Name).Assignment_Date__c)+'.<br/>';
            }
            
            //Check Recall Validations
            if(setRecentlyPaidProducts.contains(product.Id)){
                ERROR_MSG += '<b>WARNING</b> - '+'Account had a recent payment in last 2 months'+'<br/>';
            }
            //system.debug('mapProductName.get(product.Name).Customer__c:: '+mapProductName.get(product.Name).Customer__c);
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Customer__c == NULL){
                ERROR_MSG = '<b>ERROR</b> - Customer not present on Product record.'+'<br/>';
            }
            
            String AgencyProvince;
            
            
            productStaging = new Product_Staging__c();
            productStaging.Name__c = product.Name;
            productStaging.Comment__c = ERROR_MSG;
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentID;
            productStaging.Expected_Value__c = EXPECTED;
            productStaging.Document_Storage__c = productStaging.Identifier__c;
            if(product.Collection_Agency__c != NULL ){
                productStaging.Placement_Agency__c = String.valueOf(product.Collection_Agency__c);
                productStaging.Placement_Agency_ID__c = mapPlacement.get(productStaging.Placement_Agency__c).ID;
            }
            if(mapProductName.containsKey(productStaging.Name__c)){
                productStaging.Product_ID__c = mapProductName.get(productStaging.Name__c).ID;
                productStaging.Assignment_Date__c = mapProductName.get(productStaging.Name__c).Assignment_Date__c;
            }
            system.debug('productStaging: '+productStaging);
            if(String.isBlank(ERROR_MSG)){
                productStaging.Comment__c = 'SUCCESS';
            }
            listProductAllocateStaging.add(productStaging);
            ERROR_MSG = '';
           newAgency = '';
           oldAgency = '';
        }
        system.debug('listProductAllocateStaging: '+listProductAllocateStaging);
        return listProductAllocateStaging;
    }
    
    //Wrapper class for insolvency payment records
    public class productWrapper{
        public String data_id{get;set;}
        public String place_id{get;set;}
        //public String pool_id{get;set;}
        //public String place_status{get;set;}

    }
    
}