/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a testclass.
 *  @author : A5E Consulting
 *  @date : 11/03/2020
 *  
 
 *************************************************************************************************/
@isTest
public class TestAttachmentClass {
	@testSetup
    static void testData(){
        Attachment_Document_Type__c portalSettings = Attachment_Document_Type__c.getOrgDefaults();
        portalSettings.Name='Test';
        portalSettings.Document_type__c = 'Proof of Claim';
        portalSettings.Media_Request_Document_Type__c='	Statements';
        portalSettings.Media_Request_Document_Visibility__c='CFG only';
        insert portalSettings;
    }
 @isTest public static void TestFileUploads()
 {
    //Judgment record creation
        Judgment__c judg=new Judgment__c();
        Id RecrdId = Schema.SObjectType.Judgment__c.getRecordTypeInfosByName().get('Judgment').getRecordTypeId();
     	judg.Legal_Agency__c = '29';
        judg.RecordTypeId=RecrdId;
        insert judg;
     
     //Settlement record creation
        settlement__c se=new settlement__c();
        se.status__C='New';
        se.Judgment__c=judg.id;
        insert se;
     
     //contenVersion record creation
        String yourFiles = 'This is a test string';
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = EncodingUtil.base64Decode(yourFiles);
        Conver.Title = 'TestFile';
        Conver.PathOnClient= 'ionicLogo.png';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
     
     //ContentDocumentLink record Creation
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = se.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
     
     
     //Calling Apex methods
     AttachmentClass.getAttachment(se.id);
     AttachmentClass.getPickListValuesIntoList();
     AttachmentClass.monthList();
     AttachmentClass.yearList();
     
     
 }
}