/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Creditor Account object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 
 *************************************************************************************************/
public class CreditorAccountTriggerHandler{
	
	//After Insert
    public static void handleAfterInsert(List<Creditor_Account__c> CreditAccNew){
		map<id,Creditor_Account__c> CreditAccMap = new map<id,Creditor_Account__c>();
		for(Creditor_Account__c CreditAcc : [select ID,External_Correlation_ID__c from Creditor_Account__c where ID IN : CreditAccNew]){
            CreditAcc.External_Correlation_ID__c = CreditAcc.ID;
            CreditAccMap.put(CreditAcc.ID,CreditAcc);
         }
         if(!CreditAccMap.isEmpty()){
            update CreditAccMap.values();
         }
	}
}