/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for Document Storage object. The code is not bulkified. 
*  @author : A5E Consulting
*  @date : 18/01/2022
*************************************************************************************************/
public class DocumentStorageTriggerHandler {
    
    public static boolean runDocumentStorageTrigger = true;
    
    public static boolean runDocumentStorageAPI = true;
    
    public static String CUSTOMER_CONTACT_INFO_UPDATE = 'Customer Contact Information Update File';
    public static String PRODUCT_PAYMENT_UPLOAD_FILE = 'Product Payment Upload File';
    public static String ACCOUNT_STATUS_UPDATE_FILE = 'Account Status Update File';
    public static String ACCOUNT_STATUS_HAVING_JUDGMENT_FILE = 'Account Status (having Judgment) Update File';
    public static String PRODUCT_ALLOCATION_FILE = 'Product Allocation File';
    public static String PRODUCT_RECALL_FILE = 'Product Recall File';
    public static String PRODUCT_BULK_POOL_UPDATE_FILE = 'Product Bulk Pool Update File';
    public static String DIRECT_PAYMENT_UPLOAD_FILE = 'Direct Payment Upload File';
    public static String PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE = 'Product Buyback/Putback Update File';
    public static String BALANCE_ADJUSTMENT_UPLOAD_FILE = 'Balance Adjustment Upload File';
    public static String DISTRESSED_NOTES_BULK_UPLOAD_FILE  = 'Distressed Notes Bulk Upload File';
    
