/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Class that fetch eligible Product and creates Delinquency Tracker records
*  @author : A5E Consulting
*  @date : 07/10/2017   

*************************************************************************************************/
public Class DelinquencyTrackerBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    Delinquency_Tracker_Settings__c cs;
    
    Map<String, Delinquency_Tracker__c> dtMap = new Map<String, Delinquency_Tracker__c>();
    Delinquency_Tracker__c afsCC;
    Delinquency_Tracker__c afsLoan;
    Delinquency_Tracker__c wgsLoan;
    Delinquency_Tracker__c wells1;
    Delinquency_Tracker__c wells2;
    Delinquency_Tracker__c wells3;
    
    //constructor
    public DelinquencyTrackerBatch(){
    
        //fetch Delinquency Tracker Custom Settings record
        cs = Delinquency_Tracker_Settings__c.getOrgDefaults();
        
        afsCC = createDTRecord('AFS Credit Card Portfolio'); 
        afsLoan = createDTRecord('AFS Loan Portfolio');
        wgsLoan = createDTRecord('WGS Loan Portfolio');
        wells1 = createDTRecord('Wells1 Portfolio');
        wells2 = createDTRecord('Wells2 Portfolio');
        wells3 = createDTRecord('Wells3 Portfolio');
        
        dtMap.put('AFS Credit Card Portfolio',afsCC);
        dtMap.put('AFS Loan Portfolio',afsLoan);
        dtMap.put('WGS Loan Portfolio',wgsLoan);
        dtMap.put('Wells1 Portfolio',wells1);
        dtMap.put('Wells2 Portfolio',wells2);
        dtMap.put('Wells3 Portfolio',wells3);   
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([select id, name, source_system__c, PRIN_Number__c, Branch_Name__c, Branch_Number__c, 
                                        Charged_Off_Amount__c, Charged_Off_Date__c, Charged_Off_Code__c, Charge_Off_Code_Description__c, Charged_Off_Reason_Code__c,
                                        External_Status_Current__c, Internal_Status__c, Delinquency_Status__c, Delinquency_Cycles__c,  Delinquency_Days__c, 
                                        Current_Balance__c, Current_Payoff_Amount__c, 
                                        PTP1_Amount__c, PTP1_Date__c, PTP1_Mate__c, PTP1_Method__c,
                                        No_of_times_contacted_in_current_cycle__c, Customer__r.No_of_times_contacted_for_collection__c
                                        From Product__c 
                                        WHERE ((Source_System__c ='FDR' and (PRIN_Number__c = 100 or PRIN_Number__c = 200 or PRIN_Number__c = 300 or PRIN_Number__c = 400)) 
                                        or 
                                        (Source_System__c = 'Megasys' and (Branch_Number__c = 1 or Branch_Number__c = 2) and External_Status_Current__c!='Unwound Account'))
                                        ]);
    }
        
    
    //create Delinquency Tracker Records
    public void execute(Database.BatchableContext BC, List<Product__c> prodList){
    
        for(Product__c prd : prodList){
            
            System.debug('Prod is :'+prd.id);
            
            String portfoliName;  
            
            Decimal balanceAmount = 0;
            if(prd.Source_System__c == 'FDR'){
                balanceAmount = prd.Current_Balance__c;
                if(prd.PRIN_Number__c == 200){
                    portfoliName = 'AFS Credit Card Portfolio';
                }
                else if (prd.PRIN_Number__c == 100){
                    portfoliName = 'Wells1 Portfolio';
                }
                else if (prd.PRIN_Number__c == 300){
                    portfoliName = 'Wells2 Portfolio';
                }
                else if (prd.PRIN_Number__c == 400){
                    portfoliName = 'Wells3 Portfolio';
                }
                
            }   
            else if(prd.Source_System__c == 'Megasys'){
                //balanceAmount = prd.Current_Payoff_Amount__c;
                balanceAmount = prd.Current_Balance__c;
                if(prd.Branch_Number__c == 1){
                    portfoliName = 'AFS Loan Portfolio';
                }
                else if(prd.Branch_Number__c == 2){
                    portfoliName = 'WGS Loan Portfolio';
                }
            }           
            if(balanceAmount == null){
                balanceAmount = 0;
            }  
            
            //Number of times contacted related to Account and Product
            Decimal numberOfTimesContacted = (prd.No_of_times_contacted_in_current_cycle__c != null ? prd.No_of_times_contacted_in_current_cycle__c : 0) +
                                             (prd.Customer__r.No_of_times_contacted_for_collection__c != null ? prd.Customer__r.No_of_times_contacted_for_collection__c : 0);
            
            if(String.isNotBlank(portfoliName)){
                
                Delinquency_Tracker__c dt = dtMap.get(portfoliName);
                System.debug('prd.PRIN_Number__c :'+prd.PRIN_Number__c);   
                System.debug('dt.Portfolio__c :'+dt.Portfolio__c); 
                                                            
                //Product is charged off    
                if(isChargedOff(prd)){
                    
                    //Product is charged off this month
                    if(isCurrentMonth(prd.Charged_Off_Date__c)){
                        
                        if(prd.Charge_Off_Code_Description__c.equalsIgnoreCase('None')){
                            //Heeral is treating None as Aging on his reports
                            //dt.No_of_Chargeoff_Accounts__c = dt.No_of_Chargeoff_Accounts__c + 1; 
                            //dt.Chargeoff_Amount__c = dt.Chargeoff_Amount__c + balanceAmount; 
                            dt.No_of_Chargeoff_Aging_Accounts__c = dt.No_of_Chargeoff_Aging_Accounts__c + 1;
                            dt.Chargeoff_Aging_Amount__c = dt.Chargeoff_Aging_Amount__c + balanceAmount;                            
                        }                           
                        else if(prd.Charge_Off_Code_Description__c.equalsIgnoreCase('Deceased')){
                            dt.No_of_Chargeoff_Dec_Accounts__c = dt.No_of_Chargeoff_Dec_Accounts__c + 1;
                            dt.Chargeoff_Dec_Amount__c = dt.Chargeoff_Dec_Amount__c + balanceAmount;
                            
                        }                           
                        else if(prd.Charge_Off_Code_Description__c.equalsIgnoreCase('Fraud')){
                            dt.No_of_Chargeoff_Fraud_Accounts__c = dt.No_of_Chargeoff_Fraud_Accounts__c + 1;
                            dt.Chargeoff_Fraud_Amount__c = dt.Chargeoff_Fraud_Amount__c + balanceAmount;
                            
                        }
                        else if(prd.Charge_Off_Code_Description__c.equalsIgnoreCase('Bankruptcy')){
                            dt.No_of_Chargeoff_Bank_Accounts__c = dt.No_of_Chargeoff_Bank_Accounts__c + 1;
                            dt.Chargeoff_Bank_Amount__c = dt.Chargeoff_Bank_Amount__c + balanceAmount;
                            
                        }
                        else if(prd.Charge_Off_Code_Description__c.equalsIgnoreCase('Aging')){
                            dt.No_of_Chargeoff_Aging_Accounts__c = dt.No_of_Chargeoff_Aging_Accounts__c + 1;
                            dt.Chargeoff_Aging_Amount__c = dt.Chargeoff_Aging_Amount__c + balanceAmount;
                        }                       
                    }                         
                }
                //Product is not charged off
                else{
                    
                    //Product is not closed   
                    if(!isClosed(prd)){ 
                        
                        Decimal delqCycle = getDelqCycle(prd);
                        
                        Boolean calculatePTPFuture = prd.PTP1_Amount__c != null && prd.PTP1_Amount__c > 0 && prd.PTP1_Mate__c != true && prd.PTP1_Date__c >= System.Today();
                        Boolean calculatePTPMissed = prd.PTP1_Amount__c != null && prd.PTP1_Amount__c > 0 && prd.PTP1_Mate__c != true && prd.PTP1_Date__c < System.Today();
                        
                        if(delqCycle == null || delqCycle == 0){
                            dt.No_of_Current_Accounts__c = dt.No_of_Current_Accounts__c + 1;
                            dt.Current_Amount__c = dt.Current_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Current_Future_PTP_Accounts__c = dt.No_of_Current_Future_PTP_Accounts__c + 1;
                                dt.Current_Future_PTP_Amount__c = dt.Current_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Current_Missed_PTP_Accounts__c = dt.No_of_Current_Missed_PTP_Accounts__c + 1;
                                dt.Current_Missed_PTP_Amount__c = dt.Current_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Current__c = dt.No_of_Times_Contacted_Current__c + numberOfTimesContacted;
                        }
                        else if(delqCycle == 1){
                            dt.No_of_Cycle_1_Accounts__c = dt.No_of_Cycle_1_Accounts__c + 1;
                            dt.Cycle_1_Amount__c = dt.Cycle_1_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_1_Future_PTP_Accounts__c = dt.No_of_Cycle_1_Future_PTP_Accounts__c + 1;
                                dt.Cycle_1_Future_PTP_Amount__c = dt.Cycle_1_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_1_Missed_PTP_Accounts__c = dt.No_of_Cycle_1_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_1_Missed_PTP_Amount__c = dt.Cycle_1_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_1__c = dt.No_of_Times_Contacted_Cycle_1__c + numberOfTimesContacted;
                        }
                        else if(delqCycle == 2){
                            dt.No_of_Cycle_2_Accounts__c = dt.No_of_Cycle_2_Accounts__c + 1;
                            dt.Cycle_2_Amount__c = dt.Cycle_2_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_2_Future_PTP_Accounts__c = dt.No_of_Cycle_2_Future_PTP_Accounts__c + 1;
                                dt.Cycle_2_Future_PTP_Amount__c = dt.Cycle_2_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_2_Missed_PTP_Accounts__c = dt.No_of_Cycle_2_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_2_Missed_PTP_Amount__c = dt.Cycle_2_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_2__c = dt.No_of_Times_Contacted_Cycle_2__c + numberOfTimesContacted;
                        }
                        else if(delqCycle == 3){
                            dt.No_of_Cycle_3_Accounts__c = dt.No_of_Cycle_3_Accounts__c + 1;
                            dt.Cycle_3_Amount__c = dt.Cycle_3_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_3_Future_PTP_Accounts__c = dt.No_of_Cycle_3_Future_PTP_Accounts__c + 1;
                                dt.Cycle_3_Future_PTP_Amount__c = dt.Cycle_3_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_3_Missed_PTP_Accounts__c = dt.No_of_Cycle_3_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_3_Missed_PTP_Amount__c = dt.Cycle_3_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_3__c = dt.No_of_Times_Contacted_Cycle_3__c + numberOfTimesContacted;
                        }
                        else if(delqCycle == 4){
                            dt.No_of_Cycle_4_Accounts__c = dt.No_of_Cycle_4_Accounts__c + 1;
                            dt.Cycle_4_Amount__c = dt.Cycle_4_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_4_Future_PTP_Accounts__c = dt.No_of_Cycle_4_Future_PTP_Accounts__c + 1;
                                dt.Cycle_4_Future_PTP_Amount__c = dt.Cycle_4_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_4_Missed_PTP_Accounts__c = dt.No_of_Cycle_4_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_4_Missed_PTP_Amount__c = dt.Cycle_4_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_4__c = dt.No_of_Times_Contacted_Cycle_4__c + numberOfTimesContacted;
                        }
                        else if(delqCycle == 5){
                            dt.No_of_Cycle_5_Accounts__c = dt.No_of_Cycle_5_Accounts__c + 1;
                            dt.Cycle_5_Amount__c = dt.Cycle_5_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_5_Future_PTP_Accounts__c = dt.No_of_Cycle_5_Future_PTP_Accounts__c + 1;
                                dt.Cycle_5_Future_PTP_Amount__c = dt.Cycle_5_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_5_Missed_PTP_Accounts__c = dt.No_of_Cycle_5_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_5_Missed_PTP_Amount__c = dt.Cycle_5_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_5__c = dt.No_of_Times_Contacted_Cycle_5__c + numberOfTimesContacted;
                        }
                        else if(delqCycle >= 6){
                            dt.No_of_Cycle_6_Accounts__c = dt.No_of_Cycle_6_Accounts__c + 1;
                            dt.Cycle_6_Amount__c = dt.Cycle_6_Amount__c + balanceAmount;
                            
                            //PTP Calculations
                            if(calculatePTPFuture){
                                dt.No_of_Cycle_6_Future_PTP_Accounts__c = dt.No_of_Cycle_6_Future_PTP_Accounts__c + 1;
                                dt.Cycle_6_Future_PTP_Amount__c = dt.Cycle_6_Future_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            else if(calculatePTPMissed){
                                //Populate Missed PTP fields
                                dt.No_of_Cycle_6_Missed_PTP_Accounts__c = dt.No_of_Cycle_6_Missed_PTP_Accounts__c + 1;
                                dt.Cycle_6_Missed_PTP_Amount__c = dt.Cycle_6_Missed_PTP_Amount__c + prd.PTP1_Amount__c;
                            }
                            
                            //Number of Times Contacted
                            dt.No_of_Times_Contacted_Cycle_6__c = dt.No_of_Times_Contacted_Cycle_6__c + numberOfTimesContacted;
                        }
                    }    
                }             
            }   
        }     
    }
    
    //Update Delinquency Tracker Custom Settings
    public void finish(Database.BatchableContext BC){
        
        //Update Custom settings
        Decimal num ;
        if(cs.Iteration_Limit__c == cs.Next_Iteration__c){
            num = 1;
        }
        else{
            num = cs.Next_Iteration__c + 1;
        }
        cs.Next_Iteration__c = num;
        update cs; 
        
        //Insert Delinquency_Tracker records
        List<Delinquency_Tracker__c> delinquencyTrackers = new List<Delinquency_Tracker__c>();
        
        //Current Portfolio
        Set<String> dTKeys = dtMap.keySet();
        
        //30 Days old Portfolio
        Map<String, Delinquency_Tracker__c> pMDTRMap = getPreviousMonthDTRecordsMap();
        
        for (String dTKey : dTKeys){
            Delinquency_Tracker__c dtRecord = dtMap.get(dTKey);
            
            //Roll rate Calculations
            Delinquency_Tracker__c pMDTRecord = pMDTRMap.get(dTKey);
            if(pMDTRecord != null){
                
                dtRecord.Roll_Rate_0_1__c = calculareRollRate(dtRecord.Cycle_1_Amount__c, pMDTRecord.Current_Amount__c); 
                dtRecord.Roll_Rate_1_2__c = calculareRollRate(dtRecord.Cycle_2_Amount__c, pMDTRecord.Cycle_1_Amount__c);
                dtRecord.Roll_Rate_2_3__c = calculareRollRate(dtRecord.Cycle_3_Amount__c, pMDTRecord.Cycle_2_Amount__c);
                dtRecord.Roll_Rate_3_4__c = calculareRollRate(dtRecord.Cycle_4_Amount__c, pMDTRecord.Cycle_3_Amount__c);
                dtRecord.Roll_Rate_4_5__c = calculareRollRate(dtRecord.Cycle_5_Amount__c, pMDTRecord.Cycle_4_Amount__c);
                dtRecord.Roll_Rate_5_6__c = calculareRollRate(dtRecord.Cycle_6_Amount__c, pMDTRecord.Cycle_5_Amount__c);
            }
            
            delinquencyTrackers.add(dtRecord);
        }
        
        insert delinquencyTrackers;
    
    }
    
    //Create and initialize Delinquency Tracker
    private Delinquency_Tracker__c createDTRecord(String portfolioName){
        
        return new Delinquency_Tracker__c(
                Snapshot_Date__c = System.today(),
                Portfolio__c = portfolioName, 
                Iteration_Number__c = cs.Next_Iteration__c,
                No_of_Chargeoff_Accounts__c = 0,
                Chargeoff_Amount__c = 0,
                No_of_Chargeoff_Dec_Accounts__c = 0,
                Chargeoff_Dec_Amount__c = 0,
                No_of_Chargeoff_Fraud_Accounts__c = 0,
                Chargeoff_Fraud_Amount__c = 0,
                No_of_Chargeoff_Bank_Accounts__c = 0,
                Chargeoff_Bank_Amount__c = 0,
                No_of_Chargeoff_Aging_Accounts__c = 0,
                Chargeoff_Aging_Amount__c = 0,
                No_of_Current_Accounts__c = 0,
                Current_Amount__c = 0,
                No_of_Cycle_1_Accounts__c = 0,
                Cycle_1_Amount__c = 0,
                No_of_Cycle_2_Accounts__c = 0,
                Cycle_2_Amount__c = 0,
                No_of_Cycle_3_Accounts__c = 0,
                Cycle_3_Amount__c = 0,
                No_of_Cycle_4_Accounts__c = 0,
                Cycle_4_Amount__c = 0,
                No_of_Cycle_5_Accounts__c = 0,
                Cycle_5_Amount__c = 0,
                No_of_Cycle_6_Accounts__c = 0,
                Cycle_6_Amount__c = 0,
                
                //PTP Data 
                No_of_Current_Future_PTP_Accounts__c = 0,
                No_of_Cycle_1_Future_PTP_Accounts__c = 0,
                No_of_Cycle_2_Future_PTP_Accounts__c = 0,
                No_of_Cycle_3_Future_PTP_Accounts__c = 0,
                No_of_Cycle_4_Future_PTP_Accounts__c = 0,
                No_of_Cycle_5_Future_PTP_Accounts__c = 0,
                No_of_Cycle_6_Future_PTP_Accounts__c = 0,
                Current_Future_PTP_Amount__c = 0,
                Cycle_1_Future_PTP_Amount__c = 0,
                Cycle_2_Future_PTP_Amount__c = 0,
                Cycle_3_Future_PTP_Amount__c = 0,
                Cycle_4_Future_PTP_Amount__c = 0,
                Cycle_5_Future_PTP_Amount__c = 0,
                Cycle_6_Future_PTP_Amount__c = 0,
                
                //Missed PTP Data
                No_of_Current_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_1_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_2_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_3_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_4_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_5_Missed_PTP_Accounts__c = 0,
                No_of_Cycle_6_Missed_PTP_Accounts__c = 0,
                Current_Missed_PTP_Amount__c = 0,
                Cycle_1_Missed_PTP_Amount__c = 0,
                Cycle_2_Missed_PTP_Amount__c = 0,
                Cycle_3_Missed_PTP_Amount__c = 0,
                Cycle_4_Missed_PTP_Amount__c = 0,
                Cycle_5_Missed_PTP_Amount__c = 0,
                Cycle_6_Missed_PTP_Amount__c = 0,
                
                //Number of Times COntacted
                No_of_Times_Contacted_Current__c = 0,
                No_of_Times_Contacted_Cycle_1__c = 0,
                No_of_Times_Contacted_Cycle_2__c = 0,
                No_of_Times_Contacted_Cycle_3__c = 0,
                No_of_Times_Contacted_Cycle_4__c = 0,
                No_of_Times_Contacted_Cycle_5__c = 0,
                No_of_Times_Contacted_Cycle_6__c = 0
                );     
    }
    
    //Checks is Product is charged off
    private static boolean isChargedOff(Product__c prod){
        //return (prod.Charged_Off_Date__c != null || prod.External_Status_Current__c == 'Z');  
        if(prod.Source_System__c == 'FDR'){
            if(prod.Charged_Off_Date__c != null || prod.External_Status_Current__c == 'Z'){
                return true;
            }
        }   
        else if(prod.Source_System__c == 'Megasys'){
            if(prod.Charged_Off_Date__c != null || prod.Internal_Status__c == 'ChargedOff'){
                return true;
            }
        }
        
       return false;    
    }
    
    //Checks is Product is closed
    private static boolean isClosed(Product__c prod){
        if(prod.Source_System__c == 'FDR'){
            if(String.isNotBlank(prod.External_Status_Current__c) && (prod.Current_Balance__c == null || prod.Current_Balance__c == 0)){
                return true;
            }           
        }
        else if(prod.Source_System__c == 'Megasys'){
            if(prod.Current_Balance__c == null || prod.Current_Balance__c == 0){
                return true;        
            }   
        }
        
        return false;       
    }    
    
    //Utility method that return number of Delinquency Cycles
    private static Decimal getDelqCycle(Product__c prod){
        if(prod.Source_System__c == 'FDR'){
           return prod.Delinquency_Cycles__c;          
        }
        else if(prod.Source_System__c == 'Megasys'){
             return prod.Delinquency_Cycles__c;
        }
        
        return null;       
    }  
    
    //Utility method that return number of Delinquency Cycles based on Delinquency Days
    @TestVisible 
    private static Decimal getMSDelqCycle(Product__c prod){
        
        if(prod.Branch_Number__c == 1){
            Decimal delqDays = prod.Delinquency_Days__c;
        
            //Cycle null
            if(delqDays == null){
                return null;
            }
            
            //Cycle 0
            else if(delqDays >= 0 && delqDays <= 6){
                return 0;
            }
                 
            //Cycle 1
            else if(delqDays >= 7 && delqDays <= 36){
                return 1;
            }       
                
            //Cycle 2
            else if(delqDays >= 37 && delqDays <= 66){
                return 2;
            }
            
            //Cycle 3
            else if(delqDays >= 67 && delqDays <= 96){
                return 3;
            }
            
            //Cycle 4
            else if(delqDays >= 97 && delqDays <= 126){
                return 4;
            }
            
            //Cycle 5
            else if(delqDays >= 127 && delqDays <= 156){
                return 5;
            }
            
            //Cycle 6
            else if(delqDays >= 157){
                return 6;
            }  
            
            return null; 
            
        }
        
        else if(prod.Branch_Number__c == 2){
            return prod.Delinquency_Cycles__c; 
        }        
        
        return null;       
    }  
    
    //Utility method that a map of Delinquency_Trackers which were cretaed  30 days back
    private static Map<String, Delinquency_Tracker__c> getPreviousMonthDTRecordsMap(){
        
        Map<String, Delinquency_Tracker__c> pMDTRMap = new Map<String, Delinquency_Tracker__c>();
        
        Date oneMonthBack = System.today().addDays(-30);
        System.debug('oneMonthBak  :'+oneMonthBack);
        List <Delinquency_Tracker__c> pMDTRecords = [Select id, Name, Snapshot_Date__c, Portfolio__c, Current_Amount__c, 
                                                                        Cycle_1_Amount__c, Cycle_2_Amount__c, Cycle_3_Amount__c, 
                                                                        Cycle_4_Amount__c, Cycle_5_Amount__c, Cycle_6_Amount__c 
                                                                        from Delinquency_Tracker__c 
                                                                        where Snapshot_Date__c=:oneMonthBack];  
        
        if(pMDTRecords.size()>0){
            for(Delinquency_Tracker__c pMDTRecord : pMDTRecords){
                pMDTRMap.put(pMDTRecord.Portfolio__c, pMDTRecord);
            }           
        }                                                           
        
        return pMDTRMap;       
    }  
    
    //Utility method to calculate Roll Rate
    @TestVisible 
    private static Decimal calculareRollRate(decimal latestAmt, decimal prvAmt){
        
        if(prvAmt!=null && prvAmt!=0 && latestAmt!=null){
            return 100 * (latestAmt / prvAmt) ;
        }
        
        return null;      
    }  
    
    //Checks is Date is of current month
    private static boolean isCurrentMonth(Date dateToCheck){
        Date tday = System.Today();
        
        if(dateToCheck != null){
            if((dateToCheck.month() == tday.month()) && (dateToCheck.year() == tday.year())){
                return true;
            }
        }
        
        return false;      
    }  
}