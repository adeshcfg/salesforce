/**************************************************************************************************
*
* Class: AllocationProductProcessing
*
* @description : This class is used for to allocate product to agency.

* @author : A5E Consulting
* @date : 13/03/2023

*************************************************************************************************/
public class AllocationProductProcessing {

    public static decimal successRecords = 0;
    public static decimal failedRecords = 0;
    public static List<User> systemName= new list<User>();
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public static Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    
    //Allocate product to agency.
    public static void allocateProducts(List<Product_Staging__c> prodStagingList,String workAssignmentId){  
        
    List<Product_Staging__c> listProductStaging = new List<Product_Staging__c>();
        list<Product__c> listProductToUpdate = new list<Product__c>();
        try {
            List<Id> prodIdList = new List<Id>();
            String PLACEMENT_ALLOCATED = 'Placement (3); Allocated';
            String ALLOCATED_DATA_STATUS_CODE = '300000';
            String NEW_ALLOCATION_READY = '100000';
            String PROCESSED = 'Processed';
            //Fetch System Api
            if(lrpSetting.Canaccede_API_User__c != NULL){
                systemName = [Select id, Name from User where username =: lrpSetting.Canaccede_API_User__c];    
            }
            //Fetch Product RecordType
            for(RecordType rType : [SELECT Id, DeveloperName, name FROM RecordType WHERE sobjectType = 'Product__c' ]){
                prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
            }
            
            list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
            list<Pool__c> listPoolUpdate = new list<Pool__c>();
            
            map<id,Pool__c> mapPool = new map<id,Pool__c>(); 
            transient map<String,Placement__c> mapPlacement = new map<String,Placement__c>(); 
            String productNames = '';
            String success;
            String failed;
            set<string> failedStringSet = new set<string>();
            Set <String> successStringSet = new Set <String>();
            String placementIdentifier = '9999';
            String ALLOCATED = '300000';
            String Product_Placement_Status = '';
            
            //Create Success and Failure file headers
            success = 'data_id,place_id,assignment_date,place_status,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,success';
            failed = 'data_id,place_id,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,error';
            //Get Placement ID
            list<Placement__c> listPlacements = [SELECT ID, Name,Commission_rate__c FROM Placement__c];
            Id placementID;
            if(!listPlacements.isEmpty()){
                for(Placement__c place : listPlacements){
                    mapPlacement.put(place.Name,place);
                }
                placementID = listPlacements[0].ID;
                
            }
            set<id> setProductIDs = new set<id>();
            set<id> setPoolIDs = new set<id>();
            List<id> prdstgids = new List<id>();
            for(Product_Staging__c productStaging : prodStagingList){
                setProductIDs.add(productStaging.Product_ID__c);
                setPoolIDs.add(productStaging.Pool_Name_ID__c);
                prdstgids.add(productStaging.id);
            }
            map<ID, Pool__c> mapPoolRecords = new map<ID, Pool__C> ([Select ID,name,Commission_rate__c from Pool__c Where id IN: setPoolIDs]);
            
            map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, Collection_Agency_Placement__c, Placement_Status__c,
                                                                       Current_Principal_Balance__c, Current_Interest_Amount__c,
                                                                       Interest_Rate__c, Current_Bal_NSF_Fees__c, Current_Bal_Attorney_Fees__c,
                                                                       Current_Bal_General_Fees__c, Current_Bal_Other_Fees__c,
                                                                       Current_Bal_Court_Fees__c, Collection_Agency_Placement__r.Commission_Rate__c,Pool_name__r.Commission_rate__c,
                                                                       Allocated_Amount_Total__c,Pool_Name__r.Name,Commission_Rate__c,Allocated_Amount_Fees__c,Allocated_Amount_Principal__c,
                                                                       Allocated_Amount_Interest__c,Recoverable_Fee__c,Non_Recoverable_Fee__c,Collection_Agency__c,OwnerId
                                                                       FROM Product__c WHERE ID IN :setProductIDs]);
            