    //this inner method populate the comment, comment history and user name.
    public static void handleBeforeInsert(List<Document_Storage__c> docStorage) {
        system.debug('inside before insert trigger');
        list<Document_Storage__c> listInternalNewDocumentStorage = new list<Document_Storage__c>();
        list<Document_Storage__c> listExternalNewDocumentStorage = new list<Document_Storage__c>();
        system.debug('docStorage '+docStorage);
        DateTime dT = System.now();
        
        
        for(Document_Storage__c docStor : docStorage){
           
            
            docStor.Created_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.Name; 
           
            if(docStor.Work_Assignment__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
             if(docStor.Product__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
            if(docStor.Customer__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
            if(docStor.Settlement__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
            if(docStor.Judgment__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
            if(docStor.Placement_Agency__c <> NULL ){
                listInternalNewDocumentStorage.add(docStor);
            }
            
            
        }
        
        //method calls once record created in CFG
        getDocumentStorageRelatedData(listInternalNewDocumentStorage);
    }
    
    //Method to handle after insert of record
    public static void handleAfterInsert(list<Document_Storage__c> listNewDocumentStorages){
        system.debug('after insert');
        for(Document_Storage__c documentStorage: listNewDocumentStorages){
            //call API
           // PortalDocumentStorageProcessingAPI.processDocumentStorage(documentStorage.ID); 
           if(documentStorage.Placement_Identifier__c != null &&
              documentStorage.Product__c != null){
                //Ticket 7283: document uploaded from product screen then dont send notification to portal  
                //notificationCallAPI(documentStorage.Placement_Identifier__c,'Document','Document Created','A document for ' + documentStorage.Product_Identifier__c + ' has been created');  
              }
            
        }
    
    } 
    
    @future (callout=true)
    public static void notificationCallAPI(String placeId, String Type, String Title, String Message){      
            PortalNotificationAPI.sendPaymentNotification(placeId,Type,Title,'',Message);
    }
    
    //Method to handle after update of record
    public static void handleAfterUpdate(list<Document_Storage__c> listNewDocumentStorages, map<ID, Document_Storage__c> mapOldDocuments){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        List<String> noCalloutDocTypes = new List<String> {'ctb_statement_output', 'Statement Processing File', 'Statement Result File', 'Insolvency Daily Update'};
        if(config.Run_Doc_Storage_Update_API_for_Portal__c && runDocumentStorageAPI){
            Set<id> wrkAssId = new Set<id>();
            Map<id,Work_Assignment__c> mapWorkAssignment = new Map<id,Work_Assignment__c>();
            for(Document_Storage__c doc : listNewDocumentStorages){
                wrkAssId.add(doc.Work_Assignment__c);
            }
            system.debug('run api');
            List<Work_Assignment__c> wrkAss = [Select id,name,recordTypeID from Work_Assignment__c where id IN: wrkAssId];
            for(Work_Assignment__c wrkAssData : wrkAss){
                mapWorkAssignment.put(wrkAssData.id,wrkAssData);
            }
            for(Document_Storage__c documentStorage: listNewDocumentStorages){
                //call API
                if(!noCalloutDocTypes.contains(documentStorage.Document_Type__c) && documentStorage.Portfolio__c == null && (documentStorage.Document_Type__c != 'Putback Order Form'
                  && documentStorage.Document_Type__c != 'Buyback Order Form' && documentStorage.Document_Type__c != 'Putback Documentation'
                  && documentStorage.Document_Type__c != 'Buyback Documentation'))
                {
                   PortalDocumentStorageProcessingAPI.processDocumentStorage(documentStorage.ID); 
                }
                system.debug('mapWorkAssignment::'+mapWorkAssignment);
                system.debug('mapWorkAssignment.get::'+documentStorage.Work_Assignment__c);
                //system.debug('mapWorkAssignment::'+mapWorkAssignment.get(documentStorage.Work_Assignment__c).recordTypeID);
                if(mapWorkAssignment != NULL && documentStorage.Work_Assignment__c != NULL
                && (mapWorkAssignment.get(documentStorage.Work_Assignment__c).recordTypeID == config.AgencyComplaintWorkAssignmentRecordType__c || 
                   mapWorkAssignment.get(documentStorage.Work_Assignment__c).recordTypeID == config.CFGComplaintWorkAssignmentRecordID__c) && documentStorage.Visibility__c != 'CFG Only'){
                      notificationCallAPI(documentStorage.Placement_Identifier__c,'Document','Complaint No: '+mapWorkAssignment.get(documentStorage.Work_Assignment__c).Name+' Document Uploaded','Document '+documentStorage.Name+' is uploaded and ready to view. Document type is '+documentStorage.Document_Type__c);
                }
             if((documentStorage.Document_Type__c == PRODUCT_ALLOCATION_FILE || documentStorage.Document_Type__c == ACCOUNT_STATUS_UPDATE_FILE) && documentStorage.Document_Id__c != NULL && (documentStorage.File_Processing_Status__c == 'Pending'  || String.isBlank(documentStorage.File_Processing_Status__c))){
                        String workAssignmentPlacement = '';
                       if(documentStorage.Work_Assignment_Placement__c != null){
                           workAssignmentPlacement = documentStorage.Work_Assignment_Placement__c;
                       }
                        if(!Test.isRunningTest()){
                            System.enqueueJob(new BulkDataloadQueueable('PARSE_CSV', null, 0, documentStorage));
                        }
                       //processProductAllocation(documentStorage.Document_Id__c, workAssignmentPlacement, documentStorage.ID,documentStorage.Document_Type__c, documentStorage.Document_URL__c);                                    
                      //System.scheduleBatch(new CFG_ProcessBulkAPIResult('',documentStorage.ID,documentStorage.Work_Assignment__c,documentStorage.Document_Type__c,documentStorage), 'Bulk Process data', 3);
                }
                // Adesh
                /*else if(documentStorage.Document_Type__c == ACCOUNT_STATUS_UPDATE_FILE && documentStorage.Document_Id__c != NULL && (documentStorage.File_Processing_Status__c == 'Pending' 
                  || String.isBlank(documentStorage.File_Processing_Status__c)
                   )){
                        String workAssignmentPlacement = '';
                       if(documentStorage.Work_Assignment_Placement__c != null){
                           workAssignmentPlacement = documentStorage.Work_Assignment_Placement__c;
                       }
                       processProductAllocation(documentStorage.Document_Id__c, workAssignmentPlacement, documentStorage.ID,documentStorage.Document_Type__c, documentStorage.Document_URL__c);                                    
                           System.scheduleBatch(new CFG_ProcessBulkStatusUpdate('',documentStorage.ID,documentStorage.Work_Assignment__c,documentStorage), 'Bulk Process data', 1);
                }*/
                else if(documentStorage.Document_Type__c == CUSTOMER_CONTACT_INFO_UPDATE && String.isNotBlank(documentStorage.Document_Id__c) && (documentStorage.File_Processing_Status__c == 'Pending' || String.isBlank(documentStorage.File_Processing_Status__c))) {
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new CustomerStagingExcelFileProcessing(documentStorage.Document_URL__c, documentStorage.Work_Assignment_Placement__c, documentStorage.Id));
                    }
                }

                else if((documentStorage.Document_Type__c == PRODUCT_PAYMENT_UPLOAD_FILE
                //   || documentStorage.Document_Type__c == ACCOUNT_STATUS_UPDATE_FILE
                  || documentStorage.Document_Type__c == ACCOUNT_STATUS_HAVING_JUDGMENT_FILE
                //   || documentStorage.Document_Type__c == CUSTOMER_CONTACT_INFO_UPDATE
                //|| documentStorage.Document_Type__c == PRODUCT_ALLOCATION_FILE
                  || documentStorage.Document_Type__c == PRODUCT_RECALL_FILE
                  || documentStorage.Document_Type__c == PRODUCT_BULK_POOL_UPDATE_FILE
                  || documentStorage.Document_Type__c == DIRECT_PAYMENT_UPLOAD_FILE
                  || documentStorage.Document_Type__c == PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE
                  || documentStorage.Document_Type__c == BALANCE_ADJUSTMENT_UPLOAD_FILE
                  || documentStorage.Document_Type__c == DISTRESSED_NOTES_BULK_UPLOAD_FILE)
                && documentStorage.Document_Id__c != NULL
                && (documentStorage.File_Processing_Status__c == 'Pending' 
                  || String.isBlank(documentStorage.File_Processing_Status__c)
                    //&& mapOldDocuments.get(documentStorage.ID).File_Processing_Status__c != documentStorage.File_Processing_Status__c)
                   )){
                        String workAssignmentPlacement = '';
                       if(documentStorage.Work_Assignment_Placement__c != null){
                           workAssignmentPlacement = documentStorage.Work_Assignment_Placement__c;
                       }
                    exceltoJSONService(documentStorage.Document_Id__c, workAssignmentPlacement, documentStorage.ID,
                                      documentStorage.Document_Type__c, documentStorage.Document_URL__c);
                }
            }
        }
    }

    @future (callout=true)
    public static void processProductAllocation(String documentID, String placement, ID documentStorageID, String documentType, String documentURL){
        String docDetails;        
        system.debug('documentID in processProductAllocation: '+documentID);
        system.debug('documentType in processProductAllocation: '+documentType);
           System.debug('Before Update Call CSV');
            //UpdateCSVforAllocation.updateCSV(documentID);
                ContentDocumentLink con = [Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink where LinkedEntityId =: documentStorageID Limit 1]; 
                //system.debug('check' +con);
                Blob b = UpdateCSVforAllocation.updateCSV(con.ContentDocumentId, documentStorageID);  
                //if(!Test.isRunningTest()){
                    BulkAPIUtility.loadDatausingBulkAPI(b,con.ContentDocumentId, 'Product_Staging__c');
                //}
    }
    
    @future (callout=true)
    public static void exceltoJSONService(String documentID, String placement, ID documentStorageID, String documentType, String documentURL){
        String docDetails;
        
        system.debug('documentID in exceltoJSONService: '+documentID);
        system.debug('documentType in exceltoJSONService: '+documentType);
        docDetails = DocumentAPIClient.getDocumentJSON(documentURL);
        system.debug('placement in exceltoJSONService: '+placement);

        if(documentType == PRODUCT_PAYMENT_UPLOAD_FILE  || documentType == DIRECT_PAYMENT_UPLOAD_FILE){
            system.debug('product batch called');
            ProductPaymentExcelFileProcessing instance = new ProductPaymentExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if(documentType == ACCOUNT_STATUS_UPDATE_FILE){
            //AccountStatusUpdateExcelFileProcessing instance = new AccountStatusUpdateExcelFileProcessing(docDetails, placement, documentStorageID);
        

        }
        if(documentType == ACCOUNT_STATUS_HAVING_JUDGMENT_FILE){
            JudgmentStatusExcelFileProcessing instance = new JudgmentStatusExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if(documentType == CUSTOMER_CONTACT_INFO_UPDATE){
            CustomerStagingExcelFileProcessing instance = new CustomerStagingExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if (documentType == PRODUCT_ALLOCATION_FILE){
            ProductAllocationExcelFileProcessing instance = new ProductAllocationExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if(documentType == PRODUCT_RECALL_FILE){
            ProductRecallExcelFileProcessing instance = new ProductRecallExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if (documentType == PRODUCT_BULK_POOL_UPDATE_FILE){
            ProductBulkPoolExcelFileProcessing instance = new ProductBulkPoolExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if (documentType == PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE){
            ProductBuybackPutbackExcelFileProcessing instance = new ProductBuybackPutbackExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if (documentType == BALANCE_ADJUSTMENT_UPLOAD_FILE){
            BalanceAdjustmentExcelFileProcessing instance = new BalanceAdjustmentExcelFileProcessing(docDetails, placement, documentStorageID);
        }
        if(documentType == DISTRESSED_NOTES_BULK_UPLOAD_FILE){
            DistressNotesExcelFileProcessing instance = new DistressNotesExcelFileProcessing(docDetails, documentStorageID);
        }
        
    }
    
    //this inner method to handle before update functionality
    public static void handleBeforeUpdate(List<Document_Storage__c> docStorage, Map<Id, Document_Storage__c> oldMap) { 
        
        list<Document_Storage__c> listInternalNewDocumentStorage = new list<Document_Storage__c>();
        list<Document_Storage__c> listExternalNewDocumentStorage = new list<Document_Storage__c>();
       
        DateTime dT = System.now();
        
        for(Document_Storage__c docStor : docStorage){
            
            Boolean identifierRemovalFlag = false;
            
            Document_Storage__c docStorageOld= oldMap.get(docStor.id);
            
            docStor.Last_Modified_By__c =  UserInfo.getName();
            //docStor.Record_Type_Identifier__c = docStor.RecordType.name;
            
            if(docStor.Work_Assignment__c != NULL){
                if(docStor.Work_Assignment__c != docStorageOld.Work_Assignment__c){
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Work_Assignment_Identifier__c  = NULL;
            }

            if(docStor.Product__c  != NULL){
                if(docStor.Product__c  != docStorageOld.Product__c ){
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Product_Identifier__c  = NULL;
            }

            if(docStor.Customer__c != NULL){
                if(docStor.Customer__c  != docStorageOld.Customer__c ){
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Customer_Identifier__c  = NULL;
            }
            if(docStor.Settlement__c != NULL){
                if(docStor.Settlement__c  != docStorageOld.Settlement__c){
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Settlement_Identifier__c  = NULL;
            }
            if(docStor.Judgment__c != NULL){
                if(docStor.Judgment__c != docStorageOld.Judgment__c ){
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Judgment_Identifier__c = NULL;
            }
          //  system.debug('docStor.Placement_Agency__c '+docStor.Placement_Agency__c);
            if(docStor.Placement_Agency__c != NULL){
                if(docStor.Placement_Agency__c != docStorageOld.Placement_Agency__c ){
                 //  system.debug('AA');
                     listInternalNewDocumentStorage.add(docStor);
                }
            }
            else{
                docStor.Placement_Identifier__c = NULL;
            }
        }
        
        //method calls once record created/update in CFG
        getDocumentStorageRelatedData(listInternalNewDocumentStorage);
    }
    
    
    //using this inner method populate the identifier fields using CFG data.
    public static void getDocumentStorageRelatedData(list<Document_Storage__c> listDocStorages){
     
     
        set<Id> setWorkAssignmentID = new set<Id>();
        set<Id> setProductID = new set<Id>();
        set<Id> setCustomerID = new set<Id>();
        set<Id> setSettlementID = new set<Id>();
        set<Id> setJudgmentID = new set<Id>();
        set<Id> setPlacementID = new set<Id>();

        map<Id, String> mapWorkAssignmentNames = new map<Id, String>();
        map<Id, String> mapProductNames = new map<Id, String>();
        map<Id, String> mapCustomerNames = new map<Id, String>();
        map<Id, String> mapSettlementNames = new map<Id, String>();
        map<Id, String> mapJudgmentNames = new map<Id, String>();
        map<Id, String> mapPlacementNames = new map<Id, String>();

     
        for(Document_Storage__c docStorageObj : listDocStorages){
     
            setWorkAssignmentID.add(docStorageObj.Work_Assignment__c);
            setProductID.add(docStorageObj.Product__c);
            setCustomerID.add(docStorageObj.Customer__c);
            setSettlementID.add(docStorageObj.Settlement__c);
            setJudgmentID.add(docStorageObj.Judgment__c);
            setPlacementID.add(docStorageObj.Placement_Agency__c);
            
        }
        
        for(Work_Assignment__c workAssign : [SELECT ID, Task_Number__c
                                     FROM Work_Assignment__c
                                     WHERE ID IN : setWorkAssignmentID]){
            mapWorkAssignmentNames.put(workAssign.Id, workAssign.Task_Number__c);
            
        }
        
        for(Product__c product : [SELECT ID, Name
                                     FROM Product__c
                                     WHERE ID IN :setProductID]){
            mapProductNames.put(product.ID, product.Name);
            
        }
        for(Account Customer : [SELECT ID, Name, SF_ID__c
                                     FROM Account
                                     WHERE ID IN :setCustomerID]){
            mapCustomerNames.put(Customer.ID, Customer.SF_ID__c);
            
        }
        for(Settlement__c Settlement : [SELECT ID, Settlement_Number__c
                                     FROM Settlement__c
                                     WHERE ID IN :setSettlementID]){
            mapSettlementNames.put(Settlement.ID, Settlement.Settlement_Number__c);
            
        }
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c
                                     FROM Judgment__c
                                     WHERE ID IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
            
        }
        for(Placement__c Placement : [SELECT ID, Name
                                     FROM Placement__c
                                     WHERE ID IN :setPlacementID]){
            mapPlacementNames.put(Placement.ID, Placement.Name);
            
        }
        
        for(Document_Storage__c docStorageObj : listDocStorages){
            docStorageObj.Work_Assignment_Identifier__c = mapWorkAssignmentNames.get(docStorageObj.Work_Assignment__c);
            docStorageObj.Product_Identifier__c = mapProductNames.get(docStorageObj.Product__c);
            docStorageObj.Customer_Identifier__c = mapCustomerNames.get(docStorageObj.Customer__c);
            docStorageObj.Settlement_Identifier__c = mapSettlementNames.get(docStorageObj.Settlement__c);
            docStorageObj.Judgment_Identifier__c = mapJudgmentNames.get(docStorageObj.Judgment__c);
            docStorageObj.Placement_Identifier__c = mapPlacementNames.get(docStorageObj.Placement_Agency__c);

        }

    }
    
    
 
}