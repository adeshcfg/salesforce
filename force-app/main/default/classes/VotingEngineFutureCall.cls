/**************************************************************************************************
 *
 *  Class:
 *
 *  @description : This class is for future method call for the Voting Automation functionality
 *  @author : A5E Consulting
 *  @date : 05/06/2020
 *
 *************************************************************************************************/
public with sharing class VotingEngineFutureCall {
    public static List<Insolvency__c> cpvaCall(List<Insolvency__c> listInsolvency) {
        VotingEngineClientUtil.ParsedResponse parsedResponseValue = new VotingEngineClientUtil.ParsedResponse();
        for (Insolvency__c insolv : listInsolvency) {
            parsedResponseValue = new VotingEngineClientUtil.ParsedResponse();
            if (insolv.Insolvency_Type__c <> 'Consumer Proposal') {
                //Insolvency type is Bankruptcy
                //Populate the Insolvency fields
                insolv.Voting_Decision__c = 'Manually Approved';
                insolv.Manual_Approved_Reason__c = 'Insolvency with ' + insolv.Insolvency_Type__c + ' type';
            } else {
                //Call web service
                parsedResponseValue = VotingEngineClient.submit(insolv);

                //Populate the Insolvency fields
                insolv.Voting_Decision__c = parsedResponseValue.votingStatus;
                insolv.Voting_Request__c = parsedResponseValue.request;
                insolv.Voting_Response__c = parsedResponseValue.response;
                insolv.Manual_Review_Reason__c = parsedResponseValue.resultString;

                // When error received from portal API
                if (insolv.Voting_Decision__c == 'System Error') {
                    insolv.Original_Voting_Decision__c = insolv.Voting_Decision__c;
                    insolv.Voting_Decision_Time_Stamp__c = system.now();
                    continue;
                }

                // Populate the additional insolvency fields - This are the updated for voting engine enhancement requirement.
                insolv.Adjusted_Unsecured_Debt__c = parsedResponseValue.adjustedUnsecuredDebt;
                insolv.Original_Offer_Amount__c = parsedResponseValue.totalPayoutOffered;

                if (parsedResponseValue.surplusIncomePayments != null) {
                    insolv.Surplus_Income_Payments__c = parsedResponseValue.surplusIncomePayments;
                }

                insolv.BK_Duration__c = parsedResponseValue.bkDuration;
                insolv.CP_Net_Payout__c = parsedResponseValue.cpNetPayout;
                insolv.BK_Net_Payout__c = parsedResponseValue.bkNetPayout;

                if (parsedResponseValue.counterWithBKInsteadOfCP != null) {
                    insolv.Counter_With_BK_Instead_Of_CP__c = parsedResponseValue.counterWithBKInsteadOfCP;
                }

                insolv.Proposed_Monthly_Payment__c = parsedResponseValue.proposedMonthlyPayment;
                insolv.Proposed_Counter_Payout__c = parsedResponseValue.proposedCounterPayout;
                insolv.Max_Counter_Monthly_Payment__c = parsedResponseValue.maxCounterMonthlyPayment;

                if (parsedResponseValue.ShouldWeFurtherCounterWithBK != null) {
                    insolv.Further_Counter_With_BK__c = parsedResponseValue.ShouldWeFurtherCounterWithBK;
                }

                insolv.Acceptable_Monthly_Payment__c = parsedResponseValue.acceptableMonthlyPayment;
                insolv.Min_Acceptable_Payout__c = parsedResponseValue.minAcceptablePayout;
                insolv.Adjusted_Unsecured_Debt__c = parsedResponseValue.adjustedUnsecuredDebt;
                insolv.Total_Payout_Offered_AR__c = parsedResponseValue.totalPayoutOfferedAR;
                insolv.Total_Payout_Offered_TR__c = parsedResponseValue.totalPayoutOfferedTR;
                insolv.BK_Net_Payout_AR__c = parsedResponseValue.bkNetPayoutAR;
                insolv.BK_Net_Payout_TR__c = parsedResponseValue.bkNetPayoutTR;
                insolv.CP_Net_Payout_AR__c = parsedResponseValue.cpNetPayoutAR;
                insolv.CP_Net_Payout_TR__c = parsedResponseValue.cpNetPayoutTR;
                insolv.Max_Counter_Payout_AR__c = parsedResponseValue.maxCounterPayoutAR;
                insolv.Max_Counter_Payout_TR__c = parsedResponseValue.maxCounterPayoutTR;
                insolv.Proposed_Counter_Payout_AR__c = parsedResponseValue.proposedCounterPayoutAR;
                insolv.Proposed_Counter_Payout_TR__c = parsedResponseValue.proposedCounterPayoutTR;
                insolv.Min_Acceptable_Payout_AR__c = parsedResponseValue.minAcceptablePayoutAR;
                insolv.Min_Acceptable_Payout_TR__c = parsedResponseValue.minAcceptablePayoutTR;
                insolv.Max_Counter_Payout__c = parsedResponseValue.maxCounterPayout;
                insolv.Notes_For_Salesforce__c = parsedResponseValue.notesForSalesforce;

                //Original Voting Decision provided by Voting Engine
                insolv.Original_Voting_Decision__c = insolv.Voting_Decision__c;

                //If insolvency date is less than 45 days then add auto approved reason
                insolv.Auto_Approved_Reason__c = parsedResponseValue.autoApprovedReason;
            }
            //to track time stamp when voting decision is made
            insolv.Voting_Decision_Time_Stamp__c = system.now();
        }
        return listInsolvency;
    }

    //future function to call the voting automation web service
    @future(callout=true)
    public static void votingAutomationCall(List<Id> insolvencyIdList) {
        List<Insolvency__c> listInsolvency = [
            SELECT
                id,
                name,
                Number_Of_Persons_In_Household__c,
                Number_Of_Persons_In_Household_Below_17__c,
                Food_Grocery_Expenses__c,
                Entertainment_Sports_Expenses__c,
                Gifts_Charitable_Expenses__c,
                Allowances_Expenses__c,
                Dining_Expenses__c,
                Laundry_Dry_Cleaning_Expenses__c,
                Grooming_Toiletries_Expenses__c,
                Clothing_Expenses__c,
                Total_Monthly_Income_Of_Family__c,
                Monthly_Surplus_Deficit_Of_Family__c,
                Number_of_Payments__c,
                Non_Discretionary_Other_Expenditure__c,
                Death_Clause__c,
                Acceleration_Clause__c,
                Trustee_Comments_Notes__c,
                Insolvency_Type__c,
                Debtor_1_Mailing_State_Province__c,
                Debtor_Age__c,
                Insolvency_Created_Date__c,
                Total_Unsecured_Liabilities_Clc__c,
                Secured_Debts_Unsecured_Portion__c,
                Bulk_Payment_Amount__c,
                Payment_Amount__c,
                Total_Estimated_Realizable_Value__c,
                Is_Spouse_Disclosing_Income__c,
                Available_Monthly_Income_Of_Family__c,
                Debtor_Portion_Of_Monthly_Income__c,
                Ever_been_Bankrupt_Before__c,
                Other_Expenses__c,
                Other_Housing_Expenses__c,
                Other_Insurance_Expenses__c,
                Other_Living_Expenses__c,
                Other_Medical_Expenses__c,
                Other_Personal_Expenses__c,
                Other_TransportationExpenses__c,
                Other_Payments__c,
                Insolvency_Date__c,
                Telephone_Expenses__c,
                Internet_Expenses__c,
                Cable_Expenses__c,
                Hydro_Expenses__c,
                Heating_Gas_Oil_Expenses__c,
                Water_Expenses__c,
                Smoking_Expenses__c,
                Alcohol_Expenses__c,
                Car_Lease_Payments_Expenses__c,
                Repair_Maintenance_Gas_Expenses__c,
                Public_Transportation_Expenses__c
            FROM Insolvency__c
            WHERE id IN :insolvencyIdList
        ];
        List<Insolvency__c> listInsolvencyToUpdate = cpvaCall(listInsolvency);
        if (!listInsolvencyToUpdate.isEmpty()) {
            update listInsolvencyToUpdate;
        }
    }
}
