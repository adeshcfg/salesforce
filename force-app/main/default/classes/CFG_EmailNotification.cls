public class CFG_EmailNotification {
    
    public static String allocate = 'Product Allocation File';
    public static String recall = 'Account Status Update File';
    
    public static Agency_Portal_Settings__c domainName = Agency_Portal_Settings__c.getOrgDefaults();
    //When create process link at time of allocation then send email notification.
    public static void sendEmailNotification(String userName, String processingLink,String workAssigName, String workAssigTitle,String documentType){
        system.debug('userName::'+userName);
        User activeUser;
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where Username = : userName limit 1];
        }
        
        system.debug('activeUser::'+activeUser);
        String userEmail ='';
        if(!Test.isRunningTest()){
            userEmail = activeUser.Email;
        }else{
            userEmail = userName;
        }
        
        system.debug('userEmail::'+userEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail}; 
            
            mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        if(documentType == allocate){
            mail.setSubject('Allocation process link is generated successfully for task '+workAssigName);
        }else if(documentType == recall){
            mail.setSubject('Account status update process link is generated successfully for task '+workAssigName);
        }
        
        mail.setUseSignature(false);
        if(documentType == allocate){
            mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process link is generated successfully. \n\nClick to process allocation record link:\n'+processingLink + '\n\n\nThanks,\nCFG support');
        }else if(documentType == recall){
            mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the account status update process link is generated successfully. \n\nClick to process Account Status Update record link:\n'+processingLink + '\n\n\nThanks,\nCFG support');
        }
        
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Email is send');
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Email not send');
        }
        
    }
    
    //When create error file send email to user.
    public static void sendEmailNotificationOnErrorFile(String userName,String workAssigComment,String workAssigName, String workAssigTitle,String workAssignmentId,String documentType){
        User activeUser;
        system.debug('userName::'+userName);
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where name = : userName limit 1];
        }
        system.debug('activeUser::'+activeUser);
        String userEmail ='';
        if(!Test.isRunningTest()){
            userEmail = activeUser.Email;
        }else{
            userEmail = userName;
        }
        system.debug('userEmail::'+userEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail}; 
            
            mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        //mail.setOrgWideEmailAddressId('0D23a000000L6YL');
        if(documentType == allocate){
            mail.setSubject('Allocation process completed for task '+workAssigName);
        }else if(documentType == recall){
            mail.setSubject('Account status update process completed for task '+workAssigName);        
        }
        
        mail.setUseSignature(false);
        // mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is completed. \n\n\nClick to process allocation record link:<a href="'+domainName.Domain_name__c+workAssignmentId+'">click here.</a>\n\n\n\n Thanks');
        if(documentType == allocate){
            mail.setHtmlBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is completed, with following remark<br/><br/>'+workAssigComment+
                             '<br/><br/>To view your task <a href="'+domainName.Domain_name__c+workAssignmentId+'">click here.</a><br/><br/><br/>Thanks,<br/>CFG support');        
        }else if(documentType == recall){
            mail.setHtmlBody('For your task '+workAssigName+' '+workAssigTitle+' the account status update process is completed, with following remark<br/><br/>'+workAssigComment+
                             '<br/><br/>To view your task <a href="'+domainName.Domain_name__c+workAssignmentId+'">click here.</a><br/><br/><br/>Thanks,<br/>CFG support');
        }
        
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Email is send');
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Email not send');
        }
        
    }
    
    //When process link not created.
    public static void sendEmailNotificationOnProcessLinkFail(String userName,String exceptionMsg,String workAssigName, String workAssigTitle,String workAssignmentId,string documentType){
        User activeUser;
        system.debug('userName::'+userName);
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where Username = : userName limit 1];
        }
        system.debug('activeUser::'+activeUser);
        String userEmail ='';
        if(!Test.isRunningTest()){
            userEmail = activeUser.Email;
        }else{
            userEmail = userName;
        }
        system.debug('userEmail::'+userEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail}; 
            
            mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');
        if(documentType == allocate){
            mail.setSubject('Allocation process failed for task '+workAssigName);
        }else if(documentType == recall){
            mail.setSubject('Account status update process failed for task '+workAssigName);   
        }
        
        mail.setUseSignature(false);
        //mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is completed. \n\n\nClick to process allocation record link:\n\n\n\n Thanks');
        
        if(documentType == allocate){
            mail.setHtmlBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is failed, with following remark<br/><br/>'+exceptionMsg+
                             '<br/><br/>To view your task <a href="'+domainName.Domain_name__c+workAssignmentId+'">click here.</a><br/><br/><br/>Thanks,<br/>CFG support');
            
        }else if(documentType == recall){
            mail.setHtmlBody('For your task '+workAssigName+' '+workAssigTitle+' the account status update process is failed, with following remark<br/><br/>'+exceptionMsg+
                             '<br/><br/>To view your task <a href="'+domainName.Domain_name__c+workAssignmentId+'">click here.</a><br/><br/><br/>Thanks,<br/>CFG support');
            
        }
        
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Email is send');
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Email not send');
        }
        
    }
    
    //When snapshot is failed from product and pool allocation then send exception email.
    public static void snapshotFailedEmailNotification(String userName,String exceptionMsg,String documentStorage){
        User activeUser;
        system.debug('userName::'+userName);
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where name = : userName limit 1];
        }
        system.debug('activeUser::'+activeUser);
        String userEmail ='';
        if(!Test.isRunningTest()){
            userEmail = activeUser.Email;
        }else{
            userEmail = userName;
        }
        system.debug('userEmail::'+userEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail}; 
            
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Salesforce Support');

        mail.setSubject('Snapshot is failed');   
        mail.setUseSignature(false);
        
        //mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is completed. \n\n\nClick to process allocation record link:\n\n\n\n Thanks');
        mail.setHtmlBody('Snapshot is failed. Please find the below error and kindly contact with your technical team:<br/><br/>'+exceptionMsg+'<br/><br/><br/>Thanks,<br/>CFG support');
    
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            system.debug('Email is send');
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Email not send');
        }
        
    }
    
    //4735:notify to CFG App Support if snapshot failed
    public static void snapshotFailedEmailNotifyTOCFGSupport(String userName,String exceptionMsg,String action){
        //send mail to CFG App Support
        //String userEmail ='appsupport@canaccede.com';
        User activeUser;
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where name = : userName limit 1];
        }
        String userEmail ='';
        userEmail ='sulbha.konodia@canaccede.com'+',';
        if(!Test.isRunningTest()){
            userEmail += activeUser.Email ;
        }else{
            userEmail = userName;
        }
        List<String> lstEmail = userEmail.split(',');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        mail.setToAddresses(lstEmail);
        mail.setSenderDisplayName('Salesforce Support');

        mail.setSubject('Snapshot is failed');   
        mail.setUseSignature(false);
        
        //mail.setPlainTextBody('For your task '+workAssigName+' '+workAssigTitle+' the allocation process is completed. \n\n\nClick to process allocation record link:\n\n\n\n Thanks');
        mail.setHtmlBody('Snapshot is failed. Please find the below error and kindly contact with your technical team:<br/><br/>'+exceptionMsg+' '+'on action'+' '+action+'.<br/><br/><br/>Thanks,<br/>CFG support');
    
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
        }
        
    }
    
    public static void apiFailedEmailNotifyTOCFGSupport(String userName,String exceptionMsg,String action){
        //send mail to CFG App Support
        //String userEmail ='appsupport@canaccede.com';
        system.debug('inside apiFailedEmailNotifyTOCFGSupport');
        User activeUser;
        if(!Test.isRunningTest()){
            activeUser = [Select Email From User where name = : userName limit 1];
        }
        String userEmail ='';
        userEmail ='sulbha.konodia@canaccede.com'+',';
        if(!Test.isRunningTest()){
            userEmail += activeUser.Email ;
        }else{
            userEmail = userName;
        }
        List<String> lstEmail = userEmail.split(',');
        system.debug('lstEmail'+lstEmail);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
        mail.setToAddresses(lstEmail);
        mail.setSenderDisplayName('Salesforce Support');

        mail.setSubject('API is failed');   
        mail.setUseSignature(false);
        
        mail.setHtmlBody('API is failed. Please find the below error and kindly contact with your technical team:<br/><br/>'+exceptionMsg+' '+'on action'+' '+action+'.<br/><br/><br/>Thanks,<br/>CFG support');
    
        // Send the email you have created.
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            system.debug('Exception::'+e.getMessage());
        }
        
    }
}