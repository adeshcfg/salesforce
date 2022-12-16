/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class for Insolvency Account create
 *  @author : A5E Consulting
 *  @date : 05/08/2018
 
 *************************************************************************************************/
 
public class InsolvencyAccountCreateController {
  
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    public InsolvencyAccountCreateController(ApexPages.StandardController controller){
        //ToDo
    }
  
    //Redirect to Record type selection or create page
    public PageReference redirPage(){
        try {
            
            PageReference redirectPg;
            
            if(InsolvencyUtil.isCommunityUser()){
            	
            	System.debug('Community user block');
                
                String redirectUrl = '/' +Insolvency_Account__c.SObjectType.getDescribe().getKeyPrefix() + '/e';
                redirectPg = new PageReference(redirectUrl);
            }
            else{
                //ToDo redirect to Record type selection
                redirectPg = Page.InsolvencyAccountRecordType;
            } 
            
            Map<String, String> paramMap = redirectPg.getParameters();
            paramMap.putAll(ApexPages.currentPage().getParameters()); 
            paramMap.put('nooverride', '1');  
            paramMap.remove('save_new');                      
            redirectPg.setRedirect(true);
            return redirectPg;          
        }
        catch(Exception exp){  
            return null;
        }    
    }    
}