/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of ProductPotentialMatchController
 *  @author : A5E Consulting
 *  @date : 02/27/2018
 *
 *************************************************************************************************/
@isTest
public class TestProductPotentialMatchController{
	
    public static testMethod void testControllerMethod(){
    	
        //Create Account
        TestRecordsFactory.TestAccountWrapper accntWrapper1 = new TestRecordsFactory.TestAccountWrapper();
        accntWrapper1.firstName = 'firstName';
        accntWrapper1.lastName = 'lastName';
        accntWrapper1.email = 'testuser@testOrg.com';
        accntWrapper1.sin = '12345678';
		Account AccData = TestRecordsFactory.createAccountRecordAndInsert(accntWrapper1, true);
        list<Account> accList = new list<Account>();
        accList.add(AccData);
        
        //Create Product
        Product__c prodData = new Product__c();
        list<Product__c> prodList = new list<Product__c>();
        prodData.Customer__c = AccData.Id;
        prodData.First_Name__c = 'firstName';
        prodData.Last_Name__c = 'lastName';
        prodData.SIN__c = '12345678';
        prodData.Name = 'Test123';
        prodData.Needs_Manual_Review__c = true;
        insert prodData;        
        
        //Controller Constructor
        ApexPages.currentPage().getParameters().put('id', prodData.Id);  
        ProductPotentialMatchController ppmc = new ProductPotentialMatchController(new ApexPages.StandardController(prodData));
        
        List<ProductPotentialMatchController.PotentialMatchProductAccountWrapper> existingWrapAccounts = new List<ProductPotentialMatchController.PotentialMatchProductAccountWrapper>();
        //existingWrapAccounts = ppmc.existingWrappedAccounts;
        ProductPotentialMatchController.PotentialMatchProductAccountWrapper wrapperObj = new ProductPotentialMatchController.PotentialMatchProductAccountWrapper(AccData);
      	wrapperObj.selected = true;
      	existingWrapAccounts.add(wrapperObj);
                
        //Test COntroller methods
        ppmc.assignSelected();
        ppmc.createNewNAssign();
        ppmc.keepSameCustomer();
        
        //Test Utility methods
        ProductPotentialMatchController.formatDate(system.today());
        ProductPotentialMatchController.getProductByID(prodData.Id);
        
    }
}