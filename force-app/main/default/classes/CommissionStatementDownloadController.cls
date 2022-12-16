public class CommissionStatementDownloadController {

     @AuraEnabled  
    public static List<Document_Storage__c> getFiles(String recordId){
        system.debug('entered getFiles');
        system.debug('recordId: '+recordId);
        System.debug('@BASE_URL'+URL.getSalesforceBaseUrl().toExternalForm());
        
        // For all other user simply return the file list
        return [SELECT ID, 
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
                Placement_Agency__c =: recordId AND Document_Type__c = 'Commission Statement'
                ORDER BY CreatedDate DESC ];        
    }
    @AuraEnabled  
    public static DocumentDetails previewDocument(String documentId) {
        system.debug('String documentId '+documentId);
        DocumentDetails docDetails = DocumentAPIClient.getDocumentInfo(documentId);
        //system.debug('docDetails: '+docDetails);
        if(docDetails.document != NULL){
            docDetails.fileString = EncodingUtil.base64Encode(docDetails.document);    
        }
        else{
            docDetails.fileString ='';
        }
        system.debug('docDetails.fileString: '+docDetails.fileString); 
        return docDetails;       
    } 
}