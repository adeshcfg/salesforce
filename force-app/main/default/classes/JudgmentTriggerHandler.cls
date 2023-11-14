/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Judgment object 
*  @author : A5E Consulting
*  @date : 21/08/2019
*  
*************************************************************************************************/

public class JudgmentTriggerHandler {
    public static Map<String, Id> collectionAgency = new Map<String, Id>();
    public static string prodProvinceName;
    public static string ProvinceNameFormat;
    public static string provinceAcronymFormat;
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
    public static boolean runJudgmentTrigger = true;
   //Bug: 5564 Changes Starts
    public static string SEPARATOR = 'A';
    public static string UNPLACED = 'unplaced';
    //Bug: 5564 Changes Ends
    static{
        for(Placement__c place : [select id, Name, Agency_Name__c from Placement__c]){
            collectionAgency.put(place.Name, place.Id);
            //system.debug('Collection ' +collectionAgency);    
        }
        
        //Tax rate mapping by Province Acronym
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
    }
    
    public static void handleBeforeInsert(list<Judgment__c> listNewJudgments){
        system.debug('inside handleBeforeInsert judgment');
        // map <String, Judgment_product_codes_mapping__c> mapRecallCodeStatus = new  map <String, Judgment_product_codes_mapping__c>() ; 
        list<Judgment__c> listInternalNewJudgment = new list<Judgment__c>();  
        
        list<String> listJudgmentStatuses = new list<String>();
        for(Judgment__c judgRecord : listNewJudgments){
            listJudgmentStatuses.add(judgRecord.Legal_Status__c);
            
            
            if(judgRecord.Court__c == 'Small Claims Court'
               && judgRecord.Small_Claims_Court__c == null
              ){
                  judgRecord.Small_Claims_Court__c.addError('Small Claims Court can not be blank');
              }
            if(judgRecord.Court__c == 'Superior Court of Justice'
               && judgRecord.Superior_Court__c == null
              ){
                  judgRecord.Superior_Court__c.addError('Superior Court of Justice can not be blank');
              }
            
            
            judgRecord.Created_By__c =  UserInfo.getName();
            
            if(judgRecord.Agency_Initiated_Legal_Action_Lookup__c <> NULL ){
                listInternalNewJudgment.add(judgRecord);
            }
            
            if(judgRecord.Superior_Court__c <> NULL){
                listInternalNewJudgment.add(judgRecord);
            }
            
            if(judgRecord.Small_Claims_Court__c <> NULL ){
                listInternalNewJudgment.add(judgRecord);
            }
            
            if(judgRecord.Enforcement_County__c <> NULL ){
                listInternalNewJudgment.add(judgRecord);
            }
            
            if(judgRecord.County__c <> NULL ){
                listInternalNewJudgment.add(judgRecord);
            }
        }
        
        //method calls once record created in CFG
        getJudgmentRelatedData(listInternalNewJudgment);
        system.debug('listNewJudgments'+listNewJudgments);
        system.debug('listJudgmentStatuses'+listJudgmentStatuses);
        //validationRulesProductToJudgment(listNewJudgments,listJudgmentStatuses);
        //update product Placement statuses
        //if(JudgmentTriggerHandler.runUpdateProductStatus){
        updateProductStatusesOnJudgment(listNewJudgments, listJudgmentStatuses); 
        //}
        
        
        //get Judgment Balance According to Product
        getJudgmentBalance(listNewJudgments);
        //updateAgencyOnJudgment(listNewJudgments);
    }
    
