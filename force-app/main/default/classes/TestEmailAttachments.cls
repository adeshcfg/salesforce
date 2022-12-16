/**************************************************************************************************
*
*  Class: Test EmailAttachments
*
*  @description : This is Test Class to display attachemnts from Emails
*  @author : A5E Consulting
*  @date : 26th April 2019

*************************************************************************************************/
@isTest
public class TestEmailAttachments {
    public static testMethod void testdata(){
        
        //Custom setting record Creation
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
        
        //Insolvency Account Record creation
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'test11';
        insolAcct.Insolvency_Type__c='Division 1 Proposal';
        insolAcct.Claim_Type__c='Unsecured';
        insolAcct.Type_of_Service__c ='Service and Sale';
        insolAcct.CreatedDate = System.today();
        insert insolAcct;

        //Case record creation
        case c = new case();
        c.Insolvency_Account__c=insolAcct.id;
        insert c;
        
        /* awp.check = false;
        awp.attach = attach.clone();
        awp.attachmentName ='insovlency';
        awp.description = 'sde';
        awp.strCreatedDate = system.today();
        awp.strlastModifiedDate = system.today()-3;
        awp.strID = attach.id;
        */
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        ApexPages.currentPage().getParameters().put('id',c.id);
        EmailAttachments ea = new EmailAttachments(sc);
        
        Attachment att = new Attachment(Name = 'testAtt', Body = Blob.valueOf('{!Insolvency_Account__c.Balance_Owed__c}'),Description = 'PoC Document', parentId = insolAcct.id,CreatedDate=system.today(),LastModifiedDate=system.today());
        insert att;
        
        EmailAttachments.AttachWrap eawrp=new EmailAttachments.AttachWrap(att);
          
    }
    
}