/**************************************************************************************************
 *
 *  Class:   
 *  @description : Test class for PortalDocumentStorageProcessor and PortalDocumentStorageProcessorUtil
 *  @author : A5E Consulting
 *  @date : 28/01/2022
 
 *************************************************************************************************/
@isTest
public class TestPortalDocumentStorageProcessor {
	    
    public static testMethod void testPortalDocumentStorage(){
        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"Name":"Test","Document_Storage_Number":"DC-000126", "Product_Identifier": "Test Product",'+
                                    '"Created_By": "annu@test.com","Judgment_Identifier": null,"Document_URL":"GTets","Document_Type":"Account Status Update File",'+
                                    '"Last_Modified_By": "test","Customer_Identifier": null,"Placement_Identifier":null,'+
                                    '"Settlement_Identifier": null,"Work_Assignment_Identifier": null}';
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalDocumentStorageProcessor.postAssignment();
    }
    
    public static testMethod void PortalDocumentStorageProcessorUtil(){
        /*Account customerInstance = PaymentProcessorTestUtility.getDistressedAccount();
        system.debug('ss'+customerInstance.SF_ID__c);
        Product__c product = PaymentProcessorTestUtility.getDistressedProduct();
        product.Customer__c = customerInstance.Id;
        update product;

        system.debug('sss'+customerInstance.Products__r);

        ID CanaccedeCustomerRecordTypeID = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
        Account accInstance = new Account();
        accInstance.FirstName = 'Anna';
        accInstance.LastName = 'Stark';
        accInstance.PersonBirthdate = system.today().addYears(-30);
        insert accInstance; */
        
        Placement__c place = new Placement__c();
        place.name = '1';
        insert place;
        
        Id DistressedRecordTypeID =  Schema.SObjectType.Document_Storage__c.getRecordTypeInfosByName().get('Distressed').getRecordTypeId();
      
        Product__c productInstance = new Product__c();
        productInstance.Name = '100000002';
        productInstance.Status__c = 'New Allocation - New Allocation';
        productInstance.Sub_Status__c = 'Ready';
        productInstance.Product_Status__c = 'Test';
        insert productInstance;
        
        Judgment__c judgment = new Judgment__c();
        judgment.Judgment_Number__c = 'JC-001';
        judgment.Legal_Agency__c = 'Test Agency';
        insert judgment;
 
        Document_Storage__c docStorage = new Document_Storage__c();
     
        docStorage.Document_Storage_Number__c = 'DC-002300';
        docStorage.Product__c = productInstance.Id;
        docStorage.Product_Identifier__c = '100000002';
        docStorage.Judgment__c = judgment.ID;
        docStorage.Judgment_Identifier__c = 'JC-001';
        docStorage.Document_Type__c = 'Account Status Update File';
        docStorage.RecordTypeId = DistressedRecordTypeID;
        docStorage.Placement_Identifier__c = '1';
        insert docStorage;
        
        docStorage.Document_Type__c = 'Account Status Update File';
        update docStorage;
      
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Distressed_Document_Storage_RecordtypeID__c = docStorage.RecordTypeId;
        insert portalSettings;
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('Name', 'Test');
        paramMap.put('Document_Storage_Number', 'DC-000126');
        paramMap.put('Document_Type', 'Account Status Update File');
        paramMap.put('Product_Identifier','100000002');
        paramMap.put('Judgment_Identifier','JC-001');
        paramMap.put('Created_By','Test User');
        paramMap.put('Document_URL','refer to legal');
        paramMap.put('Last_Modified_By','Test User');
        paramMap.put('Placement_Identifier','1');
        paramMap.put('Record','null');
 
        PortalDocumentStorageProcessorUtil.processDocumentStorage(paramMap, docStorage);
    }

}