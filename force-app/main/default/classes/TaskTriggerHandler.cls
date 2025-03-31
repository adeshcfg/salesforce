/**************************************************************************************************
*
*  Trigger:   
*
*  @description : This is a Trigger Handler Class for Task and Activities object 
*  @author : A5E Consulting
*  @date : 29/08/2016
* 
*************************************************************************************************/

public class TaskTriggerHandler{
    
    public static Loan_ReEngineering__c lrpSetting = Loan_ReEngineering__c.getOrgDefaults();
    public static Collection_Custom_Setting__c collCustSett = Collection_Custom_Setting__c.getOrgDefaults();
    public static Docomotion_Custom_Setting__c docomotionCS = Docomotion_Custom_Setting__c.getOrgDefaults();
    public static Distress_Setting__c distressCS = Distress_Setting__c.getOrgDefaults();
    
    //Changes for: Ticket#309 All Tasks List
    public static void handleBeforeInsert(List<Task> taskNew1){
        Set<Id> setOfWhatIdIds = new Set<Id>();
        Map<Id, List<Task>> mapOfWhatIdIdAndTask = new Map<Id, List<Task>>();
        for(Task tsk : taskNew1){
            String whatId = tsk.WhatId;
            System.debug('whatId:: '+whatId);
            if(whatId.startsWith('a11')){
                setOfwhatIdIds.add(tsk.whatId);
                if(mapOfWhatIdIdAndTask.containsKey(tsk.whatId)){
                    mapOfWhatIdIdAndTask.get(tsk.whatId).add(tsk);
                }else{
                    mapOfWhatIdIdAndTask.put(tsk.whatId, new List<Task>{tsk});
                }                
            }
        }
        System.debug('mapOfWhatIdIdAndTask:: '+mapOfWhatIdIdAndTask);
        List<Insolvency_Account__c> listOfInsolvencyAccounts = [SELECT Id FROM Insolvency_Account__c WHERE Id in: setOfwhatIdIds
                                                               AND (Client_Identifier__c = 'Scotia Bank'
                                                                   OR Client_Identifier__c = 'Canaccede'
                                                                   OR Client_Identifier__c = 'SPL'
                                                                   OR Client_Identifier__c = 'SDA')];
        List<Task> tasksToUpdate = new List<Task>();
        for(Insolvency_Account__c insolAcc : listOfInsolvencyAccounts){
            tasksToUpdate.addAll(mapOfWhatIdIdAndTask.get(insolAcc.Id));
        }
        for(Task tsk : tasksToUpdate){
            tsk.IsVisibleInSelfService = true;
        }
        
        List<String> DistressedTaskList1 = distressCS.Distressed_Task_Eligible_Objects__c.split(',');
        
        system.debug('Final Distress '+DistressedTaskList1[0]);
        
        if(collCustSett.Run_Task_Trigger__c == true){
            
            
            // Product__c prodList = new Product__c();
            List<String> forObjId = new List<String>();
            for(Task forId : taskNew1){
                
                if(forId.whatID !=Null){
                    String objId =forId.whatID;
                    
                    forObjId.add(objId.substring(0,3));
                    
                    //forObjId.add(objId.substring(0,objId.length()-15));
                }
                
            }
            
            system.debug('Final OBJ ' +forObjId);
            map<id,Product__c> zeroArrayMap= new map<id,Product__c>();
            map<id,Product__c> oneArrayMap= new map<id,Product__c>();
            map<id,Product__c> twoArrayMap= new map<id,Product__c>();
            set<id> taskIdsZeroArray=new set<id>();
            set<id> taskIdsFirstArray=new set<id>();
            set<id> taskIdsSecondArray=new set<id>();
            for(Task tskForId : taskNew1){
                for(String disTask : forObjId){
                    if(DistressedTaskList1[0] == disTask){
                        taskIdsZeroArray.add(tskForId.whatid);
                    }
                        else if(DistressedTaskList1[1] == disTask){
    taskIdsFirstArray.add(tskForId.whatid);
    }
    else if(DistressedTaskList1[2] == disTask){
    taskIdsSecondArray.add(tskForId.whatid);
    }
                }
            }  
            if(!taskIdsZeroArray.isEmpty()){
                for(Product__c Product : [select id,Collection_Agency__c,recordType.name,First_Name__c,Last_Name__c,Originating_Creditor__c from Product__c where id IN: taskIdsZeroArray]){
                    zeroArrayMap.put(Product.id,Product); 
                }
                for(Product__c ProductList:zeroArrayMap.values()){
                    if(ProductList.recordType.Name.contains('Distressed')){
                        for(Task t : taskNew1){
                            t.Collection_Agency__c = 'A'+ String.ValueOf(zeroArrayMap.get(t.whatid).Collection_Agency__c) +'A';
                            t.First_Name__c = String.ValueOf(zeroArrayMap.get(t.whatid).First_Name__c);
                            t.Last_Name__c = String.ValueOf(zeroArrayMap.get(t.whatid).Last_Name__c);
                            t.Seller__c = String.ValueOf(zeroArrayMap.get(t.whatid).Originating_Creditor__c);
                        }
                    }
                }
                                  
            }
            if(!taskIdsFirstArray.isEmpty()){
                map<id,Judgment__c> JudgMap=new map<id,Judgment__c>();
      map<id,Account_Judgment__c> AccJudgMap=new map<id,Account_Judgment__c>();
      for(Judgment__c judgeList : [select id,Collection_Agency_Identifier__c from Judgment__c where id IN: taskIdsFirstArray]){
          JudgMap.put(judgeList.id, judgeList);
      }
      for(Account_Judgment__c AccJudgList : [select id,Judgment__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Account_Judgment__c where Judgment__c IN:  JudgMap.keyset() order by createddate asc]){
          AccJudgMap.put(AccJudgList.Judgment__c , AccJudgList); 
      }
      for(Judgment__c judgeList1:JudgMap.values()){
          Account_Judgment__c AccJudgList1=AccJudgMap.get(judgeList1.id);
              for(Task t : taskNew1){
                  t.Collection_Agency__c = String.ValueOf(judgeList1.Collection_Agency_Identifier__c);
                  t.First_Name__c = String.ValueOf(AccJudgList1.Product__r.First_Name__c);
                  t.Last_Name__c = String.ValueOf(AccJudgList1.Product__r.Last_Name__c);
                  t.Seller__c = String.ValueOf(AccJudgList1.Product__r.Originating_Creditor__c);
                  
              }            
          
      }
      ///system.debug('LIST ACCOUNT_judgment '+AccJudgList1);
  }
  
if(!taskIdsSecondArray.isEmpty()){
    set<id> judgeIDs=new set<id>();
    map<id,Settlement__c> settleMapNew=new map<id,Settlement__c>();
    map<id,Account_Judgment__c> AccJudgMap=new map<id,Account_Judgment__c>();
    for(Settlement__c settleList2 : [select id,Product__c,Judgment__c,Judgment_Collection_Agency_Identifier__c,Product_Collection_Agency_Identifier__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Settlement__c  where id IN: taskIdsSecondArray]){
        judgeIDs.add(settleList2.Judgment__c);
        settleMapNew.put(settleList2.id,settleList2);
        system.debug('List OF settlement ' +settleList2);
    }
    if(!judgeIDs.isEmpty()){
        for(Account_Judgment__c AccJudgList2 : [select id,Judgment__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Account_Judgment__c where Judgment__c IN: judgeIDs order by createddate asc]){
        AccJudgMap.put(AccJudgList2.Judgment__c,AccJudgList2);
        }
        for(Settlement__c settleList:settleMapNew.values()){
           Account_Judgment__c AccJudgList1=AccJudgMap.get(settleList.Judgment__c);
        for(Task t : taskNew1){
                if(settleList.Product__c != Null){
                    
                    t.Collection_Agency__c = String.ValueOf(settleList.Product_Collection_Agency_Identifier__c); 
                    t.First_Name__c = String.ValueOf(settleList.Product__r.First_Name__c);
                    t.Last_Name__c = String.ValueOf(settleList.Product__r.Last_Name__c);
                    t.Seller__c = String.ValueOf(settleList.Product__r.Originating_Creditor__c);
                    
                }else if(settleList.Judgment__c !=Null){
                    t.Collection_Agency__c = String.ValueOf(settleList.Judgment_Collection_Agency_Identifier__c);
                    t.First_Name__c = String.ValueOf(AccJudgList1.Product__r.First_Name__c);
                    t.Last_Name__c = String.ValueOf(AccJudgList1.Product__r.Last_Name__c);
                    t.Seller__c = String.ValueOf(AccJudgList1.Product__r.Originating_Creditor__c);
                    
                    
                }
            }
        }
        
        }
    }
}

        }
        
    

