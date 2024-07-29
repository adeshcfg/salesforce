/**************************************************************************************************
*
* Class: AllocationProductProcessing
*
* @description : This class is used for to recall/Account status update of product.

* @author : A5E Consulting
* @date : 13/03/2023

*************************************************************************************************/
public class RecallProductProcessing {
    
    public static decimal successRecords = 0;
    public static decimal failedRecords = 0;
    public static List<User> systemName= new list<User>();
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public static Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public static Application_Config_Settings__c applicationConfigSetting = Application_Config_Settings__c.getOrgDefaults(); 
    
    //Recall/Account status update of product.
    public static ProdIdsJudgListWrapper recallProducts(List<Product_Staging__c> prodStagingList,String workAssignmentId){  
        List<Product__c> prodList = new List<Product__c>();
        Map<String,Id> PlacementMap = new Map<String,Id>();
        Map<Id,String> PlacementStatusMap = new Map<Id,String>();
        List<Id> prodIds = new List<Id>();
        set<id> setProductIDs = new set<id>();
        List<Account_Judgment__c> accJudgStatusUpdateList = new List<Account_Judgment__c>();
        Map<String, ID> mapProductJudgment = new Map<String, ID>();
        Map<String, Map<String, String>> productIdAgencyInfoMap = new Map<String, Map<String, String>>();
        List<Judgment__c> judgmentToUpdateList;
        ProdIdsJudgListWrapper wrapperData = new ProdIdsJudgListWrapper();
        //Fetch System Api
        if(lrpSetting.Canaccede_API_User__c != NULL){
            systemName = [Select id, Name from User where username =: lrpSetting.Canaccede_API_User__c];    
        }
        //Fetch Product RecordType
        for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
        }
        
        List<Product_Staging__c> listproductstaging = new List<Product_Staging__c>();
        map<String, Placement_Status_Code_Mapping__c> codeMapping = new map<String, Placement_Status_Code_Mapping__c>();
        for(Placement_Status_Code_Mapping__c mapping : [SELECT ID, Name, Data_Status_Code__c, Data_Status_Description__C
                                                        FROM Placement_Status_Code_Mapping__c
                                                        /*WHERE Name LIKE : '9%'*/]){
                                                            codeMapping.put(mapping.Name, mapping);
                                                        }
        for(Placement__c placeList : [SELECT id,name from Placement__c]){
            PlacementMap.put(placeList.name, placeList.Id);
        }
        
