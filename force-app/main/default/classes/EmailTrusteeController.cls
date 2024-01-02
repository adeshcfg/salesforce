/**************************************************************************************************
*
*  Class:   EmailTrusteeController
*
*  @description : This is a controller class to send emails to trustee from Insolvency account page 
*  @author : A5E Consulting
*  @date : 09/26/2017

*************************************************************************************************/
public class EmailTrusteeController{
    
    // Variable to fetch data related to custom settings, exceptions
    public PoC_Package_Settings__c pocPackage{set;get;}
    public Boolean isSelectedAtt {set;get;}
    
    //Show validation message when total attachments size is exceeded
    public Application_Config_Settings__c config;// = Application_Config_Settings__c.getOrgDefaults();
    public Boolean attachSizeException{set;get;}
    public String attachSizeExceptionMessage{set;get;}
    
    public Boolean isAnyException {set;get;}
    public Id attachmentSelected{set;get;}
    public Insolvency_Account__c insolvAcc {set;get;}
    public List<InsolvAttachments> insolvAttachList{set;get;}
    public Boolean docException {set;get;}
    public Boolean accStatementError {set;get;}
    public Boolean isAmemdedClaim {set;get;}
    public Boolean isPocRequired {set;get;}
    public Boolean isActive {set;get;}
    // Variable that are used to store emails, email subject, body and footers
    public String toEmail{set;get;}
    public String toEmailBefore{set;get;}
    public String toFollowUpEmail{set;get;}
    public String subject {set;get;}
    public String htmlEmailheader {set;get;}
    public String htmlEmailfooter {set;get;}
    public String emailBody {set;get;}
    public String emailName {set;get;}
    
    
    // Stores all attachments that are selected by user
    public Set<Id> mySelectedAtt = new Set<Id>();
    
    //template lists for which Trustee follow up email is required
    list<Id> followUpEmailRequiredTemplatesList {get; set;}
    public Boolean flagForTrusteeFollowUpEmail {set;get;}
    
    //template lists for with or without header
    list<Id> insolTemplateWithHeaderList{get; set;}
    list<Id> insolTemplateWithoutHeaderList{get; set;}
    
    //template lists for mandatory attchments list
    list<Id> insolTemplateWithManAttachList{get; set;}
    
    // template related variables
    public List<selectOption> templates {set;get;}
    public Id selectedTemplate {set;get;}
    map<Id, EmailTemplate> emailTemplateMap = new map<Id, EmailTemplate>();
    
    //Language setting
    public List<selectOption> languageList{get;set;}
    public string language{get;set;}
    
