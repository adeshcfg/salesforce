/**************************************************************************************************
*
*  Class: SendAccountUpdatesDocumentToPortalBatch   
*  @description : TestSendAccUpdatesDocToPortalBatch
*  @author : A5E Consulting
*  @date : 06/09/2022  

*************************************************************************************************/
@isTest (seeAllData = false)
public class TestSendAccUpdatesDocToPortalBatch {
  
    @isTest 
    public static void testDirectPayment(){
        String documentID;
        String placement;
        ID documentStorageID;
        String documentType;
        String documentURL;
        
        String Name;
        String Creator;
        String Document_Storage_Number;
        String Document_Id;
        String Document_Name;
        String Document_Type;
        String Document_URL;
        String Placement_Identifier; 
        String Uploaded_By;
        String Visibility;
        String Record_Type_Identifier;
        String Work_Assignment_Identifier;
        String Created_By;
        String Last_Modified_By;
        String Task_Type;
        
        Test.setMock(HttpCalloutMock.class, new PortalAPIMockResponse());

        API_Call_Details__c  settings = new API_Call_Details__c ();
        settings.Name = 'Agency Portal API';
        settings.AuthorizationtUrl__c = 'https://test.com/portalapi';
        settings.Tenand_ID__c = '123';
        settings.Proxy_Client_ID__c = '123';
        settings.Client_ID__c = '1234';
        settings.Client_Secret__c = '1234';
        settings.PDF_API_URL__c = 'https://test.com/endpointurl';
        settings.Scope_Prefix__c = 'scopep.com';
        settings.Scope_Suffix__c = '/.default';
        insert settings;
        
      	List<Document_Storage__c> docSto = new List<Document_Storage__c>();
        
        Document_Storage__c docSto1 = new Document_Storage__c();
        docSto1.Document_Related_To__c = 'Task';
        docSto1.Uploaded_By__c = 'Internal User';
        docSto1.Visibility__c = 'Authoring agencies + CFG';
        docSto1.Document_Extension__c = 'Pdf';
        docSto.add(docSto1);
        insert docSto;
        
        Test.StartTest();
		SendAccountUpdatesDocumentToPortalBatch instancevar = new SendAccountUpdatesDocumentToPortalBatch();
		Database.executeBatch(instancevar);

		Test.StopTest();
        List<Document_Storage__c> docSto2 = [select id,Name,Creator__c,Document_Storage_Number__c,Document_Id__c,Document_Name__c,Document_Type__c,
                              				  Document_URL__c,Placement_Identifier__c,Uploaded_By__c,Visibility__c,
                                              Record_Type_Identifier__c,Work_Assignment_Identifier__c,Created_By__c,
                                             Last_Modified_By__c, Work_Assignment__r.Record_type_Identifier__c from Document_Storage__c];
        for(Document_Storage__c docSt : docSto2){
        Name = docSt.Name;
        Creator = docSt.Creator__c;
        Document_Storage_Number= docSt.Document_Storage_Number__c;
        Document_Id= docSt.Document_Id__c;
        Document_Name= docSt.Document_Name__c;
        Document_Type= docSt.Document_Type__c;
        Document_URL= docSt.Document_URL__c;
        Placement_Identifier= docSt.Placement_Identifier__c;
        Uploaded_By= docSt.Uploaded_By__c;
        Visibility= docSt.Visibility__c;
        Record_Type_Identifier= docSt.Record_Type_Identifier__c;
        Work_Assignment_Identifier= docSt.Work_Assignment_Identifier__c;
        Created_By= docSt.Created_By__c;
        Last_Modified_By= docSt.Last_Modified_By__c;
        }
        
        SendAccountUpdatesDocumentToPortalBatch.processDocumentStorage(Name,  Creator,  Document_Storage_Number,  Document_Id,  Document_Name,  Document_Type,
                              				   Document_URL,  Placement_Identifier,  Uploaded_By,  Visibility,
                                               Record_Type_Identifier,  Work_Assignment_Identifier,  Created_By,
                                               Last_Modified_By,  Task_Type);  
    }

}