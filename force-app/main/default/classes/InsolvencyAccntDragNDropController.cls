/**************************************************************************************************
 *
 *  Class:   InsolvencyAccntDragNDropController
 *
 *  @description : This is used to provide drag and drop functionality in insolvancy page 
 *  @author : A5E Consulting
 *  @date : 30-Dec-2017
 
 *************************************************************************************************/
 global class InsolvencyAccntDragNDropController{
    
    // Remote action to fetch record information    
    @RemoteAction
    global static Insolvency_Account__c getRecordInfo(Id recordid){
        return [SELECT RecordType.Name , Name FROM Insolvency_Account__c WHERE Id=: recordid ];
    }
    
    public String description {set;get;}
    public List<Attachment> attList {set;get;}
    public List<Attachment> insolvAttList {set;get;}
    
    public Insolvency_Account__c insAcc{set;get;}
    public Id selectedAttId {set;get;}
    public Boolean isCommunityReadOnlyUser {set; get;}
    public Boolean isCommunityUser {set; get;}
    
    public static List<SelectOption> getAllDocumentOptions(){
        Schema.DescribeFieldResult insolAccDocumenttype = Insolvency_Account__c.Insolvency_Account_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> insolAccDocTypeValues = insolAccDocumenttype.getPicklistValues();

        List<SelectOption> docOptions = new List<SelectOption>();
        for(schema.PicklistEntry values : insolAccDocTypeValues ){
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
        attList = [SELECT Id, Name,Description, CreatedDate, LastModifiedDate, ParentID FROM Attachment WHERE ParentId =: ApexPages.currentPage().getPArameters().get('Id') ORDER BY CreatedDate DESC];
        system.debug('---'+attList);
    }
    
    // To update document type of an attachment
    public void updateAtList(){
        update attList;
    }
    
    // controller to load attachments
    public InsolvencyAccntDragNDropController(ApexPages.StandardController controller) {
        insAcc = (Insolvency_Account__c )controller.getRecord();
        insAcc = [SELECT Insolvency__c FROM Insolvency_Account__c WHERE Id =: insAcc.Id];
        
        insolvAttList = new List<Attachment>();
        insolvAttList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, ParentID FROM Attachment WHERE ParentID =: insAcc.Insolvency__c AND Description='Creditors Package'];
        
        refreshAttList();

        //Checking if community user
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        
        //Checking if read only community user
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser(); 
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
    
    //Delete Attchments
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
}