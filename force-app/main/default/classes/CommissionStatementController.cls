public class CommissionStatementController {
    //Total records of direct payments
    public transient List<List<product_payments__c>> prodPayList1{get; set;}
    //Total records of payment update
    public transient List<List<product_payments__c>> prodPayUpdate{get; set;}
    //store placement details
    public Placement__c placeDetails{get; set;}
    //Store aggregate of the product payment 
    public Summary[] Summaries { get; set; }
    
    public AggregateResult aggProdDirectPayment{get; set;}
    public AggregateResult aggProdPayUpdate{get; set;}
    public String monthName { get; set; }
    public Integer year {get;set;}
    public String docCreatDate {get;set;}
    Public Decimal totalAmount {get;set;}
    //Display document number
    Public String num {get;set;}
    //Stores the total of the direct and payment update details
    public Decimal retainedAmountForDirectPayment {get;set;}
    public Decimal retainedAmountFoPaymentUpdate {get;set;}
   
    //fetch tax type 
    Public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    //Public List<Application_Config_Settings__c> applicationConfig = Application_Config_Settings__c.getAll();
    
    Public CommissionStatementController(){
        prodPayList1 =new List<List<product_payments__c>>();
        prodPayUpdate =new List<List<product_payments__c>>();
        totalAmount = 0;
        retainedAmountForDirectPayment = 0.00;
        retainedAmountFoPaymentUpdate = 0.00;
        //amountDue = new map<String, Decimal>();
        String currentMonth;
        String currentDay;
        Id id = System.currentPageReference().getParameters().get('Id');        
        num = System.currentPageReference().getParameters().get('Number');
       
        DateTime currentDate = system.now();
        year = currentDate.year();
        String monthInt = String.valueOf(currentDate.month());
        String dayInt = String.valueOf(currentDate.day());
        Integer monthSize = monthInt.length();
        Integer daySize = dayInt.length();
        if(monthSize <= 1){
            currentMonth = '0' + String.valueOf(currentDate.month());
        }else{
            currentMonth = String.valueOf(currentDate.month());
        }
        if(daySize <= 1){
            currentDay = '0' + String.valueOf(currentDate.day());
        }else{
            currentDay = String.valueOf(currentDate.day());
        }
        docCreatDate = currentMonth +'/'+ currentDay + '/' + currentDate.year();
        Integer month = currentDate.Month()-1;
        String sInteger = String.valueOf(month);        
        //Get month name based on number
        getMonth(sInteger);
        //String monthName = month.format('MMM');
      
        //Fetch agency details based on agency id
        if(id != null){
            placeDetails = [Select id,Name,Agency_Name__c,Agency_Address__c,Agency_City__c ,Agency_State__c ,Agency_Zip_Code__c ,
                            HST_GST_Registration_Number__c,Agency_Street1__c,Agency_Phone_Number__c,Agency_Street2__c
                            from placement__c
                            where id =: id];            
        }
        
        //This query is used for Direct payment detailed section
        Application_Config_Settings__c  mc = Application_Config_Settings__c.getOrgDefaults();
        //Application_Config_Settings__c mc = Application_Config_Settings__c.getValues();
        Application_Config_Settings__c config = [SELECT Product_Payment_Record_Type__c FROM Application_Config_Settings__c];
   //system.debug('mc:'+mc);
        //string recordType = '0123a0000000NDy';
        transient List<product_payments__c> prodPayList = [select id,name,createdDate,CCS_Account__c,Payment_Type__c,Payment_Created_Date__c,CCS_Account__r.Pool_Name__r.Name,
                                                 Payment_Provided_Agency__r.Name,Gross_Payment_Amount__c,Pay_Reimburse__c,Payment_Created__c,Payment_Amount__c,
                                                 Tax_Amount__c,CCS_Account__r.Name,CCS_Account__r.Next_Amount_Due__c,Pay_Due__c,Payment_Source__c,
                                                 Payment_Provided_Agency__r.Agency_Address__c,Agency_Commission_Rate__c,Amount_Due__c,CCS_Account__r.State__c,Tax_Type__C,
                                                 Commission_Rate_for_Payment__c,Agency_Calculated_Comm__c,Tax_Province__c,Tax_Province_Rate__c,Legal_Product_Identifier__c
                                                 from product_payments__c 
                                                 where Payment_Created__c = LAst_Month
                                                 AND recordTypeID =: config.Product_Payment_Record_Type__c
                                                 AND (Payment_Type__c ='1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'
                                                      OR Payment_Type__c = '1003' OR Payment_Type__c = '1004')
                                                 AND (Payment_Source__c = '2' OR Payment_Source__c = '3')
                                                 AND Payment_Provided_Agency__c =: id];
        //system.debug('prodPayments'+prodPayList);
        Decimal totalAmountDirect = 0;
        Decimal PayDueAmount=0;
        Decimal taxAmount=0;
      
      if(!prodPayList.isEmpty()){
     
      aggProdDirectPayment = [select Payment_Provided_Agency__c payAgency,count(id) total,sum(Pay_Due__c) PayDueAmount,sum(Tax_amount__c) taxAmount,
                                            sum(Payment_Amount__c) payAmount,sum(Amount_Due__c) amountDue,sum(Pay_Reimburse_Formula__c) payReimburse
                                            from product_payments__c 
                                            where Payment_Created__c = LAst_Month
                                                 AND recordTypeID =: config.Product_Payment_Record_Type__c
                                            AND (Payment_Type__c ='1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'
                                                 OR Payment_Type__c = '1003' OR Payment_Type__c = '1004')
                                            AND (Payment_Source__c = '2' OR Payment_Source__c = '3')
                                            //AND recordType.Name = 'Distressed_Product_Payment'
                                            AND  Payment_Provided_Agency__c =: id
                                            group by Payment_Provided_Agency__c];
                                                
       if((Decimal)aggProdDirectPayment.get('PayDueAmount') != null){
            PayDueAmount = (Decimal)aggProdDirectPayment.get('PayDueAmount');
        }
        if((Decimal)aggProdDirectPayment.get('taxAmount') != null){
            taxAmount= (Decimal)aggProdDirectPayment.get('taxAmount');
        }
      }
          
        totalAmountDirect = PayDueAmount + taxAmount;
        //Product_Payments__c 
        prodPayList1.add(prodPayList);
                    
        //This query is used for payment update reconsilation detailed section
        transient List<product_payments__c> prodPayUpdateDetails = [select id,name,createdDate,CCS_Account__c,Payment_Type__c,Payment_Created_Date__c,CCS_Account__r.Pool_Name__r.Name,
                                                          Payment_Provided_Agency__r.Name,Gross_Payment_Amount__c,Pay_Reimburse__c,Payment_Created__c,Payment_Amount__c,
                                                          Tax_Amount__c,CCS_Account__r.Name,CCS_Account__r.Next_Amount_Due__c,Pay_Due__c,Payment_Source__c,
                                                          Payment_Provided_Agency__r.Agency_Address__c,Agency_Commission_Rate__c,Amount_Due__c,CCS_Account__r.State__c,Tax_Type__C,
                                                          Commission_Rate_for_Payment__c,Agency_Calculated_Comm__c,Tax_Province__c,Tax_Province_Rate__c,Legal_Product_Identifier__c
                                                          from product_payments__c 
                                                          where Payment_Created__c = LAst_Month
                                                 AND recordTypeID =: config.Product_Payment_Record_Type__c
                                                          AND (Payment_Type__c ='1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'
                                                               OR Payment_Type__c = '1003' OR Payment_Type__c = '1004')
                                                          AND (Payment_Source__c != '2' AND Payment_Source__c != '3')
                                                          //AND recordType.Name = 'Distressed_Product_Payment'
                                                          AND Payment_Provided_Agency__c =: id];
        Decimal totalAmountUpdate = 0;
        Decimal PayDueAmount1=0;
        Decimal taxAmount1=0;
        
        if(!prodPayUpdateDetails.isEmpty()){
      
          aggProdPayUpdate = [select Payment_Provided_Agency__c payAgency,count(id) total,sum(Pay_Due__c) PayDueAmount,sum(Tax_amount__c) taxAmount,
                                            sum(Payment_Amount__c) payAmount,sum(Amount_Due__c) amountDue,sum(Pay_Reimburse_Formula__c) payReimburse
                                            from product_payments__c 
                                            where Payment_Created__c = LAst_Month
                                                 AND recordTypeID =: config.Product_Payment_Record_Type__c
                                            AND (Payment_Type__c ='1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'
                                                 OR Payment_Type__c = '1003' OR Payment_Type__c = '1004')
                                            AND (Payment_Source__c != '2' AND Payment_Source__c != '3')
                                            //AND recordType.Name = 'Distressed_Product_Payment'
                                            AND  Payment_Provided_Agency__c =: id
                                            group by Payment_Provided_Agency__c];
            
             if((Decimal) aggProdPayUpdate.get('PayDueAmount') != null){
              PayDueAmount1 = (Decimal) aggProdPayUpdate.get('PayDueAmount');
        }
        if((Decimal) aggProdPayUpdate.get('taxAmount') != null){
              taxAmount1 = (Decimal) aggProdPayUpdate.get('taxAmount');
        }
             }                               
       
        totalAmountUpdate = PayDueAmount1 + taxAmount1 ;
        totalAmount = totalAmountUpdate + totalAmountDirect;
        prodPayUpdate.add(prodPayUpdateDetails);
        //Aggregate product payment records based on product province.
        AggregateResult[] aggProdPayList = [select Tax_Province__c province,count(id) total,sum(Pay_Due__c) amount,sum(Tax_amount__c) taxAmount,
                                            sum(Direct_Payments__c) directPayment,sum(Payment_Update_Reconciliation__c) paymentUpdateRe
                                            from product_payments__c 
                                            where Payment_Created__c = LAst_Month
                                                 AND recordTypeID =: config.Product_Payment_Record_Type__c
                                            AND (Payment_Type__c ='1000' OR Payment_Type__c = '1001' OR Payment_Type__c = '1002'
                                                 OR Payment_Type__c = '1003' OR Payment_Type__c = '1004')
                                            //AND recordType.Name = 'Distressed_Product_Payment'
                                            AND  Payment_Provided_Agency__c =: id
                                            group by Tax_Province__c];
        //system.debug('aggProdPayList'+aggProdPayList);
        Summaries = new List<Summary>();
        for (AggregateResult ar : aggProdPayList) {       
            Summaries.add(new Summary(ar));
        }       
    }
    //This wrapper class stores the aggregate data    
    public class Summary {
        public Decimal amount { get; private set; }
        public Decimal taxAmount { get; private set; }
        public String province{get; private set;}
        public Decimal total{get; private set;}
        public Decimal gst{get; private set;}
        public Decimal pst{get; private set;}
        public Decimal directPayment{get; private set;}
        public Decimal paymentUpdateRe{get; private set;}
        public String taxType {get; private set;}
        public Decimal hst {get; private set;}
        public Decimal gstpst {get; private set;}
        public Decimal gstqst {get; private set;}
        
        public Summary(AggregateResult ar) {
            directPayment = 0.00;
            paymentUpdateRe = 0.00;
            amount = (Decimal) ar.get('amount');
            taxAmount = (Decimal) ar.get('taxAmount');
            if((Decimal) ar.get('directPayment') != null){
                directPayment = (Decimal) ar.get('directPayment');
            }else{
                directPayment = 0.00;
            }
            if((Decimal) ar.get('paymentUpdateRe') != null){
                paymentUpdateRe = (Decimal) ar.get('paymentUpdateRe');
            }else{
                paymentUpdateRe = 0.00;
            }
            if(provinceMap.containsKey((String)ar.get('province'))){
                province = provinceMap.get((String)ar.get('province'));
            }else if(!provinceMap.containsKey((String)ar.get('province')) && (String)ar.get('province') != null){
                province = (String)ar.get('province');
            }else{
                province = 'Other Areas';
            }
            //system.debug('Province_null::'+(String)ar.get('province'));
            if(provinceMapForTax.containsKey((String)ar.get('province'))){
                taxType = mapTaxMetadata.get(provinceMapForTax.get((String)ar.get('province'))).Tax_Type__c;
            }       
            //system.debug('taxType::'+taxType);
            if((Decimal) ar.get('taxAmount') != null && taxType == 'GST'){
                gst = (Decimal) ar.get('taxAmount');
            }else{
                gst = 0.00;
            }
            if((Decimal) ar.get('taxAmount') != null && taxType == 'PST'){
                pst = (Decimal) ar.get('taxAmount');
            }else{
                pst = 0.00;
            }
            if((Decimal) ar.get('taxAmount') != null && taxType == 'HST'){
                hst = (Decimal) ar.get('taxAmount');                
            }else{
                hst = 0.00;
            }
            if((Decimal) ar.get('taxAmount') != null && taxType == 'GST+PST'){
                gstpst = (Decimal) ar.get('taxAmount');                
            }else{
                gstpst = 0.00;
            }
            if((Decimal) ar.get('taxAmount') != null && taxType == 'GST+QST'){
                gstqst = (Decimal) ar.get('taxAmount');                
            }else{
                gstqst = 0.00;
            }
            total = directPayment + paymentUpdateRe + pst + gst + hst + gstpst + gstqst;
        }
    }
   
    //month name and code map.
    public static Map<String, String> monthMap = new Map<String, String>{
        '1' => 'January',
            '2' => 'February',
            '3' => 'March',
            '4' => 'April',
            '5' => 'May',
            '6' => 'June',
            '7' => 'July',
            '8' => 'August',
            '9' => 'September',
            '10' => 'October',
            '11' => 'November',
            '0' => 'December'         
            };
                public void getMonth(String month){
                    //month = province.toUpperCase();
                    
                    if(monthMap.containsKey(month)){
                        
                        monthName = monthMap.get(month);
                        //system.debug('monthName1::'+monthName);
                    }
                    else{
                        monthName = '';
                    }
                }
    // Province name and code map - These are the updated for voting engine enhancement requirement.
    public static Map<String, String> provinceMap = new Map<String, String>{
        'BC' => 'British Columbia',
            'MB' => 'Manitoba',
            'NB' => 'New Brunswick',
            'NL' => 'Newfoundland And Labrador',
            'NT' => 'Northwest Territories',
            'NS' => 'Nova Scotia',
            'NU' => 'Nunavut',
            'ON' => 'Ontario',
            'PE' => 'Prince Edward Island',
            'QC' => 'Quebec',
            'SK' => 'Saskatchewan',
            'YT' => 'Yukon',
            'AB' => 'Alberta'
            };
                //Province name and code map - These are the updated for voting engine enhancement requirement.
                public static Map<String, String> provinceMapForTax = new Map<String, String>{
                    'BC' => 'British_Columbia',
                        'MB' => 'Manitoba',
                        'NB' => 'New_Brunswick',
                        'NL' => 'Newfoundland_and_Labrador',
                        'NT' => 'Northwest_Territories',
                        'NS' => 'Nova_Scotia',
                        'NU' => 'Nunavut',
                        'ON' => 'Ontario',
                        'PE' => 'Prince_Edward_Island',
                        'QC' => 'Quebec',
                        'SK' => 'Saskatchewan',
                        'YT' => 'Yukon',
                        'AB' => 'Alberta',
                        'PE' => 'Prince_Edward_Island'
                        };
                            
                            // Replace provice name with province code and send to voting engine. - These are the updated for voting engine enhancement requirement.    
                            public static String getProvince(String province){
                                province = province.toUpperCase();
                                
                                if(provinceMap.containsKey(province)){
                                    
                                    return provinceMap.get(province);
                                }
                                else{
                                    return null;
                                }
                            }
    // Replace provice name with province code and send to voting engine. - These are the updated for voting engine enhancement requirement.    
    public static String getProvinceForTax(String province){
        province = province.toUpperCase();
        
        if(provinceMapForTax.containsKey(province)){
            
            return provinceMapForTax.get(province);
        }
        else{
            return null;
        }
    }
}