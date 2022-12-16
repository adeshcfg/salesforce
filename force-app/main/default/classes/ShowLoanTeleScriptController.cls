public class ShowLoanTeleScriptController{
    
    public Boolean showError{get;set;}
    public String errorMessage{get;set;}
    public Boolean showAccept{get;set;}
    String appName;
    public String appId{get;set;}
    Application__c app;
    
    public showLoanTeleScriptController(){
        
        appName = Apexpages.currentPage().getParameters().get('applName');
        
        app = [select id, Loan_Type__c, Decision__c, Authentication_Result__c, Application_Fullfillment_Status__c,
               Loan_Process_Type__c, First_Name__c, Last_Name__c, Authentication_Choice__c
               from Application__c where name =: appName limit 1];
        
        if('Affirm Financial MasterCard' == app.Loan_Type__c){
            errorMessage = 'This Application is for Credit Card, you cannot continue with Loan Tele Scripting.';
            showError = true;
        }else if(String.isBlank(app.Decision__c)){
            errorMessage = 'The Application Decision is missing, you cannot continue with Loan Tele Scripting.';
            showError = true;
        }else if('Declined' == app.Decision__c){
            errorMessage = 'The Application Decision is Declined, you cannot continue with Loan Tele Scripting.';
            showError = true;
        }else if(app.Authentication_Result__c != 'Passed' && app.Authentication_Choice__c != 'Completed'){
            showError = true;
            errorMessage = 'The Authentication is not completed for this Application, you cannot continue with Loan Tele Scripting.';               
        }else if(!LoanUtility.getValidLoanProcessTypes().contains(app.Loan_Process_Type__c)){
            showError = true;
            errorMessage = 'The Application is not in correct Loan Process Type, you cannot continue with Loan Tele Scripting';
        }else if(String.isBlank(app.Application_Fullfillment_Status__c )){
            errorMessage = 'The Application Fulfillment Status is missing, you cannot continue with Loan Tele Scripting.';
            showError = true;
        }else if('Completed' == app.Application_Fullfillment_Status__c ){
            errorMessage = 'The Application Fulfillment Status is Completed, you cannot continue with Loan Tele Scripting.';
            showError = true;
        }
        
        appId = app.id;
    }
    
    public PageReference saveScript(){
        
        ApplicationTriggerHandler.runApplicationLoadTrigger = false;
        app.Application_Fullfillment_Status__c = 'Tele Scripting Completed';
        app.Loan_TeleScripting_Accepted__c = showAccept;
        app.Loan_TeleScripting_Accepted_Date__c = system.Now();
        update app;
        ApplicationTriggerHandler.runApplicationLoadTrigger = true;
        
        
        Pagereference pageRef = ApexPages.currentPage();
        pagereference Pg = new pagereference('/apex/LoanTeleScript?id='+app.id);
        Blob pdf1 ;
        if(!Test.Isrunningtest())
            pdf1 = pg.getcontentAsPdf();
        else
            pdf1 = Blob.valueof('Test');
        Attachment att  = new Attachment();
        att.ParentId = app.id;
        att.Body = Pdf1;
        att.Name = 'Loan TeleScript-'+ String.valueOf(System.today())+'-'+app.First_Name__c+ '_'+app.Last_Name__c + '.pdf';
        att.ContentType = 'application/pdf';
        insert att;
        
        return null;
    }
}