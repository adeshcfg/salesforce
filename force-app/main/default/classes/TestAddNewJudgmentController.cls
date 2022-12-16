/**************************************************************************************************
 *
 *  Class:   TestAddNewJudgmentController
 *
 *  @description : This class contains unit tests for legal Judgment data functionality
 *  @author : A5E Consulting
 *  @date : 21/07/2019
 * 
 *************************************************************************************************/

@isTest
public class TestAddNewJudgmentController{
    @testSetup
    static void testData(){
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
        
        Judgment__c judg = new Judgment__c();
        judg.Legal_Agency__c = 'Test Agency';
        judg.Legal_Status__c = 'Pre-Judgment';
        judg.Legal_Sub_Status__c = 'Media Requested awaiting';
        insert judg;
        
        Product__c prod = TestRecordsFactory.createProduct('1111');
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.State__c = 'ontario';
        prod.Collection_Agency__c =29;
        insert prod;
        
        Product__c prod1 = TestRecordsFactory.createProduct('1112');
        prod1.Status__c = 'New Allocation - New Allocation';
        prod1.Sub_Status__c = 'Ready';
        prod1.Product_Status__c = 'Test';
        prod1.State__c = 'ON';
        prod1.Collection_Agency__c =29;
        insert prod1;
    }
    
   //Test linkRecords
    static testMethod void testlinkRecords(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Pre-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Media Requested awaiting';
        mapping.Codes__c='220000';
        mapping.Product_Parent__c ='Pre-Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
       
        Judgment__c judgment = new Judgment__c();
        judgment.Legal_Agency__c = 'Test Agency';
        judgment.Legal_Status__c = 'Pre-Judgment';
        judgment.Legal_Sub_Status__c = 'Media Requested awaiting';
        insert judgment;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        AddNewJudgmentController.linkRecords(prod.Id, judg.Id);
        AddNewJudgmentController.getlinkedJudgments(prod.Id);
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Pre-Judgment');
        judgMap.put('Legal_Sub_Status__c','Media Requested awaiting');
        AddNewJudgmentController.validationRule(prod.Id, judg.Id,judgMap);
        AddNewJudgmentController.nameFormat('ontario');
        AddNewJudgmentController.nameFormat('o');
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judgment.Id,judgMap);
        
