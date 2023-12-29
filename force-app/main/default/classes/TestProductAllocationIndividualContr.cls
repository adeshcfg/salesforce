@isTest
public class TestProductAllocationIndividualContr {
    @testSetup
    static void testData(){
        Agency_Portal_Fields_Mapping__c fieldMapping = new Agency_Portal_Fields_Mapping__c();
        fieldMapping.Object_Name__c = 'Product';
        fieldMapping.Field_API__c = 'Name';
        fieldMapping.Field_JSON_Tag__c = 'Name';
        fieldMapping.Field_Type__c = 'Text';
        fieldMapping.Name = 'Name';
        insert fieldMapping;
    }
    public static testMethod void testConstructor(){
        
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
        
        Placement_Status_Mapping__c placeStatus = new Placement_Status_Mapping__c();
        placeStatus.Name = '100000';
        placeStatus.Description__c = 'New Allocation Ready';
        insert placeStatus;
        
        Placement_Status_Code_Mapping__c code = new Placement_Status_Code_Mapping__c();
        code.Name='Test';
        code.Parent_Status__c = 'New Allocation';
        code.Placement_Status_Code__c = '100000';
        code.Status__c = 'New Allocation';
        code.Sub_Status__c = 'Ready';
        insert code;
        
        //list<Pool__c> poolList = new list<Pool__c>();
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Active__c= True; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;   
        

        
        Pool__c pool = new Pool__c();
        pool.Placement_Agency__c = 89;
        pool.Placement_agency_lookup__c = plcmnt.id;
        pool.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool;
        
        //Product Record Creation
        Product__c prod=new Product__C();
        prod.Pool_Name__c = pool.id;
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.Collection_Agency_Placement__c = plcmnt.id;
       // prod.State__c = 'AB';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Pool_Name__c = pool.Id;
        prod.Current_Principal_Balance__c = 1000;
        
        //ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        
        Judgment__c judg= new Judgment__c();
        string recordid=[SELECT id from RecordType where sobjecttype='Judgment__C' AND RecordType.Name='Judgment'].id;
        judg.RecordTypeId=recordid;
        judg.Legal_Status__c='Post-Judgment';
        judg.Legal_Sub_Status__c='Dormant';
        judg.Legal_Agency__c = 'Test Agency';
        judg.Filing_Date__c =system.today();
        judg.Judgment_Province__c='Ontario';
                
        insert judg;
        
        //Account-Judgment Record Creation
        Account_Judgment__c accjudg=new Account_Judgment__c();
        accjudg.Product__c=prod.id;
        accjudg.Judgment__c=judg.id;
        accjudg.Status__c='Active';
        INSERT accjudg;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        placeHist.Placement_Status__c = '821000';
        placeHist.Placement_Status_Description__c = 'Test Description';
        insert placeHist;
       

    
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prod);
        ProductAllocationIndividualController controller = new ProductAllocationIndividualController(sc);
        controller.allocateProduct();
        controller.allocateWithWarning(); 
       // ProductTriggerHandler.runProductTrigger = true;
    }
    

    
    public static testMethod void testConstructor1(){
        Placement_Status_Mapping__c placeStatus = new Placement_Status_Mapping__c();
        placeStatus.Name = '100000';
        placeStatus.Description__c = 'New Allocation Ready';
        insert placeStatus;
        
        Placement_Status_Code_Mapping__c code = new Placement_Status_Code_Mapping__c();
          code.Name='Test';
        code.Parent_Status__c = 'New Allocation';
        code.Placement_Status_Code__c = '100000';
        code.Status__c = 'New Allocation';
        code.Sub_Status__c = 'Ready';
        insert code;
        
        //list<Pool__c> poolList = new list<Pool__c>();
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Active__c= True; 
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;  
        
        
        Pool__c pool = new Pool__c();
        //pool.Name = 'P0001';
        pool.Placement_Agency__c = 89;
        pool.Placement_agency_lookup__c = plcmnt.id;
        pool.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool;
        
        //Product Record Creation
        Product__c prod=new Product__C();
        prod.Name ='123456789';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.Pool_Name__c = pool.Id;
        prod.Collection_Agency__c = 89;
        //prod.Status__c = 'ON';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        ProductTriggerHandler.runProductTrigger = true;
        
        PageReference testPage = Page.AgencyPoolAllocation;
        Test.setCurrentPage(testPage);
        Test.StartTest();
        //poolList.add(pool);
        //
        //
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        insert placeHist;
        
        ApexPages.currentPage().getParameters().put('id', prod.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(prod);
        ProductAllocationIndividualController controller = new ProductAllocationIndividualController(sc);
        controller.redirectToProduct();
        Test.StopTest();
    }
}