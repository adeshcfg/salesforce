/**************************************************************************************************
 *
 *  Class:   InsolvencyAccountOwnerShipController
 *
 *  @description : Implemented Insolvency, and related Insolvency Accounts Owner Id with either scotia/chase bank user
 *  @author : A5E Consulting
 *  @date : 16/04/2018
 
 *************************************************************************************************/
public class InsolvencyAccountOwnerShipController{

    public Insolvency_Account__c insolvAcc {set;get;}
    public static Application_Config_Settings__c config;// = Application_Config_Settings__c.getOrgDefaults();
    
    public Boolean isOwnerIdCommunityUser {set;get;}
    public Boolean eligibleForOwnerShip{set;get;}
   
    // Check varialble for community users
    @TestVisible
    Boolean isScotiaBankCommunityUser;
    
    @TestVisible
    Boolean isChaseBankCommunityUser;
    
    @TestVisible
    Boolean isSDABankCommunityUser;
    
    @TestVisible
    Boolean isFairstoneBankCommunityUser;

    @TestVisible
    Boolean isGoeasyBankCommunityUser;

    @TestVisible
    Boolean isCanadianTireCommunityUser;
    
    @TestVisible
    Boolean isMoneyMartCommunityUser;
    
    @TestVisible
    Boolean isFlexitiCommunityUser;
    
    
    public InsolvencyAccountOwnerShipController(ApexPages.StandardController controller) {
    
        config = [SELECT Run_Insolvency_Status_Validations__c, Run_Record_Ownership__c FROM Application_Config_Settings__c];
        eligibleForOwnerShip = false;
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            insolvAcc = [SELECT OwnerId, Owner.profileId, 
                                Insolvency__c, Owner.Name 
                                FROM Insolvency_Account__c 
                                WHERE Id =: ((Insolvency_Account__c)controller.getRecord()).Id];
                            
            isScotiaBankCommunityUser = InsolvencyUtil.isScotiaBankCommunityUser(Userinfo.getProfileId());
            isChaseBankCommunityUser = InsolvencyUtil.isChaseBankCommunityUser(Userinfo.getProfileId());
            isSDABankCommunityUser = InsolvencyUtil.isSDABankCommunityUser(Userinfo.getProfileId());
            isFairstoneBankCommunityUser = InsolvencyUtil.isFairstoneBankCommunityUser(Userinfo.getProfileId()); 
            isGoeasyBankCommunityUser = InsolvencyUtil.isGoeasyBankCommunityUser(Userinfo.getProfileId()); 
            isCanadianTireCommunityUser = InsolvencyUtil.isCanadianTireCommunityUser(Userinfo.getProfileId());
            isMoneyMartCommunityUser = InsolvencyUtil.isMoneyMartCommunityUser(Userinfo.getProfileId());
            isFlexitiCommunityUser = InsolvencyUtil.isFlexitiCommunityUser(Userinfo.getProfileId());
        }
    }
    
    // Default method called to check and assign ownership of an Insolvency & Insolvency Account
    public void checkInsolvencyAccountOwnerShip(){
    
        // Run only if record ownership functionality is Enabled at custom settings level
        if(config.Run_Record_Ownership__c){
            eligibleForOwnerShip = false;
            
            //Eligible Insolvency Account Record Type Name 
            String eligibleInsAcctRecordType = InsolvencyUtil.getInsAccntRecordTypeProfile(Userinfo.getProfileId());
            
            User owner = [SELECT ProfileId FROM User WHERE ID =: insolvAcc.OwnerId];
            
            if(!InsolvencyUtil.isScotiaBankCommunityUser(owner.profileId) &&
                !InsolvencyUtil.isChaseBankCommunityUser(owner.profileId) && 
                !InsolvencyUtil.isSDABankCommunityUser(owner.profileId) &&
              	!InsolvencyUtil.isFairstoneBankCommunityUser(owner.profileId) &&
                !InsolvencyUtil.isGoeasyBankCommunityUser(owner.profileId) &&
                !InsolvencyUtil.isCanadianTireCommunityUser(owner.profileId) &&
              	!InsolvencyUtil.isMoneyMartCommunityUser(owner.profileId) &&
              	!InsolvencyUtil.isFlexitiCommunityUser(owner.profileId)){
                
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
                                                FROM Insolvency__c WHERE Id =: insolvAcc.Insolvency__c];
                
                // Check appropriate user and assign then ownership                              
                if(isScotiaBankCommunityUser){
                    if(insolv.Scotia_Record_Owner__c == null){
                        insolv.Scotia_Record_Owner__c = UserInfo.getUserId();
                        InsolvencyUtil.updateOwnerShip(insolv);
                    }
                }
                else if(isChaseBankCommunityUser){
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
            else if(insolvAcc.OwnerId != Userinfo.getUserId()){
                eligibleForOwnerShip = true;
            }
        }
    }
    
    // Method to take ownership of an Insolvency Account, Insolvency if third person would like to work on
    public void takeOwnerShip(){
      
        //Don't run validation rules
        //Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c ];
        /*
         //Read and store the actual value of the insolvency status validation field
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
        
        if(isScotiaBankCommunityUser || isChaseBankCommunityUser || isSDABankCommunityUser || isFairstoneBankCommunityUser || isGoeasyBankCommunityUser || isCanadianTireCommunityUser || isMoneyMartCommunityUser || isFlexitiCommunityUser){
            insolvAcc.OwnerID = UserInfo.getUserId();
            insolvAcc.Do_Not_Run_Status_Validation__c = True;
            update insolvAcc;
            eligibleForOwnerShip = false;
        } 
        /*
         config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
         update config;       
         */
    }
    
}