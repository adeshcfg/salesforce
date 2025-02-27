/**************************************************************************************************
 *
 *  Class:   InsolvencyDragNDropController
 *
 *  @description : This is used to provide drag and dropg functionality in insolvancy page 
 *  @author : A5E Consulting
 *  @date : 30-Dec-2017
 
 *************************************************************************************************/
global class InsolvencyDragNDropController{
    
    // Remote action to fetch record information
    @RemoteAction
    global static Insolvency__c getRecordInfo(Id recordid){
        return [SELECT RecordType.Name , Name FROM Insolvency__c WHERE Id=: recordid ];
    }
    
    public String description {set;get;}
    public List<Attachment> attList {set;get;}
    public Insolvency__c insAcc{set;get;}
    public Boolean isCommunityUser {set; get;}
    public String urlPathPrefix {get;set;}
    public Boolean isLightningCommunity {get;set;}
    public Boolean isCommunityReadOnlyUser {set; get;}
    public Boolean isGoeasyBankCommunityUser {set; get;}
    public Boolean isCanadianTireCommunityUser {set; get;}
    public Boolean isMoneyMartCommunityUser {set; get;}
       //Added for 5195
       public Boolean isScotiaBankCommunityUser {set; get;}
       public Boolean isSDABankCommunityUser {set; get;}
       public Boolean isFairstoneBankCommunityUser {set; get;}
       //Ends 5195
       public Id selectedAttId {set;get;}
    
    //7935
    public List<ContentVersion> conVerList {get; set;}
    public Id selectedConVerId { get; set; }
    public boolean isDelete {get; set;}
    public boolean updateDocumentType {get; set;}
    //Utility method to populate Attachment types
    public static List<SelectOption> getAllDocumentOptions() {
        Schema.DescribeFieldResult insolDocumenttype = Insolvency__c.Insolvency_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> insolDocTypeValues = insolDocumenttype.getPicklistValues();
    
        List<SelectOption> docOptions = new List<SelectOption>();
        for(schema.PicklistEntry values : insolDocTypeValues ){
            docOptions.add(new SelectOption(values.getLabel(), values.getValue()));
        }
        /*
        //docOptions.add(new SelectOption('Account Statement','Account Statement'));
        docOptions.add(new SelectOption('Creditors Package','Creditors Package'));
        docOptions.add(new SelectOption('PoC Document','PoC Document'));  
        docOptions.add(new SelectOption('Letter of Release','Letter of Release'));   
        docOptions.add(new SelectOption('Demand Notice','Demand Notice'));   
        docOptions.add(new SelectOption('Proof of Security','Proof of Security'));       
        docOptions.add(new SelectOption('Other','Other'));
        */
        return docOptions;   
    }
   
    //Utility method to populate Attachment types
    public static List<SelectOption> getDocumentOptions() {
        List<SelectOption> docOptions = new List<SelectOption>();
        docOptions.add(new SelectOption('','--None--'));
        docOptions.addAll(getAllDocumentOptions());
        return docOptions;
    }
    
     //Utility method to populate Attachment types
    public static List<SelectOption> getFileDocumentOptions() {
       List<SelectOption> docOptions = new List<SelectOption>();
        docOptions.addAll(getAllDocumentOptions());
        return docOptions;
    }
    // Fetch all attachments related to Insolvency
    public void refreshAttList(){
        attList = [SELECT Id, Name,Description,Owner.name, CreatedDate, LastModifiedDate FROM Attachment WHERE ParentId =: ApexPages.currentPage().getPArameters().get('Id') ORDER BY CreatedDate DESC];
        refreshConVerList();
        system.debug('===='+attList);
    }
    
    // Fetch all content documents related to Insolvency
    public void refreshConVerList(){
        Id insolvencyId = ApexPages.currentPage().getPArameters().get('Id');
        Set<Id> conDocIds = new Set<Id>();
        if(insolvencyId != null){
        for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId from ContentDocumentLink where LinkedEntityid =: insolvencyId]){
            conDocIds.add(conDocLink.ContentDocumentId);
        }
        if(conDocIds.size() > 0){
            conVerList = [SELECT id, ContentDocumentId, Title, Description, CreatedBy.Name, LastModifiedDate, CreatedDate FROM ContentVersion WHERE contentDocumentId in : conDocIds ORDER BY CreatedDate DESC];
        }        
    } 
    
    } 
    
    // To update document type of an attachment
    public void updateAtList(){
        if(attList.size()>0){
        update attList;
    }
        if(conVerList != null && conVerList.size()>0){
            update conVerList;
        }
    }
    
    // controller to load attachments
    public InsolvencyDragNDropController(ApexPages.StandardController controller) {
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        isDelete = true;
        updateDocumentType = true;
        if(profileName == 'QA'){
            isDelete = false;
            updateDocumentType = false;
        }
        insAcc = (Insolvency__c )controller.getRecord();
        refreshAttList();
        refreshConVerList();
        
        //Checking if community user
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        if(isCommunityUser) {
            InsolvencyAccntNoteCntrl.getCommunityUrl();
            isLightningCommunity = InsolvencyAccntNoteCntrl.isLightningCommunity;
            if(isLightningCommunity) {
                urlPathPrefix = InsolvencyAccntNoteCntrl.isProduction ? '/' : '/' + InsolvencyAccntNoteCntrl.urlPathPrefix + '/';
            }
        }
        isGoeasyBankCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(UserInfo.getProfileId());
         //Added for 5195
         isScotiaBankCommunityUser = InsolvencyUtil.isScotiaBankCommunityUser(UserInfo.getProfileId());
         isSDABankCommunityUser = InsolvencyUtil.isSDABankCommunityUser(UserInfo.getProfileId());
         isFairstoneBankCommunityUser = InsolvencyUtil.isFairstoneBankCommunityUser(UserInfo.getProfileId());
         isCanadianTireCommunityUser = InsolvencyUtil.isCanadianTireCommunityUser(UserInfo.getProfileId());
         isMoneyMartCommunityUser = InsolvencyUtil.isMoneyMartCommunityUser(UserInfo.getProfileId());
         //Ends 5195
          //Check whether current user is readonly profile or not
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser();      
    }
    
    //Delete attachments
    public void deleteAttachment(){
        try {
            String attId = selectedAttId;
            String conId = selectedConVerId;
            if(attId != null && attId != '' && String.isNotBlank(attId)){
                for (Attachment att : attList) {
                    if (att.Id == selectedAttId)
                    delete att;
            }
            refreshAttList();
            }else{
                for (ContentVersion conVer : conVerList) {
                    if (conVer.Id == selectedConVerId){
                        ContentDocument conDoc = [select id from ContentDocument where Id =: conVer.ContentDocumentId];
                        delete conDoc;
                    }
                }
                refreshConVerList();
            }
            
            
        } catch (Exception ex) {
            refreshAttList();
            refreshConVerList();
        }
    }
    
    //Utility method to return user time zone offset
    public Double offset{
        get
        {
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    } 
}