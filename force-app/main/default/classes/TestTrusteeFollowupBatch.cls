@isTest
public class TestTrusteeFollowupBatch {

    @isTest 
    public static void TestTrusteeFollowUp() {
        
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
        
        Trustee_Payment_Followup_Setting__c tpfs = Trustee_Payment_Followup_Setting__c.getOrgDefaults();
        tpfs.Name = 'Trustee Payment Followup';
        tpfs.Domain_Name__c = '@rcfax.com.sb';
        tpfs.Trustee_Email_Org_Wide_Address_Id__c = '0D2f1000000fxpt';
        tpfs.Maximum_Emails_Per_Day__c = 5;
        insert tpfs;

        Account trusteeOffice = new Account(Name = 'my acc', 
                                            Business_Email__c = 'test@test.com',                                             
                                            Communication_Preference__c = 'Fax', 
                                            Number_Of_Emails_Sent_Today__c = 2,
                                            Fax = '123-123-123');
        insert trusteeOffice;

        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456780';
        insolv.Insolvency_Status__c = 'Active';
        insolv.Allow_Insolvency_Date_In_Past__c = true;
        insolv.Insolvency_Date__c = System.today().addMonths(-19);
        insolv.Insolvency_Type__c = 'Consumer Proposal';
        insolv.Client_Identifiers__c = 'Scotia Bank';
        insolv.Sent_For_Owner_Review_Date__c = System.today();
        insolv.Debtor_1_First_Name__c = 'firstname';
        insolv.Debtor_1_Last_Name__c = 'lastname';
        insolv.Trustee__c = trusteeOffice.Id;
        insert insolv;

        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and recordtype.name='Scotia Bank Insolvency Account']);
        Insolvency_Account__c insacc = new Insolvency_Account__c();
        insacc.RecordTypeId = recordTypeList[0].Id;
        insacc.Name = 'Test-001';
        insacc.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insacc.Insolvency__c = insolv.Id;
        insacc.Account_Number_Without_Space__c = 'Test-001';
        insacc.Asset_Status__c = 'Purchased';
        insacc.Excluded_from_Purchase__c = FALSE ; 
        insacc.Insolvency_Status__c = 'Claim Filed';
        insacc.Claim_Type__c = 'Unsecured';
        insacc.Claim_Amount__c = 251;
        insert insacc;
        TrusteeFollowupBatch obj = new TrusteeFollowupBatch();
        DataBase.executeBatch(obj);
    }

    @isTest 
    public static void TestTrusteeFollowUpEmail() {

        /*
        PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
        Client_Company_Name__c = 'Canaccede International ltd.', 
        CFG_Office_Phone_Number__c = '800-800-800', 
        CFG_Office_Name__c = 'The Scotia Bank',
        CFG_Office_Email_Address__c = 'test@canaccede.com');
        insert poc;
        */        

        /*
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        //config.Domain_Name__c = 'test.com';
        insert config;
        */
        
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
        
        /*
        Trustee_Payment_Followup_Setting__c tpfs = new Trustee_Payment_Followup_Setting__c(Name = 'Canaccede Bank',
        Domain_Name__c = '@rcfax.com.sb',
        Trustee_Email_Org_Wide_Address_Id__c = '0D2f1000000fxpt',
        Maximum_Emails_Per_Day__c = 5);
        insert tpfs;
        */
        
        Trustee_Payment_Followup_Setting__c tpfs = Trustee_Payment_Followup_Setting__c.getOrgDefaults();
        tpfs.Name = 'Trustee Payment Followup';
        tpfs.Domain_Name__c = '@rcfax.com.sb';
        tpfs.Trustee_Email_Org_Wide_Address_Id__c = '0D2f1000000fxpt';
        tpfs.Maximum_Emails_Per_Day__c = 5;
        insert tpfs;

        Account trusteeOffice = new Account(Name = 'my acc', 
                                            Business_Email__c = 'test@test.com',
                                            Communication_Preference__c = 'Email', 
                                            Number_Of_Emails_Sent_Today__c = 2, 
                                            Fax = '123-123-123');
        insert trusteeOffice;

        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '12456780';
        insolv.Insolvency_Status__c = 'Active';
        insolv.Allow_Insolvency_Date_In_Past__c = true;
        insolv.Insolvency_Date__c = System.today().addMonths(-19);
        insolv.Insolvency_Type__c = 'Consumer Proposal';
        insolv.Client_Identifiers__c = 'Scotia Bank';
        insolv.Sent_For_Owner_Review_Date__c = System.today();
        insolv.Debtor_1_First_Name__c = 'firstname';
        insolv.Debtor_1_Last_Name__c = 'lastname';
        insolv.Trustee__c = trusteeOffice.Id;
        insert insolv;

        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c' and recordtype.name='Scotia Bank Insolvency Account']);
        Insolvency_Account__c insacc = new Insolvency_Account__c();
        insacc.RecordTypeId = recordTypeList[0].Id;
        insacc.Name = 'Test-002';
        insacc.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insacc.Insolvency__c = insolv.Id;
        insacc.Account_Number_Without_Space__c = 'Test-001';
        insacc.Asset_Status__c = 'Purchased';
        insacc.Excluded_from_Purchase__c = FALSE ; 
        insacc.Insolvency_Status__c = 'Claim Filed';
        insacc.Claim_Type__c = 'Unsecured';
        insacc.Claim_Amount__c = 251;
        insert insacc;
        TrusteeFollowupBatch obj = new TrusteeFollowupBatch();
        DataBase.executeBatch(obj);
    }
}