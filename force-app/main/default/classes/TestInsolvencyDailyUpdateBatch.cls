@isTest
public class TestInsolvencyDailyUpdateBatch {
	static testMethod void insolvencyBeforeUpdateTest(){
       
        //Insolvency Record
        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456783';
        insolv.Client_Identifiers__c = 'SPL';
        insolv.Insolvency_Type__c = 'Bankruptcy';
        insolv.Insolvency_Status__c = 'Annulled';
        insolv.Debtor_1_Mailing_Street__c = '345 testing';
        insolv.Debtor_1_Mailing_City__c = 'CA';
        insert insolv;
        
        //Insolvency Account records
        List<Insolvency_Account__c> iaList = new List<Insolvency_Account__c>();
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = Schema.SObjectType.Insolvency_Account__C.getRecordTypeInfosByName().get('Canadian Tire Insolvency Account').getRecordTypeId();
        ia1.Name = 'Test-001';
        ia1.Insolvency_Status__c = 'Annulled';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 1000;
        ia1.Debtor_1_First_Name__c = 'test';
        ia1.Debtor_1_Last_Name__c = 'test';
        
        ia1.Insolvency__c = insolv.Id;   
        //insert ia1;
        List<Insolvency_Account__c> scope = new List<Insolvency_Account__c>();
        scope.add(ia1);
        insert scope;
        Test.startTest();
        //Database.executeBatch(new InsolvencyDailyUpdateBatch(),20);
        //InsolvencyDailyUpdateBatch obj = new InsolvencyDailyUpdateBatch();
		//DataBase.executeBatch(obj); 
		//obj.execute(); 
		InsolvencyDailyUpdateBatch cb = New InsolvencyDailyUpdateBatch();
        Database.QueryLocator ql = cb.start(null);
        cb.execute(null,scope);
        cb.Finish(null);       
        Test.stopTest();
        
    }
}