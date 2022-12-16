/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of JudgmentStatusExcelFileProcessing
*  @author : A5E Consulting
*  @date : 13/08/2022
* 
*************************************************************************************************/
@isTest
public class TestJudgmentStatusExcelFileProcessing {
    public static testMethod void testMethod1(){
        
        String mMonth;
        String mYear;
        String mDay;
        if(Integer.valueOf(System.Today().month()) - 1 == 0) {
            mMonth = '12';
            mYear = String.valueOf(Integer.valueOf(System.Today().year()) - 1);
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } else {
            mMonth= String.valueOf(Integer.valueOf(System.Today().month()) - 1);
            mYear = String.valueOf(Integer.valueOf(System.Today().year()));
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
        } 
        //Create placement record
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
        
        //Insert product record
        Product__C prod2 = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod2.RecordTypeId=recrdid;
        prod2.Name ='880P378';
        prod2.Previously_Reviewed_for_Legal_Action__c=True;
        prod2.Product_Status__c = 'Test Status';
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test'; 
        prod2.Current_Principal_Balance__c=101;
        prod2.Current_Interest_Amount__c=1000;
        prod2.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod2;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod3 = new Product__c();
        string recrdid2= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod3.RecordTypeId=recrdid2;
        prod3.Name ='1006P361';
        prod3.Previously_Reviewed_for_Legal_Action__c=True;
        prod3.Product_Status__c = 'Test Status';
        prod3.Status__c = 'New Allocation - New Allocation';
        prod3.Sub_Status__c = 'Ready';
        prod3.Product_Status__c = 'Test'; 
        prod3.Current_Principal_Balance__c=101;
        prod3.Current_Interest_Amount__c=1000;
        prod3.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod3;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod4 = new Product__c();
        string recrdid4= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod4.RecordTypeId=recrdid4;
        prod4.Name ='5100P52';
        prod4.Previously_Reviewed_for_Legal_Action__c=True;
        prod4.Product_Status__c = 'Test Status';
        prod4.Status__c = 'New Allocation - New Allocation';
        prod4.Sub_Status__c = 'Ready';
        prod4.Product_Status__c = 'Test'; 
        prod4.Current_Principal_Balance__c=101;
        prod4.Current_Interest_Amount__c=1000;
        prod4.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod4;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod5 = new Product__c();
        string recrdid5= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod5.RecordTypeId=recrdid5;
        prod5.Name ='451P458';
        prod5.Previously_Reviewed_for_Legal_Action__c=True;
        prod5.Product_Status__c = 'Test Status';
        prod5.Status__c = 'New Allocation - New Allocation';
        prod5.Sub_Status__c = 'Ready';
        prod5.Product_Status__c = 'Test'; 
        prod5.Current_Principal_Balance__c=101;
        prod5.Current_Interest_Amount__c=1000;
        prod5.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod5;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod6 = new Product__c();
        string recrdid6= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod6.RecordTypeId=recrdid6;
        prod6.Name ='1452P78852';
        prod6.Previously_Reviewed_for_Legal_Action__c=True;
        prod6.Product_Status__c = 'Test Status';
        prod6.Status__c = 'New Allocation - New Allocation';
        prod6.Sub_Status__c = 'Ready';
        prod6.Product_Status__c = 'Test'; 
        prod6.Current_Principal_Balance__c=101;
        prod6.Current_Interest_Amount__c=1000;
        prod6.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod6;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod7 = new Product__c();
        string recrdid7= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod7.RecordTypeId=recrdid7;
        prod7.Name ='782536P45';
        prod7.Previously_Reviewed_for_Legal_Action__c=True;
        prod7.Product_Status__c = 'Test Status';
        prod7.Status__c = 'New Allocation - New Allocation';
        prod7.Sub_Status__c = 'Ready';
        prod7.Product_Status__c = 'Test'; 
        prod7.Current_Principal_Balance__c=101;
        prod7.Current_Interest_Amount__c=1000;
        prod7.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod7;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod8 = new Product__c();
        string recrdid8= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod8.RecordTypeId=recrdid8;
        prod8.Name ='4587P125';
        prod8.Previously_Reviewed_for_Legal_Action__c=True;
        prod8.Product_Status__c = 'Test Status';
        prod8.Status__c = 'New Allocation - New Allocation';
        prod8.Sub_Status__c = 'Ready';
        prod8.Product_Status__c = 'Test'; 
        prod8.Current_Principal_Balance__c=101;
        prod8.Current_Interest_Amount__c=1000;
        prod8.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod8;
        ProductTriggerHandler.runProductTrigger = True;
        
        Product__C prod9 = new Product__c();
        string recrdid9= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod9.RecordTypeId=recrdid9;
        prod9.Name ='7856P785';
        prod9.Previously_Reviewed_for_Legal_Action__c=True;
        prod9.Product_Status__c = 'Test Status';
        prod9.Status__c = 'New Allocation - New Allocation';
        prod9.Sub_Status__c = 'Ready';
        prod9.Product_Status__c = 'Test'; 
        prod9.Current_Principal_Balance__c=101;
        prod9.Current_Interest_Amount__c=1000;
        prod9.Collection_Agency__c = Decimal.valueOf(place.Name);
        ProductTriggerHandler.runProductTrigger = False;
        INSERT prod9;
        ProductTriggerHandler.runProductTrigger = True;
        
        //Create Work assignment record
        Work_Assignment__c workAssgn = new Work_Assignment__c();
        workAssgn.Title__c = 'Account_judgment file processing';
        workAssgn.Description__c = 'Test';
        workAssgn.Purpose__c = 'Excel File Processing';
        workAssgn.Sub_Purpose__c = 'Account Status (having Judgment) Update file';
        workAssgn.Placement_Agency__c = place.ID;
        workAssgn.Requested_Date__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        workAssgn.Status__c = 'Requested';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssgn;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        //Create document storage record
        List<Id> docList = new List<Id>();
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Account_Judgment_status_update (1).xlsx';
        docInfo.Document_Type__c = 'Account Status (having Judgment) Update File';
        //docInfo.Document_URL__c = 'Test';//parsedResponse.DocUrl
        //docInfo.Document_Id__c = '122312312';//parsedResponse.docId
        docInfo.Document_URL__c = 'task@c4990412-40c4-4e32-8e55-9c364d9ba761_xlsx';
        docInfo.Document_Id__c = 'c4990412-40c4-4e32-8e55-9c364d9ba761';
        docInfo.Placement_Agency__c = place.id;
        docInfo.Visibility__c = 'CFG + Requesting Agency';
        docInfo.Placement_Identifier__c = place.Name;
        docInfo.File_Processing_Status__c = 'Pending';
        docInfo.Work_Assignment__c = workAssgn.ID;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = False;
        insert docInfo;
        DocumentStorageTriggerHandler.runDocumentStorageTrigger = True;
        docList.add(docInfo.Id);
        
        //Judgment Record Creation
        Judgment__c judg= new Judgment__c();
        string recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod2.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        INSERT accjudg;
        
        //Judgment Record Creation
        Judgment__c judg1= new Judgment__c();
        string recordid1=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg1.RecordTypeId=recordid1;
        judg1.Legal_Status__c='Post-Judgment';
        judg1.Legal_Sub_Status__c='Dormant';
        judg1.Legal_Agency__c = 'Test Agency';
        insert judg1;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg1=new Account_Judgment__c();
        accjudg1.Product__c=prod3.id;
        accjudg1.Judgment__c=judg1.id;
        accjudg1.Status__c='Active';
        INSERT accjudg1;
        
        //Judgment Record Creation
        Judgment__c judg2= new Judgment__c();
        string recordid5=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg2.RecordTypeId=recordid5;
        judg2.Legal_Status__c='Post-Judgment';
        judg2.Legal_Sub_Status__c='Dormant';
        judg2.Legal_Agency__c = 'Test Agency';
        insert judg2;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg2=new Account_Judgment__c();
        accjudg2.Product__c=prod4.id;
        accjudg2.Judgment__c=judg2.id;
        accjudg2.Status__c='Active';
        INSERT accjudg2;
        
        //Judgment Record Creation
        Judgment__c judg3= new Judgment__c();
        string recordid9=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg3.RecordTypeId=recordid9;
        judg3.Legal_Status__c='Post-Judgment';
        judg3.Legal_Sub_Status__c='Dormant';
        judg3.Legal_Agency__c = 'Test Agency';
        insert judg3;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg3=new Account_Judgment__c();
        accjudg3.Product__c=prod5.id;
        accjudg3.Judgment__c=judg3.id;
        accjudg3.Status__c='Active';
        INSERT accjudg3;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg4=new Account_Judgment__c();
        accjudg4.Product__c=prod5.id;
        accjudg4.Judgment__c=judg3.id;
        accjudg4.Status__c='Active';
        INSERT accjudg4;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg5=new Account_Judgment__c();
        accjudg5.Product__c=prod5.id;
        accjudg5.Judgment__c=judg3.id;
        accjudg5.Status__c='Active';
        INSERT accjudg5;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg6=new Account_Judgment__c();
        accjudg6.Product__c=prod5.id;
        accjudg6.Judgment__c=judg3.id;
        accjudg6.Status__c='Active';
        INSERT accjudg6;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg7=new Account_Judgment__c();
        accjudg7.Product__c=prod5.id;
        accjudg7.Judgment__c=judg3.id;
        accjudg7.Status__c='Active';
        INSERT accjudg7;
        
        //Insert Court
        Court__C courtRecord = new Court__C();
        courtRecord.Name = 'Milton';
        insert courtRecord;
        
        String workID = String.valueOf(workAssgn.ID);
        String string1 = 
            '[{"data_id":"880P378","judgment_state":"ON", "judgment_county": "Milton", "judgment_court": "Superior Court of Justice", "judgment_firm":"Goodman & Griffin", "judgment_amount":7168.7,"judgment_writ":"2017-02-28","judgment_writ_amount":7168.7,"judgment_garnishment":"2017-02-28","judgment_garnishment_amount":7168.7,"place_id":82,"judgment_place_id":82, "judgment_date":"2017-02-28","pri_last":"John","pri_first":"Smith","placedetail_status":220000,"data_status":301000,"judgment_suit_amount":6500,"judgment_case":"131/17","judgment_filed":"2017-08-01","judgment_intrate":12.5},'+
            '{"data_id":"1006P361","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"2017-02-28","judgment_writ_amount":7168.7,"judgment_garnishment":"2017-02-28","judgment_garnishment_amount":7168.7,"place_id":82,"judgment_place_id":82, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":290005,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"5100P52","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":500,"judgment_writ":"2017-02-28","judgment_writ_amount":7168.7,"judgment_garnishment":"2017-02-28","judgment_garnishment_amount":7168.7,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":220000,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"451P458","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"2017-02-28","judgment_writ_amount":7168.7,"judgment_garnishment":"2017-02-28","judgment_garnishment_amount":7168.7,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":290000,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"1452P78852","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"2017-02-28","judgment_writ_amount":7168.7,"judgment_garnishment":"","judgment_garnishment_amount":null,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":293000,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"782536P45","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"","judgment_writ_amount":null,"judgment_garnishment":"","judgment_garnishment_amount":null,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":295000,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"4587P125","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"","judgment_writ_amount":null,"judgment_garnishment":"","judgment_garnishment_amount":null,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":295000,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null},'+
            '{"data_id":"7856P785","judgment_state":null, "judgment_county": null, "judgment_court": null, "judgment_firm": null, "judgment_amount":null,"judgment_writ":"","judgment_writ_amount":null,"judgment_garnishment":"","judgment_garnishment_amount":null,"place_id":82,"judgment_place_id":null, "judgment_date":"","pri_last":"John","pri_first":"Smith","placedetail_status":295020,"data_status":"220-000","judgment_suit_amount":null,"judgment_case":null,"judgment_filed":null,"judgment_intrate":null}'+
            
            ']';
        
        Test.startTest();
        JudgmentStatusExcelFileProcessing judgExcel = new JudgmentStatusExcelFileProcessing(string1,workID,docInfo.ID);
        
        Test.stopTest();
    }
    
    
}