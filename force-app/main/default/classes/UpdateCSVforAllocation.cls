public class UpdateCSVforAllocation {
    
    public static Blob updateCSV(String contentDocumentId, ID documentStorageID){
        system.debug('documentStorageID::' + contentDocumentId);
        ContentVersion cv = [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId =: contentDocumentId ];
      	final String csvContents = cv.VersionData.toString();
		//System.debug('csvContents::' + csvContents);
        final CSVIterator iterator = new CSVIterator(csvContents, '\n');
        List<String> modifiedContent = new List<String>();
        while(iterator.hasNext()){
            String row = iterator.next().trim();
			if(modifiedContent.isEmpty()) {
               row = row + ',Identifier__c'; 
           }   
           else {
               row = row + ',' + documentStorageID;
           }
           modifiedContent.add(row);
        }
		//final String[] csvLines = csvContents.split('\n');
         
        //String stringBody = csvContents;
        //List<String> filelines = stringBody.split('\n');
		//List<String> accstoInsert = new list<String>();
        //System.debug('Total Lines ' + filelines.size());
        //line = filelines[0].trim()+',Identifier__c'+'\n';
        //for (Integer i=1;i<filelines.size();i++)
        //{            
            //line += filelines[i].trim()+','+ contentDocumentId +'\n';
            //system.debug('->'+line);           
        //}
        //system.debug('modifiedContent::' + modifiedContent);
        /*ContentVersion cvn = new ContentVersion();
        cvn.id=cv.id;
        cvn.VersionData = Blob.valueOf(line);//EncodingUtil.base64Decode(line);
        //cvn.IsMajorVersion = false;
        update cvn;*/
        return Blob.valueOf(String.join(modifiedContent, '\n'));
	}
}