    public static void updateAgencyOnJudgment(list<Judgment__c> listNewJudgments){
         map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>();
         Set<ID> mapProdId =new Set<ID>();
         map<ID,Product__c> mapProd = new map<ID,Product__c>();
        List<ID> JudId = new List<ID>(); 
        system.debug('updateAgencyOnJudgment listNewJudgments'+listNewJudgments);
        for(Judgment__c judgmentData:listNewJudgments){
            JudId.add(judgmentData.id);

        }
        system.debug('updateAgencyOnJudgment JudId'+JudId);
        //Get the active account judgment
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c,Product__r.name
                                               FROM Account_Judgment__c
                                               WHERE Judgment__c IN :JudId
                                               AND Status__c= 'Active'
                                              ]){
                                                  mapActiveAccountJudgments.put(accJudgment.Judgment__c , accJudgment.Product__c);
                                                  mapProdId.add(accJudgment.Product__c);  
                                             }
        system.debug('mapProdId***'+mapProdId);
        system.debug('mapActiveAccountJudgments***'+mapActiveAccountJudgments);
        for(Product__c prod : [SELECT ID,Name, Collection_Agency__c,Collection_Agency_Placement__c ,State__c,
                               Status__c,Sub_Status__c,Account_Purchasing_Entity_Value__c
                               FROM Product__c WHERE ID = :mapProdId ]){
                                   mapProd.put(prod.id,prod);                    
                               } 
        
        system.debug('mapProd***'+mapProd);
        Map<id,Judgment__c> judMapData = new Map<id,Judgment__c>();
        //Populate Agency from Product to Judgment.
        for(Judgment__c judgment : listNewJudgments){
            if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                system.debug('inside product check');
                if(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Collection_Agency__c != NULL){
                    system.debug('inside judgment');
                    judgment.Agency_Initiated_Legal_Action__c = String.valueOf(Math.floor(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Collection_Agency__c));                   
                }
                if(String.isNotBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    
                    judgment.Agency_Initiated_Legal_Action_Lookup__c = collectionAgency.get(judgment.Agency_Initiated_Legal_Action__c);
                    
                }else{
                    judgment.Agency_Initiated_Legal_Action_Lookup__c = Null;
                }
            }
            system.debug('inside judgment%%'+judgment);
            judMapData.put(judgment.id,judgment);
        }
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        update judMapData.values();
        JudgmentTriggerHandler.runJudgmentTrigger = True;
    }
    //method to update Placement Main Status and Sub STatus on Product based on Legal statuses
    public static void updateProductStatusesOnJudgment(list<Judgment__c> listNewJudgments, list<String> listLegalStatuses){
        system.debug('inside updated status');
        list<Product__c> listProduct = new list<Product__c>();
        Map<Id,Product__c> productMap = new Map<Id,Product__c>();
        Map<Id,Product__c> productMapTest = new Map<Id,Product__c>();
        list<Account_Judgment__c> listActiveJudgments = new list<Account_Judgment__c>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>();
        map<ID, ID> mapJudgments = new map<ID, ID>();
        Set<ID> mapProdId =new Set<ID>();
        map<ID,Product__c> mapProd = new map<ID,Product__c>();
        map<String,ID> mapProductName = new map<String,ID>(); 
        
        
        
        system.debug('listLegalStatuses'+listLegalStatuses);
        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                         Product_Sub_status__c,Judgment_Legal_Status__c,
                                                         Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                         WHERE Product_Parent__c IN :listLegalStatuses ]){
                                                             mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);
                                                         }
        system.debug('mapAccountJudgmentCodes'+mapAccountJudgmentCodes);
        system.debug('listNewJudgments'+listNewJudgments);
        //Get the active account judgment
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c,Product__r.name
                                               FROM Account_Judgment__c
                                               WHERE Judgment__c IN :listNewJudgments
                                               AND Status__c= 'Active'
                                              ]){
                                                  mapActiveAccountJudgments.put(accJudgment.Judgment__c , accJudgment.Product__c);
                                                  mapProductName.put(accJudgment.Product__r.name,accJudgment.Product__c);                             
                                                  mapProdId.add(accJudgment.Product__c);
                                              }
        
        system.debug('mapActiveAccountJudgments' +mapActiveAccountJudgments);
        system.debug('mapProductName' +mapProductName);
        system.debug('mapProdId' +mapProdId);
        
        for(Product__c prod : [SELECT ID,Name, Collection_Agency__c,Collection_Agency_Placement__c ,State__c,
                               Status__c,Sub_Status__c,Account_Purchasing_Entity_Value__c
                               FROM Product__c WHERE ID = :mapProdId ]){
                                   mapProd.put(prod.id,prod);                    
                               }
        
        system.debug('listNewJudgments***'+listNewJudgments);
        system.debug('mapActiveAccountJudgments'+mapActiveAccountJudgments);
        for(Judgment__c judgment : listNewJudgments){
            if(mapActiveAccountJudgments.containsKey(judgment.ID)){
                system.debug('inside check');
                Product__c product;
                /*product.ID = mapActiveAccountJudgments.get(judgment.ID);
if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
}
if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
}
if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
}*/
                
                //Populate Agency from Product to Judgment.
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Collection_Agency__c != NULL){
                        //judgment.Agency_Initiated_Legal_Action__c = String.valueOf(Math.floor(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Collection_Agency__c));                   
                        judgment.Placed_Agency__c = String.valueOf(Math.floor(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Collection_Agency__c));
                    }
                }
                
                system.debug('judgment.Product_1__c***'+judgment.Product_1__c);
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(judgment.Product_1__c == Null){
                        judgment.Product_1__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name;
                        system.debug('check judgment.Product_1__c***'+judgment.Product_1__c);
                    }//else{
                    if(mapProductName.containsKey(judgment.Product_1__c)){
                        product = new Product__c();
                        product.ID = mapProductName.get(judgment.Product_1__c);
                        system.debug('product.ID'+product.ID);
                        system.debug('jud Check'+judgment.Legal_Status__c+judgment.Legal_Sub_Status__c);
                        system.debug('mapAccountJudgmentCodes Check'+mapAccountJudgmentCodes);
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            system.debug('inside legal status sub status');
                            product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
                        }
                        system.debug('product.Status__c'+product.Status__c);
                        system.debug('product.Sub_Status__c'+product.Sub_Status__c);
                        system.debug('product.Placement_Status__c'+product.Placement_Status__c);
                        productMap.put(product.Id,product);
                    }
                    // }
                }
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(judgment.Product_2__c == Null && judgment.Product_1__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name){
                        judgment.Product_2__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name;
                    }
                    //else{
                    system.debug('inside else');
                    if(mapProductName.containsKey(judgment.Product_2__c)){
                        system.debug('inside else prod 2');
                        product = new Product__c();
                        product.ID = mapProductName.get(judgment.Product_2__c);
                        system.debug('product.ID'+product.ID);
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
                        }
                        productMap.put(product.Id,product);
                    }
                    // } 
                }
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(judgment.Product_3__c == Null && judgment.Product_1__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_2__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name){
                           judgment.Product_3__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name;                               
                       }
                    //else{
                    if(mapProductName.containsKey(judgment.Product_3__c)){
                        product = new Product__c();
                        product.ID = mapProductName.get(judgment.Product_3__c);
                        system.debug('product.ID'+product.ID);
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
                        }
                        productMap.put(product.Id,product);
                    }                                      
                    //}
                }
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(judgment.Product_4__c == Null && judgment.Product_1__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_2__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_3__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name){
                           judgment.Product_4__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name;                               
                       }
                    //else{
                    if(mapProductName.containsKey(judgment.Product_4__c)){
                        product = new Product__c();
                        product.ID = mapProductName.get(judgment.Product_4__c);
                        system.debug('product.ID'+product.ID);
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
                        }
                        productMap.put(product.Id,product);
                    }                                    
                    //}
                }
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(judgment.Product_5__c == Null && judgment.Product_1__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_2__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_3__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name
                       && judgment.Product_4__c != mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name){
                           judgment.Product_5__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Name;                                
                       }
                    //else{
                    if(mapProductName.containsKey(judgment.Product_5__c)){
                        product = new Product__c();
                        product.ID = mapProductName.get(judgment.Product_5__c);
                        system.debug('product.ID'+product.ID);
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Sub_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Product_Sub_status__c;    
                        }
                        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c)){
                            product.Placement_Status__c = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;    
                        }
                        productMap.put(product.Id,product);
                    }                                    
                    //}
                }
                
                system.debug('judgment***'+judgment);
                system.debug('judgment Product_1__c***'+judgment.Product_1__c);
                //Populate Province from Product to Judgment.
                if(mapProd.containsKey(mapActiveAccountJudgments.get(judgment.ID))){
                    if(mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).State__c != NULL){
                        prodProvinceName = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).State__c;
                        ProvinceNameFormat = nameFormat(prodProvinceName);
                        provinceAcronymFormat = prodProvinceName.toUpperCase();
                        if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                            judgment.Judgment_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c; 
                            judgment.Placed_Province__c = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                            system.debug('judgment.Placed_Province__c::'+judgment.Placed_Province__c);
                        }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                            judgment.Judgment_Province__c = ProvinceNameFormat; 
                            judgment.Placed_Province__c = ProvinceNameFormat;
                        }
                    }
                    judgment.Plaintiff__c = mapProd.get(mapActiveAccountJudgments.get(judgment.ID)).Account_Purchasing_Entity_Value__c;
                }
                
                
                
                //if(!(listProduct.contains(product))){
                //  system.debug('Inside ListProduct **');
                //listProduct.add(product);
                //productMap.put(product.Id,product);
                //}
                
                
                
            }
            
        }
        system.debug('productMap***'+productMap);
        system.debug('listProduct'+listProduct);
        //update product list
        ProductTriggerHandler.runProductTrigger = false;
        //update listProduct; 
        update productMap.values();
        ProductTriggerHandler.runProductTrigger = true;
        //validation for Judgment Statuses
        validationRulesProductToJudgment(listNewJudgments,listLegalStatuses);
    }
    
    public static void handleBeforeUpdate(list<Judgment__c> listNewJudgments, map<Id, Judgment__c> mapOldJudgment){
        system.debug('inside before update');
        list<Judgment__c> listInternalNewJudgment = new list<Judgment__c>();
        list<Judgment__c> listExternalNewJudgment = new list<Judgment__c>();
        Agency_Portal_Settings__c postJudgRcodtypId = Agency_Portal_Settings__c.getOrgDefaults();
        list<String> listJudgmentStatuses = new list<String>();

        for(Judgment__c judgmentObj : listNewJudgments){
            listJudgmentStatuses.add(judgmentObj.Legal_Status__c);
            
            
            if(judgmentObj.Court__c == 'Small Claims Court'
               && judgmentObj.Small_Claims_Court__c == null
              ){
                  judgmentObj.Small_Claims_Court__c.addError('Small Claims Court can not be blank');
              }
            if(judgmentObj.Court__c == 'Superior Court of Justice'
               && judgmentObj.Superior_Court__c == null
              ){
                  judgmentObj.Superior_Court__c.addError('Superior Court of Justice can not be blank');
              }
            
            
            //set Run Identifier Check on Judgment if collection identifier is changed
            
            judgmentObj.Last_Modified_By__c =  UserInfo.getName();
            Boolean identifierRemovalFlag = false;
            
            Judgment__c JudgmentOld= mapOldJudgment.get(judgmentObj.id);
            
            if(judgmentObj.Superior_Court__c != NULL){
                if(judgmentObj.Superior_Court__c != JudgmentOld.Superior_Court__c){
                    listInternalNewJudgment.add(judgmentObj);
                }
            }
            else{
                judgmentObj.Superior_Court_Identifier__c = NULL;
            }
            
            if(judgmentObj.Small_Claims_Court__c != NULL){
                if(judgmentObj.Small_Claims_Court__c != JudgmentOld.Small_Claims_Court__c){
                    listInternalNewJudgment.add(judgmentObj);
                }
            }
            else{
                judgmentObj.Small_Claims_Court_Identifier__c = NULL;
            }
            
            if(judgmentObj.Enforcement_County__c != NULL){
                if(judgmentObj.Enforcement_County__c != JudgmentOld.Enforcement_County__c){
                    listInternalNewJudgment.add(judgmentObj);
                }
            }
            else{
                judgmentObj.Enforcement_County_Identifier__c = NULL;
            }
            
            if(judgmentObj.County__c != NULL){
                if(judgmentObj.County__c != JudgmentOld.County__c){
                    listInternalNewJudgment.add(judgmentObj);
                }
            }
            else{
                judgmentObj.County_Identifier__c = NULL;
            }
            
            
            if(String.isNotBlank(judgmentObj.Collection_Agency_Identifier__c)
               && judgmentObj.Collection_Agency_Identifier__c != mapOldJudgment.get(judgmentObj.Id).Collection_Agency_Identifier__c){
                   judgmentObj.Run_Identifier_Check_On__c = Date.today();
               }
            
            
            //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
            if(String.isNotBlank(String.ValueOf(judgmentObj.Legal_Agency__c))){
                
                judgmentObj.Legal_Agency_Placement__c = collectionAgency.get(String.ValueOf(judgmentObj.Legal_Agency__c));
                
                
                
            }else{
                judgmentObj.Legal_Agency_Placement__c = Null;
            }
            
            //Ticket-LRT#972973 - Enhancements to search results in Product Search - Display Agency Name (not number)
            /*if(String.isNotBlank(String.ValueOf(judgmentObj.Agency_Initiated_Legal_Action__c))){
                
                judgmentObj.Agency_Initiated_Legal_Action_Lookup__c = collectionAgency.get(String.ValueOf(judgmentObj.Agency_Initiated_Legal_Action__c));
                
            }else{
                judgmentObj.Agency_Initiated_Legal_Action_Lookup__c = Null;
            }*/
            //Refering only Lindsay validation sheet
            /*if(judgmentObj.Legal_Status__c != mapOldJudgment.get(judgmentObj.Id).Legal_Status__c){
validationRules(listNewJudgments,mapOldJudgment);
}*/
            
            //Converted 'Post-Judgment-Vacated' workflow rule into code.
            if(judgmentObj.Legal_Status__c == 'Post-Judgment' && judgmentObj.Legal_Sub_Status__c == 'Vacated'){
                system.debug('postJudgRcodtypId.Post_Judgment_RecordTypeId__c:::'+postJudgRcodtypId.Post_Judgment_RecordTypeId__c);
                judgmentObj.RecordTypeId = postJudgRcodtypId.Post_Judgment_RecordTypeId__c;
            }
        }
        
        //method calls once record created/update in CFG
        getJudgmentRelatedData(listInternalNewJudgment);
        //validationRulesProductToJudgment(listNewJudgments,listJudgmentStatuses);
        //if(JudgmentTriggerHandler.runUpdateProductStatus){
        updateProductStatusesOnJudgment(listNewJudgments, listJudgmentStatuses);
        //}
        //method calls once record created/update in portal
        //getJudgmentRelatedAgencyData(listExternalNewJudgment);
        
        //get Judgment Balance According to Product
        getJudgmentBalance(listNewJudgments);
    }
    
    public static void getJudgmentBalance(list<Judgment__c> listNewJudgments){
        Decimal Total = 0;
        for(Judgment__c judgmentObj : listNewJudgments){
            system.debug('Total::' +Total);
            if(judgmentObj.Balance_one__c <> NULL){
                Total += judgmentObj.Balance_one__c; 
            }
            if(judgmentObj.Balance_two__c <> NULL){
                Total += judgmentObj.Balance_two__c; 
            }
            if(judgmentObj.Balance_three__c <> NULL){
                Total += judgmentObj.Balance_three__c; 
            }
            if(judgmentObj.Balance_four__c <> NULL){
                Total += judgmentObj.Balance_four__c; 
            }
            if(judgmentObj.Balance_five__c <> NULL){
                Total += judgmentObj.Balance_five__c; 
            }
            judgmentObj.Judgment_Balance__c = Total;
            system.debug('Total Balance ::' +judgmentObj.Judgment_Balance__c);
        }
    }
    
    public static void setAccountJudgmentInactive(List<Judgment__c> judgmentList){
        Set<Id> vacatedJudgments = new Set<Id>();
        for(Judgment__c judg: judgmentList){
            if(judg.Legal_Sub_Status__c == 'Vacated'){
                vacatedJudgments.add(judg.Id);
            }
        }
        
        if(vacatedJudgments.isEmpty()) return;
        List<Account_Judgment__c> accountJudgmentToInactive = new List<Account_Judgment__c>();
        for(Account_Judgment__c accJudg: [SELECT Id, Status__c FROM Account_Judgment__c WHERE Judgment__c IN: vacatedJudgments AND Status__c != 'Inactive']){
            accJudg.Status__c = 'Inactive';
            accountJudgmentToInactive.add(accJudg);
        }
        
        if(!accountJudgmentToInactive.isEmpty()){update accountJudgmentToInactive;}
    }
    
    public static void updateProductLegalStatus(Map<Id, Judgment__c> newJudgments, Map<Id, Judgment__c> oldJudgments){
        Set<Id> judgmentIds = new Set<Id>();
        for(Id key: newJudgments.keySet()){
            if(newJudgments.get(key).Legal_Status__c != oldJudgments.get(key).Legal_Status__c
               ||
               newJudgments.get(key).Legal_Sub_Status__c != oldJudgments.get(key).Legal_Sub_Status__c){
                   judgmentIds.add(key);
               }
        }
        
        Map<Id, Id> productJudgmentMap = new Map<Id, Id>();
        for(Account_Judgment__c accJudg: [SELECT 
                                          Product__c, Judgment__c FROM Account_Judgment__c 
                                          WHERE 
                                          Judgment__c IN: judgmentIds 
                                          //AND Status__c = 'Active' 
                                         ]){
                                             productJudgmentMap.put(accJudg.Product__c, accJudg.Judgment__c);
                                         }
        
        List<Product__c> prodList = new List<Product__c>();
        List<Product__c> prodData = [SELECT Id, Legal_Status__c FROM Product__c WHERE Id IN: productJudgmentMap.keySet()];
        for(Product__c prod : prodData ){
            Id judgmentId = productJudgmentMap.get(prod.Id);
            prod.Legal_Status__c = newJudgments.get(judgmentId).Legal_Status__c + ' - '+ newJudgments.get(judgmentId).Legal_Sub_Status__c;
            prodList.add(prod);
        }
        system.debug('prodList**'+prodList);
        if(!prodList.isEmpty()){
            update prodList;
        }
        
    }
    
    public static void handleAfterInsert(list<Judgment__c> judgment){
        system.debug('after insert');
        system.debug('after insert judgment' +judgment);
        //Added below line part od Bug-5564
      if(!test.isRunningTest())  updateAgencyOnJudgment(judgment);
        for(Judgment__c judgRecord : judgment){
            Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
            config.Send_Notification__c = true;  
            //call API
            if(!Test.isRunningTest()){
                if(judgRecord.Agency_Initiated_Legal_Action__c != NULL && judgRecord.Placed_Agency__c != NULL){
                	PortalJudgmentProcessingAPI.processJudgment(judgRecord.ID);
                }
            }
            system.debug('judgRecord.Placed_Agency__c::'+judgRecord.Legal_Agency__c);
            if(judgRecord.Legal_Agency__c != null &&
               judgRecord.Name != null &&
               config.Send_Notification__c == true){
                   notificationCallAPI(judgRecord.Legal_Agency__c,'Judgment','Judgment Created','Judgment ' + judgRecord.Name + ' has been created.');
               }
        }    
    }
    
    
    @future (callout=true)
    public static void notificationCallAPI(String placeId, String Type, String Title, String Message){      
        PortalNotificationAPI.sendPaymentNotification(placeId,Type,Title,'',Message);
    }
    
    public static void updateJudgmentInterestBalOnProduct(list<Judgment__c> listNewJudgments, Map<Id, Judgment__c> mapOldJudgments){
        system.debug('inside updated judgmentinter');
        system.debug('listNewJudgments'+listNewJudgments);
        system.debug('mapOldJudgments'+mapOldJudgments);
        set<String> prodName = new set<String>();
        map<String, Product__c> mapProductData = new map<String, Product__c>();
        map<String, Product__c> mapProductDataDetails = new map<String, Product__c>();
        set<id> ProductIds = new set<id>();
        map<String,Product_Payments__c> ProductPaymentList = new map<String,Product_Payments__c>();
        Map<Id,Product__c> productToUpdateMap = new Map<Id,Product__c>();
        Product__c productInstance;  
        Date judgmentDate;
        for(Judgment__c judgment : listNewJudgments){
            judgmentDate = judgment.Judgment_Date__c;
            if(judgment.Product_1__c != NULL){
                prodName.add(judgment.Product_1__c);
            }
            if(judgment.Product_2__c != NULL){
                prodName.add(judgment.Product_2__c);
            }
            if(judgment.Product_3__c != NULL){
                prodName.add(judgment.Product_3__c);
            }
            if(judgment.Product_4__c != NULL){
                prodName.add(judgment.Product_4__c);
            }
            if(judgment.Product_5__c != NULL){
                prodName.add(judgment.Product_5__c);
            }
        }
        Date todayDate = Date.today();
        list<Product_Payments__c> listPayment = new list<Product_Payments__c>();
        system.debug('prodName check'+prodName);
        system.debug('judgmentDate check'+judgmentDate);
        system.debug('todayDate check'+todayDate);
        String originalPayment = '';
        set<String> setReversalPayments = new set<String>();
        for(Product_Payments__c productPay :[select id,name,createdDate,CCS_Account__r.name,Principal_Payment_Amount__c, 
                                             Interest_Payment_Amount__c,Payment_Posting_Date__c,Payment_Type__c,
                                             Original_Of_Payment_Reversal__c,Is_Payment_Reversed__c,Payment_Amount__c
                                             from Product_Payments__c
                                             where CCS_Account__r.name =: prodName 
                                            ]){
                                                if(productPay.Payment_Amount__c < 0){
                                                    system.debug('pay amount negative::**' + productPay);
                                                    //get ID of the payments which are being reversed
                                                    setReversalPayments.add(productPay.Original_Of_Payment_Reversal__c);
                                                }
                                            }
        map<ID, Product_Payments__c> mapReversedPayments = new map<ID, Product_Payments__c>();
        if(!setReversalPayments.isEmpty()){
            for(Product_Payments__c prodPayment : [SELECT ID, Pay_Attorney__c, Pay_Court__c, Pay_Fees__c, Pay_NSF__c, Pay_Other__c, 
                                                   Interest_Payment_Amount__c, Principal_Payment_Amount__c, Pay_Recoverable_Fee__c,
                                                   Pay_Non_Recoverable_Fee__c, Payment_Amount__c, Product_Collection_Sub_Status__c, 
                                                   Pay_Data_Status__c, Placement_Status_on_Product__c, Placement_Sub_Status_on_Product__c,
                                                   Pay_Revenue__c,Payment_Posting_Date__c,
                                                   Product_Status_Desc_on_Product__c, Pay_Due__c, Tax_Amount__c,Tax_type__c,Payment_Type__c,
                                                   Balance_Before_Payment__c, Commission_Rate_For_payment__c, Product_Commission_Rate__c,
                                                   Tax_Province__c, Legal_Product_Identifier__c, Tax_Province_Rate__c, Interest_Adjustment__c,
                                                   Interest_Rate_to_For_Interest_Adjustment__c, No_of_Days_to_Adjust_Interest__c,Pay_Placedetail_Status__c
                                                   FROM Product_Payments__c
                                                   WHERE ID IN : setReversalPayments]){
                                                       mapReversedPayments.put(prodPayment.ID, prodPayment);
                                                   }    
        }
        //Added for ticket 4495.
        Map<String,Boolean> prodPaymentMap = new Map<String,Boolean>();
        
        for(Product_Payments__c prodPaymentData : [select id,name,createdDate,CCS_Account__r.name,Principal_Payment_Amount__c, 
                                                   Interest_Payment_Amount__c,Payment_Posting_Date__c,Payment_Type__c,
                                                   Original_Of_Payment_Reversal__c,Is_Payment_Reversed__c,Payment_Amount__c 
                                                   from Product_Payments__c
                                                   where CCS_Account__r.name =: prodName 
                                                  ]){
                                                      if(!mapReversedPayments.containsKey(prodPaymentData.id) && prodPaymentData.Payment_Type__c != '1003'){
                                                          system.debug('inside if condition'+prodPaymentData.name);
                                                          if(prodPaymentData.Payment_Posting_Date__c >= judgmentDate && prodPaymentData.Payment_Posting_Date__c <= todayDate){
                                                              system.debug('inside nested-if condition');
                                                              ProductIds.add(prodPaymentData.CCS_Account__c);
                                                              system.debug('ProductIds ***'+ProductIds);                          
                                                              ProductPaymentList.put(prodPaymentData.CCS_Account__r.name,prodPaymentData); 
                                                              listPayment.add(prodPaymentData);
                                                              
                                                              //Added for ticket 4495.
                                                              if(!prodPaymentMap.containsKey(prodPaymentData.CCS_Account__r.Name)){
                                                                  prodPaymentMap.put(prodPaymentData.CCS_Account__r.Name, True);
                                                              }
                                                          }                             
                                                      }             
                                                      system.debug('ProductIds ***'+ProductIds);
                                                      system.debug('prodPaymentData createdDate ***'+prodPaymentData.createdDate);                                                    
                                                  }
        
        for(Product__c prodData : [select id,name,interest_rate__c,Current_Principal_Balance__c,Current_Interest_Amount__c,Current_Balance__c,
                                   Previous_Principal_Balance__c,Previous_Interest_Rate__c,Judgment_Rate__c, Recoverable_Fee__c,Interest_Amount_Last_Calculated_Date__c from Product__c
                                   where id =: ProductIds]){
                                       mapProductData.put(prodData.Name, prodData);
                                   }
        List<Product__c> ListProdctDetails = new List<Product__c>();
        
        for(Product__c prodDataDetails : [select id,name,interest_rate__c,Current_Principal_Balance__c,Current_Interest_Amount__c,Current_Balance__c,
                                          Previous_Principal_Balance__c,Previous_Interest_Rate__c,Judgment_Rate__c, Recoverable_Fee__c,Interest_Amount_Last_Calculated_Date__c from Product__c
                                          where name =: prodName]){
                                              mapProductDataDetails.put(prodDataDetails.Name, prodDataDetails);
                                              ListProdctDetails.add(prodDataDetails);                          
                                          }
        
        system.debug('mapProductData check'+prodName);
        system.debug('mapOldJudgments check'+mapOldJudgments);
        
        Decimal JudInterestRate = 0;
        Decimal JudBalance = 0;  
        String JudProductName = '';
        String judgDate = '';
        
        //Added for ticket 4495.
        list<Product_Payments__c> listPayment1 = new list<Product_Payments__c>();
        system.debug('listPayment***'+listPayment);
        system.debug('inside testedprod'+mapProductData);
        for(Judgment__c judgment : listNewJudgments){
            system.debug('mapOldJudgments.get(judgment.ID).Legal_Status__c::'+mapOldJudgments.get(judgment.ID).Legal_Status__c);
            system.debug('mapOldJudgments.get(judgment.ID).Judgment_Date__c::'+mapOldJudgments.get(judgment.ID).Judgment_Date__c);
            system.debug('judgment.Legal_Status__c::'+judgment.Legal_Status__c);
            system.debug('judgment.Judgment_Date__c::'+judgment.Judgment_Date__c);
            system.debug('inside testing prod'+mapProductData);
            if(((mapOldJudgments.get(judgment.ID).Legal_Status__c != 'Judgment' && mapOldJudgments.get(judgment.ID).Legal_Status__c != 'Post-Judgment')
                && (judgment.Legal_Status__c == 'Judgment' || judgment.Legal_Status__c == 'Post-Judgment')
                && judgment.Judgment_Date__c != NULL) 
               || ((judgment.Legal_Status__c == 'Judgment' || judgment.Legal_Status__c == 'Post-Judgment')
                   && (judgment.Judgment_Date__c != NULL && mapOldJudgments.get(judgment.ID).Judgment_Date__c == NULL))){
                       system.debug('inside if condition');
                       system.debug('inside test prod'+mapProductData);
                       //Product 1 recalculation
                       if(judgment.Product_1__c != NULL
                          && judgment.Interest_Rate_one__c != NULL
                          && judgment.Balance_one__c != NULL){
                              system.debug('inside if condition check**');
                              JudProductName = judgment.Product_1__c;
                              JudBalance = judgment.Balance_one__c;
                              judgDate = String.valueOf(Judgment.Judgment_Date__c);
                              JudInterestRate = Judgment.Interest_Rate_one__c;
                              system.debug('inside 1st prod'+mapProductData);
                              productToUpdateMap = calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,JudProductName,JudBalance,
                                                                                       JudInterestRate,judgDate,ProductPaymentList,mapProductDataDetails); 
                              //Added for ticket 4495.
                              if(prodPaymentMap.containsKey(judgment.Product_1__c)){
                                  
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
                              }else{
                                 
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment1,ListProdctDetails);
                              }
                          }
                       
                       //Product 2 recalculation
                       if(judgment.Product_2__c != NULL
                          && judgment.Interest_Rate_two__c != NULL
                          && judgment.Balance_two__c != NULL){
                              JudProductName = judgment.Product_2__c;
                              JudBalance = judgment.Balance_two__c;
                              judgDate = String.valueOf(Judgment.Judgment_Date__c);
                              JudInterestRate = Judgment.Interest_Rate_two__c;
                              productToUpdateMap = calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,JudProductName,JudBalance,
                                                                                       JudInterestRate,judgDate,ProductPaymentList,mapProductDataDetails); 
                              //Added for ticket 4495.
                              if(prodPaymentMap.containsKey(judgment.Product_2__c)){
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
                              }else{
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment1,ListProdctDetails); 
                              }
                          }
                       //Product 2 recalculation ends
                       
                       //Product 3 recalculation
                       if(judgment.Product_3__c != NULL
                          && judgment.Interest_Rate_three__c != NULL
                          && judgment.Balance_three__c != NULL){
                              JudProductName = judgment.Product_3__c;
                              JudBalance = judgment.Balance_three__c;
                              judgDate = String.valueOf(Judgment.Judgment_Date__c);
                              JudInterestRate = Judgment.Interest_Rate_three__c;
                              productToUpdateMap = calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,JudProductName,JudBalance,
                                                                                       JudInterestRate,judgDate,ProductPaymentList,mapProductDataDetails);
                              //Added for ticket 4495.
                              if(prodPaymentMap.containsKey(judgment.Product_3__c)){
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
                              }else{
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment1,ListProdctDetails);  
                              }
                          }
                       //Product 3 recalculation ends
                       
                       //Product 4 recalculation
                       if(judgment.Product_4__c != NULL
                          && judgment.Interest_Rate_four__c != NULL
                          && judgment.Balance_four__c != NULL){
                              JudProductName = judgment.Product_4__c;
                              JudBalance = judgment.Balance_four__c;
                              judgDate = String.valueOf(Judgment.Judgment_Date__c);
                              JudInterestRate = Judgment.Interest_Rate_four__c;
                              productToUpdateMap = calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,JudProductName,JudBalance,
                                                                                       JudInterestRate,judgDate,ProductPaymentList,mapProductDataDetails);
                             //Added for ticket 4495.
                              if(prodPaymentMap.containsKey(judgment.Product_4__c)){
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
                              }else{
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment1,ListProdctDetails);  
                              }
                          }
                       //Product 4 recalculation ends
                       
                       //Product 5 recalculation
                       if(judgment.Product_5__c != NULL
                          && judgment.Interest_Rate_five__c != NULL
                          && judgment.Balance_five__c != NULL){
                              system.debug('inside product 5');
                              JudProductName = judgment.Product_5__c;
                              JudBalance = judgment.Balance_five__c;
                              judgDate = String.valueOf(Judgment.Judgment_Date__c);
                              JudInterestRate = Judgment.Interest_Rate_five__c;
                              productToUpdateMap = calculateJudgmentInterestAdjustment(listNewJudgments,mapProductData,JudProductName,JudBalance,
                                                                                       JudInterestRate,judgDate,ProductPaymentList,mapProductDataDetails);
                              system.debug('inside product 5 productToUpdateMap'+productToUpdateMap);
                              //Added for ticket 4495.
                              if(prodPaymentMap.containsKey(judgment.Product_5__c)){
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
                              }else{
                                  updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment1,ListProdctDetails);  
                              }
                          }
                       //Product 5 recalculation ends
                   }
            
        }
        system.debug('productToUpdateMap ***'+productToUpdateMap);
        system.debug('listPayment check***'+listPayment);
        
        //updateProductBalAndInterest(productToUpdateMap,judgmentDate,listPayment,ListProdctDetails);
        
        
    }
    
    public static void updateProductBalAndInterest(Map<Id,Product__c> productToUpdateMap,Date judgmentDate,
                                                   list<Product_Payments__c> listPayment,List<Product__c> ListProdctDetails){
                                                       
                                                       Product__c ProductNewInstance = new Product__c();
                                                       Date CurrentDate = Date.today();
                                                       Decimal Current_Interest = 0;
                                                       Decimal Principal_Payment_Amount = 0;
                                                       Decimal Product_Current_Principal = 0; 
                                                       Decimal Product_Current_Interest = 0;
                                                       Decimal Product_Current_Interest_Amount = 0;   
                                                       Decimal Interest_Payment_Amount = 0;
                                                       Decimal InterestAmount = 0;
                                                       Decimal InterestRate;
                                                       Decimal Principal_Balance = 0;
                                                       Decimal NoOfDays = 0;
                                                       //set current Date to judgment Date
                                                       CurrentDate = judgmentDate;
                                                       
                                                       //If Product has no Payments
                                                       if(listPayment.isEmpty()){
                                                           system.debug('inside empty list');
                                                           for(Product__c prodDetails : ListProdctDetails){
                                                               Decimal interesttoAdjust;
                                                               if(productToUpdateMap.containsKey(prodDetails.id)){
                                                                   ProductNewInstance.id = productToUpdateMap.get(prodDetails.id).id;
                                                                   ProductNewInstance.Interest_Rate__c = productToUpdateMap.get(prodDetails.id).Interest_Rate__c;
                                                                   ProductNewInstance.Judgment_Rate__c = productToUpdateMap.get(prodDetails.id).Judgment_Rate__c;
                                                                   system.debug(' ProductNewInstance.Current_Principal_Balance__c::'+ productToUpdateMap.get(prodDetails.id).Current_Principal_Balance__c);
                                                                   ProductNewInstance.Current_Principal_Balance__c = productToUpdateMap.get(prodDetails.id).Current_Principal_Balance__c;
                                                                   ProductNewInstance.Interest_Amount_Last_Calculated_Date__c = Date.Today()-1; 
                                                                   ProductNewInstance.Current_Interest_Amount__c = 0;
                                                                   
                                                                   ProductNewInstance.Recoverable_Fee__c = productToUpdateMap.get(prodDetails.id).Recoverable_Fee__c;
                                                                   
                                                                   Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                                                                   
                                                                   NoOfDays = (Date.valueOf(CurrentDate).daysBetween(Date.Today()));
                                                                   //for include current date in interest calculation.
                                                                   //as NoOfDays is one day less 
                                                                   //NoOfDays += 1;
                                                                   system.debug('NoOfDays1::'+NoOfDays);
                                                                   NoOfDays = NoOfDays/365;
                                                                   system.debug('NoOfDays2::'+NoOfDays);
                                                                   //round of no of days to 4 decimal places
                                                                   NoOfDays = NoOfDays.setScale(5,RoundingMode.HALF_UP);
                                                                   system.debug('NoOfDays'+NoOfDays);
                                                                   
                                                                   //convert interest rate percent to decimal
                                                                   InterestRate = ProductNewInstance.Interest_Rate__c;
                                                                   InterestRate = InterestRate / 100;
                                                                   
                                                                   interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                                                                   //Round off Interest Amount accrued to 2 decimal places
                                                                   interesttoAdjust = interesttoAdjust.setScale(2,RoundingMode.HALF_UP);
                                                                   system.debug('interesttoAdjust ****'+interesttoAdjust);
                                                                   
                                                                   //Update Current Interest Amount
                                                                   ProductNewInstance.Current_Interest_Amount__c = interesttoAdjust;
                                                                   
                                                                   if(InterestRate != NULL && Principal_Balance != NULL){
                                                                       system.debug('Principal_Balance:: '+Principal_Balance);
                                                                       system.debug('InterestRate:: '+InterestRate);
                                                                       
                                                                       //Simplify no of days to 1/365;
                                                                       Decimal NoOfDayss = 0.00273972;
                                                                       system.debug('NoOfDayss1****'+NoOfDayss);
                                                                       //round of no of days to 5 decimal places
                                                                       NoOfDayss = NoOfDayss.setScale(5,RoundingMode.HALF_UP);
                                                                       system.debug('NoOfDayss2****'+NoOfDayss);
                                                                       //I=Prt
                                                                       InterestAmount = Principal_Balance * InterestRate * NoOfDayss;
                                                                       //Round off Interest Amount accrued to 2 decimal places
                                                                       InterestAmount = InterestAmount.setScale(2,RoundingMode.HALF_UP);
                                                                       system.debug('InterestAmount****'+InterestAmount);
                                                                       //Populate Interest Amount Accrued for the Day
                                                                       ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                                                                       
                                                                   }
                                                                   system.debug('Current_Interest_Amount__c****'+ProductNewInstance.Current_Interest_Amount__c);
                                                                   system.debug('Current_Principal_Balance__c****'+ProductNewInstance.Current_Principal_Balance__c);
                                                                   ProductNewInstance.Current_Balance__c = 
                                                                       (ProductNewInstance.Current_Principal_Balance__c != NULL ? ProductNewInstance.Current_Principal_Balance__c : 0)
                                                                       +(ProductNewInstance.Current_Interest_Amount__c != NULL ? ProductNewInstance.Current_Interest_Amount__c : 0)
                                                                       +(ProductNewInstance.Recoverable_Fee__c != NULL ? ProductNewInstance.Recoverable_Fee__c : 0);
                                                               }
                                                           }
                                                           system.debug('ProductNewInstance****'+ProductNewInstance);
                                                           if(ProductNewInstance.id != NULL){
                                                               productToUpdateMap.put(ProductNewInstance.id,ProductNewInstance);
                                                           }
                                                       }
                                                       
                                                       //if product has payment 100x and 800x
                                                       if(!listPayment.isEmpty()){
                                                           system.debug('inside no empty list');
                                                           Date LastPaymentPostingDate;
                                                           Map<ID,Boolean> prodPaymentMap = new Map<ID,Boolean>();
                                                           for(Product_Payments__c prodPayment : listPayment){
                                                               if(!prodPaymentMap.containsKey(prodPayment.CCS_Account__c)){
                                                                   prodPaymentMap.put(prodPayment.CCS_Account__c, true); 
                                                               }
                                                               
                                                               if(productToUpdateMap.containsKey(prodPayment.CCS_Account__c)){
                                                                   if(prodPayment.Payment_Amount__c > = 0){
                                                                       system.debug('inside non reversal');
                                                                       Decimal interesttoAdjust = 0;
                                                                       
                                                                       system.debug('CurrentDate ***'+CurrentDate);
                                                                       ProductNewInstance.id = productToUpdateMap.get(prodPayment.CCS_Account__c).id;
                                                                       //Populate judgment interest rate on product
                                                                       ProductNewInstance.Interest_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Interest_Rate__c;
                                                                       ProductNewInstance.Judgment_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Judgment_Rate__c;
                                                                       
                                                                       ProductNewInstance.Previous_Interest_Rate__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Previous_Interest_Rate__c;
                                                                       ProductNewInstance.Previous_Principal_Balance__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Previous_Principal_Balance__c;
                                                                       system.debug('ProductNewInstance.Current_Principal_Balance__c::'+productToUpdateMap.get(prodPayment.CCS_Account__c).Current_Principal_Balance__c);
                                                                       ProductNewInstance.Interest_Amount_Last_Calculated_Date__c = Date.today()-1; 
                                                                       system.debug('ProductNewInstance'+ProductNewInstance.id);
                                                                       ProductNewInstance.Current_Principal_Balance__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Current_Principal_Balance__c;
                                                                       //Round off Principal Balance accrued to 2 decimal places
                                                                       Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                                                                       
                                                                       ProductNewInstance.Current_Interest_Amount__c = productToUpdateMap.get(prodPayment.CCS_Account__c).Current_Interest_Amount__c;
                                                                       //Round off Interest balance accrued to 2 decimal places
                                                                       Current_Interest = ProductNewInstance.Current_Interest_Amount__c.setScale(2,RoundingMode.HALF_UP);
                                                                       
                                                                       Principal_Payment_Amount = prodPayment.Principal_Payment_Amount__c.setScale(2,RoundingMode.HALF_UP);
                                                                       Interest_Payment_Amount = prodPayment.Interest_Payment_Amount__c.setScale(2,RoundingMode.HALF_UP);
                                                                       system.debug('payment Posting Date**'+prodPayment.Payment_Posting_Date__c);
                                                                       
                                                                       NoOfDays = (Date.valueOf(CurrentDate).daysBetween(prodPayment.Payment_Posting_Date__c));
                                                                       system.debug('NoOfDays1::'+NoOfDays);
                                                                       NoOfDays = NoOfDays/365;
                                                                       system.debug('NoOfDays2::'+NoOfDays);
                                                                       //round of no of days to 4 decimal places
                                                                       NoOfDays = NoOfDays.setScale(5,RoundingMode.HALF_UP);
                                                                       system.debug('NoOfDays'+NoOfDays);
                                                                       
                                                                       
                                                                       //convert interest rate percent to decimal
                                                                       InterestRate = ProductNewInstance.Interest_Rate__c;
                                                                       InterestRate = InterestRate / 100;
                                                                       
                                                                       
                                                                       interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                                                                       //Round off Interest Amount accrued to 2 decimal places
                                                                       interesttoAdjust = interesttoAdjust.setScale(2,RoundingMode.HALF_UP);
                                                                       system.debug('interesttoAdjust ****'+interesttoAdjust);
                                                                       
                                                                       //Update Current Interest Amount
                                                                       if(ProductNewInstance.Current_Interest_Amount__c == NULL){
                                                                           ProductNewInstance.Current_Interest_Amount__c = interesttoAdjust;  
                                                                       }
                                                                       else {
                                                                           system.debug('ProductNewInstance.Current_Interest_Amount__c before: '+ProductNewInstance.Current_Interest_Amount__c);
                                                                           ProductNewInstance.Current_Interest_Amount__c += interesttoAdjust;     
                                                                           system.debug('ProductNewInstance.Current_Interest_Amount__c after: '+ProductNewInstance.Current_Interest_Amount__c);
                                                                       }
                                                                       
                                                                       //Decimal totalProductPayment = prodPayment.Payment_Amount__c;
                                                                       
                                                                       prodPayment.Interest_Payment_Amount__c = prodPayment.Interest_Payment_Amount__c != NULL ? prodPayment.Interest_Payment_Amount__c : 0;
                                                                       prodPayment.Principal_Payment_Amount__c = prodPayment.Principal_Payment_Amount__c != NULL ? prodPayment.Principal_Payment_Amount__c : 0;
                                                                       system.debug('prodPayment Interest_Payment_Amount__c***'+prodPayment.Interest_Payment_Amount__c);
                                                                       system.debug('prodPayment Principal_Payment_Amount__c***'+prodPayment.Principal_Payment_Amount__c);
                                                                       Decimal totalProductPayment = prodPayment.Interest_Payment_Amount__c + prodPayment.Principal_Payment_Amount__c;    
                                                                       
                                                                       system.debug('Actual totalProductPayment***'+totalProductPayment);
                                                                       //Deduct Interest
                                                                       if(totalProductPayment >= ProductNewInstance.Current_Interest_Amount__c){
                                                                           prodPayment.Interest_Payment_Amount__c = ProductNewInstance.Current_Interest_Amount__c;
                                                                           totalProductPayment = totalProductPayment - ProductNewInstance.Current_Interest_Amount__c;
                                                                           ProductNewInstance.Current_Interest_Amount__c = 0;
                                                                       }
                                                                       else{
                                                                           prodPayment.Interest_Payment_Amount__c = totalProductPayment;
                                                                           ProductNewInstance.Current_Interest_Amount__c -= totalProductPayment;
                                                                           totalProductPayment = 0;
                                                                       }
                                                                       system.debug('current interest afer deduct interest::'+ProductNewInstance.Current_Interest_Amount__c);
                                                                       system.debug('totalProductPayment***'+totalProductPayment);
                                                                       //Deduct Principal 
                                                                       system.debug('ProductNewInstance.Current_Principal_Balance__c before:'+ProductNewInstance.Current_Principal_Balance__c);
                                                                       if(totalProductPayment >= ProductNewInstance.Current_Principal_Balance__c){
                                                                           prodPayment.Principal_Payment_Amount__c = ProductNewInstance.Current_Principal_Balance__c;
                                                                           totalProductPayment = totalProductPayment - ProductNewInstance.Current_Principal_Balance__c;
                                                                           system.debug('ProductNewInstance.Collection_Sub_Status__c::'+ProductNewInstance.Collection_Sub_Status__c);
                                                                           ProductNewInstance.Current_Principal_Balance__c = 0;
                                                                       }else{
                                                                           prodPayment.Principal_Payment_Amount__c = totalProductPayment;
                                                                           ProductNewInstance.Current_Principal_Balance__c -= totalProductPayment;
                                                                           totalProductPayment = 0;
                                                                       }
                                                                       //after deduction, if Payment amount is still remaining, add it to Principal as credit balance
                                                                       if(totalProductPayment <> 0 && ProductNewInstance.Current_Principal_Balance__c == 0){
                                                                           ProductNewInstance.Current_Principal_Balance__c = ProductNewInstance.Current_Principal_Balance__c - totalProductPayment;   
                                                                       }
                                                                       system.debug('Product Current_Principal_Balance__c****'+ProductNewInstance.Current_Principal_Balance__c);
                                                                       
                                                                       //set currentDate to payment posting Date
                                                                       CurrentDate = prodPayment.Payment_Posting_Date__c;
                                                                       
                                                                   }//payment amount greater than zero
                                                                   if(prodPayment.Payment_Posting_Date__c != NULL){
                                                                       LastPaymentPostingDate = prodPayment.Payment_Posting_Date__c;
                                                                   }
                                                                   Decimal DaysDiff;
                                                                   if(LastPaymentPostingDate != NULL){
                                                                       DaysDiff = (Date.valueOf(LastPaymentPostingDate).daysBetween(Date.today()));
                                                                   }
                                                                   if(DaysDiff == 0){
                                                                       Decimal Last_Principal_Balance = 0;
                                                                       Last_Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                                                                       if(InterestRate != NULL && Last_Principal_Balance != NULL){
                                                                           system.debug('Principal_Balance:: '+Principal_Balance);
                                                                           system.debug('InterestRate:: '+InterestRate);
                                                                           
                                                                           //Simplify no of days to 1/365;
                                                                           Decimal NoOfDayss = 0.00273972;
                                                                           //round of no of days to 5 decimal places
                                                                           NoOfDayss = NoOfDayss.setScale(5,RoundingMode.HALF_UP);
                                                                           
                                                                           //I=Prt
                                                                           InterestAmount = Last_Principal_Balance * InterestRate * NoOfDayss;
                                                                           //Round off Interest Amount accrued to 2 decimal places
                                                                           InterestAmount = InterestAmount.setScale(2,RoundingMode.HALF_UP);
                                                                           
                                                                           //Populate Interest Amount Accrued for the Day
                                                                           ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                                                                           
                                                                       }
                                                                   }
                                                                   
                                                                   if(ProductNewInstance.id != NULL){
                                                                       productToUpdateMap.put(ProductNewInstance.id,ProductNewInstance);
                                                                   }
                                                                   
                                                               }
                                                               //end if
                                                           }//end for loop
                                                           
                                                           for(product__c prodData : productToUpdateMap.values()){
                                                               //calculate interst between Last Payment Posting Date to currentDate
                                                               Decimal interesttoAdjust;
                                                               system.debug('LastPaymentPostingDate'+LastPaymentPostingDate);
                                                               system.debug('prodData current principal bal'+prodData.Current_Principal_Balance__c);
                                                               Principal_Balance = prodData.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                                                               if(LastPaymentPostingDate != NULL){
                                                                   NoOfDays = (Date.valueOf(LastPaymentPostingDate).daysBetween(Date.today()));
                                                               }
                                                               //for include current date in interest calculation.
                                                               //as NoOfDays is one day less 
                                                               //NoOfDays += 1;
                                                               //if number of days less than zero no calculation happen
                                                               //if(NoOfDays > 0){
                                                               system.debug('NoOfDays1::'+NoOfDays);
                                                               NoOfDays = NoOfDays/365;
                                                               system.debug('NoOfDays2::'+NoOfDays);
                                                               //round of no of days to 4 decimal places
                                                               NoOfDays = NoOfDays.setScale(5,RoundingMode.HALF_UP);
                                                               system.debug('NoOfDays'+NoOfDays);
                                                               
                                                               
                                                               //convert interest rate percent to decimal
                                                               InterestRate = prodData.Interest_Rate__c;
                                                               InterestRate = InterestRate / 100;
                                                               
                                                               system.debug('Principal_Balance****'+Principal_Balance);
                                                               system.debug('InterestRate****'+InterestRate);
                                                               
                                                               interesttoAdjust = Principal_Balance * InterestRate * NoOfDays;
                                                               //Round off Interest Amount accrued to 2 decimal places
                                                               interesttoAdjust = interesttoAdjust.setScale(2,RoundingMode.HALF_UP);
                                                               system.debug('interesttoAdjust ****'+interesttoAdjust);
                                                               
                                                               //Update Current Interest Amount
                                                               //if(ProductNewInstance.Current_Interest_Amount__c == NULL){
                                                               system.debug('last prodData Current_Interest_Amount__c before'+prodData.Current_Interest_Amount__c);
                                                               system.debug('last Current_Interest_Amount__c before'+ProductNewInstance.Current_Interest_Amount__c);
                                                               system.debug('last interesttoAdjust'+interesttoAdjust);
                                                               if(ProductNewInstance.Current_Interest_Amount__c == null){
                                                                   ProductNewInstance.Current_Interest_Amount__c = 0;
                                                               }
                                                               if(interesttoAdjust == null){
                                                                   interesttoAdjust = 0;
                                                               }
                                                               ProductNewInstance.Current_Interest_Amount__c += interesttoAdjust;  
                                                               system.debug('last Current_Interest_Amount__c after'+ProductNewInstance.Current_Interest_Amount__c);
                                                               //}
                                                               system.debug('Current_Principal_Balance__c'+ProductNewInstance.Current_Principal_Balance__c);
                                                               system.debug('Current_Interest_Amount__c'+ProductNewInstance.Current_Interest_Amount__c);
                                                               system.debug('Recoverable_Fee__c'+ProductNewInstance.Recoverable_Fee__c);
                                                               ProductNewInstance.Current_Balance__c = 
                                                                   (ProductNewInstance.Current_Principal_Balance__c != NULL ? ProductNewInstance.Current_Principal_Balance__c : 0)
                                                                   +(ProductNewInstance.Current_Interest_Amount__c != NULL ? ProductNewInstance.Current_Interest_Amount__c : 0)
                                                                   +(ProductNewInstance.Recoverable_Fee__c != NULL ? ProductNewInstance.Recoverable_Fee__c : 0);
                                                               
                                                               Decimal Last_Principal_Balance = 0;
                                                               
                                                               //Added for ticket 4495.
                                                               if(ProductNewInstance.Current_Principal_Balance__c != Null){
                                                                   Last_Principal_Balance = ProductNewInstance.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                                                               }
                                                               
                                                               if(InterestRate != NULL && Last_Principal_Balance != NULL){
                                                                   system.debug('Principal_Balance:: '+Principal_Balance);
                                                                   system.debug('InterestRate:: '+InterestRate);
                                                                   
                                                                   //Simplify no of days to 1/365;
                                                                   Decimal NoOfDayss = 0.00273972;
                                                                   //round of no of days to 5 decimal places
                                                                   NoOfDayss = NoOfDayss.setScale(5,RoundingMode.HALF_UP);
                                                                   
                                                                   //I=Prt
                                                                   InterestAmount = Last_Principal_Balance * InterestRate * NoOfDayss;
                                                                   //Round off Interest Amount accrued to 2 decimal places
                                                                   InterestAmount = InterestAmount.setScale(2,RoundingMode.HALF_UP);
                                                                   
                                                                   //Populate Interest Amount Accrued for the Day
                                                                   ProductNewInstance.Interest_Accrued_for_the_Day__c = InterestAmount;
                                                                   
                                                               }
                                                               if(ProductNewInstance.id != NULL){
                                                                   productToUpdateMap.put(ProductNewInstance.id,ProductNewInstance);
                                                               }
                                                               //}
                                                               
                                                           }
                                                       }
                                                       ProductTriggerHandler.runProductTrigger = false;
                                                       if(productToUpdateMap.containsKey(ProductNewInstance.ID) && ProductNewInstance.ID != NULL){                               
                                                           update productToUpdateMap.values();
                                                       } 
                                                       ProductTriggerHandler.runProductTrigger = true;
                                                   }
    /*****************************************************************************************************
Judgment Reversal Interest Calculation pseudo code
1) Pull list of 100x and 800x payments made between current date and Judgment Date

2)  a. Set Product Balance to be Judgment Balance
b. Set Product Current Interest Balance to $0
c. Set Product Current Interest Rate to be Judgement Rate
d. Set Interest Amount Last Calculated Date to Today

3) If no (100x and 800x) payments, Add daily interest from Judgment date to current date

Else{
CurDate = Judgment Date

For each payment P{

Add in/Accrue interest from CurDate to Payment Posting Date of P add to product current interest balance
- product Current Interest Balance = Product Current Principal Balance * ((no. of days * jud_interest_rate )/100)/365 + product Current Interest Balance

Deduct Balances according to Apportionment (Interest, Principal) 

Subtract the "Principal Payment Amount" on the Payment P from the Product Current Principal Balance
- Product Current Principal Balance = Product Current Principal Balance - Principal Payment Amount

Subtract the "Interest Payment Amount" from the Payment P from the Product Current Interest Balance
-   Product Current Interest Balance = Product Current Interest Balance - Interest Payment Amount
- interest will become will negative should will deduct from principal balance

CurDate = Payment Posting Date
}
Accure Interest from curDate (last payment's postoing date) to Today
}
4) Save final calculated values to Product Record
****************************************************************************************************/
    
    public static Map<Id,Product__c> calculateJudgmentInterestAdjustment(list<Judgment__c> listNewJudgments,map<String, Product__c> mapProductData,
                                                                         String JudProductName,Decimal JudBalance,Decimal JudInterestRate,String judgDate,
                                                                         Map<String,Product_Payments__c> ProductPaymentList,map<String, Product__c> mapProductDataDetails){
                                                                             
                                                                             system.debug('inside calJudgmentInterestAdjustment**');
                                                                             system.debug('mapProductData**'+mapProductData);                                   
                                                                             system.debug('JudProductName**'+JudProductName); 
                                                                             system.debug('JudBalance**'+JudBalance);
                                                                             system.debug('JudInterestRate**'+JudInterestRate);
                                                                             system.debug('judgDate**'+judgDate);                                   
                                                                             Map<Id,Product__c> productToUpdateMap = new Map<Id,Product__c>();
                                                                             Product__c productInstance = new Product__c();
                                                                             
                                                                             // Step:2  d. Set Interest Amount Last Calculated Date to Today                                 
                                                                             if(mapProductData.containsKey(JudProductName)){
                                                                                 productInstance = mapProductData.get(JudProductName);
                                                                                 productInstance.Id = mapProductData.get(JudProductName).ID;
                                                                                 productInstance.Name = mapProductData.get(JudProductName).Name;  
                                                                                 productInstance.Interest_Amount_Last_Calculated_Date__c = Date.today()-1;    
                                                                             }
                                                                             system.debug('productInstance**'+productInstance);   
                                                                             if(mapProductData.containsKey(productInstance.Name)){
                                                                                 if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
                                                                                    && mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
                                                                                        
                                                                                        
                                                                                        //Step2 a. Set Product Balance to be Judgment Balance    
                                                                                        system.debug('JudBalance**'+JudBalance);       
                                                                                        productInstance.Current_Principal_Balance__c = JudBalance;
                                                                                        
                                                                                        //Step2 b. Set Product Interest Balance to $0
                                                                                        productInstance.Current_Interest_Amount__c = 0;
                                                                                        
                                                                                        system.debug('ProductPaymentList'+ProductPaymentList);
                                                                                        system.debug('ProductPaymentList Check**'+ProductPaymentList.get(productInstance.Name).Principal_Payment_Amount__c );        
                                                                                        
                                                                                        if(mapProductData.containsKey(JudProductName)){
                                                                                            system.debug('Bolck run1 product...1');
                                                                                            ProductInstance.Previous_Interest_Rate__c = mapProductData.get(JudProductName).Interest_Rate__c;
                                                                                            ProductInstance.Previous_Principal_Balance__c = mapProductData.get(JudProductName).Current_Principal_Balance__c;
                                                                                        }
                                                                                        system.debug('judg interest one before**'+JudInterestRate);
                                                                                        ProductInstance.Interest_Rate__c = JudInterestRate;
                                                                                        productInstance.Judgment_Rate__c = JudInterestRate;
                                                                                        system.debug('ProductInstance Interest_Rate1**'+ProductInstance.Interest_Rate__c);  
                                                                                    }
                                                                             }
                                                                             //no payment foud for 100x and 800x then populate judgment interest rate and balance to product
                                                                             if(!mapProductData.containsKey(JudProductName) && String.isNotBlank(JudProductName)){
                                                                                 //productInstance = mapProductDataDetails.get(JudProductName);
                                                                                 productInstance.ID = mapProductDataDetails.get(JudProductName).id;
                                                                                 productInstance.Interest_Rate__c = JudInterestRate;
                                                                                 productInstance.Current_Principal_Balance__c = JudBalance;
                                                                                 productInstance.Current_Interest_Amount__c = mapProductDataDetails.get(JudProductName).Current_Interest_Amount__c;
                                                                                 productInstance.Recoverable_Fee__c = mapProductDataDetails.get(JudProductName).Recoverable_Fee__c;
                                                                                 productInstance.Judgment_Rate__c = JudInterestRate;
                                                                             } 
                                                                             system.debug('productInstance**'+productInstance);                                    
                                                                             if(productInstance.ID != NULL){                               
                                                                                 productToUpdateMap.put(productInstance.id,productInstance);
                                                                             } 
                                                                             
                                                                             return productToUpdateMap;
                                                                         }
    
    public static void handleAfterUpdate(list<Judgment__c> listNewJudgments, Map<Id, Judgment__c> mapOldJudgments){
        map<String, ID> mapProductNameIds = new map<String, ID>();
        map<String, Product__c> mapProductData = new map<String, Product__c>();
        set<String> prodName = new set<String>();
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        config.Send_Notification__c = true;
        system.debug('inside after update');
        //Get active judgments related to product
        for(Judgment__c judgment : listNewJudgments){
            if(judgment.Product_1__c != NULL){
                prodName.add(judgment.Product_1__c);
            }
            if(judgment.Product_2__c != NULL){
                prodName.add(judgment.Product_2__c);
            }
            if(judgment.Product_3__c != NULL){
                prodName.add(judgment.Product_3__c);
            }
            if(judgment.Product_4__c != NULL){
                prodName.add(judgment.Product_4__c);
            }
            if(judgment.Product_5__c != NULL){
                prodName.add(judgment.Product_5__c);
            }
        }
        system.debug('prodName::'+prodName);
        for(Account_judgment__c accJudgment : [SELECT ID, Name,Product__c, Judgment__c, Product__r.Name
                                               FROM Account_Judgment__c 
                                               WHERE Judgment__c IN :listNewJudgments
                                               AND Status__c = 'Active'
                                               AND (Judgment__r.Legal_Status__c = 'Judgment' 
                                                    OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                                               AND Judgment__r.Judgment_Date__c != NULL
                                               ORDER BY CreatedDate DESC]){
                                                   mapProductNameIds.put(accJudgment.Product__r.Name, accJudgment.Product__c);
                                                   //prodName.add(accJudgment.Product__r.Name);
                                                   system.debug('accJudgment:: '+accJudgment);
                                               }
        
        //system.debug('accJudgment:: '+accJudgment);
        for(Product__c prodData : [select id,name,interest_rate__c,Current_Principal_Balance__c,Current_Interest_Amount__c,Current_Balance__c,
                                   Previous_Principal_Balance__c,Previous_Interest_Rate__c, Recoverable_Fee__c from Product__c
                                   where Name =: prodName]){
                                       mapProductData.put(prodData.Name, prodData);
                                   }
        
        system.debug('prodName:: '+prodName);
        system.debug('mapProductData:: '+mapProductData);
        system.debug('Account Judgment : '+ mapProductNameIds);
        list<Product__c> listProductToUpdate = new list<product__c>();
        Map<Id,Product__c> productToUpdateMap = new Map<Id,Product__c>();
        //Update Current Pincipal Balance on Product from Judgment Balance wrt to Product when Judgment is updated to Active
        Product__c productInstance;
        updateJudgmentInterestBalOnProduct(listNewJudgments,mapOldJudgments);
        // String judgDate;
        for(Judgment__c judgment : listNewJudgments){
            //judgDate = String.valueOf(mapOldJudgments.get(judgment.ID).Judgment_Date__c);
            
            //Check if Judgment Date is added to Judgment record
            //check if legal status changed to Judgment and Judgment date is not null
            /*if(((mapOldJudgments.get(judgment.ID).Legal_Status__c != 'Judgment')
&& (judgment.Legal_Status__c == 'Judgment' || judgment.Legal_Status__c == 'Post-Judgment')
&& judgment.Judgment_Date__c != NULL)
|| ((judgment.Legal_Status__c == 'Judgment' || judgment.Legal_Status__c == 'Post-Judgment')
&& (judgment.Judgment_Date__c != NULL && mapOldJudgments.get(judgment.ID).Judgment_Date__c == NULL))){
if(judgment.Product_1__c != NULL
&& judgment.Interest_Rate_one__c != NULL
&& judgment.Balance_one__c != NULL){
system.debug('Product_1_Block run');
productInstance = new Product__c();
system.debug('mapProductNameIds:: '+mapProductNameIds.get(judgment.Product_1__c));
if(mapProductData.containsKey(judgment.Product_1__c)){
productInstance = mapProductData.get(judgment.Product_1__c);
productInstance.Id = mapProductData.get(judgment.Product_1__c).ID;
productInstance.Name = mapProductData.get(judgment.Product_1__c).Name;
}
system.debug('productInstance.Id::'+productInstance.Id);
system.debug('productInstance.Current_Balance__c before::'+productInstance.Current_Balance__c);

if(mapProductData.containsKey(productInstance.Name)){
if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
&& mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
Decimal interesttoAdjust = 0;
system.debug('interesttoAdjust::'+interesttoAdjust);

productInstance.Current_Principal_Balance__c = judgment.Balance_one__c;
interesttoAdjust =(productInstance.Current_Principal_Balance__c
* (Judgment.Judgment_Date__c.daysBetween(Date.Today())) 
*  Judgment.Interest_Rate_one__c) /100/365;
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('interesttoAdjust::'+interesttoAdjust);

//set the Current Interest Amount to the adjusted amount, since once judgment comes, Interest Amount on Product becomes 0,
//and only adjusted amount should show up in product current interest amount
productInstance.Current_Interest_Amount__c = interesttoAdjust;
productInstance.Judgment_Rate__c = judgment.Interest_Rate_one__c;

if(mapProductData.containsKey(judgment.Product_1__c)){
system.debug('Bolck run1 product...1');
ProductInstance.Previous_Interest_Rate__c = mapProductData.get(judgment.Product_1__c).Interest_Rate__c;
ProductInstance.Previous_Principal_Balance__c = mapProductData.get(judgment.Product_1__c).Current_Principal_Balance__c;
}
system.debug('judg interest one before**'+judgment.Interest_Rate_one__c);
ProductInstance.Interest_Rate__c = judgment.Interest_Rate_one__c;
system.debug('ProductInstance Interest_Rate1**'+ProductInstance.Interest_Rate__c);
productInstance.Current_Balance__c = 
(productInstance.Current_Principal_Balance__c != NULL ? productInstance.Current_Principal_Balance__c : 0)
+(productInstance.Current_Interest_Amount__c != NULL ? productInstance.Current_Interest_Amount__c : 0)
+(productInstance.Recoverable_Fee__c != NULL ? productInstance.Recoverable_Fee__c : 0);
}
}
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('productInstance.Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
//productInstance.Current_Balance__c = productInstance.Current_Principal_Balance__c + productInstance.Current_Interest_Amount__c;
system.debug('Current_Interest_Amount__c ::: '+productInstance.Current_Interest_Amount__c);
system.debug('Current_Balance__c::: '+productInstance.Current_Balance__c);
if(productInstance.ID != NULL){
listProductToUpdate.add(productInstance);
productToUpdateMap.put(productInstance.id,productInstance);
}
}

//Product 2 recalculation
if(judgment.Product_2__c != NULL
&& judgment.Interest_Rate_two__c != NULL
&& judgment.Balance_two__c != NULL){
system.debug('Product_2__c_Block run');
productInstance = new Product__c();
system.debug('mapProductData:: '+mapProductData.get(judgment.Product_2__c));
if(mapProductData.containsKey(judgment.Product_2__c)){
productInstance.Id = mapProductData.get(judgment.Product_2__c).ID;
productInstance.Name = mapProductData.get(judgment.Product_2__c).Name;
productInstance = mapProductData.get(judgment.Product_2__c);

if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
&& mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
Decimal interesttoAdjust = 0;
system.debug('interesttoAdjust::'+interesttoAdjust);
system.debug('Bal 1 Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
productInstance.Current_Principal_Balance__c = judgment.Balance_two__c;
system.debug('no of days::'+Judgment.Judgment_Date__c.daysBetween(Date.Today()));

interesttoAdjust = (productInstance.Current_Principal_Balance__c
* (Judgment.Judgment_Date__c.daysBetween(Date.Today())) 
*  Judgment.Interest_Rate_two__c) /100/365;
system.debug('Bal 1 .Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('Bal 1 interesttoAdjust::'+interesttoAdjust);
productInstance.Current_Interest_Amount__c = interesttoAdjust;
productInstance.Judgment_Rate__c = judgment.Interest_Rate_two__c;
ProductInstance.Interest_Rate__c = judgment.Interest_Rate_two__c;

if(mapProductData.containsKey(judgment.Product_2__c)){
system.debug('Bolck run1 product...1');
ProductInstance.Previous_Interest_Rate__c = mapProductData.get(judgment.Product_2__c).Interest_Rate__c;
ProductInstance.Previous_Principal_Balance__c = mapProductData.get(judgment.Product_2__c).Current_Principal_Balance__c;
}

productInstance.Current_Balance__c = 
(productInstance.Current_Principal_Balance__c != NULL ? productInstance.Current_Principal_Balance__c : 0)
+(productInstance.Current_Interest_Amount__c != NULL ? productInstance.Current_Interest_Amount__c : 0)
+(productInstance.Recoverable_Fee__c != NULL ? productInstance.Recoverable_Fee__c : 0);

system.debug('Bal 1.4 ::'+productInstance.Current_Balance__c);
}
}
system.debug('productInstance.Id::'+productInstance.Id);
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('productInstance.Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
//productInstance.Current_Balance__c = productInstance.Current_Principal_Balance__c + productInstance.Current_Interest_Amount__c;
system.debug('Current_Interest_Amount__c ::: '+productInstance.Current_Interest_Amount__c);
system.debug('Current_Balance__c::: '+productInstance.Current_Balance__c);
if(productInstance.ID != NULL){
listProductToUpdate.add(productInstance);
productToUpdateMap.put(productInstance.id,productInstance);
}
}
//Product 2 recalculation ends

//Product 3 recalculation
if(judgment.Product_3__c != NULL
&& judgment.Interest_Rate_three__c != NULL
&& judgment.Balance_three__c != NULL){
system.debug('Product_3_Block run');
productInstance = new Product__c();
system.debug('mapProductData:: '+mapProductData.get(judgment.Product_3__c));
if(mapProductData.containsKey(judgment.Product_3__c)){
productInstance.Id = mapProductData.get(judgment.Product_3__c).ID;
productInstance.Name = mapProductData.get(judgment.Product_3__c).Name;    
productInstance = mapProductData.get(productInstance.Name);

if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
&& mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
Decimal interesttoAdjust = 0;
system.debug('interesttoAdjust::'+interesttoAdjust);

productInstance.Current_Principal_Balance__c = judgment.Balance_three__c;

interesttoAdjust = (productInstance.Current_Principal_Balance__c
* (Judgment.Judgment_Date__c.daysBetween(Date.Today())) 
*  Judgment.Interest_Rate_three__c) /100/365;
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('interesttoAdjust::'+interesttoAdjust);
productInstance.Current_Interest_Amount__c = interesttoAdjust;
productInstance.Judgment_Rate__c = judgment.Interest_Rate_three__c;       
ProductInstance.Interest_Rate__c = judgment.Interest_Rate_three__c;

if(mapProductData.containsKey(judgment.Product_3__c)){
system.debug('Bolck run3 product...3');
ProductInstance.Previous_Interest_Rate__c = mapProductData.get(judgment.Product_3__c).Interest_Rate__c;
ProductInstance.Previous_Principal_Balance__c = mapProductData.get(judgment.Product_3__c).Current_Principal_Balance__c;
}

productInstance.Current_Balance__c = 
(productInstance.Current_Principal_Balance__c != NULL ? productInstance.Current_Principal_Balance__c : 0)
+(productInstance.Current_Interest_Amount__c != NULL ? productInstance.Current_Interest_Amount__c : 0)
+(productInstance.Recoverable_Fee__c != NULL ? productInstance.Recoverable_Fee__c : 0);

system.debug('productInstance3.Current_Balance__c::'+productInstance.Current_Balance__c);
}
}
system.debug('productInstance.Id::'+productInstance.Id);
system.debug('productInstance.Current_Balance__c before::'+productInstance.Current_Balance__c);

Decimal finalUpdateInterestAmount;
Decimal finalCurrentBalance;
Date interestAmountLastCalculatedDate;

system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('productInstance.Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
system.debug('Current_Interest_Amount__c ::: '+productInstance.Current_Interest_Amount__c);
system.debug('Current_Balance__c::: '+productInstance.Current_Balance__c);
if(productInstance.ID != NULL){
listProductToUpdate.add(productInstance);
productToUpdateMap.put(productInstance.id,productInstance);
}
}
//Product 3 recalculation ends

//Product 4 recalculation
if(judgment.Product_4__c != NULL
&& judgment.Interest_Rate_four__c != NULL
&& judgment.Balance_four__c != NULL){
system.debug('Product_4_Block run');
productInstance = new Product__c();
system.debug('mapProductData:: '+mapProductData.get(judgment.Product_4__c));
if(mapProductData.containsKey(judgment.Product_4__c)){
productInstance.Id = mapProductData.get(judgment.Product_4__c).ID;
productInstance.Name = mapProductData.get(judgment.Product_4__c).Name;
productInstance = mapProductData.get(judgment.Product_4__c);

if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
&& mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
Decimal interesttoAdjust = 0;
system.debug('interesttoAdjust::'+interesttoAdjust);

productInstance.Current_Principal_Balance__c = judgment.Balance_four__c;

interesttoAdjust = (productInstance.Current_Principal_Balance__c
* (Judgment.Judgment_Date__c.daysBetween(Date.Today())) 
*  Judgment.Interest_Rate_four__c) /100/365;
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('interesttoAdjust::'+interesttoAdjust);
productInstance.Current_Interest_Amount__c = interesttoAdjust;
productInstance.Judgment_Rate__c = judgment.Interest_Rate_four__c;       
ProductInstance.Interest_Rate__c = judgment.Interest_Rate_four__c;

if(mapProductData.containsKey(judgment.Product_4__c)){
system.debug('Bolck run1 product...4');
ProductInstance.Previous_Interest_Rate__c = mapProductData.get(judgment.Product_4__c).Interest_Rate__c;
ProductInstance.Previous_Principal_Balance__c = mapProductData.get(judgment.Product_4__c).Current_Principal_Balance__c;
}

productInstance.Current_Balance__c = 
(productInstance.Current_Principal_Balance__c != NULL ? productInstance.Current_Principal_Balance__c : 0)
+(productInstance.Current_Interest_Amount__c != NULL ? productInstance.Current_Interest_Amount__c : 0)
+(productInstance.Recoverable_Fee__c != NULL ? productInstance.Recoverable_Fee__c : 0);
}
}
system.debug('productInstance.Id::'+productInstance.Id);

system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('productInstance.Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
//productInstance.Current_Balance__c = productInstance.Current_Principal_Balance__c + productInstance.Current_Interest_Amount__c;
system.debug('Current_Interest_Amount__c ::: '+productInstance.Current_Interest_Amount__c);
system.debug('Current_Balance__c::: '+productInstance.Current_Balance__c);
if(productInstance.ID != NULL){
listProductToUpdate.add(productInstance);
productToUpdateMap.put(productInstance.id,productInstance);
}
}
//Product 4 recalculation ends

//Product 5 recalculation
if(judgment.Product_5__c != NULL
&& judgment.Interest_Rate_five__c != NULL
&& judgment.Balance_five__c != NULL){
system.debug('Product_5_Block run');
productInstance = new Product__c();
system.debug('mapProductData:: '+mapProductData.get(judgment.Product_5__c));
if(mapProductData.containsKey(judgment.Product_5__c)){
productInstance.Id = mapProductData.get(judgment.Product_5__c).ID;
productInstance.Name = mapProductData.get(judgment.Product_5__c).Name;
productInstance.Current_Balance__c = mapProductData.get(productInstance.Name).Current_Principal_Balance__c;
productInstance = mapProductData.get(judgment.Product_5__c);
if(mapProductData.get(productInstance.Name).Current_Principal_Balance__c != NULL
&& mapProductData.get(productInstance.Name).Current_Principal_Balance__c > 0){
Decimal interesttoAdjust = 0;
system.debug('interesttoAdjust::'+interesttoAdjust);

productInstance.Current_Principal_Balance__c = judgment.Balance_five__c;

interesttoAdjust = (productInstance.Current_Principal_Balance__c
* (Judgment.Judgment_Date__c.daysBetween(Date.Today())) 
*  Judgment.Interest_Rate_five__c) /100/365;
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('interesttoAdjust::'+interesttoAdjust);
productInstance.Current_Interest_Amount__c = interesttoAdjust;
productInstance.Judgment_Rate__c = judgment.Interest_Rate_five__c;                               
ProductInstance.Interest_Rate__c = judgment.Interest_Rate_five__c;

if(mapProductData.containsKey(judgment.Product_5__c)){
system.debug('Bolck run1 product...5');
ProductInstance.Previous_Interest_Rate__c = mapProductData.get(judgment.Product_5__c).Interest_Rate__c;
ProductInstance.Previous_Principal_Balance__c = mapProductData.get(judgment.Product_5__c).Current_Principal_Balance__c;
}


productInstance.Current_Balance__c = 
(productInstance.Current_Principal_Balance__c != NULL ? productInstance.Current_Principal_Balance__c : 0)
+(productInstance.Current_Interest_Amount__c != NULL ? productInstance.Current_Interest_Amount__c : 0)
+(productInstance.Recoverable_Fee__c != NULL ? productInstance.Recoverable_Fee__c : 0);

system.debug(' productInstance.Current_Balance__5::'+ productInstance.Current_Balance__c);
}
}
system.debug('productInstance.Id::'+productInstance.Id);
system.debug('productInstance.Current_Balance__c before::'+productInstance.Current_Balance__c);
system.debug('productInstance.Current_Principal_Balance__c::'+productInstance.Current_Principal_Balance__c);
system.debug('productInstance.Current_Interest_Amount__c::'+productInstance.Current_Interest_Amount__c);
//productInstance.Current_Balance__c = productInstance.Current_Principal_Balance__c + productInstance.Current_Interest_Amount__c;
system.debug('Current_Interest_Amount__c ::: '+productInstance.Current_Interest_Amount__c);
system.debug('Current_Balance__c::: '+productInstance.Current_Balance__c);
if(productInstance.ID != NULL){
listProductToUpdate.add(productInstance);
productToUpdateMap.put(productInstance.id,productInstance);
}
}
//Product 5 recalculation ends
}*/
            if(config.Run_Judgment_Update_API_For_Portal__c){ 
                //call API
                if(judgment.Agency_Initiated_Legal_Action__c != NULL && judgment.Placed_Agency__c != NULL){
                    PortalJudgmentProcessingAPI.processJudgment(judgment.ID); 
                }
                
                /*if(judgment.Legal_Agency__c != null &&
                   judgment.Name == mapOldJudgments.get(judgment.ID).Name &&
                   judgment.Legal_Status__c != null &&
                   judgment.Legal_Sub_Status__c != null &&
                   config.Send_Notification__c == true
                  ){
                      system.debug('Notification::');
                      notificationCallAPI(judgment.Legal_Agency__c,'Judgment','Judgment Updated','Judgment ' + judgment.Name + ' has been updated  to status update '+ judgment.Legal_Status__c + ' '+judgment.Legal_Sub_Status__c);
                  }*/
                
            }
        }
        system.debug('Product List' + listProductToUpdate);
        
        //update listProductToUpdate;
        update productToUpdateMap.values();
        
    }
    
    
    //using this inner method populate the identifier fields using CFG data.
    public static void getJudgmentRelatedData(list<Judgment__c> listJudgment){
        
        system.debug('listJudgment in related data' +listJudgment);
        set<Id> setSuperiorCourtID = new set<Id>();
        set<Id> setSmallCourtClaimID = new set<Id>();
        set<Id> setEnforcementCountyID = new set<Id>();
        set<Id> setCountyID = new set<Id>();
        
        map<Id, String> mapSuperiorCourtNames = new map<Id, String>();
        map<Id, String> mapSmallCourtClaimNames = new map<Id, String>();
        map<Id, String> mapEnforcementCountyNames = new map<Id, String>();
        map<Id, String> mapCountyNames = new map<Id, String>();
        
        for(Judgment__c judgmentObj : listJudgment){
            
            system.debug('judgmentObj:'+judgmentObj);
            setSuperiorCourtID.add(judgmentObj.Superior_Court__c);
            setSmallCourtClaimID.add(judgmentObj.Small_Claims_Court__c);
            setEnforcementCountyID.add(judgmentObj.Enforcement_County__c);
            setCountyID.add(judgmentObj.County__c);
            
        }
        
        for(Superior_Court__c sCourt : [SELECT ID, Name
                                        FROM Superior_Court__c
                                        WHERE ID IN : setSuperiorCourtID]){
                                            mapSuperiorCourtNames.put(sCourt.Id, sCourt.Name);
                                            
                                        }
        
        for(Small_Claims_Court__c smallCourt  : [SELECT ID, Name
                                                 FROM Small_Claims_Court__c
                                                 WHERE ID IN :setSmallCourtClaimID]){
                                                     mapSmallCourtClaimNames.put(smallCourt.ID, smallCourt.Name);
                                                     
                                                 }
        
        for(Enforcement_County__c enforceCounty : [SELECT ID, Name
                                                   FROM Enforcement_County__c
                                                   WHERE ID IN :setEnforcementCountyID]){
                                                       mapEnforcementCountyNames.put(enforceCounty.ID, enforceCounty.Name);
                                                       
                                                   }
        List<Court__c> countyData = [SELECT ID, Name
                                     FROM Court__c
                                     WHERE ID IN :setCountyID];
        
        for(Court__c county : countyData){
            mapCountyNames.put(county.ID, county.Name);
        }
        
        for(Judgment__c JudgmentObj : listJudgment){
            
            JudgmentObj.Superior_Court_Identifier__c = mapSuperiorCourtNames.get(JudgmentObj.Superior_Court__c);
            JudgmentObj.Small_Claims_Court_Identifier__c = mapSmallCourtClaimNames.get(JudgmentObj.Small_Claims_Court__c);
            JudgmentObj.Enforcement_County_Identifier__c = mapEnforcementCountyNames.get(JudgmentObj.Enforcement_County__c);
            JudgmentObj.County_Identifier__c = mapCountyNames.get(JudgmentObj.County__c);
            
        }
        
    }
    
    public static void validationRulesProductToJudgment(list<Judgment__c> listNewJudgments, list<String> listLegalStatuses){
        ProductTriggerHandler.runPaymentProcessing = False;
        //JudgmentTriggerHandler.runUpdateProductStatus = False;
        system.debug('inside validation block'); 
        system.debug('listNewJudgments check****'+listNewJudgments);
        String Codes;
        String Product_1;
        String AgencyLegalAction = '';
        String Province = '';
        String Plaintiff = '';
        map<ID, ID> mapActiveAccountJudgments = new map<ID, ID>(); 
        Set<ID> mapProdId =new Set<ID>();
        map<ID,Product__c> mapProd = new map<ID,Product__c>();                                                     
        system.debug('listNewJudgments'+listNewJudgments);
        
        /*Decimal Total = 0;
for(Judgment__c judgmentObj : listNewJudgments){
system.debug('Total::' +Total);
if(judgmentObj.Suit_Amount_1__c == NULL){
system.debug('inside if****');
Total += 0; 
}
if(judgmentObj.Suit_Amount_2__c == NULL){
system.debug('inside if****');
Total += 0; 
}
if(judgmentObj.Suit_Amount_3__c == NULL){
system.debug('inside if****');
Total += 0; 
}
if(judgmentObj.Suit_Amount_4__c == NULL){
system.debug('inside if****');
Total += 0; 
}
if(judgmentObj.Suit_Amount_5__c == NULL){
system.debug('inside if****');
Total += 0; 
}

if(judgmentObj.Suit_Amount_1__c <> NULL){
Total += judgmentObj.Suit_Amount_1__c; 
}
if(judgmentObj.Suit_Amount_2__c <> NULL){
Total += judgmentObj.Suit_Amount_2__c; 
}
//system.debug('judgmentObj.Suit_Amount_3__c'+judgmentObj.Suit_Amount_3__c);
if(judgmentObj.Suit_Amount_3__c <> NULL){
Total += judgmentObj.Suit_Amount_3__c; 
}
if(judgmentObj.Suit_Amount_4__c <> NULL){
Total += judgmentObj.Suit_Amount_4__c; 
}
if(judgmentObj.Suit_Amount_5__c <> NULL){
Total += judgmentObj.Suit_Amount_5__c; 
}
}
system.debug('Total suite amount ::' +Total);*/
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();                                                    
        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                         Product_Sub_status__c,Judgment_Legal_Status__c,
                                                         Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                         WHERE Product_Parent__c IN :listLegalStatuses ]){
                                                             system.debug('mapping**'+ mapping);                                                
                                                             mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);
                                                             system.debug('mapAccountJudgmentCodes**'+ mapAccountJudgmentCodes);                                                
                                                             
                                                         }                                                                   
        for(Account_Judgment__c accJudgment : [SELECT ID, Judgment__c, Product__c
                                               FROM Account_Judgment__c
                                               WHERE Judgment__c IN :listNewJudgments]){
                                                   mapActiveAccountJudgments.put(accJudgment.Judgment__c , accJudgment.Product__c);
                                                   mapProdId.add(accJudgment.Product__c);                                       
                                               }
        system.debug('mapActiveAccountJudgments'+mapActiveAccountJudgments);
        system.debug('mapProdId'+mapProdId);                                                      
        for(Product__c prod : [SELECT ID,Name, Collection_Agency__c,Collection_Agency_Placement__c ,State__c,
                               Account_Purchasing_Entity_Value__c
                               FROM Product__c
                               WHERE ID = :mapProdId
                              ]){
                                  mapProd.put(prod.id,prod);                    
                              }                                                    
        system.debug('mapProd'+mapProd);                                                          
        for(Judgment__c judg : listNewJudgments){
            system.debug('judg****'+judg);
            Product__c product = new Product__c();
            product.ID = mapActiveAccountJudgments.get(judg.ID);
            system.debug('product.ID trigger handler'+product.ID);
            system.debug('mapProd product.ID'+mapProd.get(product.ID));
            if(mapProd.get(product.ID) != NULL){
                //Populate Agency from Product to Judgment.
                if(mapProd.get(product.ID).Collection_Agency__c != NULL){
                    AgencyLegalAction = String.valueOf(Math.floor(mapProd.get(product.ID).Collection_Agency__c)); 
                }
                //Populate Province from Product to Judgment.
                if(mapProd.get(product.ID).State__c != NULL){
                    prodProvinceName = mapProd.get(product.ID).State__c;
                    ProvinceNameFormat = nameFormat(prodProvinceName);
                    provinceAcronymFormat = prodProvinceName.toUpperCase();
                    if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                        Province = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
                    }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                        Province = ProvinceNameFormat; 
                    }
                }
                //if(String.isBlank(judg.Product_1__c) || judg.Product_1__c == NULL){
                Product_1 = mapProd.get(product.ID).Name;
                //}
                
                system.debug('Product_1 test**'+Product_1);
                //if(String.isNotBlank(judg.Plaintiff__c)){
                Plaintiff = mapProd.get(product.ID).Account_Purchasing_Entity_Value__c;    
                //}
                system.debug('Plaintiff test**'+Plaintiff);
            }
            //system.debug('Judgment_Province__c check'+judg.Judgment_Province__c);
            if(!(mapProd.isEmpty())){
                if(mapAccountJudgmentCodes.containsKey(judg.Legal_Status__c+judg.Legal_Sub_Status__c)){
                    codes = mapAccountJudgmentCodes.get(judg.Legal_Status__c+judg.Legal_Sub_Status__c).Codes__c;    
                }
            }
            if(Test.isRunningTest()){
                system.debug('test##'+ judg.Legal_Status__c+judg.Legal_Sub_Status__c);
                if(mapAccountJudgmentCodes.containsKey(judg.Legal_Status__c+judg.Legal_Sub_Status__c)){
                    codes = mapAccountJudgmentCodes.get(judg.Legal_Status__c+judg.Legal_Sub_Status__c).Codes__c;    
                }
            }
            
            
            system.debug('codes test**'+codes);
            system.debug('Product_1 test**'+Product_1);
            if((codes == '220000') || (codes == '220210') || (codes =='220700') || (codes =='220030') 
               || (codes =='220040') || (codes =='220050')){
                   system.debug('inside code trigger');
                   if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                      || judg.Suit_Amount__c == NULL /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) || ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/
                      || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                      || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                      || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                          
                          judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                          system.debug('error 1');
                      }
                   if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                          /*|| judg.Balance_one__c == NULL*/ || judg.Interest_Rate_one__c == NULL))){
                                                              judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1');  
                                                              system.debug('error 2');
                                                              
                                                          }
                   if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                                  /*|| judg.Balance_two__c == NULL*/ || judg.Interest_Rate_two__c == NULL))){
                                                                      system.debug('error 3');
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                                  /*|| judg.Balance_three__c == NULL*/ || judg.Interest_Rate_three__c == NULL))){
                                                                      system.debug('error 4');
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                                  /*|| judg.Balance_four__c == NULL*/ || judg.Interest_Rate_four__c == NULL))){
                                                                      system.debug('error 5');
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                                  /*|| judg.Balance_five__c == NULL*/ || judg.Interest_Rate_five__c == NULL))){
                                                                      system.debug('error 6');
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');  
                                                                      
                                                                  }
                   /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
               }
            system.debug('Plaintiff__c****'+judg.Plaintiff__c);
            //system.debug('Agency_Initiated_Legal_Action__c****'+judg.Agency_Initiated_Legal_Action__c);
            //system.debug('Product_1__c****'+judg.Product_1__c);
            if((codes == '220020') || (codes == '220220') || (codes == '220900') || (codes == '290400')
               || (codes == '299100') || (codes == '299999') || (codes == '290020')){
                   if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                      || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                      /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) 
|| ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/
                      || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                      || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                      || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                          judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                      }
                   if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                          /*|| judg.Balance_one__c == NULL*/ || judg.Interest_Rate_one__c == NULL))){
                                                              judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1');  
                                                              
                                                          }
                   if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                                  /*|| judg.Balance_two__c == NULL*/ || judg.Interest_Rate_two__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2');  
                                                                      
                                                                  }
                   
                   if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                                  /*|| judg.Balance_three__c == NULL*/ || judg.Interest_Rate_three__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                                  /*|| judg.Balance_four__c == NULL*/ || judg.Interest_Rate_four__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                                  /*|| judg.Balance_five__c == NULL*/ || judg.Interest_Rate_five__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');  
                                                                      
                                                                  }
                   /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
               }
            if((codes == '290000') || (codes == '290010') || (codes == '290700') || (codes == '291000')
               || (codes == '290030') || (codes == '290040') || (codes == '290050') || (codes == '293010')
               || (codes == '293030') || (codes == '293040') || (codes == '293050') || (codes == '295070')
               || (codes == '295080') || (codes == '295900')){
                   if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                      || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                      || judg.Judgment_Date__c == NULL || judg.Judgment_Amount__c == NULL
                      || judg.Filing_Date__c == NULL /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) || ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/
                      || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                      || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                      || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                          system.debug('inside error msg 290000');
                          judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                      }
                   if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                          || judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL))){
                                                              judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1');  
                                                              
                                                          }
                   if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                                  || judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2');   
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                                  || judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                                  || judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                                  || judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');  
                                                                      
                                                                  }
                   /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
               }
            if((codes == '290005')){
                if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                   || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                   || judg.Judgment_Date__c == NULL || judg.Judgment_Amount__c == NULL
                   || judg.Filing_Date__c == NULL /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) || ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/ ){
    judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date');
}
                if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                       || judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL))){
                                                           judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1');  
                                                           
                                                       }
                if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                               || judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 2,Balance-2,interest Rate-2,Suit Amount 2');  
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                               || judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 3,Balance-3,interest Rate-3,Suit Amount 3');  
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                               || judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 4,Balance-4,interest Rate-4,Suit Amount 4');  
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                               ||  judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 5,Balance-5,interest Rate-5,Suit Amount 5');    
                                                                   
                                                               }
                /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
            }
            
            if((codes == '293000') || (codes == '294000')){
                system.debug('293000 and 294000');
                if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                   || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                   || judg.Judgment_Date__c == NULL || judg.Judgment_Amount__c == NULL
                   || judg.Filing_Date__c == NULL /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) || ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/
                   || String.isBlank(judg.Garnishment_Number__c) || judg.Garnishment_Date__c == NULL
                   || judg.Garnishment_Amount__c == NULL
                   || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                   || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                   || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                       system.debug('inside error');
                       judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                   }
                if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                       || judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL))){
                                                           judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1');  
                                                           
                                                       }
                if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                               || judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate2,Suit Amount 2');   
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                               || judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');   
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                               || judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');   
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                               || judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');  
                                                                   
                                                               }
                /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
            }
            if((codes == '295000') || (codes == '295030') || (codes == '295060') || (codes == '295010')
               || (codes == '295040') || (codes == '295050')){
                   if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                      || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                      || judg.Judgment_Date__c == NULL || judg.Judgment_Amount__c == NULL
                      || judg.Filing_Date__c == NULL || String.isBlank(judg.Writ_Number__c) || judg.Writ_Amount__c == NULL
                      || judg.Date_Writ_Issued__c == NULL
                      || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                      || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                      || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                          judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                      }
                   if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                          || judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL))){
                                                              judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1');  
                                                              
                                                          }
                   if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                                  || judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2');   
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                                  || judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');  
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                                  || judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');    
                                                                      
                                                                  }
                   if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                                  || judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))){
                                                                      judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');    
                                                                      
                                                                  }
                   /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
               }
            if((codes == '295020')){
                if(String.isBlank(judg.Case_Number__c) || String.isBlank(Province)
                   || judg.Suit_Amount__c == NULL || judg.Date_Debtor_Served__c == NULL
                   || judg.Judgment_Date__c == NULL || judg.Judgment_Amount__c == NULL
                   || judg.Filing_Date__c == NULL /*|| ((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
|| judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL)) || ((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
|| judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL)) || ((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
|| judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL)) || ((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
|| judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL)) || ((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
|| judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))*/
                   || String.isBlank(judg.Writ_Number__c) || judg.Writ_Amount__c == NULL
                   || judg.Date_Writ_Issued__c == NULL || judg.Garnishment_Amount__c == NULL
                   || String.isBlank(judg.Garnishment_Number__c) || judg.Garnishment_Date__c == NULL
                   || String.isBlank(judg.Court__c) /*|| String.isBlank(judg.County__c)*/
                   || String.isBlank(judg.Legal_Firm__c) || String.isBlank(Plaintiff)
                   || String.isBlank(judg.Attorney__c) || String.isBlank(AgencyLegalAction)){
                       judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action');
                   }
                if(((String.isNotBlank(Product_1)) && (judg.Suit_Amount_1__c == NULL 
                                                       || judg.Balance_one__c == NULL || judg.Interest_Rate_one__c == NULL))){
                                                           judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1');  
                                                           
                                                       }
                if(((String.isNotBlank(judg.Product_2__c)) && (judg.Suit_Amount_2__c == NULL 
                                                               || judg.Balance_two__c == NULL || judg.Interest_Rate_two__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2');  
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_3__c)) && (judg.Suit_Amount_3__c == NULL 
                                                               || judg.Balance_three__c == NULL || judg.Interest_Rate_three__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3');    
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_4__c)) && (judg.Suit_Amount_4__c == NULL 
                                                               || judg.Balance_four__c == NULL || judg.Interest_Rate_four__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4');  
                                                                   
                                                               }
                if(((String.isNotBlank(judg.Product_5__c)) && (judg.Suit_Amount_5__c == NULL 
                                                               || judg.Balance_five__c == NULL || judg.Interest_Rate_five__c == NULL))){
                                                                   judg.addError('Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5');   
                                                                   
                                                               }
                /*if(judg.Suit_Amount__c != Total){
judg.addError('Suit amount is not equal all Product suit amount');
}*/
            }
        }
        //JudgmentTriggerHandler.runUpdateProductStatus = True;
        //ProductTriggerHandler.runPaymentProcessing = True;                                                     
    }
    public static void validationRules(list<Judgment__c> listJudgment, Map<Id, Judgment__c> mapOldJudgment){
        
        for(Judgment__c judg : listJudgment){
            Judgment__c judgOld= mapOldJudgment.get(judg.id);
            
            if(judgOld.Legal_Status__c == 'Judgment' && judg.Legal_Status__c == 'Pre-Judgment'){
                
                judg.addError('Invalid status received. The Judgment must be vacated prior to assigning a different status');
            }
            
            if(judg.Legal_Status__c == 'Post-Judgment' && (judg.Date_Writ_Issued__c == null || judg.Writ_Amount__c == null || judg.Garnishment_Date__c == null || judg.Garnishment_Amount__c == null)){
                
                judg.addError('A writ date is not found, A writ amount is not found, A garnishment date is not found, A garnishment amount is not found');
            }
            
            if(judg.Legal_Status__c == 'Judgment' && (judg.Judgment_Date__c == null || judg.Judgment_Amount__c == null || (judg.Product_1__c != Null && judg.Interest_Rate_one__c == null) 
                                                      || (judg.Product_2__c != Null && judg.Interest_Rate_two__c == null) || (judg.Product_3__c != Null && judg.Interest_Rate_three__c == null)
                                                      || (judg.Product_4__c != Null && judg.Interest_Rate_four__c == null) || (judg.Product_5__c != Null && judg.Interest_Rate_five__c == null))){
                                                          
                                                          //judg.addError('A judgment date is not found, A judmgent amount is not found, A judgment interest rate is not found');
                                                      }
            
            if(judg.Legal_Status__c == 'Pre-Judgment' && (judg.Suit_Amount__c == null || judg.Case_Number__c == null || judg.Judgment_Province__c == null || judg.Plaintiff__c == null ) && (judg.Enforcement_County_Address__c == null && judg.Small_Claims_Court_Address__c == null && judg.Superior_Court_Address__c == null)){
                
                judg.addError('A suit amount was not found, A case number was not found, A judgment province was not found, A court division was not found, A court location was not found, A plaintiff was not found');
            }
            
            if(judg.Legal_Status__c == 'Pre-Legal' && (judg.Judgment_Province__c == null || judg.Suit_Amount__c  == null || judg.Case_Number__c == null || judg.Plaintiff__c == null || judg.County__c == null || judg.Legal_Firm__c == null || judg.Attorney__c == null) && (judg.Superior_Court__c == null && judg.Small_Claims_Court__c == null && judg.Enforcement_County__c == null)){
                
                judg.addError('suit amount not found, case number not found, judgment geography not found, court not found, county not found, plaintiff not found, attorney not found and legal firm not found');
            }
            system.debug('judg.Legal_Status__c '+judg.Legal_Status__c);
            system.debug('judg.Legal_Sub_Status__c '+judg.Legal_Sub_Status__c);
            if((judg.Legal_Status__c != 'Judgment' && judg.Legal_Status__c != 'Post-Judgment') && judg.Legal_Sub_Status__c == 'Vacated'){
                
                judg.addError('There is no judgment on this account to vacate');
            }
            
            if((judg.Legal_Status__c == 'Judgment' || judg.Legal_Sub_Status__c == 'Post-Judgment') && (judg.Judgment_Date__c != judgOld.Judgment_Date__c || judg.Judgment_Amount__c != judgOld.Judgment_Amount__c || judg.Interest_Rate_one__c != judgOld.Interest_Rate_one__c
                                                                                                       || judg.Interest_Rate_two__c != judgOld.Interest_Rate_two__c || judg.Interest_Rate_three__c != judgOld.Interest_Rate_three__c
                                                                                                       || judg.Interest_Rate_four__c != judgOld.Interest_Rate_four__c || judg.Interest_Rate_five__c != judgOld.Interest_Rate_five__c)){
                                                                                                           
                                                                                                           //judg.addError('Cannot update the judgment information, you must vacate the judgment if this information is not correct');
                                                                                                       }
            
            if((judgOld.Legal_Status__c != 'Judgment' || judgOld.Legal_Status__c != 'Post-Judgment') 
               && (judg.Legal_Status__c == 'Judgment' || judg.Legal_Status__c == 'Post-Judgment') 
               && (judg.Judgment_Amount__c == null || judg.Judgment_Date__c == null)){
                   
                   judg.addError('Judgment Amount is required, Judgment Date is required');
               }
            
            
            
        }
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
    
    public static void recalculateDisbursmentFees(set<ID> productId){
        system.debug('inside calculation');
        List<String> prodId = new List<String>();
        List<Judgment__c> updateJudg = new List<Judgment__c>();
        Map<Id,Judgment__c> judgMap = new Map<Id,Judgment__c>();
        Decimal Nonrecoverable = 0;
        Decimal recoverable = 0;
        
        List<Account_Judgment__c> accJudgment = [SELECT ID, Judgment__c, Product__c,Product__r.name,
                                                 Judgment__r.Product_1__c,Judgment__r.Product_2__c,
                                                 Judgment__r.Product_3__c,Judgment__r.Product_4__c,
                                                 Judgment__r.Product_5__c
                                                 FROM Account_Judgment__c
                                                 WHERE Product__c IN:productId];
        system.debug('accJudgment**'+accJudgment);
        for(Account_Judgment__c accJud: accJudgment){
            if(accJud.Judgment__r.Product_1__c != NULL){
                prodId.add(accJud.Judgment__r.Product_1__c);
            }
            if(accJud.Judgment__r.Product_2__c != NULL){
                prodId.add(accJud.Judgment__r.Product_2__c);
            }
            if(accJud.Judgment__r.Product_3__c != NULL){
                prodId.add(accJud.Judgment__r.Product_3__c);
            }
            if(accJud.Judgment__r.Product_4__c != NULL){
                prodId.add(accJud.Judgment__r.Product_4__c);
            }
            if(accJud.Judgment__r.Product_5__c != NULL){
                prodId.add(accJud.Judgment__r.Product_5__c);
            }
        }
        
        for(AggregateResult aggr : [SELECT Judgment__c, sum(Product__r.Non_Recoverable_Fee__c) totalNonRecov,
                                    sum(Product__r.Recoverable_Fee__c) totalRecov
                                    FROM Account_Judgment__c 
                                    WHERE 
                                    Product__r.Name IN :prodId
                                    GROUP BY Judgment__c]){
                                        system.debug('aggr check::'+aggr);
                                        system.debug('totalNonRecov'+(decimal)aggr.get('totalNonRecov'));
                                        system.debug('totalRecov'+(decimal)aggr.get('totalRecov'));      
                                        Judgment__c judg=new Judgment__c();
                                        judg.id = (id)aggr.get('Judgment__c'); 
                                        judg.Balance_Adjusting_Disbursements__c = (decimal)aggr.get('totalRecov');
                                        judg.Non_Balance_Adjusting_Disbursements__c =  (decimal)aggr.get('totalNonRecov');
                                        judgMap.put(judg.id,judg);       
                                    }
        system.debug('judgMap Check**'+judgMap);
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        update judgMap.values();
        JudgmentTriggerHandler.runJudgmentTrigger = True;
    }
    //Bug: 5564 - Nagendra added below method
     //To Populate the Placement Ids on Judgment
     public static void populateJudgmentWithPlacement(List<Judgment__C> prodJudgList){
        
        Map <Id, String> placementIDMap = new Map<Id, String>();
        Set<ID> judgmentSet = new Set<ID>();
        Set<ID> productSet = new Set<ID>();
        Map<ID, Judgment__C> judgmentMap = new Map<ID, Judgment__C>();
        Map<ID, Product__C> ProductMap = new Map<Id, Product__C>();
        
        for(Judgment__C prodJudg : prodJudgList){
            judgmentSet.add(prodJudg.ID);
           // productSet.add(prodJudg.Product__c);
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
}