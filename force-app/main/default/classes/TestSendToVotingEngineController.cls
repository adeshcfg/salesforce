@isTest
public class TestSendToVotingEngineController {

    static testMethod void SendToVotingEngine(){
                    
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new VotingEngineClientMockResponse());
        
        Voting_Automation_Reason_Mapping__c votingReasonMapping = new Voting_Automation_Reason_Mapping__c();
        votingReasonMapping.Name = 'ENTERTAINMENT_EXCEEDED';
        votingReasonMapping.Value__c = 'Entertainment limit exceeded';
        insert votingReasonMapping;
        
        API_Call_Details__c APICallDetailsInst = new API_Call_Details__c();
        APICallDetailsInst.Name = 'Voting Automation API';
        APICallDetailsInst.AuthorizationtUrl__c = 'https://login.automationurl.com/{{dptenandId}}/oauth2/v2.0/token';
        APICallDetailsInst.Client_ID__c = 'xyxyxyxyxyxyxyxxyxyx'; 
        APICallDetailsInst.Client_Secret__c = 'yxyxyxyxyx';
        APICallDetailsInst.PDF_API_URL__c = 'https://paschidev.azure-api.net/canaccede/v1/bdm/cpva/5a008cd1-adc4-41c0-8c6e-cd22683f7cba?decisions=leExtendedResults';
        APICallDetailsInst.Proxy_Client_ID__c = 'xyxyxyxyxyx';
        APICallDetailsInst.Tenand_ID__c = 'yyxyxyxyxyxxyxy';
        insert APICallDetailsInst;

        //create insolvency record
        Insolvency__c insolvencyInstance = new Insolvency__c();
            insolvencyInstance.Name = '12456789';
            insolvencyInstance.eligible_for_voting_decision__c = true;
            insolvencyInstance.Debtor_2_Estate_Number__c = '985236987';
            insolvencyInstance.Insolvency_Status__c = 'Active';
            //insolvencyInstance.Insolvency_Type__c = 'Consumer Proposal';
            insolvencyInstance.Sent_For_Owner_Review_Date__c = null;
            //insolvencyInstance.Revival_Date__c = System.today();
            insolvencyInstance.Number_Of_Persons_In_Household__c = 3;
            insolvencyInstance.Number_Of_Persons_In_Household_Below_17__c = 1;
            insolvencyInstance.Food_Grocery_Expenses__c = 100;
            insolvencyInstance.Entertainment_Sports_Expenses__c = 50;
            insolvencyInstance.Gifts_Charitable_Expenses__c = 30;
            insolvencyInstance.Allowances_Expenses__c = 20;
            
            insolvencyInstance.Debtor_1_Mailing_State_Province__c = 'Alberta';
            //Debtor_Age__c = null,
            insolvencyInstance.Secured_Debts_Unsecured_Portion__c = 100;
            insolvencyInstance.Bulk_Payment_Amount__c = 10;
            insolvencyInstance.Payment_Amount__c = 20;
            insolvencyInstance.Total_Estimated_Realizable_Value__c = 15;
            //Is_Spouse_Disclosing_Income__c = true,
            insolvencyInstance.Available_Monthly_Income_Of_Family__c = 30;
            insolvencyInstance.Debtor_Portion_Of_Monthly_Income__c = 58;
            insolvencyInstance.Ever_been_Bankrupt_Before__c = 'Yes';
            //Other_Expenses__c = null;
            //insolvencyInstance.Budgetary_Surplus_Deficit__c = 50;
         
            insert insolvencyInstance;
            
            ApexPages.currentPage().getParameters().put('id', insolvencyInstance.Id);
            ApexPages.StandardController sc = new ApexPages.StandardController(insolvencyInstance);
            
            SendToVotingEngineController send = new SendToVotingEngineController(sc);
            send.mypageloadingmethod();


        
        Test.stopTest();
    }
    
}