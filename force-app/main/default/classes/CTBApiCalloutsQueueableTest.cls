@isTest
public class CTBApiCalloutsQueueableTest {

    @isTest
    static void testQueueable() {
         Test.setMock(HttpCalloutMock.class, new CTBApiCalloutsQueueableMock());

        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://login.microsoftonline.com/{{tenandId}}/oauth2/v2.0/token';
        settings.Tenand_ID__c = '0f455e83-d015-4300-80c3-3b73c4ce1d10';
        settings.Proxy_Client_ID__c = '8c862ddf-0df2-4322-8490-e858d46f18ce';
        settings.Client_ID__c = '3b3cd051-5cc0-469f-98e0-601d5d9577f4';
        settings.Client_Secret__c = 'lxW8Q~YfJqn5yr8bRlTlH.hI6BAfAb_x-VIzDcNd';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'https://canaccedeb2cdevelopment.onmicrosoft.com/';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
        // Prepare test data (replace with your actual test data)
        ContentVersion CV = new Contentversion();
        CV.title = 'DEF';
        CV.PathOnClient = 'test';
        CV.versiondata = EncodingUtil.base64Decode('This is version data');
        insert CV;
        
        ContentVersion contentVersionData = new ContentVersion();
        contentVersionData.ContentLocation = 'S';
        contentVersionData.VersionData = Blob.valueof('H,0,999,7,11/27/2023,01:17:36,T,DRN00001');
        contentVersionData.Title = 'DRN_DailyUpdate_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss');
        contentVersionData.PathOnClient = 'DRN_DailyUpdate.csv';
        insert contentVersionData;
        
        Id contentVersionId = contentVersionData.id;// 'your_content_version_id'
        
        List<insolvency_account__c> insolvencyAccounts = new List<insolvency_account__c>();
        // Add insolvency account records to the list
        
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.name = 'test';
        insolv1.Insolvency_Status__c = 'Refused';
        insert insolv1;
        
        Id scotiabank = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Canadian_Tire_Insolvency_Account').getRecordTypeId();
        Insolvency_Account__c insolAcct1 = new Insolvency_Account__c();
        insolAcct1.name = 'Test222';
        insolAcct1.Insolvency_Status__c = 'New';
        insolAcct1.Insolvency__c = insolv1.id;
        insolAcct1.Account_Type__c = 'Credit Card';
        insolAcct1.Borrower_Primary__c = 'Kajal';
        insolAcct1.Type_of_Service__c = 'Service Only';
        insolAcct1.Claim_Type__c = 'Secured';
        insolAcct1.Is_Duplicate_Resolved__c = false;
        insolAcct1.RecordTypeId = scotiabank;
        insolAcct1.Client_Identifier__c = 'Scotia Bank';
        insert insolAcct1;
        insolvencyAccounts.add(insolAcct1);
        
        

        // Create an instance of the CTBApiCalloutsQueueable
        CTBApiCalloutsQueueable queueable = new CTBApiCalloutsQueueable(
            contentVersionId,
            insolvencyAccounts,
            System.Label.CTB_Insolvency_Account, //'YourBatchName',
            'DRN_DailyUpdate_'
        );

        // Enqueue the job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Add assertions as needed to verify the behavior of your Queueable job
        // For example, check if the status of the insolvency accounts is updated as expected
        List<insolvency_account__c> updatedInsolvencyAccounts = [SELECT Id, Insolvency_Sub_Status__c FROM insolvency_account__c WHERE Id IN :insolvencyAccounts];
        //System.assertEquals('Sent on File', updatedInsolvencyAccounts[0].Insolvency_Sub_Status__c, 'Insolvency Sub Status should be updated');
    }
}