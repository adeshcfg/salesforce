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
         
         User u = [SELECT Id FROM User WHERE Id !=: UserInfo.getUserId() AND Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
         
         System.runAs(u){
             EmailTemplate loRContent = new EmailTemplate(Name = 'LoR Content', TemplateType  = 'custom', DeveloperName='LoR_Content', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release - {!insolv.EstateNumber}', FolderId = UserInfo.getUserId());
             insert loRContent;
             EmailTemplate loRTemplate = new EmailTemplate(Name = 'LoR Template',TemplateType  = 'custom', DeveloperName='LoR_Template', HtmlValue = '{!TODAY()}', Body = '{!TODAY()}',Subject = 'Letter Of Release', FolderId = UserInfo.getUserId());
             insert loRTemplate;
             
           //Custom Setting Insertion
             PoC_Package_Settings__c poc = new PoC_Package_Settings__c();
             poc.Name = 'Scotia Bank'; 
             poc.Client_Company_Name__c = 'Canaccede International ltd.'; 
             poc.CFG_Office_Phone_Number__c = '800-800-800'; 
             poc.CFG_Office_Name__c = 'The Scotia Bank';
             poc.CFG_Office_Name_2__c = 'CFG Canada Funding, LLC';
             poc.CFG_Office_Email_Address__c = 'test@canaccede.com';
             poc.LoR_DemandTemplate_Id__c = loRTemplate.Id;
             poc.LoR_Notice_1_Content_Id__c = loRContent.Id;
             poc.Company_Name__c='';
             poc.CFG_Office_Fax_Number__c = '800-800-800';
             insert poc;
             
             PoC_Package_Settings__c poc1 = new PoC_Package_Settings__c();
             poc1.Name = 'Goeasy'; 
             poc1.Client_Company_Name__c = 'Canaccede International ltd.'; 
             poc1.CFG_Office_Phone_Number__c = '800-800-800'; 
             poc1.CFG_Office_Name__c = 'The Scotia Bank';
             poc1.CFG_Office_Name_2__c = 'CFG Canada Funding, LLC';
             poc1.CFG_Office_Email_Address__c = 'test@canaccede.com';
             poc1.LoR_DemandTemplate_Id__c = loRTemplate.Id;
             poc1.LoR_Notice_1_Content_Id__c = loRContent.Id;
             poc1.Company_Name__c='Goeasy';
             poc1.CFG_Office_Fax_Number__c = '800-800-800';
             insert poc1;
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
                                                                 RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Scotia Bank Insolvency Account').getRecordTypeId(),
                                                                 Account_Number_Without_Space__c='Test-001');
         insert insolcAcc;
         
         Insolvency_Account__c insolcAcc1 = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Goeasy',
                                                                 Insolvency__c = insolv.Id,
                                                                 name = 'Test- 001',//From Hr 
                                                                       //upto Here
                                                                 Account_Type__c = 'Leasing product',
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Date_LOR_received_for_Secured__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 PoC_Created_Date__c = System.Today().addDays(-25),
                                                                 RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Goeasy Insolvency Account').getRecordTypeId(),
                                                                 Account_Number_Without_Space__c='Test-001');
         insert insolcAcc1;
         
         Insolvency_Account__c insolcAcc2 = new Insolvency_Account__c(Claim_Type__c = 'Unsecured', 
                                                                 Proof_of_Claim_Required__c = false, 
                                                                 Client_Identifier__c='Goeasy',
                                                                 Insolvency__c = insolv.Id,
                                                                 name = 'Test- 001',//From Hr 
                                                                       //upto Here
                                                                 Account_Type__c = 'Secured Personal Installment Loan',
                                                                 Insolvency_Status_Last_Changed__c = System.Today(),
                                                                 Date_LOR_received_for_Secured__c = System.Today(),
                                                                 Insolvency_Status__c = 'For Owner Review',
                                                                 PoC_Created_Date__c = System.Today().addDays(-25),
                                                                 RecordTypeId = Schema.SObjectType.Insolvency_Account__c.getRecordTypeInfosByName().get('Goeasy Insolvency Account').getRecordTypeId(),
                                                                 Account_Number_Without_Space__c='Test-001');
         insert insolcAcc2;
         
         Task emailTask = new Task(whatID = insolcAcc.id);
         insert emailTask;
         
         EmailMessage emailmsg = new EmailMessage(Subject = 'test');
         insert emailmsg;
     }
     
     // Unit test for saving poc pdf document as attachment of insolvancy account
     static testMethod void saveDocTest(){
          Insolvency_Account__c insolcAcc = [SELECT Id FROM Insolvency_Account__c LIMIT 1];
          Task emailTask = [SELECT Id FROM Task LIMIT 1];
          EmailMessage emailmsg = [select Id, parentId from EmailMessage];
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
    
    static testMethod void saveDocTest1(){
          Insolvency_Account__c insolcAcc1 = [SELECT Id // From Here
                                              // Uptil Here
                                              FROM Insolvency_Account__c LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolcAcc1.Id);
          
          LoRDemandController obj = new LoRDemandController();
          obj.toEmail = 'test@cfg.com;';
          obj.poulateRecord('fr');        
          obj.sendEmail();
          obj.popupAttachment();
          obj.changeLanguage();
          obj.reDirect();
          obj.isAnyException = false;
     }
    //From Here
    static testMethod void saveDocTest2(){
          Insolvency_Account__c insolcAcc2 = [SELECT Id FROM Insolvency_Account__c where Client_Identifier__c='Goeasy' 
                                               LIMIT 1];
                                              
          ApexPages.currentPage().getParameters().put('Id', insolcAcc2.Id);
          
          LoRDemandController obj = new LoRDemandController();
          obj.toEmail = 'test@cfg.com;';
          obj.poulateRecord('fr');        
          obj.sendEmail();
          obj.popupAttachment();
          obj.changeLanguage();
          obj.reDirect();
          obj.isAnyException = false;
     }// Upto Here
    
    static testMethod void saveDocTest3(){
          Insolvency_Account__c insolcAcc2 = [SELECT Id 
                                              FROM Insolvency_Account__c where Client_Identifier__c='Goeasy' 
                                              AND Account_Type__c != 'Leasing product' LIMIT 1];
          ApexPages.currentPage().getParameters().put('Id', insolcAcc2.Id);
          
          LoRDemandController obj = new LoRDemandController();
          obj.toEmail = 'test@cfg.com;';
          obj.poulateRecord('');        
          obj.sendEmail();
          obj.popupAttachment();
          obj.changeLanguage();
          obj.reDirect();
          obj.isAnyException = false;
     }
}