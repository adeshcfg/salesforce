@isTest
private class TestPlacementHistoryTriggerHandler {
    
    //Initialize Custom Settings
    static {
        
        API_Call_Details__c settings = new API_Call_Details__c();      
        
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
        
        Loan_ReEngineering__c loanSettings = new Loan_ReEngineering__c();
        loanSettings.Run_Product_Validation_Trigger__c = true;
        loanSettings.Run_Product_Trigger__c = true;
        loanSettings.Run_Product_Before_Trigger__c = true;
        loanSettings.Load_Customer_Data__c = true;
        loanSettings.Canaccede_API_User__c = 'abc@xyz.com';
        insert loanSettings;   
        
        Distress_Setting__c drsetting = new Distress_Setting__c();
        drsetting.Run_Placement_History_Trigger__c = true;
        insert drsetting;
       
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Run_Product_Coll_Sub_Status_Validation__c = true;
        insert config;
    }
    
    //Test Before Update
    static testMethod void productBeforeUpdateTest(){
        
        Product__c prod = new Product__c();
        
        prod.name = '12345';
        prod.Payment_Setup_Status__c = 'Automated';
        prod.Funding_Status__c = 'Pending';
        prod.Funding_Type__c = 'Automated';
        prod.Disbursement_Amount__c = 2000.00;
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Loan Account').getRecordTypeId();
        ProductTriggerHandler.runProductTrigger = False;
        insert prod;
        ProductTriggerHandler.runProductTrigger = True;
        
        Placement__c place = new Placement__c();
        place.name = '1';
        insert place;
        
        Placement_History__c placeHist = new Placement_History__c();
        placeHist.product__c = prod.id;
        placeHist.Placement_ID_Text__c = '1';
        insert placeHist;
        
        Placement_History__c placeHist1 = new Placement_History__c();
        placeHist1.product__c = prod.id;
        placeHist1.Placement_ID_Text__c = '1';
        insert placeHist1;
        
        List<Placement_History__c> listHist = new List<Placement_History__c>();
        listHist.add(placeHist);
        Map<Id, Placement_History__c> mapPlacementHistory = new Map<Id, Placement_History__c>();
        mapPlacementHistory.put(placeHist1.id,placeHist1);
        PlacementHistoryTriggerHandler.handleBeforeInsert(listHist);
        PlacementHistoryTriggerHandler.handleBeforeUpdate(listHist,mapPlacementHistory);
        
    }
    
}