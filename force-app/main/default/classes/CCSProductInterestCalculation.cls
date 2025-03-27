/**************************************************************************************************
 *
 *  Class:   
 *  @description : This is a Batch class to calculate Interest Amount on Go Easy Product on daily basis
 *  @author : A5E Consulting
 *  @date : 19/08/2023
 
 *************************************************************************************************/
public class CCSProductInterestCalculation implements Database.Batchable<sobject> {
    
public static List<String> RECORDTYPE = new List<String>{'GoEasy_CCS_Account', 'Flexiti_CCS_Account'};
public static List<String> CCSSTAGE = new List<String>{'Missed Payment', 'In Progress (notice has been sent)'};
    

    
public Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(
            [SELECT ID,  Interest_Rate__c,Accepted_Interest_rate__C, Current_Interest_Amount__c,CCS_Stage__c, 
                    Interest_Amount_Last_Calculated_Date__c,   State__c, Current_Balance__c                     
             FROM Product__c 
             WHERE RecordType.DeveloperName IN :RECORDTYPE 
             AND Current_Balance__c != null 
             AND Current_Balance__c > 0 
             // Interest_Rate__c or Accepted_Interest_rate__c should be present 
             AND ((Interest_Rate__c != NULL 
             AND Interest_Rate__c != 0) OR (Accepted_Interest_rate__C != NULL and Accepted_Interest_rate__C !=0))
             AND (CCS_Stage__c IN :CCSSTAGE)
            ]
        );
        
    }     
    
    public void execute(Database.BatchableContext bc, List<Product__c> listProducts){
        
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        
        system.debug('config'+config);
        List<API_Error__c> listAPIErrors = New List<API_Error__c>();
         
        Decimal InterestRate;
        Decimal InterestAmount = 0;
        Decimal Principal_Balance = 0;
        Decimal NoOfDaysInYear = config.Number_of_Days__c;
        Date Today = Date.today();
       	//Simplify no of days to 1/365;
        Decimal NoOfDays = (1 / NoOfDaysInYear);
        
        for(Product__c productObj :listProducts){
            //updating Interest Last Calculated date to current date
            productObj.Interest_Amount_Last_Calculated_Date__c = Date.today();
            // If Interest_Rate__C is blank or null then Interest will be calculated on Accepted_Interest_Rate__C
            if(productObj.Interest_Rate__c!=Null &&  productObj.Interest_Rate__c!=0){
                InterestRate = productObj.Interest_Rate__c;
            }else if(productObj.Accepted_Interest_rate__C!=Null &&  productObj.Accepted_Interest_rate__C!=0){
                InterestRate = productObj.Accepted_Interest_rate__C;
            }
            
                //Round of the Principal Balance to 2 decimal places
                Principal_Balance = productObj.Current_Balance__c.setScale(2,RoundingMode.HALF_UP);
                //Interest Amount calculation = ((P*N*R)/100)/365
                //NoOfDaysInYear is set to 365 in Custom Setting
                if(InterestRate != NULL && Principal_Balance != NULL && NoOfDaysInYear != NULL){
                    system.debug('Principal_Balance:: '+Principal_Balance);
                    system.debug('InterestRate:: '+InterestRate);
                    system.debug('NoOfDaysInYear:: '+NoOfDaysInYear);
                    //Run Batch for one day at time
                    
                    //round of no of days to 5 decimal places
                    NoOfDays = NoOfDays.setScale(5,RoundingMode.HALF_UP);
                    
                    //convert interest rate percent to decimal
                    InterestRate = InterestRate / 100;
                    
                    //I=Prt
                    InterestAmount = Principal_Balance * InterestRate * NoOfDays;
                    //Round off Interest Amount accrued to 2 decimal places
                    InterestAmount = InterestAmount.setScale(2,RoundingMode.HALF_UP);
                    
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
    
                    system.debug('productObj: '+productObj);
                }    
            
            Principal_Balance = 0;
            InterestRate = Null;
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
                apiError.End_Point__c = 'Process CCS';
                apiError.Action__c = 'Daily CCS Interest Calculation';
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
 
}