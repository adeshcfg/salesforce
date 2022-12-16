@isTest
public class TestPortalSettlementProcessor {
    
    public static testMethod void testSettlement(){
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Settlement_Number":"SC-111","Product_Identifier": "123456789",'+
            '"Created_By": "Test User","Proposal_Amount":"123","Last_Modified_By": "Test User","Homeowner_Status": "Yes","Employment": "Yes",'+
            '"Settlement_complete_date": "2022-01-03","Status": "Ready for review"}';
        
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalSettlementProcessor.postSettlement();
    }
    
    public static testMethod void updateSettlementTest(){
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Status__c';
        FieldMap.Field_JSON_Tag__c ='Status';
        FieldMap.Object_Name__c = 'Settlement';
        FieldMap.Name = 'Status';        
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Settlement_Number__c';
        FieldMap1.Field_JSON_Tag__c ='Settlement_Number';
        FieldMap1.Object_Name__c = 'Settlement';
        FieldMap1.Name = 'Settlement Number';        
        insert FieldMap1;
        
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Settlement_complete_date__c';
        FieldMap2.Field_JSON_Tag__c ='Settlement_complete_date';
        FieldMap2.Object_Name__c = 'Settlement';
        FieldMap2.Name = 'Settlement complete date';
        FieldMap2.Field_Type__c = 'Date';        
        insert FieldMap2;
        
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Proposal_Amount__c';
        FieldMap3.Field_JSON_Tag__c ='Proposal_Amount';
        FieldMap3.Object_Name__c = 'Settlement';
        FieldMap3.Name = 'Proposal_Amount';
        FieldMap3.Field_Type__c = 'Currency';        
        insert FieldMap3;
        
        Agency_Portal_Fields_Mapping__c FieldMap4 = new Agency_Portal_Fields_Mapping__c();
        FieldMap4.Field_API__c = '  Product_Identifier__c';
        FieldMap4.Field_JSON_Tag__c ='  Product_Identifier';
        FieldMap4.Object_Name__c = 'Settlement';
        FieldMap4.Name = 'Product_Identifier';                
        insert FieldMap4;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        insert prod;
        
        Judgment__c judgment = new Judgment__c();
        judgment.Judgment_Number__c = 'JC-111';
        judgment.Legal_Agency__c = 'Test Agency';
        insert judgment;
        
        //Settlement Record Creation        
        Settlement__c Sttlmnt= new Settlement__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='Settlement__c' AND RecordType.Name='Judgment'].id;
        Sttlmnt.RecordTypeId=recrdid1;
        Sttlmnt.Settlement_Number__c = 'SC-111';
        Sttlmnt.Product__c = prod.Id;
        //Sttlmnt.Judgment__c = judgment.Id;
        Sttlmnt.Status__c='Counter offer accepted';
        Sttlmnt.Proposal_Amount__c= 111;
        Sttlmnt.Employment__c='Yes';
        Sttlmnt.Homeowner_Status__c='Yes';
        Sttlmnt.Comment__c ='Comment';
        Sttlmnt.Proposal_Amount__c = 2002;
        Sttlmnt.Comments_History__c ='History';
        SettlementTriggerHandler.runSettlementTrigger = false;
        insert Sttlmnt;
        SettlementTriggerHandler.runSettlementTrigger = true;
        
      //  Sttlmnt.Status__c='Approved';
       // update Sttlmnt;
        
       
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Settlement_Number', 'SC-111');
        //paramMap.put('Judgment_Number', 'JC-111');
        paramMap.put('Judgment_Identifier','JC-001');
        paramMap.put('Product_Identifier','123456789');
        paramMap.put('Proposal_Amount','123');
        paramMap.put('Settlement_complete_date','2022-01-03');
        paramMap.put('Status','Counter offer accepted');
        paramMap.put('Employment','Yes');
        paramMap.put('Homeowner_Status','Yes');
        paramMap.put('Comment__c','Comment_Reply');
        paramMap.put('Comments_History__c','History');
        paramMap.put('Comment_Reply','Comment_Reply');
        paramMap.put('Created_By','Test User');
        paramMap.put('Last_Modified_By','Test User');
        
        PortalSettlementProcessorUtil.processSettlement(paramMap, Sttlmnt);
        
    }
}