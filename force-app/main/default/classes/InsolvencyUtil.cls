/**************************************************************************************************
 *
 *  Class:   InsolvencyUtil
 *
 *  @description : This is a utility class for Insolvency
 *  @author : A5E Consulting
 *  @date : 03/21/2018
 
 *************************************************************************************************/
 
 public without sharing class InsolvencyUtil {
    public static Application_Config_Settings__c config; // = Application_Config_Settings__c.getOrgDefaults();
    
    /**
     * @description : Generate 15 character unique hash code based on current system time and an additional identifier
     * @author adesh.ikhar@canaccede.com | 04-08-2024
     * @return String
     **/
    /* public static String generateUniqueHashCode(String uniqueIdentifier) {
        // Get the current datetime
        DateTime now = DateTime.now();
        // Convert datetime to string
        String dateString = String.valueOf(now) + uniqueIdentifier;
        // Generate hash code using SHA-256
        Blob hashValue = Crypto.generateDigest('SHA-256', Blob.valueOf(dateString));
        // Convert hash code to base64
        String base64Hash = EncodingUtil.base64Encode(hashValue);
        // Get the first 15 characters of the base64 encoded hash
        String fifteenCharHash = base64Hash.substring(0, 15);
        return fifteenCharHash;
    } */

    //Create full name
    public static String createFullName(String firstName, String lastName){
        
        String fullName = String.isNotBlank(firstName) ? firstName : '';
        fullName = fullName + ' ' +  (String.isNotBlank(lastName) ? lastName : '');
        
        return fullName.trim();    
    }
    
    //Utility method to fetch specific Insolvency field set
    public static Map<String, String> getInsolvencyFieldSet(string fieldSetLabel){
        
        Map<String, String> fieldsNameLabel = new Map<String, String>();
        
        Map<String, Schema.FieldSet> insFieldsSets = Schema.SObjectType.Insolvency__c.fieldSets.getMap();
        
        List<Schema.FieldSet> listInsFieldSets = insFieldsSets.values();
        
        for(Schema.FieldSet insFieldSet : listInsFieldSets){
            
            if(fieldSetLabel == insFieldSet.getLabel()){
                
                for(Schema.FieldSetMember field : insFieldSet.getFields()) {    
                    fieldsNameLabel.put(field.getFieldPath(), field.getLabel());
                }               
                break;
            }
        }
        
        return fieldsNameLabel;    
    } 
    
    // Check whether current user belong to community profile or not
    public static boolean isCommunityUser(){
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName.contains('Community User')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Check whether current user belong to community readonly profile or not
    public static Boolean isCommunityReadOnlyUser(){
        String profileName = [Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName.contains('Community User Read Only') || profileName.contains('Community User Readonly')){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Check whether current user belong to Scotia Bank Community User or not
    public static Boolean isScotiaBankCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('Scotia Bank') ){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Check whether current user belong to SPL Community User or not
    public static Boolean isChaseBankCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('SPL') ){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Check whether current user belong to SDA Bank Community User or not
    public static Boolean isSDABankCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('SDA') ){
            return true;
        }
        else{
            return false;
        }
    }
    
    //Check whether current user belong to Fairstone Bank Community User or not
    public static Boolean isFairstoneBankCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('Fairstone') ){
            return true;
        }
        else{
            return false;
        }
    }

    //Check whether current user belong to Fairstone Bank Community User or not
    public static Boolean isGoeasyBankCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('Goeasy') ){
            return true;
        }
        else{
            return false;
        }
    }

    //Check whether current user belong to Canadian Tire Bank Community User or not
    public static Boolean isCanadianTireCommunityUser(Id profileId){
        String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
        if(profileName.contains('Canadian Tire') ){
            return true;
        }
        else{
            return false;
        }
    }
    
     //Check whether current user belong to Money Mart Bank Community User or not
     public static Boolean isMoneyMartCommunityUser(Id profileId){
         String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
         if(profileName.contains('Money Mart') ){
             return true;
         }
         else{
             return false;
         }
     }
     
     //Check whether current user belong to Flexiti Bank Community User or not
     public static Boolean isFlexitiCommunityUser(Id profileId){
         String profileName = [Select Id,Name from Profile where Id=: profileId].Name;
         if(profileName.contains('Flexiti') ){
             return true;
         }
         else{
             return false;
         }
     }
     
    //Return InsolvencyAccount Record Type Id DeveloperName Map
    public static Map <Id, String> getInsAccntRecorTypeMap(){
        
        Map <Id, String> insAccntRecorTypeMap = new Map<Id, String>();
        List <RecordType> recordTypes = [Select Id, DeveloperName From RecordType where sobjecttype = 'Insolvency_Account__c' and (NOT name like 'Unknown%')];
        
        for(RecordType recordType : recordTypes){
            insAccntRecorTypeMap.put(recordType.Id ,recordType.DeveloperName);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.DeveloperName);
        }       
        
        return insAccntRecorTypeMap;
    }
    
    //Return InsolvencyAccount Record Type Id Name Map
    public static Map <Id, String> getInsAccntRecorTypeIdNameMap(){
        
        Map <Id, String> insAccntRecorTypeMap = new Map<Id, String>();
        List <RecordType> recordTypes = [Select Id, Name From RecordType where sobjecttype = 'Insolvency_Account__c' and ((NOT name like 'Unknown%'))];
        
        for(RecordType recordType : recordTypes){
            insAccntRecorTypeMap.put(recordType.Id ,recordType.Name);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.Name);
        }       
        
        return insAccntRecorTypeMap;
    }
    
    //Return InsolvencyAccount Record Type Name Id Map
    public static Map <String, Id> getInsAccntRecorTypeNameIdMap(){
        
        Map <String, Id> insAccntRecorTypeMap = new Map<String, Id>();
        List <RecordType> recordTypes = [Select Id, Name From RecordType where sobjecttype = 'Insolvency_Account__c' and (NOT name like 'Unknown%') order by createddate];
        
        for(RecordType recordType : recordTypes){
            insAccntRecorTypeMap.put(recordType.Name, recordType.Id);
            System.debug('Record Type Id is '+recordType.Id +'Record Type Name is '+recordType.Name);
        }       
        
        return insAccntRecorTypeMap;
    }
    
    // Update Insolvency Account Owner Id with current user
    public static void updateInsolvencyAccountOwnerIds(List<Insolvency_Account__c> insolvAccList){
        /*
         //Don't run validation rules
        Application_Config_Settings__c config = [SELECT Run_Insolvency_Status_Validations__c FROM Application_Config_Settings__c FOR UPDATE];
        
         //Read and store the actual value of the insolvency status validation field
        Boolean storeCustomsettingValue = config.Run_Insolvency_Status_Validations__c;
        config.Run_Insolvency_Status_Validations__c = false;
        update config;
        */
        
        for(Insolvency_Account__c insolvAcc : insolvAccList){
            
            insolvAcc.OwnerId = UserInfo.getUserId();
        }
        if(!insolvAccList.isEmpty()){
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = false;
            update insolvAccList;
            InsolvencyAccountTriggerHandler.runInsolvencyAccountTrigger = true;
        }
        /*
         config.Run_Insolvency_Status_Validations__c = storeCustomsettingValue;
         update config;
        */
    }
    
    // Update Insolvency And Insolvency Account Account Owner
    public static void updateOwnerShip(Insolvency__c insolv){
        InsolvencyTriggerHandler.runInsolvencyTrigger = false;
        update insolv;
        InsolvencyTriggerHandler.runInsolvencyTrigger = true;
        if(insolv.Insolvency_Accounts__r.size() > 0){
            InsolvencyUtil.updateInsolvencyAccountOwnerIds(insolv.Insolvency_Accounts__r);
        }
    }
    
    //Return Insolvency Account Records related to the user profile
    public static List<Insolvency_Account__c> getInsolvencyAccounts(Id insolvId, String InsolvencyRecordTypeName){
        return [SELECT OwnerId FROM Insolvency_Account__c WHERE REcordType.Name =: InsolvencyRecordTypeName
                                                AND Insolvency__c =: insolvId];
    }
    
    //Return Insolvency Account Record Type Based on Profile
    public static String getInsAccntRecordTypeProfile(Id profileId){
      
      String profileName = getProfileNameBasedOnId (profileId);
      
      if (profileName.contains('Scotia Bank')){
         return 'Scotia Bank Insolvency Account';
      }
      else if (profileName.contains('SPL')){
         return 'SPL Insolvency Account';
      }
      else if (profileName.contains('SDA')){
         return 'SDA Insolvency Account';
      }
      else if (profileName.contains('Fairstone')){
         return 'Fairstone Insolvency Account';
      }
      else if (profileName.contains('Goeasy')){
         return 'Easyfinancial Insolvency Account';
      }
      else if (profileName.contains('Canadian Tire')){
        return 'Canadian Tire Insolvency Account';
     }
     else if (profileName.contains('Money Mart')){
        return 'Money Mart Insolvency Account';
     }
     else if (profileName.contains('Flexiti')){
        return 'Flexiti Insolvency Account	';
     }   
      return null; 
    }
    
     //Return Profile Name based on Profile Id
    public static String getProfileNameBasedOnId (Id profileId){
      return [Select Id,Name from Profile where Id=: profileId].Name;      
    }
    
    // Method creates attachment - This is generally used in LoR notice
    public static void saveAttachment(Id parentId, String contentsString, String fileName, String fileType){
        Attachment attach = new Attachment();
        attach.ParentId = parentId;
        attach.name = fileName;
        attach.body = Blob.toPDF(contentsString);
        attach.Description = fileType;
        insert attach;
    }


    /**
    * @description : Create attachment record related to another object record
    * @author adesh.ikhar@canaccede.com | 07-31-2024 
    * @param parentId 
    * @param pdfAttachment 
    * @param fileName 
    * @param fileType 
    **/
    public static void saveAttachment(String parentId, Blob pdfAttachment, String fileName, String fileType){
        Attachment attach = new Attachment();
        attach.ParentId = parentId;
        attach.name = fileName;
        attach.body = pdfAttachment;
        attach.Description = fileType;
        insert attach;
    }
    
    //Utility method to format Fax As Email Address
     public static string formatFaxAsEmail(String faxNo){
         String formattedFax = faxNo;
         if(String.isNotBlank(formattedFax)){
            formattedFax = formattedFax.replace('(', '').replace(')', '');
            formattedFax = formattedFax.replaceAll('-', '');
            formattedFax = formattedFax.replaceAll(' ', '');
            Application_Config_Settings__c acs; // = Application_Config_Settings__c.getOrgDefaults();
            acs = [SELECT Domain_Name__c FROM Application_Config_Settings__c];
            formattedFax =  formattedFax + acs.Domain_Name__c;
        }  
        return formattedFax;
    }
    
    //Utility method to convert Attachment size from bytes to KB or MB or GB
    public static String fileSizeToString(Long value){
        
        //Representation of Attachment Size in KB,MB,GB 
        if (value < 1024){
            return string.valueOf(value) + ' Bytes';
        }            
        else if (value >= 1024 && value < (1024*1024)){
            //Convert Attachment Size from Bytes to KB
            Decimal kb = Decimal.valueOf(value);
            kb = kb.divide(1024,2);
            return string.valueOf(kb) + ' KB';
        }
        else if (value >= (1024*1024) && value < (1024*1024*1024)){
            //Convert Attachment Size from Bytes to MB
           Decimal mb = Decimal.valueOf(value);
           mb = mb.divide((1024*1024),2);
           return string.valueOf(mb) + ' MB';
        }
        else {
            //Convert Attachment Size from Bytes to GB
            Decimal gb = Decimal.valueOf(value);
            gb = gb.divide((1024*1024*1024),2);
             
            return string.valueOf(gb) + ' GB';
        }    
    }
    
    //Calculate Next Business Date
    public static date calculateNextBusinesDate(date todayDate){
        
        //Week Map
        Map<Integer, Date> dateMap = new Map<Integer, Date>();
        dateMap.put(0, todayDate.addDays(1));
        dateMap.put(1, todayDate.addDays(1));
        dateMap.put(2, todayDate.addDays(1));
        dateMap.put(3, todayDate.addDays(1));
        dateMap.put(4, todayDate.addDays(1));
        dateMap.put(5, todayDate.addDays(3));
        dateMap.put(6, todayDate.addDays(2));
        
        String dayOfWeek = '';
        date nextBusinessDate;
        date nextDate;
        date FirstDate = todayDate;
        date SecondDate = date.newInstance(1900, 1, 7);
        integer numberDaysDue = SecondDate.daysBetween(FirstDate);
        integer remainder = Math.Mod(numberDaysDue,7);
        
        //Query Holidays
        list<Holiday> holidayList = new list<Holiday>();
        holidayList = [SELECT Id, Name, ActivityDate, Description FROM Holiday];
        
        nextDate = dateMap.get(remainder);
                         
        for(Holiday holidayObj : holidayList ){
            if(nextDate == holidayObj.ActivityDate){
                nextBusinessDate = nextDate + 1;
                nextDate = nextBusinessDate;
            }
            Datetime dt = DateTime.newInstance(nextDate, Time.newInstance(0, 0, 0, 0));
            dayOfWeek=dt.format('EEEE');
            if(dayOfWeek == 'Saturday'){
                nextBusinessDate = nextBusinessDate + 2;
                nextDate = nextBusinessDate;
            }
        }
        
        //nextBusinessDate = nextDate;
        //return nextBusinessDate;
        
        return nextDate;
    }   
    
    //Get Eligible Insolvency Account Record Type Options
    public Static String getRecordTypeToWorkOn() {
        String recordTypeToWorkOn = '';
        String recordToWorkOn = getRecordToWorkOn();
        if(String.isNotBlank(recordToWorkOn)){
            Map<String, String> workOnRecordTypeMap = New Map<String, String>();
            workOnRecordTypeMap.put('Scotia Bank', 'Scotia Bank Insolvency Account');
            workOnRecordTypeMap.put('SPL', 'SPL Insolvency Account');
            workOnRecordTypeMap.put('SDA', 'SDA Insolvency Account');
            workOnRecordTypeMap.put('Fairstone', 'Fairstone Insolvency Account');
            workOnRecordTypeMap.put('Goeasy', 'Easyfinancial Insolvency Account');
            workOnRecordTypeMap.put('Canadian Tire', 'Canadian Tire Insolvency Account');
            workOnRecordTypeMap.put('Money Mart', 'Money Mart Insolvency Account');
            workOnRecordTypeMap.put('Flexiti', 'Flexiti Insolvency Account	');
            recordTypeToWorkOn = workOnRecordTypeMap.get(recordToWorkOn);
        }
        return recordTypeToWorkOn;
    }
    
    //Get Eligible Insolvency Account Record Type Options
    public Static String getRecordToWorkOn() {
        return [Select Id, To_Work_On__c from User where Id=:userinfo.getUserId()].To_Work_On__c;
    }
    
    //Utility method to Fetch Owner
    public static id fetchOwner(Insolvency_Account__c insolAccnt, Insolvency__c insolv){
        
        Id ownerId = UserInfo.getUserId();        
           
        String clientIdentifier = insolAccnt.Client_Identifier__c;
        
        /*
        System.debug('insolAccnt :'+insolAccnt);
        System.debug('insolv :'+insolv);
        System.debug('clientIdentifier :'+clientIdentifier);
        System.debug('insolv.Scotia_Record_Owner__c :'+insolv.Scotia_Record_Owner__c);
        System.debug('insolv.SDA_Record_Owner__c :'+insolv.SDA_Record_Owner__c);
        System.debug('insolv.Chase_Record_Owner__c :'+insolv.Chase_Record_Owner__c);
        */
        
        if(clientIdentifier == 'Scotia Bank'){
            if(insolv.Scotia_Record_Owner__c != null){
                ownerId = insolv.Scotia_Record_Owner__c;
            }
        }
        else if(clientIdentifier == 'SDA'){
            if(insolv.SDA_Record_Owner__c!= null){
                ownerId = insolv.SDA_Record_Owner__c;
            }       
        }        
        else if(clientIdentifier == 'SPL'){
            if(insolv.Chase_Record_Owner__c!= null){
                ownerId = insolv.Chase_Record_Owner__c;
            }
        }
        else if(clientIdentifier == 'Fairstone'){
             if(insolv.Fairstone_Record_Owner__c!= null){
                ownerId = insolv.Fairstone_Record_Owner__c;
            }
        }
        else if(clientIdentifier == 'Goeasy'){
            if(insolv.Goeasy_Record_Owner__c!= null){
               ownerId = insolv.Goeasy_Record_Owner__c;
           }
       }
        else if(clientIdentifier == 'Canadian Tire'){
            if(insolv.Canadian_Tire_Record_Owner__c!= null){
                ownerId = insolv.Canadian_Tire_Record_Owner__c;
            }
        }
        else if(clientIdentifier == 'Money Mart'){
            if(insolv.Money_Mart_Record_Owner__c!= null){
                ownerId = insolv.Money_Mart_Record_Owner__c;
            }
        }
        else if(clientIdentifier == 'Flexiti'){
            if(insolv.Flexiti_Record_Owner__c!= null){
                ownerId = insolv.Flexiti_Record_Owner__c;
            }
        }
        return ownerId;
    }
}