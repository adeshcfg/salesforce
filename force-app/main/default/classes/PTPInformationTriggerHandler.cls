/**************************************************************************************************
 *
 *  Trigger:   
 *
 *  @description : This is a trigger handler for PTPInformationTrigger
 *  @author : A5E Consulting
 *  @date : 02/13/2017
 * 
 *************************************************************************************************/

public class PTPInformationTriggerHandler{
    
    public static boolean runPTPTrigger = true;
    
    public void handleAfterInsert(List<PTP_Information__C> appsNew) {
        
        /*List<Product__C> listProd = new List<Product__c>();
        List<ID> listProdID = new List<ID>();
        system.debug('List of PTP : ' + appsNew);
        for(PTP_Information__c ptpInfo : appsNew){
            listProdID.add(ptpInfo.Product__c);
        }
        
        listProd = [select id, name, PTP1_Amount__c, PTP1_Date__c, PTP1_mate__c, PTP1_Method__c from Product__C where id in : listProdID];
        system.debug('List of products : ' + listProd);
        List<Product__c> updateProdList = new List<Product__c>();
        for(PTP_Information__c ptp : appsNew){
            for(Product__c prod : listProd){
                if(ptp.Product__c == prod.id){
                    prod.PTP1_Amount__c = ptp.PTP_Amount__c;
                    prod.PTP1_Date__c = Date.valueof(ptp.PTP_Date__c);
                    prod.PTP1_mate__c = ptp.PTP_Mate__c;
                    prod.PTP1_Method__c = ptp.PTP_Method__c;
                    
                    updateProdList.add(prod);
                }
            }
        }
        system.debug('list of update prod : ' + updateProdList);
        update updateProdList;
        */
        
        List<Product__C> listProd = new List<Product__c>();
        List<ID> listProdID = new List<ID>();
        system.debug('List of PTP : ' + appsNew);
        for(PTP_Information__c ptpInfo : appsNew){
            listProdID.add(ptpInfo.Product__c);
        }
        
        listProd = [select id, name, PTP1_Amount__c, PTP1_Date__c, PTP1_mate__c, PTP1_Method__c, Current_Workflow__c, recordtype.name from Product__C where id in : listProdID];
        list<PTP_Information__c> listPTPInfo = [select id, name, PTP_Date__c, PTP_Amount__c, PTP_Mate__c, PTP_Method__c from PTP_Information__c where product__c =: listProd[0].id order by PTP_Date__c desc];
        system.debug('List of products : ' + listProd);
        List<Product__c> updateProdList = new List<Product__c>();
        
        listProd[0].PTP1_Amount__c = listPTPInfo[0].PTP_Amount__c;
        listProd[0].PTP1_Date__c = Date.valueof(listPTPInfo[0].PTP_Date__c);
        listProd[0].PTP1_mate__c = listPTPInfo[0].PTP_Mate__c;
        listProd[0].PTP1_Method__c = listPTPInfo[0].PTP_Method__c;
        if(listProd[0].recordtype.name <> 'Distressed Account'){
            listProd[0].Current_Workflow__c = 'Promise to Pay Flow';
        }
        if(listProd[0].recordtype.name == 'Distressed Account'){
            listProd[0].Current_Workflow__c = 'ICT Promise to Pay';
        }
        
        system.debug('list of update prod : ' + updateProdList);
        
        ProductTriggerHandler.runProductTrigger = false;
        update listProd;
        ProductTriggerHandler.runProductTrigger = true;
        
    }
    
    public void handleAfterUpdate(List<PTP_Information__C> appsNew, Map<Id, PTP_Information__c> oldMap) {
        
        Set<ID> setProd = new Set<ID>();
        /*for(PTP_Information__c ptpInfo : appsNew){
            setProd.add(ptpInfo.Product__c);
        }
        
        List<Product__C> listProd = [select id, name, PTP1_Amount__c, PTP1_Date__c, PTP1_mate__c, PTP1_Method__c from Product__C where id =: setProd];
        List<Product__c> updateProdList = new List<Product__c>();
        for(ID prodID : setProd){
            PTP_Information__C ptp = [select id, name, PTP_Amount__c, PTP_Date__c, PTP_mate__c, PTP_Method__c, lastmodifiedDate, product__C from PTP_Information__C where Product__c =: prodID order by lastmodifiedDate asc limit 1];
            
            for(Product__C prod : listProd){
                if(ptp.Product__C == prod.id){
                    prod.PTP1_Amount__c = ptp.PTP_Amount__c;
                    prod.PTP1_Date__c = Date.valueof(ptp.PTP_Date__c);
                    prod.PTP1_mate__c = ptp.PTP_Mate__c;
                    prod.PTP1_Method__c = ptp.PTP_Method__c;
                    
                    updateProdList.add(prod);
                }
            }
        }
        
        update updateProdList;*/
        
        for(PTP_Information__c ptpInfo : appsNew){
            setProd.add(ptpInfo.Product__c);
        }
        
        List<Product__C> listProd = [select id, name, PTP1_Amount__c, PTP1_Date__c, PTP1_mate__c, PTP1_Method__c from Product__C where id =: setProd];
        List<Product__c> updateProdList = new List<Product__c>();
        for(ID prodID : setProd){
            PTP_Information__C ptp = [select id, name, PTP_Amount__c, PTP_Date__c, PTP_mate__c, PTP_Method__c, lastmodifiedDate, product__C from PTP_Information__C where Product__c =: prodID order by PTP_Date__c desc limit 1];
            
            for(Product__C prod : listProd){
                if(ptp.Product__C == prod.id){
                    prod.PTP1_Amount__c = ptp.PTP_Amount__c;
                    prod.PTP1_Date__c = Date.valueof(ptp.PTP_Date__c);
                    prod.PTP1_mate__c = ptp.PTP_Mate__c;
                    prod.PTP1_Method__c = ptp.PTP_Method__c;
                    
                    updateProdList.add(prod);
                }
            }
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        update updateProdList;
        ProductTriggerHandler.runProductTrigger = true;
    }
    
    public void handleBeforeDelete(List<PTP_Information__C> oldList){
        
    }
}