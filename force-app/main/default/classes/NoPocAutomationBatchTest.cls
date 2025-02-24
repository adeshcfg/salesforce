/**
 * @description       : Test class for NoPocAutomationBatch
 * @author            : adesh.ikhar@canaccede.com
 * @last modified on  : 02-24-2025
 * @last modified by  : adesh.ikhar@canaccede.com
 **/
@isTest
public class NoPocAutomationBatchTest {
    @TestSetup
    static void makeData() {
        User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
        System.runAs(u) {
            EmailTemplate defaultTemplate = new EmailTemplate(
                Name = 'Creditor Package Request',
                TemplateType = 'custom',
                DeveloperName = 'ADDITIONAL_INFORMATION_REQUIRE_FAIRSTONE',
                HtmlValue = '<html> <table> <tr> <td style="width:200px;"><img src="https://cfgroup--c.na103.content.force.com/servlet/servlet.ImageServer?id=0153a000003PeHo&oid=00Dj0000001ripe&lastMod=1634276221000" width="110px" height="105"/></td> <td style="padding-left:50px; width:300px;"> {!pocPackage.CFG_Office_Name__c}<br/> {!pocPackage.CFG_Office_Address_1__c}<br/> {!pocPackage.CFG_Office_City__c} | {!pocPackage.CFG_Office_Province__c} | {!pocPackage.CFG_Office_Postal_Code__c} </td> <td style="width:100px; text-align: right;"> t. {!pocPackage.CFG_Office_Phone_Number__c}<br/> f. {!pocPackage.CFG_Office_Fax_Number__c}<br/> {!pocPackage.CFG_Office_Website__c} </td> </tr> </table><br/> <body> <p>Sir / Madam,&nbsp; <br /> <br />As you are aware, Canaccede International Management Ltd is processing Bank of Nova Scotia insolvent accounts.&nbsp; <br /> <br />We have received your package and Bank of Nova Scotia has requested some additional information on the account listed.&nbsp; <br /> <br />Please be advised that BNS is not able to locate the debtor, please provide us with the account #, VIN and/or SIN #.&nbsp; <br /> <br />If any errors occurred in the transmission of the attachment, please contact Canaccede at;&nbsp; <br />Email:&nbsp;<a href="mailto:SBInsolvency@Canaccede.com">SBInsolvency@Canaccede.com</a>&nbsp; <br />Facsimile: {!pocPackage.CFG_Office_Fax_Number__c}&nbsp; {!Insolvency_Account__c.Secured_Name__c} {!Insolvency__r.Name} {!pocPackage.CFG_Office_Address__c} {!pocPackage.Name} {!pocPackage.CFG_Office_Province_Short_Code__c} {!pocPackage.CFG_Payment_Postal_Code__c} {!pocPackage.CFG_Office_Email_Address__c} {!pocPackage.Company_Name__c} {!pocPackage.Client_Company_Name_French__c} {!pocPackage.Client_Company_Name__c}<br />Telephone: {!pocPackage.CFG_Office_Phone_Number__c}&nbsp; <br /> <br />Thank You,&nbsp; <br />Canaccede Insolvency Processing</p> </body> </html>',
                Body = '{!TODAY()}',
                Subject = '{!Insolvency_Account__c.Secured_Name__c}, {!Insolvency_Account__c.Name}',
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
                CFG_Office_Name__c = 'Test',
                CFG_Office_Address_1__c = 'PO Box 758 STN B',
                CFG_Office_Address__c = 'PO Box 758 STN B',
                CFG_Office_Fax_Number__c = '844-827-9220',
                CFG_Office_Phone_Number__c = '844-827-9222',
                CFG_Office_City__c = 'London',
                CFG_Office_Province_Short_Code__c = 'ON',
                CFG_Office_Postal_Code__c = 'N6A 4Y8',
                CFG_Payment_Postal_Code__c = 'N6A 4Y8',
                CFG_Office_Email_Address__c = 'test@canaccede.com',
                CFG_Office_Website__c = 'www.google.com',
                CFG_Office_Province__c = 'Test',
                Company_Name__c = 'Test',
                Client_Company_Name_French__c = 'Test',
                Client_Company_Name__c = 'Test'
            );
            PoC_Package_Settings__c ctb = new PoC_Package_Settings__c(
                Name = 'Canadian Tire',
                CFG_Trustee_Email_Default_content__c = 'test',
                CFG_Trustee_Email_Default_Subject__c = 'test',
                Insolvency_Template_Header__c = defaultTemplate.id,
                Insolvency_Template_WoHeader_French__c = defaultTemplate.id,
                Insolvency_Template_WoHeader__c = defaultTemplate.id,
                Attachment_Required_Email_Templates__c = defaultTemplate.id,
                CFG_Office_Name__c = 'Test',
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
                CFG_Office_Email_Address__c = 'test@canaccede.com',
                CFG_Office_Website__c = 'www.google.com',
                CFG_Office_Province__c = 'Test',
                Company_Name__c = 'Test',
                Client_Company_Name_French__c = 'Test',
                Client_Company_Name__c = 'Test'
            );
            insert new List<PoC_Package_Settings__c>{ poc, ctb };
        }

        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.fax = '651426256';
        acct.Follow_up_Email__c = 'test283@yopmail.com';
        acct.Business_Email__c = 'test11283@yopmail.com';
        acct.Preferred_Language__c = 'French';
        insert acct;

        Insolvency__c inslv = new Insolvency__c();
        inslv.Name = 'Test-Email0010';
        inslv.Debtor_1_First_Name__c = 'first';
        inslv.Debtor_1_Last_Name__c = 'last';
        inslv.Trustee__c = acct.Id;
        insert inslv;

        Insolvency_Account__c acc = new Insolvency_Account__c();
        acc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
        acc.Name = 'Test- 001';
        acc.Insolvency__c = [SELECT Id FROM Insolvency__c LIMIT 1][0].Id;
        acc.Borrower_Primary__c = 'TestData';
        acc.Client_Identifier__c = 'Scotia Bank';
        acc.Balance_Owed__c = 20.0;
        acc.Amended_Claim_Flag__c = false;
        acc.Insolvency_Status__c = 'No PoC Required';
        acc.Reason_for_No_PoC_Required_Dropdown__c = 'Unable to Locate Account';
        acc.Claim_Amount__c = 100;
        acc.Insolvency_Status_Last_Changed__c = System.Today();
        acc.Account_Number_Without_Space__c = 'Test-001';
        acc.Insolvency_Type__c = 'Consumer Proposal';
        acc.Acknowledgement_date__c = System.today();
        insert acc;
    }

    @isTest
    static void automationBatchTest() {
        Test.startTest();
        NoPocAutomationBatch noPocBatch = new NoPocAutomationBatch();
        Database.executeBatch(noPocBatch);
        Test.stopTest();
    }

    @isTest
    static void schedulerTest() {
        Test.startTest();
        NoPocAutomationBatch noPocBatch = new NoPocAutomationBatch();
        String sch = '0 0 23 * * ?';
        System.schedule('Test automation Check', sch, noPocBatch);
        Test.stopTest();
    }
}
