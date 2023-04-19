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
	Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
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
    static final String PAYMENT_TYPE_REVERAl = '1001,1002,1004,8000';
    static final String PAYMENT_TYPE = '1000,1001,1002,1003,1004,8000';
    public static String ACCOUNT_STATUS_HAVING_JUDGMENT_FILE = 'Account Status (having Judgment) Update File';
    
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
        if(listJudgmentStaging.isEmpty()){
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Account_judgment to display'));
        }
        else{
            workAssignmentId = listJudgmentStaging[0].Document_Storage__r.Work_Assignment__c;
            listProductPayStagingWrapper = new list<judgmentStagingWrapper>();
            for(Judgment_Staging__c payStaging : listJudgmentStaging){
                Boolean disabled = false;
                if(payStaging.Comment__c.contains(ERROR) || (payStaging.Status__c == PROCESSED && payStaging.Comment__c == 'SUCCESS')){
                    disabled = true;
                }
                listProductPayStagingWrapper.add(new judgmentStagingWrapper(payStaging, disabled));
                if(payStaging.Status__c != PROCESSED && !payStaging.Comment__c.contains(ERROR)){
                    showButton = false;
                }
            }
            placementAgency = listJudgmentStaging[0].Placement_Agency__c;
            documentID = listJudgmentStaging[0].Document_Storage__c;
            if(showButton == false){
            if(listJudgmentStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){
                showButton = true;
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
            }
            else{
                showButton = false;
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
        Map<String, ID> mapAccountJudgmentNumberID = new Map<String, ID>();
        List<Judgment_Staging__c> listJudgmentStagingData = new List<Judgment_Staging__c>();  
        set<ID> setJudgmentID = new set<ID>();
        set<ID> setProdutID1 = new set<ID>();
        Id product;
        
        for(Judgment_Staging__c judgStaging : listJudgmentStaging){
            setProdutNames.add(judgStaging.Data_Id__c);           
        }
        
        List<Product__C> listAccount2 = [select id, name, DebtNext_Data_ID__C, Collection_Agency__c    
                                        from Product__C 
                                        where name in :setProdutNames];
        
        for(Product__C prodList : listAccount2){
            setProdutID1.add(prodList.id);
            product = prodList.id;
        }

        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        
        List<Account_Judgment__c> listAccountJudgment = [select id, name,Product__c,Judgment__c,Product__r.Data_Id__c,Judgment__r.id,Product__r.Name
                                                         from Account_Judgment__c 
                                        where Product__c in : setProdutID1 AND Status__c = 'Active'];


        for(Account_Judgment__c judgmentRecord : listAccountJudgment ){
            mapAccountJudgmentNumberID.put(judgmentRecord.Product__r.Name, judgmentRecord.Judgment__r.id);
             setJudgmentID.add(judgmentRecord.Judgment__c);
        }

        map<ID, Judgment__c> mapJudgment = new map<ID, Judgment__c>();
        List<Judgment__c> listJudg = [Select ID,Name,Suit_Amount__c,Case_Number__c, Filing_Date__c, Judgment_Province__c, County__c, Court__c, Legal_Firm__c,
                                Judgment_Date__c, Judgment_Amount__c, Date_Writ_Issued__c, Writ_Amount__c, Garnishment_Date__c, Garnishment_Amount__c,
                                Legal_Agency__c, Agency_Initiated_Legal_Action__c,Product_1__c,Product_2__c,Product_3__c,Product_4__c,Product_5__c,
                                  Legal_Status__c    
                               From Judgment__c 
                               Where id in: setJudgmentID];
        List<Product__C> listAccount = [select id, name, Data_Id__c, Collection_Agency__c    
                                        from Product__C 
                                        where name in :setProdutNames];
        
        for(Product__C accountRecord : listAccount ){
            mapAccountNumberID.put(accountRecord.name, accountRecord.id);
        }
        
        for(Judgment__c listJudg1 : listJudg){
            mapJudgment.put(listJudg1.Id, listJudg1);
        }

        for(judgmentStagingWrapper judgStagingWrapper : listProductPayStagingWrapper){
            Judgment_Staging__c judgStaging = judgStagingWrapper.payStaging;
            String comment = '';
            list<String> listJudgmentStatuses = new list<String>();
            
            if(String.isNotBlank(judgStaging.Comment__c)){
                comment = judgStaging.Comment__c;
            }
              if(Test.isRunningTest()){
                judgStagingWrapper.selected = true;
            }
            if(judgStaging.Status__c != PROCESSED && judgStagingWrapper.selected == true) {
                //judgStaging.Status__c = PROCESSED;
                Product__c prod = new Product__c();
                Judgment__c judg = new Judgment__c();
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
                listProd.add(prod);
                
                listJudgmentStatuses.add(prod.Placement_Status__c);
               for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                        Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                        Judgment_Legal_Sub_Status__c
                                                                 FROM Judgment_product_codes_mapping__c
                                                                 WHERE Codes__c IN :listJudgmentStatuses ]){
                    mapAccountJudgmentCodes.put(mapping.Codes__c,mapping);
                }
                
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
               if(String.isNotBlank(prod.Placement_Status__c) && mapPlacementCodeStatus.containsKey(prod.Placement_Status__c)){
                      judg.Legal_Status__c =  mapAccountJudgmentCodes.get(prod.Placement_Status__c).Judgment_Legal_Status__c;
                      judg.Legal_Sub_Status__c = mapAccountJudgmentCodes.get(prod.Placement_Status__c).Judgment_Legal_Sub_Status__c;
               }
                MapJudgmentData.put(judg.id,judg);
                listJudgmentStagingData.add(judgStaging);
            }
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        JudgmentTriggerHandler.runJudgmentTrigger = false;
        boolean excFlag = False;
        String txt = '';
        try{ 
            if(listProd.size()>0){
                update listProd;
            }
            if(MapJudgmentData != NULL){
                update MapJudgmentData.values();
            }
            for(Product__c prodcheck : listProd){
                PortalProductProcessingAPI.processProduct(prodcheck.ID); 
            }
            for(Judgment__c judg : MapJudgmentData.values()){
                PortalJudgmentProcessingAPI.processJudgment(judg.ID); 
            }
            //Create Success and Error file
            GenerateSuccessAndErrorFile(listProductPayStagingWrapper,listJudgmentStaging[0].Document_Storage__r.Work_Assignment__c,portalSettings.Document_Storage_Default_Visibility__c,documentID);
            
        }Catch(exception ex){                
            txt = ex.getMessage();          
            excFlag=True;
            system.debug('exception Customer file catch--+--'+ex.getLineNumber());
            system.debug('exception Customer file catch--+--'+ex.getMessage());
            for(Judgment_Staging__c judgStaging: listJudgmentStagingData){
                String msg = '<b>ERROR</b>-'+ex.getMessage();
                if(msg.length() > 254){
                    msg = msg.substring(0,254);
                }
                judgStaging.Comment__c= msg;
                judgStaging.status__c= 'Pending';
            }             
        }
        
		if(listJudgmentStagingData.size()>0){
            update listJudgmentStagingData;
        }
        
        ProductTriggerHandler.runProductTrigger = true;
        JudgmentTriggerHandler.runJudgmentTrigger = true;
        
        showButton = true;
        displayPanel = true;
        return null;
      
    }
    
    public Static void GenerateSuccessAndErrorFile(list<judgmentStagingWrapper> listProductPayStagingWrapper,
                                            Id workAssignmentId,String visiblity,Id documentID){
        String success;
    	String failed;
		Integer successRecords = 0;
        Integer failedRecords = 0;
                                                      
		success = 'data_id' + '\t' + 'pri_first' + '\t' + 'pri_last' + '\t' + 'placedetail_status' + '\t' + 'data_status' + '\t' + 'judgment_suit_amount' + '\t' + 'judgment_case' + '\t' + 'judgment_filed' + '\t' + 'judgment_state' + '\t' + 'judgment_county' + '\t' + 'judgment_court' + '\t' + 'judgment_firm' + '\t' + 'judgment_date' + '\t' + 'judgment_amount' + '\t' + 'judgment_writ' + '\t' + 'judgment_writ_amount' + '\t' + 'judgment_garnishment' + '\t' + 'judgment_garnishment_amount' + '\t' + 'place_id' + '\t' + 'judgment_place_id' + '\t' + 'judgment_intrate';
        failed = 'data_id' + '\t' + 'pri_first' + '\t' + 'pri_last' + '\t' + 'placedetail_status' + '\t' + 'data_status' + '\t' + 'judgment_suit_amount' + '\t' + 'judgment_case' + '\t' + 'judgment_filed' + '\t' + 'judgment_state' + '\t' + 'judgment_county' + '\t' + 'judgment_court' + '\t' + 'judgment_firm' + '\t' + 'judgment_date' + '\t' + 'judgment_amount' + '\t' + 'judgment_writ' + '\t' + 'judgment_writ_amount' + '\t' + 'judgment_garnishment' + '\t' + 'judgment_garnishment_amount' + '\t' + 'place_id' + '\t' + 'judgment_place_id' + '\t' + 'judgment_intrate' + '\t' + 'error';
        
        for(judgmentStagingWrapper judgStagingWrapper : listProductPayStagingWrapper){
            Judgment_Staging__c judgStaging = judgStagingWrapper.payStaging;
            if(judgStaging.Status__c != PROCESSED && judgStagingWrapper.selected == true){
                judgStaging.Status__c = PROCESSED;
                success += '\n';
                success += judgStaging.Data_Id__c+'\t'+judgStaging.First_Name__c+'\t'
                    +judgStaging.Last_Name__c+'\t'+judgStaging.Placement_Status__c+'\t'+judgStaging.Product_Status__c+'\t'
                    +judgStaging.Suit_Amount__c+'\t'+judgStaging.Case_Number__c+'\t'+'"'+(judgStaging.Filing_Date__c!= null ? judgStaging.Filing_Date__c : NULL)+'"'+'\t'+judgStaging.Judgment_Province__c+'\t'
                    +judgStaging.County__C+'\t'+judgStaging.Type_of_Court__c+'\t'+judgStaging.Legal_Firm__c+'\t'+'"'+(judgStaging.Judgment_Date__c!= null ? judgStaging.Judgment_Date__c : NULL)+'"'+'\t'+(judgStaging.Judgment_Amount__c != null ? judgStaging.Judgment_Amount__c : Null)+'\t'
                    +'"'+(judgStaging.Date_Writ_Issued__c!= null ? judgStaging.Date_Writ_Issued__c : NULL)+'"'+'\t' +(judgStaging.Writ_Amount__c != null ? judgStaging.Writ_Amount__c : Null)+'\t'+'"'+(judgStaging.Garnishment_Date__c != null ? judgStaging.Garnishment_Date__c : NULL)+'"'+'\t'
                    +(judgStaging.Garnishment_Amount__c != null ? judgStaging.Garnishment_Amount__c : Null)+'\t'+judgStaging.Legal_Agency__c+'\t'+judgStaging.Agency_Initiated_Legal_Action__c+'\t'+judgStaging.Interest_Rate__c;
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
                failed += judgStaging.Data_Id__c+'\t'+judgStaging.First_Name__c+'\t'
                    +judgStaging.Last_Name__c+'\t'+judgStaging.Placement_Status__c+'\t'+judgStaging.Product_Status__c+'\t'
                    +judgStaging.Suit_Amount__c+'\t'+judgStaging.Case_Number__c+'\t'+'"'+(judgStaging.Filing_Date__c!= null ? judgStaging.Filing_Date__c : NULL)+'"'+'\t'+judgStaging.Judgment_Province__c+'\t'
                    +judgStaging.County__C+'\t'+judgStaging.Type_of_Court__c+'\t'+judgStaging.Legal_Firm__c+'\t'+'"'+(judgStaging.Judgment_Date__c!= null ? judgStaging.Judgment_Date__c : NULL)+'"'+'\t'+(judgStaging.Judgment_Amount__c != null ? judgStaging.Judgment_Amount__c : Null)+'\t'
                    +'"'+(judgStaging.Date_Writ_Issued__c!= null ? judgStaging.Date_Writ_Issued__c : NULL)+'"'+'\t' +(judgStaging.Writ_Amount__c != null ? judgStaging.Writ_Amount__c : Null)+'\t'+'"'+(judgStaging.Garnishment_Date__c != null ? judgStaging.Garnishment_Date__c : NULL)+'"'+'\t'
                    +(judgStaging.Garnishment_Amount__c != null ? judgStaging.Garnishment_Amount__c : Null)+'\t'+judgStaging.Legal_Agency__c+'\t'+judgStaging.Agency_Initiated_Legal_Action__c+'\t'+judgStaging.Interest_Rate__c
                    + '"'+'\t'+(judgStaging.Comment__c!= null ? CommentError : NULL);
                failedRecords = failedRecords + 1; 
            }
        }
       
       //Database.executeBatch(new ErrorCSVFileGenerationBatch(ACCOUNT_STATUS_HAVING_JUDGMENT_FILE,failed,success,failedRecords,successRecords,workAssignmentId,visiblity,documentID),2000);                                              
       system.enqueueJob(new PostDocumentAPI(ACCOUNT_STATUS_HAVING_JUDGMENT_FILE,failed,success,failedRecords,successRecords,workAssignmentId,visiblity,documentID));                                              
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
    public static Map<Id,Product__c> calculateJudgmentInterestAdjustment(list<Judgment__c> listNewJudgments,map<String, Product__c> mapProductData,
                                       String JudProductName,Decimal JudBalance,Decimal JudInterestRate,String judgDate,
                                        Map<String,Product_Payments__c> ProductPaymentList,map<String, Product__c> mapProductDataDetails){
                                                         
         Map<Id,Product__c> productToUpdateMap = new Map<Id,Product__c>();
         Product__c productInstance = new Product__c();
                                            
         //	Step:2  d. Set Interest Amount Last Calculated Date to Today                                 
         if(mapProductData.containsKey(JudProductName)){
         	productInstance = mapProductData.get(JudProductName);
         	productInstance.Id = mapProductData.get(JudProductName).ID;
         	productInstance.Name = mapProductData.get(JudProductName).Name;  
         	productInstance.Interest_Amount_Last_Calculated_Date__c = Date.today();    
         }  
         if(mapProductData.containsKey(productInstance.Name)){
            if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
                  && mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
              
              //Step2 a. Set Product Balance to be Judgment Balance       
              productInstance.Current_Principal_Balance__c = JudBalance;
                      
              //Step2 b. Set Product Interest Balance to $0
              productInstance.Current_Interest_Amount__c = 0;
                      
              if(mapProductData.containsKey(JudProductName)){
                   ProductInstance.Previous_Interest_Rate__c = mapProductData.get(JudProductName).Interest_Rate__c;
                   ProductInstance.Previous_Principal_Balance__c = mapProductData.get(JudProductName).Current_Principal_Balance__c;
               }
               ProductInstance.Interest_Rate__c = JudInterestRate;
               productInstance.Judgment_Rate__c = JudInterestRate;
              }
          }                                
          //no payment foud for 100x and 800x then populate judgment interest rate and balance to product
          if(!mapProductData.containsKey(JudProductName) && String.isNotBlank(JudProductName)){
                productInstance = mapProductDataDetails.get(JudProductName);
              	productInstance.ID = mapProductDataDetails.get(JudProductName).id;
              	productInstance.Interest_Rate__c = JudInterestRate;
              	productInstance.Current_Principal_Balance__c = JudBalance;
              	productInstance.Current_Interest_Amount__c = mapProductDataDetails.get(JudProductName).Current_Interest_Amount__c;
                productInstance.Recoverable_Fee__c = mapProductDataDetails.get(JudProductName).Recoverable_Fee__c;
          }                                 
          if(productInstance.ID != NULL){                               
              productToUpdateMap.put(productInstance.id,productInstance);
          }                                  
         return productToUpdateMap;
    }
}