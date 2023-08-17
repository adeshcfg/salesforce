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
    public Boolean isGoeasyBankCommunityUser {set; get;}
    public Boolean isCommunityReadOnlyUser {set; get;}
    public Id selectedAttId {set;get;}
    
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
        attList = [SELECT Id, Name,Description, CreatedDate, LastModifiedDate FROM Attachment WHERE ParentId =: ApexPages.currentPage().getPArameters().get('Id') ORDER BY CreatedDate DESC];
        system.debug('===='+attList);
    }
    
    // To update document type of an attachment
    public void updateAtList(){
        update attList;
    }
    
    // controller to load attachments
    public InsolvencyDragNDropController(ApexPages.StandardController controller) {
        insAcc = (Insolvency__c )controller.getRecord();
        refreshAttList();
        
        //Checking if community user
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        isGoeasyBankCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(UserInfo.getProfileId());
        //Check whether current user is readonly profile or not
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser();      
    }
    
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