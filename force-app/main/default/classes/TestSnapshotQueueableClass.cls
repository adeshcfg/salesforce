@isTest
public class TestSnapshotQueueableClass {
    public static testMethod void testMethod1() 
    {   
        Placement__c plcmnt1= new Placement__c();      
        plcmnt1.Name= '29'; 
        plcmnt1.Agency_Name__c = 'Testing';
        insert plcmnt1;
        
        List<Id> prodList1 = new List<Id>();
        Product__c prod2 = new Product__c();
        prod2.Name = '1566P470';
        prod2.Collection_Sub_Status__c = 'Legal';
        prod2.Originating_Creditor__c = 'MBNA';
        prod2.Allocated_Amount_Principal__c = 10;
        prod2.Current_Bal_Attorney_Fees__c = 10;
        prodList1.add(prod2.id);
        
        Product__c prod1 = new Product__c();
        prod1.Name = '1566P480';
        prod1.Collection_Sub_Status__c = 'Legal';
        prod1.Originating_Creditor__c = 'MBNA';
        prod1.Allocated_Amount_Principal__c = 10;
        prod1.Current_Bal_Attorney_Fees__c = 10;
        prod1.Collection_Agency_Placement__c = plcmnt1.id;
        prodList1.add(prod1.id);
        
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '9'; 
        plcmnt.Agency_Name__c = 'Testing placement';
        
        insert plcmnt; 
        
        Id agencyId = plcmnt.id; 
        
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        Account acc = new Account();
        acc.FirstName = 'Anea';
        acc.LastName = 'Starik';
        acc.PersonEmail = 'Test@gmail.com';
        acc.Number_Of_Open_Complaint__c = 5;
        acc.Phone_Number__pc = '123' ;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert acc;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Product__c prod = new Product__c();
        prod.Collection_Sub_Status__c = 'Legal';
        prod.Originating_Creditor__c = 'MBNA';
        prod.Name = '1566P430';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Bal_Attorney_Fees__c = 10;
        prod.Current_Bal_Court_Fees__c = 10;
        prod.Current_Bal_General_Fees__c =10;
        prod.Current_Bal_NSF_Fees__c =10;
        prod.Current_Bal_Other_Fees__c =10;
        prod.Allocated_Amount_Principal__c = 10;
        prod.Customer__c = acc.id;
        prod.Collection_Agency_Placement__c=plcmnt1.id;
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Judgment__c judg = new Judgment__c();
        Id recrdid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recrdid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Judgment_Date__c = System.today();
        judg.Legal_Agency__c = '29';
        JudgmentTriggerHandler.runJudgmentTrigger = False;
        insert judg;
        JudgmentTriggerHandler.runJudgmentTrigger = True;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = False;
        insert accjudg;
        AccountJudgmentTriggerHandler.runAccountJudgmentTrigger = True;
        
        Document_Storage__c docSto2 = new Document_Storage__c();
        docSto2.Document_Type__c = 'Product Snapshot';
        docSto2.Document_Name__c = 'Test';
        docSto2.Visibility__c = 'CFG + Requesting Agency';
        docSto2.Document_Extension__c = 'Pdf';
        docSto2.Placement_Agency__c = place.id;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert docSto2;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        
        Product__c con = [select id,name,Current_Bal_Attorney_Fees__c from Product__c where Id =: prod.id];
        prodList1.add(con.id);
        
        Test.startTest();
        SnapshotQueueableClass updater = new SnapshotQueueableClass(prodList1,agencyId);
       // SnapshotQueueableClass.getFiles(place.id);
        //SnapshotQueueableClass.getCSVHeaderData(prodList1,plcmnt1.id);
        //SnapshotQueueableClass.notificationCallAPI(place.name,docSto2.Document_Type__c,docSto2.Document_Name__c);
        ID jobID = System.enqueueJob(updater);
        Test.stopTest();
    }

}