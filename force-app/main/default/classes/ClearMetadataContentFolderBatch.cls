global class ClearMetadataContentFolderBatch implements Database.Batchable<sObject> {
    public string folderName = 'Metadata_Content';
    Datetime dt = Datetime.now().addMinutes(-30);
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        If(Test.isRunningTest()){            
            query = 'SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name =: folderName AND CreatedDate <=: dt LIMIT 200';       
        }else{            
            query = 'SELECT Id, FolderId, Folder.Name FROM Document WHERE Folder.Name =: folderName AND CreatedDate <=: dt';          
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Document> docList) {
        try {
            if(!docList.isEmpty()){
                delete docList;
            }
         } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
    }
}