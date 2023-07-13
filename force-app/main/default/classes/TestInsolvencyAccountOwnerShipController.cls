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
         Application_Config_Settings__c config = new  Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = false, Run_Record_Ownership__c = true);
         insert config;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-owner001', Is_Record_Locked__c = true);
         insert insolv;      
         
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c( Insolvency__c = insolv.Id, OwnerId = UserInfo.getUserId(), Name = 'test123',Claim_Amount__c =10);
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