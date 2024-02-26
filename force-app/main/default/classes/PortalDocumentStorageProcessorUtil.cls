/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Document Storage Processing API
*  @author : A5E Consulting
*  @date : 18/01/2022

*************************************************************************************************/
public class PortalDocumentStorageProcessorUtil {
    //Create Request Fund record 
    public static String processDocumentStorage(Map<String,String> paramMap, Document_Storage__c documentStorage){
        //Create temporary account instance to store request values
        documentStorage.Creator__c = paramMap.get('Creator');
        documentStorage.Document_Storage_Number__c = paramMap.get('Document_Storage_Number');
        documentStorage.Document_Id__c = paramMap.get('Document_Id');
        documentStorage.Document_Name__c = paramMap.get('Document_Name');
        documentStorage.Document_Type__c = paramMap.get('Document_Type');
        if(documentStorage.Document_Type__c == 'Product Payment Upload  File'){
            documentStorage.Document_Type__c = 'Product Payment Upload File';
        }
        if(paramMap.get('Document_URL').contains('refer to legal')){
            documentStorage.Document_URL__c = paramMap.get('Document_URL').replace('refer to legal', 'refer%20to%20legal');
            system.debug('Document_URL__c::'+documentStorage.Document_URL__c);
        }else{
            documentStorage.Document_URL__c = paramMap.get('Document_URL');
        }
        documentStorage.Placement_Identifier__c = paramMap.get('Placement_Identifier');
        documentStorage.Uploaded_By__c = paramMap.get('Uploaded_By');
        documentStorage.Visibility__c = paramMap.get('Visibility');
        documentStorage.Record_Type_Identifier__c = paramMap.get('Record_Type_Identifier');
        documentStorage.Customer_Identifier__c = paramMap.get('Customer_Identifier');
        documentStorage.Product_Identifier__c = paramMap.get('Product_Identifier');
        documentStorage.Judgment_Identifier__c = paramMap.get('Judgment_Identifier');
        documentStorage.Settlement_Identifier__c = paramMap.get('Settlement_Identifier');
        documentStorage.Work_Assignment_Identifier__c = paramMap.get('Work_Assignment_Identifier');
        documentStorage.Created_By__c = paramMap.get('Created_By');
        documentStorage.Creator__c = paramMap.get('Created_By');
        documentStorage.Last_Modified_By__c = paramMap.get('Last_Modified_By');
        documentStorage.Creator__c = AgencyPortalUtil.getUserNamefromEmail(paramMap.get('Created_By'));//for populating Creator Field
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        
        try{
            //to not run documentStorage trigger
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            list<Document_Storage__c> listDocStorage = new list<Document_Storage__c>();
            listDocStorage.add(documentStorage);
            getDocStrorageRelatedAgencyData(listDocStorage);
            documentStorage.Inbound_API_Request_Body__c = String.valueOf(paramMap);
            documentStorage.Inbound_API_Response_Body__c = 'Document Storage Record Successfully Created';
            system.debug('documentStorage: '+documentStorage);
            if(documentStorage.ID == NULL){
                documentStorage.RecordTypeID = portalSettings.Distressed_Document_Storage_RecordtypeID__c;
                insert documentStorage;

                if((documentStorage.Document_Type__c == 'Product Payment Upload File'
                  || documentStorage.Document_Type__c == 'Account Status (having Judgment) Update File'
                  || documentStorage.Document_Type__c == 'Product Recall File'
                  || documentStorage.Document_Type__c == 'Product Bulk Pool Update File')
                && documentStorage.Document_Id__c != NULL
                && (documentStorage.File_Processing_Status__c != 'Processed')){
                   DocumentStorageTriggerHandler.exceltoJSONService(documentStorage.Document_Id__c, documentStorage.Placement_Identifier__c, documentStorage.ID,
                                  documentStorage.Document_Type__c, documentStorage.Document_URL__c);
                }
                
                if(documentStorage.Document_Type__c == 'Customer Contact Information Update File' && documentStorage.Document_Id__c != null && documentStorage.File_Processing_Status__c != 'Processed'){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new CustomerStagingExcelFileProcessing(documentStorage.Document_URL__c, documentStorage.Placement_Identifier__c, documentStorage.Id));
                    }
                }
               if(documentStorage.Document_Type__c == 'Account Status Update File'){
                   Database.executeBatch(new ExcelToJSONBatch(documentStorage.Document_Id__c, documentStorage.Placement_Identifier__c, documentStorage.ID,
                                  documentStorage.Document_Type__c, documentStorage.Document_URL__c),200);
                }
            }
            else{
                update documentStorage;
            }
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in document storage processing :'+ex);
            documentStorage.Inbound_API_Response_Body__c = ex.getMessage();
            if(documentStorage.ID != NULL){
                update documentStorage;
            }
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return ex.getMessage();
        }
    }
    
    //using this inner method populate the Lookup fields using agency data.
    public static void getDocStrorageRelatedAgencyData(list<Document_Storage__c> listDocStorages){
        set<String> setWorkAssignmentID = new set<String>();
        set<String> setProductID = new set<String>();
        set<String> setCustomerID = new set<String>();
        set<String> setSettlementID = new set<String>();
        set<String> setJudgmentID = new set<String>();
        set<String> setPlacementID = new set<String>();

        map<String, Id> mapWorkAssignmentNames = new map<String, Id>();
        map<String, Id> mapProductNames = new map<String, Id>();
        map<String, Id> mapCustomerNames = new map<String, Id>();
        map<String, Id> mapSettlementNames = new map<String, Id>();
        map<String, Id> mapJudgmentNames = new map<String, Id>();
        map<String, Id> mapPlacementNames = new map<String, Id>();

        for(Document_Storage__c docStorageObj : listDocStorages){
     
            setWorkAssignmentID.add(docStorageObj.Work_Assignment_Identifier__c);
            setProductID.add(docStorageObj.Product_Identifier__c);
            setCustomerID.add(docStorageObj.Customer_Identifier__c);
            setSettlementID.add(docStorageObj.Settlement_Identifier__c);
            setJudgmentID.add(docStorageObj.Judgment_Identifier__c);
            setPlacementID.add(docStorageObj.Placement_Identifier__c);
       
        }
        
        for(Work_Assignment__c workAssign : [SELECT ID, Task_Number__c
                                     FROM Work_Assignment__c
                                     WHERE Task_Number__c IN : setWorkAssignmentID]){
            mapWorkAssignmentNames.put(workAssign.Task_Number__c, workAssign.Id);
            
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
        
        for(Placement__c Placement : [SELECT ID, Name
                                     FROM Placement__c
                                     WHERE Name IN :setPlacementID]){
            mapPlacementNames.put(Placement.Name, Placement.ID);
        }
        
        for(Document_Storage__c docStorageObj : listDocStorages){
        
            if(docStorageObj.Work_Assignment_Identifier__c != NULL && mapWorkAssignmentNames.containsKey(docStorageObj.Work_Assignment_Identifier__c)){
                docStorageObj.Work_Assignment__c = mapWorkAssignmentNames.get(docStorageObj.Work_Assignment_Identifier__c);
            }
            if(docStorageObj.Product_Identifier__c != NULL && mapProductNames.containsKey(docStorageObj.Product_Identifier__c)){
               docStorageObj.Product__c = mapProductNames.get(docStorageObj.Product_Identifier__c);
            }
            if(docStorageObj.Customer_Identifier__c != NULL && mapCustomerNames.containsKey(docStorageObj.Customer_Identifier__c)){
               docStorageObj.Customer__c = mapCustomerNames.get(docStorageObj.Customer_Identifier__c);
            }
            if(docStorageObj.Settlement_Identifier__c != NULL && mapSettlementNames.containsKey(docStorageObj.Settlement_Identifier__c)){
            	docStorageObj.Settlement__c = mapSettlementNames.get(docStorageObj.Settlement_Identifier__c);
            }
            if(docStorageObj.Judgment_Identifier__c != NULL && mapJudgmentNames.ContainsKey(docStorageObj.Judgment_Identifier__c)){
                docStorageObj.Judgment__c = mapJudgmentNames.get(docStorageObj.Judgment_Identifier__c);
            }
            if(docStorageObj.Placement_Identifier__c != NULL && mapPlacementNames.ContainsKey(docStorageObj.Placement_Identifier__c)){
            	docStorageObj.Placement_Agency__c = mapPlacementNames.get(docStorageObj.Placement_Identifier__c);
            }

        }
    }

}