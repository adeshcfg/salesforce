/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of InsolvencyTriggerHandler
 *  @author : A5E Consulting
 *  @date : 09/26/2016
 * 
 *************************************************************************************************/
 
@isTest
private class TestInsolvencyTriggerHandler{
    
    
    @testSetup
    static void testData(){
        //Custom setting record creation
        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Display_Duplicate_Accounts_List_View__c=10;
        config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        insert config;  
        
        Trustee_Fees__c trustFee = Trustee_Fees__c.getOrgDefaults();
        trustFee.Trustee_Administration_Fee__c = 1;
        trustFee.Counselling_Fee__c = 1;
        trustFee.Receiver_Fee__c = 1;
        trustFee.Trustee_Variable_Fee_Rate__c = 1;
        trustFee.HST_Tax_Rate__c = 1;
        
        insert trustFee;
    }
    
    static testMethod void insolvencyTriggerHandlerTest(){
        
        //Create Insolvency Records
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456789';
        insolv1.Insolvency_type__c = 'Consumer Proposal';
        insolv1.Debtor_2_Estate_Number__c = '985236987';   
        insolv1.Insolvency_Status__c = 'For Owner Review';
        insolv1.Sent_For_Owner_Review_Date__c = null;
        insolv1.Debtor_1_Date_of_Birth__c = Date.newInstance(1966, 12, 9);
        insolv1.Date_Of_Birth_Year__c = null;
        insolv1.Revival_Date__c = System.today();
        insolv1.Voting_Trustee_Follow_up_Date__c = System.today();
        insolvList.add(insolv1); 
        
        Insolvency__c insolv2 = new Insolvency__c();
        insolv2.Name = '852147856';
        insolv2.Debtor_2_Estate_Number__c = '874123698';  
        insolv2.Insolvency_Status__c = 'Active';
                insolv1.Sent_For_Owner_Review_Date__c = null;
                        insolv1.Revival_Date__c = System.today();
                        insolv1.Voting_Trustee_Follow_up_Date__c = System.today();
        insolvList.add(insolv2); 
        
        Insolvency__c insolv3 = new Insolvency__c();
        insolv3.Name ='467867444';
        insolv3.Debtor_2_Estate_Number__c = '765412324';  
        insolv3.Insolvency_Status__c = 'Annulled';
        insolvList.add(insolv3); 
        
        Insolvency__c insolv4 = new Insolvency__c();
        insolv4.Name = '877212227';
        insolv4.Debtor_2_Estate_Number__c = '956452322';  
        insolv4.Insolvency_Status__c = 'Refused';
        insolvList.add(insolv4); 
        
        Insolvency__c insolv5 = new Insolvency__c();
        insolv5.Name = '804989902';
        insolv5.Debtor_2_Estate_Number__c = '612376892';  
        insolv5.Insolvency_Status__c = 'Withdrawn';
        insolvList.add(insolv5); 
        
        Insolvency__c insolv6 = new Insolvency__c();
        insolv6.Name = '8049899045';
        insolv6.Debtor_2_Estate_Number__c = '612376854';  
        insolv6.Insolvency_Status__c = 'Discharged';
        insolvList.add(insolv6);
        
        Insolvency__c insolv7 = new Insolvency__c();
        insolv7.Name = '804998745';
        insolv7.Debtor_2_Estate_Number__c = '52376434316854';  
        insolv7.Insolvency_Status__c = 'Annulled - Filed New';
        insolvList.add(insolv7);
        
        Insolvency__c insolv8 = new Insolvency__c();
        insolv8.Name = '80499873345';
        insolv8.Debtor_2_Estate_Number__c = '5237616854';  
        insolv8.Insolvency_Status__c = 'Refused – Filed New';
        insolvList.add(insolv8);
        
        Insolvency__c insolv9 = new Insolvency__c();
        insolv9.Name = '804995558745';
        insolv9.Debtor_2_Estate_Number__c = '523761651854';  
        insolv9.Insolvency_Status__c = 'Withdrawn – Filed New';
        insolvList.add(insolv9);

        //Test Before Insert        
        InsolvencyTriggerHandler.handleBeforeInsert(insolvList);
        
        //Test Before Update 
        Map<ID, Insolvency__c> insolvMap = new Map<ID, Insolvency__c>();
        insolvMap.put(insolv1.id, insolv2);     
        insolvMap.put(insolv2.id, insolv1); 
        insolvMap.put(insolv3.Id,insolv3);
        insolvMap.put(insolv4.Id,insolv4);
        insolvMap.put(insolv5.Id,insolv5);
        insolvMap.put(insolv7.Id,insolv7);
        insolvMap.put(insolv8.Id,insolv8);
        insolvMap.put(insolv9.Id,insolv9);
    
        System.debug('insolvmap---'+insolvMap);
      
        InsolvencyTriggerHandler.handleBeforeUpdate(insolvList, insolvMap);  
        
    }
    
