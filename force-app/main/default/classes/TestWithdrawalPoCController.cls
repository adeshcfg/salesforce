/**************************************************************************************************
 *  Class:   TestWithdrawalPoCController
 *  @description : This class contains unit tests for sending Withdrawal PoC request
 *  @author : A5E Consulting
 *  @date : 06/06/2017
 * 
 *************************************************************************************************/

@isTest
public class TestWithdrawalPoCController{
    //Create all necessary Object records in this method
     @testSetup 
     static void testData() {
         //Custom setting Insertion
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
             EmailTemplate withdrawalTemplate = new EmailTemplate(Name = 'LoR Template',TemplateType  = 'custom', DeveloperName='LoR_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release', FolderId = UserInfo.getUserId());
             insert withdrawalTemplate;
              //Custom setting Insertion
             PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
                                                                         Client_Company_Name__c = 'Canaccede International ltd.', 
                                                                         CFG_Office_Phone_Number__c = '800-800-800', 
                                                                         CFG_Office_Name__c = 'The Scotia Bank',
                                                                         CFG_Office_Email_Address__c = 'test@canaccede.com',
                                                                         Withdrawal_PoC_Template_Id__c = withdrawalTemplate.Id,
                                                                         CFG_Office_Address_1__c = 'Country',
                                                                         CFG_Office_City__c = 'city',
                                                                         CFG_Office_Province__c='province',
                                                                         CFG_Office_Postal_Code__c = '12345',
                                                                      	 Withdrawal_PoC_Template_ID_French__c = withdrawalTemplate.Id);
             insert poc;
         }
         
          //Account Record Insertion
         Account parentAcc = new Account(Name = 'my acc', Communication_Preference__c = 'Fax', Business_Email__c = 'test@sample.com', Fax = 'test@test.com');
         insert parentAcc;
         
         //Insolvency Record Insertion
         Insolvency__c insolv = new Insolvency__c(Trustee__c = parentAcc.Id, Name = 'Test');
         insert insolv;
         
         //Insolvency  Account Record Insertion
         Insolvency_Account__c insolvAcc = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Scotia Bank',
                                                                 Name='Test- 001',
                                                                 Insolvency__c = insolv.Id,
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Date_LOR_received_for_Secured__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 Account_Number_Without_Space__c='Test- 001');
         insert insolvAcc;
         
         //Attachment insertion on related Insolvency account
         Attachment att = new Attachment(Name = 'myAtt', parentId = insolvAcc.Id, Body = Blob.valueOf('my text'));
         insert att;
     }
     
     // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void sendWithdrawalTest(){
          Insolvency_Account__c insolcAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolcAcc.Id);
          
          WithdrawalPoCController obj = new WithdrawalPoCController();
          obj.toEmail = 'test@cfg.com;';
          obj.attachmentSelected = [SELECT Id FROM Attachment LIMIT 1].Id;
          obj.attachmentSelected();
          obj.sendEmail();
          obj.attachmentSelected = [SELECT Id FROM Attachment LIMIT 1].Id;
          obj.attachmentRemoved();
          obj.isAnyException = false;
     }

}