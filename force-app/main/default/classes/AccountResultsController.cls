/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a controller class for account Results
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/

public class AccountResultsController {
    public Product__c productRecord {get;set;}
    public String collectionAgencyName {get;set;}
    public String collectionAgencyURL {get;set;}
    public String collectionAgencyPhone {get;set;}
    public String collectionAgencyEmail {get;set;}
    public String collectionAgencyAddress {get;set;}
    public String customerName {get;set;}
    public String accountID;
    public String secureCode;
    public string callfunc{get;set;}
    public String urlForRedirection{get;set;}
    public boolean showPayment{get;set;}
    public boolean showError{get;set;}
    public Customer_Portal_Setting__c setting{get;set;}
    
    //Constuctor
    public AccountResultsController(){
        accountID = apexpages.currentpage().getparameters().get('uniqueID');
        secureCode = apexpages.currentpage().getparameters().get('secureCode');
        urlForRedirection = null;
        callfunc = null;
        showPayment = false;
        showError = false;
        setting = Customer_Portal_Setting__c.getOrgDefaults();
		//Cookie searchPerformed = ApexPages.currentPage().getCookies().get('searchPerformed');
        /*if(accountID!= NULL && secureCode == NULL){
        	if(searchPerformed == NULL){
                system.debug('searchPerformed null: '+searchPerformed);
                showPayment = false;
                //return null;
            }
            else{
                system.debug('searchPerformed not null: '+searchPerformed);
                showPayment = true;
            }    
        }
        else{
            showPayment = true;
        }*/
        system.debug('showPayment '+showPayment);
    }
    
    //Check method to results
    public pageReference check(){        
        /*Cookie searchPerformed = ApexPages.currentPage().getCookies().get('searchPerformed');
        system.debug('searchPerformed:: '+searchPerformed);
        if(searchPerformed == null || searchPerformed.getValue() != 'Yes'){
            Pagereference pageRef = new PageReference(setting.Error_page_URL__c);
        	  urlForRedirection = pageref.getURL();
              callfunc='<script> redirectToError(); </script>';
              return null;
        }
        else{
            system.debug('set');
            //Cookie searchPerformedNo = new Cookie('searchPerformed', 'No', null,0, true);
        	//ApexPages.currentPage().setCookies(new Cookie[]{searchPerformedNo});
        	//system.debug('cookie after deletion:'+ApexPages.currentPage().getCookies().get('searchPerformed'));
        }*/
        //Redirect to error page URL if no parameter passed in URL
        if(String.isBlank(accountID)
        && String.isBlank(secureCode)) {
			  Pagereference pageRef = new PageReference(setting.Error_page_URL__c);
        	  urlForRedirection = pageref.getURL();
              callfunc='<script> redirectToError(); </script>';
              return null;
        }
        
        list<Product__c> customerPortalProducts = new list<Product__c>();
        //fetch customer details using accountID
        if(accountID != null){
            customerPortalProducts = [SELECT Id, Name, First_Name__c, Last_Name__c, Next_Amount_Due__c,
                                                    Date_of_Birth__c, Current_Balance__c, Originating_Creditor__c,
                                                    Interest_Rate__c, Current_Principal_Balance__c,
                                                    Last_Payment_Date__c, Collection_Agency__c,Current_Interest_Amount__c,
                                                    Customer__r.FirstName,Customer__r.LastName, Customer__r.AccountNumber,
                                                   Customer__r.Name, Interest_Rate_Display__c, Customer__r.Search_Performed__c	
                                                    FROM Product__c WHERE Customer__c= :accountID];    
        }
        //fetch customer details using secure Code
        else {
			customerPortalProducts = [SELECT Id, Name, First_Name__c, Last_Name__c, Next_Amount_Due__c,
                                                    Date_of_Birth__c, Current_Balance__c, Originating_Creditor__c,
                                                    Interest_Rate__c, Current_Principal_Balance__c,
                                                    Last_Payment_Date__c, Collection_Agency__c,Current_Interest_Amount__c,
                                                    Customer__r.FirstName,Customer__r.LastName, Customer__r.AccountNumber,
                                                   Customer__r.Name, Interest_Rate_Display__c, Customer__r.Search_Performed__c
                                                    FROM Product__c WHERE Customer__r.Secret_Code__c= :secureCode];                
        }
        if(!customerPortalProducts.isEmpty()){
            productRecord = new Product__c();    
            productRecord = customerPortalProducts[0];
            system.debug('productRecord.Customer__r.Search_Performed__c'+productRecord.Customer__r.Search_Performed__c);
            /*if(String.isNotBlank(secureCode) && productRecord.Collection_Agency__c == NULL){
                showError = true;
                return null;
            }*/
            //commenting accountID check, as secureLink is scrapped
            if(/*String.isNotBlank(accountID)
            &&*/ productRecord.Customer__r.Search_Performed__c == false){
				Pagereference pageRef = new PageReference(setting.Error_page_URL__c);
				urlForRedirection = pageref.getURL();
                callfunc='<script> redirectToError(); </script>';
                return null;
            }
            showPayment = true;
            customerName = (String.isBlank(productRecord.Customer__r.FirstName) ? '' : productRecord.Customer__r.FirstName.ToLowerCase()) +
                           (String.isBlank(productRecord.Customer__r.LastName) ? '' : ' ' + productRecord.Customer__r.LastName.ToLowerCase());
            //Get Placement Agency details
            List<Placement__c> listPlacements = [SELECT ID, Name, Agency_Name__c, Agency_Email__c, Agency_Phone_Number__c,
                                                    Agency_Address__c, Agency_Logo_URL__c, Include_In_Portal_Search__c	
                                                 FROM Placement__c
                                                 WHERE Name= :String.valueOf(productRecord.Collection_Agency__c)];
            if(!listPlacements.isEmpty()){
        		//Set page variables
                collectionAgencyName = listPlacements[0].Agency_Name__c;
                collectionAgencyURL = listPlacements[0].Agency_Logo_URL__c;
                collectionAgencyPhone = listPlacements[0].Agency_Phone_Number__c  ;
                collectionAgencyEmail= listPlacements[0].Agency_Email__c;
                collectionAgencyAddress = listPlacements[0].Agency_Address__c;
                /*if(listPlacements[0].Include_In_Portal_Search__c == true){
                    showPayment = true;
                }
                else{
                    showPayment = false;
                }*/
                //Cookie searchPerformedNo = new Cookie('searchPerformed', 'No', null,-1, true);
                //ApexPages.currentPage().setCookies(new Cookie[]{searchPerformedNo});
                //system.debug('cookie after deletion:'+ApexPages.currentPage().getCookies().get('searchPerformed'));
                Account accountToUpdate = new Account();
                accountToUpdate.Id = productRecord.Customer__c;
                accountToUpdate.Search_Performed__c	= false;
                
                system.debug('on update');
                update accountToUpdate;
            }
        }
        //redirect to error page URL in case of invalid URL parameters
        else{
            system.debug('inside else error');
            Pagereference pageRef = new PageReference(setting.Error_page_URL__c);
        	urlForRedirection = pageref.getURL();
            callfunc='<script> redirectToError(); </script>';
            return null;
        }
        
        	return null;
    }
}