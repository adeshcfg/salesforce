/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Distressed Notes Processing API
*  @author : A5E Consulting
*  @date : 11/02/2022

*************************************************************************************************/
public class PortalDistressedNotesProcessorUtil {
    //Create Request Fund record 
    public static String processDistressedNotes(Map<String,String> paramMap, Distressed_notes__c distressedNotes){
        //Create temporary distressed Notes instance to store request values
        //distressedNotes.Name = paramMap.get('Name');
        distressedNotes.Title__c = paramMap.get('Title');
        distressedNotes.Body__c = paramMap.get('Body');
        distressedNotes.Notes_History__c = paramMap.get('Notes_History');
        distressedNotes.Hist_Open__c = paramMap.get('Hist_Open');
        distressedNotes.Hist_Private__c = paramMap.get('Hist_Private');
        if(String.isNotBlank(paramMap.get('Notes_Date'))){
            distressedNotes.Notes_Date__c = Date.valueOf(paramMap.get('Notes_Date'));    
        }
        if(String.isNotBlank(paramMap.get('Hist_Completed'))){
            distressedNotes.Hist_Completed__c = Date.valueOf(paramMap.get('Hist_Completed'));    
        }
        if(String.isNotBlank(paramMap.get('Hist_Due'))){
            distressedNotes.Hist_Due__c = Date.valueOf(paramMap.get('Hist_Due'));    
        }
        distressedNotes.Visibility__c = paramMap.get('Visibility');
        distressedNotes.Customer_Identifier__c = paramMap.get('Customer_Identifier');
        distressedNotes.Product_Identifier__c = paramMap.get('Product_Identifier');
        distressedNotes.Judgment_Identifier__c = paramMap.get('Judgment_Identifier');
        distressedNotes.Settlement_Identifier__c = paramMap.get('Settlement_Identifier');
        distressedNotes.Created_By__c = paramMap.get('Created_By');
        distressedNotes.Last_Modified_By__c = paramMap.get('Last_Modified_By');
        distressedNotes.Distressed_Notes_Number__c = paramMap.get('Name');
        distressedNotes.Agency_ID__c = paramMap.get('Place_Id');
        system.debug('Place_Id::'+paramMap.get('Place_Id'));
        system.debug('Agency_ID__c::'+distressedNotes.Agency_ID__c);
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        try{
            //to not run distressedNotes trigger
            DistressedNotesTriggerHandler.runDistressedNotesTrigger = false;
            list<Distressed_notes__c> listDistressedNotes = new list<Distressed_notes__c>();
            listDistressedNotes.add(distressedNotes);
            getDistressedNotesRelatedAgencyData(listDistressedNotes);
            distressedNotes.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            distressedNotes.Inbound_API_Response_Body__c = 'Successfully Created';
            system.debug('distressedNotes: '+distressedNotes);
            
            /*List<Distressed_notes__c> listDistressedNotes1 = [SELECT ID,Name
                                             FROM Distressed_notes__c 
                                             WHERE Distressed_Notes_Number__c =: paramMap.get('Name')                                   
                                             LIMIT 1];
            system.debug('listDistressedNotes1::'+listDistressedNotes1);*/
            if(distressedNotes.ID == null){
                insert distressedNotes;
            }
            else{
                update distressedNotes;
            }
           
            DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in Distressed notes processing :'+ex);
            distressedNotes.Inbound_API_Response_Body__c = ex.getMessage();
            if(distressedNotes.Id != NULL){
                //update distressedNotes;    
            }
            DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;
            return ex.getMessage();
        }
    }
    
    //using this inner method populate the Lookup fields using agency data.
     static void getDistressedNotesRelatedAgencyData(list<Distressed_notes__c> listDistressedNotes){
        set<String> setCustomerID = new set<String>();
        set<String> setJudgmentID = new set<String>();
        set<String> setProductID = new set<String>();
        set<String> setSettlementID = new set<String>();

        map<String, Id> mapCustomerNames = new map<String, Id>();
        map<String, Id> mapJudgmentNames = new map<String, Id>();
        map<String, Id> mapProductNames = new map<String, Id>();
        map<String, Id> mapSettlementNames = new map<String, Id>();

     
        for(Distressed_notes__c distressedNotesObj : listDistressedNotes){
            setCustomerID.add(distressedNotesObj.Customer_Identifier__c);
            setJudgmentID.add(distressedNotesObj.Judgment_Identifier__c);
            setProductID.add(distressedNotesObj.Product_Identifier__c);
            setSettlementID.add(distressedNotesObj.Settlement_Identifier__c);
        }
        system.debug('setProductID::'+setProductID);
        
        try{
            for(Account Customer : [SELECT ID, Name, SF_ID__c
                                         FROM Account
                                         WHERE SF_ID__c IN :setCustomerID]){
                mapCustomerNames.put(Customer.SF_ID__c, Customer.ID);
            
                system.debug('Cutomer name' +mapCustomerNames);
            
            }
        }catch(Exception ex){
            system.debug('Exception ex:  '+ex);
        }
        system.debug('mapCustomerNames: '+mapCustomerNames);
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c
                                     FROM Judgment__c
                                     WHERE Judgment_Number__c IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.Judgment_Number__c, Judgment.ID);
            
        }
        for(Product__c product : [SELECT ID, Name
                                     FROM Product__c
                                     WHERE Name IN :setProductID]){
            mapProductNames.put(product.Name, product.ID);
            
        }
        system.debug('mapProductNames:'+mapProductNames);
        for(Settlement__c Settlement : [SELECT ID, Settlement_Number__c
                                     FROM Settlement__c
                                     WHERE Settlement_Number__c IN :setSettlementID]){
            mapSettlementNames.put(Settlement.Settlement_Number__c, Settlement.ID);
            
        }
        
        for(Distressed_notes__c distressedNotesObj : listDistressedNotes){
            distressedNotesObj.Customer__c = mapCustomerNames.get(distressedNotesObj.Customer_Identifier__c);
            distressedNotesObj.Judgment__c = mapJudgmentNames.get(distressedNotesObj.Judgment_Identifier__c);
            distressedNotesObj.Product__c = mapProductNames.get(distressedNotesObj.Product_Identifier__c);
            distressedNotesObj.Settlement__c = mapSettlementNames.get(distressedNotesObj.Settlement_Identifier__c);
 system.debug('distressedNotesObj_Product__c :'+distressedNotesObj.Product__c);
        system.debug('distressedNotesObj.Judgment__c:'+distressedNotesObj.Judgment__c);
        }
       
    }
}