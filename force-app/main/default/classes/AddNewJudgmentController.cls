public class AddNewJudgmentController {
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapTaxMetadata = Province_Tax_Rate_Mapping__mdt.getAll();
    public static map<String, Province_Tax_Rate_Mapping__mdt> mapProvinceAcronymTaxMetadata = new map<String, Province_Tax_Rate_Mapping__mdt>();
    static{
        for(Province_Tax_Rate_Mapping__mdt taxMetadata : mapTaxMetadata.values()){
            mapProvinceAcronymTaxMetadata.put(taxMetadata.Province_Acronym__c, taxMetadata);
        }
    }
    //bug:5476 changes starts
    @AuraEnabled
    public static string getProductName(Id prodId){
        product__c prod=[select id,name from product__c where ID=:prodId];
        return prod.name;
    }
    //bug:5476 changes ends
    @AuraEnabled
    public static void linkRecords(Id prodId, Id judgId){
        Account_Judgment__c prodJudg = new Account_Judgment__c();
        prodJudg.Judgment__c = judgId;
        prodJudg.Product__c = prodId;
        prodJudg.Status__c = 'Active';
        Database.insert(prodJudg, false) ;

        Judgment__c judg = [SELECT Legal_Status__c, Legal_Sub_Status__c,Agency_Initiated_Legal_Action__c,Judgment_Province__c FROM Judgment__c where Id  =: judgId];
        for(Product__c prod: [SELECT Id, Legal_Status__c,Collection_Agency__c,State__c FROM Product__c WHERE Id =: prodId]){
            prod.Legal_Status__c = judg.Legal_Status__c != null ? judg.Legal_Status__c : '' + ' - '+judg.Legal_Sub_Status__c != NULL ? judg.Legal_Sub_Status__c : '';
        }
    }
   
    @AuraEnabled
    public static List<Id> getlinkedJudgments(Id prodId){
        List<Id> linkedJudgments = new List<Id>();
        for(Account_Judgment__c accJudg: [SELECT Judgment__c FROM Account_Judgment__c WHERE Product__c=: prodId]){
            linkedJudgments.add(accJudg.Judgment__c);
        }
        return linkedJudgments;
    }
    @AuraEnabled
    public static String validationRule(Id prodId, Id judgId,Map<String,String> judgMap){
        String prodProvinceName;
        String ProvinceNameFormat;
        String provinceAcronymFormat;
        String purchaseProvince;
        String agency;
        String ErrorMsg = '';
        String Codes;
        list<String> listError = new list<String>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();
        
        if(judgId != null){
        	Judgment__c judgment = [SELECT Id,Name,Legal_Status__c, Legal_Sub_Status__c,Agency_Initiated_Legal_Action__c, Judgment_Province__c FROM Judgment__c where Id  =: judgId];
        }
        Product__c prod = [SELECT Id,Name,Status__c, Legal_Status__c,Collection_Agency__c,Purchase_Province__c,State__c,Account_Purchasing_Entity_Value__c
                           FROM Product__c WHERE Id =: prodId];

        //Added below IF loop for #4586
        if(prod.Status__c.contains('Pending Recall')){
            ErrorMsg=System.label.Judgment_Pending_Recall_Error_Message;
        }
        //Bug: 5631 changes starts
        if(!judgMap.containsKey('Legal_Status__c')){
            ErrorMsg='Judgment Legal Status, Legal SubStatus are Mandatory. Please select the values for Legal Status, Legal SubStatus fields';      
        }
        else if(string.isBlank(judgMap.get('Legal_Status__c')) || string.isBlank(judgMap.get('Legal_Sub_Status__c'))){
          ErrorMsg='Judgment Legal Status, Legal SubStatus are Mandatory. Please select the values for Legal Status, Legal SubStatus fields';
        }
        //Bug:5631 changes ends
        if(prod.Purchase_Province__c != NULL){
            purchaseProvince = prod.Purchase_Province__c;
        }
        if(prod.Collection_Agency__c != NULL){
            agency = String.valueOf(Math.floor(prod.Collection_Agency__c));
        }
       	
        judgMap.put('Judgment_Province__c',purchaseProvince);
        judgMap.put('Product_1__c',prod.Name);
        judgMap.put('Plaintiff__c',prod.Account_Purchasing_Entity_Value__c);
        judgMap.put('Agency_Initiated_Legal_Action__c',agency);
        
        String Status = judgMap.get('Legal_Status__c');

        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                          WHERE Product_Parent__c = :Status]){         
          mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);                                                                                  
        }
        
        if(mapAccountJudgmentCodes.containsKey(judgMap.get('Legal_Status__c')+ judgMap.get('Legal_Sub_Status__c'))){
            Codes = mapAccountJudgmentCodes.get(judgMap.get('Legal_Status__c')+judgMap.get('Legal_Sub_Status__c')).Codes__c;  
        }
        
        if(String.isBlank(purchaseProvince)){
            ErrorMsg = 'Product Province is required';
        }
        if((codes == '220000') || (codes == '220210') || (codes =='220700') || (codes =='220030') || (codes =='220040') || (codes =='220050')){
            if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL))
                  || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c')) || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){                     
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Product 1,interest Rate-1,Suit Amount 1,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
             }
        }
        if((codes == '220020') || (codes == '220220') || (codes == '220900') || (codes == '290400')
           || (codes == '299100') || (codes == '299999') || (codes == '290020')){
               if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
                  || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL))
                  || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c')) || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Product 1,Balance-1,interest Rate-1,Suit Amount 1,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                  }
           }
        if((codes == '290000') || (codes == '290010') || (codes == '290700') || (codes == '291000')
          || (codes == '290030') || (codes == '290040') || (codes == '290050') || (codes == '293010')
          || (codes == '293030') || (codes == '293040') || (codes == '293050') || (codes == '295070')
          || (codes == '295080') || (codes == '295900')){
            if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
               	  || judgMap.get('Judgment_Date__c') == NULL || judgMap.get('Judgment_Amount__c') == NULL || judgMap.get('Filing_Date__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL 
                  || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL)) || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c'))
                  || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){
                   ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
               }
        }
        if((codes == '290005')){
            if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
               	  || judgMap.get('Judgment_Date__c') == NULL || judgMap.get('Judgment_Amount__c') == NULL || judgMap.get('Filing_Date__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL 
                  || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL))){
                   ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1';
               }
        }
        if((codes == '293000') || (codes == '294000')){
            if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
               	  || judgMap.get('Judgment_Date__c') == NULL || judgMap.get('Judgment_Amount__c') == NULL || judgMap.get('Filing_Date__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL 
                  || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL)) || String.isBlank(judgMap.get('Garnishment_Number__c')) || judgMap.get('Garnishment_Date__c') == NULL
                  || judgMap.get('Garnishment_Amount__c') == NULL || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c'))
                  || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){
                   ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
               }
        }
        
        if((codes == '295000') || (codes == '295030') || (codes == '295060') || (codes == '295010')
          || (codes == '295040') || (codes == '295050')){
            if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
               	  || judgMap.get('Judgment_Date__c') == NULL || judgMap.get('Judgment_Amount__c') == NULL || judgMap.get('Filing_Date__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL 
                  || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL)) || String.isBlank(judgMap.get('Writ_Number__c')) || judgMap.get('Writ_Amount__c') == NULL
               	  || judgMap.get('Date_Writ_Issued__c') == NULL || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c'))
                  || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){
                   ErrorMsg ='Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1,Writ Number,Writ Amount,Date Writ Issued,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
               }
        }
        if((codes == '295020')){
               if(String.isBlank(judgMap.get('Case_Number__c')) || String.isBlank(judgMap.get('Judgment_Province__c')) || judgMap.get('Suit_Amount__c') == NULL || judgMap.get('Date_Debtor_Served__c') == NULL
                  || judgMap.get('Judgment_Date__c') == NULL || judgMap.get('Judgment_Amount__c') == NULL || judgMap.get('Filing_Date__c') == NULL || ((String.isNotBlank(judgMap.get('Product_1__c'))) && (judgMap.get('Balance_one__c') == NULL 
                  || judgMap.get('Interest_Rate_one__c') == NULL || judgMap.get('Suit_Amount_1__c') == NULL)) || String.isBlank(judgMap.get('Writ_Number__c')) || judgMap.get('Writ_Amount__c') == NULL
                  || judgMap.get('Date_Writ_Issued__c') == NULL || judgMap.get('Garnishment_Amount__c') == NULL || String.isBlank(judgMap.get('Garnishment_Number__c')) || judgMap.get('Garnishment_Date__c') == NULL
                  || String.isBlank(judgMap.get('Court__c')) || String.isBlank(judgMap.get('Legal_Firm__c')) || String.isBlank(judgMap.get('Plaintiff__c')) || String.isBlank(judgMap.get('Attorney__c')) || String.isBlank(judgMap.get('Agency_Initiated_Legal_Action__c'))){
                    ErrorMsg ='Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
              } 
         }
                
       listError.add(ErrorMsg);
        return ErrorMsg;
    }
    
    @AuraEnabled
   
    //get Province Name
    public static String nameFormat (String name) {
        String result = '';
        if (name != null && name != '') {
            name = name.toLowercase();
            for (String iter : name.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1) {  
                        result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                    }
                    else {
                        result += iter.substring(0,1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
        }
        return result;
    }
    @AuraEnabled
    public static list<String> validationRuleForExistingRecord(Id prodId, Id judgId,Map<String,String> judgMap){
        String prodProvinceName;
        String ProvinceNameFormat;
        String provinceAcronymFormat;
        String purchaseProvince;
        String ErrorMsg = '';
        String ProdProvince;
        Judgment__c judgment;
        String Codes;
        list<String> listError = new list<String>();
        map<String, Judgment_product_codes_mapping__c> mapAccountJudgmentCodes = new map<String, Judgment_product_codes_mapping__c>();

        if(judgId != null){
        	 judgment = [SELECT Id,Name,Legal_Status__c, Legal_Sub_Status__c,Agency_Initiated_Legal_Action__c, Judgment_Province__c,
                         Case_Number__c,Suit_Amount__c,Date_Debtor_Served__c,Product_1__c,Balance_one__c,Interest_Rate_one__c,Suit_Amount_1__c,
                         Court__c,Legal_Firm__c,Plaintiff__c,Attorney__c,Product_2__c,Balance_two__c,Suit_Amount_2__c,
                         Interest_Rate_two__c,County__c,Product_3__c,Balance_three__c,Interest_Rate_three__c,Suit_Amount_3__c,
                         Product_4__c,Balance_four__c,Interest_Rate_four__c,Suit_Amount_4__c,Product_5__c,Balance_five__c,
                         Interest_Rate_five__c,Suit_Amount_5__c,Judgment_Date__c,Judgment_Amount__c,Filing_Date__c,Legal_Agency__c
                         FROM Judgment__c where Id  =: judgId];
        }

        Product__c prod = [SELECT Id,Name, Legal_Status__c,Collection_Agency__c,Purchase_Province__c,State__c,Invalid_Submission_Reason__c FROM Product__c WHERE Id =: prodId];
		
        if(prod.Purchase_Province__c != NULL){
            purchaseProvince = prod.Purchase_Province__c;
            ProvinceNameFormat = nameFormat(purchaseProvince);
            provinceAcronymFormat = purchaseProvince.toUpperCase();
            if(mapProvinceAcronymTaxMetadata.containsKey(provinceAcronymFormat)){
                ProdProvince = mapProvinceAcronymTaxMetadata.get(provinceAcronymFormat).Province_Name__c;
            }else if(mapTaxMetadata.containsKey(ProvinceNameFormat)){
                ProdProvince = ProvinceNameFormat;
            }
        }
        
        string Product_1;
        string Product_2;
        string Product_3;
        string Product_4;
        string Product_5;
        String Status = judgment.Legal_Status__c;

        if(judgment.Product_1__c == NULL){
            Product_1 = prod.Name;
        }
        else if(judgment.Product_2__c == NULL){
            Product_2 = prod.Name;
        }
        else if(judgment.Product_3__c == NULL){
            Product_3 = prod.Name;
        }
        else if(judgment.Product_4__c == NULL){
            Product_4 = prod.Name;
        }
        else if(judgment.Product_5__c == NULL){
            Product_5 = prod.Name;
        }
        
        for(Judgment_product_codes_mapping__c mapping : [SELECT Id,Name,Codes__c, Product_Status__c,
                                                                Product_Sub_status__c,Judgment_Legal_Status__c,
                                                                Judgment_Legal_Sub_Status__c
                                                         FROM Judgment_product_codes_mapping__c
                                                          WHERE Product_Parent__c = :Status]){
          mapAccountJudgmentCodes.put(mapping.Judgment_Legal_Status__c+mapping.Judgment_Legal_Sub_Status__c, mapping);                                                                                   
        }
        
        if(mapAccountJudgmentCodes.containsKey(judgment.Legal_Status__c+ judgment.Legal_Sub_Status__c)){
            Codes = mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c;  
        }
        if(!System.Label.Exclude_Judgment_Codes.contains(mapAccountJudgmentCodes.get(judgment.Legal_Status__c+judgment.Legal_Sub_Status__c).Codes__c)){
            ErrorMsg = 'You cannot add this record on product becuase this is in judgment state';
            listError.add(ErrorMsg);
        }
        if(prod.Collection_Agency__c == NULL){
            ErrorMsg = 'Product Agency is required';
            listError.add(ErrorMsg);
        }
        if(String.isBlank(purchaseProvince)){
            ErrorMsg = 'Product Province is required';
            listError.add(ErrorMsg);
        }
        if(prod.Collection_Agency__c != NULL && judgment.Legal_Agency__c != String.valueOf(Math.floor(prod.Collection_Agency__c))){
            ErrorMsg='Product Agency is not Match with Judgment Agency.';
            listError.add(ErrorMsg);

        }
        if(judgment.Judgment_Province__c != ProdProvince){
			ErrorMsg='Product Province is not Match with Judgment Province.';
            listError.add(ErrorMsg);
        }
        if((codes == '220000') || (codes == '220210') || (codes =='220700') || (codes =='220030')
          || (codes =='220040') || (codes =='220050')){
            if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || String.isBlank(judgment.Court__c) || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c) || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){                     
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                      listError.add(ErrorMsg);
             }
              if(((String.isNotBlank(Product_1)) && (judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1';                                      
                   listError.add(ErrorMsg);
              }
             if(((String.isNotBlank(Product_2)) && (judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                  ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                   listError.add(ErrorMsg);
              }
              if(((String.isNotBlank(Product_3)) && (judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                  ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                   listError.add(ErrorMsg);
              }
              if(((String.isNotBlank(Product_4)) && (judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                  ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                   listError.add(ErrorMsg);
               }
              if(((String.isNotBlank(Product_5)) && (judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                  ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                      listError.add(ErrorMsg);
              }
        }
        if((codes == '220020') || (codes == '220220') || (codes == '220900') || (codes == '290400')
              || (codes == '299100') || (codes == '299999') || (codes == '290020')){
                if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || String.isBlank(judgment.Court__c) || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c) || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                    listError.add(ErrorMsg);  
                }
                if(((String.isNotBlank(Product_1)) && (judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,Court,County,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        if((codes == '290000') || (codes == '290010') || (codes == '290700') || (codes == '291000')
              || (codes == '290030') || (codes == '290040') || (codes == '290050') || (codes == '293010')
              || (codes == '293030') || (codes == '293040') || (codes == '293050') || (codes == '295070')
              || (codes == '295080') || (codes == '295900')){
                if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || judgment.Judgment_Date__c == NULL || judgment.Judgment_Amount__c == NULL || judgment.Filing_Date__c == NULL || String.isBlank(judgment.Court__c)
                  || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c) || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                    listError.add(ErrorMsg);    
                }
                  if(((String.isNotBlank(Product_1)) && (judgment.Balance_one__c == NULL  || judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Balance_two__c == NULL || judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Balance_three__c == NULL || judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Balance_four__c == NULL || judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Balance_five__c == NULL || judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        if((codes == '290005')){
                if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || judgment.Judgment_Date__c == NULL || judgment.Judgment_Amount__c == NULL || judgment.Filing_Date__c == NULL){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date';
                    listError.add(ErrorMsg);  
                }
            	  if(((String.isNotBlank(Product_1)) && (judgment.Balance_one__c == NULL || judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 1,Balance-1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Balance_two__c == NULL || judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Balance_three__c == NULL || judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Balance_four__c == NULL || judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Balance_five__c == NULL || judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        if((codes == '293000') || (codes == '294000')){
                if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || judgment.Judgment_Date__c == NULL || judgment.Judgment_Amount__c == NULL || judgment.Filing_Date__c == NULL || String.isBlank(judgment.Court__c)
                  || String.isBlank(judgment.Garnishment_Number__c) || judgment.Garnishment_Date__c == NULL || judgment.Garnishment_Amount__c == NULL
                  || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c) || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                    listError.add(ErrorMsg);    
                }
            	 if(((String.isNotBlank(Product_1)) && (judgment.Balance_one__c == NULL || judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Balance_two__c == NULL || judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Balance_three__c == NULL || judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Balance_four__c == NULL || judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Balance_five__c == NULL || judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        if((codes == '295000') || (codes == '295030') || (codes == '295060') || (codes == '295010')
              || (codes == '295040') || (codes == '295050')){
                if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || judgment.Judgment_Date__c == NULL || judgment.Judgment_Amount__c == NULL || judgment.Filing_Date__c == NULL || judgment.Date_Writ_Issued__c == NULL
                  || String.isBlank(judgment.Writ_Number__c) || judgment.Writ_Amount__c == NULL || String.isBlank(judgment.Court__c) || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c)
                  || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                    listError.add(ErrorMsg);      
                }
                  if(((String.isNotBlank(Product_1)) && (judgment.Balance_one__c == NULL || judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Balance_two__c == NULL || judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Balance_three__c == NULL || judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Balance_four__c == NULL || judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Balance_five__c == NULL || judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        if((codes == '295020')){
               if(String.isBlank(judgment.Case_Number__c) || String.isBlank(judgment.Judgment_Province__c) || judgment.Suit_Amount__c == NULL || judgment.Date_Debtor_Served__c == NULL
                  || judgment.Judgment_Date__c == NULL || judgment.Judgment_Amount__c == NULL || judgment.Filing_Date__c == NULL 
                  || String.isBlank(judgment.Writ_Number__c) || judgment.Writ_Amount__c == NULL || judgment.Date_Writ_Issued__c == NULL || judgment.Garnishment_Amount__c == NULL
                  || String.isBlank(judgment.Garnishment_Number__c) || judgment.Garnishment_Date__c == NULL || String.isBlank(judgment.Court__c) 
                  || String.isBlank(judgment.Legal_Firm__c) || String.isBlank(judgment.Plaintiff__c) || String.isBlank(judgment.Attorney__c) || String.isBlank(judgment.Agency_Initiated_Legal_Action__c)){
                    ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action';
                    listError.add(ErrorMsg);       
                }
            	if(((String.isNotBlank(Product_1)) && (judgment.Balance_one__c == NULL || judgment.Interest_Rate_one__c == NULL || judgment.Suit_Amount_1__c == NULL))){
                        ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 1,Balance-1,interest Rate-1,Suit Amount 1';                                      
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_2)) && (judgment.Balance_two__c == NULL || judgment.Interest_Rate_two__c == NULL || judgment.Suit_Amount_2__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 2,Balance-2,interest Rate-2,Suit Amount 2';                                        
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_3)) && (judgment.Balance_three__c == NULL || judgment.Interest_Rate_three__c == NULL || judgment.Suit_Amount_3__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 3,Balance-3,interest Rate-3,Suit Amount 3';                                       
                       listError.add(ErrorMsg);
                  }
                  if(((String.isNotBlank(Product_4)) && (judgment.Balance_four__c == NULL || judgment.Interest_Rate_four__c == NULL || judgment.Suit_Amount_4__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 4,Balance-4,interest Rate-4,Suit Amount 4';                                        
                       listError.add(ErrorMsg);
                 }
                  if(((String.isNotBlank(Product_5)) && (judgment.Balance_five__c == NULL || judgment.Interest_Rate_five__c == NULL || judgment.Suit_Amount_5__c == NULL))){
                      ErrorMsg = 'Fields should not blank Case Number,Province,Suit Amount,Debtor Served,judgment date,judgment amount,judgment filing date,Writ Number,Writ Amount,Date Writ Issued,Garnishment Number,Date Garnishment Issued,Garnishment Amount,Court,Legal Firm,Plaintiff,Attorney,Agency Initiated Legal Action,Product 5,Balance-5,interest Rate-5,Suit Amount 5';  
                          listError.add(ErrorMsg);
                  }
            }
        return listError;
    }

    @AuraEnabled
    public static Judgment__c getProductJudgmentDetails(Id judgmentId) {
        Judgment__c judg = [SELECT id, name, Product_1__c, Product_2__c, Product_3__c, Product_4__c, Product_5__c FROM Judgment__c WHERE ID = :JudgmentId];
        return judg;
    }
}