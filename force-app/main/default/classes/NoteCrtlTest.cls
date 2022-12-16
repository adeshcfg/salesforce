/**************************************************************************************************
*
*  Class:   NoteCrtlTest
*
*  @description : Used to Test Public Note record from Insolvency and Insolvnecy Account
*  @author : A5E Consulting
*  @date : 03/04/2019
* 
*************************************************************************************************/
@isTest
private class NoteCrtlTest {
    static testMethod void edit()
    {
        
        Insolvency__c recordInsolvency= new Insolvency__c(name='dummy');
        insert recordInsolvency;
        Note recordNote = new Note(parentid = recordInsolvency.id, body ='hi', title = 'Bye');
        insert recordNote;
        // retrive the note page
        recordNote = [SELECT id, parentID, body, createdDate, owner.name, title, LastModifiedDate, CreatedBy.name, lastmodifiedby.name
                      from Note where id = : recordNote.id];
        test.startTest();
        /*PageReference pageRef = Page.Notedisplay;
        Test.setCurrentPage(pageRef);*/
        
        ApexPages.currentPage().getParameters().put('id',recordNote.id);
        ApexPages.StandardController sc = new ApexPages.standardController(recordNote);
        
        NoteCrtl noteCrtlController = new NoteCrtl(sc);
        noteCrtlController.Edit();
        noteCrtlController.Cancel();
        test.stopTest();
    }
}