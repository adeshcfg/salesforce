@isTest
public class TestVotingEngineFutureCall {
    public static testMethod void testVotingAutomationCall() {
        //set Mockresponse class
        Test.setMock(HttpCalloutMock.class, new VotingEngineClientMockResponse());

        Voting_Automation_Reason_Mapping__c votingReasonMapping = new Voting_Automation_Reason_Mapping__c();
        votingReasonMapping.Name = 'ENTERTAINMENT_EXCEEDED';
        votingReasonMapping.Value__c = 'Entertainment limit exceeded';
        insert votingReasonMapping;

        API_Call_Details__c APICallDetailsInst = new API_Call_Details__c();
        APICallDetailsInst.Name = 'Voting Automation API';
        APICallDetailsInst.AuthorizationtUrl__c = 'https://login.automotion.com/{{dptenandId}}/oauth2/v2.0/token';
        APICallDetailsInst.Client_ID__c = 'xyxyxyxyxyxyxyxxyxyx';
        APICallDetailsInst.Client_Secret__c = 'yxyxyxyxyx';
        APICallDetailsInst.PDF_API_URL__c = 'https://paschidev.azure-api.net/canaccede/v1/bdm/cpva/5a008cd1-adc4-41c0-8c6e-cd22683f7cba?decisions=leExtendedResults';
        APICallDetailsInst.Proxy_Client_ID__c = 'xyxyxyxyxyx';
        APICallDetailsInst.Tenand_ID__c = 'yyxyxyxyxyxxyxy';
        insert APICallDetailsInst;

        Trustee_Fees__c trusteeFees = Trustee_Fees__c.getOrgDefaults();
        trusteeFees.Trustee_Administration_Fee__c = 10;
        trusteeFees.Counselling_Fee__c = 10;
        trusteeFees.Receiver_Fee__c = 10;
        trusteeFees.Trustee_Variable_Fee_Rate__c = 10;
        insert trusteeFees;

        Insolvency__c insolvencyInstance = new Insolvency__c(
            Name = '12456789',
            eligible_for_voting_decision__c = true,
            Debtor_2_Estate_Number__c = '985236987',
            Insolvency_Status__c = 'Active',
            Insolvency_Type__c = 'Consumer Proposal',
            Sent_For_Owner_Review_Date__c = null,
            //Revival_Date__c = System.today(),
            Number_Of_Persons_In_Household__c = 3,
            Number_Of_Persons_In_Household_Below_17__c = 1,
            Food_Grocery_Expenses__c = 100,
            Entertainment_Sports_Expenses__c = 50,
            Gifts_Charitable_Expenses__c = 30,
            Allowances_Expenses__c = 20,
            Debtor_1_Mailing_State_Province__c = 'Alberta',
            Secured_Debts_Unsecured_Portion__c = 100,
            Bulk_Payment_Amount__c = 10,
            Payment_Amount__c = 20,
            Total_Estimated_Realizable_Value__c = 15,
            Available_Monthly_Income_Of_Family__c = 30,
            Debtor_Portion_Of_Monthly_Income__c = 58,
            Ever_been_Bankrupt_Before__c = 'Yes',
            //Budgetary_Surplus_Deficit__c = 50,
            Trustee_Comments_Notes__c = 'The payments proposed under the terms of the proposal are within the debtors family means and will result in more funds being available for distribution to creditors then would otherwise be available through a bankruptcy.',
            Other_Housing_Expenses__c = 10,
            Other_Personal_Expenses__c = 20,
            Other_Medical_Expenses__c = 30,
            Other_Living_Expenses__c = 40,
            Other_TransportationExpenses__c = 50,
            Other_Insurance_Expenses__c = 60,
            Other_Payments__c = 70,
            Insolvency_date__c = Date.newInstance(2022, 3, 1),
            Allow_Insolvency_Date_In_Past__c = true
        );

        insert insolvencyInstance;

        List<Id> listInsolvency = new List<Id>();
        listInsolvency.add(insolvencyInstance.Id);

        Test.startTest();
        VotingEngineFutureCall.votingAutomationCall(listInsolvency);
        Database.executeBatch(new VotingEngineBatch(listInsolvency), 90);
        Test.stopTest();
    }
}
