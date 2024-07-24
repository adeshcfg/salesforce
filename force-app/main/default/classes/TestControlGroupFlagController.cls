@isTest 
public class TestControlGroupFlagController {
    
    @testSetup 
    static void setup() {
        PermissionSet permSet;
        try {
            permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Control_Group_Flag' LIMIT 1];
        } catch (Exception e) {
            permSet = new PermissionSet(
                Name = 'Control_Group_Flag',
                Label = 'Control Group Flag'
            );
            insert permSet;
        }
        
        // user with the Control_Group_Flag permission set
        
        User userWithPermSet = new User(
            FirstName = 'control',
            LastName = 'Group',
            Username = 'controlGroup@test.com',
            Email = 'controlGroup@test.com',
            Alias = 'flag',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert userWithPermSet;
        
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment(
            AssigneeId = userWithPermSet.Id,
            PermissionSetId = permSet.Id
        );
        insert permSetAssign;
        
        //user without the Control_Group_Flag permission set
        User userWithoutPermSet = new User(
            FirstName = 'control',
            LastName = 'control2',
            Username = 'controlGroup2@test.com',
            Email = 'controlGroup2@test.com',
            Alias = 'flag',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert userWithoutPermSet;
        
    }
    
    
    @isTest 
    static void testControlGroupFlagUser() {
        
        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c']
        );
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c();
        insolvAcc.RecordTypeId = recordTypeList[0].Id;
        insolvAcc.Name = 'Test- 001';
        insolvAcc.Control_Group__c = true;
        insolvAcc.Insolvency_Status__c = 'New';
        insolvAcc.Claim_Type__c = 'Secured';
        insolvAcc.Claim_Amount__c = 1000;
        
        insert insolvAcc;  
        
        
        User userWithPermSet = [SELECT Id FROM User WHERE Username = 'controlGroup@test.com' LIMIT 1];
        System.runAs(userWithPermSet) {
            PageReference pageRef = Page.controlGroupflag; 
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController([SELECT Id FROM Insolvency_Account__c LIMIT 1]);
            ControlGroupFlagController controller = new ControlGroupFlagController(sc);
            
            System.assert(controller.hasControlGroupFlag == true, 'control group true.');
        }
    }
    
    @isTest
    static void testNonControlGroupFlagUser() {
        
        list<RecordType> recordTypeList = new List<RecordType>(
            [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Insolvency_Account__c']
        );
        Insolvency_Account__c insolvAcc = new Insolvency_Account__c();
        insolvAcc.RecordTypeId = recordTypeList[0].Id;
        insolvAcc.Name = 'Test- 001';
        insolvAcc.Control_Group__c = true;
        insolvAcc.Insolvency_Status__c = 'New';
        insolvAcc.Claim_Type__c = 'Secured';
        insolvAcc.Claim_Amount__c = 1000;
        
        insert insolvAcc;               
        
        User userWithoutPermSet = [SELECT Id FROM User WHERE Username = 'controlGroup2@test.com' LIMIT 1];
        System.runAs(userWithoutPermSet) {
            PageReference pageRef = Page.controlGroupflag; 
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController sc = new ApexPages.StandardController([SELECT Id FROM Insolvency_Account__c LIMIT 1]);
            ControlGroupFlagController controller = new ControlGroupFlagController(sc);
            
            System.assert(controller.hasControlGroupFlag == false, 'control group false.');
        }
    }
}