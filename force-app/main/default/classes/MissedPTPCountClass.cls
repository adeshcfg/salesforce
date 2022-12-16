/**************************************************************************************************
*
*  Class:   
*
*  @description : This class will populate the value of Missed PTP Count if there are any consugative Missed PTP
*  @author : A5E Consulting
*  @date : 01/15/2018   
*
*************************************************************************************************/
public Class MissedPTPCountClass{
        
    @InvocableMethod(label='Missed PTP' description='Count of Continueous Missed PTP in last month')
    public static void isFuturePTPAvailable(List<Product__c> prod){
        
        Product__c productData = [select id, name, Missed_PTP_Count__c from Product__c where id =: prod[0].id];
        
        List<PTP_Information__c> listPTP = [select id, name, PTP_Date__c, PTP_Mate__c from PTP_Information__c where Product__c =: productData.ID 
                                            and (( PTP_Date__C < Today and PTP_Date__c = THIS_MONTH) or PTP_Date__c = LAST_MONTH )
                                            order by PTP_Date__c desc];
        
        if(listPTP.size() > 0){
            
            productData.Missed_PTP_Count__c = 0;
            for(PTP_Information__c ptp : listPTP){
                if(ptp.PTP_Mate__c == false){
                    productData.Missed_PTP_Count__c = productData.Missed_PTP_Count__c + 1;
                }else{
                    break;
                }
            }
            
        }else{
            productData.Missed_PTP_Count__c = 0;
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update productData;
        ProductTriggerHandler.runProductTrigger = true;

    }
}