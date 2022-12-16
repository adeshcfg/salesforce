/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Deposit_Slip object 
 *  @author : A5E Consulting
 *  @date : 01/03/2019
 
 *************************************************************************************************/
 
public class DepositSlipTriggerHandler {

    public static boolean runDepsoitSlipTrigger = true; 
    
    //Before Delete   
    public static void handleBeforeDelete(List<Deposit_Slip__C> depositSlipList, Map<Id, Deposit_Slip__C> oldMap) {
        Profile profileInfo = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() limit 1];
        
        //Loan re-engineering
        if('System Administrator' != profileInfo.Name){
            for(Deposit_Slip__C ds : oldMap.values()){
                ds.addError('You can not delete Deposit slip Records', false);
            }
        }
    }
}