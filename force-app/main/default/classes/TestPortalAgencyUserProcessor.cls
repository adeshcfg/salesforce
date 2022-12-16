@isTest
public class TestPortalAgencyUserProcessor {
     public static testMethod void testPortalAgencyUser(){        
        RestRequest req = new RestRequest ();
        RestResponse res = new RestResponse();
        system.debug('req: '+req);
        String jsonTokenResponse = '{"First_Name":"Test", "Last_Name": "Test Agency User",'+
                                    '"Created_By": "TestABC","Is_Active": "True","Last_Modified_By": "test",'+
                                    '"Email_Address": "test@gmail.com","Role": "Regular User","Placement_Identifier":null}';      
                                    
        system.debug('JSONPaymentTransaction: '+jsonTokenResponse);
        req.requestBody  = Blob.valueof(jsonTokenResponse);
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;
        
        PortalAgencyUserProcessor.postAgencyUser();
    }
    
    public static testMethod void testPortalAgencyUtil(){  
        
        Placement__c plcmnt= new Placement__c();      
        plcmnt.Name='89';       
        insert plcmnt;
        
        Agency_User__c agusr = new Agency_User__c();       
        agusr.Placement__c = plcmnt.id;
        agusr.Email_Address__c = 'test@gmail.com';
        agusr.Role__c = 'Regular User';       
        AgencyUserTriggerHandler.runAgencyUserTrigger = false;
        insert agusr;
        AgencyUserTriggerHandler.runAgencyUserTrigger = true;
        
        map<String, String> paramMap = new map<String, String>();
        paramMap.put('First_Name', 'Test');
        paramMap.put('Last_Name','Test Agency User');
        paramMap.put('Created_By','TestABC');
        paramMap.put('Last_Modified_By','test');
        paramMap.put('Email_Address','test@gmail.com');
        paramMap.put('Role','Regular User');
        paramMap.put('Placement_Identifier',null);
        paramMap.put('Is_Active','True');
        PortalAgencyUserProcessorUtil.processAgencyUser(paramMap, agusr);
    }

}