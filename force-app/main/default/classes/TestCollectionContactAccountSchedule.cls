/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Test Class for CollectionContactAccountSchedule   
*  @author : A5E Consulting
*  @date : 23/04/2019   

*************************************************************************************************/
@isTest
public class TestCollectionContactAccountSchedule {
    public Static testMethod void CollectionContactAccountSchedule(){
        
        CollectionContactAccountSchedule collconaccsch = new CollectionContactAccountSchedule();
         string sch = '24 00 * * * ?'; 
        /*CollectionContactAccountSchedule.SchedulerMethod();*/
         system.schedule('Test', sch, collconaccsch);
        
    }

}