public class DepositSlipAutoLock {
    public  static Deposit_Slip__c ccsdepositSlip;
    public  static Deposit_Slip__c InsolvdepositSlip;  
    public static Application_Config_Settings__c appConfigFinal=Application_Config_Settings__c.getOrgDefaults();
    public void DepositSlipAutoLock(){
        
    }
    public static void DepositSlipLock(){
        appConfigFinal = [SELECT CCS_Final_Deposit_Slip__c, Final_Deposit_Slip__c FROM Application_Config_Settings__c FOR UPDATE];//CCS and Inolsvency Final Depsoti slip dates       
        ccsdepositSlip=[SELECT Id, Name FROM Deposit_Slip__c WHERE CreatedDate = TODAY AND recordType.developerName = 'CCS_Deposit_Slip' ORDER BY createdDate DESC limit 1];// Today's CCS Deposit Slips
        system.debug('Todays CCS deposit slip is' + ccsdepositSlip);
        InsolvdepositSlip=[SELECT Id, Name FROM Deposit_Slip__c WHERE CreatedDate = TODAY AND recordType.developerName = 'Insolvency_Deposit_Slip' ORDER BY createdDate DESC limit 1];// Today's Insolvency Deposit Slips
        system.debug('Todays Insolvency deposit slip is' + InsolvdepositSlip);
        //Logic to CCS Deposit Auto Lock
        if(ccsdepositSlip!=Null && appConfigFinal.CCS_Final_Deposit_Slip__c!= system.today() ){
            appConfigFinal.CCS_Final_Deposit_Slip__c= system.today();
            update appConfigFinal;
        }
        
        //Logic to Insolvency Deposit Auto Lock
        if(InsolvdepositSlip!=Null && appConfigFinal.Final_Deposit_Slip__c!=system.today()){
         appConfigFinal.Final_Deposit_Slip__c= system.today();
            update appConfigFinal;  
        }  
        
    }
}