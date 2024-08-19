/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for EmailMessage object 
*  @author : A5E Consulting
*  @date : 10/24/2016

*************************************************************************************************/

public class EmailMessageTriggerHandler {
    
    public static boolean runEmailMessageTrigger = true;
    
    //After new Case is created
    public static void handleAfterInsert(List<EmailMessage> emailMessageNew) {
        List<String> newEmailMessageIds = new List<String>();
        List<ID> listID = new List<ID>();
        List<Case> listCases=new list<case>();
        for(EmailMessage em : emailMessageNew){
            String createdDate = String.valueOf(em.createdDate);
            String systemDate = String.valueOf(System.now());
            if(em.relatedToId <> null){
                newEmailMessageIds.add(em.Id);
                if(createdDate == systemDate || test.isRunningTest()) {
                    listID.add(em.relatedToId);
                }
            }
        }
        if(!listID.isEmpty()){
            listCases = [select id, subject, status, New_Email_on_Case__c, recordType.DeveloperName 
                         from Case where id in :listID and Reason != 'Duplicate'];
        }
        List<Case> listCaseUpdate = new List<Case>();
        if(!listCases.isEmpty()){
            for(EmailMessage em : emailMessageNew){
                if(em.relatedToId <> null){
                    for(Case listCase : listCases){
                        if(em.relatedToId == listCase.id){
                            listCase.New_Email_on_Case__c = true;
                            system.debug('CAse Status : ' + listCase.status);
                            if(listCase.recordType.DeveloperName != 'Remittance' && listCase.recordType.DeveloperName != 'CCS_Dividend' && (listCase.status == 'Completed'|| listCase.status == 'Closed')){
                                listCase.Is_Email_to_Case__c = True;
                                listCase.status = 'New';                            
                            }
                            listCaseUpdate.add(listCase);
                        }
                    }
                }
            }
        }
        if(!newEmailMessageIds.isEmpty()) {
            flagDuplicateCases(newEmailMessageIds);
        }
        
        if(!listCaseUpdate.isEmpty()) update listCaseUpdate;
    }
    
    public static void handleAfterUpdate(List<EmailMessage> emailMessageNew, Map<Id, EmailMessage> oldMap) { 
        List<ID> listID = new List<ID>();
        for(EmailMessage em : emailMessageNew){
            if(em.relatedToId <> null){
                listID.add(em.ParentID);
            }
        }
        
        List<Case> listCases = [select id, subject, status, New_Email_on_Case__c from Case where id in :listID];
        List<Case> listCaseUpdate = new List<Case>();
        
        for(EmailMessage em : emailMessageNew){
            EmailMessage eMsg = oldMap.get(em.id);
            if(em.relatedToId <> null && eMsg.status == 'New' && em.status == 'Read'){
                for(Case listCase : listCases){
                    if(em.relatedToId == listCase.id){
                        listCase.New_Email_on_Case__c = false;
                        listCaseUpdate.add(listCase);
                    }
                }
            }
        }
        
        update listCaseUpdate;
    }
    
    public static void handleBeforeDelete(List<EmailMessage> oldList) { 
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() limit 1];
        
        if('System Administrator' != profileInfo.Name){
            for(EmailMessage emMsg : oldList){
                if (emMsg.ParentId != null){
                    if(emMsg.relatedToID.getSObjectType() == Case.sObjectType){
                        emMsg.relatedToID.addError('You can not delete an Email Message from Case, Product and Funding Batch Records');
                    }
                }
            }
        }
    }
    
    /**
    * @description : Method to flag duplicate cases created within defined time frame
    * @author adesh.ikhar@canaccede.com | 08-19-2024 
    * @param newEmailMessageIds 
    **/
    @future
    public static void flagDuplicateCases(List<String> newEmailMessageIds) {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        Datetime newCaseCreationTime = System.now();
        List<Case> duplicateCases = new List<Case>();
        Map<String, String> uniqueKeyCaseIdMap = new Map<String, String>();
        Set<String> fromAddresses = new Set<String>();
        Set<String> attachmentNames = new Set<String>();
        // Query newly created email messages and related attachments, also get parent case info
        for(EmailMessage newMessage : [SELECT FromAddress, ParentId, CreatedDate, (SELECT Name FROM Attachments Where ContentType = 'application/pdf' OR ContentType = 'text/xml') FROM EmailMessage WHERE Id IN :newEmailMessageIds AND HasAttachment = true AND Parent.Is_Email_to_Case__c = true]) {
            if(newMessage.Attachments.size() == 1) {
                Attachment attach = newMessage.Attachments[0];
                uniqueKeyCaseIdMap.put(newMessage.FromAddress + attach.Name, newMessage.ParentId);
                fromAddresses.add(newMessage.FromAddress);
                attachmentNames.add(attach.Name);
                newCaseCreationTime = newMessage.CreatedDate.addMinutes(-Integer.valueOf(config.Case_duplicate_time__c));
            }
        }
        // Check for duplicate open cases created within given time window which match the subject and attachment file name
        for(EmailMessage oldMatchingEmailMessage : [SELECT FromAddress, ParentId, (SELECT Name FROM Attachments Where (ContentType = 'application/pdf' OR ContentType = 'text/xml') AND Name In : attachmentNames) FROM EmailMessage WHERE FromAddress IN :fromAddresses AND HasAttachment = true AND Parent.Is_Email_to_Case__c = true AND CreatedDate > :newCaseCreationTime AND Id NOT IN :newEmailMessageIds AND Parent.Status != 'Closed']) {
            if(oldMatchingEmailMessage.Attachments.size() == 1) {
                Attachment attach = oldMatchingEmailMessage.Attachments[0];
                // If we have a duplicate case open, mark new case as closed and reason as duplicate
                if(uniqueKeyCaseIdMap.containsKey(oldMatchingEmailMessage.FromAddress + attach.Name)) {
                    duplicateCases.add(new Case(Id = uniqueKeyCaseIdMap.get(oldMatchingEmailMessage.FromAddress + attach.Name), Status = 'Closed', Reason = 'Duplicate'));
                }
            }
        }
        if(!duplicateCases.isEmpty()) {
            Database.update(duplicateCases);
        }
    }
}