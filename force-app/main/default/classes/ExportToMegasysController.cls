/**************************************************************************************************
*
*  Class:   
*
*  @description : ExportToMegasysController for Validate Application.
*  @author : A5E Consulting
*  @date : 08/25/2016   

*************************************************************************************************/
public class ExportToMegasysController{
    
    public Boolean intial{get;set;}
    public Boolean showError{get;set;}
    public string appId{get;set;}
    public Boolean isSuccess{get;set;}
    public String megaSysNumber{get;set;}
    public String megaSysNumFromApp{get;set;}
    public String errorMsg{get;set;}
    public Boolean showSuccess{get;set;}
    public String successMsg{get;set;}
    
    Application__c appln;
    
    //variable constant for MegaSys Fields length validations
    private final Integer LIMIT_MS_FIRST_NAME = 50;
    private final Integer LIMIT_MS_MIDDLE_NAME = 50;
    private final Integer LIMIT_MS_LAST_NAME = 50;
    private final Integer LIMIT_MS_AKA_NAME = 50;
    private final Integer LIMIT_MS_SOCIALSECURITYNUMBER = 20;
    private final Integer LIMIT_MS_PERMANENT_ADDRESSLINE1 = 50; 
    private final Integer LIMIT_MS_PERMANENT_ADDRESSLINE2 = 50;
    private final Integer LIMIT_MS_PERMANENT_CITY = 50;
    private final Integer LIMIT_MS_EMPLOYER_NAME = 50;
    private final Integer LIMIT_MS_EMPLOYER_ADDRESSLINE1 = 50;
    private final Integer LIMIT_MS_EMPLOYER_ADDRESSLINE2 = 50;
    private final Integer LIMIT_MS_EMPLOYER_CITY = 50;
    
    
    public ExportToMegasysController(){
        
        String appStatus;
        
        //get the Application Id
        appId = ApexPages.currentPage().getParameters().get('id');
        
        //Fetch Application records
        appln = MegaSysUtilities.getApplicationById(appId);
        showSuccess = false;
        successMsg = '';
        showError = false;
        
        if(appln.Loan_Type__c.equalsIgnoreCase('Affirm Financial Term Loan')){
            
            //stored all error Message
            errorMsg = '';
            
            //get the Application Fullfillment Status
            appStatus = appln.Application_Fullfillment_Status__c;
            
            //get the MegaSys Loan Number if exist in records
            megaSysNumFromApp = appln.Megasys_Loan_Number__c;
            
            /*if(String.isNotBlank(appStatus) && appStatus.equalsIgnoreCase('Ready For Export') && String.isBlank(megaSysNumFromApp)){
				showError = true;
			}else{
				showError = false;
			}*/    
            //Validations for Application is not in proper status validations
            if(String.isBlank(appStatus)){
                showError = true;
                errorMsg = 'Your application fulfillment status is blank, you cannot complete Export to Megasys';
            }else if(String.isNotBlank(megaSysNumFromApp)){
                showError = true;
                errorMsg = 'Product already exists in MegaSys and MegaSys Loan Number is ' + megaSysNumFromApp;
            }else if('Ready For Export' != appln.Application_Fullfillment_Status__c){
                showError = true;
                errorMsg = 'The Application is not in correct Fullfillment Status, you cannot continue with Export to Megasys';
            }else if('Completed' == appln.Application_Fullfillment_Status__c){
                showError = true;
                errorMsg = 'The Application Fulfillment Status is Completed, you cannot continue with Export to Megasys';
            }
            else{
                
                //captured required validation Messages    
                errorMsg = '';
                
                //Missing Fields validations 
                if(String.isBlank(appln.First_Name__c)){
                    errorMsg += 'First Name '+''+'<br/>';
                }
                
                if(String.isBlank(appln.Last_Name__c)){
                    errorMsg += 'Last Name '+''+'<br/>';
                }
                /*
                if(appln.Birth_Date__c == null){
                    errorMsg += 'Birth Date '+''+'<br/>';
                }
                
                if(String.isBlank(appln.Gender__c)){
                    errorMsg += 'Gender '+''+'<br/>';
                }
                
                if(String.isBlank(appln.Marital_Status__c)){
                    errorMsg += 'Marital Status '+''+'<br/>';
                }
                
                if(String.isBlank(appln.Number_of_Dependants__c)){
                    errorMsg += 'Number of Dependants  '+''+'<br/>';
                }
                */
                if(appln.Home_phone__c == null && appln.work_Phone__c==null && appln.cell_Phone__c==null){
                    errorMsg += 'Home Phone or Cell Phone or Work Phone'+''+'<br/>';
                }
                /*
                if(String.isBlank(appln.Permanent_Address_Type__c)){
                    errorMsg += 'Permanent Address Type'+''+'<br/>';
                }
                */
                
                if(String.isBlank(appln.Home_Owner__c)){
                    errorMsg += 'Home Owner'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Permanent_Address_Street_Number__c)){
                    errorMsg += 'Permanent Address Street Number'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Permanent_Address_Street_Name__c)){
                    errorMsg += 'Permanent Address Street Name'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Permanent_Address_Province__c)){
                    errorMsg += 'Permanent Address Province'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Permanent_Address_PostalCode__c)){
                    errorMsg += 'Permanent Address PostalCode'+''+'<br/>';
                }
                
                if(appln.Months_At_Permanent_Address__c == null){
                    errorMsg += 'Months At Permanent Address '+''+'<br/>';
                }
                
                if(appln.Years_At_Permanent_Address__c == null){
                    errorMsg += 'Years At Permanent Address'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Employer_Name__c)){
                    errorMsg += 'Employer Name'+''+'<br/>';
                }
                /*
                if(String.isBlank(appln.Employer_Province__c)){
                    errorMsg += 'Employer Province'+''+'<br/>';
                }
                
                if(String.isBlank(appln.Employer_Address_Type__c)){
                    errorMsg += 'Employer Address Type'+''+'<br/>';
                }
                */
                if(appln.Employment_Years__c == null){
                    errorMsg += 'Employment Year'+''+'<br/>';
                }
                
                if(appln.Employment_Months__c == null){
                    errorMsg += 'Employment Months'+''+'<br/>';
                }
                /*
                if(appln.Gross_Monthly_Income__c == null){
                    errorMsg += 'Gross Monthly Income'+''+'<br/>';
                }
                
                if(appln.Monthly_Expenses__c == null){
                    errorMsg += 'Monthly Expenses'+''+'<br/>';
                }
                */
                if(appln.Payment__c == null){
                    errorMsg += 'Payment Frequency'+''+'<br/>';
                }
                
                if(appln.Loan_Start_Date__c == null){
                    errorMsg += 'Loan Start Date'+''+'<br/>';
                }
                
                if(appln.First_Payment_Date__c == null){
                    errorMsg += 'First Payment Date '+''+'<br/>';
                }
                
                if(appln.Number_of_Payments__c == null){
                    errorMsg += 'Number of Payments'+''+'<br/>';
                }
                
                if(appln.First_Payment_Amount__c == null){
                    errorMsg += 'First Payment Amount'+''+'<br/>';
                }
                
                if(appln.Regular_Payment_Amount__c == null){
                    errorMsg += 'Regular Payment Amount'+''+'<br/>';
                }
                
                if(appln.Total_of_Payment__c == null){
                    errorMsg += 'Total of Payment'+''+'<br/>';
                }
                
                if(appln.Loan_Amount__c == null){
                    errorMsg += 'Loan Amount'+''+'<br/>';
                }
                
                if(appln.Interest_Rate__c == null){
                    errorMsg += 'Interest Rate'+''+'<br/>';
                }
                
                if(String.isNotBlank(errorMsg)){
                    showError = true;
                    String str = 'Below Fields are Required,'+'<br/>'+ errorMsg +'Please fill up above Fields and proceed further with MegaSys.'+'<br/><br/>';
                    errorMsg = str;
                }
                
                //captured MegaSys Length Limit validation Messages
                String errorLimitMSMsg = '';
                
                //Fields length validations
                //fetch AddressLine 1 & AddressLine 2 for Permanent Address
                String peraddressLine1 = MegaSysUtilities.getAddressLine1(appln.Permanent_Address_Unit_Number__c, appln.Permanent_Address_Street_Number__c ,appln.Permanent_Address_Street_Name__c );
                String peraddressLine2 = MegaSysUtilities.getAddressLine2(appln.Permanent_Address_PO_BOX__c);
                
                //fetch AddressLine 1 & AddressLine 2 for Employer Address
                String empaddressLine1 = MegaSysUtilities.getAddressLine1(appln.Employer_Unit_Number__c, appln.Employer_Street_Number__c ,appln.Employer_Street_Name__c );
                String empaddressLine2 = MegaSysUtilities.getAddressLine2(appln.Employer_PO_BOX__c);
                
                if(String.isNotBlank(appln.First_Name__c) && appln.First_Name__c.length() > LIMIT_MS_FIRST_NAME){
                    errorLimitMSMsg += 'First Name - '+ LIMIT_MS_FIRST_NAME + '<br/>';
                }
                
                if(String.isNotBlank(appln.Middle_Name__c) && appln.Middle_Name__c.length() > LIMIT_MS_MIDDLE_NAME){
                    errorLimitMSMsg += 'Middle Name - '+ LIMIT_MS_MIDDLE_NAME + '<br/>';
                }
                
                if(String.isNotBlank(appln.Last_Name__c) && appln.Last_Name__c.length() > LIMIT_MS_LAST_NAME){
                    errorLimitMSMsg += 'Last Name - '+ LIMIT_MS_LAST_NAME + '<br/>';
                }
                
                if(String.isNotBlank(appln.Alias_Name__c) && appln.Alias_Name__c.length() > LIMIT_MS_AKA_NAME){
                    errorLimitMSMsg  += 'Alias Name - '+ LIMIT_MS_AKA_NAME + '<br/>';
                }
                
                if(String.isNotBlank(appln.SIN__c) && appln.SIN__c.length() > LIMIT_MS_SOCIALSECURITYNUMBER){
                    errorLimitMSMsg += 'SIN - '+ LIMIT_MS_SOCIALSECURITYNUMBER + '<br/>';
                }
                
                //Permenant Address field length limit validation
                
                if(String.isNotBlank(peraddressLine1) && peraddressLine1.length()> LIMIT_MS_PERMANENT_ADDRESSLINE1 ){
                    errorLimitMSMsg += 'Permanent AddressLine 1 '+' ( '+ peraddressLine1 +' )' + ' - ' + LIMIT_MS_PERMANENT_ADDRESSLINE1 +'<br/>'; 
                }
                
                if(String.isNotBlank(peraddressLine2) && peraddressLine2.length()> LIMIT_MS_PERMANENT_ADDRESSLINE1 ){
                    errorLimitMSMsg += 'Permanent AddressLine 2 ' + '( '+ peraddressLine2 +' )' + ' - ' + LIMIT_MS_PERMANENT_ADDRESSLINE2 +'<br/>'; 
                }
                
                if(String.isNotBlank(appln.Permanent_Address_City__c) && appln.Permanent_Address_City__c.length()>LIMIT_MS_PERMANENT_CITY){
                    errorLimitMSMsg += 'Permanent Address City - '+ LIMIT_MS_PERMANENT_CITY +'<br/>';
                }
                //Employer Name field length limit validation
                
                if(String.isNotBlank(appln.Employer_Name__c) && appln.Employer_Name__c.length() > LIMIT_MS_EMPLOYER_NAME){
                    errorLimitMSMsg += 'Employer Name - '+ LIMIT_MS_EMPLOYER_NAME+'<br/>';
                }
                //Employer Address field length limit validation
                
                if(String.isNotBlank(empaddressLine1) && empaddressLine1.length()> LIMIT_MS_EMPLOYER_ADDRESSLINE1 ){
                    errorLimitMSMsg += 'Employer AddressLine 1' + '( '+empaddressLine1+' )' + ' - ' + LIMIT_MS_EMPLOYER_ADDRESSLINE1 +'<br/>'; 
                }
                
                
                if(String.isNotBlank(empaddressLine2) && empaddressLine2.length()> LIMIT_MS_EMPLOYER_ADDRESSLINE1 ){
                    errorLimitMSMsg += 'Employer AddressLine 2 ' + '( '+empaddressLine2+' )' + ' - ' + LIMIT_MS_EMPLOYER_ADDRESSLINE2 + '<br/>'; 
                }
                
                if(String.isNotBlank(appln.Employer_City__c) && appln.Employer_City__c.length()>LIMIT_MS_EMPLOYER_CITY){
                    errorLimitMSMsg += 'Employer City - ' + LIMIT_MS_EMPLOYER_CITY + '<br/>';
                }

                if(String.isNotBlank(errorLimitMSMsg)){
                    showError = true;
                    String str = 'Below Fields have exceeded corresponding MegaSys Length Limits,'+'<br/>'+ errorLimitMSMsg +'Please Correct the Fields and proceed further with MegaSys.'+'<br/><br/>';
                    errorLimitMSMsg = str;
                }
                
                if(String.isBlank(errorMsg)){
                   errorMsg = errorLimitMSMsg ;
                }
                else
                {
                   errorMsg =errorMsg +'<br/>'+ errorLimitMSMsg ;
                }
            }
        }
        else{
            showError = true;
            errorMsg = 'This Application is for Credit Card, you cannot continue with MegaSys Export.';
        }
    }
    
    //execute MegaSys API
    public void callMegasys(){
        
        if(appln.Loan_Type__c.equalsIgnoreCase('Affirm Financial Term Loan')){
            isSuccess = false;
            megaSysNumber = '';
            if(showError == false){
                
                //call Megasys web service
                isSuccess = MegasysWSUtil.execute(appln);
                
                /*
                if(String.isNotBlank(MegasysWSUtil.megaSysAccNum)){
                    megaSysNumber = MegasysWSUtil.megaSysAccNum;
                }
                */
                
                /*
                if(isSuccess && String.isNotBlank(megaSysNumber)){
                    showSuccess = true;
                    successMsg = 'Application sent to MegaSys successfully.<br/>Product is Created and MegaSys Loan Number is ' + megaSysNumber;
                }else if(!isSuccess && String.isNotBlank(megaSysNumber)){
                    showSuccess = true;
                    successMsg = 'An unexpected error has occurred. Please Contact your Administrator.<br/>Product is not Created and MegaSys Loan Number is ' + megaSysNumber;
                }else if(!isSuccess && String.isBlank(megaSysNumber)){
                    showSuccess = true;
                    successMsg = 'An unexpected error has occurred. Please Contact your Administrator.';
                }
                */
                
                if(isSuccess){
                	showSuccess = true;
                	successMsg = 'Application will be sent to MegaSys shortly.';
                }
                else{
                	showSuccess = true;
                	successMsg = 'An unexpected error has occurred. Please Contact your Administrator.';
                }
            }
        }
    }
}