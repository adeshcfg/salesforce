@isTest
public class TestDividendsDelete {

    @isTest
    static void testDeleteDividend() {
                   
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
        Remittance__c remittance1 = new Remittance__c();
        remittance1.Status__c = 'New';
        remittance1.Email_to_Case_Reference_Number__c = caseObj.Id;
        insert remittance1;
        
        //Insolvency Record
        Insolvency__c insolv1 = new Insolvency__c();
        insolv1.Name = '12456780';
        insert insolv1;
        
        //Insolvency Account Record
        Insolvency_Account__c insAcc1 = new Insolvency_Account__c();
        insAcc1.Insolvency_Status__c = 'For Owner Review';
        insAcc1.Claim_Type__c = 'Unsecured';
        insAcc1.Insolvency__c = insolv1.id;
        insert insAcc1;        
        
        //Insolvency Payments
        Insolvency_Payment__c payment1 = new Insolvency_Payment__c();
        payment1.Remittance__c = remittance1.Id;
        payment1.Insolvency_Account__c = insAcc1.Id;
        insert payment1;
               
        //Unallocated Payments
        Unallocated_Payment__c payment2 = new Unallocated_Payment__c();
        payment2.Remittance__c = remittance1.Id;
        insert payment2;
        
        ApexPages.currentPage().getParameters().put('id', remittance1.Id);
        
        // Create a StandardController for the Remittance__c object
        ApexPages.StandardController sc = new ApexPages.StandardController(remittance1);
        
        // Instantiate the DividendsDelete class
        DividendsDelete controller = new DividendsDelete(sc);
         
        // Call the deleteDividend method
        DividendsDelete.deleteDividend();
        DividendsDelete.closePopup();
   }
 
@isTest
    static void testExceptionDeleteDividend() {                      
        ApexPages.currentPage().getParameters().put('id', '111111111111111');
         
        // Call the deleteDividend method
        DividendsDelete.deleteDividend();
    }
}