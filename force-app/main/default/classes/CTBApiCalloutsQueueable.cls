public class CTBApiCalloutsQueueable implements Queueable, Database.AllowsCallouts {
    private Id contentVersionDataID;
    private List<sObject> listData;
    public static API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
    public string batchName = '';
    public string fileNameFormat = '';

    public CTBApiCalloutsQueueable(Id cvID, List<sObject> Data, string CTBBatchName, string fileName) {
        //ContentVersion ID
        contentVersionDataID = cvID;
        //Retrive Data
        listData = Data;
        //Batch Name
        batchName = CTBBatchName;
        //File Name
        fileNameFormat = fileName;
    }

    public CTBApiCalloutsQueueable(List<sObject> data) {
        this.listData = data;
    }

    public void execute(QueueableContext context) {
        system.debug('inside CTBApiCalloutsQueueable');
        if (!listData.isEmpty() && String.isNotBlank(batchName)) {
            //Get access token for http request
            String accToken;
            accToken = AzureUtility.getRequestToken('Agency Portal API');
            if (accToken != '') {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + accToken);
                req.setHeader('Content-Type', 'application/json');

                apiCallDetails.PDF_API_URL__c = apiCallDetails.PDF_API_URL__c.replace('Document', 'SftpProxy');
                req.setMethod('POST');
                string apiUrl = apiCallDetails.PDF_API_URL__c + 'sobjects/' + contentVersionDataID + '/outgoing_clear?name=' + fileNameFormat;
                req.setEndpoint(apiUrl);

                system.debug('Endpoint req body:: ' + req.getEndpoint());
                Map<id, sobject> mapRecordUpdate = new Map<id, sobject>();
                try {
                    // Send the request, and return a response
                    HttpResponse res = h.send(req);
                    system.debug('res.getBody(): ' + res.getBody());
                    String statusCode = String.valueOf(res.getStatusCode());
                    String statusDesc = String.valueOf(res.getStatus());
                    system.debug('statusCode: ' + statusCode);

                    Insolvency_Payment__c newinsolPayRec = new Insolvency_Payment__c();
                    //update processing sub status based on portal response
                    mapRecordUpdate = populateProcessingSubStatus(batchName, statusCode, listData, fileNameFormat, res.getBody(), statusDesc);
                } catch (Exception ex) {
                    system.debug('Exception class' + ex);
                    system.debug('exceptionline::' + ex.getStackTraceString());
                    Map<id, sobject> errorMap = new Map<id, sobject>();
                    errorMap = errorProcessingStatusUpdate(batchName, listData);
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(ex.getMessage(), ex.getStackTraceString(), null, errorMap.values(), batchName);
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), ex.getStackTraceString(), 'CTB API Failed');
                }
                try {
                    if (!mapRecordUpdate.values().isEmpty()) {
                        update mapRecordUpdate.values();
                    }
                } catch (DMLException dmlEx) {
                    Map<id, sObject> insolvAcctErrorMap = new Map<id, sObject>();
                    system.debug('Exception class' + dmlEx.getDMLMessage(0));
                    system.debug('getStackTraceString class' + dmlEx.getStackTraceString());
                    system.debug('getDmlId class' + dmlEx.getDmlId(0));

                    insolvAcctErrorMap = populateErrorMesssage(batchName, dmlEx.getDmlId(0), dmlEx.getStackTraceString());
                    //Add Insolvency Error log in backend database
                    CTBFileGenerator.exceptionHandling(dmlEx.getDMLMessage(0), dmlEx.getStackTraceString(), dmlEx.getDmlId(0), null, batchName);
                    // Notify to user via Email
                    CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), dmlEx.getStackTraceString(), 'Record update Failed');

                    try {
                        if (insolvAcctErrorMap != null && !insolvAcctErrorMap.isEmpty()) {
                            update insolvAcctErrorMap.values();
                        }
                    } catch (DMLException ex) {
                        system.debug('Exception class' + ex.getDMLMessage(0));
                        system.debug('getDmlId class' + ex.getDmlId(0));
                    }
                }
            }
        }
        // Statement file processing success and failed file upload
        if (String.isBlank(batchName)) {
            finishStatementProcessing(listData);
        }
    }

    /**
     * @description : Method to create doc storage and upload success and failed files to azure
     * @author adesh.ikhar@canaccede.com | 06-06-2024
     * @param cvList
     * @param listData
     **/
    public static void finishStatementProcessing(List<sObject> listData) {
        List<ContentDocument> contentDocToDelete = new List<ContentDocument>();
        List<String> conVerIdsToDelete = new List<String>();
        List<Document_Storage__c> docStorageToCreateList = new List<Document_Storage__c>();
        for (ContentVersion cv : (List<ContentVersion>) listData) {
            conVerIdsToDelete.add(cv.Id);
            // Upload content version csv to azure
            GetSuccessFailedFilesScheduler.uploadFile(cv.Id, cv.PathOnClient);
            // Create new doc storage for each csv
            Document_Storage__c docInfo = new Document_Storage__c(
                Document_Name__c = cv.PathOnClient,
                Document_Type__c = 'Statement Result File',
                Statement_Processing_Status__c = 'Processed',
                Document_Extension__c = 'csv',
                Uploaded_By__c = 'System',
                Creator__c = 'System',
                Visibility__c = 'CFG only',
                RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Insolvency').getRecordTypeId()
            );
            docStorageToCreateList.add(docInfo);
        }
        try {
            Database.insert(docStorageToCreateList);
            Statement_Processing_Settings__c stmtProcessingSettings = Statement_Processing_Settings__c.getInstance('Canadian Tire');
            stmtProcessingSettings.Number_of_Statements_Attempts__c = 0;
            Database.update(stmtProcessingSettings);
            for (ContentVersion conVer : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :conVerIdsToDelete]) {
                contentDocToDelete.add(new ContentDocument(Id = conVer.ContentDocumentId));
            }
            if (!contentDocToDelete.isEmpty()) {
                Database.delete(contentDocToDelete);
            }
        } catch (DmlException ex) {
            System.debug('DMLException in CTBApiCalloutsQueueable ' + ex.getDmlMessage(0));
            CTBFileProcessingQueueable.createInsolvencyError(ex.getDmlMessage(0), ex.getStackTraceString());
        }
    }

    public Map<id, sObject> populateProcessingSubStatus(
        string batchName,
        string statusCode,
        List<sObject> listData,
        string fileNameFormat,
        String response,
        string statusDesc
    ) {
        Map<id, sObject> insolAccAndPaymentMap = new Map<id, sObject>();
        String errResponse = '';
        if (batchName == System.Label.CTB_Insolvency_Account) {
            //if we get success response then update insolvency account fields
            for (insolvency_account__c insolAccData : (List<insolvency_account__c>) listData) {
                insolvency_account__c newInsolAccRec = new insolvency_account__c();
                if (statusCode.startsWith('2')) {
                    newInsolAccRec.id = insolAccData.id;
                    newInsolAccRec.Insolvency_Sub_Status__c = 'Sent on File';
                    newInsolAccRec.CTB_Update_Filename__c = fileNameFormat;
                    newInsolAccRec.CTB_Update_File_Timestamp__c = null;
                    insolAccAndPaymentMap.put(newInsolAccRec.id, newInsolAccRec);
                } else {
                    if (response.length() > 131071) {
                        errResponse = response.subString(0, 131071);
                    } else {
                        errResponse = response;
                    }
                    if (string.isBlank(errResponse)) {
                        errResponse = 'statusCode get: ' + statusCode + ' - ' + statusDesc;
                    }
                    newInsolAccRec.id = insolAccData.id;
                    newInsolAccRec.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                    newInsolAccRec.Error_Message__c = errResponse;
                    insolAccAndPaymentMap.put(newInsolAccRec.id, newInsolAccRec);

                    CTBFileGenerator.exceptionHandling(errResponse, null, null, insolAccAndPaymentMap.values(), batchName);
                }
            }
            if (!string.isBlank(errResponse)) {
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), errResponse, 'Error Response');
            }
        }

        if (batchName == System.Label.CTB_Payment) {
            //if we get success response then update insolvency account fields
            for (Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>) listData) {
                Insolvency_Payment__c newinsolPayRec = new Insolvency_Payment__c();
                if (statusCode.startsWith('2')) {
                    newinsolPayRec.id = insolPayData.id;
                    newinsolPayRec.Payment_Sub_Status__c = 'Sent on File';
                    newinsolPayRec.CTB_Update_Filename__c = fileNameFormat;
                    newinsolPayRec.CTB_Update_File_Timestamp__c = null;
                    insolAccAndPaymentMap.put(newinsolPayRec.id, newinsolPayRec);
                } else {
                    if (response.length() > 131071) {
                        errResponse = response.subString(0, 131071);
                    } else {
                        errResponse = response;
                    }
                    if (string.isBlank(errResponse)) {
                        errResponse = 'statusCode get: ' + statusCode + ' - ' + statusDesc;
                    }
                    newinsolPayRec.id = insolPayData.id;
                    newinsolPayRec.Payment_Sub_Status__c = 'File Error Parsing Record';
                    insolAccAndPaymentMap.put(newinsolPayRec.id, newinsolPayRec);

                    CTBFileGenerator.exceptionHandling(null, null, null, insolAccAndPaymentMap.values(), batchName);
                }
            }
            if (!string.isBlank(errResponse)) {
                CFG_EmailNotification.apiFailedEmailNotify(UserInfo.getUserId(), errResponse, 'Error Response');
            }
        }
        return insolAccAndPaymentMap;
    }

    public Map<id, sObject> errorProcessingStatusUpdate(string batchName, List<sObject> listData) {
        Map<id, sObject> errorMap = new Map<id, sObject>();
        if (batchName == System.Label.CTB_Insolvency_Account) {
            for (insolvency_account__c insolAccData : (List<insolvency_account__c>) listData) {
                insolAccData.Insolvency_Sub_Status__c = 'File Error Parsing Record';
                errorMap.put(insolAccData.id, insolAccData);
            }
        }
        if (batchName == System.Label.CTB_Payment) {
            for (Insolvency_Payment__c insolPayData : (List<Insolvency_Payment__c>) listData) {
                insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                errorMap.put(insolPayData.id, insolPayData);
            }
        }
        return errorMap;
    }

    public Map<id, Sobject> populateErrorMesssage(String batchName, string DmlId, string errMsg) {
        Map<id, Sobject> insolvAcctErrorListMap = new Map<id, Sobject>();
        if (batchName == System.Label.CTB_Insolvency_Account) {
            insolvency_account__c insolAccError = new insolvency_account__c();
            insolAccError.id = DmlId;
            insolAccError.Insolvency_Sub_Status__c = 'File Error Parsing Record';
            insolAccError.Error_Message__c = errMsg;
            insolvAcctErrorListMap.put(insolAccError.id, insolAccError);
        }
        if (batchName == System.Label.CTB_Payment) {
            Insolvency_Payment__c insolPayError = new Insolvency_Payment__c();
            insolPayError.id = DmlId;
            insolPayError.Payment_Sub_Status__c = 'File Error Parsing Record';
            insolvAcctErrorListMap.put(insolPayError.id, insolPayError);
        }

        return insolvAcctErrorListMap;
    }
}
