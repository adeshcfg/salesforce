/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a test class for Docomotion Updates batch
 *  @author : A5E Consulting
 *  @date : 07/08/2020
 
 *************************************************************************************************/
@isTest
public class TestDocomotionUpdatesOnDocumentBatch {
    public static testMethod void testBatch(){
        Account account = new Account(name='test acc');
        insert account;
        
        Task task = new Task();
        task.WhatID = account.Id;
        task.Subject='testTask';
        task.Status='New';
        task.Priority='Normal';
        insert task;

        ContentVersion content=new ContentVersion(); 
        content.Title='LetterFile'; 
        content.PathOnClient='/' + content.Title + '.pdf'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=account.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        Test.startTest();
        Database.executeBatch(new DocomotionUpdatesOnDocumentBatch(),20);
        Test.stopTest();
    }
}