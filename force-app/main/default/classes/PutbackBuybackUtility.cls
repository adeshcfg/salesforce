/**
 * @description       : Utility class for putback/buyback processing
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-25-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class PutbackBuybackUtility {
    /**
     * @description : Method to get list of sellers
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @return List<String>
     **/
    @AuraEnabled(cacheable=true)
    public static List<String> getSellerList() {
        List<String> sellerList = new List<String>();
        for (AggregateResult portfolio : [
            SELECT Seller__r.Name seller
            FROM Portfolio_Name__c
            WHERE Seller__r.Name != NULL
            GROUP BY Seller__r.Name
            ORDER BY Seller__r.Name
        ]) {
            sellerList.add(String.valueOf(portfolio.get('seller')));
        }
        return sellerList;
    }

    /**
     * @description : Method to check if file generation is already in progress for the selected seller
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param selectedSeller
     * @return Boolean
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean canGenerateFile(String selectedSeller) {
        String docName = Datetime.now().format('yyyyMMdd') + '_' + selectedSeller + '.zip';
        List<Document_storage__c> existingDocument = [
            SELECT Id, Name
            FROM Document_storage__c
            WHERE Document_Name__c = :docName AND CreatedDate = TODAY AND File_Processing_Status__c = 'Pending'
        ];
        if (existingDocument.isEmpty()) {
            return true;
        }
        return false;
    }

    /**
     * @description : Method to initiate file generation process
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param selectedSeller
     **/
    @AuraEnabled(cacheable=true)
    public static void initiateFormGeneration(String selectedSeller) {
        List<String> productIdList = new List<String>();
        try {
            List<Product__c> productList = getSellerProducts(selectedSeller);
            if (productList.isEmpty()) {
                throw newMessageException('No eligible products found for the selected Seller');
            }
            for (Product__c prod : productList) {
                productIdList.add(prod.Id);
            }
            // CSV generation job
            System.enqueueJob(new PutbackBuybackQueueable(productIdList, productList, selectedSeller));
        } catch (Exception e) {
            throw newMessageException(e.getMessage());
        }
    }

    /**
     * @description : Method to get list of products which are in Buyback/Putback Initiated for the selected seller
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param selectedSeller
     * @return List<Product__c>
     **/
    public static List<Product__c> getSellerProducts(String selectedSeller) {
        List<Product__c> productList = new List<Product__c>();
        productList = [
            SELECT
                Id,
                Name,
                Product_Status__c,
                Purchase_Date_Formula__c,
                Customer__r.Name,
                Previous_Primary_Account_Number__c,
                Purchase_Face_Value__c,
                Purchase_Price__c,
                Purchase_Factor__c,
                Buyback_Putback_Reason__c,
                Charged_Off_Date__c,
                Charged_Off_Amount__c,
                Other_Reason__c
            FROM Product__c
            WHERE
                Seller__r.Name = :selectedSeller
                AND (Product_Status__c = '297000'
                OR Product_Status__c = '298000')
                AND Purchase_Status__c = 'Buyback/Putback Initiated'
        ];
        return productList;
    }

    /**
     * @description : Method to create ContentVersion record
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param fileName
     * @param fileContent
     * @return ContentVersion
     **/
    public static ContentVersion createContentVersion(String fileName, Blob fileContent) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = fileContent;
        cv.Title = fileName;
        cv.PathOnClient = fileName + '.csv';
        try {
            Database.insert(cv);
            return cv;
        } catch (DmlException ex) {
            System.debug('DMLException in createContentVersion ' + ex.getDmlMessage(0));
            createInsolvencyError('Putback/Buyback Processing failed', ex.getDmlMessage(0), ex.getStackTraceString());
            return null;
        }
    }

    /**
     * @description : Method to create Document_Storage__c record
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param fileName
     * @param contentVersionId
     * @return Document_Storage__c
     **/
    public static Document_Storage__c createDocStorage(String fileName, String contentVersionId) {
        // Create document storage record associated to the file
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Type__c = 'Buyback/Putback Submission ZIP';
        docInfo.Document_Name__c = fileName + '.zip';
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Comment__c = contentVersionId;
        docInfo.Document_Extension__c = 'zip';
        docInfo.Visibility__c = 'CFG only';
        docInfo.Uploaded_By__c = 'Internal User';
        docInfo.RecordTypeId = Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Distressed').getRecordTypeId();
        try {
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = false;
            Database.insert(docInfo);
            DocumentStorageTriggerHandler.runDocumentStorageTrigger = true;
            return docInfo;
        } catch (DmlException ex) {
            System.debug('DMLException in createDocStorage ' + ex.getDmlMessage(0));
            createInsolvencyError('Putback/Buyback Processing failed', ex.getDmlMessage(0), ex.getStackTraceString());
            return null;
        }
    }

    /**
     * @description : Method to convert date to string format for CSV
     * @author adesh.ikhar@canaccede.com | 02-12-2025
     * @param dt
     * @return String
     **/
    public static String convertDateToString(DateTime dt) {
        if (dt != null) {
            return (dt.formatGMT('MM/dd/yyyy'));
        } else {
            return '';
        }
    }

    /**
     * @description : Method to throw AuraHandledException with custom error message
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param message
     * @return AuraHandledException
     **/
    public static AuraHandledException newMessageException(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        return e;
    }

    /**
     * @description : Method to create error record and send failure email
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param emailSubject
     * @param errorMsg
     * @param stackTrace
     **/
    public static void createInsolvencyError(String emailSubject, String errorMsg, String stackTrace) {
        Insolvency_Error__c insolErrorData = new Insolvency_Error__c();
        insolErrorData.Error__c = 'Processing failed due to' + '\n' + errorMsg + ' ' + stackTrace;
        Database.insert(insolErrorData);
        CTBFileValidationUtility.sendEmail(emailSubject, 'Processing failed due to - ' + errorMsg + '\n' + stackTrace, System.Label.Putback_Buyback_Email_Ids);
    }

    /**
     * @description : Method to create api error record and send failure email
     * @author adesh.ikhar@canaccede.com | 02-11-2025
     * @param exceptionMsg
     * @param stackTraceString
     * @param subject
     * @param commaSeparatedEmails
     **/
    public static void createApiError(String exceptionMsg, String stackTraceString, String subject, String commaSeparatedEmails) {
        API_Error__c apiError = new API_Error__c(Action__c = 'API Failed', Error__c = exceptionMsg + stackTraceString);
        insert apiError;
        CTBFileValidationUtility.sendEmail(subject, 'API Failed with error - ' + apiError.Error__c, commaSeparatedEmails);
    }
}
