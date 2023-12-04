/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 23/02/2021

*************************************************************************************************/
public class PortalComplaintProcessorUtil {
    //Create Request Fund record 
    public static String processComplaint(Map<String,String> paramMap, Work_Assignment__c complaint){
        //Create temporary account instance to store request values
        complaint.Task_Number__c = paramMap.get('Task_Number');
        complaint.Description__c = paramMap.get('Description');
        complaint.Priority__c = paramMap.get('Priority');
        complaint.Status__c = paramMap.get('Status');
        if(String.isNotBlank(paramMap.get('Requested_Date'))){
            complaint.Requested_Date__c = Date.valueOf(paramMap.get('Requested_Date'));    
        }
         if(String.isNotBlank(paramMap.get('Next_follow_up_date'))){
            complaint.Next_follow_up_date__c = Date.valueOf(paramMap.get('Next_follow_up_date'));    
        }
        if(String.isNotBlank(paramMap.get('Due_Date'))){
            complaint.Due_Date__c = Date.valueOf(paramMap.get('Due_Date'));    
        }
        complaint.CFG_Complaint_Analysis__c = paramMap.get('CFG_Complaint_Analysis');
        complaint.Complaint_Type__c = paramMap.get('Complaint_Type');
        complaint.Root_Cause__c = paramMap.get('Root_Cause');
        complaint.Original_Creditor__c = paramMap.get('Original_Creditor');
        complaint.Resolution_By__c = paramMap.get('Resolution_By');
        if(String.isNotBlank(paramMap.get('Resolution_Date'))){
            complaint.Resolution_Date__c = Date.valueOf(paramMap.get('Resolution_Date'));    
        }
       // complaint.Agency_Investigation_Notes__c = paramMap.get('Agency_Investigation_Notes');
        complaint.Agency_Investigation_Notes__c = paramMap.get('Result_of_Investigation');
        complaint.Source__c = paramMap.get('Source');
        complaint.Assign_To__c = paramMap.get('Assign_To');
       // complaint.Assign_To_Agency_User__c = paramMap.get('Assign_To_Agency_User');
         complaint.Assign_To_Agency_User__c = AgencyPortalUtil.getUserNamefromEmail(paramMap.get('Assign_To_Agency_User')); //For populating name from email
         System.debug('Assign_To_Agency_User__c-->'+ complaint.Assign_To_Agency_User__c);//Debug to check Assign_To_Agency_User__c
        complaint.Assigned_To_User_Name__c = paramMap.get('Assigned_To_User_Name');
        complaint.Customer_Identifier__c = paramMap.get('Customer_Identifier');
        
        //complaint.Judgment_Identifier__c = paramMap.get('Judgment_Identifier');
        complaint.Product_Identifier__c = paramMap.get('Product_Identifier');
        //complaint.Settlement_Identifier__c = paramMap.get('Settlement_Identifier');
        complaint.Placement_Agency_Identifier__c = paramMap.get('Placement_Agency_Identifier');
        complaint.Assigned_To_Agency_User_Email__c = paramMap.get('Assign_To_Agency_User');
        complaint.Last_Modified_By__c = paramMap.get('Last_Modified_By');
        //complaint.Comment_Reply__c = paramMap.get('Comment_Reply');
        complaint.Reopen_Comments__c = paramMap.get('Reopen_Comments');
        //complaint.Complaint_Related_To_Another_Products__c = paramMap.get('Complaint_Related_To_Another_Products');
        if(String.isNotBlank(paramMap.get('Complaint_Related_To_Another_Products__c'))){
            complaint.Complaint_Related_To_Another_Products__c = Boolean.valueOf(paramMap.get('Complaint_Related_To_Another_Products__c'));    
        } 
        complaint.Root_Cause_Other__c = paramMap.get('Root_Cause_Other');
        complaint.Complaint_Type_Other__c = paramMap.get('Complaint_Type_Other');
        complaint.Is_The_Complaint_Valid__c = paramMap.get('Is_The_Complaint_Valid');
        complaint.Have_You_Provided_Supporting_Media__c = paramMap.get('Have_You_Provided_Supporting_Media');
        //complaint.Request_To_Reopen__c = paramMap.get('Request_To_Reopen');
        complaint.Account_Being_CB_Reported_By_Agency__c = paramMap.get('Account_Being_CB_Reported_By_Agency');
        complaint.Agency_Currently_Has_Account_On_Hold__c = paramMap.get('Agency_Currently_Has_Account_On_Hold');
       // complaint.Canaccede_Entity__c = paramMap.get('Canaccede_Entity');
        if(String.isNotBlank(paramMap.get('Date_Complaint_Received_By_Agency'))){
            complaint.Date_Complaint_Received_By_Agency__c = Date.valueOf(paramMap.get('Date_Complaint_Received_By_Agency'));    
        }
        //New Field Added for agency
        complaint.Products_List__c = paramMap.get('Products_List');
        if(String.isNotBlank(paramMap.get('Is_Multiple_Products'))){
            complaint.Is_Multiple_Products__c = Boolean.valueOf(paramMap.get('Is_Multiple_Products'));
        }
        if(complaint.Products_List__c != null){
                complaint.Is_Multiple_Products__c = True;
        }
        
        system.debug('Comment_Reply: '+paramMap.get('Comment_Reply'));
        system.debug('Last_Modified_By__c: '+paramMap.get('Last_Modified_By'));
        
        DateTime dT = System.now();
        if(String.isNotBlank(paramMap.get('Comment_Reply'))){
           // if(workAssignment.Latest_Comment__c != paramMap.get('Comment_Reply')){
                system.debug('--Comments_History__c: '+complaint.Comments_History__c);
                system.debug('complaint.Comment_Reply__c: '+complaint.Latest_Comment__c);
                //workAssignment.Comment_Reply__c = paramMap.get('Comment_Reply');
                system.debug('Comment_Reply::'+paramMap.get('Comment_Reply'));
                complaint.Latest_Comment__c = paramMap.get('Comment_Reply');
                String Comment = complaint.Last_Modified_By__c + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() 
                    + '/' + dT.year()+ ';' + ' ' + ' ' + complaint.Latest_Comment__c + '\n' + '\n';
                system.debug('Comment : '+Comment );
                
                if(String.isNotBlank(complaint.Comments_History__c)){
                    Comment  = Comment  + complaint.Comments_History__c;
                }
                //Comment  += (String.isNotBlank(workAssignment.Comments_History__c) ? workAssignment.Comments_History__c: '');
                system.debug('Comment  2:'+Comment);
                complaint.Comments_History__c = Comment ;
                //workAssignment.Comment_Reply__c = '';
                system.debug('Comment History 3:' +complaint.Comments_History__c );
           // }
        }
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        try{
            //to not run workassignment trigger
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
            
            //Populate identifier fields from handler method
            list<Work_Assignment__c> listWorkAssignments = new list<Work_Assignment__c>();
            listWorkAssignments.add(complaint);
            //WorkAssignmentTriggerHandler.getWorkAssignRelatedAgencyData(listWorkAssignments);
            getWorkAssignRelatedAgencyData(listWorkAssignments);
            complaint.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            complaint.Inbound_API_Response_Body__c = 'Successfully Created';
            
            
            if(complaint.ID == NULL){
                complaint.RecordTypeID = portalSettings.AgencyComplaintWorkAssignmentRecordType__c ;
                complaint.Record_Type_Identifier__c = 'Agency_Complaint';
                //Ticket-3196 Added new field Customer Name 
                complaint.Customer_Name__c = paramMap.get('Customer_Name');
                insert complaint;
                system.debug('complaint: '+complaint);
            }
            else{
                update complaint;
            }
            getComplaintCountAgency(listWorkAssignments);
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in payment transaction insert :'+ex);
            complaint.Inbound_API_Response_Body__c = ex.getMessage();
            if(complaint.ID != NULL){
            update complaint;
                }
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            return ex.getMessage();
        }
    }
    
