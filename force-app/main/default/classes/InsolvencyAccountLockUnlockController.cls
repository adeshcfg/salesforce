/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to Lock and Unlock Insolvency
 *  @author : A5E Consulting
 *  @date : 01/20/2018
 
 *************************************************************************************************/
 
public class InsolvencyAccountLockUnlockController {
    
    public Boolean isRecordLockedByCurrentUser{set;get;}
    public String insolvncyAccntId{get;set;}
    public Insolvency_Account__c insolvncyAccnt{get;set;}
    public String insolvencyId{get;set;}
    public Insolvency__c insolvncy{get;set;}
    public Boolean showLockButton{get;set;}
    public Id loggedinUserId{get;set;}    
    
    //Constructor
    public InsolvencyAccountLockUnlockController(ApexPages.StandardController controller){
        
        loggedinUserId = Userinfo.getUserId();
        
        //Initialize values
        showLockButton = true;
        
        //Insolvency Account ID
        insolvncyAccntId = ApexPages.currentPage().getParameters().get('id');  
        
        //Insolvency Account
        insolvncyAccnt = [Select Id, Name, 
                                 Insolvency__c, Insolvency__r.Is_Record_Locked__c, 
                                 Insolvency__r.Record_Locked_By__c, Insolvency__r.Record_Locked_By__r.Name    
                                 from Insolvency_Account__c 
                                 where id =: insolvncyAccntId limit 1];
                                 
        insolvencyId = insolvncyAccnt.Insolvency__c;                                 
        
        //Insolvency                   
        insolvncy = getInsolvency(insolvencyId);
                            
        
        //Record lock-Unlock check                    
        if(insolvncyAccnt.Insolvency__r.Is_Record_Locked__c){
            showLockButton = false; 
            recordLockedBy = insolvncy.Record_Locked_By__r.Name;
            if(UserInfo.getUserId() == insolvncy.Record_Locked_By__c){
                isRecordLockedByCurrentUser = true;
            }
           
        }
        else{
            showLockButton = true;
        }  
    }
    public String recordLockedBy {set;get;}
    //Lock related Insolvency record
    public PageReference lockInsolvency(){
        //Insolvency record
        insolvncy = getInsolvency(insolvencyId);
        if(insolvncy.Is_Record_Locked__c){
            //do nothing
            recordLockedBy = insolvncy.Record_Locked_By__r.Name;
        }
        else{
            insolvncy.Is_Record_Locked__c = true;
            insolvncy.Record_Locked_By__c = loggedinUserId;
            
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            update insolvncy;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true; 
            recordLockedBy = UserInfo.getName();
            isRecordLockedByCurrentUser = true;
        }   
        
        showLockButton = false;
        return null;
    }
    
     
    //Unlock related Insolvency record
    public PageReference unLockInsolvency(){
        insolvncy = getInsolvency(insolvencyId);
        if(insolvncy.Is_Record_Locked__c){
            //ToDo unlock the record in trigger too
            insolvncy.Is_Record_Locked__c = false;
            insolvncy.Record_Locked_By__c = null;
            
            InsolvencyTriggerHandler.runInsolvencyTrigger = false;
            update insolvncy;
            InsolvencyTriggerHandler.runInsolvencyTrigger = true;
            showLockButton = true;
        }
        else{
            //do nothing
        }
        
        return null;
     }
     
    //Return latest Insolvency record
    private static Insolvency__c getInsolvency(String insolvencyId){
        
        return [Select Id, Name,
                            Is_Record_Locked__c, 
                            Record_Locked_By__c, Record_Locked_By__r.Name    
                            from Insolvency__c 
                            where id =: insolvencyId limit 1];      
     }
}