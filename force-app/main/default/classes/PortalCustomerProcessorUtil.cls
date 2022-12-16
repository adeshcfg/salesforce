/**************************************************************************************************
*
*  Class:   
*
*  @description : Util class for Portal Customer Processing API
*  @author : A5E Consulting
*  @date : 18/08/2021

*************************************************************************************************/
public class PortalCustomerProcessorUtil {
	//Create Request Fund record 
    public static String updateCustomer(Map<String,String> paramMap, Account account){
        //Create temporary account instance to store request values
        Account tempAccountInstance = new Account();
        tempAccountInstance.FirstName = paramMap.get('Primary_FirstName');
        tempAccountInstance.LastName = paramMap.get('Primary_LastName');
        tempAccountInstance.PersonEmail = paramMap.get('Primary_PersonEmail');
        //tempAccountInstance.PersonBirthdate = datetime.valueOf(paramMap.get('Primary_PersonBirthdate'));
        tempAccountInstance.SIN__pc = paramMap.get('Primary_SIN');
        tempAccountInstance.PersonMailingStreet = paramMap.get('Primary_PersonMailingStreet');
        tempAccountInstance.PersonMailingCity = paramMap.get('Primary_PersonMailingCity');
        tempAccountInstance.PersonMailingPostalCode = paramMap.get('Primary_PersonMailingPostalCode');
        tempAccountInstance.PersonMailingState = paramMap.get('Primary_PersonMailingState');
        tempAccountInstance.PersonHomePhone = paramMap.get('Primary_PersonHomePhone');
        tempAccountInstance.Work_Phone__pc = paramMap.get('Primary_Work_Phone');
        tempAccountInstance.PersonMobilePhone = paramMap.get('Primary_PersonOtherPhone');
        
        system.debug('tempAccountInstance: '+tempAccountInstance);
        Date todayDate = Date.today();
        //Update customer contact information from API request params
        //Set Previous contact information on Customer
        if(account.FirstName != tempAccountInstance.FirstName){
            /*if(String.isNotBlank(account.FirstName)){
            	account.Previous_First_Name__c = account.FirstName;    
            }*/
            account.FirstName = tempAccountInstance.FirstName;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
        if(account.LastName != tempAccountInstance.LastName){
           /* if(String.isNotBlank(account.LastName)){
            	account.Previous_Last_Name__c = account.LastName;    
            }*/
            account.LastName = tempAccountInstance.LastName;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
        if(account.PersonEmail != tempAccountInstance.PersonEmail){
            /*if(String.isNotBlank(account.PersonEmail)){
            	account.Previous_Email_Address__c = account.PersonEmail;    
            }*/
            account.PersonEmail = tempAccountInstance.PersonEmail;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
        /*if(tempAccountInstance.PersonBirthDate != NULL 
        && account.PersonBirthdate != tempAccountInstance.PersonBirthdate){
            account.Previous_Birthdate__c = account.PersonBirthdate;
            account.PersonBirthdate = tempAccountInstance.PersonBirthdate;
            account.Portal_Profile_Update_Date__c = todayDate;
        }*/
        if(account.PersonMailingStreet != tempAccountInstance.PersonMailingStreet){
           /* if(String.isNotBlank(account.PersonMailingStreet)){
            	account.Previous_MailingStreet__c = account.PersonMailingStreet;    
            }*/
            account.PersonMailingStreet = tempAccountInstance.PersonMailingStreet; 
            account.Portal_Profile_Update_Date__c = todayDate;
            account.Portal_Address_Update_Date__c = todayDate;
        }
        if(account.PersonMailingCity != tempAccountInstance.PersonMailingCity){
           /* if(String.isNotBlank(account.PersonMailingCity)){
            	account.Previous_MailingCity__c = account.PersonMailingCity;       
            }*/
            account.PersonMailingCity = tempAccountInstance.PersonMailingCity; 
            account.Portal_Profile_Update_Date__c = todayDate;
            account.Portal_Address_Update_Date__c = todayDate;
        }
        if(account.PersonMailingPostalCode != tempAccountInstance.PersonMailingPostalCode){
           /* if(String.isNotBlank(account.PersonMailingPostalCode)){
            	account.Previous_MailingPostalCode__c = account.PersonMailingPostalCode;    
            }*/
            account.PersonMailingPostalCode = tempAccountInstance.PersonMailingPostalCode;
            account.Portal_Profile_Update_Date__c = todayDate;
            account.Portal_Address_Update_Date__c = todayDate;
        }
        if(account.PersonMailingState != tempAccountInstance.PersonMailingState){
           /* if(String.isNotBlank(account.PersonMailingState)){
            	account.Previous_MailingState__c = account.PersonMailingState;    
            }*/
            account.PersonMailingState = tempAccountInstance.PersonMailingState;
            account.Portal_Profile_Update_Date__c = todayDate;
            account.Portal_Address_Update_Date__c = todayDate;
        }
        if(account.PersonHomePhone != tempAccountInstance.PersonHomePhone){
            /*if(String.isNotBlank(account.PersonHomePhone)){
            	account.Previous_HomePhone__c = account.PersonHomePhone;    
            }*/
            account.PersonHomePhone = tempAccountInstance.PersonHomePhone;
            account.Previous_Invalidate_Home_Phone__c = tempAccountInstance.Invalidate_Home_Phone__c;
            account.Invalidate_Home_Phone__c = false;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
        if(account.Work_Phone__pc != tempAccountInstance.Work_Phone__pc){
           /* if(String.isNotBlank(account.Work_Phone__pc)){
            	account.Previous_WorkPhone__c = account.Work_Phone__pc;    
            }*/
            account.Work_Phone__pc = tempAccountInstance.Work_Phone__pc;
            account.Previous_Invalidate_Work_Phone__c = tempAccountInstance.Invalidate_Work_Phone__c;
            account.Invalidate_Work_Phone__c = false;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
        if(account.PersonMobilePhone != tempAccountInstance.PersonMobilePhone){
            if(String.isNotBlank(account.PersonMobilePhone)){
            	account.Previous_Mobile_Phone__c = account.PersonMobilePhone;    
            }
            account.PersonMobilePhone = tempAccountInstance.PersonMobilePhone;
            account.Portal_Profile_Update_Date__c = todayDate;
            account.Previous_Invalidate_Cell_Phone__c = tempAccountInstance.Invalidate_Cell_Phone__c;
            account.Invalidate_Cell_Phone__c = false;
        }
        //If SIN is updated to null in Portal, update SIN value on salesforce
        if(account.SIN__pc != tempAccountInstance.SIN__pc){
            if(String.isNotBlank(account.SIN__pc)){
            	account.Previous_SIN__c = account.SIN__pc;    
            }
            account.SIN__pc = tempAccountInstance.SIN__pc;
            account.Portal_Profile_Update_Date__c = todayDate;
        }
          
        //Update contact information on Product from Customer
        //Set Previous contact information on Product 
        list<Product__c> listProductsToUpdate = new list<Product__c>();
        List<Product__c> listProducts = account.Products__r;
        if(Test.isRunningTest()){
            listProducts = [SELECT ID, First_Name__c, Last_Name__c, Email_Address__c,
                            	   Address_Line1__c, City__c, Zip_Code__c/*, State__c*/, Phone_Home__c, 
                            	   Phone_Work__c, Phone_Other__c
                            //, Invalidate_Cell_Phone__c, Invalidate_Home_Phone__c, Invalidate_Work_Phone__c
                            FROM Product__c LIMIT 1];
        }
        for(Product__c product : listProducts){
            if(product.First_Name__c != tempAccountInstance.FirstName){
                /*if(String.isNotBlank(product.First_Name__c)){
                	product.Previous_First_Name__c = product.First_Name__c;    
                }*/
                product.First_Name__c = tempAccountInstance.FirstName;    
            }
            if(product.Last_Name__c != tempAccountInstance.LastName){
                /*if(String.isNotBlank(product.Last_Name__c)){
                	product.Previous_Last_Name__c = product.Last_Name__c;    
                }*/
                product.Last_Name__c = tempAccountInstance.LastName;    
            }
            if(product.Email_Address__c != tempAccountInstance.PersonEmail){
               /* if(String.isNotBlank(product.Email_Address__c)){
                	product.Previous_Email_Address__c = product.Email_Address__c;    
                }*/
                product.Email_Address__c = tempAccountInstance.PersonEmail;    
            }
            /*if(product.Date_of_Birth__c != tempAccountInstance.PersonBirthdate){
                product.Previous_Birthdate__c = product.Date_of_Birth__c;
                product.Date_of_Birth__c = tempAccountInstance.PersonBirthdate;    
            }**/
            if(product.Address_Line1__c != tempAccountInstance.PersonMailingStreet){
               /* if(String.isNotBlank(product.Address_Line1__c)){
                	product.Previous_MailingStreet__c = product.Address_Line1__c;    
                }*/
                product.Address_Line1__c = tempAccountInstance.PersonMailingStreet;   
            }
            if(product.City__c != tempAccountInstance.PersonMailingCity){
               /* if(String.isNotBlank(product.City__c)){
                	product.Previous_MailingCity__c = product.City__c;    
                }*/
                product.City__c = tempAccountInstance.PersonMailingCity;   
            }
            if(product.Zip_Code__c != tempAccountInstance.PersonMailingPostalCode){
                /*if(String.isNotBlank(product.Zip_Code__c)){
                	product.Previous_MailingPostalCode__c = product.Zip_Code__c;    
                }*/
                product.Zip_Code__c = tempAccountInstance.PersonMailingPostalCode;  
            }
            /*if(product.State__c != tempAccountInstance.PersonMailingState){
                if(String.isNotBlank(product.State__c)){
                	product.Previous_MailingState__c = product.State__c;    
                }
                product.State__c = tempAccountInstance.PersonMailingState;    
            }*/
            if(product.Phone_Home__c != tempAccountInstance.PersonHomePhone){
                /*if(String.isNotBlank(product.Phone_Home__c)){
                	product.Previous_HomePhone__c = product.Phone_Home__c;    
                }*/
                product.Phone_Home__c = tempAccountInstance.PersonHomePhone; 
                //product.Previous_Invalidate_Home_Phone__c = product.Invalidate_Home_Phone__c;
                //product.Invalidate_Home_Phone__c = false;
            }
            if(product.Phone_Work__c != tempAccountInstance.Work_Phone__pc){
                /*if(String.isNotBlank(product.Phone_Work__c)){
                	product.Previous_WorkPhone__c = product.Phone_Work__c;    
                }*/
                product.Phone_Work__c = tempAccountInstance.Work_Phone__pc; 
                //product.Previous_Invalidate_Work_Phone__c = product.Invalidate_Work_Phone__c;
                //product.Invalidate_Work_Phone__c = false;
            }
            /*if(product.Phone_Other__c != tempAccountInstance.PersonOtherPhone){
                product.Previous_OtherPhone__c = product.Phone_Other__c;
                product.Phone_Other__c = tempAccountInstance.PersonOtherPhone; 
                product.Previous_Invalidate_Other_Phone__c = product.Invalidate_Cell_Phone__c;
                product.Invalidate_Cell_Phone__c = false;
            }*/
            //Cell Phone on product API name = Phone_Other__c
            if(product.Phone_Other__c != tempAccountInstance.PersonMobilePhone){
                /*if(String.isNotBlank(product.Phone_Other__c)){
                	product.Previous_Cell_Phone__c = product.Phone_Other__c;    
                }*/
                product.Phone_Other__c = tempAccountInstance.PersonMobilePhone; 
                //product.Previous_Invalidate_Cell_Phone__c = product.Invalidate_Cell_Phone__c;
                ///product.Invalidate_Cell_Phone__c = false;
            }
            //product.First_Name__c = tempAccountInstance.SIN__pc ;            
            listProductsToUpdate.add(product);
        }
        
        try{
            //to not run customer trigger
            CustomerTriggerHandler.runCustomerTrigger = false;
            update account;
            CustomerTriggerHandler.runCustomerTrigger = true;
            
            //to not run product trigger
            ProductTriggerHandler.runProductTrigger = false;
            update listProductsToUpdate;
            ProductTriggerHandler.runProductTrigger = true; 
            return 'success';
        }
        catch(Exception ex){
            system.debug('Exception in payment transaction insert :'+ex);
            return ex.getMessage();
        }
    }
}