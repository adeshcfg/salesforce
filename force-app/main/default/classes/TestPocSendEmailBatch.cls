/**
 * @description       : Test class for PocSendEmailBatch
 * @author            : nagendra.yanadigalla@canaccede.com
 * @created on        : 09-12-2024
 * @last modified on  : 10-09-2024
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest(seeAllData=false)
public class TestPocSendEmailBatch {
    @testSetup
    static void testData() {
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
        System.runAs(u) {
            EmailTemplate defaultTemplate = new EmailTemplate(
                Name = 'Creditor Package Request',
                TemplateType = 'custom',
                DeveloperName = 'Insolvency_Template2',
                HtmlValue = '{!TODAY()}',
                Body = '{!TODAY()}',
                Subject = '{!Insolvency_Account__c.Secured_Name__c}',
                FolderId = UserInfo.getUserId()
            );
            insert defaultTemplate;

            PoC_Package_Settings__c poc = new PoC_Package_Settings__c(
                Name = 'Scotia Bank',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc;
            PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c(
                Name = 'Canaccede',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc1;
            PoC_Package_Settings__c ctb = new PoC_Package_Settings__c(
                Name = 'Canadian Tire',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert ctb;
        }
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(
            Run_Insolvency_Status_Validations__c = true,
            Maximum_Email_Attachments_Size__c = 18874368,
            Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB',
            Run_Insolvency_Account_Trigger__c = true,
            Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
            Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
            Bank_Eligible_for_Duplicate_Check__c = 'SPL',
            Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
            Run_Insolvency_Trigger__c = false,
            Run_Insolvency_Account_Duplicate_Check__c = true,
            Eligible_for_Voting_Decision__c = 'Scotia Bank,SDA,SPL,Canaccede,Fidem,Fairstone'
        );
        insert appConfig;

        Account acct = new Account();
        acct.Name = 'Test Account';
        //acct.Communication_Preference__c = 'Fax';
        acct.fax = '651426256';
        acct.Follow_up_Email__c = 'test283@yopmail.com';
        acct.Business_Email__c = 'test11283@yopmail.com';
        acct.Preferred_Language__c = 'French';
        insert acct;

        //Insolvency Record Insertion
        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;

        String csvString = '"H","2","999","0000001","08/15/2008","12:32:06","P","DRN00001"\n"D","2","999","9/19/2023","41414","Consumer Proposal","Canadian Tire Credit Card","HILDA, test","ZIRK, test","1108-1660 Henderson Hwy, Test","","Winnipeg","MB","CA","R2G 1H7","","11/12/1977","9/15/2023","21-2986827","1","L.C. Taylor & Co. Ltd.","386 Broadway Suite 605","","Winnipeg","MB","R3C3R6","0000000008PCOM","","","9/15/2023","500","9/15/2023","10","9/15/2023","11","9/16/2023","12","9/16/2023","13","9/17/2023","14","9/18/2023","15","9/19/2023","50","","","Test, Adesh123"\n"T","2","999","3","1","08/15/2008","12:32:06"';
        Document documentObj = new Document();
        documentObj.Body = Blob.valueOf(csvString);
        documentObj.ContentType = 'text/csv';
        documentObj.DeveloperName = 'my_document';
        documentObj.IsPublic = true;
        documentObj.Name = 'My Document';
        documentObj.FolderId = [SELECT Id FROM folder WHERE DeveloperName = 'Metadata_Content'].Id;
        insert documentObj;

        TestDocumentAPIClient.testDocumentAPI();
        //Insolvency Account Record Insertion
        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'PoC Details Provided';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = '{!Insolvency_Account__c.Insolvency_Type__c}'; // 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;

        Attachment att = new Attachment(
            Name = 'testAtt',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            Description = 'PoC Document',
            parentId = acc.Id
        );
        insert att;
        
        ContentVersion conVer = new ContentVersion(Title='TestConVer',PathOnClient='path',VersionData = EncodingUtil.base64Decode('String'));
        insert conVer;
        
        conVer = [Select id, ContentDocumentId from ContentVersion where id =: conVer.Id];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = acc.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        //conDocLinks.add(contentDocumentLink);
        insert contentDocumentLink;
    }

    @isTest
    static void testBatch() {
        // Create a set of Ids (String type) from the query result
        Set<String> insolvencySet = new Set<String>();
        for (Insolvency_Account__c insolvAcc : [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
        ]) {
            System.debug('insolvAcc.Id ' + insolvAcc.Id);
            insolvencySet.add(insolvAcc.Id); // Add the Id (String) to the set
        }

        Test.startTest();
        // Pass the Set<String> to the batch
        PocSendEmailBatch pocBatch = new PocSendEmailBatch(insolvencySet);
        Database.executeBatch(pocBatch);
        Test.stopTest();
    }

    @isTest
    static void testBatch2() {
        Insolvency_Account__c insolvAccUpd = [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
            LIMIT 1
        ];
        insolvAccUpd.Client_Identifier__c = 'Fairstone';
        update insolvAccUpd;
        // Create a set of Ids (String type) from the query result
        Set<String> insolvencySet = new Set<String>();
        for (Insolvency_Account__c insolvAcc : [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
        ]) {
            System.debug('insolvAcc.Id ' + insolvAcc.Id);
            insolvencySet.add(insolvAcc.Id); // Add the Id (String) to the set
        }

        Test.startTest();
        // Pass the Set<String> to the batch
        PocSendEmailBatch pocBatch = new PocSendEmailBatch(insolvencySet);
        Database.executeBatch(pocBatch);
        Test.stopTest();
    }

    @isTest
    static void testBatch3() {
        Insolvency_Account__c insolvAccUpd = [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
            LIMIT 1
        ];
        insolvAccUpd.Client_Identifier__c = 'Canadian Tire';
        update insolvAccUpd;
        // Create a set of Ids (String type) from the query result
        Set<String> insolvencySet = new Set<String>();
        for (Insolvency_Account__c insolvAcc : [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
        ]) {
            System.debug('insolvAcc.Id ' + insolvAcc.Id);
            insolvencySet.add(insolvAcc.Id); // Add the Id (String) to the set
        }

        Test.startTest();
        // Pass the Set<String> to the batch
        PocSendEmailBatch pocBatch = new PocSendEmailBatch(insolvencySet);
        Database.executeBatch(pocBatch);
        Test.stopTest();
    }

    @isTest
    static void testBatch4() {
        Insolvency_Account__c insolvAccUpd = [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
            LIMIT 1
        ];
        insolvAccUpd.Client_Identifier__c = 'Goeasy';
        update insolvAccUpd;
        // Create a set of Ids (String type) from the query result
        Set<String> insolvencySet = new Set<String>();
        for (Insolvency_Account__c insolvAcc : [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
        ]) {
            System.debug('insolvAcc.Id ' + insolvAcc.Id);
            insolvencySet.add(insolvAcc.Id); // Add the Id (String) to the set
        }

        Test.startTest();
        // Pass the Set<String> to the batch
        PocSendEmailBatch pocBatch = new PocSendEmailBatch(insolvencySet);
        Database.executeBatch(pocBatch);
        Test.stopTest();
    }
    @isTest
    static void testBatch5() {
        // Create a set of Ids (String type) from the query result
        Set<String> insolvencySet = new Set<String>();
        Account acc = [
            SELECT Id
            FROM Account
            WHERE Id = :[SELECT Id, Insolvency__r.Trustee__c FROM Insolvency_Account__c LIMIT 1].Insolvency__r.Trustee__c
            LIMIT 1
        ];
        acc.Communication_Preference__c = 'Fax';
        acc.Fax = 'testfax384@yopmail.com';
        update acc;

        for (Insolvency_Account__c insolvAcc : [
            SELECT
                Id,
                Name,
                Amended_Claim_Flag__c,
                Insolvency__r.Trustee__r.Preferred_Language__c,
                Insolvency__r.Trustee__r.Communication_Preference__c,
                Insolvency__r.Trustee__r.Business_Email__c,
                Client_Identifier__c
            FROM Insolvency_Account__c
        ]) {
            System.debug('insolvAcc.Id ' + insolvAcc.Id);
            insolvencySet.add(insolvAcc.Id); // Add the Id (String) to the set
        }

        Test.startTest();
        // Pass the Set<String> to the batch
        PocSendEmailBatch pocBatch = new PocSendEmailBatch(insolvencySet);
        Database.executeBatch(pocBatch);
        Test.stopTest();
    }
    /* @isTest
    public static void testBatch6(){
        Set<String> insolvencySet = new Set<String>();
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c(
            Name = 'Test111',
            Client_Identifier__c = 'Canadian Tire'
        );
        insert insolvAcc;
        
        Attachment att = new Attachment(
            Name = 'testAtt',
            Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),
            Description = 'Account Statement',
            parentId = insolvAcc.Id
        );
        insert att;
        
        // Insolvency Acc record create
        Insolvency_Account__c insolvAcc1 = new Insolvency_Account__c(
            Name = 'Test101',
            Client_Identifier__c = 'Canadian Tire'
        );   
        insert insolvAcc1;  
        
        // document storage record //
        Document_Storage__c docInfo = new Document_Storage__c();
        docInfo.Document_Name__c = 'Test_Document.pdf';
        docInfo.Document_Type__c = 'ctb statement output';
        docInfo.Insolvency_Account__c = insolvAcc1.Id;
        insert docInfo;   
        
        Boolean accountStateError = false;
        
        if (docInfo.Document_Type__c.containsIgnoreCase('statement')) {
            accountStateError = true;
            
        }
        
        Test.startTest();
        boolean result = new PocSendEmailBatch(insolvencySet).checkAttachmentForAccState(insolvAcc);
        boolean result1 = new PocSendEmailBatch(insolvencySet).checkAttachmentForAccState(insolvAcc1);
        
        Test.stopTest();
        
    } */

    @isTest
    public static void testBatch7() {
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
        System.runAs(u) {
            EmailTemplate defaultTemplate = new EmailTemplate(
                Name = 'Creditor Package Request',
                TemplateType = 'custom',
                DeveloperName = 'Insolvency_Template22',
                HtmlValue = '{!TODAY()}',
                Body = '{!TODAY()}',
                Subject = '{!Insolvency_Account__c.Secured_Name__c}',
                FolderId = UserInfo.getUserId()
            );
            insert defaultTemplate;

            PoC_Package_Settings__c poc = new PoC_Package_Settings__c(
                Name = 'Scotia Bank',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc;
            PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c(
                Name = 'Canaccede',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                Account_Statement_Not_Allowed__c = defaultTemplate.id,
                Follow_Up_Email_Required_Templates__c = defaultTemplate.id,
                Insolvency_Template_Header_French__c = defaultTemplate.id,
                CFG_Office_Email_Address__c = 'test@canaccede.com'
            );
            insert poc1;
            Test.startTest();
            String header =
                '{!pocPackage.CFG_Office_Name__c},{!pocPackage.CFG_Office_Address_1__c},{!pocPackage.CFG_Office_City__c},{!pocPackage.CFG_Office_Province__c},' +
                '{!pocPackage.CFG_Office_Postal_Code__c},{!pocPackage.CFG_Office_Phone_Number__c},{!pocPackage.CFG_Office_Fax_Number__c},{!pocPackage.CFG_Office_Website__c},' +
                '{!pocPackage.CFG_Office_Address__c},{!pocPackage.CFG_Office_Province_Short_Code__c}{!pocPackage.CFG_Payment_Postal_Code__c},{!pocPackage.Client_Company_Name__c}';
            PocSendEmailBatch.getHTMLHeader(header, poc1);
            Test.stopTest();
        }

    }
}
