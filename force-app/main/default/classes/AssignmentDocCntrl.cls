/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to upload and display all Assignment Documents for
 * 				  internal and external users
 *  @author : A5E Consulting
 *  @date : 08/31/2018
 *  
 *************************************************************************************************/
public class AssignmentDocCntrl{
    
    public String assignmentId{get;set;}
    public Attachment attach{get;set;}
    public String documentType{get;set;}
    public boolean communityUser{get;set;}
    public boolean fileUploadSuccess{get;set;}
    public boolean initialLoad{get;set;}
    public boolean showOnBIorSD{get;set;}
    public Id selectedAttId {set;get;}
    public Boolean isGoeasyBankCommunityUser {set; get;}
    public Boolean isLightningCommunity {get;set;}
    public String urlPathPrefix {get;set;}
    public List<Attachment> attList {set;get;}
    //public boolean showOnSD = false;
    
    public boolean communityQAUser{get;set;}
    
    //Constants
    public static final String dateFormat = 'MM/dd/yyyy'; 
    case assignObj = new case();

    //Constructor
    public AssignmentDocCntrl(ApexPages.StandardController controller) { 
        
        //Insolvency Account Id
        assignmentId = ApexPages.currentPage().getParameters().get('id');
        
        assignObj = [Select Id, Insolvency_Assignment_Type__c from case where id =: assignmentId limit 1];
        
        showOnBIorSD = false;
        /*if(assignObj.Insolvency_Assignment_Type__c == 'Business Insolvency' || assignObj.Insolvency_Assignment_Type__c == 'Secured Communications' || assignObj.Insolvency_Assignment_Type__c == 'Final'|| assignObj.Insolvency_Assignment_Type__c == 'Refund Request'){
            showOnBIorSD = true;
        }*/
        
        //Initialize Attchment
        attach = new Attachment();
        
        communityUser = isCommunityUser();
        communityQAUser = isCommunityQAUser();
        //Checking if community user
        if(communityUser) {
            InsolvencyAccntNoteCntrl.getCommunityUrl();
            isLightningCommunity = InsolvencyAccntNoteCntrl.isLightningCommunity;
            if(isLightningCommunity) {
                urlPathPrefix = InsolvencyAccntNoteCntrl.isProduction ? '/' : '/' + InsolvencyAccntNoteCntrl.urlPathPrefix + '/';
            }
        }
        initialLoad = true;
        isGoeasyBankCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(UserInfo.getProfileId());      
    }   
    
    //Upload Attachment
    public PageReference upload() {
        
        Boolean okToUpload = true;         
        
        if(String.isBlank(attach.name)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a document to upload'));
            okToUpload = false;
        }
        
        if(okToUpload) {
          
          fileUploadSuccess = true; 
          initialLoad = false;   
        
            try {
                //Insert Attachment
                attach.ParentId = assignmentId;
                attach.Description = assignObj.Insolvency_Assignment_Type__c;
                attach.IsPrivate = false;
                insert attach;            
                    
                //Reset attachment
                attach = new Attachment();
                documentType = '';        
            } 
            catch (Exception ex) {
              
              fileUploadSuccess = false; 
              initialLoad = false;
              
              /*
                //Create Error record
                Insolvency_Error__c inslErr = new Insolvency_Error__c();
                inslErr.Insolvency_Account__c = insolvencyAccntId;
                inslErr.Action__c = 'Document Upload';
                inslErr.Error__c = 'Exception: ' + ex.getTypeName();
                inslErr.Error__c += '\nMessage: ' + ex.getMessage();
                inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();
                
                try{
                    insert inslErr;
                }
                catch(Exception inslErrEx){
                    system.debug('inslErr Message :'+inslErrEx.getMEssage());
                }
                */
            }
        }     
        
        return null;
    }
    
    //Attachment Wrapper
    public class AttachmentWrpper{
        public Attachment attch {get;set;}
        public String attchLink {get;set;}
        public dateTime dateCreated {get;set;}
        public dateTime datemodified {get;set;}
        public String strCreatedDate {get;set;}
        public String strModifiedDate {get;set;}
        
        public AttachmentWrpper(Attachment attch, String baseUrl){
            this.attch = attch;
            this.attchLink = baseUrl + '/' + attch.Id;
            this.dateCreated = attch.createdDate;        
            this.dateModified = attch.LastModifiedDate;
            //Added on 02.03.21 STRM#659296 - Ticket#150 - Assignment Attachment time stamp incorrect
            this.strCreatedDate = attch.CreatedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
            this.strModifiedDate = attch.LastModifiedDate.format('MMMM d\',\' yyyy hh:mm a', UserInfo.getTimeZone().toString());
        }       
    }    
    
    //Populate and return Attachment Wrappers
    public List<AttachmentWrpper> getInslAttachmentWrappers(){
        
        //Construct Base URL
        String baseUrl = getBaseUrl(isCommunityUser());

        List<AttachmentWrpper> attachmentWrappers = new List<AttachmentWrpper>();
        List<Attachment> attachments = [Select Id, Name, Description, createdDate, LastModifiedDate
                                        From Attachment
                                        where ParentId =:assignmentId
                                        order by createdDate desc 
                                        ];
               
        for(Attachment attchment : attachments){
            attachmentWrappers.add(new AttachmentWrpper(attchment, baseUrl));
        }
        
        return attachmentWrappers;

    }
    
    //Utility method that checks if logged user is Community user or not
    private static boolean isCommunityUser(){
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName.contains('Community User')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Utility method that checks if logged user is Community user or not
    private static boolean isCommunityQAUser(){
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'QA Community User Readonly'){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Utility method that constructs community url
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        System.debug('comm.siteUrl' + comm.siteUrl);
        return comm.siteUrl;
    } 
    
    //Utility method that constructs base url
    public string getBaseUrl(Boolean communityUser){
        String baseUrl;
        if(communityUser){
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        return baseUrl;
    }
    /*
    //Utility method to return user time zone offset
    public Double offset{
        get
        {
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    } 
*/
    
     //Delete attachments
    public void deleteAttachment(){
        try{
            for(Attachment att :  attList){
                if(att.Id == selectedAttId )
                    delete att;
            }
            refreshAttList();
        }catch(Exception ex){
            refreshAttList();
        }
    }
    
    public void refreshAttList(){
        attList = [SELECT Id, Name,Description, CreatedDate, LastModifiedDate FROM Attachment WHERE ParentId =: ApexPages.currentPage().getPArameters().get('Id') ORDER BY CreatedDate DESC];
        system.debug('===='+attList);
    }
}