/**************************************************************************************************
*
*  Class:   
*
*  @description : Controller class to display Product Payment records from Staging and create success
*                  and failure files for payments
*  @author : A5E Consulting
*  @date : 08/02/2022

*************************************************************************************************/
public class DisplayProductPaymentStagingController {
    Agency_Portal_Settings__c portalSettings = Agency_Portal_Settings__c.getOrgDefaults();
    public list<Product_Payment_Staging__c> listProductPayStaging {get;set;}
    public list<productPaymentStagingWrapper> listProductPayStagingWrapper {get;set;}
    public static Boolean stopSuccessfilegenaration = false;
    public static final String PROCESSED = 'Processed';
    public static final String ERROR = 'ERROR';
    public static final String FEE_TRANSACION_CODES = '3000,3400,4000,4001,4002,4003,5000,5001,5002,5003,7000,7001';
    public static boolean showTypeColumn {get;set;}
    static String PAYTYPE_REGULAR = '1000';
    static String PAYTYPE_REVERSAL = '1003';
    static String PAYTYPE_SETTLED_IN_FULL = '1002';
    static String PAYTYPE_PAID_IN_FULL = '1001';
    static String PENDING_RECALL_PIF = 'Pending Recall - PIF';
    static String PENDING_RECALL_PIF_CODE = '806000';
    static String PENDING_RECALL_SIF = 'Pending Recall - SIF';
    static String PENDING_RECALL_SIF_CODE = '807000';
    static String PENDING_RECALL = 'Pending Recall';
    static String PENDING_RECALL_PRODUCT_STATUS_CODE = '302000';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF = 'Pending Recall - Paid Prior To Previous Agency';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE = '808500';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF = 'Pending Recall - Paid Prior To Previous Agency';
    static String PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE = '808550';
    static String PIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE = '908500';
    static String SIF_PAID_PRIOR_PREVIOUS_AGENCY_PRODUCT_STATUS_CODE = '908550';
    public static String productNames = '';
    public static String placementIdentifier = '';
    public static String placementStatusCode = '';
    String exceptionMessage = '';
    public boolean showButton {get;set;}
    public boolean displayPanel {get;set;}
    public boolean executeWarning {get;set;}
    public Id workAssignmentId {get;set;}
    Decimal successRecords;
    Decimal failedRecords;
    String placementAgency = '';
    //bug : 5354 added below line
    ID docStorplacementAgency;
    String success;
    String failed;
    Id documentID;
    boolean directPayment = false;
    boolean balanceAdjustment = false;
    //Constructor
    public DisplayProductPaymentStagingController(){
        showButton = false;
        displayPanel = false;
        showTypeColumn = false;
        String recordIdentfier = ApexPages.currentPage().getParameters().get('id');
        listProductPayStaging = [SELECT ID,CCS_Account__c, Cheque_Number__c, Comment__c, Document_Storage__c, Document_Storage__r.File_Processing_Status__c,
                                 Document_Storage__r.Work_Assignment_Identifier__c, Commission_Rate_for_Payment__c,
                                 Document_Storage__r.Placement_Agency__c,Commission_Amount__c,Payment_Type__c, Payment_posting_Date__c,Product_ID__c,Pool_Lookup__c,
                                 Interest_Payment_Amount__c, Pay_Attorney__c, Pay_Court__c, Pay_Fees__c,Tax_Amount__c,
                                 Pay_NSF__c, Pay_Other__c, Principal_Payment_Amount__c,Agency_Calculated_Comm__c,
                                 Payment_Amount__c, Payment_Source__c, Placement_Agency__c, Status__c, Expected_Value__c,
                                 Original_Of_Payment_Reversal__c, Document_Storage__r.Work_Assignment__c, Product_Agency__c,
                                 Product_Commission_Rate__c, Agency_Commission_Rate__c, Pool_Commission_Rate__c,Pay_Posting_Date__c,
                                 Payment_Type_Description__c, Fee_Type__c, Billing_Entity__c, Primary_Account_Number__c,Product_Payment_Agency__c,
                                 Tax_Type__c,Tax_Province__c,Tax_Province_Rate__c,Legal_Product_Identifier__c, Document_Storage__r.Direct_Payment__c,
                                 Direct_Payment_Type__c,Portfolio_Group_Name__c,Legal_Entity__c,Document_Storage__r.Balance_Adjustment__c
                                 FROM Product_Payment_Staging__c
                                 WHERE Identifier__c = :recordIdentfier
                                 order by Pay_Posting_Date__c ASC
                                ];
        if(listProductPayStaging.isEmpty()){
            //showButton = false;
            displayPanel = false;
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'There are no Payments to display'));
        }
        else{
            workAssignmentId = listProductPayStaging[0].Document_Storage__r.Work_Assignment__c;
            listProductPayStagingWrapper = new list<productPaymentStagingWrapper>();
            for(Product_Payment_Staging__c payStaging : listProductPayStaging){
                Boolean disabled = false;
                directPayment = payStaging.Document_Storage__r.Direct_Payment__c;
                balanceAdjustment = payStaging.Document_Storage__r.Balance_Adjustment__c;
                if(String.isnotblank(payStaging.Direct_Payment_Type__c)){
                    showTypeColumn = true;
                }
                if(payStaging.Comment__c.contains(ERROR) || (payStaging.Status__c == PROCESSED && payStaging.Comment__c == 'SUCCESS')){
                    disabled = true;
                }
                listProductPayStagingWrapper.add(new productPaymentStagingWrapper(payStaging, disabled));
                if(payStaging.Status__c != PROCESSED && !payStaging.Comment__c.contains(ERROR)){
                    showButton = true;
                }
            }
            placementAgency = listProductPayStaging[0].Placement_Agency__c;
       //bug:5354 added if loop
            if(listProductPayStaging[0].Document_Storage__r.Placement_Agency__c != NULL){
                system.debug('listProductPayStaging[0].Document_Storage__r.Placement_Agency__c'+listProductPayStaging[0].Document_Storage__r.Placement_Agency__c);
            docStorplacementAgency=listProductPayStaging[0].Document_Storage__r.Placement_Agency__c;
            system.debug('docStorplacementAgency-->'+docStorplacementAgency);
        }
             documentID = listProductPayStaging[0].Document_Storage__c;
            if(showButton == false){
                if(listProductPayStaging[0].Document_Storage__r.File_Processing_Status__c == PROCESSED){
                    //showButton = false;
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Records are already processed'));
                }
                else{
                    showButton = false;
                }
            }
        }
    }
    //made by tejal for success and error file
    public pageReference Save(){
        list<Product_Payments__c> listProdPayment = new list<Product_Payments__c>();
        list<Product_Payments__c> listProductPayToUpdate = new list<Product_Payments__c>();
        map<ID, Product_Payments__c> mapProductPayments = new map<ID, product_Payments__c>();
        map<ID, Product_Payments__c> mapBalanceAdjustments = new map<ID, product_Payments__c>();
        List<Product_Payment_Staging__c> listProductPaymentStaging = new List<Product_Payment_Staging__c>();    
        Map<Id, Product__c> mapProducts = new map<Id, Product__c>();
        Set<Id> setProductId = new Set<Id>();
        Map<String, List<Placement_History__c>> mapProductIdPlacementHistoryList = new Map<String,List<Placement_History__c>>();
        String monthInt = '';
        Integer monthSize = null;
        
        for(productPaymentStagingWrapper payStagingWrapper : listProductPayStagingWrapper){
            setProductId.add(payStagingWrapper.payStaging.Product_ID__c);
        }

        // 4578 Changes - Get product and placement history details
        if (!setProductId.isEmpty()) {
            for (Placement_History__c placementHistory : [
                SELECT Id, Product__c, Placement_Date__c, Agency_Id__c, Placement__c, Placement_History_External__c
                FROM Placement_History__c
                WHERE Product__c IN :setProductId
                ORDER BY Placement_Date__c DESC
            ]) {
                if (mapProductIdPlacementHistoryList.containsKey(placementHistory.Product__c)) {
                    mapProductIdPlacementHistoryList.get(placementHistory.Product__c).add(placementHistory);
                } else {
                    mapProductIdPlacementHistoryList.put(placementHistory.Product__c, new List<Placement_History__c>{ placementHistory });
                }
            }

            for (Product__c productInstance : [
                SELECT Id, Collection_Agency__c, Recalled_Date__c
                FROM Product__c
                WHERE ID IN :setProductId
            ]) {
                mapProducts.put(productInstance.ID, productInstance);
            }
        }
        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        
        for(productPaymentStagingWrapper payStagingWrapper : listProductPayStagingWrapper){
            Product_Payment_Staging__c payStaging = payStagingWrapper.payStaging;
            
            String comment = '';
            String currentMonth;
            if(String.isNotBlank(payStaging.Comment__c)){
                comment = payStaging.Comment__c;
            }
            
            if(Test.isRunningTest()){
                payStagingWrapper.selected = true;
            }
            //If No error found, create payment record from staging
            if(payStaging.Status__c != PROCESSED
               && payStagingWrapper.selected == true){
                   
                   Product_Payments__c prodPayment = new Product_Payments__c();
                   prodPayment.CCS_Account__c = payStaging.Product_ID__c;
                   prodPayment.Payment_Amount__c = payStaging.Payment_Amount__c;
                   prodPayment.Payment_Posting_Date__c = payStaging.Pay_Posting_Date__c;
                   prodPayment.Payment_Created__c = Date.today();
                   //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
                   monthInt = String.valueOf(prodPayment.Payment_Created__c.month());
                   
                   if(monthInt.length() == 1){
                       currentMonth = '0' + String.valueOf(prodPayment.Payment_Created__c.month());
                   }else{
                       currentMonth = String.valueOf(prodPayment.Payment_Created__c.month()); 
                   }
                   //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
                   prodPayment.Payment_Posting_Month__c =  String.valueOf(prodPayment.Payment_Created__c.year() +''+ currentMonth);
                   prodPayment.Payment_Posting_Date_Text__c = payStaging.Payment_Posting_Date__c;
                   prodPayment.Payment_Type__c = payStaging.Payment_Type__c;
                   prodPayment.Payment_Source__c = payStaging.Payment_Source__c;
                   prodPayment.Cheque_Number__c = payStaging.Cheque_Number__c;
                   prodPayment.Payment_Agency__c = payStaging.Placement_Agency__c;
                   if(payStaging.Agency_Calculated_Comm__c != NULL){
                       prodPayment.Agency_Calculated_Comm__c = Decimal.valueOF(payStaging.Agency_Calculated_Comm__c);
                   }
                   prodPayment.Payment_Provided_Agency__c = placementID;
                   prodPayment.Payment_Provided_Agency__c = payStaging.Product_Payment_Agency__c;
                   //Bug : 5354 changes starts
                  if(docStorplacementAgency != NULL){
                    system.debug('docStorplacementAgency--->'+docStorplacementAgency);
                    prodPayment.Agency_Submitted_Payment__c = docStorplacementAgency;
                    system.debug('prodPayment.Agency_Submitted_Payment__c--->'+docStorplacementAgency);
                  } 
                  // prodPayment.Agency_Submitted_Payment__c = payStaging.Product_Payment_Agency__c;
                  //Bug: 5354 changes ends
                  prodPayment.Product_Agency__c = payStaging.Product_Agency__c;
                   prodPayment.Pay_Due__c = payStaging.Commission_Amount__c;
                   prodPayment.Tax_Amount__c = payStaging.Tax_Amount__c;
                   prodPayment.Tax_Type__c = payStaging.Tax_Type__c;
                   prodPayment.Tax_Province__c = payStaging.Tax_Province__c;
                   prodPayment.Tax_Province_Rate__c = payStaging.Tax_Province_Rate__c;
                   prodPayment.Legal_Product_Identifier__c = payStaging.Legal_Product_Identifier__c;
                   prodPayment.Commission_Rate_for_Payment__c = payStaging.Commission_Rate_for_Payment__c;
                   prodPayment.Pool_Lookup__c = payStaging.Pool_Lookup__c;
                   prodPayment.Product_Commission_Rate__c = payStaging.Product_Commission_Rate__c;
                   prodPayment.Agency_Commission_Rate__c = payStaging.Agency_Commission_Rate__c;
                   prodPayment.Pool_Commission_Rate__c = payStaging.Pool_Commission_Rate__c;
                   prodPayment.Legal_Entity__c = payStaging.Legal_Entity__c;
                   prodPayment.Portfolio_Group_Name__c = payStaging.Portfolio_Group_Name__c;
                   prodPayment.Original_Of_Payment_Reversal__c = payStaging.Original_Of_Payment_Reversal__c;
                   prodPayment.Fee_Type__c = payStaging.Fee_Type__c;
                   prodPayment.Billing_Entity__c = payStaging.Billing_Entity__c;
                   //4578 - Link appropriate placement history with payment
                   Map<String, String> mapPlacementHistoryToLink = ProductPaymentsTriggerHandler.getPlacementHistoryToLink(prodPayment, mapProducts, mapProductIdPlacementHistoryList);
                   prodPayment.Placement_History__c = mapPlacementHistoryToLink.get('Id');
                   // 4806
                   prodPayment.Placement_History_External__c =  mapPlacementHistoryToLink.get('Placement_History_External__c');
                   if(prodPayment.Payment_Type__c != null){
                       if(FEE_TRANSACION_CODES.contains(prodPayment.Payment_Type__c)){
                           prodPayment.Interest_Payment_Amount__c = payStaging.Interest_Payment_Amount__c;
                           prodPayment.Principal_Payment_Amount__c = payStaging.Principal_Payment_Amount__c;
                           prodPayment.Pay_Attorney__c = payStaging.Pay_Attorney__c;
                           prodPayment.Pay_Court__c = payStaging.Pay_Court__c;
                           prodPayment.Pay_NSF__c   = payStaging.Pay_NSF__c    ;
                           prodPayment.Pay_Other__c = payStaging.Pay_Other__c;
                           prodPayment.Pay_Fees__c = payStaging.Pay_Fees__c;      
                       }
                   } 
                   if(portalSettings.Distressed_Payment_RecordType_ID__c != NULL){
                       prodPayment.RecordTypeID = portalSettings.Distressed_Payment_RecordType_ID__c;
                   }
                   listProdPayment.add(prodPayment);
                   
                   if(String.isNotBlank(payStaging.Original_Of_Payment_Reversal__c)){
                       Product_payments__c prodPayToUpdate = new Product_payments__c();
                       prodPayToUpdate.Id = payStaging.Original_Of_Payment_Reversal__c;
                       prodPayToUpdate.Is_Payment_Reversed__c = true;
                       listProductPayToUpdate.add(prodPayToUpdate);
                   }
                   listProductPaymentStaging.add(payStaging);
               }
        }
        ProductTriggerHandler.runProductTrigger = false;
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        
        //Added by satyajit for ticket:4518
        Savepoint sp = Database.setSavepoint();
        
        try{
            if(listProductPayToUpdate.size()>0){
                update listProductPayToUpdate;
            }
            if(listProdPayment.size()>0){
                insert listProdPayment;
            }
            for(Product_payments__c prodPay : listProdPayment){
                if(prodPay.Payment_Type__c != null){
                    if(!FEE_TRANSACION_CODES.contains(prodPay.Payment_Type__c)){
                        mapProductPayments.put(prodPay.ID, prodPay);    
                    }
                    else{
                        mapBalanceAdjustments.put(prodPay.ID, prodPay);
                    }
                }
            }
            //call to calculateBalanceBackdatedPayments method, to update balances
            ProductPaymentsTriggerHandler.calculateBalanceBackdatedPayments(mapProductPayments,NULL,sp,workAssignmentId,documentID,'Payment Excel Processing');
            
            //call to calculateBalanceFeeAdjustments method, to update balances
            ProductPaymentsTriggerHandler.calculateBalanceFeeAdjustments(mapBalanceAdjustments,sp,workAssignmentId,documentID,'Payment Excel Processing');
            
            //Create Success and Error file
           if(stopSuccessfilegenaration == false){
                GenerateSuccessAndErrorFile(listProductPayStagingWrapper,listProductPayStaging[0].Document_Storage__r.Work_Assignment__c,portalSettings.Document_Storage_Default_Visibility__c,documentID,directPayment,NULL);
			}
           stopSuccessfilegenaration = false;
            
        }catch(Exception ex){
            //for ticket:5202
            exceptionMessage = '<b>ERROR</b>-'+ex.getMessage()+' '+ex.getStackTraceString();
            if(exceptionMessage.length() > 131072){
                exceptionMessage = exceptionMessage.substring(0, 131072);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
            //Added by satyajit for ticket:4518
            //Database.rollback(sp);
            for(Product_Payment_Staging__c ProductPaymentStaging: listProductPaymentStaging){
                String msg = '<b>ERROR</b>-'+ex.getMessage();
                if(msg.length() > 254){
                    msg = msg.substring(0,254);
                }
                //for ticket:5202
                ProductPaymentStaging.Comment__c= exceptionMessage;
                ProductPaymentStaging.status__c= 'Pending';
            }
            
            //Added by satyajit for ticket:4518
            DateTime dT = System.now();
            String oldComments = '';
            String msg1 = 'The trasaction is failed due to below exception: '+ex.getMessage();
            if(msg1.length() > 1199){
                msg1 = msg1.substring(0,1199);
            }
            
            Work_Assignment__c workAssignmentData = [Select id,name,comment_Reply__c,Comments_History__c from Work_Assignment__c where id =: listProductPayStaging[0].Document_Storage__r.Work_Assignment__c];
            workAssignmentData.Status__c = 'Completed';
            workAssignmentData.Comment_Reply__c = '';
            workAssignmentData.Comment_Reply__c +=msg1;
            
            if(workAssignmentData.Comments_History__c !=null){
                oldComments = workAssignmentData.Comments_History__c;
            }
            workAssignmentData.Latest_Comment__c =workAssignmentData.Comment_Reply__c;
            //bug:4743 : changes starts
            workAssignmentData.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' +workAssignmentData.Comment_Reply__c + '\n' + '\n';
            //bug:4743 : changes ends
            if(oldComments != null){
                workAssignmentData.Comments_History__c += oldComments;
            }
            
            workAssignmentData.Comment_Reply__c = '';
            
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
            update workAssignmentData;
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            
            if(!Test.isRunningTest()){
                system.enqueueJob(new CFG_ProcessWorkAssignment(workAssignmentData.Id));
            }
        }
        
        if(listProductPaymentStaging.size()>0){
            update listProductPaymentStaging;
        }
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        ProductTriggerHandler.runProductTrigger = true;
        
        showButton = true;
        displayPanel = true;
        return null;
    } 
    //Changes made by tejal for success and error file
    public pageReference SaveBalanceAdjustment(){
        list<Product_Payments__c> listProdPayment = new list<Product_Payments__c>();
        list<Product_Payments__c> listProductPayToUpdate = new list<Product_Payments__c>();
        List<Product_Payment_Staging__c> listProductPaymentStaging = new List<Product_Payment_Staging__c>();  
        
        //Get Placement ID
        list<Placement__c> listPlacements = [SELECT ID 
                                             FROM Placement__c 
                                             WHERE Name= :placementAgency];
        Id placementID;
        if(!listPlacements.isEmpty()){
            placementID = listPlacements[0].ID;
        }
        
        String monthInt = '';
        Integer monthSize = null;
        
        for(productPaymentStagingWrapper payStagingWrapper : listProductPayStagingWrapper){
            Product_Payment_Staging__c payStaging = payStagingWrapper.payStaging;
            if(String.isnotblank(payStaging.Direct_Payment_Type__c)){
                showTypeColumn = true;
            }
            String comment = '';
            String currentMonth;
            if(String.isNotBlank(payStaging.Comment__c)){
                comment = payStaging.Comment__c;
            }
            
            if(Test.isRunningTest()){
                payStagingWrapper.selected = true;
            }
            
            //If No error found, create payment record from staging
            if(payStaging.Status__c != PROCESSED
               && payStagingWrapper.selected == true){
                   //payStaging.Status__c = PROCESSED;
                   Product_Payments__c prodPayment = new Product_Payments__c();
                   
                   prodPayment.CCS_Account__c = payStaging.Product_ID__c;
                   prodPayment.Payment_Amount__c = payStaging.Payment_Amount__c;
                   prodPayment.Payment_Posting_Date__c = payStaging.Pay_Posting_Date__c;
                   //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
                   prodPayment.Payment_Created__c = Date.today();
                   monthInt = String.valueOf(prodPayment.Payment_Created__c.month());
                   
                   if(monthInt.length() == 1){
                       currentMonth = '0' + String.valueOf(prodPayment.Payment_Created__c.month());
                   }else{
                       currentMonth = String.valueOf(prodPayment.Payment_Created__c.month()); 
                   }
                   //updating the code to populate payment posting month from Payment created instead of Payment Posting date Ticket: 4546
                   prodPayment.Payment_Posting_Month__c =  String.valueOf(prodPayment.Payment_Created__c.year() +''+ currentMonth);
                   prodPayment.Payment_Posting_Date_Text__c = payStaging.Payment_Posting_Date__c;
                   prodPayment.Payment_Type__c = payStaging.Payment_Type__c;
                   prodPayment.Payment_Source__c = payStaging.Payment_Source__c;
                   prodPayment.Cheque_Number__c = payStaging.Cheque_Number__c;
                   prodPayment.Payment_Agency__c = payStaging.Placement_Agency__c;
                   prodPayment.Payment_Provided_Agency__c = payStaging.Product_Payment_Agency__c;    
                   //Bug: 5354 - Added below line
                   //prodPayment.Agency_Submitted_Payment__c = payStaging.Product_Payment_Agency__c;    
                   
                   prodPayment.Product_Agency__c = payStaging.Product_Agency__c;
                   prodPayment.Pool_Lookup__c = payStaging.Pool_Lookup__c;
                   prodPayment.Direct_Payment_Type__c = payStaging.Direct_Payment_Type__c;
                   if(prodPayment.Direct_Payment_Type__c == 'Direct Payment' || String.isBlank(prodPayment.Direct_Payment_Type__c)){
                       prodPayment.Product_Commission_Rate__c = payStaging.Product_Commission_Rate__c;
                       prodPayment.Agency_Commission_Rate__c = payStaging.Agency_Commission_Rate__c;
                       prodPayment.Pool_Commission_Rate__c = payStaging.Pool_Commission_Rate__c;
                       prodPayment.Pay_Due__c = payStaging.Commission_Amount__c;
                       prodPayment.Tax_Amount__c = payStaging.Tax_Amount__c;
                       prodPayment.Tax_Type__c = payStaging.Tax_Type__c;
                       prodPayment.Tax_Province__c = payStaging.Tax_Province__c;
                       prodPayment.Tax_Province_Rate__c = payStaging.Tax_Province_Rate__c;
                       prodPayment.Legal_Product_Identifier__c = payStaging.Legal_Product_Identifier__c;
                       prodPayment.Commission_Rate_for_Payment__c = payStaging.Commission_Rate_for_Payment__c;        
                   }
                   
                   prodPayment.Original_Of_Payment_Reversal__c = payStaging.Original_Of_Payment_Reversal__c;
                   
                   prodPayment.Interest_Payment_Amount__c = payStaging.Interest_Payment_Amount__c;
                   prodPayment.Principal_Payment_Amount__c = payStaging.Principal_Payment_Amount__c;   
                   prodPayment.Legal_Entity__c = payStaging.Legal_Entity__c;
                   prodPayment.Portfolio_Group_Name__c = payStaging.Portfolio_Group_Name__c;
                   if(portalSettings.Distressed_Payment_RecordType_ID__c != NULL){
                       prodPayment.RecordTypeID = portalSettings.Distressed_Payment_RecordType_ID__c;
                   }
                   listProdPayment.add(prodPayment);
                   if(String.isNotBlank(payStaging.Original_Of_Payment_Reversal__c)){
                       Product_payments__c prodPayToUpdate = new Product_payments__c();
                       prodPayToUpdate.Id = payStaging.Original_Of_Payment_Reversal__c;
                       prodPayToUpdate.Is_Payment_Reversed__c = true;
                       listProductPayToUpdate.add(prodPayToUpdate);
                   }
                   listProductPaymentStaging.add(payStaging);
               }
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        ProductPaymentsTriggerHandler.runProductTrigger = false;
        
        //Added by satyajit for ticket: 4518
        Savepoint sp = Database.setSavepoint();
        
        try{
            if(listProductPayToUpdate.size()>0){
                update listProductPayToUpdate;
            }
            if(listProdPayment.size()>0){
                insert listProdPayment;
            }
            
            map<ID, Product_Payments__c> mapProductPayments = new map<ID, product_Payments__c>();
            
            for(Product_payments__c prodPay : listProdPayment){
                mapProductPayments.put(prodPay.ID, prodPay);    
            }
            
            //call to calculateBalanceBackdatedPayments method, to update balances
            calculateBalanceBackdatedPayments(mapProductPayments,sp,workAssignmentId,documentID);
            
            //Create Success and Error file
            if(stopSuccessfilegenaration != true){
            	GenerateSuccessAndErrorFile(listProductPayStagingWrapper,listProductPayStaging[0].Document_Storage__r.Work_Assignment__c,portalSettings.Document_Storage_Default_Visibility__c,documentID,NULL,true);
            }
            stopSuccessfilegenaration = false;
            
        }catch(Exception ex){
            //for ticket:5202
            exceptionMessage = '<b>ERROR</b>-'+ex.getMessage()+' '+ex.getStackTraceString();
            if(exceptionMessage.length() > 131072){
                exceptionMessage = exceptionMessage.substring(0, 131072);    
            }
            else{
                exceptionMessage = exceptionMessage;
            }
            //Added by satyajit for ticket: 4518
            //Database.rollback(sp);
            
            for(Product_Payment_Staging__c ProductPaymentStaging: listProductPaymentStaging){
                String msg = '<b>ERROR</b>-'+ex.getMessage();
                if(msg.length() > 254){
                    msg = msg.substring(0,254);
                }
                //for ticket:5202
                ProductPaymentStaging.Comment__c= exceptionMessage;
                ProductPaymentStaging.status__c= 'Pending';
            }
            
            //Added by satyajit for ticket:4518
            DateTime dT = System.now();
            String oldComments = '';
            String msg1 = 'The trasaction is failed due to below exception: '+ex.getMessage();
            if(msg1.length() > 1199){
                msg1 = msg1.substring(0,1199);
            }
            
            Work_Assignment__c workAssignmentData = [Select id,name,comment_Reply__c,Comments_History__c from Work_Assignment__c where id =: listProductPayStaging[0].Document_Storage__r.Work_Assignment__c];
            workAssignmentData.Status__c = 'Completed';
            workAssignmentData.Comment_Reply__c = '';
            workAssignmentData.Comment_Reply__c += msg1;
            if(workAssignmentData.Comments_History__c !=null){
                oldComments = workAssignmentData.Comments_History__c;
            }
            workAssignmentData.Latest_Comment__c = workAssignmentData.Comment_Reply__c;
            //bug:4743 : changes starts
            workAssignmentData.Comments_History__c = 'System Generated Comment on behalf of' + ' ' +UserInfo.getName()+' '+ 'on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' +workAssignmentData.Comment_Reply__c + '\n' + '\n';
            //bug:4743 changes ends
            if(oldComments != null){
                workAssignmentData.Comments_History__c += oldComments;
            }
            
            workAssignmentData.Comment_Reply__c = '';
            
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = false;
            update workAssignmentData;
            WorkAssignmentTriggerHandler.runWorkAssignmentTrigger = true;
            
            if(!Test.isRunningTest()){
                system.enqueueJob(new CFG_ProcessWorkAssignment(workAssignmentData.Id));
            }
            
        }
        if(listProductPaymentStaging.size()>0){
            update listProductPaymentStaging;
        }
        
        ProductPaymentsTriggerHandler.runProductTrigger = true;
        ProductTriggerHandler.runProductTrigger = true;      
        
        showButton = true;
        displayPanel = true;
        return null;
    }
    //Created by tejal for success and error file
    public Static void GenerateSuccessAndErrorFile(list<productPaymentStagingWrapper> listProductPayStagingWrapper,Id workAssignmentId,String visiblity,
                                                   Id documentID,boolean directPayment,boolean balanceAdjustment){
                                                       String success;
                                                       String failed;
                                                       Integer successRecords = 0;
                                                       Integer failedRecords = 0;
                                                       String DocumentType;                                                      
                                                       if(directPayment == true){
                                                           //Create Success and Failure file headers for Direct Payement
                                                           success = 'data_id' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amount' + '\t' + 'pay_source' + '\t' + 'pri_acctno';
                                                           failed = 'data_id' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amount' + '\t' + 'pay_source' + '\t' + 'pri_acctno' + '\t' + 'error';    
                                                       }
                                                       else if(balanceAdjustment == true){
                                                           //Create Success and Failure file headers for Balance Adjustment
                                                           success = 'data_id' + '\t' + 'Direct_Payment_Type' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amount' + '\t' + 'pay_principal' + '\t' + 'pay_interest' + '\t' + 'pay_source' + '\t' + 'Agency_Allocation' + '\t' + 'Commsion_Rate_Override';
                                                           failed = 'data_id' + '\t' + 'Direct_Payment_Type' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amoun' + '\t' + 'pay_principal' + '\t' + 'pay_interest' + '\t' + 'pay_source' + '\t' + 'Agency_Allocation' + '\t' + 'Commsion_Rate_Override' + '\t' + 'Error';                                          
                                                       }                                   
                                                       else{
                                                           //Create Success and Failure file headers for Product Payment
                                                           success = 'data_id' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amount' + '\t' + 'tran_principal' + '\t' + 'tran_interest' + '\t' + 'tran_court' + '\t' + 'tran_attorney' + '\t' + 'tran_nsf' + '\t' + 'tran_general' + '\t' + 'tran_other' + '\t' + 'tran_retained';
                                                           failed = 'data_id' + '\t' + 'tran_type' + '\t' + 'tran_date' + '\t' + 'tran_amount' + '\t' + 'tran_principal' + '\t' + 'tran_interest' + '\t' + 'tran_court' + '\t' + 'tran_attorney' + '\t' + 'tran_nsf' + '\t' + 'tran_general' + '\t' + 'tran_other' + '\t' + 'tran_retained' + '\t' + 'error';    
                                                       }
                                                       
                                                       for(productPaymentStagingWrapper payStagingWrapper : listProductPayStagingWrapper){
                                                           Product_Payment_Staging__c payStaging = payStagingWrapper.payStaging;
                                                           if(payStaging.Status__c != PROCESSED && payStagingWrapper.selected == true){
                                                               payStaging.Status__c = PROCESSED;
                                                               if(balanceAdjustment == true){
                                                                   DocumentType = 'Balance Adjustment Upload File';
                                                                   success += '\n';
                                                                   success += payStaging.CCS_Account__c
                                                                       +'\t' + (payStaging.Direct_Payment_Type__c!= null ? payStaging.Direct_Payment_Type__c : '')
                                                                       +'\t'+payStaging.Payment_Type__c
                                                                       +'\t' + (payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Principal_Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Interest_Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Payment_Source__c!= null ? payStaging.Payment_Source__c : '')
                                                                       +'\t'+(payStaging.Placement_Agency__c!= null ? payStaging.Placement_Agency__c : '')
                                                                       +'\t'+(payStaging.Commission_Rate_for_Payment__c != null ? payStaging.Commission_Rate_for_Payment__c :0);
                                                               }
                                                               else if(directPayment == true){
                                                                   DocumentType = 'Direct Payment Upload File';
                                                                   success += '\n';
                                                                   success +=  payStaging.CCS_Account__c+'\t'+payStaging.Payment_Type__c
                                                                       +'\t' + (payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Payment_Source__c!= null ? payStaging.Payment_Source__c : '')
                                                                       +'\t'+'\''+(payStaging.Primary_Account_Number__c!= null ? payStaging.Primary_Account_Number__c :'');
                                                               }
                                                               else{
                                                                   DocumentType = 'Product Payment Upload File';
                                                                   success += '\n';
                                                                   success += payStaging.CCS_Account__c+'\t'+payStaging.Payment_Type__c
                                                                       +'\t' + (payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Principal_Payment_Amount__c!= null ? payStaging.Principal_Payment_Amount__c : 0)
                                                                       +'\t'+(payStaging.Interest_Payment_Amount__c!= null ? payStaging.Interest_Payment_Amount__c :0)
                                                                       +'\t'+(payStaging.Pay_Court__c!= null ? payStaging.Pay_Court__c : '0')
                                                                       +'\t'+(payStaging.Pay_Attorney__c!= null ? payStaging.Pay_Attorney__c : '0')
                                                                       +'\t'+(payStaging.Pay_NSF__c!= null ? payStaging.Pay_NSF__c : '0')
                                                                       +'\t'+(payStaging.Pay_Fees__c!= null ? payStaging.Pay_Fees__c : 0)
                                                                       +'\t'+(payStaging.Pay_Other__c!= null ? payStaging.Pay_Other__c : 0)
                                                                       +'\t'+(payStaging.Agency_Calculated_Comm__c!= null ? payStaging.Agency_Calculated_Comm__c : '0');    
                                                               }
                                                               
                                                               successRecords = successRecords + 1;
                                                           }
                                                           else{
                                                               String CommentError;  
                                                               if(payStaging.Comment__c!= null){
                                                                   CommentError = payStaging.Comment__c;
                                                                   CommentError = CommentError.replaceAll('<br/>','');
                                                                   CommentError = CommentError.replaceAll('</b>','');
                                                                   CommentError = CommentError.replaceAll('<b>','');
                                                               }
                                                               if(balanceAdjustment == true){
                                                                   DocumentType = 'Balance Adjustment Upload File';
                                                                   failed += '\n';
                                                                   failed += payStaging.CCS_Account__c
                                                                       +'\t' + (payStaging.Direct_Payment_Type__c!= null ? payStaging.Direct_Payment_Type__c : '')
                                                                       +'\t'+payStaging.Payment_Type__c
                                                                       +'\t' + (payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Principal_Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Interest_Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Payment_Source__c!= null ? payStaging.Payment_Source__c : '')
                                                                       +'\t'+(payStaging.Placement_Agency__c!= null ? payStaging.Placement_Agency__c : '')
                                                                       +'\t'+(payStaging.Commission_Rate_for_Payment__c != null ? payStaging.Commission_Rate_for_Payment__c :0)
                                                                       +'\t'+ '"' + (payStaging.Comment__c!= null ? CommentError : '') + '"';
                                                               }
                                                               else if(directPayment == true){
                                                                   DocumentType = 'Direct Payment Upload File';
                                                                   failed += '\n';
                                                                   failed += payStaging.CCS_Account__c+'\t'+payStaging.Payment_Type__c
                                                                       +'\t'+(payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Payment_Source__c!= null ? payStaging.Payment_Source__c : '')
                                                                       +'\t'+'\''+(payStaging.Primary_Account_Number__c!= null ? payStaging.Primary_Account_Number__c :'')
                                                                       +'\t'+ '"' + (payStaging.Comment__c!= null ? CommentError : '') + '"';
                                                                   
                                                               }
                                                               else{
                                                                   DocumentType = 'Product Payment Upload File';
                                                                   failed += '\n';
                                                                   failed += payStaging.CCS_Account__c+'\t'+payStaging.Payment_Type__c
                                                                       +'\t'+(payStaging.Payment_Posting_Date__c!= null ? payStaging.Payment_Posting_Date__c : '') 
                                                                       +'\t'+(payStaging.Payment_Amount__c != null ? payStaging.Payment_Amount__c :0) 
                                                                       +'\t'+(payStaging.Principal_Payment_Amount__c!= null ? payStaging.Principal_Payment_Amount__c : 0)
                                                                       +'\t'+(payStaging.Interest_Payment_Amount__c!= null ? payStaging.Interest_Payment_Amount__c :0)
                                                                       +'\t'+(payStaging.Pay_Court__c!= null ? payStaging.Pay_Court__c : '0')
                                                                       +'\t'+(payStaging.Pay_Attorney__c!= null ? payStaging.Pay_Attorney__c : '0')
                                                                       +'\t'+(payStaging.Pay_NSF__c!= null ? payStaging.Pay_NSF__c : '0')
                                                                       +'\t'+(payStaging.Pay_Fees__c!= null ? payStaging.Pay_Fees__c : 0)
                                                                       +'\t'+(payStaging.Pay_Other__c!= null ? payStaging.Pay_Other__c : 0)
                                                                       +'\t'+(payStaging.Agency_Calculated_Comm__c!= '' ? payStaging.Agency_Calculated_Comm__c : '0')
                                                                       +'\t'+(payStaging.Comment__c!= null ? CommentError : '');
                                                               }
                                                               failedRecords = failedRecords + 1;
                                                           }
                                                       }                                        
                                                       system.enqueueJob(new PostDocumentAPI(DocumentType,failed,success,failedRecords,successRecords,workAssignmentId,visiblity,documentID));                                              
                                                   }
    
    //Recalculate Interest Amount and Principal balance payments are added
    public static void calculateBalanceBackdatedPayments(map<Id, Product_Payments__c> mapNewProductPayment,Savepoint sp, Id workAssignmentId, Id documentID){
        map<Id, Product__c> mapProductToAdjustInterestFinal = new map<Id, Product__c>();
        list<Product_Payments__c> listProdPaymentToUpdate = new list<Product_Payments__c>();
        set<ID> setProductID = new set<ID>();
        list<ID> setProductToUpdateStatus = new list<ID>();
        set<ID> setSettledInFullPayments = new Set<ID>();
        map<String, productWrapper> mapStatusProductWrapper = new map<String, productWrapper>();
        set<String> setReversalPayments = new set<String>();
        
        for(Product_Payments__c productPay : mapNewProductPayment.values()){
            setProductID.add(productPay.CCS_Account__c);
            if(productPay.Payment_Amount__c < 0){
                //get ID of the payments which are being reversed
                setReversalPayments.add(productPay.Original_Of_Payment_Reversal__c);
            }
        }
        map<ID, Product_Payments__c> mapReversedPayments = new map<ID, Product_Payments__c>();
        list<ID> listProductsIds = new list<ID>();
        for(Product_Payments__c prodPayment : [SELECT ID, Pay_Attorney__c, Pay_Court__c, Pay_Fees__c, Pay_NSF__c, Pay_Other__c, 
                                               Interest_Payment_Amount__c, Principal_Payment_Amount__c, Pay_Recoverable_Fee__c,
                                               Pay_Non_Recoverable_Fee__c, Payment_Amount__c, Product_Collection_Sub_Status__c, 
                                               Pay_Data_Status__c, Placement_Status_on_Product__c,Payment_Posting_Date__c,CCS_Account__c, 
                                               Product_Status_Desc_on_Product__c, Pay_Due__c, Tax_Amount__c,Tax_type__c,
                                               Balance_Before_Payment__c, Commission_Rate_For_payment__c, Product_Commission_Rate__c,
                                               Tax_Province__c, Legal_Product_Identifier__c, Tax_Province_Rate__c, Interest_Adjustment__c,
                                               Interest_Rate_to_For_Interest_Adjustment__c, No_of_Days_to_Adjust_Interest__c,Pay_Placedetail_Status__c,
                                               Payment_Type__c
                                               FROM Product_Payments__c
                                               WHERE ID IN : setReversalPayments]){
                                                   mapReversedPayments.put(prodPayment.ID, prodPayment);
                                                   listProductsIds.add(prodPayment.CCS_Account__c);                                         
                                               }
        map<ID,Date> mapProductNameIds = new map<ID,Date>();
        for(Account_judgment__c accJudgment : [SELECT ID, Name,Product__c, Judgment__c, Product__r.Name,
                                               Judgment__r.Judgment_Date__c
                                               FROM Account_Judgment__c 
                                               WHERE Product__c IN :listProductsIds
                                               AND Status__c = 'Active'
                                               AND (Judgment__r.Legal_Status__c = 'Judgment' 
                                                    OR Judgment__r.Legal_Status__c = 'Post-Judgment')
                                               AND Judgment__r.Judgment_Date__c != NULL
                                               ORDER BY CreatedDate DESC]){
                                                   mapProductNameIds.put(accJudgment.Product__c, accJudgment.Judgment__r.Judgment_Date__c);
                                               } 
        set<ID> prodPaymentId = new set<ID>();
        List<Product_Payments__C> latestPayment = [select Id,name,Payment_Posting_Date__c,Original_Of_Payment_Reversal__c 
                                                   from Product_Payments__C 
                                                   where CCS_Account__c IN: listProductsIds 
                                                   AND Original_Of_Payment_Reversal__c != null];
        
        for(Product_Payments__C prodpaylist : latestPayment){
            prodPaymentId.add(prodpaylist.Original_Of_Payment_Reversal__c);
        }
        
        for(Product__c productInstance : [SELECT ID, Name, Current_Interest_Amount__c,Collection_Agency__c,Last_Payment_Date__c,Last_Payment_Amount__c,
                                          Current_Principal_Balance__c, Collection_Sub_Status__c,
                                          Collection_Agency_Placement__c,
                                          Collection_Agency_Placement__r.Name,
                                          Collection_Agency_Placement__r.Commission_Rate_Mode__c,
                                          Current_Balance__c,Current_Bal_NSF_Fees__c,
                                          Non_Recoverable_Fee__c, Recoverable_Fee__c, Placement_Status__c, 
                                          Product_Status__c, Status__c, Data_Status_Description__c,Interest_Rate__c,
                                          Interest_Waived_Off_Start_Date__c, Interest_Waived_Of_End_Date__c ,
                                          Payment_Apportionment__c,Interest_Waived_Off__c,Closed_Date__c,
                                          (SELECT ID, Payment_Amount__c,Pay_NSF__c,Pay_Attorney__c,Payment_Posting_Date__c,Last_Payment_Date__c,Last_Payment_Amount__c,
                                           Pay_Court__c,Pay_Other__c,Pay_Fees__c,Interest_Payment_Amount__c,
                                           Pay_Due__c, Pay_Recoverable_Fee__c, Pay_Non_Recoverable_fee__c,Pay_Placedetail_Status__c,
                                           Principal_Payment_Amount__c,CCS_Account__c, Payment_Type__c, Original_Of_Payment_Reversal__c,Payment_Provided_Agency__c,
                    					   Product_Agency__c
                                           FROM Product_Payments__r
                                           WHERE
                                           // Payment_Amount__c > 0
                                           //AND Is_Payment_Reversed__c = false
                                           CCS_Account__r.RecordType.DeveloperName= :'Distressed_Account'
                                           AND ID IN :mapNewProductPayment.keySet()
                                           ORDER BY Payment_Posting_Date__c ASC)
                                          FROM Product__c
                                          WHERE ID IN :setProductID]){
                                              for(Product_Payments__c payProductInstance : productInstance.Product_Payments__r){
                                                  
                                                  Product_Payments__c prodPayToUpdate = new Product_Payments__c();
                                                  
                                                  prodPayToUpdate.ID = payProductInstance.ID;
                                                  prodPayToUpdate.Interest_Payment_Amount__c = payProductInstance.Interest_Payment_Amount__c;
                                                  prodPayToUpdate.Principal_Payment_Amount__c = payProductInstance.Principal_Payment_Amount__c;
                                                  prodPayToUpdate.Balance_Before_Payment__c = productInstance.Current_Balance__c;
                                                  prodPayToUpdate.Pre_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                                                  prodPayToUpdate.Pre_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                                                  prodPayToUpdate.Pay_NSF__c = '0';
                                                  //record product status at the time of payment on product Payment record
                                                  //prodPayToUpdate.Placement_Status_Code_on_Product__c = productInstance.Placement_Status__c;
                                                  prodPayToUpdate.Product_Collection_Sub_Status__c = productInstance.Collection_Sub_Status__c;
                                                  prodPayToUpdate.Pay_Data_Status__c = productInstance.Product_Status__c;
                                                  prodPayToUpdate.Product_Status_Desc_on_Product__c = productInstance.Data_Status_Description__c;
                                                  prodPayToUpdate.Placement_Status_on_Product__c = productInstance.Status__c;
                                                  prodPayToUpdate.Pay_Placedetail_Status__c = productInstance.Placement_Status__c;
                                                  
                                                  /*--------------Positive Amount Payment Calculation STARTS------------------------------*/
                                                  if(payProductInstance.Payment_Amount__c > = 0){
                                                      Decimal totalProductPayment = payProductInstance.Payment_Amount__c;
                                                      
                                                      //Set Product to Pending recall if paid In Full type Payment is made
                                                      if(payProductInstance.Payment_Type__c == PAYTYPE_PAID_IN_FULL){
                                                          productInstance.Collection_Sub_Status__c = 'Paid In Full Account';
                                                          productInstance.Sub_Status__c = null;
                                                          //if payement posted agency and product agency is not same
                                                          if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                                              productInstance.Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF;
                                                              productInstance.Placement_Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE;
                                                              placementStatusCode = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_PIF_CODE;
                                                              productInstance.Sub_Status__c = 'PIF';
                                                          }else{
                                                              productInstance.Status__c = PENDING_RECALL_PIF;
                                                              productInstance.Placement_Status__c = PENDING_RECALL_PIF_CODE;
                                                              placementStatusCode = PENDING_RECALL_PIF_CODE;
                                                          }
                                                          productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                                                          productInstance.Data_Status_Description__c = PENDING_RECALL;
                                                          productInstance.Status_Changed_Date__c = Date.today();
                                                          productNames += productInstance.Name + ',';
                                                          
                                                          setProductToUpdateStatus.add(productInstance.ID);
                                                          if(productInstance.Collection_Agency__c != NULL){
                                                              placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));    
                                                          }                                                         
                                                      }
                                                      
                                                      //Set Product to Pending recall if Settled In Full type Payment is made
                                                      if(payProductInstance.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL){
                                                          productInstance.Collection_Sub_Status__c = 'Settled In Full Account';
                                                          productInstance.Sub_Status__c = null;
                                                          //if payement posted agency and product agency is not same
                                                          if(payProductInstance.Payment_Provided_Agency__c <> payProductInstance.Product_Agency__c){
                                                              productInstance.Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF;
                                                              productInstance.Placement_Status__c = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE;
                                                              placementStatusCode = PENDING_RECALL_PAID_PRIOR_PREVIOUS_AGENCY_SIF_CODE;
                                                              productInstance.Sub_Status__c = 'SIF';
                                                          }else{
                                                              productInstance.Status__c = PENDING_RECALL_SIF;
                                                              productInstance.Placement_Status__c = PENDING_RECALL_SIF_CODE;
                                                              placementStatusCode = PENDING_RECALL_SIF_CODE;
                                                          }
                                                          productInstance.Product_Status__c = PENDING_RECALL_PRODUCT_STATUS_CODE;
                                                          productInstance.Data_Status_Description__c = PENDING_RECALL;
                                                          productInstance.Status_Changed_Date__c = Date.today();
                                                          productNames += productInstance.Name + ',';
                                                          
                                                          setProductToUpdateStatus.add(productInstance.ID);
                                                          if(productInstance.Collection_Agency__c != NULL){
                                                              placementIdentifier = String.valueOf(Math.floor(productInstance.Collection_Agency__c));    
                                                          }
                                                      }
                                                      
                                                      //DEDUCT INTEREST and PRINCIPAL
                                                      if(prodPayToUpdate.Interest_Payment_Amount__c != NULL){
                                                          productInstance.Current_Interest_Amount__c = productInstance.Current_Interest_Amount__c - prodPayToUpdate.Interest_Payment_Amount__c;   
                                                      }
                                                      
                                                      if(prodPayToUpdate.Principal_Payment_Amount__c != NULL){
                                                          productInstance.Current_Principal_Balance__c = productInstance.Current_Principal_Balance__c - prodPayToUpdate.Principal_Payment_Amount__c;    
                                                      }
                                                      
                                                      /*----------Interest Adjustment Starts--------------*/
                                                      Integer DaystoAdjust = 0;                    
                                                      DaystoAdjust +=  payProductInstance.Payment_Posting_Date__c.daysBetween(Date.today());
                                                      if(productInstance.Interest_Waived_Off__c == true
                                                         && productInstance.Interest_Waived_Off_Start_Date__c > payProductInstance.Payment_Posting_Date__c){
                                                             DaystoAdjust-= productInstance.Interest_Waived_Of_End_Date__c.daysBetween(productInstance.Interest_Waived_Off_Start_Date__c);
                                                         }
                                                      
                                                      Decimal InterestAdjustment = 0;
                                                      if(DaystoAdjust > 0 && payProductInstance.Payment_Type__c != '3000'){
                                                          if(payProductInstance.Principal_Payment_Amount__c != NULL 
                                                             && productInstance.Interest_Rate__c != NULL){
                                                                 //calculate the adjustment
                                                                 InterestAdjustment = 
                                                                     (((
                                                                         (payProductInstance.Principal_Payment_Amount__c)
                                                                         * (DaystoAdjust) * productInstance.Interest_Rate__c)/100)/365).setScale(2, RoundingMode.HALF_UP);
                                                                 
                                                                 prodPayToUpdate.Interest_Adjustment__c = InterestAdjustment;
                                                                 prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = DaystoAdjust;
                                                                 prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = productInstance.Interest_Rate__c;
                                                                 if(InterestAdjustment != null){
                                                                     //deduct interest paid amount on Product pay record
                                                                     productInstance.Current_Interest_Amount__c -= InterestAdjustment;    
                                                                     productInstance.Current_Balance__c -= InterestAdjustment; // DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                                                                 }
                                                             }
                                                      }
                                                      /*----------Interest Adjustment Ends--------------*/
                                                      
                                                      //----------------------------------------------------------------------------------------------
                                                      
                                                      //Payment after balances    
                                                      prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                                                      prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                                                      
                                                      /*if(payProductInstance.Payment_Type__c != '3000'){
productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;
}*/
                                                      
                                                      //Update total balance on Product
                                                      productInstance.Current_Balance__c = productInstance.Current_Balance__c - payProductInstance.Payment_Amount__c;
                                                      if(InterestAdjustment > 0){
                                                          productInstance.Current_Balance__c = productInstance.Current_Balance__c - InterestAdjustment;
                                                      }
                                                      prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                                                  }
                                                  /*--------------Positive Amount Payment Calculation ENDS------------------------------*/
                                                  
                                                  /*--------------Reversed Payment Calculation STARTS------------------------------*/
                                                  //If reversed payment is added, it is added to Balances on Product as per original Payment
                                                  if(payProductInstance.Payment_Amount__c < 0){
                                                      Boolean calflag = false;                        
                                                      if(mapReversedPayments.containsKey(payProductInstance.Original_Of_Payment_Reversal__c)
                                                         && payProductInstance.Payment_Type__c != '3000'){
                                                             Product_Payments__c reversedPay = mapReversedPayments.get(payProductInstance.Original_Of_Payment_Reversal__c);
                                                             if(reversedPay.Payment_Type__c != PAYTYPE_REGULAR){
                                                                 //revert the statuses
                                                                 productInstance.Placement_Status__c = reversedPay.Pay_Placedetail_Status__c;
                                                                 productInstance.Product_Status__c = reversedPay.Pay_Data_Status__c;
                                                                 productInstance.Collection_Sub_Status__c = reversedPay.Product_Collection_Sub_Status__c;
                                                                 productInstance.Data_Status_Description__c = reversedPay.Product_Status_Desc_on_Product__c;
                                                                 productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;
                                                                 //Ticket 6495: whenver we reverse PIF or SIF payments then reset closded date
                                                                 if (reversedPay.Payment_Type__c == PAYTYPE_SETTLED_IN_FULL || reversedPay.Payment_Type__c == PAYTYPE_PAID_IN_FULL) {
                                                                     if(productInstance.Closed_Date__c <> NULL){
                                                                         productInstance.Closed_Date__c = NULL;
                                                                     }
                                                                 }
                                                                 if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                     if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                         productInstance.Status__c = reversedPay.Placement_Status_on_Product__c;  
                                                                     }
                                                                 }else{
                                                                     productInstance.Status__c = reversedPay.Placement_Status_on_Product__c; 
                                                                 }
                                                             }
                                                             //revert amounts
                                                             if(reversedPay.Pay_Due__c!= NULL){
                                                                 prodPayToUpdate.Pay_Due__c= reversedPay.Pay_Due__c* -1;    
                                                             }
                                                             
                                                             if(reversedPay.Tax_Amount__c != NULL){
                                                                 prodPayToUpdate.Tax_Amount__c = reversedPay.Tax_Amount__c * -1;    
                                                             }
                                                             
                                                             if(String.isnotblank(reversedPay.Tax_type__c)){
                                                                 prodPayToUpdate.Tax_type__c = reversedPay.Tax_type__c;    
                                                             }
                                                             
                                                             if(reversedPay.Commission_Rate_For_payment__c != NULL){
                                                                 prodPayToUpdate.Commission_Rate_For_payment__c = reversedPay.Commission_Rate_For_payment__c;    
                                                             }
                                                             
                                                             if(reversedPay.Product_Commission_Rate__C!= NULL){
                                                                 prodPayToUpdate.Product_Commission_Rate__C = reversedPay.Product_Commission_Rate__C;    
                                                             }
                                                             
                                                             if(reversedPay.Legal_Product_Identifier__c != NULL){
                                                                 prodPayToUpdate.Legal_Product_Identifier__c = reversedPay.Legal_Product_Identifier__c;    
                                                             }
                                                             
                                                             if(reversedPay.Tax_Province__c != NULL){
                                                                 prodPayToUpdate.Tax_Province__c = reversedPay.Tax_Province__c;    
                                                             }
                                                             
                                                             if(reversedPay.Tax_Province_Rate__c != NULL){
                                                                 prodPayToUpdate.Tax_Province_Rate__c = reversedPay.Tax_Province_Rate__c;    
                                                             }
                                                             
                                                             if(reversedPay.Pay_NSF__c <> '0'){
                                                                 productInstance.Current_Bal_NSF_Fees__c = 
                                                                     (productInstance.Current_Bal_NSF_Fees__c != NULL 
                                                                      ? (productInstance.Current_Bal_NSF_Fees__c + Decimal.valueOf(reversedPay.Pay_NSF__c)) 
                                                                      : Decimal.valueOf(reversedPay.Pay_NSF__c));
                                                                 Decimal payNSF = Decimal.valueOf(reversedPay.Pay_NSF__c);
                                                                 Decimal newpayNSF = payNSF * -1;
                                                                 prodPayToUpdate.Pay_NSF__c = String.valueOf(newpayNSF);
                                                             }
                                                             if(reversedPay.Pay_Recoverable_Fee__c != NULL && reversedPay.Pay_Recoverable_Fee__c <> 0){
                                                                 productInstance.Recoverable_Fee__c = 
                                                                     (productInstance.Recoverable_Fee__c != NULL 
                                                                      ? (productInstance.Recoverable_Fee__c + reversedPay.Pay_Recoverable_Fee__c) 
                                                                      : reversedPay.Pay_Recoverable_Fee__c);
                                                                 prodPayToUpdate.Pay_Recoverable_Fee__c = reversedPay.Pay_Recoverable_Fee__c * -1;
                                                             }
                                                             if(reversedPay.Pay_Non_Recoverable_Fee__c != NULL && reversedPay.Pay_Non_Recoverable_Fee__c <> 0){
                                                                 productInstance.Non_Recoverable_Fee__c = 
                                                                     (productInstance.Non_Recoverable_Fee__c != NULL 
                                                                      ? (productInstance.Non_Recoverable_Fee__c + reversedPay.Pay_Non_Recoverable_Fee__c) 
                                                                      : reversedPay.Pay_Non_Recoverable_Fee__c);
                                                                 prodPayToUpdate.Pay_Non_Recoverable_Fee__c = reversedPay.Pay_Non_Recoverable_Fee__c * -1;
                                                             }
                                                             
                                                             if(reversedPay.Interest_Payment_Amount__c != NULL && reversedPay.Interest_Payment_Amount__c <> 0  &&
                                                                productInstance.Current_Interest_Amount__c >= 0){
                                                                    //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                                                    if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                        if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                            calflag = true;
                                                                            productInstance.Current_Interest_Amount__c = 
                                                                                (productInstance.Current_Interest_Amount__c != NULL 
                                                                                 ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c) 
                                                                                 : reversedPay.Interest_Payment_Amount__c);
                                                                        }
                                                                    }else{
                                                                        calflag = true;
                                                                        productInstance.Current_Interest_Amount__c = 
                                                                            (productInstance.Current_Interest_Amount__c != NULL 
                                                                             ? (productInstance.Current_Interest_Amount__c + reversedPay.Interest_Payment_Amount__c) 
                                                                             : reversedPay.Interest_Payment_Amount__c);
                                                                    }  
                                                                    prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                                                                }
                                                             else{
                                                                 if(productInstance.Current_Interest_Amount__c < 0){
                                                                     productInstance.Current_Interest_Amount__c = 0;
                                                                 }
                                                                 //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                                                 if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                     if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                         calflag = true;
                                                                         productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                                                     }
                                                                 }else{
                                                                     calflag = true;
                                                                     productInstance.Current_Interest_Amount__c += reversedPay.Interest_Payment_Amount__c;
                                                                 }
                                                                 prodPayToUpdate.Interest_Payment_Amount__c = reversedPay.Interest_Payment_Amount__c * -1;
                                                             }
                                                             
                                                             if(reversedPay.Principal_Payment_Amount__c != NULL
                                                                && reversedPay.Principal_Payment_Amount__c <> 0){
                                                                    //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                                                    if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                        if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                            calflag = true;
                                                                            productInstance.Current_Principal_Balance__c = 
                                                                                (productInstance.Current_Principal_Balance__c != NULL 
                                                                                 ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c) 
                                                                                 : reversedPay.Principal_Payment_Amount__c);
                                                                        }
                                                                    }
                                                                    else{
                                                                        calflag = true;
                                                                        productInstance.Current_Principal_Balance__c = 
                                                                            (productInstance.Current_Principal_Balance__c != NULL 
                                                                             ? (productInstance.Current_Principal_Balance__c + reversedPay.Principal_Payment_Amount__c) 
                                                                             : reversedPay.Principal_Payment_Amount__c);
                                                                    }
                                                                    prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c * -1;
                                                                }
                                                             else{
                                                                 prodPayToUpdate.Principal_Payment_Amount__c = reversedPay.Principal_Payment_Amount__c;
                                                             }
                                                             
                                                             if(reversedPay.Interest_Adjustment__c != NULL
                                                                && reversedPay.Interest_Adjustment__c <> 0 && reversedPay.Interest_Adjustment__c < 0){
                                                                    prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1;
                                                                    prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                                                    prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                                                    
                                                                    
                                                                    //adding adjustment to payment amount, so that it would deduct from inetrest
                                                                    //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;
                                                                    //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                                                    if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                        if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                            calflag = true;
                                                                            productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                                                        }
                                                                    }else{
                                                                        calflag = true;
                                                                        productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c;
                                                                    }
                                                                }
                                                             else{
                                                                 if(reversedPay.Interest_Adjustment__c != NULL
                                                                    && reversedPay.Interest_Adjustment__c <> 0){
                                                                        prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c;
                                                                        prodPayToUpdate.No_of_Days_to_Adjust_Interest__c = reversedPay.No_of_Days_to_Adjust_Interest__c;
                                                                        prodPayToUpdate.Interest_Rate_to_For_Interest_Adjustment__c = reversedPay.Interest_Rate_to_For_Interest_Adjustment__c;
                                                                        //adding adjustment to payment amount, so that it would deduct from inetrest
                                                                        //productInstance.Current_Principal_Balance__c -= prodPayToUpdate.Interest_Adjustment__c;
                                                                        
                                                                        //product has active judgment and paymet posting date is greater than judgment date then only reversal calculation will done
                                                                        if(mapProductNameIds.containsKey(reversedPay.CCS_Account__c)){
                                                                            if(reversedPay.Payment_Posting_Date__c >= mapProductNameIds.get(reversedPay.CCS_Account__c)){
                                                                                calflag = true;
                                                                                productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c; 
                                                                            }
                                                                        }else{
                                                                            calflag = true;
                                                                            productInstance.Current_Interest_Amount__c += prodPayToUpdate.Interest_Adjustment__c; 
                                                                        }
                                                                        prodPayToUpdate.Interest_Adjustment__c = reversedPay.Interest_Adjustment__c * -1;  
                                                                    }
                                                             }
                                                         }
                                                      
                                                      if(payProductInstance.Payment_Type__c == '3000'){
                                                          //DEDUCT INTEREST and PRINCIPAL
                                                          if(prodPayToUpdate.Interest_Payment_Amount__c != NULL){
                                                              calflag = true;
                                                              productInstance.Current_Interest_Amount__c = 
                                                                  productInstance.Current_Interest_Amount__c - prodPayToUpdate.Interest_Payment_Amount__c;   
                                                          }
                                                          
                                                          if(prodPayToUpdate.Principal_Payment_Amount__c != NULL){
                                                              calflag = true;
                                                              productInstance.Current_Principal_Balance__c = 
                                                                  productInstance.Current_Principal_Balance__c - prodPayToUpdate.Principal_Payment_Amount__c;    
                                                          }
                                                      }
                                                      
                                                      //Payment after balances    
                                                      prodPayToUpdate.Post_Pay_Interest__c = productInstance.Current_Interest_Amount__c;
                                                      prodPayToUpdate.Post_Pay_Principal__c = productInstance.Current_Principal_Balance__c;
                                                      
                                                      //Update total balance on Product
                                                      //add reverse pay amount to current balance, pay amount is negative (- - = +)
                                                      if(calflag == True){
                                                          //productInstance.Current_Balance__c = productInstance.Current_Balance__c - (payProductInstance.Payment_Amount__c);
                                                          //productInstance.Current_Balance__c= productInstance.Recoverable_Fee__c+productInstance.Current_Principal_Balance__c+productInstance.Current_Interest_Amount__c+productInstance.Current_Bal_NSF_Fees__c;  
                                                          productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                                                      }
                                                      
                                                      prodPayToUpdate.Balance_After_Payment__c = productInstance.Current_Balance__c;
                                                      
                                                      /*if(payProductInstance.Payment_Type__c != '3000'){
productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;
}*/
                                                      //mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                                                  }
                                                  /*--------------Reversed Payment Calculation ENDS------------------------------*/
                                                  
                                                  
                                                  //Populate latest last payment date and last payment amount on product
                                                  
                                                  if(payProductInstance.Payment_Type__c == '1000' || payProductInstance.Payment_Type__c == '1001' || payProductInstance.Payment_Type__c == '1002' ||payProductInstance.Payment_Type__c == '8000'
                                                     && (productInstance.Last_Payment_Date__c <= payProductInstance.Payment_Posting_Date__c || productInstance.Last_Payment_Date__c == null)){
                                                         
                                                         //set old date and amount on product payment
                                                         prodPayToUpdate.Last_Payment_Date__c = productInstance.Last_Payment_Date__c;
                                                         prodPayToUpdate.Last_Payment_Amount__c= productInstance.Last_Payment_Amount__c;
                                                         
                                                         //set new latest date and amount on product
                                                         productInstance.Last_Payment_Date__c = payProductInstance.Payment_Posting_Date__c;
                                                         productInstance.Last_Payment_Amount__c = payProductInstance.Payment_Amount__c;
                                                         
                                                     }
                                                  
                                                  
                                                  if(payProductInstance.payment_type__c == '1003' && productInstance.Last_Payment_Date__c == payProductInstance.Payment_Posting_Date__c && productInstance.Last_Payment_Amount__c == (payProductInstance.Payment_Amount__c*-1)){
                                                      if(prodPaymentId !=null ){
                                                          List<Product_Payments__C> latestPayment1 = [select Id,name,Payment_Posting_Date__c,Payment_Amount__c
                                                                                                      from Product_Payments__C where CCS_Account__c =: payProductInstance.CCS_Account__c
                                                                                                      AND Payment_Amount__c > 0
                                                                                                      AND Payment_Posting_Date__c <=: productInstance.Last_Payment_Date__c
                                                                                                      AND (Payment_Type__c = '1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'OR Payment_Type__c = '8000') 
                                                                                                      AND Id NOT IN: prodPaymentId order by Payment_Posting_Date__c desc limit 1];
                                                          if(!latestPayment1.isEmpty()){
                                                              for(Product_Payments__C prodPay : latestPayment1){
                                                                  productInstance.Last_Payment_Date__c = prodPay.Payment_Posting_Date__c;
                                                                  productInstance.Last_Payment_Amount__c = prodPay.Payment_Amount__c;
                                                              }
                                                          }else{
                                                              product_Payments__c prodOldDate = [select id,name,Last_Payment_Date__c,Last_Payment_Amount__c from product_Payments__c 
                                                                                                 where CCS_Account__c =: payProductInstance.CCS_Account__c 
                                                                                                 AND (Payment_Type__c = '1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'OR Payment_Type__c = '8000') order by name ASC limit 1];
                                                              productInstance.Last_Payment_Date__c = prodOldDate.Last_Payment_Date__c;
                                                              productInstance.Last_Payment_Amount__c = prodOldDate.Last_Payment_Amount__c;
                                                          }
                                                          
                                                      }
                                                  }
                                                  //productInstance.Current_Balance__c = DistressedUtilites_Total.UpdateTotalCurrentBalance(productInstance);
                                                  mapProductToAdjustInterestFinal.put(productInstance.ID, productInstance);
                                                  listProdPaymentToUpdate.add(prodPayToUpdate);
                                              }
                                          }
        
        ProductTriggerHandler.runProductTrigger = false;
        ProductPaymentstriggerHandler.runProductTrigger = false;
        //update mapProductToAdjustInterestFinal.values();
        List<Database.SaveResult> updateResults = Database.update(mapProductToAdjustInterestFinal.values(),true);                                        
       List<Database.SaveResult> ErrorrResult = new List<Database.SaveResult>();
        set<Id> prodIdList = new set<Id>();
        for(Database.SaveResult res : updateResults){
             if(res.isSuccess() == false){
                 	prodIdList.add(res.getId());
                    ErrorrResult.add(res); 
             }
        }      
        update listProdPaymentToUpdate;
       
        if(!setProductToUpdateStatus.isEmpty()){
            PortalProductProcessingAPI.processProductBulkBatch(setProductToUpdateStatus, new List<Product__c>());
        }
        
        ProductTriggerHandler.runProductTrigger = true;
        ProductPaymentstriggerHandler.runProductTrigger = true;
        
         //For ticket 4518 - satyajit patil                                                    
        if(!ErrorrResult.isEmpty()){                                                    
        	Database.rollback(sp);
            
        	DistressedUtilities.GenerateSuccessAndErrorFile(ErrorrResult,workAssignmentId,documentID,prodIdList); 
        }
    }
   
    
    public class productPaymentStagingWrapper{
        public Product_Payment_Staging__c payStaging {get;set;}
        public boolean selected {get;set;}
        public boolean disabled {get;set;}
        public productPaymentStagingWrapper(Product_Payment_Staging__c pay, Boolean disable){
            payStaging = pay;
            selected = false;
            disabled = disable;
        }
    }
    
    public class productWrapper{
        public String productName;
        public String placementStatusCode;
        public String productStatusCode;
        public String placementIdentifier;
        public productWrapper(String productName,String placementStatusCode, String productStatusCode, String placementIdentifier){
            this.productName = productName;
            this.placementStatusCode = placementStatusCode;
            this.productStatusCode = productStatusCode;
            this.placementIdentifier = placementIdentifier;
        }
    }
    
     /*public static void createError(List<Database.SaveResult> saveResults, Map<ID,Product__c> objectList){
        try{
            //error object list
            List<Error_Log__c> errorList = new List<Error_Log__c>();
            for( integer i=0; i < saveResults.size(); i++ ){
                if (saveResults.get(i).isSuccess()) {
                    //add the code here if you want to do something in success case
                }//error case
                else if(! saveResults.get(i).isSuccess()){
                    // Operation failed, so get all errors        
                    Database.Error dbError = saveResults.get(i).getErrors().get(0);

                    system.debug('Failed record id: '+ (String) objectList[i].get('Id'));
                    String recordId, recordName = '';
                    if(objectList.size()>0){
                        recordId = (String) objectList[i].get('Id');
                        recordName = (String) objectList[i].get('Name');
                    }

                    Error_Log__c err = new Error_Log__c();
                    err.Error_Message__c = dbError.getMessage();
                    err.Stack_Trace__c = String.valueOf(dbError.getStatusCode());
                    err.Record_ID__c = recordId;
                    err.Record_Name__c = recordName;
                    err.Topic__c = topic;
                    //add error in the list
                    errorList.add(err);
                }
            }
            if (errorList.size()>0) {
                insert errorList;
            }
        }catch(Exception e){
            System.debug('Exception has occured! ' + e.getMessage());
        }
    }
}*/
}