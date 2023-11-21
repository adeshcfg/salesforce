/***************************************************
* Author         : A5E Consultancy
* Created On     : 15 Feb 2020
* Description    : Helper class for CustomerProcesingBatch
*
***************************************************/
public class CustomerProcessingBatchHelper {
    
    public static Map<String, String> accountStatusMapping =  new Map<String, String>{
                                                                        'COMPLETED / PAID IN FULL' => '13',
                                                                        'SENT TO COLLECTIONS'=>'97',
                                                                        'DEFAULT' => 'ZA',
                                                                        'INSOLVENT AFTER PURCHASE' => '97',
                                                                        'SETTLED' => '13'
                                                                    }; 
    public static Map<String, String> customerInformationIndicator =  new Map<String, String>{
                                                                    'COMPLETED / PAID IN FULL' => 'H ',
                                                                    'DROPPED NOTIFICATION'=>'P ',
                                                                    'DEFAULT' => '  '
                                                                }; 
                                                                
    public static Map<String, String> specialCommentMapping =  new Map<String, String>{
                                                                    'COMPLETED / PAID IN FULL' => 'B ',
                                                                    'SETTLED' =>'AU',
                                                                    'DEFAULT' => 'B '
                                                                };
    public static Map<String, String> distressedSpecialCommentMapping =  new Map<String, String>{
                                                                    '906000' => 'AC',
                                                                    '907000' =>'AU'
                                                                    
                                                                }; 
    public static Map<String, String> termFrequencyMapping =  new Map<String, String>{
                                                                    'MONTHLY' => 'M',
                                                                    'BI-MONTHLY' =>'L',
                                                                    'QUARTERLY' => 'Q',
                                                                    'DEFAULT' => 'M'
                                                                }; 
    public static Map<String, Decimal> paymentAmountMultiplierMapping =  new Map<String, Decimal>{
                                                                    'M' => 1,
                                                                    'L' => 2,
                                                                    'Q' => 3
                                                                };
    
    // Takes Date instance as parameter and converts to mm-dd-yyyy
    public static string  formatDate_MM_DD_YYYY(Date dateToFormat) {
        String returnValue = '';
        String day = String.valueOf(dateToFormat.day());
        day = day.leftPad(2, '0'); 

        String  month = String.valueOf(dateToFormat.month());
        month = month.leftPad(2, '0'); 
        
        String year = String.valueOf(dateToFormat.year());
        returnValue = month + day + year;
        return returnValue;
    }

    // Check account status and return mapped value for custmor information indicator
    public static String getcustomerInformationIndicator(String customerStage){
        if(customerInformationIndicator.containsKey(customerStage)){
            return customerInformationIndicator.get(customerStage);
        }else{
            return customerInformationIndicator.get('DEFAULT');
        }
    }

    // Check account status and return mapped value
    public static String getAccountStatus(String accountStatus){
        if(accountStatusMapping.containsKey(accountStatus)){
            return accountStatusMapping.get(accountStatus);
        }else{
            return accountStatusMapping.get('DEFAULT');
        }
    }
    
    // Check account status and return mapped value for special comments
    public static String getSpecialComments(String accountStatus){
        if(distressedSpecialCommentMapping.containsKey(accountStatus)){
            return distressedSpecialCommentMapping.get(accountStatus);
        }else{
            return distressedSpecialCommentMapping.get('DEFAULT');
        }
    }
    // Check account status and return mapped value for Distressed special comments
    public static String getDistressedSpecialComments(String accStatus){
        if(specialCommentMapping.containsKey(accStatus)){
            return specialCommentMapping.get(accStatus);
        }
    }
    // Check payment frequency and return mapped value for Term Frequency
    public static String getPaymentFrequency(String paymentFrequency){
        if(termFrequencyMapping.containsKey(paymentFrequency)){
            return termFrequencyMapping.get(paymentFrequency);
        }else{
            return termFrequencyMapping.get('DEFAULT');
        }
    }
    
    // Check payment frequency and return mapped value for Term Frequency
    public static String getCalculatedPaymentAmount(String paymentFrequency, Decimal monthlyPaymentAmount){
        if(paymentAmountMultiplierMapping.containsKey(paymentFrequency)){
            return (''+(monthlyPaymentAmount * paymentAmountMultiplierMapping.get(paymentFrequency)));
        }else{
            return (''+monthlyPaymentAmount);
        }
    }
    
    //This method will accept integers and return string with 0 paddings
    public static String getStringWithZeroPadding(Integer numberCount){
        
        if(numberCount != null) {
            if(numberCount <= 9) {
                return '00000000' + numberCount;
            } 
            else if(numberCount > 9 && numberCount <= 99) {
                return '0000000' + numberCount;
            } 
            else if(numberCount > 99 && numberCount <= 999) {
                return '000000' + numberCount;
            } 
            else if(numberCount > 999 && numberCount <= 9999) {
                return '00000' + numberCount;
            }
            else if(numberCount > 9999) {
                return '0000' + numberCount;
            }
        }
        return null;        
        
    }
    
    public static String getProvinceCode(String province){
        
        if(province == null || province.length() <= 2){
            return Province;
        }
        else{
            return (getProvinceCodeMap().get(province));
        }
    }
    
    public static String getNumberOfPayments(Date firstPaymentDate){
        String StringnumberOfPayments = '000000000000000000000000';
        
        Integer noOfPayments = 0;
        noOfPayments = firstPaymentDate.monthsBetween(System.today());
        if(noOfPayments > 24){
           noOfPayments = 24; 
        }
        StringnumberOfPayments = '';
        for(Integer i = 0; i < noOfPayments; i++){
            StringnumberOfPayments += 'Y';
        }
        
        StringnumberOfPayments = StringnumberOfPayments.rightPad(24, 'B');
        
        return StringnumberOfPayments;
    }
    
    public static Map<String,String> getProvinceCodeMap(){
        
        Map<String,String> provinceCodeMap = new Map<String,String>();                  
          provinceCodeMap.put('Alberta', 'AB');
          provinceCodeMap.put('British Columbia', 'BC');
          provinceCodeMap.put('Manitoba', 'MB');
          provinceCodeMap.put('New Brunswick', 'NB');
          provinceCodeMap.put('Newfoundland and Labrador', 'NL');
          provinceCodeMap.put('Newfoundland', 'NL');
          provinceCodeMap.put('Northwest Territories', 'NT');
          provinceCodeMap.put('Nova Scotia', 'NS');
          provinceCodeMap.put('Nunavut', 'NU');
          provinceCodeMap.put('Ontario', 'ON');
          provinceCodeMap.put('Prince Edward Island', 'PE');
          provinceCodeMap.put('Quebec', 'QC');
          provinceCodeMap.put('Saskatchewan', 'SK');
          provinceCodeMap.put('Yukon', 'YT');
        
          return provinceCodeMap;
    }
}