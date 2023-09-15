/**************************************************************************************************
 *  Class:   TestServicerNoticeToTrusteeController
 *  @description : This class contains unit tests for sending Notice To Servicer
 *  @author : A5E Consulting
 *  @date : 31/05/2018
 * 
 *************************************************************************************************/
@isTest
public class TestServicerNoticeToTrusteeController {
    
    @testSetup 
    static void testData() {
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
        //Email Template Insertion 
        System.runAs(u){
            EmailTemplate NoTTemplate = new EmailTemplate(Name = 'Notice to Trustee Template',TemplateType  = 'custom', DeveloperName='Notice_to_Trustee_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Servicer Notice to Trustee', FolderId = UserInfo.getUserId());      
        	insert NoTTemplate;
             
         	PoC_Package_Settings__c poc = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
                                                                         Client_Company_Name__c = 'Canaccede International ltd.', 
                                                                         CFG_Office_Phone_Number__c = '800-800-800', 
                                                                         CFG_Office_Name__c = 'The Scotia Bank',
                                                                         CFG_Office_Email_Address__c = 'test@canaccede.com',
                                                                         CFG_Office_Fax_Number__c = '111-111-111',
                                                                         CFG_Office_Name_2__c = 'temp',
                                                                         Notice_to_Trustee_Template_Id__c = NoTTemplate.Id,
                                                                      	 CFG_French_Office_Name__c = 'Canaccede International Management Ltd.',
                                                                         Account_Statement_Not_Allowed__c  = '00X17000000RbO1EAK');                                                                    
        	insert poc;
            
            PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c(Name = 'Scotia Bank', 
                                                                         Client_Company_Name__c = 'Canaccede International ltd.', 
                                                                         CFG_Office_Phone_Number__c = '800-800-800', 
                                                                         CFG_Office_Name__c = 'CFG Canada Funding, LLC',
                                                                         CFG_Office_Email_Address__c = 'test@canaccede.com',
                                                                         CFG_Office_Fax_Number__c = '111-111-111',
                                                                         CFG_Office_Name_2__c = 'temp',
                                                                         Notice_to_Trustee_Template_Id__c = NoTTemplate.Id,
                                                                       	 CFG_French_Office_Name__c = 'Canaccede International Management Ltd.',
                                                                         Account_Statement_Not_Allowed__c  = '00X17000000RbO1EAK');                                                                    
        	insert poc1;
        }
        //Cusomer record Insertion
        Account parentAcc = new Account(Name = 'my acc', Communication_Preference__c = 'Email', 
                                        Business_Email__c = 'test@sample.com', BillingStreet = 'test', 
                                        BillingState = 'test', BillingPostalcode = 'test',
                                       BillingCity = 'test',Is_Active__c=True);
        insert parentAcc;
        //Insolvency record Insertion
        Insolvency__c insolv = new Insolvency__c();
        insolv.name = 'insolv';
        insolv.Insolvency_Type__c = 'Bankruptcy	';
        insolv.Insolvency_Received_Date__c = system.today();
        insolv.Insolvency_Status__c = 'Active';
        insolv.Insolvency_Date__c = system.today();
        insolv.Debtor_1_Court_Number__c = 'test';
        insolv.Court_Division_Number__c = 'test';
        insolv.Court_District_Name__c = 'Mission';
        insolv.Court_Province__c = 'Newfoundland and Labrador';
        insolv.Debtor_2_First_Name__c = 'Gari';
        insolv.Debtor_2_Last_Name__c = 'Steves';
        insolv.Debtor_2_Date_of_Birth__c = system.today();
        insolv.Debtor_2_Gender__c = 'Male';
        insolv.Debtor_2_Mailing_Street__c = '45 A street 12';
        insolv.Debtor_2_Mailing_City__c = 'test city';
        insolv.Debtor_2_Mailing_State_Province__c = 'Newfoundland and Labrador';
        insolv.Debtor_2_Mailing_Postal_Code__c = 'N8U 7Y7';
        insolv.Trustee__c = parentAcc.Id;
        insert insolv;
        //Insolvency Account record Insertion 
        Insolvency_Account__c insolcAcc = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Scotia Bank',
                                                                 Insolvency__c = insolv.Id,
                                                                 Name='Test- 001',
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Servicer_Notice_to_Trustee_Sent_Date__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 Account_Number_Without_Space__c='Test-001');
                                                                   
        insert insolcAcc;
        Insolvency_Account__c insolcAcc1 = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Goeasy',
                                                                 Insolvency__c = insolv.Id,
                                                                 Name='Test- 001',
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Servicer_Notice_to_Trustee_Sent_Date__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 Account_Number_Without_Space__c='Test-001');
                                                                   
        insert insolcAcc1;
        //Attachment insertion on related Insolvency account
        Attachment attch = new Attachment(name='Sample Document', body=Blob.valueOf('test Body'), parentId=insolcAcc.id);
        insert attch;
 
    }
    
    static testMethod void saveDocTest(){
      Insolvency_Account__c insolAcc = [SELECT Id, Trustee_Company__c FROM Insolvency_Account__c LIMIT 1];
      Attachment attchObj = [select Name, description from attachment limit 1];
      ApexPages.currentPage().getParameters().put('Id', insolAcc.Id);
      PageReference pRef = Page.ServicerNoticeToTrustee;
      pRef.getParameters().put('id', insolAcc.Id);
      Test.setCurrentPage(pRef);
        
      ServicerNoticeToTrusteeController obj = new ServicerNoticeToTrusteeController();
       //calling class methods
       obj.toEmail = 'test@cfg.com;';
       obj.poulateRecord();
       obj.attachmentRemoved();
       obj.attachmentSelected = [SELECT Id FROM Attachment LIMIT 1].Id;
       obj.attachmentSelected();
       obj.attachmentSelected = [SELECT Id FROM Attachment LIMIT 1].Id;
       obj.sendEmail();
       obj.isAnyException = false;
        
    }
    
}