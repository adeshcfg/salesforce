/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to display Remittance Case Documents
 *  @author : A5E Consulting
 *  @date : 09/18/2018
 *  
 *************************************************************************************************/
public class RemittanceCaseInlineController{
    
    public List<RemAttachWrap> remAttachWrapList{get;set;}
    
    //Constructor
    public RemittanceCaseInlineController(ApexPages.StandardController controller) {
        
        String remittanceId = ApexPages.currentPage().getParameters().get('Id');
        
        remAttachWrapList = new List<RemAttachWrap>();
        
        Remittance__c paymentRemittance = [Select Id, Email_to_Case_Reference_Number__c 
                                                     from Remittance__c
                                                     where Id =: remittanceId];
                                                     
        String caseRefId = paymentRemittance.Email_to_Case_Reference_Number__c;
        
        if(!String.isBlank(caseRefId)){
            List<Attachment> remAttachList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId 
                                                    FROM Attachment 
                                                    WHERE ParentId in (select id from EMailMessage where relatedToid =: caseRefId) 
                                                    ORDER BY CreatedDate DESC];
                                                
            if(remAttachList.size() > 0 ){
                for(Attachment remAttach : remAttachList){
                    remAttachWrapList.add(new RemAttachWrap(remAttach));
                }
            }
        }
    }
    
    //Attachment Wrapper
    public class RemAttachWrap{
        
        public Attachment attach{get;set;}
        public dateTime dateCreated {get;set;}
        public dateTime datemodified {get;set;}
        public String strCreatedDate {get;set;}
        public String strlastModifiedDate {get;set;}
        
        public RemAttachWrap(Attachment attach){
            this.attach = attach;
            this.dateCreated = attach.CreatedDate;        
            this.dateModified = attach.LastModifiedDate;
            this.strCreatedDate = attach.CreatedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
            this.strlastModifiedDate = attach.LastModifiedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
            
        }
    }
}