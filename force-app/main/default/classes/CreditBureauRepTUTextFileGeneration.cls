public class CreditBureauRepTUTextFileGeneration implements Queueable {
    private string batchNum;

    public CreditBureauRepTUTextFileGeneration(String bachNumber) {
        batchNum = bachNumber;
    }
    public void execute(QueueableContext context) {
        String csvString = '';

        try {
            for (MetroFlatFileData__c prodData : [
                SELECT RowData1__c
                FROM MetroFlatFileData__c
                WHERE Bureau_Type__c = 'TransUnion' AND Product_Type__c = 'Distressed Account' AND Batch_Number__c = :batchNum AND CreatedDate = TODAY
                ORDER BY Sort_Order__c ASC
            ]) {
                String recordStr = prodData.RowData1__c;
                if (recordStr != null && recordStr != '') {
                    csvString += recordStr.rightPad(460) + '\n';
                }
            }

            csvString.removeEnd('\n');
            Blob fileBlob = Blob.valueOf(csvString);

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName('creditBureauRep.txt');
            efa.setBody(fileBlob);

            String userName = UserInfo.getUserName();
            User activeUser;
            activeUser = [SELECT Email FROM User WHERE Username = :userName LIMIT 1];
            system.debug('activeUser' + activeUser);
            String userEmail = activeUser.Email;
            system.debug('userEmail' + userEmail);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = userEmail.split(':', 0);
            system.debug('toAddresses' + toAddresses);
            email.setSubject('Credit Bureau Rep Generation');
            email.setToAddresses(toAddresses);
            email.setPlainTextBody('Generating text file for credit bureau .');
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{ efa });
            email.setSaveAsActivity(true);
            if (!Test.isRunningTest()) {
                Messaging.SendEmailResult[] r = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
            }
            csvString = '';
        } catch (Exception e) {
            system.debug('e.getStackTraceString()' + e.getStackTraceString());
            throw e;
        }
    }
}
