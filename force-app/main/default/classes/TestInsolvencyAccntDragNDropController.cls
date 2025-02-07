/**************************************************************************************************
 *
 *  Class:   TestInsolvencyAccntDragNDropController
 *
 *  @description : This class contains unit tests for InsolvencyAccntDragNDropController regarding insolvancy account and drag and drop of an attachments
 *  @author : A5E Consulting
 *  @date : 30-Dec-2017
 * 
 *************************************************************************************************/
@isTest(seeAllData=false)
public class TestInsolvencyAccntDragNDropController{

     // Create all necessary test data
     @testSetup 
     static void testData() {
         
         // create poc custom settings
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', CFG_Trustee_Email_Default_content__c = 'test', CFG_Trustee_Email_Default_Subject__c ='test');
         insert poc;
         
         Application_Config_Settings__c config = Application_Config_Settings__c.getOrgDefaults();
         config.Run_Insolvency_Account_Trigger__c = true;
         config.Run_Insolvency_Status_Validations__c = true;
         config.Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
         config.Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm';
         config.Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm';
         config.Bank_Eligible_for_Duplicate_Check__c = 'SPL';
         config.Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN';
         config.Run_Insolvency_Trigger__c = false;
         config.Run_Insolvency_Account_Duplicate_Check__c = true;
         insert config;
         
         // insert insolvency account
         Insolvency_Account__c insolvAcc = new Insolvency_Account__c();
         insolvAcc.Name='1056649437375';
         insolvAcc.Account_Type__c='Auto';
         insolvAcc.Insolvency_Status__c='New';
         insolvAcc.Borrower_Primary__c='test';
         insolvAcc.Type_of_Service__c='Service and Sale';
         insolvAcc.Claim_Type__c='Unsecured';
         insolvAcc.RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId();
         Insert insolvAcc;

         Document_Storage__c docStr = new Document_Storage__c();
         docStr.Document_Type__c = 'test';
         docStr.Insolvency_Account__c = insolvAcc.id;
         insert docStr;
         
         // insert attachments for insolvance account
         Attachment att = new Attachment(Name = 'testAtt', Body = Blob.valueOf('Test'), parentId = insolvAcc.Id);
         insert att;
         
        ContentVersion conVer = new ContentVersion(Title='TestConVer',PathOnClient='path',VersionData = EncodingUtil.base64Decode('String'));
        insert conVer;
        
        conVer = [Select id, ContentDocumentId from ContentVersion where id =: conVer.Id];
        
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = conVer.ContentDocumentId; // ID of the uploaded ContentDocument
        contentDocumentLink.LinkedEntityId = insolvAcc.id; // ID of the EmailMessage record
        contentDocumentLink.ShareType = 'V'; // 'V' for Viewer access
        contentDocumentLink.Visibility = 'AllUsers'; // File visibility
        //conDocLinks.add(contentDocumentLink);
        insert contentDocumentLink;
         
     }
     
      // Testing update attachments
      static testMethod void uploadAttachments(){
          Insolvency_Account__c insolvAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolvAcc.Id);
          // call the constructor
          InsolvencyAccntDragNDropController controller = new InsolvencyAccntDragNDropController(new ApexPages.StandardController(insolvAcc));
          InsolvencyAccntDragNDropController.getDocumentOptions();
          InsolvencyAccntDragNDropController.getfileDocumentOptions();
          InsolvencyAccntDragNDropController.getRecordInfo(insolvAcc.Id);
          controller.updateAtList();
          controller.description='acc';
          Double db = controller.offset;
          InsolvencyAccntDragNDropController.wrapperClass wrapper = new InsolvencyAccntDragNDropController.wrapperClass();
          wrapper.createdBy = 'test';
          wrapper.documetName = 'test';
          controller.selectedAttId = [SELECT Id FROM Attachment LIMIT 1].Id;
          controller.deleteAttachment();
     }
}