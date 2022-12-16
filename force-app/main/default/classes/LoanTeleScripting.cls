public class LoanTeleScripting{
    
    Application__c app;
    String appId;
    private static Loan_ReEngineering__c loanDocs = Loan_ReEngineering__c.getOrgDefaults();
    private List<String> args = new String[]{'0','number','###,###,##0.00'};
    
    public Boolean manitobaScript{get;set;}
    public Boolean nonManitobaScript{get;set;}
    
    public string teleScriptString{get;set;}
    
    public LoanTeleScripting(){
        
        appId = Apexpages.currentPage().getParameters().get('id');
        
        if(appId != null){
            app = [Select id, name, Customer__c, Customer__r.name,  First_Name__c, Middle_Name__c, Last_Name__c,
                    Permanent_Address_Street_Number__c, Permanent_Address_Street_Name__c, First_Payment_Amount__c, 
                    Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, Pay_Day__c, 
                    Permanent_Address_PostalCode__c, First_Payment_Date__c, Interest_Rate__c, Home_Phone__c, Birth_Date__c,
                    Megasys_Loan_Number__C, Number_of_Payments__c, Loan_Amount__c,  Regular_Payment_Amount__c,
                    Email_Address__c, Loan_Start_Date__c, Total_of_Payment__c, Total_Interest__c
                    FROM Application__c where id=: appId];
            
            if(app.Permanent_Address_Province__c == 'MB'){
                generateManitobaLoanTeleScript();
            }else{
                generateGenericLoanTeleScript();
            }
            
        }
    }
    
    public void generateGenericLoanTeleScript(){
        List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Generic_Loan_Telescript'];
        String tempScript = '';
        tempScript = emailTemp[0].HtmlValue;
        
        if(app !=null   &&  tempScript.contains('{Customer Name}') && app.Customer__r.name != null   ){
            tempScript = tempScript.replace('{Customer Name}',app.Customer__r.name);
        }
        else
        {    if(tempScript.contains('{Customer Name}'))
            tempScript = tempScript.replace('{Customer Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{AFI Number}') && app.name != null   ){
            tempScript = tempScript.replace('{AFI Number}',app.name);
        }
        else
        {    if(tempScript.contains('{AFI Number}'))
            tempScript = tempScript.replace('{AFI Number}','');
        }
        
        if(app !=null   &&  tempScript.contains('{First Name}') && app.First_Name__c != null   ){
            tempScript = tempScript.replace('{First Name}',app.First_Name__c);
        }
        else
        {    if(tempScript.contains('{First Name}'))
            tempScript = tempScript.replace('{First Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{Middle Name}') && app.Middle_Name__c != null   ){
            tempScript = tempScript.replace('{Middle Name}',app.Middle_Name__c);
        }
        else
        {    if(tempScript.contains('{Middle Name}'))
            tempScript = tempScript.replace('{Middle Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{Last Name}') && app.Last_Name__c != null   ){
            tempScript = tempScript.replace('{Last Name}',app.Last_Name__c);
        }
        else
        {    if(tempScript.contains('{Last Name}'))
            tempScript = tempScript.replace('{Last Name}','');
        }
        
        string address = app.Permanent_Address_Street_Number__c == null ? '' : app.Permanent_Address_Street_Number__c;
        address += app.Permanent_Address_Street_Name__c == null ? '' : ' ' + app.Permanent_Address_Street_Name__c;
        address += app.Permanent_Address_Unit_Number__c == null ? '' : ' ' + app.Permanent_Address_Unit_Number__c;
        if(app !=null   &&  tempScript.contains('{Address}') && address !=null ){
            tempScript = tempScript.replace('{Address}',address);
        }
        else
        {    if(tempScript.contains('{Address}'))
            tempScript = tempScript.replace('{Address}','');
        }
        
        if(app!= null && app.Permanent_Address_City__c !=null  &&  tempScript.contains('{City}') ){
            tempScript = tempScript.replace('{City}',app.Permanent_Address_City__c);
        }
        else{
            if(tempScript.contains('{City}'))
                tempScript = tempScript.replace('{City}','');
        }
        
        if(app != null && app.Permanent_Address_Province__c !=null  &&  tempScript.contains('{Province}') ){
            tempScript = tempScript.replace('{Province}',app.Permanent_Address_Province__c);
        }
        else{
            if( tempScript.contains('{Province}'))
                tempScript = tempScript.replace('{Province}','');
        }
        
        if(app != null && app.Permanent_Address_PostalCode__c !=null  &&  tempScript.contains('{Postal Code}')){
            tempScript = tempScript.replace('{Postal Code}',app.Permanent_Address_PostalCode__c);
        }
        else{
            if( tempScript.contains('{Postal Code}')){
                tempScript = tempScript.replace('{Postal Code}',''); 
            }
        }
        
        if(app !=null   &&  tempScript.contains('{HomeNumber}') && app.Home_Phone__c != null   ){
            tempScript = tempScript.replace('{HomeNumber}',app.Home_Phone__c);
        }
        else
        {    if(tempScript.contains('{HomeNumber}'))
            tempScript = tempScript.replace('{HomeNumber}','');
        }
        
        //{BOD}
        if(app !=null   &&  tempScript.contains('{BOD}') && app.Birth_Date__c != null   ){
            tempScript = tempScript.replace('{BOD}', convertDate(app.Birth_Date__c));
        }
        else
        {    if(tempScript.contains('{BOD}'))
            tempScript = tempScript.replace('{BOD}','');
        }
        
        //emailID
        if(app !=null   &&  tempScript.contains('{emailID}') && app.Email_Address__c != null   ){
            tempScript = tempScript.replace('{emailID}',app.Email_Address__c);
        }
        else
        {    if(tempScript.contains('{emailID}'))
            tempScript = tempScript.replace('{emailID}','');
        }
        
        //loanAmount
        if(app !=null   &&  tempScript.contains('{loanAmount}') && app.Loan_Amount__c != null   ){
            tempScript = tempScript.replace('{loanAmount}',currency(''+app.Loan_Amount__c));
        }
        else
        {    if(tempScript.contains('{loanAmount}'))
            tempScript = tempScript.replace('{loanAmount}','');
        }
        
        //InterestRate
        if(app !=null   &&  tempScript.contains('{InterestRate}') && app.Interest_Rate__c!= null   ){
            tempScript = tempScript.replace('{InterestRate}', currency(''+app.Interest_Rate__c));
        }
        else
        {    if(tempScript.contains('{InterestRate}'))
            tempScript = tempScript.replace('{InterestRate}','');
        }
        
        //Term
        if(app !=null   &&  tempScript.contains('{Term}') && app.Number_of_Payments__c != null   ){
            tempScript = tempScript.replace('{Term}',string.valueOf(app.Number_of_Payments__c));
        }
        else
        {    if(tempScript.contains('{Term}'))
            tempScript = tempScript.replace('{Term}','');
        }
        
        //LoanStartDate
        if(app !=null   &&  tempScript.contains('{LoanStartDate}') && app.Loan_Start_Date__c!= null ){
            tempScript = tempScript.replace('{LoanStartDate}',convertDate(app.Loan_Start_Date__c));
        }
        else
        {    if(tempScript.contains('{LoanStartDate}'))
            tempScript = tempScript.replace('{LoanStartDate}','');
        }
        
        //RegularPayment
        if(app !=null   &&  tempScript.contains('{RegularPayment}') && app.Regular_Payment_Amount__c!= null ){
            tempScript = tempScript.replace('{RegularPayment}',currency(''+ app.Regular_Payment_Amount__c));
        }
        else
        {    if(tempScript.contains('{RegularPayment}'))
            tempScript = tempScript.replace('{RegularPayment}','');
        }
        
        //FirstPayment
        if(app !=null   &&  tempScript.contains('{FirstPayment}') && app.First_Payment_Amount__c!= null ){
            tempScript = tempScript.replace('{FirstPayment}',currency(''+ app.First_Payment_Amount__c));
        }
        else
        {    if(tempScript.contains('{FirstPayment}'))
            tempScript = tempScript.replace('{FirstPayment}','');
        }
        
        //PayDay
        if(app !=null   &&  tempScript.contains('{PayDay}') && app.Pay_Day__c!= null ){
            tempScript = tempScript.replace('{PayDay}', String.valueOf(app.Pay_Day__c));
        }
        else
        {    if(tempScript.contains('{PayDay}'))
            tempScript = tempScript.replace('{PayDay}','');
        }
        
        //FirstPaymentDate
        if(app !=null   &&  tempScript.contains('{FirstPaymentDate}') && app.First_Payment_Date__c!= null   ){
            tempScript = tempScript.replace('{FirstPaymentDate}',convertDate(app.First_Payment_Date__c));
        }
        else
        {    if(tempScript.contains('{FirstPaymentDate}'))
            tempScript = tempScript.replace('{FirstPaymentDate}','');
        }
        
        //TotalPayment
        if(app !=null   &&  tempScript.contains('{TotalPayment}') && app.Total_of_Payment__c!= null   ){
            tempScript = tempScript.replace('{TotalPayment}',currency(''+ app.Total_of_Payment__c));
        }
        else
        {    if(tempScript.contains('{TotalPayment}'))
            tempScript = tempScript.replace('{TotalPayment}','');
        }
        
        //
        if(app != null && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  tempScript.contains('{NSFFee}') ){
            tempScript = tempScript.replace('{NSFFee}',currency(''+loanDocs.NSF_Fee_Amount__c));
        }
        else{
            if(tempScript.contains('{NSFFee}'))
                tempScript = tempScript.replace('{NSFFee}','');
        }
        
        teleScriptString = tempScript;
    }
    
    public void generateManitobaLoanTeleScript(){
        List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Manitoba_Loan_Tele_Script_document'];
        String tempScript = '';
        tempScript = emailTemp[0].HtmlValue;
        
        if(app !=null   &&  tempScript.contains('{Customer Name}') && app.Customer__r.name != null   ){
            tempScript = tempScript.replace('{Customer Name}',app.Customer__r.name);
        }
        else
        {    if(tempScript.contains('{Customer Name}'))
            tempScript = tempScript.replace('{Customer Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{AFI Number}') && app.name != null   ){
            tempScript = tempScript.replace('{AFI Number}',app.name);
        }
        else
        {    if(tempScript.contains('{AFI Number}'))
            tempScript = tempScript.replace('{AFI Number}','');
        }
        
        if(app !=null   &&  tempScript.contains('{First Name}') && app.First_Name__c != null   ){
            tempScript = tempScript.replace('{First Name}',app.First_Name__c);
        }
        else
        {    if(tempScript.contains('{First Name}'))
            tempScript = tempScript.replace('{First Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{Middle Name}') && app.Middle_Name__c != null   ){
            tempScript = tempScript.replace('{Middle Name}',app.Middle_Name__c);
        }
        else
        {    if(tempScript.contains('{Middle Name}'))
            tempScript = tempScript.replace('{Middle Name}','');
        }
        
        if(app !=null   &&  tempScript.contains('{Last Name}') && app.Last_Name__c != null   ){
            tempScript = tempScript.replace('{Last Name}',app.Last_Name__c);
        }
        else
        {    if(tempScript.contains('{Last Name}'))
            tempScript = tempScript.replace('{Last Name}','');
        }
        
        string address = app.Permanent_Address_Street_Number__c == null ? '' : app.Permanent_Address_Street_Number__c;
        address += app.Permanent_Address_Street_Name__c == null ? '' : ' ' + app.Permanent_Address_Street_Name__c;
        address += app.Permanent_Address_Unit_Number__c == null ? '' : ' ' + app.Permanent_Address_Unit_Number__c;
        if(app !=null   &&  tempScript.contains('{Address}') && address !=null ){
            tempScript = tempScript.replace('{Address}',address);
        }
        else
        {    if(tempScript.contains('{Address}'))
            tempScript = tempScript.replace('{Address}','');
        }
        
        if(app!= null && app.Permanent_Address_City__c !=null  &&  tempScript.contains('{City}') ){
            tempScript = tempScript.replace('{City}',app.Permanent_Address_City__c);
        }
        else{
            if(tempScript.contains('{City}'))
                tempScript = tempScript.replace('{City}','');
        }
        
        if(app != null && app.Permanent_Address_Province__c !=null  &&  tempScript.contains('{Province}') ){
            tempScript = tempScript.replace('{Province}',app.Permanent_Address_Province__c);
        }
        else{
            if( tempScript.contains('{Province}'))
                tempScript = tempScript.replace('{Province}','');
        }
        
        if(app != null && app.Permanent_Address_PostalCode__c !=null  &&  tempScript.contains('{Postal Code}')){
            tempScript = tempScript.replace('{Postal Code}',app.Permanent_Address_PostalCode__c);
        }
        else{
            if( tempScript.contains('{Postal Code}')){
                tempScript = tempScript.replace('{Postal Code}',''); 
            }
        }
        
        if(app !=null   &&  tempScript.contains('{HomeNumber}') && app.Home_Phone__c != null   ){
            tempScript = tempScript.replace('{HomeNumber}',app.Home_Phone__c);
        }
        else
        {    if(tempScript.contains('{HomeNumber}'))
            tempScript = tempScript.replace('{HomeNumber}','');
        }
        
        //{BOD}
        if(app !=null   &&  tempScript.contains('{BOD}') && app.Birth_Date__c != null   ){
            tempScript = tempScript.replace('{BOD}', convertDate(app.Birth_Date__c));
        }
        else
        {    if(tempScript.contains('{BOD}'))
            tempScript = tempScript.replace('{BOD}','');
        }
        
        //emailID
        if(app !=null   &&  tempScript.contains('{emailID}') && app.Email_Address__c != null   ){
            tempScript = tempScript.replace('{emailID}',app.Email_Address__c);
        }
        else
        {    if(tempScript.contains('{emailID}'))
            tempScript = tempScript.replace('{emailID}','');
        }
        
        //loanAmount
        if(app !=null   &&  tempScript.contains('{loanAmount}') && app.Loan_Amount__c != null   ){
            tempScript = tempScript.replace('{loanAmount}',currency(''+app.Loan_Amount__c));
        }
        else
        {    if(tempScript.contains('{loanAmount}'))
            tempScript = tempScript.replace('{loanAmount}','');
        }
        
        //InterestRate
        if(app !=null   &&  tempScript.contains('{InterestRate}') && app.Interest_Rate__c!= null   ){
            tempScript = tempScript.replace('{InterestRate}', currency(''+ app.Interest_Rate__c));
        }
        else
        {    if(tempScript.contains('{InterestRate}'))
            tempScript = tempScript.replace('{InterestRate}','');
        }
        
        //Term
        if(app !=null   &&  tempScript.contains('{Term}') && app.Number_of_Payments__c != null   ){
            tempScript = tempScript.replace('{Term}',string.valueOf(app.Number_of_Payments__c));
        }
        else
        {    if(tempScript.contains('{Term}'))
            tempScript = tempScript.replace('{Term}','');
        }
        
        //LoanStartDate
        if(app !=null   &&  tempScript.contains('{LoanStartDate}') && app.Loan_Start_Date__c!= null ){
            tempScript = tempScript.replace('{LoanStartDate}', convertDate(app.Loan_Start_Date__c));
        }
        else
        {    if(tempScript.contains('{LoanStartDate}'))
            tempScript = tempScript.replace('{LoanStartDate}','');
        }
        
        //RegularPayment
        if(app !=null   &&  tempScript.contains('{RegularPayment}') && app.Regular_Payment_Amount__c!= null ){
            tempScript = tempScript.replace('{RegularPayment}',currency(''+ app.Regular_Payment_Amount__c));
        }
        else
        {    if(tempScript.contains('{RegularPayment}'))
            tempScript = tempScript.replace('{RegularPayment}','');
        }
        
        //FirstPayment
        if(app !=null   &&  tempScript.contains('{FirstPayment}') && app.First_Payment_Amount__c!= null ){
            tempScript = tempScript.replace('{FirstPayment}',currency(''+ app.First_Payment_Amount__c));
        }
        else
        {    if(tempScript.contains('{FirstPayment}'))
            tempScript = tempScript.replace('{FirstPayment}','');
        }
        
        //PayDay
        if(app !=null   &&  tempScript.contains('{PayDay}') && app.Pay_Day__c!= null ){
            tempScript = tempScript.replace('{PayDay}', String.valueOf(app.Pay_Day__c));
        }
        else
        {    if(tempScript.contains('{PayDay}'))
            tempScript = tempScript.replace('{PayDay}','');
        }
        
        //FirstPaymentDate
        if(app !=null   &&  tempScript.contains('{FirstPaymentDate}') && app.First_Payment_Date__c!= null   ){
            tempScript = tempScript.replace('{FirstPaymentDate}',convertDate(app.First_Payment_Date__c));
        }
        else
        {    if(tempScript.contains('{FirstPaymentDate}'))
            tempScript = tempScript.replace('{FirstPaymentDate}','');
        }
        
        //TotalPayment
        if(app !=null   &&  tempScript.contains('{TotalPayment}') && app.Total_of_Payment__c!= null   ){
            tempScript = tempScript.replace('{TotalPayment}',currency(''+ app.Total_of_Payment__c));
        }
        else
        {    if(tempScript.contains('{TotalPayment}'))
            tempScript = tempScript.replace('{TotalPayment}','');
        }
        
        //{TotalInterest}
        if(app !=null   &&  tempScript.contains('{TotalInterest}') && app.Total_Interest__c!= null   ){
            tempScript = tempScript.replace('{TotalInterest}',currency(''+ app.Total_Interest__c));
        }
        else
        {    if(tempScript.contains('{TotalInterest}'))
            tempScript = tempScript.replace('{TotalInterest}','');
        }
        
        if(app != null && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  tempScript.contains('{NSFFee}') ){
            tempScript = tempScript.replace('{NSFFee}', currency(loanDocs.NSF_Fee_Amount__c));
        }
        else{
            if(tempScript.contains('{NSFFee}'))
                tempScript = tempScript.replace('{NSFFee}','');
        }
        
        teleScriptString = tempScript;
    }
    
    private string convertDate(Date dateToString){
        DateTime dt = datetime.newInstance(dateToString.Year(), dateToString.Month(), dateToString.Day());
        
        return dt.format('MMMM d,  yyyy');
    }
    
    private String currency(String i) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }
}