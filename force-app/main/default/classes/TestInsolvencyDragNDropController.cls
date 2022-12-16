/**************************************************************************************************
 *
 *  Class:   TestInsolvencyDragNDropController
 *
 *  @description : This class contains unit tests for InsolvencyAccntDragNDropController regarding insolvancy drag and drop of an attachments
 *  @author : A5E Consulting
 *  @date : 30-Dec-2017
 * 
 *************************************************************************************************/
@isTest(seeAllData=false)
public class TestInsolvencyDragNDropController{
    
     // Create all necessary test data
     @testSetup 
     static void testData() {
         // create poc custom settings
         PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', CFG_Trustee_Email_Default_content__c = 'test', CFG_Trustee_Email_Default_Subject__c ='test');
         insert poc;
         
         // insert insolvency record
         Insolvency__c insolv = new Insolvency__c(Name='test');
         insert insolv; 
         
         // insert attachments for insolvance
         Attachment att = new Attachment(Name = 'testAtt', Body = Blob.valueOf('Test'), parentId = insolv.Id);
         insert att;
                                                     
         Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = true);
         insert appConfig;
     }
     
     // Testing update attachments
     static testMethod void sendEmailTest(){
          Insolvency__c insolv = [SELECT Id FROM Insolvency__c LIMIT 1];
          // call the constructor
          InsolvencyDragNDropController controller = new InsolvencyDragNDropController(new ApexPages.StandardController(insolv));
          InsolvencyDragNDropController.getDocumentOptions();
          InsolvencyDragNDropController.getfileDocumentOptions();
          InsolvencyDragNDropController.getRecordInfo(insolv.Id);
          controller.updateAtList();
          controller.description = 'Account';
          Double db = controller.offset;
          controller.selectedAttId = [SELECT Id FROM Attachment LIMIT 1].Id;
          controller.deleteAttachment();
     }
}