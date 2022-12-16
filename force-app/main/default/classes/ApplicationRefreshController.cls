/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : Controller class that check if standard Application page needs to be refreshed
 *  @author : A5E Consulting
 *  @date : 0/05/2016
 *  
 
 *************************************************************************************************/
public class ApplicationRefreshController {
    
    //decides whether to refresh main application detail page or not
    public Boolean refreshPage {get; set;} 
    public String applnId;
    
    //Constructor
    public ApplicationRefreshController(ApexPages.StandardController stdController) {
        refreshPage = false; 
    } 
    
    //Check if there is a need to Refresh the Standare Page Layout
    public void checkRefreshFlag(){ 
        applnId = ApexPages.currentPage().getParameters().get('id');
        Application__c refAppln = [Select ID, Call_Status__c From application__c Where ID = :applnID];
        if(String.isNotBlank(refAppln.Call_Status__c) && refAppln.Call_Status__c == 'In Progress'){
            refreshPage = true;         
        } 
        else{
            refreshPage = false;
        }
    } 
}