    static testMethod void insolvencyStatusChangeTest(){
        
        //Create Insolvency Records
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '852147856';
        insolv1.Debtor_2_Estate_Number__c = '874123698';  
        insolv1.Insolvency_Status__c='Staging'; 
        insolvList.add(insolv1); 
        
        Insolvency__c insolv3 = new Insolvency__c();
        insolv3.Name = '12456789';
        insolv3.Debtor_2_Estate_Number__c = '985236987';
        insolv3.Insolvency_Status__c = 'Staging';
        insolvList.add(insolv3);
        
        Insolvency__c insolv5 = new Insolvency__c();
        insolv5.Name = '98700432';
        insolv5.Insolvency_Status__c = 'Discharged';
        insolvList.add(insolv5);
        
        Insolvency__c insolv10 = new Insolvency__c();
        insolv10.Name = '32-249956224657';
        insolv10.Insolvency_Status__c = 'Active';
        insolvList.add(insolv10);
        
        Insolvency__c insolv11 = new Insolvency__c();
        insolv11.Name = '32-2499565552';
        insolv11.Insolvency_Status__c = 'Conditional Discharge';
        insolvList.add(insolv11);
        
        Insolvency__c insolv14 = new Insolvency__c();
        insolv14.Name = '68654554';
        insolv14.Insolvency_Status__c = 'For Owner Review';
        insolvList.add(insolv14);
        
        Insolvency__c insolv15 = new Insolvency__c();
        insolv15.Name = '789456123';
        insolv15.Insolvency_Status__c = 'Withdrawn';
        insolvList.add(insolv15);
                
                
        insert  insolvList; 
        
        Map<ID, Insolvency__c> insolvOldMap = new Map<ID, Insolvency__c>();
        insolvOldMap.put(insolv1.Id, insolv1);
        insolvOldMap.put(insolv3.Id,insolv3);
        insolvOldMap.put(insolv5.Id,insolv5);
        insolvOldMap.put(insolv10.Id,insolv10);
        insolvOldMap.put(insolv11.Id,insolv11);
        insolvOldMap.put(insolv14.Id,insolv14);
        insolvOldMap.put(insolv15.Id,insolv15);

       
        Id devRecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        
        //Insolvency Account record insertion
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'TestDup -1';
        insolAcct.Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct.Insolvency_Status__c = 'New';
        insolAcct.Account_Type__c = 'Line of Credit';
        insolAcct.Borrower_Primary__c = 'Kajal';
        insolAcct.Type_of_Service__c = 'Service Only';
        insolAcct.Claim_Amount__c = 1200.00;
        insolAcct.Claim_Type__c = 'Secured';
        insolAcct.Excluded_from_Purchase__c=False;
        insolAcct.Excluded_Account_Comments__c='TestData';
        insolAcct.Is_Duplicate_Resolved__c=False;
        insolAcct.Insolvency_Type__c='Bankruptcy';
        insolAcct.Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct.Product_Code__c='MOR';
        insolAcct.Debtor__c='test';
        insolAcct.PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct.Asset_Status__c='Bulk Purchased';
        insolAcct.Insolvency__c = insolv1.id;
        insolAcct.Account_Type__c = '';
        insolAcct.Borrower_Primary__c = '';    
        insolAcct.Type_of_Service__c = '';
        insolAcct.Claim_Type__c = '';
        insolAcct.Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.recordTypeId = devRecordTypeId;
        
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1 .name = 'TestDup -2';
        insolAcct1 .Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct1 .Insolvency_Status__c = 'New';
        insolAcct1 .Account_Type__c = 'Line of Credit';
        insolAcct1 .Borrower_Primary__c = 'Kajal';
        insolAcct1 .Type_of_Service__c = 'Service Only';
        insolAcct1 .Claim_Amount__c = 1200.00;
        insolAcct1 .Claim_Type__c = 'Secured';
        insolAcct1 .Excluded_from_Purchase__c=False;
        insolAcct1 .Excluded_Account_Comments__c='TestData';
        insolAcct1 .Is_Duplicate_Resolved__c=False;
        insolAcct1 .Insolvency_Type__c='Bankruptcy';
        insolAcct1 .Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct1 .Product_Code__c='MOR';
        insolAcct1 .Debtor__c='test';
        insolAcct1 .PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct1 .Asset_Status__c='Bulk Purchased';
        insolAcct1 .Insolvency__c = insolv3.id;
        insolAcct1 .Account_Type__c = '';
        insolAcct1 .Borrower_Primary__c = '';    
        insolAcct1 .Type_of_Service__c = '';
        insolAcct1 .Claim_Type__c = '';
        insolAcct1 .Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct1 .Client_Identifier__c = 'Scotia Bank';
        insolAcct1 .recordTypeId = devRecordTypeId;
        
        Insolvency_Account__c insolAcct2 = new Insolvency_Account__c();
        insolAcct2 .name = 'TestDup -2';
        insolAcct2 .Account_Number_Without_Space__c = 'TestDup-1';
        insolAcct2 .Insolvency_Status__c = 'New';
        insolAcct2 .Account_Type__c = 'Line of Credit';
        insolAcct2 .Borrower_Primary__c = 'Kajal';
        insolAcct2 .Type_of_Service__c = 'Service Only';
        insolAcct2 .Claim_Amount__c = 1200.00;
        insolAcct2 .Claim_Type__c = 'Secured';
        insolAcct2 .Excluded_from_Purchase__c=False;
        insolAcct2 .Excluded_Account_Comments__c='TestData';
        insolAcct2 .Is_Duplicate_Resolved__c=False;
        insolAcct2 .Insolvency_Type__c='Bankruptcy';
        insolAcct2 .Insolvency_Date__c=Date.newInstance(2020,04, 11);
        insolAcct2 .Product_Code__c='MOR';
        insolAcct2 .Debtor__c='test';
        insolAcct2 .PoC_Created_Date__c=DateTime.newInstance(2020, 01, 08);
        insolAcct2 .Asset_Status__c='Bulk Purchased';
        insolAcct2 .Insolvency__c = insolv11.id;
        insolAcct2 .Account_Type__c = '';
        insolAcct2 .Borrower_Primary__c = '';    
        insolAcct2 .Type_of_Service__c = '';
        insolAcct2 .Claim_Type__c = '';
        insolAcct2 .Reasons_for_Duplicate_Account_Number__c='Test';
        insolAcct2 .Client_Identifier__c = 'Scotia Bank';
        insolAcct2 .recordTypeId = devRecordTypeId;
        
        
        insert  insolAcct;
        insert  insolAcct1;
        insert  insolAcct2;
        
        Insolvency__c insolv2 = new Insolvency__c();
        insolv2.Insolvency_Status__c = 'Annulled';
        insolv2.Id = insolv3.Id;

        Insolvency__c insolv4 = new Insolvency__c();
        insolv4.Insolvency_Status__c = 'Refused';        
        insolv4.Id = insolv10.Id;
        
        Insolvency__c insolv6 = new Insolvency__c();
        insolv6.Insolvency_Status__c = 'Withdrawn';        
        insolv6.Id = insolv5.Id;
        
        Insolvency__c insolv8 = new Insolvency__c();
        insolv8.Insolvency_Status__c = 'Refused – Filed New';        
        insolv8.Id = insolv1.Id;
        
        Insolvency__c insolv9 = new Insolvency__c();
        insolv9.Insolvency_Status__c = 'Withdrawn – Filed New';        
        insolv9.Id = insolv11.Id;
        
        Insolvency__c insolv16 = new Insolvency__c();
        insolv16.Insolvency_Status__c = 'Discharged';        
        insolv16.Id = insolv14.Id;
        
        Insolvency__c insolv17 = new Insolvency__c();
        insolv17.Insolvency_Status__c = 'Annulled - Filed New';        
        insolv17.Id = insolv15.Id;
        
        
        
        Map<ID, Insolvency__c> insolvNewMap = new Map<ID, Insolvency__c>();
        insolvNewMap.put(insolv2.Id, insolv2);
        insolvNewMap.put(insolv4.Id,insolv4);
        insolvNewMap.put(insolv6.Id,insolv6);
        insolvNewMap.put(insolv8.Id,insolv8);
        insolvNewMap.put(insolv9.Id,insolv9);
        insolvNewMap.put(insolv16.Id,insolv16);
        insolvNewMap.put(insolv17.Id,insolv17);
         
        
        
        InsolvencyTriggerHandler.handleAfterInsert(insolvList);
        InsolvencyTriggerHandler.handleAfterUpdate(insolvNewMap , insolvOldMap);        
        
        InsolvencyTriggerHandler.provinceMap();
    }
    
