/**************************************************************************************************
 *
 *  Class: Test MarkEmailRead
 *
 *  @description : This is used to mark new email as read
 *  @author : A5E Consulting
 *  @date : 25/04/2019
 
 *************************************************************************************************/
@isTest
public class TestMarkEmailRead {
    @isTest
     static void testData() {
         
    	Insolvency_Account__c insolAcct = new Insolvency_Account__c();
        insolAcct.name = 'test11';
        insolAcct.Insolvency_Type__c='Division 1 Proposal';
        insolAcct.Claim_Type__c='Unsecured';
        insolAcct.Type_of_Service__c ='Service and Sale';
        insert insolAcct;
         
    case c = new case();
    c.New_Email_on_Case__c = true;
    c.Insolvency_Account__c=insolAcct.id;
    insert c;
         
     ApexPages.StandardController sc = new ApexPages.StandardController(c);
      ApexPages.currentPage().getParameters().put('id',c.id);
          MarkEmailRead mark= new MarkEmailRead(sc);
           mark.markNewEmailasRead();
    
}
}