/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to process potential matches 
 *  @author : A5E Consulting
 *  @date : 03/30/2016
 *
 *  Change History:
 *
 *  Developer       Date          Description
 *  ------------------------------------------------------------------------------------------------
 *
 *  A5E Consulting 03/30/2016     Class created
 *  A5E Consulting 04/04/2016     Use PotentialMatchUtil methods to find exact and uncertain matches
 *  A5E Consulting 04/04/2016     Validation code to find no of Accounts selected
  
 *************************************************************************************************/
public class PotentialMatchController {
    
    public String applnId;
    public Boolean manualReview{get;set;}
    public String validationErrMsg{get;set;}  
    
    //decides whether to refresh main detail page or not
    public Boolean refreshPage {get; set;}  
    
    //Wrapped Potential matches
    public List<PotentialMatchAccountWrapper> existingWrappedAccounts {get;set;}
        
    //Constructor
    public PotentialMatchController(ApexPages.StandardController controller) {
        
        applnId = ApexPages.currentPage().getParameters().get('id');
        existingWrappedAccounts = new List<PotentialMatchAccountWrapper>();
        refreshPage = false;
                
        Application__c appln = [Select Id, customer__c, First_Name__c, Last_Name__c, Email_Address__c, SIN__c, Birth_Date__c, Needs_Manual_Review__c, Manual_Review_Reason__c from  Application__c where id=:applnId];
        manualReview = appln.Needs_Manual_Review__c == true ? true : false;
        
        if(manualReview){
        
            List<Account> potentialMatchList;
            
            if(appln.Manual_Review_Reason__c == PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_EXACT_MATCHES){                
                potentialMatchList = PotentialMatchUtil.getExactMatchList(appln);               
            } 
            else if(appln.Manual_Review_Reason__c == PotentialMatchUtil.MANUAL_REVIEW_REASON_MULTIPLE_UNCERTAIN_MATCHES){               
                potentialMatchList = PotentialMatchUtil.getUncertainMatchList(appln);               
            } 
            
            if(!potentialMatchList.isEmpty()){
                                
                for(Account existingAcc : potentialMatchList){
                    if(existingAcc.Id != appln.customer__c){
                        existingWrappedAccounts.add(new PotentialMatchAccountWrapper(existingAcc));
                    }                    
                }            
            }             
        }                                                                 
    }
    
    //Assign Application to selected Account  
    public PageReference assignSelected(){
        
        applnId = ApexPages.currentPage().getParameters().get('id');         
        String matchAccntId;                
        Integer matchCnt = 0;
        refreshPage = false;
        
        for (PotentialMatchAccountWrapper matchAccntWrppr : existingWrappedAccounts){
            
            if(matchAccntWrppr.selected){
                matchAccntId = matchAccntWrppr.accnt.Id;
                matchCnt++;  
            }           
        }
        
        //Single selection
        if(matchCnt == 1){
            if(matchAccntId != null){
                PotentialMatchUtil.assignSelectedAccountToApplication(Id.valueOf(matchAccntId), Id.valueOf(applnId));
                refreshPage = true;
            }           
        }
        
        //No selection
        if(matchCnt == 0){
            validationErrMsg = 'You must first Select a Customer.';
            refreshPage = false;                        
        }
        
        //Multiple selection
        if(matchCnt > 1){
            validationErrMsg = 'Select only one Customer.';
            refreshPage = false;                    
        }   
               
        return null;     
    }
    
    //Create new Account and assign Application to it
    public PageReference createNewNAssign(){
        
        applnId = ApexPages.currentPage().getParameters().get('id');
        PotentialMatchUtil.createNewAccountAndAssignToApplication(Id.valueOf(applnId));
        refreshPage = true;
        
        return null;
    }
    
    //Keep Assignmnet as it is, reset review flags
    public PageReference keepSameCustomer(){
      
        applnId = ApexPages.currentPage().getParameters().get('id');
        PotentialMatchUtil.keepSameCustomer(Id.valueOf(applnId));
        refreshPage = true;
                       
        return null;
    }
}