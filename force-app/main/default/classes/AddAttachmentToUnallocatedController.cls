public class AddAttachmentToUnallocatedController {
    public static string EstateNumber{get;set;}
    public case caseObj{get;set;}
    public String insolvencyAccNumbers{set;get;}
    public Id attachmentSelected{set;get;}
    public Id paymentSelected{set;get;}
    public Boolean searchResultsFound{get;set;}
    public Boolean errorOccured{get;set;}
    // Stores all attachments that are selected by user
    public Set<Id> mySelectedAtt = new Set<Id>();
    // Stores all Payments that are selected by user
    public Set<Id> mySelectedPaymts = new Set<Id>();
    public Set<ID> recordsNotToSearch = new Set<ID>();
    
    //Attachment for Dividend
    public List<caseAttachment> attachDocument{get;set;}
    
    //Unallocated Payments list
    public list<unallPayments> showUnallPay{get;set;}
    public list<unallPayments> displayUnallPay{get;set;}
    
    //Constructor
    public AddAttachmentToUnallocatedController(ApexPages.StandardController controller) {
        caseObj = new case();
        caseObj = [select Id, CaseNumber, Subject, Insolvency__c, Insolvency_Account__c, Assign_To__c, Assigned_To__c, Insolvency_Assignment_Type__c, Form_Types__c, CreatedDate 
                    from Case where Id =: ApexPages.currentPage().getParameters().get('id')];
    
        fetchAttachment();
        displayUnallPay = new List<unallPayments>();
        List<Unallocated_Payment__c> listUnallocPayment = [select id, name, Bank_Name__c, Account_Number__c, Allocated__c, Customer_Name__c, Debtor_Name__c, Estate_Number__c, Payment_Date__c, Payment_Reference_Number__c, Reviewed_status__c, Unallocated_Amount__c from Unallocated_Payment__c where assignment__c =: caseObj.id];
        for(Unallocated_Payment__c unPayRec : listUnallocPayment){
            unallPayments payRecord = new unallPayments();
            payRecord.selected = True;
            payRecord.unallPay = unPayRec;
            displayUnallPay.add(payRecord);
            recordsNotToSearch.add(unPayRec.id);
        }
        
        errorOccured = false;
    }
    
    void fetchAttachment(){
          attachDocument = new list<caseAttachment>();
          Datetime now = Datetime.now();
          Integer offset = UserInfo.getTimezone().getOffset(now);
        
          for(Attachment attchmt : [select id, name, Description, CreatedDate, LastModifiedDate, parentID, BodyLength 
                           from attachment where parentID =:caseObj.ID ORDER BY CreatedDate DESC]){
         
              caseAttachment temp = new caseAttachment();
              temp.attId = attchmt.Id;
              temp.selected =false;
              temp.fileName=attchmt.Name;
              temp.fileDesc=attchmt.Description;
              temp.fileCreatedDate = attchmt.createdDate.addSeconds(offset/1000);
              temp.displaySize = InsolvencyUtil.fileSizeToString((attchmt.BodyLength));
              attachDocument.add(temp);                   
          }
         
          for(Attachment attch : [SELECT Id, Name, Description, CreatedDate, LastModifiedDate, parentId, BodyLength  
                          FROM Attachment WHERE ParentId in (select id from EMailMessage where relatedToid =: caseObj.id)]){
              caseAttachment temp = new caseAttachment();
              temp.attId = attch.Id;
              temp.selected =false;
              temp.fileName=attch.Name;
              temp.fileDesc=attch.Description;
              temp.fileCreatedDate = attch.createdDate.addSeconds(offset/1000);
              temp.displaySize = InsolvencyUtil.fileSizeToString((attch.BodyLength));
              attachDocument.add(temp);
          }
                          
         //attachDocument.addAll(listAttach);
    }
    
    // Method search for given Insolvency account, Estate Number, Primary Borrower and Debtor
    public PageReference searchUnallPayments(){
        
        fillShowUnallPay();
        List<ID> listInsolvAccIDs = new List<ID>();
        if(insolvencyAccNumbers.trim().length()==0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter data in search field.'));
            return null;
        }
      
        // Perform search only if user entered some text in search field
        if(!String.isEmpty(insolvencyAccNumbers)){
            List<String> searchList = New List<String>();
            List<String> accNumList = insolvencyAccNumbers.split(',');
            for(Integer i=0; i<accNumList.size(); i++){
                String temp = accNumList.get(i).trim();
                temp = '%'+temp+'%';
                searchList.add(temp);
            }
            searchResultsFound = false;
            
            for(Unallocated_Payment__c unPay : [SELECT Id, name, Bank_Name__c, Account_Number__c, Allocated__c, Customer_Name__c, Debtor_Name__c, Estate_Number__c, Payment_Date__c, Payment_Reference_Number__c, Reviewed_status__c, Unallocated_Amount__c FROM Unallocated_Payment__c WHERE (Name LIKE : searchList OR Debtor_Name__c LIKE : searchList OR Customer_Name__c LIKE : searchList OR Estate_Number__c LIKE : searchList OR Account_Number__c LIKE : searchList ) AND ( Not id in :recordsNotToSearch ) AND Allocated__c = FALSE AND Is_Payment_Remitted__c = FALSE AND Is_Payments_Reversed__c = NULL ORDER BY NAME,Customer_Name__c,Debtor_Name__c ASC]){
                unallPayments UnallPay = new unallPayments();
            
                UnallPay.selected = false;
                UnallPay.unallPay = unPay;
                showUnallPay.add(UnallPay);
                
                searchResultsFound = true;
            }
            if(!searchResultsFound){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No search results found.'));
            }
        }
        return null;
    }
    
    //attach selected document to selected unallocated payments
    public void attachDocument(){
        list<Attachment> createAttach = new list<Attachment>();
        Attachment newAttch;
        system.debug('mySelectedAtt='+mySelectedAtt);
        system.debug('mySelectedPaymts='+mySelectedPaymts);
        if(mySelectedPaymts.size() < 1){
            errorOccured = True;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select unallocated payment record to attach the document.'));
            return;
        }
        if(mySelectedAtt.size() < 1){
            errorOccured = True;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select attachment record.'));
            fillShowUnallPay();
            return;
        }
        for(Unallocated_Payment__c unPay : [select Id, Name, assignment__c, Bank_Name__c, Account_Number__c, Allocated__c, Customer_Name__c, Debtor_Name__c, Estate_Number__c, Payment_Date__c, Payment_Reference_Number__c, Reviewed_status__c, Unallocated_Amount__c  from Unallocated_Payment__c where Id IN: mySelectedPaymts]){
            //if(unPay.assignment__c == null){
                for(Attachment attch : [select Id, Name, Body, parentId from Attachment where Id IN: mySelectedAtt]){
                    newAttch = new Attachment();
                    newAttch.Body = attch.Body;
                    newAttch.Name = attch.Name;
                    newAttch.ParentId = unPay.Id;
                    createAttach.add(newAttch);
                    
                }
                
                unPay.Assignment__c = caseObj.id;
                unallPayments payRecord = new unallPayments();
                payRecord.selected = True;
                payRecord.unallPay = unPay;
                displayUnallPay.add(payRecord);
                recordsNotToSearch.add(unPay.id);
                update unPay;
            //}
        }
        insert createAttach;
        system.debug('createAttach='+createAttach);
        system.debug('displayUnallPay='+displayUnallPay);
        showUnallPay = new List<unallPayments>();
        mySelectedPaymts = new Set<ID>();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Document has been attached to selected unallocated record/s.'));
        
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
    
    //Handles to store list of payments selected by user
    public void paymentSelected(){
        if(paymentSelected != null){
            mySelectedPaymts.add(paymentSelected );
            paymentSelected = null;
        }
    }
    
    //Handles to remove payments un selected by user
    public void paymentRemoved(){
        if(paymentSelected != null){
            mySelectedPaymts.remove(paymentSelected );
            paymentSelected = null;
        }
        
    }
    
    //to fill the show list after search
    public void fillShowUnallPay(){
        showUnallPay = new list<unallPayments>();
        List<Unallocated_Payment__c> listUnallocatedPayments = [select Id, Name, Bank_Name__c, Account_Number__c, Allocated__c, Customer_Name__c, Debtor_Name__c, Estate_Number__c, Payment_Date__c, Payment_Reference_Number__c, Reviewed_status__c, Unallocated_Amount__c from Unallocated_Payment__c where Id IN: mySelectedPaymts];
        for(Unallocated_Payment__c unAllocPay : listUnallocatedPayments){
            unallPayments payRecord = new unallPayments();
            payRecord.selected = True;
            payRecord.unallPay = unAllocPay;
            showUnallPay.add(payRecord);
            recordsNotToSearch.add(unAllocPay.id);
        }
    }
    
    // Wrapper class used to frame attachments with checkboxes 
    public class caseAttachment{
        public Boolean selected{set;get;}
        public Id attId{set;get;}
        public String filename{set;get;}
        public String fileDesc{set;get;}
        public DateTime fileCreatedDate {set;get;}
        public String displaySize {set;get;}
    }
    
    //Wrapper class used to frame unallocated payments with checkboxes
    public class unallPayments{
        public Boolean selected{get;set;}
        public Unallocated_Payment__c unallPay;
         
         public void setunallPay(){
             unallPay = unallPay;
         }
         public Unallocated_Payment__c getunallPay(){
             return unallPay;
         }
    }
}