/**************************************************************************************************
 *
 *  Class:   TestTrusteeAssignmentController
 *
 *  @description : This class contains unit tests for trustee assignment of an Insolvency
 *  @author : A5E Consulting
 *  @date : 05/01/2018
 * 
 *************************************************************************************************/

@isTest(seeAllData = false)
public class TestTrusteeAssignmentController{
    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         Account parentAcc = new Account(Name = 'my acc');
         insert parentAcc;
         Id trusteeOfficeRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Trustee Office' LIMIT 1].Id;
         
         List<Account> accList = new List<Account>();
         for( Integer  i=0; i<=3; i++){
         Account acc = new Account(RecordTypeId = trusteeOfficeRecordTypeId , Name = 'my acc', ParentId = parentAcc.Id, Fax = '123-123-1234', BillingCity ='city', Phone ='123-123-1234', BillingStreet = 'street 123', Business_Email__c ='test@a5e.com');
         accList.add(acc);
         }
         Account acc = new Account(RecordTypeId = trusteeOfficeRecordTypeId , Name = 'my acc', ParentId = parentAcc.Id, Fax = '123-123-1234', BillingCity ='city', Phone ='123-123-1234', BillingStreet = 'street 123', Business_Email__c ='test@a5e.com');
         accList.add(acc);
         insert accList;
         
          // insert insolvency account
         Insolvency_Account__c insolvAacc = new Insolvency_Account__c();
         insert insolvAacc ;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(name = 'test-trAssg001', Trustee__c = acc.Id);
         insert insolv; 
     }
      // Testing trustee assignment
     static testMethod void sendAssignTrustee(){
         Insolvency__c insolv = [SELECT Id, Trustee__c FROM Insolvency__c LIMIT 1];
         TrusteeAssignmentController obj = new TrusteeAssignmentController(new ApexPages.StandardController(insolv));
         obj.companyName = 'my acc';
         obj.officeName = 'my acc';
         obj.phoneNumber = '123-123-1234';
         obj.streetAddress = 'street 123';
         obj.businessEmail =  'test@a5e.com';
         obj.limitSize = 1;
         obj.fax = '123-123-1234';
         obj.activeTrusteesOnly = True;
         obj.searchTrustee();
         obj.beginning();
         obj.next();
         obj.previous();
         obj.last();
         obj.getDisableNext();
         obj.getDisablePrevious();
         obj.updateInsolvency();
         ApexPages.currentPage().getParameters().put('accid', insolv.Trustee__c);
         obj.accountSelected();
         obj.gettotalSize();
         obj.getcounter();
         
         obj.getlimitSize();
         
         
     }
}