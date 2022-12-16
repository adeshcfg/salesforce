/**************************************************************************************************
 *
 *  Class: AttachDocumenttoOtherRecords
 *
 *  @description : This is used to attach the Email message document to parent Insolvency or Insolvency records 
 *  @author : A5E Consulting
 *  @date : 06/05/2018
 
 *************************************************************************************************/
public class AttachDocumenttoOtherRecords{
    
    public List<Attachment> attList;
    public Case caseRec {get; set;}
    public List<AttachWrap> listAttachWrap{get;set;}
    public boolean showMessage{get;set;}
    public String displayMessage{get;set;}
    public String linkRecord{get;set;}
    public String differentPareser{get;set;}
    public boolean showParser{get;set;}
    public boolean communityUser{get;set;}
    public boolean showOnBIorSD{get; set;}
    Boolean isInsAccPresent;
    String publicGroupID;
    
    public AttachDocumenttoOtherRecords(ApexPages.StandardController controller) {
        showMessage = false;
        isInsAccPresent = false;
        String caseID = ApexPages.currentPage().getPArameters().get('Id');
        caseRec = [select id, Insolvency__c, Insolvency_Account__c, Assign_To__c, Insolvency_Assignment_Type__c, document_ID__c,
                   Assigned_To__c,Status,Priority, Subject, Description, Type, RecordTypeId, SuppliedEmail, ParentId
                   from case where id =: caseID];
                   
        publicGroupID = [select ID, name from Group where DeveloperName = 'Insolvency_CFG_Users'].id;
        if(caseRec.Insolvency__c <> null){
            List<Insolvency__c> insolRecord = [select id, name from Insolvency__c where id =: caseRec.Insolvency__c];
            linkRecord = insolRecord[0].name;
        } else if(caseRec.Insolvency_Account__c <> null){
            List<Insolvency_Account__c> insolAccRecord = [select id, name from Insolvency_Account__c where id =: caseRec.Insolvency_Account__c];
            linkRecord = insolAccRecord[0].name;
            isInsAccPresent = true;
        }else{
            showMessage = true;
            displayMessage = 'Link Insolevncy or Insolvency Account record to Assignment';
        }
        
        showOnBIorSD = false;
        if(caseRec.Insolvency_Assignment_Type__c == 'Business Insolvency' || caseRec.Insolvency_Assignment_Type__c == 'Secured Communications' || caseRec.Insolvency_Assignment_Type__c == 'Final'|| caseRec.Insolvency_Assignment_Type__c == 'Refund Request'){
           showOnBIorSD = true;
        }
        
        communityUser = isCommunityUser();
        getAllDocumentOptions();
        refreshAttList();    
    }
    
