/**************************************************************************************************
 *
 *  Class:   AccountJudgmentTriggerHandler
 *
 *  @description :  When new AccountJudgment record created, update existing product related Account Judgments to Inactive
 *                  Once new AccountJudgment record is created update Status on Product record to Legal
 *  @author : A5E Consulting
 *  @date : 21/10/2019
 * 
 *************************************************************************************************/
public class AccountJudgmentTriggerHandler{
    public static Application_Config_Settings__c config; //Application_Config_Settings__c.getOrgDefaults();
    public static boolean runAccountJudgmentTrigger = true;
    public static string SEPARATOR = 'A';
    public static string UNPLACED = 'unplaced';
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
    public static Agency_Portal_Settings__c configSetting = Agency_Portal_Settings__c.getOrgDefaults();
    
    //method to handle after update 
    public static void handleBeforeInsert(List<Account_Judgment__c> listAccountJudgment){
        list<Account_Judgment__c> listInternalAccountJudgment = new list<Account_Judgment__c>();
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        for(Account_Judgment__c accJudgment: listAccountJudgment){
            if(accJudgment.Product__c <> NULL ){
                listInternalAccountJudgment.add(accJudgment);
            }
            if(accJudgment.Judgment__c <> NULL ){
                listInternalAccountJudgment.add(accJudgment);
            }
        }
        
        //method calls once record created in CFG
        getAccJudgmentRelatedData(listInternalAccountJudgment);
    }
    
    public static void getAccJudgmentRelatedData(list<Account_Judgment__c> listAccountJudgment){
        set<Id> setProductID = new set<Id>();
        set<Id> setJudgmentID = new set<Id>();

        map<Id, String> mapProductNames = new map<Id, String>();
        map<Id, String> mapJudgmentNames = new map<Id, String>();
     
        for(Account_Judgment__c accountJudgment : listAccountJudgment){
            setProductID.add(accountJudgment.Product__c);
            setJudgmentID.add(accountJudgment.Judgment__c);      
        }
        
        for(Product__c product : [SELECT ID, Name
                                     FROM Product__c
                                     WHERE ID IN :setProductID]){
            mapProductNames.put(product.ID, product.Name);
            
        }
        for(Judgment__c Judgment : [SELECT ID, Name
                                     FROM Judgment__c
                                     WHERE ID IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.ID, Judgment.Name);
            
        }
        for(Account_Judgment__c accJudgment : listAccountJudgment){
            accJudgment.Product_Identifier__c = mapProductNames.get(accJudgment.Product__c);
            accJudgment.Judgment_Identifier__c = mapJudgmentNames.get(accJudgment.Judgment__c);
        }
    }
    
