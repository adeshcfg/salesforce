/**************************************************************************************************
 *  Class:   TestLoRNotice1Controller
 *  @description : This class contains unit tests for sending LoR notice 1
 *  @author : A5E Consulting
 *  @date : 20/05/2017
 * 
 *************************************************************************************************/

@isTest
public class TestLoRDemandController{
    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         //Custom Setting Insertion
         Application_Config_Settings__c config = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = True,
                                                                                      Maximum_Email_Attachments_Size__c = 18874368,
                                                                                      Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB',
                                                                                     Run_Insolvency_Account_Trigger__c = true,
                                                                                     Eligible_for_Validn_Needed_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
        																			 Eligible_for_Claim_Type_Calculation__c = 'Scotia Bank, SPL, Cannacede, SDA, Affirm',
        																			 Profile_Eligible_for_Duplicate_Check__c = 'CFG,System Administrator,SPL,SDA,Scotia,Affirm',
        																			 Bank_Eligible_for_Duplicate_Check__c = 'SPL',
        																		     Ignore_Account_Number_for_DuplicateCheck__c = 'UNKNOWN',
        																	         Run_Insolvency_Trigger__c = false,
        																			 Run_Insolvency_Account_Duplicate_Check__c = True);
         insert config;
         
         User u = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
         
         System.runAs(u){
             EmailTemplate loRContent = new EmailTemplate(Name = 'LoR Content', TemplateType  = 'custom', DeveloperName='LoR_Content', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release - {!insolv.EstateNumber}', FolderId = UserInfo.getUserId());
             insert loRContent;
             EmailTemplate loRTemplate = new EmailTemplate(Name = 'LoR Template',TemplateType  = 'custom', DeveloperName='LoR_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release', FolderId = UserInfo.getUserId());
             insert loRTemplate;
             
             //Custom Setting Insertion
             PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
                                                                         Client_Company_Name__c = 'Canaccede International ltd.', 
                                                                         CFG_Office_Phone_Number__c = '800-800-800', 
                                                                         CFG_Office_Name__c = 'The Scotia Bank',
                                                                         CFG_Office_Email_Address__c = 'test@canaccede.com',
                                                                         LoR_DemandTemplate_Id__c = loRTemplate.Id,
                                                                         LoR_Notice_1_Content_Id__c = loRContent.Id,
                                                                         CFG_Office_Fax_Number__c = '800-800-800');
             insert poc;
         }
         
         //Account Record Insertion
         Account parentAcc = new Account(Name = 'my acc', Communication_Preference__c = 'Email', Business_Email__c = 'test@sample.com', Is_Active__c=True);
         insert parentAcc;
         //Insolvency Record Insertion
         Insolvency__c insolv = new Insolvency__c(Trustee__c = parentAcc.Id, Name = 'Test');
         insert insolv;
         
         //Insolvency Account Record Insertion
         Insolvency_Account__c insolcAcc = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Scotia Bank',
                                                                 Insolvency__c = insolv.Id,
                                                                 name = 'Test- 001',
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Date_LOR_received_for_Secured__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 Account_Number_Without_Space__c='Test-001');
         insert insolcAcc;
     }
     
     // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void saveDocTest(){
          Insolvency_Account__c insolcAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolcAcc.Id);
          
          LoRDemandController obj = new LoRDemandController();
          obj.toEmail = 'test@cfg.com;';
          obj.poulateRecord('fr');        
          obj.sendEmail();
          obj.popupAttachment();
          obj.changeLanguage();
          obj.reDirect();
          obj.isAnyException = false;
     }
}