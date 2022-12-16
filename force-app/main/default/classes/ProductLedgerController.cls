/**************************************************************************************************
*
*  Class:   
*
*  @description : This is the apex class for Product Ledger
*  @author : A5E Consulting
*  @date : 06/06/2022

*************************************************************************************************/
public class ProductLedgerController {
    
    public list<productLedgerWrapper> listProductLedgerToPassWrapper;
    public map<String, productLedgerWrapper> mapProductPaymentLedger {get;set;} 
    public map<String, list<productLedgerWrapper>> mapProductPaymentLedgerList {get;set;} 
    public map<String, productLedgerWrapper> mapReversalProductPaymentLedger {get;set;} 
    //public map<String, productInterestWrapper> mapInterestAdjustmentWrapper {get;set;}
    public map<Date, productLedgerWrapper> mapDateLedger; 
    public map<String, productLedgerWrapper> mapDateLedger2 {get;set;}
    public map<String, productLedgerWrapper> mapJudgmentAdjust {get;set;}
    public map<String, list<productLedgerWrapper>> mapDateWrapperList {get;set;}
    
    public list <String> listStringDates {get;set;}
    public list<String> listDateToIterate;
    public list<Date> listDates; 
    set<String> setDatesToIterate;
    
    public Product__c productInstance {get;set;}
    public Product_Payments__c productPay;
    
    public decimal currentFeesDue {get;set;}
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public blob blobcontents {get;set;}
    
    public string ledgerKeys {get;set;}
    public string paymentKeys {get;set;}
    public string adjustmentKeys {get;set;}
    public string reversalKeys {get;set;}
    public string customerAddress {get;set;}
    public string judgmentKey {get;set;}
    string productID ;
    
    
    public ProductLedgerController(ApexPages.StandardController stdController){
        productID = ApexPages.CurrentPage().getParameters().get('Id');  
        startDate = System.Today()-30;	
        endDate = system.Today();
        mapProductPaymentLedger = new map<String, productLedgerWrapper>();
        mapReversalProductPaymentLedger = new map<String, productLedgerWrapper>();
        mapDateLedger = new map<Date, productLedgerWrapper>();
        system.debug('mapDateLedger initialised');
        mapDateLedger2 = new map<String, productLedgerWrapper>();
        mapJudgmentAdjust = new map<String, productLedgerWrapper>();
        //mapInterestAdjustmentWrapper = new map<String, productInterestWrapper>();
        mapProductPaymentLedgerList = new map<String, list<productLedgerWrapper>>();
            
        listDates = new list<Date>();
        listDateToIterate = new list<String>();
        setDatesToIterate = new set<String>();
        ledgerKeys = '';
        paymentkeys = '';
        reversalKeys = '';
        judgmentKey = '';
        productInstance = [Select id,Name,Customer__r.Name,Address_Line1__c,Address_Line2__c,Previous_Interest_rate__c, Judgment_rate__c,
                                   City__c,State__c,Zip_Code__c,Country__c,Current_Principal_Balance__c,Previous_Principal_Balance__c,
                                   Current_Interest_Amount__c,Current_Bal_Attorney_Fees__c,Current_Bal_Court_Fees__c,
                                   Current_Bal_General_Fees__c,Current_Bal_NSF_Fees__c,Current_Bal_Other_Fees__c,Current_Balance__c,
                           		   Recoverable_Fee__c, Non_Recoverable_Fee__c, Fee_Recovery__c, Interest_Waived_Off__c, Interest_Waived_Off_Start_Date__c,
                           	       Interest_Waived_Of_End_Date__c
                                   from Product__c where id =:productID];
        
        productPay = new Product_payments__c();
        productPay.Payment_Posting_Date__c = Date.today().addMonths(-1);
        
        
        if(productInstance.Current_Bal_NSF_Fees__c == NULL){
            productInstance.Current_Bal_NSF_Fees__c = 0;
        }
        if(productInstance.Address_Line1__c != null){
            customerAddress = productInstance.Address_Line1__c;
        }
        if(String.isnotblank(productInstance.Address_Line2__c)){
            customerAddress += ' '+productInstance.Address_Line2__c;
        }
        if(productInstance.City__c != null ){
            customerAddress += ' '+productInstance.City__c;
        }
        if(productInstance.State__c != null ){
            customerAddress = ' '+productInstance.State__c;
        }
        if(productInstance.Zip_Code__c != null ){
            customerAddress +=' '+productInstance.Zip_Code__c;
        }
        if(productInstance.Country__c != null ){
            customerAddress +=' '+productInstance.Country__c;
        }
    }
    