    // Controller to load initial values and insolvancy account details
    public EmailTrusteeController(){
    
        isAnyException  = false;
        isAmemdedClaim = false;
        isPocRequired = false;
        flagForTrusteeFollowUpEmail = false;
        //Atachment Size limit check
        attachSizeException = false;
        //TrusteeOffice Active Check
        isActive = true;
        
        subject = '';
        emailBody = '';
        htmlEmailheader = '';
        
        //Populate language list
        languageList = new List<selectOption>();
        languageList.add(new SelectOption('en_US', 'English'));
        languageList.add(new SelectOption('fr', 'French'));
        
        insolTemplateWithHeaderList = new list<ID>();
        insolTemplateWithoutHeaderList = new list<ID>();
        config = [SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c,Run_Insolvency_Status_Validations__c,
                    Domain_Name__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        
        attachSizeExceptionMessage = config.Maximum_Email_Attachments_Size_Text__c;
        
        insolvAcc = [SELECT Id, Name,
                     Secured_Name__c,Insolvency__r.Trustee__r.ParentId,Is_Active__c, Insolvency__r.Trustee__r.Preferred_Language__c,
                     Insolvency__r.Trustee__r.Communication_Preference__c, Insolvency_Account__c.Borrower_Primary__c,
                     Insolvency__r.Debtor__c, Balance_Owed__c, Insolvency__r.Trustee__r.Fax, Insolvency__r.Trustee__r.Business_Email__c,
                     Insolvency__r.Trustee__r.Follow_up_Email__c,Insolvency_Status__c, Insolvency__r.Name, Client_Identifier__c,Reason_for_No_PoC_Required_Dropdown__c,
                     Reason_for_No_PoC_Required__c,Amended_Claim_Flag__c, Insolvency_Type__c,
                     Claim_Filed_Date__c //for SLA tracking
                     FROM Insolvency_Account__c 
                     WHERE Id =: ApexPages.currentPage().getParameters().get('Id') FOR UPDATE];
        
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
            toFollowUpEmail = insolvAcc.Insolvency__r.Trustee__r.Follow_up_Email__c;
        }
        toEmailBefore = toEmail;
    
        //checking if Trustee Office is Active
        if(insolvAcc.Is_Active__c == False){ 
            //system.debug('Trustee Office is not Active so email cannot be sent');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Trustee Office is not Active so email cannot be sent')); 
            isActive=false;
        }
        insolvAttachList = new List<InsolvAttachments>();
        
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        
        // Read all attachments related to insolvacny account
        for (Attachment attchmt : [select Name, 
                                   Body, BodyLength,  
                                   Description,
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
        
        // Read custom settings to use hard code values in poc package
        pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        system.debug('pocPackage::'+pocPackage);
        //loadEmailTemplates();
        changeLanguage();
        //emailTemplatechanged();
    } 
    
    //Loads template which names start with Insolvency
    public void loadEmailTemplates(){
        
        //Fetcth Id's List for With or Without Header
        string idWithHeaderList = pocPackage.Insolvency_Template_Header__c;
        insolTemplateWithHeaderList = idWithHeaderList.split(',');
        string idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader__c; 
        insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');
        
        //Fetcth Id's List for Attachment Required Email Templates
        String idWithMandAttchList = pocPackage.Attachment_Required_Email_Templates__c;
        insolTemplateWithManAttachList =  idWithMandAttchList.split(',');
        
        //Default Template
        selectedTemplate = insolTemplateWithoutHeaderList.get(0);
        
        templates = new List<selectOption>();
        //templates.add(new SelectOselectedTemplateption('','--select--'));
        //for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Name LIKE 'Insolvency %' OR Name LIKE 'POC %') AND (NOT NAME LIKE '%Error%')])
        for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate 
                                       WHERE (Id IN: insolTemplateWithHeaderList OR Id IN: 
                                              insolTemplateWithoutHeaderList /*OR Id IN: insolTemplateWithManAttachList */) order by Name]){
            
            emailTemplateMap.put(emailTemp.Id, emailTemp);            
            templates.add(new SelectOption(emailTemp.Id,emailTemp.Name));
        }
    } 
    
