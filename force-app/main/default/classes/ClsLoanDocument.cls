public class ClsLoanDocument {
    
    public string applicationid {get ;set ;}
    
    public Boolean checkValue{get;set;}
    public Boolean showError{get;set;}
    public Boolean sucessMessage{get;set;}
    public Boolean showSucessLoan{get;set;}
    public Boolean showSucessUpload{get;set;}
    public Application__c app{get;set;}
    public Attachment loanDocument{get;set;}
    public Loan_ReEngineering__c loanSettings{get;set;}
    public String errorMessage{get;set;}
    public String acceptFormat{get;set;}
    public Integer acceptFileSize{get;set;}
    public Integer fileSize{get;set;}
    
    public clsLoanDocument (){
        
        errorMessage = '';
        showError = false;
        showSucessLoan = false;
        
        loanSettings = Loan_ReEngineering__c.getOrgDefaults();
        applicationid  = Apexpages.currentPage().getParameters().get('id');
        
        //File Validation
        acceptFormat = loanSettings.File_Formats__c;
        acceptFileSize = (Integer)loanSettings.File_Size__c;
        
        List<Application__c> applist = [Select id,Customer__c,Customer__r.name,Permanent_Address_Street_Number__c,Permanent_Address_Street_Name__c,
                                        Permanent_Address_Unit_Number__c, Permanent_Address_City__c, Permanent_Address_Province__c,
                                        Permanent_Address_PostalCode__c, First_Payment_Date__c, Loan_Type__c, Authentication_Choice__c, 
                                        First_Name__c, Last_Name__c, Interest_Rate__c, Megasys_Loan_Number__C, Decision__c, Loan_Document_Acceptance__c,
                                        Number_of_Payments__c, Loan_Amount__c,  Regular_Payment_Amount__c, Application_Fullfillment_Status__c,
                                        First_Payment_Amount__c,Pay_Day__c FROM Application__c where id=:applicationid  ];
        if(applist.size() > 0)
            app = applist[0];
        
        
        loanDocument = new Attachment();
        
        if('Affirm Financial MasterCard' == appList[0].Loan_Type__c){
            errorMessage = 'This Application is for Creadit Card, you cannot continue with Loan Document.';
            showError = true;
        }else if('Declined' == appList[0].Decision__c){
            errorMessage = 'The Authentication choice is Declined, you cannot continue with Loan Document.';
            showError = true;
        }else if('Approved for Funding' == appList[0].Application_Fullfillment_Status__c ||
                 'Completed' == appList[0].Application_Fullfillment_Status__c ||
                 'Ready For Export' == appList[0].Application_Fullfillment_Status__c ||
                 'Loan Document Executed' == appList[0].Application_Fullfillment_Status__c ){
                     errorMessage = 'The Application is not in correct Fullfillment Status, you cannot continue with Loan Document';
                     showError = true;
                 }
        
    }
    
    public void checkValueFunction(){
        if(checkValue == false)
            checkValue = true;
        else
            checkValue = false;
    }
    
    public PageReference saveData(){
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        //app.Application_Fullfillment_Status__c = 'Executing Loan Document';
        app.Loan_Document_Acceptance__c = checkValue; 
        app.Loan_Document_Accepted_DateTime__c = system.Now();
        update app;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        showSucessUpload = true;
        
        Pagereference pageRef = ApexPages.currentPage();
        pagereference Pg = new pagereference('/apex/LoanPdf?id='+app.id);
        Blob pdf1;
        String textPDF = 'Hi This is textttt';
        if(!Test.isRunningTest()){
            pdf1 = pg.getcontentAsPdf(); 
        }
        else{
            textPDF = 'Hi This is textttt';
            pdf1 = Blob.valueOf(textPDF);
        }
        
        Attachment att  = new Attachment();
        att.ParentId = app.id;
        att.Body = Pdf1;
        att.Name = 'Loan Document-'+String.valueOf(System.Now())+'-'+app.First_Name__c+ '_'+app.Last_Name__c + '.pdf';
        att.ContentType = 'application/pdf';
        insert att;
        
        showSucessLoan = true;
        
        return pageRef;
    }
    
    public PageReference goBack(){
        PageReference pageRef = new PageReference('/' + app.id);
        return pageref;
    }
    public void downloadPage(){
        String url = '/servlet/servlet.FileDownload?file=066P000000015q2?id&'+app.id;
    }
    
    public PageReference upload(){
        
        showSucessLoan = true;
        
        /*if(app.Loan_Document_Acceptance__c == false){
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Accept the Loan Document Before uploading the Loan Document');
ApexPages.addMessage(myMsg);
loanDocument = new Attachment();
showSucessLoan = false;
return null;
}*/
        if(loanDocument.body == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please upload the Loan Document');
            ApexPages.addMessage(myMsg);
            loanDocument = new Attachment();
            showSucessLoan = false;
            return null;
        }
        
        //PAP file validation
        if(loanDocument.body != null){
            
            //File Extention
            String extensionVal = loanDocument.Name.substringAfterLast('.').toLowerCase();
            if(!acceptFormat.contains(extensionVal)){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please attach '+ acceptFormat +' files only');
                ApexPages.addMessage(myMsg);
                showSucessLoan = false;
                loanDocument = new Attachment();
                return null;    
            }   
            
            //File Size
            if(fileSize > acceptFileSize){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'File size greater than accepted file size');
                ApexPages.addMessage(myMsg);
                showSucessLoan = false;
                loanDocument = new Attachment();
                return null;                        
            }
        }
        
        
        loanDocument.parentid = app.id;
        loanDocument.name = 'Loan_Document_'+ loanDocument.name;
        
        insert loanDocument;
        
        Profile prof = [SELECT Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        
        if('CFG - Loan Administrator' != prof.Name){
            app.Application_Fullfillment_Status__c = 'Ready for Approval';
        }
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        update app;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        showSucessUpload = true;
        loanDocument = new Attachment();
        PageReference pageRef = ApexPages.currentPage();
        
        return pageRef;
    }
}