    public pagereference getData(){
        listProductLedgerToPassWrapper = new list<productLedgerWrapper>();
        mapDateLedger = new map<Date, productLedgerWrapper>();
         mapProductPaymentLedgerList = new map<String, list<productLedgerWrapper>>();
        mapDateLedger2 = new map<String, productLedgerWrapper>();
        listDates = new list<Date>();
        listDateToIterate = new list<String>();
        setDatesToIterate = new set<String>();
        ledgerKeys = '';
        paymentkeys = '';
        reversalKeys = '';
        if(endDate != NULL && endDate > Date.today()){
        	    
        }
        system.debug('startDate ::'+startDate);
        system.debug('endDate ::'+endDate);
        map<ID, Product__c> mapProductsToReverseBalances = new map<ID, Product__c>();
        
        map<Date, Decimal> mapDateInterestAccrued = new map<Date, Decimal>();
        map<Date, Decimal> mapDatePrincipalAmount = new map<Date, Decimal>();
        map<Date, Decimal> mapDateCurrentBalanceAmount = new map<Date, Decimal>();
        //list<Date> listDates = new list<Date>();
        set<Date> setDates = new set<Date>();
        
        Decimal InterestAccrualAtStartOfTheMonth = null;
        Decimal PrincipalAtStartOfTheMonth = null;
        
        list<Product__History> listProductHistoryBeforeMonthStart = [SELECT ParentId, OldValue, NewValue, Field
                                               FROM Product__History
                                               WHERE ParentId = :productID
                                               AND (Field= :'Interest_Accrued_for_the_Day__c')
                                               AND CreatedDate <= :startDate
                                               ORDER BY CreatedDate DESC
                                               LIMIT 1];
        if(!listProductHistoryBeforeMonthStart.isEmpty()){
            InterestAccrualAtStartOfTheMonth = Double.valueOf(listProductHistoryBeforeMonthStart[0].NewValue);
        }
        system.debug('InterestAccrualAtStartOfTheMonth::'+InterestAccrualAtStartOfTheMonth);
        
        list<Product__History> listProductHistoryPrincipalBeforeMonthStart = [SELECT ParentId, OldValue, NewValue, Field
                                               FROM Product__History
                                               WHERE ParentId = :productID
                                               AND (Field= :'Current_Principal_Balance__c')
                                               AND CreatedDate <= :startDate
                                               ORDER BY CreatedDate DESC
                                               LIMIT 1];
        if(!listProductHistoryPrincipalBeforeMonthStart.isEmpty()){
            PrincipalAtStartOfTheMonth = Double.valueOf(listProductHistoryPrincipalBeforeMonthStart[0].NewValue);
        }
        
        Date createdDate;
        system.debug('startDate:::'+startDate);
        system.debug('endDate::'+endDate);
        //endDate = endDate.addDays(1);
        Date endDate1 = endDate.addDays(2);
        listStringDates = new list<String>();
        
        if(productInstance.Previous_interest_rate__c != NULL)
        //map for Date and Interest accrued for the day
        for(Product__History productHistory : [SELECT ParentId, OldValue, NewValue, Field,CreatedDate
                                               FROM Product__History
                                               WHERE ParentId = :productID
                                               AND (Field= :'Current_Principal_Balance__c'
                                                 OR Field= :'Current_Balance__c')
                                               AND CreatedDate >= :startDate
                                               AND CreatedDate <= :endDate1
                                               ORDER BY CreatedDate DESC]){
            //createdDate = Date.valueOf(productHistory.CreatedDate);
            system.debug('CreatedDate::'+productHistory.CreatedDate);
            system.debug('productHistory.Field'+productHistory.Field);
			createdDate = Date.valueOf(productHistory.CreatedDate);
            system.debug('createdDate::::'+createdDate);
			
			if(productHistory.Field == 'Current_Principal_Balance__c'){
                mapDatePrincipalAmount.put(createdDate, Double.valueOf(productHistory.NewValue));
                system.debug('mapDatePrincipalAmount ::'+createdDate +'>'+mapDatePrincipalAmount.get(createdDate));
            }
                                                   
			if(productHistory.Field == 'Current_Balance__c'){
                mapDateCurrentBalanceAmount.put(createdDate, Double.valueOf(productHistory.NewValue));
                system.debug('mapDateCurrentBalanceAmount ::'+createdDate +'>'+mapDateCurrentBalanceAmount.get(createdDate));
            }
        }
        
        map<String, String> mapInterestLastUpdatedCreatedDate = new map<String, String>();
        Decimal TotalBalance = 0;
        Decimal OpeningInterest = 0;
        Date AdjustedDateForJudgment;
        system.debug('startDate before query::'+startDate);
        list<Product__History> listProductHistory = [SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate 
                                                     FROM Product__History
                                                     WHERE ParentId = :productID
                                                     AND (Field= :'Interest_Accrued_for_the_Day__c'
                                                          OR Field= :'Current_Interest_Amount__c'
                                                          OR Field= :'Current_Principal_Balance__c'
                                                          OR Field= :'Current_Balance__c'
                                                          OR Field= :'Interest_Amount_Last_Calculated_Date__c'
                                                          OR Field= :'Previous_interest_Rate__c'
                                                         )
                                                     AND CreatedDate >= :startDate
                                                     AND CreatedDate <= :endDate1
                                                     ORDER BY CreatedDate ASC];
        
        //map for Date and Interest accrued for the day
        for(Product__History productHistory : listProductHistory){
            //createdDate = Date.valueOf(productHistory.CreatedDate);
            system.debug('CreatedDate::'+productHistory.CreatedDate);
            system.debug('productHistory.Field'+productHistory.Field);
            if(productHistory.Field == 'Interest_Amount_Last_Calculated_Date__c'){
                system.debug('old date::'+productHistory.OldValue);
                system.debug('new date::'+Date.valueOf(productHistory.NewValue));
                
                createdDate = Date.valueOf(productHistory.NewValue);
                if(Test.isRunningTest()){
                    createdDate = Date.Today();
                }
                system.debug('createdDate::::'+createdDate);
                if(!setDates.contains(createdDate)){
                    //using list to keep dates in sorted order
                    system.debug('createdDate in set add:'+createdDate);
                    listDates.add(createdDate);
                    system.debug('startdate in set add:'+startdate);
                    if(createdDate != NULL && createdDate>= startdate){
                    	listStringDates.add(String.valueOf(createdDate.format()));    
                    }
                    system.debug('adding to list::'+createdDate);
                    //using set to check that list doesnt get dupliacte data of date
                    setDates.add(createdDate);
            	}
                //mapDateInterestAccrued.put(createdDate, Double.valueOf(productHistory.NewValue));
                //system.debug('mapDateInterestAccrued ::'+createdDate +'>'+mapDateInterestAccrued.get(createdDate));
            }
            
            if(productHistory.Field == 'Interest_Accrued_for_the_Day__c'){
                mapDateInterestAccrued.put(createdDate, Double.valueOf(productHistory.NewValue));
                system.debug('mapDateInterestAccrued ::'+createdDate +'>'+mapDateInterestAccrued.get(createdDate));
            }
            
            if(productHistory.Field == 'Current_Principal_Balance__c'){
                system.debug('pppp>'+productHistory.OldValue + '>>>'+productHistory.NewValue);
                if(PrincipalAtStartOfTheMonth == NULL){
                    PrincipalAtStartOfTheMonth = Double.valueOf(productHistory.OldValue);
                }
                //mapDatePrincipalAmount.put(createdDate, Double.valueOf(productHistory.OldValue));
                //system.debug('mapDatePrincipalAmount ::'+createdDate +'>'+mapDatePrincipalAmount.get(createdDate));
            }
            
            
            if(productHistory.Field == 'Current_Interest_Amount__c'){
                if(OpeningInterest == 0){
                	OpeningInterest = Double.valueOf(productHistory.OldValue);
                    if(OpeningInterest != NULL){
                    	OpeningInterest = OpeningInterest.setScale(2);    
                    }
                    
                }
                system.debug('Interest Balance check::'+productHistory.CreatedDate + '::'+productHistory.OldValue + '::'+productHistory.NewValue);
            }
            
            if(productHistory.Field == 'Current_Balance__c'){
                system.debug('TotalBalance::::'+TotalBalance);
                if(TotalBalance == 0){
                	TotalBalance = Double.valueOf(productHistory.OldValue); 
                    if(TotalBalance != NULL){
                    	TotalBalance = TotalBalance.setScale(2);    
                    }
                }
                system.debug('Interest Balance check::'+productHistory.CreatedDate + '::'+productHistory.OldValue + '::'+productHistory.NewValue);
            }
            
            if(productHistory.Field == 'Previous_Interest_Rate__c'){
                AdjustedDateForJudgment = Date.valueOf(productHistory.CreatedDate);
                
                if(!setDates.contains(AdjustedDateForJudgment)){
                    //using list to keep dates in sorted order
                    listDates.add(AdjustedDateForJudgment);
                    if(AdjustedDateForJudgment != NULL){
                    	listStringDates.add(String.valueOf(AdjustedDateForJudgment.format()));    
                    }
                    system.debug('adding to list::'+AdjustedDateForJudgment);
                    //using set to check that list doesnt get dupliacte data of date
                    setDates.add(AdjustedDateForJudgment);
            	}
            }
        }
        
        system.debug('listDates::'+listDates);
        Decimal InterestAccrual = null;
        //set starting Interest accrual for the month
        if(mapDateInterestAccrued.containsKey(startDate)){
            InterestAccrual = mapDateInterestAccrued.get(startDate);
        }
        else{
            InterestAccrual = InterestAccrualAtStartOfTheMonth;
        }
        
        Decimal PrincipalAmount = null;
        system.debug('PrincipalAtStartOfTheMonth::'+PrincipalAtStartOfTheMonth);
        //set starting Interest accrual for the month
        if(mapDatePrincipalAmount.containsKey(startDate)){
            PrincipalAmount = mapDatePrincipalAmount.get(startDate);
        }
        else{
            PrincipalAmount = PrincipalAtStartOfTheMonth;
        }
        
        if(PrincipalAmount == null){
            PrincipalAmount = productInstance.Current_Principal_Balance__c;
        }
        system.debug('InterestAccrual:: '+InterestAccrual);
		system.debug('PrincipalAmount:: '+PrincipalAmount);
		Decimal adjustedInterestRate = 0;
        Decimal judgmentClosingPrincipal = 0;
        Decimal openingInterestBalance = 0;
        list<Account_Judgment__c> listacc;
        if(AdjustedDateForJudgment != NULL){
            listacc = [SELECT id, Judgment__c, Judgment__r.Judgment_Date__c,Judgment__r.Legal_Status__c,
                                   		 Judgment__r.Product_1__c,Judgment__r.balance_one__c,
                                   		 Judgment__r.Product_2__c,Judgment__r.balance_two__c,
                                   		 Judgment__r.Product_3__c,Judgment__r.balance_three__c,
                                   		 Judgment__r.Product_4__c,Judgment__r.balance_four__c,
                                  		 Judgment__r.Product_5__c,Judgment__r.balance_five__c
                                   FROM Account_Judgment__c 
                                   where Product__c = :productInstance.id];
            if(!listacc.isEmpty() 
               && listacc[0].Judgment__r.Judgment_Date__c != NULL 
               && (listacc[0].Judgment__r.Legal_Status__c == 'Judgment' || listacc[0].Judgment__r.Legal_Status__c == 'Post-Judgment')){
                if(productInstance.Name == listacc[0].Judgment__r.Product_1__c){
                    Decimal NoOfDays =listacc[0].Judgment__r.Judgment_Date__c.daysBetween(AdjustedDateForJudgment);
                    system.debug('AdjustedDateForJudgment::'+AdjustedDateForJudgment);
                    system.debug('acc.Judgment__r.Judgment_Date__c::'+listacc[0].Judgment__r.Judgment_Date__c);
                    system.debug('NoOfDays::'+NoOfDays);
                    system.debug('productInstance.Judgment_Rate__c::'+productInstance.Judgment_Rate__c);
                    adjustedInterestRate = (listacc[0].Judgment__r.balance_one__c * 
                                           (NoOfDays) *
                                           productInstance.Judgment_Rate__c)/100/365;
                    adjustedInterestRate = adjustedInterestRate.setScale(2);
                    judgmentClosingPrincipal = listacc[0].Judgment__r.balance_one__c;
                }
                if(productInstance.Name == listacc[0].Judgment__r.Product_2__c){
                    Decimal NoOfDays =listacc[0].Judgment__r.Judgment_Date__c.daysBetween(AdjustedDateForJudgment);
                    adjustedInterestRate = (listacc[0].Judgment__r.balance_two__c * 
                                           (NoOfDays) *
                                           productInstance.Judgment_Rate__c)/100/365;
                    adjustedInterestRate = adjustedInterestRate.setScale(2);
                    judgmentClosingPrincipal = listacc[0].Judgment__r.balance_two__c;
                }
                if(productInstance.Name == listacc[0].Judgment__r.Product_3__c){
                    Decimal NoOfDays =listacc[0].Judgment__r.Judgment_Date__c.daysBetween(AdjustedDateForJudgment);
                    adjustedInterestRate = (listacc[0].Judgment__r.balance_three__c * 
                                           (NoOfDays) *
                                           productInstance.Judgment_Rate__c)/100/365;
                    adjustedInterestRate = adjustedInterestRate.setScale(2);
                    judgmentClosingPrincipal = listacc[0].Judgment__r.balance_three__c;
                }
                if(productInstance.Name == listacc[0].Judgment__r.Product_4__c){
                    Decimal NoOfDays =listacc[0].Judgment__r.Judgment_Date__c.daysBetween(AdjustedDateForJudgment);
                    adjustedInterestRate = (listacc[0].Judgment__r.balance_four__c * 
                                           (NoOfDays) *
                                           productInstance.Judgment_Rate__c)/100/365;
                    adjustedInterestRate = adjustedInterestRate.setScale(2);
                    judgmentClosingPrincipal = listacc[0].Judgment__r.balance_four__c;
                }
                if(productInstance.Name == listacc[0].Judgment__r.Product_5__c){
                    Decimal NoOfDays =listacc[0].Judgment__r.Judgment_Date__c.daysBetween(AdjustedDateForJudgment);
                    adjustedInterestRate = (listacc[0].Judgment__r.balance_five__c * 
                                           (NoOfDays) *
                                           productInstance.Judgment_Rate__c)/100/365;
                    adjustedInterestRate = adjustedInterestRate.setScale(2);
                    judgmentClosingPrincipal = listacc[0].Judgment__r.balance_five__c;
                }
            }
        }
        
        map<String, Decimal> mapStringPrincipalAmount = new map<String, Decimal>();
        for(Date dateInstance : listDates){
            //if there is interest accrual in the map,for the date, get it in the variable
            if(mapDateInterestAccrued.containsKey(dateInstance)){
                InterestAccrual = mapDateInterestAccrued.get(dateInstance);
                system.debug('InterestAccrual inside if::'+dateInstance + '::' +InterestAccrual);        
            }
            //if there is no interest accrual in history for the date, put the the date and previous Interest accrual value in the map
            //since Interest accrual is same as previous day
            else{
                mapDateInterestAccrued.put(dateInstance, InterestAccrual);
                system.debug('check date::'+ dateInstance + '>>'+InterestAccrual);
            }
            //if there is principal update in the map,for the date, get it in the variable
            if(mapDatePrincipalAmount.containsKey(dateInstance)){
                PrincipalAmount = mapDatePrincipalAmount.get(dateInstance);
                system.debug('PrincipalAmount inside if::'+PrincipalAmount);
                mapStringPrincipalAmount.put(dateInstance.format(), PrincipalAmount);
                system.debug('principal mapping::'+dateInstance.format() + '>>'+PrincipalAmount);
            }
            //if there is no principal update in history for the date, put the the date and previous principal value in the map
            //since principal is same as previous day
            else{
                mapDatePrincipalAmount.put(dateInstance, PrincipalAmount);
                system.debug('principal check::'+dateInstance + ':'+PrincipalAmount);
                mapStringPrincipalAmount.put(dateInstance.format(), PrincipalAmount);
            }
        }
        system.debug('mapDatePrincipalAmount::'+mapDatePrincipalAmount);
        system.debug('mapDateInterestAccrued::'+mapDateInterestAccrued);
        map<String, Decimal> mapStringDecimal = new map<String, Decimal>();
        
        for(Date ss : mapDateInterestAccrued.keySet()){
            system.debug('mapDateInterestAccrued::::'+ss + '::'+mapDateInterestAccrued.get(ss));
            mapStringDecimal.put(String.valueOf(ss.format()), mapDateInterestAccrued.get(ss));
        }
        system.debug('mapDateLedger:::'+mapDateLedger);
        for(Product__History productHistory : listProductHistory){
            //productHistory.CreatedDate = productHistory.CreatedDate.addhours(-8);
			createdDate = Date.valueOf(productHistory.CreatedDate.addhours(-8));
			system.debug('mapDateInterestAccrued.containsKey(createdDate)::'+createdDate + '::'+mapDateInterestAccrued.containsKey(createdDate));
            
            if(productHistory.Field == 'Current_Interest_Amount__c'){
                Double NewValue = Double.valueOf(productHistory.NewValue);
                Double OldValue = Double.valueOf(productHistory.OldValue);
                system.debug('OldValue::'+productHistory.Field + ':' + OldValue);
                system.debug('NewValue::'+productHistory.Field + ':'+NewValue);
                Decimal roundOff = 0;
                if(NewValue != NULL){
                	roundOff = Decimal.valueOf(NewValue).setScale(2);      
                }
                system.debug('adjustedInterestRate:::'+adjustedInterestRate + '>>>'+NewValue);
                if(roundOff == adjustedInterestRate){
                    openingInterestBalance = OldValue;
                }
            }
            if(productHistory.Field == 'Current_Interest_Amount__c'
            && mapDateInterestAccrued.containsKey(createdDate)){
                //check if the interest change is equalling the interest accrual for the day from mapDateInterestAccrued
                Double NewValue = Double.valueOf(productHistory.NewValue);
                Double OldValue = Double.valueOf(productHistory.OldValue);
                system.debug('OldValue::'+productHistory.Field + ':' + OldValue);
                system.debug('NewValue::'+productHistory.Field + ':'+NewValue);
                
                Decimal roundOff = 0;
                if(NewValue != NULL && OldValue != NULL){
                	if(NewValue > OldValue){
                        roundOff = Decimal.valueOf(NewValue - OldValue).setScale(2);  
                        system.debug('roundOff1::'+roundOff);
                    }
                    else{
                        roundOff = Decimal.valueOf(OldValue - NewValue).setScale(2);
                        system.debug('roundOff2::'+roundOff);
                    }
                }
                
                system.debug('roundOff::'+roundOff);
                system.debug('mapDateInterestAccrued.get(createdDate)::'+mapDateInterestAccrued.get(createdDate));
                if((roundOff) == mapDateInterestAccrued.get(createdDate)){
                    system.debug('old value inside first::'+OldValue + '>>'+NewValue);
                    system.debug('mapDateLedger value--'+mapDateLedger );
                    system.debug('createdDate value--'+createdDate );
                    if(!mapDateLedger.containsKey(createdDate)){
                        system.debug('inside interest field history first');
                        system.debug('createdDate in interest check'+createdDate);
                        productLedgerWrapper wrapperInstance = new productLedgerWrapper();
						wrapperInstance.openingInterestAmt = Decimal.valueOf(OldValue).setScale(2);
                       	wrapperInstance.balInterest = Decimal.valueOf(NewValue).setScale(2);
                        wrapperInstance.interestDebit = mapDateInterestAccrued.get(createdDate);
                        wrapperInstance.openingPrincpalAmt = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        wrapperInstance.balPrincipal = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        system.debug('balPrincipal::'+createdDate + '::' +wrapperInstance.balPrincipal);
                        wrapperInstance.transactionType = 'Interest Accrual';
                        wrapperInstance.createdDates = String.valueOf(createdDate.format());
                        mapDateLedger.put(createdDate, wrapperInstance);
                        mapDateLedger2.put(wrapperInstance.createdDates, wrapperInstance);
                        system.debug('wrapperInstance.createdDates mapDateLedger2::'+wrapperInstance.createdDates);
                        
                        if(!setDatesToIterate.contains(wrapperInstance.createdDates)){
                            //using list to keep dates in sorted order
                            listDateToIterate.add(wrapperInstance.createdDates);
                            //using set to check that list doesnt get dupliacte data of date
                            setDatesToIterate.add(wrapperInstance.createdDates);
                            ledgerKeys += wrapperInstance.createdDates;
                        }
                    }
                    
                    else{
                        system.debug('old value inside second::'+OldValue + '>>'+NewValue);
                        system.debug('inside interest field history second');
                        productLedgerWrapper wrapperInstance = mapDateLedger.get(createdDate);
						wrapperInstance.openingInterestAmt = Decimal.valueOf(OldValue).setScale(2);
                       	wrapperInstance.balInterest = Decimal.valueOf(NewValue).setScale(2);
                        wrapperInstance.interestDebit = mapDateInterestAccrued.get(createdDate).setScale(2);
                        mapDateLedger.put(createdDate, wrapperInstance);
                        mapDateLedger2.put(wrapperInstance.createdDates, wrapperInstance);
						system.debug('wrapperInstance.createdDates mapDateLedger2::'+wrapperInstance.createdDates);
                    }
                }
            }
			if(productHistory.Field == 'Current_Balance__c'
            && mapDateInterestAccrued.containsKey(createdDate)){
                //check if the interest change is equalling the interest accrual for the day from mapDateInterestAccrued
                Double NewValue = Double.valueOf(productHistory.NewValue);
                Double OldValue = Double.valueOf(productHistory.OldValue);
                system.debug('OldValue::'+OldValue);
                system.debug('NewValue::'+NewValue);
                Decimal roundOff = 0;
                if(NewValue != NULL && OldValue != NULL){
                    roundOff = Decimal.valueOf(NewValue - OldValue).setScale(2);
                }
                system.debug('roundOff:'+roundOff);
                system.debug('mapDateInterestAccrued.get(createdDate)::'+mapDateInterestAccrued.get(createdDate));
                if((roundOff) == mapDateInterestAccrued.get(createdDate)){
                    if(!mapDateLedger.containsKey(createdDate)){
                        system.debug('inside interest field history first');
                        system.debug('createdDate in current balance check:'+createdDate);
                        productLedgerWrapper wrapperInstance = new productLedgerWrapper();
                        wrapperInstance.interestDebit = mapDateInterestAccrued.get(createdDate);
                        wrapperInstance.transactionType = 'Interest Accrual';
                        wrapperInstance.createdDates = String.valueOf(createdDate.format());
                        wrapperInstance.balTotal = Decimal.valueOf(NewValue).setScale(2);
                        wrapperInstance.openingPrincpalAmt = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        wrapperInstance.balPrincipal = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        mapDateLedger.put(createdDate, wrapperInstance);
                        mapDateLedger2.put(wrapperInstance.createdDates, wrapperInstance);
                    	
                        if(!setDatesToIterate.contains(wrapperInstance.createdDates)){
                            //using list to keep dates in sorted order
                            listDateToIterate.add(wrapperInstance.createdDates);
                            //using set to check that list doesnt get dupliacte data of date
                            setDatesToIterate.add(wrapperInstance.createdDates);
                            ledgerKeys += wrapperInstance.createdDates;
                        }
                    }
                    else{
                        system.debug('inside current balance field history second');
                        productLedgerWrapper wrapperInstance = mapDateLedger.get(createdDate);
						wrapperInstance.createdDates = String.valueOf(createdDate.format());
                        wrapperInstance.balTotal = Decimal.valueOf(NewValue).setScale(2);
                        wrapperInstance.openingPrincpalAmt = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        wrapperInstance.balPrincipal = mapDatePrincipalAmount.get(createdDate).setScale(2);
                        mapDateLedger.put(createdDate, wrapperInstance);
                        mapDateLedger2.put(wrapperInstance.createdDates, wrapperInstance);
                    }
                }
            }
		}
       	
        for(String dateInstance : listStringDates){
            Date dateValue = Date.parse(dateInstance);
            system.debug('dateValue::'+dateValue + '>>'+productInstance.Interest_Waived_Off_Start_Date__c + '>>>'+productInstance.Interest_Waived_Of_End_Date__c);
            
            system.debug('1..dateValue innnn+'+dateValue+'>>>>'+dateInstance);  
            system.debug('1..Interest_Waived_Off_Start_Date__c::'+productInstance.Interest_Waived_Off_Start_Date__c);
            system.debug('1..Interest_Waived_Of_End_Date__c::'+productInstance.Interest_Waived_Of_End_Date__c);
            if((productInstance.Interest_Waived_Off__c == TRUE 
            && ((productInstance.Interest_Waived_Off_Start_Date__c <= dateValue 
            && dateValue  <= productInstance.Interest_Waived_Of_End_Date__c)) )
            && mapDateLedger2.containsKey(dateInstance) ){
                mapDateLedger2.remove(dateInstance);
                ledgerKeys = ledgerKeys.remove(dateInstance);
            }
            if((productInstance.Interest_Waived_Off__c == FALSE
                ||(productInstance.Interest_Waived_Off__c == TRUE 
                   && (!(productInstance.Interest_Waived_Off_Start_Date__c <= dateValue 
                   && dateValue  <= productInstance.Interest_Waived_Of_End_Date__c)) ))){
				if(mapDateLedger2.containsKey(dateInstance) 
                && mapStringDecimal.containsKey(dateInstance)){
                    OpeningInterest = mapDateLedger2.get(dateInstance).balInterest;
                    TotalBalance = mapDateLedger2.get(dateInstance).balTotal;
                }
                if(!mapDateLedger2.containsKey(dateInstance) 
                && mapStringDecimal.containsKey(dateInstance)){
                    system.debug('dateInstance in second::'+dateInstance);
                    system.debug('OpeningInterest::'+OpeningInterest);
                    system.debug('TotalBalance::'+TotalBalance);
                    productLedgerWrapper wrapperInstance = new productLedgerWrapper();
                    wrapperInstance.interestDebit = mapStringDecimal.get(dateInstance);
                    wrapperInstance.transactionType = 'Interest Accrual';
                    wrapperInstance.createdDates = dateInstance;
                    wrapperInstance.openingInterestAmt = OpeningInterest;
                    if(OpeningInterest != NULL && wrapperInstance.interestDebit != NULL){
                    	wrapperInstance.balInterest = OpeningInterest + wrapperInstance.interestDebit;    
                    }
                    else{
                        wrapperInstance.balInterest = wrapperInstance.interestDebit;
                    }
                    if(wrapperInstance.interestDebit != NULL){
                    	wrapperInstance.balTotal = TotalBalance + wrapperInstance.interestDebit;    
                    }
                    else{
                        wrapperInstance.balTotal = TotalBalance;
                    }
                    if(dateInstance != NULL && mapStringPrincipalAmount.get(dateInstance) != NULL){
                        system.debug('mapStringPrincipalAmount.get(dateInstance)::'+mapStringPrincipalAmount.get(dateInstance));
                    	wrapperInstance.openingPrincpalAmt = mapStringPrincipalAmount.get(dateInstance).setScale(2);
                    	wrapperInstance.balPrincipal = mapStringPrincipalAmount.get(dateInstance).setScale(2);
                    }
                    mapDateLedger2.put(wrapperInstance.createdDates, wrapperInstance);
                    ledgerKeys += wrapperInstance.createdDates;
                    
                    OpeningInterest = wrapperInstance.balInterest;
                    TotalBalance = wrapperInstance.balTotal;
                    system.debug('wrapperInstance.createdDates'+wrapperInstance.createdDates);                
                }
           	}
        }
        
        
        
        if(AdjustedDateForJudgment != NULL && !listacc.isEmpty()){
            productLedgerWrapper wrapperInstance = new productLedgerWrapper();
            wrapperInstance.interestDebit = adjustedInterestRate;
            wrapperInstance.transactionType = 'Judgment Adjustment';
            wrapperInstance.createdDates = String.valueOf(AdjustedDateForJudgment.format());
            wrapperInstance.openingInterestAmt = openingInterestBalance.setScale(2);
            wrapperInstance.balInterest = adjustedInterestRate;    
            system.debug('productInstance.Previous_Principal_Balance__c::'+productInstance.Previous_Principal_Balance__c);
            wrapperInstance.openingPrincpalAmt = productInstance.Previous_Principal_Balance__c;
            wrapperInstance.balPrincipal = judgmentClosingPrincipal;
            wrapperInstance.balTotal = wrapperInstance.balPrincipal + wrapperInstance.balInterest;
            mapJudgmentAdjust.put(wrapperInstance.createdDates, wrapperInstance);
            judgmentKey = wrapperInstance.createdDates;
        }
        system.debug('mapJudgmentAdjust::'+mapJudgmentAdjust);
        system.debug('mapDateLedger:::'+mapDateLedger);
        adjustmentKeys = '';
        system.debug('startDate in pay::: '+startDate);
        system.debug('endDate1::: '+endDate1);
        system.debug([select id, payment_posting_date__c from Product_Payments__c Where CCS_Account__c =:productID]);
        for(Product_Payments__c prodPayment : [Select id,Name,NSF_Fees_Before_Payment__c,Pay_NSF__c,Attorney_Fees_Before_Payment__c,Pay_Attorney__c,
                                               Other_Fees_Before_Payment__c,Pay_Other__c,
                                               Interest_Payment_Amount__c,Balance_Before_Payment__c,Balance_After_Payment__c,CreatedDate,
                                               Payment_Posting_Date__c,Payment_Type__c,Payment_Amount__c,Post_Pay_Principal__c,Post_Pay_Interest__c,
                                               Transaction_Type__c,Pay_Court__c,Pay_Fees__c,Pre_Pay_Principal__c,Pre_Pay_Interest__c,
                                               Pay_Non_Recoverable_Fee__c,Pay_Recoverable_Fee__c,Principal_Payment_Amount__c,Interest_Adjustment__c
                                               from Product_Payments__c  Where CCS_Account__c =:productID 
                                               and CreatedDate >=: startDate
                                               and CreatedDate  <=: endDate1
                                               ORDER BY CreatedDate ASC NULLS LAST]){
			system.debug('prodPayment.CreatedDate::'+prodPayment.CreatedDate);
            createdDate = Date.valueOf(prodPayment.CreatedDate);
            
			system.debug('createdDate for payment::'+createdDate);
            if(prodPayment.Payment_Amount__c > 0){
            	productLedgerWrapper wrapRecord = new productLedgerWrapper(prodPayment, 'Payment');
            	if(!setDatesToIterate.contains(wrapRecord.createdDates)){
                    setDatesToIterate.add(wrapRecord.createdDates);
                    listDateToIterate.add(wrapRecord.createdDates);
                    listStringDates.add(String.valueOf(createdDate.format()));
                }
                if(mapProductPaymentLedgerList.containsKey(wrapRecord.createdDates)){
					list<productLedgerWrapper> listLedger = mapProductPaymentLedgerList.get(wrapRecord.createdDates);
                   	listLedger.add(wrapRecord);
                    mapProductPaymentLedgerList.put(wrapRecord.createdDates, 
                                                    listLedger);
                }
                else{
                    mapProductPaymentLedgerList.put(wrapRecord.createdDates, new list<productLedgerWrapper>{wrapRecord});
                }
            	paymentKeys +=wrapRecord.createdDates;
                
                if(prodPayment.Interest_Adjustment__c != NULL && prodPayment.Interest_Adjustment__c <> 0){
                    productLedgerWrapper wrapRecordAdjust = new productLedgerWrapper(prodPayment, 'Adjustment');
                    list<productLedgerWrapper> listAdjustment = mapProductPaymentLedgerList.get(wrapRecordAdjust.createdDates);
                    listAdjustment.add(wrapRecordAdjust);
                    if(mapProductPaymentLedgerList.containsKey(wrapRecordAdjust.createdDates)){
                        mapProductPaymentLedgerList.put(wrapRecordAdjust.createdDates, 
                                                        listAdjustment);
                    }
                    else{
                        mapProductPaymentLedgerList.put(wrapRecordAdjust.createdDates, new list<productLedgerWrapper>{wrapRecordAdjust});
                    }
                }
            }

			if(prodPayment.Payment_Amount__c < 0){
                productLedgerWrapper wrapRecordReverse = new productLedgerWrapper(prodPayment, 'Reversal');
            	if(!setDatesToIterate.contains(wrapRecordReverse.createdDates)){
                    setDatesToIterate.add(wrapRecordReverse.createdDates);
                    listDateToIterate.add(wrapRecordReverse.createdDates);
                    listStringDates.add(String.valueOf(createdDate.format()));
                }
                paymentKeys +=wrapRecordReverse.createdDates;
                if(mapProductPaymentLedgerList.containsKey(wrapRecordReverse.createdDates)){
                    list<productLedgerWrapper> listReversal = mapProductPaymentLedgerList.get(wrapRecordReverse.createdDates);
                    listReversal.add(wrapRecordReverse);
                    mapProductPaymentLedgerList.put(wrapRecordReverse.createdDates, 
                                                    listReversal);
                }
                else{
                    mapProductPaymentLedgerList.put(wrapRecordReverse.createdDates, new list<productLedgerWrapper>{wrapRecordReverse});
                }
                
                if(prodPayment.Interest_Adjustment__c != NULL && prodPayment.Interest_Adjustment__c <> 0){
                	productLedgerWrapper wrapRecordReverseAdjust = new productLedgerWrapper(prodPayment, 'Adjustment');
                    mapProductPaymentLedger.put(wrapRecordReverseAdjust.createdDates,wrapRecordReverseAdjust);
                    if(mapProductPaymentLedgerList.containsKey(wrapRecordReverseAdjust.createdDates)){
                        list<productLedgerWrapper> listReversalAdjust = mapProductPaymentLedgerList.get(wrapRecordReverseAdjust.createdDates);
                        listReversalAdjust.add(wrapRecordReverseAdjust);
                        mapProductPaymentLedgerList.put(wrapRecordReverseAdjust.createdDates, 
                                                        listReversalAdjust);
                    }
                    else{
                        mapProductPaymentLedgerList.put(wrapRecordReverseAdjust.createdDates, new list<productLedgerWrapper>{wrapRecordReverseAdjust});
                    }    
                }
                
            }
            // listProductLedgerToPassWrapper = new list<productLedgerWrapper>();
            system.debug('prodPayment::'+prodPayment);
        }
        
        listProductLedgerToPassWrapper.addAll(mapDateLedger.values());
       // startDate = null;
       // endDate = null;
        
        system.debug('listProductLedgerToPassWrapper '+listProductLedgerToPassWrapper);
        return null;
    }
    
