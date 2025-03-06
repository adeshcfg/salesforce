/**************************************************************************************************
 *
 *  Class:   InsolvencyOwnerShipController
 *
 *  @description : Implemented Insolvency, and related Insolvency Accounts Owner Id with either scotia/chase bank user
 *  @author : A5E Consulting
 *  @date : 16/04/2018
 
 *************************************************************************************************/
public class InsolvencyOwnerShipController{

    public Insolvency__c insolv {set;get;}
    Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
    
    // Check varialble for community users
    @TestVisible
    public Boolean isScotiaBankCommunityUser {set;get;}
    
    @TestVisible
    public Boolean isChaseBankCommunityUser {set;get;}
    
    @TestVisible
    public Boolean isSDABankCommunityUser {set;get;}
    
    @TestVisible
    public Boolean isFairstoneBankCommunityUser {set;get;}

    @TestVisible
    public Boolean isGoeasyBankCommunityUser {set;get;}

    @TestVisible
    public Boolean isCanadianTireCommunityUser {set;get;}
    
    @TestVisible
    public Boolean isMoneyMartCommunityUser {set;get;}
    
    @TestVisible
    public Boolean isFlexitiCommunityUser {set;get;}
    
    public InsolvencyOwnerShipController(ApexPages.StandardController controller) {
    	
    	//Initialize the values
        isScotiaBankCommunityUser = InsolvencyUtil.isScotiaBankCommunityUser(UserInfo.getProfileId());
        isChaseBankCommunityUser = InsolvencyUtil.isChaseBankCommunityUser(UserInfo.getProfileId());
    	isSDABankCommunityUser = InsolvencyUtil.isSDABankCommunityUser(UserInfo.getProfileId());
        isFairstoneBankCommunityUser = InsolvencyUtil.isFairstoneBankCommunityUser(UserInfo.getProfileId());
        isGoeasyBankCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(Userinfo.getProfileId());
        isCanadianTireCommunityUser = InsolvencyUtil.isCanadianTireCommunityUser(Userinfo.getProfileId());
        isMoneyMartCommunityUser = InsolvencyUtil.isMoneyMartCommunityUser(Userinfo.getProfileId());
        isFlexitiCommunityUser = InsolvencyUtil.isFlexitiCommunityUser(Userinfo.getProfileId());
        //Eligible Insolvency Account Record Type Name 
        String eligibleInsAcctRecordType = InsolvencyUtil.getInsAccntRecordTypeProfile(Userinfo.getProfileId());
 
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            insolv = [SELECT Scotia_Record_Owner__c,
                             Chase_Record_Owner__c, 
                             SDA_Record_Owner__c,
                             Insolvency_Owner__c,
                      		 Fairstone_Record_Owner__c,
                             Goeasy_Record_Owner__c,
                             Canadian_Tire_Record_Owner__c,
                      		 Money_Mart_Record_Owner__c,
                      		 Flexiti_Record_Owner__c,
                             OwnerId, Owner.Name, Insolvency_Owner_Id__c,
                             (SELECT OwnerId 
                                    FROM Insolvency_Accounts__r 
                                    where RecordType.name =: eligibleInsAcctRecordType
                             ) 
                             FROM Insolvency__c 
                             WHERE Id =: ((Insolvency__c)controller.getRecord()).Id];
        }
        
    }
    
    // Default method called to check and assign ownership of an Insolvency & Insolvency Account
    public void checkInsolvencyAccountOwnerShip(){
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            if(isScotiaBankCommunityUser){
                if(insolv.Scotia_Record_Owner__c == null){
                    insolv.Scotia_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }else if(isChaseBankCommunityUser){
                if(insolv.Chase_Record_Owner__c == null){
                    insolv.Chase_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            
            else if(isSDABankCommunityUser){
                if(insolv.SDA_Record_Owner__c == null){
                    insolv.SDA_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            
            else if(isFairstoneBankCommunityUser){
                if(insolv.Fairstone_Record_Owner__c == null){
                    insolv.Fairstone_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(isGoeasyBankCommunityUser){
                if(insolv.Goeasy_Record_Owner__c == null){
                    insolv.Goeasy_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(isCanadianTireCommunityUser){
                if(insolv.Canadian_Tire_Record_Owner__c == null){
                    insolv.Canadian_Tire_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(isMoneyMartCommunityUser){
                if(insolv.Money_Mart_Record_Owner__c == null){
                    insolv.Money_Mart_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
            else if(isFlexitiCommunityUser){
                if(insolv.Flexiti_Record_Owner__c == null){
                    insolv.Flexiti_Record_Owner__c = UserInfo.getUserId();
                    InsolvencyUtil.updateOwnerShip(insolv);
                }
            }
        }
    }
}