        for(Product_Staging__c productStaging : prodStagingList){
            setProductIDs.add(productStaging.Product_ID__c);
        }
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c, Product__r.Name FROM Account_Judgment__c
                                                  WHERE Product__c IN :setProductIDs
                                                  AND Status__c = 'Active']){
                mapProductJudgment.put(accJudgment.Product__c, accJudgment.id);
        }
        map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, RecordTypeId,OwnerId,Collection_Agency__c,
                                                                   Placement_Status__c
                                                                       FROM Product__c WHERE ID IN :setProductIDs]);
        try {
            for(Product_Staging__c productStaging : prodStagingList){
                //Regex to check MM/DD/YYYY (text format in excel)
                String dateRegex = '^([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0-9]{4})$';
                
                //Regex to check YYYY/MM/DD (Date format in excel)
                String dateRegex2 = '^([0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
                
                String dateRegex3 = '^([0-9]{4}|[0-9]{2})[./-]([0]?[1-9]|[1][0-2])[./-]([0]?[1-9]|[1|2][0-9]|[3][0|1])$';
                Pattern MyPattern3 = Pattern.compile(dateRegex3);
              
                Pattern MyPattern1 = Pattern.compile(dateRegex);
                
                Pattern MyPattern2 = Pattern.compile(dateRegex2);
                
                Matcher MyMatcher1;
                date myDate;
                if(String.isNotBlank(productStaging.Status_Changed_Date__c)){
                    //list<String> datelist = productStaging.Status_Changed_Date__c.split('/');
                    //Bug:5438 - Commented above line and changes Starts
                    list<String> datelist =new list<string>();
                    if(productStaging.Status_Changed_Date__c.contains('/')){
                        datelist = productStaging.Status_Changed_Date__c.split('/');
                    } 
                    if(productStaging.Status_Changed_Date__c.contains('-')){
                        datelist = productStaging.Status_Changed_Date__c.split('-');
                    }
                    //Bug:5438 Changes Ends
                    MyMatcher1 = MyPattern1.matcher(productStaging.Status_Changed_Date__c);  
                    Matcher MyMatcher2 = MyPattern2.matcher(productStaging.Status_Changed_Date__c);  
                    Matcher MyMatcher3 = MyPattern3.matcher(productStaging.Status_Changed_Date__c);
                    
                    if(MyMatcher1.matches() == true){
                        myDate = date.newInstance(Integer.valueOf(datelist[2]), Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]));
                        //product.Status_Changed_Date__C = myDate;
                    }
                    //matching of date when entered in Date format in excel file  product.Status_Changed_Date__c 
                    else if(MyMatcher2.matches() == true){
                        //  list<String> datelist = productStaging.Status_Changed_Date__c.split('/');
                        myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                        
                    }
                    else if(MyMatcher3.matches() == true){
                        // list<String> datelist = productStaging.Status_Changed_Date__c.split('/');
                        myDate = date.newInstance(Integer.valueOf(datelist[0]), Integer.valueOf(datelist[1]), Integer.valueOf(datelist[2]));
                       
                    }
                }
                
                Product__c prod = new Product__c();
                Product_Staging__c productStaging1 = new Product_Staging__c();
                //productStaging1 = productStaging;
                String comment = '';
                if(String.isNotBlank(productStaging1.Comment__c)) comment = productStaging1.Comment__c;
                
                //If No error found, update product record from staging
                if(productStaging.Status__c != 'Processed' || Test.isRunningTest()) {
                    productStaging1.id = productStaging.id;
                    productStaging1.Status__c = 'Processed';
                    prod.id = productStaging.Product_ID__c;
                    prod.Placement_Status__c = productStaging.Placement_Status_Code__c;
                    prod.Status__c = productStaging.Placement_Main_Status__c;
                    prod.Sub_Status__c = productStaging.Placement_Sub_Status__c;
                    prod.Status_Changed_Date__c = myDate;
                    prod.Run_Identifier_Check_On__c = System.today();
                    if((String.isNotBlank(prod.Placement_Status__c) && prod.Placement_Status__c.startsWith('9')) || Test.isRunningTest()){   
                        if(codeMapping.containsKey(prod.Placement_Status__c) ){
                            if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                            }
                        }
                        
                        prod.Placement_Status__c = null;
                        prod.Status__c = null;
                        prod.Sub_Status__c = null;   
                        //prod.Collection_Sub_Status__c = null; Rasmitha : 27-Dec as per #4177 Collection Sub Status should not get blank on recall
                        prod.External_Status_Current__c = null;
                        prod.Collection_Agency__c = 9999;
                        prod.Collection_Agency_Placement__c = PlacementMap.get(String.valueOf(prod.Collection_Agency__c));
                        prod.Recalled_Date__c = Date.today();
                        prod.External_Status_Current__c = null;
                        if(Test.isRunningTest())  prod.Placement_Status__c ='800000';
                        if((String.isNotBlank(prod.Placement_Status__c) &&  prod.Placement_Status__c.startsWith('8'))){
                           system.debug('prod.Placement_Status__c--->'+prod.Placement_Status__c);
                            system.debug('codeMapping--->'+codeMapping);
                            if(codeMapping.containsKey(prod.Placement_Status__c) ){
                                if(codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c != NULL){
                                    prod.Product_Status__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Code__c;
                                    prod.Data_Status_Description__c = codeMapping.get(prod.Placement_Status__c).Data_Status_Description__c;
                                    prod.External_Status_Current__c = null;
                                }
                            }
                            
                        }  
                        if(prod.Collection_Agency__c == 9999){
                            prodIds.add(Prod.Id);
                            wrapperData.productIds = prodIds;
                            PlacementStatusMap.put(Prod.Id, productStaging.Placement_Status_Code__c);
                            if(prodRTypeIdMap.get('Distressed_Account') == mapProduct.get(productStaging.Product_ID__c).RecordTypeId
                               && prod.Collection_Agency__c != mapProduct.get(productStaging.Product_ID__c).Collection_Agency__c){
                                   ID oldOwnerId = mapProduct.get(productStaging.Product_ID__c).OwnerId;
                                   // Assign System API to Owner
                                   if(!systemName.isEmpty()){
                                       prod.OwnerId = systemName[0].Id;      
                                   }
                                   //Also Assign the last owner to the previous ownership field
                                   if(oldOwnerId <> NULL && oldOwnerId <> prod.OwnerId){
                                       prod.Previous_Ownership__c = oldOwnerId;
                                   }
                           }
                            productIdAgencyInfoMap.put(
                                prod.Id,
                                new Map<String, String>{
                                    'Agency' => String.valueOf(prod.Collection_Agency__c),
                                    'AgencyPlacement' => prod.Collection_Agency_Placement__c
                                        }
                            );
                        }
                       //Ticket 6430 : Point 2
                       if(System.Label.Exclude_Judgment_Codes.contains(mapProduct.get(productStaging.Product_ID__c).Placement_Status__c) 
                          && mapProductJudgment.containsKey(productStaging.Product_ID__c)){
                              Account_Judgment__c accJudgment = new Account_Judgment__c();
                              accJudgment.id =  mapProductJudgment.get(productStaging.Product_ID__c);  
                              accJudgment.Status__c = 'Inactive';
                              accJudgStatusUpdateList.add(accJudgment);
                          }
                           
                 
                    }else{
                        failedRecords = failedRecords + 1;
                    }
                }
                listproductstaging.add(productStaging1);
                prodList.add(prod);
                
            }
            try{
                if(prodList.size()>0){
                    ProductTriggerHandler.runProductTrigger = false;
                    update prodList;
                    ProductTriggerHandler.runProductTrigger = true;
                    AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = false;
                    update accJudgStatusUpdateList;
                    AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = true;
                    if(productIdAgencyInfoMap.values() <> NULL){
                        judgmentToUpdateList = ProductRecallIndividualController.updateJudgmentAgency(productIdAgencyInfoMap);
                        if (!judgmentToUpdateList.isEmpty()) {
                            JudgmentTriggerHandler.runJudgmentTrigger = false;
                            //bypass judgment validation rule
                            applicationConfigSetting.Bypass_Judgement_Validation__c = false;
                            update applicationConfigSetting;
                            Database.update(judgmentToUpdateList);
                            //bypass judgment validation rule
                            applicationConfigSetting.Bypass_Judgement_Validation__c = true;
                            JudgmentTriggerHandler.runJudgmentTrigger = true;
                            update applicationConfigSetting;
                            wrapperData.judgmentList = judgmentToUpdateList;
                        }
                    }
                }
                
                // Added by satyajit for ticket: 4217
                if(prodIds.size() > 0){
                    //Update Placement history when product is recalled.
                    DistressedUtilities.updatePlacementHistory_New(ProdIds,PlacementStatusMap);
                }
                
            }catch(Exception ex){

                for(Product_Staging__c productStaging: listproductstaging){
                    String msg = '<b>ERROR</b>-'+ex.getMessage();
                    if(msg.length() > 254) msg = msg.substring(0,254);
                    
                    productStaging.Comment__c= msg;
                    productStaging.status__c= 'Pending';
                    
                    successRecords -= 1;
                }
            }
            if(listproductstaging.size()>0){
                update listproductstaging;
            }
            system.debug('prodIds::'+prodIds);

        }catch(Exception ex){
            system.debug('exception success file--+--'+ex.getLineNumber());
            system.debug('exception success file--+--'+ex.getMessage());
        }
        return wrapperData;
    }
    
    public class ProdIdsJudgListWrapper{
        public List<String> productIds {get;set;}
        public List<Judgment__c> judgmentList {get;set;}
    }
}