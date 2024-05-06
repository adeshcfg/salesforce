public with sharing class CustomerComplaintsController {
    @AuraEnabled(cacheable=true)
    public static List<Work_Assignment__c> getCustomerComplaints(String recordId) {
        List<Work_Assignment__c> customerComplaints = new List<Work_Assignment__c>();
        try {
            List<Product__c> currentProduct = [SELECT Id, Customer__c FROM Product__c WHERE Id = :recordId LIMIT 1];
            String customerId = currentProduct[0].Customer__c;
            String customerCondition = '';
            if (String.isNotBlank(customerId)) {
                customerCondition = 'Customer__c = :customerId OR';
            }
            String query =
                'SELECT Id, Name, Status__c, Complaint_Type__c, Root_Cause__c FROM Work_Assignment__c WHERE (' +
                customerCondition +
                ' Product__c = :recordId) AND (Record_Type_Identifier__c = \'CFG_Complaint\' OR Record_Type_Identifier__c = \'Agency_Complaint\')';
            customerComplaints = Database.query(query);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return customerComplaints;
    }
}
