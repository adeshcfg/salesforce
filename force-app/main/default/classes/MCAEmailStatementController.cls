/**************************************************************************************************
 *
 *  Class:   Controller class for email statement generation
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 19/05/2021
 
*************************************************************************************************/
public class MCAEmailStatementController {
    //public list<paymentWrapper> listPaymentWrapper {get;set;}
    public list<Merchant_Account_Payment__c> listPaymentsToDisplay {get;set;}
    public Merchant_Account__c merchantAcc {get;set;}
    public String strTodayDate {get;set;}
    public Double totalDue {get;set;}
    public String statementMonth {get;set;}
    
    public static String BALANCE_FORWARD = 'Balance Forward';

    public MCAEmailStatementController(){
        Id merchantRecordId = ApexPages.currentPage().getParameters().get('id');
        listPaymentsToDisplay = new list<Merchant_Account_Payment__c>();
        merchantAcc = new Merchant_Account__c();
        merchantAcc = [SELECT ID, Name, 
                                // Former_BFS_Capital_Account_Number_XXXX__c,
                                // Former_BFS_Capital_Account_Number__c,
                                Address__c, City__c, Province__c, Postal_Code__c, 
                                Merchant__r.DBA__c,Current_Balance__c, Current_Balance_When_Payments_Loaded__c,
                       			Date_When_payments_loaded__c 
                       FROM Merchant_Account__c 
                       WHERE id = :merchantRecordId
                       LIMIT 1];
        strTodayDate = DateTime.now().format('MMMM d\',\' yyyy', UserInfo.getTimeZone().toString());
        statementMonth = DateTime.now().addMonths(-1).format('MMMM', UserInfo.getTimeZone().toString());
        getPaymentDetails(merchantRecordId);
    }
    
    public list<Merchant_Account_Payment__c> getPaymentDetails(ID merchantRecordId){
        Date lastDayPreviousMonth = Date.today().toStartOfMonth().addDays(-1);
        Date firstDayPreviousMonth = lastDayPreviousMonth.toStartOfMonth();
        system.debug('firstDayPreviousMonth: '+firstDayPreviousMonth);
        system.debug('lastDayPreviousMonth: '+lastDayPreviousMonth);
		
		//----Calculate the Current Balance value before the first transaction of Statement Month Starts---//
        Double Current_Balance = merchantAcc.Current_Balance_When_Payments_Loaded__c;
		system.debug('Current_Balance from Merchant Account: '+Current_Balance);
		for(Merchant_Account_Payment__c paymentInstance : [SELECT ID, Amount__c 
                                                           FROM Merchant_Account_Payment__c
                                                           WHERE TranDate__c > :merchantAcc.Date_when_payments_loaded__c
                                                           AND TranDate__c < :firstDayPreviousMonth
                                                           AND LeadID__c = :merchantAcc.Id]){
            Current_Balance = Current_Balance - paymentInstance.Amount__c;
        }        
        system.debug('Current_Balance after prev deduction: '+Current_Balance);
        //----Calculate the Current Balance value before the first transaction of Statement Month ENDS---//
        
        //Get Statement Month transactions
        Integer i = 0;
        for(Merchant_Account_Payment__c paymentInstance : [SELECT ID, Amount__c, Processor__c, TranType__c, TranDate__c
                                                           FROM Merchant_Account_Payment__c
                                                           WHERE TranDate__c >= :firstDayPreviousMonth
                                                           AND TranDate__c <= :lastDayPreviousMonth
                                                           AND LeadID__c = :merchantAcc.Id
                                                           ORDER BY TranDate__c ASC,
                                                           Amount__c DESC]){
            //Get Balance Forward as first row
            if(i == 0){
                listPaymentsToDisplay.add(new Merchant_Account_Payment__c(Amount__c = Current_Balance,
                Processor__c = BALANCE_FORWARD, TranType__c = BALANCE_FORWARD,TranDate__c = firstDayPreviousMonth.addDays(-1),
                                                                Current_Balance__c = Current_Balance));
            }
			Current_Balance = Current_Balance - paymentInstance.Amount__c;
			listPaymentsToDisplay.add(new Merchant_Account_Payment__c(Amount__c = paymentInstance.Amount__c,
                Processor__c = paymentInstance.Processor__c, TranType__c = paymentInstance.TranType__c,
                                                                           TranDate__c = paymentInstance.TranDate__c,
                                                                		   Current_Balance__c = Current_Balance)); 
			
			totalDue = Current_Balance;
            //listPaymentsToDisplay.add(merchantAccountPayment);  
            i++;            
        }
		system.debug('listPaymentsToDisplay: '+listPaymentsToDisplay.size());
        //Check if Payments List is empty, display Balance Forward and Total Due
        if(listPaymentsToDisplay.isEmpty()){
            //if no transactions made for the statement month, get the Balance Forward calculated based on
            //payment amount from previous month 
            for(Merchant_Account_Payment__c merchantAccountPayment : [SELECT ID, Amount__c, TranDate__c, TranType__c,
                                                                 	  Processor__c,Current_Balance__c, Previous_Balance__c,
                                                                      leadId__r.Current_Balance__c
                                                                 	  FROM Merchant_Account_Payment__c
                                                                 	  WHERE leadId__c= :merchantRecordId
                                                                 	  AND TranDate__c <= :firstDayPreviousMonth
                                                                      ORDER BY TranDate__c DESC
                                                                      LIMIT 1]){
				if(merchantAccountPayment.Current_Balance__c == NULL){
					listPaymentsToDisplay.add(new Merchant_Account_Payment__c(Amount__c = merchantAccountPayment.leadId__r.Current_Balance__c,
                	Processor__c = BALANCE_FORWARD, TranType__c = BALANCE_FORWARD,TranDate__c = firstDayPreviousMonth.addDays(-1),
                                                                Current_Balance__c = merchantAccountPayment.leadId__r.Current_Balance__c));                                        
                }
				else{
                    listPaymentsToDisplay.add(new Merchant_Account_Payment__c(Amount__c = merchantAccountPayment.Current_Balance__c,
                	Processor__c = BALANCE_FORWARD, TranType__c = BALANCE_FORWARD,TranDate__c = firstDayPreviousMonth.addDays(-1),
                                                                Current_Balance__c = merchantAccountPayment.Current_Balance__c));                                       
                }
				//totalDue will be set to Current Balance if no new transactions are made 
				totalDue = merchantAccountPayment.Current_Balance__c;
				
			}
        }
        
        return listPaymentsToDisplay;
    }
}