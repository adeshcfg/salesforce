public class CreditBureauRepTUTextFileGeneration implements Queueable {
    public void execute(QueueableContext context) {
        String csvString = '';
        
        try{
        for(MetroFlatFileData__c prodData:[SELECT RowData1__c   
                    FROM MetroFlatFileData__c
                    WHERE Bureau_Type__c = 'TransUnion' AND Product_Type__c = 'Distressed Account' 
                    AND CreatedDate = TODAY  ORDER BY Sort_Order__c ASC]){
            String recordStr = prodData.RowData1__c ;
            if(recordStr!=null && recordStr!='' && recordStr.length()==460){
            csvString +=recordStr+'\n';
            }
        }

        csvString.removeEnd('\n');
        Blob fileBlob = Blob.valueOf(csvString);
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('creditBureauRep.txt');
        efa.setBody(fileBlob);
        
        String userName = UserInfo.getUserName();
        User activeUser;
        activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail =activeUser.Email;
         
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = userEmail.split(':', 0);
        email.setSubject( 'Credit Bureau Rep Generation');
        email.setToAddresses( toAddresses );
        email.setPlainTextBody( 'Generating text file for credit bureau .');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        email.setSaveAsActivity(true);
        Messaging.SendEmailResult [] r =
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        csvString='';
        }catch(Exception e){
            system.debug('e.getStackTraceString()'+e.getStackTraceString());
            throw e;
        }
    }
    
    
}