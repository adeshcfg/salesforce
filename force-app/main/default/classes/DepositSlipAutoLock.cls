public class DepositSlipAutoLock {
    // Production Issue - Converted variables to list
    public static List<Deposit_Slip__c> ccsdepositSlip = new List<Deposit_Slip__c>();
    public static List<Deposit_Slip__c> InsolvdepositSlip = new List<Deposit_Slip__c>();
    public static Application_Config_Settings__c appConfigFinal = Application_Config_Settings__c.getOrgDefaults();

    public static void DepositSlipLock() {
        appConfigFinal = [SELECT CCS_Final_Deposit_Slip__c, Final_Deposit_Slip__c FROM Application_Config_Settings__c FOR UPDATE]; //CCS and Inolsvency Final Depsoti slip dates
        ccsdepositSlip = [
            SELECT Id, Name
            FROM Deposit_Slip__c
            WHERE CreatedDate = TODAY AND recordType.developerName = 'CCS_Deposit_Slip'
            ORDER BY createdDate DESC
            LIMIT 1
        ]; // Today's CCS Deposit Slips
        InsolvdepositSlip = [
            SELECT Id, Name
            FROM Deposit_Slip__c
            WHERE CreatedDate = TODAY AND recordType.developerName = 'Insolvency_Deposit_Slip'
            ORDER BY createdDate DESC
            LIMIT 1
        ]; // Today's Insolvency Deposit Slips
        //Logic to CCS Deposit Auto Lock
        // Production Issue - Added List empty check
        if (!ccsdepositSlip.isEmpty() && appConfigFinal.CCS_Final_Deposit_Slip__c != system.today()) {
            appConfigFinal.CCS_Final_Deposit_Slip__c = system.today();
            update appConfigFinal;
        }

        //Logic to Insolvency Deposit Auto Lock
        // Production Issue - Added List empty check
        if (!InsolvdepositSlip.isEmpty() && appConfigFinal.Final_Deposit_Slip__c != system.today()) {
            appConfigFinal.Final_Deposit_Slip__c = system.today();
            update appConfigFinal;
        }
    }
}