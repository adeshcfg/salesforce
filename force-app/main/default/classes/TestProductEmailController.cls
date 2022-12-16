/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a Test class For ProductEmailController 
*  @author : A5E Consulting
*  @date : 29/04/2019
* 
*************************************************************************************************/
@isTest(seeAllData = false)
public class TestProductEmailController {
    
    @testSetup
    static void testData() {
        CCS_Custom_Settings__c CcsSetting = new  CCS_Custom_Settings__c( Product_Template_Header__c ='00X17000000RbO1EAK',
                                                                        Product_Template_WoHeader__c='00X17000000GqaB');
        insert CcsSetting;
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c(Run_Insolvency_Status_Validations__c = false,
                                                                                      Maximum_Email_Attachments_Size__c = 18874368,
                                                                                      Maximum_Email_Attachments_Size_Text__c = 'You can send attachments only upto 18 MB');
        insert appConfig;
        
        
        
    }
   
    static testmethod void testdata1(){
        id rtid=[Select id from RecordType where name = 'CCS Account'].id;
        Product__c prod=new Product__c();
        prod.Name='test';
        prod.CCS_Account_Number__c='459863';
        /*prod.Customer__c=customer.id;*/
        prod.CCS_Client_ID__c='213546';
        prod.RecordTypeId=rtid;
        insert prod;
        //customer creation//
         Account customer = new Account();
         customer.Name = 'Test Account';
         customer.Communication_Preference__c = 'Fax';
         customer.fax= '651426256';
         insert customer;
        
        //Attachment Record Insertion
        Attachment att = new Attachment(Name = 'testAtt', Description = ' Document', Body = Blob.valueOf('Test'), parentId = prod.Id);
        insert att; 
        
        ApexPages.currentPage().getParameters().put('Id', prod.Id);
        
        ProductEmailController obj= new ProductEmailController();
        obj.toEmail = 'test@test.com';
        set<Id> attIdSet = new set<Id>();
        
        for( ProductEmailController.productAttachments  attch : obj.ProdAttachList){
            attch.selected = true;
            obj.attachmentSelected = attch.attId;
            obj.attachmentSelected();         
        }
        
        EmailTemplate  emailTempl = new EmailTemplate(Name = '{!Product__c.Name}',TemplateType  = 'custom', DeveloperName='Product__cTemplate2', HtmlValue = '{!TODAY()}', Body = '{!CcsSetting.CFG_Office_Name__c}',Subject = '{!Product__c.CCS_Client_ID__c}', FolderId = UserInfo.getUserId());
        //set<Id> templateSet = new set<Id>();
       //templateSet.add(emailTempl.Id);
        ///obj.attachmentSelected = att.Id;
        attIdSet.add(att.Id);
        obj.selectedTemplate = emailTempl.Id;
        obj.mySelectedAtt = attIdSet;
        obj.emailTemplatechanged();
        obj.attachmentRemoved();
        //obj.sendEmail();
        obj.emailBody = emailTempl.Body;
        obj.sendEmail();
        obj.checkAttachment();
        obj.isAnyException = false;
        
        
        
        
        
        
    }
    
}