/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
public class PortalWorkAssignmentProcessorUtil {
    //Create Request Fund record 
    public static String processWorkAssignment(Map<String,String> paramMap, Work_Assignment__c workAssignment){
        //Create temporary account instance to store request values
        workAssignment.Title__c = paramMap.get('Title');
        workAssignment.Task_Number__c = paramMap.get('Task_Number');
        workAssignment.Description__c = paramMap.get('Description');
        workAssignment.Purpose__c = paramMap.get('Purpose');
        workAssignment.Sub_Purpose__c = paramMap.get('Sub_Purpose');
        workAssignment.Priority__c = paramMap.get('Priority');
        workAssignment.Status__c = paramMap.get('Status');
        //Addtional fields for Media request sub-purpose
        workAssignment.Start_Month__c = paramMap.get('Start_Month');
        workAssignment.Start_Year__c = paramMap.get('Start_Year');
        workAssignment.End_Month__c = paramMap.get('End_Month');
        workAssignment.End_Year__c = paramMap.get('End_Year');
        
        //Addtional fields for Media request status-purpose
          
        workAssignment.Other_Media_Request__c = paramMap.get('Other_Media_Request');
        workAssignment.Other_Media_Request_Status__c = paramMap.get('Other_Media_Request_Status');
        workAssignment.Application_Status__c = paramMap.get('Application_Status');
        workAssignment.Statements_Status__c = paramMap.get('Statements_Status');
        workAssignment.Cardholder_Agreement_Status__c = paramMap.get('Cardholder_Agreement_Status');
        workAssignment.Check_Copy_Status__c = paramMap.get('Check_Copy_Status');
        workAssignment.PPSA_Registration_Status__c = paramMap.get('PPSA_Registration_Status');
        workAssignment.Drivers_License_Status__c = paramMap.get('Drivers_License_Status');
        workAssignment.Repossession_And_Auction_DocumentsStatus__c = paramMap.get('Repossession_And_Auction_DocumentsStatus');
        workAssignment.Note_Lines_Status__c = paramMap.get('Note_Lines_Status');
        
        //Addtional fields for Media request status-purpose
        workAssignment.Other_Media_Request__c = paramMap.get('Other_Media_Request');
        if(String.isNotBlank(paramMap.get('Application'))){
            workAssignment.Application__c = Boolean.valueOf(paramMap.get('Application'));    
        }
        if(String.isNotBlank(paramMap.get('Statements'))){
            workAssignment.Statements__c = Boolean.valueOf(paramMap.get('Statements'));    
        } 
        if(String.isNotBlank(paramMap.get('Cardholder_Agreement'))){
            workAssignment.Cardholder_Agreement__c = Boolean.valueOf(paramMap.get('Cardholder_Agreement'));    
        } 
        if(String.isNotBlank(paramMap.get('Check_Copy'))){
            workAssignment.Check_Copy__c = Boolean.valueOf(paramMap.get('Check_Copy'));    
        } 
        if(String.isNotBlank(paramMap.get('PPSA_Registration'))){
            workAssignment.PPSA_Registration__c = Boolean.valueOf(paramMap.get('PPSA_Registration'));    
        } 
        if(String.isNotBlank(paramMap.get('Drivers_License'))){
            workAssignment.Drivers_License__c = Boolean.valueOf(paramMap.get('Drivers_License'));    
        }
        if(String.isNotBlank(paramMap.get('Repossession_And_Auction_Documents'))){
            workAssignment.Repossession_And_Auction_Documents__c = Boolean.valueOf(paramMap.get('Repossession_And_Auction_Documents'));    
        }
        if(String.isNotBlank(paramMap.get('Note_Lines'))){
            workAssignment.Note_Lines__c = Boolean.valueOf(paramMap.get('Note_Lines'));    
        }
        if(String.isNotBlank(paramMap.get('Other'))){
            workAssignment.Other__c = Boolean.valueOf(paramMap.get('Other'));    
        }
        if(String.isNotBlank(paramMap.get('Last_Payment_Statement'))){
            workAssignment.Last_Payment_Statement__c = Boolean.valueOf(paramMap.get('Last_Payment_Statement'));    
        }
        if(String.isNotBlank(paramMap.get('Charge_Off_Statement'))){
            workAssignment.Charge_Off_Statement__c = Boolean.valueOf(paramMap.get('Charge_Off_Statement'));    
        }
        
        if(String.isNotBlank(paramMap.get('Requested_Date'))){
            workAssignment.Requested_Date__c = Date.valueOf(paramMap.get('Requested_Date'));    
        }
        if(String.isNotBlank(paramMap.get('Due_Date'))){
            workAssignment.Due_Date__c = Date.valueOf(paramMap.get('Due_Date'));    
        }

        workAssignment.Customer_Identifier__c = paramMap.get('Customer_Identifier');
        workAssignment.Judgment_Identifier__c = paramMap.get('Judgment_Identifier');
        workAssignment.Product_Identifier__c = paramMap.get('Product_Identifier');
        workAssignment.Settlement_Identifier__c = paramMap.get('Settlement_Identifier');
        workAssignment.Placement_Agency_Identifier__c = paramMap.get('Placement_Agency_Identifier');
        workAssignment.Assign_To__c = paramMap.get('Assign_To');
        workAssignment.Last_Modified_By__c = paramMap.get('Last_Modified_By');
        workAssignment.Assigned_To_Agency_User_Email__c= paramMap.get('Last_Modified_By');
        workAssignment.Assign_To_Agency_User__c = AgencyPortalUtil.getUserNamefromEmail(paramMap.get('Last_Modified_By'));
        workAssignment.Source__c = paramMap.get('Source');
       // workAssignment.Comments_History__c = paramMap.get('Comment_Reply');
        system.debug('workAssignment: '+workAssignment.Source__c);
        system.debug('Comment_Reply: '+paramMap.get('Comment_Reply'));
        system.debug('workAssignment.Comment_Reply__c: '+workAssignment.Comment_Reply__c);
        system.debug('Last_Modified_By__c: '+paramMap.get('Last_Modified_By'));
        
        DateTime dT = System.now();
        if(String.isNotBlank(paramMap.get('Comment_Reply'))){
           // if(workAssignment.Latest_Comment__c != paramMap.get('Comment_Reply')){
                system.debug('--Comments_History__c: '+workAssignment.Comments_History__c);
                system.debug('workAssignment.Comment_Reply__c: '+workAssignment.Latest_Comment__c);
                //workAssignment.Comment_Reply__c = paramMap.get('Comment_Reply');
                workAssignment.Latest_Comment__c = paramMap.get('Comment_Reply');
                String Comment = workAssignment.Last_Modified_By__c + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() 
                    + '/' + dT.year()+ ';' + ' ' + ' ' + workAssignment.Latest_Comment__c + '\n' + '\n';
                system.debug('Comment : '+Comment );
                
                if(String.isNotBlank(workAssignment.Comments_History__c)){
                    Comment  = Comment  + workAssignment.Comments_History__c;
                }
                //Comment  += (String.isNotBlank(workAssignment.Comments_History__c) ? workAssignment.Comments_History__c: '');
                system.debug('Comment  2:'+Comment);
                workAssignment.Comments_History__c = Comment ;
                //workAssignment.Comment_Reply__c = '';
                system.debug('Comment History 3:' +workAssignment.Comments_History__c );
           // }
        }
        
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        try{
            //to not run workassignment trigger
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
            
            //Populate identifier fields from handler method
            list<Work_Assignment__c> listWorkAssignments = new list<Work_Assignment__c>();
            system.debug('workAssignment checking in Util' +workAssignment);
            listWorkAssignments.add(workAssignment);
            getWorkAssignRelatedAgencyData(listWorkAssignments);
            workAssignment.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            workAssignment.Inbound_API_Response_Body__c = 'Successfully Created';
            if(workAssignment.ID == NULL){
                if(workAssignment.Purpose__c == 'Media Request'){
                    workAssignment.RecordTypeID = portalSettings.AgencyMediaWorkAssignmentRecordTypeID__c ;
                    workAssignment.Record_Type_Identifier__c = 'Agency_Media';
                }
                else if(workAssignment.Purpose__c == 'Excel File Processing'){
                    workAssignment.RecordTypeID = portalSettings.AgencyExcelProcessingRecordTypeID__c;
                    workAssignment.Record_Type_Identifier__c = 'Agency_Excel_Processing';
                }
                else{
                    workAssignment.RecordTypeID = portalSettings.Agency_Work_Assignment_RecordTypeID__c ;
                    workAssignment.Record_Type_Identifier__c = 'Agency';
                }
                insert workAssignment;
                system.debug('workAssignment: '+workAssignment);
            }
            else{
                update workAssignment;
            }
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in workassignment insert :'+ex);
            workAssignment.Inbound_API_Response_Body__c = ex.getMessage();
            if(workAssignment.ID != NULL){
                update workAssignment;    
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
        
        for(Product__c product : [SELECT ID, Name , Originating_Creditor__c
                                  FROM Product__c
                                  WHERE Name IN :setProductID ]){
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
        list<Product__c> prodList = [Select id ,Name, Originating_Creditor__c from Product__c where Name =:setProductID  ];
        
        for(Work_Assignment__c workAssignObj : listWorkAssignments){
            workAssignObj.Placement_Agency__c = mapPlacementNames.get(workAssignObj.Placement_Agency_Identifier__c);
            workAssignObj.Product__c = mapProductNames.get(workAssignObj.Product_Identifier__c);
            workAssignObj.Customer__c = mapCustomerNames.get(workAssignObj.Customer_Identifier__c);
            workAssignObj.Settlement__c = mapSettlementNames.get(workAssignObj.Settlement_Identifier__c);
            workAssignObj.Judgment__c = mapJudgmentNames.get(workAssignObj.Judgment_Identifier__c);
            
            For (Product__c prod :prodList ){
                try{
                    if (workAssignObj.Product__c != Null || workAssignObj.Original_Creditor__c == Null){
                        system.debug('Block run 1 '+prod.Originating_Creditor__c);
                        workAssignObj.Original_Creditor__c = prod.Originating_Creditor__c ; 
                    } 
                }
                Catch(Exception e){
                    System.debug('Blockrun 2'+e);
                }
            }
            
        }
    }
}