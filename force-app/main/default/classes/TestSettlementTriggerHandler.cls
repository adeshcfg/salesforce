/**************************************************************************************************
*
*  Class:   
*  @description : This is a Test class for SettlementTriggerHandler
*  @author : A5E Consulting
*  @date : 06/12/2020

*************************************************************************************************/
@isTest
public class TestSettlementTriggerHandler {
    
    public static testMethod void testHandler(){
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.Run_Settlement_Trigger__c = true;
        insert loanSettings;
        
        
        List<Placement__c> placeList = new List<Placement__c>();
        Placement__c place = new Placement__c();
        
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        placeList.add(place);
        
        place = new Placement__c();
        
        place.Name = '40';
        place.Agency_Name__c = 'National Credit Recovery Inc.';
        placeList.add(place);        
        insert placeList;
        
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
        
        list<Account> listAccounts = new list<Account>();
        for(integer i=0; i < 2; i++){
            system.debug('i: '+i);
            Account accInstance = new Account();
            accInstance.LastName = 'TestName'+i;
            accInstance.RecordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId();
            listAccounts.add(accInstance);
        }
        insert listAccounts;
        
        system.debug('listAccounts: '+listAccounts);
        list<Product__c> listProduct = new list<Product__c>();
        for(Account acc : listAccounts){
            Product__c productWithAgency2 = new Product__c();
            productWithAgency2.Customer__c = acc.Id;
            productWithAgency2.Run_Identifier_Check_On__c = Date.today();
            productWithAgency2.Collection_Agency__c = 6;
            productWithAgency2.Status__c = 'New Allocation - New Allocation';
            productWithAgency2.Sub_Status__c = 'Ready';
            productWithAgency2.Product_Status__c = 'Test';
            productWithAgency2.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(productWithAgency2);
            
            Product__c distressedProdInstance = new Product__c();
            distressedProdInstance.Customer__c = acc.Id;
            distressedProdInstance.Run_Identifier_Check_On__c = Date.today();
            distressedProdInstance.Status__c = 'New Allocation - New Allocation';
            distressedProdInstance.Sub_Status__c = 'Ready';
            distressedProdInstance.Product_Status__c = 'Test';
            distressedProdInstance.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
            listProduct.add(distressedProdInstance);
        }
        insert listProduct;
      
        system.debug('listproduct'+listProduct);
        
        Judgment__c judgmentInst = new Judgment__c();
        judgmentInst.Run_Identifier_Check_On__c = Date.today();
        judgmentInst.Collection_Agency_Identifier__c = 'A68A';
        judgmentInst.Legal_Agency__c = 'Test Agency';
        insert judgmentInst;
        
        Settlement__c settlementInst = new Settlement__c();
        settlementInst.Judgment__c = judgmentInst.Id;
        settlementInst.Placement_Text_Id__c = '6';
        insert settlementInst;
        
        Judgment__c judgmentInst2 = new Judgment__c();
        judgmentInst2.Run_Identifier_Check_On__c = Date.today();
        judgmentInst2.Legal_Agency__c = 'Test Agency';
        insert judgmentInst2;
        
        Placement__c placemntInst = new Placement__c(); 
        placemntInst.Name = '11';
        placemntInst.Agency_Name__c = 'ABC';
        insert placemntInst;
        
        Agency_Portal_Fields_Mapping__c FieldMap = new Agency_Portal_Fields_Mapping__c();
        FieldMap.Field_API__c = 'Product__c';
        FieldMap.Field_JSON_Tag__c ='Product';
        FieldMap.Object_Name__c = 'Settlement';
        FieldMap.Name = 'Product';               
        insert FieldMap;
        
        Agency_Portal_Fields_Mapping__c FieldMap1 = new Agency_Portal_Fields_Mapping__c();
        FieldMap1.Field_API__c = 'Judgment__c';
        FieldMap1.Field_JSON_Tag__c ='Judgment';
        FieldMap1.Object_Name__c = 'Settlement';
        FieldMap1.Name = 'Judgment';               
        insert FieldMap1;
        
        Agency_Portal_Fields_Mapping__c FieldMap2 = new Agency_Portal_Fields_Mapping__c();
        FieldMap2.Field_API__c = 'Settlement_Number__c';
        FieldMap2.Field_JSON_Tag__c ='Settlement_Number';
        FieldMap2.Object_Name__c = 'Settlement';
        FieldMap2.Name = 'Settlement_Number';               
        insert FieldMap2;
        
        List<Settlement__c> sttlmntData = new List<Settlement__c>();
        Settlement__c settlementInst2 = new Settlement__c();
        settlementInst2.Judgment__c = judgmentInst2.Id;
        settlementInst2.Placement__c = placemntInst.Id;
        settlementInst2.Proposal_Amount__c = 123;
        settlementInst2.Placement_Text_Id__c = '6';
        settlementInst2.Placement_Identifier__c = placemntInst.Id;
        settlementInst2.Judgment_Identifier__c = judgmentInst2.Id;
        sttlmntData.add(settlementInst2);
        insert sttlmntData;
        
        
       list<Settlement__c> listSettlement = new list<Settlement__c>();        
        for(Product__c prod : listProduct){
            Settlement__c settlementProdInst = new Settlement__c();
            settlementProdInst.Product__c = prod.Id;
            listSettlement.add(settlementProdInst);
        }
        insert listSettlement;  
        
        settlementInst2.Judgment__c = judgmentInst.Id;
        settlementInst2.Proposal_Amount__c = 111;
        //settlementInst2.Placement__c = placemntInst1.Id;     
        update sttlmntData;
        
        //SettlementTriggerHandler.getSettlementRelatedAgencyData(sttlmntData);
    }
}