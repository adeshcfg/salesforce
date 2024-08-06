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
    public static String saveAccountJudgmentRecord(List<Product__c> prodList, Id judgId) {
        List<Account_Judgment__c> prodJudgList = new List<Account_Judgment__c>();
        for (Product__c prod : prodList) {
            Account_Judgment__c profJudg = new Account_Judgment__c();
            profJudg.Judgment__c = judgId;
            profJudg.Product__c = prod.Id;
            profJudg.Status__c = 'Active';
            prodJudgList.add(profJudg);
        }
        if (!prodJudgList.isEmpty()) {
            try {
                Judgment__c judgmentToUpdate = updateJudgmentProducts(prodList, judgId);
                if (judgmentToUpdate != null) {
                    update judgmentToUpdate;
                }
                insert prodJudgList;
            } catch (System.DmlException ex) {
                return readDMLMessage(ex);
            }
        }
        return null;
    }

    /**
     * @description : Method to update product fields with the selected products on Judgment record
     * @author adeshi@a5econsulting.net | 12-05-2023
     * @param prodList
     * @param judgId
     * @return Judgment__c
     **/
    public static Judgment__c updateJudgmentProducts(List<Product__c> prodList, Id judgId) {
        List<Judgment__c> currentJudgment = [
            SELECT Product_1__c, Product_2__c, Product_3__c, Product_4__c, Product_5__c
            FROM Judgment__c
            WHERE Id = :judgId
            LIMIT 1
        ];
        if (currentJudgment.isEmpty()) {
            return null;
        }
        // Will store the index of the product field to start the population from
        Integer productNumberToStart = 1;
        Judgment__c judgmentToUpdate = new Judgment__c(Id = judgId);
        // Get empty product field with the lowest index
        for (Integer i = 1; i < 6; i++) {
            if (String.isBlank(String.valueOf(currentJudgment[0].get('Product_' + i + '__c')))) {
                productNumberToStart = i;
                break;
            }
        }
        for (Product__c product : prodList) {
            // We only have 5 product fields so break if we go above 5 products
            if (productNumberToStart > 5) {
                break;
            }
            judgmentToUpdate.put('Product_' + productNumberToStart + '__c', product.Name);
            productNumberToStart++;
        }
        return judgmentToUpdate;
    }

    public static string readDMLMessage(System.DMLException ex) {
        String errorMessage = ex.getMessage();
        Integer occurence;
        if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
            errorMessage = errorMessage.mid(occurence, errorMessage.length());
            occurence = errorMessage.lastIndexOf(':');
            errorMessage = errorMessage.mid(0, occurence);

            if (errorMessage.indexOf('Class') > 0) {
                errorMessage = errorMessage.split('Class')[0];
            }
        } else {
            errorMessage = ex.getMessage();
        }
        system.debug('EEE ' + errorMessage + 'EE');
        return errorMessage;
    }

    // Return existing Accounts(i.e., Product__c) related to Judgment
    @AuraEnabled
    public static List<Product__c> fetchLinkedAccounts(Id judgId) {
        List<Id> prodIds = new List<Id>();
        for (Account_Judgment__c accJudg : [SELECT Id, Product__c FROM Account_Judgment__c WHERE Judgment__c = :judgId]) {
            prodIds.add(accJudg.Product__c);
        }

        List<Product__c> existingProdList = [
            SELECT Id, Customer__r.Name, DebtNext_Data_ID__c, Name
            FROM Product__c
            WHERE Id IN :prodIds AND RecordTypeId = :distreeRecordTypeId
        ];
        return existingProdList;
    }
    
    @AuraEnabled
    public static String validationCheck(Id judgId) {
        String ErrorMsg = '';
        String judgLegalStatus = '';
        String judgLegalSubStatus = '';
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        
        for (Account_Judgment__c accJudg : [SELECT Id, Product__c,Judgment__r.Legal_Status__c,Judgment__r.Legal_Sub_Status__c FROM Account_Judgment__c WHERE Judgment__c = :judgId]) {
			judgLegalStatus = accJudg.Judgment__r.Legal_Status__c;
            judgLegalSubStatus = accJudg.Judgment__r.Legal_Sub_Status__c;
        }
		for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                          WHERE Product_Parent__c = :judgLegalStatus]){
          mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);                                                                                   
        }
        
        if(!System.Label.Exclude_Judgment_Codes.contains(mapAccountJudgmentCodes.get(judgLegalStatus+judgLegalSubStatus).Codes__c)){
            ErrorMsg = 'You cannot add new product on this judgment because legal status is "'+judgLegalStatus+'" & legal sub status is "'+ judgLegalSubStatus+'"';
        }
        return ErrorMsg;
    }
    
    @AuraEnabled
    public static void deactivateAccJudgRelatedAccounts(Id judgId) {
        List<Id> prodIDs = new List<Id>();
        for (Account_Judgment__c accJudg : [SELECT Id, Product__c FROM Account_Judgment__c WHERE Judgment__c = :judgId]) {
            prodIDs.add(accJudg.Product__c);
        }
        List<Account_Judgment__c> accJudgList = [
            SELECT Id, Status__c
            FROM Account_Judgment__c
            WHERE Product__c IN :prodIDs AND Judgment__c != :judgId AND Status__c = 'Active'
        ];
        for (Account_Judgment__c accJudg : accJudgList) {
            accJudg.Status__c = 'Inactive';
        }
        if (!accJudgList.isEmpty()) {
            Utilities.runAccountJudgmentTrigger = false;
            update accJudgList;
        }
    }
}