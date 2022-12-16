global class PortalProductAllocationSuccessErrorFile  implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{
    
    public id documentID,workAssignmentID;
    public List<Product_Staging__c> prodStagingLisgt = new List<Product_Staging__c>();
    public id recordIdentfier;
    public string failed = 'data_id,place_id,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,error';
    
    public string success = 'data_id,place_id,assignment_date,place_status,pool_name,current_commission_rate,commission_rate_at_time_of_placement,settlement_rate,settlement_rate_at_time_of_placement,value_tier_at_time_of_placement,success';
    
    public static final String ERROR = 'ERROR';
    public static final String SUCCESS_STR = 'SUCCESS';    
    public static final String FAILED_STR = 'FAILED';
    public static final String PLACEMENT_ALLOCATED = 'Placement (3); Allocated';
    public static final String ALLOCATED_DATA_STATUS_CODE = '300000';
    public static final String NEW_ALLOCATION_READY = '100000';
    public static final String PROCESSED = 'Processed';
    public string pendingstatus='Pending';
    public Decimal successRecords =0;
    public Decimal failedRecords =0;
    public set<string> failedStringSet = new Set<string>();
    public set<string> successStringSet = new Set<string>();
  	public string queryStr;
    public List<id> prdstgids = new List<id>();
    
    public integer totalProdStageRec,Totalcount=0;
    public PortalProductAllocationSuccessErrorFile(List<id> prdstgids,integer totalProdStageRec,id workAssignmentID,id documentID, string recordIdentfier) {     
             this.totalProdStageRec=totalProdStageRec;
             this.recordIdentfier = recordIdentfier;
        	this.documentID=documentID;     
        this.prdstgids=prdstgids;
        this.workAssignmentID=workAssignmentID;
    }
   
 global database.QueryLocator start(Database.BatchableContext BC) {
    failed += '\n';
     success += '\n';  
     queryStr=' SELECT Status_Changed_Date_Text__c,Placement_Status_Code__c,ID, Name__c, Comment__c, Placement_Agency__c, Status__c, Expected_Value__c,Document_Storage__c,Current_Principal_Balance__c,';
        queryStr = queryStr  +'Current_Interest_Balance__c,Fees__c,Document_Storage__r.File_Processing_Status__c, Product_ID__c, Identifier__c,Placement_Agency_ID__c,';
        queryStr = queryStr +'Document_Storage__r.Work_Assignment_Identifier__c, Pool_Name__c, Document_Storage__r.Work_Assignment__c,';
        queryStr = queryStr +'Record_Type_ID__c,Placed_Commission_Rate__c,Current_Commission_Rate__c,Pool_Name_ID__c,';
        queryStr = queryStr+'Value_Tier_at_Time_of_Placement__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c';
        queryStr = queryStr +' FROM Product_Staging__c WHERE Identifier__c = :recordIdentfier And id in:prdstgids limit 6000';
         return database.getQueryLocator(queryStr);
    }
 global void execute(Database.BatchableContext BC, List<Product_Staging__c> listproductstaging) {
     
    /* set<id> prodids = new set<id>();
     map<String,Placement__c> mapPlacement = new map<String,Placement__c>();
     for(Product_Staging__c productStaging1: listproductstaging){  
      prodids.add(productStaging1.Product_ID__c);
     }
     List<Product__c> listProductToUpdate = new List<Product__c>();
     list<Placement_History__c> listPlacementHistory = new list<Placement_History__c>();
           
     list<Placement__c> listPlacements = [SELECT ID, Name FROM Placement__c];
        Id placementID;
       if(!listPlacements.isEmpty()){
            for(Placement__c place : listPlacements){
                mapPlacement.put(place.Name,place);
            }
            placementID = listPlacements[0].ID;
            
        }
     
     map<ID, Product__c> mapProduct = new Map<ID, Product__c> ([SELECT ID, Name, Collection_Agency_Placement__c, Placement_Status__c,
                                                                          Current_Principal_Balance__c, Current_Interest_Amount__c,
                                                                          Interest_Rate__c, Current_Bal_NSF_Fees__c, Current_Bal_Attorney_Fees__c,
                                                                          Current_Bal_General_Fees__c, Current_Bal_Other_Fees__c,
                                                                          Current_Bal_Court_Fees__c, Collection_Agency_Placement__r.Commission_Rate__c
                                                                         FROM Product__c WHERE ID IN :prodids]);*/
 
for(Product_Staging__c productStaging1: listproductstaging){ 
		if(productStaging1.Status__c == PROCESSED ||
           productStaging1.Comment__c.contains('SUCCESS') || !productStaging1.Comment__c.contains('ERROR')){            	
                 success = success + productStaging1.Name__c+','+productStaging1.Placement_Agency__c+','
                                      + '"'+(Date.today()!= null ? Date.today() : NULL) 
                                      + '"'+','+(NEW_ALLOCATION_READY != null ? NEW_ALLOCATION_READY :NULL)
                                      +','+productStaging1.Pool_Name__c+','+productStaging1.Current_Commission_Rate__c
                                      +','+productStaging1.Placed_Commission_Rate__c+','+productStaging1.Current_Settlement_Rate__c
                                      +','+productStaging1.Placed_Settlement_Rate__c+','+productStaging1.Value_Tier_at_Time_of_Placement__c
                                      +','+SUCCESS_STR;
            	  success = success  + '\n';
                  successRecords = successRecords + 1;              
        	}else{
                String CommentError;  
                if(productStaging1.Comment__c!= null){
                    CommentError = productStaging1.Comment__c;
                    CommentError = CommentError.replaceAll('<br/>','');
                    CommentError = CommentError.replaceAll('</b>','');
                    CommentError = CommentError.replaceAll('<b>','');
					}
                   
               failed = failed+ productStaging1.Name__c+','+productStaging1.Placement_Agency__c
                                    +','+productStaging1.Pool_Name__c+','+productStaging1.Current_Commission_Rate__c
                                    +','+productStaging1.Placed_Commission_Rate__c+','+productStaging1.Current_Settlement_Rate__c
                                    +','+productStaging1.Placed_Settlement_Rate__c+','+productStaging1.Value_Tier_at_Time_of_Placement__c
                                    +','+(productStaging1.Comment__c!= null ? CommentError : NULL);
                 failedRecords = failedRecords + 1;
                  failed = failed + '\n';
            }    
    		Totalcount = Totalcount+1;
		}
     system.debug('failedRecords count '+failedRecords +' successRecords records'+successRecords);
 		system.debug(' prdstgids '+prdstgids.size()+'total count '+Totalcount +' process records'+totalProdStageRec);
        system.debug(documentID+' work assignemtn id 115'+workAssignmentID);
 		//if(Totalcount == totalProdStageRec)
        // DisplayProductAllocateStagingController.postDocumentAPI(documentID, workAssignmentID, successRecords,
        //                                                        failedRecords,failedStringSet,
          //                                  successStringSet,failed, success,null);//listproductstaging
     
 }
 global void finish(Database.BatchableContext BC){
        
}
                                      
}