    //method to handle after update 
    public static void handleAfterUpdate(List<Account_Judgment__c> listAccountJudgment){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        if(config.Run_AccountJudgment_API_for_Portal__c){
            for(Account_Judgment__c accJudgment: listAccountJudgment){
                //call API
              //  config.Send_Notification__c = false;
                PortalAccountJudgmentProcessingAPI.processAccountJudgment(accJudgment.ID); 
              //  config.Send_Notification__c = True;
            }
        }
    }
    
    
    //Fetch related Product record Update status to “Legal” 
    public static void updateProductRecord(List<Account_Judgment__c> prodJudgList){
        map<String, Judgment_product_codes_mapping__c> mapJudgment = Judgment_product_codes_mapping__c.getAll();
        map<String, Judgment_product_codes_mapping__c> mapJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        for(Judgment_product_codes_mapping__c judgmentCodes : mapJudgment.values()){
            mapJudgmentCodes.put(judgmentCodes.Judgment_Legal_Status__c+judgmentCodes.Judgment_Legal_Sub_Status__c, judgmentCodes);
        }    
        List<Id> prodIds = new List<Id>();
        List<Id> judIds = new List<Id>();
        Map<string,Judgment__c> mapJudgmentData = new Map<string,Judgment__c>();
        Map<string,map<string,string>> prodStatus = new Map<string,map<string,string>>();
        system.debug('prodJudgList::'+prodJudgList);
        config = [SELECT Run_Product_Coll_Sub_Status_Validation__c FROM Application_Config_Settings__c FOR UPDATE];
        for(Account_Judgment__c prodJudg : prodJudgList){
            if(prodJudg.Judgment__c != NULL){
                judIds.add(prodJudg.Judgment__c);
            }
        }
        List<Judgment__c> judgList = [SELECT Id,Legal_Status__c,Legal_Sub_Status__c  FROM Judgment__c WHERE Id IN: judIds];
        for(Judgment__c judData : judgList){
            mapJudgmentData.put(judData.id,judData);
        }
        for(Account_Judgment__c prodJudg : prodJudgList){
            if(prodJudg.Product__c != NULL){
                prodIds.add(prodJudg.Product__c);
            }
            prodStatus.put(
                        prodJudg.Product__c,
                        new Map<String, String>{
                            'PlacementStatus' => mapJudgmentCodes.get(mapJudgmentData.get(prodJudg.Judgment__c).Legal_Status__c+mapJudgmentData.get(prodJudg.Judgment__c).Legal_Sub_Status__c).Codes__c,
                            'PlacemntMainStatus' => mapJudgmentCodes.get(mapJudgmentData.get(prodJudg.Judgment__c).Legal_Status__c+mapJudgmentData.get(prodJudg.Judgment__c).Legal_Sub_Status__c).Product_Status__c,
                            'PlacementSubStatus' => mapJudgmentCodes.get(mapJudgmentData.get(prodJudg.Judgment__c).Legal_Status__c+mapJudgmentData.get(prodJudg.Judgment__c).Legal_Sub_Status__c).Product_Sub_status__c
                        }
                    );
        }
        system.debug('prodIds::'+prodIds);
        system.debug('prodStatus::'+prodStatus);
        if(!prodIds.isEmpty()){
            system.debug('BlockRun');
            List<Product__c> prodList = [SELECT Id, Collection_Sub_Status__c FROM Product__c WHERE Id IN: prodIds];
            for(Product__c prod: prodList){
                prod.Collection_Sub_Status__c = 'Legal';
                prod.Previously_Reviewed_for_Legal_Action__c = TRUE;
                //Ticket 6928: added judgment on product from judgment UI screen
                //update placement main status,placement sub status and placement status on product
                prod.Status__c = prodStatus.get(prod.id).get('PlacemntMainStatus');
                prod.Sub_Status__c = prodStatus.get(prod.id).get('PlacementSubStatus');
                prod.Placement_Status__c = prodStatus.get(prod.id).get('PlacementStatus');
            }
            //Ticket 7279 - updating product statuses with trigger off and make API call
            ProductTriggerHandler.runProductTrigger = false;
            config.Run_Product_Coll_Sub_Status_Validation__c = false; 
            update config;
            try{
                system.debug('BlockRunProductUpdate');
                update prodList; 
            }Catch(Exception ex){
                throw ex;
            }
            config.Run_Product_Coll_Sub_Status_Validation__c = true; 
            update config;
            if(Test.isRunningTest()){
                Database.executeBatch(new PortalProductProcessingAPIBatch(prodIds, prodList,false), 40);
            }
            
            ProductTriggerHandler.runProductTrigger = true;
        }
        //populateProductNameOnJudgment(prodJudgList);
    }

