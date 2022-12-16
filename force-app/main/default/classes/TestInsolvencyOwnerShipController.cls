/**************************************************************************************************
 *
 *  Class:   TestInsolvencyOwnerShipController
 *
 *  @description : This class contains unit tests for generating and saving poc pdf document
 *  @author : A5E Consulting
 *  @date : 10/08/2017
 * 
 *************************************************************************************************/

@isTest
public class TestInsolvencyOwnerShipController{
    //Create all necessary Object records in this method
    @testSetup 
    static void testData() {
         Application_Config_Settings__c config = new  Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = false, Run_Record_Ownership__c = true);
         insert config;
         
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c();
         insert insolvAacc ;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-insolOwner', Is_Record_Locked__c = true);
         insert insolv;      
    }
     
    // Unit test for saving poc pdf document as attachment of insolvancy account
    static testMethod void testRecorOwneship(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('Id', insolv.Id);  
        InsolvencyOwnerShipController obj = new InsolvencyOwnerShipController(new ApexPages.StandardController(insolv));
        
        obj.isScotiaBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        
        obj.isScotiaBankCommunityUser = false;
        obj.isChaseBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        
        obj.isChaseBankCommunityUser = false;
        obj.isSDABankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
        
        obj.isSDABankCommunityUser = false;
        obj.isChaseBankCommunityUser = true;
        obj.checkInsolvencyAccountOwnerShip();
     }
}