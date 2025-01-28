@isTest
public class MMFileProcessingTest {
    @TestSetup
    static void makeData() {
        API_Call_Details__c settings = new API_Call_Details__c();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/api/accessToken';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/api/getFileList';
        settings.Scope_Prefix__c = 'scope.com';
        settings.Scope_Suffix__c = '/.default';
        settings.API_Request_Timeout__c = 90000;
        insert settings;

        String csvString = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","DDEC","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","SOLD","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","",""\n"T","2","999","5","3","08/15/2008","12:32:06"';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;

        String csvStringNoMatch = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000003","","","9/15/2023","50","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","9/19/2023",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000002","","NMAT","9/15/2023","50","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","9/19/2023",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000002","","","9/15/2023","50","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","9/19/2023",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","","9/15/2023","50","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","9/19/2023",""\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","NMAT","9/15/2023","50","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","9/19/2023",""\n"D","2","999","9/19/2023","testMM123","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","","","","","1500","","","","","","","","","","","","","","50","","","Test, Adesh123","","",""\n"D","2","999","9/19/2023","testMMCreditor","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","","","","9/15/2023","1500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","",""\n"T","2","999","9","7","08/15/2008","12:32:06"';
        Document documentObjNoMatch = new Document();
        documentObjNoMatch.Body = Blob.valueOf(csvStringNoMatch);
        documentObjNoMatch.ContentType = 'text/csv';
        documentObjNoMatch.DeveloperName = 'my_document_no_match';
        documentObjNoMatch.IsPublic = true;
        documentObjNoMatch.Name = 'my_document_no_match';
        documentObjNoMatch.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;

        String csvString1 = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001","D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","","9/19/2023"\n"T","2","999","3","1","08/15/2008","12:32:06"';
        Document documentObjNoOfRows = new Document();
        documentObjNoOfRows.Body = Blob.valueOf(csvString1);
        documentObjNoOfRows.ContentType = 'text/csv';
        documentObjNoOfRows.DeveloperName = 'my_document_noofrows';
        documentObjNoOfRows.IsPublic = true;
        documentObjNoOfRows.Name = 'my_document_noofrows';
        documentObjNoOfRows.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;

        String csvString2 = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Money Mart Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","000000000000001","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123","","Fail","",""\n"T","2","999","3","1","08/15/2008","12:32:06"';
        Document documentObjNoOfCols = new Document();
        documentObjNoOfCols.Body = Blob.valueOf(csvString2);
        documentObjNoOfCols.ContentType = 'text/csv';
        documentObjNoOfCols.DeveloperName = 'my_document_noofcols';
        documentObjNoOfCols.IsPublic = true;
        documentObjNoOfCols.Name = 'my_document_noofcols';
        documentObjNoOfCols.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert new List<Document>{ documentObj, documentObjNoOfRows, documentObjNoOfCols, documentObjNoMatch };

        Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
        config.Run_Insolvency_Account_Trigger__c = true;
        config.Run_Insolvency_Status_Validations__c = true;
        config.Eligible_for_Validn_Needed_Calculation__c = 'Money Mart';
        config.Eligible_for_Claim_Type_Calculation__c = 'Money Mart';
        config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
        config.Bank_Eligible_for_Duplicate_Check__c = 'Money Mart';
        config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
        config.Run_Insolvency_Trigger__c = false;
        config.Run_Insolvency_Account_Duplicate_Check__c = true;
        config.Eligible_for_Voting_Decision__c = 'Money Mart';
        insert config;

        Insolvency__c insolv = new Insolvency__c();
        insolv.Name = '21-2986827';
        insolv.Client_Identifiers__c = 'New';
        insolv.Insolvency_Type__c = 'Bankruptcy';
        insolv.Debtor_1_First_Name__c = 'Test';
        insolv.Debtor_1_Last_Name__c = 'Debtor';
        insolv.Debtor_2_First_Name__c = 'Co';
        insolv.Debtor_2_Last_Name__c = 'Debtor';
        insert insolv;

        Creditor_Account__c creditorAccount = new Creditor_Account__c();
        creditorAccount.Name = 'testMMCreditor';
        creditorAccount.Insolvency__c = insolv.Id;
        creditorAccount.External_Correlation_ID__c = '';
        insert creditorAccount;

        //Portfolio record
        Portfolio_Name__c portfolioName = new Portfolio_Name__c();
        portfolioName.name = 'AFSCARD';
        portfolioName.Account_Purchasing_Entity_ID__c = ' 13';
        insert portfolioName;

        //Insolvency Account records
        Insolvency_Account__c ia1 = new Insolvency_Account__c();
        ia1.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByDeveloperName().get('Money_Mart_Insolvency_Account').getRecordTypeId();
        ia1.Name = '001278905436';
        ia1.Co_Debtor__c = 'Test Co Debtor';
        ia1.Insolvency_Status__c = 'For Owner Review';
        ia1.Claim_Type__c = 'Unsecured';
        ia1.Claim_Amount__c = 1000;
        ia1.Insolvency__c = insolv.Id;
        ia1.Portfolio_Group_Name__c = 'CCL001';
        ia1.Investment_Group__c = 'AFFIRM';
        ia1.Portfolio_Name_Lookup__c = portfolioName.id;
        ia1.Asset_Status__c = 'Purchased';
        ia1.Distressed_Data_Id__c = '848085644';
        ia1.Sent_For_Owner_Review_Date_Original__c = date.today();
        ia1.Trustee_Not_Providing_LoR__c = false;
        ia1.Distressed_Data_Id__c = '1';
        ia1.Claim_Filed_Date__c = System.now();
        ia1.Correlation_Id__c = '000000000000001';
        Insolvency_Account__c ia2 = ia1.clone();
        ia2.Name = '001278905454';
        ia2.Correlation_Id__c = '000000000000002';
        Insolvency_Account__c ia3 = ia1.clone();
        ia3.Name = '0012789054678';
        ia3.Insolvency_Status__c = 'New';
        ia3.Correlation_Id__c = '000000000000003';
        List<Insolvency_Account__c> iaListNew = new List<Insolvency_Account__c>{ ia1, ia2, ia3 };
        insert iaListNew;
    }

