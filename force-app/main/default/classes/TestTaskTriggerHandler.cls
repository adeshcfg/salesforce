/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for CollectionContactAccountBatch
*  @author : A5E Consulting
*  @date : 09/07/2017   

*************************************************************************************************/
@isTest
public class TestTaskTriggerHandler{
    
    public Static testMethod void testMethod1(){
        
        //Custom settings
        createCCAB();
        
        createTask1();
        
        TaskTriggerHandler.isCanaccedeAPIUser();
    }
    
    public Static testMethod void testMethod2(){
        
        //Custom settings
        createCCAB();
        
        createTask2();
        
    }
    
    public Static testMethod void testMethod3(){
        
        //Custom settings
        createCCAB();
        
        createTask3();
        

    }
    public Static testMethod void testMethod4(){
        
        //Custom settings
        createCCAB();
        
        createTask4();
        createTask5();
        createTask6();
        
    }
    public Static testMethod void testMethod5(){
        
        //Custom settings
        createCCAB();
        createTask7();
        
    }
    
    //Create Product records
    public static List<Product__c> createProduct(){
      
      Date ptpDate = System.Today().addDays(10);
        
        Id stExam = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();

        Account acc = createAccountRecordAndInsert();
        
        // From Here
        Account accnt1 = new Account(RecordTypeId = [ select Id from RecordType where IsPersonType = true and SObjectType = 'Account' and DeveloperName = 'Canaccede_Customer'].id);        
        //From Here
        accnt1.Salutation = 'Mr.';
        //Upto Here  
        accnt1.FirstName = 'testFName1'+System.now();
        accnt1.LastName = 'testLName1'+System.now();
        accnt1.PersonEmail = 'test1@email.com';
        accnt1.SIN__pc = '12345678'; 
        accnt1.CCS_Agency_Total_Balance_Updated_On__c = system.Today().addDays(-2);
        accnt1.CCS_Agency_Total_Balance__c = 12344 ;
        accnt1.PersonBirthdate = system.today();
        
        insert accnt1;  
        List<Product__c> prds = new List<Product__c>();

        // Upto Here
        try{
        Product__c prd = new Product__c();
        //From Here
          prd.RecordtypeId= stExam;
        //Upto Here
        prd.name = '10000P1';
        // commented by me prd.customer__c = acc.id;
         prd.customer__c = accnt1.id;
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        //prd.Account_Portfolio_ID__c = '826';
        // From Here
        prd.Purchase_Province__c = 'Canada';
        //Upto Here
        insert prd;
            system.debug('record created--->'+prd.recordtype.name);
        //prds.add(prd);
        } catch(DmlException e){
            system.debug('producr'+e.getMessage());
         	 // System.assert(false, 'Exception ' + e);
        }try{
        Product__c prd1 = new Product__c();
        prd1.name = '10000P2';
        //prd1.customer__c = acc.id;
        prd1.source_system__c = 'Megasys';
        prd1.Branch_Number__c = 1;
        prd1.Charged_Off_Date__c = System.Today();
        prd1.Charged_Off_Code__c = 'None';
        prd1.Current_Balance__c = null;
        prd1.Current_Payoff_Amount__c = 100;
        prd1.PTP1_Mate__c = false;
        prd1.PTP1_Amount__c = 75;
        prd1.PTP1_Date__c = ptpDate;
        prd1.Status__c = 'New Allocation - New Allocation';
        prd1.Sub_Status__c = 'Ready';
        prd1.Product_Status__c = 'Test';
        //prd1.Account_Portfolio_ID__c = '825';
            insert prd1;
        } // Bracket done by me
        //prds.add(prd);
        catch(DmlException e){
            system.debug('producr1'+e.getMessage());
        }
        try{
       product__c prd = new Product__c();     
       // prd = new Product__c();
        prd.name = '10000P3';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 6;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Collection_Agency__c = 68;
        prd.First_name__c='PQR';
        prd.Last_Name__c='XYZ';
        prd.Originating_Creditor__c='LMN'; 
        //prd.RecordtypeId= stExam;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        //prd.Account_Portfolio_ID__c = '830';
                      prd.RecordtypeId= stExam;
        prds.add(prd);
        
        
          product__c prd2 = new Product__c();     
       // prd = new Product__c();
        prd2.name = '10000P4';
        //prd.customer__c = acc.id;
        prd2.source_system__c ='FDR' ;
        prd2.PRIN_Number__c = 200;
        prd2.Current_Balance__c = 400;
        prd2.Current_Payoff_Amount__c = 400;
        prd2.Delinquency_Cycles__c = 7;
        prd2.PTP1_Mate__c = false;
        prd2.PTP1_Amount__c = 75;
        prd2.PTP1_Date__c = ptpDate;
        prd2.Collection_Agency__c = 68;
        prd2.First_name__c='PQR';
        prd2.Last_Name__c='XYZ';
        prd2.Originating_Creditor__c='LMN'; 
        //prd.RecordtypeId= stExam;
        prd2.Collection_Sub_Status__c ='';
        prd2.Previously_Reviewed_for_Legal_Action__c =FALSE;
        prd2.Status__c = 'New Allocation - New Allocation';
        prd2.Sub_Status__c = 'Ready';
        prd2.Product_Status__c = 'Test';
        //prd2.Account_Portfolio_ID__c = '827';
        prd2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prds.add(prd2);
        
        prd = new Product__c();
        prd.name = '10000P5';
      //  prd.customer__c = acc.id;
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 300;
        prd.Current_Balance__c = 0;
        prd.External_Status_Current__c = 'C';
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        //prd.Account_Portfolio_ID__c = '828';
        prd.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Credit Card Account').getRecordTypeId();
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = '10000P6';
       // prd.customer__c = acc.id;
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 400;
        prd.Current_Balance__c = 0;
        prd.External_Status_Current__c = 'C';
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        //prd.Account_Portfolio_ID__c = '829';
        prd.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        prds.add(prd);
        
        insert prds;
            }
        catch (Exception e){
            //System.assert(false, 'Exception ' + e);
            system.debug('producr2'+e.getMessage());
        }
            return prds;
        //}catch(exception ex){return prds;}
        
    }
    
