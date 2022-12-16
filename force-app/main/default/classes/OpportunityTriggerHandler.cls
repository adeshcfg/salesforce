/**************************************************************************************************
 *
 *  Class:   OpportunityTriggerHandler
 *
 *  @description : This is handler class for OpportunityTrigger
 *  @author : A5E Consulting
 *  @date : 07/01/2020
 *************************************************************************************************/
public class OpportunityTriggerHandler {
    //map to hold Bulk Amount fields wrt Asset Class Names
    public static map<String, String> amountBulkFieldsMap = new map<String, String>{
        'Credit Card' => 'Credit_Card_Bulk_Purchase_Amount__c',
        'Student Loan' => 'Student_Loan_Bulk_Purchase_Amount__c',
        'Auto Deficiencies' => 'Auto_Deficiencies_Bulk_Purchase_Amount__c',
        'Secured Auto' => 'Secured_Auto_Bulk_Purchase_Amount__c',
        'Utilities' => 'Utilities_Bulk_Purchase_Amount__c',
        'Telecom' => 'Telecom_Bulk_Purchase_Amount__c',
        'Term Loan' => 'Term_Loan_Bulk_Purchase_Amount__c',
        'Others' => 'Others_Bulk_Purchase_Amount__c'
    };
    
    //map to hold Forward Flow Amount fields wrt Asset Class Names
    public static map<String, String> amountForwardFlowFieldsMap = new map<String, String>{
        'Credit Card' => 'Credit_Card_Forward_Flow_Purchase_Amount__c',
        'Student Loan' => 'Student_Loan_Forward_Flow_PurchaseAmount__c',
        'Auto Deficiencies' => 'Auto_Def_Forward_Flow_Purchase_Amount__c',
        'Secured Auto' => 'Secured_Auto_Forward_Flow_PurchaseAmount__c',
        'Utilities' => 'Utilities_Forward_Flow_Purchase_Amount__c',
        'Telecom' => 'Telecom_Forward_Flow_Purchase_Amount__c',
        'Term Loan' => 'Term_Loan_Forward_Flow_Purchase_Amount__c',
        'Others' => 'Others_Forward_Flow_Purchase_Amount__c'
    };
    
    //Method to handle After Insert logic
    public static void handleOnAfterInsert(list<Opportunity> listNewOpportunities){
        createOpportunityLineItems(listNewOpportunities);
    }
    
    //Method to handle After Update logic
    public static void handleOnAfterUpdate(list<Opportunity> listNewOpportunity, map<Id, Opportunity> mapOldOpportunity){
        map<Id, Opportunity> mapOpportunityToUpdate = new map<Id, Opportunity>();
        for(Opportunity oppObj : listNewOpportunity){
            //Check if any field from fieldset in changed on Opportunity
            integer i = 0;
            for(Schema.FieldSetMember field :SObjectType.Opportunity.FieldSets.Sales_Pipeline_FieldSet.getFields()) {
                i+=1;
                if(oppObj.get(field.getFieldPath()) != mapOldOpportunity.get(oppObj.Id).get(field.getFieldPath())){
                    system.debug('i:'+i);
                    system.debug('field.getFieldPath():'+field.getFieldPath());
                    system.debug('field value:'+mapOldOpportunity.get(oppObj.Id).get(field.getFieldPath()));
                    mapOpportunityToUpdate.put(oppObj.Id, oppObj);
                }
            }
        }
        
        //Delete the OppLine associated records
        if(!mapOpportunityToUpdate.isEmpty()){
            map<Id, Product2> mapProductToDelete = new map<Id, Product2>();
            map<Id, PricebookEntry> mapPBEntryToDelete = new map<Id, PricebookEntry>();

            list<OpportunityLineItem> listOppLineToDelete= [SELECT Id, PricebookEntryId, Product2Id 
                                                        FROM OpportunityLineItem 
                                                        WHERE Opportunity.Id IN :mapOpportunityToUpdate.keySet()];

            for(OpportunityLineItem oppLineItem : listOppLineToDelete){
                if(!mapPBEntryToDelete.containsKey(oppLineItem.PricebookEntryId)){
                	mapPBEntryToDelete.put(oppLineItem.PricebookEntryId, new PricebookEntry(Id = oppLineItem.PricebookEntryId));
                }
                if(!mapPBEntryToDelete.containsKey(oppLineItem.Product2Id)){
                	mapProductToDelete.put(oppLineItem.Product2Id, new Product2(Id = oppLineItem.Product2Id));
                }
            }
			
            //delete OpportunityLineItems
            delete listOppLineToDelete;	
            //delete PricebookEntry
            delete mapPBEntryToDelete.values();
            //delete Products
            delete mapProductToDelete.values();
            
            //Method call for creating new opportunity line items
            createOpportunityLineItems(mapOpportunityToUpdate.values());
        }
    }
    
