@isTest
public class TestBulkUpdateTaskMediaController {
    @testSetup
    static void testData(){
        Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
        portalSettings.Work_Assignment_Status__c = 'Requested,In Progress';
        portalSettings.Agency_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.CFG_Complaint_Status__c = 'Request to Reopen,Reopened';
        portalSettings.Media_Status__c = 'Requested,In Progress';
        portalSettings.Excel_File_Processing_Status__c = 'Requested,In Progress,Completed';
        insert portalSettings;
    }
    
    public static testMethod void testBulkUpdateTaskAndMediaController(){
        Map<String,Id> rectordTypeCheck = new Map<String,Id>();
        List<Work_Assignment__c> selectedCases = new List<Work_Assignment__c>();
        list<Work_Assignment__c> listWrkAss = new list<Work_Assignment__c>();
        List<Work_Assignment__c> listMedia = new List<Work_Assignment__c>();
        List<Work_Assignment__c> listExcel = new List<Work_Assignment__c>();
        List<Work_Assignment__c> listCFG = new List<Work_Assignment__c>();
        
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Work_Assignment__c'];
        for(RecordType recordType : recordTypes){
            rectordTypeCheck.put(recordType.DeveloperName, recordType.Id);
        }
       
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Status__c = 'Reopened';
        wrkAss.RecordTypeId = Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Complaint').getRecordTypeId();
        listWrkAss.add(wrkAss);
        
       	Work_Assignment__c wrkAss1 = new Work_Assignment__c();
        wrkAss1.Status__c = 'Request to Reopen';
        wrkAss1.RecordTypeId=Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('Agency Complaint').getRecordTypeId();
        selectedCases.add(wrkAss1);
        
        Work_Assignment__c wrkAss2 = new Work_Assignment__c();
        wrkAss2.Status__c = 'Request to Reopen';
        wrkAss2.RecordTypeId=Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Media').getRecordTypeId();
        listMedia.add(wrkAss2);
		
		Work_Assignment__c wrkAss3 = new Work_Assignment__c();
        wrkAss3.Status__c = 'Request to Reopen';
        wrkAss3.RecordTypeId=Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('CFG Excel Processing').getRecordTypeId();
        listExcel.add(wrkAss3);
        
        Work_Assignment__c wrkAss4 = new Work_Assignment__c();
        wrkAss4.Status__c = 'Request to Reopen';
        wrkAss4.RecordTypeId=Schema.SObjectType.Work_Assignment__c.getRecordTypeInfosByName().get('Agency Work Assignment').getRecordTypeId();
        listCFG.add(wrkAss4);
        
        Test.startTest();
        Test.setCurrentPage(Page.BulkUpdateTaskAndMedia);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listWrkAss);
        stdSetController.setSelected(listWrkAss);
        BulkUpdateTaskAndMediaController ext = new BulkUpdateTaskAndMediaController(stdSetController);
        
        ApexPages.StandardSetController stdSetController1 = new ApexPages.StandardSetController(selectedCases);
        stdSetController1.setSelected(selectedCases);
        BulkUpdateTaskAndMediaController ext1 = new BulkUpdateTaskAndMediaController(stdSetController1);
        
        ApexPages.StandardSetController stdSetController2 = new ApexPages.StandardSetController(listMedia);
        stdSetController2.setSelected(listMedia);
        BulkUpdateTaskAndMediaController ext2 = new BulkUpdateTaskAndMediaController(stdSetController2);
        
        ApexPages.StandardSetController stdSetController3 = new ApexPages.StandardSetController(listExcel);
        stdSetController3.setSelected(listExcel);
        BulkUpdateTaskAndMediaController ext3 = new BulkUpdateTaskAndMediaController(stdSetController3);
        
        ApexPages.StandardSetController stdSetController4 = new ApexPages.StandardSetController(listCFG);
        stdSetController4.setSelected(listCFG);
        BulkUpdateTaskAndMediaController ext4 = new BulkUpdateTaskAndMediaController(stdSetController4);
        
        ext.bulkUpdatemethod();
        ext1.bulkUpdatemethod();
        ext2.bulkUpdatemethod();
        ext3.bulkUpdatemethod();
        ext4.bulkUpdatemethod();
        ext.updateCases();
        ext.Redirect();
        Test.stopTest();
        
    }
}