    public static List<Judgment__c> createJudgment(){
        
        List<Judgment__c> judgs = new List<Judgment__c>();
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = '72';
        judg.Legal_Status__c='Pre-legal';
        judg.Legal_Sub_Status__c='Recommended for legal action';
        judg.Collection_Agency_Identifier__c = '6';
        judgs.add(judg);
        
        insert judgs;
        return judgs;
    }
     public static List<Account_Judgment__c> createAccountJudgment(){
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Pre-legal';
        mapping.Judgment_Legal_Sub_Status__c = 'Recommended for legal action';
        mapping.Codes__c='210000';
        mapping.Product_Parent__c ='Pre - Legal - In Process';
        mapping.Product_Sub_status__c ='Recommended for Legal Action';
        insert mapping;
         
        List<Account_Judgment__c> judgs1 = new List<Account_Judgment__c>();
         List<Judgment__c> listJudg = createJudgment();
         List<Product__c> listProd = createProduct();
         

        Account_Judgment__c judg1 = new Account_Judgment__c();
        
        judg1.Judgment__c=listJudg[0].id;
        judg1.Product__c =listProd[3].id;
        judg1.Status__c= 'Active';
        
        insert judg1;
        judgs1.add(judg1);
        
        AccountJudgmentTriggerHandler.updateProductRecord(judgs1);
       //  AccountJudgmentTriggerHandler.updateActiveAccountJudgmentRecord(judgs1);
         //  AccountJudgmentTriggerHandler.updateAmountsOnJudgment(judgs1);
           // AccountJudgmentTriggerHandler.populateJudgmentWithPlacement(judgs1);

        return judgs1 ;
        
    } 
    
    
    public static List<Settlement__c> createSettlement(){
        
        Product__c prd1 = new Product__c();
        prd1.name = '10000P122';
        prd1.source_system__c = 'Megasys';
        prd1.Branch_Number__c = 1;
        prd1.Charged_Off_Date__c = System.Today();
        prd1.Charged_Off_Code__c = 'None';
        prd1.Current_Balance__c = null;
        insert prd1;
        
        List<Product__c> listProd = createProduct();
        List<Judgment__c> listJudg = createJudgment();
        
        List<Settlement__c> settles = new List<Settlement__c>();
        Settlement__c settle = new Settlement__c();
        
        settle.Product__c = prd1.id;
        settle.Proposal_Amount__c = 150;
        settle.Status__c = 'New';
        settle.Employment__c ='Yes';
        settle.Homeowner_Status__c ='Yes';
        settles.add(settle);
        
        settle = new Settlement__c();
        settle.Judgment__c = listJudg[0].id;
        settle.Proposal_Amount__c = 150;
        settle.Status__c = 'New';
        settle.Employment__c ='Yes';
        settle.Homeowner_Status__c ='Yes';
        settles.add(settle);
        
       
        SettlementTriggerHandler.runSettlementTrigger = False;
        insert settles;
        SettlementTriggerHandler.runSettlementTrigger = True;
        return settles;
    }
    
   
    
    //Create Product records
    public static Account createAccountRecordAndInsert() {
       
        Account accnt = new Account(RecordTypeId = [ select Id from RecordType where IsPersonType = true and SObjectType = 'Account' and DeveloperName = 'Fidem_Customer'].id);
 //From Here
        accnt.Salutation = 'Mr.';
        //Upto Here        
        accnt.FirstName = 'testFName';
        accnt.LastName = 'testLName';
        accnt.PersonEmail = 'test@email.com';
        accnt.SIN__pc = '1234567';  
        accnt.PersonBirthdate = system.today();
        
        insert accnt;   
        
        return accnt;
    }
    
