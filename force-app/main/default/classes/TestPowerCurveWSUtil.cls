@isTest
public class TestPowerCurveWSUtil {
    
    private static Application_Form_Settings__c afSettings;
    private static Application__c app;
    
    static void insertTestData() {
        afSettings = new Application_Form_Settings__c(
            Power_Curve_Web_Service_URL__c = PowerCurveTestUtilities.Power_Curve_Web_Service_URL,
            Power_Curve_Username__c = PowerCurveTestUtilities.Power_Curve_Username, 
            Power_Curve_Password__c = PowerCurveTestUtilities.Power_Curve_Password, 
            Site_Profile_Id__c = '00eK0000000MDqzIAG'
        );
        insert afSettings;
        
        app = new Application__c(
            Salutation__c = 'Mr.', 
            First_Name__c = 'Rob', 
            Last_Name__c = 'Johnson', 
            Gender__c = 'Male',
            SIN__c = '123456789',
            Requested_Credit_Limit__c = 4500,
            Birth_Date__c = Date.today().addYears(-25), 
            Current_BKCP__c = false, 
            Marital_Status__c = 'Single', 
            Home_Phone__c = '416-555-1234', 
            Work_Phone__c = '416-555-4567', 
            
            Permanent_Address_Street_Number__c = '123', 
            Permanent_Address_Street_Name__c = 'Current St.', 
            Permanent_Address_City__c = 'Toronto', 
            Permanent_Address_Province__c = 'ON', 
            Permanent_Address_PostalCode__c = 'A1A 1A1', 
            Years_At_Permanent_Address__c = 0, 
            Months_At_Permanent_Address__c = 6, 
            Home_Owner__c = 'Rent', 
            Housing_Costs__c = 1000,
            
            Previous_Address_Street_Number__c = '456', 
            Previous_Address_Street_Name__c = 'Previous St.', 
            Previous_Address_City__c = 'Toronto', 
            Previous_Address_Province__c = 'ON', 
            Previous_Address_PostalCode__c = 'P1P 1P1', 
            Years_At_Previous_Address__c = 5, 
            Months_At_Previous_Address__c = 8, 
            
            Employment_Status__c = 'Full-time', 
            Employer_Name__c = 'ACME Co.', 
            Employment_Years__c = 0, 
            Employment_Months__c = 8, 
            Gross_Monthly_Income__c = 3000, 
            Employer_Street_Number__c = '1212', 
            Employer_Street_Name__c = 'Main St.', 
            Employer_City__c = 'Toronto', 
            Employer_Province__c = 'ON', 
            Employer_PostalCode__c = 'M2M 2M2',
            Employer_Phone__c = '416-555-4567',
            
            Previous_Employer_Name__c = 'ABC Computers', 
            Previous_Employment_Years__c = 4, 
            Previous_Employment_Months__c = 6, 
            Previous_Gross_Monthly_Income__c = 2000, 
            Previous_Employer_Street_Number__c = '4545', 
            Previous_Employer_Street_Name__c = 'Front St.', 
            Previous_Employer_City__c = 'Toronto', 
            Previous_Employer_Province__c = 'ON', 
            Previous_Employer_PostalCode__c = 'F2F 2F2'
        );
        insert app;
    }
    static testMethod void testValidCallout() {
        insertTestData();
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockReferResponse());
        PowerCurveWSUtil.DecisionResponse dr = PowerCurveWSUtil.submit('SFID0123456', app, PowerCurveWSUtil.Channel.SFExternal);
        Test.stopTest();
        
        PowerCurveTestUtilities.verifyReferResponse(dr);
    }
    
    static testMethod void testErrorCallout() {
        insertTestData();
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockErrorResponse());
        PowerCurveWSUtil.DecisionResponse dr = PowerCurveWSUtil.submit('SFID0123456', app, PowerCurveWSUtil.Channel.SFInternal);
        Test.stopTest();
        
        PowerCurveTestUtilities.verifyErrorResponse(dr);
        
        API_Error__c apiError = [
            select Id, End_Point__c, Action__c, Error__c, Request__c, Response__c 
            from API_Error__c where Application__c =: app.Id
        ];
        system.assertEquals('PCoD', apiError.End_Point__c);
        system.assertEquals('Create Application', apiError.Action__c);
        system.assertNotEquals(null, apiError.Error__c);
        system.assert(apiError.Request__c != null);
    }
    
    static testMethod void testChangeQueue() {
        insertTestData();
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockReferResponse());
        PowerCurveWSUtil.DecisionResponse dr = PowerCurveWSUtil.changeQueue('SFID0123456', app, PowerCurveWSUtil.Channel.SFExternal);
        
        PowerCurveTestUtilities.verifyReferResponse(dr);
        
        // Test error case
        
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockErrorResponse());
        dr = PowerCurveWSUtil.changeQueue('SFID0123456', app, PowerCurveWSUtil.Channel.SFExternal);
        Test.stopTest();
        
        PowerCurveTestUtilities.verifyErrorResponse(dr);

        API_Error__c apiError = [
            select Id, End_Point__c, Action__c, Error__c, Request__c, Response__c 
            from API_Error__c where Application__c =: app.Id
        ];
        system.assertEquals('PCoD', apiError.End_Point__c);
        system.assertEquals('Resubmit Application', apiError.Action__c);
        system.assertNotEquals(null, apiError.Error__c);
        system.assert(apiError.Request__c != null);
    }
    
    static testMethod void testChangeQueueRedecide() {
        insertTestData();
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockFullResponse());
        PowerCurveWSUtil.DecisionResponse dr = PowerCurveWSUtil.changeQueue('SFID0123456', app, PowerCurveWSUtil.Channel.SFExternal, true);
        Test.stopTest();
        
        PowerCurveTestUtilities.verifyFullResponse(dr);
    } 
    
    static testMethod void testChangeQueueRedecideIncorrectResponse() {
        insertTestData();
        
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, PowerCurveTestUtilities.getMockFullIncorrectResponse());
        PowerCurveWSUtil.DecisionResponse dr = PowerCurveWSUtil.changeQueue('SFID0123456', app, PowerCurveWSUtil.Channel.SFExternal, true);
        Test.stopTest();
        
        PowerCurveTestUtilities.verifyFullIncorrectResponse(dr);
    }
}