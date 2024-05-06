/**************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product Allocation Staging records and check Product allocation validtaions
*  @author : A5E Consulting
*  @date : 09/03/2022
/**************************************************************************************************/

public class ProductAllocationExcelFileProcessing {
    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<productWrapper> listProductWrapper = new List<productWrapper>();
    public static Map<String,Provice_Name_Map_with_Abbreviations__mdt> mapProviceAbbreviations = Provice_Name_Map_with_Abbreviations__mdt.getAll();
    public static Map<String, String> mapProvinceAcronym = new Map<String, String>();
    
    public ProductAllocationExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId){
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
            List<Product__c> listProductsToInsert = new List<Product__c>();
            List<String> accountNumberList = new List<String>();
            List<String> poolNumberList = new List<String>();
            //map of account number to the Salesforce record ID
            Map<String, Product__c> mapProductName= new Map<String, Product__c>();
            set<ID> setProdutID = new set<ID>();
            set<String> setPlacementNames = new set<String>();
            Map<String ,Pool__C> mapPoolName =new Map<String,Pool__C>();

            for(ProductWrapper wrapRecord : listProductWrapper){
                if(String.isNotBlank(wrapRecord.data_id) &&  wrapRecord.data_id.contains('.') ){
                    wrapRecord.data_id = wrapRecord.data_id.substringBefore('.');
                }
                wrapRecord.data_id = wrapRecord.data_id.toUppercase();
                accountNumberList.add(wrapRecord.data_id);
                if(String.isNotBlank(wrapRecord.pool_name)){
                    if(wrapRecord.pool_name.contains('.') ){
                        wrapRecord.pool_name = wrapRecord.pool_name.substringBefore('.');
                    }
                    poolNumberList.add(wrapRecord.pool_name);
                    
                }
            }

            for(Pool__C pool : [SELECT ID, Name,Placement_Agency__c
                                FROM Pool__C 
                                where Name =: poolNumberList ]){
                                   mapPoolName.put(pool.Name, pool);  
                               }
            
            for(Product__C accountRecord : [SELECT ID, Name, Collection_Agency__c,Collection_Sub_Status__c,State__c,Current_Principal_Balance__c,
                                            Current_Interest_Amount__c,Fee_Recovery__c,Assignment_Date__c,Collection_Agency_Placement__r.Serviceable_Province__c,
                                            Data_Status_Description__c, Pool_Name__r.Name,RecordTypeId,Commission_Rate_at_Time_of_Placement__c,
                                            Commission_Rate__c,Value_Tier_at_Time_of_Placement__c,Settlement_Rate__c,Current_Bal_NSF_Fees__c,Purchase_Province__c
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
                if(String.isNotBlank(wrapRecord.Commission_Rate_at_time_of_Placement)){
                    product.Commission_Rate_at_Time_of_Placement__c = Decimal.valueOf(wrapRecord.Commission_Rate_at_time_of_Placement);
                }
                if(String.isNotBlank(wrapRecord.Current_Commission_rate)){
                    product.Commission_Rate__c = Decimal.valueOf(wrapRecord.Current_Commission_rate);
                }
                if(String.isNotBlank(wrapRecord.Value_Tier_at_time_of_Placement)){
                    if(wrapRecord.Value_Tier_at_time_of_Placement.contains('.') ){
                        wrapRecord.Value_Tier_at_time_of_Placement = wrapRecord.Value_Tier_at_time_of_Placement.substringBefore('.');
                    }
                    product.Value_Tier_at_Time_of_Placement__c = wrapRecord.Value_Tier_at_time_of_Placement;
                }
                if(String.isNotBlank(wrapRecord.Settlement_Rate)){
                    product.Settlement_Rate__c = Decimal.valueOf(wrapRecord.Settlement_Rate);
                }
                if(String.isNotBlank(wrapRecord.Settlement_Rate_at_time_of_Placement)){
                    product.Placed_Settlement_Rate__c = Decimal.valueOf(wrapRecord.Settlement_Rate_at_time_of_Placement);
                }
                if(String.isNotBlank(wrapRecord.pool_name)){
                    if(wrapRecord.pool_name.contains('.') ){
                        wrapRecord.pool_name = wrapRecord.pool_name.substringBefore('.');
                    }
                    product.Pool_Name_Text__c = wrapRecord.pool_name;
                }  
                if(String.isNotBlank(wrapRecord.data_id) || String.isNotBlank(wrapRecord.place_id)
                  || String.isNotBlank(wrapRecord.Commission_Rate_at_time_of_Placement) || String.isNotBlank(wrapRecord.Current_Commission_rate)
                  || String.isNotBlank(wrapRecord.Settlement_Rate) || String.isNotBlank(wrapRecord.Value_Tier_at_time_of_Placement) || String.isNotBlank(wrapRecord.pool_name)
                  || String.isNotBlank(wrapRecord.Settlement_Rate_at_time_of_Placement)){
                    listProductsToInsert.add(product);    
                } 
            }
            
            list<Product_Staging__c> listProductStaging = validationOnRecordUpdate(listProductsToInsert, mapProductName,
                                                              documentID,mapPoolName);
            Database.SaveResult[] sr = database.insert(listProductStaging);    
        }
        catch(Exception ex){
            exceptionMessage = String.valueOf(ex);
            system.debug('exceptionMessage::'+ex.getStackTraceString());
        }
        
        list<Document_Storage__c> listDocuments = [Select ID, Creator__c, Work_Assignment__c, Uploaded_By__c 
                                                        FROM Document_Storage__c 
                                                        WHERE ID= :documentID];

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
        message.subject = 'Product Allocation Status';
        
        String processingLink = '';
        String processingStatus = '';
        Boolean stagingCreated;
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Payment records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductAllocateStaging?id='+documentID;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductAllocateStaging?id='+documentID;
            processingStatus = 'Staging Table Created';
            stagingCreated = true;
        }
        else{
            message.plainTextBody = 'Product Allocation processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayProductAllocateStaging?id='+documentID;
            processingStatus = 'Staging Table Creation Failed';
            stagingCreated = false;
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
                                                          File_Processing_Error__c = exceptionMessage,
                                                          File_Processing_Status__c = processingStatus,
                                                          Staging_Records_Created__c = stagingCreated
                                                         );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
    
    
    public static Set<String> getPlacementHistoryDetails(set<String> setProductName){
        set<String> setProductAgencyName = new set<String>();
        //Get Placement History for new Distressed Products
        for(Placement_History__c placementHistory : [SELECT ID, Placement__r.Name, Product__c, Product__r.Name
                                                     FROM Placement_History__c
                                                     WHERE Product__r.Name IN :setProductName
                                                     AND CreatedDate = LAST_N_DAYS:180]){
            //Combine Product name + Placement Agency
            setProductAgencyName.add(placementHistory.Product__r.Name + placementHistory.Placement__r.Name );   
        }
        return setProductAgencyName;
    }
    
    //Validation method to be called  before update
    public static list<Product_Staging__c> validationOnRecordUpdate(List<Product__c> listProducts, map<String, Product__c> mapProductName,
                                                ID documentID,Map<String ,Pool__C> mapPoolName
                                                ){
        
        Map<String ,Placement__c> mapPlacement =new Map<String,Placement__c>();
        Map<String ,Pool__c> mapPool =new Map<String,Pool__c>();                                                
        Map<Id ,Product_Payments__c> mapProductPayment =new Map<Id,Product_Payments__c>();
        list<Product_Staging__c> listProductAllocateStaging = new list<Product_Staging__c>();
        set<String> setPreviousPlacedProductNames = new set<String>();
        Product_Staging__c productStaging = new Product_Staging__c();
        String newAgency = '';
        String oldAgency;
        String prodAgency = '';
        String poolAgency = '';
        String EXPECTED = '';
        String ERROR_MSG = '';
                                                    
        setPreviousPlacedProductNames = getPlacementHistoryDetails(mapProductName.keySet());
        
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>();     
       	for(Product__c prodList:listProducts){
            if(mapProductNameAmount.containsKey(String.valueOf(prodList.Name))){
                mapProductNameAmount.put(String.valueOf(prodList.Name), 
                                        mapProductNameAmount.get(prodList.Name)+1);
            }
            else{
                mapProductNameAmount.put(String.valueOf(prodList.Name), 1);
            }
        }
                                                    
        for(Placement__c placement : [Select ID, Name, Serviceable_Province__c
                                      From Placement__c ]){
           mapPlacement.put(placement.Name, placement);
        }
                                                    
        for(Pool__c pool : [SELECT ID, Name,Placement_Agency__c
                                       FROM Pool__c ]){
           mapPool.put(pool.Name, pool);
        }   
        //Fill provice name map with abbriviations                                            
        for(Provice_Name_Map_with_Abbreviations__mdt metaData : mapProviceAbbreviations.values()){
            mapProvinceAcronym.put(metaData.Province_Acronym__c,metaData.Province_Name__c);
        }                                            
                                                 
        for(Product__c product: listProducts){
            if(product.Collection_Agency__c != NULL){
                newAgency = String.valueOf(Math.floor(product.Collection_Agency__c));    
            }
            if(mapProductName.containsKey(product.Name)
            && mapProductName.get(product.Name).Collection_Agency__c != NULL){
                    oldAgency = String.valueOf(Math.floor(mapProductName.get(product.Name).Collection_Agency__c));    
            }
            if(setPreviousPlacedProductNames.contains(product.Name+ newAgency)){
                ERROR_MSG+= '<b>WARNING</b> - '+'Product is placed with the agency in last 6 months'+'<br/>';
            }
            if(!mapProductName.containsKey(product.Name)){
                ERROR_MSG = '<b>ERROR</b> - Invalid Account Number.'+'<br/>';
            }
            if((String.isNotBlank(newAgency) && !mapPlacement.containsKey(newAgency))){
                ERROR_MSG = '<b>ERROR</b> - Invalid Agency Number.'+'<br/>';
            }  
            if( String.isBlank(newAgency)){
                ERROR_MSG = '<b>ERROR</b> - Enter Agency Number to allocate.'+'<br/>';
            }
            if(mapPool.get(product.Pool_Name_Text__c) == NULL && String.isNotBlank(product.Pool_Name_Text__c)){
                ERROR_MSG += '<b>ERROR</b> - This Pool is not available in system.<br/>';
            }
            if(mapProductNameAmount.containsKey(product.Name )
            && mapProductNameAmount.get(product.Name) > 1){
				ERROR_MSG += '<b>WARNING</b> - A duplicate transaction was found in this File Update.<br/>';    
            }
            String AgencyProvince;
            if(String.isNotBlank(newAgency)
            && mapPlacement.containsKey(newAgency)
            && String.isNotBlank(mapPlacement.get(newAgency).Serviceable_Province__c)){
                AgencyProvince = mapPlacement.get(newAgency).Serviceable_Province__c; 
            }
            if(String.isNotBlank(newAgency)
            && String.isNotBlank(AgencyProvince)
            && mapProductName.containsKey(product.Name)
            && String.isNotBlank(mapProductName.get(product.Name).Purchase_Province__c)
            && ( (!mapProvinceAcronym.containsKey(mapProductName.get(product.Name).Purchase_Province__c) && !AgencyProvince.contains(mapProductName.get(product.Name).Purchase_Province__c))
            ||   (mapProvinceAcronym.containsKey(mapProductName.get(product.Name).Purchase_Province__c)  &&!AgencyProvince.contains(mapProvinceAcronym.get(mapProductName.get(product.Name).Purchase_Province__c))))){
                ERROR_MSG += '<b>ERROR</b> - '+'Product cannot be placed with agency as Product Province is Non Serviceable for Agency'+'<br/>';
                EXPECTED += 'Product Province - ' + mapProductName.get(product.Name).Purchase_Province__c +'<br/>';
            }
            if(newAgency == oldAgency){
                ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with Same agency'+'<br/>'; 
            }
            else if(String.isNotBlank(oldAgency) && oldAgency != '9999'){
                ERROR_MSG += '<b>ERROR</b> - '+'Product is already placed with another agency'+'<br/>';
                EXPECTED += 'Current Agency- ' + oldAgency +'<br/>';
            }
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
            if(mapPoolName.get(product.Pool_Name_Text__c).Placement_Agency__c != null &&
              prodAgency != poolAgency){
                ERROR_MSG += '<b>ERROR</b> - Pool cannot be mapped to account.<br/>';
                EXPECTED += 'Pool Agency is different to account collection agency.<br/>';  
            }
            if(String.isNotBlank(prodAgency) && String.isNotBlank(poolAgency)){
                if(poolAgency != '9999' && prodAgency != '9999'){
                    if(prodAgency != poolAgency){
                        ERROR_MSG += '<b>ERROR</b> - This account cannot be assigned to Pool.<br/>';
                        EXPECTED += 'Pool Agency = ' +poolAgency+'.<br/>Product Agency = ' +prodAgency+'.<br/>';
                    }
                }
            }
            if(String.isNotBlank(newAgency)
            && mapProductName.containsKey(product.Name)){
                if(String.isNotBlank(mapProductName.get(product.Name).Collection_Sub_Status__c)){
                    String collectionSubStatus = mapProductName.get(product.Name).Collection_Sub_Status__c;
                    if(collectionSubStatus == 'Credit Counselling'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Credit Counselling Collection Sub Status'+'<br/>';
                    }
                    else if(collectionSubStatus == 'Cease and Desist – In Writing'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Cease and Desist – In Writing Collection Sub Status'+'<br/>';
                    }
                    else if(collectionSubStatus == 'Buy back/put back and sale categories'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Buy back/put back and sale categories Collection Sub Status'+'<br/>';
                    }
                    else if(collectionSubStatus == 'Paid in Full Account'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Paid in Full Account Collection Sub Status'+'<br/>';
                    }
                    else if(collectionSubStatus == 'Fraud Claimed'){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Fraud Claimed Collection Sub Status'+'<br/>';
                    }
                }
                if(String.isNotBlank(mapProductName.get(product.Name).Data_Status_Description__c)){
                    String dataStatus = mapProductName.get(product.Name).Data_Status_Description__c;
                    if(dataStatus.contains('Closed')){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is in Closed Status'+'<br/>';    
                    }
                    else if(dataStatus.contains('Insolvency') 
                         || dataStatus.contains('Insolvent')){
                        ERROR_MSG += '<b>ERROR</b> - '+'Product is Insolveny Status'+'<br/>';    
                    } 
                }
            }
            
            productStaging = new Product_Staging__c();
            productStaging.Name__c = product.Name;
            productStaging.Comment__c = ERROR_MSG;
            productStaging.Status__c = 'Pending';
            productStaging.Identifier__c = documentID;
            productStaging.Expected_Value__c = EXPECTED;
            productStaging.Placement_Status_Code__c = '100000';
            productStaging.Data_Status_Code__c = '300000';
            productStaging.Document_Storage__c = productStaging.Identifier__c;
            if(mapProductName.containsKey(product.Name)){
                if(mapProductName.get(product.Name).Current_Principal_Balance__c != NULL){
            		productStaging.Current_Principal_Balance__c = mapProductName.get(product.Name).Current_Principal_Balance__c ;       
                }
                if(mapProductName.get(product.Name).Current_Interest_Amount__c != NULL){
            		productStaging.Current_Interest_Balance__c = mapProductName.get(product.Name).Current_Interest_Amount__c;       
                }
                Decimal NSF = 0;
                if(mapProductName.get(product.Name).Current_Bal_NSF_Fees__c != NULL){
                    NSF = mapProductName.get(product.Name).Current_Bal_NSF_Fees__c;
                }
                if(mapProductName.get(product.Name).Fee_Recovery__c != NULL){
            		productStaging.Fees__c = mapProductName.get(product.Name).Fee_Recovery__c + NSF;        
                }
            }
             
            if(product.Collection_Agency__c != NULL ){
                productStaging.Placement_Agency__c = String.valueOf(product.Collection_Agency__c);
                if(mapPlacement.containsKey(productStaging.Placement_Agency__c)){
                    productStaging.Placement_Agency_ID__c = mapPlacement.get(productStaging.Placement_Agency__c).ID;    
                }
            }
            if(mapProductName.containsKey(productStaging.Name__c)){
                productStaging.Product_ID__c = mapProductName.get(productStaging.Name__c).ID;
            }
            if(mapProductName.containsKey(productStaging.Name__c)){
                productStaging.Record_Type_ID__c = mapProductName.get(productStaging.Name__c).RecordTypeId;
            }
            if(product.Commission_Rate_at_Time_of_Placement__c != NULL ){
                productStaging.Placed_Commission_Rate__c = product.Commission_Rate_at_Time_of_Placement__c;
            }
            if(product.Commission_Rate__c != NULL ){
                productStaging.Current_Commission_Rate__c = product.Commission_Rate__c;
            }
            if(product.Settlement_Rate__c != NULL ){
                productStaging.Current_Settlement_Rate__c = product.Settlement_Rate__c;
            }
            if(product.Value_Tier_at_Time_of_Placement__c != NULL ){
                productStaging.Value_Tier_at_Time_of_Placement__c = product.Value_Tier_at_Time_of_Placement__c;
            }
            if(product.Placed_Settlement_Rate__c != NULL ){
                productStaging.Placed_Settlement_Rate__c = product.Placed_Settlement_Rate__c;
            }
            productStaging.Pool_Name__c = String.valueOf(product.Pool_Name_Text__c);
            if(product.Pool_Name_Text__c != NULL && mapPool.get(product.Pool_Name_Text__c) != NULL){
                productStaging.Pool_Name_ID__c = mapPool.get(productStaging.Pool_Name__c).ID;
            }
            if(String.isBlank(ERROR_MSG)){
                productStaging.Comment__c = 'SUCCESS';
            }
            listProductAllocateStaging.add(productStaging);
            ERROR_MSG = '';
           newAgency = '';
           oldAgency = '';
        }
        return listProductAllocateStaging;
    }
    
    //Wrapper class for insolvency payment records
    public class productWrapper{
        public String data_id{get;set;}
        public String place_id{get;set;}
        public String Commission_Rate_at_time_of_Placement{get;set;}
        public String Current_Commission_rate{get;set;}
        public String Settlement_Rate{get;set;}
        public String Value_Tier_at_time_of_Placement{get;set;}
        public String pool_name{get;set;}
        public String Settlement_Rate_at_time_of_Placement{get;set;}

    }
    
}