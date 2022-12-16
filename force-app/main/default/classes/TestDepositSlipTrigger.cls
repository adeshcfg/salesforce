@isTest
public class TestDepositSlipTrigger { 
    
    @isTest public static void TestDepositSlip()
    {
        Application_Config_Settings__c ccsettings=new Application_Config_Settings__c(Run_Deposit_Slip_Trigger__c=True);
        insert ccsettings;
        ccsettings.Run_Deposit_Slip_Trigger__c=true;
        update ccsettings;
        system.debug(ccsettings.Run_Deposit_Slip_Trigger__c);
        
        DepositSlipTriggerHandler.runDepsoitSlipTrigger=true;
        system.debug(DepositSlipTriggerHandler.runDepsoitSlipTrigger);
        
        
        Profile profileId2 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User sa = new User(LastName = 'User1',
                           FirstName='Test1',
                           Alias = 'utest1',
                           Email = 'test1.user@asdf.com',
                           Username = 'test1.user@asdf.com',
                           ProfileId = profileId2.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                          );
        //System.runAs(sa){
        Id rid=[Select Id From RecordType where sobjecttype = 'Deposit_Slip__c' limit 1].id;
        Deposit_Slip__c depslip=new Deposit_Slip__c();
        depslip.RecordTypeId=rid;
        insert depslip;
        
        delete depslip;
        
        //}
    }
}