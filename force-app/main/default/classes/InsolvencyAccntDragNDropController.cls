/**************************************************************************************************
 *
 *  Class:   InsolvencyAccntDragNDropController
 *
 *  @description : This is used to provide drag and drop functionality in insolvancy page 
 *  @author : A5E Consulting
 *  @date : 30-Dec-2017
 
 *************************************************************************************************/
global class InsolvencyAccntDragNDropController {
    // Remote action to fetch record information
    @RemoteAction
    global static Insolvency_Account__c getRecordInfo(Id recordid) {
        return [SELECT RecordType.Name, Name FROM Insolvency_Account__c WHERE Id = :recordid];
    }
    public String description { get; set; }
    public List<Attachment> attList { get; set; }
    public List<Attachment> insolvAttList { get; set; }
    public List<wrapperClass> downloadFile { get; set; }
    public String urlPathPrefix { get; set; }
    public Boolean isLightningCommunity { get; set; }
    public Insolvency_Account__c insAcc { get; set; }
    public Id selectedAttId { get; set; }
    public Boolean isCommunityReadOnlyUser { get; set; }
    public Boolean isGoeasyBankCommunityUser { get; set; }
    //Added for 5195
    public Boolean isScotiaBankCommunityUser { get; set; }
    public Boolean isSDABankCommunityUser { get; set; }
    public Boolean isFairstoneBankCommunityUser { get; set; }
    public Boolean isCanadianTireCommunityUser { get; set; }
    //Ends 5195
    public Boolean isCommunityUser { get; set; }
    public Boolean isEasyFinanacial { get; set; }
	public Boolean isMoneyMartCommunityUser { get; set; }
    public Boolean isFlexitiCommunityUser { get; set; }
    //7935
    public List<ContentVersion> conVerList {get; set;}
    public List<ContentVersion> insolvConVerList { get; set; }
    public Id selectedConVerId { get; set; }
    public String urlValue {get; set;}
    
    public static List<SelectOption> getAllDocumentOptions() {
        Schema.DescribeFieldResult insolAccDocumenttype = Insolvency_Account__c.Insolvency_Account_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> insolAccDocTypeValues = insolAccDocumenttype.getPicklistValues();

        List<SelectOption> docOptions = new List<SelectOption>();
        for (schema.PicklistEntry values : insolAccDocTypeValues) {
            docOptions.add(new SelectOption(values.getLabel(), values.getValue()));
        }
        /*
        docOptions.add(new SelectOption('Account Statement','Account Statement'));
        docOptions.add(new SelectOption('PoC Document','PoC Document'));  
        docOptions.add(new SelectOption('Letter of Release','Letter of Release'));   
        docOptions.add(new SelectOption('Demand Notice','Demand Notice'));   
        docOptions.add(new SelectOption('Proof of Security','Proof of Security'));       
        docOptions.add(new SelectOption('Other','Other'));
        docOptions.add(new SelectOption('LoR Request Document','LoR Request Document'));
        //docOptions.add(new SelectOption('Servicer Notice','Servicer Notice'));
        docOptions.add(new SelectOption('Form 149 – Notice requiring person to prove claim','Form 149 – Notice requiring person to prove claim'));
        docOptions.add(new SelectOption('Form 76 – Notice to filing of proof of security','Form 76 – Notice to filing of proof of security'));
        docOptions.add(new SelectOption('Form 77 – Notice of disallowance of claim','Form 77 – Notice of disallowance of claim'));
        docOptions.add(new SelectOption('Stay of proceeding','Stay of proceeding'));
        */
        return docOptions;
    }

    //Utility method to populate Attachment types
    public static List<SelectOption> getDocumentOptions() {
        List<SelectOption> docOptions = new List<SelectOption>();
        docOptions.add(new SelectOption('', '--None--'));
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
    public void refreshAttList() {
        attList = [
            SELECT Id, Name, Description, createdbyid, owner.Name, CreatedDate, LastModifiedDate, ParentID
            FROM Attachment
            WHERE ParentId = :ApexPages.currentPage().getPArameters().get('Id')
            ORDER BY CreatedDate DESC
        ];
        refreshConVerList();
    }
    
    // Fetch all content documents related to Insolvency
    public void refreshConVerList(){
        Id insolvencyAccId = ApexPages.currentPage().getPArameters().get('Id');
        Set<Id> conDocIds = new Set<Id>();
        for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId from ContentDocumentLink where LinkedEntityid =: insolvencyAccId]){
            conDocIds.add(conDocLink.ContentDocumentId);
        }
        if(conDocIds.size() > 0){
            conVerList = [SELECT id, ContentDocumentId, Title, Description, CreatedBy.Name, LastModifiedDate, CreatedDate  FROM ContentVersion WHERE contentDocumentId in : conDocIds ORDER BY CreatedDate DESC];
        }else{
            conVerList = new List<ContentVersion>();
        }
        
		System.debug('conVerList:: '+conVerList);        
    }

    // To update document type of an attachment
    public void updateAtList() {
        if(attList.size()>0){
        update attList;
    }
        if(conVerList.size()>0){
            update conVerList;
        }
    }

    /**
     * @description : Method to get content version id uploaded and return
     * @author adesh.ikhar@canaccede.com | 06-12-2024
     * @param selectedDocId
     * @param insAccId
     * @return String
     **/
    @RemoteAction
    global static String getDocumentId(String selectedDocId, String insAccId) {
        List<Document_Storage__c> docStorageList = [
            SELECT Id, Name, Document_Type__c, Document_Name__c, Document_URL__c, createdBy.name, LastModifiedDate, CreatedDate
            FROM Document_Storage__c
            WHERE Insolvency_Account__c = :insAccId AND Document_Name__c = :selectedDocId
            LIMIT 1
        ];
        String conVerId = DocumentAPIClient.getContentVersionIdForAzureFile(docStorageList[0].Document_URL__c, docStorageList[0].Document_Type__c);
        return conVerId;
    }

    // controller to load attachments
    public InsolvencyAccntDragNDropController(ApexPages.StandardController controller) {
        insAcc = (Insolvency_Account__c) controller.getRecord();
        urlValue = URL.getSalesforceBaseUrl().toExternalForm();
        insAcc = [SELECT Insolvency__c, RecordType.Name FROM Insolvency_Account__c WHERE Id = :insAcc.Id];
        insolvAttList = new List<Attachment>();
        insolvAttList = [
            SELECT Id, Name, owner.name, Description, CreatedDate, LastModifiedDate, ParentID
            FROM Attachment
            WHERE ParentID = :insAcc.Insolvency__c AND Description = 'Creditors Package'
        ];
        Set<Id> conDocIds = new Set<Id>();
        if(insAcc.Insolvency__c != null){
            for(ContentDocumentLink conDocLink : [SELECT Id, ContentDocumentId from ContentDocumentLink where LinkedEntityid =: insAcc.Insolvency__c]){
                conDocIds.add(conDocLink.ContentDocumentId);
            }
        }
        if(conDocIds.size() > 0){
            insolvConVerList = [SELECT id, ContentDocumentId, Title, Description, CreatedBy.Name, LastModifiedDate, CreatedDate, owner.name FROM ContentVersion WHERE contentDocumentId in : conDocIds ORDER BY CreatedDate DESC];
        }else{
            insolvConVerList = new List<ContentVersion>();
        }

        List<Document_Storage__c> docStorageList = new List<Document_Storage__c>();
        docStorageList = [
            SELECT Id, Name, Document_Type__c, Document_Name__c, Document_URL__c, createdBy.name, LastModifiedDate, CreatedDate
            FROM Document_Storage__c
            WHERE Insolvency_Account__c = :insAcc.Id
        ];

        wrapperClass wrpclass = new wrapperClass();
        downloadFile = new List<wrapperClass>();
        String filePath = '';

        for (Document_Storage__c docStorageData : docStorageList) {
            wrpclass = new wrapperClass();
            if (docStorageData.Document_Type__c <> null) {
                wrpclass.documetType = 'Account Statement';
            }
            if (docStorageData.Document_Name__c <> null) {
                wrpclass.documetName = docStorageData.Document_Name__c;
            }
            if (docStorageData.CreatedDate <> null) {
                wrpclass.createdDate = docStorageData.CreatedDate;
            }
            if (docStorageData.createdBy.name <> null) {
                wrpclass.createdBy = docStorageData.createdBy.name;
            }
            if (docStorageData.LastModifiedDate <> null) {
                wrpclass.LastModifiedDate = docStorageData.LastModifiedDate;
            }
            downloadFile.add(wrpclass);
        }

        refreshAttList();
        refreshConVerList();

        //Checking if community user
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        isLightningCommunity = false;
        if (isCommunityUser) {
            InsolvencyAccntNoteCntrl.getCommunityUrl();
            isLightningCommunity = InsolvencyAccntNoteCntrl.isLightningCommunity;
            if (isLightningCommunity) {
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
        isFlexitiCommunityUser = InsolvencyUtil.isFlexitiCommunityUser(UserInfo.getProfileId());
        //Ends 5195
        //Checking if read only community user
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser();
    }

    //Utility method to return user time zone offset
    public Double offset {
        get {
            TimeZone tz = UserInfo.getTimeZone();
            //Milliseconds to Day
            return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
        }
    }

    //Delete Attchments
    public void deleteAttachment() {
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
        }
    }

    public class wrapperClass {
        public string documetType { get; set; }
        public string documetName { get; set; }
        public DateTime createdDate { get; set; }
        public string createdBy { get; set; }
        public DateTime LastModifiedDate { get; set; }
    }
}