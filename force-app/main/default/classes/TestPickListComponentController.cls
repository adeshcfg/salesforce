@isTest
public class TestPickListComponentController {
    public static testMethod void testPicklistComponent(){
        PickListComponentController.getPickListValues('Payment_Transaction__c', 'Recurrence_Type__c');
    }
}