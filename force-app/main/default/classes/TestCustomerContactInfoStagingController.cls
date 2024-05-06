@isTest
public class TestCustomerContactInfoStagingController {
    @TestSetup
    static void makeData() {
        Work_Assignment__c workAssignment = new Work_Assignment__c();
        workAssignment.Requested_Date__c = Date.today();
        workAssignment.Title__c = 'Product Status Update' + Date.today();
        workAssignment.Description__c = 'Product Status Update Status';
        workAssignment.Status__c = 'Completed';
        workAssignment.Assign_To__c = 'Agency';
        workAssignment.Priority__c = 'High';
        workAssignment.Purpose__c = 'Payment';
        workAssignment.Sub_Purpose__c = 'Customer Contact Information Update File';
        workAssignment.Comments_History__c = 'test';
        insert workAssignment;

        Document_Storage__c failedDocStorage = new Document_Storage__c();
        failedDocStorage.Work_Assignment__c = workAssignment.Id;
        failedDocStorage.Document_Name__c = 'Product Failed.csv';
        failedDocStorage.Document_Extension__c = 'csv';
        failedDocStorage.Document_Type__C = 'Payment Processing File';
        failedDocStorage.Visibility__c = 'Authoring agencies + CFG  ';
        failedDocStorage.Uploaded_By__c = 'Internal User';
        failedDocStorage.Creator__c = UserInfo.getName();
        failedDocStorage.File_Processing_Date__c = System.Today();
        failedDocStorage.Document_Related_To__c = 'Task';
        failedDocStorage.File_Processing_Status__c = 'In Progress';
        insert failedDocStorage;
    }

