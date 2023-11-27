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
        List<ID> listID = new List<ID>();
        for(EmailMessage em : emailMessageNew){
            if(em.relatedToId <> null){
                listID.add(em.relatedToId);
            }
        }
        
        List<Case> listCases = [select id, subject, status, New_Email_on_Case__c, recordType.DeveloperName 
                                from Case where id in :listID];
        List<Case> listCaseUpdate = new List<Case>();
        
        for(EmailMessage em : emailMessageNew){
            if(em.relatedToId <> null){
                for(Case listCase : listCases){
                    if(em.relatedToId == listCase.id){
                        listCase.New_Email_on_Case__c = true;
                        system.debug('CAse Status : ' + listCase.status);
                        if(listCase.recordType.DeveloperName == 'Remittance' ||
                           listCase.recordType.DeveloperName == 'CCS_Dividend' ){
                           //Do nothing
                        }else if(listCase.status == 'Completed'|| listCase.status == 'Closed'){
                            if (em.status == 'New') { // Check the Email Message status
                            listCase.Is_Email_to_Case__c = True;
                            listCase.status = 'New';
                            }
                        }
                        listCaseUpdate.add(listCase);
                    }
                }
            }
        }
        
        update listCaseUpdate;
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
}