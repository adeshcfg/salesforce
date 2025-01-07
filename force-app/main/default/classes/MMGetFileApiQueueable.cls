/**
 * @description       : Queueable class to get file list and store other API callout methods for MM incoming file
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-07-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class MMGetFileApiQueueable implements Queueable, Database.AllowsCallouts {
    public static final String API_TYPE_PARAMETER = 'incoming_decrypted';

    public void execute(QueueableContext context) {
        List<String> filteredFileList = new List<String>();
        // Call API to get the list of files
        List<String> fileNameList = CTBGetFileApiQueueable.getFileList(API_TYPE_PARAMETER, CTBGetFileApiQueueable.FILE_TYPE_PARAMETER);
        if (!fileNameList.isEmpty()) {
            filteredFileList.addAll(fileNameList);
            for (Document_Storage__c doc : [SELECT Id, Document_Name__c FROM Document_Storage__c WHERE Document_Name__c IN :filteredFileList]) {
                // Check if we already have document storage record for any file
                if (filteredFileList.contains(doc.Document_Name__c)) {
                    // Remove the file name if we already have a document storage record
                    filteredFileList.remove(filteredFileList.indexOf(doc.Document_Name__c));
                }
            }
        }
        // Enqueue the file processing class
        if (!filteredFileList.isEmpty() && !Test.isRunningTest()) {
            System.enqueueJob(new MMFileProcessingQueueable(filteredFileList, System.Label.CTB_Insolvency_Account));
        } else {
            CTBFileValidationUtility.sendEmail(
                'Account files processing status : No files processed',
                'No files were found on the server to process or all the files are already processed for today',
                System.Label.CTB_File_Processing_Emails
            );
        }
    }
}
