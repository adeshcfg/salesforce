public class BatchConvertAttachmentsToConVersion implements Database.Batchable<sObject> {
    public Set<Id> setOfInsolvAccIds = new Set<Id>();
    public Set<Id> setOfInsolvAccIdsToProcess = new Set<Id>();
    public Map<Id, List<EmailMessage>> mapOfInsolvAccIdAndEmailMessages;
    public Map<Id, List<Attachment>> mapOfInsolvAccIdAndAttachments;
    public Map<Id, EmailMessage> mapOfIdAndEmailMessage;
    public Map<Id, List<ContentVersion>> mapOfInsolvAccIdAndConVersions;
    public Map<Id, List<ContentVersion>> mapOfEmailMessageIdAndConVersions;
    public List<ContentVersion> listOfConVersion = new List<ContentVersion>();
    public List<ContentDocumentLink> listOfConDocLink = new List<ContentDocumentLink>();
    
    public BatchConvertAttachmentsToConVersion(Set<Id> setOfInsolvAccIdsToProcess){
        this.setOfInsolvAccIdsToProcess = setOfInsolvAccIdsToProcess;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id FROM Insolvency_Account__c WHERE Id in : setOfInsolvAccIdsToProcess');
    }
    public void execute(Database.BatchableContext bc, List<Insolvency_Account__c> listOfInsolAccts){
        mapOfInsolvAccIdAndEmailMessages = new Map<Id, List<EmailMessage>>();
        mapOfInsolvAccIdAndAttachments = new Map<Id, List<Attachment>>();
        Set<Id> setofAttachmentIds = new Set<Id>();
        List<Attachment> listOfAttachmentToDelete = new List<Attachment>();
        mapOfIdAndEmailMessage = new Map<Id, EmailMessage>([SELECT Id, RelatedToId, (SELECT Id, Name, Description FROM Attachments) FROM EmailMessage WHERE RelatedToId in : setOfInsolvAccIdsToProcess]);
        Map<Id, Attachment> mapOfAttachIdwithAttach = new Map<Id, Attachment>([SELECT Id, Body FROM Attachment WHERE ParentId =: mapOfIdAndEmailMessage.keyset()]);
        
        List<Attachment> listOfInsolAccAttachToConvert = new List<Attachment>();
        
        if(mapOfIdAndEmailMessage != null){
            for(EmailMessage eMessage : mapOfIdAndEmailMessage.values()){
                List<Attachment> childAttachs = eMessage.Attachments;
                if(childAttachs.size() > 0){
                    if(mapOfInsolvAccIdAndEmailMessages.containsKey(eMessage.RelatedToId)){
                        List<EmailMessage> listOfEmailMessage = mapOfInsolvAccIdAndEmailMessages.get(eMessage.RelatedToId);
                        listOfEmailMessage.add(eMessage);
                        mapOfInsolvAccIdAndEmailMessages.put(eMessage.RelatedToId, listOfEmailMessage);
                    }else{
                        List<EmailMessage> listOfEmailMessage = new List<EmailMessage>();
                        listOfEmailMessage.add(eMessage);
                        mapOfInsolvAccIdAndEmailMessages.put(eMessage.RelatedToId, listOfEmailMessage);
                    }
                    if(mapOfInsolvAccIdAndAttachments != null){
                        if(mapOfInsolvAccIdAndAttachments.containsKey(eMessage.Id)){
                            List<Attachment> listOfAttachment = mapOfInsolvAccIdAndAttachments.get(eMessage.Id);
                            listOfAttachment.addAll(eMessage.Attachments);
                            mapOfInsolvAccIdAndAttachments.put(eMessage.Id, listOfAttachment);
                        }else{
                            List<Attachment> listOfAttachment = new List<Attachment>();
                            listOfAttachment.addAll(eMessage.Attachments);
                            mapOfInsolvAccIdAndAttachments.put(eMessage.Id, listOfAttachment);
                        }                   
                    }
                }
            }
        }
        Map<String,Attachment> mapOfTitleDescWithAttach = new Map<String,Attachment>();
        Map<String,List<EmailMessage>> duplicateAttach = new Map<String,List<EmailMessage>>();
        for(Insolvency_Account__c InsolAcc: listOfInsolAccts){
            if(mapOfInsolvAccIdAndEmailMessages.containskey(InsolAcc.Id)){
                for(EmailMessage eMessage : mapOfInsolvAccIdAndEmailMessages.get(InsolAcc.Id)){
                    if(mapOfInsolvAccIdAndAttachments.containskey(eMessage.Id)){
                        for(Attachment attachment : mapOfInsolvAccIdAndAttachments.get(eMessage.Id)){
                            if(duplicateAttach.containskey(attachment.Name+attachment.description)){
                                System.debug('Duplicate Found: '+attachment.Name+attachment.description);
                                List<EmailMessage> listOfEmailMessage = duplicateAttach.get(attachment.Name+attachment.description);
                                listOfEmailMessage.add(eMessage);
                                duplicateAttach.put(attachment.Name+attachment.description,listOfEmailMessage);
                            }else{
                                List<EmailMessage> listOfEmailMessage = new List<EmailMessage>();
                                listOfEmailMessage.add(eMessage);
                                duplicateAttach.put(attachment.Name+attachment.description,listOfEmailMessage);
                                mapOfTitleDescWithAttach.put(attachment.Name+attachment.description,attachment);
                                ContentVersion conVer = new ContentVersion();
                                conVer.Title = attachment.Name;
                                conVer.PathOnClient = attachment.Name;
                                conVer.IsMajorVersion = true;
                                conVer.Description = attachment.description;
                                conVer.VersionData = mapOfAttachIdwithAttach.get(attachment.Id).Body;
                                conVer.EmailMessageId__c = eMessage.Id;
                                conVer.InsolvencyAccountId__c = InsolAcc.Id;
                                listOfConVersion.add(conVer);
                            }
                            System.debug('Adding '+attachment.Id+ ' Title: '+attachment.Name);
                            listOfAttachmentToDelete.add(attachment);
                        }
                    }
                }
            }
        }
        
        if(listOfConVersion.size() > 0){
            insert listOfConVersion;
        }
        Set<Id> setOfConVerIds = new Set<Id>();
        for(ContentVersion conVer : listOfConVersion){
            setOfConVerIds.add(conVer.Id);
        }
        List<ContentVersion> insertedConVersionList = [SELECT Id, Title, Description, ContentDocumentId, EmailMessageId__c, InsolvencyAccountId__c FROM ContentVersion WHERE Id in : setOfConVerIds];
        List<ContentDocumentLink> conDocLinkToInsert = new List<ContentDocumentLink>();
        Set<String> pairs = new Set<String>();
        for(ContentVersion conVer : insertedConVersionList){
            ContentDocumentLink emailMessageConDocLink = new ContentDocumentLink();
            ContentDocumentLink insolvAccConDocLink = new ContentDocumentLink();
            
            if(duplicateAttach.containskey(conVer.Title+conVer.Description)){
                for(EmailMessage eMessage : duplicateAttach.get(conVer.Title+conVer.Description)){
                    pairs.add(conVer.ContentDocumentId+'_'+eMessage.Id);
                    emailMessageConDocLink = new ContentDocumentLink();
                    emailMessageConDocLink.ContentDocumentId = conVer.ContentDocumentId;
                    emailMessageConDocLink.LinkedEntityId = eMessage.Id;
                    emailMessageConDocLink.ShareType = 'V';
                    emailMessageConDocLink.Visibility = 'AllUsers';
                    conDocLinkToInsert.add(emailMessageConDocLink);
            	}
            }else{
                pairs.add(conVer.ContentDocumentId+'_'+conVer.EmailMessageId__c);
                emailMessageConDocLink.ContentDocumentId = conVer.ContentDocumentId;
                emailMessageConDocLink.LinkedEntityId = conVer.EmailMessageId__c;
                emailMessageConDocLink.ShareType = 'V';
                emailMessageConDocLink.Visibility = 'AllUsers';
                conDocLinkToInsert.add(emailMessageConDocLink);
            }
            pairs.add(conVer.ContentDocumentId+'_'+conVer.InsolvencyAccountId__c);
            insolvAccConDocLink.ContentDocumentId = conVer.ContentDocumentId;
            insolvAccConDocLink.LinkedEntityId = conVer.InsolvencyAccountId__c;
            insolvAccConDocLink.ShareType = 'V';
            insolvAccConDocLink.Visibility = 'AllUsers';           
            conDocLinkToInsert.add(insolvAccConDocLink);
        }
        if(conDocLinkToInsert.size() > 0){
            insert conDocLinkToInsert;
        }
        if(listOfAttachmentToDelete.size() > 0){
            delete listOfAttachmentToDelete;
        }
        
        List<Attachment> listOfInsolAccAttach = [SELECT Id, Name, Description, Body, ParentId FROM Attachment WHERE ParentId =: setOfInsolvAccIdsToProcess];
        listOfConVersion = new List<ContentVersion>();
        listOfAttachmentToDelete = new List<Attachment>();
        for(Attachment attachment : listOfInsolAccAttach){
            if(mapOfTitleDescWithAttach.containskey(attachment.Name+attachment.description)){
                listOfAttachmentToDelete.add(attachment);
            }else{
                ContentVersion conVer = new ContentVersion();
                conVer.Title = attachment.Name;
                conVer.PathOnClient = attachment.Name;
                conVer.IsMajorVersion = true;
                conVer.Description = attachment.description;
                conVer.VersionData = attachment.Body;
                conVer.InsolvencyAccountId__c = attachment.ParentId;
                listOfConVersion.add(conVer);
                listOfAttachmentToDelete.add(attachment);
            }
        }
        if(listOfConVersion.size() > 0){
            insert listOfConVersion;
        }
        setOfConVerIds = new Set<Id>();
        for(ContentVersion conVer : listOfConVersion){
            setOfConVerIds.add(conVer.Id);
        }
        insertedConVersionList = [SELECT Id, ContentDocumentId, EmailMessageId__c, InsolvencyAccountId__c FROM ContentVersion WHERE Id in : setOfConVerIds];
        
        conDocLinkToInsert = new List<ContentDocumentLink>();
        for(ContentVersion conVer : insertedConVersionList){
            ContentDocumentLink insolvAccConDocLink = new ContentDocumentLink();
            insolvAccConDocLink.ContentDocumentId = conVer.ContentDocumentId;
            insolvAccConDocLink.LinkedEntityId = conVer.InsolvencyAccountId__c;
            insolvAccConDocLink.ShareType = 'V';
            insolvAccConDocLink.Visibility = 'AllUsers';           
            conDocLinkToInsert.add(insolvAccConDocLink);
        }
        if(conDocLinkToInsert.size() > 0){
            insert conDocLinkToInsert;
        }
        if(listOfAttachmentToDelete.size() > 0){
            delete listOfAttachmentToDelete;
        }
    }
    public void finish(Database.BatchableContext bc){
        
    }
}