        judgment.Product_1__c = '101-0011-111323';
        judgment.Interest_Rate_one__c = NULL;
        judgment.Suit_Amount_1__c = NULL;
        update judgment; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judgment.Id,judgMap);
        
        judgment.Product_2__c = '101-0011-111393';
        judgment.Interest_Rate_two__c = NULL;
        update judgment; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judgment.Id,judgMap);
        
        judgment.Product_3__c = '101-0011-118393';
        judgment.Interest_Rate_three__c = NULL;
        update judgment; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judgment.Id,judgMap);
        
        judgment.Product_4__c = '101-0011-111383';
        judgment.Interest_Rate_four__c = NULL;
        update judgment; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judgment.Id,judgMap);
    }
    
    static testMethod void testlinkRecords1(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Post-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Enforcement Lost';
        mapping.Codes__c='295080';
        mapping.Product_Parent__c ='Post-Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
        
        Judgment__c judg1 = new Judgment__c();
        judg1.Legal_Agency__c = 'Test Agency';
        judg1.Legal_Status__c = 'Post-Judgment';
        judg1.Legal_Sub_Status__c = 'Enforcement Lost';
        insert judg1;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod1 = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Attorney__c','');
        judgMap.put('Legal_Status__c','Post-Judgment');
        judgMap.put('Legal_Sub_Status__c','Enforcement Lost');
        AddNewJudgmentController.validationRule(prod1.Id, judg1.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod1.Id, judg1.Id,judgMap);
        
        judg1.Product_1__c = '101-0011-111323';
        judg1.Interest_Rate_one__c = NULL;
        judg1.Suit_Amount_1__c = NULL;
        update judg1; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod1.Id, judg1.Id,judgMap);
        
        judg1.Product_2__c = '101-0011-111393';
        judg1.Interest_Rate_two__c = NULL;
        update judg1; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod1.Id, judg1.Id,judgMap);
        
        judg1.Product_3__c = '101-0011-118393';
        judg1.Interest_Rate_three__c = NULL;
        update judg1; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod1.Id, judg1.Id,judgMap);
        
        judg1.Product_4__c = '101-0011-111383';
        judg1.Interest_Rate_four__c = NULL;
        update judg1; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod1.Id, judg1.Id,judgMap);
    }
    
    static testMethod void testlinkRecords2(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Pre-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Claim Served';
        mapping.Codes__c='220020';
        mapping.Product_Parent__c ='Pre-Judgment';
        insert mapping;
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
        
        Judgment__c judg2 = new Judgment__c();
        judg2.Legal_Agency__c = 'Test Agency';
        judg2.Legal_Status__c = 'Pre-Judgment';
        judg2.Legal_Sub_Status__c = 'Claim Served';
        insert judg2;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Pre-Judgment');
        judgMap.put('Legal_Sub_Status__c','Claim Served');
        AddNewJudgmentController.validationRule(prod.Id, judg2.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg2.Id,judgMap);
        
        judg2.Product_1__c = '101-0011-111323';
        judg2.Interest_Rate_one__c = NULL;
        judg2.Suit_Amount_1__c = NULL;
        update judg2; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg2.Id,judgMap);
        
        judg2.Product_2__c = '101-0011-111393';
        judg2.Interest_Rate_two__c = NULL;
        update judg2; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg2.Id,judgMap);
        
        judg2.Product_3__c = '101-0011-118393';
        judg2.Interest_Rate_three__c = NULL;
        update judg2; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg2.Id,judgMap);
        
        judg2.Product_4__c = '101-0011-111383';
        judg2.Interest_Rate_four__c = NULL;
        update judg2; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg2.Id,judgMap);
    }
    
    static testMethod void testlinkRecords3(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Consent Judgment';
        mapping.Codes__c='290005';
        mapping.Product_Parent__c ='Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
        
        Judgment__c judg3 = new Judgment__c();
        judg3.Legal_Agency__c = 'Test Agency';
        judg3.Legal_Status__c = 'Judgment';
        judg3.Legal_Sub_Status__c = 'Consent Judgment';
        insert judg3;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Judgment');
        judgMap.put('Legal_Sub_Status__c','Consent Judgment');
        AddNewJudgmentController.validationRule(prod.Id, judg.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg3.Id,judgMap);
        
        judg3.Product_1__c = '101-0011-111323';
        judg3.Interest_Rate_one__c = NULL;
        judg3.Suit_Amount_1__c = NULL;
        update judg3; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg3.Id,judgMap);
        
        judg3.Product_2__c = '101-0011-111393';
        judg3.Interest_Rate_two__c = NULL;
        update judg3; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg3.Id,judgMap);
        
        judg3.Product_3__c = '101-0011-118393';
        judg3.Interest_Rate_three__c = NULL;
        update judg3; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg3.Id,judgMap);
        
        judg3.Product_4__c = '101-0011-111383';
        judg3.Interest_Rate_four__c = NULL;
        update judg3; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg3.Id,judgMap);
    }
    static testMethod void testlinkRecords4(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Post-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Wage Garnishment';
        mapping.Codes__c='293000';
        mapping.Product_Parent__c ='Post-Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
        
        Judgment__c judg4 = new Judgment__c();
        judg4.Legal_Agency__c = 'Test Agency';
        judg4.Legal_Status__c = 'Post-Judgment';
        judg4.Legal_Sub_Status__c = 'Wage Garnishment';
        insert judg4;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Post-Judgment');
        judgMap.put('Legal_Sub_Status__c','Wage Garnishment');
        AddNewJudgmentController.validationRule(prod.Id, judg.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg4.Id,judgMap);
        
        judg4.Product_1__c = '101-0011-111323';
        judg4.Interest_Rate_one__c = NULL;
        judg4.Suit_Amount_1__c = NULL;
        update judg4; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg4.Id,judgMap);
        
        judg4.Product_2__c = '101-0011-111393';
        judg4.Interest_Rate_two__c = NULL;
        update judg4; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg4.Id,judgMap);
        
        judg4.Product_3__c = '101-0011-118393';
        judg4.Interest_Rate_three__c = NULL;
        update judg4; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg4.Id,judgMap);
        
        judg4.Product_4__c = '101-0011-111383';
        judg4.Interest_Rate_four__c = NULL;
        update judg4; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg4.Id,judgMap);
    }
    static testMethod void testlinkRecords5(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Post-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Writ Filed';
        mapping.Codes__c='295000';
        mapping.Product_Parent__c ='Post-Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);        
        
        Judgment__c judg5 = new Judgment__c();
        judg5.Legal_Agency__c = 'Test Agency';
        judg5.Legal_Status__c = 'Post-Judgment';
        judg5.Legal_Sub_Status__c = 'Writ Filed';
        
        insert judg5;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Post-Judgment');
        judgMap.put('Legal_Sub_Status__c','Writ Filed');
        AddNewJudgmentController.validationRule(prod.Id, judg.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg5.Id,judgMap);
        
        judg5.Product_1__c = '101-0011-111323';
        judg5.Interest_Rate_one__c = NULL;
        judg5.Suit_Amount_1__c = NULL;
        update judg5; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg5.Id,judgMap);
        
        judg5.Product_2__c = '101-0011-111393';
        judg5.Interest_Rate_two__c = NULL;
        update judg5; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg5.Id,judgMap);
        
        judg5.Product_3__c = '101-0011-118393';
        judg5.Interest_Rate_three__c = NULL;
        update judg5; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg5.Id,judgMap);
        
        judg5.Product_4__c = '101-0011-111383';
        judg5.Interest_Rate_four__c = NULL;
        update judg5; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg5.Id,judgMap);
    }
    static testMethod void testlinkRecords6(){
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        Map<String,String> judgMap = new Map<String,String>();
        
        Judgment_product_codes_mapping__c mapping = new Judgment_product_codes_mapping__c();
        mapping.name='A-0007';
        mapping.Judgment_Legal_Status__c='Post-Judgment';
        mapping.Judgment_Legal_Sub_Status__c = 'Writ & Garnishment';
        mapping.Codes__c='295020';
        mapping.Product_Parent__c ='Post-Judgment';
        insert mapping;
        system.debug('mapping**'+mapping);
        mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c,mapping);  
        
        Judgment__c judg6 = new Judgment__c();
        judg6.Legal_Agency__c = 'Test Agency';
        judg6.Legal_Status__c = 'Post-Judgment';
        judg6.Legal_Sub_Status__c = 'Writ & Garnishment';
        insert judg6;
        
        Judgment__c judg = [SELECT Id,Judgment_Province__c,Case_Number__c,Legal_Status__c,Legal_Sub_Status__c FROM Judgment__c LIMIT 1];
        Product__c prod = [SELECT Id FROM Product__c LIMIT 1];
        
        judgMap.put('judgment_Province__c','');
        judgMap.put('Case_Number__c','');
        judgMap.put('Legal_Status__c','Post-Judgment');
        judgMap.put('Legal_Sub_Status__c','Writ & Garnishment');
        AddNewJudgmentController.validationRule(prod.Id, judg.Id,judgMap);
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg6.Id,judgMap);
        
        judg6.Product_1__c = '101-0011-111323';
        judg6.Interest_Rate_one__c = NULL;
        judg6.Suit_Amount_1__c = NULL;
        update judg6; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg6.Id,judgMap);
        
        judg6.Product_2__c = '101-0011-111393';
        judg6.Interest_Rate_two__c = NULL;
        update judg6; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg6.Id,judgMap);
        
        judg6.Product_3__c = '101-0011-118393';
        judg6.Interest_Rate_three__c = NULL;
        update judg6; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg6.Id,judgMap);
        
        judg6.Product_4__c = '101-0011-111383';
        judg6.Interest_Rate_four__c = NULL;
        update judg6; 
        AddNewJudgmentController.validationRuleForExistingRecord(prod.Id, judg6.Id,judgMap);
    }
}