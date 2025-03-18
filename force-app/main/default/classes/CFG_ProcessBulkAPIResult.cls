/**************************************************************************************************
 *
 *  Class:  CFG_ProcessBulkAPIResult
 *
 *  @description : This class is used for create the allocation and recall procesing link and check the validations and update staging records.
 *  @author : A5E Consulting
 *  @date : 29/12/2022
 *
 *************************************************************************************************/
public class CFG_ProcessBulkAPIResult implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public final String jobId;
    public final String documentStorageId;
    public String docType;
    //public static String documentType;
    public String workAssignmentPlacement;
    public Document_Storage__c docStorage;
    public static String allocate = 'Product Allocation File';
    public static String recall = 'Account Status Update File';

    public CFG_ProcessBulkAPIResult(String jobId, String documentStorageId, String workAssignmentPlacement, string docType, Document_Storage__c docStorage) {
        this.jobId = jobId;
        this.documentStorageId = documentStorageId;
        this.workAssignmentPlacement = workAssignmentPlacement;
        this.docStorage = docStorage;
        this.docType = docType;
        // this.documentType = docType;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Name,
                    Is_Record_Process__c,
                    Status__c,
                    Product_ID__c,
                    pool_Name__c,
                    pool_name_id__c,
                    Placed_Commission_Rate__c,
                    Current_Commission_Rate__c,
                    Status_Changed_Date_Text__c,
                    Status_Changed_Date__c,
                    Placed_Settlement_Rate__c,
                    Placement_Main_Status__c,
                    Data_Id__c,
                    place_Id__c,
                    External_Id__c,
                    Name__c,
                    Placement_Agency__c,
                    Value_Tier_at_Time_of_Placement__c,
                    Current_Settlement_Rate__c,
                    Placement_Status_Code__c,
                    Assignment_Date__c,
                    Purchase_Status__c,
                    Product_Status__c,
                    Rejection_Reason__c
                FROM Product_Staging__c
                WHERE Is_Record_Process__c = FALSE AND Identifier__c = :documentStorageId AND CREATEDDATE = Today
            ]
        );
    }

    public void execute(Database.BatchableContext BC, List<Product_Staging__c> scope) {
        try {
            Set<String> productList = new Set<String>();
            Set<String> poolNameList = new Set<String>();
            List<String> dataIdDoctypeList = new List<String>{
                allocate,
                DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE,
                DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE
            };
            if (dataIdDoctypeList.contains(docType)) {
                for (Product_Staging__c prod : scope) {
                    if (prod.Data_Id__c != null) {
                        productList.add(prod.Data_Id__c);
                    }
                    poolNameList.add(prod.Pool_Name__c);
                }
            } else {
                for (Product_Staging__c prod : scope) {
                    if (prod.Name__c != null) {
                        productList.add(prod.Name__c);
                    }
                    poolNameList.add(prod.Pool_Name__c);
                }
            }
            prepareFileProcessingLink(scope, documentStorageId, productList, poolNameList, docType, workAssignmentPlacement, docStorage);
            updateRecordProcessCheck(scope);
        } catch (Exception ex) {
            list<Product_Staging__c> listProductAllocateStaging = new List<Product_Staging__c>();
            for (Product_Staging__c ps : scope) {
                ps.Identifier__c = documentStorageId;
                if (ps.Data_Id__c != null) {
                    ps.External_Id__c = ps.Data_Id__c + '_' + documentStorageId;
                }
                if (ex.getMessage().length() > 247) {
                    ps.Comment__c = '<ERROR>' + ex.getMessage().subString(0, 247);
                } else {
                    ps.Comment__c = '<ERROR>' + ex.getMessage();
                }

                listProductAllocateStaging.add(ps);
            }
            update listProductAllocateStaging;
        }
    }

    public void finish(Database.BatchableContext BC) {
        updateFileProcessingLink(documentStorageId, docType);
    }

    public static void prepareFileProcessingLink(
        List<Product_Staging__c> batchScope,
        String documentStorageId,
        Set<String> productNameList,
        Set<String> poolNumberList,
        String documentType,
        String workAssignment,
        document_storage__c docStorage
    ) {
        list<Product_Staging__c> listProductAllocateStaging = new List<Product_Staging__c>();
        for (Product_Staging__c ps : batchScope) {
            //ps.Identifier__c = documentStorageId;
            if (ps.Data_Id__c != null) {
                ps.External_Id__c = ps.Data_Id__c + '_' + documentStorageId;
            }
            listProductAllocateStaging.add(ps);
        }
        update listProductAllocateStaging;

        Map<String, Product__c> mapProductName = new Map<String, Product__c>();
        set<ID> setProdutID = new Set<ID>();
        set<String> setPlacementNames = new Set<String>();
        Map<String, Pool__C> mapPoolName = new Map<String, Pool__C>();
        List<String> accountNumberList = new List<String>();
        List<Product__c> prodList = [
            SELECT
                Id,
                Name,
                Collection_Agency__c,
                Collection_Sub_Status__c,
                Current_Principal_Balance__c,
                Current_Interest_Amount__c,
                Fee_Recovery__c,
                Collection_Agency_Placement__r.Serviceable_Province__c,
                Pool_Name__r.Name,
                RecordTypeId,
                Current_Bal_NSF_Fees__c,
                Commission_Adjustment__c,
                Purchase_Status__c,
                Pool_Name_Text__c,
                Commission_Rate__c,
                Commission_Rate_at_Time_of_Placement__c,
                Settlement_Rate__c,
                Placed_Settlement_Rate__c,
                Placement_Status__c,
                Status__c,
                Purchase_Province__c,
                Data_Status_Description__c,
                Value_Tier_at_Time_of_Placement__c,
                State__c,
                Assignment_Date__c,
                Recalled_Date__c,
                Product_Status__c,
                Refer_to_Legal__c
            FROM Product__c
            WHERE Name IN :productNameList
        ];
        for (Product__C accountRecord : prodList) {
            mapProductName.put(accountRecord.name, accountRecord);
        }
        list<Product_Staging__c> listProductStaging = new List<Product_Staging__c>();

        //Call validation method based on the document type. developer: satyajit patil
        if (allocate == documentType) {
            for (Pool__C pool : [SELECT ID, Name, Placement_Agency__c FROM Pool__C WHERE Name IN :(poolNumberList)]) {
                mapPoolName.put(pool.Name, pool);
            }
            listProductStaging = DistressedUtilities.allocationValidationOnRecordUpdate(batchScope, prodList, mapProductName, documentStorageID, mapPoolName);
        } else if (recall == documentType) {
            listProductStaging = DistressedUtilities.recallValidationOnRecordUpdate(
                batchScope,
                prodList,
                mapProductName,
                documentStorageID,
                workAssignment,
                docStorage
            );
        } else if (documentType == DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE) {
            listProductStaging = DistressedUtilities.validatePutbackBuybackRecords(batchScope, mapProductName, documentStorageID);
        } else if (documentType == DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE) {
            listProductStaging = DistressedUtilities.validateProductStatusUpdateRecords(batchScope, mapProductName, documentStorageID);
        }
        if (listProductStaging != null && !listProductStaging.isEmpty()) {
            Database.UpsertResult[] sr = database.upsert(listProductStaging, Product_Staging__c.Id, true);
        }
    }

    public void updateRecordProcessCheck(list<Product_Staging__c> batchScope) {
        list<Product_Staging__c> listProductAllocateStaging = new List<Product_Staging__c>();
        for (Product_Staging__c ps : batchScope) {
            ps.Is_Record_Process__c = true;
            listProductAllocateStaging.add(ps);
        }
        update listProductAllocateStaging;
    }

    public static void updateFileProcessingLink(String documentStorageId, String documentType) {
        String subject = documentType == DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE
            ? 'Product Putback/Buyback Status'
            : documentType == DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE ? 'Product Status Update' : 'Product Allocation Status';
        String vfPage = documentType == DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE
            ? 'DisplayBuybackPutbackStaging'
            : documentType == DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE ? 'DisplayProductStatusStaging' : 'DisplayProductAllocateStaging';
        list<Document_Storage__c> listDocuments = [
            SELECT ID, name, Creator__c, Work_Assignment__c, Uploaded_By__c, Work_Assignment__r.Name, Work_Assignment__r.Title__c
            FROM Document_Storage__c
            WHERE ID = :documentStorageId
        ];
        //Send email of File processing completion
        String processingLink = '';
        String processingStatus = '';
        Boolean stagingCreated;
        processingLink = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + vfPage + '?id=' + documentStorageId;
        if (documentType != DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE) {
            processingLink += '&docType=' + documentType;
        }
        processingStatus = 'Staging Table Created';
        stagingCreated = true;
        String userName = UserInfo.getUserName();
        if (listDocuments[0].Uploaded_By__c != 'External User') {
            CFG_EmailNotification.sendEmailNotification(
                userName,
                processingLink,
                listDocuments[0].Work_Assignment__r.Name,
                listDocuments[0].Work_Assignment__r.title__c,
                documentType
            );
        }
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
        Document_Storage__c doc = new Document_Storage__c(
            Id = listDocuments[0].ID,
            File_Processing_Link__c = processingLink,
            File_Processing_Date__c = Date.today(),
            File_Processing_Status__c = processingStatus,
            Staging_Records_Created__c = stagingCreated
        );
        update doc;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
    }
}
