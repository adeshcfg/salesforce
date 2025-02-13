@isTest

public class TestRemittanceReportUtility {
     //Insolvency Record
     Insolvency__c insolv1 = new Insolvency__c();
     insolv1.Name = '00-000001';
     insolv1.Client_Identifiers__c = 'Scotia Bank';
     insolv1.Sent_For_Owner_Review_Date__c = System.today();
     insert insolv1;

     list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c' AND name LIKE '%SPL%']
        );

     Insolvency_Account__c insolvencyAccount = new Insolvency_Account__c();
        insolvencyAccount.RecordTypeId = recordTypeList[0].Id;
        insolvencyAccount.Name = '4537049889659';
        insolvencyAccount.Insolvency_Status__c = 'No PoC Required';
        insolvencyAccount.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolvencyAccount.Claim_Type__c = 'Unsecured';
        insolvencyAccount.Insolvency__c = insolv1.Id;
        insolvencyAccount.Account_Number_Without_Space__c = '4537049889659';
        insolvencyAccount.Portfolio_Group_Name__c = 'CCL001';
        insolvencyAccount.Previous_Account_Reference__c = '111';
        insolvencyAccount.Debtor_1_Estate_Number__c = '00-000001';
        insolvencyAccount.Client_Identifier__c = 'Scotia';
        insert insolvencyAccount;

        Insolvency_Payment__c paymentInstance2 = new Insolvency_Payment__c();
        paymentInstance2.Insolvency_Account__c = insolvencyAccount.ID;
        paymentInstance2.Payment_Posting_Date__c = system.today();
        paymentInstance2.Payment_Amount__c = -321.98;
        paymentInstance2.Payment_Reversed__c = 'Stopped';
        paymentInstance2.Payment_Reversal_Date__c = system.today();
        insert paymentInstance2;

        RemittanceReportUtility.getReportNameList();
}
