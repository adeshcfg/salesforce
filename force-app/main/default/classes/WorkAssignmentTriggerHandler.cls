/**************************************************************************************************
*
*  Class:   
*
*  @description : This is a trigger handler class for Work Assignment object. The code is not bulkified. 
*  @author : A5E Consulting
*  @date : 07/12/2021

*************************************************************************************************/
public class WorkAssignmentTriggerHandler {
    
    public static boolean runWorkAssignmentTrigger = true;
    public static Map <String, Id> WorkAssRecTypeMap;
    //public static Id CFG_Complaint = '0127g000001QgFEAA0';
   //  public static Id Agency_Complaint = '0127g000001QgFDAA0';
    public static boolean commentStatus = True;
    
    public static Map <String, Id> getCaseRecorTypeMap(){
        Map <String, Id> WorkAssRecTypeMap = new Map<String, Id>();
        //Fetch Record Type list of Case
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Work_Assignment__c'];
        for(RecordType recordType : recordTypes){
            WorkAssRecTypeMap.put(recordType.DeveloperName, recordType.Id);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.DeveloperName);
        }    
        return WorkAssRecTypeMap;
    }
    
    static{
        WorkAssRecTypeMap = getCaseRecorTypeMap(); 
    }

   //this inner method populate the comment, comment history and user name.
    public static void handleBeforeInsert(List<Work_Assignment__c> wrkAssgns ) {
        system.debug('inside before insert trigger');
        list<Work_Assignment__c> listInternalNewWorkAssignment = new list<Work_Assignment__c>();
        list<Work_Assignment__c> listExternalNewWorkAssignment = new list<Work_Assignment__c>();
        DateTime dT = System.now();
        set<ID> setProductID = new set<ID>();
        system.debug('wrkAssgns test::' +wrkAssgns);
        for(Work_Assignment__c listwork : wrkAssgns ){
            setProductID.add(listwork.Product__c);
        }
        system.debug('setProductID test::' +setProductID);
        list<Product__c> prodList = [Select id ,Name, Originating_Creditor__c,Previous_Primary_Account_Number__c,Collection_Agency_Placement__c
                                     from Product__c where ID =:setProductID  ];
        system.debug('prodList test::' +prodList);
        For(Work_Assignment__c listWorkAssignment : wrkAssgns){
            For (Product__c prod :prodList ){
                try{
                    if (listWorkAssignment.Product__c != Null || listWorkAssignment.Original_Creditor__c == Null){
                        system.debug('Block run 1 '+prod.Originating_Creditor__c);
                        listWorkAssignment.Original_Creditor__c = prod.Originating_Creditor__c ; 
                    }
                    if (listWorkAssignment.Product__c != Null && prod.Previous_Primary_Account_Number__c != Null){
                        listWorkAssignment.Primary_Account_Number__c = prod.Previous_Primary_Account_Number__c ; 
                    }
                    if(listWorkAssignment.Product__c != null){
                        System.debug('Run Data');
                        listWorkAssignment.Placement_Agency__c = prod.Collection_Agency_Placement__c;
                        system.debug('listWorkAssignment.Placement_Agency__c::'+listWorkAssignment.Placement_Agency__c);
                    }
                }
                Catch(Exception e){
                    System.debug('Blockrun 2'+e);
                }
            }
        }
        
        for(Work_Assignment__c workAssig : wrkAssgns){
            system.debug('workAssig.Source__c: '+workAssig.Source__c);
            /*if(workAssig.Source__c == 'Agency'){
            
                workAssig.RecordTypeId = distressCS.Record_Type_Agency__c;
            
            }*/
            system.debug('workAssig: '+workAssig);
            workAssig.Created_By__c =  UserInfo.getName();
            String commReply = '';
            if(workAssig.Comment_Reply__c != null){
                commReply = String.valueOf(workAssig.Comment_Reply__c).replace('\n', '').replace('\r', '');
                workAssig.Latest_Comment__c = commReply;
                workAssig.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + commReply;
                workAssig.Comment_Reply__c = '';
            }
            
            /*if(workAssig.Statements__c == True && workAssig.Start_Month__c == null){
                workAssig.Start_Month__c.addError('If Statment is check than Start Month cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.Start_Year__c    == null){
                workAssig.Start_Year__c .addError('If Statment is check than Start Year cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.End_Month__c == null){
                workAssig.End_Month__c.addError('If Statment is check than End Month cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.End_Year__c == null){
                workAssig.End_Year__c.addError('If Statment is check than End Year cannot be blank');
            }*/
            
            if(workAssig.Start_Year__c !=Null  && workAssig.Start_Month__c !=Null && workAssig.End_Year__c!=Null && workAssig.End_Month__c!=Null ){
                String StartDate = workAssig.Start_Year__c +  workAssig.Start_Month__c ;
                System.debug('Block ***123***'  + StartDate );   
                
                String EndDate = workAssig.End_Year__c +  workAssig.End_Month__c  ;
                System.debug('Block ***$$$$***'  + EndDate );
                
                
                String TodaydT = String.valueOf(date.Today().Year())  + String.valueOf(date.Today().Month()) ;
                System.debug('Blockrun'+TodaydT);
                
                Integer StartDateInt = Integer.valueOf(StartDate);
                Integer EndDateInt = Integer.valueOf(EndDate);
                //Integer TodayInt = Integer.valueOf(TodaydT);
                system.debug('%%%%%%'+StartDateInt);
                system.debug('*******'+EndDateInt);
                
                if(workAssig.Statements__c == True && StartDateInt > EndDateInt ){
                    workAssig.Adderror('End Date should be greater than Start Date'); 
                }
            }
            
            if(workAssig.Statements__c == False){
                workAssig.Start_Month__c = null ;
                workAssig.Start_Year__c = null ;
                workAssig.End_Month__c = null ;
                workAssig.End_Year__c = null ;
            }
            
            if(workAssig.Placement_Agency__c <> NULL ){
                listInternalNewWorkAssignment.add(workAssig);
            }
             if(workAssig.Product__c <> NULL ){
                listInternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Customer__c <> NULL ){
                listInternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Settlement__c <> NULL ){
                listInternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Judgment__c <> NULL ){
                listInternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Placement_Agency_Identifier__c <> NULL ){
                listExternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Product_Identifier__c <> NULL ){
                listExternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Customer_Identifier__c <> NULL ){
                listExternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Settlement_Identifier__c <> NULL ){
                listExternalNewWorkAssignment.add(workAssig);
            }
            if(workAssig.Judgment_Identifier__c <> NULL ){
                listExternalNewWorkAssignment.add(workAssig);
            }
        }
        system.debug('listInternalNewWorkAssignment inside insert' +listInternalNewWorkAssignment);
        //method calls once record created in CFG
        getWorkAssignmentRelatedData(listInternalNewWorkAssignment);  
    }
   
    
    
     //Method to handle after insert of record
    public static void handleAfterInsert(list<Work_Assignment__c> listNewWorkAssignments){
        system.debug('after insert');
        /*for(Work_Assignment__c workAssignment: listNewWorkAssignments){
            //call API
            PortalWorkAssignmentProcessingAPI.processWorkAssignment(workAssignment.ID, 'after insert');    
        }*/
        system.debug('listNewWorkAssignments:::' +listNewWorkAssignments);
        Work_Assignment__c newListWorkAss = listNewWorkAssignments.get(0);
        set<ID> setProductID = new set<ID>();
        set<ID> setCustomerID = new set<ID>();
       
        system.debug('newListWorkAss:::' +newListWorkAss);
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('CFG_Complaint'));
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('Agency_Complaint'));
        
        if((newListWorkAss.recordTypeID != null && newListWorkAss.recordTypeID == WorkAssRecTypeMap.get('CFG_Complaint'))
            || (newListWorkAss.recordTypeID != null && newListWorkAss.recordTypeID == WorkAssRecTypeMap.get('Agency_Complaint'))){           
              
            for(Work_Assignment__c wrkAss : listNewWorkAssignments){
                setProductID.add(wrkAss.Product__c);
                setCustomerID.add(wrkAss.Customer__c);
                
            }
            
            AggregateResult[] custGroupedResults = [select Customer__c, Count(Customer__r.SF_ID__c)comptCustomercnt from Work_Assignment__c 
                                                WHERE Customer__c IN :setCustomerID 
                                                AND Customer__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                GROUP BY Customer__c];
            System.Debug('custGroupedResults' +custGroupedResults);
            ProductTriggerHandler.runProductTrigger = false;
            for (AggregateResult arr : custGroupedResults)  {
                if((decimal)arr.get('comptCustomercnt') > 0){
                    Account cust=new Account();
                    cust.Id=(id)arr.get('Customer__c'); 
                    cust.Number_Of_Open_Complaint__c=(decimal)arr.get('comptCustomercnt'); 
                    update cust;
                }
            }
            ProductTriggerHandler.runProductTrigger = true;
             set<ID> customerID =new set<ID>();
                system.debug('setProductID::'+setProductID);
            AggregateResult[] prodGroupedResults = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE Product__c IN :setProductID 
                                                AND Product__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request' AND Status__c != 'Unjustified - Cease and Desist - Active') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                GROUP BY Product__c];
            System.Debug('prodGroupedResults' +prodGroupedResults);
            for (AggregateResult ar : prodGroupedResults)  {
                if((decimal)ar.get('comptProductcnt') > 0){
                    Product__c prodCustomer = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)ar.get('Product__c')];
                    //Account acc = new Account();
                  if(prodCustomer.Customer__c != NULL)  customerID.add(prodCustomer.Customer__c); //added null check for #5223
                    Product__c pr1=new Product__c();
                    pr1.Id=(id)ar.get('Product__c'); 
                    pr1.Number_Of_Open_Complaint__c=(decimal)ar.get('comptProductcnt'); 
                    //acc.id = prodCustomer.Customer__c;
                    //acc.Number_Of_Open_Product_Complaint__c  = (decimal)ar.get('comptProductcnt');
                    ProductTriggerHandler.runProductTrigger = false;
                    update pr1;
                    //update acc;
                    //PortalProductProcessingAPI.processProduct(pr1.ID);   
                }
            }
            ProductTriggerHandler.runProductTrigger = True;
                 set<Id> custProdId = new set<ID>();
                List<Product__C> cutProdList = [Select id,name from Product__c where customer__c IN: customerID LIMIT 50000]; //added LIMIT for #5223
                system.debug('cutProdList:'+cutProdList);
                for(Product__C custprod : cutProdList){
                    custProdId.add(custprod.Id);
                }
                AggregateResult[] prodGroupedResults1 = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE (Product__c IN :custProdId AND Product__c != NULL)
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request' AND Status__c != 'Unjustified - Cease and Desist - Active') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint') GROUP BY Product__c];
                system.debug('prodGroupedResults1:'+prodGroupedResults1);
                Id cutomerId;
                Decimal prodcomplaintcount = 0;
                for(AggregateResult prdlist : prodGroupedResults1){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)prdlist.get('Product__c')];
                    cutomerId = prodCustomer1.Customer__c;
                    //system.debug('inside for');
                    prodcomplaintcount = prodcomplaintcount + (Decimal)prdlist.get('comptProductcnt');
                    //system.debug('prodcomplaintcount::'+prodcomplaintcount);
                }
                system.debug('prodcomplaintcount211::'+prodcomplaintcount);
                //system.debug('cutomerId::'+cutomerId);
                if(cutomerId != null){
                    //system.debug('prodcomplaintcount45785:'+prodcomplaintcount);
                    Account acc = new Account();
                    acc.id = cutomerId;
                    acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                    //update pr1;
                    CustomerTriggerHandler.runCustomerTrigger= false;
                    update acc;     
                    CustomerTriggerHandler.runCustomerTrigger= true;
                }
        }
    }         
    @future (callout=true)
    public static void notificationCallAPI(String placeId, String Type, String Title, String Message){      
        	PortalNotificationAPI.sendPaymentNotification(placeId,Type,Title,'',Message);
    }
    //Method to handle after update of record
    public static void handleAfterUpdate(list<Work_Assignment__c> listNewWorkAssignments, map<ID, Work_Assignment__c> mapOldWorkAssignment){
        Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
       //Bug: 5555 - Changes Starts
       map<ID, Work_Assignment__c> mapNewWorkAssignment = new map<ID, Work_Assignment__c>();
       for(Work_Assignment__c workAssignment: listNewWorkAssignments){
        mapNewWorkAssignment.put(workAssignment.id,workAssignment);
       }
       //Bug: 5555 - Changes Ends
        if (config.Run_WorkAssignment_API_for_Portal__c){
            system.debug('listNewWorkAssignment check**'+listNewWorkAssignments);
                system.debug('mapOldWorkAssignment check**'+mapOldWorkAssignment);
            for(Work_Assignment__c workAssignment: listNewWorkAssignments){
              if (workAssignment.RecordTypeId == config.CFGWorkAssignmentRecordTypeId__c 
               || workAssignment.RecordTypeId == config.Agency_Work_Assignment_RecordTypeID__c 
               || workAssignment.RecordTypeId == config.CFGMediaWorkAssignmentRecordTypeID__c 
               || workAssignment.RecordTypeId == config.AgencyMediaWorkAssignmentRecordTypeID__c
               || workAssignment.RecordTypeId == config.AgencyExcelProcessingRecordTypeID__c
               || workAssignment.RecordTypeId == config.CFGExcelProcessingReccordTypeID__c){
                    system.debug('workAssignment.RecordTypeId*** ' +workAssignment.RecordTypeId);
                    system.debug('config*******');
                   PortalWorkAssignmentProcessingAPI.processWorkAssignment(workAssignment.ID, 'after update',commentStatus);
               }
                
                else if (workAssignment.RecordTypeId == config.CFGComplaintWorkAssignmentRecordID__c || workAssignment.RecordTypeId == config.AgencyComplaintWorkAssignmentRecordType__c){
                    system.debug('workAssignment.RecordTypeId ' +workAssignment.RecordTypeId);
                    system.debug('config');
                    if(!Test.isRunningTest()){
                        //Bug: 5555 - Added 4th parameter
                       PortalComplaintProcessingAPI.processComplaint(workAssignment.ID, 'after update', mapOldWorkAssignment.get(workAssignment.Id).Latest_Comment__c,mapNewWorkAssignment.get(workAssignment.Id).Latest_Comment__c);
                    }
                    if(workAssignment.Agency_Currently_Has_Account_On_Hold__c != NULL &&
                      mapOldWorkAssignment.get(workAssignment.Id).Agency_Currently_Has_Account_On_Hold__c != NULL){
                          if(workAssignment.Agency_Currently_Has_Account_On_Hold__c != mapOldWorkAssignment.get(workAssignment.Id).Agency_Currently_Has_Account_On_Hold__c){
                              notificationCallAPI(workAssignment.Placement_Agency_Identifier__c,'Complaint','Complaint No: '+workAssignment.Name+' Agency Currently Has Any Account(s) On Hold','Changed from current state '+mapOldWorkAssignment.get(workAssignment.Id).Agency_Currently_Has_Account_On_Hold__c+' to new state '+workAssignment.Agency_Currently_Has_Account_On_Hold__c);
                          }
                    }
                    if(workAssignment.Account_Being_CB_Reported_By_Agency__c != NULL &&
                       mapOldWorkAssignment.get(workAssignment.Id).Account_Being_CB_Reported_By_Agency__c != NULL){
                           if(workAssignment.Account_Being_CB_Reported_By_Agency__c != mapOldWorkAssignment.get(workAssignment.Id).Account_Being_CB_Reported_By_Agency__c){
                               notificationCallAPI(workAssignment.Placement_Agency_Identifier__c,'Complaint','Complaint No: '+workAssignment.Name+' File Being CB Reported by Agency','Changed from current state '+mapOldWorkAssignment.get(workAssignment.Id).Account_Being_CB_Reported_By_Agency__c+' to new state '+workAssignment.Account_Being_CB_Reported_By_Agency__c);
                           }
                    }
                    if(workAssignment.Status__c != NULL &&
                       mapOldWorkAssignment.get(workAssignment.Id).Status__c != NULL){
                           if(workAssignment.Status__c != mapOldWorkAssignment.get(workAssignment.Id).Status__c){
                               notificationCallAPI(workAssignment.Placement_Agency_Identifier__c,'Complaint','Complaint No: '+workAssignment.Name+' Status Changed ','Current status '+workAssignment.Status__c+' - previous status was '+mapOldWorkAssignment.get(workAssignment.Id).Status__c);
                           }
                    }
                    if(workAssignment.Task_Number__c != NULL){
                           if(workAssignment.Task_Number__c != NULL &&  mapOldWorkAssignment.get(workAssignment.Id).Task_Number__c == NULL){
                               notificationCallAPI(workAssignment.Placement_Agency_Identifier__c,'Complaint','Complaint No: '+workAssignment.Name+' Created ','Complaint type - '+workAssignment.Complaint_Type__c+' for - '+workAssignment.Root_Cause__c+' has status - '+workAssignment.Status__c);
                           }
                    }
                }  
            }
        }
        system.debug('after update:::');
        system.debug('listNewWorkAssignments:::' +listNewWorkAssignments);
        Work_Assignment__c newListWorkAss = listNewWorkAssignments.get(0);
        set<ID> setProductID = new set<ID>();
        set<ID> setCustomerID = new set<ID>();
       
        system.debug('newListWorkAss:::' +newListWorkAss);
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('CFG_Complaint'));
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('Agency_Complaint'));
        
        if((newListWorkAss.recordTypeID != null && newListWorkAss.recordTypeID == WorkAssRecTypeMap.get('CFG_Complaint'))
            || (newListWorkAss.recordTypeID != null && newListWorkAss.recordTypeID == WorkAssRecTypeMap.get('Agency_Complaint'))){
              
            for(Work_Assignment__c wrkAss : listNewWorkAssignments){
                setProductID.add(wrkAss.Product__c);
                setCustomerID.add(wrkAss.Customer__c);
                system.debug('wrkAss.Product__c::'+wrkAss.Product__c);
                system.debug('mapOldWorkAssignment.get(wrkAss.id).Product__c::'+mapOldWorkAssignment.get(wrkAss.id).Product__c);
                if(wrkAss.Product__c != mapOldWorkAssignment.get(wrkAss.id).Product__c){
                    setProductID.add(mapOldWorkAssignment.get(wrkAss.id).Product__c);
                }
            }
            system.debug('setProductID::' +setProductID);
 			AggregateResult[] custGroupedResults = [select Customer__c, Count(Customer__r.SF_ID__c)comptCustomercnt from Work_Assignment__c 
                                                WHERE Customer__c IN :setCustomerID 
                                                AND Customer__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request')
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                GROUP BY Customer__c];
      
            System.Debug('custGroupedResults' +custGroupedResults);
                if(custGroupedResults != NULL && !custGroupedResults.isEmpty()){
                    for (AggregateResult arr : custGroupedResults)  {
                        if((decimal)arr.get('comptCustomercnt') > 0){
                            Account cust=new Account();
                            cust.Id=(id)arr.get('Customer__c'); 
                            cust.Number_Of_Open_Complaint__c = 0;
                            cust.Number_Of_Open_Complaint__c= (decimal)arr.get('comptCustomercnt'); 
                            ProductTriggerHandler.runProductTrigger = false;
                            update cust;
                            ProductTriggerHandler.runProductTrigger = true;
                        }
                        
                    }
                } else{
                        for(Account Acc : [SELECT ID, Name FROM Account
                                           WHERE ID IN :setCustomerID ]){
                                               Account cus =new Account();
                                               cus.Id = Acc.Id;
                                               cus.Number_Of_Open_Complaint__c = 0;
                                               ProductTriggerHandler.runProductTrigger = false;
                                               update cus;
                                               ProductTriggerHandler.runProductTrigger = true;
                                           }
                    }
               
             set<ID> customerID =new set<ID>();    
            AggregateResult[] prodGroupedResults = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE Product__c IN :setProductID 
                                                AND Product__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request')
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                GROUP BY Product__c];
            System.Debug('prodGroupedResults' +prodGroupedResults);
            if(prodGroupedResults != NULL && !prodGroupedResults.isEmpty()) { 
                system.debug('inside if update');
                for (AggregateResult ar : prodGroupedResults)  {
                    if((decimal)ar.get('comptProductcnt') > 0){
                        Product__c prodCustomer = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)ar.get('Product__c')];
                        //Account acc = new Account();
                        customerID.add(prodCustomer.Customer__c);
                        Product__c pr1=new Product__c();
                        pr1.Id=(id)ar.get('Product__c'); 
                        pr1.Number_Of_Open_Complaint__c = 0;
                        pr1.Number_Of_Open_Complaint__c=(decimal)ar.get('comptProductcnt');
                         
                        ProductTriggerHandler.runProductTrigger = false;
                        update pr1;  
                        ProductTriggerHandler.runProductTrigger = True;
					}
                }
                set<Id> custProdId = new set<ID>();
                List<Product__C> cutProdList = [Select id,name from Product__c where customer__c IN: customerID];
                system.debug('cutProdList:'+cutProdList);
                for(Product__C custprod : cutProdList){
                    custProdId.add(custprod.Id);
                }
                AggregateResult[] prodGroupedResults1 = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE (Product__c IN :custProdId AND Product__c != NULL)
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint') GROUP BY Product__c];
                system.debug('prodGroupedResults1:'+prodGroupedResults1);
                Id cutomerId;
                Decimal prodcomplaintcount = 0;
                for(AggregateResult prdlist : prodGroupedResults1){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)prdlist.get('Product__c')];
                    cutomerId = prodCustomer1.Customer__c;
                    prodcomplaintcount = prodcomplaintcount + (Decimal)prdlist.get('comptProductcnt');
                }
                system.debug('prodcomplaintcount211::'+prodcomplaintcount);
                if(cutomerId != null){
                    Account acc = new Account();
                    acc.id = cutomerId;
                    acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                    CustomerTriggerHandler.runCustomerTrigger= false;
                    update acc;     
                    CustomerTriggerHandler.runCustomerTrigger= true;
                }
            }else{
                system.debug('inside setProductID::' +setProductID);
                Id custId;
                 for(Product__c product : [SELECT ID, Name,Customer__c
                                     FROM Product__c
                                     WHERE ID IN :setProductID ]){
                                         system.debug('inside else test product' +product);
                    customerID.add(product.Customer__c);
                    custId = product.Customer__c;                 
                    Product__c pr1=new Product__c();
                            pr1.Id=product.id; 
                            pr1.Number_Of_Open_Complaint__c=0; 
                            ProductTriggerHandler.runProductTrigger = false;
                            update pr1;  
                            ProductTriggerHandler.runProductTrigger = True;
                }
                system.debug('customerID:'+customerID);
                set<Id> custProdId = new set<ID>();
                List<Product__C> cutProdList = [Select id,name from Product__c where customer__c IN: customerID];
                
                system.debug('cutProdList:'+cutProdList);
                for(Product__C custprod : cutProdList){
                    custProdId.add(custprod.Id);
                }
                AggregateResult[] prodGroupedResults1 = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE (Product__c IN :custProdId AND Product__c != NULL)
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint') GROUP BY Product__c];
                system.debug('prodGroupedResults1:'+prodGroupedResults1);
                Id cutomerId;
                Decimal prodcomplaintcount = 0;
                for(AggregateResult prdlist : prodGroupedResults1){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)prdlist.get('Product__c')];
                    cutomerId = prodCustomer1.Customer__c;
                    prodcomplaintcount = prodcomplaintcount + (Decimal)prdlist.get('comptProductcnt');
                }
                system.debug('prodcomplaintcount211::'+prodcomplaintcount);
                if(cutomerId != null){
                    Account acc = new Account();
                    acc.id = cutomerId;
                    acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                    CustomerTriggerHandler.runCustomerTrigger= false;
                    update acc;     
                    CustomerTriggerHandler.runCustomerTrigger= true;
                }
                system.debug('custId::'+custId);
                if(prodGroupedResults1.isEmpty()) { 
                    if(custId != null){
                        system.debug('inside custId::'+custId);
                        Account acc = new Account();
                        acc.id = custId;
                        acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                        CustomerTriggerHandler.runCustomerTrigger= false;
                        update acc;     
                        CustomerTriggerHandler.runCustomerTrigger= true;
                    }
                }
            }
        }
    }
   
    //this inner method populate the comment, comment history and user name.
    public static void handleBeforeUpdate(List<Work_Assignment__c> wrkAssgns, Map<Id, Work_Assignment__c> oldMap) {
        list<Work_Assignment__c> listInternalNewWorkAssignment = new list<Work_Assignment__c>();
        list<Work_Assignment__c> listExternalNewWorkAssignment = new list<Work_Assignment__c>();
        Date dT = System.Today();
      /*  Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
        if (config.Run_WorkAssignment_API_for_Portal__c){
            for(Work_Assignment__c workAssignment: wrkAssgns){
               if (workAssignment.RecordTypeId == config.CFGWorkAssignmentRecordTypeId__c || workAssignment.RecordTypeId == config.Agency_Work_Assignment_RecordTypeID__c){
                    system.debug('workAssignment.RecordTypeId ' +workAssignment.RecordTypeId);
                    system.debug('config*******'+config);
                    PortalWorkAssignmentProcessingAPI.processWorkAssignment(workAssignment.ID, 'before update');
               }
                else if (workAssignment.RecordTypeId == config.ComplaintWorkAssignmentRecordID__c ||workAssignment.RecordTypeId == config.AgencyComplaintWorkAssignmentRecordType__c){
                    system.debug('workAssignment.RecordTypeId ' +workAssignment.RecordTypeId);
                    system.debug('config');
                    PortalComplaintProcessingAPI.processComplaint(workAssignment.ID, 'before update');
                    
                   
                }
            }
       
        }*/
        set<ID> setProductID = new set<ID>();
        
        for(Work_Assignment__c listwork : wrkAssgns ){
            setProductID.add(listwork.Product__c);
        }
        list<Product__c> prodList = [Select id ,Name, Originating_Creditor__c,Previous_Primary_Account_Number__c from Product__c where ID =:setProductID  ];
        
        For(Work_Assignment__c listWorkAssignment : wrkAssgns){
            For (Product__c prod :prodList ){
                try{
                    if (listWorkAssignment.Product__c != Null || listWorkAssignment.Original_Creditor__c == Null){
                        system.debug('Block run 1 '+prod.Originating_Creditor__c);
                        listWorkAssignment.Original_Creditor__c = prod.Originating_Creditor__c ; 
                    } 
                    if (listWorkAssignment.Product__c != Null && prod.Previous_Primary_Account_Number__c != Null){
                        listWorkAssignment.Primary_Account_Number__c = prod.Previous_Primary_Account_Number__c ; 
                    }
                }
                Catch(Exception e){
                    System.debug('Blockrun 2'+e);
                }
            }
        }
        
        for(Work_Assignment__c workAssig : wrkAssgns){
            
            if(workAssig.Start_Year__c !=Null  && workAssig.Start_Month__c !=Null && workAssig.End_Year__c!=Null && workAssig.End_Month__c!=Null ){
                String StartDate = workAssig.Start_Year__c +  workAssig.Start_Month__c ;
                System.debug('Block ***123***'  + StartDate );   
                
                String EndDate = workAssig.End_Year__c +  workAssig.End_Month__c  ;
                System.debug('Block ***$$$$***'  + EndDate );
                
                
                String TodaydT = String.valueOf(date.Today().Year())  + String.valueOf(date.Today().Month()) ;
                System.debug('Blockrun'+TodaydT);
                
                Integer StartDateInt = Integer.valueOf(StartDate);
                Integer EndDateInt = Integer.valueOf(EndDate);
                //Integer TodayInt = Integer.valueOf(TodaydT);
                system.debug('%%%%%%'+StartDateInt);
                system.debug('*******'+EndDateInt);
                
                if(workAssig.Statements__c == True && StartDateInt > EndDateInt ){
                    workAssig.Adderror('End Date should be greater than Start Date'); 
                }
            }
            
            Boolean identifierRemovalFlag = false;
            Work_Assignment__c wrkAssgnsOld = oldMap.get(workAssig.id);
            workAssig.Last_Modified_By__c = UserInfo.getName();
             
            System.debug('Block Run1'+workAssig);
            System.debug('workAssig.Status__c :'+workAssig.Status__c);
            System.debug('wrkAssgnsOld.Status__c :'+wrkAssgnsOld.Status__c);
            System.debug('workAssig.Status__c :'+workAssig);
            if(workAssig.Status__c != wrkAssgnsOld.Status__c && workAssig.Status__c == 'Completed – Agency Confirms Complaint Resolved'){
               workAssig.Resolution_Date__c = dT;
               workAssig.Resolution_By__c = UserInfo.getName();
            }
            system.debug('Block Run2 '+workAssig);
            
            /*if(workAssig.Statements__c == True && workAssig.Start_Month__c == null){
                workAssig.Start_Month__c.addError('If Statment is check than Start Month cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.Start_Year__c    == null){
                workAssig.Start_Year__c .addError('If Statment is check than Start Year cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.End_Month__c == null){
                workAssig.End_Month__c.addError('If Statment is check than End Month cannot be blank');
            }
            if(workAssig.Statements__c == True && workAssig.End_Year__c == null){
                workAssig.End_Year__c.addError('If Statment is check than End Year cannot be blank');
            }*/
            
            if(workAssig.Statements__c == False){
                workAssig.Start_Month__c = null ;
                workAssig.Start_Year__c = null ;
                workAssig.End_Month__c = null ;
                workAssig.End_Year__c = null ;
            }
            
            if(workAssig.Placement_Agency__c != wrkAssgnsOld.Placement_Agency__c
            && workAssig.Placement_Agency__c != NULL){
                listInternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Placement_Agency_Identifier__C == wrkAssgnsOld.Placement_Agency_Identifier__C && workAssig.Placement_Agency__c == null){
                workAssig.Placement_Agency_Identifier__C = null;
                identifierRemovalFlag = true;
            }
            else if(workAssig.Placement_Agency_Identifier__C != wrkAssgnsOld.Placement_Agency_Identifier__C
            && workAssig.Placement_Agency_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Placement_Agency__c == wrkAssgnsOld.Placement_Agency__c
            && workAssig.Placement_Agency_Identifier__c == NULL){
                workAssig.Placement_Agency__c = null;
            }
            
            system.debug('wrkAssgnsOld.Product__c :'+ wrkAssgnsOld.Product__c);
            system.debug('workAssig.Product__c :'+workAssig.Product__c);
            
            if(workAssig.Product__c != wrkAssgnsOld.Product__c
            && workAssig.Product__c != NULL){
                listInternalNewWorkAssignment.add(workAssig);
                system.debug('wrkAssgnsOld.Product__c :'+ wrkAssgnsOld.Product__c);
                system.debug('workAssig.Product__c :'+workAssig.Product__c);
            }
            else if(workAssig.Product_Identifier__c == wrkAssgnsOld.Product_Identifier__c && workAssig.Product__c == null){            
                workAssig.Product_Identifier__c = null;
            }
            else if(workAssig.Product_Identifier__c != wrkAssgnsOld.Product_Identifier__c
            && workAssig.Product_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Product__c == wrkAssgnsOld.Product__c
            && workAssig.Product_Identifier__c == NULL){
                workAssig.Product__c = null;
            }
            
            if(workAssig.Customer__c != wrkAssgnsOld.Customer__c
            && workAssig.Customer__c != NULL){
                listInternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Customer_Identifier__c == wrkAssgnsOld.Customer_Identifier__c && workAssig.Customer__c == null){            
                workAssig.Customer_Identifier__c = null;
            }
            else if(workAssig.Customer_Identifier__c != wrkAssgnsOld.Customer_Identifier__c
            && workAssig.Customer_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Customer__c == wrkAssgnsOld.Customer__c
            && workAssig.Customer_Identifier__c == NULL){
                workAssig.Customer__c = null;
            }
            
            if(workAssig.Settlement__c != wrkAssgnsOld.Settlement__c
            && workAssig.Settlement__c != NULL){
                listInternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Settlement_Identifier__c == wrkAssgnsOld.Settlement_Identifier__c && workAssig.Settlement__c == null){            
                workAssig.Settlement_Identifier__c = null;
            }
            else if(workAssig.Settlement_Identifier__c != wrkAssgnsOld.Settlement_Identifier__c
            && workAssig.Settlement_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Settlement__c == wrkAssgnsOld.Settlement__c
            && workAssig.Settlement_Identifier__c == NULL){
                workAssig.Settlement__c = null;
            }
            
            if(workAssig.Judgment__c != wrkAssgnsOld.Judgment__c
            && workAssig.Judgment__c != NULL){
                listInternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Judgment_Identifier__c == wrkAssgnsOld.Judgment_Identifier__c && workAssig.Judgment__c == null){            
                workAssig.Judgment_Identifier__c = null;
            }
            else if(workAssig.Judgment_Identifier__c != wrkAssgnsOld.Judgment_Identifier__c
            && workAssig.Judgment_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(workAssig.Judgment__c == wrkAssgnsOld.Judgment__c
            && workAssig.Judgment_Identifier__c == NULL){
                workAssig.Judgment__c = null;
            }
            
            /*if(workAssig.Placement_Agency_Identifier__c != wrkAssgnsOld.Placement_Agency_Identifier__c
            && workAssig.Placement_Agency_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            else if(identifierRemovalFlag == true){
                workAssig.Placement_Agency__c = null;
            }
            
            if(workAssig.Product_Identifier__c != wrkAssgnsOld.Product_Identifier__c
            && workAssig.Product_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            
            if(workAssig.Customer_Identifier__c != wrkAssgnsOld.Customer_Identifier__c
            && workAssig.Customer_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            
            if(workAssig.Settlement_Identifier__c != wrkAssgnsOld.Settlement_Identifier__c
            && workAssig.Settlement_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }
            
            if(workAssig.Judgment_Identifier__c != wrkAssgnsOld.Judgment_Identifier__c
            && workAssig.Judgment_Identifier__c != NULL){
                listExternalNewWorkAssignment.add(workAssig);
            }*/
           system.debug('ABC1');
            String commentReply = '';
            system.debug('commentReply::'+commentReply);
            if(workAssig.Comment_Reply__c != null && workAssig.Comment_Reply__c != wrkAssgnsOld.Comment_Reply__c){
               try{
                   commentReply = String.valueOf(workAssig.Comment_Reply__c).replace('\n', '').replace('\r', '');
                   workAssig.Comments_History__c = UserInfo.getName() + ' ' + 'added on' + ' ' + dT.month() + '/' + dT.day() + '/' + dT.year() + ';' + ' ' + ' ' + commentReply + '\n' + '\n';
                   workAssig.Latest_Comment__c = commentReply;
                   system.debug('ABC');
                   workAssig.Comment_Reply__c = '';
                    if(wrkAssgnsOld.Comments_History__c !=null){
                         workAssig.Comments_History__c += wrkAssgnsOld.Comments_History__c;
                    }
                   
                }catch(exception e){
               }
            }else{
                commentStatus = False;
            }

            
            if(workAssig.Accept_Assignment__c == true){
                workAssig.Assigned_To_User__c = UserInfo.getUserId();
                workAssig.Accept_Assignment__c = false;
                if((workAssig.recordTypeID != null && workAssig.recordTypeID == WorkAssRecTypeMap.get('CFG_Complaint'))
                   || (workAssig.recordTypeID != null && workAssig.recordTypeID == WorkAssRecTypeMap.get('Agency_Complaint'))){
                       //if(workAssig.RecordTypeId == CFG_Complaint || workAssig.RecordTypeId == Agency_Complaint){
                       workAssig.Status__c = 'In Progress - Pending CFG Action';
                   }
                else{
                   workAssig.Status__c = 'In Progress'; 
                }
                workAssig.Assigned_To_User_Name__c = UserInfo.getName();
            }
        }
        system.debug('listWorkAssignments before update::' +listInternalNewWorkAssignment);
        //method calls once record created/update in CFG
        getWorkAssignmentRelatedData(listInternalNewWorkAssignment);
    }
    
    public static void handleAfterDelete(List<Work_Assignment__c> oldWrkAssgns) {
        system.debug('after delete');
        Work_Assignment__c oldListWorkAss = oldWrkAssgns.get(0);
        set<ID> setProductID = new set<ID>();
        set<ID> setCustomerID = new set<ID>();
       
        system.debug('oldListWorkAss:::' +oldListWorkAss);
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('CFG_Complaint'));
        System.debug('WorkAssRecTypeMap.get '+WorkAssRecTypeMap.get('Agency_Complaint'));
        
        if((oldListWorkAss.recordTypeID != null && oldListWorkAss.recordTypeID == WorkAssRecTypeMap.get('CFG_Complaint'))
            || (oldListWorkAss.recordTypeID != null && oldListWorkAss.recordTypeID == WorkAssRecTypeMap.get('Agency_Complaint'))){
              
            for(Work_Assignment__c wrkAss : oldWrkAssgns){
                setProductID.add(wrkAss.Product__c);
                setCustomerID.add(wrkAss.Customer__c);
            }
            System.Debug('setProductID' +setProductID);
            AggregateResult[] custGroupedResults = [select Customer__c, Count(Customer__r.SF_ID__c)comptCustomercnt from Work_Assignment__c 
                                                WHERE Customer__c IN :setCustomerID 
                                                AND Customer__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request')
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')
                                                GROUP BY Customer__c];
      
            System.Debug('custGroupedResults' +custGroupedResults);
                if(custGroupedResults != NULL && !custGroupedResults.isEmpty()){
                    for (AggregateResult arr : custGroupedResults)  {
                        if((decimal)arr.get('comptCustomercnt') > 0){
                            Account cust=new Account();
                            cust.Id=(id)arr.get('Customer__c'); 
                            cust.Number_Of_Open_Complaint__c = 0;
                            cust.Number_Of_Open_Complaint__c= (decimal)arr.get('comptCustomercnt'); 
                            ProductTriggerHandler.runProductTrigger = false;
                            update cust;
                            ProductTriggerHandler.runProductTrigger = true;
                        }
                        
                    }
                } else{
                        for(Account Acc : [SELECT ID, Name FROM Account
                                           WHERE ID IN :setCustomerID ]){
                                               Account cus =new Account();
                                               cus.Id = Acc.Id;
                                               cus.Number_Of_Open_Complaint__c = 0;
                                               ProductTriggerHandler.runProductTrigger = false;
                                               update cus;
                                               ProductTriggerHandler.runProductTrigger = true;
                                           }
                    }
               
             set<ID> customerID =new set<ID>();   
            AggregateResult[] prodGroupedResults = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE Product__c IN :setProductID 
                                                AND Product__c != NULL
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request')
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint')  
                                                GROUP BY Product__c];
            System.Debug('prodGroupedResults' +prodGroupedResults);
            if(prodGroupedResults != NULL && !prodGroupedResults.isEmpty()) { 
                system.debug('inside if update');
                for (AggregateResult ar : prodGroupedResults)  {
                    if((decimal)ar.get('comptProductcnt') > 0){
                        Product__c prodCustomer = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)ar.get('Product__c')];
                        customerID.add(prodCustomer.Customer__c);
                        Product__c pr1=new Product__c();
                        pr1.Id=(id)ar.get('Product__c'); 
                        pr1.Number_Of_Open_Complaint__c = 0;
                        pr1.Number_Of_Open_Complaint__c=(decimal)ar.get('comptProductcnt');
                        ProductTriggerHandler.runProductTrigger = false;
                        update pr1; 
                        ProductTriggerHandler.runProductTrigger = True;
                    }
                }
                 set<Id> custProdId = new set<ID>();
                List<Product__C> cutProdList = [Select id,name from Product__c where customer__c IN: customerID];
                system.debug('cutProdList:'+cutProdList);
                for(Product__C custprod : cutProdList){
                    custProdId.add(custprod.Id);
                }
                AggregateResult[] prodGroupedResults1 = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE (Product__c IN :custProdId AND Product__c != NULL)
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint') GROUP BY Product__c];
                system.debug('prodGroupedResults1:'+prodGroupedResults1);
                Id cutomerId;
                Decimal prodcomplaintcount = 0;
                for(AggregateResult prdlist : prodGroupedResults1){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)prdlist.get('Product__c')];
                    cutomerId = prodCustomer1.Customer__c;
                    prodcomplaintcount = prodcomplaintcount + (Decimal)prdlist.get('comptProductcnt');
                }
                system.debug('prodcomplaintcount211::'+prodcomplaintcount);
                if(cutomerId != null){
                    Account acc = new Account();
                    acc.id = cutomerId;
                    acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                    CustomerTriggerHandler.runCustomerTrigger= false;
                    update acc;     
                    CustomerTriggerHandler.runCustomerTrigger= true;
                }
            }else{
                Id custId;
                system.debug('inside setProductID::' +setProductID);
                 for(Product__c product : [SELECT ID, Name,Customer__c
                                     FROM Product__c
                                     WHERE ID IN :setProductID ]){
                                         system.debug('inside else test product' +product);
                    customerID.add(product.Customer__c);  
                    custId = product.Customer__c;                 
                    Product__c pr1=new Product__c();
                            pr1.Id=product.id; 
                            pr1.Number_Of_Open_Complaint__c=0; 
                            ProductTriggerHandler.runProductTrigger = false;
                            update pr1; 
                            ProductTriggerHandler.runProductTrigger = True;
                }
                set<Id> custProdId = new set<ID>();
                List<Product__C> cutProdList = [Select id,name from Product__c where customer__c IN: customerID];
                system.debug('cutProdList:'+cutProdList);
                for(Product__C custprod : cutProdList){
                    custProdId.add(custprod.Id);
                }
                AggregateResult[] prodGroupedResults1 = [select Product__c, Count(Product__r.Name)comptProductcnt from Work_Assignment__c 
                                                WHERE (Product__c IN :custProdId AND Product__c != NULL)
                                                AND (Status__c != 'Closed - Justified' AND Status__c != 'Closed - Unjustified'
                                                AND Status__c != 'Closed - Unjustified - Cease and Desist Request') 
                                                AND (Recordtype.DeveloperName = 'CFG_Complaint' OR RecordType.DeveloperName = 'Agency_Complaint') GROUP BY Product__c];
                system.debug('prodGroupedResults1:'+prodGroupedResults1);
                Id cutomerId;
                Decimal prodcomplaintcount = 0;
                for(AggregateResult prdlist : prodGroupedResults1){
                    Product__c prodCustomer1 = [Select id,name,Customer__c,Customer__r.Number_Of_Open_Complaint__c from product__c where id =: (id)prdlist.get('Product__c')];
                    cutomerId = prodCustomer1.Customer__c;
                    prodcomplaintcount = prodcomplaintcount + (Decimal)prdlist.get('comptProductcnt');
                }
                system.debug('prodcomplaintcount211::'+prodcomplaintcount);
                if(cutomerId != null){
                    Account acc = new Account();
                    acc.id = cutomerId;
                    acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                    CustomerTriggerHandler.runCustomerTrigger= false;
                    update acc;     
                    CustomerTriggerHandler.runCustomerTrigger= true;
                }
                system.debug('custId::'+custId);
                if(prodGroupedResults1.isEmpty()) { 
                    if(custId != null){
                        system.debug('inside custId::'+custId);
                        Account acc = new Account();
                        acc.id = custId;
                        acc.Number_Of_Open_Product_Complaint__c  = prodcomplaintcount;
                        CustomerTriggerHandler.runCustomerTrigger= false;
                        update acc;     
                        CustomerTriggerHandler.runCustomerTrigger= true;
                    }
                }
            }
        }
    }
    
    //using this inner method populate the identifier fields using CFG data.
     public static void getWorkAssignmentRelatedData(list<Work_Assignment__c> listWorkAssignments){
         system.debug('listWorkAssignments first testing::' +listWorkAssignments);
        set<Id> setPlacementID = new set<Id>();
        set<Id> setProductID = new set<Id>();
        set<Id> setCustomerID = new set<Id>();
        set<Id> setSettlementID = new set<Id>();
        set<Id> setJudgmentID = new set<Id>();
        
        map<Id, String> mapPlacementNames = new map<Id, String>();
        map<Id, String> mapProductNames = new map<Id, String>();
        map<Id, String> mapCustomerNames = new map<Id, String>();
        map<Id, String> mapSettlementNames = new map<Id, String>();
        map<Id, String> mapJudgmentNames = new map<Id, String>();
        map<Id, String> mapRecordTypeNameIDs = new map<Id, String>();
       
       for(RecordType workAssigRecordType : [SELECT Id,DeveloperName FROM RecordType
                                              WHERE sObjectType = 'Work_Assignment__c']){
            mapRecordTypeNameIDs.put(workAssigRecordType.ID, workAssigRecordType.DeveloperName);
        }
        system.debug('mapRecordTypeNameIDs testing::' +mapRecordTypeNameIDs);
         
        for(Work_Assignment__c workAssignObj : listWorkAssignments){
            setPlacementID.add(workAssignObj.Placement_Agency__c);
            setProductID.add(workAssignObj.Product__c);
            setCustomerID.add(workAssignObj.Customer__c);
            setSettlementID.add(workAssignObj.Settlement__c);
            setJudgmentID.add(workAssignObj.Judgment__c);
        }
        
        for(Placement__c placement : [SELECT ID, Name
                                     FROM Placement__c
                                     WHERE ID IN : setPlacementID]){
            mapPlacementNames.put(placement.Id, placement.Name);
        }
        for(Product__c product : [SELECT ID, Name
                                     FROM Product__c
                                     WHERE ID IN :setProductID]){
            mapProductNames.put(product.ID, product.Name);
        }
      
        for(Account Customer : [SELECT ID, Name, SF_ID__c
                                     FROM Account
                                     WHERE ID IN :setCustomerID]){
            mapCustomerNames.put(Customer.ID, Customer.SF_ID__c);
        }
        for(Settlement__c Settlement : [SELECT ID, Settlement_Number__c
                                     FROM Settlement__c
                                     WHERE ID IN :setSettlementID]){
            mapSettlementNames.put(Settlement.ID, Settlement.Settlement_Number__c);
        }
        for(Judgment__c Judgment : [SELECT ID, Judgment_Number__c
                                     FROM Judgment__c
                                     WHERE ID IN :setJudgmentID]){
            mapJudgmentNames.put(Judgment.ID, Judgment.Judgment_Number__c);
        }
         system.debug('listWorkAssignments testing::' +listWorkAssignments);
        for(Work_Assignment__c workAssignObj : listWorkAssignments){
            system.debug('inside testing::');
            workAssignObj.Placement_Agency_Identifier__c = mapPlacementNames.get(workAssignObj.Placement_Agency__c);
            workAssignObj.Product_Identifier__c = mapProductNames.get(workAssignObj.Product__c);
            workAssignObj.Customer_Identifier__c = mapCustomerNames.get(workAssignObj.Customer__c);
            workAssignObj.Settlement_Identifier__c = mapSettlementNames.get(workAssignObj.Settlement__c);
            workAssignObj.Judgment_Identifier__c = mapJudgmentNames.get(workAssignObj.Judgment__c);
            workAssignObj.Record_Type_Identifier__c = mapRecordTypeNameIDs.get(workAssignObj.RecordTypeId);
            system.debug('workAssignObj.Record_Type_Identifier__c testing::' +workAssignObj.Record_Type_Identifier__c);
        }
        system.debug('outside testing::');
        
    }
}