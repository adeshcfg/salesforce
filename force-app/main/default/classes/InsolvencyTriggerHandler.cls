/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a trigger handler class for Insolvency object 
 *  @author : A5E Consulting
 *  @date : 09/26/2016
 
 *************************************************************************************************/
 
 public class InsolvencyTriggerHandler {
    
    public static boolean runInsolvencyTrigger = true; 
    public static boolean stopDuplicatePaymentInsert = True;
    public static Trustee_Fees__c trusteeFees = Trustee_Fees__c.getOrgDefaults();
    
    //Before Insert
    public static void handleBeforeInsert(List<Insolvency__c> insolsNew) {
        
        DateTime dtNow = System.now();
        ID userId = UserInfo.getUserId();
            
        for (Insolvency__c insol : insolsNew){   
            
           
            //This change is made for Insolvency Dicison Engine to calculate debtor age
            if(insol.Debtor_1_Date_of_Birth__c != null){
            
                 date dateOfBirth = insol.Debtor_1_Date_of_Birth__c;
                 insol.Date_Of_Birth_Year__c = dateOfBirth.year();
            
            }
            
            //Format Debtor 1 Estate Number         
            insol.Name = formatEstateNumber(insol.Name);
            
            //Error if formatted number is blank
            /*
            if(String.isBlank(insol.Name)){
                insol.Name.addError('Estate Number is not valid', false);
            }
            */
            
            //Assign Province from 2 charachter Province Code
            if(null <> insol.Debtor_1_Mailing_State_Province__c){
                insol.Debtor_1_Mailing_State_Province__c = (InsolvencyTriggerHandler.provinceMap()).get(insol.Debtor_1_Mailing_State_Province__c);
            }
            if(null <> insol.Debtor_2_Mailing_State_Province__c){
                insol.Debtor_2_Mailing_State_Province__c = (InsolvencyTriggerHandler.provinceMap()).get(insol.Debtor_2_Mailing_State_Province__c);
            }
            
            //Format Debtor 2 Estate Number
            if(String.isNotBlank(insol.Debtor_2_Estate_Number__c)){
                insol.Debtor_2_Estate_Number__c = formatEstateNumber(insol.Debtor_2_Estate_Number__c);
            }
            
            // Insolvency Status Update
            //Set Insolvency_Status_Last_Changed to now
            if(String.isNotBlank(insol.Insolvency_Status__c)){
                insol.Insolvency_Status_Last_Changed__c = dtNow;
                
                //Insolvency Status dates for SLA tracking
                if(insol.Insolvency_Status__c == 'For Owner Review'){
                    insol.Sent_For_Owner_Review_Date__c = dtNow;
                    insol.Sent_For_Owner_Review_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Active'){
                    insol.Set_to_Active_Date__c = dtNow;
                    insol.Set_to_Active_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Annulled'){
                    insol.Set_to_Annulled_Date__c = dtNow;
                    insol.Set_to_Annulled_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Refused'){
                    insol.Set_to_Refused_Date__c = dtNow;
                    insol.Set_to_Refused_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Withdrawn'){
                    insol.Set_to_Withdrawn_Date__c = dtNow;
                    insol.Set_to_Withdrawn_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Discharged'){
                    insol.Set_to_Discharged_Date__c = dtNow;
                    insol.Set_to_Discharged_By__c = userId ;
                }  
            } 
            
            /*if(String.isNotBlank(insol.Expected_Discharge_Month__c) && null != insol.Insolvency_Date__c){
                //insol.Insolvency_Expected_Discharged_Date__c = insol.Insolvency_Created_Date__c.addMonths(integer.valueOf(insol.Expected_Discharge_Month__c));
                insol.Insolvency_Expected_Discharged_Date__c = insol.Insolvency_Date__c.addMonths(integer.valueOf(insol.Expected_Discharge_Month__c));
                system.debug('Insolvency_Expected_Discharged_Date__c=='+insol.Insolvency_Expected_Discharged_Date__c);
            }*/
            
             //Logic changed as per the new requirement by Phil 06-08-2020
            if(insol.Number_of_Payments__c != null && null != insol.Payment_Start_Date__c){
                insol.Insolvency_Expected_Discharged_Date__c = insol.Payment_Start_Date__c.addMonths(integer.valueOf(insol.Number_of_Payments__c));
                system.debug('Insolvency_Expected_Discharged_Date__c=='+insol.Insolvency_Expected_Discharged_Date__c);
            }
            else{
                insol.Insolvency_Expected_Discharged_Date__c = null;
            }
            
            if(insol.Insolvency_Status__c == 'Annulled' || insol.Insolvency_Status__c =='Withdrawn'
               || insol.Insolvency_Status__c == 'Refused'){
                   insol.addError('Insolvency cannot be created with status Annulled/Withdrawn/Refused');
               }  
            
            if(insol.Revival_Date__c <> null|| insol.Insolvency_Annulled_Date__c <> null  ||
               insol.Insolvency_Withdrawn_Date__c <> null || insol.Insolvency_Refused_Date__c <> null){
                   insol.addError('Insolvency cannot be created if Revival/Annulled/Refused/Withdrawn date is present');
               }
               
            //Previous Payment information
            if(insol.Insolvency_type__c == 'Consumer Proposal' || insol.Insolvency_type__c == 'Division 1 Proposal'){
                   
                system.debug('Inside if');
                Decimal bulkPaymentAmount = insol.Previous_Bulk_Payment_Amount__c == null ? insol.Bulk_Payment_Amount__c : insol.Previous_Bulk_Payment_Amount__c;
                Decimal paymentAmount = insol.Previous_Payment_Amount__c == null ? insol.Payment_Amount__c : insol.Previous_Payment_Amount__c;
                Decimal noOfPayments = insol.Previous_Number_of_Payments__c == null ? insol.Number_of_Payments__c : insol.Previous_Number_of_Payments__c;
                
                system.debug(bulkPaymentAmount );
                system.debug(paymentAmount );
                system.debug(noOfPayments );
                
                if(null == bulkPaymentAmount){
                    bulkPaymentAmount = 0;
                }
                if(null == paymentAmount){
                    paymentAmount = 0;
                }
                if(null == noOfPayments){
                    noOfPayments = 0;
                }
                
                insol.Previous_Trustee_Variable_Fees__c = (((paymentAmount  * noOfPayments) + bulkPaymentAmount ) - 
                                                            trusteeFees.Trustee_Administration_Fee__c - 
                                                            trusteeFees.Counselling_Fee__c - 
                                                            trusteeFees.Receiver_Fee__c ) * 
                                                            (trusteeFees.Trustee_Variable_Fee_Rate__c * 0.01);
                insol.Previous_Trustee_Fees__c = trusteeFees.Trustee_Administration_Fee__c + trusteeFees.Counselling_Fee__c + 
                                                trusteeFees.Receiver_Fee__c + insol.Previous_Trustee_Variable_Fees__c + 
                                                (( insol.Previous_Trustee_Variable_Fees__c + 
                                                trusteeFees.Trustee_Administration_Fee__c + 
                                                trusteeFees.Counselling_Fee__c) * 
                                                (trusteeFees.HST_Tax_Rate__c * 0.01) );
                
            }
        }   
    }
    
    //Before Update
    public static void handleBeforeUpdate(List<Insolvency__c> insolsNew, Map<Id, Insolvency__c> oldMap) {
        
        DateTime dtNow = System.now();
        ID userId = UserInfo.getUserId();
        List<ID> InsolvencyIDs = new List<ID>();
        
        for(Insolvency__C insol : insolsNew){
            InsolvencyIDs.add(insol.id);
            
            
        }
        
        //Fetch all related history records for Insolvency Status
        Map<id, Insolvency__History> mapInsolHistory = new map<id, Insolvency__History>();
        if(!Test.isRunningTest()){
        List<Insolvency__History> insolvencyHistoryList = [select id, createdDate, OldValue, NewValue, Field, ParentID 
                                                           from Insolvency__History where 
                                                           ParentID in :InsolvencyIDs and Field = 'Insolvency_Status__c' 
                                                           order by createdDate desc];
            
        
        //put all latest records for each insolvency into map
        for(Insolvency__History insolHist : insolvencyHistoryList){
            String oldValueStr = '' + insolHist.oldValue;
            if(null == mapInsolHistory.get(insolHist.ParentID) && (oldValueStr <> 'Refused' || oldValueStr <> 'Annulled' ||
                                                                   oldValueStr <> 'Withdrawn')){
                                                                       mapInsolHistory.put(insolHist.parentId, insolHist);
                                                                   }
        }
        }
        for (Insolvency__c insol : insolsNew){ 
            
            //Old Insolvency values
            Insolvency__c insolOld = oldMap.get(insol.id);
            
            
            
            //This change is made for Insolvency Dicison Engine to calculate debtor age
            if(insol.Debtor_1_Date_of_Birth__c != insolOld.Debtor_1_Date_of_Birth__c && insol.Debtor_1_Date_of_Birth__c != null){
            
                 date dateOfBirth = insol.Debtor_1_Date_of_Birth__c;
                 insol.Date_Of_Birth_Year__c = dateOfBirth.year();
            
            }
            
           
            //if(insol.Updated_by_Jittebit__c == 'Data Load'){
            //    break;
            //}
            //Format Debtor 1 Estate Number
            if(String.isNotBlank(insol.Name)){
                if(insol.name != insolOld.Name){
                    insol.Name = formatEstateNumber(insol.Name);
                }
            }
            
            //Format Debtor 2 Estate Number
            if(String.isNotBlank(insol.Debtor_2_Estate_Number__c)){
                if(insol.Debtor_2_Estate_Number__c != insolOld.Debtor_2_Estate_Number__c){
                    insol.Debtor_2_Estate_Number__c = formatEstateNumber(insol.Debtor_2_Estate_Number__c);
                }
            }
            //‘Voting-Trustee-Follow-up-Date’ is changed then set ‘Voting-Trustee-Follow-up-Date-Updated-By’ =current user.
           if(insol.Voting_Trustee_Follow_up_Date__c  != insolOld.Voting_Trustee_Follow_up_Date__c){
             insol.Voting_Trustee_Follow_up_Date_Updated_By__c = UserInfo.getuserId();  
            }
            
            if(!(insolOld.Insolvency_Status__c == 'Annulled' || insolOld.Insolvency_Status__c == 'Withdrawn' || insolOld.Insolvency_Status__c == 'Refused') && 
               (insol.Revival_Date__c <> insolOld.Revival_Date__c)){
                   System.debug('status---'+insol.Insolvency_Status__c);
                   System.debug('Status---'+insol.Revival_Date__c);
                   insol.addError('Revival date should be set/changed only when status is Annulled/Withdrawn/Refused');
               }
            
            //Set Old Status value
            if((insol.Insolvency_Status__c == 'Annulled' || insol.Insolvency_Status__c == 'Withdrawn' || insol.Insolvency_Status__c == 'Refused') && (insol.Revival_Date__c <> insolOld.Revival_Date__c)){
                if(mapInsolHistory.get(insol.id) != null){
                    insol.Insolvency_Status__c = ''+(mapInsolHistory.get(insol.id)).OldValue;
                    insol.Insolvency_Annulled_Date__c = null;
                    insol.Insolvency_Refused_Date__c = null;
                    insol.Insolvency_Withdrawn_Date__c = null;
                }
            }     
            
            // Insolvency Status Update
            //Update Insolvency_Status_Last_Changed to now if Insolvency_Status is changed
            if(insol.Insolvency_Status__c != insolOld.Insolvency_Status__c){
                insol.Insolvency_Status_Last_Changed__c = dtNow;
                
                //Insolvency Status dates for SLA tracking
                if(insol.Insolvency_Status__c == 'For Owner Review'){
                    if(insol.Sent_For_Owner_Review_Date__c == null){
                        insol.Sent_For_Owner_Review_Date__c = dtNow;
                        insol.Sent_For_Owner_Review_By__c = userId ;

                    }
                }
                else if(insol.Insolvency_Status__c == 'Active'){
                    insol.Set_to_Active_Date__c = dtNow;
                    insol.Set_to_Active_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Annulled'){
                    insol.Set_to_Annulled_Date__c = dtNow;
                    insol.Set_to_Annulled_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Refused'){
                    insol.Set_to_Refused_Date__c = dtNow;
                    insol.Set_to_Refused_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Withdrawn'){
                    insol.Set_to_Withdrawn_Date__c = dtNow;
                    insol.Set_to_Withdrawn_By__c = userId ;
                }
                else if(insol.Insolvency_Status__c == 'Discharged'){
                    insol.Set_to_Discharged_Date__c = dtNow;
                    insol.Set_to_Discharged_By__c = userId ;
                } 
            } 
            
            /*if(String.isNotBlank(insol.Expected_Discharge_Month__c)){
                if(insol.Expected_Discharge_Month__c != insolOld.Expected_Discharge_Month__c || insol.Insolvency_Date__c != insolOld.Insolvency_Date__c){
                    insol.Insolvency_Expected_Discharged_Date__c = insol.Insolvency_Date__c.addMonths(integer.valueOf(insol.Expected_Discharge_Month__c));
                }
            }*/
            
            //Logic changed as per the new requirement by Phil 06-08-2020
            if(insol.Number_of_Payments__c != null && null != insol.Payment_Start_Date__c){
                if(insol.Number_of_Payments__c != insolOld.Number_of_Payments__c || insol.Payment_Start_Date__c != insolOld.Payment_Start_Date__c){
                    insol.Insolvency_Expected_Discharged_Date__c = insol.Payment_Start_Date__c.addMonths(integer.valueOf(insol.Number_of_Payments__c));
                }
            }
            else{
                insol.Insolvency_Expected_Discharged_Date__c = null;
            }
            
            Boolean changedValue = false;
            /****** Deactivate the Prior Values for Voting reporting Starts**************/
            //Populate the previous values for first Payment amount
            if(null == insol.Previous_Payment_Amount__c && insol.Payment_Amount__c != insolOld.Payment_Amount__c){
                insol.Previous_Payment_Amount__c = insolOld.Payment_Amount__c;
                changedValue = true;
            }
            
            //Populate the previous values for Voting Decision
            if(insol.Voting_Decision__c != NULL && insol.Voting_Decision__c != insolOld.Voting_Decision__c){
                insol.Previous_Voting_Decision__c = insolOld.Voting_Decision__c;
            }
            /****** Deactivate the Prior Values for Voting reporting Ends**************/
            
            //Populate the previous values for first no of payments
            if(null == insol.Previous_Number_of_Payments__c && insol.Number_of_Payments__c != insolOld.Number_of_Payments__c){
                insol.Previous_Number_of_Payments__c = insolOld.Number_of_Payments__c;
                changedValue = true;
            }
            
            //Populate the previous values for first bulk payment amount
            if(null == insol.Previous_Bulk_Payment_Amount__c && insol.Bulk_Payment_Amount__c != insolOld.Bulk_Payment_Amount__c){
                insol.Previous_Bulk_Payment_Amount__c = insolOld.Bulk_Payment_Amount__c;
                changedValue = true;
            }
            
            if(insol.Previous_Payment_Amount__c != insolOld.Previous_Payment_Amount__c ||
               insol.Previous_Number_of_Payments__c != insolOld.Previous_Number_of_Payments__c ||
               insol.Previous_Bulk_Payment_Amount__c != insolOld.Previous_Bulk_Payment_Amount__c ){
                changedValue = true;
            }
            
            if(insol.Insolvency_type__c != insolOld.Insolvency_type__c){
                changedValue = true;
            }
            
            //Previous Payment information
            if(insol.Insolvency_type__c == 'Consumer Proposal' || insol.Insolvency_type__c == 'Division 1 Proposal'){
                if(changedValue == true){
                   
                   system.debug('Inside if');
                   Decimal bulkPaymentAmount = insol.Previous_Bulk_Payment_Amount__c == null ? insol.Bulk_Payment_Amount__c : insol.Previous_Bulk_Payment_Amount__c;
                   Decimal paymentAmount = insol.Previous_Payment_Amount__c == null ? insol.Payment_Amount__c : insol.Previous_Payment_Amount__c;
                   Decimal noOfPayments = insol.Previous_Number_of_Payments__c == null ? insol.Number_of_Payments__c : insol.Previous_Number_of_Payments__c;
                   
                   system.debug(bulkPaymentAmount );
                   system.debug(paymentAmount );
                   system.debug(noOfPayments );
                   
                   if(null == bulkPaymentAmount){
                       bulkPaymentAmount = 0;
                   }
                   if(null == paymentAmount){
                       paymentAmount = 0;
                   }
                   if(null == noOfPayments){
                       noOfPayments = 0;
                   }
                   
                  insol.Previous_Trustee_Variable_Fees__c = (((paymentAmount  * noOfPayments) + bulkPaymentAmount ) - 
                                                               trusteeFees.Trustee_Administration_Fee__c - 
                                                               trusteeFees.Counselling_Fee__c - 
                                                               trusteeFees.Receiver_Fee__c ) * 
                                                               (trusteeFees.Trustee_Variable_Fee_Rate__c * 0.01);
                   insol.Previous_Trustee_Fees__c = trusteeFees.Trustee_Administration_Fee__c + trusteeFees.Counselling_Fee__c + 
                                                   trusteeFees.Receiver_Fee__c + insol.Previous_Trustee_Variable_Fees__c + 
                                                   (( insol.Previous_Trustee_Variable_Fees__c + 
                                                   trusteeFees.Trustee_Administration_Fee__c + 
                                                   trusteeFees.Counselling_Fee__c) * 
                                                   (trusteeFees.HST_Tax_Rate__c * 0.01) );
                   
                }
            }
        }           
        
        checkForCreditorPackage( insolsNew, oldMap); 
    }
    
    //Utility method to format estate number
    public static String formatEstateNumber(String estateNumber){
        
        String formattedEstateNumber = '';
        
        //Split at ;
        String[] splitEstateNumbers = estateNumber.split(';');
        for(String splitEstateNumber : splitEstateNumbers){
            
            //Add dash between 2nd and 3rd number
            if(String.isNotBlank(splitEstateNumber)){
                formattedEstateNumber+= addDash(splitEstateNumber) + ';';
            }           
        }
        
        //Remove unwanted ;
        if(formattedEstateNumber.startsWith(';')){
            formattedEstateNumber = formattedEstateNumber.removeStart(';');
        } 
        if(formattedEstateNumber.endsWith(';')){
            formattedEstateNumber = formattedEstateNumber.removeEnd(';');
        }  
        
        return formattedEstateNumber;       
    }
    
    //Utility method to add dash between 2nd and 3rd number
    public static String addDash(String str){
        if(String.isNotBlank(str)){
            if(!str.contains('-')){
                if(str.length() > 2){
                    str = str.substring(0, 2) + '-' + str.substring(2, str.length());
                    System.debug('String with Dash :'+str);
                }
            }
        }
        
        return str;
    }
    
    //Handle After Insert
    public static void handleAfterInsert(List<Insolvency__c> insolsNew) {
        ArchiveUnarchiveUtility.assignExternalCorID(insolsNew);
        for(Insolvency__c insolRec : insolsNew){
            //Doc Parser code
            if(insolRec.Document_ID__c <> null){
                InsolvencyAccountCreationFuture.SendPDFtoParser(insolRec.Remote_ID__c);
                //InsolvencyAccountCreationFuture.SendPDFtoParser(insolRec.Document_ID__c); 
            }
        }
    }
    
    //Handle After Update
    public static void handleAfterUpdate(Map<Id, Insolvency__c> insolvNewMap, Map<Id, Insolvency__c> insolvOldMap) {
        
        DateTime dtNow = System.now();
        ID userId = UserInfo.getUserId();
        
        //Insolvency in For Owner Review status
        List<Id> insolvIdsForOwnerReview = new List<Id>();
        
        //Insolvency in Annulled status
        List<Id> insolvIdsAnnulled = new List<Id>();
        
        //Insolvency in Refused status
        List<Id> insolvIdsRefused = new List<Id>();
        
        //Insolvency in Withdrawn status
        List<Id> insolvIdsWithdrawn = new List<Id>();
        
        //Insolvency in Revival status
        List<Id> insolvIdsForRevival = new List<Id>();
        
        //Insolvency in Discharged status
        List<Id> insolvIdsDischarged = new List<Id>(); 
        
        //Insolvency eligible for Voting Automatio
        List<Id> votingAutomationList = new List<Id>();
        
        //Insolvency in Annulled - Filed New status
        List<Id> insolvIdsAnnulledFiledNew = new List<Id>();
        
        //Insolvency in Refused- Filed New status
        List<Id> insolvIdsRefusedFiledNew = new List<Id>(); 



        //Insolvency in Withdrawn- Filed New
        List<Id> insolvIdsWithdrawnFiledNew = new List<Id>(); 
        
        //Copy from Insolvency
        Map<String, String> cpyInsFieldsMap = InsolvencyUtil.getInsolvencyFieldSet('CopyInsolvencyFields');   
        Set<String> cpyInsFields = cpyInsFieldsMap.keySet(); 
        List<Id> insolvIdsCopy = new List<Id>();
        //set<ID> ProdId = new set<ID>();
        //map<Id, Product__c> mapProdList = new map<Id, Product__c>();
        //list<Product__c> listProductToUpdate = new list<product__c>();
        
        //Store associate product ID
         /*for(Id insolvId1 : insolvNewMap.keySet()){
            
            Insolvency__c newIns1 =  insolvNewMap.get(insolvId1);
            Insolvency__c oldIns1 =  insolvOldMap.get(insolvId1);
             ProdId.add(newIns1.Product__c);
            
         }*/
        //Fetch associate product data
        /*if(ProdId != null){
               List<Product__c> prodData = [select id, name,Interest_Rate__c,Previous_Interest_Rate__c,Insolvency_Date__c,
                                  Current_Principal_Balance__c,Current_Interest_Amount__c,Interest_Amount_Last_Calculated_Date__c
                                  from Product__C where id =: ProdId];
            for(Product__c prod : prodData){
                mapProdList.put(prod.Id, prod);
            }
        }*/
        List<Id> insolvIdsToUpdateAccounts = new List<Id>();
        List<String> insolvencyIds = new List<String>();
        List<String> votingDecisionChangeinsolIds = new List<String>();
        for(Id insolvId : insolvNewMap.keySet()){
            
            Insolvency__c newIns =  insolvNewMap.get(insolvId);
            Insolvency__c oldIns =  insolvOldMap.get(insolvId);
            
            insolvencyIds.add(insolvId);
            if(newIns.Voting_Decision__c != oldIns.Voting_Decision__c){
                votingDecisionChangeinsolIds.add(newIns.id);
            }
            
            // Add Insolvency whose any of the below field is updated
            if (
                newIns.Total_Unsecured_Liabilities_Clc__c != oldIns.Total_Unsecured_Liabilities_Clc__c ||
                newIns.Insolvency_Type__c != oldIns.Insolvency_Type__c ||
                newIns.Expected_Discharge_Month__c != oldIns.Expected_Discharge_Month__c ||
                newIns.Payment_Amount__c != oldIns.Payment_Amount__c ||
                newIns.Number_of_Payments__c != oldIns.Number_of_Payments__c ||
                newIns.Bulk_Payment_Amount__c != oldIns.Bulk_Payment_Amount__c ||
                newIns.Trustee_Fees__c != oldIns.Trustee_Fees__c ||
                newIns.Previous_Offer_Amount__c != oldIns.Previous_Offer_Amount__c ||
                newIns.Previous_Trustee_Fees__c != oldIns.Previous_Trustee_Fees__c
            ) {
                insolvIdsToUpdateAccounts.add(insolvId);
            }

            // Replace Insolvency Status from 'New' to 'For Owner Review'
            if(newIns.Insolvency_Status__c == 'For Owner Review' && oldIns.Insolvency_Status__c == 'Staging'){
                insolvIdsForOwnerReview.add(insolvId);
            }
            
            //Insolvency in Annulled status
            if(newIns.Insolvency_Status__c == 'Annulled'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsAnnulled.add(insolvId);
                }
            }
            
            //Insolvency in Refused status
            if(newIns.Insolvency_Status__c == 'Refused'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsRefused.add(insolvId);
                }
            }
            
            //Insolvency in Withdrawn status
            if(newIns.Insolvency_Status__c == 'Withdrawn'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsWithdrawn.add(insolvId);
                }
            }   
            
            //Insolvency in Discharged status
            if(newIns.Insolvency_Status__c == 'Discharged'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsDischarged.add(insolvId);
                }
            } 
            
             //Insolvency in Annulled - Filed New status
            if(newIns.Insolvency_Status__c == 'Annulled - Filed New'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsAnnulledFiledNew.add(insolvId);
                }
            }
            
             //Insolvency in Refused – Filed New status
            if(newIns.Insolvency_Status__c == 'Refused – Filed New'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsRefusedFiledNew.add(insolvId);
                }
            }
            
            //Insolvency in Withdrawn- Filed New status
            if(newIns.Insolvency_Status__c == 'Withdrawn – Filed New'){
                if(newIns.Insolvency_Status__c != oldIns.Insolvency_Status__c){
                    insolvIdsWithdrawnFiledNew.add(insolvId);
                }
            }
            
            //Copy from Insolvency
            for(String cpyInsField : cpyInsFields) {
                if(newIns.name != oldIns.name){
                    insolvIdsCopy.add(insolvId);
                }
                else if(newIns.get(cpyInsField) != oldIns.get(cpyInsField)){
                    insolvIdsCopy.add(insolvId);
                }
            }           
            
            if(newIns.Revival_Date__c <> oldIns.Revival_Date__c ){
                insolvIdsForRevival.add(insolvId);
            }

            //Voting Automation list population
            if(newIns.Eligible_For_Voting_Decision__c <> oldIns.Eligible_For_Voting_Decision__c && 
                newIns.Eligible_For_Voting_Decision__c == True && newIns.Total_Estimated_Realizable_Value__c < 20000){
                votingAutomationList.add(newIns.id);
            }
            
            //listProductToUpdate
            //mapProdList
            // Insolvency__c newIns =  insolvNewMap.get(insolvId);
            //Insolvency__c oldIns =  insolvOldMap.get(insolvId);
            
        
        }
        //update listProductToUpdate;
        
        //Ticket 7404: Voting Decision and Voting Letter Comments
        updateVotingDecision(votingDecisionChangeinsolIds);
        
        
        List<Insolvency_Account__c > insolvAccList = new List<Insolvency_Account__c >();
        List<Insolvency_Account__c > insolvAccsToUpdateForFlow = new List<Insolvency_Account__c >();
        for (Insolvency_Account__c insolvAcc : [
            SELECT Id, Percent_of_increased_return_from_voting__c, Previous_Expected_Account_Recovery__c, Expected_Account_Recovery__c
            FROM Insolvency_Account__c
            WHERE Insolvency__c IN :insolvIdsToUpdateAccounts AND RecordType.DeveloperName = 'Canadian_Tire_Insolvency_Account'
        ]) {
            Insolvency_Account__c updatedAcc = InsolvencyAccountTriggerHandler.updatePercentageOfIncreasedReturn(insolvAcc);
            if(updatedAcc != null) {
                insolvAccsToUpdateForFlow.add(updatedAcc);
            }
        }

        List<Insolvency_Account__c > insolvAccsUpdateDeceasedStatusCode = new List<Insolvency_Account__c >();
        for (Insolvency_Account__c insolvAccData : [
            SELECT Id, CTB_Status_Update_Code__c
            FROM Insolvency_Account__c
            WHERE Insolvency__c IN :insolvencyIds AND RecordType.DeveloperName = 'Canadian_Tire_Insolvency_Account'
            AND (Insolvency__r.Debtor_Deceased__c = TRUE OR Insolvency__r.Co_Debtor_Deceased__c = TRUE)
        ]) {
            insolvAccData.CTB_Status_Update_Code__c = 'DDEC';
            if(insolvAccData.CTB_Status_Update_Code__c != null) {
                insolvAccsUpdateDeceasedStatusCode.add(insolvAccData);
            }
        }

        //for(Insolvency_Account__c insolvAcc : [SELECT Id, Insolvency__c, Insolvency_Status__c FROM Insolvency_Account__c WHERE /*Insolvency_Status__c = 'New' AND */ Insolvency__c IN: insolvIdsForOwnerReview or Insolvency__c IN: insolvIdsCopy] )
        for(Insolvency_Account__c insolvAcc : [SELECT Id, 
                                               Insolvency__c, Insolvency_Status__c, Insolvency__r.Revival_Date__c 
                                               FROM Insolvency_Account__c 
                                               WHERE /*Insolvency_Status__c = 'New' AND */ 
                                               (Insolvency__c IN: insolvIdsForOwnerReview 
                                                or 
                                                Insolvency__c IN: insolvIdsCopy
                                                or 
                                                Insolvency__c IN: insolvIdsAnnulled 
                                                or 
                                                Insolvency__c IN: insolvIdsRefused
                                                or
                                                Insolvency__c IN: insolvIdsWithdrawn
                                                or
                                                Insolvency__c IN: insolvIdsForRevival 
                                                or                                        
                                                Insolvency__c IN: insolvIdsDischarged
                                                or
                                                Insolvency__c IN: insolvIdsAnnulledFiledNew
                                                or
                                                Insolvency__c IN: insolvIdsRefusedFiledNew
                                                or
                                                Insolvency__c IN: insolvIdsWithdrawnFiledNew) 
                                                and
                                                RecordType.name != 'Unknown Bank'
                                              ])
                                               
                                              {
                                                  
                                                  Boolean updateEligible = false;
                                                  
                                                  //Insolvency in For Owner Review status
                                                  if(insolvIdsForOwnerReview.contains(insolvAcc.Insolvency__c)){
                                                      if(insolvAcc.Insolvency_Status__c == 'New'){
                                                          insolvAcc.Insolvency_Status__c  = 'For Owner Review';
                                                          
                                                          //for SLA Tracking
                                                          insolvAcc.Sent_For_Owner_Review_Date_Original__c = dtNow;
                                                          insolvAcc.Sent_For_Owner_Review_By_Original__c = userId ;
                                                          insolvAcc.Sent_For_Owner_Review_Date_Updated__c = dtNow;
                                                          insolvAcc.Sent_For_Owner_Review_By_Updated__c = userId;
                                                          
                                                                                  
                                                          //Added for Ticket#167 - SLA Reports Dec_2020
                                                          insolvAcc.Sent_For_Owner_Review_Date_External__c = dtNow;
                                                          insolvAcc.Sent_For_Owner_Review_By_External__c = userId ;
                                                          updateEligible = true;
                                                      }
                                                  }
                                                  
                                                  //For Insolvency Revival date
                                                  if(insolvIdsForRevival.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Revival_Date__C = insolvAcc.Insolvency__r.Revival_Date__c;
                                                      updateEligible = true;
                                                  }
                                                  
                                                  //Insolvency in Annulled status
                                                  if(insolvIdsAnnulled.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Insolvency_Status__c  = 'Annulled';
                                                      insolvAcc.Review_Account__c = false;
                                                      updateEligible = true;                
                                                  } 
                                                  
                                                  //Insolvency in Refused status
                                                  if(insolvIdsRefused.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Insolvency_Status__c  = 'Refused';
                                                      insolvAcc.Review_Account__c = false;
                                                      updateEligible = true;                
                                                  } 
                                                  
                                                  //Insolvency in Withdrawn status
                                                  if(insolvIdsWithdrawn.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Insolvency_Status__c  = 'Withdrawn';
                                                      insolvAcc.Review_Account__c = false;
                                                      updateEligible = true;                
                                                  } 
                                                  
                                                  //Insolvency in Discharged status
                                                  
                                                  if(insolvIdsDischarged.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Insolvency_Status__c  = 'Discharged';
                                                      updateEligible = true;                
                                                  }
                                                  //Insolvency in Annulled - Filed New
                                                  if(insolvIdsAnnulledFiledNew.contains(insolvAcc.Insolvency__c)){
                                                      insolvAcc.Insolvency_Status__c  = 'Annulled - Filed New';
                                                      updateEligible = true;                
                                                  } 
                                                  
                                                  //Insolvency in Refused – Filed New status
                                                  if(insolvIdsRefusedFiledNew.contains(insolvAcc.Insolvency__c)){
                                                   insolvAcc.Insolvency_Status__c  = 'Refused – Filed New';
                                                   updateEligible = true;                
                                                  } 
              
                                                   //Insolvency in Withdrawn- Filed New status
                                                  if(insolvIdsWithdrawnFiledNew.contains(insolvAcc.Insolvency__c)){
                                                   insolvAcc.Insolvency_Status__c  = 'Withdrawn – Filed New';
                                                   updateEligible = true;                
                                                  } 
                                                                           
                                                  //Copy Insolvency Data on Insolvency Accounts
                                                  if(insolvIdsCopy.contains(insolvAcc.Insolvency__c)){
                                                      
                                                      //Copy from Insolvency
                                                      Insolvency__c newIns =  insolvNewMap.get(insolvAcc.Insolvency__c);
                                                      
                                                      //Insolvency Name - Insolvency Account Estate number
                                                      insolvAcc.Debtor_1_Estate_Number__c = newIns.name;
                                                      
                                                      //Copy from Insolvency
                                                      for(String cpyInsField : cpyInsFields) {
                                                          insolvAcc.put(cpyInsField, newIns.get(cpyInsField));
                                                      }  
                                                      
                                                      //Debtor Name
                                                      insolvAcc.Debtor__c = InsolvencyUtil.createFullName(insolvAcc.Debtor_1_First_Name__c, insolvAcc.Debtor_1_Last_Name__c);
                                                      insolvAcc.Borrower_Primary__c = InsolvencyUtil.createFullName(insolvAcc.Debtor_1_First_Name__c, insolvAcc.Debtor_1_Last_Name__c);
                                                      
                                                      //Co-Debtor Name
                                                      insolvAcc.Co_Debtor__c = InsolvencyUtil.createFullName(insolvAcc.Debtor_2_First_Name__c, insolvAcc.Debtor_2_Last_Name__c);
                                                      insolvAcc.Borrower_Coborrower_1__c = InsolvencyUtil.createFullName(insolvAcc.Debtor_2_First_Name__c, insolvAcc.Debtor_2_Last_Name__c);
                                                      
                                                      updateEligible = true;
                                                  }
                                                  
                                                  if(updateEligible){
                                                      insolvAcc.Do_Not_Run_Status_Validation__c = True;
                                                      insolvAccList.add(insolvAcc);
                                                  }
                                              }
        
        
        if(!insolvAccList.isEmpty()){
            
            try{
                update insolvAccList;
            }
            catch(Exception ex){
                system.debug('ex Message :'+ex.getMessage());
            }
        }

        if(!insolvAccsToUpdateForFlow.isEmpty()) {
            try {
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
                update insolvAccsToUpdateForFlow;
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            }
            catch(DmlException ex) {
                System.debug('DML Exception in update ' + ex.getDmlMessage(0));
            }
        }
        
        if(!insolvAccsUpdateDeceasedStatusCode.isEmpty()) {
            try {
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
                update insolvAccsUpdateDeceasedStatusCode;
                InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            }
            catch(DmlException ex) {
                System.debug('DML Exception in update ' + ex.getDmlMessage(0));
            }
        }
        
        //Call future method for Voting automation
        if(null != votingAutomationList && votingAutomationList.size() > 0){
            Database.executeBatch(new VotingEngineBatch(votingAutomationList), 40);
            // VotingEngineFutureCall.votingAutomationCall(votingAutomationList);
        }
        
    }
    
    
    public static Map<String, String> provinceMap() {
        Map<String, String> provOpts = new Map<String, String>();
        provOpts.put('AB', 'Alberta');
        provOpts.put('BC', 'British Columbia');
        provOpts.put('MB', 'Manitoba');
        provOpts.put('NB', 'New Brunswick');
        provOpts.put('NL', 'Newfoundland and Labrador');
        provOpts.put('NS', 'Nova Scotia');
        provOpts.put('ON', 'Ontario');
        provOpts.put('PE', 'Prince Edward Island');
        provOpts.put('SK', 'Saskatchewan');
        provOpts.put('NT', 'Northwest Territories');
        provOpts.put('NU', 'Nunavut');
        provOpts.put('YT', 'Yukon');
        provOpts.put('QC', 'Quebec');
        
        provOpts.put('Alberta', 'Alberta');
        provOpts.put('British Columbia', 'British Columbia');
        provOpts.put('Manitoba', 'Manitoba');
        provOpts.put('New Brunswick', 'New Brunswick');
        provOpts.put('Newfoundland and Labrador', 'Newfoundland and Labrador');
        provOpts.put('Nova Scotia', 'Nova Scotia');
        provOpts.put('Ontario', 'Ontario');
        provOpts.put('Prince Edward Island', 'Prince Edward Island');
        provOpts.put('Saskatchewan', 'Saskatchewan');
        provOpts.put('Northwest Territories', 'Northwest Territories');
        provOpts.put('Nunavut', 'Nunavut');
        provOpts.put('Yukon', 'Yukon');
        provOpts.put('Quebec', 'Quebec');
        return provOpts;
    }
    
    /* Method validates whether Insolvency has Creditor package attachment or not when submitted for Owner Review */
    public static void checkForCreditorPackage(List<Insolvency__c> insolsNew, Map<Id, Insolvency__c> oldMap){
        Set<Id> insolvIds = new Set<Id>();
        for(Attachment att : [SELECT Id, ParentId,Description FROM Attachment WHERE ParentId =:insolsNew AND description = 'Creditors Package']){
            insolvIds.add(att.ParentId);
        }
        for(Insolvency__c insolv : insolsNew){
            if(oldMap != null && (oldMap.get(insolv.Id).Insolvency_Status__c) != NULL && (oldMap.get(insolv.Id)).Insolvency_Status__c != 'For Owner Review' && insolv.Insolvency_Status__c == 'For Owner Review'){
                if(!insolvIds.contains(insolv.ID)){
                system.debug('Error added...');
                    insolv.addError('There are no \'Creditors Package\' with the insolvency created');
                }
            }
        }
    }
    public static void handleBeforeDelete(List<Insolvency__c> insolvRecords){
        ArchiveUnarchiveUtility.insertDeletedRecords(insolvRecords);
     }
     
     public static void updateVotingDecision(List<String> votingDecisionUpdateInsolIds){
         List<Insolvency_Account__c> allInsolvAcctList = new List<Insolvency_Account__c>();
        for(Insolvency_Account__c insolAccUpdate : [select id,Insolvency__r.Voting_Letter_Comments__c,
                                                 Voting_Letter_Comments__c,Voting_Options__c,Insolvency__r.Voting_Decision__c 
                                                FROM Insolvency_Account__c
                                                WHERE Insolvency__c =: votingDecisionUpdateInsolIds]){
            if(String.isNotBlank(insolAccUpdate.Insolvency__r.Voting_Letter_Comments__c)){
                insolAccUpdate.Voting_Letter_Comments__c = insolAccUpdate.Insolvency__r.Voting_Letter_Comments__c;
            } 
            if(insolAccUpdate.Insolvency__r.Voting_Decision__c == '' || 
               insolAccUpdate.Insolvency__r.Voting_Decision__c == 'Needs Manual Review'){
            	insolAccUpdate.Voting_Options__c = '';
            }else if(insolAccUpdate.Insolvency__r.Voting_Decision__c == 'Manually Approved' || 
                     insolAccUpdate.Insolvency__r.Voting_Decision__c == 'Auto Approved'){
                insolAccUpdate.Voting_Options__c = 'Vote Accept';                                        
            }else if(insolAccUpdate.Insolvency__r.Voting_Decision__c == 'Manually Rejected' ||
                    insolAccUpdate.Insolvency__r.Voting_Decision__c == 'Manually Rejected - Majority Approved'){                       
                insolAccUpdate.Voting_Options__c = 'Vote: Decline - With Creditor Meeting Request';
            }    
            allInsolvAcctList.add(insolAccUpdate);
        }
        if(!allInsolvAcctList.isEmpty()){
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            update allInsolvAcctList;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
     }
}