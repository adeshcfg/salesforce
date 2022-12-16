public class PickListComponentController {
    
    @AuraEnabled        
    public static List<String> getPickListValues(String objectType, String selectedField) {
        List<String> pkListValues = new List<String>();
        Schema.SObjectType obj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = obj.getDescribe();
        Schema.DescribeFieldResult result = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> pkle = result.getPicklistValues();
        pkListValues.add('--None--');
        for( Schema.PicklistEntry pklVal : pkle){
            pkListValues.add(pklVal.getLabel());
        }     
        return pkListValues;
    }
}