    //Handle after insert
    public static void handleAfterInsert(List<Task> taskNew) {
        
            List<Product__c> listProd = new List<Product__c>();
        List<Account> listAcc = new List<Account>();
        List<String> contactCountCodeList = collCustSett.Contact_Counter_Code__c.split(',');
        map<id,product__c> taskMapa0D=new map<id,product__c>();
        set<id> taska0D=new set<id>();
        set<id> task001=new set<id>();
        map<id,product__c> taskMap001=new map<id,product__c>();
        if(collCustSett.Run_Task_Trigger__c == true){
            
            for(Task tsk : taskNew){
                if(null != tsk.whatid){
                    if(String.valueOf(tsk.whatid).startsWith('a0D') && tsk.status != 'Generated by Docomotion'){
                        taska0D.add(tsk.whatid);                       
                    }
                    else if(String.valueOf(tsk.whatid).startswith('001')){
                        task001.add(tsk.whatid);
                    }                    
                    //for Docomotion to populate document type on attachment
                    //a1c for settlement, a1Y for Judgment and a0D for Product
                    List<String> listwhatIDforObject = docomotionCS.Document_type_for_objects__c.split(',');
                    
                    for(String startValue : listwhatIDforObject ){
                        if(String.valueOf(tsk.whatid).startsWith(startValue)){
                            if(tsk.status == 'Generated by Docomotion' && tsk.subject.contains('Docomotion')){
                                updateDocumentDescription(tsk.id);
                            }
                        }
                    }
                    
                }
            }
            if(!taska0D.isEmpty()){
                map<id,Product__c> prodMap=new map<id,Product__c>();
                list<Product__c> prod = [select id, Delinquency_Cycles__c, Delinquency_Days__c,
                                         No_of_times_contacted__c, No_of_times_contacted_in_current_cycle__c,
                                         No_of_times_contact_collection_in_n_days__c
                                         from Product__c where id IN : taska0D];
                for(Product__c p: prod){
                    prodMap.put(p.id,p);
                }
                
                for(Task tsk : taskNew){
                    
                    if((tsk.Subject.contains('Send Email')) || (tsk.Subject.contains('Print Email'))){
                        if(null == prodMap.get(tsk.WhatId).No_of_times_contacted__c){
                            prodMap.get(tsk.WhatId).No_of_times_contacted__c = 1;
                        }else{
                            prodMap.get(tsk.WhatId).No_of_times_contacted__c++;
                        }
                        if(null == prodMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c){
                            prodMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c = 1;
                        }else{
                            prodMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c++;
                        }
                        if(prodMap.get(tsk.WhatId).Delinquency_Cycles__c > 0){
                            if(null == prodMap.get(tsk.WhatId).No_of_times_contacted_in_current_cycle__c ){
                                prodMap.get(tsk.WhatId).No_of_times_contacted_in_current_cycle__c = 1;
                            }else{
                                prodMap.get(tsk.WhatId).No_of_times_contacted_in_current_cycle__c++;
                            }
                        }
                    }
                    for(Product__c p:prodMap.values()){
                        if(listProd.contains(p)){
                            //do nothing    
                        }else{
                            listProd.add(p);
                        }
                    }
                }
            }
            if(!task001.isEmpty()){
                map<id,Account> accMap=new map<id,Account>();
                list<Account> acc = [select id,
                                     No_of_times_contacted_for_collection__c,
                                     No_of_times_contact_collection_in_n_days__c, No_of_times_contacted__c
                                     from account where id IN: task001];
                for(Account a: acc){
                    accMap.put(a.id, a);
                }
                for(Task tsk : taskNew){
                    
                    if(null == accMap.get(tsk.WhatId).No_of_times_contacted__c){
                        accMap.get(tsk.WhatId).No_of_times_contacted__c = 1;
                    }else{
                        accMap.get(tsk.WhatId).No_of_times_contacted__c++;
                    }
                    if((tsk.Subject.contains('Collection') || (tsk.Type_of_Activity__c == 'Collection'))){
                        for(String contactCode : contactCountCodeList){
                            if(contactCode == tsk.CallClassification1__c){
                                
                                if(null == accMap.get(tsk.WhatId).No_of_times_contacted_for_collection__c){
                                    accMap.get(tsk.WhatId).No_of_times_contacted_for_collection__c = 1;
                                }else{
                                    accMap.get(tsk.WhatId).No_of_times_contacted_for_collection__c++;
                                }
                                if(null == accMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c){
                                    accMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c = 1;
                                }else{
                                    accMap.get(tsk.WhatId).No_of_times_contact_collection_in_n_days__c++;
                                }
                                break;
                            }
                        }
                    }
                    for(Account a:accMap.values()){
                        if(listAcc.contains(a)){
                            //do nothing    
                        }else{
                            listAcc.add(a);
                        }
                    }
                }
                
            }
            ProductTriggerHandler.runProductTrigger = false;
            update listProd;
            ProductTriggerHandler.runProductTrigger = true;
            update listAcc;
            
        }
        
    }
    
