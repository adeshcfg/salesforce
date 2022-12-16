/**************************************************************************************************
 *
 *  Class:   ServicerNoticeToTrusteeController
 *
 *  @description : Implemented functionality to send LoR Notice letter, and save LoR Notice as attachment on Insolvency Account
 *  @author : A5E Consulting
 *  @date : 08/05/2018
 
 *************************************************************************************************/
public class ServicerNoticeToTrusteeController{
    public Insolvency_Account__c insolvAcc {set;get;}
     
    // Variable that are used to store emails, email subject, body and exceptions
    public String toEmail{set;get;}
    public String subject {set;get;}
    public String emailBody {set;get;}
    public String attachmentBody {set;get;}
    PoC_Package_Settings__c pocPackage;
    public Boolean  isAnyException{set;get;}
    public Boolean isActive {set;get;}
    public List<InsolvAttachments> insolvAttachList{set;get;}
    
    //Show validation message when total attachments size is exceeded
    public Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();
    public Boolean attachSizeException{set;get;}
    public String attachSizeExceptionMessage{set;get;}
    
    // Stores all attachments that are selected by user
    public Set<Id> mySelectedAtt = new Set<Id>();
    public Id attachmentSelected{set;get;}
    
    // Controller loads Insolvency Account record data
    public ServicerNoticeToTrusteeController(){
    
        config = [SELECT Maximum_Email_Attachments_Size_Text__c, Maximum_Email_Attachments_Size__c,
                    Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c FOR UPDATE];//update for lock issue
        poulateRecord();
        insolvAttachList= new List<InsolvAttachments>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        
        //Atachment Size limit check
        attachSizeException = false;
        
        //TrusteeOffice Active Check
        isActive = true;
        
        attachSizeExceptionMessage = config.Maximum_Email_Attachments_Size_Text__c;
        
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
        
        //checking if Trustee Office is Active
        if(insolvAcc.Is_Active__c == False){ 
           system.debug('Trustee is not Active so Email cannot be sent');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Trustee Office is not Active so email cannot be sent')); 
            isActive=false;
        }
        
     }
     //Load intital values
     public void poulateRecord(){
         insolvAcc = [SELECT Id,
                            Trustee_Company__c,
                            Insolvency__r.Name,Is_Active__c,
                            Insolvency__r.Trustee__r.BillingStreet,
                            Insolvency__r.Trustee__r.BillingState,
                            Insolvency__r.Trustee__r.BillingPostalcode,
                            Insolvency__r.Trustee__r.BillingCity,
                            Insolvency__r.Trustee__r.Communication_Preference__c,
                            Insolvency__r.Trustee__r.Business_Email__c,
                            Insolvency__r.Trustee__r.Fax,
                            Servicer_Notice_to_Trustee_Sent_Date__c,
                            Client_Identifier__c, Trustee_Office__c
                    FROM Insolvency_Account__c 
                    WHERE Id =: ApexPages.currentPage().getParameters().get('Id')];
        
        // Check communication preference and use them to send email
        if(insolvAcc.Insolvency__r.Trustee__r.Communication_Preference__c == 'Fax'){
            toEmail =  InsolvencyUtil.formatFaxAsEmail(insolvAcc.Insolvency__r.Trustee__r.Fax);                        
        }
        else{
            toEmail =  insolvAcc.Insolvency__r.Trustee__r.Business_Email__c;
        }
        
        // Fetch PoC custom settings which will have critical information about the bank
        pocPackage = (PoC_Package_Settings__c)PoC_Package_Settings__c.getValues(insolvAcc.Client_Identifier__c);
        Date dateToday = System.Today();
        
        // Convert DateTime to Date format ex: May 01, 2018
        //String formattedDate = DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('MMM dd, YYYY');
        String formattedDate = DateTime.newInstance(dateToday.year(),dateToday.month(),dateToday.day()).formatGMT('MMM dd, YYYY');
        
        // Merge fields used in email template
        Map<String, String> emailMergeFields  = new Map<String, String>{
                                                    '{!TODAY()}' => formattedDate,
                                                    '{!insolvAcc.Trustee_Company__c}' => (insolvAcc.Trustee_Company__c != null ? insolvAcc.Trustee_Company__c.toUppercase() : ''),
                                                    '{!Insolvency_Account__c.Insolvency__r.Trustee__r.BillingStreet}' => (insolvAcc.Insolvency__r.Trustee__r.BillingStreet != null ? insolvAcc.Insolvency__r.Trustee__r.BillingStreet : ''),
                                                    '{!Insolvency_Account__c.Insolvency__r.Trustee__r.BillingState}' => (insolvAcc.Insolvency__r.Trustee__r.BillingState != null ? insolvAcc.Insolvency__r.Trustee__r.BillingState : ''),
                                                    '{!Insolvency_Account__c.Insolvency__r.Trustee__r.BillingPostalcode}' => (insolvAcc.Insolvency__r.Trustee__r.BillingPostalcode != null ? insolvAcc.Insolvency__r.Trustee__r.BillingPostalcode : ''),
                                                    '{!Insolvency_Account__c.Insolvency__r.Trustee__r.BillingCity}' => (insolvAcc.Insolvency__r.Trustee__r.BillingCity != null ? insolvAcc.Insolvency__r.Trustee__r.BillingCity : ''),
                                                    '{!pocPackage.Client_Company_Name__c}' => pocPackage.Client_Company_Name__c.toUppercase(),
                                                    '{!pocPackage.Client_Company_Name}' => pocPackage.Client_Company_Name__c,
                                                    '{!pocPackage.CFG_Office_Name__c}' => pocPackage.CFG_Office_Name__c.toUppercase(),
                                                    '{!pocPackage.CFG_Office_Name}' => pocPackage.CFG_Office_Name__c,             
                                                    '{!pocPackage.CFG_Office_Address_1__c}' => pocPackage.CFG_Office_Address_1__c,
                                                    '{!pocPackage.CFG_Office_City__c}' => pocPackage.CFG_Office_City__c,
                                                    '{!pocPackage.CFG_Office_Province__c}' => pocPackage.CFG_Office_Province__c,
                                                    '{!pocPackage.CFG_Office_Postal_Code__c}' => pocPackage.CFG_Office_Postal_Code__c,
                                                    '{!pocPackage.CFG_Office_Name}' => pocPackage.CFG_Office_Name__c,
                                                    '{!pocPackage.CFG_Office_Phone_Number__c}' => pocPackage.CFG_Office_Phone_Number__c.replace('-','.'),
                                                    '{!pocPackage.CFG_Office_Fax_Number__c}' => pocPackage.CFG_Office_Fax_Number__c.replace('-','.'),
                                                    '{!pocPackage.CFG_Office_Email_Address__c}' => pocPackage.CFG_Office_Email_Address__c,
                                                    '{!pocPackage.CFG_Office_Name_2__c}' => pocPackage.CFG_Office_Name_2__c
                                                    };
        
        // Fetch LoRNotice1 email template
        for(EmailTemplate emt :  [SELECT Id, Name, HtmlValue, Body,Subject FROM EmailTemplate WHERE Id =: pocPackage.Notice_to_Trustee_Template_Id__c]){
            if(emt.Id == pocPackage.Notice_to_Trustee_Template_Id__c){
                subject = emt.subject;
                subject = subject.replace('{!insolv.EstateNumber}', insolvAcc.Insolvency__r.Name);
                emailBody = emt.HtmlValue;
                emailBody = emailBody.replace('{!Insolvency_Account__c.Trustee_Company__c}', (insolvAcc.Trustee_Company__c+ ''));
                emailBody = emailBody.replace('{!Insolvency_Account__c.Trustee_Office__c}', (insolvAcc.Trustee_Office__c+ ''));
                emailBody = emailBody.replace('{!Trustee_street}', (insolvAcc.Insolvency__r.Trustee__r.BillingStreet != null? insolvAcc.Insolvency__r.Trustee__r.BillingStreet : ''));
               // attachmentBody = emt.HtmlValue;
            }
        }
        
        // replace merge fields in email template with actual values in Insolvency Account
        for(String str : emailMergeFields.keySet()){
            emailBody = emailBody.replace(str, (emailMergeFields.get(str)+''));
            //attachmentBody = attachmentBody.replace(str, emailMergeFields.get(str));
        }
     }
     

     
     //Method is used to send email to trustee, and creates Activity under Insolvency account
     public PageReference sendEmail(){  
        
        //Atachment Size limit check    
        attachSizeException = false;
        
        Decimal totalFilesize = 0;
        Decimal maxAttachSize = config.Maximum_Email_Attachments_Size__c;
        system.debug('maxAttachSize ='+maxAttachSize );
        for(Attachment selectedAtt: [SELECT Name, Body, BodyLength FROM Attachment WHERE Id IN : mySelectedAtt]){
          totalFilesize = totalFilesize + selectedAtt.BodyLength;
        }
        system.debug('totalFilesize ='+totalFilesize );
        if(totalFilesize > maxAttachSize){
            attachSizeException = true;
             return null;
        } 
        else{
            attachSizeException = false;
        }
           
        //Sending Email to trustee,and creates activity   
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(toEmail.endsWith(';')){
        toEmail = toEmail.subString(0, toEmail.length()-1);
        }
        List<String> toEmails = new List<String>(toEmail.split(';'));
        mail.setToAddresses(toEmails);
        mail.setOrgWideEmailAddressId(pocPackage.Trustee_Email_Org_Wide_Address_Id__c);
        mail.setSubject(subject);
        mail.setHTMLBody(emailBody );
        mail.setSaveAsActivity(true);
        mail.setWhatId(insolvAcc.Id);
        
        DateTime d = Date.Today() ;
        String dateStr =  d.formatGMT('yyyy-MM-dd') ;
        String attachmentName = 'Servicer Notice.pdf';
        
       /* // Attach pdf to email message with same content as per LoR Notice Letter 1 template
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(attachmentName);
        efa.setBody(Blob.toPDF(attachmentBody));
        fileAttachments.add(efa);
      */  
        // Attach files to email
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        
            for(Attachment attObj : [SELECT Name, Body FROM Attachment WHERE Id IN : mySelectedAtt]){
                    
                    Messaging.Emailfileattachment att = new Messaging.Emailfileattachment();
                    att.setFileName(attObj.Name);
                    att.setBody(attObj.Body);
                    fileAttachments.add(att);
                
            }
        mail.setFileAttachments(fileAttachments);        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        /*
        //Don't run validation rules
        //Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c ];
        
        // Read and store actuall value about running validation rule
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
        try{  
            // Update LoR notice sent date
            insolvAcc.Servicer_Notice_to_Trustee_Sent_Date__c = System.Today();
            insolvAcc.Do_Not_Run_Status_Validation__c = True;
            update insolvAcc;
            
            //InsolvencyUtil.saveAttachment(insolvAcc.Id, attachmentBody, attachmentName, 'Servicer Notice');
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;
            */
            
            // Revert back custom setting value with previous value
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
            
        }catch(Exception ex){
            
            /*
            config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
            update config;            
            */
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
           
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
        
        // Create Attachment against activity history on Insolvency Account
        Task emailTask = [select id from Task where whatID =: insolvAcc.id ORDER BY CreatedDate DESC limit 1];
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
       
       return null; 
     }
     
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
       // Wrapper class used to frame attachments with checkboxes 
    public class InsolvAttachments{
        public Boolean selected{set;get;}
        public Id attId{set;get;}
        public String filename{set;get;}
        public String fileDesc{set;get;}
        public DateTime fileCreatedDate {set;get;}
        public String displaySize {set;get;}
    }
}