    /*
    static testMethod void insolvencyTriggerHandlerTest(){
        
        //Create Accounts
        List<Account> debtors = new List <Account>();
        Account debtor1 = new Account();
        debtor1.firstName = 'D1First'; 
        debtor1.lastName = 'D1Last';
        debtors.add(debtor1);
        Account debtor2 = new Account();
        debtor2.firstName = 'D2First'; 
        debtor2.lastName = 'D2Last';
        debtors.add(debtor2);
        insert debtors;
        
        //Create Insolvency Records
        List<Insolvency__c> insolvList = new List<Insolvency__c>();
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.debtor_1__c = debtor1.id;
        insolv1.debtor_2__c = debtor2.id;       
        insolv1.Client_Identifier__c = 'Scotia Bank';
        insolvList.add(insolv1); 
        Insolvency__c insolv2 = new Insolvency__c();
        insolv2.debtor_1__c = debtor2.id;
        insolv2.debtor_2__c = debtor1.id;       
        insolv2.Client_Identifier__c = 'Scotia Bank';
        insolvList.add(insolv2); 
                   
        //Test Before Insert        
        InsolvencyTriggerHandler.handleBeforeInsert(insolvList);
        
        //Test After Insert 
        insert insolvList; 
        InsolvencyTriggerHandler.handleAfterInsert(insolvList);
        
        //Test Before Update 
        Map<ID, Insolvency__c> insolvMap = new Map<ID, Insolvency__c>();
        insolvMap.put(insolv1.id, insolv2);     
        insolvMap.put(insolv2.id, insolv1);       
        InsolvencyTriggerHandler.handleBeforeUpdate(insolvList, insolvMap);
        
        //Test After Update 
        InsolvencyTriggerHandler.handleBeforeUpdate(insolvList, insolvMap);        
    }
    */
}