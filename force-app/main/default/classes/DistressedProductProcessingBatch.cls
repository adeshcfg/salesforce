/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to calculate Interest Amount on Product on daily basis
 *  @author : A5E Consulting
 *  @date : 18/11/2021
 
 *************************************************************************************************/
public class DistressedProductProcessingBatch implements Database.Batchable<sObject> { 
    Agency_Portal_Settings__c agencyPortalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    //List<String> productNames = new List<String>{'825P15670','825P15671','825P15765','825P15766','825P15768','825P15769','825P15862','825P15863','825P15954','825P15957'};
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            [SELECT ID, Current_Principal_Balance__c, Interest_Rate__c, Current_Interest_Amount__c,Judgment_Rate__c, 
                    Interest_Amount_Last_Calculated_Date__c, Collection_Sub_Status__c, State__c, Current_Balance__c,
                    Interest_Waived_Off__c, Interest_Waived_Off_Start_Date__c, Interest_Waived_Of_End_Date__c,Interest_Stopped__c
             FROM Product__c 
             WHERE RecordType.DeveloperName= 'Distressed_Account'  
             
             AND Current_Principal_Balance__c != null 
             AND Current_Principal_Balance__c > 0 
             //Commenting since Interest Rate can be fetched from Province Rate object
             //AND Interest_Rate__c != NULL 
             AND Interest_Rate__c != 0
             AND Interest_Amount_Last_Calculated_Date__c != NULL
             AND Interest_Amount_Last_Calculated_Date__c <> TODAY
             AND Collection_Sub_Status__c != 'Paid in Full Account'
             AND Collection_Sub_Status__c != 'Settled in Full Account'
             AND Collection_Sub_Status__c != 'Deceased'
             AND Collection_Sub_Status__c != 'Bankrupt Account'
             AND Collection_Sub_Status__c != 'Credit Counselling'
             AND Insolvency_Date__c = NULL
             AND Deceased_Date__c = NULL 
             
             /*
             AND (Interest_Waived_Off__c = false OR (Interest_Waived_Off__c = true 
             AND (Interest_Waived_Off_Start_Date__c <= TODAY   
             AND Interest_Waived_Of_End_Date__c >= TODAY)))
             */
             
             //AND Name IN: productNames
            ]
        );
        
    }     
    
    public void execute(Database.BatchableContext bc, List<Product__c> listProducts){
        List<API_Error__c> listAPIErrors = New List<API_Error__c>();
        
        map<Id, list<Settlement__c>> mapProductSettlement = new map<Id, list<Settlement__c>>();
        map<Id, Judgment__c> mapProductJudgment = new map<Id, Judgment__c>();
        
        map<String, Decimal> mapProvinceFullName = new map<String, Decimal>();
        map<String, Decimal> mapProvinceAcronym = new map<String, Decimal>();
        
        Decimal InterestRate;
        Decimal InterestAmount = 0;
        Decimal Principal_Balance = 0;
        Decimal NoOfDaysInYear = agencyPortalSettings.Number_of_Days__c;
        
        Date Today = Date.today();
        
        //get province details in map
        for(Province_Interest_Rate__c rateInstance : [SELECT Province_Name__c, Province_Acronym__c, Interest_Rate__c, 
                                                             Start_Date__c, End_Date__c
                                                      FROM Province_Interest_Rate__c
                                                      WHERE Start_Date__c <= TODAY
                                                      AND End_Date__c >= TODAY
                                                      ORDER BY CreatedDate DESC 
                                                     ]){
            if(String.isNotBlank(rateInstance.Province_Name__c)){
                mapProvinceFullName.put(rateInstance.Province_Name__c, rateInstance.Interest_Rate__c);    
            }
            if(String.isNotBlank(rateInstance.Province_Name__c)){
                mapProvinceAcronym.put(rateInstance.Province_Acronym__c, rateInstance.Interest_Rate__c);    
            }
        }
        
        system.debug('mapProvinceAcronym: '+mapProvinceAcronym);
        
        //mapProductSettlement = getSettlementRecords(listProducts);
        mapProductJudgment = getJudgmentRecords(listProducts);       
        
        system.debug('Current Time After Related records query: '+system.now());
       
        for(Product__c productObj :listProducts){
            //If interest calculation date falls between Waived of Dates, product will be excluded from Daily Interest Accrual
            productObj.Interest_Amount_Last_Calculated_Date__c = productObj.Interest_Amount_Last_Calculated_Date__c.addDays(1);
            if(productObj.Interest_Waived_Off__c == false
            || (productObj.Interest_Waived_Off__c == true
            && (productObj.Interest_Amount_Last_Calculated_Date__c < productObj.Interest_Waived_Off_Start_Date__c 
             || productObj.Interest_Amount_Last_Calculated_Date__c > productObj.Interest_Waived_Of_End_Date__c))){

                 //Ticket 4558: Interest Waiver functionality checking Accuring Interest
                 productObj.Interest_Stopped__c = false;
                 
                 System.debug('Current Time 4 before interest rate checks:'+System.now());
                
                //Check if product has the Judgment
                if(mapProductJudgment.containsKey(productObj.Id)
                && mapProductJudgment.get(productObj.Id) != NULL){
                    system.debug('Judgment not empty');
                    
                    Principal_Balance = productObj.Current_Principal_Balance__c;
                    
                    //Get Interest rate Province wise from Province_Interest_Rate__c, if Judgment is present
                    if(mapProvinceFullName.containsKey(productObj.State__c)){
                        InterestRate = mapProvinceFullName.get(productObj.State__c);
                        system.debug('InterestRate mapProvinceFullName: '+InterestRate);
                    }
                    else if(mapProvinceAcronym.containsKey(productObj.State__c)){
                        InterestRate = mapProvinceAcronym.get(productObj.State__c);
                        system.debug('InterestRate mapProvinceAcronym: '+InterestRate);
                    }
                    
                    /*----Commenting the code since Judgment Rate is populated on Account Interest Rate When Judgment is created----
                    //Get Interest Rate from Judgment if Province Interest Rate not present
                    if(InterestRate == NULL && productObj.Judgment_Rate__c != NULL){
                        system.debug('Current Time before Judgment interestrate assignment:'+ system.now());
                        InterestRate = productObj.Judgment_Rate__c;
                        system.debug('Current Time after Judgment interestrate assignment:'+ system.now());    
                    }*/
                } 
                
                //Else Get interest rate from product
                if(InterestRate == NULL && productObj.Interest_Rate__c != NULL) {
                    system.debug('Current Time in product interest rate check:'+ system.now());
                    InterestRate = productObj.Interest_Rate__c;
                }
                
                //Round of the Principal Balance to 2 decimal places
                Principal_Balance = productObj.Current_Principal_Balance__c.setScale(2,RoundingMode.HALF_UP);
                
                //Interest Amount calculation = ((P*N*R)/100)/365
                //NoOfDaysInYear is set to 365 in Custom Setting
                if(InterestRate != NULL && Principal_Balance != NULL && NoOfDaysInYear != NULL){
                    system.debug('Principal_Balance:: '+Principal_Balance);
                    system.debug('InterestRate:: '+InterestRate);
                    system.debug('NoOfDaysInYear:: '+NoOfDaysInYear);
                                        
                    //Decimal NoOfDays = productObj.Interest_Amount_Last_Calculated_Date__c.daysBetween(Today);
                    
                    //Run Batch for one day at time
                    //Simplify no of days to 1/365;
                    Decimal NoOfDays = (1 / NoOfDaysInYear);
                    //round of no of days to 5 decimal places
                    NoOfDays = NoOfDays.setScale(5,RoundingMode.HALF_UP);
                    
                    //convert interest rate percent to decimal
                    InterestRate = InterestRate / 100;
                    
                    //I=Prt
                    InterestAmount = Principal_Balance * InterestRate * NoOfDays;
                    //Round off Interest Amount accrued to 2 decimal places
                    InterestAmount = InterestAmount.setScale(2,RoundingMode.HALF_UP);
                    
                    /*InterestAmount =           
                    (((Principal_Balance * InterestRate * NoOfDays)/100)/NoOfDaysInYear);*/
                    
                    system.debug('productObj.Current_Interest_Amount__c:: '+productObj.Current_Interest_Amount__c);
                    system.debug('InterestAmount::'+InterestAmount);
                    
                    //Update Current Interest Amount
                    if(productObj.Current_Interest_Amount__c == NULL){
                        productObj.Current_Interest_Amount__c = interestAmount;  
                    }
                    else {
                        system.debug('productObj.Current_Interest_Amount__c before: '+productObj.Current_Interest_Amount__c);
                        productObj.Current_Interest_Amount__c += interestAmount;     
                        system.debug('productObj.Current_Interest_Amount__c after: '+productObj.Current_Interest_Amount__c);
                    }
                    
                    //Populate Interest Amount Accrued for the Day
                    productObj.Interest_Accrued_for_the_Day__c = InterestAmount;
                    //Update total balance on Product
                    productObj.Current_Balance__c = ( productObj.Current_Balance__c!=NULL 
                                                    ? productObj.Current_Balance__c + InterestAmount
                                                    : InterestAmount);
                    //Set total balance to 2 decimal round off
                    productObj.Current_Balance__c = productObj.Current_Balance__c.setScale(2,RoundingMode.HALF_UP);
                    
                    /*
                    if(productObj.Current_Balance__c ==  NULL){
                        productObj.Current_Balance__c = InterestAmount;
                    }
                    else {
                        //Add the accrued amount to Total Balance
                        system.debug('Current_Balance__c before'+productObj.Current_Balance__c);
                        productObj.Current_Balance__c = productObj.Current_Balance__c + InterestAmount;
                        system.debug('Current_Balance__c after'+productObj.Current_Balance__c);
                    }*/                    
                    system.debug('productObj: '+productObj);
                }    
             }else{
                 //Ticket 4558: Interest Waiver functionality checking Accuring Interest
                 productObj.Interest_Stopped__c = True;
            }
            
            Principal_Balance = 0;
            InterestRate = Null;
            //productObj.Interest_Amount_Last_Calculated_Date__c = Date.today();
        }
        
        system.debug('listProducts update: '+listProducts);
        
        ProductTriggerHandler.runProductTrigger = false;

        Database.SaveResult[] srList = Database.update(listProducts, false);

        // Iterate through each returned result
        for (Integer i=0; i<srList.size(); i++) {
            if (srList.get(i).isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                //System.debug('Successfully updated account. Account` ID: ' + sr.getId());
            }
            //in  case of failure, create database Error records
            else if (!srList.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = srList.get(i).getErrors().get(0);
                String failedDML = error.getMessage();
                listProducts.get(i);//failed record from the list
                system.debug('Failed ID'+listProducts.get(i).Id);
                API_Error__c apiError = New API_Error__c();
                apiError.Product__c = listProducts.get(i).Id;
                apiError.Error__c = failedDML;
                apiError.End_Point__c = 'Process Distressed';
                apiError.Action__c = 'Daily Interest Calculation';
                listAPIErrors.add(apiError); 
            }
        }
        insert listAPIErrors;
        
        ProductTriggerHandler.runProductTrigger = true;
        
        system.debug('current time after product update'+system.now());
    }

    //Finish method
    public void finish(Database.BatchableContext bc){  
        //switch on metadata
        //MetadataSwitchJob.activateProductMetadata();
        system.enqueueJob(new MetaDataActivation());
    }
    
    //Get Active judgment related to Product
    public map<Id, Judgment__c> getJudgmentRecords(list<Product__c> listProduct){
        system.debug('Current Time before judgment query: '+system.now());
        map<Id, Judgment__c> mapProductAccountJudgment = new map<Id, Judgment__c>();
        
        for(Account_Judgment__c accJudgment : [SELECT ID, Name,Product__c, Judgment__c,
                                                      Judgment__r.Product_1__c
                                               FROM Account_Judgment__c 
                                               WHERE Product__c IN :listProduct
                                               AND Status__c = 'Active'
                                               AND (Judgment__r.Legal_Status__c = 'Judgment' 
                                                    OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                                               AND Judgment__r.Judgment_Date__c != NULL
                                               ORDER BY CreatedDate DESC 
                                               ]){
            Judgment__c judgment = new Judgment__c(Id=accJudgment.Judgment__c,
                                                  Product_1__c = accJudgment.Judgment__r.Product_1__c
                                                  );
            /*
            if(!mapProductAccountJudgment.containsKey(accJudgment.Product__c)){
                mapProductAccountJudgment.put(accJudgment.Product__c, accJudgment);
            }
            */
                                                   
            if(!mapProductAccountJudgment.containsKey(accJudgment.Product__c)){
                mapProductAccountJudgment.put(accJudgment.Product__c, judgment);
            }
                                                   
        }
        
        system.debug('mapProductAccountJudgment: '+mapProductAccountJudgment);
        system.debug('Current Time after judgment query: '+system.now());
        return mapProductAccountJudgment;
    }
    
    //Get Settlement records related to Products
    //Commenting settlement code as settlement is not going to affect interest calculation for now
    /*
    public map<Id, list<Settlement__c>> getSettlementRecords(list<Product__c> listProduct){
        system.debug('Current Time before settlement query: '+system.now());
        
        map<Id, list<Settlement__c>> map1 = new map<Id, list<Settlement__c>>();
        
        for(Settlement__c settlement : [SELECT ID, Name,Product__c FROM Settlement__c WHERE Product__c IN :listProduct]){
            if(!map1.containsKey(settlement .Product__c)){
                map1.put(settlement.Product__c, new list<settlement__c> {settlement });
            }
            else{
                list<Settlement__c> list1 = new list<Settlement__c>();
                list1 =  map1.get(settlement.Product__c);
                list1.add(settlement);
                map1.put(settlement.Product__c, list1);
            }
            
        }
        
        system.debug('Current Time after settlement query: '+system.now());
        return map1;
    }
    */
    
}