    public static void updateActiveAccountJudgmentRecord(List<Account_Judgment__c> prodJudgList){
        List<Id> prodIds = new List<Id>();
        List<Id> judgIds = new List<Id>();
        
        List<Account_Judgment__c> prodJudUpdatedToInactive = new List<Account_Judgment__c>();
         List<Account_Judgment__c> prodJudUpdatedToActive = new List<Account_Judgment__c>();
        Set<Id> activated = new set<Id>();
        system.debug('updateActiveAccountJudgmentRecord'+prodJudgList);
        for(Account_Judgment__c prodJudg : prodJudgList){
            if(prodJudg.Product__c != NULL /*&& prodJudg.Status__c == 'Inactive'*/){
                prodIds.add(prodJudg.Product__c);
            }
            if(prodJudg.Status__c == 'Active'){
                if(prodJudg.Judgment__c != NULL){
                    judgIds.add(prodJudg.Judgment__c);
                }
            }
        }
        List<Judgment__c> judgList = [SELECT Id, name,Agency_Initiated_Legal_Action__c,Agency_Initiated_Legal_Action_Lookup__c FROM Judgment__c WHERE Id IN: judgIds];
        system.debug('prodJudUpdatedToInactive v1: '+prodJudUpdatedToInactive);
        for(Account_Judgment__c prodJudg: [SELECT Id, Status__c, Product__c FROM Account_Judgment__c WHERE Judgment__c IN: judgIds]){
            prodJudg.Status__c = 'Active';
            //prodJudUpdatedToInactive.add(prodJudg);
            prodJudUpdatedToActive.add(prodJudg);
            activated.add(prodJudg.Id); // to verify test
            prodIds.add(prodJudg.Product__c);
        }
        system.debug('prodJudUpdatedToInactive v2: '+prodJudUpdatedToInactive);
        
        if(!prodIds.isEmpty()){
            Set<Id> inactiveJudgmentIds = new Set<Id>();
            for(Account_Judgment__c prodJudg: [SELECT Id, Status__c, Judgment__c FROM Account_Judgment__c WHERE Product__c IN: prodIds AND Status__c != 'Inactive' AND Id NOT IN: activated]){
                prodJudg.Status__c = 'Inactive';
                system.debug(activated.contains(prodJudg.Id)+'111'+prodJudg);
                inactiveJudgmentIds.add(prodJudg.Judgment__c);
                prodJudUpdatedToInactive.add(prodJudg);
            }
            for(Account_Judgment__c prodJudg: [SELECT Id, Status__c FROM Account_Judgment__c WHERE 
                                                                                                Judgment__c IN: inactiveJudgmentIds 
                                                                                            AND  
                                                                                                Status__c != 'Inactive'
                                                                                            AND Id NOT IN: prodJudgList
                                                                                            AND Id NOT IN: prodJudUpdatedToInactive]){
                system.debug('222'+prodJudg);
                prodJudg.Status__c = 'Inactive';
                prodJudUpdatedToInactive.add(prodJudg);
            }
            prodJudUpdatedToInactive.addAll(prodJudUpdatedToActive);
            
            if(!prodJudUpdatedToInactive.isEmpty())
            update prodJudUpdatedToInactive;
        }
        //Bug: 5564 - Commented below line
        //JudgmentTriggerHandler.updateAgencyOnJudgment(judgList);
        //– fetch all active AccountJudgment records on the related product record. Update those record’s status to “Inactive” 
    } 
    
    public static void updateActiveAccountJudgmentRecord(Map<Id, Account_Judgment__c> newAccountJudgments, Map<Id, Account_Judgment__c> oldAccountJudgments){
        List<Account_Judgment__c> accJudgListActivated = new List<Account_Judgment__c>();
        List<Account_Judgment__c> accJudgListInactivated = new List<Account_Judgment__c>();
        List<Account_Judgment__c> accJudgEmptyStatus = new List<Account_Judgment__c>();
        
        Map<Id, Account_Judgment__c> judgmentMap = new Map<Id, Account_Judgment__c>();
        for(Id key: newAccountJudgments.keySet()){
            if(newAccountJudgments.get(key).Status__c != oldAccountJudgments.get(key).Status__c)
                if(newAccountJudgments.get(key).Status__c == 'Active'){
                    accJudgListActivated.add(newAccountJudgments.get(key));
                    
                    judgmentMap.put(newAccountJudgments.get(key).Judgment__c, newAccountJudgments.get(key));
                }else if(newAccountJudgments.get(key).Status__c == 'Inactive'){
                    accJudgListInactivated.add(newAccountJudgments.get(key));
                }else{
                    
                }
        }
        //validateJudgments(judgmentMap);
        system.debug('accJudgList'+accJudgListActivated);
        
        if(!accJudgListActivated.isEmpty()){
            updateAccountJudgments(accJudgListActivated, 'Active');
            updateActiveAccountJudgmentRecord(accJudgListActivated);
        }
        if(!accJudgListInactivated.isEmpty()){
            updateAccountJudgments(accJudgListInactivated, 'Inactive');
        }
    }
    
    public static void updateAccountJudgments(List<Account_Judgment__c> prodJudgList, String status){
        List<Id> judgmentIds = new List<Id>();
        List<Account_Judgment__c> prodJudgToUpdate = new List<Account_Judgment__c>();
        system.debug('updateActiveAccountJudgmentRecord'+prodJudgList);
        for(Account_Judgment__c prodJudg : prodJudgList){
            if(prodJudg.Judgment__c != NULL){
                judgmentIds.add(prodJudg.Judgment__c);
            }
        }
        
        if(judgmentIds.isEmpty()) return;
        for(Account_Judgment__c prodJudg: [SELECT Id, Status__c 
                                            FROM Account_Judgment__c 
                                            WHERE Judgment__c IN: judgmentIds 
                                            AND  Status__c !=: status]){
            prodJudg.status__c = status;
            prodJudgToUpdate.add(prodJudg);                               
        }
        
        if(!prodJudgToUpdate.isEmpty()){
            Utilities.runAccountJudgmentTrigger = FALSE;
            configSetting.Send_Notification__c = FALSE;
            update prodJudgToUpdate;
            configSetting.Send_Notification__c = TRUE;
        }
    }
        //Bug: 5564 Commented below method

