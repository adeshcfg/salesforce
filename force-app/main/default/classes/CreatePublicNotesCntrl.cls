/**************************************************************************************************
 *
 *  Class:   CreatePublicNotesCntrl
 *
 *  @description : Used to create Public Note record from Insolvency and Insolvnecy Account
 *  @author : A5E Consulting
 *  @date : 03/13/2019
 * 
 *************************************************************************************************/
public with sharing class CreatePublicNotesCntrl {
    public string noteTitle{get;set;}
    public string noteBody{get;set;}
    public String profileName;
    public String baseUrl{get;set;}
    public Boolean editNote{get;set;}
    String sobjectType;

    
    id parentID;
    public Note createNote{get;set;}
    
    //Controller
    public CreatePublicNotesCntrl(ApexPages.StandardController controller) {
    	editNote = true;
        profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'QA'){
            editNote = false;
        }
    
        parentID = ApexPages.CurrentPage().getParameters().get('parent_id');
        
        //get SObjectType from ID
        sobjectType = parentID.getSObjectType().getDescribe().getName();
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
        
        String noteID = ApexPages.CurrentPage().getParameters().get('id');
        createNote = new Note();
        if(String.isNotEmpty(noteID)){
            
            createNote = [SELECT id, parentID, body, createdDate, owner.name, title, LastModifiedDate, CreatedBy.name, lastmodifiedby.name
                        from Note where id = :noteID];
            noteTitle = createNote.title;
            noteBody = createNote.body;
        }
    }
    
    public pageReference save(){
        system.debug('createNote ' + createNote);
        if(createNote.parentID == null){
            createNote.ParentID = parentID;
        }/*else{
            
            createNote.title = noteTitle;
            createNote.body = noteBody;
        }*/
        
        upsert createNote; 
        PageReference orderPage;
        if(profileName.contains('CFG') || profileName.contains('Admin')){
            if(sobjectType == 'Insolvency Account'){
                orderPage = new PageReference(baseUrl + '/apex/InsolvencyAccountView?id=' + parentID + '&sfdc.override=1');
            }
            else{
                orderPage = new PageReference(baseUrl + '/' + parentID);
            }
        }
        else{
            orderPage = new PageReference(baseUrl + '/' + parentID);
        }
        orderPage.setRedirect(true);
        return orderPage; 
    }
    
    public pageReference cancel(){
        PageReference orderPage;
        
        if(profileName.contains('CFG') || profileName.contains('Admin')){
            if(sobjectType == 'Insolvency Account'){
                orderPage = new PageReference(baseUrl + '/apex/InsolvencyAccountView?id=' + parentID);
            }
            else{
                orderPage = new PageReference(baseUrl + '/' + parentID);    
            }
        }
        else{
            orderPage = new PageReference(baseUrl + '/' + parentID);
        }
        orderPage.setRedirect(true);
        return orderPage; 
    }
    
    // method to fetch community URL
    public string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        return comm.siteUrl;
    } 
}