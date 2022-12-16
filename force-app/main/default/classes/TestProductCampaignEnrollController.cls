/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a test class for ProductCampaignEnrollController
 *  @author : A5E Consulting
 *  @date : 04/14/2020
 
 *************************************************************************************************/ 
@isTest
public class TestProductCampaignEnrollController {

    //Application record
    private static Product__c capgnProd;
       
    //Dummy Camapign Code
    private static String cCode= 'CB12345';
    
    //Inserting Product record
    static void insertTestdata(){
    
        RecordType ccProductType = [select Id from RecordType where SObjectType = 'Product__c' and Name = 'Credit Card Account' limit 1];
        
        capgnProd = new Product__c(
            First_Name__c = 'FirstName', 
            Last_Name__c = 'LastName',
            Campaign_Code__c = cCOde,
            Campaign_Enroll_Status__c = 'Pending',
            Campaign_Expiration_Date__c = System.Today().addMonths(6),
            RecordTypeId = ccProductType.Id 
            );
        insert capgnProd ;
        
    }
         
    //Test Method
    static testmethod void testVerify(){
    
        //Success
        insertTestdata();
        ApexPages.currentPage().getParameters().put('cCode', cCode);
        ProductCampaignEnrollController cntrl = new ProductCampaignEnrollController();
        cntrl.checkVerifyRequest();
        
        //Link Expired
        capgnProd.Campaign_Expiration_Date__c = System.Today().addDays(-1);       
        update capgnProd;
        ApexPages.currentPage().getParameters().put('cCode', cCode);
        cntrl = new ProductCampaignEnrollController();
        cntrl.checkVerifyRequest();  
        
        //Already Verified
        capgnProd.Campaign_Enroll_Status__c = 'Enrolled';        
        update capgnProd;
        ApexPages.currentPage().getParameters().put('cCode', cCode);
        cntrl = new ProductCampaignEnrollController();
        cntrl.checkVerifyRequest();
                                
        //No Campaign Code value
        ApexPages.currentPage().getParameters().put('cCode', null);
        cntrl = new ProductCampaignEnrollController();
        cntrl.checkVerifyRequest();  
                
        //Wrong Campaign Code value
        ApexPages.currentPage().getParameters().put('cCode', 'abcd1234');
        cntrl = new ProductCampaignEnrollController();
        cntrl.checkVerifyRequest(); 
    }
}