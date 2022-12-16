/***************************************************
* Author         : A5E Consultancy
* Last Modified  : 13 Apr 2017
* Description    : Provided user to preview & print email templates with product merge fields
*
***************************************************/
public class PreviewProductEmailCntrl{

    // To render HTML in vf page 
    public String htmlBody { get; set; }
    
    // To define how the page should display
    public String renderedAs{set;get;}
    Product__c prod;
    String templateName;
    String productType;
    // Constructor to read product through SOQL
    public PreviewProductEmailCntrl(){
        Id prodId = ApexPages.currentPage().getParameters().get('Id');
        templateName = ApexPages.currentPage().getParameters().get('TemplateName');
        renderedAs = ApexPages.currentPage().getParameters().get('renderedAs');
        productType = ApexPages.currentPage().getParameters().get('productType');
        System.debug('===='+templateName);
        // Queries product record and values
        prod = [SELECT First_Name__c, Last_Name__c, Past_Due_Amount__c, Charged_Off_Date__c, Last_Payment_Date__c, Employer_Name__c,
                Current_Payoff_Amount__c, Effective_Next_Payment_Amount__c, Minimum_Payment_Amount__c, Current_Balance__c, Name, 
                Customer__r.Name, Address_Line1__c,Address_Line2__c, city__c/*, State__c*/, Zip_Code__c, Customer__r.Employer_Name__pc, 
                Payment_Due_Date__c, Product_Type__c,Previous_Primary_Account_Number__c,Originating_Creditor__c, 
                Account_Purchasing_Entity__c, Account_Purchase_Date__c 
                FROM Product__c 
                WHERE Id =: prodId];
        
        // Queries Email template that selected by user
        htmlBody = [Select id,HtmlValue from EmailTemplate where Name =: TemplateName ].HTMLValue;
       
        // Mapping merge field to replace in HTML body
        Map<String, String> mapBodyParams = new Map<String, String>{
                                             '{!Product__c.First_Name__c}' => prod.First_Name__c,
                                             '{!Product__c.Employer_Name__c}' => prod.Employer_Name__c,
                                             '{!Product__c.Minimum_Payment_Amount__c}' => '$'+(prod.Minimum_Payment_Amount__c != null ? String.valueOF(prod.Minimum_Payment_Amount__c).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,') : '0'),
                                             '{!Product__c.Current_Balance__c}' =>  '$'+(prod.Current_Balance__c != null ? String.valueOf(prod.Current_Balance__c) .replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'): '0'),
                                             '{!LPAD(Product__c.Name, 8, \'0\')}' => prod.Name.leftPad(8, '0'),
                                             '{!Product__c.Name}' => prod.Name,
                                             '{!TEXT(MONTH(Product__c.Last_Payment_Date__c))}/{!TEXT(DAY(Product__c.Last_Payment_Date__c))}/{!TEXT(YEAR(Product__c.Last_Payment_Date__c))}' => prod.Last_Payment_Date__c != null ? (prod.Last_Payment_Date__c.month() +'/'+ prod.Last_Payment_Date__c.day() +'/'+ prod.Last_Payment_Date__c.year()) : '',
                                             '{!TEXT(MONTH(TODAY())) +\' - \'+ TEXT(DAY(TODAY())) +\' - \'+ TEXT(YEAR(TODAY()))}' => System.Today().day() +'-'+System.TODAY().month() +'-'+System.TODAY().year(),
                                             '{!Product__c.Customer__r.Name}' => prod.Customer__r.Name,
                                             '{!Product__c.Address_Line1__c}' => prod.Address_Line1__c,
                                             '{!Product__c.Address_Line2__c}' => prod.Address_Line2__c,
                                             '{!Product__c.City__c}' => prod.city__c,
                                             //'{!Product__c.State__c}' => prod.State__c,
                                             '{!Product__c.Zip_Code__c}' => prod.Zip_Code__c,
                                             '{!Product__c.Last_Name__c}' => prod.Last_Name__c,
                                             '{!Product__c.Last_Payment_Date__c}' => String.valueOf(prod.Last_Payment_Date__c),
                                             '{!Product__c.Effective_Next_Payment_Amount__c}' => ((String.valueOf(prod.Effective_Next_Payment_Amount__c) != null ? '$'+String.valueOf(prod.Effective_Next_Payment_Amount__c) : '0')).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!Product__c.Past_Due_Amount__c}' => (String.valueOf(prod.Past_Due_Amount__c) != null ? '$'+String.valueOf(prod.Past_Due_Amount__c) : '0'),
                                             '{!Product__c.Current_Payoff_Amount__c}' => ((String.valueOf(prod.Current_Payoff_Amount__c) != null ? '$'+String.valueOf(prod.Current_Payoff_Amount__c) : '0')).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!CASE(MONTH(TODAY()),1, "January",2, "February",3, "March", 4, "April", 5, "May", 6,"June",7, "July",8, "August",9, "September",10, "October",11, "November",12, "December","None")}'=> Datetime.now().format('MMMM'),
                                             '{!TEXT(DAY(TODAY()))}' => String.valueOf(System.Today().day()),
                                             '{!TEXT(YEAR(TODAY()))}' => String.valueOf(System.Today().year()),
                                             '{!CompanyName}' =>  prod.Customer__r.Employer_Name__pc,
                                             '{!Product__c.Payment_Due_Date__c}' =>  (prod.Payment_Due_Date__c != null ? String.valueOf(prod.Payment_Due_Date__c.day()+'/'+prod.Payment_Due_Date__c.month()+'/'+prod.Payment_Due_Date__c.year()) : ''),
                                             '{!Product__c.Customer__r.Employer_Name__pc}' => prod.Customer__r.Employer_Name__pc,
                                             '{!TODAY()+14}' => String.valueOf((System.today().addDays(14)).format()),
                                             '{!IF(CONTAINS(TEXT(0.75*Product__c.Current_Payoff_Amount__c), "."), LEFT(TEXT(0.75*Product__c.Current_Payoff_Amount__c), FIND(".",TEXT(0.75*Product__c.Current_Payoff_Amount__c)) -1) & "." & RPAD(MID(TEXT(ROUND(0.75*Product__c.Current_Payoff_Amount__c, 2)), FIND(".", TEXT(0.75*Product__c.Current_Payoff_Amount__c))+1, 2), 2, "0"), TEXT(0.75*Product__c.Current_Payoff_Amount__c) & ",00" )}' => (String.valueOf((0.75*(prod.Current_Payoff_Amount__c != null ? prod.Current_Payoff_Amount__c : 0)).setscale(2))).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!IF(CONTAINS(TEXT(0.25*Product__c.Current_Payoff_Amount__c), "."), LEFT(TEXT(0.25*Product__c.Current_Payoff_Amount__c), FIND(".", TEXT(0.25*Product__c.Current_Payoff_Amount__c)) -1) & "." & RPAD(MID(TEXT(ROUND(0.25*Product__c.Current_Payoff_Amount__c, 2)), FIND(".", TEXT(0.25*Product__c.Current_Payoff_Amount__c))+1, 2), 2, "0"), TEXT(0.25*Product__c.Current_Payoff_Amount__c) & ",00" )}' => (String.valueOf((0.25*(prod.Current_Payoff_Amount__c != null ? prod.Current_Payoff_Amount__c : 0)).setscale(2))).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!Product__c.Product_Current_Balance__c}' => '$'+(String.valueOf((0.75*(prod.Current_Balance__c != null ? prod.Current_Balance__c : 0)).setscale(2))).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!Product__c.Product_Current_Balance_2__c}' => '$'+(String.valueOf((0.25*(prod.Current_Balance__c != null ? prod.Current_Balance__c : 0)).setscale(2))).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!Product__c.Originating_Creditor__c}' => (prod.Originating_Creditor__c != null ? prod.Originating_Creditor__c : ''),
                                             '{!Product__c.Account_Purchasing_Entity__c}' => (prod.Account_Purchasing_Entity__c != null ? prod.Account_Purchasing_Entity__c : ''),
                                             '{!Product__c.Previous_Primary_Account_Number__c}' => (prod.Previous_Primary_Account_Number__c != null ? prod.Previous_Primary_Account_Number__c : ''),
                                             '{!Product__c.Product_Current_Balance_0__c}' =>'$'+ (String.valueOf(((prod.Current_Balance__c != null ? prod.Current_Balance__c : 0)/12).setscale(2))).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,'),
                                             '{!Product__c.Product_Type__c}' => prod.Product_Type__c,
                                             '{!CASE(MONTH(Product__c.Charged_Off_Date__c),1, "January",2, "February",3, "March", 4, "April", 5, "May", 6,"June",7, "July",8, "August",9, "September",10, "October",11, "November",12, "December","None")}' => (prod.Charged_Off_Date__c != null ? (datetime.newInstance(prod.Charged_Off_Date__c.year(), prod.Charged_Off_Date__c.month(),prod.Charged_Off_Date__c.day())).format('MMMM') : ''),
                                             '{!CASE(MONTH(Product__c.Account_Purchase_Date__c),1, "January",2, "February",3, "March", 4, "April", 5, "May", 6,"June",7, "July",8, "August",9, "September",10, "October",11, "November",12, "December","None")}' => (prod.Account_Purchase_Date__c != null ? (datetime.newInstance(prod.Account_Purchase_Date__c.year(), prod.Account_Purchase_Date__c.month(),prod.Account_Purchase_Date__c.day())).format('MMMM') : ''),
                                             '{!TEXT(DAY(Product__c.Charged_Off_Date__c))}' => (prod.Charged_Off_Date__c != null ? String.valueOf(prod.Charged_Off_Date__c.day()) : ''),
                                             '{!TEXT(YEAR(Product__c.Charged_Off_Date__c))}' => (prod.Charged_Off_Date__c != null ? String.valueOf(prod.Charged_Off_Date__c.year()) : ''),
                                             '{!TEXT(DAY(Product__c.Account_Purchase_Date__c))}' => (prod.Account_Purchase_Date__c != null ? String.valueOf(prod.Account_Purchase_Date__c.day()) : ''),
                                             '{!TEXT(YEAR(Product__c.Account_Purchase_Date__c))}' => (prod.Account_Purchase_Date__c != null ? String.valueOf(prod.Account_Purchase_Date__c.year()) : '')
                                             };
        // Replacing mere fields with product data
        for(String key : mapBodyParams.keySet()){
        system.debug('--'+key);
            htmlBody = htmlBody.replace(key, (mapBodyParams .get(key) == null) ? '' : mapBodyParams .get(key));
        }
    }
    
    // Creating Activity
    public void createActivity(){
        if(renderedAs != 'pdf' && templateName != null && templateName != ''){
        Task activity = new Task( Subject = 'Print Email - '+templateName,
                WhatId = prod.Id,
                OwnerId = UserInfo.getUserId(),
                Status='Completed');
        insert activity;
        }
    }
}