/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class for Insolvency Account edit
 *  @author : A5E Consulting
 *  @date : 01/20/2018
 
 *************************************************************************************************/
 
public class InsolvencyAccountEditController {
  
    public String insolvencyAccntId{get;set;}
    public Insolvency_Account__c insolvncyAccnt{get;set;}
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    //public Insolvency__c insolvncy{get;set;}
  
    public InsolvencyAccountEditController(ApexPages.StandardController controller){
        //Insolvency Account ID
        insolvencyAccntId = ApexPages.currentPage().getParameters().get('id');  
          
        //Insolvency Account record
        insolvncyAccnt = [SELECT Id, Name, 
                            Client_Identifier__c, 
                            Insolvency__c,
                            OwnerId 
                            FROM Insolvency_Account__c WHERE Id =: insolvencyAccntId limit 1];
    }
  
    //Redirect to Edit PAge
    public PageReference redirPage(){
    
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            User owner = [SELECT ProfileId FROM User WHERE ID =: insolvncyAccnt.OwnerId];
            //Eligible Insolvency Account Record Type Name 
            String eligibleInsAcctRecordType = InsolvencyUtil.getInsAccntRecordTypeProfile(Userinfo.getProfileId());
             
             if(!InsolvencyUtil.isScotiaBankCommunityUser(owner.profileId) &&
                !InsolvencyUtil.isChaseBankCommunityUser(owner.profileId) && 
                !InsolvencyUtil.isSDABankCommunityUser(owner.profileId)){
                
                Insolvency__c insolv = [SELECT Scotia_Record_Owner__c, 
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
                                                FROM Insolvency__c WHERE Id =: insolvncyAccnt.Insolvency__c];
                                                
                if(InsolvencyUtil.isScotiaBankCommunityUser(Userinfo.getProfileId())){
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
        }
        
        return redirectEditPage();
    }
    
    private PageReference redirectEditPage(){
        try {
            String redirectUrl = '/' +Insolvency_Account__c.SObjectType.getDescribe().getKeyPrefix() + '/e';
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