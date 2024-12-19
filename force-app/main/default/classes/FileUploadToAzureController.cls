/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class is to upload document to azure
 *  @author : A5E Consulting
 *  @date : 07/12/2021
 *
 *************************************************************************************************/

public without sharing class FileUploadToAzureController {
    static final string PENDING = 'Pending';

    @AuraEnabled
    public static string save(String offerId, Blob versionData) {
        system.debug('entered save');
        ContentVersion currentContentVersion = new ContentVersion(Title = offerId, PathOnClient = offerId, VersionData = versionData);
        insert currentContentVersion;
        System.debug('@@currentContentVersion ' + currentContentVersion.Id);
        return currentContentVersion.Id;
    }

    //Save file in chunks
    @AuraEnabled
    public static Id saveChunk(
        Id parentId,
        String fileName,
        String base64Data,
        String contentType,
        String fileId,
        String documentType,
        String month,
        String year
    ) {
        system.debug('entered savechunk');
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks
        system.debug('fileId:' + fileId);
        if (fileId == '') {
            system.debug('call to saveTheFile from saveChink');
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, documentType);
        } else {
            system.debug('call to appendToFile from saveChink');
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }

    //Save document
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String documentType) {
        system.debug('entered saveTheFile');
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion contentVersionFile = new ContentVersion();
        //Setting that location of file will be in salesforce
        contentVersionFile.ContentLocation = 'S';
        contentVersionFile.VersionData = EncodingUtil.base64Decode(base64Data);
        contentVersionFile.Title = fileName;
        contentVersionFile.PathOnClient = '/' + fileName;
        if (documentType != '--None--') {
            contentVersionFile.Description = documentType + ';';
        } else {
        }
        insert contentVersionFile;
        system.debug('contentVersionFile: ' + contentVersionFile);
        // First get the content document Id from ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionFile.Id].ContentDocumentId;
        system.debug('ContentDocumentId ID: ' + conDoc);
        //Create ContentDocumentLink
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = parentId; // you can use objectId,GroupId etc
        // Inferred permission, checkout description of ContentDocumentLink object for more details
        cDe.ShareType = 'V';
        cDe.Visibility = 'AllUsers';
        insert cDe;
        system.debug('ContentDocumentLink::' + cDe);
        return cDe.Id;
    } //Saving Files

    @testVisible
    private static void appendToFile(Id fileId, String base64Data) {
        system.debug('entered appendToFile');
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion conv = [
            SELECT Id, Title, VersionData, ContentDocumentId, FileType, Description, CreatedDate, LastModifiedDate
            FROM ContentVersion
            WHERE ContentDocumentId = :fileId
        ];
        String existingBody = EncodingUtil.base64Encode(conv.VersionData);
        conv.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
        system.debug('ContentVersion in appendToFile' + conv);
        update conv;
    }

    public static string AGENCY_USER = 'Agency User';
    public static string LENDER_USER = 'Lender User';

    // recordId: application Id that sent from lightning component
    @AuraEnabled
    public static String getPurpose(String recordId) {
        //String setPurpose = 'True';
        system.debug('recordId::' + recordId);
        if (String.isNotBlank(recordId)) {
            list<Work_Assignment__c> docPurpose = new List<Work_Assignment__c>();
            docPurpose = [
                SELECT Id, Name, Purpose__c, Product__c
                FROM Work_Assignment__c
                WHERE id = :recordId
                LIMIT 1
            ];
            system.debug('docPurpose::' + docPurpose);
            if (!docPurpose.isEmpty()) {
                if (docPurpose[0].Purpose__c == 'Media Request') {
                    return docPurpose[0].Product__c;
                } else {
                    return null;
                }
            }
        }
        return null;
    }

    //system.debug('DocumentStorage::'+docPurpose);
    @AuraEnabled
    public static List<String> getPickListValuesIntoList() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Document_Storage__c.Visibility__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getLabel());
        }
        system.debug('pickListValuesList: ' + pickListValuesList);
        return pickListValuesList;
    }

    @AuraEnabled
    public static List<Document_Storage__c> getFiles(String recordId) {
        system.debug('entered getFiles');
        system.debug('recordId: ' + recordId);
        System.debug('@BASE_URL' + URL.getSalesforceBaseUrl().toExternalForm());
        String concat = recordId.substring(0, 3);
        system.debug('concat::' + concat);
        if (concat == 'a0D') {
            set<ID> settl = new Set<ID>();
            set<ID> accJudg = new Set<ID>();
            set<ID> workAssig = new Set<ID>();
            set<ID> customerId = new Set<ID>();
            List<settlement__c> settlID = [SELECT Id FROM settlement__c WHERE product__c = :recordId];
            if (!settlID.isEmpty()) {
                for (settlement__c settPrdId : settlID) {
                    settl.add(settPrdId.Id);
                }
            }
            List<Account_Judgment__c> accProdId = [SELECT judgment__c FROM Account_Judgment__c WHERE product__c = :recordID];
            if (!accProdId.isEmpty()) {
                for (account_judgment__c accjud : accProdId) {
                    accJudg.add(accjud.judgment__c);
                }
            }
            //List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Work_Assignment__c'];
            List<Work_Assignment__c> workId = [
                SELECT id, recordType.Name
                FROM Work_Assignment__c
                WHERE product__c = :recordID AND recordType.Name NOT IN ('CFG Complaint', 'Agency Excel Processing', 'Agency Complaint', 'CFG Excel Processing')
            ];
            system.debug('workId::' + workId);
            if (!workId.isEmpty()) {
                for (Work_Assignment__c workAssId : workId) {
                    workAssig.add(workAssId.ID);
                }
            }
            List<Product__c> accProdCutmId = [SELECT id, Customer__c FROM Product__c WHERE id = :recordID];
            system.debug('accProdCutmId' + accProdCutmId);
            if (!accProdCutmId.isEmpty()) {
                //system.debug('accProdCutmId'+accProdCutmId);
                for (Product__c cutmID : accProdCutmId) {
                    if (cutmID.Customer__c != null) {
                        system.debug('Customer__c::' + cutmID.Customer__c);
                        customerId.add(cutmID.Customer__c);
                    }
                }
            }
            return [
                SELECT
                    ID,
                    Document_ID__c,
                    Document_Name__c,
                    Document_URL__c,
                    Document_Type__c,
                    CreatedDate,
                    Content_Type__c,
                    Work_Assignment__c,
                    Created_By__c,
                    Document_Storage_Number__c,
                    //Work_Assignment_Purpose__c,
                    Parent_WorkAssignment_Product__c,
                    File_Processing_Status__c,
                    Staging_Records_Created__c,
                    Visibility__c,
                    Product__c
                FROM Document_Storage__c
                WHERE
                    Customer__c IN :customerId
                    OR Judgment__c IN :accJudg
                    OR Product__c = :RecordID
                    OR Settlement__c IN :settl
                    OR Work_Assignment__c IN :workAssig
                    OR Portfolio__c = :recordId
                ORDER BY CreatedDate DESC
            ];
        } else {
            // For all other user simply return the file list
            return [
                SELECT
                    ID,
                    Document_ID__c,
                    Document_Name__c,
                    Document_URL__c,
                    Document_Type__c,
                    CreatedDate,
                    Content_Type__c,
                    Work_Assignment__c,
                    Created_By__c,
                    Document_Storage_Number__c,
                    //Work_Assignment_Purpose__c,
                    Parent_WorkAssignment_Product__c,
                    File_Processing_Status__c,
                    Staging_Records_Created__c,
                    Visibility__c,
                    Product__c
                FROM Document_Storage__c
                WHERE
                    Customer__c = :recordId
                    OR Judgment__c = :recordId
                    OR Product__c = :recordId
                    OR Settlement__c = :recordId
                    OR Work_Assignment__c = :recordId
                    OR Portfolio__c = :recordId
                ORDER BY CreatedDate DESC
            ];
        }
    }

    @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
    }

    //method to upload file to azure system
    @AuraEnabled
    public static string uploadFile(
        Id parentId,
        String fileName,
        String base64Data,
        String contentType,
        String documentType,
        String sObjectName,
        String DocumentVisibility,
        boolean isMediaRequest,
        String productId
    ) {
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        //parsedResponse = DocumentAPIClient.postDocument(EncodingUtil.base64Decode(base64Data));
        //System.debug('@@base64Data '+base64Data);
        //Blob base64Data = [SELECT Id, VersionData FROM ContentVersion WHERE Id =: contentVersionId LIMIT 1].VersionData;
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob fileBlob = EncodingUtil.base64Decode(base64Data);

        if (sObjectName == 'Account') {
            sObjectName = 'Customer';
        }
        if (sObjectName == 'Product__c') {
            sObjectName = 'Account';
        }
        if (sObjectName == 'Judgment__c') {
            sObjectName = 'Judgment';
        }
        if (sObjectName == 'Settlement__c') {
            sObjectName = 'Settlement';
        }
        if (sObjectName == 'Work_Assignment__c' && isMediaRequest == false) {
            sObjectName = 'Task';
        }
        if (sObjectName == 'Portfolio_Name__c') {
            sObjectName = 'portfolio';
        }
        if (sObjectName == 'Work_Assignment__c' && isMediaRequest == true && String.isNotBlank(productId)) {
            sObjectName = 'Account';
            parentId = productId;
        }
        //if(!Test.isRunningTest()){
        parsedResponse = DocumentAPIClient.postDocument(fileBlob, fileName, sObjectName);
        //}

        /*  string splitHeaders = '';
        String ERROR_MSG = '';      
        Agency_Portal_Settings__c portalSetting = new Agency_Portal_Settings__c();
        if(documentType == 'Product Recall File'){            
            splitHeaders = portalSetting.validProductRecallHeaders__c;
            list<String> splitedHeadersList = splitHeaders.split(',');
            splitedHeadersList.sort();         
            if(splitedHeadersList.size() != 2){
               ERROR_MSG = 'Headers are not in a proper Count';
               return ERROR_MSG;
            }
            if(!splitedHeadersList.contains('json headers values')){
                ERROR_MSG = 'File is not in proper format'; 
                return ERROR_MSG;
            }
        }
        */
        List<Product__c> productCollectionAgency = [SELECT Collection_Agency_Placement__c FROM Product__c WHERE id = :parentId];
        List<Account> customerCollectionAgency = [SELECT Collection_Agency_Identifier__c FROM Account WHERE id = :parentId];
        List<Judgment__c> judgmentPlacementAgency = [
            SELECT Collection_Agency_Identifier__c, Legal_Agency__c, Legal_Agency_Placement__c
            FROM Judgment__c
            WHERE id = :parentId
        ];
        List<Settlement__c> settlementPlacementAgency = [SELECT Placement__c FROM Settlement__c WHERE id = :parentId];
        List<Work_Assignment__c> workAssignmentPlacementAgency = [SELECT Placement_Agency__c FROM Work_Assignment__c WHERE id = :parentId];
        if (parsedResponse.response == null) {
            return null;
        }
        //if(Test.isRunningTest()){

        // parsedResponse.response ={"$id":"1","docId":"69651f79ad0330cd67dc","docUrl":"account69651f79"};

        //        }
        Map<String, Object> rawObj = (Map<String, Object>) JSON.deserializeUntyped(parsedResponse.response);
        /*if(Test.isRunningTest()){
            //parsedResponse = test;
            rawObj.put('$id',1); 
            rawObj.put('docId','d8187e46d4a84ae6a98cb290e3f2b8de');                            
            rawObj.put('docUrl','accountd8187e46d4a84ae6');                            
        }*/
        Document_Storage__c docStorage = new Document_Storage__c();

        if ((null != parsedResponse && String.isnotBlank(String.valueOf(rawObj.get('docId')))) || Test.isrunningTest()) {
            if (sObjectName == 'Customer') {
                docStorage.Customer__c = parentId;
                for (Account cust : customerCollectionAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Identifier__c = cust.Collection_Agency_Identifier__c;
                    }
                }
            }
            if (sObjectName == 'Account') {
                docStorage.Product__c = parentId;
                for (Product__c prod : productCollectionAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = prod.Collection_Agency_Placement__c;
                    }
                }
            }
            if (sObjectName == 'Judgment') {
                docStorage.Judgment__c = parentId;
                for (Judgment__c judg : judgmentPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        // docStorage.Placement_Identifier__c = judg.Collection_Agency_Identifier__c;
                        //  docStorage.Placement_Identifier__c = judg.Legal_Agency__c;
                        docStorage.Placement_Agency__c = judg.Legal_Agency_Placement__c;
                    }
                }
            }
            if (sObjectName == 'Settlement') {
                docStorage.Settlement__c = parentId;
                for (Settlement__c stllmnt : settlementPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = stllmnt.Placement__c;
                    }
                }
            }
            if (sObjectName == 'Task') {
                docStorage.Work_Assignment__c = parentId;
                for (Work_Assignment__c workAssig : workAssignmentPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = workAssig.Placement_Agency__c;
                    }
                }
            }

            if (sObjectName == 'portfolio') {
                docStorage.Portfolio__c = parentId;
            }

            docStorage.Document_Name__c = fileName;
            docStorage.Document_Extension__c = fileName.substringAfter('.');
            docStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            docStorage.Document_Type__C = documentType;
            docStorage.Content_Type__c = contentType;
            docStorage.Visibility__c = DocumentVisibility;
            docStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            docStorage.Uploaded_By__c = 'Internal User';
            docStorage.Creator__c = UserInfo.getName();
            docStorage.Document_Related_To__c = sObjectName;
            //docStorage.Placement_Agency__c = placement ;
            //docStorage.Version__c = 1;
            insert docStorage;
            return docStorage.id;
        }
        return null;
    }
    @AuraEnabled
    public static DocumentDetails previewDocument(String documentId) {
        system.debug('String documentId ' + documentId);
        DocumentDetails docDetails = DocumentAPIClient.getDocumentInfo(documentId);
        if (docDetails.document != null) {
            docDetails.fileString = EncodingUtil.base64Encode(docDetails.document);
        } else {
            docDetails.fileString = '';
        }
        return docDetails;
    }
    @AuraEnabled //Fetching Document Names from Custom Setting
    public static list<String> documentTypeList() {
        List<String> listDocumentType = new List<String>();
        List<Attachment_Document_Type__c> attachlistsetting = new List<Attachment_Document_Type__c>();
        attachlistsetting = [SELECT name, Document_type__c FROM Attachment_Document_Type__c ORDER BY name ASC];

        for (Attachment_Document_Type__c alist : attachlistsetting) {
            listDocumentType.add(alist.Document_type__c);
        }

        /*listDocumentType.add('Product Payment Upload File');
        listDocumentType.add('Account Status Update File');
        listDocumentType.add('Account Status (having Judgment) Update File');
        listDocumentType.add('Customer Contact Information Update File');
        listDocumentType.add('Product Allocation File');
        listDocumentType.add('Product Recall File');
        listDocumentType.add('Others');
        //listDocumentType.remove('--None--');*/
        listDocumentType.sort();
        return listDocumentType;
    }
    @AuraEnabled
    public static Blob getDocument(String documentId) {
        Blob pdfBlob = DocumentAPIClient.getDocument(documentId);
        return pdfBlob;
    }
    @AuraEnabled
    public static String contentSize(String cid) {
        List<ContentDocument> Doc = [SELECT id, contentsize FROM ContentDocument WHERE id = :cid LIMIT 1];
        integer size = Doc[0].contentsize;
        // if(size > 5797743){ // commented by Rajesh
        if (size > 20971520) {
            delete Doc[0];
            return 'ERROR';
        } else {
            return 'SUCCESS';
        }
    }
    @AuraEnabled
    public static string uploadFileToAzure(
        id documentid,
        string parentId,
        String documentType,
        String sObjectName,
        String DocumentVisibility,
        boolean isMediaRequest,
        String productId,
        Boolean isEvidence
    ) {
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        if (test.isRunningTest()) {
            parsedResponse.docId = documentid;
            parsedResponse.DocUrl = 'google.com';
            parsedResponse.request = 'ssss';
            parsedResponse.response = '{"data": [{"docId": "ooooa", "i": 1}]}';
        }
        if (sObjectName == 'Account') {
            sObjectName = 'Customer';
        }
        if (sObjectName == 'Product__c') {
            sObjectName = 'Account';
        }
        if (sObjectName == 'Judgment__c') {
            sObjectName = 'Judgment';
        }
        if (sObjectName == 'Settlement__c') {
            sObjectName = 'Settlement';
        }
        if (sObjectName == 'Work_Assignment__c' && isMediaRequest == false) {
            sObjectName = 'Task';
        }
        if (sObjectName == 'Portfolio_Name__c') {
            sObjectName = 'portfolio';
        }
        if (sObjectName == 'Work_Assignment__c' && isMediaRequest == true && String.isNotBlank(productId)) {
            sObjectName = 'Account';
            parentId = productId;
        }
        ContentVersion con = [
            SELECT Id, FileExtension, ContentDocumentId, VersionData, CreatedById, TextPreview, Title, VersionNumber
            FROM ContentVersion
            WHERE ContentDocumentId = :documentid
            ORDER BY CreatedDate DESC
        ];
        System.debug('@@@@@@@@@:' + con);
        string fullfilename = con.Title + '.' + con.FileExtension;
        String attachmentName = (con.Title.substringBefore('@') + '.' + con.FileExtension);
        String encodedString = EncodingUtil.urlEncode(attachmentName, 'UTF-8');
        attachmentName = encodedString;
        if (!test.isRunningTest()) {
            //con.VersionData is replaced by con.ContentDocumentId >>> blob.valueOf(con.ContentDocumentId), attachmentName, sObjectName)
            // parsedResponse = DocumentAPIClient.postDocument(blob.valueOf(con.ContentDocumentId), attachmentName, sObjectName);
            //parsedResponse = DocumentAPIClient.postDocument(con.VersionData, attachmentName, sObjectName);
            parsedResponse = DocumentAPIClient.postDocument2(con.Id, attachmentName, sObjectName);
            System.debug('@@@@@@@@@:' + parsedResponse);
        }
        List<Product__c> productCollectionAgency = [SELECT Collection_Agency_Placement__c FROM Product__c WHERE id = :parentId];
        List<Account> customerCollectionAgency = [SELECT Collection_Agency_Identifier__c FROM Account WHERE id = :parentId];
        List<Judgment__c> judgmentPlacementAgency = [
            SELECT Collection_Agency_Identifier__c, Legal_Agency__c, Legal_Agency_Placement__c
            FROM Judgment__c
            WHERE id = :parentId
        ];
        List<Settlement__c> settlementPlacementAgency = [SELECT Placement__c FROM Settlement__c WHERE id = :parentId];
        List<Work_Assignment__c> workAssignmentPlacementAgency = [SELECT Placement_Agency__c FROM Work_Assignment__c WHERE id = :parentId];
        if (parsedResponse.response == null) {
            return null;
        }

        Map<String, Object> rawObj = (Map<String, Object>) JSON.deserializeUntyped(parsedResponse.response);

        Document_Storage__c docStorage = new Document_Storage__c();

        if ((null != parsedResponse && String.isnotBlank(String.valueOf(rawObj.get('docId')))) || Test.isrunningTest()) {
            if (sObjectName == 'Customer') {
                docStorage.Customer__c = parentId;
                for (Account cust : customerCollectionAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Identifier__c = cust.Collection_Agency_Identifier__c;
                    }
                }
            }
            if (sObjectName == 'Account') {
                docStorage.Product__c = parentId;
                for (Product__c prod : productCollectionAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = prod.Collection_Agency_Placement__c;
                    }
                }
            }
            if (sObjectName == 'Judgment') {
                docStorage.Judgment__c = parentId;
                for (Judgment__c judg : judgmentPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = judg.Legal_Agency_Placement__c;
                    }
                }
            }
            if (sObjectName == 'Settlement') {
                docStorage.Settlement__c = parentId;
                for (Settlement__c stllmnt : settlementPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = stllmnt.Placement__c;
                    }
                }
            }
            if (sObjectName == 'Task') {
                docStorage.Work_Assignment__c = parentId;
                for (Work_Assignment__c workAssig : workAssignmentPlacementAgency) {
                    if (docStorage.Placement_Agency__c == null) {
                        docStorage.Placement_Agency__c = workAssig.Placement_Agency__c;
                    }
                }
            }

            if (sObjectName == 'portfolio') {
                docStorage.Portfolio__c = parentId;
            }

            docStorage.Document_Name__c = fullfilename;
            docStorage.Document_Extension__c = con.FileExtension;
            docStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            docStorage.Document_Type__C = documentType;
            docStorage.Visibility__c = DocumentVisibility;
            docStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            docStorage.Uploaded_By__c = 'Internal User';
            docStorage.Creator__c = UserInfo.getName();
            docStorage.Document_Related_To__c = sObjectName;
            docStorage.Buyback_Putback_Evidence__c = isEvidence;
            insert docStorage;
            if (con != null) {
                List<ContentDocumentLink> contlist = [
                    SELECT id
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :parentId AND contentdocumentid = :con.ContentDocumentId
                ];
                ContentDocumentLink documentlinkinsert = new ContentDocumentLink(
                    ContentDocumentId = con.ContentDocumentId,
                    LinkedEntityId = docStorage.id,
                    ShareType = 'V',
                    Visibility = 'InternalUsers'
                );
                insert documentlinkinsert;
                delete contlist;
            }
            return docStorage.id;
        }
        return null;
    }

    /*+++*/
    @AuraEnabled
    public static string getPreviewOfDoc(string documentId) {
        Document_Storage__c docObj = [SELECT id, product__c, Document_Name__c, Document_URL__c FROM Document_storage__c WHERE document_Id__c = :documentId][0];
        Set<Id> contentDocumentSet = new Set<Id>();
        for (contentdocumentlink contDocLinkObj : [SELECT contentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = :docObj.product__c]) {
            contentDocumentSet.add(contDocLinkObj.contentDocumentId);
        }
        Id contentVersionId;
        for (ContentVersion conV : [
            SELECT Id, FileExtension, ContentDocumentId, VersionData, CreatedById, TextPreview, Title, VersionNumber
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentSet
            ORDER BY CreatedDate DESC
        ]) {
            system.debug(docObj.Document_Name__c);
            system.debug(conV.Title);
            if (docObj.Document_Name__c.contains(conV.Title)) {
                contentVersionId = conV.Id;
                system.debug('+++' + ' ' + conV.Title + contentVersionId);
            }
        }

        String fileToDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentVersionId;
        //	String fileToDownload=URL.getSalesforceBaseUrl().toExternalForm()+'/sfc/servlet.shepherd/version/download/'+documentId;
        system.debug(fileToDownload);
        return fileToDownload;
    }
    //Added by Rajesh 4134
    @AuraEnabled
    public static string uploadDocumentProxy(string documentURL) {
        //Commented by satyajit because we are using document URL instead of document id as discussed with Ankur
        //Document_Storage__c docObj = [Select id,product__c,Document_Extension__c,Document_Name__c,Document_URL__c from Document_storage__c where document_URL__c=:documentId][0];
        //system.debug('documentURL::'+documentURL);
        //  Document documents = [SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name ='Metadata_Content' LIMIT 1];
        Folder documents = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];

        //Pass the document URL directly : change made by satyajit
        String fileToDownloadID = DocumentApiClient.createDocumentFromAzure(documents.Id, documentURL);

        // File name update from document object - Nagendra - 4336//
        Document_Storage__c docObj = [SELECT id, Document_Name__c, Document_URL__c FROM Document_storage__c WHERE document_URL__c = :documentURL][0];

        Document document = new Document(Id = fileToDownloadID, name = docObj.Document_Name__c);
        update document;

        //Building the URL to downlowd the file from salesforce
        String fileToDownload = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + fileToDownloadID;
        //Api call
        system.debug(fileToDownload);
        return fileToDownload;
    }
}
