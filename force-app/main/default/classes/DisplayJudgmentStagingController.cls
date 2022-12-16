/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Judgment records from Staging and create success
*                  and failure files for Judgment
*  @author : A5E Consulting
*  @date : 14/02/2022

*************************************************************************************************/
public class DisplayJudgmentStagingController {

    public list<Judgment_Staging__c> listJudgmentStaging{get;set;}
    public list<judgmentStagingWrapper> listProductPayStagingWrapper {get;set;}
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    //map of Placement Code and Placement Status  
    public static map<String, Placement_Status_Code_Mapping__c> mapPlacementCodeStatus;    
    //map of Placement Status and Placement Code
    public static map<String, String> mapPlacementStatus;
    public boolean showButton {get;set;}
    public boolean displayPanel {get;set;}
    public Id workAssignmentId {get;set;}
    public boolean executeWarning {get;set;}
    String success;
    String failed;
    String placementAgency = '';
    Decimal successRecords;
    Decimal failedRecords;
    ID documentID;   
    
    public DisplayJudgmentStagingController(){
        showButton = false;
        displayPanel = false;
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');

    listJudgmentStaging = [SELECT ID,Agency_Initiated_Legal_Action__c, Case_Number__c, County__c,
                                        Data_Id__c, Date_Writ_Issued__c,Filing_Date__c,Document_Storage__r.File_Processing_Status__c,Document_Storage__r.Work_Assignment__c,
                                        First_Name__c, Garnishment_Amount__c, Garnishment_Date__c, Judgment_Amount__c, Judgment_Date__c,
                                        Last_Name__c, Legal_Agency__c, Legal_Firm__c, Placement_Status__c, Product_Status__c, Suit_Amount__c,
                                        Type_of_Court__c,Writ_Amount__c,Comment__c,Judgment_Province__c,Status__c,County_Identifier__c,Interest_Rate__c,Placement_Agency__c,
                                        Expected_Value__c,Document_Storage__r.Work_Assignment_Identifier__c,Product_Id__c,Balance__c,Date_Writ_Issued_Text__c,Filing_Date_Text__c,
                                        Garnishment_Date_Text__c,Judgment_Date_Text__c
                                 FROM Judgment_Staging__c WHERE Identifier__c = :recordIdentfier];
        
        system.debug('listJudgmentStaging:::@#$ '+listJudgmentStaging);
        if(listJudgmentStaging.isEmpty()){
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Account_judgment to display'));
        }
        else{
            listProductPayStagingWrapper = new list<judgmentStagingWrapper>();
            for(Judgment_Staging__c payStaging : listJudgmentStaging){
            system.debug('Inter in for');
                Boolean disabled = false;
                system.debug('payStaging.Document_Storage__r.File_Processing_Status__c'+payStaging.Document_Storage__r.File_Processing_Status__c);
                if(payStaging.Comment__c.contains(ERROR) || (payStaging.Status__c == PROCESSED && payStaging.Comment__c == 'SUCCESS')){
                    disabled = true;
                }
                listProductPayStagingWrapper.add(new judgmentStagingWrapper(payStaging, disabled));
                if(payStaging.Status__c != PROCESSED && !payStaging.Comment__c.contains(ERROR)){
                    showButton = true;
                }
            }
             //showButton = true;
            placementAgency = listJudgmentStaging[0].Placement_Agency__c;
            documentID = listJudgmentStaging[0].Document_Storage__c;
            if(showButton == false){
            if(listJudgmentStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){
                showButton = false;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
            }
            else{
                showButton = true;
            }
           }
        }
    }
    