    //Loads French template which names start with Insolvency
    public void loadFrenchEmailTemplates(){
        
        //Fetcth Id's List for With or Without Header
        string idWithHeaderList = pocPackage.Insolvency_Template_Header_French__c;
        if(String.isNotBlank(idWithHeaderList)){
            insolTemplateWithHeaderList = idWithHeaderList.split(',');    
        }
        string idWithoutHeaderList = pocPackage.Insolvency_Template_WoHeader_French__c; 
        if(String.isNotBlank(idWithoutHeaderList)){
            insolTemplateWithoutHeaderList = idWithoutHeaderList.split(',');    
        }
        
        //Fetcth Id's List for Attachment Required Email Templates
        String idWithMandAttchList = pocPackage.Attachment_Required_Email_Templates__c;
        if(String.isNotBlank(idWithMandAttchList)){
            insolTemplateWithManAttachList =  idWithMandAttchList.split(',');    
        }
        
        //Default Template
        if(insolTemplateWithoutHeaderList != NULL && !insolTemplateWithoutHeaderList.isEmpty()){
            selectedTemplate = insolTemplateWithoutHeaderList.get(0);    
        }
        
        templates = new List<selectOption>();
        //templates.add(new SelectOption('','--select--'));
        //for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Name LIKE 'Insolvency %' OR Name LIKE 'POC %') AND (NOT NAME LIKE '%Error%')])
        if(insolTemplateWithHeaderList != NULL){
            for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Id IN: insolTemplateWithHeaderList OR Id IN: insolTemplateWithoutHeaderList /*OR Id IN: insolTemplateWithManAttachList */)order by Name]){
                emailTemplateMap.put(emailTemp.Id, emailTemp);            
                templates.add(new SelectOption(emailTemp.Id,emailTemp.Name));
            }    
        }
        
    }   
    
   
    //Load email template body, subject seelcted from drop down
    public void emailTemplatechanged(){
        
        flagForTrusteeFollowUpEmail = false;
        
        //get ID's of template for follow-up email.
        string idforTrusteeFollowupEmail =pocPackage.Follow_Up_Email_Required_Templates__c;
        system.debug('idforTrusteeFollowupEmail:::'+idforTrusteeFollowupEmail);
        //checking if the selected tepmplate needs trustee follow-up email.
        if(idforTrusteeFollowupEmail != null){
            followUpEmailRequiredTemplatesList = idforTrusteeFollowupEmail.split(',');
        }           
        
        if(followUpEmailRequiredTemplatesList != Null){
            if(followUpEmailRequiredTemplatesList.contains(selectedTemplate)){
                flagForTrusteeFollowUpEmail = true;
            }
        else{
                flagForTrusteeFollowUpEmail = false;
            }
         }       
        system.debug('flagForTrusteeFollowUpEmail::'+flagForTrusteeFollowUpEmail);
        if(toFollowUpEmail != null && flagForTrusteeFollowUpEmail == true){       
            toEmail = toFollowUpEmail;
        }
        else{
            toEmail = toEmailBefore;
        }
        //system.debug('emailTemplateMap::'+emailTemplateMap);
        system.debug('selectedTemplate::'+selectedTemplate);
        //templateRequireTrusteeEmailList
        if(emailTemplateMap.containsKey(selectedTemplate )){
   
            EmailTemplate emt = emailTemplateMap.get(selectedTemplate );
            subject = emt.subject;
            system.debug('subject'+subject);
            if(Test.isRunningTest()){
                subject = '{!Insolvency_Account__c.Secured_Name__c},{!Insolvency_Account__c.Name},{!Insolvency_Account__c.Borrower_Primary__c},{!Insolvency__r.Name},{!Insolvency__r.Debtor__c},{!Insolvency_Account__c.Insolvency_Type__c}';
            }
            if(subject != null){
                
                if(subject.contains('{!Insolvency_Account__c.Secured_Name__c}')){
                    subject = subject.replace('{!Insolvency_Account__c.Secured_Name__c}', (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c:''));
                } 
                
                if(subject.contains('{!Insolvency_Account__c.Name}')){
                    subject = subject.replace('{!Insolvency_Account__c.Name}', (insolvAcc.Name != null ? insolvAcc.Name:''));
                }
                
                if(subject.contains('{!Insolvency_Account__c.Borrower_Primary__c}')){
                    subject = subject.replace('{!Insolvency_Account__c.Borrower_Primary__c}', (insolvAcc.Borrower_Primary__c!= null ? insolvAcc.Borrower_Primary__c:''));
                }
                
                if(subject.contains('{!Insolvency__r.Name}')){
                    subject = subject.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);
                }
                
                if(subject.contains('{!Insolvency__r.Debtor__c}')){
                    subject = subject.replace('{!Insolvency__r.Debtor__c}', insolvAcc.Insolvency__r.Debtor__c);
                }
                
                if(insolvAcc.Insolvency_Type__c != null){
                    if(subject.contains('{!Insolvency_Account__c.Insolvency_Type__c}')){
                            subject = subject.replace('{!Insolvency_Account__c.Insolvency_Type__c}', insolvAcc.Insolvency_Type__c);
                    }
                }
            }
        
            emailBody = emt.body;
            emailName = emt.Name;
            system.debug('emailBody:::'+emailBody);
            String[] emailContent = emt.HTMLValue.split('<body>');
            system.debug('emailContent='+emailContent );
            if(emailContent.size()==1){
            htmlEmailheader = emailContent[0];
            system.debug('htmlEmailheader ='+htmlEmailheader );
            }
            if(emailContent.size()==2){
            emailContent = emailContent[1].split('</body>');
            system.debug('emailContent ='+emailContent );
            
            htmlEmailFooter = emailContent[1];           
            system.debug('htmlEmailFooter ='+htmlEmailFooter );
            }
            // replace all merge fields that are in email template
            if(Test.isRunningTest()){
                emailBody = '{!Insolvency_Account__c.Balance_Owed__c},{!Insolvency_Account__c.Secured_Name__c},{!pocPackage.CFG_Office_Fax_Number__c},{!pocPackage.CFG_Office_Phone_Number__c},{!Insolvency__r.Name},{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c},{!Insolvency_Account__c.Reason_for_No_PoC_Required__c},{!pocPackage.CFG_Office_Address_1__c},{!pocPackage.CFG_Office_Address__c},{!pocPackage.Name},{!pocPackage.CFG_Office_City__c},{!pocPackage.CFG_Office_Province_Short_Code__c},{!pocPackage.CFG_Office_Postal_Code__c},{!pocPackage.CFG_Payment_Postal_Code__c},{!pocPackage.CFG_Office_Email_Address__c}';
            }
            if (emailBody != null){
                if(emailBody.contains('{!Insolvency_Account__c.Balance_Owed__c}')){
                    emailBody = emailBody.replace('{!Insolvency_Account__c.Balance_Owed__c}', '$'+String.valueOf(insolvAcc.Balance_Owed__c));
                }
                
                if(emailBody.contains('{!Insolvency_Account__c.Secured_Name__c}')){
                    emailBody = emailBody.replace('{!Insolvency_Account__c.Secured_Name__c}', (insolvAcc.Secured_Name__c != null ? insolvAcc.Secured_Name__c:''));
                }
                
                if(emailBody.contains('{!Insolvency__r.Name}')){
                    emailBody = emailBody.replace('{!Insolvency__r.Name}', insolvAcc.Insolvency__r.Name);    
                }
                
                if(emailBody.contains('{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c}')){
                    emailBody = emailBody.replace('{!Insolvency_Account__c.Reason_for_No_PoC_Required_Dropdown__c}', (insolvAcc.Reason_for_No_PoC_Required_Dropdown__c!= null ? insolvAcc.Reason_for_No_PoC_Required_Dropdown__c:''));    
                }
                
                if(emailBody.contains('{!Insolvency_Account__c.Reason_for_No_PoC_Required__c}')){
                    emailBody = emailBody.replace('{!Insolvency_Account__c.Reason_for_No_PoC_Required__c}', (insolvAcc.Reason_for_No_PoC_Required__c!= null ? insolvAcc.Reason_for_No_PoC_Required__c:''));    
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Address_1__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Address_1__c}', pocPackage.CFG_Office_Address_1__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Address__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Address__c}',(pocPackage.CFG_Office_Address__c!= null ? pocPackage.CFG_Office_Address__c:''));         
                }
                
                if(emailBody.contains('{!pocPackage.Name}')){       
                    emailBody = emailBody.replace('{!pocPackage.Name}', pocPackage.Name);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_City__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_City__c}', pocPackage.CFG_Office_City__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Province_Short_Code__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Province_Short_Code__c}', pocPackage.CFG_Office_Province_Short_Code__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Postal_Code__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Postal_Code__c}', pocPackage.CFG_Office_Postal_Code__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Payment_Postal_Code__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Payment_Postal_Code__c}', pocPackage.CFG_Payment_Postal_Code__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Email_Address__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Email_Address__c}', pocPackage.CFG_Office_Email_Address__c);         
                }
                
                if(emailBody.contains('{!pocPackage.Company_Name__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.Company_Name__c}', pocPackage.Company_Name__c);         
                }
                
                if(emailBody.contains('{!pocPackage.Client_Company_Name_French__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.Client_Company_Name_French__c}', pocPackage.Client_Company_Name_French__c);         
                }
                
                if(emailBody.contains('{!pocPackage.Client_Company_Name__c}')){       
                    emailBody = emailBody.replace('{!pocPackage.Client_Company_Name__c}', pocPackage.Client_Company_Name__c);         
                }
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Fax_Number__c}')){        
                    String numberVal = pocPackage.CFG_Office_Fax_Number__c;
                    if(language == 'fr'){
                        numberVal = numberVal.replace('-', '.');
                    }
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Fax_Number__c}', numberVal );         
                }  
                
                if(emailBody.contains('{!pocPackage.CFG_Office_Phone_Number__c}')){     
                               
                    String numberVal = pocPackage.CFG_Office_Phone_Number__c;
                    if(language == 'fr'){
                        numberVal = numberVal.replace('-', '.');
                    }
                    emailBody = emailBody.replace('{!pocPackage.CFG_Office_Phone_Number__c}', numberVal);
                }  
                
                if(emailName == 'Notice Received to Prove Claim' && insolvAcc.Client_Identifier__c == 'Canaccede'){      
                   if(language == 'fr'){
                       emailBody = emailBody.replace('La raison pour laquelle nous n\'avons pas déposé une réclamation au nom de Scotiabank est', 'La raison pour laquelle Canaccede n\'a pas déposé une preuve de réclamation est');
                   }else{
                       emailBody = emailBody.replace('The reason that we have not filed a claim on behalf of Scotiabank is','The reason Canaccede has not filed a claim is');        
                   }
                }

                if(emailName == 'Additional Information Required'){
                    if(insolvAcc.Client_Identifier__c == 'Canaccede') {
                        if(language == 'fr') {
                            emailBody = emailBody.replace('{!Additional_Info_Text}', System.Label.Canaccede_Additional_Info_French_Text);
                        }
                        else {
                            emailBody = emailBody.replace('{!Additional_Info_Text}', System.Label.Canaccede_Additional_Info_Text);
                        }
                    }
                    else {
                        if(language == 'fr') {
                            emailBody = emailBody.replace('{!Additional_Info_Text}', 'Comme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' + pocPackage.Client_Company_Name__c);
                        }
                        else {
                            emailBody = emailBody.replace('{!Additional_Info_Text}','As you are aware, Canaccede International Management Ltd is processing '+ pocPackage.Client_Company_Name__c + ' insolvent accounts');
                        }
                    }
                }
                
                if(emailName == 'Creditor Package Request'){
                    if(insolvAcc.Client_Identifier__c == 'Canaccede'){  
                        emailBody = emailBody.replace('{!Extra_Line_Except_Canaccede}','');
                    }
                    else{
                        if(language == 'fr'){
                            emailBody = emailBody.replace('{!Extra_Line_Except_Canaccede}','\nComme vous le savez, Canaccede International Management Ltd. traite les comptes insolvables de ' + getBankName() + '.\n');
                        }else{
                            emailBody = emailBody.replace('{!Extra_Line_Except_Canaccede}','\nAs you are aware, Canaccede International Management Ltd is processing ' + getBankName() + ' insolvent accounts.\n');
                        }
                    }
                }
            }  
      
            system.debug('emailBody::::'+emailBody);
            system.debug('emt.Id=='+emt.Id);
            system.debug('insolTemplateWithHeaderList=='+insolTemplateWithHeaderList);
           
            if(insolTemplateWithHeaderList.contains(emt.Id)){
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Name__c}', (pocPackage.CFG_Office_Name__c != null ? pocPackage.CFG_Office_Name__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Address_1__c}', (pocPackage.CFG_Office_Address_1__c != null ? pocPackage.CFG_Office_Address_1__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_City__c}', (pocPackage.CFG_Office_City__c != null ? pocPackage.CFG_Office_City__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Province__c}', (pocPackage.CFG_Office_Province__c != null ? pocPackage.CFG_Office_Province__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Postal_Code__c}', (pocPackage.CFG_Office_Postal_Code__c != null ? pocPackage.CFG_Office_Postal_Code__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Phone_Number__c}', (pocPackage.CFG_Office_Phone_Number__c != null ? pocPackage.CFG_Office_Phone_Number__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Fax_Number__c}', (pocPackage.CFG_Office_Fax_Number__c != null ? pocPackage.CFG_Office_Fax_Number__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Website__c}', (pocPackage.CFG_Office_Website__c != null ? pocPackage.CFG_Office_Website__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Address__c}', (pocPackage.CFG_Office_Address__c != null ? pocPackage.CFG_Office_Address__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Office_Province_Short_Code__c}', (pocPackage.CFG_Office_Province_Short_Code__c != null ? pocPackage.CFG_Office_Province_Short_Code__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.CFG_Payment_Postal_Code__c}', (pocPackage.CFG_Payment_Postal_Code__c != null ? pocPackage.CFG_Payment_Postal_Code__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!pocPackage.Client_Company_Name__c}', (pocPackage.Client_Company_Name__c != null ? pocPackage.Client_Company_Name__c : ''));
            }

            system.debug('htmlEmailheader:::'+htmlEmailheader);
        }
    }
    
    public String getBankName(){
        if(insolvAcc.Client_Identifier__c == 'Scotia Bank' || insolvAcc.Client_Identifier__c == 'SDA' || insolvAcc.Client_Identifier__c == 'SPL'){
            if(language == 'fr'){
                return 'la Banque de Nouvelle-Écosse';
            }else{
                return 'Bank of Nova Scotia';
            }
            
        }else if(insolvAcc.Client_Identifier__c == 'Fairstone'){
            if(language == 'fr'){
                return 'Fairstone';
            }else{
                return 'Fairstone';
            }
            
        }else if(insolvAcc.Client_Identifier__c == 'Goeasy'){
            if(language == 'fr'){
                return 'Easyhome/Easyfinancial Services Ltd';
            }else{
                return 'Easyhome/Easyfinancial Services Ltd';
            }
            
        }else if(insolvAcc.Client_Identifier__c == 'Canadian Tire'){
            if(language == 'fr'){
                return 'la Banque Canadian Tire';
            }else{
                return 'Canadian Tire Bank';
            }
            
        }
        
        return null;
    }
    
    // Method implementes functionality to send email to trustee with selected attachments
    public PageReference sendEmail() {
        accStatementError = false;
        docException = false;
        attachSizeException = false;
        isPocRequired = false;
        isAmemdedClaim = false;
        
        if(emailName == 'Amended Proof of Claim' && insolvAcc.Amended_Claim_Flag__c != true){
            isAmemdedClaim = true;
            isPocRequired = false;
            return null;
        }
        
        /*
        if(emailName == 'Notice Received to Prove Claim' && insolvAcc.Insolvency_Status__c != 'No PoC Required'){
            isPocRequired = true;
            isAmemdedClaim = false;
            return null;
        }
        */
                
        //to check if NovaScotia trustee
        if(checkEligibleTrustee()){
            if(checkAttachmentForAccState()){
                accStatementError = true;
                return null;
            } 
        }  
        
        //send Email with selected attachments for header templates
        if(insolTemplateWithManAttachList.contains(selectedTemplate)){    
            if(checkAttachment()){
                docException = true;
                return null;
            }
        }
        
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
        //InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
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
            if (emailBody != null){
                for(String s: emailBody.split('\n')){
                    emailBodyCustomized = emailBodyCustomized +s+'<br/>';
                }
            }
            mail.setToAddresses(toEmails);
            mail.setOrgWideEmailAddressId(pocPackage.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(subject);
            
            if(htmlEmailheader == null){
                htmlEmailheader ='';
            }
            if(htmlEmailFooter == null){
                htmlEmailFooter ='';
            }
            
            String htmlBody = htmlEmailheader +'<body style="clear:both;">'+ emailBodyCustomized +'</body>'+htmlEmailFooter ;
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
            
            mail.setFileAttachments(fileAttachments);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
                if(insolTemplateWithManAttachList.contains(selectedTemplate)){  
                    //if(insolvAcc.Insolvency_Status__c == 'PoC Package Generated'){
                    EmailTrusteeController.updateInsolvencyAccount(insolvAcc.Id,mySelectedAtt);
                    //}
                }
                
                // Create Attachment against activity history on Insolvency Account
                List<Task> emailTask = [select id from Task where whatID =: insolvAcc.Id ORDER BY CreatedDate DESC limit 1];
                System.debug('emailTask--'+emailTask);
                List<EmailMessage> emailmsg = [select Id, parentId from EmailMessage where activityId = : emailTask[0].Id];
                
                list<Attachment> emailMsgAttachments = new list<Attachment>();
                for(Attachment emailMsgAtt : [SELECT Name, Body, ParentId, Description FROM Attachment WHERE Id IN : mySelectedAtt]){
                    Attachment emailAttachment = new Attachment();
                    emailAttachment.body = emailMsgAtt.body;
                    emailAttachment.Name = emailMsgAtt.Name;
                    emailAttachment.Description = emailMsgAtt.Description;
                    emailAttachment.ParentId = emailmsg[0].id; 
                    emailAttachment.isPrivate = false; 
                    emailMsgAttachments.add(emailAttachment);
                }  
                
                if(emailMsgAttachments.size()>0){
                    insert emailMsgAttachments;
                } 
           
        }
        catch(Exception ex){
            
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
        
        /*
        config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
        update config;
        */                 
        
        return null;
    }
    
    // This method updates insolvency Account and inserts attachment against EmailMessages
    @future
    private static void updateInsolvencyAccount(Id insonvAccId, Set<Id> mySelectedAtt){
    
        //Querying Insolvency Account again as this is a future method and different transaction
        
        List<Insolvency_Account__c> insolvAccToUpdate = [Select id,Insolvency_Status__c,Insolvency_Status_Last_Changed__c,
                                        Claim_Filed_Date__c, Do_Not_Run_Status_Validation__c FROM Insolvency_Account__c
                                        WHERE Id =:insonvAccId FOR UPDATE];
        system.debug('@@@changed1'+insolvAccToUpdate);
        
        if(insolvAccToUpdate!= null && insolvAccToUpdate.size() > 0){
            if(insolvAccToUpdate[0].Insolvency_Status__c == 'PoC Package Generated'){
                insolvAccToUpdate[0].Insolvency_Status__c = 'Claim Filed';
                insolvAccToUpdate[0].Insolvency_Status_Last_Changed__c = System.now();
                        
                if(insolvAccToUpdate[0].Claim_Filed_Date__c == null){
                    insolvAccToUpdate[0].Claim_Filed_Date__c = System.now();
                    insolvAccToUpdate[0].Claim_Filed_By__c = UserInfo.getUserId();
                }
                insolvAccToUpdate[0].Do_Not_Run_Status_Validation__c = True;
                
                update insolvAccToUpdate;
                system.debug('@@@changed'+insolvAccToUpdate);
            }
        }
    }
    
    //Handles to store list of attachments selected by user
    public void attachmentSelected(){
        if(attachmentSelected != null){
            mySelectedAtt.add(attachmentSelected );
            attachmentSelected = null;
        }
    }
    
    //Handles to remove attachments un selected by user
    public void attachmentRemoved(){
        if(attachmentSelected != null){
            mySelectedAtt.remove(attachmentSelected );
            attachmentSelected = null;
        }
    }
    
    //Utility method to format Fax As Email Address
    private static string formatFaxAsEmail(String faxNo){
        String formattedFax = faxNo;
        if(String.isNotBlank(formattedFax)){
            formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            
            Application_Config_Settings__c acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
            formattedFax =  formattedFax + acs.Domain_Name__c;
        }  
        return formattedFax;
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
    
    //Check if attachment selcted or not
    public boolean checkAttachment(){
        
        boolean error = true;
        list<Attachment> checkedAttchList = new list<Attachment>([select Name, Body, BodyLength, Description, createdDate from Attachment where ParentId =: insolvAcc.Id and Id IN: mySelectedAtt]);               
        
        for(Attachment selectedAttach : checkedAttchList){
            
            if(selectedAttach.Description == 'PoC Document'){
                error = false;
                return error;
            }
        }
        
        return error;
    }  
    
    // Check the Attachment for Account Statement
    public boolean checkAttachmentForAccState(){
        
        System.debug('TestcheckAttachmentForAcc');
        Boolean trusteeCheckErrorForAttach = checkEligibleTrustee();
        boolean accountStateError = false;
        list<Attachment> checkedAttchList = new list<Attachment>([select Name, Body, BodyLength, Description, createdDate from Attachment where ParentId =: insolvAcc.Id and Id IN: mySelectedAtt]);               
        System.debug('CheckedAttachList' + checkedAttchList);
        
        for(Attachment selectedAttach : checkedAttchList){
            System.debug('Test');
            if(selectedAttach.Description == 'Account Statement'){
                accountStateError = true;
                return accountStateError;
            }
            
        }
        
        return accountStateError;
        
    } 
    
    // Check the trustee 
    public boolean checkEligibleTrustee(){
        
        System.debug('TestCheckTrustee');
        List<String> trusteeCheckList = new List<String>();
        Boolean trusteeCheckError = false ;    
        //pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        String idWithAccountStatement = pocPackage.Account_Statement_Not_Allowed__c;
        trusteeCheckList = idWithAccountStatement.split(',');
        
        for(String trusteeCheck: trusteeCheckList){
            if(insolvAcc.Insolvency__r.Trustee__r.ParentId == trusteeCheck){
                trusteeCheckError = true;
                System.debug('TrusteeCheckError');
                return trusteeCheckError;
            }
        }
        System.debug('TrusteeCheckError1');
        return trusteeCheckError;
        
    }  
    
    //change the language
    public void changeLanguage(){
        /*subject = '';
        emailBody = '';
        htmlEmailheader = '';*/
        system.debug(' language details'+language);
        if(language == 'fr'){
            //languageValue = 'fr';
            loadFrenchEmailTemplates();
             system.debug(' inside french details');
        }else{
            //languageValue = 'en_US';
            loadEmailTemplates();
        }
        
        emailTemplatechanged();
    }
}