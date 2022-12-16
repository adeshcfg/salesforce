global class PoolSummaryBatchClass implements Database.Batchable<Pool__c>,Database.AllowsCallouts{
	
    List<Pool__c> listPool = new List<Pool__c>();
    List<Pool__c> PoolRec = new List<Pool__c>();
    List<String> setPool = new List<String>();
     public List<Pool__c> start(Database.BatchableContext BC) {
		listPool = [Select id,name from Pool__c]; 
         system.debug('listPool test::' +listPool);
         
        return listPool;
    }
    public void execute(Database.BatchableContext BC,List<Pool__c> listPool) {
       system.debug('listPool::'+listPool);
       system.debug('block run');
        for(Pool__c poolList : listPool){
             setPool.add(poolList.id);
         }
       
        Map<String, AggregateResult> productSumTotal = new Map<String, AggregateResult>();
        
        for(AggregateResult aggr : [SELECT Pool_Name__c, Count(Pool_Name__r.Name) poolCnt, sum(Current_Balance__c) totalBalance
                                    FROM Product__c 
                                    WHERE 
                                    Pool_Name__c IN :setPool
                                   GROUP BY Pool_Name__c]){
            system.debug('aggr check::'+aggr);
            
            Pool__c pool=new Pool__c();
            pool.Id=(id)aggr.get('Pool_Name__c'); 
            pool.Placepool_Accounts__c = (decimal)aggr.get('poolCnt');
            pool.Placepool_Facevalue__c = (decimal)aggr.get('totalBalance');
            PoolRec.add(pool);        
        }
        PoolTriggerHandler.runPoolTrigger = false;       
        update PoolRec;
        PoolTriggerHandler.runPoolTrigger = true;       
        
    }
     public void finish(Database.BatchableContext BC){
        
     }

}