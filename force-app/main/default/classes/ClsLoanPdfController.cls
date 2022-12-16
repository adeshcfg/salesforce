public class ClsLoanPdfController {
    
    public string applicationid {get ;set ;}
    public boolean showNsPdf { get ;set ;}
    public boolean showNonNsPdf { get ;set ;}
    public boolean showNBPdf { get ;set ;}
    public boolean showNonNBPdf { get ;set ;}
    public boolean showManitoba{get;set;}
    
    private Map<String, String> provinceMap;

    private static Loan_ReEngineering__c loanDocs = Loan_ReEngineering__c.getOrgDefaults();
    private List<String> args = new String[]{'0','number','###,###,##0.00'};
        
        public String appId { get ;set ;} 
    
    public STring htmlstring1 {get ;set ;}
    public STring htmlstring2 {get ;set ;}
    public STring htmlstring3 {get ;set ;}
    public STring htmlstring4 {get ;set ;}
    public STring htmlstring5 {get ;set ;}
    public STring htmlstring6 {get ;set ;}
    public STring htmlstring7 {get ;set ;}
    public STring htmlstring8 {get ;set ;}
    public STring htmlstring9 {get ;set ;}
    public STring htmlstring10 {get ;set ;}
    
    public ClsLoanPdfController ()
    {
        appId = Apexpages.currentPage().getParameters().get('id');
        
        provinceMap = new Map<String, String>();
        provinceMap.put('AB', 'Alberta');
        provinceMap.put('BC', 'British Columbia');
        provinceMap.put('MB', 'Manitoba');
        provinceMap.put('NB', 'New Brunswick');
        provinceMap.put('NL', 'Newfoundland and Labrador');
        provinceMap.put('NS', 'Nova Scotia');
        provinceMap.put('NT', 'Northwest Territories');
        provinceMap.put('NU', 'Nunavut');
        provinceMap.put('ON', 'Ontario');
        provinceMap.put('PE', 'Prince Edward Island');
        provinceMap.put('QC', 'Quebec');
        provinceMap.put('SK', 'Saskatchewan');
        provinceMap.put('YT', 'Yukon');
        
        applicationid  =appId ;
        if(applicationid  != null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Middle_Name__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Megasys_Loan_Number__C,
                                            Number_of_Payments__c, Loan_Amount__c,  Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:applicationid  ];
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                showNsPdf  = true ;
                showNonNsPdf = false;
            }     
            else{
                showNsPdf  = false;
                showNonNsPdf = true;
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NB'){
                showNBPdf  = true ;
                showNonNBPdf  =false ;
            }else{
                showNonNBPdf  = true ;
                showNBPdf  = false;
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'MB'){
                showManitoba = true;
                showNonNBPdf  = false;
                showNBPdf  = false;
                showNsPdf  = false;
                showNonNsPdf = false;
            }else{
                showManitoba = false;
            }
            
        }
        clsgenrteWelcomepdfforAll();
        genrteWelcomepdfforNS();
        welcomeLetterforManitoba();
        genrteLoanAgrrement();
        genrteLoanAgrrementNB();
        ManitobaLoanAgreementDocument();
        ManitobaCancellationScheduleB();
        ManitobaCancellationScheduleA();
        LOANDISCLOSURE();
        LoanDisclosureManitoba();
        
    }
    
    Public  void clsgenrteWelcomepdfforAll (){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, name,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c,First_Name__c, Last_Name__c, Interest_Rate__c,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c, Middle_Name__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Generic_Welcome_Letter'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Full Customer Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Full Customer Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Full Customer Name}'))
                htmlbody = htmlbody.replace('{Full Customer Name}','');
            }
            
            htmlbody = htmlbody.replace('{Date}', convertDate(System.Today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}', currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring1  = htmlbody;
            
        }
    }
    
    Public void welcomeLetterforManitoba(){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, name,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c,First_Name__c, Last_Name__c, Interest_Rate__c,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c, Middle_Name__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Manitoba_Welcome_Letter'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Full Customer Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Full Customer Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Full Customer Name}'))
                htmlbody = htmlbody.replace('{Full Customer Name}','');
            }
            
            htmlbody = htmlbody.replace('{Date}', convertDate(System.Today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}', currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring8  = htmlbody;
            
        }
    }
    
    Public  void genrteWelcomepdfforNS (){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Middle_Name__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Name, Loan_Start_Date__c,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Welcome_Letter_Nova_Scotia'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Full Customer Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Full Customer Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Full Customer Name}'))
                htmlbody = htmlbody.replace('{Full Customer Name}','');
            }
            
            htmlbody = htmlbody.replace('{Date}',convertDate(system.today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}','' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}', convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}',currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring2  = htmlbody;
            
        }
    }
    
    Public  void genrteLoanAgrrement (){
        if( appId !=  null){
            List<Application__c> applist = [Select id ,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, Name,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, First_Name__c, Last_Name__c, Interest_Rate__c, 
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c, Middle_Name__c,
                                            First_Payment_Amount__c,Pay_Day__c, Loan_Start_Date__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Loan_Agreement_Generic'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Customer Full Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Customer Full Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Customer Full Name}'))
                htmlbody = htmlbody.replace('{Customer Full Name}','');
            }
            
            if(applist.size() > 0 && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  htmlbody.contains('{NSF Fee}') ){
                htmlbody = htmlbody.replace('{NSF Fee}',currency(loanDocs.NSF_Fee_Amount__c));
            }
            else{
                if(htmlbody.contains('{NSF Fee}'))
                    htmlbody = htmlbody.replace('{NSF Fee}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Pmt Date}')){
                htmlbody = htmlbody.replace('{First Pmt Date}', convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Pmt Date}'))
                    htmlbody = htmlbody.replace('{First Pmt Date}','');
            }
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{ Province}') ){
                htmlbody = htmlbody.replace('{ Province}', provinceMap.get(applist[0].Permanent_Address_Province__c));
            }
            else{
                if( htmlbody.contains('{ Province}'))
                    htmlbody = htmlbody.replace('{ Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            ////{Loan Amount In Words}
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Loan Amount In Words}') ){
                htmlbody = htmlbody.replace('{Loan Amount In Words}',convert(Integer.valueOf(applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Loan Amount In Words}'))
                    htmlbody = htmlbody.replace('{Loan Amount In Words}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}','' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}',currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            //{Open Date}
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{Open Date}')){
                htmlbody = htmlbody.replace('{Open Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Open Date}'))
                    htmlbody = htmlbody.replace('{Open Date}','');
            }
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            if(htmlbody.contains('{Date}'))
                htmlbody = htmlbody.replace('{Date}',convertDate(Date.today()));
            
            if(htmlbody.contains('{ (DATE mm-yyyy)}'))
                htmlbody = htmlbody.replace('{ (DATE mm-yyyy)}',convertDate(Date.today()));
            
            
            htmlstring3  = htmlbody;
            
        }
    }
    
    Public  void genrteLoanAgrrementNB (){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, Name,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, First_Name__c, Last_Name__c, Interest_Rate__c, 
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c, Loan_Start_Date__c,
                                            First_Payment_Amount__c,Pay_Day__c, Middle_Name__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Loan_Agreement_for_NB'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Customer Full Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Customer Full Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Customer Full Name}'))
                htmlbody = htmlbody.replace('{Customer Full Name}','');
            }
            
            if(htmlbody.contains('{DATE mm-yyyy}'))
                htmlbody = htmlbody.replace('{DATE mm-yyyy}',convertDate(Date.today()));
            if(htmlbody.contains('{Date}'))
                htmlbody = htmlbody.replace('{Date}',convertDate(Date.today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Pmt Date}')){
                htmlbody = htmlbody.replace('{First Pmt Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Pmt Date}'))
                    htmlbody = htmlbody.replace('{First Pmt Date}','');
            }
            
            //{Loan Amount In Words}
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Loan Amount In Words}') ){
                htmlbody = htmlbody.replace('{Loan Amount In Words}',convert(Integer.valueOf(applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Loan Amount In Words}'))
                    htmlbody = htmlbody.replace('{Loan Amount In Words}','');
            }
            
            if(applist.size() > 0 && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  htmlbody.contains('{NSF Fee}') ){
                htmlbody = htmlbody.replace('{NSF Fee}',currency(loanDocs.NSF_Fee_Amount__c));
            }
            else{
                if(htmlbody.contains('{NSF Fee}'))
                    htmlbody = htmlbody.replace('{NSF Fee}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}',currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            //{Open Date}
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{Open Date}')){
                htmlbody = htmlbody.replace('{Open Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Open Date}'))
                    htmlbody = htmlbody.replace('{Open Date}','');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring4  = htmlbody;
            
        }
    }
    
    Public  void LOANDISCLOSURE (){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Total_of_Payment__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Loan_Start_Date__c, Name, Middle_Name__c,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Loan_Disclosure_Satement_Generic'];
            String htmlbody  = ''; 
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Full Customer Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Full Customer Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Full Customer Name}'))
                htmlbody = htmlbody.replace('{Full Customer Name}','');
            }
            
            htmlbody = htmlbody.replace('{Date}',convertDate(system.today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('XXDateXX') ){
                htmlbody = htmlbody.replace('XXDateXX',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('XXDateXX'))
                    htmlbody = htmlbody.replace('XXDateXX','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}',currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            if(applist.size() > 0 && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  htmlbody.contains('{NSF Fee}') ){
                htmlbody = htmlbody.replace('{NSF Fee}',currency(loanDocs.NSF_Fee_Amount__c));
            }
            else{
                if(htmlbody.contains('{NSF Fee}'))
                    htmlbody = htmlbody.replace('{NSF Fee}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c != null  &&  htmlbody.contains('{Open Date}') ){
                htmlbody = htmlbody.replace('{Open Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Open Date}'))
                    htmlbody = htmlbody.replace('{Open Date}','null');
            }
            
            if(applist.size() > 0 && applist[0].Total_of_Payment__c != null  &&  htmlbody.contains('{Full Amount Paid Back}') ){
                htmlbody = htmlbody.replace('{Full Amount Paid Back}',currency(''+ (applist[0].Total_of_Payment__c)));
            }
            else{
                if(htmlbody.contains('{Full Amount Paid Back}'))
                    htmlbody = htmlbody.replace('{Full Amount Paid Back}','null');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring5  = htmlbody;
            
        }
    }
    
    Public void LoanDisclosureManitoba(){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Total_of_Payment__c, Total_Interest__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Loan_Start_Date__c, Name, Middle_Name__c,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Manitoba_Loan_Disclosure_statement_Updated'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Full Customer Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Full Customer Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Full Customer Name}'))
                htmlbody = htmlbody.replace('{Full Customer Name}','');
            }
            
            htmlbody = htmlbody.replace('{Date}',convertDate(system.today()));
            
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Total_of_Payment__c !=null  &&  htmlbody.contains('{TotalCost}') ){
                htmlbody = htmlbody.replace('{TotalCost}',currency(''+applist[0].Total_of_Payment__c));
            }
            else{
                if( htmlbody.contains('{TotalCost}}'))
                    htmlbody = htmlbody.replace('{TotalCost}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}',currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            if(applist != null && htmlbody.contains('{Total Interest}') && applist[0].Total_Interest__c != null   ){
                htmlbody = htmlbody.replace('{Total Interest}', currency(''+applist[0].Total_Interest__c));
            }
            else
            {    if(htmlbody.contains('{Total Interest}'))
                htmlbody = htmlbody.replace('{Total Interest}','');
            }
            
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + (applist[0].Interest_Rate__c).setScale(2));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+ (applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('XXDateXX') ){
                htmlbody = htmlbody.replace('XXDateXX',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('XXDateXX'))
                    htmlbody = htmlbody.replace('XXDateXX','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}', currency(''+ (applist[0].First_Payment_Amount__c)));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            if(applist.size() > 0 && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  htmlbody.contains('{NSF Fee}') ){
                htmlbody = htmlbody.replace('{NSF Fee}', currency(loanDocs.NSF_Fee_Amount__c));
            }
            else{
                if(htmlbody.contains('{NSF Fee}'))
                    htmlbody = htmlbody.replace('{NSF Fee}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c != null  &&  htmlbody.contains('{Open Date}') ){
                htmlbody = htmlbody.replace('{Open Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Open Date}'))
                    htmlbody = htmlbody.replace('{Open Date}','null');
            }
            
            if(applist.size() > 0 && applist[0].Total_of_Payment__c != null  &&  htmlbody.contains('{Full Amount Paid Back}') ){
                htmlbody = htmlbody.replace('{Full Amount Paid Back}',currency(''+ (applist[0].Total_of_Payment__c)));
            }
            else{
                if(htmlbody.contains('{Full Amount Paid Back}'))
                    htmlbody = htmlbody.replace('{Full Amount Paid Back}','null');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            
            htmlstring6  = htmlbody;
            
        }
    }
    
    Public void ManitobaLoanAgreementDocument(){
        if( appId !=  null){
            List<Application__c> applist = [Select id ,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c, Name,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, First_Name__c, Last_Name__c, Interest_Rate__c, 
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c, Loan_Start_Date__c,
                                            First_Payment_Amount__c,Pay_Day__c, Work_Phone__c, Total_of_Payment__c, Total_Interest__c, Middle_Name__c
                                            FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Manitoba_Loan_Agreement'];
            String htmlbody  = '';
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{Customer Full Name}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{Customer Full Name}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{Customer Full Name}'))
                htmlbody = htmlbody.replace('{Customer Full Name}','');
            }
            
            if(applist != null && htmlbody.contains('{Total Interest}') && applist[0].Total_Interest__c != null   ){
                htmlbody = htmlbody.replace('{Total Interest}', currency(''+applist[0].Total_Interest__c));
            }
            else
            {    if(htmlbody.contains('{Total Interest}'))
                htmlbody = htmlbody.replace('{Total Interest}','');
            }
            
            if(applist.size() > 0 && String.isNotBlank(loanDocs.NSF_Fee_Amount__c)  &&  htmlbody.contains('{NSF Fee}') ){
                htmlbody = htmlbody.replace('{NSF Fee}', currency(loanDocs.NSF_Fee_Amount__c));
            }
            else{
                if(htmlbody.contains('{NSF Fee}'))
                    htmlbody = htmlbody.replace('{NSF Fee}','');
            }
            htmlbody = htmlbody.replace('{Date}',convertDate(system.today()));
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Pmt Date}')){
                htmlbody = htmlbody.replace('{First Pmt Date}', convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Pmt Date}'))
                    htmlbody = htmlbody.replace('{First Pmt Date}','');
            }
            string address = applist[0].Permanent_Address_Street_Number__c == null ? '' : applist[0].Permanent_Address_Street_Number__c;
            address += applist[0].Permanent_Address_Street_Name__c == null ? '' : ' ' + applist[0].Permanent_Address_Street_Name__c;
            address += applist[0].Permanent_Address_Unit_Number__c == null ? '' : ', ' + applist[0].Permanent_Address_Unit_Number__c;
            if(applist.size() > 0 && address !=null  &&  htmlbody.contains('{Customer Street Address}')){
                htmlbody = htmlbody.replace('{Customer Street Address}',address);
            }
            else{
                if(htmlbody.contains('{Customer Street Address}'))
                    htmlbody = htmlbody.replace('{Customer Street Address}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_City__c !=null  &&  htmlbody.contains('{City}') ){
                htmlbody = htmlbody.replace('{City}',applist[0].Permanent_Address_City__c);
            }
            else{
                if(htmlbody.contains('{City}'))
                    htmlbody = htmlbody.replace('{City}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{ Province}') ){
                htmlbody = htmlbody.replace('{ Province}',provinceMap.get(applist[0].Permanent_Address_Province__c));
            }
            else{
                if( htmlbody.contains('{ Province}'))
                    htmlbody = htmlbody.replace('{ Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null  &&  htmlbody.contains('{Province}') ){
                htmlbody = htmlbody.replace('{Province}',applist[0].Permanent_Address_Province__c);
            }
            else{
                if( htmlbody.contains('{Province}'))
                    htmlbody = htmlbody.replace('{Province}','');
            }
            
            if(applist.size() > 0 && applist[0].Permanent_Address_PostalCode__c !=null  &&  htmlbody.contains('{Postal Code}')){
                htmlbody = htmlbody.replace('{Postal Code}',applist[0].Permanent_Address_PostalCode__c);
            }
            else{
                if( htmlbody.contains('{Postal Code}')){
                    htmlbody = htmlbody.replace('{Postal Code}',''); 
                }
            }
            
            if(applist.size() > 0 && applist[0].First_Name__c !=null  &&  htmlbody.contains('{First Name}') ){
                htmlbody = htmlbody.replace('{First Name}',applist[0].First_Name__c);
            }
            else{
                if(htmlbody.contains('{First Name}'))
                    htmlbody = htmlbody.replace('{First Name}','');
            }
            
            if(applist.size() > 0 && htmlbody.contains('{Middle Name}') && applist[0].Middle_Name__c != null   ){
                htmlbody = htmlbody.replace('{Middle Name}',applist[0].Middle_Name__c);
            }
            else
            {    if(htmlbody.contains('{Middle Name}'))
                htmlbody = htmlbody.replace('{Middle Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Last_Name__c !=null  &&  htmlbody.contains('{Last Name}')){
                htmlbody = htmlbody.replace('{Last Name}',applist[0].Last_Name__c);
            }
            else{
                if( htmlbody.contains('{Last Name}'))
                    htmlbody = htmlbody.replace('{Last Name}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{Megasys Loan Number}') ){
                htmlbody = htmlbody.replace('{Megasys Loan Number}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{Megasys Loan Number}'))
                    htmlbody = htmlbody.replace('{Megasys Loan Number}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Full Loan Amount}') ){
                htmlbody = htmlbody.replace('{Full Loan Amount}', currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Full Loan Amount}'))
                    htmlbody = htmlbody.replace('{Full Loan Amount}','');
            }
            
            //{Loan Amount In Words}
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{Loan Amount In Words}') ){
                htmlbody = htmlbody.replace('{Loan Amount In Words}',convert(Integer.valueOf(applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{Loan Amount In Words}'))
                    htmlbody = htmlbody.replace('{Loan Amount In Words}','');
            }
            if(applist.size() > 0 && applist[0].Number_of_Payments__c !=null  &&  htmlbody.contains('{Term}')){
                htmlbody = htmlbody.replace('{Term}',String.valueOf(applist[0].Number_of_Payments__c));
            }
            else{
                if( htmlbody.contains('{Term}'))
                    htmlbody = htmlbody.replace('{Term}','');
            }
            
            if(applist.size() > 0 && applist[0].Interest_Rate__c !=null  &&  htmlbody.contains('{APR}') ){
                htmlbody = htmlbody.replace('{APR}', '' + currency(''+applist[0].Interest_Rate__c));
            }
            else{
                if(htmlbody.contains('{APR}')){
                    htmlbody = htmlbody.replace('{APR}','');  
                    
                }
            }
            
            if(applist.size() > 0 && applist[0].Regular_Payment_Amount__c !=null  &&  htmlbody.contains('{Reg Pmt Amt}') ){
                htmlbody = htmlbody.replace('{Reg Pmt Amt}',currency(''+(applist[0].Regular_Payment_Amount__c)));
            }
            else{
                if( htmlbody.contains('{Reg Pmt Amt}'))
                    htmlbody = htmlbody.replace('{Reg Pmt Amt}','');
            }
            
            if(applist.size() > 0 && applist[0].Pay_Day__c !=null   &&  htmlbody.contains('{Pay Day}') ){
                htmlbody = htmlbody.replace('{Pay Day}',String.valueOf(applist[0].Pay_Day__c));
            }
            else{
                if( htmlbody.contains('{Pay Day}'))
                    htmlbody = htmlbody.replace('{Pay Day}','');
            }
            
            if(applist.size() > 0 && applist[0].First_Payment_Date__c !=null  &&  htmlbody.contains('{First Payment Date}') ){
                htmlbody = htmlbody.replace('{First Payment Date}',convertDate(applist[0].First_Payment_Date__c));
            }
            else{
                if(htmlbody.contains('{First Payment Date}'))
                    htmlbody = htmlbody.replace('{First Payment Date}','');
            }
            
            //{Open Date}
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{Open Date}')){
                htmlbody = htmlbody.replace('{Open Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Open Date}'))
                    htmlbody = htmlbody.replace('{Open Date}','');
            }
            
            if(applist.size() > 0 && applist[0].Work_Phone__c !=null  &&  htmlbody.contains('{PhoneNumber}')){
                htmlbody = htmlbody.replace('{PhoneNumber}', ('' + (applist[0].Work_Phone__c)));
            }
            else{
                if(htmlbody.contains('{PhoneNumber}'))
                    htmlbody = htmlbody.replace('{PhoneNumber}','');
            }
            
            if(applist.size() > 0 && applist[0].Total_of_Payment__c !=null  &&  htmlbody.contains('{Total of Payment}')){
                htmlbody = htmlbody.replace('{Total of Payment}', currency('' + applist[0].Total_of_Payment__c));
            }
            else{
                if(htmlbody.contains('{Total of Payment}'))
                    htmlbody = htmlbody.replace('{Total of Payment}','');
            }
            
            
            if(applist.size() > 0 && applist[0].First_Payment_Amount__c !=null  &&  htmlbody.contains('{First Pmt Amt}') ){
                htmlbody = htmlbody.replace('{First Pmt Amt}', currency(''+ applist[0].First_Payment_Amount__c));
            }
            else{
                if(htmlbody.contains('{First Pmt Amt}'))
                    htmlbody = htmlbody.replace('{First Pmt Amt}','');
            }
            
            String ns = 'Affirm Financial Services<br/>1959 Upper Water St, Suite 1301<br/>Halifax, Nova Scotia, B3J 3N2';
            String nonNS = 'Affirm Financial Services<br/>Station B, P.O. Box 53<br/>London, Ontario, N6A 4V3';
            
            
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c != 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',nonNS);
            }
            if(applist.size() > 0 && applist[0].Permanent_Address_Province__c !=null && applist[0].Permanent_Address_Province__c == 'NS'){
                htmlbody = htmlbody.replace('{Address Text}',ns);
            }
            if(htmlbody.contains('{Date}'))
                htmlbody = htmlbody.replace('Date', convertDate(Date.today()));
            
            if(htmlbody.contains('{ (DATE mm-yyyy)}'))
                htmlbody = htmlbody.replace('{ (DATE mm-yyyy)}',convertDate(Date.today()));
            
            
            htmlstring7  = htmlbody;
            
        }
    }
    
    Public  void ManitobaCancellationScheduleA (){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Total_of_Payment__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Loan_Start_Date__c, Name,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Schedule_A_Cancellation_Notice'];
            String htmlbody  = ''; 
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{CustomerName}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{CustomerName}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{CustomerName}'))
                htmlbody = htmlbody.replace('{CustomerName}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{LoanAmount}') ){
                htmlbody = htmlbody.replace('{LoanAmount}', currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{LoanAmount}'))
                    htmlbody = htmlbody.replace('{LoanAmount}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{Date}')){
                htmlbody = htmlbody.replace('{Date}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{Date}'))
                    htmlbody = htmlbody.replace('{Date}','');
            }
                        
            htmlstring9  = htmlbody;
            
        }
    }
    
    Public  void ManitobaCancellationScheduleB(){
        if( appId !=  null){
            List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                            Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                            Permanent_Address_PostalCode__c, First_Payment_Date__c, Total_of_Payment__c,
                                            First_Name__c, Last_Name__c, Interest_Rate__c, Loan_Start_Date__c, Name,
                                            Number_of_Payments__c, Loan_Amount__c, Megasys_Loan_Number__c, Regular_Payment_Amount__c,
                                            First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:appId];
            
            List<EmailTemplate> emailTemp = [SELECT ApiVersion,Body,Markup,HtmlValue FROM EmailTemplate where developername ='Schedule_B_Cancellation_Receipt'];
            String htmlbody  = ''; 
            htmlbody = emailTemp[0].HtmlValue;
            
            if(applist !=null   &&  htmlbody.contains('{CustomerName}') && applist[0].Customer__r.name != null   ){
                htmlbody = htmlbody.replace('{CustomerName}',applist[0].Customer__r.name);
            }
            else
            {    if(htmlbody.contains('{CustomerName}'))
                htmlbody = htmlbody.replace('{CustomerName}','');
            }
            
            if(applist.size() > 0 && applist[0].Name !=null  &&  htmlbody.contains('{ApplicationNumber}') ){
                htmlbody = htmlbody.replace('{ApplicationNumber}',String.valueOf(applist[0].Name));
            }
            else{
                if( htmlbody.contains('{ApplicationNumber}'))
                    htmlbody = htmlbody.replace('{ApplicationNumber}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Amount__c !=null  &&  htmlbody.contains('{LoanAmount}') ){
                htmlbody = htmlbody.replace('{LoanAmount}', currency(''+ (applist[0].Loan_Amount__c)));
            }
            else{
                if(htmlbody.contains('{LoanAmount}'))
                    htmlbody = htmlbody.replace('{LoanAmount}','');
            }
            
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{LoanStartDate}')){
                htmlbody = htmlbody.replace('{LoanStartDate}', convertDate(applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{LoanStartDate}'))
                    htmlbody = htmlbody.replace('{LoanStartDate}','');
            }
            
            /*
            //whichValue
            if(applist.size() > 0 && applist[0].Loan_Start_Date__c !=null  &&  htmlbody.contains('{WhichValue}')){
                htmlbody = htmlbody.replace('{WhichValue}', (applist[0].Loan_Start_Date__c));
            }
            else{
                if(htmlbody.contains('{WhichValue}'))
                    htmlbody = htmlbody.replace('{WhichValue}','');
            }*/
                        
            htmlstring10  = htmlbody;
            
        }
    }
    
    private string convertDate(Date dateToString){
        DateTime dt = datetime.newInstance(dateToString.Year(), dateToString.Month(), dateToString.Day());
        
        return dt.format('MMMM d,  yyyy');
    }
    
    private String currency(String i) {
        String s = ( Decimal.valueOf(i==null||i.trim()==''?'0':i).setScale(2) + 0.001 ).format();
        return s.substring(0,s.length()-1);
    }
    
    private String convert(integer i){
        String[] units = new String[]{'Zero ','One ','Two ','Three ','Four ','Five ','Six ','Seven ','Eight ','Nine ','Ten ',
                          'Eleven ','Twelve ','Thirteen ','Fourteen ','Fifteen ', 'Sixteen ','Seventeen ','Eighteen ','Nineteen '};
        String[] tens = new String[]{'','','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety'};
       
        if( i < 20)  return units[integer.valueOf(i)];
        if( i < 100) return tens[integer.valueOf(i)/10] + ((math.mod(i , 10) > 0)? '' + convert(math.mod(i , 10)):'');
        if( i < 1000) return units[integer.valueOf(i)/100] + ' Hundred ' + ((math.mod(i , 100) > 0)?' ' + convert(math.mod(i , 100)):'');
        if( i < 10000) return units[integer.valueOf(i)/1000] + ' Thousand ' + ((math.mod(i , 1000) > 0)?' ' + convert(math.mod(i , 1000)):'');
        if( i < 100000) return convert(i / 1000) + ' Thousand ' + ((math.mod(i , 1000) > 0)? '' + convert(math.mod(i ,1000)):'') ;
        if( i < 1000000) return units[integer.valueOf(i)/100000] + ' Lakh ' + ((math.mod(i , 100000) > 0)? '' + convert(math.mod(i ,100000)):'') ;
        if( i < 10000000) return convert(i / 100000) + ' Lakh ' + ((math.mod(i , 100000) > 0)? '' + convert(math.mod(i ,100000)):'') ;
        if(i < 100000000) return units[integer.valueOf(i)/10000000] + ' Crore ' + ((math.mod(i , 10000000) > 0)? '' + convert(math.mod(i , 10000000)):'') ;
        if(i < 1000000000) return convert(i / 10000000) + 'Crore ' + ((math.mod(i , 10000000) > 0)? '' + convert(math.mod(i , 10000000)):'') ;

        return convert(i / 1000000000) + ' Crore ' + ((math.mod(i , 1000000000) > 0) ? '' + convert(math.mod(i , 1000000000)):'') ;

    }   
}