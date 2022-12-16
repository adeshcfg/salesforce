/**************************************************************************************************
*
*  Class:   
*
*  @description : Utility class for MegaSys
*  @author : A5E Consulting
*  @date : 08/25/2016   

*************************************************************************************************/
public class MegaSysUtilities{
    
    //get custom setting records that contain Username, Password, Clientnumber etc for MegaSys
    private static Loan_ReEngineering__c megaSysCS = Loan_ReEngineering__c.getOrgDefaults();
    
    //get Application record by ID
    public static Application__c getApplicationById(Id applicationId) {
        
        Application__c appln = null;
        
        if(applicationId != null){
            
            appln =[SELECT Id, Name, First_Name__c, Middle_Name__c, Last_Name__c, Alias_Name__c, Birth_Date__c, Home_Owner__c, Gender__c, 
                    Marital_Status__c, Number_of_Dependants__c, Email_Address__c, Monthly_Home_Expense__c, Permanent_Address_PO_Box__c,
                    Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                    Permanent_Address_PostalCode__c, Permanent_Address_Type__c, Cell_Phone__c, Employer_Name__c, Gross_Monthly_Income__c,
                    Payment__c, Occupation__c, Employer_Phone__c, Employer_PO_Box__c, Employer_Street_Number__c, Employer_Street_Name__c,
                    Employer_City__c, Employer_Province__c, Employer_PostalCode__c, Employer_Address_Type__c, Loan_Start_Date__c, Application_Number__c,
                    Interest_Rate__c, Regular_Payment_Amount__c,First_Payment_Amount__c, First_Payment_Date__c, Total_of_Payment__c, Loan_Amount__c,
                    Total_Interest__c, Work_Phone__c, Home_Phone__c,  Months_At_Permanent_Address__c, Years_At_Permanent_Address__c,
                    Number_of_Payments__c, Customer__r.SF_ID__c, CreatedDate, Employment_Months__c, Employment_Years__c, Customer__c,
                    Loan_Process_Type__c, Loan_Type__c, PAP_Bank_Code__c, PAP_Account_Number__c, PAP_Transit_Code__c, Megasys_Loan_Number__c,
                    Application_Fullfillment_Status__c, Monthly_Expenses__c, Disbursement__c, PAP_Information_I_Accept__c, 
                    PAP_Information_I_Accept_DateTime__c, Permanent_Address_Unit_Number__c, Employer_Unit_Number__c, SIN__c
                    from Application__c WHERE Id=:applicationId];
        }
        return appln;
    }
    
    
    //get Product record by ID
    public static Product__c getProductById(Id prodId) {
        
        Product__c prod = null;
        
        if(prodId != null){
            
            prod =[SELECT Id, Name 
                    from Product__c WHERE Id=:prodId];
        }
        return prod;
    }
    
