/**************************************************************************************************
 *
 *  Class:   AddNewAccountToJudgmentController
 *
 *  @description :      Adding Judgment to Account(i.e., Product__c)  with Active status
 *                      Return existing Account(i.e., Product__c) related to Judgment
 *  @author : A5E Consulting
 *  @date : 21/07/2019
 * 
 *************************************************************************************************/
 public class AddNewAccountToJudgmentController {
    
    private static Id distreeRecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByDeveloperName().get('Distressed_Account').getRecordTypeId();
    
    // Adding new AccountJudgment with Active 'Status'
    @AuraEnabled
    public static String saveAccountJudgmentRecord(List<Product__c> prodList, Id judgId){
        List<Account_Judgment__c> prodJudgList = new List<Account_Judgment__c>();
        for(Product__c prod: prodList){
            Account_Judgment__c profJudg = new Account_Judgment__c();
            profJudg.Judgment__c = judgId;
            profJudg.Product__c = prod.Id;
            profJudg.Status__c = 'Active';
            prodJudgList.add(profJudg);
        }
        if(! prodJudgList.isEmpty()){
            try{
            	insert prodJudgList;
            }catch(System.DmlException ex){
                return readDMLMessage(ex);
            }
        }
        return null;
    }
     
    public static string readDMLMessage(System.DMLException ex){
        String errorMessage = ex.getMessage();
        Integer occurence;
        if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
            errorMessage = errorMessage.mid(occurence, errorMessage.length());
            occurence = errorMessage.lastIndexOf(':');
            errorMessage = errorMessage.mid(0, occurence);
            
            if(errorMessage.indexOf('Class') > 0){
                errorMessage = errorMessage.split('Class')[0];
            }
        }
        else {
            errorMessage = ex.getMessage();
        }
         system.debug('EEE '+errorMessage+'EE');
         return errorMessage;
     }
    
    // Return existing Accounts(i.e., Product__c) related to Judgment
    @AuraEnabled
    public static List<Product__c>   fetchLinkedAccounts(Id judgId){

        List<Id> prodIds = new List<Id>();
        for(Account_Judgment__c accJudg : [SELECT Id, Product__c  FROM Account_Judgment__c where Judgment__c =: judgId]){
            prodIds.add(accJudg.Product__c);
        }

        List<Product__c> existingProdList = [SELECT     Id, 
                                    Customer__r.Name, 
                                    DebtNext_Data_ID__c,
                                    Name 
                            FROM 
                                    Product__c 
                            WHERE Id IN: prodIds
                            AND RecordTypeId =: distreeRecordTypeId];
        return existingProdList;
    }
     @AuraEnabled
    public static void deactivateAccJudgRelatedAccounts(Id judgId){
        List<Id> prodIDs = new List<Id>();
        for(Account_Judgment__c accJudg: [SELECT Id, Product__c FROM Account_Judgment__c WHERE Judgment__c =: judgId]){
            prodIDs.add(accJudg.Product__c);
        }
        List<Account_Judgment__c> accJudgList = [SELECT Id, Status__c FROM Account_Judgment__c WHERE Product__c IN: prodIDs AND Judgment__c !=: judgId AND Status__c = 'Active'];
        for(Account_Judgment__c accJudg: accJudgList){
            accJudg.Status__c = 'Inactive';
        }
        if(!accJudgList.isEmpty()){
          Utilities.runAccountJudgmentTrigger = FALSE;
          update accJudgList;  
        }
        
    }
}