/**************************************************************************************************
*
*  Class:   
*
*  @description : TestComplaintWorkAssignmentWidget
*  @author : A5E Consulting
*  @date : 29/06/2022  

*************************************************************************************************/
@isTest
public class TestComplaintWorkAssignmentWidget {
    public static testMethod void testComplaintWorkAssignmentWidgetController(){
        test.startTest();
        
        Product__c prod = new Product__c();
        string recrdid= [SELECT id from RecordType where sobjecttype='product__c' 
                         AND RecordType.Name='Distressed Account'].id;
        prod.RecordTypeId=recrdid;
        prod.Name = '1566P000';
        prod.First_Name__c = 'Test Data';
        prod.Co_Borrower_First_Name__c = 'Test Data';
        prod.Last_Name__c = 'Test Data';
        prod.Co_Borrower_Last_Name__c = 'Test Data';
        prod.Current_Principal_Balance__c = 100;
        prod.Commission_Rate__c=13;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        Account acc = new Account();
        acc.Name = 'Anea';
        acc.Previous_First_Name__c = 'Anea';
        acc.Previous_Last_Name__c = 'Test Data';
        acc.Previous_Email_Address__c = 'Test@gmail.com';
        acc.Previous_MailingCity__c = 'Canada';
        acc.Number_Of_Open_Complaint__c = 5;
        CustomerTriggerHandler.runCustomerTrigger = False;
        insert acc;
        CustomerTriggerHandler.runCustomerTrigger = True;
        
        Work_Assignment__c workAssign = new Work_Assignment__c();
        workAssign.Description__c = 'Test';
        workAssign.Account_Being_CB_Reported_By_Agency__c = 'Yes';
        workAssign.Agency_Currently_Has_Account_On_Hold__c = 'Yes';
        workAssign.Is_The_Complaint_Valid__c  = 'Yes';
        workAssign.Have_You_Provided_Supporting_Media__c = 'Yes';
        workAssign.Product__c = prod.id;
        insert workAssign;
        
        
        ComplaintWorkAssignmentWidgetController.getproduct(workAssign.id);
        ComplaintWorkAssignmentWidgetController.getcustomer(workAssign.id);
        test.stopTest();
    }
    
}