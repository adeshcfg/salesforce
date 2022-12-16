/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for DelinquencyTrackerBatch
*  @author : A5E Consulting
*  @date : 07/13/2017   

*************************************************************************************************/
@isTest
public class TestDelinquencyTrackerBatch{

    public Static testMethod void testDTBatch(){
        
        //Create Custom Setting Record    
        createDTCS();
        
        //Create Product record
        createProduct();
        
        //Create 30 day old Delinquency_Tracker records
        createBackDateDTRecords();
        
        //Execute DelinquencyTrackerBatch
        Database.executeBatch(New DelinquencyTrackerBatch());
    }
    
    //Create Product records
    public static void createProduct(){
    	
    	Date ptpDate = System.Today().addDays(10);
        
        List<Product__c> prds = new List<Product__c>();
        Product__c prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
                
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = 'None';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '0';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today().addMonths(-2);
        prd.Charged_Off_Code__c = '0';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 1;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '02';
        prd.Current_Balance__c = null;
        prd.Current_Payoff_Amount__c = 100;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 2;
        prd.Current_Balance__c = 200;
        prd.Current_Payoff_Amount__c = 200;
        prd.Delinquency_Cycles__c = 0;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 2;
        prd.Current_Balance__c = 200;
        prd.Current_Payoff_Amount__c = 200;
        prd.Delinquency_Cycles__c = 1;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 2;
        prd.Current_Balance__c = 200;
        prd.Current_Payoff_Amount__c = 200;
        prd.Delinquency_Cycles__c = 2;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 2;
        prd.Current_Balance__c = 200;
        prd.Current_Payoff_Amount__c = 200;
        prd.Delinquency_Cycles__c = 3;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c = 'Megasys';
        prd.Branch_Number__c = 2;
        prd.Current_Balance__c = 0;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 100;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '18';
        prd.Current_Balance__c = 300;
        prd.Current_Payoff_Amount__c = 300;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 100;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '88';
        prd.Current_Balance__c = 300;
        prd.Current_Payoff_Amount__c = 300;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 100;
        prd.Charged_Off_Date__c = System.Today();
        prd.Charged_Off_Code__c = '89';
        prd.Current_Balance__c = 300;
        prd.Current_Payoff_Amount__c = 300;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 4;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 5;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 6;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 200;
        prd.Current_Balance__c = 400;
        prd.Current_Payoff_Amount__c = 400;
        prd.Delinquency_Cycles__c = 7;
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 300;
        prd.Current_Balance__c = 0;
        prd.External_Status_Current__c = 'C';
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        prd = new Product__c();
        prd.name = 'Prod';
        prd.source_system__c ='FDR' ;
        prd.PRIN_Number__c = 400;
        prd.Current_Balance__c = 0;
        prd.External_Status_Current__c = 'C';
        prd.PTP1_Mate__c = false;
        prd.PTP1_Amount__c = 75;
        prd.PTP1_Date__c = ptpDate;
        prds.add(prd);
        
        insert prds;
    }
    
    //create Product records
    public static void createBackDateDTRecords(){
        
        List<Delinquency_Tracker__c> dtRecords = new List<Delinquency_Tracker__c>();
        
        dtRecords.add(new Delinquency_Tracker__c(Snapshot_Date__c = System.today().addDays(-30), Portfolio__c = 'AFS Credit Card Portfolio'));
        dtRecords.add(new Delinquency_Tracker__c(Snapshot_Date__c = System.today().addDays(-30), Portfolio__c = 'AFS Loan Portfolio'));
        dtRecords.add(new Delinquency_Tracker__c(Snapshot_Date__c = System.today().addDays(-30), Portfolio__c = 'WGS Loan Portfolio'));
        
        insert dtRecords;
    }

	//Test method that retuirn Delinquency Cycles for Megasys 
    public static testMethod void tetGetMSDelqCycle(){
        
        Product__c prd = new Product__c();
        prd.name = 'Prod';
        prd.Branch_Number__c = 1;       
        System.assertEquals(null,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 5;
        System.assertEquals(0,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 35;
        System.assertEquals(1,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 65;
        System.assertEquals(2,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 95;
        System.assertEquals(3,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 125;
        System.assertEquals(4,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 155;
        System.assertEquals(5,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = 180;
        System.assertEquals(6,DelinquencyTrackerBatch.getMSDelqCycle(prd));
        
        prd.Delinquency_Days__c = null;
        System.assertEquals(null,DelinquencyTrackerBatch.getMSDelqCycle(prd));
                
        prd.Branch_Number__c = 2;
        prd.Delinquency_Cycles__c = 2;
        System.assertEquals(2,DelinquencyTrackerBatch.getMSDelqCycle(prd));        
    }
    
    //Test method to test Roll Rate Calculations
    public static testMethod void testCalculareRollRate(){      
        System.assertEquals(null, DelinquencyTrackerBatch.calculareRollRate(0, null));   
        System.assertEquals(null, DelinquencyTrackerBatch.calculareRollRate(0, 0));     
        System.assertEquals(null, DelinquencyTrackerBatch.calculareRollRate(100, 0));  
        System.assertEquals(0, DelinquencyTrackerBatch.calculareRollRate(0, 100)); 
        System.assertEquals(50, DelinquencyTrackerBatch.calculareRollRate(50, 100)); 
    }  
    
    //Create Custom Setting Record  
    public static void createDTCS(){
        
        Delinquency_Tracker_Settings__c dtCS = New Delinquency_Tracker_Settings__c();
        dtCS.Iteration_Limit__c = 1;
        dtCS.Next_Iteration__c = 2;        
        insert dtCS; 
    }  
    
    
}