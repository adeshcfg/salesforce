/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of FileUploadLWC.
 *  @author : A5E Consulting
 *  @date : 25/07/2022
 * 
 *************************************************************************************************/
 
@isTest
public class TestFileUploadLWC {
    public static testMethod void testMethod1() 
     {
          Date dT = System.Today();
        //insert placement
        Placement__c place = new Placement__c();
        place.Name = '106';
        place.Agency_Name__c = '(C.C.A.) Commercial Credit Adjusters Ltd.1';
        insert place;
         
        //Insert product
        Product__c prod2 = new Product__c();
        List<User> systemName=[Select Name from User where Name ='System API'];
        prod2.name = '12345';
        prod2.Internal_Status__c = 'Active';
        prod2.Payment_Setup_Status__c = 'Automated';
        prod2.Funding_Status__c = 'Funded';
        prod2.Funding_Type__c = 'Automated';
        prod2.Disbursement_Amount__c = 3000.00;
        prod2.Collection_Agency__c = 106;
        prod2.Current_Balance__c = 7730;
        prod2.Current_Principal_Balance__c = 5000;
        prod2.Current_Interest_Amount__c = 2730;
        prod2.product_status__C = '310000';
        prod2.Current_Workflow__c = 'Collection Process';
        prod2.Requested_Close_Date__c = System.Today();
        prod2.Status__c = 'New Allocation - New Allocation';
        prod2.Sub_Status__c = 'Ready';
        prod2.Product_Status__c = 'Test';
        prod2.Collection_Agency__c = Decimal.valueOf(place.Name);        
        prod2.RecordTypeId = Schema.SObjectType.Product__C.getRecordTypeInfosByName().get('Distressed Account').getRecordTypeId();
        insert prod2;
        
         //insert content version
         String yourFiles = 'Lets assume this is your binary string of the files';
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = EncodingUtil.base64Decode(yourFiles);
        Conver.Title = 'Proposal';
        Conver.PathOnClient= 'ionicLogo.png';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];         
        //ContentDocumentLink record Creation
        String docId = conDoc;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = prod2.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
         FileUploadLWC.UpdateFiles(docId,Conver.Title,prod2.id);
         FileUploadLWC.deleteRecordFile(conDoc);
         FileUploadLWC.contentSize(conDoc);
         //MultipleFileUploadClass.updateAttachmentrecord(cDe,prod2.id);
     }
}