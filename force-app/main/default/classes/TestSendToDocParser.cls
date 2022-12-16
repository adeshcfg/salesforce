/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of SendToDocParser
 *  @author : A5E Consulting
 *  @date : 07/20/2018
 * 
 *************************************************************************************************/
@IsTest
public class TestSendToDocParser{
    
    @IsTest
    static void testDataCreation() {
    	
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User userRec = new User(Alias = 'standt', Email='sfuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='admintestuser@testorg.com',
            ManagerId = UserInfo.getUserId());  
        insert userRec;
        
        RecordType emailToCaseRecordType = [select Id from RecordType where SObjectType = 'Case' and DeveloperName = 'EmailToCase'];
        
        System.Test.startTest();

        //Application config creation
        Application_Config_Settings__c appConfig = new Application_Config_Settings__c();
        appConfig.Doc_Parser_API_Key__c = '7146d1c4f964579e9faa36c112b2035e3d965a03';
        appConfig.Target_URL_for_Insolvency__c = 'https://api.docparser.com/v1/document/upload'; //'https://api.docparser.com/v1/document/upload
        insert appConfig;

        //English domain name record creation
        Domain_Name_Parser__c domainNameParserObj = new Domain_Name_Parser__c();
        domainNameParserObj.Name = 'a5econsulting.net';
        domainNameParserObj.Domain_Name__c = 'a5econsulting.net'; //'a5econsulting.net'
        domainNameParserObj.Parser_Name__c = 'tkvojqfbfkrm'; //'tkvojqfbfkrm'
        insert domainNameParserObj;

        //Case record creation
        Case caseObj = new Case();
        caseObj.SuppliedEmail = 'abc@a5econsulting.net';
        caseObj.Assigned_To__c = userRec.Id;
        caseObj.Status = 'InProgress';
        caseObj.RecordTypeId = emailToCaseRecordType.Id;
        insert caseObj;

        //Attachment record creation
        Attachment att = new Attachment();
        att.parentId = caseObj.Id;
        att.Body = Blob.valueOf('Test Attach');
        att.Name= 'Test';
        insert att; 
        
        List<Id> listID = new List<Id>{caseObj.Id};
        
        Test.setMock(HttpCalloutMock.class, new DocParserMockResponseGenerator());
        
        // Call the method that invokes a callout
        SendToDocParser.sendDoc(listID, 'French');
        
        //French domain name creation
        French_Domain_Name_Parser__c frenchDomainObj = new French_Domain_Name_Parser__c();
        frenchDomainObj.Name = 'a5econsulting.net';
        frenchDomainObj.Domain_Name__c = 'a5econsulting.net'; //a5econsulting.net
        frenchDomainObj.Parser_Name__c = 'cikdcfvgvhqa'; //cikdcfvgvhqa
        insert frenchDomainObj;
        
        // This causes a fake response to be generated
        Test.setMock(HttpCalloutMock.class, new DocParserMockResponseGenerator());
        
        // Call the method that invokes a callout
        SendToDocParser.sendDoc(listID, 'English');
        SendToDocParser.sendDoc(listID, 'French');
        SendToDocParser.sendDoc(listID, '');
        // Verify that a fake result is returned
        //System.assertEquals('Mock response', output);
        
        System.Test.stopTest();
    }
}