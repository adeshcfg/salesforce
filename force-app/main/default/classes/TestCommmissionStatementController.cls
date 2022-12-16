/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of CommmissionStatementController
 *  @author : A5E Consulting
 *  @date : 17/06/2022
 * 
 *************************************************************************************************/
@isTest
public class TestCommmissionStatementController {
        
        static testMethod void testMethod1() 
    {
        String recordTypeID1 = Schema.SObjectType.Product_Payments__c.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId();
        Application_Config_Settings__c config = new Application_Config_Settings__c();
        config.Product_Payment_Record_Type__c = recordTypeID1;
        insert config;
        
        //List<Placement__c> lstPlacement= new List<Placement__c>();        
        Placement__c place = new Placement__c();
        place.Name = '29';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.';
        insert place;
        
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 29;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;
        String mMonth;
        String mYear;
        String mDay;
        if(Integer.valueOf(System.Today().month()) - 1 == 0) {
            mMonth = '12';
             mYear = String.valueOf(Integer.valueOf(System.Today().year()) - 1);
            mDay= String.valueOf(Integer.valueOf(System.Today().day()));
         } else {
            mMonth= String.valueOf(Integer.valueOf(System.Today().month()) - 1);
             mYear = String.valueOf(Integer.valueOf(System.Today().year()));
             mDay= String.valueOf(Integer.valueOf(System.Today().day()));
         } 
        
        Product_Payments__c prodpay= new  Product_Payments__c();
        prodpay.CCS_Account__c=prod2.id;
        prodpay.Payment_Source__c = '2';
        prodpay.Payment_Type__c ='1003';
        prodpay.Payment_Amount__c=1002;
        prodpay.Agency_Calculated_Comm__c=10;
        prodpay.Payment_Posting_Date__c= System.today();
        prodpay.Payment_Provided_Agency__c=place.id;
        prodpay.Pay_Due__c = 200;
        prodpay.Tax_amount__c= 100;
        prodpay.Payment_Created__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        //prodpay.RecordType.name = 'Distressed_Product_Payment';
        prodpay.RecordTypeId = Schema.SObjectType.Product_Payments__C.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId();
       // ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay;
        system.debug('prodpay'+prodpay.recordType.name);
        
        Product_Payments__c prodpay1= new  Product_Payments__c();
        prodpay1.CCS_Account__c=prod2.id;
        prodpay1.Payment_Source__c = '1';
        prodpay1.Payment_Type__c ='1003';
        prodpay1.Payment_Amount__c=1002;
        prodpay1.Agency_Calculated_Comm__c=10;
        prodpay1.Payment_Posting_Date__c= System.today();
        prodpay1.Payment_Provided_Agency__c=place.id;
        prodpay1.Pay_Due__c = 200;
        prodpay1.Tax_amount__c= 100;
        prodpay1.Payment_Created__c = date.newInstance(Integer.valueOf(mYear),Integer.valueOf(mMonth),Integer.valueOf(mDay));
        prodpay1.RecordTypeId = Schema.SObjectType.Product_Payments__C.getRecordTypeInfosByName().get('Distressed Product Payment').getRecordTypeId();
         //prodpay1.RecordType.name = 'Distressed_Product_Payment';
       // ProductPaymentsTriggerHandler.runProductTrigger = false;
        insert prodpay1;
        
        //CommissionStatementController.Summary wrap = new CommissionStatementController.Summary();
        //wrap.Summary(prodpay);
        ApexPages.currentPage().getParameters().put('id', place.Id);
        //ApexPages.StandardSetController sc = new ApexPages.StandardSetController(prodpay);
        CommissionStatementController send = new CommissionStatementController();
    }
}