    //Create a product with megaSys Account Number
    /*
    public static Product__c createProdRecord(Application__c app,String megaSysAccNum){
        
        Product__c prod = New Product__c();
        
        //Default Values
        prod.Product_Type__c = 'Direct';
        prod.Product_Status__c = 'New';
        //prod.System_of_Record__c = 'Megasys';
        prod.Times_30_Days_Late__c = 0;
        prod.Times_60_Days_Late__c = 0;
        prod.Times_90_Days_Late__c = 0;
        prod.Funding_Type__c = 'Automated';
        prod.Funding_Status__c = 'Pending';
        //prod.Last_Payment_Status__c = '';
        prod.Payment_Setup_Status__c = 'Automated';        
        prod.Source_System__c = 'Megasys';
        prod.Actual_Date_Funded__c = null;
        prod.Actual_Funded_Amount__c = null;
        //prod.Verification_ID__c = '';
        
        //Various IDs
        //prod.SOR_External_ID__c = megaSysAccNum+'_'+'Megasys';
        prod.Originating_Creditor__c = 'Affirm Financial';  
        //prod.SOR_Account_Number__c = megaSysAccNum;         
        prod.recordTypeId = Utilities.getProductRecordType(prod.Source_System__c);
        
        if(String.isNotBlank(megaSysAccNum)){
            prod.Name = megaSysAccNum;
        }
        
        //Application Id is external Id
        if(String.isNotBlank(app.Application_Number__c)){
            prod.Application_ID__c = app.Application_Number__c;
        }
        
        //Application Record Id
        //prod.Application_Record_ID__c = app.Id;
        
        //Application Lookup
        prod.Application__C = app.id;
        
        //Customer Record
        if(String.isNotBlank(app.Customer__c)){
            prod.Customer__c = app.Customer__c;
        }
        
        //Loan Type
        if(String.isNotBlank(app.Loan_Type__c)){
            prod.Loan_Type__c = app.Loan_Type__c;
        }
        
        if(String.isNotBlank(app.Loan_Process_Type__c)){
            prod.Loan_Process_Type__c = app.Loan_Process_Type__c;
        }
        
        //Various Dates
        if(app.Loan_Start_Date__c != null){
            prod.Open_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.Loan_Start_Date__c != null){
            prod.Current_Balance_Effective_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.Loan_Start_Date__c != null){
            prod.Funding_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.First_Payment_Date__c!= null){
            prod.Payment_Due_Date__c = app.First_Payment_Date__c;
        }
        
        if(app.First_Payment_Date__c!=null){
            prod.First_Payment_Date__c = app.First_Payment_Date__c;
        }
        
        //Various Amounts
        if(app.Loan_Amount__c != null){
            prod.Credit_Limit__c = app.Loan_Amount__c;
            prod.Original_Credit_Amount__c = app.Loan_Amount__c;
        }
        
        if(app.Loan_Amount__c != null){
            prod.Current_Balance__c = app.Loan_Amount__c;
        }
        
        if(app.Loan_Amount__c != null){
            prod.Funding_Amount__c = app.Loan_Amount__c;
        }
        
        if(app.Regular_Payment_Amount__c != null){
            prod.Payment_Amount__c = app.Regular_Payment_Amount__c;
        }
        
        if(app.Regular_Payment_Amount__c !=null){
            prod.Regular_Payment_Amount__c = app.Regular_Payment_Amount__c;
        }
        
        if(app.Disbursement__c != null){
            prod.Disbursement_Amount__c = app.Disbursement__c;
        }
        
        if(app.First_Payment_Amount__c !=null){
            prod.First_Payment_Amount__c = app.First_Payment_Amount__c;
        }
        
        //Various Fee Amounts
        prod.NSF_Fee_Amount_Outstanding__c = 0;
        if(String.isNotBlank(megaSysCS.NSF_Fee_Amount__c)){
            prod.NSF_Fee_Amount__c = Integer.valueof(megaSysCS.NSF_Fee_Amount__c);
        }
        
        prod.Late_Fee_Amount_Outstanding__c = 0; 
        
        //Interest Dates
        if(app.Interest_Rate__c !=null){
            prod.Interest_Rate__c = app.Interest_Rate__c;
        }
        
        //No of Payments
        if(app.Number_of_Payments__c != null){
            prod.Term__c = app.Number_of_Payments__c;
        }
        
        //PAP Information
        if(app.PAP_Account_Number__c != null){
            prod.PAP_Account_Number__c = app.PAP_Account_Number__c;
        }
        
        if(app.PAP_Bank_Code__c != null){
            prod.PAP_Bank_Code__c = app.PAP_Bank_Code__c;
        }
        
        if(app.PAP_Transit_Code__c != null){
            prod.PAP_Transit_Code__c = app.PAP_Transit_Code__c;
        }
        
        if(app.PAP_Information_I_Accept_DateTime__c != null){
            prod.PAP_Information_Accepted_Date__c = app.PAP_Information_I_Accept_DateTime__c;
        }
        
        if(app.PAP_Information_I_Accept__c != null){
            prod.PAP_Information_Accepted__c = app.PAP_Information_I_Accept__c;
        }
        
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;    
        ProductTriggerHandler.runProductTrigger = true; 
        
        return prod;         
    }
    */
    