    public void refreshAttList(){
        //String caseID = ApexPages.currentPage().getPArameters().get('Id');
        showParser = false;
        attList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId FROM Attachment WHERE ParentId in (select id from EMailMessage where relatedToid =: caseRec.Id) ORDER BY CreatedDate DESC];
        listAttachWrap = new List<AttachWrap>();
        for(Attachment att:attList){
            AttachWrap awp = new AttachWrap(att);
            listAttachWrap.add(awp);
            showParser = true;
        }
        system.debug('===='+listAttachWrap);
    }
    
    public PageReference attachDocument(){
        
        system.debug('===='+listAttachWrap);
        Boolean checkedValues = false;
        Boolean selectDocType = false;
        List<AttachWrap> listWrap = new list<AttachWrap>();
        List<String> attachmentID = new List<String>();
        for(AttachWrap apW : listAttachWrap){
            
            if(apw.check == true){
                checkedValues = true;
                if(String.isBlank(apw.attach.description)){
                    selectDocType = true;
                }
                //if(String.isBlank(apw.description)){
                    listWrap.add(apw);
                    attachmentID.add(apw.strId);
                //}
            }
        }
        displayMessage = '';
        system.debug('list to be updated : '+ listWrap);
        system.debug('list to be updated ID : ' + attachmentID);
        list<attachment> listAttach = new List<attachment>();
        List<Insolvency__c> insolRecord = new List<Insolvency__c>();
        List<Insolvency_Account__c> insolAccRecord = new List<Insolvency_Account__c>();
        
        /*
        if(listWrap.size() == 0 && checkedValues == True){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Selected documents already been assigned to the ' + linkRecord );
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        */
        if(selectDocType == True){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Select document type for the all selected document(s)' );
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        if(listWrap.size() == 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Select the document');
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
        List<Attachment> attachmentsList = [select id, body from attachment where id in :attachmentID];
        Map<id, Attachment> attachmentMap = new Map<id, Attachment>();
        
        for(Attachment singleAttach : attachmentsList){
            attachmentMap.put(singleAttach.id, singleAttach);
        }
        
        if(caseRec.Insolvency__c <> null){
            insolRecord = [select id, name from Insolvency__c where id =: caseRec.Insolvency__c];
            
            for(AttachWrap apW : listWrap){
                Attachment at = apW.attach.clone();
                at.body = attachmentMap.get(apw.strid).body;
                at.parentID = insolRecord[0].id;
                listAttach.add(at);
                displayMessage += at.name + ', ';
            }
            
            displayMessage = displayMessage.removeEnd(', ');
            displayMessage += ' has been attached to ' + insolRecord[0].name;
            
        } else if(caseRec.Insolvency_Account__c <> null){
            insolAccRecord = [select id, name from Insolvency_Account__c where id =: caseRec.Insolvency_Account__c];
            
            for(AttachWrap apW : listWrap){
                Attachment at = apW.attach.clone();
                at.body = attachmentMap.get(apw.strid).body;
                at.parentID = insolAccRecord[0].id;
                listAttach.add(at);
                displayMessage += at.name + ', ';
            }
            
            displayMessage = displayMessage.removeEnd(', ');
            displayMessage += ' has been attached to ' + insolAccRecord[0].name;            
            
        }
        
        insert listAttach;
        
        for(Attachment attachRecord : attList){
            for(Attachment insertedAttach : listAttach){
                if(attachRecord.name == insertedAttach.name){
                    attachRecord.Description = insertedAttach.Description;
                }
            }
        }
        
        update attList;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.confirm, 'Document(s) are attached to ' + linkRecord );
        ApexPages.addMessage(myMsg);
        
        return null;
    }
    
    public List<SelectOption> getAllInsolvencyDocumentOptions() {
        Schema.DescribeFieldResult insolDocumenttype = Insolvency__c.Insolvency_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> insolDocTypeValues = insolDocumenttype.getPicklistValues();
    
        List<SelectOption> docOptions = new List<SelectOption>();
        for(schema.PicklistEntry values : insolDocTypeValues ){
            docOptions.add(new SelectOption(values.getLabel(), values.getValue()));
        }
        
        return docOptions;
    }
    
    public List<SelectOption> getAllDocumentOptions() {
        List<SelectOption> docOptions = new List<SelectOption>();
        if(isInsAccPresent == true){
            docOptions = getAllInsolvencyAccountDocumentOptions();
        }else{
            docOptions = getAllInsolvencyDocumentOptions();
        }
        docOptions.add(0, new SelectOption('','--None--'));
        /*
        docOptions.add(new SelectOption('','--None--'));
        docOptions.add(new SelectOption('Creditors Package','Creditors Package'));
        docOptions.add(new SelectOption('PoC Document','PoC Document'));  
        docOptions.add(new SelectOption('Letter of Release','Letter of Release'));   
        docOptions.add(new SelectOption('Demand Notice','Demand Notice'));   
        docOptions.add(new SelectOption('Proof of Security','Proof of Security'));       
        docOptions.add(new SelectOption('Other','Other'));
        */

        return docOptions;
    }
    
    public List<SelectOption> getAllInsolvencyAccountDocumentOptions(){
        Schema.DescribeFieldResult insolAccDocumenttype = Insolvency_Account__c.Insolvency_Account_Document_Type__c.getDescribe();
        List<Schema.PicklistEntry> insolAccDocTypeValues = insolAccDocumenttype.getPicklistValues();

        List<SelectOption> docOptions = new List<SelectOption>();
        for(schema.PicklistEntry values : insolAccDocTypeValues ){
            docOptions.add(new SelectOption(values.getLabel(), values.getValue()));
        }
        
        return docOptions;
    }
    
    public class AttachWrap{
        public boolean check{get;set;}
        public Attachment attach{get;set;}
        public string attachmentName{get;set;}
        public String description{get;set;}
        public datetime strCreatedDate{get;set;}
        public datetime strlastModifiedDate{get;set;}
        public String strID{get;set;}
        
        public attachWrap(Attachment attach){
            this.check = false;
            this.attach = attach.clone();
            this.attachmentName = attach.name;
            this.description = attach.description;
            //this.strCreatedDate = string.valueof(attach.CreatedDate);
            //this.strlastModifiedDate = string.valueof(attach.lastModifiedDate);
            this.strCreatedDate = attach.CreatedDate;
            this.strlastModifiedDate = attach.lastModifiedDate;
            this.strID = attach.id;
            
        }
    }
    
    public pageReference createNewAssignment(){
        
        //PageReference pgRef = new PageReference();
        List<Attachment> listAttach = new List<attachment>();
        Map<string, Attachment> mapAttach = new Map<String, Attachment>();
        List<String> attachmentID = new List<String>();
        List<Domain_Name_Parser__c> domPar = Domain_Name_Parser__c.getall().values();
        List<French_Domain_Name_Parser__c> domFrePar = French_Domain_Name_Parser__c.getall().values();
        
        for(attachment at : attList){
            mapAttach.put(at.name, at);
        }
        
        String emailAddress = caseRec.SuppliedEmail;
        String domainName = emailAddress.split('@').get(1);
        String caseSubject = caseRec.Subject;
        
        //Check domain name for duplicate estate number(Uberbase/bankex)
       
        if(!String.isBlank(caseSubject) && domainName == 'bankex.ca' ){
            
            // Fetch the Estate Number from Case Subject (BankEx)
            String filterEstateNumber = caseSubject.subStringAfter('\"').subStringBefore('\"');
            
            // fetch the same Estate Number for bankex
            List<Insolvency__c> insolvForBankEx = [SELECT Id, Name FROM Insolvency__c WHERE Name =:filterEstateNumber ];
            
            if(insolvForBankEx.size() >0){
                System.debug('insolvForBankEx---'+insolvForBankEx.size());
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info, 'Assignment is already created with same Estate Number for bankEx');
                ApexPages.addMessage(myMsg);
                return null;
            }
         
        }else if(!String.isBlank(caseSubject) && domainName == 'uberbase.com'){
            //Fetch the Estate Number from Case Subject (Uberbase)
            String filterEstateNumAfterOSB = caseSubject.subStringAfter('OSB:');
            
            // fetch the same Estate Number for Uberbase
            List<Insolvency__c> insolvForUberbase = [SELECT Id,Name FROM Insolvency__c WHERE Name =:filterEstateNumAfterOSB];
            
            if(insolvForUberbase.size() >0){ 
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info, 'Assignment is already created with same Estate Number for Uberbase');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        String strParserID = null;
        //String strParserId;
        if(differentPareser == 'English'){
        for(Domain_Name_Parser__c dnp : domPar){
            if(dnp.Domain_Name__c == domainName){
                strParserId = dnp.Parser_Name__c;
            }
        }
        }else if(differentPareser == 'French'){
            for(French_Domain_Name_Parser__c fnp : domFrePar){
                if(fnp.Domain_Name__c == domainName){
                    strParserId = fnp.Parser_Name__c;
                }
            }
        }
        
        if(strParserID == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info, 'This is not registered for any parser. Please process this manually');
            ApexPages.addMessage(myMsg);
        }
        
        for(AttachWrap apW : listAttachWrap){
            if(apw.check == true && (mapAttach.get(apw.attachmentName)).description != 'Creditors Package'){
                Attachment at = apW.attach.clone();
                listAttach.add(at);
                attachmentID.add(apw.strId);
            }
            if(apw.check == true && (mapAttach.get(apw.attachmentName)).description == 'Creditors Package'){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info, apw.attachmentName+ ' is already been processed. Please see the comments for additional information');
                ApexPages.addMessage(myMsg);
            }
            
        }
        
        if(listAttach.size() == 0){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select an attachment');
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
        List<Case> listCase = new List<Case>();
        List<ID> listId = new List<ID>();
        
        if(listAttach.size() == 1 && (caseRec.document_ID__c == '' || null == caseRec.document_ID__c)){
            
            listId.add(caseRec.id);
            SendToDocParser.sendDoc(listId, differentPareser);
            
            (mapAttach.get(listAttach[0].name)).description = 'Creditors Package';
            update (mapAttach.get(listAttach[0].name));
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.confirm, 'Document is sent to Parser');
            ApexPages.addMessage(myMsg);
            
            return null;
        }
        
        List<Attachment> attachmentsList = [select id, name, body from attachment where id in :attachmentID];
        Map<String, Attachment> attachmentMap = new Map<String, Attachment>();
        
        for(Attachment singleAttach : attachmentsList){
            attachmentMap.put(singleAttach.name, singleAttach);
        }
        
        for(Attachment att : listAttach){
            Case newCase = caseRec.clone();
            newCase.parentId = caseRec.id;
            if(!Test.isRunningTest()){
             //   newCase.ownerid = publicGroupID;
            }
            listCase.add(newCase);
        }
        
        caseRec.status = 'In Progress';
        
        insert listCase;
        update caserec;
        
        system.debug('list CAse : ' + listCase);
        
        for (Integer i=0; i < listCase.size();i++) {
            //Attachment newAttach = listAttach[i].clone();
            listAttach[i].parentId = listCase[i].id;
            listId.add(listCase[i].id);
            listAttach[i].body = attachmentMap.get(listAttach[i].name).body;
            (mapAttach.get(listAttach[i].name)).description = 'Creditors Package';
            
        }
        
        update mapAttach.Values();
        
        insert listAttach;
        system.debug('list Attachment : ' + listAttach);
        
        for(ID caseID : listId){
            List<ID> idList = new List<ID>();
            idList.add(caseID);
            SendToDocParser.sendDoc(idList, differentPareser);
        }
        
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.confirm, 'Document is sent to Parser');
        ApexPages.addMessage(myMsg);
        return null;
    }
    
    //Utility method that checks if logged user is Community user or not
    public static boolean isCommunityUser(){
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName.contains('Community User')){
            return true;
        }
        else{
            return false;
        }
    }
}