    // Validating current context user
    public static Boolean isCanaccedeAPIUser(){
        String uName = userInfo.getUserName();
        System.debug('uName :'+uName);
        if(uName.equalsIgnoreCase(lrpSetting.Canaccede_API_User__c)){
            return true;
        }
        return false;
    }
    
    //Future method to get documetns generated after task generation 
    @Future
    private static void updateDocumentDescription(Id taskID){
        
        List<ContentDocumentLink> ConDocLnk = new List<ContentDocumentLink>();
        List<ContentDocument> ConDoc = new List<ContentDocument>();
        List<ContentDocument> ConDoctoUpdate = new List<ContentDocument>();
        
        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 60000; // 60-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }
        
        Task tsk = [select id, subject, status, whatId, createdDate from Task where id =: taskID];
        ConDocLnk = new List<ContentDocumentLink>();
        ConDoc = new List<ContentDocument>();
        
        dateTime createdDateValueSub = tsk.createdDate.addSeconds(-60);
        system.debug('Created Date : ' + createdDateValueSub);
        dateTime createdDateValueAdd = tsk.createdDate.addSeconds(60);
        system.debug('Created Date : ' + createdDateValueAdd );
        
        ConDocLnk=[SELECT id,LinkedEntityId,ContentDocumentId,Visibility, ShareType FROM ContentDocumentLink WHERE LinkedEntityId =: tsk.whatid and SystemModstamp <= :createdDateValueAdd and SystemModstamp > :createdDateValueSub]; 
        System.debug('ConDoc : ' + ConDoc);
        
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : ConDocLnk) 
        {      
            nextCDL.Visibility='AllUsers'; 
            CDIdList.add(nextCDL.ContentDocumentId); 
        }
        
        system.debug('CDIdList : ' + CDIdList);
        system.debug('Created Date : ' + tsk.createdDate);
        
        ConDoc = [SELECT Id, Title, FileType,Description,CreatedDate,LastModifiedDate FROM ContentDocument WHERE Id IN :CDIdList and createdDate <= :createdDateValueAdd and createdDate > :createdDateValueSub];
        System.debug('ConDoc : ' + ConDoc);
        
        if(conDoc.size() > 0){
            ConDoc[0].Description = tsk.subject.split('-')[0];
            
            ConDoctoUpdate.add(ConDoc[0]);
        }
        
        update ConDoctoUpdate;
    }
    }