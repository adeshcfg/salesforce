/**
 * @description       : Queueable class for putback/buyback processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-11-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class PutbackBuybackQueueable implements Queueable, Database.AllowsCallouts {
    List<String> productIdList = new List<String>();
    List<Product__c> productList = new List<Product__c>();
    String zipDocStorageId = '';
    String sellerName = '';
    String csvContentVersionId = '';
    String operation = 'CSV';

    // Constructor for CSV generation
    public PutbackBuybackQueueable(List<String> productIdList, List<Product__c> productList, String sellerName) {
        this.productIdList = productIdList;
        this.productList = productList;
        this.sellerName = sellerName;
    }

    // Constructor for zip file inititation
    public PutbackBuybackQueueable(List<String> productIdList, String zipDocStorageId, String sellerName, String csvContentVersionId) {
        this.operation = 'ZIP';
        this.productIdList = productIdList;
        this.zipDocStorageId = zipDocStorageId;
        this.sellerName = sellerName;
        this.csvContentVersionId = csvContentVersionId;
    }

    public void execute(QueueableContext context) {
        try {
            switch on operation {
                when 'CSV' {
                    createProductCsv(productIdList, productList, sellerName);
                }
                when 'ZIP' {
                    createZipFile(productIdList, zipDocStorageId, sellerName, csvContentVersionId);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' ' + ex.getStackTraceString());
            PutbackBuybackUtility.createInsolvencyError('Putback/Buyback Processing failed', ex.getMessage(), ex.getStackTraceString());
        }
    }

    /**
     * @description : Method to create Putback/Buyback CSV for provided product list
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param productIdList
     * @param productList
     * @param sellerName
     **/
    public void createProductCsv(List<String> productIdList, List<Product__c> productList, String sellerName) {
        Map<String, String> putbackBuyback = new Map<String, String>{ '297000' => 'Putback', '298000' => 'Buyback' };
        String fileName = '';
        String csvHeader = 'Putback/Buyback,Canaccede Account ID,Purchase Date,Debtor Name,pri_acctno,Purchased Amount,Buyback Back Amount,Purchase Price,Reason,Backup Submitted,Charge Off Date,Charge Off Amount,Note\n';
        String productCsvString = '';
        Set<String> productIdsWithEvidence = new Set<String>();
        // Get documents marked as evidence with associated product
        for (Document_Storage__c evidenceDoc : [
            SELECT Product__c
            FROM Document_Storage__c
            WHERE Product__c IN :productIdList AND Buyback_Putback_Evidence__c = TRUE
        ]) {
            productIdsWithEvidence.add(evidenceDoc.Product__c);
        }
        // CSV generation logic
        productCsvString += csvHeader;
        for (Product__c prod : productList) {
            String documentSubmitted = productIdsWithEvidence.contains(prod.Id) ? 'Yes' : '';
            productCsvString +=
                putbackBuyback.get(prod.Product_Status__c) +
                ',' +
                prod.Name +
                ',' +
                PutbackBuybackUtility.convertDateToString(prod.Purchase_Date_Formula__c) +
                ',' +
                prod.Primary_Debtor_AKA_Name__c +
                ',' +
                prod.Previous_Primary_Account_Number__c +
                ',' +
                String.valueOf(prod.Purchase_Face_Value__c) +
                ',' +
                String.valueOf(prod.Purchase_Price__c) +
                ',' +
                String.valueOf(prod.Purchase_Factor__c) +
                ',' +
                prod.Buyback_Putback_Reason__c +
                ',' +
                documentSubmitted +
                ',' +
                PutbackBuybackUtility.convertDateToString(prod.Charged_Off_Date__c) +
                ',' +
                String.valueOf(prod.Charged_Off_Amount__c) +
                ',' +
                prod.Other_Reason__c +
                '\n';
        }
        fileName = Datetime.now().format('yyyyMMdd') + '_' + sellerName;
        // Create content version record for generated CSV
        ContentVersion cv = PutbackBuybackUtility.createContentVersion(fileName, Blob.valueOf(productCsvString));
        // Update comment field on doc storage with content version Id of CSV file
        Document_Storage__c zipDoc = PutbackBuybackUtility.createDocStorage(fileName, cv.Id);
        // Queue zip inititation job
        if (!Test.isRunningTest()) {
            System.enqueueJob(new PutbackBuybackQueueable(productIdList, zipDoc.Id, sellerName, cv.Id));
        }
    }

    /**
     * @description : Method to call portal API to inititate ZIP file creation
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param productIdList
     * @param zipDocStorageId
     * @param sellerName
     * @param csvContentVersionId
     **/
    public void createZipFile(List<String> productIdList, String zipDocStorageId, String sellerName, String csvContentVersionId) {
        List<String> documentIdList = new List<String>();
        for (Document_Storage__c evidenceDoc : [SELECT Id FROM Document_Storage__c WHERE Product__c IN :productIdList AND Buyback_Putback_Evidence__c = TRUE]) {
            documentIdList.add(evidenceDoc.Id);
        }
        // Call Portal API for zip file processing
        Boolean zipFileInitiationSuccessful = initiateZipFileCreation(documentIdList, zipDocStorageId);
        if (!zipFileInitiationSuccessful) {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            update new Document_Storage__c(Id = zipDocStorageId, File_Processing_Status__c = 'Failed');
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return;
        }
        // Call API portal to upload CSV to blob storage and create doc storage record
        uploadCsvToAzure(csvContentVersionId, zipDocStorageId);
        // Send processing/failure mail
        CTBFileValidationUtility.sendEmail(
            'Putback/Buyback Processing initiated',
            'You will be emailed when the processing is complete.<br/>You will be notified if any issues are encountered during the processing of your request.',
            System.Label.Putback_Buyback_Email_Ids
        );
        // Check and Schedule ZipFileStatusChecker if success
        String jobName = 'ZipFileStatusChecker for ' + sellerName;
        List<CronTrigger> existingJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName AND State = 'WAITING'];
        if (!Test.isRunningTest()) {
            // Abort existing job and schedule new one
            if (!existingJob.isEmpty()) {
                System.abortJob(existingJob[0].Id);
            }
            System.scheduleBatch(new ZipFileStatusChecker(sellerName), jobName, 120);
        }
    }

    public void uploadCsvToAzure(String csvContentVersionId, String zipDocStorageId) {
        ContentVersion con = [
            SELECT Id, FileExtension, Title
            FROM ContentVersion
            WHERE Id = :csvContentVersionId
        ];
        String fullFileName = con.Title + '.' + con.FileExtension;
        String attachmentName = EncodingUtil.urlEncode((con.Title.substringBefore('@') + '.' + con.FileExtension), 'UTF-8');
        // Call API to upload CSV file
        DocumentAPIClientUtil.ParsedResponse parsedResponse = DocumentAPIClient.postDocument2(csvContentVersionId, attachmentName, 'buybackputback');
        if (parsedResponse != null) {
            Document_Storage__c docStorage = new Document_Storage__c();
            docStorage.Document_Name__c = fullfilename;
            docStorage.Document_Extension__c = con.FileExtension;
            docStorage.Document_ID__c = parsedResponse.docId;
            docStorage.Document_Type__C = 'Buyback/Putback Submission CSV';
            docStorage.Visibility__c = 'CFG only';
            docStorage.Document_URL__c = parsedResponse.DocUrl;
            docStorage.Uploaded_By__c = 'Internal User';
            docStorage.Creator__c = UserInfo.getName();
            docStorage.Document_Storage__c = zipDocStorageId;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            insert docStorage;
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
        }
    }

    /**
     * @description : Method to call portal API for zip file creation
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param documentIdList
     * @param zipDocStorageId
     * @return Boolean
     **/
    public Boolean initiateZipFileCreation(List<String> documentIdList, String zipDocStorageId) {
        Boolean status = false;
        Folder downloadFolder = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        API_Call_Details__c apiCallDetails = API_Call_Details__c.getInstance('Agency Portal API');
        String accToken = AzureUtility.getRequestToken('Agency Portal API');
        String endpoint = apiCallDetails.PDF_API_URL__c.replace('Document', 'background/zip') + '?SalesforceFolderId=' + downloadFolder.Id;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accToken);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(apiCallDetails.API_Request_Timeout__c));
        req.setBody(JSON.serialize(new Map<String, List<String>>{ 'DocumentIds' => documentIdList }));
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = h.send(req);
            if (res.getStatusCode() == 202) {
                status = true;
            } else {
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
                update new Document_Storage__c(Id = zipDocStorageId, File_Processing_Status__c = 'Failed', Comment__c = res.getBody());
                DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
                PutbackBuybackUtility.createApiError(
                    String.valueOf(res.getStatusCode()),
                    res.getBody(),
                    'Putback/Buyback Zip File initiation failed',
                    System.Label.Putback_Buyback_Email_Ids
                );
            }
        } catch (Exception ex) {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            update new Document_Storage__c(Id = zipDocStorageId, File_Processing_Status__c = 'Failed', Comment__c = ex.getStackTraceString());
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            PutbackBuybackUtility.createApiError(
                ex.getMessage(),
                ex.getStackTraceString(),
                'Putback/Buyback Zip File initiation failed',
                System.Label.Putback_Buyback_Email_Ids
            );
            System.debug('Exception in initiateZipFileCreation ' + ex.getStackTraceString());
        }
        return status;
    }
}