    /*public pagereference download(){
        PageReference ref = Page.ProductLedgerDownload;
        blobcontents = ref.getContent();        
        system.debug('blobcontents::'+blobcontents);
        return null;
    }*/
    
    /*public class productInterestWrapper{
        public Product_Payments__c prodPayments {get; set;}
        
        public String createdDates{get;set;}
        public String transactionType{get;set;}
        public String transactionCode{get;set;}
        public decimal paymentAmount{get;set;}
        public decimal openingPrincpalAmt{get;set;}
        public decimal openingInterestAmt{get;set;}
        public decimal feesDebit{get;set;}
        public decimal feesCredit{get;set;}
        public decimal principalDebit{get;set;}
        public decimal principalCredit{get;set;}
        public decimal interestDebit{get;set;}
        public decimal interestCredit{get;set;}
        public decimal balPrincipal{get;set;}
        public decimal balInterest{get;set;}
        public decimal balTotal{get;set;}
        
        public productInterestWrapper(Product_Payments__c prodPayment) {
            //if(prodPayment.Payment_Type__c != '1003'){
            Date createdDateValue = Date.valueOf(prodPayment.CreatedDate);
            createdDates = String.valueOf(createdDateValue.format());
            transactionType = 'Interest Adjustment';
            transactionCode = 'Interest Adjustment';
            if(prodpayment.Interest_Adjustment__c != null){
                paymentAmount = prodPayment.Interest_Adjustment__c.setScale(2);
            }
            if(prodpayment.Pre_Pay_Principal__c != null){
                openingPrincpalAmt = prodPayment.Pre_Pay_Principal__c.setScale(2); 
            }
            if(prodpayment.Pre_Pay_Interest__c != null){
                openingInterestAmt = prodPayment.Pre_Pay_Interest__c.setScale(2);  
            }
            feesCredit = 0 ;
            
            if(prodPayment.Principal_Payment_Amount__c != null){
                principalCredit = prodPayment.Principal_Payment_Amount__c.setScale(2);
            }
            if(prodPayment.Interest_Payment_Amount__c != null){
                interestCredit  = prodPayment.Interest_Payment_Amount__c.setScale(2);
            }
            if(prodPayment.Post_Pay_Principal__c != null){
                balPrincipal = prodPayment.Post_Pay_Principal__c.setScale(2);
            }
            
            if(prodPayment.Post_Pay_Interest__c != null){
                balInterest = prodPayment.Post_Pay_Interest__c.setScale(2);
            }
            if(prodPayment.Balance_After_Payment__c != null){
                balTotal = prodPayment.Balance_After_Payment__c.setScale(2);
            }
        } 
    }*/
    
