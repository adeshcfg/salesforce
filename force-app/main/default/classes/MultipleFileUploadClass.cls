/**************************************************************************************************
*
*  Class:   
*
*  @description : This ControllerClass is used for displaying Document Names and document type list.     
*  @author : A5E Consulting
*  @date : 05/04/2022

*************************************************************************************************/
public class MultipleFileUploadClass {
    public static List<ContentDocumentLink> ConDocLnk{set;get;}
    public static List<ContentDocument> ConDoc{set;get;}
    public Attachment_Document_Type__c attachlistsetting {set;get;}
    public static Map<Id, String> selectedDocType = new Map<Id, String>();
    public static Map<Id, String> selectedDocVisibility = new Map<Id, String>();
    public static List<Id> CDIdList = new List<Id>();
    public static List<Document_Storage__c> listCon1 =new List<Document_Storage__c>();
    //public static Map<String,Object> rawObj;
    public static Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
    
    @AuraEnabled
    public  static  Map<id,ContentDocument> attachmap {set;get;} 
    public MultipleFileUploadClass(){    
    }
    @AuraEnabled
    public static List<AttachWrapper> getAttachment(Id parentId){
        //system.debug('Parent ID' + parentID);
        Set<Id> newset = new Set<ID>{parentId};
        ConDocLnk=[SELECT id,LinkedEntityId,ContentDocumentId,Visibility,ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :newset];
         // Make a List of ContentDocument IDs
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : ConDocLnk) 
        {      
            nextCDL.Visibility='AllUsers'; // File visibility is to All Users
              CDIdList.add(nextCDL.ContentDocumentId); 
        }   
        //DateTime timeNow = System.now(); // Get the time now createdDate >:X30MinutesAgo
        //DateTime X30MinutesAgo = timeNow.addMinutes(-30);
        ConDoc = [SELECT Id, Title, FileType,Description,CreatedDate,LastModifiedDate FROM ContentDocument WHERE Id IN :CDIdList AND Title like '%@FileUpload%' order by createdDate desc];
        //system.debug('CDS are' + ConDoc);
        List<AttachWrapper> listWrapper = new List<AttachWrapper>();
        attachmap  = new Map<id,ContentDocument>();
        for(ContentDocument attach : ConDoc){
            AttachWrapper wrapRecord = new AttachWrapper(attach);
            listWrapper.add(wrapRecord);
        }   
        return listWrapper;       
    }//fetching parent record    
    public class AttachWrapper{
        
        @AuraEnabled public string attachmentName{set;get;}
        @AuraEnabled public String docType{set;get;}
        @AuraEnabled public String month{set;get;}
        //@AuraEnabled public ContentDocument attachRecord {set;get;}
        @AuraEnabled public Id attachID{set;get;}      
        @AuraEnabled public string attachmentCreateddate{set;get;}
        @AuraEnabled public string attachmentLastmodifieddate{set;get;}
        
        public Attachwrapper(ContentDocument attach)
        {
            attachID = attach.id;
            //system.debug('attachID:::'+attachID);
            attachmentName = attach.title.substringBefore('@');
            //attachRecord = attach;
            List<String> descriptionList = new List<String>();
            if(!(String.isBlank(attach.description))){
                descriptionList = (attach.description).split(';');
                if(descriptionList.size() > 0){
                    docType = descriptionList[0];
                }
               
            }
            attachmentCreateddate = (attach.CreatedDate).format();
            attachmentLastmodifieddate = (attach.LastModifiedDate).format();  
            system.debug('attachmentName:::'+attachmentName);
        }
    } 
    //set document type and visibility to document and send it to azure cloud and delete it from files
    @AuraEnabled
    public static void updateAttachmentrecord(String jvar, string parentid){
        //system.debug('JSon Format input to Apex'+jvar);
        //system.debug('Parent ID::'+parentid);
        //Set<Id> recordIds=new Set<Id>{parentid};
        //system.debug('recordIds::'+recordIds);
        //system.debug('sObjectName::'+sObjectName);
       
        List<Attachwrapper> attach1 = (List<Attachwrapper>)JSON.deserialize(jvar, List<Attachwrapper>.class);
       if(attach1.size()>0){ 
       for(Attachwrapper attwrp : attach1){
           selectedDocType.put(attwrp.attachID, attwrp.docType);
           selectedDocVisibility.put(attwrp.attachID, attwrp.month);
           CDIdList.add(attwrp.attachID);
       }
         }
        Document_Storage__c multipeDocumentList;
        Work_assignment__c prodId;
        Product__c productIdQuery;
       Id productId = parentid;
       system.debug('parentid::'+parentid);
        if(parentid.contains(config.MutipleFileUpload__c)){
         productIdQuery = [Select id,Name,Collection_Agency_Placement__c from Product__c where id =: productId ];
        }
        system.debug('productIdQuery::'+productIdQuery);
       try{
            prodId = [select id,name,product__c,product__r.Collection_Agency_Placement__c from Work_assignment__c where id =: productId];
           
            system.debug('prodId::'+prodId);
       }catch(Exception e){
           
       }
       for(Id con : CDIdList){
           MultipleDocumentAPIClient.AttachWrapper attach = new MultipleDocumentAPIClient.AttachWrapper();
           if(!Test.isRunningTest()) {
           	attach = MultipleDocumentAPIClient.postDocument1(con);
           }
           multipeDocumentList = new Document_Storage__c();
           if(parentid.contains(config.MutipleFileUpload__c)){
            multipeDocumentList.Product__c = productId; 
            multipeDocumentList.Placement_Agency__c = productIdQuery.Collection_Agency_Placement__c;
           }else{
            multipeDocumentList.Product__c = prodId.product__c;
            multipeDocumentList.Placement_Agency__c = prodId.product__r.Collection_Agency_Placement__c;
           }
            multipeDocumentList.Document_Name__c = attach.title+'.'+attach.extension;
            multipeDocumentList.Document_Extension__c = attach.extension;
            multipeDocumentList.Document_ID__c = attach.docID;
            multipeDocumentList.Document_Type__C = selectedDocType.get(con);
            multipeDocumentList.Visibility__c = selectedDocVisibility.get(con);
            multipeDocumentList.Document_URL__c = attach.docURL;
            multipeDocumentList.Uploaded_By__c = 'Internal User';
            multipeDocumentList.Creator__c = UserInfo.getName();
            multipeDocumentList.File_Processed_By__c = UserInfo.getName();
            multipeDocumentList.File_Processing_Date__c = Date.today();
            listCon1.add(multipeDocumentList);         
            attach = Null;
           multipeDocumentList = Null;
        }
        //system.debug('listCon1:::::::'+listCon1);
        insert listCon1;
        List<ContentDocument> deleteListAttach = new List<ContentDocument>();
        if(CDIdList != Null){
            for(Id attachId : CDIdList){
                ContentDocument deleteAttch = new ContentDocument();
                deleteAttch.id = attachId;
              
                deleteListAttach.add(deleteAttch);
                //system.debug('listCon1 after delete::'+listCon1);
            }
            delete deleteListAttach;
        }
        
        
    }//updating files 
    
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        
        List<String> listDocumentType = new List<String>();
        List<Attachment_Document_Type__c> attachlistsetting = new List<Attachment_Document_Type__c>();
        attachlistsetting =[SELECT name, Media_Request_Document_Type__c FROM Attachment_Document_Type__c order by name];
        for( Attachment_Document_Type__c alist : attachlistsetting ) {
            listDocumentType.add(alist.Media_Request_Document_Type__c);
        }
        return listDocumentType;
    }// Getting Attachment Document List 
    @AuraEnabled
    public static List<String> getDocVisibilityValues(){
        
        List<String> listDocumentType = new List<String>();
        List<Attachment_Document_Type__c> attachlistsetting = new List<Attachment_Document_Type__c>();
        attachlistsetting =[SELECT name, Media_Request_Document_Visibility__c FROM Attachment_Document_Type__c order by name];
        for( Attachment_Document_Type__c alist : attachlistsetting ) {
            listDocumentType.add(alist.Media_Request_Document_Visibility__c);
        }
        system.debug('attachlistsetting:::'+attachlistsetting);
        return listDocumentType;
    }
 
}