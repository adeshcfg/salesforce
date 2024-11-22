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
		for(Insolvency_Payment__c insolvPayment : [select ID,Name,External_Correlation_ID__c,Insolvency_Payment_Name_Original__c from Insolvency_Payment__c where ID IN : insolvPaymentsNew]){
            insolvPayment.External_Correlation_ID__c = insolvPayment.ID;
			insolvPayment.Insolvency_Payment_Name_Original__c=insolvPayment.Name;
            insolvPaymentMap.put(insolvPayment.ID,insolvPayment);
         }
         if(!insolvPaymentMap.isEmpty()){
            update insolvPaymentMap.values();
         }
        
        
	}
    //Before Insert
    public static void handleBeforeInsert(List<Insolvency_Payment__c> insolvPaymentsNew){
        Set<ID> insolAcctIds = new Set<ID>();
        for(Insolvency_Payment__c insolvPayment : insolvPaymentsNew){
            insolAcctIds.add(insolvPayment.Insolvency_Account__c);
        }
       
        Map<String,String> insolAcctMap = new Map<String,String>();
        List<Insolvency_Account__c> insolAcctData = [select id,name,Client_Identifier__c,RecordTypeId from Insolvency_Account__c where id IN: insolAcctIds and 
                                                    RecordType.DeveloperName = 'Canadian_Tire_Insolvency_Account'];
        for(Insolvency_Account__c insolAcct : insolAcctData){
            insolAcctMap.put(insolAcct.id,insolAcct.Client_Identifier__c);
        }
        
        String errorMsg;
        String accNumberRegex = '^[0-9]+$';
        Pattern MyPattern1 = Pattern.compile(accNumberRegex);
        Matcher MyMatcher1;
        
        for(Insolvency_Payment__c insolPayData : insolvPaymentsNew){
            if(!Test.isRunningTest()){
                MyMatcher1 = MyPattern1.matcher(insolPayData.Account_Number__c);
            }
            
            errorMsg = '';
            Boolean fieldMissing = false;
            if(insolAcctMap.get(insolPayData.Insolvency_Account__c) == 'Canadian Tire'){
                if(insolPayData.Payment_Amount__c < 0){
                    errorMsg = 'Payment amount should be greater than zero ,';
                    fieldMissing = true;
                } 
                if(insolPayData.Is_Payment_Remitted__c == true){
                    errorMsg += 'Is payment remitted should be false ,';
                    fieldMissing = true;
                }
                if(insolPayData.Payment_Reversed__c != NULL){
                    errorMsg += 'Reversal payments not inclued ,';
                    fieldMissing = true;
                }
                if(insolPayData.Payment_Reversal_Date__c != NULL){
                    errorMsg += 'Payment reversal date should be blank ,';
                    fieldMissing = true;
                }
                if(!Test.isRunningTest()){
                    if(insolPayData.Account_Number__c.length() > 16){
                        errorMsg += 'Insolvency account number is greater than 16 digit ,';
                        fieldMissing = true;
                    }
                    if(MyMatcher1.matches() == False){
                        errorMsg += 'Insolvency account number shoud be numberic ,';
                        fieldMissing = true;
                    }
                }
                errorMsg = errorMsg.removeEnd(' ,');
                
                if(fieldMissing == False){
                    insolPayData.Error_Message__c = '';
                }
               
                if(fieldMissing == True){
                    insolPayData.Error_Message__c = errorMsg;
                    insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                } 
            }
            system.debug('Error_Message__c::'+insolPayData.Error_Message__c);
            system.debug('Payment_Sub_Status__c::'+insolPayData.Payment_Sub_Status__c);
        }
    }
}