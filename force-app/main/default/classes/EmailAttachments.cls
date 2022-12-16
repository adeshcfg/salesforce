/**************************************************************************************************
 *
 *  Class: EmailAttachments
 *
 *  @description : This is used to display attachemnts from Emails
 *  @author : A5E Consulting
 *  @date : 8th April 2019
 
 *************************************************************************************************/
public class EmailAttachments{

    public List<Attachment> attList;
    public List<AttachWrap> listAttachWrap{get;set;}
    
    public EmailAttachments(ApexPages.StandardController controller) {
        
        String caseID = ApexPages.currentPage().getPArameters().get('Id');
        listAttachWrap = new List<AttachWrap>();
        
        attList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId 
                    FROM Attachment 
                    WHERE ParentId in (select id from EMailMessage where relatedToid =: caseID ) 
                    ORDER BY CreatedDate DESC];
        
        for(Attachment att:attList){
            AttachWrap awp = new AttachWrap(att);
            listAttachWrap.add(awp);
            
        }
        
    }
    
    public class AttachWrap{
        public boolean check{get;set;}
        public Attachment attach{get;set;}
        public string attachmentName{get;set;}
        public String description{get;set;}
        public dateTime dateCreated {get;set;}
        public dateTime datemodified {get;set;}
        public String strCreatedDate {get;set;}
        public String strlastModifiedDate {get;set;}
        public String strID{get;set;}
       
        
        public attachWrap(Attachment attach){
            this.check = false;
            this.attach = attach.clone();
            this.attachmentName = attach.name;
            this.description = attach.description;
            this.dateCreated = attach.CreatedDate;        
            this.dateModified = attach.LastModifiedDate;
            this.strCreatedDate = attach.CreatedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
            this.strlastModifiedDate = attach.LastModifiedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
            this.strID = attach.id;
            
        }
    }
}