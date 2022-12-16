/**************************************************************************************************
 *
 *  Class:   Batch clas to update Merchant Account Payment fields
 *  @description : 
 *  @author : A5E Consulting
 *  @date : 31/03/2021
 
 *************************************************************************************************/
global class MerchantAccountPaymentUpdatesBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT tranDate__c, amount__c, Current_CAD__c, Previous_CAD__c,Previous_Balance__c,Current_Balance__c,leadId__c, leadId__r.Current_Balance__c,leadId__r.Last_Payment_Date__c,leadId__r.Last_Pay_Amount__c,'+
            ' leadId__r.Collective_Cash_Collections_CAD__c FROM Merchant_Account_payment__c'+
            ' WHERE CreatedDate = Today AND Payment_Processed__c = false ORDER BY tranDate__c ASC'
            ); 
    }
    
    global void execute(Database.BatchableContext bc, List<Merchant_Account_Payment__c> listMerchantAccountPayments){ 
        map<ID, Decimal> merchantAccountBalanceMap = new map<ID, Decimal>();
        map<ID, Decimal> merchantAccountCADMap = new map<ID, Decimal>();
        map<ID, Merchant_Account__c> mapIDMerchantAccounts= new map<ID, Merchant_Account__c>();
        Merchant_Account__c merchantAccountInstance;
        system.debug('listMerchantAccountPayments: '+listMerchantAccountPayments);
        list<Merchant_Account_Payment__c> listMerchantAccountPaymentToUpdate = new list<Merchant_Account_Payment__c>();
        for(Merchant_Account_payment__c paymentInstance : listMerchantAccountPayments){
             merchantAccountInstance = new Merchant_Account__c(Last_Payment_Date__c = paymentInstance.tranDate__c,
                                                              Current_Balance__c = paymentInstance.leadId__r.Current_Balance__c,
                                                              Collective_Cash_Collections_CAD__c = paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c);
            //mapIdMerchantAccounts.put(paymentInstance.leadId__c, merchantAccountInstance);
            system.debug('paymentInstance.leadID__c'+paymentInstance.leadID__c);                                                
            
            //Check if map contains MerchantAccount ID
            if(!mapIdMerchantAccounts.containsKey(paymentInstance.leadID__c)){
                //Calculate Collective Cash Collections CAD on Merchant Account 29.03.21
                //update last payment details of Last Payment Date is less than transaction date
                if(paymentInstance.leadId__r.Last_Payment_Date__c <= paymentInstance.TranDate__c
                && paymentInstance.amount__c > 0){
                    mapIdMerchantAccounts.put(paymentInstance.leadID__c, 
                    new Merchant_Account__c(Id=paymentInstance.leadID__c,
                        Last_Payment_Date__c = paymentInstance.tranDate__c,
                        Last_Pay_Amount__c = paymentInstance.amount__c,
                        Current_Balance__c = 
                        paymentInstance.leadId__r.Current_Balance__c != NULL ? 
                        paymentInstance.leadId__r.Current_Balance__c - paymentInstance.amount__c : 
                        0,
                        Collective_Cash_Collections_CAD__c = 
                        paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c != NULL ? 
                        paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c + paymentInstance.amount__c : 
                        0));    
                }
                else{
                    mapIdMerchantAccounts.put(paymentInstance.leadID__c, 
                    new Merchant_Account__c(Id=paymentInstance.leadID__c,
                        Last_Payment_Date__c = paymentInstance.leadId__r.Last_Payment_Date__c,
                        Last_Pay_Amount__c = paymentInstance.leadId__r.Last_Pay_Amount__c,
                        Current_Balance__c = 
                        paymentInstance.leadId__r.Current_Balance__c != NULL ? 
                        paymentInstance.leadId__r.Current_Balance__c - paymentInstance.amount__c : 
                        0,
                        Collective_Cash_Collections_CAD__c = 
                        paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c != NULL ? 
                        paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c + paymentInstance.amount__c : 
                        0));
                }
            }
            else{
                system.debug('already present');
                //update last payment details if previous Transaction date in sheet is less than new transaction date
                if(mapIdMerchantAccounts.get(paymentInstance.leadId__c).Last_Payment_Date__c <= paymentInstance.TranDate__c
                && paymentInstance.amount__c > 0){
                    system.debug('lesser date');
                    system.debug('map value: '+mapIdMerchantAccounts.get(paymentInstance.leadId__c).Last_Payment_Date__c);
                    system.debug('paymentInstance.TranDate__c:'+paymentInstance.TranDate__c);
                    mapIdMerchantAccounts.put(paymentInstance.leadID__c, 
                    new Merchant_Account__c(Id=paymentInstance.leadID__c,
                        Last_Payment_Date__c = paymentInstance.tranDate__c,
                        Last_Pay_Amount__c = paymentInstance.amount__c,
                        Current_Balance__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Current_Balance__c - paymentInstance.amount__c,
                        Collective_Cash_Collections_CAD__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Collective_Cash_Collections_CAD__c + paymentInstance.amount__c));   
                }
                else{
                    system.debug('greater date');
                    system.debug('map value: '+mapIdMerchantAccounts.get(paymentInstance.leadId__c).Last_Payment_Date__c);
                    system.debug('lesser date'+paymentInstance.TranDate__c);
                    mapIdMerchantAccounts.put(paymentInstance.leadID__c, 
                    new Merchant_Account__c(Id=paymentInstance.leadID__c,
                        Last_Payment_Date__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Last_Payment_Date__c,
                        Last_Pay_Amount__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Last_Pay_Amount__c,
                        Current_Balance__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Current_Balance__c - paymentInstance.amount__c,
                        Collective_Cash_Collections_CAD__c = mapIdMerchantAccounts.get(paymentInstance.leadId__c).Collective_Cash_Collections_CAD__c + paymentInstance.amount__c));   
                }                                                      
            }
            
            system.debug('merchantAccountBalanceMap first: '+merchantAccountBalanceMap);
            //Calculate Balance amounts on Merchant Account Payment
            if(!merchantAccountBalanceMap.containsKey(paymentInstance.leadId__c)){
                system.debug('not contains');
                merchantAccountBalanceMap.put(paymentInstance.leadId__c,paymentInstance.leadId__r.Current_Balance__c);
            }
            if(merchantAccountBalanceMap.containsKey(paymentInstance.leadId__c)){
                system.debug('contains');
                paymentInstance.Previous_Balance__c = merchantAccountBalanceMap.get(paymentInstance.leadId__c);
                paymentInstance.Current_Balance__c = paymentInstance.Previous_Balance__c - paymentInstance.amount__c;
                merchantAccountBalanceMap.put(paymentInstance.leadId__c,paymentInstance.Current_Balance__c);    
            }                                              
            
            if(!merchantAccountCADMap.containsKey(paymentInstance.leadId__c)){
                system.debug('not contains CAD');
                merchantAccountCADMap.put(paymentInstance.leadId__c,paymentInstance.leadId__r.Collective_Cash_Collections_CAD__c);
            }
            //Calculate Collection CAD amounts on Merchant Account Payment
            if(merchantAccountCADMap.containsKey(paymentInstance.leadId__c)){
                system.debug('contains CAD');
                system.debug('merchantAccountCADMap.get(paymentInstance.leadId__c):'+merchantAccountCADMap.get(paymentInstance.leadId__c));
                paymentInstance.Previous_CAD__c = merchantAccountCADMap.get(paymentInstance.leadId__c);
                system.debug('paymentInstance.Current_CAD__c:'+paymentInstance.Current_CAD__c);
                system.debug('paymentInstance.Previous_CAD__c:'+paymentInstance.Previous_CAD__c);
                paymentInstance.Current_CAD__c = paymentInstance.Previous_CAD__c + paymentInstance.amount__c;
                merchantAccountCADMap.put(paymentInstance.leadId__c,paymentInstance.Current_CAD__c);    
            }
            //Set Payment Processed checkbox to true
            paymentInstance.Payment_Processed__c = true;
            system.debug('paymentInstance: '+paymentInstance);
            listMerchantAccountPaymentToUpdate.add(paymentInstance);
        }
        
        update mapIdMerchantAccounts.values();
        update listMerchantAccountPaymentToUpdate;
    }
    
    global void finish(Database.BatchableContext bc){
        //Call batch to update Max Deliquency Days on Merchant Accounts
        Database.executeBatch(new MerchantAccountUpdatesBatch(), 200);
    }
}