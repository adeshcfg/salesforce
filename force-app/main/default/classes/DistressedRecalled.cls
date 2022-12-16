/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Batch Class that mark distressed products as RECALLED
*  @author : A5E Consulting
*  @date : 20 Feb 2019  

*************************************************************************************************/
public Class DistressedRecalled implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
    
        //Datetime recalledAccountdate = AddBusinessDays(system.TODAY(), -3);
        return Database.getQueryLocator([select id, name, recordType.Name, Record_Last_Updated_In_Staging__c,
                                         Collection_Sub_Status__c
                                         from product__c where recordType.name = 'Distressed Account'
                                         AND Collection_Sub_Status__c <> 'RECALLED'
                                         AND Collection_Agency__c = null]);
    }
    
    public void execute(Database.BatchableContext BC, List<Product__C> prodList){
        
        for(Product__C prod : prodList){
            prod.Collection_Sub_Status__c = 'RECALLED';
            
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update prodList;
        ProductTriggerHandler.runProductTrigger = true;
    }
    
    public void finish(Database.BatchableContext BC){
        Database.executeBatch(New DistressedToActive(), 100);
    }
    
    /*
    public static Boolean IsWeekendDay(Date dateParam)
   {
      boolean result     = false;
      system.debug('dateParam = '+dateParam); 
      //Recover the day of the week
      Date startOfWeek   = dateParam.toStartOfWeek();
      system.debug('startOfWeek = '+startOfWeek);
      Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
      system.debug('dayOfWeek = '+dayOfWeek);   
      result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
      system.debug('result = '+result); 
      return result;
   } 
   
   
   public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd )
   {
      //Add or decrease in BusinessDaysToAdd days 
      Date finalDate = StartDate;
      system.debug('finaldate = '+finalDate);
      integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
      system.debug('direction = '+direction);
       while(BusinessDaysToAdd != 0)
       {
           finalDate = finalDate.AddDays(direction);
           system.debug('BusinessDaysToAdd = '+BusinessDaysToAdd);            
           system.debug('finaldate = '+finalDate);
           if (!isWeekendDay(finalDate))
           {
               BusinessDaysToAdd -= direction;
               
           }
       }

       return finalDate;
   }
   */
}