/**************************************************************************************************
*
*  Class:   
*  @description : Test class for TestPortalProductProcessor
*  @author : A5E Consulting
*  @date : 05/08/2022

*************************************************************************************************/
@isTest
public class TestPortalProductProcessor {
    
    public static testMethod void testProduct(){
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Name":"1000P00","Product_Status": "Test Status","Placement_Status": "220210",'+
            '"Account_Extinguished_Date": "2022-01-03","Last_Modified_By": "Test User","Created_By": "Test User"}';
        
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalProductProcessor.postAssignment();
    }
    
    public static testMethod void updateProductTest(){
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
		FieldMap2.Field_Type__c = 'Date';        
        insert FieldMap2;
 
        /*
        Agency_Portal_Fields_Mapping__c FieldMap3 = new Agency_Portal_Fields_Mapping__c();
        FieldMap3.Field_API__c = 'Charged_Off_Date__c';
        FieldMap3.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap3.Object_Name__c = 'Product';
        FieldMap3.Name = 'Charged Off Date';
		FieldMap3.Field_Type__c = 'Date';        
        insert FieldMap3;
        
        Agency_Portal_Fields_Mapping__c FieldMap4 = new Agency_Portal_Fields_Mapping__c();
        FieldMap4.Field_API__c = 'Charged_Off_Date__c';
        FieldMap4.Field_JSON_Tag__c ='Charged_Off_Date';
        FieldMap4.Object_Name__c = 'Product';
        FieldMap4.Name = 'Charged Off Date';
		FieldMap4.Field_Type__c = 'Date';        
        insert FieldMap4;*/
        
        
        Agency_Portal_Fields_Mapping__c FieldMap5 = new Agency_Portal_Fields_Mapping__c();
        FieldMap5.Field_API__c = 'Allocated_Amount_Fees__c';
        FieldMap5.Field_JSON_Tag__c ='Allocated_Amount_Fees';
        FieldMap5.Object_Name__c = 'Product';
        FieldMap5.Name = 'Allocated_Amount_Fees';
		FieldMap5.Field_Type__c = 'Currency';        
        insert FieldMap5;
        
        Agency_Portal_Fields_Mapping__c FieldMap6 = new Agency_Portal_Fields_Mapping__c();
        FieldMap6.Field_API__c = 'Timestamp_Of_Invalid_Submission__c';
        FieldMap6.Field_JSON_Tag__c ='Timestamp_Of_Invalid_Submission';
        FieldMap6.Object_Name__c = 'Product';
        FieldMap6.Name = 'Timestamp_Of_Invalid_Submission';
		FieldMap6.Field_Type__c = 'DateTime';        
        insert FieldMap6;
        
        
        Agency_Portal_Fields_Mapping__c FieldMap7 = new Agency_Portal_Fields_Mapping__c();
        FieldMap7.Field_API__c = 'Insolvency_On_File_Primary_Debtor__c	';
        FieldMap7.Field_JSON_Tag__c ='Insolvency_On_File_Primary_Debtor';
        FieldMap7.Object_Name__c = 'Product';
        FieldMap7.Name = 'Insolvency_On_File_Primary_Debtor';
		FieldMap7.Field_Type__c = 'Checkbox';        
        insert FieldMap7;
        
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__C' AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Product_Status__c = 'Test Status';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test'; 
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        INSERT prod;
        
        Product_Extension__c prodExt = new Product_Extension__c();
        prodExt.Account_ID__c = prod.id;
        prodExt.Description__c = 'Test data';
        insert prodExt;        
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Name', '1000P00');
        paramMap.put('Product_Status', 'Test Status');
        paramMap.put('Placement_Status', '220210');
        //paramMap.put('Account_Extinguished_Date', '2022-01-03');
        paramMap.put('Created_By','Test User');
        paramMap.put('Last_Modified_By','Test User');
        
        paramMap.put('Charged_Off_Date', '2022-01-03');
        paramMap.put('Allocated_Amount_Fees', '20');        
        paramMap.put('Timestamp_Of_Invalid_Submission', '2013-01-30T07:38:44.268Z');       
        paramMap.put('Insolvency_On_File_Primary_Debtor', '\''+true+'\'');
            
        PortalProductProcessorUtil.processProduct(paramMap, prod);
        
    }
   
}