    //Create a loan product from term loan application
    public static Product__c createProdRecord(Application__c app){
        
        Product__c prod = New Product__c();
        
        //Product Name
        prod.Name = app.Name;
        
        //Default Values
        prod.Product_Type__c = 'Direct';
        prod.Product_Status__c = 'New';
        prod.Times_30_Days_Late__c = 0;
        prod.Times_60_Days_Late__c = 0;
        prod.Times_90_Days_Late__c = 0;
        prod.Funding_Type__c = 'Automated';
       // prod.Funding_Status__c = 'Pending';
        prod.Payment_Setup_Status__c = 'Automated';        
        prod.Source_System__c = 'Megasys';
        prod.Actual_Date_Funded__c = null;
        prod.Actual_Funded_Amount__c = null;
        
        //Various IDs
        prod.Originating_Creditor__c = 'Affirm Financial';  
        prod.recordTypeId = Utilities.getProductRecordType(prod.Source_System__c);
        
        //Application Id is external Id
        if(String.isNotBlank(app.Application_Number__c)){
            prod.Application_ID__c = app.Application_Number__c;
        }
        
        //Application Lookup
        prod.Application__C = app.id;
        
        //Customer Record
        prod.Customer__c = app.Customer__c;
        
        //Loan Type
        if(String.isNotBlank(app.Loan_Type__c)){
            prod.Loan_Type__c = app.Loan_Type__c;
        }
        
        if(String.isNotBlank(app.Loan_Process_Type__c)){
            prod.Loan_Process_Type__c = app.Loan_Process_Type__c;
        }
        
        //Various Dates
        if(app.Loan_Start_Date__c != null){
            prod.Open_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.Loan_Start_Date__c != null){
            prod.Current_Balance_Effective_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.Loan_Start_Date__c != null){
            prod.Funding_Date__c = app.Loan_Start_Date__c;
        }
        
        if(app.First_Payment_Date__c!= null){
            prod.Payment_Due_Date__c = app.First_Payment_Date__c;
        }
        
        if(app.First_Payment_Date__c!=null){
            prod.First_Payment_Date__c = app.First_Payment_Date__c;
        }
        
        //Various Amounts
        if(app.Loan_Amount__c != null){
            prod.Credit_Limit__c = app.Loan_Amount__c;
            prod.Original_Credit_Amount__c = app.Loan_Amount__c;
        }
        
        if(app.Loan_Amount__c != null){
            prod.Current_Balance__c = app.Loan_Amount__c;
        }
        
        if(app.Loan_Amount__c != null){
            prod.Funding_Amount__c = app.Loan_Amount__c;
        }
        
        if(app.Regular_Payment_Amount__c != null){
            prod.Payment_Amount__c = app.Regular_Payment_Amount__c;
        }
        
        if(app.Regular_Payment_Amount__c !=null){
            prod.Regular_Payment_Amount__c = app.Regular_Payment_Amount__c;
        }
        
        if(app.Disbursement__c != null){
            prod.Disbursement_Amount__c = app.Disbursement__c;
        }
        
        if(app.First_Payment_Amount__c !=null){
            prod.First_Payment_Amount__c = app.First_Payment_Amount__c;
        }
        
        //Various Fee Amounts
        prod.NSF_Fee_Amount_Outstanding__c = 0;
        if(String.isNotBlank(megaSysCS.NSF_Fee_Amount__c)){
            prod.NSF_Fee_Amount__c = Integer.valueof(megaSysCS.NSF_Fee_Amount__c);
        }
        
        prod.Late_Fee_Amount_Outstanding__c = 0; 
        
        //Interest Dates
        if(app.Interest_Rate__c !=null){
            prod.Interest_Rate__c = app.Interest_Rate__c;
        }
        
        //No of Payments
        if(app.Number_of_Payments__c != null){
            prod.Term__c = app.Number_of_Payments__c;
        }
        
        //PAP Information
        if(app.PAP_Account_Number__c != null){
            prod.PAP_Account_Number__c = app.PAP_Account_Number__c;
        }
        
        if(app.PAP_Bank_Code__c != null){
            prod.PAP_Bank_Code__c = app.PAP_Bank_Code__c;
        }
        
        if(app.PAP_Transit_Code__c != null){
            prod.PAP_Transit_Code__c = app.PAP_Transit_Code__c;
        }
        
        if(app.PAP_Information_I_Accept_DateTime__c != null){
            prod.PAP_Information_Accepted_Date__c = app.PAP_Information_I_Accept_DateTime__c;
        }
        
        if(app.PAP_Information_I_Accept__c != null){
            prod.PAP_Information_Accepted__c = app.PAP_Information_I_Accept__c;
        }
        
        //Additional fields to be mapped
        prod.First_Name__c = app.First_Name__c;
		prod.Last_Name__c =	app.Last_Name__c ;
		prod.Date_of_Birth__c =	app.Birth_Date__c;
		
		prod.Address_Line1__c = addressLineOne(app);
		prod.Address_Line2__c = addressLineTwo(app);
		
		prod.City__c = app.Permanent_Address_City__c;
		prod.Zip_Code__c = app.Permanent_Address_PostalCode__c; 
		//prod.State__c =	app.Permanent_Address_Province__c; 
		prod.Phone_Home__c = app.Home_Phone__c; 
		prod.Phone_Work__c = app.Work_Phone__c; 
		prod.Phone_Other__c = app.Cell_Phone__c;
				
        ProductTriggerHandler.runProductTrigger = false;
        insert prod;    
        ProductTriggerHandler.runProductTrigger = true;   
        
        return prod; 
    }
    
