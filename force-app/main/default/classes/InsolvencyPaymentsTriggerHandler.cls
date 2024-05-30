/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Insolvency Payment object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 
 *************************************************************************************************/
public class InsolvencyPaymentsTriggerHandler{
	public static void handleBeforeDelete(List<Insolvency_Payment__c> insolvPaymentRecords){
		list<Deleted_Records__c> deletedRecords=new list<Deleted_Records__c>();
		for(Insolvency_Payment__c insolvPayment: insolvPaymentRecords){
				ID recordID=insolvPayment.ID;
				Deleted_Records__c deletedRec=new Deleted_Records__c();
				deletedRec.Object_Name__c= recordId.getSObjectType().getDescribe().getName();
				deletedRec.Salesforce_Record_Id__c=insolvPayment.External_Correlation_ID__c;
				deletedRecords.add(deletedRec);
		}
		if(!deletedRecords.isEmpty()){
			insert deletedRecords;
		}
	 }
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