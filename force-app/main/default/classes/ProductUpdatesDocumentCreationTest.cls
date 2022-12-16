@isTest
public class ProductUpdatesDocumentCreationTest {
   
    public static testMethod void testProductUpdates() {
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());
        String recordId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Work Assignment').getRecordTypeId();
        Agency_Portal_Settings__c portalSettings = new Agency_Portal_Settings__c();
        portalSettings.CFGWorkAssignmentRecordTypeId__c = recordId;
        insert portalSettings;
        
        Placement__c plcgy = new  Placement__c();      
        plcgy.Name='12233';
        insert plcgy;
        
        Product__c prod = new Product__c();
        prod.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        prod.Name = '1566P000';
        prod.Commission_Rate__c=13;
        prod.Collection_Agency__c = 12233;
        prod.Collection_Agency_Placement__c = plcgy.Id;
        prod.Value_Tier_at_Time_of_Placement__c = 'A';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        insert prod;
        
        Product__History prodHistory2 = new Product__History();
        prodHistory2.Field = 'Collection_Agency__c';
        prodHistory2.ParentId = prod.Id;
        insert prodHistory2;
        
        Product__History prodHistory3 = new Product__History();
        prodHistory3.Field = 'Collection_Agency_Placement__c';
        prodHistory3.ParentId = prod.Id;
        insert prodHistory3;
        
        Product__History prodHistory4 = new Product__History();
        prodHistory4.Field = 'Status__c';
        prodHistory4.ParentId = prod.Id;
        insert prodHistory4;
        
        prod.Codebtor_Address_Line1__c='SHN';
        update prod;
        
    	Test.startTest();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second()+3);
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        ProductUpdatesDocumentCreation s = new ProductUpdatesDocumentCreation(); 
        System.schedule('Account Update Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        Test.stopTest();
    }
}