    public static void updateAmountsOnJudgment(List<Account_Judgment__c> prodJudgList){
        Set<Id> judgmentIds = new Set<Id>();
        for(Account_Judgment__c prodJudg: prodJudgList ){
            system.debug('prodJudg.Judgment__c '+prodJudg.Judgment__c);
            if(prodJudg.Judgment__c != NULL){
              judgmentIds.add(prodJudg.Judgment__c);
            }
        }
        
        Map<Id, String> judgmentIdCompanyNameMap = new  Map<Id, String>();
        Map<Id, String> judgmentIdPurchaseEntityMap = new  Map<Id, String>();
        for(Account_Judgment__c accJudgList : [SELECT Judgment__c, Product__r.Company_Name__c, Product__r.Account_Purchasing_Entity_Value__c FROM Account_Judgment__c WHERE  
                                                 /*(Judgment__r.Company_Name__c  = NULL OR Judgment__r.Plaintiff__c = NULL)*/
                                                /*Product__r.Company_Name__c != NULL
                                              AND */ judgment__c IN: judgmentIds
                                              ORDER BY Product__r.LastModifiedDate DESC]){
            if(!judgmentIdCompanyNameMap.containsKey(accJudgList.Judgment__c) && accJudgList.Product__r.Company_Name__c != NULL)
            judgmentIdCompanyNameMap.put(accJudgList.Judgment__c, accJudgList.Product__r.Company_Name__c);
            
            if(!judgmentIdPurchaseEntityMap.containsKey(accJudgList.Judgment__c) && accJudgList.Product__r.Account_Purchasing_Entity_Value__c != NULL)
            judgmentIdPurchaseEntityMap.put(accJudgList.Judgment__c, accJudgList.Product__r.Account_Purchasing_Entity_Value__c);

            
                                                  
                                                  system.debug(accJudgList.Judgment__c+'==='+accJudgList.Product__r.Company_Name__c);
        }
        
        AggregateResult[] groupedResults  = [SELECT SUM(Product__r.Current_Principal_Balance__c)  currentPrincipalBalance, 
                                                 SUM(Product__r.Current_Interest_Amount__c) currentInterestBalance,
                                                 Judgment__c  
                                              FROM 
                                                 Account_Judgment__c
                                               WHERE 
                                                 Judgment__c IN: judgmentIds AND Status__c = 'Active'
                                             GROUP BY 
                                                 Judgment__c];
        List<Judgment__c> judgList = new List<Judgment__c>();
        List<Id> judgUpdate = new List<Id>();
        system.debug('groupedResults'+groupedResults);
        for(AggregateResult aggRes: groupedResults){
            system.debug('groupedResults'+aggRes.get('Judgment__c'));
            if((Id)aggRes.get('Judgment__c')!= NULL){
                Judgment__c judg = new Judgment__c();
                judg.Current_Principal_Balance__c = (Decimal)aggRes.get('currentPrincipalBalance');
                judg.Current_Interest_Balance__c  = (Decimal)aggRes.get('currentInterestBalance');
                judg.Id = (Id)aggRes.get('Judgment__c');

                system.debug('judgmentIdCompanyNameMap.containsKey(judg.Id) '+judgmentIdCompanyNameMap.containsKey(judg.Id));
                if(judgmentIdCompanyNameMap.containsKey(judg.Id)){
                    judg.Company_Name__c = judgmentIdCompanyNameMap.get(judg.Id);
                }
                if(judgmentIdPurchaseEntityMap.containsKey(judg.Id)){
                    judg.Plaintiff__c = judgmentIdPurchaseEntityMap.get(judg.Id);
                }
                judgUpdate.add(judg.Id);
                judgList.add(judg);
            }

        }
        judgmentIds.removeAll(judgUpdate);
        
        for(Id judgId: judgmentIds){
            Judgment__c judg = new Judgment__c();
            judg.Id = judgId;
            judg.Current_Principal_Balance__c = null;
            judg.Current_Interest_Balance__c = null;
            judgList.add(judg);
        }
        system.debug('judgList==='+judgList);
        if(judgList.size() > 0){
            //JudgmentTriggerHandler.runJudgmentTrigger = False;
            configSetting.Send_Notification__c = false;
            update judgList;
            configSetting.Send_Notification__c = true;
            //JudgmentTriggerHandler.runJudgmentTrigger = True;
        }
    }
    
