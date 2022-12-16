/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a trigger handler class for Customer object 
 *  @author : A5E Consulting
 *  @date : 03/08/2021
 
 *************************************************************************************************/
public class CustomerTriggerHandler {
    
    public static boolean runCustomerTrigger = true; 
    public static String CANACCEDE_CUSTOMER = 'Canaccede_Customer';
    public static String DISTRESSED_ACCOUNT = 'Distressed_Account';
    
    public static void onBeforeUpdate(map<Id, Account> mapOldAccounts, list<Account> listNewAccounts){
        //Commenting the code to update Customer contact information as it is handled using API 
        //and moved to PortalPaymentProcessorCustomer 18.08.2021
        
        for(Account account : listNewAccounts){
            Account oldAccountInstance = mapOldAccounts.get(account.ID);
            system.debug('recordtype='+account.Record_Type_Name__c);
            if(account.Record_Type_Name__c == CANACCEDE_CUSTOMER){
                system.debug('record updating');
                //Update Previous details fields if Customer Profile data is updated
                if(account.FirstName != oldAccountInstance.FirstName){
                    if(String.isNotBlank(oldAccountInstance.FirstName)){
                        account.Previous_First_Name__c = oldAccountInstance.FirstName;    
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                }
                if(account.LastName != oldAccountInstance.LastName){
                    if(String.isNotBlank(oldAccountInstance.LastName)){
                        account.Previous_Last_Name__c = oldAccountInstance.LastName;    
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                }
                if(account.PersonEmail != oldAccountInstance.PersonEmail){
                    if(String.isNotBlank(oldAccountInstance.PersonEmail)){
                        account.Previous_Email_Address__c = oldAccountInstance.PersonEmail;   
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                }
                if(account.PersonBirthdate != oldAccountInstance.PersonBirthdate){
                    if(null != oldAccountInstance.PersonBirthdate){
                        account.Previous_Birthdate__c = oldAccountInstance.PersonBirthdate;    
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                }
                if(account.PersonMailingStreet != oldAccountInstance.PersonMailingStreet){
                    if(String.isNotBlank(oldAccountInstance.PersonMailingStreet)){
                        account.Previous_MailingStreet__c = oldAccountInstance.PersonMailingStreet;       
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Portal_Address_Update_Date__c = Date.Today();
                }
                if(account.PersonMailingCity != oldAccountInstance.PersonMailingCity){
                    if(String.isNotBlank(oldAccountInstance.PersonMailingCity)){
                        account.Previous_MailingCity__c = oldAccountInstance.PersonMailingCity;       
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Portal_Address_Update_Date__c = Date.Today();
                }
                if(account.PersonMailingPostalCode != oldAccountInstance.PersonMailingPostalCode){
                    if(String.isNotBlank(oldAccountInstance.PersonMailingPostalCode)){
                        account.Previous_MailingPostalCode__c = oldAccountInstance.PersonMailingPostalCode;    
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Portal_Address_Update_Date__c = Date.Today();
                }
                if(account.PersonMailingState != oldAccountInstance.PersonMailingState){
                    if(String.isNotBlank(oldAccountInstance.PersonMailingState)){
                        account.Previous_MailingState__c = oldAccountInstance.PersonMailingState;        
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Portal_Address_Update_Date__c = Date.Today();
                }
                if(account.PersonHomePhone != oldAccountInstance.PersonHomePhone){
                    if(String.isNotBlank(oldAccountInstance.PersonHomePhone)){
                        account.Previous_HomePhone__c = oldAccountInstance.PersonHomePhone;       
                        account.Previous_Invalidate_Home_Phone__c = oldAccountInstance.Invalidate_Home_Phone__c;
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Invalidate_Home_Phone__c = false;
                }
                if(account.Work_Phone__pc != oldAccountInstance.Work_Phone__pc){
                    if(String.isNotBlank(oldAccountInstance.Work_Phone__pc)){
                        account.Previous_WorkPhone__c = oldAccountInstance.Work_Phone__pc;     
                        account.Previous_Invalidate_Work_Phone__c = oldAccountInstance.Invalidate_Work_Phone__c;
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Invalidate_Work_Phone__c = false;
                }
                if(account.PersonMobilePhone != oldAccountInstance.PersonMobilePhone){
                    if(String.isNotBlank(oldAccountInstance.PersonMobilePhone)){
                        account.Previous_Mobile_Phone__c = oldAccountInstance.PersonMobilePhone;     
                        account.Previous_Invalidate_Cell_Phone__c = oldAccountInstance.Invalidate_Cell_Phone__c;
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                    account.Invalidate_Cell_Phone__c = false;
                }
                if(account.SIN__pc != oldAccountInstance.SIN__pc){
                    if(String.isNotBlank(oldAccountInstance.SIN__pc)){
                        account.Previous_SIN__c = oldAccountInstance.SIN__pc;    
                    }
                    account.Portal_Profile_Update_Date__c = Date.Today();
                }    
            }
            
        }
        
    }
    
    public static void onAfterUpdate(map<Id, Account> mapOldAccounts, list<Account> listNewAccounts){
        system.debug('run customer trigger');
        Application_Config_Settings__c  config = Application_Config_Settings__c.getOrgDefaults();
        if(listNewAccounts[0].Portal_Profile_Update_Date__c == Date.today()){
            if(config.Run_Customer_Update_API_for_Portal__c){
                system.debug('run api');
                set<ID> setAccountID = new set<ID>();
                
                //commented code to send one account record to API 
                //PortalCustomerUpdateAPI.updateCustomerDetails(listNewAccounts[0].ID);  
                
                //Sending on account id one by one to customer API 
                //for(ID accountID : mapOldAccounts.keySet()){
                    //PortalCustomerUpdateAPI.updateCustomerDetails(accountID);  
                    //CustomerTriggerHandler.callCustomerUpdateApi(mapOldAccounts.keySet());
                //}
                PortalCustomerUpdateAPI.updateCustomerDetails(mapOldAccounts.keySet());  
            }
            //updateRelatedProducts(listNewAccounts);
        }
    }
    
    
   /* public static void updateRelatedProducts(list<Account> listNewAccounts){
        system.debug('update product called');
        list<Product__c> listProductsToUpdate = new list<Product__c>();
        list<Product__c> customerRelatedProducts = [SELECT ID, First_Name__c, Last_Name__c, Email_Address__c, Address_Line1__c, City__c, Zip_Code__c, 
                                                           State__c, Phone_Home__c, Phone_Work__c, Phone_Other__c, Date_of_Birth__c,
                                                           //Invalidate_Cell_Phone__c   , Invalidate_Home_Phone__c, Invalidate_Work_Phone__c,
                                                           Customer__c, Customer__r.FirstName, Customer__r.LastName, Customer__r.PersonEmail, Customer__r.PersonMobilePhone,
                                                           Customer__r.PersonBirthdate, Customer__r.SIN__pc, Customer__r.PersonMailingStreet, 
                                                           Customer__r.PersonMailingCity , Customer__r.PersonMailingPostalCode, Customer__r.PersonMailingState,
                                                           Customer__r.PersonHomePhone, Customer__r.Work_Phone__pc , Customer__r.PersonOtherPhone 
                                                    FROM Product__c
                                                    WHERE Customer__c IN :listNewAccounts
                                                    AND RecordType.DeveloperName = :DISTRESSED_ACCOUNT
                                                    AND Customer__r.RecordType.Developername = :CANACCEDE_CUSTOMER];
        system.debug('customerRelatedProducts: '+customerRelatedProducts);
        for(Product__c product : customerRelatedProducts){
            if(product.First_Name__c != product.Customer__r.FirstName){
                if(String.isNotBlank(product.First_Name__c)){
                    //product.Previous_First_Name__c = product.First_Name__c;   
                }
                product.First_Name__c = product.Customer__r.FirstName;    
            }
            if(product.Last_Name__c != product.Customer__r.LastName){
                if(String.isNotBlank(product.Last_Name__c)){
                    //product.Previous_Last_Name__c = product.Last_Name__c;    
                }
                product.Last_Name__c = product.Customer__r.LastName;    
            }
            if(product.Email_Address__c != product.Customer__r.PersonEmail){
                if(String.isNotBlank(product.Email_Address__c)){
                    //product.Previous_Email_Address__c = product .Email_Address__c;    
                }
                product.Email_Address__c = product.Customer__r.PersonEmail;    
            }
            if(product.Date_of_Birth__c != product.Customer__r.PersonBirthdate){
                if(NULL != product.Date_of_Birth__c){
                    //product.Previous_Birthdate__c = product.Date_of_Birth__c;    
                }
                product.Date_of_Birth__c = product.Customer__r.PersonBirthdate;    
            }
            if(product.Address_Line1__c != product.Customer__r.PersonMailingStreet){
                if(String.isNotBlank(product.Address_Line1__c)){
                    //product.Previous_MailingStreet__c = product.Address_Line1__c;    
                }
                product.Address_Line1__c = product.Customer__r.PersonMailingStreet;   
            }
            if(product.City__c != product.Customer__r.PersonMailingCity){
                if(String.isNotBlank(product.City__c)){
                    //product.Previous_MailingCity__c = product.City__c;    
                }
                product.City__c = product.Customer__r.PersonMailingCity;   
            }
            if(product.Zip_Code__c != product.Customer__r.PersonMailingPostalCode){
                if(String.isNotBlank(product.Zip_Code__c)){
                    //product.Previous_MailingPostalCode__c = product.Zip_Code__c;    
                }
                product.Zip_Code__c = product.Customer__r.PersonMailingPostalCode;  
            }
            if(product.State__c != product.Customer__r.PersonMailingState){
                if(String.isNotBlank(product.State__c)){
                    //product.Previous_MailingState__c = product.State__c;    
                }
                product.State__c = product.Customer__r.PersonMailingState;    
            }
            if(product.Phone_Home__c != product.Customer__r.PersonHomePhone){
                if(String.isNotBlank(product.Phone_Home__c)){
                    //product.Previous_HomePhone__c = product.Phone_Home__c;    
                }
                product.Phone_Home__c = product.Customer__r.PersonHomePhone;  
                //product.Previous_Invalidate_Home_Phone__c = product.Invalidate_Home_Phone__c;
                //product.Invalidate_Home_Phone__c = false;
            }
            if(product.Phone_Work__c != product.Customer__r.Work_Phone__pc){
                if(String.isNotBlank(product.Phone_Work__c)){
                    //product.Previous_WorkPhone__c   = product.Phone_Work__c;    
                }
                product.Phone_Work__c = product.Customer__r.Work_Phone__pc;
                //product.Previous_Invalidate_Work_Phone__c = product.Invalidate_Work_Phone__c;
                //product.Invalidate_Work_Phone__c = false;
            }
            //Cell Phone on product API name = Phone_Other__c
            if(product.Phone_Other__c != product.Customer__r.PersonMobilePhone){                
                if(String.isNotBlank(product.Phone_Other__c)){
                    //product.Previous_Cell_Phone__c = product.Phone_Other__c;    
                }
                product.Phone_Other__c = product.Customer__r.PersonMobilePhone; 
                //product.Previous_Invalidate_Cell_Phone__c = product.Invalidate_Cell_Phone__c;
                //product.Invalidate_Cell_Phone__c = false;
                
            }
            //product.First_Name__c = product.Customer__r.SIN__pc ; 
            
            listProductsToUpdate.add(product);
            
        }
        ProductTriggerHandler.runProductTrigger = false;
        system.debug('listProductsToUpdate: '+listProductsToUpdate);
        update listProductsToUpdate;
        ProductTriggerHandler.runProductTrigger = true; 
    } */
}