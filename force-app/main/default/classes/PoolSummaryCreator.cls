/**************************************************************************************************
*
*  Class:   
*
*  @description : This is PoolSummaryCreator of Pool object.
*  @author : A5E Consulting
*  @date : 06/07/2022

*************************************************************************************************/
public class PoolSummaryCreator {

    //@future
    public Static void populatePoolData(String poolId){
        
        //Fetch pool aggregate data     
        AggregateResult[] poolSummaryQuery = 
                                [Select Count(id) prodCnt, 
                                        Sum(Current_Balance__c) sumCurrentBal 
                                        from Product__c 
                                        Where Pool_Name__c =:poolId 
                                ];
        
        //Populate aggregate data on pool record
        Pool__c dbPool = new Pool__c();
        dbPool.id = poolId;
        dbPool.Placepool_Accounts__c = (decimal)poolSummaryQuery[0].get('prodCnt'); 
        dbPool.Placepool_Facevalue__c = (decimal)poolSummaryQuery[0].get('sumCurrentBal'); 
        
        //Updte pool record
        Update dbPool;
    }   
}