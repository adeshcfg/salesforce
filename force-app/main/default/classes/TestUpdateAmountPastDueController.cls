@isTest
public class TestUpdateAmountPastDueController {
    public static testMethod void TestProduct(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        UpdateAmountPastDueController.ResponseJSON wrap=new UpdateAmountPastDueController.ResponseJSON();
        wrap.isSuccess=true;
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        String bodyParams =  'client_id='+settings.Client_ID__c;
        bodyParams =  bodyParams+'&client_secret='+settings.Client_Secret__c;
        bodyParams =  bodyParams+'&scope='+settings.Scope_Prefix__c+settings.Proxy_Client_ID__c+settings.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        
		Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(settings.AuthorizationtUrl__c);
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Integer counter;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.Past_Due_Amount_Refresh_Date__c = system.Today();
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', prodInstance.Id);
		UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController();

        UpdateAmountPastDueController.HostIntegrationDataResult data = new UpdateAmountPastDueController.HostIntegrationDataResult();
        data.amDlq = 'test';
        UpdateAmountPastDueController.Payload payLoaddata = new UpdateAmountPastDueController.Payload();
        payLoaddata.acctId = '12345';
        UpdateAmountPastDueController.ResponseJSON ResponseJSONdata = new UpdateAmountPastDueController.ResponseJSON();
        ResponseJSONdata.code = '12345';
        ResponseJSONdata.statusCode = 200;
        ResponseJSONdata.tag = '12345';
        ResponseJSONdata.isSuccess = true;
        ResponseJSONdata.data = data;
        UpdateAmountPastDueController.ResponseErrorJSON ResponseErrJSONdata = new UpdateAmountPastDueController.ResponseErrorJSON();
        ResponseErrJSONdata.code = '12345';
        ResponseErrJSONdata.statusCode = 200;
        ResponseErrJSONdata.tag = '12345';
        ResponseErrJSONdata.isSuccess = true;
        ResponseErrJSONdata.data = true;
        UpdateAmountPastDueController.ResponseJSON ResponseJSONdata1 = new UpdateAmountPastDueController.ResponseJSON();
        ResponseJSONdata1.isSuccess = false;
        controller1.updateAmountPastDueAPI();
        controller1.redirectToProduct();
        counter = 1;
        Test.stopTest();
    }
    
    public static testMethod void TestProduct1(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/documentAPI';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        String bodyParams =  'client_id='+settings.Client_ID__c;
        bodyParams =  bodyParams+'&client_secret='+settings.Client_Secret__c;
        bodyParams =  bodyParams+'&scope='+settings.Scope_Prefix__c+settings.Proxy_Client_ID__c+settings.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        
		Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(settings.AuthorizationtUrl__c);
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', Null);
		UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController();
        try{
           controller1.updateAmountPastDueAPI(); 
        }Catch(Exception ex){
            
        }
        Test.stopTest();
    }
    
