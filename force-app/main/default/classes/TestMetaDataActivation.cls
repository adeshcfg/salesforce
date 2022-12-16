@isTest(SeeAllData=true)
public class TestMetaDataActivation {
    public static testMethod void testschedule() {
        Metadata_Object__c metaData = new Metadata_Object__c();
        metaData.Object_Name__c = 'Product';
        metaData.Metadata_Type__c = 'ValidationRule';
        metaData.Metadata_Rule_Name__c = 'Product__c.Putback_Reason';
        insert metaData;
        
        Metadata_Object__c metaData1 = new Metadata_Object__c();
        metaData1.Object_Name__c = 'Product';
        metaData1.Metadata_Type__c = 'WorkflowRule';
        metaData1.Metadata_Rule_Name__c = 'Product__c.Collection DD22 NOPTP';
        insert metaData1;
        MetaDataActivation cb = New MetaDataActivation();
        cb.execute(null);
    }
}