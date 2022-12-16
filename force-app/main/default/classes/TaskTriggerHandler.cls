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
            
            for(Task tskForId : taskNew1){
                for(String disTask : forObjId){
                    if(DistressedTaskList1[0] == disTask){
                        for(Product__c ProductList : [select id,Collection_Agency__c,recordType.name,First_Name__c,Last_Name__c,Originating_Creditor__c from Product__c where id =: tskForId.whatid]){
                            if(ProductList.recordType.Name.contains('Distressed')){
                                for(Task t : taskNew1){
                                    t.Collection_Agency__c = 'A'+ String.ValueOf(ProductList.Collection_Agency__c) +'A';
                                    t.First_Name__c = String.ValueOf(ProductList.First_Name__c);
                                    t.Last_Name__c = String.ValueOf(ProductList.Last_Name__c);
                                    t.Seller__c = String.ValueOf(ProductList.Originating_Creditor__c);
                                }
                            }
                        } 
                    }else if(DistressedTaskList1[1] == disTask){
                        for(Judgment__c judgeList : [select id,Collection_Agency_Identifier__c from Judgment__c where id =: tskForId.whatid]){
                            for(Account_Judgment__c[] AccJudgList : [select id,Judgment__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Account_Judgment__c where Judgment__c =:  tskForId.whatid order by createddate asc]){
                                for(Task t : taskNew1){
                                    t.Collection_Agency__c = String.ValueOf(judgeList.Collection_Agency_Identifier__c);
                                    t.First_Name__c = String.ValueOf(AccJudgList[0].Product__r.First_Name__c);
                                    t.Last_Name__c = String.ValueOf(AccJudgList[0].Product__r.Last_Name__c);
                                    t.Seller__c = String.ValueOf(AccJudgList[0].Product__r.Originating_Creditor__c);
                                    
                                }system.debug('LIST ACCOUNT_judgment '+AccJudgList);
                            }
                        }
                    }else if(DistressedTaskList1[2] == disTask){
                        for(Settlement__c settleList : [select id,Product__c,Judgment__c,Judgment_Collection_Agency_Identifier__c,Product_Collection_Agency_Identifier__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Settlement__c  where id =: tskForId.whatid]){
                            for(Account_Judgment__c[] AccJudgList1 : [select id,Judgment__c,Product__r.First_Name__c,Product__r.Last_Name__c,Product__r.Originating_Creditor__c from Account_Judgment__c where Judgment__c =: settleList.Judgment__c order by createddate asc]){
                                for(Task t : taskNew1){
                                    if(settleList.Product__c != Null){
                                        
                                        t.Collection_Agency__c = String.ValueOf(settleList.Product_Collection_Agency_Identifier__c); 
                                        t.First_Name__c = String.ValueOf(settleList.Product__r.First_Name__c);
                                        t.Last_Name__c = String.ValueOf(settleList.Product__r.Last_Name__c);
                                        t.Seller__c = String.ValueOf(settleList.Product__r.Originating_Creditor__c);
                                        
                                    }else if(settleList.Judgment__c !=Null){
                                        t.Collection_Agency__c = String.ValueOf(settleList.Judgment_Collection_Agency_Identifier__c);
                                        t.First_Name__c = String.ValueOf(AccJudgList1[0].Product__r.First_Name__c);
                                        t.Last_Name__c = String.ValueOf(AccJudgList1[0].Product__r.Last_Name__c);
                                        t.Seller__c = String.ValueOf(AccJudgList1[0].Product__r.Originating_Creditor__c);
                                        
                                        
                                    }
                                }
                            }system.debug('List OF settlement ' +settleList);
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
        
        if(collCustSett.Run_Task_Trigger__c == true){
            
            for(Task tsk : taskNew){
                if(null != tsk.whatid){
                    if(String.valueOf(tsk.whatid).startsWith('a0D') && tsk.status != 'Generated by Docomotion'){
                        Product__c prod = [select id, Delinquency_Cycles__c, Delinquency_Days__c,
                                           No_of_times_contacted__c, No_of_times_contacted_in_current_cycle__c,
                                           No_of_times_contact_collection_in_n_days__c
                                           from Product__c where id =: tsk.whatid];
                        

                        if((tsk.Subject.contains('Send Email')) || (tsk.Subject.contains('Print Email'))){
                            if(null == prod.No_of_times_contacted__c){
                                prod.No_of_times_contacted__c = 1;
                            }else{
                                prod.No_of_times_contacted__c++;
                            }
                            if(null == prod.No_of_times_contact_collection_in_n_days__c){
                                prod.No_of_times_contact_collection_in_n_days__c = 1;
                            }else{
                                prod.No_of_times_contact_collection_in_n_days__c++;
                            }
                            if(prod.Delinquency_Cycles__c > 0){
                                if(null == prod.No_of_times_contacted_in_current_cycle__c ){
                                    prod.No_of_times_contacted_in_current_cycle__c = 1;
                                }else{
                                    prod.No_of_times_contacted_in_current_cycle__c++;
                                }
                            }
                        }
                        if(listProd.contains(prod)){
                            //do nothing    
                        }else{
                            listProd.add(prod);
                        }
                    }else if(String.valueOf(tsk.whatid).startswith('001')){
                        Account acc = [select id,
                                      No_of_times_contacted_for_collection__c,
                                      No_of_times_contact_collection_in_n_days__c, No_of_times_contacted__c
                                      from account where id =: tsk.whatid];
                        
                        if(null == acc.No_of_times_contacted__c){
                            acc.No_of_times_contacted__c = 1;
                        }else{
                            acc.No_of_times_contacted__c++;
                        }
                        if((tsk.Subject.contains('Collection') || (tsk.Type_of_Activity__c == 'Collection'))){
                            for(String contactCode : contactCountCodeList){
                                if(contactCode == tsk.CallClassification1__c){
                                    
                                    if(null == acc.No_of_times_contacted_for_collection__c){
                                        acc.No_of_times_contacted_for_collection__c = 1;
                                    }else{
                                        acc.No_of_times_contacted_for_collection__c++;
                                    }
                                    if(null == acc.No_of_times_contact_collection_in_n_days__c){
                                        acc.No_of_times_contact_collection_in_n_days__c = 1;
                                    }else{
                                        acc.No_of_times_contact_collection_in_n_days__c++;
                                    }
                                    break;
                                }
                            }
                        }
                        
                        if(listAcc.contains(acc)){
                            //do nothing    
                        }else{
                            listAcc.add(acc);
                        }
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