/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Insolvency Payment object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 
 *************************************************************************************************/
public class InsolvencyPaymentsTriggerHandler{
	
	//After Insert
    public static void handleAfterInsert(List<Insolvency_Payment__c> insolvPaymentsNew){
		map<id,Insolvency_Payment__c> insolvPaymentMap = new map<id,Insolvency_Payment__c>();
		for(Insolvency_Payment__c insolvPayment : [select ID,External_Correlation_ID__c from Insolvency_Payment__c where ID IN : insolvPaymentsNew]){
            insolvPayment.External_Correlation_ID__c = insolvPayment.ID;
            insolvPaymentMap.put(insolvPayment.ID,insolvPayment);
         }
         if(!insolvPaymentMap.isEmpty()){
            update insolvPaymentMap.values();
         }
	}
}