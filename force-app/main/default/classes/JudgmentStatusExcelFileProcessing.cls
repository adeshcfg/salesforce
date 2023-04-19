/**************************************************************************************************
*
*  Class:   
*
*  @description : Class to create Product having Judgment Staging records and check ProductPayment validtaions
*  @author : A5E Consulting
*  @date : 08/03/2022
/**************************************************************************************************/

public class JudgmentStatusExcelFileProcessing {
    public ID documentId; 
    String exceptionMessage;
    String workAssignmentPlacement;
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    List<judgmentRecordsWrapper> listJudgmentRecordWrapper = new List<judgmentRecordsWrapper>();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
    
    public JudgmentStatusExcelFileProcessing(String data, String workAssignmentPlacement, ID documentId){
        exceptionMessage = '';
        system.debug('String Data::'+data);
        system.debug('class called');
        listJudgmentRecordWrapper = deSerializeJSON(data);
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.documentId = documentId;
        processExcelFileRecords();
    }
    
    
    public void processExcelFileRecords(){
        list<Document_Storage__c> listDocuments = [Select ID, Creator__c, Work_Assignment__c, Uploaded_By__c 
                                                        FROM Document_Storage__c 
                                                        WHERE ID= :documentID];
        
        try{
        List<Judgment__c> listJudgmentToUpdate = new List<Judgment__c>();
        List<Product__c> listProductToUpdate = new List<Product__c>();

        List<String> accountNumberList = new List<String>();
        for(judgmentRecordsWrapper wrapRecord : listJudgmentRecordWrapper){
            wrapRecord.data_id = wrapRecord.data_id.toUppercase();
            accountNumberList.add(wrapRecord.data_id);
        }
        
        map<ID,Product__C> mapProduct = new map<ID,Product__C>();
        system.debug('PlacementID:::'+workAssignmentPlacement);
        system.debug('accountNumberList:: '+accountNumberList);
        //Fetch canaccede and fidem accounts
        List<Product__C> listAccount = [select id, name, Data_Id__c, Collection_Agency__c,Product_Status__c,
                                        Placement_Status__c 
                                        from Product__C 
                                        where name in :accountNumberList];
        for(Product__C prodList : listAccount){
            
            mapProduct.put(prodList.id, prodList);
           
        }
        
        List<String> countyNames = new List<String>();
        map<String, Court__C> mapCourtID = new map<String, Court__C>();
        set<ID> courtId = new set<ID>();
        set<ID> legalActionID = new set<ID>();
        set<ID> legalID = new set <ID>();
        for(judgmentRecordsWrapper wrapRecord1 : listJudgmentRecordWrapper){
            countyNames.add(wrapRecord1.judgment_county);
            
        }
        
        List<Court__C> listCourt = [select id, name   
                                        from Court__C 
                                        where name in :countyNames];
        for(Court__c listCourt1 : listCourt){
            mapCourtID.put(listCourt1.name, listCourt1);
        }
        
        List<String> placementNames = new List<String>();
        map<String, ID> mapPalcementID = new map<String, ID>();
        
        for(judgmentRecordsWrapper wrapRecord2 : listJudgmentRecordWrapper){
            placementNames.add(wrapRecord2.place_id);
            
        }
        
        List<Placement__c> listPlaceId = [select id, name   
                                        from Placement__c 
                                        where name in :placementNames];
        for(Placement__c listPlace : listPlaceId){
            mapPalcementID.put(listPlace.name, listPlace.Id);
            legalID.add(listPlace.Id);
        }
        
        List<String> placementAgencyNames = new List<String>();
        map<String, ID> mapPalcementAgencyID = new map<String, ID>();
        
        for(judgmentRecordsWrapper wrapRecord3 : listJudgmentRecordWrapper){
            placementAgencyNames.add(wrapRecord3.judgment_place_id);
        }
        
        List<Placement__c> listPlaceAgency = [select id, name   
                                        from Placement__c 
                                        where name in :placementAgencyNames];
        for(Placement__c listPlaceAgency1 : listPlaceAgency){
            mapPalcementAgencyID.put(listPlaceAgency1.name, listPlaceAgency1.Id);
            legalActionID.add(listPlaceAgency1.Id);
        }

        system.debug('countyNames:: '+countyNames);
        system.debug('mapCourtID:: '+mapCourtID);
        //Fetch canaccede and fidem accounts
        List<Account_Judgment__c> listAccountJudgment = [select id, name,Product__c,Judgment__c, Judgment__r.County__c, Judgment__r.Legal_Agency__c, Judgment__r.Agency_Initiated_Legal_Action__c,
                                                         Product__r.Data_Id__c,Product__r.Name,Product__r.Last_Name__c,Product__r.First_Name__c,Product__r.Placement_Status__c,
                                                         Product__r.Product_Status__c,Judgment__r.Suit_Amount__c,Judgment__r.Case_Number__c,Judgment__r.Filing_Date__c,Judgment__r.Judgment_Province__c,Judgment__r.Court__c,
                                                         Judgment__r.Legal_Firm__c,Judgment__r.Judgment_Date__c,Judgment__r.Judgment_Amount__c,Judgment__r.Date_Writ_Issued__c,
                                                         Judgment__r.Writ_Amount__c,Judgment__r.Garnishment_Date__c,Judgment__r.Garnishment_Amount__c
                                                         from Account_Judgment__c 
                                        where Product__c in : mapProduct.keySet()];
        system.debug('listAccountJudgment:: '+listAccountJudgment);
        //system.debug('Data_Id__c:: '+listAccountJudgment[0].Product__r.Name);
        //map of account number to the Salesforce record ID
        Map<String, Account_Judgment__c> mapAccountNumberID = new Map<String, Account_Judgment__c>();
        set<ID> setProdutID = new set<ID>();
        set<ID> setJudgmentID = new set<ID>();
        
        for(Account_Judgment__c judgmentRecord : listAccountJudgment ){
            mapAccountNumberID.put(judgmentRecord.Product__r.Name, judgmentRecord);
            setProdutID.add(judgmentRecord.Product__c);
            setJudgmentID.add(judgmentRecord.Judgment__c);
        }
        system.debug('ProductId:: '+setProdutID);
        System.debug('mapAccountNumberID:: '+mapAccountNumberID);
        map<String,Product__c> mapProd = new  map<String,Product__c>();
        map<String, Judgment__c> mapJudg = new map<String, Judgment__c>();
        map<String,String> mapFilingDate = new map<String,String>();
        map<String,String> mapJudgmentDate = new map<String,String>();
        map<String,String> mapWritDate = new map<String,String>();
        map<String,String> mapGarnishmentDate = new map<String,String>();
        List<Product__c> listProduct = new List<Product__c>();
            
        for(judgmentRecordsWrapper wrapRecord : listJudgmentRecordWrapper){
            Account_Judgment__c AccJudgment = new Account_Judgment__c();
            Product__c prod = new Product__c();
            Judgment__c judg = new Judgment__c();
            
            prod.Name = wrapRecord.data_id;
            prod.Last_Name__c = wrapRecord.pri_last;
            prod.First_Name__c = wrapRecord.pri_first;
            prod.Placement_Status__c = wrapRecord.placedetail_status;
            prod.Product_Status__c = wrapRecord.data_status;            
            mapProd.put(prod.Name, prod);
            listProduct.add(prod);
            
            system.debug('Prod1:: '+mapProd);
            
            judg.Case_Number__c = wrapRecord.judgment_case;
            judg.County_Identifier__c = wrapRecord.judgment_county;
            if(String.isNotBlank(wrapRecord.judgment_suit_amount)){
                judg.Suit_Amount__c = Decimal.valueOf(wrapRecord.judgment_suit_amount);
            }
            /*if(String.isNotBlank(wrapRecord.judgment_filed)){
                try{
                        judg.Filing_Date__c = Date.valueOf(wrapRecord.judgment_filed);
                   
                }
                catch(exception e){
                    mapFilingDate.put(prod.Name, wrapRecord.judgment_filed);
                }
            }*/
            if(String.isNotBlank(wrapRecord.judgment_filed)){
                wrapRecord.judgment_filed = wrapRecord.judgment_filed.trim();
                if(wrapRecord.judgment_filed.contains('-')){
                    wrapRecord.judgment_filed= wrapRecord.judgment_filed.replace('-','/');
                }
                if(wrapRecord.judgment_filed.contains('T')){
                    wrapRecord.judgment_filed = wrapRecord.judgment_filed.SubstringBefore('T');
                }
                try{
                    judg.Filing_Date_Text__c = wrapRecord.judgment_filed; //String.valueOf(wrapRecord.status_date);
                    System.debug('Block Run ' + judg.Filing_Date_Text__c);
                }
                catch(exception e){
                    mapFilingDate.put(prod.Name, wrapRecord.judgment_filed);
                }    
            }
            //system.debug('Filing date:: '+judg.Filing_Date__c);
            /*if(String.isNotBlank(wrapRecord.judgment_date)){
                try{
                    judg.Judgment_Date__c = Date.valueOf(wrapRecord.judgment_date);    
                }
                catch(exception e){
                    mapJudgmentDate.put(prod.Name, wrapRecord.judgment_date);
                }
            }*/
            if(String.isNotBlank(wrapRecord.judgment_date)){
                wrapRecord.judgment_date = wrapRecord.judgment_date.trim();
                if(wrapRecord.judgment_date.contains('-')){
                    wrapRecord.judgment_date= wrapRecord.judgment_date.replace('-','/');
                }
                if(wrapRecord.judgment_date.contains('T')){
                    wrapRecord.judgment_date = wrapRecord.judgment_date.SubstringBefore('T');
                }
                try{
                    judg.Judgment_Date_Text__c = wrapRecord.judgment_date; //String.valueOf(wrapRecord.status_date);
                    System.debug('Block Run ' + judg.Judgment_Date_Text__c);
                }
                catch(exception e){
                    mapJudgmentDate.put(prod.Name, wrapRecord.judgment_date);
                }    
            }
            judg.Judgment_Province__c = wrapRecord.judgment_state;
            if(wrapRecord.judgment_county != null && mapCourtID.containsKey(wrapRecord.judgment_county)){
                judg.County__c = mapCourtID.get(wrapRecord.judgment_county).id;
            }
            system.debug('judg.County__c:: '+judg.County__c);
            judg.Court__c = wrapRecord.judgment_court;
            judg.Legal_Firm__c = wrapRecord.judgment_firm;
            /*if(String.isNotBlank(wrapRecord.judgment_writ)){
                try{
                    judg.Date_Writ_Issued__c = Date.valueOf(wrapRecord.judgment_writ);
                }
                catch(exception e){
                    mapWritDate.put(prod.Name, wrapRecord.judgment_writ);
                }
            }*/
            if(String.isNotBlank(wrapRecord.judgment_writ)){
                wrapRecord.judgment_writ = wrapRecord.judgment_writ.trim();
                if(wrapRecord.judgment_writ.contains('-')){
                    wrapRecord.judgment_writ= wrapRecord.judgment_writ.replace('-','/');
                }
                if(wrapRecord.judgment_writ.contains('T')){
                    wrapRecord.judgment_writ = wrapRecord.judgment_writ.SubstringBefore('T');
                }
                try{
                    judg.Date_Writ_Issued_Text__c = wrapRecord.judgment_writ; //String.valueOf(wrapRecord.status_date);
                    System.debug('Block Run ' + judg.Date_Writ_Issued_Text__c);
                }
                catch(exception e){
                    mapWritDate.put(prod.Name, wrapRecord.judgment_writ);
                }    
            }
            /*if(String.isNotBlank(wrapRecord.judgment_date)){
                judg.Judgment_Date__c = Date.valueOf(wrapRecord.judgment_date);    
            }*/
            if(String.isNotBlank(wrapRecord.judgment_amount)){
                judg.Judgment_Amount__c = Decimal.valueOf(wrapRecord.judgment_amount);
            }
            if(String.isNotBlank(wrapRecord.judgment_writ_amount)){
                judg.Writ_Amount__c = Decimal.valueOf(wrapRecord.judgment_writ_amount);
            }
            /*if(String.isNotBlank(wrapRecord.judgment_garnishment)){
                try{
                    judg.Garnishment_Date__c = Date.valueOf(wrapRecord.judgment_garnishment);    
                }
                catch(exception e){
                     mapGarnishmentDate.put(prod.Name, wrapRecord.judgment_garnishment);
                }
            }*/
            if(String.isNotBlank(wrapRecord.judgment_garnishment)){
                wrapRecord.judgment_garnishment = wrapRecord.judgment_garnishment.trim();
                if(wrapRecord.judgment_garnishment.contains('-')){
                    wrapRecord.judgment_garnishment= wrapRecord.judgment_garnishment.replace('-','/');
                }
                if(wrapRecord.judgment_garnishment.contains('T')){
                    wrapRecord.judgment_garnishment = wrapRecord.judgment_garnishment.SubstringBefore('T');
                }
                try{
                    judg.Garnishment_Date_Text__c = wrapRecord.judgment_garnishment; //String.valueOf(wrapRecord.status_date);
                    System.debug('Block Run ' + judg.Garnishment_Date_Text__c);
                }
                catch(exception e){
                    mapGarnishmentDate.put(prod.Name, wrapRecord.judgment_garnishment);
                }    
            }
            if(String.isNotBlank(wrapRecord.judgment_garnishment_amount)){
                judg.Garnishment_Amount__c = Decimal.valueOf(wrapRecord.judgment_garnishment_amount);
            }
            judg.Legal_Agency__c = wrapRecord.place_id;
            judg.Agency_Initiated_Legal_Action__c = wrapRecord.judgment_place_id;
           
            if(String.isNotBlank(wrapRecord.judgment_intrate)){
                judg.Interest_Rate_one__c = Decimal.valueOf(wrapRecord.judgment_intrate);
            }
            
            mapJudg.put(prod.Name, judg);
    
            system.debug('Judg1:: '+mapJudg);
           
        }

        list<Judgment_Staging__c> listJudgmentStaging = validationOnRecordUpdate(mapProd, mapJudg, 
                                                          mapProduct, mapCourtID, documentId, workAssignmentPlacement, mapFilingDate, mapJudgmentDate, mapWritDate,
                                                          mapGarnishmentDate,listDocuments[0],listProduct);
        Database.SaveResult[] sr = database.insert(listJudgmentStaging);
       } 
        catch(Exception ex){
            system.debug('exceptionMessage::'+exceptionMessage);
            exceptionMessage = String.valueOf(ex);
        }

        
        
        
        system.debug('listDocuments:: '+listDocuments);
        //Send email of File processing completion
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        if(!listDocuments.isEmpty() && listDocuments[0].Uploaded_By__c == 'External User' && String.isnotblank(listDocuments[0].Creator__c)){
            message.toAddresses = new String[] {listDocuments[0].Creator__c};  
        }
        else{
            message.setTargetObjectId(UserInfo.getUserId());    
        }        message.setSaveAsActivity(false);
        message.optOutPolicy = 'FILTER';
        message.subject = 'Account Judgment Upload Status';
        String processingLink = '';
        String processingStatus = '';
        
        if(String.isBlank(exceptionMessage)){
            message.plainTextBody = 
            'Please click the link below to review Account Judgment records: \n'+URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayJudgmentStaging?id='+documentId;            
            processingLink = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayJudgmentStaging?id='+documentId;
            processingStatus = 'Staging Table Created';
        }
        else{
            message.plainTextBody = 'Payment Processing failed! \nReason: ' +exceptionMessage + '\n\n'+
            'Please click the link below to view page :\n'+
            URL.getSalesforceBaseUrl().toExternalForm()+'/apex/DisplayJudgmentStaging?id='+documentId;
            processingStatus = 'Staging Table Creation Failed';
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
        
        //Update file processing link on DOcument
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(ID = listDocuments[0].ID,
                                                          File_Processing_Link__c = processingLink,
                                                          File_Processing_Date__c = Date.today(),
                                                          File_Processing_Status__c = processingStatus,
                                                          File_processing_Error__c = exceptionMessage
                                                         );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        
    }
    
    
    public List<judgmentRecordsWrapper> deSerializeJSON(String dataAsString){
        List<judgmentRecordsWrapper>  listJudgmentRecordWrapper = (List<judgmentRecordsWrapper>)JSON.deserialize(dataAsString, List<judgmentRecordsWrapper>.class);
        return listJudgmentRecordWrapper;
    }
    
    
    //Validation method to be called  before update
    public static list<Judgment_Staging__c> validationOnRecordUpdate(map<String,Product__c> prodNew, map<String,Judgment__c> judgNew,
                                                map<ID,Product__c> mapProduct1, map<String,Court__c> mapCourtID, ID documentId, String workAssignmentPlacement,
                                                map<String,String> mapFilingDate, map<String,String> mapJudgmentDate, map<String,String> mapWritDate, map<String,String> mapGarnishmentDate,
                                                Document_Storage__c docStorage,List<Product__c> listProduct                     
                                                ){
        Map<String,Product__c> mapProduct = new Map<String,Product__c>();
        set<String> setProdutID1 = new set<String>();
        map<String, String> mapProductActiveJudgment = new map<String, String>();
       system.debug('listProduct**'+listProduct);
        //Tax rate mapping by Province Acronym
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }                                            
        for(Product__c prod : [Select ID,Name, Product_Status__c,Placement_Status__c,Data_Status_Description__c,State__c
                               From Product__c
                               Where id in: mapProduct1.keySet()]){
           mapProduct.put(prod.Name, prod);
           setProdutID1.add(prod.id);
        }
        system.debug('setProdutID1***'+setProdutID1);
        List<Account_Judgment__c> listAccountJudgment = [select id, name,Product__c,Judgment__c,Product__r.Data_Id__c,Judgment__r.id,Product__r.Name
                                          from Account_Judgment__c 
                                          where Product__c in : setProdutID1 AND Status__c = 'Active'];
        system.debug('listAccountJudgment***'+listAccountJudgment);                                            
        for(Account_Judgment__c accJud: listAccountJudgment){
              mapProductActiveJudgment.put(accJud.Product__r.Name,accJud.Product__c);                                          
        }
        system.debug('mapProductActiveJudgment***'+mapProductActiveJudgment);                                                                                       
        map<String, Decimal> mapProductNameAmount = new map<String, Decimal>();     
        for(Product__c prodPayment:listProduct){
            if(mapProductNameAmount.containsKey(String.valueOf(prodPayment.Name))){
                mapProductNameAmount.put(String.valueOf(prodPayment.Name), 
                                        mapProductNameAmount.get(prodPayment.Name)+1);
            }
            else{
                mapProductNameAmount.put(String.valueOf(prodPayment.Name), 1);
            }
        }                                        
        system.debug('mapProduct:: '+mapProduct);
        system.debug('mapProductNameAmount***:: '+mapProductNameAmount);                             
        list<Judgment_Staging__c> listJudgmentStaging = new list<Judgment_Staging__c>();
        Judgment_Staging__c judgStaging = new Judgment_Staging__c();
        for(Product__c prodRecord : prodNew.values()){
            Boolean error = false;
            String ERROR_MSG = '';
            String EXPECTED = '';
            
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
            //Filing Date
            if(String.isNotBlank(judgNew.get(prodRecord.Name).Filing_Date_Text__c)){
                MyMatcher1 = MyPattern1.matcher(judgNew.get(prodRecord.Name).Filing_Date_Text__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(judgNew.get(prodRecord.Name).Filing_Date_Text__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(judgNew.get(prodRecord.Name).Filing_Date_Text__c);
                system.debug('MyMatcher3.matches()::'+MyMatcher3.matches());
                
                system.debug('MyMatcher1:: '+MyMatcher1);
                system.debug('MyMatcher1.matches()::'+MyMatcher1.matches());
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                system.debug('judgNew.get(prodRecord.Name).Filing_Date_Text__c::'+judgNew.get(prodRecord.Name).Filing_Date_Text__c);
                //matching of date when entered in Text format in excel file
                if(MyMatcher1.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Filing_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Filing_Date__c = myDate;
                    system.debug('judgNew.get(prodRecord.Name).Filing_Date__c external '+judgNew.get(prodRecord.Name).Filing_Date__c);
                }
                //matching of date when entered in Date format in excel file  judgNew.get(prodRecord.Name).Filing_Date__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Filing_Date_Text__c.split('/');
                    system.debug('datelist2 ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Filing_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Filing_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Filing_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Filing_Date__c external '+judgNew.get(prodRecord.Name).Filing_Date__c);
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Filing_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Filing_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Filing_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Filing_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Filing_Date__c external '+judgNew.get(prodRecord.Name).Filing_Date__c);
                }
            }
            //Judgment Date Validation
            if(String.isNotBlank(judgNew.get(prodRecord.Name).Judgment_Date_Text__c)){
                MyMatcher1 = MyPattern1.matcher(judgNew.get(prodRecord.Name).Judgment_Date_Text__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(judgNew.get(prodRecord.Name).Judgment_Date_Text__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(judgNew.get(prodRecord.Name).Judgment_Date_Text__c);
                system.debug('MyMatcher3.matches()::'+MyMatcher3.matches());
                
                system.debug('MyMatcher1:: '+MyMatcher1);
                system.debug('MyMatcher1.matches()::'+MyMatcher1.matches());
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                system.debug('judgNew.get(prodRecord.Name).Judgment_Date_Text__c::'+judgNew.get(prodRecord.Name).Judgment_Date_Text__c);
                //matching of date when entered in Text format in excel file
                if(MyMatcher1.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Judgment_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Judgment_Date__c = myDate;
                    system.debug('judgNew.get(prodRecord.Name).Judgment_Date__c external '+judgNew.get(prodRecord.Name).Judgment_Date__c);
                }
                //matching of date when entered in Date format in excel file  judgNew.get(prodRecord.Name).Judgment_Date__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Judgment_Date_Text__c.split('/');
                    system.debug('datelist2 ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Judgment_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Judgment_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Judgment_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Judgment_Date__c external '+judgNew.get(prodRecord.Name).Judgment_Date__c);
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Judgment_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Judgment_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Judgment_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Judgment_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Judgment_Date__c external '+judgNew.get(prodRecord.Name).Judgment_Date__c);
                }
            }
            //Writ Date
            if(String.isNotBlank(judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c)){
                MyMatcher1 = MyPattern1.matcher(judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);
                system.debug('MyMatcher3.matches()::'+MyMatcher3.matches());
                
                system.debug('MyMatcher1:: '+MyMatcher1);
                system.debug('MyMatcher1.matches()::'+MyMatcher1.matches());
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                system.debug('judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c::'+judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);
                //matching of date when entered in Text format in excel file
                if(MyMatcher1.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Date_Writ_Issued__c = myDate;
                    system.debug('judgNew.get(prodRecord.Name).Date_Writ_Issued__c external '+judgNew.get(prodRecord.Name).Date_Writ_Issued__c);
                }
                //matching of date when entered in Date format in excel file  judgNew.get(prodRecord.Name).Date_Writ_Issued__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c.split('/');
                    system.debug('datelist2 ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Date_Writ_Issued__c = myDate;
                    judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Date_Writ_Issued__c external '+judgNew.get(prodRecord.Name).Date_Writ_Issued__c);
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Date_Writ_Issued__c = myDate;
                    judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Date_Writ_Issued__c external '+judgNew.get(prodRecord.Name).Date_Writ_Issued__c);
                }
            }
            //Garnishment Date
            if(String.isNotBlank(judgNew.get(prodRecord.Name).Garnishment_Date_Text__c)){
                MyMatcher1 = MyPattern1.matcher(judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);  
                Matcher MyMatcher2 = MyPattern2.matcher(judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);  
                Matcher MyMatcher3 = MyPattern3.matcher(judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);
                system.debug('MyMatcher3.matches()::'+MyMatcher3.matches());
                
                system.debug('MyMatcher1:: '+MyMatcher1);
                system.debug('MyMatcher1.matches()::'+MyMatcher1.matches());
                //Invalid Payment date (pmt date must exist, be formatted correctly and cannot be in the future)
                system.debug('judgNew.get(prodRecord.Name).Garnishment_Date_Text__c::'+judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);
                //matching of date when entered in Text format in excel file
                if(MyMatcher1.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Garnishment_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Garnishment_Date__c = myDate;
                    system.debug('judgNew.get(prodRecord.Name).Garnishment_Date__c external '+judgNew.get(prodRecord.Name).Garnishment_Date__c);
                }
                //matching of date when entered in Date format in excel file  judgNew.get(prodRecord.Name).Garnishment_Date__c 
                else if(MyMatcher2.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Garnishment_Date_Text__c.split('/');
                    system.debug('datelist2 ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Garnishment_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Garnishment_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Garnishment_Date__c external '+judgNew.get(prodRecord.Name).Garnishment_Date__c);
                }
                else if(MyMatcher3.matches() == true){
                    list<String> datelist = judgNew.get(prodRecord.Name).Garnishment_Date_Text__c.split('/');
                    system.debug('datelist ::'+datelist);
                    date myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                    system.debug('myDate::'+myDate);
                    judgNew.get(prodRecord.Name).Garnishment_Date__c = myDate;
                    judgNew.get(prodRecord.Name).Garnishment_Date_Text__c = String.valueOf(datelist[1] )+'/'+ String.valueOf(datelist[2]) + '/'+ String.valueOf(datelist[0]);
                    system.debug('Payment_Posting_Date_Text__c::::'+judgNew.get(prodRecord.Name).Garnishment_Date_Text__c);
                    system.debug('judgNew.get(prodRecord.Name).Garnishment_Date__c external '+judgNew.get(prodRecord.Name).Garnishment_Date__c);
                }
            }
            if(!mapProduct.containsKey(prodRecord.Name)){
                system.debug('BLOCK RUN INVALID DATA ID');
                ERROR_MSG = '<b>ERROR</b> - Invalid Data Id<br/>';
            }
            system.debug('prodRecord.Name'+prodRecord.Name);
            system.debug('prodNew.id'+prodNew.get(prodRecord.Name));
            //system.debug('prodNew.id'+(prodRecord.Name).id);
            system.debug('product id***'+mapProductActiveJudgment.get(prodRecord.Name));
            system.debug('product id'+mapProductActiveJudgment.get(prodRecord.id));
            if(!mapProductActiveJudgment.containsKey(prodRecord.Name)){
                ERROR_MSG = '<b>ERROR</b> - Product not have active Judgment.<br/>';
            }
            String valError = '';
            //validation on Judgment status
             if((prodNew.get(prodRecord.Name).Placement_Status__c == '220000' || prodNew.get(prodRecord.Name).Placement_Status__c == '220210' 
                 || prodNew.get(prodRecord.Name).Placement_Status__c =='220700' || prodNew.get(prodRecord.Name).Placement_Status__c =='220030'
                 || prodNew.get(prodRecord.Name).Placement_Status__c =='220040' || prodNew.get(prodRecord.Name).Placement_Status__c =='220050'
                 || prodNew.get(prodRecord.Name).Placement_Status__c == '220020' || prodNew.get(prodRecord.Name).Placement_Status__c == '220220' 
                 || prodNew.get(prodRecord.Name).Placement_Status__c == '220900' || prodNew.get(prodRecord.Name).Placement_Status__c == '290400'
                 || prodNew.get(prodRecord.Name).Placement_Status__c == '299100' || prodNew.get(prodRecord.Name).Placement_Status__c == '299999' 
                 || prodNew.get(prodRecord.Name).Placement_Status__c == '290020')){
                     if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                         valError += 'Case Number'+ ',';
                     }
                     if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                         valError += 'Province'+ ',';
                     }
                     if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                         valError += 'Suit Amount'+ ',';
                     }
                     if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                         valError += 'interest Rate-1'+ ',';
                     }
                     if(String.isBlank(judgNew.get(prodRecord.Name).court__c)){
                         valError += 'Court'+ ',';
                     }
                     if(String.isBlank(judgNew.get(prodRecord.Name).County__c)){
                         valError += 'County'+ ',';
                     }
                     if(String.isBlank(judgNew.get(prodRecord.Name).Legal_Firm__c)){
                         valError += 'Legal Firm'+ ',';
                     }
                     if(String.isBlank(judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__c)){
                         valError += 'Agency Initiated Legal Action'+ ',';
                     }
                     valError = valError.removeEnd(',');
                     if(!string.isBlank(valError)){
                         ERROR_MSG += '<b>ERROR</b> Fields should not blank '+valError+'.<br/>';
                         EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';
                     }
                 
            }
            String val1Error = '';
            if((prodNew.get(prodRecord.Name).Placement_Status__c == '290000' || prodNew.get(prodRecord.Name).Placement_Status__c == '290010' 
                || prodNew.get(prodRecord.Name).Placement_Status__c == '290700' || prodNew.get(prodRecord.Name).Placement_Status__c == '291000'
                || prodNew.get(prodRecord.Name).Placement_Status__c == '290030' || prodNew.get(prodRecord.Name).Placement_Status__c == '290040' 
                || prodNew.get(prodRecord.Name).Placement_Status__c == '290050' || prodNew.get(prodRecord.Name).Placement_Status__c == '293010'
                || prodNew.get(prodRecord.Name).Placement_Status__c == '293030' || prodNew.get(prodRecord.Name).Placement_Status__c == '293040' 
                || prodNew.get(prodRecord.Name).Placement_Status__c == '293050' || prodNew.get(prodRecord.Name).Placement_Status__c == '295070'
                || prodNew.get(prodRecord.Name).Placement_Status__c == '295080' || prodNew.get(prodRecord.Name).Placement_Status__c == '295900')){
                    if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                       val1Error += 'Case Number'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                       val1Error += 'Province'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                       val1Error += 'Suit Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Filing_Date__c == NULL){
                       val1Error += 'judgment filing date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Date__c == NULL){
                       val1Error += 'judgment date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Amount__c == NULL){
                       val1Error += 'judgment amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                       val1Error += 'interest Rate-1'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Legal_Firm__c)){
                       val1Error += 'Legal Firm'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Court__c)){
                       val1Error += 'Court'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).County__c)){
                       val1Error += 'County'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__c)){
                       val1Error += 'Agency Initiated Legal Action'+ ','; 
                    }
                    val1Error = val1Error.removeEnd(',');
                    if(!string.isBlank(val1Error)){
                        ERROR_MSG += '<b>ERROR</b> Fields should not blank '+val1Error+'.<br/>';
                        EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';
                    }
                
            }
            String val2Error = '';
            if(prodNew.get(prodRecord.Name).Placement_Status__c == '290005'){
                    if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                       val2Error += 'Case Number'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                       val2Error += 'Province'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                       val2Error += 'Suit Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Filing_Date__c == NULL){
                       val2Error += 'judgment filing date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Date__c == NULL){
                       val2Error += 'judgment date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Amount__c == NULL){
                       val2Error += 'judgment amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                       val2Error += 'interest Rate-1'+ ','; 
                    }
                    val2Error = val2Error.removeEnd(',');
                    if(!string.isBlank(val2Error)){
                        ERROR_MSG += '<b>ERROR</b> Fields should not blank '+val2Error+'.<br/>';
                        EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';
                    }
            }
            String val3Error = '';
            if((prodNew.get(prodRecord.Name).Placement_Status__c == '293000' || prodNew.get(prodRecord.Name).Placement_Status__c == '294000')){
                    if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                       val3Error += 'Case Number'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                       val3Error += 'Province'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                       val3Error += 'Suit Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Filing_Date__c == NULL){
                       val3Error += 'judgment filing date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Date__c == NULL){
                       val3Error += 'judgment date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Amount__c == NULL){
                       val3Error += 'judgment amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                       val3Error += 'interest Rate-1'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Garnishment_Date__c == NULL){
                       val3Error += 'Date Garnishment Issued'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Garnishment_Amount__c == NULL){
                       val3Error += 'Garnishment Amount'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Legal_Firm__c)){
                       val3Error += 'Legal Firm'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Court__c)){
                       val3Error += 'Court'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).County__c)){
                       val3Error += 'County'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__c)){
                       val3Error += 'Agency Initiated Legal Action'+ ','; 
                    }
                    val3Error = val3Error.removeEnd(',');
                    if(!string.isBlank(val3Error)){
                        ERROR_MSG += '<b>ERROR</b> Fields should not blank '+val3Error+'.<br/>';
                        EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';
                    }
                
            }
            String val4Error = '';
            if((prodNew.get(prodRecord.Name).Placement_Status__c == '295000' || prodNew.get(prodRecord.Name).Placement_Status__c == '295030' 
                || prodNew.get(prodRecord.Name).Placement_Status__c == '295060' || prodNew.get(prodRecord.Name).Placement_Status__c == '295010'
                || prodNew.get(prodRecord.Name).Placement_Status__c == '295040' || prodNew.get(prodRecord.Name).Placement_Status__c == '295050')){
                    if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                       val4Error += 'Case Number'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                       val4Error += 'Province'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                       val4Error += 'Suit Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Writ_Amount__c == NULL){
                       val4Error += 'Writ Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Filing_Date__c == NULL){
                       val4Error += 'judgment filing date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Date__c == NULL){
                       val4Error += 'judgment date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Amount__c == NULL){
                       val4Error += 'judgment amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                       val4Error += 'interest Rate-1'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Legal_Firm__c)){
                       val4Error += 'Legal Firm'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Court__c)){
                       val4Error += 'Court'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).County__c)){
                       val4Error += 'County'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__c)){
                       val4Error += 'Agency Initiated Legal Action'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c == NULL){
                       val4Error += 'Date Writ Issued'+ ','; 
                    }
                    val4Error = val4Error.removeEnd(',');
                    if(!string.isBlank(val4Error)){
                        ERROR_MSG += '<b>ERROR</b> Fields should not blank '+val4Error+'.<br/>';
                        EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';
                    }
            }
            String val5Error = '';
            
            system.debug('Placement_status__c::'+prodNew.get(prodRecord.Name).Placement_Status__c);
            system.debug('Case_Number::'+judgNew.get(prodRecord.Name).Case_Number__c);
            if(prodNew.get(prodRecord.Name).Placement_Status__c == '295020'){
                    if(String.isBlank(judgNew.get(prodRecord.Name).Case_Number__c)){
                       val5Error += 'Case Number'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Judgment_Province__c)){
                       val5Error += 'Province'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Suit_Amount__c == NULL){
                       val5Error += 'Suit Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Interest_Rate_one__c == NULL){
                       val5Error += 'interest Rate-1'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Writ_Amount__c == NULL){
                       val5Error += 'Writ Amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Filing_Date__c == NULL){
                       val5Error += 'judgment filing date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Date__c == NULL){
                       val5Error += 'judgment date'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Judgment_Amount__c == NULL){
                       val5Error += 'judgment amount'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Garnishment_Date__c == NULL){
                       val5Error += 'Date Garnishment Issued'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Garnishment_Amount__c == NULL){
                       val5Error += 'Garnishment Amount'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Legal_Firm__c)){
                       val5Error += 'Legal Firm'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Court__c)){
                       val5Error += 'Court'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).County__c)){
                       val5Error += 'County'+ ','; 
                    }
                    if(String.isBlank(judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__c)){
                       val5Error += 'Agency Initiated Legal Action'+ ','; 
                    }
                    if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c == NULL){
                        val5Error += 'Date Writ Issued'+ ','; 
                    }
                    val5Error = val5Error.removeEnd(',');
                    if(!string.isBlank(val5Error)){
                        ERROR_MSG += '<b>ERROR</b> Fields should not blank '+val5Error+'.<br/>';
                        EXPECTED +='If Placement Status is'+prodNew.get(prodRecord.Name).Placement_Status__c+' then all error fields are reqiured <br/>';             
                    }
            }
            
            system.debug('Filing Date:: '+mapFilingDate.get(prodRecord.Name));
            
            //Invalid Filing date
            /*if(judgNew.get(prodRecord.Name).Filing_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Filing_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Filing Date.<br/>';
                    EXPECTED += 'Filing Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(judgNew.get(prodRecord.Name).Filing_Date__c == null){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Filing Date.<br/>';
                   EXPECTED += 'Filing Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }*/
            if(judgNew.get(prodRecord.Name).Filing_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Filing_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Filing date.<br/>';
                    EXPECTED += 'Filing Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isNotBlank(judgNew.get(prodRecord.Name).Filing_Date_Text__c)){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Filing date.<br/>';
                   EXPECTED += 'Filing Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                else{
                    ERROR_MSG += '<b>ERROR</b> - Enter valid Filing date.<br/>';
                    EXPECTED += 'Filing Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }
            //Invalid Judgment date
            /*if(judgNew.get(prodRecord.Name).Judgment_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Judgment_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Judgment Date.<br/>';
                    EXPECTED += 'Judgment Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(judgNew.get(prodRecord.Name).Judgment_Date__c == null){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Judgment Date.<br/>';
                   EXPECTED += 'Judgment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }*/
            if(judgNew.get(prodRecord.Name).Judgment_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Judgment_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Judgment date.<br/>';
                    EXPECTED += 'Judgment Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isNotBlank(judgNew.get(prodRecord.Name).Judgment_Date_Text__c)){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Judgment date.<br/>';
                   EXPECTED += 'Judgment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                else{
                    ERROR_MSG += '<b>ERROR</b> - Enter valid Judgment date.<br/>';
                    EXPECTED += 'Judgment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }
            //Writ date
            /*if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c != NULL){
                if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Writ date Date.<br/>';
                    EXPECTED += 'Writ date Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c == null){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Writ date Date.<br/>';
                   EXPECTED += 'Writ Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }*/
            if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c != NULL){
                if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Writ date.<br/>';
                    EXPECTED += 'Writ Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isNotBlank(judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c)){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Writ date.<br/>';
                   EXPECTED += 'Writ Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                else{
                    ERROR_MSG += '<b>ERROR</b> - Enter valid Writ date.<br/>';
                    EXPECTED += 'Writ Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }
            //Garnishment Date
            /*if(judgNew.get(prodRecord.Name).Garnishment_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Garnishment_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Garnishment Date.<br/>';
                    EXPECTED += 'Garnishment Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(judgNew.get(prodRecord.Name).Garnishment_Date__c == null){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Garnishment Date.<br/>';
                   EXPECTED += 'Garnishment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }*/
            if(judgNew.get(prodRecord.Name).Garnishment_Date__c != NULL){
                if(judgNew.get(prodRecord.Name).Garnishment_Date__c > Date.today()){
                    ERROR_MSG += '<b>ERROR</b> - Invalid Garnishment date.<br/>';
                    EXPECTED += 'Garnishment Date cannot be in future.<br/>'; 
                }  
            }
            else{
                if(String.isNotBlank(judgNew.get(prodRecord.Name).Garnishment_Date_Text__c)){
                   ERROR_MSG += '<b>ERROR</b> - Invalid Garnishment date.<br/>';
                   EXPECTED += 'Garnishment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
                else{
                    ERROR_MSG += '<b>ERROR</b> - Enter valid Garnishment date.<br/>';
                    EXPECTED += 'Garnishment Date should be proper format.(MM/DD/YYYY)<br/>';
                }
            }
            if(mapProductNameAmount.containsKey(prodRecord.Name)
            && mapProductNameAmount.get(prodRecord.Name) > 1){
                system.debug('inside warning');
                ERROR_MSG += '<b>ERROR</b> - A duplicate transaction was found in this File Update.<br/>';    
            }else{
                system.debug('outside warning');
            }
            //Account must not be closed mapProduct.containsKey(prodRecord.Name)
            if(mapProduct.containsKey(prodRecord.Name)
               && String.isnotblank(mapProduct.get(prodRecord.Name).Data_Status_Description__c)
               && mapProduct.get(prodRecord.Name).Data_Status_Description__c.startsWith('Closed')){
                   ERROR_MSG += '<b>ERROR</b> - Account is closed.<br/>';
               }
            //prodNew.get(prodRecord.Name).state__c
            
            
            
            judgStaging = new Judgment_Staging__c();
            system.debug('prodRecord: '+prodRecord);
            judgStaging.Data_Id__c = prodRecord.Name;
            judgStaging.Last_Name__c = prodRecord.Last_Name__c;
            judgStaging.First_Name__c = prodRecord.First_Name__c;
            judgStaging.Placement_Status__c = prodRecord.Placement_Status__c;
            judgStaging.Product_Status__c = prodRecord.Product_Status__c;
            judgStaging.Suit_Amount__c = judgNew.get(prodRecord.Name).Suit_Amount__c;
            judgStaging.Case_Number__c = judgNew.get(prodRecord.Name).Case_Number__c;
            if(judgNew.get(prodRecord.Name).Filing_Date__c != null){
                judgStaging.Filing_Date__c = String.valueOf(judgNew.get(prodRecord.Name).Filing_Date__c);
            }else if(mapFilingDate.get(prodRecord.Name) != null){
                judgStaging.Filing_Date__c = mapFilingDate.get(prodRecord.Name);
            }
            judgStaging.Filing_Date_Text__c = judgNew.get(prodRecord.Name).Filing_Date_Text__c;
            //judgStaging.Judgment_Province__c = judgNew.get(prodRecord.Name).Judgment_Province__c;
            system.debug('product proviance'+mapProduct.get(prodRecord.Name).state__c);
            if(mapProduct.get(prodRecord.Name).state__c != NULL){
                prodProvinceName = mapProduct.get(prodRecord.Name).state__c;
                ProvinceNameFormat = nameFormat(prodProvinceName);
                provinceAcronymFormat = prodProvinceName.toUpperCase();
                if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                    judgStaging.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c; 
                    system.debug('judgStaging.Judgment_Province__c::'+judgStaging.Judgment_Province__c);
                }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                    judgStaging.Judgment_Province__c = ProvinceNameFormat;  
                }
            }
            system.debug('judgStaging proviance'+judgStaging.Judgment_Province__c);
            judgStaging.County__c = judgNew.get(prodRecord.Name).County_Identifier__c;
            judgStaging.Type_of_Court__c = judgNew.get(prodRecord.Name).Court__c;
            judgStaging.Legal_Firm__c = judgNew.get(prodRecord.Name).Legal_Firm__c;
            if(judgNew.get(prodRecord.Name).Judgment_Date__c != null){
                judgStaging.Judgment_Date__c = String.valueOf(judgNew.get(prodRecord.Name).Judgment_Date__c);
            }else if(mapJudgmentDate.get(prodRecord.Name) != null){
                judgStaging.Judgment_Date__c = mapJudgmentDate.get(prodRecord.Name);
            }
            judgStaging.Judgment_Date_Text__c = judgNew.get(prodRecord.Name).Judgment_Date_Text__c;
            judgStaging.Judgment_Amount__c = judgNew.get(prodRecord.Name).Judgment_Amount__c;
            if(judgNew.get(prodRecord.Name).Date_Writ_Issued__c != null){
                judgStaging.Date_Writ_Issued__c = String.valueOf(judgNew.get(prodRecord.Name).Date_Writ_Issued__c);
            }else if(mapWritDate.get(prodRecord.Name) != null){
                judgStaging.Date_Writ_Issued__c = mapWritDate.get(prodRecord.Name);
            }
            judgStaging.Date_Writ_Issued_Text__c = judgNew.get(prodRecord.Name).Date_Writ_Issued_Text__c;
            judgStaging.Writ_Amount__c = judgNew.get(prodRecord.Name).Writ_Amount__c;
            if(judgNew.get(prodRecord.Name).Garnishment_Date__c != null){
                judgStaging.Garnishment_Date__c = String.valueOf(judgNew.get(prodRecord.Name).Garnishment_Date__c);
            }else if(mapGarnishmentDate.get(prodRecord.Name) != null){
                judgStaging.Garnishment_Date__c = mapGarnishmentDate.get(prodRecord.Name);
            }
            judgStaging.Garnishment_Date_Text__c = judgNew.get(prodRecord.Name).Garnishment_Date_Text__c;
            judgStaging.Garnishment_Amount__c = judgNew.get(prodRecord.Name).Garnishment_Amount__c;
            judgStaging.Legal_Agency__c = judgNew.get(prodRecord.Name).Legal_Agency__c;
            judgStaging.Agency_Initiated_Legal_Action__C = judgNew.get(prodRecord.Name).Agency_Initiated_Legal_Action__C;
            judgStaging.County_Identifier__c = judgNew.get(prodRecord.Name).County__c;
            judgStaging.Interest_Rate__c = String.valueOf(judgNew.get(prodRecord.Name).Interest_Rate_one__c);
            judgStaging.Balance__c = '0';
            judgStaging.Placement_Agency__c = workAssignmentPlacement;
            judgStaging.Comment__c = ERROR_MSG;
            if(String.isNotBlank(EXPECTED)){
                judgStaging.Expected_Value__c = EXPECTED;
            }
            if(String.isBlank(ERROR_MSG)){
                judgStaging.Comment__c = 'SUCCESS';
            }
            judgStaging.Status__C = 'Pending';
            judgStaging.Identifier__c = documentId;
            judgStaging.Document_Storage__c = documentId;
            judgStaging.Product_Id__c = mapProduct.get(prodRecord.Name).ID;
            listJudgmentStaging.add(judgStaging);
            ERROR_MSG = '';
            //EXPECTED = '';
        }
        system.debug('listJudgmentStaging: '+listJudgmentStaging);
        return listJudgmentStaging;
    }
    
    //Wrapper class for insolvency payment records
    public class judgmentRecordsWrapper{
        public String data_id{get;set;}
        public String pri_last{get;set;}
        public String pri_first{get;set;}
        public String pds_desc_full{get;set;}
        public String placedetail_status{get;set;}
        public String data_status{get;set;}
        public String judgment_suit_amount{get;set;}
        public String judgment_case{get;set;}
        public String judgment_filed{get;set;}
        public String judgment_state{get;set;}
        public String judgment_county{get;set;}
        public String judgment_court{get;set;}
        public String judgment_firm{get;set;}
        public String judgment_date{get;set;}
        public String judgment_amount{get;set;}
        public String judgment_writ{get;set;}
        public String judgment_writ_amount{get;set;}
        public String judgment_garnishment{get;set;}
        public String judgment_garnishment_amount{get;set;}
        public String place_id{get;set;}
        public String judgment_intrate{get;set;}
        public String judgment_place_id{get;set;}
        
    }
    
    //get Province Name
    public static String nameFormat (String name) {
        String result = '';
        if (name != null && name != '') {
            name = name.toLowercase();
            for (String iter : name.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1) {  
                        result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                    }
                    else {
                        result += iter.substring(0,1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
    
}