    //Bug: 5564 Commented below method
    //To Populate the Placement Ids on Judgment
  /*  public static void populateJudgmentWithPlacement(List<Account_Judgment__c> prodJudgList){
        
        Map <Id, String> placementIDMap = new Map<Id, String>();
        Set<ID> judgmentSet = new Set<ID>();
        Set<ID> productSet = new Set<ID>();
        Map<ID, Judgment__C> judgmentMap = new Map<ID, Judgment__C>();
        Map<ID, Product__C> ProductMap = new Map<Id, Product__C>();
        
        for(Account_Judgment__c prodJudg : prodJudgList){
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }
        
        //Fetch all related products
        //List<Product__c> listProduct = [select id, Collection_Agency__C from Product__C where id in :productSet];
        //Fetch all accounts judgments related to Judgments
        List<Account_Judgment__c> listAccountJudgment = [select id, Judgment__C, Product__c from Account_Judgment__c where Judgment__C in :judgmentSet];
        
        for(Account_Judgment__c prodJudg : listAccountJudgment ){
            judgmentSet.add(prodJudg.Judgment__C);
            productSet.add(prodJudg.Product__c);
        }
        
        List<Product__c> listProduct = [select id, Collection_Agency__C from Product__C where id in :productSet];
        
        for(Account_Judgment__c prodJudg : listAccountJudgment){
           
           for(Product__C prod : listProduct){
               if(prod.id == prodJudg.Product__C){
                   productMap.put(prodJudg.id, prod);
               }
           }
        }
        
        //recalculate the Collection agency identifer for all related judgmets
        Map<ID, String> judgmentUpdate = new Map<Id, String>();
        Map<ID, String> judgmentExternalIdentifierUpdate = new Map<Id, String>();
        String collectionAgencyidentifier = '';
        String externalCollectionAgency = '';
        for(Account_Judgment__c prodJudg : listAccountJudgment){
            Product__c prod = productMap.get(prodJudg.id);
            if(null == prod)
                continue;
            if(null == prod.Collection_Agency__C){
                collectionAgencyidentifier = SEPARATOR + UNPLACED + SEPARATOR;
            }else{
                collectionAgencyidentifier = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                //populate External Collection Agency identifier
                if(prod.Collection_Agency__C != 6 && prod.Collection_Agency__C != 68){
                    externalCollectionAgency = SEPARATOR + prod.Collection_Agency__C + SEPARATOR;
                }
            }
            
            system.debug('externalCollectionAgency: '+externalCollectionAgency);
            String IdentifierList = '';
            //String ExternalIdentifierList = '';
            IdentifierList = judgmentUpdate.get(prodJudg.Judgment__c);
            //ExternalIdentifierList = judgmentExternalIdentifierUpdate.get(prodJudg.Judgment__c);
            if(String.isBlank(IdentifierList)){
                IdentifierList = collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            }else if((IdentifierList).contains(collectionAgencyidentifier)){
                //Do Nothing
            }else{
                IdentifierList += collectionAgencyidentifier;
                judgmentUpdate.put(prodJudg.Judgment__c, IdentifierList);
            }
            //system.debug('ExternalIdentifierList: '+ExternalIdentifierList);
            if(String.isNotBlank(externalCollectionAgency)){
                judgmentExternalIdentifierUpdate.put(prodJudg.Judgment__c, externalCollectionAgency);
            }
        }
        
        system.debug('judgmentExternalIdentifierUpdate: '+judgmentExternalIdentifierUpdate);
        //Save the Judgments
        List<Judgment__C> listJudgment = new List<Judgment__c>();
        if(judgmentUpdate.size() > 0){
            for(ID judgmentID : judgmentUpdate.keySet()){
                Judgment__c judge = new Judgment__c();
                
                judge.Collection_Agency_Identifier__c = judgmentUpdate.get(judgmentID);
                //populate External Collection Agency identifier
                judge.External_Collection_Agency_Identifier__c = judgmentExternalIdentifierUpdate.get(judgmentID);
                judge.id = judgmentID;
                if(null != judge.id){
                    listJudgment.add(judge);
                }
            }
           JudgmentTriggerHandler.runJudgmentTrigger = false;
          // configSetting.Send_Notification__c = false;
           update listJudgment;
          // configSetting.Send_Notification__c = true;
            JudgmentTriggerHandler.runJudgmentTrigger = true;
        }
    }
    */
    //When we create judgment on product then we are populating product1,2,3,4,5 on judgment
    public static void populateProductNameOnJudgment(list<Account_Judgment__c> listAccJudgment){
        system.debug('populateProductNameOnJudgment');
        set<Id> productId = new set<Id>();
        set<Id> judgmentId = new set<Id>();
        List<Judgment__c> listJudgment = new List<Judgment__c>();
        for(Account_Judgment__c lstAccjudg : listAccJudgment){
            productId.add(lstAccjudg.Product__c);
            judgmentId.add(lstAccjudg.Judgment__c);
        }
        system.debug('listAccJudgment:::'+listAccJudgment);
        Judgment__c judgRecord;
        Product__c prod;
        if(judgmentId != Null){
          judgRecord = [select id,name,Product_1__c,Product_2__c,Product_3__c,Product_4__c,Product_5__c,
                        Agency_Initiated_Legal_Action__c,Judgment_Province__c
                        from Judgment__c where id =: judgmentId];
        }
        if(productId != Null){
            prod =[select id,name,Collection_Agency__c ,State__c from product__c where id =: productId];
        }
        //validationRulesProductToJudgment(judgRecord,prod);
        system.debug('prod:::'+prod);
        for(Account_Judgment__c lstAccjudg1 : listAccJudgment){
            system.debug('Product_1__c'+judgRecord.Product_1__c);
            Judgment__c judg = new Judgment__c();
            if(judgRecord.Product_1__c == Null){
                system.debug('Block run 1');
                judg.Id = lstAccjudg1.Judgment__c;
                judg.Product_1__c = prod.Name;         
                listJudgment.add(judg);
            }else if(judgRecord.Product_2__c == Null){
                system.debug('Block run 2');
                judg.Id = lstAccjudg1.Judgment__c;
                judg.Product_2__c = prod.Name;         
                listJudgment.add(judg);
            }else if(judgRecord.Product_3__c == Null){
                system.debug('Block run 3');
                judg.Id = lstAccjudg1.Judgment__c;
                judg.Product_3__c = prod.Name;         
                listJudgment.add(judg);
            }else if(judgRecord.Product_4__c == Null){
                system.debug('Block run 4');
                judg.Id = lstAccjudg1.Judgment__c;
                judg.Product_4__c = prod.Name;         
                listJudgment.add(judg);
            }else if(judgRecord.Product_5__c == Null){
                system.debug('Block run 5');
                judg.Id = lstAccjudg1.Judgment__c;
                judg.Product_5__c = prod.Name;         
                listJudgment.add(judg);
            }
        }
        system.debug('listJudgment Check***'+listJudgment);
        // configSetting.Send_Notification__c = FALSE;
         JudgmentTriggerHandler.runJudgmentTrigger = false;
         update listJudgment;
        // configSetting.Send_Notification__c = TRUE;
         JudgmentTriggerHandler.runJudgmentTrigger = true;
    }
    /*public static void validationRulesProductToJudgment(Judgment__c judgRecord,Product__c prod){
        String prod1ProvinceName;
        String prod1ProvinceNameFormat;
        String prod1provinceAcronymFormat;
        if(prod.State__c != NULL){
            prod1ProvinceName = prod.State__c;
            prod1ProvinceNameFormat = nameFormat(prod1ProvinceName);
            prod1provinceAcronymFormat = prod1ProvinceName.toUpperCase();
        }
        if(judgRecord.Agency_Initiated_Legal_Action__c != String.valueOf(Math.floor(prod.Collection_Agency__c)) 
           && (judgRecord.Judgment_Province__c != prod1ProvinceNameFormat || judgRecord.Judgment_Province__c != prod1provinceAcronymFormat)){
               
               judgRecord.addError('Product1 Province and Agency shoule be same as Judgment Province and Agency');
        }
    }*/
    
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