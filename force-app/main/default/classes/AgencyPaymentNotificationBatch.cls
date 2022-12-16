/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to send Notifications for Direct Payments to Portal
 *  @author : A5E Consulting
 *  @date : 08/07/2022
 
 *************************************************************************************************/
public class AgencyPaymentNotificationBatch implements Database.Batchable<AggregateResult>, Database.AllowsCallouts {
    
    public Iterable<AggregateResult> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        //Get work assignments created today with Notifictaion Type = Direct Payment
        
        String query = 'SELECT SUM(Payment_Amount__c) TotalPayment, Payment_Agency__c FROM Product_Payments__c'+
             + ' WHERE Payment_Source__c = \'1\''
             + ' AND CreatedDate = TODAY '
             + ' GROUP BY Payment_Agency__c';
    	return new AggregateResultIterable(query);
        
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        String Title = '';
        String Message = '';
        map<String, String> mapAgencyNames = new map<String, String>();
        
        Date dtTodayDate = System.Today();

        Datetime dtTodayDateTime = datetime.newInstance(dtTodayDate.year(), dtTodayDate.month(),dtTodayDate.day());
        
        string strDate = dtTodayDateTime.format('MM/dd/yyyy');
                
        for(Placement__c place : [SELECT ID, Name, Agency_Name__c FROM Placement__c]){
            mapAgencyNames.put(place.Name, place.Agency_Name__c);
        }
        
        for(sObject sObj : scope) {
			AggregateResult ar = (AggregateResult)sObj;
          	system.debug('>>>> COUNT : ' + ar.get('TotalPayment'));
          	system.debug('>>>> Payment_Agency__c : ' + ar.get('Payment_Agency__c'));
            String agencyName = String.valueOf(ar.get('Payment_Agency__c'));
          	Title = 'Agency Payment Notification for Placement '+agencyName +
                '(' + mapAgencyNames.get(agencyName) + ') on '+strDate;

            Message = '$'+ar.get('TotalPayment') + ' Amount received in Agency Payment';
            String payAgency = String.valueOf(ar.get('Payment_Agency__c'));
            //call to portal API to send payment notification
            PortalNotificationAPI.sendPaymentNotification(payAgency, 
                                                          'Agency Payment', 
                                                          Title, 
                                                          '',
                                                          Message);
        }
        /*
        for(Work_Assignment__c workAssignment : listWorkAssignments){
            Title = 'Direct Payment Notification for Placement '+workAssignment.Placement_Agency_Identifier__c 
                	+ ' (' + workAssignment.Placement_Agency_Name__c + ')';
            Message = workAssignment.Total_Amount_of_Payments__c + ' Amount received in Direct Payment';
                
            //call to portal API to send payment notification
            PortalNotificationAPI.sendPaymentNotification(workAssignment.Placement_Agency_Identifier__c, 
                                                                 workAssignment.Notification_Type__c, 
                                                                 Title, workAssignment.Task_Number__c,
                                                                 Message);
        }*/
    }    
    
    public void finish(Database.BatchableContext bc){
     	   
    }    
}