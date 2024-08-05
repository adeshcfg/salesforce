/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for Product Recall Individual Controller
 *  @author : A5E Consulting
 *  @date : 05/08/2022
 
 *************************************************************************************************/
@isTest
public class TestProductRecallIndividualController {
    
    public static testMethod void testConstructor(){
        
        String mainStatus;
        
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        API_Call_Details__c  settings = new API_Call_Details__c ();
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
        
        Placement__c placement= new Placement__c();      
        placement.Name= '9999'; 
        placement.Serviceable_Province__c = 'AB';
        placement.Agency_Name__c = 'Warehouse';
        insert placement; 
        
        //Product Record Creation
        Product__C prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c=101;
        prod.Current_Interest_Amount__c=1000;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.OwnerId= UserInfo.getUserId();
        prod.Placement_Status__c = '290700';
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        map<String, Placement_Status_Code_Mapping__c> mapCodes = new map<String, Placement_Status_Code_Mapping__c> ();
        Placement_Status_Code_Mapping__c placementCode = new Placement_Status_Code_Mapping__c();
        placementCode.Name = 'Name';
        placementCode.Parent_Status__c = 'Test Data';
        placementCode.Status__c = 'Test Status';
        placementCode.Placement_Status_Code__c = '210000';
        placementCode.Sub_Status__c = 'Test Substatus';
        insert placementCode;
        mapCodes.put(placementCode.Placement_Status_Code__c,placementCode);
        
        Judgment__c judg = new Judgment__c();
        judg.legal_Agency__c = '9999';
        judg.Legal_Agency_Placement__c = placement.id;
        insert judg;
        
        Account_judgment__c accJud = new Account_judgment__c();
        accJud.Judgment__c = judg.id;
        accJud.product__c = prod.id;
        accJud.Status__c = 'Active';
        insert accJud;
        
        Work_Assignment__c workAssData2 = new Work_Assignment__c();
        workAssData2.Title__c = 'This task for Test class';
        workAssData2.Description__c = 'This task is for settlement record';
        workAssData2.Product_Identifier__c = prod.id ;
            
        workAssData2.Placement_Agency_Identifier__c=null;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = False;
        insert workAssData2;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = True;
        
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prod);
        ProductRecallIndividualController controller = new ProductRecallIndividualController(sc);
        controller.getactionItems();
        controller.redirectToProduct();
        controller.selectedRecallReason = '210000';
        controller.selectedValueAction = 'PENDING RECALL';
        controller.recallProduct();
        controller.recallWithWarning();
        controller.selectedRecallReason = '210000';
        controller.selectedValueAction = 'Send To Warehouse';
        controller.recallProduct();
        controller.recallWithWarning();
        controller.selectedRecallReason = '210000';
        controller.selectedValueAction = 'Pending Allocation';
        controller.recallProduct();
        controller.recallWithWarning();
        
        
    }
    
}