    @isTest
    static void processFileTest() {
        Document doc = [SELECT Id, Name FROM Document WHERE DeveloperName = 'my_document' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(doc.Id));
        Test.startTest();
        MMFileProcessingScheduler scheduler = new MMFileProcessingScheduler();
        scheduler.execute(null);
        System.enqueueJob(new MMFileProcessingQueueable(new List<String>{ doc.Name }, System.Label.CTB_Insolvency_Account));
        Test.stopTest();
    }

    @isTest
    static void processFileTestNoMatch() {
        Document doc = [SELECT Id, Name FROM Document WHERE DeveloperName = 'my_document_no_match' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(doc.Id));
        Test.startTest();
        MMFileProcessingScheduler scheduler = new MMFileProcessingScheduler();
        scheduler.execute(null);
        System.enqueueJob(new MMFileProcessingQueueable(new List<String>{ doc.Name }, System.Label.CTB_Insolvency_Account));
        Test.stopTest();
    }

    @isTest
    static void processFileNegativeRows() {
        Document doc = [SELECT Id, Name FROM Document WHERE DeveloperName = 'my_document_noofrows' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(doc.Id));
        Test.startTest();
        System.enqueueJob(new MMFileProcessingQueueable(new List<String>{ doc.Name }, System.Label.CTB_Insolvency_Account));
        Test.stopTest();
    }

    @isTest
    static void processFileNegativeCols() {
        Document doc = [SELECT Id, Name FROM Document WHERE DeveloperName = 'my_document_noofcols' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SftpApiCalloutMock(doc.Id));
        Test.startTest();
        System.enqueueJob(new MMFileProcessingQueueable(new List<String>{ doc.Name }, System.Label.CTB_Insolvency_Account));
        Test.stopTest();
    }
}
