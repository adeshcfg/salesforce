/**************************************************************************************************
*
*  Class:   TestCCSEmailController
*
*  @description : This class contains unit tests for send email Agency regarding CCS accounts
*  @author : A5E Consulting
*  @date : 05/02/2020
* 
*************************************************************************************************/

@isTest(seeAllData = false)
public class TestCCSEmailController {
    
    //Create all necessary Object records in this method
    @testSetup 
    public static void testData() {
        
        EmailTemplate emailTempl = new EmailTemplate(Name = 'Balance_Request',TemplateType  = 'custom', DeveloperName='ProductTemplate', HtmlValue = '{!TODAY()}', Body = 'TestBody',Subject = 'Balance Request', FolderId = UserInfo.getUserId());
        //insert emailTempl;
        EmailTemplate emailTemplBody = new EmailTemplate(Name = 'BalanceUpdated_Letter',TemplateType  = 'custom', DeveloperName='ProducTemplateBody', HtmlValue = '{!TODAY()}', Body = 'TestBodyvbody',Subject = 'Balance Updated letter', FolderId = UserInfo.getUserId());
        //insert emailTemplBody;
        
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_EmailMessage_Trigger__c = True);
        insert appConfig;
        
        CCS_Custom_Settings__c CCSPackage = new CCS_Custom_Settings__c(Trustee_Email_Org_Wide_Address_Id__c = '0D2f1000000fxtW');
        insert CCSPackage;
        
        CCS_Email_Templates__c temp = new CCS_Email_Templates__c(Attachment_Template_id__c= '00X56000000y5rlEAA',
                                                                 Email_Body_Template_id__c= '00X56000000y5rmEAA',
                                                                 Name='Product Default Template',
                                                                 Record_Type__c = 'CCS_Account'
                                                                );
        insert temp;
    }
    
    static testMethod void testdata1(){
        
        Account customer = new Account(FirstName = 'FirstName', LastName = 'Last Name', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Canaccede Customer').getRecordTypeId());
        insert customer;
        Account customer2 = new Account(Name = 'Company Name', Business_Email__c = 'test@test.com', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CCS Agency').getRecordTypeId());
        insert customer2;
        
        Product__c prod=new Product__c();
        id rtid=[Select id from RecordType where name = 'CCS Account'].id;
        prod.Name='test';
        prod.CCS_Account_Number__c='459863';
        prod.Customer__c= customer.id;
        prod.CCS_Agency__c = customer2.id;
        prod.CCS_Client_ID__c='213546';
        prod.Status__c = 'New Allocation - New Allocation';
        prod.Sub_Status__c = 'Ready';
        prod.Product_Status__c = 'Test';
        prod.RecordTypeId=rtid;
        insert prod;
        
        Attachment att = new Attachment(Name = 'testAtt', Description = ' Document', Body = Blob.valueOf('Test'), parentId = prod.Id);
        insert att; 
        
        ApexPages.currentPage().getParameters().put('Id', prod.Id);
        
        CCSEmailController obj= new CCSEmailController();
        obj.toEmail = 'test@test.com';
        set<Id> attIdSet = new set<Id>();
        
        /*for(CCSEmailController.Attachment  attch : obj.ProdAttachList){
attch.selected = true;
obj.attachmentSelected = attch.attId;
obj.attachmentSelected();         
}*/
        set<Id> templateSet = new set<Id>();
        //templateSet.add(emailTempl.Id);
        /*obj.attachmentSelected = temp.Id;*/
        //attIdSet.add(att.Id);
        /*obj.mySelectedAtt = attIdSet;*/
        //attIdSet.add(att.Id);//
        obj.emailTemplatechanged();
        obj.CCSEmailAgency();
        /*obj.emailBody = temp.id;*/
        obj.loadEmailTemplates();
        obj.listTempletsDropdown();
        obj.populateValuesInTemplate();
        
        
    } 
    
}