/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class for Insolvency edit
 *  @author : A5E Consulting
 *  @date : 01/16/2018
 
 *************************************************************************************************/
 
public class InsolvencyEditController {
    
    public String insolvencyId{get;set;}
    public Insolvency__c insolv{get;set;}
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    public InsolvencyEditController(ApexPages.StandardController controller){
    
        //Insolvency ID
        insolvencyId = ApexPages.currentPage().getParameters().get('id'); 
        
        //Eligible Insolvency Account Record Type Name 
    	String eligibleInsAcctRecordType = InsolvencyUtil.getInsAccntRecordTypeProfile(Userinfo.getProfileId());
     
        //Insolvency record
        insolv = [Select Id, Name,
                            Scotia_Record_Owner__c, 
                            Chase_Record_Owner__c, 
                            SDA_Record_Owner__c,
                  			Fairstone_Record_Owner__c,
                            Goeasy_Record_Owner__c,
                            Canadian_Tire_Record_Owner__c,
                  			Money_Mart_Record_Owner__c,
                  			Flexiti_Record_Owner__c,
                            (SELECT OwnerId 
                                FROM Insolvency_Accounts__r
                                where RecordType.name =: eligibleInsAcctRecordType
                             ) 
                            from Insolvency__c where id =: insolvencyId limit 1]; 
        
            
    }
    
    public PageReference redirPage(){
        
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            if(InsolvencyUtil.isScotiaBankCommunityUser(UserInfo.getProfileId())){
                if(insolv.Scotia_Record_Owner__c == null){
                    insolv.Scotia_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(InsolvencyUtil.isChaseBankCommunityUser(UserInfo.getProfileId())){
                if(insolv.Chase_Record_Owner__c == null){
                    insolv.Chase_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            
            else if(InsolvencyUtil.isSDABankCommunityUser(UserInfo.getProfileId())){
                if(insolv.SDA_Record_Owner__c == null){
                    insolv.SDA_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            
            else if(InsolvencyUtil.isFairstoneBankCommunityUser(UserInfo.getProfileId())){
                if(insolv.Fairstone_Record_Owner__c == null){
                    insolv.Fairstone_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(InsolvencyUtil.isGoeasyBankCommunityUser(UserInfo.getProfileId())){
                if(insolv.Goeasy_Record_Owner__c == null){
                    insolv.Goeasy_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(InsolvencyUtil.isCanadianTireCommunityUser(UserInfo.getProfileId())){
                if(insolv.Canadian_Tire_Record_Owner__c == null){
                    insolv.Canadian_Tire_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(InsolvencyUtil.isMoneyMartCommunityUser(UserInfo.getProfileId())){
                if(insolv.Money_Mart_Record_Owner__c == null){
                    insolv.Money_Mart_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(InsolvencyUtil.isFlexitiCommunityUser(UserInfo.getProfileId())){
                if(insolv.Flexiti_Record_Owner__c == null){
                    insolv.Flexiti_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
        }
        
         return redirectEditPage();
    }
    
    //Redirect to edit page
    private PageReference redirectEditPage(){
        try {
                String redirectUrl = '/' +Insolvency__c.SObjectType.getDescribe().getKeyPrefix() + '/e';
                PageReference redirectPg = new PageReference(redirectUrl);
                
                Map<String, String> paramMap = redirectPg.getParameters();
                paramMap.putAll(ApexPages.currentPage().getParameters()); 
                paramMap.put('nooverride', '1');                       
                redirectPg.setRedirect(true);
                return redirectPg;            
        }
        catch(Exception exp){  
            return null;
        }
    }
}