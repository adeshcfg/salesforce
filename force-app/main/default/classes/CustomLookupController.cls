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
    //bug:5476 changes starts
    @AuraEnabled
    public static Judgment__c getJudgmentDetails(Id JudgmentId){
        Judgment__c judg=[select id,name,Product_1__c,Product_2__c,Product_3__c,Product_4__c,Product_5__c from Judgment__c where ID=:JudgmentId];
      return judg;
        /*  if(judg.Product_2__c==''){
            return true;
        }
        else  if(judg.Product_3__c==''){
            return true;
        }
        else  if(judg.Product_4__c==''){
            return true;
        }
        else  if(judg.Product_5__c==''){
            return true;
        }
        */
    }
    //bug:5476 changes ends
    //bug:5476 changes starts
    @AuraEnabled
    public static string getProductName(Id prodId){
product__c prod=[select id,name from product__c where ID=:prodId];
return prod.name;
    }
    //bug:5476 changes ends
}