    public static API_Call_Details__c testDocumentAPI() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI'; //endpointurl
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        insert settings;
        return settings;
    }

    @isTest
    static void testGenerateSuccessAndErrorFile() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Pending';
        custStaging.Document_Storage__c = failedDocStorage.id;
        custStaging.Include_in_Processing__c = true;

        Customer_Staging__c custStaging1 = new Customer_Staging__c();
        custStaging1.Comment__c = 'SUCCESS';
        custStaging1.ProdID__c = '656P178';
        custStaging1.Placement_Agency__c = '68';
        custStaging1.Status__c = 'Processed';
        custStaging1.Document_Storage__c = failedDocStorage.id;
        insert new List<Customer_Staging__c>{ custStaging, custStaging1 };

        testDocumentAPI();
        DisplayCustomerContInfoStagingController.GenerateSuccessAndErrorFile(
            new List<Customer_Staging__c>{ custStaging, custStaging1 },
            workAssignment.Id,
            'CFG + Requesting Agency',
            failedDocStorage.Id
        );
    }

    @isTest
    static void testMethodSave() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.documentID = failedDocStorage.Id;
        dc.save();
    }

    @isTest
    static void testMethod1() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.updateSet();
    }
    @isTest
    static void testMethod2() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.id;
        dc.getTotalPages();
    }
    @isTest
    static void testMethod3() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c api = testDocumentAPI();
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Include_in_Processing__c = true;
        custStaging.Document_Storage__c = failedDocStorage.id;
        Customer_Staging__c custStaging1 = new Customer_Staging__c();
        custStaging1.Comment__c = 'SUCCESS';
        custStaging1.ProdID__c = '656P178';
        custStaging1.Placement_Agency__c = '68';
        custStaging1.Status__c = 'Processed';
        custStaging1.Include_in_Processing__c = false;
        custStaging1.Document_Storage__c = failedDocStorage.id;
        list<Customer_Staging__c> abc = new List<Customer_Staging__c>();
        abc.add(custStaging);
        abc.add(custStaging1);
        insert abc;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController.GenerateSuccessAndErrorFile(abc, workAssignment.Id, 'abc', failedDocStorage.Id);
    }
    @isTest
    static void testMethod4() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Identifier__c = failedDocStorage.id;
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.getlistCustomerContInfoStagingWrapper();
    }
    @isTest
    static void testMethod5() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        API_Call_Details__c api = testDocumentAPI();
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        custStaging.Include_in_Processing__c = true;
        insert custStaging;
        Customer_Staging__c custStaging1 = new Customer_Staging__c();
        custStaging1.Comment__c = 'SUCCESS';
        custStaging1.ProdID__c = '656P178';
        custStaging1.Placement_Agency__c = '68';
        custStaging1.Status__c = 'Pending';
        custStaging1.Include_in_Processing__c = false;
        custStaging1.Document_Storage__c = failedDocStorage.id;
        insert custStaging1;

        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;

        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        system.debug('workassignment--->' + custStaging.Document_Storage__r.Work_Assignment__c);
        List<Customer_Staging__c> custList = [
            SELECT
                id,
                Coborrower_Address2__c,
                Coborrower_Cell_Phone__c,
                Coborrower_Home_Phone__c,
                Coborrower_Work_Phone__c,
                Coborrower_Country__c,
                Coborrower_Postal_Code__c,
                Coborrower_State__c,
                Coborrower_City__c,
                Coborrower_Address1__c,
                Coborrower_Email__c,
                Cell_Phone__c,
                Country__c,
                Home_Phone__c,
                Work_Phone__c,
                Postal_Code__c,
                city__c,
                state__c,
                Address_Line2__c,
                Address_Line1__c,
                Document_Storage__c,
                Include_in_Processing__c,
                Email_Address__c,
                status__c,
                comment__c,
                Placement_Agency__c,
                prodID__c,
                Document_Storage__r.Work_Assignment__c
            FROM Customer_Staging__c
        ];
        DisplayCustomerContInfoStagingController.processRecords(custList);
    }
    @isTest
    static void testMethod6() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;

        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.id;
        dc.selectAll();
    }
    @isTest
    static void testMethod7() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.updateSearchItemsMap();
    }
    @isTest
    static void testMethod8() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;

        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.last();
    }
    @isTest
    static void testMethod9() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Pending';
        custStaging.Identifier__c = failedDocStorage.Id;
        custStaging.Include_in_Processing__c = false;
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = false;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.getAllRecords();
        dc.previous();
    }
    @isTest
    static void testMethod10() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;

        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.isSelected = true;
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.next();
    }
    @isTest
    static void testMethod11() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.isSelected = true;
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.first();
    }
    @isTest
    static void testMethod12() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = true;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.getlistCustomerContInfoStagingWrapper();
    }
    @isTest
    static void testMethod13() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = new Document_Storage__c();
        failedDocStorage.Work_Assignment__c = workAssignment.Id;
        failedDocStorage.Document_Name__c = 'Product Failed.csv';
        failedDocStorage.Document_Extension__c = 'csv';
        failedDocStorage.Document_Type__C = 'Payment Processing File';
        failedDocStorage.Visibility__c = 'Authoring agencies + CFG  ';
        failedDocStorage.Uploaded_By__c = 'Internal User';
        failedDocStorage.Creator__c = UserInfo.getName();
        failedDocStorage.File_Processing_Date__c = System.Today();
        failedDocStorage.Document_Related_To__c = 'Task';
        failedDocStorage.File_Processing_Status__c = 'Processed';
        insert failedDocStorage;

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Processed';
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = false;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.getlistCustomerContInfoStagingWrapper();
        dc.first();
        dc.last();
        dc.previous();
        dc.next();
        dc.selectAll();
    }
    @isTest
    static void testMethod14() {
        Work_Assignment__c workAssignment = [SELECT Id FROM Work_Assignment__c LIMIT 1];
        Document_Storage__c failedDocStorage = [SELECT Id FROM Document_Storage__c LIMIT 1];

        Customer_Staging__c custStaging = new Customer_Staging__c();
        custStaging.Comment__c = 'SUCCESS';
        custStaging.ProdID__c = '656P178';
        custStaging.Placement_Agency__c = '68';
        custStaging.Status__c = 'Pending';
        custStaging.Identifier__c = failedDocStorage.id;
        custStaging.Document_Storage__c = failedDocStorage.id;
        insert custStaging;
        DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper wrap = new DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper(
            custStaging,
            false
        );
        wrap.custStaging = custStaging;
        wrap.disabled = false;
        wrap.selected = true;
        list<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper> wrapList = new List<DisplayCustomerContInfoStagingController.customerContactInfoStagingWrapper>();
        wrapList.add(wrap);
        DisplayCustomerContInfoStagingController dc = new DisplayCustomerContInfoStagingController();
        dc.listCustomerContInfoStagingWrapper = wrapList;
        dc.isSelected = false;
        dc.recordIdentfier = failedDocStorage.Id;
        dc.getlistCustomerContInfoStagingWrapper();
    }
}
