global class ExportDuplicatePurchaseAccBatch implements Database.Batchable<Insolvency_Account__c>{
    
    private string header = 'Salesforce Id, Name, Account_Number_Without_Space__c, Asset_Status__c, Purchase_Date__c, Bank_Name__c \n';
    private string finalstr = header ;
    string recordString = '';
    string searchQuery;
    string csvname;
    blob csvBlob;
    Id userId;
    
    private string selectedBankName;
    case caseObject;
    Attachment attachObject;
    
    List<String> duplicateNameList = new List<String>();
    list<string> ignoreAcctNameList = new list<string>();
    list<Insolvency_account__c> accList = new list<Insolvency_account__c>();
    
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    global Iterable<Insolvency_account__c> start(Database.BatchableContext BC){
        //duplicate check not to consider account names from custom setting
        string acctNameCS = config.Ignore_Account_Number_for_DuplicateCheck__c;
        ignoreAcctNameList = acctNameCS.split(',');
    
        //case object to atttach csv attachment
         caseObject = new Case(subject = 'Test Case Attachment',RecordTypeId = '012f1000000LJ8g');
         CaseTriggerHandler.runCaseTrigger = false;
         insert caseObject;
         CaseTriggerHandler.runCaseTrigger = true;
         caseObject = [select Id from case where subject = 'Test Case Attachment' limit 1];
         
         //add Not Purchased Duplicate Account.csv attachment to case object
         csvBlob = Blob.valueOf(finalstr);
         csvname = 'Not Purchased Duplicate Account '+system.Today().format();
        
         Attachment createAttachment = new Attachment(Body = csvBlob,
                                      Name = csvname,
                                      parentId = caseObject.Id,
                                      Contenttype = '.csv');
         insert createAttachment;
         
         //get accounts to create csv file
         accList = [Select Id, Name, Account_Number_Without_Space__c, Asset_Status__c, Purchase_Date__c, Client_Identifier__c FROM Insolvency_Account__c where Asset_Status__c IN ('Purchased', 'Bulk Purchased') AND Account_Number_Without_Space__c NOT IN: ignoreAcctNameList ];
         
         //get Account_Number_Without_Space__c list to search duplicate
         for(Insolvency_account__c acc : accList){
             duplicateNameList.add(acc.Account_Number_Without_Space__c);
         }
         
         return accList = [select Id, Name, Account_Number_Without_Space__c, Asset_Status__c, Purchase_Date__c, Client_Identifier__c  
                            FROM Insolvency_Account__c where Account_Number_Without_Space__c IN: duplicateNameList AND Asset_Status__c NOT IN ('Purchased', 'Bulk Purchased') ];
         
    }
    
    global void execute(Database.BatchableContext BC, List<Insolvency_Account__c> accList){
    
        //create csv file from string for Duplicate not Purchased Accounts
        for(Insolvency_Account__c a: accList)
        {
            recordString += '"'+a.id+'","'+a.Name+'","'+a.Account_Number_Without_Space__c+'","'+a.Asset_Status__c+'","'+a.Purchase_Date__c +'","'+ a.Client_Identifier__c +'"\n';
        }
        finalstr = recordString;
                
        attachObject = [select Name, Body from Attachment where name Like '%Duplicate Account%' limit 1];
        string attachBody = attachObject.Body.toString() + finalstr;
        attachObject.Body = Blob.valueOf(attachBody);
        update attachObject;
    }
    
    public void finish(Database.BatchableContext bc) {
        //get the Case and Attachment record
        attachObject = [select Id, Name, Body from Attachment where name Like '%Duplicate Account%' limit 1];
        caseObject = [select Id from case where subject = 'Test Case Attachment' limit 1];
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        //sent csv file attachment in mail
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(attachObject.Name);
        csvAttc.setBody(attachObject.Body);
        
        //get logged in user email address
        userId = userInfo.getUserId();
        user userEmail = [select Email from user where Id =: userId];
        
        String[] toAddresses = new list<string> {userEmail.Email};
        String subject ='Account CSV';
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('Duplicate Account CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        
        
        //delete case and attachment at the end
        delete attachObject;
        delete caseObject;
        System.debug('Batch Apex program successfully executed..');
    }
}