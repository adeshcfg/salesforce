public class CreditBureauRepTUTextFileGeneration implements Queueable, Database.AllowsCallouts {
    private string contentVersionId = '';

    public CreditBureauRepTUTextFileGeneration(String batchNumber, String bureauType, String productType) {
    }

    public CreditBureauRepTUTextFileGeneration(String contentVersionId) {
        this.contentVersionId = contentVersionId;
    }

    public void execute(QueueableContext context) {
        String csvString = '';
        try {
            // Get content version record for the csv file
            ContentVersion con = [
                SELECT Id, FileExtension, ContentDocumentId, VersionData, CreatedById, TextPreview, Title, VersionNumber
                FROM ContentVersion
                WHERE Id = :contentVersionId
            ];
            // Create document in azure for the csv
            DocumentAPIClientUtil.ParsedResponse parsedResponse = DocumentAPIClient.postDocument2(
                con.Id,
                EncodingUtil.urlEncode(con.Title + '.' + con.FileExtension, 'UTF-8'),
                'Task'
            );
            // Query work assignment record to link the document storage record with
            List<Work_Assignment__c> cimlWS = [
                SELECT Id
                FROM Work_Assignment__c
                WHERE RecordType.DeveloperName = 'Credit_Bureau_Reporting_Files'
                ORDER BY CreatedDate
                LIMIT 1
            ];
            // Create document storage record for the uploaded csv
            Map<String, Object> rawObj = (Map<String, Object>) JSON.deserializeUntyped(parsedResponse.response);
            Document_Storage__c docStorage = new Document_Storage__c();
            docStorage.Work_Assignment__c = cimlWS[0].Id;
            docStorage.Document_Name__c = con.Title + '.' + con.FileExtension;
            docStorage.Document_Extension__c = 'txt';
            docStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            docStorage.Document_Type__C = 'Metro2 File';
            docStorage.Visibility__c = 'CFG Only';
            docStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            docStorage.Uploaded_By__c = 'Internal User';
            docStorage.Creator__c = UserInfo.getName();
            docStorage.Document_Related_To__c = 'Task';
            insert docStorage;
            delete new ContentDocument(Id = con.ContentDocumentId);
        } catch (Exception e) {
            system.debug('e.getStackTraceString()' + e.getStackTraceString());
            throw e;
        }
    }

    /**
     * @description : Method to form csv and create content version record for it
     * @author adesh.ikhar@canaccede.com | 04-23-2024
     * @param batchNumber
     * @param bureauType
     * @param productType
     * @return String
     **/
    public static String getContentVersion(String batchNumber, String bureauType, String productType) {
        String csvString = '';
        String fileNameSuffix = bureauType == 'TransUnion' && productType == 'Distressed Account' ? 'CIML' : 'CCS';
        Map<String, Integer> mapFileTypeRowLength = new Map<String, Integer>{
            'TransUnion_Distressed Account' => 460,
            'TransUnion_CCS Account' => 426,
            'Equifax_CCS Account' => 1364
        };
        Integer rowPadding = mapFileTypeRowLength.get(bureauType + '_' + productType);
        for (MetroFlatFileData__c prodData : [
            SELECT RowData1__c
            FROM MetroFlatFileData__c
            WHERE Bureau_Type__c = :bureauType AND Product_Type__c = :productType AND Batch_Number__c = :batchNumber AND CreatedDate = TODAY
            ORDER BY Sort_Order__c ASC
        ]) {
            String recordStr = prodData.RowData1__c;
            if (recordStr != null && recordStr != '') {
                csvString += recordStr.rightPad(rowPadding) + '\r\n';
            }
        }
        Blob fileBlob = Blob.valueOf(csvString);
        Date todayDate = Date.today();
        String fileName = bureauType + '_' + String.valueOf(Datetime.now().format('MM')) + todayDate.year().toString() + '_' + fileNameSuffix + '.txt';
        ContentVersion contentVersion = new ContentVersion(Title = fileName.substringBefore('.'), PathOnClient = fileName, VersionData = fileBlob);
        insert contentVersion;
        csvString = '';
        return contentVersion.Id;
    }
}
