/**************************************************************************************************
*
* Class: CFG_ProcessSuccessRecords
*
* @description : This class can be used to update the selected product records of Allocation/Account status Update.
* and failure files for product allocation
* @author : A5E Consulting
* @date : 15/01/2023

*************************************************************************************************/
public class CFG_ProcessSuccessRecords implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public final String workAssignmentId;
    public final String documentStorageId;
    public final string docType;
    public String success;
    public String failed;
    public List<Id> prodIds = new List<Id>();
    public List<Judgment__c> judgementData = new List<Judgment__c>();
    public List<Product__c> listProductToUpdateBatch { get; set; }
    public CFG_ProcessSuccessRecords(String workAssignmentId, String documentStorageId, String docType) {
        this.workAssignmentId = workAssignmentId;
        this.documentStorageId = documentStorageId;
        this.docType = docType;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (docType == DisplayCustomerContInfoStagingController.CUSTOMER_CONTACT_INFO_UPDATE) {
            return Database.getQueryLocator(
                [
                    SELECT
                        ID,
                        Name,
                        Address_Line1__c,
                        Address_Line2__c,
                        Cell_Phone__c,
                        City__c,
                        Country__c,
                        Email_Address__c,
                        Home_Phone__c,
                        Postal_Code__c,
                        State__c,
                        Work_Phone__c,
                        Coborrower_Address1__c,
                        Coborrower_Address2__c,
                        Coborrower_Cell_Phone__c,
                        Coborrower_City__c,
                        Coborrower_Country__c,
                        Coborrower_Email__c,
                        Coborrower_Home_Phone__c,
                        Coborrower_Postal_Code__c,
                        Coborrower_State__c,
                        Coborrower_Work_Phone__c,
                        Comment__c,
                        Placement_Agency__c,
                        ProdID__c,
                        Status__c,
                        Document_Storage__c,
                        Document_Storage__r.File_Processing_Status__c,
                        Document_Storage__r.Work_Assignment__c,
                        Product_ID__c,
                        Expected_Value__c,
                        Include_in_Processing__c
                    FROM Customer_Staging__c
                    WHERE Identifier__c = :documentStorageId AND Status__c != 'Processed'
                    ORDER BY Include_in_Processing__c
                ]
            );
        } else {
            return Database.getQueryLocator(
                [
                    SELECT
                        Status_Changed_Date_Text__c,
                        Placement_Status_Code__c,
                        ID,
                        Name__c,
                        Comment__c,
                        Placement_Agency__c,
                        Status__c,
                        Expected_Value__c,
                        Document_Storage__c,
                        Current_Principal_Balance__c,
                        Current_Interest_Balance__c,
                        Fees__c,
                        Document_Storage__r.File_Processing_Status__c,
                        Product_ID__c,
                        Identifier__c,
                        Placement_Agency_ID__c,
                        Document_Storage__r.Work_Assignment_Identifier__c,
                        Pool_Name__c,
                        Document_Storage__r.Work_Assignment__c,
                        Record_Type_ID__c,
                        Placed_Commission_Rate__c,
                        Current_Commission_Rate__c,
                        Pool_Name_ID__c,
                        Include_in_Processing__c,
                        Placement_Sub_Status__c,
                        Value_Tier_at_Time_of_Placement__c,
                        Current_Settlement_Rate__c,
                        Placed_Settlement_Rate__c,
                        Data_Id__c,
                        Status_Changed_Date__c,
                        Placement_Main_Status__c,
                        Putback_Buyback_Amount__c,
                        Purchase_Status__c,
                        Rejection_Reason__c,
                        Product_Status__c
                    FROM Product_Staging__c
                    WHERE Identifier__c = :documentStorageId AND Status__c != 'Processed' AND Include_in_Processing__c = TRUE
                ]
            );
        }
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (docType == 'Product Allocation File') {
            //Call product allocation update class. developer - satyajit patil
            judgementData = AllocationProductProcessing.allocateProducts(scope, workAssignmentId);
        } else if (docType == 'Account Status Update File') {
            //Call product recall update class. developer - satyajit patil
            RecallProductProcessing.ProdIdsJudgListWrapper wrapperDetails = RecallProductProcessing.recallProducts(scope, workAssignmentId);
            prodIds = wrapperDetails.productIds;
            judgementData = wrapperDetails.judgmentList;
        } else if (docType == DisplayCustomerContInfoStagingController.CUSTOMER_CONTACT_INFO_UPDATE) {
            List<Id> scopedProdIds = new List<Id>();
            scopedProdIds = DisplayCustomerContInfoStagingController.processRecords(scope);
            if (prodIds.isEmpty()) {
                prodIds = scopedProdIds;
            } else {
                prodIds.addAll(scopedProdIds);
            }
        } else if (docType == DocumentStorageTriggerHandler.PRODUCT_BUYBACK_PUTBACK_UPDATE_FILE) {
            prodIds.addAll(DisplayBuybackPutbackStagingController.processRecords(scope));
        } else if (docType == DocumentStorageTriggerHandler.PRODUCT_STATUS_UPDATE_FILE) {
            prodIds.addAll(DisplayProductStatusStagingController.processRecords(scope));
        }
        if (Test.isRunningTest()) {
            RecallProductProcessing.ProdIdsJudgListWrapper wrapperDetails = RecallProductProcessing.recallProducts(scope, workAssignmentId);
        }
    }

    public void finish(Database.BatchableContext bc) {
        //Deactivate active placement when product is recalled from agency.
        if (prodIds != null && !prodIds.isEmpty() && docType == 'Account Status Update File') {
            DistressedUtilities.UpdateSettlement(prodIds);
        }
        //Call the portal API Batch. Developer: satyajit patil
        if (docType == DocumentStorageTriggerHandler.PRODUCT_ALLOCATION_FILE || docType == DocumentStorageTriggerHandler.ACCOUNT_STATUS_UPDATE_FILE) {
            Database.executeBatch(new CFG_ProductBulkApiProcess(documentStorageId, docType, judgementData), 200);
        } else if (docType == DisplayCustomerContInfoStagingController.CUSTOMER_CONTACT_INFO_UPDATE) {
            Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
            // Create Success and Error file
            generateCustomerStagingSuccessErrorFile();
            // Call Portal API to update product records on Portal
            PortalProductProcessingAPI.processProductBulkBatch(prodIds, new List<Product__c>());
        } else {
            DisplayBuybackPutbackStagingController.generateSuccessErrorFiles(documentStorageId, workAssignmentId, docType);
            // Call Portal API to update product records on Portal
            PortalProductProcessingAPI.processProductBulkBatch(prodIds, new List<Product__c>());
        }
    }

    public void generateCustomerStagingSuccessErrorFile() {
        List<Customer_Staging__c> listCustomerStaging = [
            SELECT
                ID,
                Name,
                Address_Line1__c,
                Address_Line2__c,
                Cell_Phone__c,
                City__c,
                Country__c,
                Email_Address__c,
                Home_Phone__c,
                Postal_Code__c,
                State__c,
                Work_Phone__c,
                Coborrower_Address1__c,
                Coborrower_Address2__c,
                Coborrower_Cell_Phone__c,
                Coborrower_City__c,
                Coborrower_Country__c,
                Coborrower_Email__c,
                Coborrower_Home_Phone__c,
                Coborrower_Postal_Code__c,
                Coborrower_State__c,
                Coborrower_Work_Phone__c,
                Comment__c,
                Placement_Agency__c,
                ProdID__c,
                Status__c,
                Document_Storage__c,
                Document_Storage__r.File_Processing_Status__c,
                Document_Storage__r.Work_Assignment__c,
                Product_ID__c,
                Expected_Value__c,
                Include_in_Processing__c
            FROM Customer_Staging__c
            WHERE Identifier__c = :documentStorageId AND Status__c != 'Processed'
            ORDER BY Include_in_Processing__c
        ];
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        // Create Success and Error file
        if (!listCustomerStaging.isEmpty()) {
            DisplayCustomerContInfoStagingController.GenerateSuccessAndErrorFile(
                listCustomerStaging,
                listCustomerStaging[0].Document_Storage__r.Work_Assignment__c,
                portalSettings.Document_Storage_Default_Visibility__c,
                listCustomerStaging[0].Document_Storage__c
            );
        }
    }

    public static void processWorkAssignment(ID workAssignmentId, String triggereve, Boolean commentStatus) {
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        list<Work_Assignment__c> listWorkAssignment = [
            SELECT
                ID,
                Name,
                Title__c,
                Task_Number__c,
                Sub_Purpose__c,
                Status__c,
                Source__c,
                Requested_Date__c,
                Purpose__c,
                Priority__c,
                Due_Date__c,
                Description__c,
                Created_By__c,
                Customer_Identifier__c,
                Judgment_Identifier__c,
                Settlement_identifier__c,
                Placement_Agency_Identifier__c,
                Assign_To__c,
                Product_Identifier__c,
                Last_Modified_By__c,
                Assign_To_Agency_User__c,
                Assigned_To_User_Name__c,
                Application__c,
                Statements__c,
                Cardholder_Agreement__c,
                Check_Copy__c,
                PPSA_Registration__c,
                Drivers_License__c,
                Repossession_And_Auction_Documents__c,
                Note_Lines__c,
                Other__c,
                Other_Media_Request__c,
                Last_Payment_Statement__c,
                Charge_Off_Statement__c,
                Latest_Comment__c,
                Start_Month__c,
                Assigned_To_Agency_User_Email__c,
                Start_Year__c,
                End_Month__c,
                End_Year__c,
                Application_Status__c,
                Statements_Status__c,
                Cardholder_Agreement_Status__c,
                Check_Copy_Status__c,
                PPSA_Registration_Status__c,
                Drivers_License_Status__c,
                Repossession_And_Auction_DocumentsStatus__c,
                Note_Lines_Status__c,
                Other_Media_Request_Status__c
            FROM Work_Assignment__c
            WHERE ID = :workAssignmentId
        ];

        String workAssignmentJSONRequest;
        Work_Assignment__c workAssignmentInstance;
        if (!listWorkAssignment.isEmpty()) {
            //Create JSON request for customer update
            workAssignmentInstance = listWorkAssignment[0];
            String Descrip = '';
            String commentReply = '';
            if (String.isNotBlank(workAssignmentInstance.Description__c)) {
                Descrip = String.valueOf(workAssignmentInstance.Description__c).replace('\n', '').replace('\r', '');
            }
            if (String.isNotBlank(workAssignmentInstance.Latest_Comment__c)) {
                commentReply = String.valueOf(workAssignmentInstance.Latest_Comment__c).replace('\n', '').replace('\r', '');
            }
            //system.debug('Descrip::'+Descrip);
            workAssignmentJSONRequest = '{';
            workAssignmentJSONRequest +=
                '"Name": "' +
                workAssignmentInstance.Name +
                '",' +
                //'"Title": "'+workAssignmentInstance.Title__c+'",'+
                '"Title": "' +
                (String.isNotBlank(workAssignmentInstance.Title__c) ? workAssignmentInstance.Title__c : '') +
                '",' +
                '"Task_Number": "' +
                workAssignmentInstance.Task_Number__c +
                '",' +
                '"Description": "' +
                Descrip +
                '",' +
                '"Purpose": "' +
                workAssignmentInstance.Purpose__c +
                '",' +
                '"Sub_Purpose": "' +
                workAssignmentInstance.Sub_Purpose__c +
                '",' +
                //'"Priority": "'+workAssignmentInstance.Priority__c+'",'+
                '"Priority": "' +
                (String.isNotBlank(workAssignmentInstance.Priority__c) ? workAssignmentInstance.Priority__c : '') +
                '",' +
                '"Status": "' +
                workAssignmentInstance.Status__c +
                '",' +
                '"Requested_Date": "' +
                workAssignmentInstance.Requested_Date__c +
                '",' +
                '"Due_Date": "' +
                workAssignmentInstance.Due_Date__c +
                '",' +
                //'"Customer_Identifier": "'+workAssignmentInstance.Customer_Identifier__c+'",'+
                '"Judgment_Identifier": "' +
                workAssignmentInstance.Judgment_Identifier__c +
                '",' +
                '"Product_Identifier": "' +
                workAssignmentInstance.Product_Identifier__c +
                '",' +
                '"Settlement_Identifier": "' +
                workAssignmentInstance.Settlement_Identifier__c +
                '",' +
                '"Placement_Agency_Identifier": "' +
                workAssignmentInstance.Placement_Agency_Identifier__c +
                '",' +
                '"Source": "' +
                workAssignmentInstance.Source__c +
                '",' +
                '"Assign_To": "' +
                workAssignmentInstance.Assign_To__c +
                '",' +
                '"Last_Modified_By": "' +
                workAssignmentInstance.Last_Modified_By__c +
                '",' +
                '"Assign_To_Agency_User": "' +
                workAssignmentInstance.Assigned_To_Agency_User_Email__c +
                '",' +
                '"Assigned_To_User_Name": "' +
                workAssignmentInstance.Assigned_To_User_Name__c +
                '",' +
                //'"Statement_Start_Date": "'+workAssignmentInstance.Statement_Start_Date__c+'",'+
                //'"Statement_End_Date": "'+workAssignmentInstance.Statement_End_Date__c+'",'+
                //Addtional fields for Media request sub-purpose
                '"Start_Month": "' +
                workAssignmentInstance.Start_Month__c +
                '",' +
                '"Start_Year": "' +
                workAssignmentInstance.Start_Year__c +
                '",' +
                '"End_Month": "' +
                workAssignmentInstance.End_Month__c +
                '",' +
                '"End_Year": "' +
                workAssignmentInstance.End_Year__c +
                '",' +
                //Addtional fields for Media request sub-purpose
                '"Application": "' +
                workAssignmentInstance.Application__c +
                '",' +
                '"Statements": "' +
                workAssignmentInstance.Statements__c +
                '",' +
                '"Cardholder_Agreement": "' +
                workAssignmentInstance.Cardholder_Agreement__c +
                '",' +
                '"Check_Copy": "' +
                workAssignmentInstance.Check_Copy__c +
                '",' +
                '"PPSA_Registration": "' +
                workAssignmentInstance.PPSA_Registration__c +
                '",' +
                '"Drivers_License": "' +
                workAssignmentInstance.Drivers_License__c +
                '",' +
                '"Repossession_And_Auction_Documents": "' +
                workAssignmentInstance.Repossession_And_Auction_Documents__c +
                '",' +
                '"Note_Lines": "' +
                workAssignmentInstance.Note_Lines__c +
                '",' +
                '"Other": "' +
                workAssignmentInstance.Other__c +
                '",' +
                '"Other_Media_Request": "' +
                workAssignmentInstance.Other_Media_Request__c +
                '",' +
                // Fields of media request status

                //'"Application_Status": "'+workAssignmentInstance.Application_Status__c+'",'+
                '"Statements_Status": "' +
                workAssignmentInstance.Statements_Status__c +
                '",' +
                '"Cardholder_Agreement_Status": "' +
                workAssignmentInstance.Cardholder_Agreement_Status__c +
                '",' +
                '"Check_Copy_Status": "' +
                workAssignmentInstance.Check_Copy_Status__c +
                '",' +
                '"PPSA_Registration_Status": "' +
                workAssignmentInstance.PPSA_Registration_Status__c +
                '",' +
                '"Drivers_License_Status": "' +
                workAssignmentInstance.Drivers_License_Status__c +
                '",' +
                '"Repossession_And_Auction_DocumentsStatus": "' +
                workAssignmentInstance.Repossession_And_Auction_DocumentsStatus__c +
                '",' +
                '"Note_Lines_Status": "' +
                workAssignmentInstance.Note_Lines_Status__c +
                '",' +
                '"Other_Media_Request_Status": "' +
                workAssignmentInstance.Other_Media_Request_Status__c +
                '",' +
                '"Last_Payment_Statement": "' +
                workAssignmentInstance.Last_Payment_Statement__c +
                '",' +
                '"Charge_Off_Statement": "' +
                workAssignmentInstance.Charge_Off_Statement__c +
                '",';

            //'"Comment_Reply": "'+commentReply+'",';
            //workAssignmentJSONRequest = workAssignmentJSONRequest.replaceAll('null', '');
            if (commentStatus == true) {
                workAssignmentJSONRequest = workAssignmentJSONRequest + '"Comment_Reply":"' + commentReply + '",';
            }
            if (workAssignmentInstance.Customer_Identifier__c != null) {
                workAssignmentJSONRequest = workAssignmentJSONRequest + '"Customer_Identifier":"' + workAssignmentInstance.Customer_Identifier__c + '",';
            } else {
                workAssignmentJSONRequest = workAssignmentJSONRequest + '"Customer_Identifier": null,';
            }

            if (workAssignmentInstance.Application_Status__c != null) {
                workAssignmentJSONRequest = workAssignmentJSONRequest + '"Application_Status":"' + workAssignmentInstance.Application_Status__c + '"';
            } else {
                workAssignmentJSONRequest = workAssignmentJSONRequest + '"Application_Status": ""';
            }
        }

        workAssignmentJSONRequest += '}';

        system.debug('workAssignmentJSONRequest::' + workAssignmentJSONRequest);
        //Get access token for http request
        String accToken;
        accToken = PortalWorkAssignmentProcessingAPI.getRequestToken();
        if (accToken != '') {
            // Instantiate a new http object
            Http h = new Http();
            // Instantiate a new HTTP request
            HttpRequest req = new HttpRequest();
            req.setBody(workAssignmentJSONRequest);
            system.debug('req body' + req.getBody());
            req.setHeader('Authorization', 'Bearer ' + accToken);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'Task');
            req.setEndpoint(apiCallDetails.PDF_API_URL__c + workAssignmentInstance.Task_Number__c);
            req.setMethod('PUT');
            //req.setEndpoint('https://paschidev-cnccd-cstprt-d.azurewebsites.net/api/'+'Customers/'+workAssignmentInstance.SF_ID__c);
            system.debug('req endpoint:: ' + req.getEndpoint());
            system.debug('req body:: ' + req.getBody());
            workAssignmentInstance.Outbound_API_Request_Body__c = req.getBody();
            system.debug('Outbound req body:: ' + req.getBody());
            system.debug('req:: ' + req);

            try {
                // Send the request, and return a response
                HttpResponse res = h.send(req);
                system.debug('res.getBody(): ' + res.getBody());
                Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                workAssignmentInstance.Outbound_API_Response_Body__c = res.getBody();
                system.debug('Outbound res.getBody() :: ' + res.getBody());
                if (res.getStatusCode() == 200 && bodyMap.get('IsSuccess') == String.valueOf('true')) {
                    system.debug(bodyMap.get('ReturnMessage'));
                } else {
                    system.debug('Error Response');
                    system.debug(bodyMap.get('ReturnMessage'));
                }
            } catch (Exception ex) {
                system.debug('exception ex: ' + ex);
            }

            if (workAssignmentInstance != null) {
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
                update workAssignmentInstance;
                WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            }
        }
    }
}
