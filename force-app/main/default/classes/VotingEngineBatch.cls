/**
 * @description       : Batch class to do bulk voting engine calls in batch size of 90
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 03-28-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
public class VotingEngineBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public List<String> insolvencyIdList = new List<String>();

    public VotingEngineBatch(List<String> insolvencyIdList) {
        this.insolvencyIdList = insolvencyIdList;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id,name,Number_Of_Persons_In_Household__c,Number_Of_Persons_In_Household_Below_17__c,Food_Grocery_Expenses__c,Entertainment_Sports_Expenses__c,Gifts_Charitable_Expenses__c,Allowances_Expenses__c,Dining_Expenses__c,Laundry_Dry_Cleaning_Expenses__c,Grooming_Toiletries_Expenses__c,Clothing_Expenses__c,Total_Monthly_Income_Of_Family__c,Monthly_Surplus_Deficit_Of_Family__c,Number_of_Payments__c,Non_Discretionary_Other_Expenditure__c,Death_Clause__c,Acceleration_Clause__c,Trustee_Comments_Notes__c,Insolvency_Type__c,Debtor_1_Mailing_State_Province__c,Debtor_Age__c,Insolvency_Created_Date__c,Total_Unsecured_Liabilities_Clc__c,Secured_Debts_Unsecured_Portion__c,Bulk_Payment_Amount__c,Payment_Amount__c,Total_Estimated_Realizable_Value__c,Is_Spouse_Disclosing_Income__c,Available_Monthly_Income_Of_Family__c,Debtor_Portion_Of_Monthly_Income__c,Ever_been_Bankrupt_Before__c,Other_Expenses__c,Other_Housing_Expenses__c,Other_Insurance_Expenses__c,Other_Living_Expenses__c,Other_Medical_Expenses__c,Other_Personal_Expenses__c,Other_TransportationExpenses__c,Other_Payments__c,Insolvency_Date__c,Telephone_Expenses__c,Internet_Expenses__c,Cable_Expenses__c,Hydro_Expenses__c,Heating_Gas_Oil_Expenses__c,Water_Expenses__c,Smoking_Expenses__c,Alcohol_Expenses__c,Car_Lease_Payments_Expenses__c,Repair_Maintenance_Gas_Expenses__c,Public_Transportation_Expenses__c,Rent_Mortgage_Hypothec_Expenses__c,Property_Taxes_Condo_Fees_Expenses__c,Furniture_Expenses__c,Vehicle_Expenses__c,House_Expenses__c,Furniture_Contents_Expenses__c,Life_Insurance_Expenses__c,Payments_To_Proposal__c,Payments_Other_Than_Mortgage_Vehicle__c,Payment_to_Financial_Advisor__c FROM Insolvency__c WHERE Id IN :insolvencyIdList'
        );
    }

    public void execute(Database.BatchableContext bc, List<Insolvency__c> listInsolvency) {
        try {
            startProcessing(listInsolvency);
        } catch (Exception ex) {
            System.debug('Exception in VotingEngineBatch ' + ex.getStackTraceString());
            Insolvency_Error__c inslErr = PocDocUtility.handleException(ex, listInsolvency[0].Id);
            inslErr.Action__c = 'Voting Automation Batch';
            insert inslErr;
        }
    }

    public void startProcessing(List<Insolvency__c> listInsolvency) {
        List<Insolvency__c> listInsolvencyToUpdate = VotingEngineFutureCall.cpvaCall(listInsolvency);
        if (!listInsolvencyToUpdate.isEmpty()) {
            update listInsolvencyToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}