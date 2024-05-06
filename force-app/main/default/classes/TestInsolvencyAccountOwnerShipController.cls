/**************************************************************************************************
 *
 *  Class:   TestInsolvencyAccountOwnerShipController
 *
 *  @description : This class contains unit tests for generating and saving poc pdf document
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 * 
 *************************************************************************************************/

@isTest(seeAllData = false)
public class TestInsolvencyAccountOwnerShipController{
    
    //Create all necessary Object records in this method
    @testSetup 
    static void testData() {
         //Application config creation
        Application_Config_Settings__c config = new Application_Config_Settings__c(
            Run_Remittance_Validation__c = false,
            Run_Record_Ownership__c = true,
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Run_Insolvency_Account_Trigger__c = false,
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Run_Insolvency_Status_Validations__c = false,
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm'
        );
        insert config;         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-owner001', Is_Record_Locked__c = true);
         insert insolv;      
         
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c( Account_Number_Without_Space__c='123',Insolvency__c = insolv.Id, OwnerId = UserInfo.getUserId(), Name = 'test123',Claim_Amount__c =10);
         insert insolvAacc ;
         
    }
     
    // Unit test for saving poc pdf document as attachment of insolvancy account
    static testMethod void testRecorOwneship(){
        Insolvency_Account__c insolvAcc = [SELECT OwnerID,Id, owner.Profile.Id, Insolvency__c FROM Insolvency_Account__c WHERE Name ='test123' LIMIT 1];
        insolvAcc.OwnerID= USerinfo.getUSerId();
        update insolvAcc;
        
        ApexPages.currentPage().getParameters().put('Id', insolvAcc.Id);  
        InsolvencyAccountOwnerShipController obj = new InsolvencyAccountOwnerShipController(new ApexPages.StandardController(insolvAcc));
        
        obj.insolvAcc = insolvAcc;
        obj.isScotiaBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        
        obj.isScotiaBankCommunityUser = false;
        obj.isChaseBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        
        obj.isChaseBankCommunityUser = false;
        obj.isSDABankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();

        obj.isSDABankCommunityUser = false;
        obj.isFairstoneBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();

        obj.isFairstoneBankCommunityUser = false;
        obj.isGoeasyBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        obj.takeOwnerShip();

    }
}