/**************************************************************************************************
 *
 *  Class:   WithdrawalPoCController
 *
 *  @description : This is to controll attachments, and send email to trustee from insolvancy account page for Withdrawal PoC
 *  @author : A5E Consulting
 *  @date : 04.June.2017
 
 *************************************************************************************************/
 //false positive: 
 Public class WithdrawalPoCController{
    
    // Variable to fetch data related to custom settings, exceptions
    public PoC_Package_Settings__c pocPackage{set;get;}
    Public Boolean isAnyException {set;get;}
    public Boolean isActive {set;get;}
    public String withdrawPoCInvalid {set;get;}
    public Id attachmentSelected{set;get;}
    public Insolvency_Account__c insolvAcc {set;get;}
    public List<InsolvAttachments> insolvAttachList{set;get;}
    
    //Show validation message when total attachments size is exceeded
    public Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();
    public Boolean attachSizeException{set;get;}
    public String attachSizeExceptionMessage{set;get;}
    
    //Language setting
    public List<selectOption> languageList{get;set;}
    public string language{get;set;}
    
    // Variable that are used to store emails, email subject, body and footers
    public String toEmail{set;get;}
    public String subject {set;get;}
    public String emailBody {set;get;}
    public string displayText{set;get;}
    public Map<Integer, String> frenchDates = new Map<Integer, String>{1 => 'Jan',
    2 => 'Fév',
    3 => 'Mar',
    4 => 'Avr',
    5 => 'Mai',
    6 => 'Juin',
    7 => 'Juil',
    8 => 'Août',
    9 => 'Sep',
    10 => 'Oct',
    11 => 'Nov',
    12 => 'Déc'};
    // Stores all attachments that are selected by user
    Set<Id> mySelectedAtt = new Set<Id>();
    
    /*********************************************************
    * Method description: Handles to store list of attachments selected by user
    * Parameters : none
    * return type: void
    **********************************************************/
    public void attachmentSelected(){
        if(attachmentSelected != null){
            mySelectedAtt.add(attachmentSelected );
            attachmentSelected = null;
        }
    }
    
    /*********************************************************
    * Method description: Handles to remove attachments un selected by user
    * Parameters : none
    * return type: void
    **********************************************************/
    public void attachmentRemoved(){
        if(attachmentSelected != null){
            mySelectedAtt.remove(attachmentSelected );
            attachmentSelected = null;
        }
    }
    
    // Controller to load initial values and insolvancy account details
    public WithdrawalPoCController(){   
        isAnyException  = false;
        //Trustee Office Active Check
        isActive = true;
        withdrawPoCInvalid='';
        
        subject = '';
        emailBody = '';
        
        //Populate language list
        languageList = new List<selectOption>();
        //language = languageValue;
        languageList.add(new SelectOption('en_US', 'English'));
        languageList.add(new SelectOption('fr', 'French'));
        
        config = [SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c, Run_Insolvency_Status_Validations__c
                    FROM Application_Config_Settings__c];
        //Atachment Size limit check
        attachSizeException = false;
        attachSizeExceptionMessage = config.Maximum_Email_Attachments_Size_Text__c;
        
        insolvAcc = getInsolvencyAccountDetails(ApexPages.currentPage().getParameters().get('Id'));

        insolvAttachList= new List<InsolvAttachments>();
        
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        
        // Read all attachments related to insolvacny account
        for (Attachment attchmt : [select Name,  
                            Description,
                            BodyLength,
                            createdDate 
                            from Attachment where ParentId =: insolvAcc.Id 
                            order by lastmodifieddate desc
                      ]){
                        
            InsolvAttachments temp = new InsolvAttachments();
            temp.attId = attchmt.Id;
            temp.selected =false;
            temp.fileName=attchmt.Name;
            temp.fileDesc=attchmt.Description;
            temp.fileCreatedDate = attchmt.createdDate.addSeconds(offset/1000);
            temp.displaySize = InsolvencyUtil.fileSizeToString((attchmt.BodyLength));
           
            insolvAttachList.add(temp);
        }
        system.debug('=='+insolvAttachList);
        
        // Read custom settings to use hard code values in poc package
        pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        loadTemplate(language);
    }

    /************************************************************************************
    * Method description: get insolvency account data
    * Parameters : Insolvency Account ID
    * return type: Insolvency_Account__c
    ************************************************************************************/
    public Insolvency_Account__c getInsolvencyAccountDetails (ID insolvAccId){
        Insolvency_Account__c insolvAcc = [SELECT Id, Name, Insolvency__r.Name,
                            Insolvency_Status__c,
                            Client_Identifier__c,
                            Trustee_Company__c,
                            Is_Active__c,
                     		Account_Type__c,
                            Insolvency__r.Trustee__r.Name,
                            Insolvency__r.Trustee__r.Parent.Name,
                            Insolvency__r.Trustee__r.BillingStreet, 
                            Insolvency__r.Trustee__r.BillingCity,
                            Insolvency__r.Trustee__r.BillingState, 
                            Insolvency__r.Trustee__r.BillingPostalcode,
                            Insolvency__r.Trustee__r.Communication_Preference__c, 
                            Insolvency__r.Trustee__r.Fax, 
                            Insolvency__r.Trustee__r.Business_Email__c,
                            Insolvency__r.Trustee__r.Preferred_Language__c,
                            Insolvency__r.Debtor__c, Insolvency__r.Co_Debtor__c, 
                            Claim_Amount__c, 
                            Reason_for_Claim_withdrawal__c,  Date_Claim_Withdrawal_Sent__c,
                            Debtor_1_Estate_Number__c,
                            Originator__c 
                            FROM Insolvency_Account__c 
                            WHERE Id =: insolvAccId];

        //Set language as per trustee office
        if(null != insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c){
            language = insolvAcc.Insolvency__r.Trustee__r.Preferred_Language__c;
            if(language == 'French'){
                language = 'fr';
            }else{
                language = 'en_US';
            }
        }else{
            language = 'en_US';
        }
        if(insolvAcc.Insolvency__r.Trustee__r.Communication_Preference__c == 'Fax'){
            toEmail =  formatFaxAsEmail(insolvAcc.Insolvency__r.Trustee__r.Fax);                        
        }
        else{
            toEmail =  insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
        }

        if(insolvAcc.Insolvency_Status__c != 'Withdraw PoC'){
            withdrawPoCInvalid = 'Insolvency Account status is not equal to Withdraw PoC \n';
        }
        if(insolvAcc.Reason_for_Claim_withdrawal__c == null ){
            withdrawPoCInvalid = withdrawPoCInvalid+'Reason for Claim withdrawal is not filled \n';
        }
        
        if(insolvAcc.Is_Active__c == False){ 
            isActive=false;
            withdrawPoCInvalid= withdrawPoCInvalid+ 'Trustee Office is not Active so email cannot be sent\n';
        }
        return insolvAcc;                    
    }
    /*********************************************************
    * Method description: Load email template body, subject seelcted from drop down
    * Parameters : none
    * return type: void
    **********************************************************/
    public void loadTemplate(String languageValue){
    	Set<String> fairstoneProductTypes = new Set<String>{ 'Secured', 'PL Unsecured', 'PL Secured', 'PL Auto Secured', 'Retail', 'Auto Loans' };
            
        EmailTemplate emt = new EmailTemplate();
        
        if(languageValue == 'fr'){
            emt = [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE Id =: pocPackage.Withdrawal_PoC_Template_ID_French__c];
        }else{
            emt = [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE Id =: pocPackage.Withdrawal_PoC_Template_Id__c];
        }
        
        Date dateToday = System.Today();
        // Convert DateTime to Date format ex: May 01, 2018
        String formattedDate = DateTime.newInstance(dateToday.year(),dateToday.month(),dateToday.day()).formatGMT('MMM dd, YYYY');
        
        // Merge fields used in email template
        String claimAmount = '$'+'0.00';
        List<String> args = new String[]{'0','number','###,###,###.00'};
        if(insolvAcc.Claim_Amount__c != null){
            claimAmount = '$'+String.format(insolvAcc.Claim_Amount__c.format(), args);
        }
        if(insolvAcc.Client_Identifier__c == 'Goeasy'){
                pocPackage.Client_Company_Name__c = pocPackage.Company_Name__c;
        }
        if (insolvAcc.Client_Identifier__c == 'Fairstone' && fairstoneProductTypes.contains(insolvAcc.Account_Type__c)) {
            pocPackage.Client_Company_Name__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
            pocPackage.Client_Company_Name_French__c = pocPackage.Fairstone_New_Product_Company_Detail__c;
        }
        Map<String, String> emailMergeFields  = new Map<String, String>{
                                                    '{!TODAY()}' => formattedDate,
                                                    '{!Insolvency__r.Trustee__r.Parent.Name}' => insolvAcc.Insolvency__r.Trustee__r.Parent.Name,
                                                    '{!insolvAcc.Insolvency__r.Trustee__r.Name}' => (insolvAcc.Insolvency__r.Trustee__r.Name != null ? insolvAcc.Insolvency__r.Trustee__r.Name : ''),
                                                    '{!Insolvency__r.Trustee__r.BillingStreet}' => insolvAcc.Insolvency__r.Trustee__r.BillingStreet,
                                                    '{!Insolvency__r.Trustee__r.BillingCity}' => insolvAcc.Insolvency__r.Trustee__r.BillingCity,
                                                    '{!Insolvency__r.Trustee__r.BillingState}' => insolvAcc.Insolvency__r.Trustee__r.BillingState,
                                                    '{!Insolvency__r.Trustee__r.BillingPostalcode}' => insolvAcc.Insolvency__r.Trustee__r.BillingPostalcode,
                                                    '{!insolv.Debitors}' => (insolvAcc.Insolvency__r.Debtor__c != null ? insolvAcc.Insolvency__r.Debtor__c : '') + (insolvAcc.Insolvency__r.Co_Debtor__c != null ? (insolvAcc.Insolvency__r.Debtor__c != null ? ',' : '')+insolvAcc.Insolvency__r.Co_Debtor__c : ''),
                                                    '{!Display_Text_As_Per_Bank}' => displayText(),
                                                    '{!pocPackage.Client_Company_Name__c}' => pocPackage.Client_Company_Name__c,
                                                    '{!pocPackage.Company_Name__c}' => pocPackage.Company_Name__c,
                                                    '{!pocPackage.Client_Company_Name_French__c}' => pocPackage.Client_Company_Name_French__c,    
                                                    '{!pocPackage.CFG_Office_Phone_Number__c}' => pocPackage.CFG_Office_Phone_Number__c.replace('-','.'),
                                                    '{!pocPackage.CFG_Office_Address_1__c}'=> pocPackage.CFG_Office_Address_1__c,
                                                    '{!pocPackage.CFG_Office_Email_Address__c}' => pocPackage.CFG_Office_Email_Address__c,
                                                    '{!pocPackage.CFG_Office_City__c}' => pocPackage.CFG_Office_City__c,
                                                    '{!pocPackage.CFG_Office_Province__c}' => pocPackage.CFG_Office_Province__c,
                                                    '{!pocPackage.CFG_Office_Postal_Code__c}' => pocPackage.CFG_Office_Postal_Code__c,                                                    
                                                    '{!insolv.EstateNumber}' => insolvAcc.Insolvency__r.Name,
                                                    '{!insolvAcc.Reason_for_Claim_withdrawal__c}' => (insolvAcc.Reason_for_Claim_withdrawal__c != null? insolvAcc.Reason_for_Claim_withdrawal__c  : ''),
                                                    '{!insolvAcc.Claim_Amount__c}' => claimAmount,
                                                    '{!pocPackage.CFG_Office_Name__c}' => pocPackage.CFG_Office_Name__c,
                                                    '{!insolvAcc.Name}' => insolvAcc.Name,
                                                    '{!insolvAcc.Originator__c}' => insolvAcc.Originator__c
                                                    };
                                                    
            subject = emt.subject.replace('{!insolv.EstateNumber}', insolvAcc.Insolvency__r.Name);
             Datetime dateNow = Datetime.now();
             string formattedDateTodayHeader = String.valueOf(frenchDates.get(dateNow.month()) + ' '+dateNow.day()+' '+String.valueOf(dateNow.year()));
            emailBody = emt.HtmlValue;
            // replace merge fields in email template with actual values in Insolvency Account
          if(languageValue == 'fr'){   
            emailBody = emailBody.replace('{!TODAY()}',formattedDateTodayHeader);
          }
            for(String str : emailMergeFields.keySet()){
                emailBody = emailBody.replace(str, (emailMergeFields.get(str) != null ? emailMergeFields.get(str) :''));
            }
            /*if(insolvAcc.Client_Identifier__c == 'Canaccede'){
                //emailBody = emailBody.replace('Creditor- '+pocPackage.Client_Company_Name__c+', Account Number: '+insolvAcc.Name+',amount '+insolvAcc.Claim_Amount__c,'Creditor – '+pocPackage.Client_Company_Name__c+', assignee of ‘'+insolvAcc.Originator__c+'’');    
                emailBody = emailBody.replace('{!Display_Text_As_Per_Bank}',displayText);
            }
            */
            
    }
    
    
    //populate value in map per bank and language
    public String displayText(){
    
        if(insolvAcc.Client_Identifier__c == 'Canaccede' && language == 'fr'){
            return 'Créancier- {!pocPackage.Client_Company_Name_French__c}, cessionnaire de \'{!insolvAcc.Originator__c}\', Numéro de compte: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Montant {!insolvAcc.Claim_Amount__c}';
        }
        if(insolvAcc.Client_Identifier__c != 'Goeasy' && insolvAcc.Client_Identifier__c != 'Canaccede' && language == 'fr'){
            return 'Créancier- {!pocPackage.Client_Company_Name_French__c}, Numéro de compte: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Montant {!insolvAcc.Claim_Amount__c}';
        }
        if(insolvAcc.Client_Identifier__c == 'Canaccede' && language != 'fr'){
            return 'Creditor- {!pocPackage.Client_Company_Name__c}, Assignee of \'{!insolvAcc.Originator__c}\', Account Number: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Amount {!insolvAcc.Claim_Amount__c}';
        }
        if(insolvAcc.Client_Identifier__c != 'Goeasy' && insolvAcc.Client_Identifier__c != 'Canaccede' && language != 'fr'){
            return 'Creditor- {!pocPackage.Client_Company_Name__c}, Account Number: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Amount {!insolvAcc.Claim_Amount__c}';
        }
        if(insolvAcc.Client_Identifier__c == 'Goeasy' && language == 'fr'){
            return 'Créancier- {!pocPackage.Company_Name__c}, Numéro de compte: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Montant {!insolvAcc.Claim_Amount__c}';
        }
        if(insolvAcc.Client_Identifier__c == 'Goeasy' && language != 'fr'){
            return 'Creditor- {!pocPackage.Company_Name__c}, Account Number: {!insolvAcc.Name},<br/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Amount {!insolvAcc.Claim_Amount__c}';
        }
        return null;
    }
    
    // template related variables
    Map<Id, EmailTemplate> emailTemplateMap = new Map<Id, EmailTemplate>();
    
    
    
    // Method implementes functionality to send email to trustee with selected attachments
    public PageReference sendEmail() {
        attachSizeException = false;
        //Atachment Size limit check
        Decimal totalFilesize = 0;
        Decimal maxAttachSize = config.Maximum_Email_Attachments_Size__c;
        for(Attachment selectedAtt: [SELECT Name, Body, BodyLength FROM Attachment WHERE Id IN : mySelectedAtt]){
          totalFilesize = totalFilesize + selectedAtt.BodyLength;
        }
        
        if(totalFilesize > maxAttachSize){
          attachSizeException = true;
            return null;
        } 
        else{
          attachSizeException = false;
        }
        
        //Don't run validation rules
        //Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c ];
        /*
        // Read and store actuall value about running validation rule
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
         //Don't run InsolvencyAccountTrigger
        InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
        
        
        try{
            isAnyException  = false;
            
            // Use single email message feature of salesforce
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toEmail.endsWith(';')){
                toEmail = toEmail.subString(0, toEmail.length()-1);
            }
            List<String> toEmails = new List<String>(toEmail.split(';'));
            
            // read email body from VF page and bind with format of new lines
            String emailBodyCustomized ='';
            for(String s: emailBody.split('\n')){
                emailBodyCustomized = emailBodyCustomized +s+'<br/>';
            }
            mail.setToAddresses(toEmails);
            mail.setOrgWideEmailAddressId(pocPackage.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(subject);
            
            
            String htmlBody = '<body style="clear:both;">'+emailBodyCustomized +'</body>';
            mail.setHTMLBody(htmlBody );
            
            // Set activity tru to create activity once email is send
            mail.setSaveAsActivity(true);
            mail.setWhatId(insolvAcc.Id);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            // Attach files to email
            for(Attachment attObj : [SELECT Name, Body FROM Attachment WHERE Id IN : mySelectedAtt]){
                    
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(attObj .Name);
                    efa.setBody(attObj.Body);
                    fileAttachments.add(efa);
                
            }
            
            if(!fileAttachments.isEmpty()){
                mail.setFileAttachments(fileAttachments);
            }
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            // Update status value of Insolvancy account
            insolvAcc.Insolvency_Status__c = 'Claim Withdrawn';
            insolvAcc.Insolvency_Status_Last_Changed__c = System.now();
            //insolvAcc.Date_Claim_Withdrawal_Sent__c = Date.valueOf(System.now());
            insolvAcc.Date_Claim_Withdrawal_Sent__c = System.Today();
            update insolvAcc;
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */
            
            // Revert back custom setting value with previous value
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            
        }
        catch(Exception ex){
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;            
            */
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
           
            system.debug('===='+ex.getMessage());
            isAnyException = true;
            Insolvency_Error__c inslErr = new Insolvency_Error__c();
            inslErr.Insolvency_Account__c = insolvAcc.Id;
            inslErr.Action__c = 'Email Trustee';
            inslErr.Error__c = 'Exception: ' + ex.getTypeName();
            inslErr.Error__c += '\nMessage: ' + ex.getMessage();
            inslErr.Error__c += '\nStack trace:\n' + ex.getStackTraceString();
            
            try{
                insert inslErr;
            }
            catch(Exception inslErrEx){
                system.debug('inslErr Message :'+inslErrEx.getMEssage());
            }
        }
        
        if(!Test.isRunningTest()) {
            // Create Attachment against activity history on Insolvency Account
            Task emailTask = [select id from Task where whatID =: insolvAcc.id ORDER BY CreatedDate DESC limit 1];
            EmailMessage emailmsg = [select Id, parentId from EmailMessage where activityId = : emailTask.Id];
        
            list<Attachment> emailMsgAttachments = new list<Attachment>();
            for(Attachment emailMsgAtt : [SELECT Name, Body, ParentId FROM Attachment WHERE Id IN : mySelectedAtt]){
                Attachment emailAttachment = new Attachment();
                emailAttachment.body = emailMsgAtt.body;
                emailAttachment.Name = emailMsgAtt.Name;
                emailAttachment.ParentId = emailmsg.id; 
                emailAttachment.isPrivate = false; 
                emailMsgAttachments.add(emailAttachment);
            }         
            if(emailMsgAttachments.size()>0){
                insert emailMsgAttachments;
            }
        }

        return null;
    }
    
    // Wrapper class used to frame attachments with checkboxes 
    public class InsolvAttachments{
        public Boolean selected{set;get;}
        public Id attId{set;get;}
        public String filename{set;get;}
        public String fileDesc{set;get;}
        public DateTime fileCreatedDate {set;get;}
        public String displaySize {set;get;}
    }
    
    //Utility method to format Fax As Email Address
    private static string formatFaxAsEmail(String faxNo){
      String formattedFax = faxNo;
        if(String.isNotBlank(formattedFax)){
          formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            
            Application_Config_Settings__c acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c];
            formattedFax =  formattedFax + acs.Domain_Name__c;
        }  
        return formattedFax;
    }
    
    //change the language
    public void changeLanguage(){
        subject = '';
        emailBody = '';
        
        if(language == 'fr'){
            //languageValue = 'fr';
            loadTemplate(language );
        }else{
            //languageValue = 'en_US';
            loadTemplate(language);
        }
    }
}