    public static testMethod void TestProduct2(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        UpdateAmountPastDueController.ResponseJSON wrap=new UpdateAmountPastDueController.ResponseJSON();
        wrap.isSuccess=true;
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/FidemAPI';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', prodInstance.Id);
		UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController();
        controller1.updateAmountPastDueAPI();
        controller1.redirectToProduct();
        UpdateAmountPastDueController.ResponseErrorJSON ResponseErrJSONdata = new UpdateAmountPastDueController.ResponseErrorJSON();
        ResponseErrJSONdata.code = '2020';
        ResponseErrJSONdata.statusCode = 500;
        ResponseErrJSONdata.tag = '12345';
        ResponseErrJSONdata.isSuccess = false;
        ResponseErrJSONdata.data = true;
        Test.stopTest();
    }
    
    public static testMethod void TestProduct3(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        UpdateAmountPastDueController.ResponseJSON wrap=new UpdateAmountPastDueController.ResponseJSON();
        wrap.isSuccess=true;
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/FidemAPIError';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        String bodyParams =  'client_id='+settings.Client_ID__c;
        bodyParams =  bodyParams+'&client_secret='+settings.Client_Secret__c;
        bodyParams =  bodyParams+'&scope='+settings.Scope_Prefix__c+settings.Proxy_Client_ID__c+settings.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        
		Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(settings.AuthorizationtUrl__c);
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', prodInstance.Id);
		UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController();

        UpdateAmountPastDueController.HostIntegrationDataResult data = new UpdateAmountPastDueController.HostIntegrationDataResult();
        data.amDlq = 'test';
        UpdateAmountPastDueController.Payload payLoaddata = new UpdateAmountPastDueController.Payload();
        payLoaddata.acctId = '12345';
        UpdateAmountPastDueController.ResponseJSON ResponseJSONdata = new UpdateAmountPastDueController.ResponseJSON();
        ResponseJSONdata.code = '12345';
        ResponseJSONdata.statusCode = 200;
        ResponseJSONdata.tag = '12345';
        ResponseJSONdata.isSuccess = true;
        ResponseJSONdata.data = data;
        UpdateAmountPastDueController.ResponseErrorJSON ResponseErrJSONdata = new UpdateAmountPastDueController.ResponseErrorJSON();
        ResponseErrJSONdata.code = '2037';
        ResponseErrJSONdata.statusCode = 500;
        ResponseErrJSONdata.tag = '12345';
        ResponseErrJSONdata.isSuccess = false;
        ResponseErrJSONdata.data = true;
        controller1.updateAmountPastDueAPI();
        controller1.redirectToProduct();
        Test.stopTest();
    }
    
    public static testMethod void TestProduct4(){ 
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        UpdateAmountPastDueController.ResponseJSON wrap=new UpdateAmountPastDueController.ResponseJSON();
        wrap.isSuccess=true;
        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Fidem Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/FidemAPIErrorTest';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        String bodyParams =  'client_id='+settings.Client_ID__c;
        bodyParams =  bodyParams+'&client_secret='+settings.Client_Secret__c;
        bodyParams =  bodyParams+'&scope='+settings.Scope_Prefix__c+settings.Proxy_Client_ID__c+settings.Scope_Suffix__c;
        bodyParams =  bodyParams+'&grant_type=client_credentials';
        
        
		Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(bodyParams);
        req.setHeader('Content-Length', String.valueOf(bodyParams.length()));
        req.setEndpoint(settings.AuthorizationtUrl__c);
        
    	Placement__c plcgy1 = new  Placement__c();      
        plcgy1.Name='101'; 
        plcgy1.Agency_Email__c = 'test@gmail.com';
        insert plcgy1;
        
        Product__c prodInstance = new Product__c();
        prodInstance.Name = 'TestName';
        prodInstance.Funding_Status__c = 'Funded';
        prodInstance.Funding_Type__c = 'Automated';
        prodInstance.Disbursement_Amount__c = 3000.00;
        prodInstance.Status__c = 'New Allocation - New Allocation';
        prodInstance.Sub_Status__c = 'Ready';
        prodInstance.Product_Status__c = 'Test';
        prodInstance.Collection_Agency__c = Decimal.valueOf(plcgy1.name);
        prodInstance.State__c = 'ON';
        prodInstance.Current_Principal_Balance__c = 5000;
        prodInstance.Outbound_API_Request_Body__c = 'Testing';
        prodInstance.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prodInstance;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', prodInstance.Id);
		UpdateAmountPastDueController controller1 = new UpdateAmountPastDueController();

        UpdateAmountPastDueController.HostIntegrationDataResult data = new UpdateAmountPastDueController.HostIntegrationDataResult();
        data.amDlq = 'test';
        UpdateAmountPastDueController.Payload payLoaddata = new UpdateAmountPastDueController.Payload();
        payLoaddata.acctId = '12345';
        UpdateAmountPastDueController.ResponseJSON ResponseJSONdata = new UpdateAmountPastDueController.ResponseJSON();
        ResponseJSONdata.code = '12345';
        ResponseJSONdata.statusCode = 200;
        ResponseJSONdata.tag = '12345';
        ResponseJSONdata.isSuccess = true;
        ResponseJSONdata.data = data;
        UpdateAmountPastDueController.ResponseErrorJSON ResponseErrJSONdata = new UpdateAmountPastDueController.ResponseErrorJSON();
        ResponseErrJSONdata.code = '2037';
        ResponseErrJSONdata.statusCode = 500;
        ResponseErrJSONdata.tag = '12345';
        ResponseErrJSONdata.isSuccess = false;
        ResponseErrJSONdata.data = true;
        controller1.updateAmountPastDueAPI();
        controller1.redirectToProduct();
        Test.stopTest();
    }
}