    //using this inner method populate the Lookup fields using agency data.
    public static void getWorkAssignRelatedAgencyData(list<Work_Assignment__c> listWorkAssignments){
     
     
        set<String> setPlacementID = new set<String>();
        set<String> setProductID = new set<String>();
        set<String> setCustomerID = new set<String>();
        set<String> setSettlementID = new set<String>();
        set<String> setJudgmentID = new set<String>();

     
        map<String, Id> mapPlacementNames = new map<String, Id>();
        map<String, Id> mapProductNames = new map<String, Id>();
        map<String, Id> mapCustomerNames = new map<String, Id>();
        map<String, Id> mapSettlementNames = new map<String, Id>();
        map<String, Id> mapJudgmentNames = new map<String, Id>();

        //getComplaintCountAgency(listWorkAssignments);
        
        for(Work_Assignment__c workAssignObj : listWorkAssignments){
     
            setPlacementID.add(workAssignObj.Placement_Agency_Identifier__c);
            setProductID.add(workAssignObj.Product_Identifier__c);
            setCustomerID.add(workAssignObj.Customer_Identifier__c);
            setSettlementID.add(workAssignObj.Settlement_Identifier__c);
            setJudgmentID.add(workAssignObj.Judgment_Identifier__c);
       
        }
        
        for(Placement__c placement : [SELECT ID, Name
                                     FROM Placement__c
                                     WHERE Name IN : setPlacementID]){
            mapPlacementNames.put(placement.Name, placement.Id);
            
        }
        
        for(Product__c product : [SELECT ID, Name
                                     FROM Product__c
                                     WHERE Name IN :setProductID]){
            mapProductNames.put(product.Name, product.ID);
            
        }
        
        try{
            for(Account Customer : [SELECT ID, Name, SF_ID__c
                                         FROM Account
                                         WHERE SF_ID__c IN :setCustomerID]){
                mapCustomerNames.put(Customer.SF_ID__c, Customer.ID);
            
                system.debug('Cutomer name' +mapCustomerNames);
            
            }
        }catch(Exception e){
        
        }
        for(Settlement__c Settlement : [SELECT ID, Settlement_Number__c
                                     FROM Settlement__c
                                     WHERE Settlement_Number__c IN :setSettlementID]){
            mapSettlementNames.put(Settlement.Settlement_Number__c, Settlement.ID);
            
        }
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c
                                     FROM Judgment__c
                                     WHERE Judgment_Number__c IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.Judgment_Number__c, Judgment.ID);
            
        }
        
        for(Work_Assignment__c workAssignObj : listWorkAssignments){
        
       
            workAssignObj.Placement_Agency__c = mapPlacementNames.get(workAssignObj.Placement_Agency_Identifier__c);
            if(workAssignObj.ID == NULL){
                system.debug('Blok run sucessfully');
                workAssignObj.Product__c = mapProductNames.get(workAssignObj.Product_Identifier__c);
                workAssignObj.Customer__c = mapCustomerNames.get(workAssignObj.Customer_Identifier__c);
            }
            workAssignObj.Settlement__c = mapSettlementNames.get(workAssignObj.Settlement_Identifier__c);
            workAssignObj.Judgment__c = mapJudgmentNames.get(workAssignObj.Judgment_Identifier__c);

        }
    }
    
    //Complaint count on Customer and Product
    public static void getComplaintCountAgency(list<Work_Assignment__c> listWorkAssignments){
        system.debug('listWorkAssignments:::' +listWorkAssignments);
        Work_Assignment__c newListWorkAss = listWorkAssignments.get(0);
        set<String> setProductIDs = new set<String>();
        String setCustomerIDs = '';
        
        for(Work_Assignment__c wrkAss : listWorkAssignments){
            setProductIDs.add(wrkAss.Product_Identifier__c);
            setCustomerIDs = wrkAss.Customer_Identifier__c;
        }
        
        String customerID;
        Id custId;
        Decimal prodcomplaintcount = 0;
        Decimal customercomplaintcount = 0;
        Account cust;
        Product__c prodData;
        Map<String, AggregateResult> mapProdCompCount = new Map<String, AggregateResult>();
        Map<id, decimal> mapCustomerCompCount = new Map<id, decimal>();
        
        if(newListWorkAss.Complaint_Type__c != null){
            
            if(setProductIDs.isEmpty() && setCustomerIDs == null){
                return;
            }
            if(setCustomerIDs == null && !setProductIDs.isEmpty()){
                if(!Test.isRunningTest()){
                	List<Product__c> prodCustomerList = [Select id,name,Customer__c,Customer__r.SF_ID__c,Customer__r.Number_Of_Open_Complaint__c from product__c where name IN: setProductIDs Limit 1];     
                    if(!prodCustomerList.isEmpty() && prodCustomerList[0].Customer__r.SF_ID__c != null){
                        customerID = prodCustomerList[0].Customer__r.SF_ID__c;
                    }else{
                        return;
                    }
                }                
            }else{
                customerID = setCustomerIDs;
            }
            
            //step 1: get open customer complaint count store it in an variable
            if(customerID != NULL){
                AggregateResult[] custGroupedResults = [select Customer__c, Count(Customer__r.SF_ID__c)comptCustomercnt from Work_Assignment__c 
                                                        WHERE (Customer__r.SF_ID__c =:customerID AND Customer__r.SF_ID__c != NULL)
                                                        AND Customer__c != NULL AND Product__c = NULL
                                                        AND Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                        AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                        GROUP BY Customer__c];
                
                if(custGroupedResults != NULL && !custGroupedResults.isEmpty()){
                    for (AggregateResult arr : custGroupedResults)  {
                        if((decimal)arr.get('comptCustomercnt') > 0){ 
                            custId = (id)arr.get('Customer__c');
                            customercomplaintcount = (decimal)arr.get('comptCustomercnt');
                        }
                    }
                }
            }
            
            //step 2: get all product associated to customer
            List<product__c> listProdData = [Select id,name,Number_Of_Open_Complaint__c from product__c where Customer__r.SF_ID__c =: customerID]; 
            List<String> prodListIds = new List<String>();
            for(product__c prodIDList: listProdData){
                prodListIds.add(prodIDList.name);
            }
            
            //step 3: get all complaint based on product retrive in step 2
            AggregateResult[] prodGroupedResults = [select Product__c prodId, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                    WHERE Product__r.Name IN :prodListIds 
                                                    AND Product__c != NULL
                                                    AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                         AND Status__c != 'Closed - Unjustified - Cease and Desist Request')
                                                    AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                    GROUP BY Product__c];
            if(prodGroupedResults != NULL && !prodGroupedResults.isEmpty()) { 
                for (AggregateResult ar : prodGroupedResults)  {
                    //step 4: create map for step 3 with product and complaint count
                    mapProdCompCount.put((String)ar.get('prodId'),ar);
                    prodcomplaintcount += (decimal)ar.get('comptProductcnt');
                }
            }
            
            //step 5: loop all the product of customer
            Map<id,product__c> prodMap = new Map<id,product__c>();
            for(Product__c prodDlist : listProdData){
                prodData=new Product__c();
                prodData.id = prodDlist.Id;
                if(mapProdCompCount.containsKey(prodDlist.id)){
                    AggregateResult prodCompTotalCount = mapProdCompCount.get(prodDlist.id);
                    prodData.Number_Of_Open_Complaint__c = (Decimal)prodCompTotalCount.get('comptProductcnt') + customercomplaintcount;
                }else{
                    prodData.Number_Of_Open_Complaint__c = customercomplaintcount;
                }
                prodMap.put(prodData.id,prodData);
            }
            
            ProductTriggerHandler.runProductTrigger = false;
            update prodMap.values();
            ProductTriggerHandler.runProductTrigger = true;
            
            cust=new Account();
            if(custId != null){
                cust.id = custId;
            }
            if(customerID != null){
                List<Account> customerDetails = [SELECT Id FROM Account WHERE SF_ID__c = :customerID LIMIT 1];
                cust.id = customerDetails[0].Id;
            }
            cust.Number_Of_Open_Complaint__c = customercomplaintcount;
            cust.Number_Of_Open_Product_Complaint__c = prodcomplaintcount;
            
            CustomerTriggerHandler.runCustomerTrigger= false;
            if(!Test.isRunningTest()){
                update cust; 
            }
                
            CustomerTriggerHandler.runCustomerTrigger= true;
            
        }
    }
}