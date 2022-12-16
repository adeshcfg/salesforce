@isTest
public class TestDepositSlipAutoLock {
    
  static testmethod void testData(){
        
      //Custom setting Record Creation
      Application_Config_Settings__c config = new Application_Config_Settings__c();
      config.CCS_Final_Deposit_Slip__c=date.newInstance(2020, 04, 16);
      config.Final_Deposit_Slip__c=date.newInstance(2020, 04, 18);
      insert config;
        
      //CCS Deposit SLip record Creation
      Deposit_Slip__c csds=new Deposit_Slip__c(); 
      RecordType CCSDepositslip = [Select Id from RecordType where SObjectType = 'Deposit_Slip__c' and DeveloperName = 'CCS_Deposit_Slip'];
      csds.RecordTypeId=CCSDepositslip.id;
      insert csds;

      //CCS Deposit SLip record Creation
      Deposit_Slip__c insolds=new Deposit_Slip__c(); 
      RecordType InsolvDepositslip = [Select Id from RecordType where SObjectType = 'Deposit_Slip__c' and DeveloperName = 'Insolvency_Deposit_Slip'];
      insolds.RecordTypeId=InsolvDepositslip.id;
      insert insolds;
      
      //Calling Method
      DepositSlipAutoLock.DepositSlipLock();
    }
    
  
}