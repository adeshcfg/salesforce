/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of MultipleFileUpload.
 *  @author : A5E Consulting
 *  @date : 25/07/2022
 * 
 *************************************************************************************************/

@isTest
public class TestMultipleFileUploadClass {
    
    public static testMethod void testMethod1() 
    {
        
        Date dT = System.Today();
        Attachment_Document_Type__c AttachDocType = new Attachment_Document_Type__c(); 
        AttachDocType.Name = '01';
        AttachDocType.Media_Request_Document_Type__c = 'Application';
        // AttachDocType.Media_Request_Document_Visibility__c = 'CFG + All Agencies';
        insert AttachDocType;
        
        Attachment_Document_Type__c AttachDocType1 = new Attachment_Document_Type__c(); 
        //AttachDocType1.Media_Request_Document_Type__c = 'Application';
        AttachDocType1.Name = '02';
        AttachDocType1.Media_Request_Document_Visibility__c = 'CFG + All Agencies';
        insert AttachDocType1;
        
        Agency_Portal_Settings__c config = new Agency_Portal_Settings__c();
        config.Name = 'Agency Portal Settings';
        config.MutipleFileUpload__c = 'a0D';
        insert config;
        //config.MutipleFileUpload__c = 'a0D';
        //update config;
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
        
        //Insert work Assignment
        Work_Assignment__c workAssData1 = new Work_Assignment__c();
        string recrdid1= [SELECT id from RecordType where sobjecttype='Work_Assignment__c' 
                          AND RecordType.Name='CFG Media'].id;
        workAssData1.Title__c = 'This task for Test class';
        workAssData1.Description__c = 'This task is for product record';
        workAssData1.Purpose__c = 'Payment';
        workAssData1.Start_Month__c = '08';
        workAssData1.Start_Year__c = '2020';
        workAssData1.End_Month__c = '03';
        workAssData1.End_Year__c = '2021';
        workAssData1.Status__c = 'Requested';
        workAssData1.Assign_To__c = 'CFG';
        workAssData1.Comment_Reply__c = 'I have resolved the issue of product record';
        workAssData1.Product__c = prod2.id;
        workAssData1.Placement_Agency__c=place.id;
        workAssData1.Placement_Agency_Identifier__c=place.id;
        workAssData1.Product_Identifier__c = prod2.id;
        //workAssData1.Customer_Identifier__c = accInstance.id;
        //workAssData1.Judgment_Identifier__c = jud.id;
        //workAssData1.Settlement_Identifier__c = stmt.id;
        workAssData1.Accept_Assignment__c = True;
        workAssData1.Original_Creditor__c = 'Test data';
        workAssData1.Resolution_By__c = 'Test By User';
        workAssData1.Resolution_Date__c = dT;
        insert workAssData1;
        
        //insert content version
        String yourFiles = 'Lets assume this is your binary string of the files';
        ContentVersion Conver = new ContentVersion();
        Conver.ContentLocation = 'S';
        Conver.VersionData = EncodingUtil.base64Decode(yourFiles);
        Conver.Title = 'Proposal@FileUpload';
        Conver.PathOnClient= 'ionicLogo.png';
        insert conVer;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:Conver.Id].ContentDocumentId;
        //List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];         
        //ContentDocumentLink record Creation
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = prod2.id; // This will link inserted file to above inserted settlement record
        cDe.ShareType = 'I'; 
        cDe.Visibility = 'InternalUsers';
        insert cDe;
        
        String jarJson = '['+'{'+
            '"attachID": "'+conDoc+'",'+
            '"attachmentCreateddate": "25/07/2022 9:21 AM",'+
            '"attachmentLastmodifieddate": "25/07/2022 9:21 AM",'+
            '"attachmentName": "Proposal@FileUpload",'+
            '"docType": "Drivers License",'+
            '"month": "CFG + All Agencies"'+
            '}'+']';
        MultipleFileUploadClass.getAttachment(prod2.id);
        MultipleFileUploadClass.updateAttachmentrecord(jarJson,prod2.id);
        MultipleFileUploadClass.getPickListValuesIntoList();
        MultipleFileUploadClass.getDocVisibilityValues();
    }
}