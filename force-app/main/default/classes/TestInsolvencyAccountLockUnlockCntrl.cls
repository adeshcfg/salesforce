@isTest(seeAllData = false)
public class TestInsolvencyAccountLockUnlockCntrl{
    @testSetup
    static void testData() {
        
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;
          
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(Name = 'Test-Lock01', Is_Record_Locked__c = true);
         insert insolv; 
        
         // insert insolvency account
 		Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'Test111';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Insolvency__c = insolv.id;
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Insolvency__c = insolv.Id;
        insert insolAcct;	        
        
        
         //Insolvency_Account__c insolvAacc = new Insolvency_Account__c(Insolvency__c = insolv.Id);
         //insert insolvAacc ;
    }
    
    public testmethod static void  InsolvencyLockUnlock(){
        Insolvency_Account__c insolvacc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', insolvacc.Id);  
        InsolvencyAccountLockUnlockController obj = new InsolvencyAccountLockUnlockController(new ApexPages.StandardController(insolvacc));
        obj.lockInsolvency();
        obj.unLockInsolvency();
        obj = new InsolvencyAccountLockUnlockController(new ApexPages.StandardController(insolvacc));
        obj.lockInsolvency();
    }
}