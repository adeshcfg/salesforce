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
        List<Case> listCases = new List<case>();
        for (EmailMessage em : emailMessageNew) {
            String createdDate = String.valueOf(em.createdDate);
            String systemDate = String.valueOf(System.now());
            if (em.relatedToId <> null) {
                newEmailMessageIds.add(em.Id);
                if (createdDate == systemDate || test.isRunningTest()) {
                    listID.add(em.relatedToId);
                }
            }
        }
        if (!listID.isEmpty()) {
            listCases = [
                SELECT id, subject, status, New_Email_on_Case__c, recordType.DeveloperName
                FROM Case
                WHERE id IN :listID AND Reason != 'Duplicate'
            ];
        }
        List<Case> listCaseUpdate = new List<Case>();
        if (!listCases.isEmpty()) {
            for (EmailMessage em : emailMessageNew) {
                if (em.relatedToId <> null) {
                    for (Case listCase : listCases) {
                        if (em.relatedToId == listCase.id) {
                            listCase.New_Email_on_Case__c = true;
                            system.debug('CAse Status : ' + listCase.status);
                            if (
                                listCase.recordType.DeveloperName != 'Remittance' &&
                                listCase.recordType.DeveloperName != 'CCS_Dividend' &&
                                (listCase.status == 'Completed' ||
                                listCase.status == 'Closed')
                            ) {
                                listCase.Is_Email_to_Case__c = true;
                                listCase.status = 'New';
                            }
                            listCaseUpdate.add(listCase);
                        }
                    }
                }
            }
        }
        if (!System.isBatch() && !newEmailMessageIds.isEmpty()) {
            flagDuplicateCases(newEmailMessageIds);
        }

        if (!listCaseUpdate.isEmpty())
            update listCaseUpdate;
    }
	
    //Before Insert of Email Message
    public static void handleBeforeInsert(List<EmailMessage> emailMessageNew) {
        Set<Id> setOfRelatedToIds = new Set<Id>();
        Map<Id, List<EmailMessage>> mapOfRelatedToIdAndEmailMessage = new Map<Id, List<EmailMessage>>();
        for(EmailMessage em : emailMessageNew){
            String relatedToId = em.RelatedToId;
            System.debug('relatedToId:: '+relatedToId);
            if(relatedToId.startsWith('a11')){
                setOfRelatedToIds.add(em.RelatedToId);
                if(mapOfRelatedToIdAndEmailMessage.containsKey(em.RelatedToId)){
                    mapOfRelatedToIdAndEmailMessage.get(em.RelatedToId).add(em);
                }else{
                    mapOfRelatedToIdAndEmailMessage.put(em.RelatedToId, new List<EmailMessage>{em});
                }                
            }
        }
        System.debug('mapOfRelatedToIdAndEmailMessage:: '+mapOfRelatedToIdAndEmailMessage);
        List<Insolvency_Account__c> listOfInsolvencyAccounts = [SELECT Id FROM Insolvency_Account__c WHERE Id in: setOfRelatedToIds
                                                               AND (Client_Identifier__c = 'Scotia Bank'
                                                                   OR Client_Identifier__c = 'Canaccede'
                                                                   OR Client_Identifier__c = 'SPL'
                                                                   OR Client_Identifier__c = 'SDA')];
        List<EmailMessage> emailMessageToUpdate = new List<EmailMessage>();
        for(Insolvency_Account__c insolAcc : listOfInsolvencyAccounts){
            emailMessageToUpdate.addAll(mapOfRelatedToIdAndEmailMessage.get(insolAcc.Id));
        }
        for(EmailMessage em : emailMessageToUpdate){
            em.IsExternallyVisible = true;
        }
    }
    public static void handleAfterUpdate(List<EmailMessage> emailMessageNew, Map<Id, EmailMessage> oldMap) {
        List<ID> listID = new List<ID>();
        for (EmailMessage em : emailMessageNew) {
            if (em.relatedToId <> null) {
                listID.add(em.ParentID);
            }
        }

        List<Case> listCases = [SELECT id, subject, status, New_Email_on_Case__c FROM Case WHERE id IN :listID];
        List<Case> listCaseUpdate = new List<Case>();

        for (EmailMessage em : emailMessageNew) {
            EmailMessage eMsg = oldMap.get(em.id);
            if (em.relatedToId <> null && eMsg.status == 'New' && em.status == 'Read') {
                for (Case listCase : listCases) {
                    if (em.relatedToId == listCase.id) {
                        listCase.New_Email_on_Case__c = false;
                        listCaseUpdate.add(listCase);
                    }
                }
            }
        }

        update listCaseUpdate;
    }

    public static void handleBeforeDelete(List<EmailMessage> oldList) {
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];

        if ('System Administrator' != profileInfo.Name) {
            for (EmailMessage emMsg : oldList) {
                if (emMsg.ParentId != null) {
                    if (emMsg.relatedToID.getSObjectType() == Case.sObjectType) {
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
        Map<String, Case> duplicateCasesMap = new Map<String, Case>();
        Map<String, String> uniqueKeyCaseIdMap = new Map<String, String>();
        Set<String> fromAddresses = new Set<String>();
        Set<String> attachmentNames = new Set<String>();
        // Query newly created email messages and related attachments, also get parent case info
        for (EmailMessage newMessage : [
            SELECT FromAddress, ParentId, CreatedDate, (SELECT Name FROM Attachments WHERE ContentType = 'application/pdf' OR ContentType = 'text/xml')
            FROM EmailMessage
            WHERE Id IN :newEmailMessageIds AND HasAttachment = TRUE AND Parent.Is_Email_to_Case__c = TRUE
        ]) {
            if (newMessage.Attachments.size() == 1) {
                Attachment attach = newMessage.Attachments[0];
                uniqueKeyCaseIdMap.put(newMessage.FromAddress + attach.Name, newMessage.ParentId);
                fromAddresses.add(newMessage.FromAddress);
                attachmentNames.add(attach.Name);
                newCaseCreationTime = newMessage.CreatedDate.addMinutes(-Integer.valueOf(config.Case_duplicate_time__c));
            }
        }
        // Check for duplicate open cases created within given time window which match the subject and attachment file name
        for (EmailMessage oldMatchingEmailMessage : [
            SELECT
                FromAddress,
                ParentId,
                (SELECT Name FROM Attachments WHERE (ContentType = 'application/pdf' OR ContentType = 'text/xml') AND Name IN :attachmentNames)
            FROM EmailMessage
            WHERE
                FromAddress IN :fromAddresses
                AND HasAttachment = TRUE
                AND Parent.Is_Email_to_Case__c = TRUE
                AND CreatedDate > :newCaseCreationTime
                AND Id NOT IN :newEmailMessageIds
                AND Parent.Status != 'Closed'
        ]) {
            if (oldMatchingEmailMessage.Attachments.size() == 1) {
                Attachment attach = oldMatchingEmailMessage.Attachments[0];
                // If we have a duplicate case open, mark new case as closed and reason as duplicate
                if (uniqueKeyCaseIdMap.containsKey(oldMatchingEmailMessage.FromAddress + attach.Name)) {
                    String caseId = uniqueKeyCaseIdMap.get(oldMatchingEmailMessage.FromAddress + attach.Name);
                    duplicateCasesMap.put(caseId, new Case(Id = caseId, Status = 'Closed', Reason = 'Duplicate'));
                }
            }
        }
        if (!duplicateCasesMap.values().isEmpty()) {
            Database.update(duplicateCasesMap.values());
        }
    }
}