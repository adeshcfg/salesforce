/**************************************************************************************************
*
*  Class:    
*
*  @description : This is a trigger handler class for Creditor Account object 
*  @author : A5E Consulting
*  @date : 11/25/2024

*************************************************************************************************/
public class CreditorAccountTriggerHandler{
    
    //After Insert
    public static void handleAfterInsert(List<Creditor_Account__c> CreditAccNew){
        ArchiveUnarchiveUtility.assignExternalCorID(CreditAccNew);
    }
    public static void handleBeforeDelete(List<Creditor_Account__c> CreditAccOld){
        ArchiveUnarchiveUtility.insertDeletedRecords(CreditAccOld);
    }
}