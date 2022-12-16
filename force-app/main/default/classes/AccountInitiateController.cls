/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a controller class for account Intiate Controller
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/

public class AccountInitiateController {
   	Id uniqueID;
    Id notRegistered;
    String secureCode;
    public string callfunc{get;set;}
    public String urlForRedirection{get;set;}

    public AccountInitiateController(){
        uniqueID = apexpages.currentpage().getparameters().get('uniqueID');
		secureCode = apexpages.currentpage().getparameters().get('secureCode');
        system.debug('uniqueID'+uniqueID);
        system.debug('secureCode'+secureCode);
    }
    public pageReference checkNavigation(){
        system.debug('check'+secureCode);
        Customer_Portal_Setting__c	setting = Customer_Portal_Setting__c.getOrgDefaults();
        urlForRedirection = null;
        callfunc = null;
        //commented the code as securelink is scrapped
        /*if(secureCode != null){
            list<Account> listCustomer = [SELECT ID, User_Registration_Date__c, Verification_Status__c, 
                                          		 Verification_Expiration_Date__c
                                          FROM Account
                                          WHERE Secret_Code__c =:secureCode
                                          LIMIT 1];
            system.debug('listCustomer: '+listCustomer);
            if(listCustomer[0].User_Registration_Date__c != null
            && listCustomer[0].Verification_Status__c == 'Verified'){
                Pagereference pageRef = new PageReference(setting.Account_Results_page__c +'?uniqueID='+listCustomer[0].Id);
        		urlForRedirection = pageref.getURL();
                callfunc='<script> func(); </script>';
                return null;
            }
            else if (listCustomer[0].User_Registration_Date__c == null){
                //redirect to registration
                PageReference retURL;
                retURL = new PageReference(setting.Customer_Registration_Page__c+'?uniqueID='+listCustomer[0].Id 
                                           + '&iframeDomain=https%3A%2F%2Fmycfgdev.wpengine.com');
                system.debug('retURL registration: '+retURL);
                retURL.setRedirect(true);
                return retURL;
            }
        }
        
        else*/
		if(uniqueID != null){
       		list<Account> listCustomer = [SELECT ID, User_Registration_Date__c, Verification_Status__c, 
                                          		 Verification_Expiration_Date__c
                                          FROM Account
                                          WHERE ID =:uniqueID];
            system.debug('listCustomer in unique code: '+listCustomer);
            if(listCustomer[0].User_Registration_Date__c != null
            && listCustomer[0].Verification_Status__c == 'Verified'){
                Pagereference pageRef = new PageReference(setting.Account_Results_page__c +'?_iframeDomain='+setting.iFrameDomain__c+'&uniqueID='+listCustomer[0].Id);
        		urlForRedirection = pageref.getURL();
                callfunc='<script> func(); </script>';
                return null;
                /*PageReference retURL;
                retURL = new PageReference(setting.Account_Results_page__c +'?uniqueID='+listCustomer[0].Id);
                retURL.setRedirect(true);
                return retURL;*/
            }
            else if (listCustomer[0].User_Registration_Date__c == null){
                urlForRedirection = null;
                callfunc = null;	
                PageReference retURL;
                system.debug('listCustomer[0].User_Registration_Date__c '+listCustomer[0]);
                retURL = new PageReference(setting.Customer_Registration_Page__c +'?_iframeDomain='+setting.iFrameDomain__c+'&uniqueID='+listCustomer[0].Id);
                system.debug('retURL registration: '+retURL);
                retURL.setRedirect(true);
                return retURL;
            }
        }
        return null;
    }
}