    public class productLedgerWrapper{
        
        public Product_Payments__c prodPayments {get; set;}
        
        public String createdDates{get;set;}
        public String transactionType{get;set;}
        public String transactionCode{get;set;}
        public decimal paymentAmount{get;set;}
        public decimal openingPrincpalAmt{get;set;}
        public decimal openingInterestAmt{get;set;}
        public decimal feesDebit{get;set;}
        public decimal feesCredit{get;set;}
        public decimal principalDebit{get;set;}
        public decimal principalCredit{get;set;}
        public decimal interestDebit{get;set;}
        public decimal interestCredit{get;set;}
        public decimal balPrincipal{get;set;}
        public decimal balInterest{get;set;}
        public decimal balTotal{get;set;}
        
        public productLedgerWrapper(){
            
        }
        public productLedgerWrapper(Product_Payments__c prodPayment, String Type) {
             if(Type == 'Payment'){
                Date createdDateValue = Date.valueOf(prodPayment.CreatedDate);
                transactionType = prodPayment.Transaction_Type__c;
            	createdDates = String.valueOf(createdDateValue.format());
                transactionCode = prodPayment.Payment_Type__c;
                 if(prodpayment.Payment_Amount__c != null){
                     paymentAmount = prodPayment.Payment_Amount__c.setScale(2);
                 }
                 if(prodpayment.Pre_Pay_Principal__c != null){
                     openingPrincpalAmt = prodPayment.Pre_Pay_Principal__c.setScale(2); 
                 }
                 if(prodpayment.Pre_Pay_Interest__c != null){
                     openingInterestAmt = prodPayment.Pre_Pay_Interest__c.setScale(2);  
                 }
                feesCredit = 0 ;
                 if(prodpayment.Pay_Non_Recoverable_Fee__c != null){
                   feesCredit =  prodpayment.Pay_Non_Recoverable_Fee__c.setScale(2);
                     system.debug('feesCredit 1 :: '+feesCredit);
                }
                if(prodpayment.Pay_Recoverable_Fee__c != null){
                   feesCredit +=   prodpayment.Pay_Recoverable_Fee__c.setScale(2);
                    system.debug('feesCredit 2 :: '+feesCredit);
                }
                if(prodpayment.Pay_NSF__c != null){
                   feesCredit +=  Decimal.valueOf(prodpayment.Pay_NSF__c).setScale(2);
                   system.debug('feesCredit 2 :: '+feesCredit);
                }

                 if(prodPayment.Principal_Payment_Amount__c != null){
                    principalCredit = prodPayment.Principal_Payment_Amount__c.setScale(2);
                }
                if(prodPayment.Interest_Payment_Amount__c != null){
                    interestCredit  = prodPayment.Interest_Payment_Amount__c.setScale(2);
                }
                 if(prodPayment.Post_Pay_Principal__c != null){
                     balPrincipal = prodPayment.Post_Pay_Principal__c.setScale(2);
                 }
                
                if(prodPayment.Post_Pay_Interest__c != null){
                    balInterest = prodPayment.Post_Pay_Interest__c.setScale(2);
                }
                if(prodPayment.Balance_After_Payment__c != null){
                    balTotal = prodPayment.Balance_After_Payment__c.setScale(2);
                }
             
               // balTotal = Decimal.valueOf(balPrincipal) + Decimal.valueOf(balInterest);
            }
            else if(Type == 'Reversal'){
                Date createdDateValue = Date.valueOf(prodPayment.CreatedDate);
            	createdDates = String.valueOf(createdDateValue.format());
                system.debug('regular_'+createdDates);
                transactionType = prodPayment.Transaction_Type__c;
                transactionCode = prodPayment.Payment_Type__c;
                if(prodpayment.Payment_Amount__c != null){
                    paymentAmount = prodPayment.Payment_Amount__c.setScale(2);
                }
                if(prodpayment.Pre_Pay_Principal__c != null){
                   openingPrincpalAmt = prodPayment.Pre_Pay_Principal__c.setScale(2); 
                }
                if(prodpayment.Pre_Pay_Interest__c != null){
                    openingInterestAmt = prodPayment.Pre_Pay_Interest__c.setScale(2);  
                }
                
                feesDebit = 0 ;
                if(prodpayment.Pay_Non_Recoverable_Fee__c != null){
                   feesDebit =  prodpayment.Pay_Non_Recoverable_Fee__c.setScale(2);
                   system.debug('feesDebit1::'+feesDebit);
                }
                if(prodpayment.Pay_Recoverable_Fee__c != null){
                   feesDebit +=  prodpayment.Pay_Recoverable_Fee__c.setScale(2);
                	system.debug('feesDebit2::'+feesDebit);
                }
                if(prodpayment.Pay_NSF__c != null){
                    system.debug('prodpayment.Pay_NSF__c::'+prodpayment.Pay_NSF__c);
                   feesDebit +=   Decimal.valueOf(prodpayment.Pay_NSF__c).setScale(2);
                	system.debug('feesDebit3::'+feesDebit);
                }
                system.debug('feesDebit::'+feesDebit);
                  if(prodPayment.Principal_Payment_Amount__c != null){
                    principalDebit = prodPayment.Principal_Payment_Amount__c.setScale(2);
                }
                if(prodPayment.Interest_Payment_Amount__c != null){
                    interestDebit  = prodPayment.Interest_Payment_Amount__c.setScale(2);
                }
                 if(prodPayment.Post_Pay_Principal__c != null){
                     balPrincipal = prodPayment.Post_Pay_Principal__c.setScale(2);
                 }
                if(prodPayment.Post_Pay_Interest__c != null){
                    balInterest = prodPayment.Post_Pay_Interest__c.setScale(2);
                }
                if(prodPayment.Balance_After_Payment__c != null){
                    balTotal = prodPayment.Balance_After_Payment__c.setScale(2);
                }
            }
            
            else if(Type == 'Adjustment'){
                Date createdDateValue = Date.valueOf(prodPayment.CreatedDate);
                createdDates = String.valueOf(createdDateValue.format());
                transactionType = 'Interest Adjustment';
                transactionCode = 'Interest Adjustment';
                if(prodpayment.Interest_Adjustment__c != null){
                    paymentAmount = prodPayment.Interest_Adjustment__c.setScale(2);
                }
                if(prodpayment.Pre_Pay_Principal__c != null){
                    openingPrincpalAmt = prodPayment.Pre_Pay_Principal__c.setScale(2); 
                }
                if(prodpayment.Pre_Pay_Interest__c != null){
                    openingInterestAmt = prodPayment.Pre_Pay_Interest__c.setScale(2);  
                }
                feesCredit = 0 ;
                
                if(prodPayment.Principal_Payment_Amount__c != null){
                    principalCredit = prodPayment.Principal_Payment_Amount__c.setScale(2);
                }
                if(prodPayment.Interest_Payment_Amount__c != null){
                    interestCredit  = prodPayment.Interest_Payment_Amount__c.setScale(2);
                }
                if(prodPayment.Post_Pay_Principal__c != null){
                    balPrincipal = prodPayment.Post_Pay_Principal__c.setScale(2);
                }
                
                if(prodPayment.Post_Pay_Interest__c != null){
                    balInterest = prodPayment.Post_Pay_Interest__c.setScale(2);
                }
                if(prodPayment.Balance_After_Payment__c != null){
                    balTotal = prodPayment.Balance_After_Payment__c.setScale(2);
                }
            }
        } 
    }
}