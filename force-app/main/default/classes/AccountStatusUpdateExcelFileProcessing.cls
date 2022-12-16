/**************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product  Staging records and check Account Status Update validtaions
*  @author : A5E Consulting
*  @date : 08/03/2022
/**************************************************************************************************/
public class AccountStatusUpdateExcelFileProcessing {
    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    List<accountRecordsWrapper> listAccountRecordWrapper = new List<accountRecordsWrapper>();
    list<Document_Storage__c> listDocuments = new list<Document_Storage__c>();
    public static map<String, ID> mapProductJudgment = new map<String, ID>();
        
    public AccountStatusUpdateExcelFileProcessing (String data, String workAssignmentPlacement, ID documentId) {
        exceptionMessage = '';
        listAccountRecordWrapper = deSerializeJSON(data);
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.documentId = documentId;
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
            list<Product_Staging__c> listpayStaging = validationOnRecordUpdate(listProductsToInsert, 
                                                                               mapProduct, documentId, 
                                                                               workAssignmentPlacement,mapFilingDate,
                                                                               listDocuments[0]
                                                                             );
            Database.SaveResult[] sr = database.insert(listpayStaging);
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
        
        //Update file processing link on DOcument
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        system.debug('exceptionMessage testing' +exceptionMessage);
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
    
    public static set<String> getProductPaymentDetails(set<String> setProductNames){
        set<String> setRecentlyPaidProducts = new set<String>();
        for(Product_Payments__c productPay : [SELECT ID, CCS_Account__c,CCS_Account__r.Name 
                                              FROM Product_Payments__c 
                                              WHERE CCS_Account__r.Name IN :setProductNames
                                              AND Payment_Posting_Date__c = LAST_N_DAYS:60]){
            setRecentlyPaidProducts.add(productPay.CCS_Account__r.Name);
        }
        return setRecentlyPaidProducts;
    }
    
    //Validation method to be called  before update
    public static list<Product_Staging__c> validationOnRecordUpdate(List<Product__c> listProduct, 
                                                map<String,Product__c> mapProduct, ID documentId,
                                                String workAssignmentPlacement,map<String,String> mapFilingDate,
                                                Document_Storage__c docStorage
                                                ){
                                                    
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>();
        map<String, Judgment_product_codes_mapping__c> mapJudgment = Judgment_product_codes_mapping__c.getAll();
        map<String, Judgment_product_codes_mapping__c> mapJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();                                            
        for(Judgment_product_codes_mapping__c judgmentCodes : mapJudgment.values()){
            mapJudgmentCodes.put(judgmentCodes.Codes__c, judgmentCodes);
        }
        set<String> setRecentlyPaidProducts = new set<String>();
        setRecentlyPaidProducts = getProductPaymentDetails(mapProduct.keySet());
        system.debug('setRecentlyPaidProducts::'+setRecentlyPaidProducts);                 
        for(Product__c prodPayment:listProduct){
            if(mapProductNameAmount.containsKey(String.valueOf(prodPayment.Name))){
                mapProductNameAmount.put(String.valueOf(prodPayment.Name), 
                                        mapProductNameAmount.get(prodPayment.Name)+1);
            }
            else{
                mapProductNameAmount.put(String.valueOf(prodPayment.Name), 1);
            }
        }
                                                    
        list<Product_Staging__c> listAccStaging = new list<Product_Staging__c>();                                          
        Product_Staging__c accStaging = new Product_Staging__c();
                                                    
        Map<String, Placement_Status_Code_Mapping__c> settings = Placement_Status_Code_Mapping__c.getAll();
                                                       
        for(Product__c product:listProduct){
            system.debug('product::::: '+product);
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';
            String newAgency = '';
            
            //Regex to check MM/DD/YYYY (text format in excel)
            String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4})$';
            //String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4}|[0-9]{2})$';
            
            //Regex to check YYYY/MM/DD (Date format in excel)
            String dateRegex2 = '^([0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
            
            String dateRegex3 = '^([0-9]{4}|[0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
            Pattern MyPattern3 = Pattern.compile(dateRegex3);
            
            
            
            Pattern MyPattern1 = Pattern.compile(dateRegex);
            
            Pattern MyPattern2 = Pattern.compile(dateRegex2);
            
            Matcher MyMatcher1;
            if(String.isNotBlank(product.Status_Changed_Date_Text__c)){
                MyMatcher1 = MyPattern1.matcher(product.Status_Changed_Date_Text__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(product.Status_Changed_Date_Text__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(product.Status_Changed_Date_Text__c);
                system.debug('MyMatcher3.matches()::'+MyMatcher3.matches());
                
                system.debug('MyMatcher1:: '+MyMatcher1);
                system.debug('MyMatcher1.matches()::'+MyMatcher1.matches());
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                system.debug('product.Status_Changed_Date_Text__c::'+product.Status_Changed_Date_Text__c);
                //matching of date when entered in Text format in excel file
                if(MyMatcher1.matches() == true){
                    list<String> datelist = product.Status_Changed_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    system.debug('myDate::'+myDate);
                    product.Status_Changed_Date__C = myDate;
                    system.debug('product.Status_Changed_Date__C external '+product.Status_Changed_Date__C);
                }
                //matching of date when entered in Date format in excel file  product.Status_Changed_Date__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist = product.Status_Changed_Date_Text__c.split('/');
                    system.debug('datelist2 ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    product.Status_Changed_Date__C = myDate;
                    product.Status_Changed_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+product.Status_Changed_Date_Text__c);
                    system.debug('product.Status_Changed_Date__C external '+product.Status_Changed_Date__C);
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist = product.Status_Changed_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    product.Status_Changed_Date__C = myDate;
                    product.Status_Changed_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+product.Status_Changed_Date_Text__c);
                    system.debug('product.Status_Changed_Date__C external '+product.Status_Changed_Date__C);
                }
            }
            

            
            system.debug('workAssignmentPlacement inside validation' +workAssignmentPlacement);
            
            if(!mapProduct.containsKey(product.Name)){
                ERROR_MSG += '<b>ERROR</b> - Account not found.<br/>';
            }
            //Invalid Payment Date
            if(product.Status_Changed_Date__C != NULL){
                if(product.Status_Changed_Date__C > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid payment date.<br/>';
                    EXPECTED += 'Payment Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isNotBlank(product.Status_Changed_Date_Text__c)){
                   ERROR_MSG += '<b>ERROR</b> - Invalid payment date.<br/>';
                   EXPECTED += 'Payment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                else{
                    ERROR_MSG += '<b>ERROR</b> - Enter valid payment date.<br/>';
                    EXPECTED += 'Payment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                /*ERROR_MSG += '<b>ERROR</b> - Invalid payment date.\n';
                EXPECTED += 'Payment Date cannot be blank.<br/>';*/
            } 
            
            if(docStorage != NULL && docStorage.Uploaded_By__c == 'External User' && mapProductJudgment.containsKey(product.Name)){
                 ERROR_MSG += '<b>ERROR</b> - Invalid Status Update.<br/>';
                 EXPECTED += 'Agency user cannot update the status on Product with Judgment<br/>';
            }
             
            if(mapProduct.containsKey(product.Name)
            && mapProduct.get(product.Name).Collection_Agency__c != NULL){
                newAgency = String.valueOf(Math.floor(mapProduct.get(product.Name).Collection_Agency__c));  
                system.debug('newAgency inside if' +newAgency);
            }
            
            //Check Recall Validations
            if(setRecentlyPaidProducts.contains(product.Name)){
                ERROR_MSG += '<b>WARNING</b> - '+'Account had a recent payment in last 2 months'+'<br/>';
            }
            
            if(mapJudgmentCodes.containsKey(product.Placement_Status__c)){
                ERROR_MSG += '<b>ERROR</b> - Judgment Code should not updated as Status Code.<br/>';
            }
            
            if(mapProduct.containsKey(product.Name)
            && String.isNotBlank(mapProduct.get(product.Name).Placement_Status__c)
            && String.isNotBlank(product.Placement_Status__c)){
                if(product.Placement_Status__c.startsWith('9') 
                && mapProduct.get(product.Name).Placement_Status__c.startsWith('8')){
                    if(product.Placement_Status__c.subStringAfter('9') <> mapProduct.get(product.Name).Placement_Status__c.subStringAfter('8')){
                        ERROR_MSG += '<b>ERROR</b> - An Invalid Status Code was provided.<br/>';
                        EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                    }
                }
            }
          
            //Validation User can not update status from pending recall to any other status instead of confirm recall.
            if(mapProduct.containsKey(product.Name)
            && String.isNotBlank(mapProduct.get(product.Name).Placement_Status__c)
            && String.isNotBlank(product.Placement_Status__c))
            {

                if(mapProduct.get(product.Name).Placement_Status__c.startsWith('8') && !product.Placement_Status__c.startsWith('9') && docStorage != NULL /*&& docStorage.Uploaded_By__c == 'External User'*/){
                        ERROR_MSG += '<b>ERROR</b> - Status cannot change from pending recall to any other status.<br/>';
                        //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }
                
                //agency can not change from any other status to recall status.
               
                if(!mapProduct.get(product.Name).Placement_Status__c.startsWith('8') && product.Placement_Status__c.startsWith('9') && docStorage != NULL && docStorage.Uploaded_By__c == 'External User'){
                        system.debug('Run Block123');
                        ERROR_MSG += '<b>ERROR</b> - Status can not change from any other to recall status.<br/>';
                        //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }
                
                //agency can not change status when refer to legal is in for review/main status is in pregal.
                 //system.debug('Test run block::'+mapProduct.get(product.Name).Status__c.startsWith('Pre - Legal'));
                if(mapProduct.get(product.Name).Status__c != null){
                      if((mapProduct.get(product.Name).Status__c.startsWith('Pre - Legal') && mapProduct.get(product.Name).Placement_Status__c != product.Placement_Status__c) || (mapProduct.get(product.Name).Refer_to_Legal__c == 'For Review' && mapProduct.get(product.Name).Placement_Status__c != product.Placement_Status__c)){
                        ERROR_MSG += '<b>ERROR</b> - Status can not change if refer to legal is in For review/placement status is in Pre-Legal.<br/>';
                        //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                   }
                }
               
            }

            system.debug('newAgency inside validation' +newAgency);
            if(docStorage != NULL && docStorage.Uploaded_By__c == 'External User'){
                if(product.Placement_Status__c.startsWith('8')){
                    ERROR_MSG += '<b>ERROR</b> - Agency User cannot set account to Recall Status.<br/>';
                    //EXPECTED += 'Current Placement Status = ' +mapProduct.get(product.Name).Placement_Status__c+'.<br/>';
                }
                if(mapProduct.containsKey(product.Name)
                && String.isNotBlank(mapProduct.get(product.Name).Placement_Status__c)
                && String.isNotBlank(product.Placement_Status__c)
                && !(mapProduct.get(product.Name).Placement_Status__c.startsWith('8'))
                && product.Placement_Status__c.startsWith('9')){
                    ERROR_MSG += '<b>ERROR</b> - A status change is not permitted.<br/>';
                    EXPECTED += 'Account is not in Pending Recall Status' +'.<br/>'; 
                }
                system.debug('product is presenet'+mapProduct.containsKey(product.Name));
                if(String.isnotblank(workAssignmentPlacement) 
                && workAssignmentPlacement != newAgency 
                && newAgency != '9999'){
                    ERROR_MSG += '<b>ERROR</b> - This account is not available in this Placement.<br/>';
                    EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>';        
                }
                /*else if(mapProduct.containsKey(product.Name)
                && (String.isBlank(newAgency) || newAgency == '9999')){
                    ERROR_MSG += '<b>ERROR</b> - Contact does not have permission to this account.<br/>';
                    EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 
                        
                } */  
                
            }
            
            if(mapProduct.containsKey(product.Name)
               && (String.isBlank(newAgency) || newAgency == '9999')){
                   ERROR_MSG += '<b>ERROR</b> - Account is already recalled.<br/>';
                   EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 
                   
               }  
            
            /*if(workAssignmentPlacement != newAgency && newAgency != '9999'){
                ERROR_MSG += '<b>ERROR</b> - This account is not available in this Placement.<br/>';
                EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 
                    
            }
            
            else if(mapProduct.containsKey(product.Name)
            && (mapProduct.get(product.Name).Collection_Agency__c == NULL || mapProduct.get(product.Name).Collection_Agency__c == 9999)){
                ERROR_MSG += '<b>ERROR</b> - Contact does not have permission to this account.<br/>';
                EXPECTED += 'WorkAssignment Agency = ' +workAssignmentPlacement+'.<br/>Product Agency = ' +newAgency+'.<br/>'; 
                    
            }*/
            
            system.debug('product.Placement_Status__c::'+product.Placement_Status__c);
            /*for(String ss : settings.keySet()){
                system.debug('settings::'+ss);
            }*/
            if(!settings.keySet().Contains(product.Placement_Status__c)){
                system.debug('inside setStatusCode');
                ERROR_MSG += '<b>ERROR</b> - The Status Code provided was not found.<br/>';
                EXPECTED += 'Invalid Status Code.'+'<br/>'; 
            }
            
            if(mapProductNameAmount.containsKey(product.Name )
            && mapProductNameAmount.get(product.Name) > 1){
                ERROR_MSG += '<b>ERROR</b> - A duplicate transaction was found in this File Update.<br/>';    
            }
            
            if(mapProduct.containsKey(product.Name)
               && mapProduct.get(product.Name).Data_Status_Description__c != null
               && mapProduct.get(product.Name).Data_Status_Description__c.startswith('Closed')){
                   ERROR_MSG = '<b>ERROR</b> - Account is Closed.<br/>';
            }
            /*if(mapProduct.containsKey(product.Name)
               && mapProduct.get(product.Name).Status__c != null
               && mapProduct.get(product.Name).Status__c.startswith('Pending Recall')){
                   ERROR_MSG = '<b>ERROR</b> - Account in Pending Recall.<br/>';
            }*/
            system.debug('product status date tested::' +product.Status_Changed_Date__c);
  
            
            if(product.Status_Changed_Date__c > Date.today()){
                ERROR_MSG += '<b>ERROR</b> - Invalid Status date.<br/>';
                EXPECTED += 'Status Date cannot be in future.<br/>';                    
            }else if(product.Status_Changed_Date__c == null){
                ERROR_MSG += '<b>ERROR</b> - Invalid Status date.<br/>';
                EXPECTED += 'Status Date Should be in proper format.<br/>';  
            }
            
            System.debug('Current Date ' +Date.today());
            
            if(product.Assignment_Date__c <= Date.today()){    
                ERROR_MSG += '<b>ERROR</b> - Invalid Status Date found. Must be after account Placement Date.<br/>';
                EXPECTED += 'Assignment Date should be greater than current date <br/>';
            }
            system.debug('product tested::');
            
            
            accStaging = new Product_Staging__c();
            system.debug('product: '+product);
            accStaging.Name__c = product.Name;
            accStaging.Placement_Agency__c = workAssignmentPlacement;
            accStaging.Comment__c = ERROR_MSG;
            accStaging.Status__c = 'Pending';
            accStaging.Identifier__c = documentId;
            accStaging.Document_Storage__c = documentId;
            accStaging.Placement_Status_Code__c = product.Placement_Status__c;
            
            
            if(mapProduct.containsKey(product.Name)){
                accStaging.Product_ID__c = mapProduct.get(product.Name).ID;
                accStaging.Placement_Agency_ID__c = mapProduct.get(product.Name).Collection_Agency_Placement__c;
            }
            
            if(settings.containsKey(product.Placement_Status__c)){
                accStaging.Placement_Main_Status__c = settings.get(product.Placement_Status__c).Parent_Status__c +' - ' +settings.get(product.Placement_Status__c).Status__c;
                accStaging.Placement_Sub_Status__c = settings.get(product.Placement_Status__c).Sub_Status__c;
            }
            if(product.Status_Changed_Date__c != null){
                accStaging.Status_Changed_Date__c = String.valueOf(product.Status_Changed_Date__c);
            }
            accStaging.Status_Changed_Date_Text__c = product.Status_Changed_Date_Text__c;
            
            /*else if(mapFilingDate.get(product.Name) != null){
                accStaging.Status_Changed_Date__c = mapFilingDate.get(product.Name);
            }*/
            if(String.isBlank(ERROR_MSG)){
                accStaging.Comment__c = 'SUCCESS';
            }
            if(String.isNotBlank(EXPECTED)){
                accStaging.Expected_Value__c = EXPECTED;
            }
            listAccStaging.add(accStaging);
            ERROR_MSG = '';
        }
        system.debug('listAccStaging: '+listAccStaging);
        return listAccStaging;
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