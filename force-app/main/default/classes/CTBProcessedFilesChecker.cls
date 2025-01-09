/**
 * @description       : Scheduler to check for unprocessed files
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 01-09-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class CTBProcessedFilesChecker implements Schedulable, Database.AllowsCallouts {
    public void execute(SchedulableContext sc) {
        List<String> filteredFileList = new List<String>();
        // Call API to get the list of files
        List<String> fileNameList = CTBGetFileApiQueueable.getFileList(CTBGetFileApiQueueable.API_TYPE_PARAMETER, CTBGetFileApiQueueable.FILE_TYPE_PARAMETER);
        if (!fileNameList.isEmpty()) {
            filteredFileList.addAll(fileNameList);
            for (String fileName : fileNameList) {
                // Only include files which match the naming convention
                if (!fileName.split('\\.').contains('drnbkruptupd')) {
                    filteredFileList.remove(filteredFileList.indexOf(fileName));
                }
            }
            for (Document_Storage__c doc : [
                SELECT Id, Document_Name__c
                FROM Document_Storage__c
                WHERE Document_Name__c IN :filteredFileList AND CreatedDate = TODAY
            ]) {
                // Check if we already have document storage record for any file
                if (filteredFileList.contains(doc.Document_Name__c)) {
                    // Remove the file name if we already have a document storage record
                    filteredFileList.remove(filteredFileList.indexOf(doc.Document_Name__c));
                }
            }
        }
        // Mail if any file is not processed for the day
        if (!filteredFileList.isEmpty()) {
            CTBFileValidationUtility.sendEmail(
                'Account files processing status : Files not processed',
                'Processing failed for files - ' + String.join(filteredFileList, ', '),
                System.Label.CTB_File_Processing_Emails
            );
        }
    }
}
