/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to upload and display Insolvency Notes
 *  @author : A5E Consulting
 *  @date : 12/07/2017
 *  
 *************************************************************************************************/
public class InsolvencyAccntNoteCntrl{
    
    public String insolvencyAccntId{get;set;}
    
    public String newNoteLink{get;set;}
    public boolean communityUser{get;set;}
    public Boolean isCommunityReadOnlyUser {set;get;}
    public static Boolean isLightningCommunity = false;
    public static String urlPathPrefix = '';
    public static Boolean isProduction = true;
    //Constants
    public static final String dateFormat = 'MM/dd/yyyy h:mm a';
    public static final String lastmodified = 'MM/dd/yyyy h:mm a';
   //public static final datetime timestamp = System.now(); 
    //COnstructor
    public InsolvencyAccntNoteCntrl(ApexPages.StandardController controller) {
         
        //Insolvency Account Id
        insolvencyAccntId = ApexPages.currentPage().getParameters().get('id');
        
        communityUser = InsolvencyUtil.isCommunityUser();
        
        //New Note Link
        String baseUrl ='';     
        if(communityUser){
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        newNoteLink = createNewNoteLink(baseUrl, insolvencyAccntId);
        
        //Check whether current user is readonly profile or not
        isCommunityReadOnlyUser = InsolvencyUtil.isCommunityReadOnlyUser();
        
    }   
    
    //Notes WRapper
    public class NoteWrpper{
        public Note nte{get;set;}
        public String nteLink {get;set;}
        public string dateCreated {get;set;}
        public string LastModifiedDate {get;set;}
        public string body{get;set;}
        
        public NoteWrpper(Note nte, String baseUrl){
            this.nte = nte;
            this.nteLink = baseUrl + '/apex/NoteDisplay?id=' + nte.Id;
            this.dateCreated = (nte.createdDate).format(dateFormat);
            this.LastModifiedDate = (nte.LastModifiedDate).format(lastmodified);
           //this.dateCreated = timestamp.format('M/d/yyyy h:mm a');   
            this.body = nte.body;     
        }       
    }
    
    //Populate and return Note Wrappers
    public List<NoteWrpper> getInslNoteWrappers(){
        
        //Construct Base URL
        String baseUrl = getBaseUrl(InsolvencyUtil.isCommunityUser());
        
        List<NoteWrpper> noteWrappers = new List<NoteWrpper>();
        List<Note> notes = [Select Id, Title, CreatedDate,LastModifiedDate,Body  
                            From Note
                            where ParentId =:insolvencyAccntId  
                            order by LastModifiedDate desc 
                           ];
               
        for(Note nte : Notes){
            noteWrappers.add(new NoteWrpper(nte, baseUrl));
        }
        
        return noteWrappers;
    }    
    
    //Utility method that constructs community url
    public static string getCommunityUrl(){        
        String ntwrkId = Network.getNetworkId();
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
        if (comm.siteAsContainerEnabled) {
            isLightningCommunity = true;
            urlPathPrefix = comm.urlPathPrefix;
            if(comm.siteUrl.contains('sandbox')) {
                isProduction = false;
            }
        }
        // System.debug('comm.siteUrl' + comm.siteUrl);
        return comm.siteUrl;
    } 
    
    //Utility method that constructs base url
    private static string getBaseUrl(Boolean communityUser){
        String baseUrl;
        if(communityUser){
            baseUrl = getCommunityUrl();
        }
        else{
            baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        }
        return baseUrl;
    }
    
    //Utility method to create new Note link
    private static String createNewNoteLink(String BaseUrl, String insolvencyAccntId){       
        pageReference pgRef = new pageReference(BaseUrl + '/apex/CreatePublicNotes?parent_id=' + insolvencyAccntId + '&retURL=/' + insolvencyAccntId);
        if (isLightningCommunity) {
            pgRef.getParameters().put('isdtp', 'vw');
        }
        pgRef.setRedirect(true);
        return pgRef.getUrl();
    }   
   
}