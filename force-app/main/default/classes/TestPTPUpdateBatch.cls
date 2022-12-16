/**************************************************************************************************
*
*  Class:   
*
*  @description : This class contains unit tests for validating behavior of PTPUpdateBatch
*  @author : A5E Consulting
*  @date : 19/04/2019
*
*************************************************************************************************/  
      @isTest
    public class TestPTPUpdateBatch {
   public static boolean runPTPTrigger = true;
 		@isTest   
        public static void Testptpbatch(){
        Product__c prod=new Product__c();
        prod.Name='Test';
        prod.Current_Interest_Amount__c=18000;
        prod.Interest_Rate__c=19;
        prod.Current_Balance__c=814596;
        insert prod;
            
        //Id idt=[select id from Product__c limit 1].id;
        //system.debug(idt);
        PTP_Information__c ptp = new PTP_Information__c();  
        ptp.PTP_Method__c='online';
        ptp.PTP_Amount__c=16000;
        ptp.PTP_Date__c=system.now();
        ptp.PTP_mate__c=True;
        ptp.Product__c=prod.Id;
        insert ptp; 
       
test.startTest();
PTPUpdateBatch ptpub=new PTPUpdateBatch();
Database.executeBatch(ptpub); 
test.stopTest();
 } 

}