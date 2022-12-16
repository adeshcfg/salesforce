/**************************************************************************************************
*
*  Class:   
*
*  @description : This class will populate the value if there are any future PTP records present
*  @author : A5E Consulting
*  @date : 01/15/2018   
*
*************************************************************************************************/
public Class IsFuturePTPPresent{
        
    @InvocableMethod(label='Future PTP' description='Checks the flag if Future PTP is present for the Product')
    public static void isFuturePTPAvailable(List<Product__c> prod){
        
        Product__c productData = [select id, name, Is_Future_PTP__c from Product__c where id =: prod[0].id];
        
        List<PTP_Information__c> listPTP = [select id, name, PTP_Date__c from PTP_Information__c where Product__c =: productData.ID and PTP_Date__C > Today];
        
        if(listPTP.size() > 0){
            productData.Is_Future_PTP__c = true;
        }else{
            productData.Is_Future_PTP__c = false;
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update productData;
        ProductTriggerHandler.runProductTrigger = true;

    }
}