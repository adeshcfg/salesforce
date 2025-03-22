/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Insolvency Payment object 
 *  @author : A5E Consulting
 *  @date : 05/21/2024
 
 *************************************************************************************************/
public class InsolvencyPaymentsTriggerHandler{
    public static boolean runInsolvencyPaymentTrigger = true;
    
	public static void handleBeforeDelete(List<Insolvency_Payment__c> insolvPaymentRecords){
		ArchiveUnarchiveUtility.insertDeletedRecords(insolvPaymentRecords);
	 }
	//After Insert
    public static void handleAfterInsert(List<Insolvency_Payment__c> insolvPaymentsNew){
        System.debug('handleAfterInsert');
		ArchiveUnarchiveUtility.assignExternalCorID(insolvPaymentsNew);
        InsolvencyPaymentsTriggerHandler.runInsolvencyPaymentTrigger = false;
	}
    //Before Update
    public static void handleBeforeUpdate(List<Insolvency_Payment__c> insolvPaymentsNew, Map<Id, Insolvency_Payment__c> oldMap) {
        updateCTBInsolvencyPaymentStatus(insolvPaymentsNew,'insolvency Payment');
        InsolvencyPaymentsTriggerHandler.runInsolvencyPaymentTrigger = false;
    }
    
    //Before Insert
    public static void handleBeforeInsert(List<Insolvency_Payment__c> insolvPaymentsNew){
        updateCTBInsolvencyPaymentStatus(insolvPaymentsNew,'insolvency Payment');        
    }
    
    public static void updateCTBInsolvencyPaymentStatus(List<Insolvency_Payment__c> insolvPaymentsNew,String checkStatus){
        Set<ID> insolAcctIds = new Set<ID>();
        for(Insolvency_Payment__c insolvPayment : insolvPaymentsNew){
            insolAcctIds.add(insolvPayment.Insolvency_Account__c);
        }
       
        Map<String,String> insolAcctMap = new Map<String,String>();
        for(Insolvency_Account__c insolAcct : [select id,name,Client_Identifier__c,RecordTypeId from Insolvency_Account__c where id IN: insolAcctIds and 
                                                    RecordType.DeveloperName = 'Canadian_Tire_Insolvency_Account']){
            insolAcctMap.put(insolAcct.id,insolAcct.Client_Identifier__c);
        }
        
        String errorMsg;
        String accNumberRegex = '^[0-9]+$';
        Pattern MyPattern1 = Pattern.compile(accNumberRegex);
        Matcher MyMatcher1;
        Map<string,Insolvency_Payment__c> insolPaymentMap = new Map<string,Insolvency_Payment__c>();
        for(Insolvency_Payment__c insolPayData : insolvPaymentsNew){
            if(!Test.isRunningTest()){
                MyMatcher1 = MyPattern1.matcher(insolPayData.Account_Number__c);
            }
            errorMsg = '';
            Boolean fieldMissing = false;
            if(insolAcctMap.get(insolPayData.Insolvency_Account__c) == 'Canadian Tire'){
                if(insolPayData.Payment_Amount__c < 0 || insolPayData.Payment_Amount__c == 0){
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
                if(fieldMissing == False && insolPayData.Payment_Sub_Status__c != 'Sent on File'){
                    insolPayData.Error_Message__c = '';
                    insolPayData.Payment_Sub_Status__c = 'Pending File';
                }
                if(fieldMissing == True){
                    insolPayData.Error_Message__c = errorMsg;
                    insolPayData.Payment_Sub_Status__c = 'File Error Parsing Record';
                } 
                insolPaymentMap.put(insolPayData.id,insolPayData);
            }
        }
                
        string errorValidationRuleMsg = '';
        if(checkStatus == 'Insolvency Account'){
            try{
           		 update insolPaymentMap.values();
            }catch (DMLException ex) {
                errorValidationRuleMsg = AddNewAccountToJudgmentController.readDMLMessage(ex);
                throw new CustomException(errorValidationRuleMsg);
            }
        }
      
    }
    
    public class CustomException extends Exception {
        
        
    }
}