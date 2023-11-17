/**************************************************************************************************
*
*  Class:   NoteCrtl
*
*  @description : Used to create Edit Public Note record from Insolvency and Insolvnecy Account
*  @author : A5E Consulting
*  @date : 03/29/2019
* 
*************************************************************************************************/
 public class NoteCrtl {
    
    public id parentRecordID{get;set;}
    public Boolean isCommunityUser{get;set;}
    public Note noteRecord{get;set;}
    public String baseUrl{get;set;}
    public String profileName;
    public String sObjectType{get;set;}
    id parentID;
    
    List<sObject> listParentRecord{get;set;}   
            
    
    //controller
    public NoteCrtl(ApexPages.StandardController controller){
        
        
        List<Note> listNoteRecord = [SELECT id, parentID, body, createdDate, owner.name, title, LastModifiedDate, CreatedBy.name, lastmodifiedby.name
                        from Note where id = : ApexPages.CurrentPage().getParameters().get('id')];
        //system.List(listNoteRecord);
        
        if(listNoteRecord.size() > 0){
            noteRecord = listNoteRecord[0];
        parentID = noteRecord.parentId;
       /* parentRecordID = noteRecord.ParentId;
        String parentObject = parentRecordID.getSObjectType().getDescribe().getName();
        String queryStr = 'SELECT Id  FROM ' + parentObject + 'WHERE Id = ' +parentRecordID;
        listParentRecord = database.query(queryStr);//[select Id  FROM sobjectType WHERE Id=:parentID];*/
        
        //get SObjectType from ID
        sObjectType = parentID.getSObjectType().getDescribe().getName();
        //sobjectType = Insolvency__c.getSObjectType().getDescribe().getName();
        
        // Check whether current user is commnity user or not and set URL
        isCommunityUser = InsolvencyUtil.isCommunityUser();
        if(isCommunityUser){
            baseUrl = InsolvencyAccntNoteCntrl.getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    }
    
     public pageReference Edit(){
         
       PageReference p=new PageReference(baseUrl + '/apex/CreatePublicNotes?parent_id=' + parentID + '&id=' + noteRecord.id);
         
         
       return p;
    }
     public pageReference Cancel(){
         pageReference r= new pageReference(baseUrl + '/' + parentID);
         return r;
     }
     
}