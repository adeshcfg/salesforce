/**************************************************************************************************
 *
 *  Class:    InsolvencyAccountToCreditorAccountCntrl
 *
 *  @description : Copies specified fields from Insolvency Account and creates Creditor Account
 *  @author : A5E Consulting
 *  @date : 05/05/2020
 *
 *************************************************************************************************/
public class InsolvencyAccountToCreditorAccountCntrl {
    
    // variable to store current Insolvency Record
    @TestVisible
    Insolvency_Account__c insolvAccount;
    
    // controller
    public InsolvencyAccountToCreditorAccountCntrl(ApexPages.StandardController controller) {
         insolvAccount = (Insolvency_Account__c)controller.getRecord();
         insolvAccount = [SELECT   Id, 
                                Name, 
                                Creditor_Name__c, 
                                Address_of_Creditor__c, 
                                Unsecured_Asset_Amount__c,
                                Secured_Asset_Amount__c,
                                Preferred_Amount__c,
                                Claim_Type__c,
                                Liabilities_Type_Code__c, 
                                Liability_Id__c,
                                Creditor_Id__c,
                                Insolvency__c,
                                Created_By_Doc_Parser__c 
                        FROM Insolvency_Account__c
                        WHERE Id =: insolvAccount.Id];
    }

    // Method creates Creditor account from Creditor account, and deletes Insolvency account
    public Pagereference createCreditorAccount(){
        Creditor_Account__c creditorAccount = new Creditor_Account__c();
        creditorAccount.Name = insolvAccount.Name;
        creditorAccount.Created_By_Doc_Parser__c = insolvAccount.Created_By_Doc_Parser__c;
        if(insolvAccount.Creditor_Name__c != NULL){
            creditorAccount.Creditor_Name__c = insolvAccount.Creditor_Name__c;
        }
        if(insolvAccount.Address_of_Creditor__c != NULL){
            creditorAccount.Address_of_Creditor__c = insolvAccount.Address_of_Creditor__c;
        }        
        if(insolvAccount.Unsecured_Asset_Amount__c != NULL){
            creditorAccount.Unsecured_Asset_Amount__c = insolvAccount.Unsecured_Asset_Amount__c;
        }
        if(insolvAccount.Secured_Asset_Amount__c != NULL){
            creditorAccount.Secured_Asset_Amount__c = insolvAccount.Secured_Asset_Amount__c;
        }
        if(insolvAccount.Preferred_Amount__c != NULL){
        creditorAccount.Preferred_Amount__c = insolvAccount.Preferred_Amount__c;
        }
        if(insolvAccount.Claim_Type__c != NULL){
            creditorAccount.Claim_Type__c = insolvAccount.Claim_Type__c;
        }
        if(insolvAccount.Liabilities_Type_Code__c != NULL){
            creditorAccount.Liabilities_Type_Code__c = insolvAccount.Liabilities_Type_Code__c;
        }
         
        // Insolvency Account Related creditorId  & liabilityId 
        if(insolvAccount.Liability_Id__c != NULL){
            creditorAccount.Liability_Id__c = insolvAccount.Liability_Id__c;
        }
        if(insolvAccount.Creditor_Id__c != NULL){
            creditorAccount.Creditor_Id__c = insolvAccount.Creditor_Id__c;
        }  
        
        if(insolvAccount.Insolvency__c != NULL){
            creditorAccount.Insolvency__c = insolvAccount.Insolvency__c;
        }
        try{
            insert creditorAccount;
            delete insolvAccount;
            PageReference creditorAccountPage = new PageReference('/' + creditorAccount.id);
        return creditorAccountPage;
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        return null;
    }
}