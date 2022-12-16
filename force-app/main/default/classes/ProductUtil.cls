/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a utility class for Product Object 
 *  @author : A5E Consulting
 *  @date : 02/19/2018
 *
 *************************************************************************************************/
public class ProductUtil{
    
    public static Id customerAccountRecordTypeId;
    public static Map <Id, String> prodRecorTypeMap;
    public static Map<String, Id> prodRTypeIdMap = new Map<String, Id>();
    public static Map<Id, String> prodRTypeIdNameMap = new Map<Id, String>();
    
    static{
        prodRecorTypeMap = Utilities.getProdRecorTypeMap();
        customerAccountRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Customer Salesforce' LIMIT 1].Id;
      
        for(RecordType rType : [SELECT Id, DeveloperName, Name FROM RecordType WHERE sobjectType = 'Product__c' ]){
            prodRTypeIdMap.put(rType.DeveloperName, rType.Id);
            prodRTypeIdNameMap.put(rType.Id, rType.Name);
        }
    }
    
    // Create Account for Product
    public static Account createCustomer(Product__c prod, String RecordType){
        
        ID recordTypeIDValue = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = :recordType LIMIT 1].Id;
        
        if(String.isNotBlank(prod.Last_Name__c)){
            
            Account acc = new Account(RecordTypeId = recordTypeIDValue);
        
            // Map Product fields with Customer Account to create
            if(String.isNotBlank(prod.First_Name__c)){
                if((prod.First_Name__c).length() > 39){
                    acc.FirstName = (prod.First_Name__c).subString(0,39);
                    acc.LastName = (prod.First_Name__c).subString(40,((prod.First_Name__c).length()-1));
                }else{
                    acc.FirstName = prod.First_Name__c;
                }
            }
            if(String.isNotBlank(prod.Last_Name__c)){
                if(String.isNotBlank(acc.LastName)){
                    acc.LastName += ' ' + prod.Last_Name__c;
                }else{
                    acc.LastName = prod.Last_Name__c;
                }
            }
            if(String.isNotBlank(prod.Email_Address__c)){
                acc.PersonEmail = prod.Email_Address__c;
            }
            if(prod.Date_of_Birth__c != null){
                acc.PersonBirthdate = prod.Date_of_Birth__c;
            }
            if(String.isNotBlank(prod.SIN__c)){
                acc.SIN__pc = prod.SIN__c;
            }
            String address = '';
            if(String.isBlank(prod.Address_Line2__c)){
                address = prod.Address_Line1__c;
            }
            else{
                address = (prod.Address_Line1__c != null ? prod.Address_Line1__c : '')+''+prod.Address_Line2__c;
            }
            acc.PersonMailingStreet = address;
            if(String.isNotBlank(prod.City__c)){
                acc.PersonMailingCity = prod.City__c;
            }
            if(String.isNotBlank(prod.Zip_Code__c)){
                acc.PersonMailingPostalCode = prod.Zip_Code__c;
            }
            if(String.isNotBlank(prod.State__c)){
                acc.PersonMailingState = prod.State__c;
            }
            if(String.isNotBlank(prod.Phone_Home__c)){
                acc.PersonHomePhone = prod.Phone_Home__c;
            }
            if(String.isNotBlank(prod.Phone_Work__c)){
                acc.Work_Phone__pc = prod.Phone_Work__c;
            }
            if(String.isNotBlank(prod.Phone_Other__c)){
                acc.PersonOtherPhone = prod.Phone_Other__c;
            }
            if(prod.Address_Last_Changed_Date__c != null){
                acc.Address_Last_Changed_Date__c = prod.Address_Last_Changed_Date__c;
            }
            
            insert acc;
            return acc; 
            
        }
        else {
            return null;
        }           
    }
    
    // Fetch customer using product information
    public static List<Account> queryCustomer(Product__c prod, String recordType){
        
        List<Account> accList = new List<account>();
        
        ID recordTypeIDValue = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = :recordType LIMIT 1].Id;
        
        //If Last Name is null, don't run the query
        if(String.isNotBlank(prod.Last_Name__c)){
        
            String firstNameLetter;
            if(prod.First_Name__c != null){
                firstNameLetter = prod.First_Name__c.subString(0,1)+'%';
            }
            accList = [SELECT Id, FirstName, LastName, SIN__pc, PersonBirthdate, PersonEmail, Address_Last_Changed_Date__c,
                       PersonOtherPhone, Work_Phone__pc, PersonHomePhone, PersonMailingState, PersonMailingPostalCode,
                       PersonMailingCity, PersonMailingStreet
                        FROM Account WHERE (
                                (LastName!=null and SIN__pc!=null and  LastName =: prod.Last_Name__c AND SIN__pc =: prod.SIN__c) 
                                 OR 
                                (LastName!=null and FirstName!=null and PersonBirthdate!=null and FirstName =: prod.First_Name__c AND LastName =: prod.Last_Name__c AND PersonBirthdate =: prod.Date_of_Birth__c) 
                                 OR 
                                (LastName!=null and PersonEmail!=null and FirstName!=null and FirstName LIKE : firstNameLetter AND LastName =: prod.Last_Name__c AND PersonEmail =: prod.Email_Address__c )
                                ) 
                                AND RecordTypeId =: recordTypeIDValue 
                                //AND (RecordType.Name= 'Customer Salesforce' OR RecordType.Name='Updated From SOR') 
                                ORDER BY CreatedDate DESC];
        }
            
        return accList;
    }
}