    //Create Custom Setting Record  
    public static void createCCAB(){
        
        Collection_Custom_Setting__c dtCS = New Collection_Custom_Setting__c();
        dtCS.Contact_Counter_Code__c = 'test';
        dtCS.Last_n_Days__c = 5;
        dtCS.Run_Task_Trigger__c = True;
        insert dtCS; 
        
        Loan_ReEngineering__c lrpCS = New Loan_ReEngineering__c();
        lrpCS.Canaccede_API_User__c = 'api@canaccede.com.sb';
        insert lrpCS; 
        
        Docomotion_Custom_Setting__c docoCS = new Docomotion_Custom_Setting__c ();
        docoCS.Document_type_for_objects__c = 'a0D';
        insert docoCS;
        
        Distress_Setting__c distressCS = new Distress_Setting__c ();
        distressCS.Distressed_Task_Eligible_Objects__c = 'a0D,a1w,a1y';
        insert distressCS;
        
         Application_Config_Settings__c config= new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c= True;
        config.Run_Insolvency_Status_Validations__c = true;
            config.Maximum_Email_Attachments_Size__c = 18874368;
            config.Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB';
            config.Run_Insolvency_Account_Trigger__c = true;
            config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
            config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
            config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
            config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
            config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
            config.Run_Insolvency_Trigger__c = false;
            config.Run_Insolvency_Account_Duplicate_Check__c = true;
            config.Eligible_for_Voting_Decision__c = 'Scotia Bank,SDA,SPL,Canaccede,Fidem,Fairstone';
        insert config;
        
        
    }  
    
    public static void createTask1(){
        
        List<Product__c> listProd = createProduct();
        
        List<Task> listTask = new List<Task>();
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        //t.Responsavel__c='Felipe';
        t.whatId = listProd[0].id;
        t.Subject = 'Print Email';
        insert t;
        
        listTask.add(t);
        
        t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='Letter - Docomotion';
        t.Status='Generated by Docomotion';
        t.Priority='Normal';
        //t.Responsavel__c='Felipe';
        t.whatId = listProd[1].id;
        insert t;
        ContentVersion contentVersion = new ContentVersion(
                    Title          = 'a picture',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);
            insert contentVersion;
List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];       
        ContentDocumentLink cdl=new ContentDocumentLink();
        cdl.LinkedEntityId=t.WhatId;
        cdl.ContentDocumentId=documents[0].id;
        insert cdl;
        listTask.add(t);
        TaskTriggerHandler.handleAfterInsert(listTask);
        
    }
    
    public static void createTask2(){
        
        List<Product__c> listProd = createProduct();
        
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = createAccountRecordAndInsert().id;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        insert t1;
        listTask.add(t1);
        TaskTriggerHandler.handleAfterInsert(listTask);
        
    }
     public static void createTask3(){
        
        List<Product__c> listProd = createProduct();
        system.debug('listPROD--->'+listProd);
         for(Product__c p: listprod){
             system.debug('record type name-->'+p.recordtype.name);
         }
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = listProd[2].id;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        t1.Collection_Agency__c = '';
        listTask.add(t1);
        TaskTriggerHandler.handleBeforeInsert(listTask);
        
    }
    public static void createTask4(){
        
        List<Judgment__c> listJudg = createJudgment();
        List<Account_Judgment__c> judgs1 = createAccountJudgment();

        
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = judgs1[0].Judgment__c;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        t1.Collection_Agency__c = '';
        t1.First_Name__c ='';
        t1.Last_Name__c ='';
        t1.Seller__c='';
        listTask.add(t1);
        TaskTriggerHandler.handleBeforeInsert(listTask);
        
    }
      public static void createTask5(){
        
        List<Settlement__c> listSettle = createSettlement();
        
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();

        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = listSettle[0].id;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        t1.Collection_Agency__c = '';
        t1.First_Name__c ='';
        t1.Last_Name__c ='';
        t1.Seller__c='';
        listTask.add(t1);
        
        
        
        TaskTriggerHandler.handleBeforeInsert(listTask);
        
    }
    
     public static void createTask6(){
     
     List<Judgment__c> listJudg = createJudgment();
        
        List<Settlement__c> listSettle = createSettlement();
        
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = listSettle[0].id;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        t1.Collection_Agency__c = '';
        t1.First_Name__c ='';
        t1.Last_Name__c ='';
        t1.Seller__c='';
        listTask.add(t1);
        TaskTriggerHandler.handleBeforeInsert(listTask);
       
       }
    
    public static void createTask7(){
       
     List<Insolvency_Account__c> insolvansyList = new List<Insolvency_Account__c>();
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insolvansyList.add(acc);
        insert insolvansyList;
        
        List<Task> listTask = new List<Task>();
           
        listTask = new List<task>();
        Task t1 = new Task();
        t1.OwnerId = UserInfo.getUserId();
        t1.Subject='Collection';
        t1.Status='Not Started';
        t1.Priority='Normal';
        //t1.Responsavel__c='Felipe';
        t1.whatId = insolvansyList[0].id;
        t1.CallClassification1__c = 'test';
        t1.subject = 'Collection';
        t1.Type_of_Activity__c = 'Collection';
        t1.CallType = 'Outbound';
        t1.Collection_Agency__c = '';
        t1.First_Name__c ='';
        t1.Last_Name__c ='';
        t1.Seller__c='';
        listTask.add(t1);
        TaskTriggerHandler.handleBeforeInsert(listTask);
       
       }
        
    
}