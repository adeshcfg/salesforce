/**************************************************************************************************
 *
 *  Class: MarkEmailRead
 *
 *  @description : This is used to mark new email as read
 *  @author : A5E Consulting
 *  @date : 23/07/2018
 
 *************************************************************************************************/
global class MarkEmailRead{
    
    public Case caseRecord{get;set;}
    
    public MarkEmailRead(ApexPages.StandardController controller){
        
        String caseID = ApexPages.currentPage().getPArameters().get('Id');
        
        caseRecord = [select id, New_Email_on_Case__c from CAse where id = :caseID];
    }
    
    public PageReference markNewEmailasRead(){
    List<EmailMessage> emails= [select id from EmailMessage where parentId=: caseRecord.Id and incoming= true and Status ='0'];
        if(caseRecord.New_Email_on_Case__c == true && emails!= null && emails.size()==0){
            caseRecord.New_Email_on_Case__c = false;
           update caseRecord;
        }
        
        return null;
    }
}