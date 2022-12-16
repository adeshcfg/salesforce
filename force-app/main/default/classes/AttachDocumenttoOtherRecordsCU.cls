/**************************************************************************************************
 *
 *  Class: AttachDocumenttoOtherRecordsCU
 *
 *  @description : This is used to attach the Email message document to parent Insolvency or Insolvency records 
 *                 This controller is for external users only and not be added for Internal users layout
 *  @author : A5E Consulting
 *  @date : 08/21/2020
 
 *************************************************************************************************/
public class AttachDocumenttoOtherRecordsCU {
    
    public List<Attachment> attList{get;set;}

    public AttachDocumenttoOtherRecordsCU(ApexPages.StandardController controller) {
        attList = new list<Attachment>();
        String caseID = ApexPages.currentPage().getPArameters().get('Id');
        attList = [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId 
                   FROM Attachment 
                   WHERE ParentId in (select id from EMailMessage where relatedToid =: caseID) 
                   ORDER BY CreatedDate DESC];
    }
}