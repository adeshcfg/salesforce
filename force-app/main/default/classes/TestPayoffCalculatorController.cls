/**************************************************************************************************
 *
 *  Class:    TestInsolvencyAccntToCreditorAccntCntrl
 *
 *  @description : Test payoff calculator controller
 *  @author : A5E Consulting
 *  @date : 17/Feb/2021
 *
 *************************************************************************************************/
@isTest(seeAllData =  false)
public class TestPayoffCalculatorController {
    
    @IsTest
    static void testMothod1(){
        
        Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Product_Coll_Sub_Status_Validation__c = true);
        insert config;
        
        Account customer1 = new Account(FirstName = 'FirstName', LastName = 'Last Name', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId());
        insert customer1;
        
        Judgment__c judgment1 = new Judgment__c();
        judgment1.Judgment_Date__c = system.today().addDays(-50);
        judgment1.Judgment_Amount__c = 6500;
        judgment1.Legal_Agency__c = '29';
        insert judgment1;
                 
        Product__c prod = new Product__c(First_Name__c = 'ProdFirstName', Last_Name__c = 'ProdLastName',Status__c = 'New Allocation - New Allocation',Sub_Status__c = 'Ready',Product_Status__c = 'Test', Customer__c = customer1.Id, Source_System__c ='DebtNext', RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId());
        insert prod;
        
        Account_Judgment__c accJudg = new Account_Judgment__c(Product__c = prod.Id, Judgment__c = judgment1.Id, Status__c = 'Active');
		insert accJudg;
        
        prod.Current_Balance__c = 5000;
        prod.Last_Payment_Date__c = system.today().addDays(-40);
        prod.Interest_Rate__c = 12.99;
        prod.Previous_Primary_Account_Number__c = 'TestPrimaryAccount';
        
        update prod;
               
        Product__c prod2 = new Product__c(First_Name__c = 'ProdFirstName', Last_Name__c = 'ProdLastName',Status__c = 'New Allocation - New Allocation',Sub_Status__c = 'Ready',Product_Status__c = 'Test', Customer__c = customer1.Id, Source_System__c ='DebtNext', RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId());
        insert prod2;        
        
        prod2.Current_Balance__c = 5000;
        prod2.Last_Payment_Date__c = system.today().addDays(-40);
        prod2.Interest_Rate__c = 12.99;
        prod2.Previous_Primary_Account_Number__c = 'TestPrimaryAccount';
        
        update prod2;
        
        PayoffCalculatorController.getproduct(prod.id);
        PayoffCalculatorController.getproduct(prod2.id);
        
    }
}