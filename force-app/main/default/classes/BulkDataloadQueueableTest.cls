/**
 * @description       : Test class for BulkDataloadQueueable
 * @author            : adeshi@a5econsulting.net
 * @group             :
 * @last modified on  : 03-27-2023
 * @last modified by  : adeshi@a5econsulting.net
 **/
@isTest
public class BulkDataloadQueueableTest {
    @testSetup
    static void setupData() {
        Work_Assignment__c wrkAss = new Work_Assignment__c();
        wrkAss.Assign_To__c = 'CFG';
        wrkAss.Status__c = 'Requested';
        wrkAss.Sub_Purpose__c = 'Product Allocation';
        wrkAss.Task_Number__c = 'TA-00007';
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
        insert wrkAss;
        WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;

        Product__c prod = new Product__c();
        prod.Collection_Sub_Status__c = '';
        prod.Originating_Creditor__c = 'MBNA';
        prod.Name = '1566P430';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.Purchase_Province__c = 'AB';
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;
        ProductTriggerHandler.runProductTrigger = true;

        Placement__c place = new Placement__c();
        place.Name = '68';
        place.Agency_Name__c = 'Canaccede International Management Ltd.';
        insert place;

        // Document Storage insertion
        List<Document_Storage__c> docSto = new List<Document_Storage__c>();
        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Allocation';
        docSto1.Work_Assignment__c = wrkAss.Id;
        docSto1.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto1.Document_Type__c = 'Product Allocation File';
        docSto1.Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade2';
        docSto1.File_Processing_Status__c = 'Pending';
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'CFG Only';
        docSto1.Document_Extension__c = 'csv';
        Document_Storage__c docSto2 = new Document_Storage__c();
        docSto2.Document_Related_To__c = 'Recall';
        docSto2.Work_Assignment__c = wrkAss.Id;
        docSto2.Work_Assignment_Identifier__c = wrkAss.Task_Number__c;
        docSto2.Document_Type__c = 'Account Status Update File';
        docSto2.Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade3';
        docSto2.File_Processing_Status__c = 'Pending';
        docSto2.Uploaded_By__c = 'Internal User';
        docSto2.Visibility__c = 'CFG Only';
        docSto2.Document_Extension__c = 'csv';
        docSto.add(docSto1);
        docSto.add(docSto2);
        insert docSto;

        Pool__c pool = new Pool__c();
        insert pool;
        String poolName = pool.Name;

        // Attachment insertion
        List<Attachment> attachmentToInsert = new List<Attachment>();
        Attachment attachAllocation = new Attachment();
        attachAllocation.parentid = docSto1.Id;
        attachAllocation.name = 'Allocation file.csv';
        String allocatedData = 'Data_Id__c,Placement_Agency__c,Pool_Name__c,Current_Commission_Rate__c,Placed_Commission_Rate__c,Current_Settlement_Rate__c,Placed_Settlement_Rate__c,Value_Tier_at_Time_of_Placement__c\n';
        allocatedData += '1566P430,68,' + poolName + ',67,67,99,99,D\n';
        allocatedData += '1566P431,68,' + poolName + ',67,67,99,99,C\n';
        attachAllocation.Body = Blob.valueOf(allocatedData);
        attachmentToInsert.add(attachAllocation);
        Attachment attachRecall = new Attachment();
        attachRecall.parentid = docSto2.Id;
        attachRecall.name = 'Allocation file.csv';
        String recallData = 'Name__c,placement_Status_Code__c,Status_Changed_Date__c\n';
        recallData += '1067P1126,800120,2/27/2023\n';
        recallData += '1000P001,800120,2/27/2023\n';
        attachRecall.body = Blob.valueof(recallData);
        attachmentToInsert.add(attachRecall);
        insert attachmentToInsert;

        // Create Content Version
        List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
        ContentVersion conver = new ContentVersion();
        conver.ContentLocation = 'S';
        conver.VersionData = Blob.valueof(allocatedData);
        conver.Title = 'Allocation';
        conver.PathOnClient = 'Allocation file.csv';
        contentVersionToInsert.add(conver);
        ContentVersion converRecall = new ContentVersion();
        converRecall.ContentLocation = 'S';
        converRecall.VersionData = Blob.valueof(recallData);
        converRecall.Title = 'Recall';
        converRecall.PathOnClient = 'Recall file.csv';
        contentVersionToInsert.add(converRecall);
        insert contentVersionToInsert;

        // ContentDocumentLink record Creation
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conver.Id].ContentDocumentId;
        Id conDocRecall = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :converRecall.Id].ContentDocumentId;
        List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = docSto1.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I';
        cDe.Visibility = 'InternalUsers';
        contentDocumentLinkToInsert.add(cDe);
        ContentDocumentLink cDeRecall = new ContentDocumentLink();
        cDeRecall.ContentDocumentId = conDocRecall;
        cDeRecall.LinkedEntityId = docSto2.id; // This will link inserted file to above inserted settlement record
        cDeRecall.ShareType = 'I';
        cDeRecall.Visibility = 'InternalUsers';
        contentDocumentLinkToInsert.add(cDeRecall);
        insert contentDocumentLinkToInsert;
    }

    @isTest
    static void testCSVParse() {
        Document_Storage__c documentStorage = [
            SELECT Id, Document_Type__c, Uploaded_By__c
            FROM Document_Storage__c
            WHERE Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade2'
        ];
        Test.startTest();
        System.enqueueJob(new BulkDataloadQueueable('PARSE_CSV', null, 0, documentStorage));
        Test.stopTest();
    }

    @isTest
    static void testAllocationInsertData() {
        Document_Storage__c documentStorage = [
            SELECT Id, Document_Type__c, Uploaded_By__c
            FROM Document_Storage__c
            WHERE Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade2'
        ];
        Pool__c pool = [SELECT Name FROM Pool__c LIMIT 1];
        List<String> csvStringList = new List<String>{ '1566P430,68,' + pool.Name + ',67,67,99,99,D', '1566P430,68,' + pool.Name + ',67,67,99,99,c' };
        Test.startTest();
        System.enqueueJob(new BulkDataloadQueueable('INSERT_DATA', csvStringList, 0, documentStorage));
        Test.stopTest();
        List<Product_Staging__c> prodStagingList = [SELECT Id FROM Product_Staging__c];
        System.assertEquals(2, prodStagingList.size(), 'Success');
    }

    @isTest
    static void testRecallInsertData() {
        Document_Storage__c documentStorage = [
            SELECT Id, Document_Type__c, Uploaded_By__c
            FROM Document_Storage__c
            WHERE Document_Id__c = 'a8f6022e-93a9-4b54-967f-e01cb140ade3'
        ];
        Pool__c pool = [SELECT Name FROM Pool__c LIMIT 1];
        List<String> csvStringList = new List<String>{ '1067P1126,800120,2/27/2023', '1067P001,800120,2/27/2023' };
        Test.startTest();
        System.enqueueJob(new BulkDataloadQueueable('INSERT_DATA', csvStringList, 0, documentStorage));
        Test.stopTest();
        List<Product_Staging__c> prodStagingList = [SELECT Id FROM Product_Staging__c];
        System.assertEquals(2, prodStagingList.size(), 'Success');
    }
}