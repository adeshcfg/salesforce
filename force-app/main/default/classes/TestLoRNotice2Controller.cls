/**************************************************************************************************
 *  Class:   TestLoRNotice2Controller
 *  @description : This class contains unit tests for sending LoR notice 2
 *  @author : A5E Consulting
 *  @date : 15/05/2017
 * 
 *************************************************************************************************/

@isTest
public class TestLoRNotice2Controller{
    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         Application_Config_Settings__c config = new  Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = false);
         insert config;
         
         User u = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
         
         System.runAs(u){
             EmailTemplate loRContent = new EmailTemplate(Name = 'LoR Content', TemplateType  = 'custom', DeveloperName='LoR_Content', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release', FolderId = UserInfo.getUserId());
             insert loRContent;
             EmailTemplate loRTemplate = new EmailTemplate(Name = 'LoR Template',TemplateType  = 'custom', DeveloperName='LoR_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release', FolderId = UserInfo.getUserId());
             insert loRTemplate;
             
             PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
                                                                         Client_Company_Name__c = 'Canaccede International ltd.', 
                                                                         CFG_Office_Phone_Number__c = '800-800-800', 
                                                                         CFG_Office_Name__c = 'The Scotia Bank',
                                                                         CFG_Office_Email_Address__c = 'test@canaccede.com',
                                                                         LoR_Notice_2_Template_Id__c = loRTemplate.Id,
                                                                         LoR_Notice_2_Content_Id__c = loRContent.Id);
             insert poc;
         }
         Account parentAcc = new Account(Name = 'my acc', Communication_Preference__c = 'Email', Business_Email__c = 'test@sample.com');
         insert parentAcc;
         
         Insolvency__c insolv = new Insolvency__c(Trustee__c = parentAcc.Id, Name='Test');
         insert insolv;
         
         Insolvency_Account__c insolcAcc = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Scotia Bank',
                                                                 Insolvency__c = insolv.Id,
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Date_LOR_received_for_Secured__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review');
         insert insolcAcc;
     }
     
     // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void saveDocTest(){
          Insolvency_Account__c insolcAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolcAcc.Id);
          
          LoRNotice2Controller obj = new LoRNotice2Controller();
          obj.toEmail = 'test@cfg.com;';
          obj.sendEmail();
          obj.isAnyException = false;
     }
}