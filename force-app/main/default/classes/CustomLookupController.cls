public with sharing class CustomLookupController {

    @AuraEnabled(cacheable = true)
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString, String whereClauseField, String whereClauseValue, List<Id> excludeIds) {
        List<RecordsData> recordsDataList = new List<RecordsData>();

        try {
	        String query = 'SELECT Id, ' + filterField+
	                        ' FROM '+objectName+
	                        ' WHERE '+filterField+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' ;
                if(!String.isEmpty(whereClauseField) && !String.isEmpty(whereClauseValue)){
                    query = query + ' AND '+ whereClauseField + ' !=: whereClauseValue';
                }
            
             if( excludeIds.size() > 0){
                    query = query + ' AND Id NOT IN: excludeIds';
                }
                query = query + ' LIMIT 50000';

	        for(SObject s : Database.query(query)){
	            RecordsData recordsData = new RecordsData();
	            recordsData.value = String.valueOf(s.get('id'));
	            recordsData.label = String.valueOf(s.get(filterField));
	            recordsDataList.add(recordsData);
	        } 
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
        
        return recordsDataList;
    }

    public class RecordsData{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }
}