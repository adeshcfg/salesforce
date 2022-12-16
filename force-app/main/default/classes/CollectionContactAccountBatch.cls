/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Class that calculates tasks and activities per delinquency cycle
*  @author : A5E Consulting
*  @date : 08/10/2017   

*************************************************************************************************/
public Class CollectionContactAccountBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([Select Id, No_of_times_contacted_for_collection__c,
                                        No_of_times_contact_collection_in_n_days__c, No_of_times_contacted__c
                                         from account]);
    }
    
    public void execute(Database.BatchableContext BC, List<Account> customerList){
        
        Collection_Custom_Setting__c collCustSett = Collection_Custom_Setting__c.getOrgDefaults();
        List<String> contactCountCodeList = collCustSett.Contact_Counter_Code__c.split(',');
        List<Account> listCustomer = new List<Account>();
        List<Product__c> listProduct = new List<Product__c>();
        
        // variables to optimise SOQL queries
        List<Id> accIds = new List<Id>();
        Map<Id, List<Product__c>> accountIdProductsMap = new Map<Id, List<Product__c>>();
        Map<Id, List<Task>> accountIdTasksMap = new Map<Id, List<Task>>();
        Map<Id, List<Task>> productIdTasksMap = new Map<Id, List<Task>>();
        List<Id> productIds = new List<Id>();
        // Store accoundIds
        for(Account acc : customerList){
            accIds.add(acc.Id);
        }

        // Account Id to Products Map
        for(Product__c prod : [SELECT id, Name, Delinquency_Cycles__c, Delinquency_Days__c,
                                                No_of_times_contacted__c, No_of_times_contacted_in_current_cycle__c,
                                                No_of_times_contact_collection_in_n_days__c,Customer__c
                                                FROM Product__c WHERE customer__c IN: accIds])
        {
            List<Product__c> tempList = new List<Product__c>();

            if( accountIdProductsMap.containsKey(prod.Customer__c) ){
                tempList = accountIdProductsMap.get(prod.Customer__c);
            }
            tempList.add(prod);
            accountIdProductsMap.put(prod.Customer__c, tempList);
            productIds.add(prod.Id);
        }

        // Account Id to Task Map
        // Product Id to Tasks Map
        for(Task tsk : [SELECT Id, Type_of_Activity__c, Subject, Type__c, CallType, 
                                        lastModifiedDate, CallClassification1__c,WhatId 
                                        FROM Task 
                                        WHERE 
                                            ( 
                                                (
                                                    WhatId IN: accIds AND 
                                                        (Type__c = 'Outgoing' OR CallType = 'Outbound')
                                                ) 
                                                OR 
                                                WhatId IN: productIds
                                            ) AND 
                                            isdeleted = FALSE 
                                            ])
        {
            List<Task> tempList = new List<Task>();
            // Account Related Tasks
            if( ( (string)tsk.WhatId).startsWith('001') ){
                
                if( accountIdTasksMap.containsKey(tsk.WhatId) ){
                    tempList = accountIdTasksMap.get(tsk.WhatId);
                }
                tempList.add(tsk);
                accountIdTasksMap.put(tsk.WhatId, tempList);
            }
            // Product Related Tasks
            else{
                if( productIdTasksMap.containsKey(tsk.WhatId) ){
                    tempList = productIdTasksMap.get(tsk.WhatId);
                }
                tempList.add(tsk);
                productIdTasksMap.put(tsk.WhatId, tempList);
            }
            
        }


             
        for(Account acc : customerList){
            List<Task> taskListAcc = new List<Task>();

            // Read account related tasks from Map
            if( accountIdTasksMap.containsKey(acc.Id) ){
                taskListAcc = accountIdTasksMap.get(acc.Id);
            }
            
            Integer totalAccContact = taskListAcc.size();
            //total number of times contacted for collection
            Integer collectionAccCount = 0;
            Integer totalAccCollectionCount = 0;
            List<Product__c> prodList = new List<Product__c>();
            if( accountIdProductsMap.containsKey(acc.Id) ){
                prodList = accountIdProductsMap.get(acc.Id);
            }

            DateTime delinquentDate = null;
            for(Product__C prod : prodList){
                List<Task> taskListProd = new List<Task>();
                if( productIdTasksMap.containsKey(prod.Id) ){
                    taskListProd = productIdTasksMap.get(prod.Id);
                }
                // [Select Id, Type_of_Activity__c, Subject, Type__c, CallType, lastModifiedDate, CallClassification1__c From Task where WhatId =: prod.id and isdeleted=false];
                
                //total number of times contacted for collection
                Integer collectionCount = 0;
                Integer totalCollectionCount = 0;
                Integer totalDelinquentCount = 0;
                
                if(null == prod.Delinquency_Days__c){
                    delinquentDate = system.now();
                }else{
                    delinquentDate = system.now() - prod.Delinquency_Days__c;
                }
                
                //(Subject like 'Send Email%' or Subject like 'Print Email%' )
                for(Task tsk : taskListProd){
                    if((tsk.Subject.contains('Send Email')) || (tsk.Subject.contains('Print Email'))){
                        totalCollectionCount++;
                        if(tsk.lastModifiedDate > (system.now() - collCustSett.Last_n_Days__c)){
                            collectionCount++;
                        }
                        if(tsk.lastModifiedDate > delinquentDate){
                            totalDelinquentCount++;
                        }
                    }
                }
                
                prod.No_of_times_contacted__c = totalCollectionCount;
                prod.No_of_times_contact_collection_in_n_days__c = collectionCount;
                prod.No_of_times_contacted_in_current_cycle__c = totalDelinquentCount;
                
                listProduct.add(prod);
            }
            
            for(Task tsk : taskListAcc){
                if((tsk.Subject.contains('Collection') || (tsk.Type_of_Activity__c == 'Collection'))){
                    for(String contactCode : contactCountCodeList){
                        if(contactCode == tsk.CallClassification1__c){
                            if(tsk.lastModifiedDate > delinquentDate){
                                totalAccCollectionCount++;
                            }
                            if(tsk.lastModifiedDate > (system.now() - collCustSett.Last_n_Days__c)){
                                collectionAccCount++;
                            }
                            break;
                        }
                    }
                }
            }
            
            acc.No_of_times_contacted_for_collection__c = totalAccCollectionCount;
            acc.No_of_times_contact_collection_in_n_days__c = collectionAccCount;
            acc.No_of_times_contacted__c = totalAccContact;
            listCustomer.add(acc);
            
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update listProduct;
        ProductTriggerHandler.runProductTrigger = true;
        CustomerTriggerHandler.runCustomerTrigger = false;
        update listCustomer;
        CustomerTriggerHandler.runCustomerTrigger = true;
    }
    
    public void finish(Database.BatchableContext BC){
        //Database.executeBatch(New CollectionContactProductBatch(), 50);
    }
}