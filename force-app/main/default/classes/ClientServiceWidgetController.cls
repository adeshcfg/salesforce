public class ClientServiceWidgetController {
    Public Static Set<Id> SetId = new Set<Id>();
    Public Static Set<Id> setProdId = new Set<Id>();
	@AuraEnabled 
    public static List<Product__c> getPlacement(String parentId){
    	List<Product__c> prolist= [SELECT Id,Name,Collection_Agency_Placement__r.Name,
                                   Collection_Agency_Placement__r.Agency_Name__c,
                                   Collection_Agency_Placement__r.Agency_Phone_Number__c,
                                   Collection_Agency_Placement__r.Client_Services_Details__c,
                                   Number_Of_Open_Complaint__c,
                                   Status__c from Product__c 
                                   where id =: parentId ];
     	return prolist;
    }
}