            for(Product_Staging__c productStaging : prodStagingList){
                
                Product_Staging__c productStaging1 = new Product_Staging__c();
                productStaging1 = productStaging;
                String comment = '';
                if(String.isNotBlank(productStaging1.Comment__c)){
                    comment = productStaging1.Comment__c;
                }
                //If No error found, update product record from staging
                if(productStaging1.Status__c != 'Processed' ) {
                    productStaging1.Status__c = 'Processed';
                    Product__c product = new Product__c();
                    product.ID = productStaging1.Product_ID__c;
                    product.Collection_Agency__c = Decimal.valueOf(productStaging1.Placement_Agency__c);
                    if(String.isNotBlank(productStaging1.Placement_Agency__c)
                       && mapPlacement.containsKey(productStaging1.Placement_Agency__c)){
                           product.Collection_Agency_Placement__c=mapPlacement.get(productStaging1.Placement_Agency__c).ID; 
                       }
                    product.Assignment_Date__c = Date.today();
                    product.Assignment_Accepted_Date__c = NULL;
                    product.Recalled_Date__c = NULL;
                    //set placement status for new allocation
                    product.Placement_Status__c = NEW_ALLOCATION_READY;
                    product.Status_Changed_Date__c = Date.today();
                    product.Product_Status__c = ALLOCATED_DATA_STATUS_CODE;
                    product.Data_Status_Description__c = PLACEMENT_ALLOCATED;
                    product.Status__c = 'New Allocation - New Allocation';
                    product.Sub_Status__c = 'Ready';
                    product.Collection_Sub_Status__c = null;
                    product.RecordTypeId = productStaging1.Record_Type_ID__c; 
                    product.Commission_Rate_at_Time_of_Placement__c = productStaging1.Placed_Commission_Rate__c;
                    product.Commission_Rate__c = productStaging1.Current_Commission_Rate__c; 
                    product.Settlement_Rate__c = productStaging1.Current_Settlement_Rate__c; 
                    product.Value_Tier_at_Time_of_Placement__c = productStaging1.Value_Tier_at_Time_of_Placement__c;
                    product.Placed_Settlement_Rate__c = productStaging1.Placed_Settlement_Rate__c;
                    product.Pool_Name__c = productStaging1.Pool_Name_ID__c;
                    product.Allocated_Amount_Fees__c = productStaging1.Fees__c;
                    product.Allocated_Amount_Principal__c = productStaging1.Current_Principal_Balance__c;
                    product.Allocated_Amount_Interest__c = productStaging1.Current_Interest_Balance__c;
                    if(prodRTypeIdMap.get('Distressed_Account') == product.RecordTypeId
                       && Decimal.valueOf(productStaging1.Placement_Agency__c) != mapProduct.get(productStaging1.Product_ID__c).Collection_Agency__c){
                           Id oldOwnerId = mapProduct.get(productStaging1.Product_ID__c).OwnerId;
                           // Assign System API to Owner
                           if(!systemName.isEmpty()){
                               product.OwnerId = systemName[0].Id;      
                           }
                           //Also Assign the last owner to the previous ownership field
                           if(oldOwnerId <> NULL && oldOwnerId <> product.OwnerId){
                               product.Previous_Ownership__c = oldOwnerId;
                           }
                    }
                    productNames += productStaging1.Name__c + ',';
                    if(productStaging1.Product_ID__c!=null) {
                        prodIdList.add(productStaging1.Product_ID__c);
                    }
                    Pool__c pool = new Pool__c();
                    pool.ID = productStaging1.Pool_Name_ID__c;
                    pool.Placement_Agency__c = Decimal.valueOf(productStaging1.Placement_Agency__c);
                    pool.Placement_agency_lookup__c = productStaging1.Placement_Agency_ID__c; 
                    if(productStaging1.Pool_Name_ID__c != NULL){
                        mapPool.put(productStaging1.Pool_Name_ID__c,pool);
                    }
                    if(!mapProduct.keySet().isEmpty() && mapProduct.containsKey(productStaging1.Product_ID__c)){
                        Product__c productToRefer = mapProduct.get(productStaging1.Product_ID__c);
                        Placement_History__c placementHistory = new Placement_History__c();
                        placementHistory = DistressedUtilities.createPlaceHistoryAlloExcel_new(productStaging1,productToRefer,mapPlacement,mapPoolRecords);
                        listPlacementHistory.add(placementHistory); 
                    } 

                    successRecords = successRecords + 1;
                    listProductStaging.add(productStaging1);
                    listProductToUpdate.add(product);
                        
                }else{
                    failedRecords = failedRecords + 1;
                }
            }
            
            Work_Assignment__c workAssignment = new Work_Assignment__c();
            workAssignment.ID = workAssignmentId;
            workAssignment.Comment_Reply__c = '';
            workAssignment.Status__c = 'Completed';
            if(failedRecords > 0){
                workAssignment.Comment_Reply__c = 'No. of Records Failed: '+ failedRecords +'\n';
            }
            if(successRecords > 0){
                workAssignment.Comment_Reply__c += 'No. of Records Succeeded: '+ successRecords;
            }            
            Set<Product_Staging__c> prstg = new Set<Product_Staging__c>(listProductStaging);
            ProductTriggerHandler.runProductTrigger = false;
            PoolTriggerHandler.runPoolTrigger = false;
            update mapPool.values();
            PoolTriggerHandler.runPoolTrigger = true;
            
            // Commented by satyajit for ticket: 4217
            //PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
            
            //insert listPlacementHistory;
            //PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
            productNames.removeEnd(',');
            
            list<Work_Assignment__c> listWorkAssignmentToUpsert = new list<Work_Assignment__c>();
            
            try{
                if(listProductToUpdate.size()>0){
                    update listProductToUpdate;
                }
                
                // Added by satyajit for ticket: 4217
                if(listPlacementHistory.size()>0){
                     PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = false;
                     insert listPlacementHistory;
                     PlacementHistoryTriggerHandler.runPlacementHistoryTrigger = true;
                }
                
            }catch(Exception ex){
                
                for(Product_Staging__c productStaging: listProductStaging){
                    String msg = '<b>ERROR</b>-'+ex.getMessage();
                    if(msg.length() > 254){
                        msg = msg.substring(0,254);
                    }
                    productStaging.Comment__c= msg;
                    productStaging.status__c= 'Pending';
                    
                     successRecords -= 1;
                }
               
            }
            if(listProductStaging.size()>0){
                update listProductStaging;
            }
        }catch(Exception ex) {
            system.debug('exception success file--+--'+ex.getLineNumber());
            system.debug('exception success file--+--'+ex.getMessage());
        }
    }
}