    //Method to create OpportunityLineItems
    public static void createOpportunityLineItems(list<Opportunity> listOpportunity){
        Id standardPbId;
        if(!Test.isRunningTest()){
        	standardPbId= [SELECT Id, Name, isActive FROM Pricebook2 WHERE IsStandard = True LIMIT 1].Id;
        }
        else{
        	standardPbId = Test.getStandardPricebookId();    
        }
    	
        // Create  product
        Product2 productInstance = new Product2(); 
        productInstance.Name = 'Umbrella Product';
        insert productInstance;
        
        //Create PriceBookEntry
        PricebookEntry PBEntryInstance = new PricebookEntry();
        PBEntryInstance.Product2ID = productInstance.Id;
        PBEntryInstance.Pricebook2ID = standardPbId;
        PBEntryInstance.UnitPrice = 50;
        PBEntryInstance.isActive = True;
        insert PBEntryInstance;
        
        //Create List to store OpportunityLineItem
        List<OpportunityLineItem> listOppLineItem=new List<OpportunityLineItem>(); 
        List<String> listSelectedAssetClass = new list<String>();
        
        for(Opportunity opportunityObj: listOpportunity){
            //Get Selected Asset Classes into list
            if(String.isNotBlank(opportunityObj.Asset_Class__c)){
                listSelectedAssetClass.addAll(opportunityObj.Asset_Class__c.split(';'));
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                //Create Opportunity LineItem for Bulk Type
                for(String assetClass : listSelectedAssetClass){
                    if(opportunityObj.Opportunity_Type__c == 'Bulk' || opportunityObj.Opportunity_Type__c == 'Hybrid'){
                        //Create OpportunityLineItem
                        oppLineItem = new OpportunityLineItem();
                        oppLineItem.PricebookEntryId = PBEntryInstance.Id;
                        oppLineItem.OpportunityId = opportunityObj.Id;
                        oppLineItem.Quantity = 1;
                        if(amountBulkFieldsMap.containsKey(assetClass)
                        && opportunityObj.get(amountBulkFieldsMap.get(assetClass)) != null){
                        	oppLineItem.TotalPrice = (Decimal)opportunityObj.get(amountBulkFieldsMap.get(assetClass));
                        }
                        //populate Expected date on Bulk Products from Bulk Payment Date
                        oppLineItem.Expected_Date__c = opportunityObj.Bulk_Payment_Date__c;
                        oppLineItem.Asset_Class__c = assetClass;
                        listOppLineItem.add(oppLineItem);
                    }
                }
                
                //Create Opportunity LineItem for Forward Flow
                for(String assetClass : listSelectedAssetClass){
                    if(opportunityObj.Opportunity_Type__c == 'Forward Flow' || opportunityObj.Opportunity_Type__c == 'Hybrid'){
                        //Get the total price for LineItem based on Forward Flow Amount
                        Double totalPrice = (Decimal)opportunityObj.get(amountForwardFlowFieldsMap.get(assetClass));
                        Date previousDate;
    
                        for (integer intgr=0; intgr<opportunityObj.Opportunity_Term__c; intgr++){
                            //Create OpportunityLineItem
                            oppLineItem = new OpportunityLineItem();
                            oppLineItem.PricebookEntryId = PBEntryInstance.Id;
                            oppLineItem.OpportunityId = opportunityObj.Id;
                            oppLineItem.Quantity = 1;
                            oppLineItem.TotalPrice = totalPrice;
                            if(intgr == 0){
                                oppLineItem.Expected_Date__c = opportunityObj.Forward_Flow_Starting_From__c;
                            }
                            else{
                                oppLineItem.Expected_Date__c = getDueDate(previousDate, opportunityObj.Term_Frequency__c);
                            }
                            previousDate = oppLineItem.Expected_Date__c;
                            oppLineItem.Asset_Class__c = assetClass;
                            listOppLineItem.add(oppLineItem);
                        }
                    }
                }
            }
        }
    
        //insert OpportunityLineItem
        insert listOppLineItem; 
    }
    
    //Method to set Expected Date on Line Item based on Previous Due Date and Frequency
    public static Date getDueDate(Date previousDate, String termFrequency){
        Date expectedDate;
        if(termFrequency == 'Weekly'){
            expectedDate = previousDate.addDays(7);
        }
        if(termFrequency == 'Biweekly'){
            expectedDate = previousDate.addDays(15);
        }
        if(termFrequency == 'Monthly'){
            expectedDate = previousDate.addMonths(1);
        }
        if(termFrequency == 'Bimonthly'){
            expectedDate = previousDate.addMonths(2);
        }
        if(termFrequency == 'Quarterly'){
            expectedDate = previousDate.addMonths(3);
        }
        return expectedDate;
    }
}