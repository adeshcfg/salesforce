global class ProductEmailController{
    
    // Variable to fetch data related to custom settings, exceptions
    public CCS_Custom_Settings__c CcsSetting = CCS_Custom_Settings__c.getOrgDefaults();
    public Boolean isSelectedAtt {set;get;}
    
    //Show validation message when total attachments size is exceeded
    public Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();
    public Boolean attachSizeException{set;get;}
    public String attachSizeExceptionMessage{set;get;}  
    global Boolean isAnyException {set;get;}
    public Id attachmentSelected{set;get;}
    public Product__c pro {set; get;}
    public  List<ProductAttachments> ProdAttachList{set; get;}
    public Boolean docException {set;get;}
    public Boolean accStatementError {set;get;}
    // Variable that are used to store emails, email subject, body and footers
    public String toEmail{set;get;}
    public String subject {set;get;}
    public String htmlEmailheader {set;get;}
    public String htmlEmailfooter {set;get;}
    public String emailBody {set;get;}
    public String emailName {set;get;}
    
    // Stores all attachments that are selected by user
    public Set<Id> mySelectedAtt = new Set<Id>();
    
    //template lists for with or without header
    list<Id> proTemplateWithHeaderList{get; set;}
    list<Id> proTemplateWithoutHeaderList{get; set;}
    
    //template lists for mandatory attchments list
    list<Id> proTemplateWithManAttachList{get; set;}
    
    // template related variables
    public List<selectOption> templates {set;get;}
    public Id selectedTemplate {set;get;}
    map<Id, EmailTemplate> emailTemplateMap = new map<Id, EmailTemplate>();
    
    // Controller to load initial values and insolvancy account details
    public ProductEmailController(){
        isAnyException  = false;
        //Atachment Size limit check
        attachSizeException = false;
        
        config = [SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c, Run_Insolvency_Status_Validations__c 
                     FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        
        attachSizeExceptionMessage = config.Maximum_Email_Attachments_Size_Text__c;
        proTemplateWithHeaderList = new List<ID>();
        proTemplateWithManAttachList = new List<ID>();
        proTemplateWithHeaderList = new List<ID>();
        
        pro = [SELECT Id, Name, CCS_Account_Number__c, Customer__c, Agency_Email__c, CCS_Client_ID__c FROM Product__c 
               WHERE Id =: ApexPages.currentPage().getParameters().get('Id')]; 
        
        toEmail=pro.Agency_Email__c;
        ProdAttachList = new List<ProductAttachments>();
        
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        
        // Read all attachments related to insolvacny account
        for (Attachment attchmt : [select Name, 
                                   Body, BodyLength,  
                                   Description,
                                   createdDate 
                                   from Attachment where ParentId =: pro.Id 
                                   order by lastmodifieddate desc
                                  ]){
                                      
                                      ProductAttachments temp = new ProductAttachments();
                                      temp.attId = attchmt.Id;
                                      temp.selected =false;
                                      temp.fileName=attchmt.Name;
                                      temp.fileDesc=attchmt.Description;
                                      temp.fileCreatedDate = attchmt.createdDate.addSeconds(offset/1000);
                                      temp.displaySize = InsolvencyUtil.fileSizeToString((attchmt.BodyLength));
                                      
                                      ProdAttachList.add(temp);
                                  }
        
        loadEmailTemplates();
        emailTemplatechanged();
    } 
    
    //Loads template which names start with Insolvency
    public void loadEmailTemplates(){
        
        //Fetcth Id's List for With or Without Header
        string idWithHeaderList = CcsSetting.Product_Template_Header__c;
        if(String.isNotBlank(idWithHeaderList)){
            proTemplateWithHeaderList = idWithHeaderList.split(',');
        }
        string idWithoutHeaderList = CcsSetting.Product_Template_WoHeader__c; 
        proTemplateWithoutHeaderList = idWithoutHeaderList.split(',');
        system.debug('proTemplateWithoutHeaderList : ' + proTemplateWithoutHeaderList);
        //Fetcth Id's List for Attachment Required Email Templates
        String idWithMandAttchList = CcsSetting.Attachment_Required_Email_Templates__c;
        if(String.isNotBlank(idWithMandAttchList)){
            proTemplateWithManAttachList =  idWithMandAttchList.split(',');
        }
        
        //Default Template
        selectedTemplate = proTemplateWithoutHeaderList.get(0);
        
        templates = new List<selectOption>();
        templates.add(new SelectOption('','--select--'));
        //for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Name LIKE 'Insolvency %' OR Name LIKE 'POC %') AND (NOT NAME LIKE '%Error%')])
        for(EmailTemplate emailTemp : [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE (Id IN: proTemplateWithHeaderList OR Id IN: proTemplateWithoutHeaderList /*OR Id IN: insolTemplateWithManAttachList */)]){
            
            emailTemplateMap.put(emailTemp.Id, emailTemp);            
            templates.add(new SelectOption(emailTemp.Id,emailTemp.Name));
        }
    }   
    
    //Load email template body, subject seelcted from drop down
    public void emailTemplatechanged(){
        if(emailTemplateMap.containsKey(selectedTemplate)){
            EmailTemplate emt = emailTemplateMap.get(selectedTemplate);
            subject = emt.subject;
            if(subject != null){
                if(subject.contains('{!Product__c.Name}')){
                    subject = subject.replace('{!Product__c.Name}', (pro.Name != null ? pro.Name:''));
                }
                
                if(subject.contains('{!Product__c.CCS_Client_ID__c}')){
                    subject = subject.replace('{!Product__c.CCS_Client_ID__c}', (pro.CCS_Client_ID__c != null ? pro.CCS_Client_ID__c:''));
                }
            }
            emailBody = emt.body;
            emailName = emt.Name;           
            // replace all merge fields that are in email template
            if (emailBody != null){
                
                if(emailBody.contains('{!CcsSetting.CFG_Office_Name__c}')){       
                    emailBody = emailBody.replace('{!CcsSetting.CFG_Office_Name__c}', CcsSetting.CFG_Office_Name__c);         
                }     
                if(emailBody.contains('{!CcsSetting.CFG_Office_Fax_Number__c}')){        
                    emailBody = emailBody.replace('{!CcsSetting.CFG_Office_Fax_Number__c}', CcsSetting.CFG_Office_Fax_Number__c);         
                }     
                if(emailBody.contains('{!CcsSetting.CFG_Office_Phone_Number__c}')){     
                    emailBody = emailBody.replace('{!CcsSetting.CFG_Office_Phone_Number__c}', CcsSetting.CFG_Office_Phone_Number__c);           
                }       
                
            }  
            
            system.debug('proTemplateWithHeaderList=='+proTemplateWithHeaderList);
            if(proTemplateWithHeaderList.contains(emt.Id)){
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Name__c}', (CcsSetting.CFG_Office_Name__c != null ? CcsSetting.CFG_Office_Name__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Address_1__c}', (CcsSetting.CFG_Office_Address_1__c != null ? CcsSetting.CFG_Office_Address_1__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_City__c}', (CcsSetting.CFG_Office_City__c != null ? CcsSetting.CFG_Office_City__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Province__c}', (CcsSetting.CFG_Office_Province__c != null ? CcsSetting.CFG_Office_Province__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Postal_Code__c}', (CcsSetting.CFG_Office_Postal_Code__c != null ? CcsSetting.CFG_Office_Postal_Code__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Phone_Number__c}', (CcsSetting.CFG_Office_Phone_Number__c != null ? CcsSetting.CFG_Office_Phone_Number__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Fax_Number__c}', (CcsSetting.CFG_Office_Fax_Number__c != null ? CcsSetting.CFG_Office_Fax_Number__c : ''));
                htmlEmailheader = htmlEmailheader.replace('{!CcsSetting.CFG_Office_Website__c}', (CcsSetting.CFG_Office_Website__c != null ? CcsSetting.CFG_Office_Website__c : ''));
            }
        }
    }
    public PageReference sendEmail() {
        isAnyException  = false;
        accStatementError = false;
        docException = false;
        attachSizeException = false; 
        
        //send Email with selected attachments for header templates
        if(proTemplateWithManAttachList.contains(selectedTemplate)){    
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
        }else{
            attachSizeException = false;
        }  
        //Don't run validation rules
        //Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c ];
        
        // Read and store actuall value about running validation rule
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
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
            mail.setOrgWideEmailAddressId(CcsSetting.Trustee_Email_Org_Wide_Address_Id__c);
            mail.setSubject(subject);
            if(htmlEmailheader == null){
                htmlEmailheader ='';
            }
            if(htmlEmailFooter == null){
                htmlEmailFooter ='';
            }
            
            String htmlBody = htmlEmailheader +'<body style="clear:both;">'+emailBodyCustomized +'</body>'+htmlEmailFooter ;
            mail.setHTMLBody(htmlBody );
            // Set activity tru to create activity once email is send
            mail.setSaveAsActivity(true);
            mail.setWhatId(pro.Id);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            // Attach files to email
            for(Attachment attObj : [SELECT Name, Body FROM Attachment WHERE Id IN : mySelectedAtt]){              
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(attObj .Name);
                efa.setBody(attObj.Body);
                fileAttachments.add(efa);                
            }
            
            mail.setFileAttachments(fileAttachments);
            if(!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                // Create Attachment against activity history on Insolvency Account
                Task emailTask = [select id from Task where whatID =: pro.id ORDER BY CreatedDate DESC limit 1];
                
                EmailMessage emailmsg = [select Id, parentId from EmailMessage where activityId = : emailTask.Id];
                
                
                list<Attachment> emailMsgAttachments = new list<Attachment>();
                for(Attachment emailMsgAtt : [SELECT Name, Body, ParentId, Description FROM Attachment WHERE Id IN : mySelectedAtt]){
                    Attachment emailAttachment = new Attachment();
                    emailAttachment.body = emailMsgAtt.body;
                    emailAttachment.Name = emailMsgAtt.Name;
                    emailAttachment.Description = emailMsgAtt.Description;
                    emailAttachment.ParentId = emailmsg.id; 
                    emailAttachment.isPrivate = false; 
                    emailMsgAttachments.add(emailAttachment);
                }         
                if(emailMsgAttachments.size()>0){
                    insert emailMsgAttachments;
                }
            }
        }catch(Exception e){
            
            
        }
        return null;
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
            
            Application_Config_Settings__c acs; // = Application_Config_Settings__c.getOrgDefaults();
            acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
            formattedFax =  formattedFax + acs.Domain_Name__c;
        }  
        return formattedFax;
    }
    
    // Wrapper class used to frame attachments with checkboxes 
    public class ProductAttachments{
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
        list<Attachment> checkedAttchList = new list<Attachment>([select Name, Body, BodyLength, Description, createdDate from Attachment where ParentId =: pro.Id and Id IN: mySelectedAtt]);               
        
        for(Attachment selectedAttach :   checkedAttchList){
            
        }
        
        return error;
    }  
    
}