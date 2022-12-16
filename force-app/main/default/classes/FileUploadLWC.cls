/**************************************************************************************************
*
*  Class: FileUploadLWC
*
*  @description : This class is integration layer for the Update Document name for multiple file upload.     
*  @author : A5E Consulting
*  @date : 25/04/2022

*************************************************************************************************/
public with sharing class FileUploadLWC {
    public static string s2;
    @AuraEnabled
   public static string UpdateFiles(string documentId,string title, String recordId){  
     ContentDocument cd = [select id,title from ContentDocument where Id=:documentId]; // Getting files from Parent record
       system.debug('documentId'+documentId);
       s2 =  title.substringBefore('.');
       cd.Title = s2 + '@FileUpload';  // Changing file Title with user entered title
       s2 = null;
     try{  
       update cd;  // Update ContentDocument (File)
     }  
     catch(DMLException e){  
       system.debug('Exception has occurred! ' +e.getMessage());  
     }  
    List<ContentDocument> DocumentList = new List<ContentDocument>();  
     Set<Id> documentIds = new Set<Id>();  
     List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId];  
     for(ContentDocumentLink cdLink:cdl){  
       documentIds.add(cdLink.ContentDocumentId);  
     }      
     DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds];
     return null;  // Return list of files on parent record
   }  
   @AuraEnabled
    public static String deleteRecordFile(String fileid) {
        List<ContentDocument> Doc = [select id,contentsize from ContentDocument where id =: fileid limit 1];
      if(doc.size()>0){
        integer filesize = Doc[0].contentsize;
          system.debug('filesize::'+filesize);
      if(filesize > 5507743){
            Delete Doc[0];
            return 'ERROR';
        }else{
            return 'SUCCESS';
        }    
      }else{
    return '';
  }
}
    @AuraEnabled
    public static String contentSize(String cid) {
        ContentDocument Doc = [select id,title,contentsize,FileExtension from ContentDocument where id =: cid limit 1];
        integer size = Doc.contentsize;
        system.debug('size:'+size);
     try{    
      if(size > 5797743){
            Delete Doc;
            return 'ERROR'+','+doc.title+'.'+Doc.FileExtension;
        }else{
            s2 =  Doc.title.substringBefore('.');
            Doc.Title = s2 + '@FileUpload';  // Changing file Title with user entered title
            update Doc;
          return 'SUCCESS';
        }
         }catch(DMLException e){  
           system.debug('Exception has occurred! ' +e.getMessage());  
         }
        return '';
   }
}