    public pageReference Save(){
        getPlacementStatusCodes();
        list<Product__c> listProd = new list<Product__c>();
        list<Judgment__c> listJudgment = new list<Judgment__c>();
        Map<id,Judgment__c> MapJudgmentData = new Map<id,Judgment__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        set<String> setProdutNames = new set<String>();
        Map<String, ID> mapAccountNumberID = new Map<String, String>();
        Map<String, ID> mapJudgmentNumberID = new map<String, ID>();
        
        //Create Success and Failure file headers
        success = 'data_id,pri_first,pri_last,placedetail_status,data_status,judgment_suit_amount,judgment_case,judgment_filed,judgment_state,judgment_county,judgment_court,judgment_firm,judgment_date,judgment_amount,judgment_writ,judgment_writ_amount,judgment_garnishment,judgment_garnishment_amount,place_id,judgment_place_id,judgment_intrate';
        failed = 'data_id,pri_first,pri_last,placedetail_status,data_status,judgment_suit_amount,judgment_case,judgment_filed,judgment_state,judgment_county,judgment_court,judgment_firm,judgment_date,judgment_amount,judgment_writ,judgment_writ_amount,judgment_garnishment,judgment_garnishment_amount,place_id,judgment_place_id,judgment_intrate,error';
        //String placementAgency = '';
        
        set<ID> setProdutID1 = new set<ID>();
        Id product;
       for(Judgment_Staging__c judgStaging : listJudgmentStaging){
            setProdutNames.add(judgStaging.Data_Id__c);
           // placementAgency = judgStaging.Placement_Agency__c;            
        }
        List<Product__C> listAccount2 = [select id, name, DebtNext_Data_ID__C, Collection_Agency__c    
                                        from Product__C 
                                        where name in :setProdutNames];
        for(Product__C prodList : listAccount2){
            
            setProdutID1.add(prodList.id);
            product = prodList.id;
        }
        system.debug('setProdutID1:: '+setProdutID1);
        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        
        successRecords = 0;
        failedRecords = 0;
        
        List<Account_Judgment__c> listAccountJudgment = [select id, name,Product__c,Judgment__c,Product__r.Data_Id__c,Judgment__r.id,Product__r.Name
                                                         from Account_Judgment__c 
                                        where Product__c in : setProdutID1 AND Status__c = 'Active'];
        system.debug('listAccountJudgment@$@@$:: '+listAccountJudgment);
        Map<String, ID> mapAccountJudgmentNumberID = new Map<String, ID>();
        set<ID> setJudgmentID = new set<ID>();
        for(Account_Judgment__c judgmentRecord : listAccountJudgment ){
            mapAccountJudgmentNumberID.put(judgmentRecord.Product__r.Name, judgmentRecord.Judgment__r.id);
             setJudgmentID.add(judgmentRecord.Judgment__c);
        }
       system.debug('mapAccountJudgmentNumberID:: '+mapAccountJudgmentNumberID);
        system.debug('setJudgmentID::'+setJudgmentID);
        map<ID, Judgment__c> mapJudgment = new map<ID, Judgment__c>();
        List<Judgment__c> listJudg = [Select ID,Name,Suit_Amount__c,Case_Number__c, Filing_Date__c, Judgment_Province__c, County__c, Court__c, Legal_Firm__c,
                                Judgment_Date__c, Judgment_Amount__c, Date_Writ_Issued__c, Writ_Amount__c, Garnishment_Date__c, Garnishment_Amount__c,
                                Legal_Agency__c, Agency_Initiated_Legal_Action__c,Product_1__c,Product_2__c,Product_3__c,Product_4__c,Product_5__c
                               From Judgment__c 
                               Where id in: setJudgmentID];
        system.debug('listJudg@#@@# '+listJudg);
        List<Product__C> listAccount = [select id, name, Data_Id__c, Collection_Agency__c    
                                        from Product__C 
                                        where name in :setProdutNames];
        
        for(Product__C accountRecord : listAccount ){
            mapAccountNumberID.put(accountRecord.name, accountRecord.id);
        }
        
        for(Judgment__c listJudg1 : listJudg){
            mapJudgment.put(listJudg1.Id, listJudg1);
        }
        system.debug('mapJudgment::: '+mapJudgment);
        system.debug('mapAccountNumberID:: '+mapAccountNumberID);
        
       // Decimal successRecords = 0;
       // Decimal failedRecords = 0;
        for(judgmentStagingWrapper judgStagingWrapper : listProductPayStagingWrapper){
            Judgment_Staging__c judgStaging = judgStagingWrapper.payStaging;
            String comment = '';
            if(String.isNotBlank(judgStaging.Comment__c)){
                comment = judgStaging.Comment__c;
            }
              if(Test.isRunningTest()){
                judgStagingWrapper.selected = true;
            }
            system.debug('judgStaging.Status__c::'+judgStaging.Status__c);
            system.debug('judgStagingWrapper.selected::'+judgStagingWrapper.selected);
            if(judgStaging.Status__c != PROCESSED 
               && judgStagingWrapper.selected == true
           // && !comment.contains('ERROR')
           // && ((executeWarning == false && !comment.contains('WARNING') ) || executeWarning == true))
              ){
              system.debug('Inside for test');
                judgStaging.Status__c = PROCESSED;
                Product__c prod = new Product__c();
                Judgment__c judg = new Judgment__c();
                //system.debug('ProductID:: '+mapAccountNumberID.get(judgStaging.Data_Id__c));
                  if(mapAccountNumberID.containsKey(judgStaging.Data_Id__c)){
                    prod.id = mapAccountNumberID.get(judgStaging.Data_Id__c);
                  }
                prod.First_Name__c = judgStaging.First_Name__c;
                prod.Last_Name__c = judgStaging.Last_Name__c;
                prod.Placement_Status__c = judgStaging.Placement_Status__c;
                prod.Product_Status__c = judgStaging.Product_Status__c;
                if(String.isNotBlank(prod.Placement_Status__c) && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)){
                    prod.Status__c =  mapPlacementCodeStatus.get(prod.Placement_Status__c).Parent_Status__c +' - ' +mapPlacementCodeStatus.get(prod.Placement_Status__c).Status__c;
                    prod.Sub_Status__c = mapPlacementCodeStatus.get(prod.Placement_Status__c).Sub_Status__c;
                }
                system.debug('prod!@#:: '+prod);
                listProd.add(prod);
                list<String> listJudgmentStatuses = new list<String>();
                listJudgmentStatuses.add(prod.Placement_Status__c);
               for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                        Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                        Judgment_Legal_Sub_Status__c
                                                                 FROM Judgment_product_codes_mapping__c
                                                                 WHERE Codes__c IN :listJudgmentStatuses ]){
                    mapAccountJudgmentCodes.put(mapping.Codes__c,mapping);
                }
                //system.debug('Judgment_product:: '+mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_1__c);
                if(mapAccountJudgmentNumberID.containsKey(judgStaging.Data_Id__c)){
                    judg.id = mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c);
                }
                judg.Suit_Amount__c = judgStaging.Suit_Amount__c;
                judg.Case_Number__c = judgStaging.Case_Number__c;
                judg.Filing_Date__c = Date.valueOf(judgStaging.Filing_Date__c);
                judg.Judgment_Province__c = judgStaging.Judgment_Province__C;
                judg.County__C = judgStaging.County_Identifier__c;
                judg.Court__c = judgStaging.Type_of_Court__c;
                judg.Legal_Firm__c = judgStaging.Legal_Firm__c;
                judg.Judgment_Date__c = Date.valueOf(judgStaging.Judgment_Date__c);
                judg.Judgment_Amount__c = judgStaging.Judgment_Amount__c;
                judg.Date_Writ_Issued__c = Date.valueOf(judgStaging.Date_Writ_Issued__c);
                judg.Writ_Amount__c = judgStaging.Writ_Amount__c;
                judg.Garnishment_Date__c = Date.valueOf(judgStaging.Garnishment_Date__c);
                judg.Garnishment_Amount__c = judgStaging.Garnishment_Amount__c;
                judg.Legal_Agency__c = judgStaging.Legal_Agency__c;
                judg.Agency_Initiated_Legal_Action__c = judgStaging.Agency_Initiated_Legal_Action__c;
                  system.debug('Check dataID contains::'+mapJudgment.containsKey(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)));
                  if(mapJudgment.containsKey(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c))){
                if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_1__c == judgStaging.Data_Id__c){
                    judg.Interest_Rate_one__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                    judg.Balance_one__c = Decimal.valueOf(judgStaging.Balance__c);
                }else if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_2__c == judgStaging.Data_Id__c){
                    judg.Interest_Rate_two__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                    judg.Balance_two__c = Decimal.valueOf(judgStaging.Balance__c);
                }else if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_3__c == judgStaging.Data_Id__c){
                    judg.Interest_Rate_three__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                    judg.Balance_three__c = Decimal.valueOf(judgStaging.Balance__c);
                }else if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_4__c == judgStaging.Data_Id__c){
                    judg.Interest_Rate_four__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                    judg.Balance_four__c = Decimal.valueOf(judgStaging.Balance__c);
                }else if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_5__c == judgStaging.Data_Id__c){
                    judg.Interest_Rate_five__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                    judg.Balance_five__c = Decimal.valueOf(judgStaging.Balance__c);
                }else if(mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_1__c == null && mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_2__c == null
                        && mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_3__c == null
                        && mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_4__c == null
                        && mapJudgment.get(mapAccountJudgmentNumberID.get(judgStaging.Data_Id__c)).Product_5__c == null){
                    
                        judg.Interest_Rate_one__c = Decimal.valueOf(judgStaging.Interest_Rate__c);
                        judg.Balance_one__c = Decimal.valueOf(judgStaging.Balance__c);
                    }
               }
                  system.debug('prod.Placement_Status__c'+prod.Placement_Status__c);
                  system.debug('mapAccountJudgmentCodes'+mapAccountJudgmentCodes);
               if(String.isNotBlank(prod.Placement_Status__c) && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)){
                      judg.Legal_Status__c =  mapAccountJudgmentCodes.get(prod.Placement_Status__c).Judgment_Legal_Status__c;
                      judg.Legal_Sub_Status__c = mapAccountJudgmentCodes.get(prod.Placement_Status__c).Judgment_Legal_Sub_Status__c;
               }
               /*if(mapAccountJudgmentCodes.containsKey(judg.Legal_Status__c)){
                    judg.Legal_Status__c = mapAccountJudgmentCodes.get(judg.Legal_Status__c);    
               }
               if(mapAccountJudgmentCodes.containsKey(judg.Legal_Sub_Status__c)){
                    judg.Legal_Sub_Status__c = mapAccountJudgmentCodes.get(judg.Legal_Sub_Status__c);      
               }*/
                
                system.debug('judg!@#:: '+judg);
                //listJudgment.add(judg);
                MapJudgmentData.put(judg.id,judg);
                 success += '\n';
                            success += judgStaging.Data_Id__c+','+judgStaging.First_Name__c+','
                                          +judgStaging.Last_Name__c+','+judgStaging.Placement_Status__c+','+judgStaging.Product_Status__c+','
                                          +judgStaging.Suit_Amount__c+','+judgStaging.Case_Number__c+','+'"'+(judgStaging.Filing_Date__c!= null ? judgStaging.Filing_Date__c : NULL)+'"'+','+judgStaging.Judgment_Province__c+','
                                          +judgStaging.County__C+','+judgStaging.Type_of_Court__c+','+judgStaging.Legal_Firm__c+','+'"'+(judgStaging.Judgment_Date__c!= null ? judgStaging.Judgment_Date__c : NULL)+'"'+','+(judgStaging.Judgment_Amount__c != null ? judgStaging.Judgment_Amount__c : Null)+','
                                          +'"'+(judgStaging.Date_Writ_Issued__c!= null ? judgStaging.Date_Writ_Issued__c : NULL)+'"'+',' +(judgStaging.Writ_Amount__c != null ? judgStaging.Writ_Amount__c : Null)+','+'"'+(judgStaging.Garnishment_Date__c != null ? judgStaging.Garnishment_Date__c : NULL)+'"'+','
                                          +(judgStaging.Garnishment_Amount__c != null ? judgStaging.Garnishment_Amount__c : Null)+','+judgStaging.Legal_Agency__c+','+judgStaging.Agency_Initiated_Legal_Action__c+','+judgStaging.Interest_Rate__c;
                                          //+','+payStaging.;
                      //SuccessHasRecord = true;
                successRecords = successRecords + 1;
       
            }
            else{
                failed += '\n';
                String CommentError;
                if(judgStaging.Comment__c!= null){
                    CommentError = judgStaging.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
                    system.debug('CommentError test::' +CommentError);
                }
                            failed += judgStaging.Data_Id__c+','+judgStaging.First_Name__c+','
                                          +judgStaging.Last_Name__c+','+judgStaging.Placement_Status__c+','+judgStaging.Product_Status__c+','
                                          +judgStaging.Suit_Amount__c+','+judgStaging.Case_Number__c+','+'"'+(judgStaging.Filing_Date__c!= null ? judgStaging.Filing_Date__c : NULL)+'"'+','+judgStaging.Judgment_Province__c+','
                                          +judgStaging.County__C+','+judgStaging.Type_of_Court__c+','+judgStaging.Legal_Firm__c+','+'"'+(judgStaging.Judgment_Date__c!= null ? judgStaging.Judgment_Date__c : NULL)+'"'+','+(judgStaging.Judgment_Amount__c != null ? judgStaging.Judgment_Amount__c : Null)+','
                                          +'"'+(judgStaging.Date_Writ_Issued__c!= null ? judgStaging.Date_Writ_Issued__c : NULL)+'"'+',' +(judgStaging.Writ_Amount__c != null ? judgStaging.Writ_Amount__c : Null)+','+'"'+(judgStaging.Garnishment_Date__c != null ? judgStaging.Garnishment_Date__c : NULL)+'"'+','
                                          +(judgStaging.Garnishment_Amount__c != null ? judgStaging.Garnishment_Amount__c : Null)+','+judgStaging.Legal_Agency__c+','+judgStaging.Agency_Initiated_Legal_Action__c+','+judgStaging.Interest_Rate__c
                                          + '"'+','+(judgStaging.Comment__c!= null ? CommentError : NULL);
                                          //+','+payStaging.;
                           //FailedHasRecord = true;
                     failedRecords = failedRecords + 1;                                     
            }
        }
        system.debug('listProd: '+listProd);
        system.debug('listJudgment:: '+listJudgment);
        ProductTriggerHandler.runProductTrigger = false;
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        update listProd;
        //update listJudgment;
        update MapJudgmentData.values();
        for(Product__c prodcheck : listProd){
             PortalProductProcessingAPI.processProduct(prodcheck.ID); 
        }
        for(Judgment__c judg : MapJudgmentData.values()){
             PortalJudgmentProcessingAPI.processJudgment(judg.ID); 
        }
        ProductTriggerHandler.runProductTrigger = true;
        JudgmentTriggerHandler.runJudgmentTrigger = true;

        //Create Task record and assign it to Agency
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.ID = listJudgmentStaging[0].Document_Storage__r.Work_Assignment__c;
        workAssignmentId = workAssignment.ID;
        /*workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Account Judgment Upload Status ' + '[' + listJudgmentStaging[0].Document_Storage__r.Work_Assignment_Identifier__c + ']';
        workAssignment.Description__c = 'Account Judgment Upload Status';
        workAssignment.Status__c = 'Requested';
        workAssignment.Assign_To__c = 'Agency';
        workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.Sub_Purpose__c = 'Account status (having judgment) update';
        workAssignment.Placement_Agency__c = placementID;*/
        workAssignment.Comment_Reply__c = '';
        workAssignment.Status__c = 'Completed';
        if(failedRecords > 0){
            workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
        }
        if(successRecords > 0){
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
        }      
        update workAssignment;
        system.debug('workAssignment: '+workAssignment);
        //workAssignmentId = workAssignment.Id;
        
        update new Work_Assignment__c(Id = listJudgmentStaging[0].Document_Storage__r.Work_Assignment__c, 
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
        //if(failed != null){
        Blob fileBlob = Blob.valueOf(failed);
       system.debug('fileBlob::'+fileBlob);
       if(failedRecords > 0){
           system.debug('Inside fail for');
            parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Account Judgment Failed.csv', 'Task');
            system.debug('parsedResponse in controller: '+parsedResponse);
            rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response);
       }
        //Success CSV API
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        System.debug('@@base64Data '+success);
        Blob fileBlobSuccess = Blob.valueOf(success);
        system.debug('fileBlobSuccess ::'+fileBlobSuccess );
        if(successRecords > 0){
        system.debug('Inside success for');
            parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Account Judgment Success.csv', 'Task');
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
            failedDocStorage.Document_Name__c = 'Account Judgment Failed.csv';
            failedDocStorage.Document_Extension__c = 'csv';
            failedDocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            failedDocStorage.Document_Type__C = 'Account Judgment Processing File';
            //failedDocStorage.Content_Type__c = contentType;
            failedDocStorage.Visibility__c = 'CFG + Requesting Agency';
            failedDocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            system.debug('failedDocStorage.Document_Related_To__c: '+failedDocStorage.Document_Related_To__c);
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            insert failedDocStorage;
            system.debug('failedDocStorage: '+failedDocStorage);
            //delete listProductPayStaging;
        }
     
        
        //Create Success CSV Document Storage
        Document_Storage__c  SuccessDocStorage = new Document_Storage__c();
        
        if(null != parsedResponse1 
        && rawObj1 != NULL
        && String.isnotBlank(String.valueOf(rawObj1.get('docId')))){
            
            system.debug('task creation');
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;                        
            SuccessDocStorage.Document_Name__c = 'Account Judgment Success.csv';
            SuccessDocStorage.Document_Extension__c = 'csv';
            SuccessDocStorage.Document_ID__c = String.valueOf(rawObj1.get('docId'));
            SuccessDocStorage.Document_Type__C = 'Account Judgment Processing File';
            SuccessDocStorage.Visibility__c = 'CFG + Requesting Agency';
            SuccessDocStorage.Document_URL__c = String.valueOf(rawObj1.get('docUrl'));
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
        //delete [SELECT ID FROM Judgment_Staging__c];
        ProductTriggerHandler.runProductAPI = false;
        update listJudgmentStaging;
        ProductTriggerHandler.runProductAPI = true;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Payment Processing Complete'));
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID= documentID, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;
         
        //disable buttons
        showButton = false;
        displayPanel = true;
        system.debug('ShowOk: '+showButton);
        system.debug('displayPanel: '+displayPanel);
        return null;
    }
    
     public class judgmentStagingWrapper{
        public Judgment_Staging__c payStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public judgmentStagingWrapper(Judgment_Staging__c pay, Boolean disable ){
            payStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
    
    public static map<String, Placement_Status_Code_Mapping__c> getPlacementStatusCodes(){
        mapPlacementCodeStatus = new map<String, Placement_Status_Code_Mapping__c>();
        mapPlacementStatus = new map<String, String>();
        for(Placement_Status_Code_Mapping__c reasons : [SELECT Parent_Status__c,Placement_Status_Code__c,
                                                               Status__c,Sub_Status__c, Complete_Status__c
                                                        FROM Placement_Status_Code_Mapping__c
                                                        ORDER BY Status__c]){
            mapPlacementCodeStatus.put(reasons.Placement_Status_Code__c, reasons);
            if(String.isNotBlank(reasons.Status__c)){
                if(String.isBlank(reasons.Sub_Status__c)){
                    reasons.Sub_Status__c = '';
                }
                mapPlacementStatus.put(reasons.Complete_Status__c, reasons.Placement_Status_Code__c);   
            }
        }
        return mapPlacementCodeStatus;
    }
}