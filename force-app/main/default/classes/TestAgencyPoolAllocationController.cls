@isTest
public class TestAgencyPoolAllocationController {
     @testSetup
    static void testData(){
        Placement_Status_Mapping__c placementStatusMap = Placement_Status_Mapping__c.getOrgDefaults();
        placementStatusMap.Name = '100000';
        placementStatusMap.Description__c = 'New Allocation (1.0); Ready';
        insert placementStatusMap;  
    }
    
    public static testMethod void testConstructor(){
        Boolean countrefresh = true;
        Boolean error = true;
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
        
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name= '89'; 
        plcmnt.Serviceable_Province__c = 'Nova Scotia';
        plcmnt.Agency_Name__c = 'CCS Agency';
        plcmnt.Active__c = True;
        insert plcmnt;   
        
        Placement_Status_Code_Mapping__c code = new Placement_Status_Code_Mapping__c();
        code.Name = '100000';
        code.Parent_Status__c = 'New Allocation';
        code.Placement_Status_Code__c = '100000';
        code.Status__c = 'New Allocation';
        code.Sub_Status__c = 'Ready';
        insert code;
        
        Pool__c pool = new Pool__c();
        pool.Placement_Agency__c = 89;
        pool.Placement_agency_lookup__c = plcmnt.id;
        pool.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool;
        
        Pool__c pool1 = new Pool__c();
        pool1.Placement_Agency__c = 9999;
        pool1.Id = ApexPages.currentPage().getParameters().get('id');   
        insert pool1;
        
        //Product Record Creation
        Product__c prod=new Product__C();
        prod.Pool_Name__c = pool.id;
        prod.Name ='647P1545';
        prod.Previously_Reviewed_for_Legal_Action__c=True;
        prod.Current_Principal_Balance__c = 101;
        prod.Current_Interest_Amount__c = 1000;
        prod.Collection_Agency_Placement__c = plcmnt.id;
        prod.Collection_Sub_Status__c = 'Annulled';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Pool_Name__c = pool.Id;
        prod.Data_Status_Description__c = 'Test';
        prod.Current_Bal_NSF_Fees__c = null;
        prod.Recoverable_Fee__c = 100;
        prod.Current_Bal_NSF_Fees__c = 200;
        prod.Placement_Status__c = '100000';
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        
        Product__c prod1=new Product__C();
        prod1.Pool_Name__c = pool1.id;
        prod1.Name ='647P1546';
        prod1.Previously_Reviewed_for_Legal_Action__c=True;
        prod1.Current_Principal_Balance__c = 101;
        prod1.Current_Interest_Amount__c = 1000;
        prod1.Collection_Agency_Placement__c = plcmnt.id;
        prod1.Collection_Sub_Status__c = 'Annulled';
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.Pool_Name__c = pool.Id;
        prod1.Data_Status_Description__c = 'Test';
        prod1.Current_Bal_NSF_Fees__c = null;
        prod1.Recoverable_Fee__c = 100;
        prod1.Current_Bal_NSF_Fees__c = NULL;
        prod1.Placement_Status__c = '100000';
        prod1.Allocated_Amount_Fees__c = NULL;
        prod1.Allocated_Amount_Principal__c = NULL;
        prod1.Allocated_Amount_Interest__c = NULL;
        ProductTriggerHandler.runProductTrigger = false;
        insert prod1;
       
        List<product__c> prodNew = new List<product__c>();
        prodNew.add(prod);
        
        ApexPages.currentPage().getParameters().put('id', pool.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(pool);
        AgencyPoolAllocationController controller = new AgencyPoolAllocationController(sc);
        AgencyPoolAllocationController.getSnapshortRecords(prodNew);
        controller.allocateAgencyToProduct();
        controller.allocateWithWarning(); 
        controller.Alert_msg = 'test';
        controller.redirectToPool();
        
        ApexPages.currentPage().getParameters().put('id', pool1.Id);
        ApexPages.StandardController sc1 = new ApexPages.standardController(pool1);
        AgencyPoolAllocationController controller1 = new AgencyPoolAllocationController(sc1);
        ProductTriggerHandler.runProductTrigger = true;
        
    }
    
    static testMethod void testWrapperclass(){
        Product__c prod = new Product__c(Name='123456789');
        String comments ='Test';
        AgencyPoolAllocationController.productWrapper testWrap=new AgencyPoolAllocationController.productWrapper(prod,comments); 
        
    }
    
}