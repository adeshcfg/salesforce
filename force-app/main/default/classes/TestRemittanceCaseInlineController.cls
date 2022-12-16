/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of RemittanceCaseInlineController
 *  @author : A5E Consulting
 *  @date : 09/24/2018
 * 
 *************************************************************************************************/
@IsTest
public class TestRemittanceCaseInlineController {
    
    static testMethod void testRemittanceCaseInlineController() {

        System.Test.startTest();
        
        RecordType remittanceRecType = [Select Id 
                                            from RecordType 
                                            where 
                                            SObjectType = 'Case' and 
                                            DeveloperName = 'Remittance'];
        
        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@testOrg.com';
        caseObj.Assigned_To__c = UserInfo.getUserId();
        caseObj.recordTypeId = remittanceRecType.Id;
        caseObj.Status = 'New';
        insert caseObj;
      
        //EmailMessage record creation
        EmailMessage emailMsg =  new EmailMessage();
        emailMsg.relatedToid = caseObj.Id;
        emailMsg.TextBody = 'Test Email';
        emailMsg.FromAddress = 'abc@gmail.com';
        emailMsg.ToAddress = 'xyz@gmail.com';
        insert emailMsg;


        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = emailMsg.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        insert att;
        
        //Remittance record creation
        Remittance__c remittance = new Remittance__c();
        remittance.Status__c = 'New';
        remittance.Email_to_Case_Reference_Number__c = caseObj.Id;
        insert remittance;
        
        PageReference pageRef = Page.RemittanceCaseInline;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', remittance.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(remittance);
        RemittanceCaseInlineController controlr = new RemittanceCaseInlineController(sc);
        
    }
}