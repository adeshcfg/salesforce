/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of AssignmentDocCntrl
 *  @author : A5E Consulting
 *  @date : 09/04/2018
 * 
 *************************************************************************************************/
@IsTest
public class TestAssignmentDocCntrl {
    
    static testMethod void testMethodAttachment() {
        //Case record creation
        Case caseObj = new Case();
        caseObj.Status = 'InProgress';
        caseObj.Insolvency_Assignment_Type__c = 'Business Insolvency';
        INSERT caseObj;
        
        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = caseObj.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        att.Description = 'Test Attachment';
        att.IsPrivate = false;
        INSERT att;
        
        PageReference pageRef = Page.AssignmentDocument;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(caseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj);
        AssignmentDocCntrl attachRec = new AssignmentDocCntrl(sc);
        attachRec.selectedAttId = caseObj.Id;
        attachRec.attach = att;
        attachRec.fileUploadSuccess = true;
        attachRec.communityUser = false;
        attachRec.documentType = caseObj.Insolvency_Assignment_Type__c;
        attachRec.deleteAttachment();
        attachRec.upload();
       // attachRec.getCommunityUrl();
        attachRec.getBaseUrl(attachRec.communityUser);
        attachRec.getInslAttachmentWrappers();
        //attachRec.refreshAttList();
    }
}