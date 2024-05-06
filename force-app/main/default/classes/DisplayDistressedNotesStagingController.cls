/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Distressed Notes records from Staging and create success
*                  and failure files for Distressed Notes
*  @author : A5E Consulting
*  @date : 15/01/2023

*************************************************************************************************/
public class DisplayDistressedNotesStagingController {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public Map<Integer, distressedNotesStagingWrapper> recordMap { get; set; }
    public list<Distressed_Note_Staging__c> listDistressedNotesStaging { get; set; }
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    public boolean showButton { get; set; }
    public boolean showRecords { get; set; }
    public boolean displayPanel { get; set; }
    public Id workAssignmentId { get; set; }
    public String message { get; set; }
    Id recordID;
    Id documentID;
    String success;
    String failed;
    Decimal successRecords;
    Decimal failedRecords;
    Boolean SuccessHasRecord;
    Boolean FailedHasRecord;
    String placementAgency = '';
    public boolean isSelected { get; set; }

    public DisplayDistressedNotesStagingController() {
        //ShowOk = false;
        showRecords = false;
        showButton = true;
        displayPanel = false;
        SuccessHasRecord = false;
        FailedHasRecord = false;
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listDistressedNotesStaging = [
            SELECT
                ID,
                body__c,
                ProdID__c,
                Comment__c,
                Agency_Id__c,
                CreatedById,
                Data_Id__c,
                Document_Storage__r.Work_Assignment__c,
                Name,
                Document_Storage__c,
                Expected_Value__c,
                Identifier__c,
                LastModifiedById,
                OwnerId,
                Product_Id__c,
                Status__c,
                Title__c,
                Visibility__c
            FROM Distressed_Note_Staging__c
            WHERE Identifier__c = :recordIdentfier
        ];
        if (listDistressedNotesStaging.isEmpty()) {
            //showButton = false;
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'There are no Distressed Notes Information  to display'));
        } else {
            showRecords = true;
            Integer i = 0;
            recordMap = new Map<Integer, distressedNotesStagingWrapper>();
            for (Distressed_Note_Staging__c distStaging : listDistressedNotesStaging) {
                Boolean disabled = false;
                if (distStaging.Comment__c.contains(ERROR) || (distStaging.Status__c == PROCESSED && distStaging.Comment__c == 'SUCCESS')) {
                    disabled = true;
                }
                recordMap.put(i, new distressedNotesStagingWrapper(distStaging, disabled));
                i++;
                if (distStaging.Status__c != PROCESSED && !distStaging.Comment__c.contains(ERROR)) {
                    showButton = true;
                }
            }
            //placementAgency = listDistressedNotesStaging[0].Placement_Agency__c;
            documentID = listDistressedNotesStaging[0].Document_Storage__c;
            if (showButton == false) {
                if (listDistressedNotesStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED) {
                    //showButton = false;
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO, 'Records are already processed'));
                } else {
                    showButton = false;
                }
            }
        }
    }
    public pageReference Save() {
        list<Distressed_notes__c> listDistNotes = new List<Distressed_notes__c>();
        success = 'data_id' + '\t' + 'title' + '\t' + 'body' + '\t' + 'visibility';
        failed = 'data_id' + '\t' + 'title' + '\t' + 'body' + '\t' + 'visibility' + '\t' + 'error' + '\n';
        successRecords = 0;
        failedRecords = 0;
        String monthInt = '';
        Integer monthSize = null;

        for (Integer key : recordMap.keySet()) {
            distressedNotesStagingWrapper distStagingWrapper = recordMap.get(key);
            Distressed_Note_Staging__c distStaging = distStagingWrapper.distStaging;
            String comment = '';
            String currentMonth;
            if (String.isNotBlank(distStaging.Comment__c)) {
                comment = distStaging.Comment__c;
            }
            if (Test.isRunningTest()) {
                distStagingWrapper.selected = true;
            }
            //If No error found, create  record from staging
            if (distStaging.Status__c != PROCESSED && !distStaging.Comment__c.contains('ERROR')) {
                distStaging.Status__c = PROCESSED;
                Distressed_notes__c distNotes = new Distressed_notes__c();

                distNotes.Body__c = distStaging.body__c;
                distNotes.Product__c = distStaging.Product_Id__c;
                distNotes.Title__c = distStaging.Title__c;
                distNotes.Visibility__c = distStaging.Visibility__c;
                distNotes.Product_Identifier__c = distStaging.ProdID__c;
                distNotes.Agency_ID__c = distStaging.Agency_Id__c;
                distNotes.Created_By__C = UserInfo.getName();
                distNotes.Last_Modified_By__c = UserInfo.getName();
                listDistNotes.add(distNotes);

                success += '\n';
                success +=
                    distStaging.ProdID__c +
                    '\t' +
                    distStaging.Title__c +
                    '\t' +
                    (distStaging.body__c != null ? distStaging.body__c : '') +
                    '\t' +
                    (distStaging.Visibility__c != null ? distStaging.Visibility__c : '');

                SuccessHasRecord = true;
                successRecords = successRecords + 1;
            } else {
                failed +=
                    distStaging.ProdID__c +
                    '\t' +
                    distStaging.Title__c +
                    '\t' +
                    (distStaging.body__c != null ? distStaging.body__c : '') +
                    '\t' +
                    (distStaging.Visibility__c != null ? distStaging.Visibility__c : '') +
                    '\t' +
                    (distStaging.Comment__c != null ? distStaging.Comment__c.stripHtmlTags() : '');
                FailedHasRecord = true;
                failedRecords = failedRecords + 1;
            }
        }
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = false;
        insert listDistNotes;
        DistressedNotesTriggerHandler.runDistressedNotesTrigger = true;

        //Added for ticket: 4232 by satyajit
        //Bug:5140 Updated the batch size from 200 to 50
        Database.executeBatch(new DistressedNotesAPIBatch(listDistNotes), 50);
        list<Work_Assignment__c> listWorkAssignmentToUpsert = new List<Work_Assignment__c>();

        //Create Task record and assign it to Agency
        //Update the existing Task record (as per new req)
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.ID = listDistressedNotesStaging[0].Document_Storage__r.Work_Assignment__c;
        workAssignmentId = workAssignment.ID;

        workAssignment.Comment_Reply__c = '';
        workAssignment.Status__c = 'Completed';
        if (failedRecords > 0) {
            workAssignment.Comment_Reply__c = 'No. of Records Failed: ' + failedRecords + '\n';
        }
        if (successRecords > 0) {
            workAssignment.Comment_Reply__c += 'No. of Records Succeeded: ' + successRecords;
        }
        //bug:4743 : changes starts
        WorkAssignmentTriggerHandler.updateCommentHistoryField = false;
        //bug:4743 : changes ends
        update workAssignment;
        WorkAssignmentTriggerHandler.updateCommentHistoryField = true; //Added part of bug #4743
        upsert listWorkAssignmentToUpsert;

        showButton = false;
        // Free up view state and don't show any record after processing
        recordMap.clear();
        displayPanel = true;
        return null;
    }

    public PageReference postDocumentAPI() {
        Map<String, Object> rawObj;
        Map<String, Object> rawObj1;
        //Failed CSV API
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        Blob fileBlob = Blob.valueOf(failed);

        if (FailedHasRecord) {
            parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Distressed Notes Failed.csv', 'Task');
            rawObj = (Map<String, Object>) JSON.deserializeUntyped(parsedResponse.response);
        }

        //Success CSV API
        DocumentAPIClientUtil.ParsedResponse parsedResponse1 = new DocumentAPIClientUtil.ParsedResponse();
        Blob fileBlobSuccess = Blob.valueOf(success);
        if (SuccessHasRecord) {
            parsedResponse1 = DocumentAPIClient.postDocument(fileBlobSuccess, 'Distressed Notes Success.csv', 'Task');
            rawObj1 = (Map<String, Object>) JSON.deserializeUntyped(parsedResponse1.response);
        }

        //Create Failed CSV Document Storage
        Document_Storage__c failedDocStorage = new Document_Storage__c();

        if (null != parsedResponse && rawObj != null && String.isnotBlank(String.valueOf(rawObj.get('docId')))) {
            failedDocStorage.Work_Assignment__c = workAssignmentID;

            failedDocStorage.Document_Name__c = 'Distressed Notes Failed.xls';
            failedDocStorage.Document_Extension__c = 'xls';
            failedDocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            failedDocStorage.Document_Type__C = 'Payment Processing File';
            failedDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            failedDocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            failedDocStorage.Uploaded_By__c = 'Internal User';
            failedDocStorage.Creator__c = UserInfo.getName();
            failedDocStorage.Document_Related_To__c = 'Task';
            failedDocStorage.File_Processed_By__c = UserInfo.getName();
            failedDocStorage.File_Processing_Date__c = Date.today();
            insert failedDocStorage;
        }
        Document_Storage__c SuccessDocStorage = new Document_Storage__c();
        if (null != parsedResponse1 && rawObj1 != null && String.isnotBlank(String.valueOf(rawObj1.get('docId')))) {
            SuccessDocStorage.Work_Assignment__c = workAssignmentID;
            SuccessDocStorage.Document_Name__c = 'Distressed Notes Success.xls';
            SuccessDocStorage.Document_Extension__c = 'xls';
            SuccessDocStorage.Document_ID__c = String.valueOf(rawObj1.get('docId'));
            SuccessDocStorage.Document_Type__C = 'Payment Processing File';
            SuccessDocStorage.Visibility__c = portalSettings.Document_Storage_Default_Visibility__c;
            SuccessDocStorage.Document_URL__c = String.valueOf(rawObj1.get('docUrl'));
            SuccessDocStorage.Uploaded_By__c = 'Internal User';
            SuccessDocStorage.Creator__c = UserInfo.getName();
            SuccessDocStorage.Document_Related_To__c = 'Task';
            SuccessDocStorage.File_Processed_By__c = UserInfo.getName();
            SuccessDocStorage.File_Processing_Date__c = Date.today();
            insert SuccessDocStorage;
        }
        ProductTriggerHandler.runProductAPI = false;
        update listDistressedNotesStaging;
        ProductTriggerHandler.runProductAPI = true;
        //ProductPaymentsTriggerHandler.runProductTrigger = true;
        Document_Storage__c docStorageToUpdate = new Document_Storage__c(ID = documentID, File_Processing_Status__c = 'Processed');
        update docStorageToUpdate;

        showButton = false;
        displayPanel = true;
        return null;
    }

    public class distressedNotesStagingWrapper {
        public Distressed_Note_Staging__c distStaging { get; set; }
        public boolean selected { get; set; }
        public boolean disabled { get; set; }
        public distressedNotesStagingWrapper(Distressed_Note_Staging__c cust, Boolean disable) {
            distStaging = cust;
            selected = false;
            disabled = disable;
        }
    }
}
