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
    public Note noteRecord{get;set;}
    public String baseUrl{get;set;}
    public String profileName;
    String sobjectType;
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
        sobjectType = (noteRecord.parentID).getSObjectType().getDescribe().getName();
        //sobjectType = Insolvency__c.getSObjectType().getDescribe().getName();

        //get the Profile name of current login user
        profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        
        // Check whether current user is commnity user or not and set URL
        if(profileName.contains('Community User')){
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
    }
    }
    // method to fetch community URL
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        return comm.siteUrl;
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