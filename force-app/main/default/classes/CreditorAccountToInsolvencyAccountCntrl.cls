/**************************************************************************************************
 *
 *  Class:    CreditorAccountToInsolvencyAccountCntrl
 *
 *  @description : Copies specified fields from Creditor Account to creates Insolvency Account
 *  @author : A5E Consulting
 *  @date : 05/05/2020
 
 *************************************************************************************************/
public class CreditorAccountToInsolvencyAccountCntrl {
    
    // Variable captures selected record type on VF page
    public String selectedRecordType{set;get;}
    
    // variable stores current Creditor Account, and is visible in test class
    @TestVisible
    Creditor_Account__c creditorAccount;
    
    // Controller
    public CreditorAccountToInsolvencyAccountCntrl(ApexPages.StandardController controller) {
        creditorAccount = (Creditor_Account__c) controller.getRecord();
        creditorAccount = [SELECT   Id, 
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
                        FROM Creditor_Account__c
                        WHERE Id =: creditorAccount.Id];
    }
    
    //Fetch Insolvency Record Types
    public List < SelectOption > getRecordTypes() {
        List < SelectOption > types = new List < SelectOption > ();        
        for(RecordType rType: [SELECT Id, Name FROM RecordType WHERE SObjectType='Insolvency_Account__c' and (NOT name like 'Canadian%')]){
                types.add(new SelectOption(rType.Id, rType.Name));    
        }      
        return types;
    }

    // Method creates Insolvency account from Creditor account, and delete creditor account
    public Pagereference createInsolvencyAccount(){
        Insolvency_Account__c insolvAccount = new Insolvency_Account__c();
        insolvAccount.Name = creditorAccount.Name;
        insolvAccount.RecordTypeId = selectedRecordType;
        insolvAccount.Created_By_Doc_Parser__c = creditorAccount.Created_By_Doc_Parser__c;
        if(creditorAccount.Creditor_Name__c != NULL){
            insolvAccount.Creditor_Name__c = creditorAccount.Creditor_Name__c;
        }
        if(creditorAccount.Address_of_Creditor__c != NULL){
            insolvAccount.Address_of_Creditor__c = creditorAccount.Address_of_Creditor__c;
        }       
        if(creditorAccount.Unsecured_Asset_Amount__c != NULL){
            insolvAccount.Unsecured_Asset_Amount__c = creditorAccount.Unsecured_Asset_Amount__c;
        }
        if(creditorAccount.Secured_Asset_Amount__c != NULL){
            insolvAccount.Secured_Asset_Amount__c = creditorAccount.Secured_Asset_Amount__c;
        }
        if(creditorAccount.Preferred_Amount__c != NULL){
            insolvAccount.Preferred_Amount__c = creditorAccount.Preferred_Amount__c;
        }
        if(creditorAccount.Claim_Type__c != NULL){
            insolvAccount.Claim_Type__c = creditorAccount.Claim_Type__c;
        }
        if(creditorAccount.Liabilities_Type_Code__c != NULL){
            insolvAccount.Liabilities_Type_Code__c = creditorAccount.Liabilities_Type_Code__c;
        }
       
        // creditor Account Related creditorId  & liabilityId 
        if(creditorAccount.Liability_Id__c != NULL){
            insolvAccount.Liability_Id__c = creditorAccount.Liability_Id__c;
        }
        if(creditorAccount.Creditor_Id__c != NULL){
            insolvAccount.Creditor_Id__c = creditorAccount.Creditor_Id__c;
        }
        
        if(creditorAccount.Insolvency__c != NULL){
            insolvAccount.Insolvency__c = creditorAccount.Insolvency__c;
        }
        try{
            insert insolvAccount;
            delete creditorAccount;
            PageReference creditorAccountPage = new PageReference('/' + insolvAccount.id);
        return creditorAccountPage;
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        return null;        
    }
}