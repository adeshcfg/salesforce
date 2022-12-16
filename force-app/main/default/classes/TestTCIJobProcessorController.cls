/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class contains unit tests for validating behavior of DeleteCustomersController
 *  @author : A5E Consulting
 *  @date : 08/02/2016
 *
 *  Change History:
 *
 *  Developer       Date          Description
 *  ------------------------------------------------------------------------------------------------
 *
 *  A5E Consulting 08/02/2016     Development
 
 *************************************************************************************************/
@isTest
public class TestTCIJobProcessorController{
    
    static testmethod void testTCIReport(){   
        
        //Create Test Records        
        createCustomertWithOneApplication();
        
        //Create TCI Job Record
        createTCIJob();
        
        //Create TCI Job Setting Records
        TestRecordsFactory.createTciCSRecords();
        
        //Call Controller method
        TCIJobProcessorController tciCntrl = new TCIJobProcessorController();
        
        tciCntrl.callTCIJob();
        
        //Verify Test results
        Application__c application = [Select id,Application_Status__c,Decision__c from Application__c ];
        
        System.debug('================='+application );
        //System.assertEquals('Archived',application.Application_Status__c);        
    }
    
    //Create Application Records
    public static void createCustomertWithOneApplication() { 
     
        Account acc = new Account(FirstName='Mark',LastName='Vanpee');
        insert acc;
     
        Application__c app = new Application__c(
        Name='AFITest1'
        ,Customer__C=acc.id,Decision__c='Completed'
        , Application_Status__c='Completed – Credit Card'
        , Loan_Type__c='Affirm Financial MasterCard'
        //,Completed_CreditCard_DateTime__c=System.now() - 1);        
        ,Decision_Timestamp__c=System.now() - 1);
        insert app;

    }
    
    //Create TCI Job Records
    public static void createTCIJob() { 
        
        TCI_Job__c tci= new TCI_Job__c();
        tci.Last_Job_Run_Date__c=System.now();
        tci.Job_Type__c='Manual';
        insert tci;
     
    }
}