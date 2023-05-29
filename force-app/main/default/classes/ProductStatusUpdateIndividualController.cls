/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to update Product Status individually from Product record
*  @author : A5E Consulting
*  @date : 28/03/2022

*************************************************************************************************/
public with sharing class ProductStatusUpdateIndividualController {
    public map<String, Data_Status_Mapping__c> dataStatusMap = Data_Status_Mapping__c.getAll();
    public map<String, Placement_Status_Mapping__c> placementStatusMap = Placement_Status_Mapping__c.getAll();
    public boolean warehouse{get;set;}
    public boolean pendingAllocation{get;set;}
    public boolean closed{get;set;}
    public boolean updateProductButtonFlag{get;set;}
    public boolean statusFlag{get;set;}
    public boolean positiveFlag{get;set;}
    public string currentStatus{get;set;}
    public list<SelectOption> listDataStatusOptions {get;set;}
    public string StatusText{get;set;}
    public boolean StatusTextFlag{get;set;}
    public boolean labelDisplay{get;set;}
    public string buyBackText='Closed: Buyback';
    public string putBackText='Closed: Putback';
    public string soldText='Closed: Sold';
    
    public String SUCCESS_MSG {get;set;}
    public String productID {get;set;}
    public String selectedValueAction {get;set;}
    public List<Product__c> listProduct = new List<Product__c>();
    public Product__c product {get;set;}
    public String valiError{get;set;}
    
    public ProductStatusUpdateIndividualController(ApexPages.StandardController stdController) {
        listDataStatusOptions=new list<selectOption>();
        productID =  ApexPages.currentPage().getParameters().get('id');
        product = [SELECT ID, Name, Data_Status_Description__c,State__c, Placement_Status__c,Product_Status__c, Status__c,Collection_Agency__c,Assignment_Date__c
                   FROM Product__c WHERE ID= :productID];
        
        Integer persmiss = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Product_Status_Update_Access' AND AssigneeId =: Userinfo.getUserId()];
        
        System.debug('persmiss'+persmiss);
        System.debug('UserId'+Userinfo.getUserId());
        if(persmiss == 0){
            system.debug('inside debug'+userinfo.getUserName());
            valiError = 'You are not authorized to access';
        }else{
            system.debug('else debug'+userinfo.getUserName());
        }

        if(product.Data_Status_Description__c <> NULL){    
            StatusTextFlag=false;
            currentStatus=product.Data_Status_Description__c;
            system.debug('currentStatus--->'+currentStatus);
            system.debug('product.Data_Status_Description__c: '+product.Data_Status_Description__c);
            system.debug('buy back checking-->'+product.Data_Status_Description__c.Equals(buyBackText));
            system.debug('put back checking-->'+product.Data_Status_Description__c.Equals(putBackText));
            system.debug('sold checking-->'+product.Data_Status_Description__c.Equals(soldText));
            if(product.Data_Status_Description__c.startsWith('Warehouse') && (!product.Product_Status__c.startsWith('998') && !product.Product_Status__c.startsWith('997') && !product.Product_Status__c.startsWith('499000'))){
                system.debug('Inside warehouse');
                warehouse = true;
                positiveFlag=true;
                updateProductButtonFlag=true;
                labelDisplay=true;
            }
            if(product.Data_Status_Description__c.startsWith('Pending Allocation') && (!product.Product_Status__c.startsWith('998') && !product.Product_Status__c.startsWith('997') && !product.Product_Status__c.startsWith('499000'))){
                system.debug('Inside Pending Allocation');
                positiveFlag=true;
                pendingAllocation = true;
                updateProductButtonFlag=true;
                labelDisplay=true;
            }
            if(product.Data_Status_Description__c.startsWith('Closed') && (!product.Product_Status__c.startsWith('998') && !product.Product_Status__c.startsWith('997') && !product.Product_Status__c.startsWith('499000')) && product.Data_Status_Description__c!=soldText){
                system.debug('Inside Closed');
                positiveFlag=true;
                closed=true;
                updateProductButtonFlag=true;
                labelDisplay=true;
            }
            system.debug('warehouse -->'+warehouse);
            system.debug('pendingAllocation -->'+pendingAllocation);
            system.debug('closed -->'+closed);
            if(warehouse!=true && pendingAllocation!=true && closed!=true){
                system.debug('IF Loop -->');
                updateProductButtonFlag=false;
                labelDisplay=false;
                positiveFlag=false;
                StatusTextFlag=false;
                StatusText='We can not update status from "' +currentStatus+'" to another status. Please click on below BACK button';
            }
            list<Data_Status_Mapping__c> CSRecords=[select id,name,Description__c from Data_Status_Mapping__c where Description__c like 'Pending%' OR Description__c like 'Warehouse%' OR Description__c like 'Close%'];
            if(!CSRecords.isEmpty()){
                for(Data_Status_Mapping__c d:CSRecords){
                    listDataStatusOptions.add(new SelectOption(d.Description__c,d.Description__c));
                }
            }
        }
    }
    
    //Update Product  
    public void updateProduct(){ 
        system.debug('product update method');
        system.debug('selectedValueAction -->'+selectedValueAction);
        ProductTriggerHandler.runProductAPITrigger=false;
        RecursiveTriggerHandler.isFirstTime=false;
        Data_Status_Mapping__c dsm=[select id,name from Data_Status_Mapping__c where Description__c=:selectedValueAction limit 1];
        product.Data_Status_Description__c=selectedValueAction;
        product.Product_Status__c =dsm.Name;
        update product;
        SUCCESS_MSG='Product Updated Successfully';
        system.debug('Product Updated');
        
    }
    
    public pageReference redirectToProduct(){
        PageReference pageRef = new PageReference('/'+productID);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}