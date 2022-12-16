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
    
    //Create Product records
    public static List<Product__c> createProduct(){
      
      Date ptpDate = System.Today().addDays(10);
        
        Id stExam = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();

        Account acc = createAccountRecordAndInsert();
        
        List<Product__c> prds = new List<Product__c>();
        Product__c prd = new Product__c();
        prd.name = 'Prod';
        prd.customer__c = acc.id;
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
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.customer__c = acc.id;
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = 'None';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
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
        prd.RecordtypeId= stExam;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.customer__c = acc.id;
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 7;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prd.Collection_Agency__c = 68;
        prd.First_name__c='PQR';
        prd.Last_Name__c='XYZ';
        prd.Originating_Creditor__c='LMN'; 
        prd.RecordtypeId= stExam;
        prd.Collection_Sub_Status__c ='';
        prd.Previously_Reviewed_for_Legal_Action__c =FALSE;
        prd.Status__c = 'New Allocation - New Allocation';
        prd.Sub_Status__c = 'Ready';
        prd.Product_Status__c = 'Test';
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.customer__c = acc.id;
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
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.customer__c = acc.id;
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
        prd.Account_Portfolio_ID__c = '825';
        prds.add(prd);
        
        insert prds;
        
        return prds;
    }
    
    public static List<Judgment__c> createJudgment(){
        
        List<Judgment__c> judgs = new List<Judgment__c>();
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = '29';
        judg.Collection_Agency_Identifier__c = '6';
        judgs.add(judg);
        
        insert judgs;
        return judgs;
    }
     public static List<Account_Judgment__c> createAccountJudgment(){
        
        List<Account_Judgment__c> judgs1 = new List<Account_Judgment__c>();
         List<Judgment__c> listJudg = createJudgment();
         List<Product__c> listProd = createProduct();
         

        Account_Judgment__c judg1 = new Account_Judgment__c();
        
        judg1.Judgment__c=listJudg[0].id;
        //judg1.Legal_Agency__c = '29';
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
        
        List<Product__c> listProd = createProduct();
        List<Judgment__c> listJudg = createJudgment();
        
        List<Settlement__c> settles = new List<Settlement__c>();
        Settlement__c settle = new Settlement__c();
        
        settle.Product__c = listProd[2].id;
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
        
       
        
        insert settles;
        return settles;
    }
    
   
    
    //Create Product records
    public static Account createAccountRecordAndInsert() {
        
        Account accnt = new Account(RecordTypeId = [ select Id from RecordType where IsPersonType = true and SObjectType = 'Account' and DeveloperName = 'Fidem_Customer'].id);        
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
        
    
}