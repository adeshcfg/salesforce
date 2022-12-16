/**************************************************************************************************
*
*  Class:   
*
*  @description : Apex Batch Class that will send the emails and SMS for missed days when ETL doesn't run
*  @author : A5E Consulting
*  @date : 04/05/2018  

*************************************************************************************************/
public Class RunWorkflowBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        Collection_Custom_Setting__c collCust = Collection_Custom_Setting__c.getOrgDefaults();
        collCust.Workflow_In_Progress__c = True;
        update collCust;
        
        return Database.getQueryLocator([select id, name, recordType.Name, Record_Last_Updated_In_Staging__c, Last_Batch_Run_Date__c, Current_Workflow__c, 
                                         Delinquent_Day_for_Workflow__c, Workflow_Rule_Name__c, Workflow_Run_Date__c, Calculated_Delinquent_Days__c,
                                         Delinquency_Days__c, Payment_Due_Date__c, Workflow_In_Progress__c, Workflow_run_flag__c
                                         from product__c where recordType.name <> 'Distressed Account']);
    }
    
    public void execute(Database.BatchableContext BC, List<Product__C> prodList){
        List<Workflow_Rule__c> listWorkflowRule = workflow_Rule__c.getall().values();
        
        For(Product__C prod : prodList){
            Integer diffInETL = 0;//(Date.ValueOf(prod.Record_Last_Updated_In_Staging__c)).daysBetween(prod.Old_ETL_run_Date__c);
            Product__c originalProd = prod.clone();
            If(null == prod.Record_Last_Updated_In_Staging__c){
                diffInETL = 0;
            } else if(null == prod.Last_Batch_Run_Date__c){
                diffInETL = 1;
            }else if(null != prod.Last_Batch_Run_Date__c && null != prod.Record_Last_Updated_In_Staging__c){
                
                diffInETL = prod.Last_Batch_Run_Date__c.daysBetween(Date.ValueOf(prod.Record_Last_Updated_In_Staging__c));
            }
            system.debug('Difference in Dates :' + diffInETL );
            If(diffInETL < 1){
                //Do nothing
            /*} else if(diffInETL == 1){
                system.debug('Difference in Dates :' + 1);
                ProductTriggerHandler.runProductTrigger = false;
                prod.Old_ETL_run_Date__c = Date.ValueOf(prod.Record_Last_Updated_In_Staging__c);
                prod.Workflow_run_flag__c = true;
                update prod;
                ProductTriggerHandler.runProductTrigger = true;*/
            } else if(diffInETL >= 1){
                Decimal DDDay = 0;
                if(prod.recordType.Name == 'Credit Card Account'){
                    DDDay = prod.Delinquency_Days__c;
                    if(DDDay > 0){
                        
                        For(Integer i = 0; i < diffInETL; i++){
                            Decimal DelinquentDay = 0;
                            if(null != DDDay ){
                                DelinquentDay = (DDDay - 30) - i;
                            }else{
                                DelinquentDay = -30 - i;
                            }
                            for(Workflow_Rule__c wrl : listWorkflowRule){
                                if(wrl.Number_of_Delinquent_Days__c == DelinquentDay ){
                                    //prod.Delinquency_Days__c = DelinquentDay + 30;
                                    prod.Workflow_Rule_Name__c = wrl.Name;
                                    prod.Delinquent_Day_for_Workflow__c = DelinquentDay;
                                    prod.Workflow_run_flag__c = true;
                                    break;
                                }
                            }
                            if(prod.Workflow_run_flag__c == true){
                                break;
                            }
                        }
                        
                    }else if(DDDay == 0){
                        //Do Nothing
                    }
                    
                }else if(prod.recordType.Name == 'Loan Account'){
                    DDDay = prod.Delinquency_Days__c;
                    if(DDDay > 0){
                        
                        For(Integer i = 0; i < diffInETL; i++){
                            Decimal DelinquentDay = 0;
                            if(null != DDDay){
                                DelinquentDay = DDDay-i;
                            }else{
                                DelinquentDay = -i;
                            }
                            
                            if(DelinquentDay == 3){
                                DelinquentDay = 0;
                                //prod.Delinquent_Day_for_Workflow__c = null;
                            }
                            if(DelinquentDay == 10){
                                DelinquentDay = 3;
                                //prod.Delinquent_Day_for_Workflow__c = null;
                            }
                            
                            for(Workflow_Rule__c wrl : listWorkflowRule){
                                if(wrl.Number_of_Delinquent_Days__c == DelinquentDay ){
                                    
                                    prod.Workflow_Rule_Name__c = wrl.Name;
                                    prod.Delinquent_Day_for_Workflow__c = DelinquentDay;
                                    
                                    prod.Workflow_run_flag__c = true;
                                    break;
                                }
                            }
                            if(prod.Workflow_run_flag__c == true){
                                break;
                            }
                        }
                        
                    }else if(prod.Delinquency_Days__c == 0){
                        //Do Nothing
                    }
                }
                ProductTriggerHandler.runProductTrigger = false;
                prod.Last_Batch_Run_Date__c = Date.ValueOf(prod.Record_Last_Updated_In_Staging__c) ; 
                update prod;
                ProductTriggerHandler.runProductTrigger = true;
            }             
        }
    }
    
    public void finish(Database.BatchableContext BC){
        Collection_Custom_Setting__c collCust = Collection_Custom_Setting__c.getOrgDefaults();
        collCust.Workflow_In_Progress__c = False;
        update collCust;
    }
}