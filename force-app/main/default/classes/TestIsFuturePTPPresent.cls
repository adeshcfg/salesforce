/**************************************************************************************************
 *
 *  Class:  TestIsFuturePTPPresent 
 *
 *  @description : This is a testclass for IsFuturePTPPresent.
 *  @author : A5E Consulting
 *  @date : 02/22/2018
 *  
 
 *************************************************************************************************/

@isTest
public class TestIsFuturePTPPresent {

  //Positive Testing
  static testMethod void testMethodPositive(){
      
        // insert product record
        Product__c productdata = new Product__c(Name = 'Test-123', Is_Future_PTP__c= false);
        insert productdata;
        list<Product__c> productlist = new list<Product__c>();
        productlist.add(productdata);
      
        // insert ptp information record
        PTP_Information__c ptp_infodata = new PTP_Information__c();
        ptp_infodata.PTP_Date__c = system.today()+1;
        ptp_infodata.Product__c = productdata.id;
        insert ptp_infodata;
        
        list<PTP_Information__c> ptp_infolist = new list<PTP_Information__c>();
        ptp_infolist.add(ptp_infodata);
        
        if(ptp_infolist.size()>0)
        {
            productdata.Is_Future_PTP__c = true;
        }
        update productdata;
        IsFuturePTPPresent.isFuturePTPAvailable(productlist);
    }
    
    //Negative Testing
    static testMethod void testMethodNegative(){
    
        Product__c productdata = new Product__c(Name = 'Test-123');
        insert productdata;
        list<Product__c> productlist = new list<Product__c>();
        productlist.add(productdata);
        
        PTP_Information__c ptp_infodata = new PTP_Information__c();
        ptp_infodata.PTP_Date__c = system.today();
        ptp_infodata.Product__c = productdata.id;
        insert ptp_infodata;
        
        list<PTP_Information__c> ptp_infolist = new list<PTP_Information__c>();
        ptp_infolist.add(ptp_infodata);
        
        if(ptp_infoList.size()==null){
                    productdata.Is_Future_PTP__c = false;
        }
        update productdata;
        IsFuturePTPPresent.isFuturePTPAvailable(productlist);
    }
}