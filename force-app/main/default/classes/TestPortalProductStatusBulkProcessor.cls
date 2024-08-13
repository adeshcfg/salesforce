/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Portal Product Status Bulk Processor
 *  @author : A5E Consulting
 *  @date : 08/08/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalProductStatusBulkProcessor {
    
    public static testMethod void testPortalProductStatusBulkProcessor(){
        
        Placement__c placement  = new Placement__c();
        placement.name = '9999';
        placement.Serviceable_Province__c = 'AB';
        insert placement;
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"AccountList":"647P1545", "PlacementStatus":"295000", "Type":"Bulk", "SubmittedBy":"TestABC", "Placement_Identifier":null}';
        
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalProductStatusBulkProcessor.postAssignment();
    }
    
    public static testMethod void PortalProductStatusBulkProcessingUtil(){
     	Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        String postJSON;
        list <Product__c> prodList = new list<Product__c>();
        
        Placement__c place = new Placement__c();
        place.name = '05';
        place.Serviceable_Province__c = 'AB';
        insert place;
        
        Placement__c placement  = new Placement__c();
        placement.name = '9999';
        placement.Serviceable_Province__c = 'AB';
        insert placement;
        
        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;
        
        Pool__c poolInstance1 = new Pool__c();
        
        poolInstance1.Placement_Agency__c = 29;
        poolInstance1.Placement_agency_lookup__c = place.id;
        insert poolInstance1;
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name = 'A-0010';
        mapping.Codes__c = '220000';
        mapping.Judgment_Legal_Status__c = 'Pre-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Claim Issued';
        mapping.Product_Parent__c = 'Pre-Judgment';
        mapping.Product_Status__c = 'Pre - Judgment - In Process';
        mapping.Product_Sub_status__c = 'Claim Issued';
        insert mapping;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Charged_Off_Date__c';
        FieldMap2.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap2.Object_Name__c = 'Product';
        FieldMap2.Name = 'Charged Off Date';        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Status__c';
        FieldMap3.Field_JSON_Tag__c ='Status';
        FieldMap3.Object_Name__c = 'Product';
        FieldMap3.Name = 'Status';        
        insert FieldMap3;
        
        list<Id> listPoolId = new list<Id>();
    	Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='647P1545';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c= 101;
        prod.Current_Interest_Amount__c= 1000;
        prod.Placement_Status__c = '800300';
        prod.Pool_Name__c = poolInstance1.Id; 
        INSERT prod;
        prodList.add(prod);
        listPoolId.add(prod.Pool_Name__c);
        
        Account_Judgment__c addJudg = new Account_Judgment__c();
        addJudg.status__C = 'Active';
        addJudg.Product__c = prod.id;
        insert addJudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Status__c = '921000';
        placeHist.Placement_Status_Description__c = 'Test Description';
        insert placeHist;
       
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='12';
        insert plcgy;
        
        Agency_User__c agencyUser = new Agency_User__c();
        agencyUser.Email_Address__c = 'test@gmail.com';
        insert agencyUser;
        
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        workAgt.Title__c = 'Test';
        workAgt.Description__c = 'test';
        workAgt.Purpose__c = 'Payment';
        workAgt.Sub_Purpose__c = 'Media';
        workAgt.Priority__c = 'Medium';
        workAgt.Other_Media_Request__c = 'Other';
        workAgt.Comment_Reply__c = 'Comment';    
        workAgt.Status__c = 'Requested';
        workAgt.Product__c= prod.id;
        workAgt.Original_Creditor__c = 'Test Data';
        workAgt.Placement_Agency__c= plcgy.id;
        insert workAgt;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Account_Judgment_Number__c = 'test';
        accJudgment.Product_Identifier__c = 'test123';
        accJudgment.Created_By__c = '2022-01-03';
        insert accJudgment;
        
          
        map<String, Placement_Status_Code_Mapping__c> mapCodes = new map<String, Placement_Status_Code_Mapping__c>();
        Placement_Status_Code_Mapping__c placementCode = new Placement_Status_Code_Mapping__c();
        placementCode.Name = 'Name';
        placementCode.Parent_Status__c = 'Test Data';
        placementCode.Status__c = 'Test Status';
        placementCode.Placement_Status_Code__c = '210000';
        placementCode.Sub_Status__c = 'Test Substatus';
        insert placementCode;
        mapCodes.put(placementCode.Placement_Status_Code__c,placementCode);
       
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('AccountList', '1000P00');
        paramMap.put('SubmittedBy', 'test@gmail.com');
        paramMap.put('Placement_Status', '920210');
        paramMap.put('Placement_Identifier', 'Test');
        paramMap.put('Type', 'Allocation');
        paramMap.put('PlacementStatus', '111000');
        paramMap.put('AssignmentDate', '2024-08-12');
        postJSON = '{"accountList":"647P1545", "PlacementStatus":"800300", "Type":"Recall", "SubmittedBy":"TestABC", "Placement_Identifier":null}';

        PortalProductStatusBulkProcessingUtil.processBulkProducts(postJSON);
    }
    
     public static testMethod void PortalProductStatusBulkProcessingUtil1(){
     
        String postJSON;
        list <Product__c> prodList = new list<Product__c>();
        
        Placement__c place = new Placement__c();
        place.name = '05';
        place.Serviceable_Province__c = 'AB';
        insert place;
         
        Placement__c placement  = new Placement__c();
        placement.name = '9999';
        placement.Serviceable_Province__c = 'AB';
        insert placement;
         
        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;
        
        Pool__c poolInstance1 = new Pool__c();
        
        poolInstance1.Placement_Agency__c = 29;
        poolInstance1.Placement_agency_lookup__c = place.id;
        insert poolInstance1;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Charged_Off_Date__c';
        FieldMap2.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap2.Object_Name__c = 'Product';
        FieldMap2.Name = 'Charged Off Date';        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Status__c';
        FieldMap3.Field_JSON_Tag__c ='Status';
        FieldMap3.Object_Name__c = 'Product';
        FieldMap3.Name = 'Status';        
        insert FieldMap3;
        
        list<Id> listPoolId = new list<Id>();
    	Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='647P1545';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c= 101;
        prod.Current_Interest_Amount__c= 1000;
        prod.Placement_Status__c = '111010';
        prod.Pool_Name__c = poolInstance1.Id;
        INSERT prod;
        prodList.add(prod);
        listPoolId.add(prod.Pool_Name__c);
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Status__c = '921000';
        placeHist.Placement_Status_Description__c = 'Test Description';
        insert placeHist;
       
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='12';
        insert plcgy;
        
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        workAgt.Title__c = 'Test';
        workAgt.Description__c = 'test';
        workAgt.Purpose__c = 'Payment';
        workAgt.Sub_Purpose__c = 'Media';
        workAgt.Priority__c = 'Medium';
        workAgt.Other_Media_Request__c = 'Other';
        workAgt.Comment_Reply__c = 'Comment';    
        workAgt.Status__c = 'Requested';
        workAgt.Product__c= prod.id;
        workAgt.Original_Creditor__c = 'Test Data';
        workAgt.Placement_Agency__c= plcgy.id;
        insert workAgt;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Account_Judgment_Number__c = 'test';
        accJudgment.Product_Identifier__c = 'test123';
        accJudgment.Created_By__c = '2022-01-03';
        insert accJudgment;
        
          
        map<String, Placement_Status_Code_Mapping__c> mapCodes = new map<String, Placement_Status_Code_Mapping__c>();
        Placement_Status_Code_Mapping__c placementCode = new Placement_Status_Code_Mapping__c();
        placementCode.Name = '111010';
        placementCode.Parent_Status__c = 'Demand Letters';
        placementCode.Status__c = 'In Process';
        placementCode.Placement_Status_Code__c = '111010';
        placementCode.Sub_Status__c = 'Initial Letter Sent';
        placementCode.Data_Status_Description__c = 'Initial Letter Sent';
        placementCode.Data_Status_Code__c = '111010';
        insert placementCode;
        mapCodes.put(placementCode.Placement_Status_Code__c,placementCode);
       
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('AccountList', '1000P00');
        paramMap.put('SubmittedBy', 'Test Status');
        paramMap.put('Placement_Status', '920210');
        paramMap.put('Placement_Identifier', 'Test');
        
        postJSON = '{"accountList":"647P1545", "PlacementStatus":"800300", "Type":"Allocation", "SubmittedBy":"TestABC", "Placement_Identifier":null}';

        PortalProductStatusBulkProcessingUtil.processBulkProducts(postJSON);
    }
    
     public static testMethod void PortalProductStatusBulkProcessingUtil2(){
     
        String postJSON;
        list <Product__c> prodList = new list<Product__c>();
        
        Placement__c place = new Placement__c();
        place.name = '05';
        place.Serviceable_Province__c = 'AB';
        insert place;
        
        Placement__c placement  = new Placement__c();
        placement.name = '9999';
        placement.Serviceable_Province__c = 'AB';
        insert placement;
         
        Pool__c poolInstance = new Pool__c();
        poolInstance.Placement_Agency__c = 29;
        poolInstance.Placement_agency_lookup__c = place.id;
        insert poolInstance;
        
        Pool__c poolInstance1 = new Pool__c();
        
        poolInstance1.Placement_Agency__c = 29;
        poolInstance1.Placement_agency_lookup__c = place.id;
        insert poolInstance1;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Name';
        FieldMap.Field_JSON_Tag__c ='Name';
        FieldMap.Object_Name__c = 'Product';
        FieldMap.Name = 'Name';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Product_Status__c';
        FieldMap1.Field_JSON_Tag__c ='Product_Status';
        FieldMap1.Object_Name__c = 'Product';
        FieldMap1.Name = 'Product Status';        
        insert FieldMap1;
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Charged_Off_Date__c';
        FieldMap2.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap2.Object_Name__c = 'Product';
        FieldMap2.Name = 'Charged Off Date';        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Status__c';
        FieldMap3.Field_JSON_Tag__c ='Status';
        FieldMap3.Object_Name__c = 'Product';
        FieldMap3.Name = 'Status';        
        insert FieldMap3;
        
        list<Id> listPoolId = new list<Id>();
    	Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='647P1545';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c= 101;
        prod.Current_Interest_Amount__c= 1000;
        prod.Placement_Status__c = '800300';
        prod.Pool_Name__c = poolInstance1.Id;
        INSERT prod;
        prodList.add(prod);
        listPoolId.add(prod.Pool_Name__c);
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Status__c = '921000';
        placeHist.Placement_Status_Description__c = 'Test Description';
        insert placeHist;
       
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='12';
        insert plcgy;
        
        Work_Assignment__c workAgt = new Work_Assignment__c();       
        workAgt.Title__c = 'Test';
        workAgt.Description__c = 'test';
        workAgt.Purpose__c = 'Payment';
        workAgt.Sub_Purpose__c = 'Media';
        workAgt.Priority__c = 'Medium';
        workAgt.Other_Media_Request__c = 'Other';
        workAgt.Comment_Reply__c = 'Comment';    
        workAgt.Status__c = 'Requested';
        workAgt.Product__c= prod.id;
        workAgt.Original_Creditor__c = 'Test Data';
        workAgt.Placement_Agency__c= plcgy.id;
        insert workAgt;
        
        Account_Judgment__c accJudgment = new Account_Judgment__c();
        accJudgment.Account_Judgment_Number__c = 'test';
        accJudgment.Product_Identifier__c = 'test123';
        accJudgment.Created_By__c = '2022-01-03';
        insert accJudgment;
        
          
        map<String, Placement_Status_Code_Mapping__c> mapCodes = new map<String, Placement_Status_Code_Mapping__c>();
        Placement_Status_Code_Mapping__c placementCode = new Placement_Status_Code_Mapping__c();
        placementCode.Name = 'Name';
        placementCode.Parent_Status__c = 'Test Data';
        placementCode.Status__c = 'Test Status';
        placementCode.Placement_Status_Code__c = '210000';
        placementCode.Sub_Status__c = 'Test Substatus';
        insert placementCode;
        mapCodes.put(placementCode.Placement_Status_Code__c,placementCode);
       
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('AccountList', '1000P00');
        paramMap.put('SubmittedBy', 'Test Status');
        paramMap.put('Placement_Status', '920210');
        paramMap.put('Placement_Identifier', 'Test');
        
        postJSON = '{"accountList":"647P1545", "PlacementStatus":"800300", "Type":"InvalidSubmission", "SubmittedBy":"TestABC", "Placement_Identifier":null}';

        PortalProductStatusBulkProcessingUtil.processBulkProducts(postJSON);
    }

}