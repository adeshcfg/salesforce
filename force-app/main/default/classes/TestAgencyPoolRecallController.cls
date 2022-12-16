@isTest
public class TestAgencyPoolRecallController {
    
    public static testMethod void testConstructor1(){

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

        
        //list<Pool__c> poolList = new list<Pool__c>();
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;    
        
        Placement__c placement= new Placement__c();      
        placement.Name= '9999'; 
        placement.Serviceable_Province__c = 'AB';
        placement.Agency_Name__c = 'Warehouse';
        insert placement; 
        
        Pool__c pool = new Pool__c();
       // pool.Placement_Agency__c = 89;
        pool.Placement_agency_lookup__c = plcmnt.id;
        pool.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool;
        
        //Product Record Creation
        Product__c prod = new Product__C();
        prod.Pool_Name__c = pool.id;
        prod.Collection_Agency_Placement__c =plcmnt.id;
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.Name ='123456789';
        prod.State__c = 'Nova Scotia';
        prod.Status__c = 'Client Request - Others';
        prod.Sub_Status__c = 'Recall'; 
        prod.Product_Status__c = 'Test';
        prod.DebtNext_Data_ID__C = pool.Id; 
        prod.Current_Balance__c=34567;
        prod.Legal_Status__c='Legal';
        
       
        
        
        Agency_Portal_Settings__c ab = Agency_Portal_Settings__c.getOrgDefaults();
        ab.Pool_Recall_Reasons__c = 'Test,Client'; // -Request Contractual';
        insert ab;
        Placement_Status_Code_Mapping__c place= new Placement_Status_Code_Mapping__c();
        place.Complete_Status__c = 'Test';
        place.Name= 'NameTest';
        place.Placement_Status_Code__c='112987';
        place.Parent_Status__C ='test2';
        place.Data_Status_Code__c ='DataStatus Code';
        place.Data_Status_Description__c='dataStatusDescription';
        place.Status__c='status';
        place.Sub_Status__c='subStatus1';
        insert place;
        
        Data_Status_Mapping__c dataStatusMapping = new Data_Status_Mapping__c();
        dataStatusMapping.Name ='123233';
        dataStatusMapping.Description__c ='Warehouse';
        dataStatusMapping.Description1__c ='Description1 Allocation';
        dataStatusMapping.Description2__c ='Description2 Allocation';
        insert dataStatusMapping;
        
        insert prod;
        // insert place;

        PageReference testPage = Page.AgencyPoolRecall;
        Test.setCurrentPage(testPage);
        
        ApexPages.currentPage().getParameters().put('id', pool.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(pool);
        AgencyPoolRecallController controller = new AgencyPoolRecallController(sc);
        list<Product__c> pclist = new list<Product__c>();
        pclist.add(prod);
        controller.listProd = pclist;
        controller.selectedValueAction = 'Pending Recall';
        controller.getItems();
        controller.getactionItems();
        controller.selectedValue = '112987';// For code coverage
       //  controller.oldPlacementID = a1x7g0000004C5uAAE;
        controller.listProd = pclist;
        controller.recallProduct();
        controller.selectedValueAction = 'Send to Warehouse';
        controller.recallProduct();
        controller.selectedValueAction = 'Pending Allocation';
        controller.recallProduct();       
        controller.selectedValueAction = 'Pending Recall';
        controller.recallProduct();        
        controller.recallWithWarning();
        controller.selectedValueAction = 'Send to Warehouse';
        controller.recallWithWarning();
        controller.selectedValueAction = 'Pending Allocation';
        controller.recallWithWarning();       
        controller.selectedValueAction = 'Pending Recall';
        controller.recallWithWarning();        
        ProductTriggerHandler.runProductTrigger = true;
        controller.redirectToPool();
    }
    
    static testMethod void testWrapperclass(){
        
        Product__c prod = new Product__c(Name='Test');
        String comments ='Test';
        List<AgencyPoolRecallController.productWrapper> w;
        
        AgencyPoolRecallController.productWrapper testWrap=new AgencyPoolRecallController.productWrapper(prod,comments); 
        
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
        
       //list<Pool__c> poolList = new list<Pool__c>();
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        insert plcmnt;  
        
        Pool__c pool = new Pool__c();
        //pool.Name = 'P0001';
        //pool.Placement_Agency__c = 89;
        pool.Placement_Agency__c = null;
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
        prod.Status__c = 'Client Request - Others';
        prod.Sub_Status__c = 'Recall'; 
        prod.Product_Status__c = 'Test';
        prod.Legal_Status__c='Legal';
        insert prod;


        PageReference testPage = Page.AgencyPoolRecall;
        Test.setCurrentPage(testPage);
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', pool.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(pool);
        AgencyPoolRecallController controller = new AgencyPoolRecallController(sc);
        controller.redirectToPool();
        //controller.recallWithWarning();
        Test.StopTest(); 
    }
    

    public static testMethod void testvalidationOnRecordUpdate()
    {
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
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
        prod.Status__c = 'Client Request - Others';
        prod.Sub_Status__c = 'Recall'; 
        prod.Product_Status__c = 'Test';
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        ProductTriggerHandler.runProductTrigger = true;

        
        PageReference testPage = Page.AgencyPoolRecall;
        Test.setCurrentPage(testPage);
        Test.StartTest();
        ApexPages.currentPage().getParameters().put('id', pool.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(pool);
        AgencyPoolRecallController controller = new AgencyPoolRecallController(sc);
        //controller.recallProduct();
        Test.StopTest(); 

    }

    public static API_Call_Details__c testDocumentAPI(){
        //Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
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
        settings.API_Request_Timeout__c = 90000; 
        insert settings;
        return settings;
        
    }    
}