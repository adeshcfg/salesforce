/**************************************************************************************************
*
*  Class: ClearMetadataContentFloderBatchTest 
*
*  @description : This test class testing the ClearMetadataContentFloderBatchTest
*  @author : A5E Consulting
*  @date : 08/02/2023
*
*************************************************************************************************/
@istest(SeeAllData=true)
public class ClearMetadataContentFolderBatchTest {
    
    @istest
    public static void ContentFolderBatchTest(){
        List<Document> documentList = new List<Document>();
        id folderid = [select id from folder where name = 'Metadata_Content'].id;
        for(integer i=0; i<=10; i++){
            Document document = new Document();
            document.Body = Blob.valueOf('Some Text');
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'my_document'+i;
            document.IsPublic = true;
            document.Name = 'My Document';
            document.FolderId = folderid;
            documentList.add(document);
            
        }
        
        if(!documentList.isEmpty()){
            insert documentList;  
        }
        test.startTest();
        //ClearMetadataContentFolderscheduledBatch cmbbatch = new ClearMetadataContentFolderscheduledBatch();
        ClearMetadataContentFolderscheduledBatch sh1 = new ClearMetadataContentFolderscheduledBatch();
		String sch = '0 0 23 * * ?'; system.schedule('Test Territory Check', sch, sh1); 
        ClearMetadataContentFolderBatch cmb = new ClearMetadataContentFolderBatch(); 
        Database.executeBatch(cmb);
        
        test.stopTest();
        
    }
}