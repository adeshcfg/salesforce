/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class will schedule the DepositSlipAutoLock Class 
 *  @author : A5E Consulting
 *  @date : 10/11/2018
 * 
 *************************************************************************************************/
public class DepositSlipAutoLockScehdule implements Schedulable {
  
    public void execute(SchedulableContext sc) {
          DepositSlipAutoLock.DepositSlipLock();
        
    }

}