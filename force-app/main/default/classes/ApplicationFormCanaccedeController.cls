/**************************************************************************************************
 *
 *  Class: ApplicationFormCanaccedeController   
 *
 *  @description : This is controller class for Application Form Canaccede landing page
 *  @author : A5E Consulting
 *  @date : 
 
 *************************************************************************************************/
public without sharing class ApplicationFormCanaccedeController{
    
    public Application_Form_Settings__c AppFormSettings {get;set;}
    
    public Account PersonAccount {get;set;}
    
    //Variables Added for preProcessing form
    //public Application__c app{get;set;}
    //public String FirstNamecust {get;set;}
    
    public String FirstName2 {get;set;}
    public String LastName2 {get;set;}
    public String dateofbirth{get;set;}
    public String urlForRedirection{get;set;}
    
    public String PrimaryphoneNumber2 {get;set;}
    
    private final String REGEX_PHONE_NUMBER = '^\\(?([0-9]{3})\\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$';
    private final String REGEX_EMAIL_ADDRESS = '^\\w+([\\.-]?\\w+)*@\\w+([\\.-]?\\w+)*(\\.\\w{2,3})+$';
    
    //Variables Added for preProcessing form
    public String Uniqueid{ get; set; }
    public Boolean consent{ get; set; }
    public String Email{ get; set; }
    public String cellPhone{ get; set; }
    public boolean InvalidData {get;set;}
    
    public ApplicationFormCanaccedeController() {        
        //app = new Application__c();
        InvalidData = false;
        //Custom setting values
        AppFormSettings = Application_Form_Settings__c.getOrgDefaults();
        Pagereference pageRef = new PageReference(AppFormSettings.Redirect_URL_from_Canaccede_to_Fidem__c);
        urlForRedirection = pageref.getURL();
        system.debug('urlForRedirection: '+urlForRedirection);                
    }
    
    public PageReference nextProcessing() {
        system.debug('consent'+consent);
        Boolean redirectApplicationform = false;
        
        system.debug('Uniqueid'  + Uniqueid);
        //system.debug('Email' + app.Email_Address__c);
        system.debug('cellnumber' + cellPhone);
        system.debug('FirstNamecust' + dateofbirth);
        system.debug('lastname2' + lastname2);
        
        //PrimaryphoneNumber2 = app.Cell_Phone__c;        
        /*if(app.Cell_Phone__c!=null){
            Pattern phonePattern = Pattern.compile(REGEX_PHONE_NUMBER);
            if(phonePattern.matcher(app.Cell_Phone__c).matches()){
                PrimaryphoneNumber2 = app.;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter valid phone number'));
                return null;
            }
        }*/
        //avi
         PrimaryphoneNumber2 = cellPhone;
         if(cellPhone.trim()!=null){
            Pattern phonePattern = Pattern.compile(REGEX_PHONE_NUMBER);
            if(phonePattern.matcher(cellPhone).matches()){
                PrimaryphoneNumber2 = cellPhone;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter valid phone number'));
                return null;
            }
        } 
        
        if(Email.trim()!=''){       
            // Email Address (required)
            Pattern emailPattern = Pattern.compile(REGEX_EMAIL_ADDRESS);
            if (String.isNotBlank(Email) &&
                emailPattern.matcher(Email).matches() == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter valid Email Address'));
                    return null;
                }  
        }      
        
        //PrimaryphoneNumber2 = cellPhone;
        system.debug('Checkphone' + PrimaryphoneNumber2);
        if(String.isNotBlank(Uniqueid.trim()) && String.isNotBlank(FirstName2) && String.isNotBlank(lastname2) && String.isNotBlank(dateofbirth) && String.isNotBlank(Email) && String.isNotBlank(cellPhone)){
            //Convert String dateofBirth(mm-dd-yyyy) to Date format
            String[] strDate = dateofbirth.split('-');
            Integer myIntMonth = integer.valueOf(strDate[0]);
            Integer myIntDate = integer.valueOf(strDate[1]);
            Integer myIntYear = integer.valueOf(strDate[2]);
            Date dateOfBirthFormatted = Date.newInstance(myIntYear, myIntMonth, myIntDate);
            
            List<Insolvency__c> listInsolvency = new List<Insolvency__c>();
            listInsolvency = [SELECT Id, Debtor_1_First_Name__c  , Debtor_1_Last_Name__c,Offer_Code__c 
                              FROM Insolvency__c 
                              WHERE Debtor_1_First_Name__c= :FirstName2.trim() AND Debtor_1_Last_Name__c = :lastname2.trim()
                              AND Offer_Code__c= :Uniqueid.trim()
                              ];
            system.debug('listInsolvency: '+listInsolvency);
            if(listInsolvency.size()==0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid data entered.'));
                InvalidData = true;
                return null;
            }
            else if(listInsolvency.size()>0){
                InvalidData = false;
                system.debug('dateofbirth: '+dateofbirth);
                Insolvency__c insolvency = new Insolvency__c();
                insolvency.Id = listInsolvency[0].Id;
                insolvency.Canaccede_Date_of_Birth__c = dateOfBirthFormatted;
                insolvency.Canaccede_Email__c = email.trim();
                insolvency.Canaccede_Mobile_Phone__c = cellPhone.trim();
                insolvency.Canaccede_Data_Captured_Date__c = system.now();
                //Capture the User's Marketing Consent 
                insolvency.Marketing_and_Offers_Consent__c = consent;
                InsolvencyTriggerHandler.runInsolvencyTrigger = false;
                try{
                  update insolvency;
                }
                catch(Exception ex){
                    system.debug('Exception in Insolvency Update: '+ex);
                }
                InsolvencyTriggerHandler.runInsolvencyTrigger = true;
                
                Pagereference pageRef = new PageReference(AppFormSettings.Redirect_URL_from_Canaccede_to_Fidem__c);
        urlForRedirection = pageref.getURL();
                system.debug('urlForRedirection ::'+urlForRedirection);
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'All fields are mandatory.'));
            return null;
        }
        
        return null;        
    }
}