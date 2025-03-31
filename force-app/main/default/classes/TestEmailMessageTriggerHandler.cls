/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a trigger handler class for EmailMessage object 
 *  @author : A5E Consulting
 *  @date : 24/04/2019
 
 *************************************************************************************************/
  @isTest(SeeAllData=false)
  public class TestEmailMessageTriggerHandler {
    @isTest
    static void testData(){
        
        //Custom setting
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
        config.Run_EmailMessage_Trigger__c = true;
        insert config; 
        
        List<ID> listID = new List<ID>();
        Map<ID,EmailMessage> oldmap=new Map<ID,EmailMessage>();
        
        //Portfolio reocrd creation
        
       Portfolio_Name__c pn=new Portfolio_Name__c();
       pn.name='Test_Portfolio';
       pn.Account_Purchasing_Entity_ID__c = 'text';
       insert pn;    
           
        //Insolvency record creation     
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insolv1.Client_Identifiers__c = 'Scotia Bank';
        insolv1.Sent_For_Owner_Review_Date__c = System.today();
        insert insolv1;
        
        //Insolvency-Account record creation
        list<RecordType> recordTypeList = new list<RecordType>([SELECT Id,Name FROM RecordType WHERE SobjectType='Insolvency_Account__c']);
        
        Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.RecordTypeId = recordTypeList[1].Id;
        insolAcct.Reason_for_No_PoC_Required_Dropdown__c = 'Duplicate';
        insolAcct.Client_Identifier__c = 'Scotia Bank';
        insolAcct.Insolvency__c = insolv1.Id;
        insolAcct.Account_Number_Without_Space__c = 'Test-001';
        insolAcct.name = 'test11';
        insolAcct.Insolvency_Type__c='Division 1 Proposal';
        insolAcct.Claim_Type__c='Unsecured';
        insolAcct.Type_of_Service__c ='Service and Sale';
        insolAcct.Investment_Group__c='OTHER';
        insolAcct.Portfolio_Name_Lookup__c=pn.id;
        insolAcct.Portfolio_Group_Name__c='CAL004';
        insert insolAcct;
        
        // Case record creation
       List<Case> listCase = new List<Case>();
        Case c1 = new Case();
        c1.subject='email';
        c1.status='completed';
        c1.Insolvency_Account__c=insolAcct.id;
        c1.New_Email_on_Case__c = true;
        listCase.add(c1);
        
        Case c2 = new Case();
        c2.subject='email';
        c2.status='completed';
        c2.Insolvency_Account__c=insolAcct.id;
        c2.New_Email_on_Case__c = true;
        c2.Is_Email_to_Case__c = true;
        listCase.add(c2);
        insert listcase;
        
        
        List<EmailMessage> listEmailMessage = new List<EmailMessage>();
        EmailMessage email1 = new EmailMessage();
        email1.Subject='Test1';
        email1.RelatedToId=c1.Id;
        listEmailMessage.add(email1);
        
        EmailMessage email2 = new EmailMessage();
        email2.Subject='Test1';
        email2.RelatedToId=c2.Id;
        listEmailMessage.add(email2);
        insert listEmailMessage;

        Attachment attach = new Attachment(Name = 'Test', ContentType = 'text/xml', ParentId = email2.Id, Body = Blob.valueOf('Test'));
        insert attach;
        
        listID.add(email1.Id);
        listID.add(email2.Id);
        
        email1.subject='UpdateTest1';
        email2.subject='UpdateTest2';
        update listEmailMessage;
        
        
        
        List<Case> listCases = [select id, subject, status, New_Email_on_Case__c from Case where id in :listID];
        
        oldmap.put(email1.Id, email1);
        oldmap.put(email2.Id, email2);
        
        //delete listEmailMessage;
        
        EmailMessageTriggerHandler.handleBeforeDelete(listEmailMessage);
        EmailMessageTriggerHandler.handleAfterUpdate(listEmailMessage, oldmap);
        EmailMessageTriggerHandler.handleAfterInsert(listEmailMessage);
        EmailMessageTriggerHandler.handleBeforeInsert(listEmailMessage);

    }

    }