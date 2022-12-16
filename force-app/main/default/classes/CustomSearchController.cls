public class CustomSearchController {
    @AuraEnabled
    public static List<sObject> search(String searchText, String searchObject, List<String> searchFields, List<String> returnFields, List<sObject> excludeRecords, List<String> searchRecordTypes) {
    	String return_Fields = String.join(returnFields, ',');
        List<String> searchValues = formatSeachValues(searchText);
        String soql = 'SELECT '+return_Fields;
        soql= soql+' FROM '+searchObject+' WHERE (';
        
        List<String> searchFieldFormat = new List<String>();
        
        for(String searchField: searchFields){
            for(String searchValue: searchValues){
                searchFieldFormat.add(searchField+' LIKE '+searchValue);
            }
           
            //String.escapeSingleQuotes(companyName)
        }
        soql= soql+''+String.join( searchFieldFormat, ' OR ' );
        soql = soql+') AND Id NOT IN: excludeRecords';
        List<String> searchRecordTYpeIDs = new List<String>();
        for(String recordTypeName: searchRecordTypes){
            if(!String.isEmpty(recordTypeName)){
                Schema.DescribeSObjectResult descResult = Schema.describeSObjects(new String[]{searchObject})[0];
                Id recordTypeId = descResult.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                String recType = 'RecordTypeId = \''+recordTypeId+'\'';
                searchRecordTYpeIDs.add(recType);
//                soql = soql+' AND RecordTypeId  =: recordTypeId';
            }
        }
        
        if(!searchRecordTYpeIDs.isEmpty()){
            soql = soql+' AND ('+String.join( searchRecordTYpeIDs, ' OR ')+')';
        }
        soql = soql+' LIMIT 1000';
        system.debug('soql='+soql);
        List<sObject> searchResults = database.Query(soql);
        return searchResults;
    }
    
    public static List<String> formatSeachValues(String searchText){
        List<String> returnValues = new List<String>();
        List<String> searchValues = searchText.split(',');
        for(String str: searchValues){
            str = str.trim();
            if(!String.isEmpty(str)){
                str = '\'%'+str+'%\'';
                returnValues.add(str);
            }
            
        }
        return returnValues;
    }
}