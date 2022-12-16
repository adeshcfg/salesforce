/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of PTPMetBatch
*  @author : A5E Consulting
*  @date : 11/08/2017
*
*************************************************************************************************/

@isTest
private class TestPTPMetBatch{
    
    static testMethod void PTPTestMethod(){
        
        Id recordTypeId = Utilities.getProductRecordType('Megasys');
        
        List<Product__c> prodList = new List<Product__c>();
        Product__c prod = new Product__c();        
        prod.name = 'Prod1';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Delinquency_Days__c = 30.00;
        prod.Last_Payment_Date__c = System.Today().addDays(-10);
        prod.Last_Payment_Amount__c = 500.00;
        prod.Closed_Date__c = null;
        prod.Payment_Due_Date__c = System.Today().addDays(-10);
        prod.Internal_Status__c = 'Active';
        prodList.add(prod);
        
        prod = new Product__c();        
        prod.name = 'Prod2';
        prod.recordTypeId = recordTypeId;
        prod.Phone_Home__c = '12345678999';
        prod.Delinquency_Days__c = 30.00;
        prod.Last_Payment_Date__c = System.Today().addDays(-10);
        prod.Last_Payment_Amount__c = 500.00;
        prod.Closed_Date__c = null;
        prod.Payment_Due_Date__c = System.Today().addDays(-10);
        prod.Internal_Status__c = 'Active';
        prodList.add(prod);
        
        insert prodList;
        
        PTP_Information__c ptpInfo = new PTP_Information__c();
        ptpInfo.PTP_Date__c = System.Today().addDays(10);
        ptpInfo.PTP_Amount__c = 300.00;
        ptpInfo.Product__C = prodList[0].id;
        insert ptpInfo;
        
        PTP_Information__c ptpInfo1 = new PTP_Information__c();
        ptpInfo1.PTP_Date__c = System.Today().addDays(10);
        ptpInfo1.PTP_Amount__c = 300.00;
        ptpInfo1.Product__C = prodList[1].id;
        insert ptpInfo1;
        
        PTP_Information__c ptpInfo2 = new PTP_Information__c();
        ptpInfo2.PTP_Date__c = System.Today().addDays(-20);
        ptpInfo2.PTP_Amount__c = 300.00;
        ptpInfo2.Product__C = prodList[0].id;
        insert ptpInfo2;
        
        
        Database.executeBatch(New PTPMetBatch(), 40);
        
    }
}