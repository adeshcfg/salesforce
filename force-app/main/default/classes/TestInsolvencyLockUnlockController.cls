@isTest(seeAllData = false)
public class TestInsolvencyLockUnlockController{
    @testSetup
    static void testData() {
          // insert insolvency account
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c();
         insert insolvAacc ;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-insolLock', Is_Record_Locked__c = true);
         insert insolv; 
    }
    
    public testmethod static void  InsolvencyLockUnlock(){
        Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
        ApexPages.currentPage().getParameters().put('id', insolv.Id);  
        InsolvencyLockUnlockController obj = new InsolvencyLockUnlockController(new ApexPages.StandardController(insolv));
        obj.lockInsolvency();
        obj.unLockInsolvency();
        obj = new InsolvencyLockUnlockController(new ApexPages.StandardController(insolv));
        obj.lockInsolvency();
    }
}