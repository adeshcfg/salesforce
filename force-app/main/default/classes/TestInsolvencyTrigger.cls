@isTest
public class TestInsolvencyTrigger {
@testSetup static void testData(){
        
}
@isTest static void TestInsolvency(){  
Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Insolvency_Trigger__c = true;
        insert config; 
InsolvencyTriggerHandler.runInsolvencyTrigger=True; 
Insolvency__c insolv=new Insolvency__c();
insolv.Name='1000000';
insolv.Insolvency_Type__c='Bankruptcy';
insolv.Insolvency_Received_Date__c=system.today();
insolv.Insolvency_Date__c=system.today();
insolv.Debtor_1_Mailing_State_Province__c='Ontario';
insolv.Debtor_2_Mailing_State_Province__c='Ontario';
insolv.Debtor_2_Estate_Number__c='10000000';
insolv.Insolvency_Status__c='Staging';
insolv.Debtor_1_Court_Number__c='1023';
insolv.Court_Division_Number__c='1234';
insolv.Court_District_Name__c='sample';
insolv.Court_Province_Name__c='sample';
insolv.Debtor_1_First_Name__c='sam';
insolv.Debtor_1_Last_Name__c='samp';
insolv.Debtor_1_Mailing_Street__c='sample address';
insolv.Debtor_1_Mailing_City__c='city sample';
insolv.Debtor_1_Employer_Postal_Code__c='L7S1X3';
insolv.Debtor_1_Date_of_Birth__c=system.today();
insolv.Debtor_1_Gender__c='male';
insolv.Insolvency_Status_Last_Changed__c=System.now();
insolv.Expected_Discharge_Month__c='24';
insolv.Insolvency_Date__c=system.today();
insert insolv;
insolv.Name='1000001';
insolv.Debtor_2_Estate_Number__c='1000002';
update insolv;
}
   
}