    //Update product name with megaSys Account Number
    public static void updateProdRecord(Product__c prod,String megaSysAccNum){
    	
        prod.name = megaSysAccNum;
    	
    	ProductTriggerHandler.runProductTrigger = false;
    	update prod;     	
    	ProductTriggerHandler.runProductTrigger = true;
    }
    
    //Update Application
    public static void updateApplication(Application__c app){
        app.Application_Fullfillment_Status__c = 'Completed';
        app.Decision__c = 'Completed';
        app.Application_Status__c = 'Completed - Loan';
        update app;
    }
    
    //Update MegaSys Number on Application
    public static void updateMSNumberOnApplication(Application__c app, String megaSysAccNum){
    	
    	/*
    	Application__c dbApp = [Select id from Application__c where id=:app.Id];
    	dbApp.Megasys_Loan_Number__c = megaSysAccNum;
    	ApplicationTriggerHandler.runApplicationLoadTrigger = false;
    	update dbApp;
    	ApplicationTriggerHandler.runApplicationLoadTrigger = true;
    	*/
    	
    	app.Megasys_Loan_Number__c = megaSysAccNum;
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update app;    
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;        
    }
    
    //Mapping for Provice Code
    public static Map<String, String> getClassNumber(){
        
        Map<String, String> mapList = New Map<String, String>();
        mapList.put('AB','15');
        mapList.put('BC','25');
        mapList.put('MB','35');
        mapList.put('NB','45');
        mapList.put('NL','55');
        mapList.put('NS','65');
        mapList.put('NT','75');
        mapList.put('NU','85');
        mapList.put('ON','95');
        mapList.put('PE','105');
        mapList.put('SK','125');
        mapList.put('YT','135');
        mapList.put('','');
        return mapList;
    }
    
    //return AddressLine1 for Permanent Address and Employer Address
    public static String getAddressLine1(String unitNumber, String streetNumber, String streetName){
        
        //If String is NULL, set it blank
        if(String.isBlank(unitNumber)){
            unitNumber = '';
        }
        
        if(String.isBlank(streetNumber)){
            streetNumber = '';
        }
                
        if(String.isBlank(streetName)){
            streetName = '';
        }
        
        if(String.isNotBlank(unitNumber))
        {
            if(unitNumber.contains(' ')){
               return  streetNumber+' '+streetName+' '+unitNumber;
            }
            else{
                if(String.isNotBlank(streetNumber) || String.isNotBlank(streetName)){
                    return unitNumber+'-'+streetNumber+' '+streetName;
                }
                else{
                    return unitNumber;
                }
            }
        }
        else{
            return streetNumber+' '+streetName;
        }    
    }

    //return AddressLine2 for Permanent Address and Employer Address
    public static String getAddressLine2(String poBox){
        
        if(String.isNotBlank(poBox)){
            return poBox;
        }
        else{
            return '';
        }
    }
    
    //Return address line 1 
    private static string addressLineOne(Application__c application){
    	
    	String unitNumber  = replaceNullWithBlank(application.Permanent_Address_Unit_Number__c);
    	String streetNumber  = replaceNullWithBlank(application.Permanent_Address_Street_Number__c);
    	String streetName  = replaceNullWithBlank(application.Permanent_Address_Street_Name__c);
        
        if(String.isNotBlank(unitNumber)){        
            return (unitNumber+'-'+streetNumber+' '+streetName);
        }
        else{        
            return (streetNumber+' '+streetName);
        }
        
    }
    
    //Return address line 2 
    private static string addressLineTwo(Application__c application){
    
        if(String.isNotBlank(application.Permanent_Address_PO_Box__c)){
            return (application.Permanent_Address_PO_Box__c);
        }
        else{        
            return '';
        }
    }
    
    //Replace null with blank
    private static String replaceNullWithBlank(String str){
    
        if(str != null){
            return str;
        }
        else{
            return '';
        }
    }
    
}