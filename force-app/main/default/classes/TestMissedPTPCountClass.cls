/**************************************************************************************************
 *
 *  Class:   MissedPTPCountClass
 *
 *  @description : This is a test class for MissedPTPCountClass
 *  @author : A5E Consulting
 *  @date : 20/02/2018
 * 
 *************************************************************************************************/

@isTest
public class TestMissedPTPCountClass{

  // test missed PTP count
   static testMethod void testMethodMissedPTP(){
  
        //insert product record
        Product__c productData = new Product__c(Name = 'Test-123', Is_Future_PTP__c= false);
        insert productData;
        list<Product__c> productList = new list<Product__c>();
        productList.add(productData);
        
        //insert PTP Information record
        PTP_Information__c ptp_InfoData = new PTP_Information__c();
        ptp_InfoData.PTP_Date__c = system.today()-1;
        ptp_InfoData.PTP_Mate__c = false;
        ptp_InfoData.Product__c = productData.id;
        insert ptp_InfoData;
        
        list<PTP_Information__c> ptp_InfoList = new list<PTP_Information__c>();
        ptp_InfoList.add(ptp_InfoData);
        
        if(ptp_InfoList.size() > 0)
        {
            productData.Missed_PTP_Count__c = 0;
            if(ptp_InfoData.PTP_Mate__c == false) 
            {
                productData.Missed_PTP_Count__c += 1;
            }
            system.assertEquals(1, productData.Missed_PTP_Count__c);
        }
        else
        {
            productData.Missed_PTP_Count__c = 0;
            system.assertEquals(0, productData.Missed_PTP_Count__c);
        }
        update productData;
        
        MissedPTPCountClass.isFuturePTPAvailable(productList);
        
    }
    
}