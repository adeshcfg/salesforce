@istest
public class TestInsolvencyPopupMessage {
@istest

    public static void TestInsolvencyPopupMessage()
    {
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;
        
        Insolvency__c insolv=new Insolvency__c();
        insolv.Insolvency_Type__c='Bankruptcy';
        insolv.Insolvency_Status__c='Staging';
        insolv.Name='35-1415724';
        insolv.Debtor_1_Court_Number__c='12';
        insolv.Court_Division_Number__c='1014';
        insolv.Court_District_Name__c='101';
        insolv.Court_Province__c='Alberta';
        insolv.Insolvency_Received_Date__c=system.today();
        insolv.Insolvency_Date__c=system.today();
        insolv.Debtor_1_First_Name__c='dummy';
        insolv.Debtor_1_Last_Name__c='dummy2';
        insolv.Debtor_1_Date_of_Birth__c=Date.newInstance(1994, 12, 9);
        insolv.Debtor_1_Gender__c='Male';
        insolv.Debtor_1_Mailing_Street__c='dummy text';
        insolv.Debtor_1_Mailing_City__c='Toronto';
        insolv.Debtor_1_Mailing_State_Province__c='Ontario';
        insolv.Debtor_1_Mailing_Postal_Code__c='N2T2X6';
        Insert insolv;
        RecordType rt=[select id,Name from RecordType where Name='Scotia Bank Insolvency Account' and sObjectType='Insolvency_Account__c' limit 1];
        //Insolvency Account 1
        Insolvency_Account__c insolvncyAccnt=new Insolvency_Account__c();
        insolvncyAccnt.RecordTypeId=rt.id;
        insolvncyAccnt.Name='1056649437375';
        insolvncyAccnt.Account_Type__c='Auto';
        
        insolvncyAccnt.Insolvency_Status__c='Annulled';
        insolvncyAccnt.Borrower_Primary__c='test';
        insolvncyAccnt.Type_of_Service__c='Service and Sale';
        insolvncyAccnt.Claim_Type__c='Unsecured';
        insolvncyAccnt.Asset_Status__c='Purchased';
        insolvncyAccnt.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('SDA Insolvency Account').getRecordTypeId();
        Insert insolvncyAccnt;
        insolvncyAccnt.Insolvency_Status__c='Sent to collections';
        update insolvncyAccnt;    
 		
        PageReference pageRef = Page.InsolvencyAccountView;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(insolvncyAccnt.Id));
        
        ApexPages.StandardController sc = new ApexPages.standardController(insolvncyAccnt);
  		InsolvencyPopupMessage Insolvpop = new InsolvencyPopupMessage(sc);
		Insolvpop.displayPopup();
        
        //Insolvency Account 2
        Insolvency_Account__c insolvncyAccnt2 = new Insolvency_Account__c();
        insolvncyAccnt2.RecordTypeId=rt.id;
        insolvncyAccnt2.Name='1056649437375';
        insolvncyAccnt2.Account_Type__c='Auto';
        
        insolvncyAccnt2.Insolvency_Status__c='New';
        insolvncyAccnt2.Borrower_Primary__c='test';
        insolvncyAccnt2.Type_of_Service__c='Service and Sale';
        insolvncyAccnt2.Claim_Type__c='Unsecured';
        insolvncyAccnt2.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        Insert insolvncyAccnt2;
        insolvncyAccnt2.Insolvency_Status__c='BOT Review completed';
        update insolvncyAccnt;    
 		
        PageReference pageRef1 = Page.InsolvencyAccountView;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('Id', String.valueOf(insolvncyAccnt2.Id));
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(insolvncyAccnt2);
  		InsolvencyPopupMessage Insolvpop1 = new InsolvencyPopupMessage(sc1);
		Insolvpop1.displayPopup();
        
    }
    
}