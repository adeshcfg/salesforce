/**************************************************************************************************
 *
 *  Class:    
 *
 *  @description : This is a controller class for account Search
 *  @author : A5E Consulting
 *  @date : 27/11/2020
 
 *************************************************************************************************/
 public without sharing class AccountSearchController{
    
     //Collection
    public List<Product__c> customerPortalProducts{get;set;}
    public List<SelectOption> listProvinces{get;set;}
   
    //Filters
    public String firstName{get;set;}
    public String lastName{get;set;}
    public String dateOfBirthStr{get;set;}
    public String city{get;set;}
    public String provinceName{get;set;}
    public String postalCode{get;set;}
    public String authenticationCode{get;set;}
    public String address1{get;set;}
    public String address2{get;set;}
    public String message{get;set;}
    
    //public String fullAddress;
    //public String provinceNameFull;
    
    public boolean showMessage{get;set;}
     
    //static variables 
    public static String QUEBEC = 'Quebec';
	public static String UNABLE_TO_RETRIEVE_INFO = 'We are unable to retrieve your information at this time.  Please contact Canaccede client services for assistance toll-free at '+
                        + '<a href="tel:1-888-316-2369" style="color: #0078d4;">1-888-316-2369</a>,'+
                            ' or <a href = "mailto: client.services@canaccede.com" style="color: #0078d4;">client.services@canaccede.com.</a>';    
     //Constructor
    public AccountSearchController(ApexPages.StandardController controller) {
        customerPortalProducts = new List<Product__c>();
        showMessage = false;
        //get provincelist
        listProvinces = getProvinceList();
    }   
    
    //Search Accounts on filter criteria    
    public Pagereference searchAccounts(){
        Customer_Portal_Setting__c setting = Customer_Portal_Setting__c.getOrgDefaults();
        try{
            //Date Hack, need to removeDate
            Date dateOfBirthDT;
            if(String.isnotblank(dateOfBirthStr)){
                String [] dateArray = dateOfBirthStr.split('-');
                system.debug('dateArray'+dateArray);
                dateOfBirthDT = Date.newInstance(Integer.valueOf(dateArray[2]), Integer.valueOf(dateArray[0]), 
                                Integer.valueOf(dateArray[1])); 
                system.debug('dateOfBirthDT: '+dateOfBirthDT);
                if(dateOfBirthDT > system.today()){
                    showMessage = true;
                    message = UNABLE_TO_RETRIEVE_INFO;
                    return null; 
                }
            }
    
            set<ID> setCustomerID = new set<ID>();
            String provinceNameFull;
            
            //get full name of selected Province
            if(String.isNotBlank(provinceName)){
                for(SelectOption so : listProvinces){
                    if(so.getValue() == provinceName){
                        provinceNameFull = so.getLabel();
                        break;
                    }
                }
            }

            //Concatename Street1 and Street2
            String fullAddress = (String.isBlank(address1) ? '' : address1.trim()) +
                                 (String.isBlank(address2) ? '' : ' ' + address2.trim());
            system.debug('fullAddress: '+'\''+fullAddress+'\'');
            
            //trim inputs to delete spaces
            firstName = String.isNotBlank(firstName) ? firstName.trim() : '' ;
            lastName = String.isNotBlank(lastName) ? lastName.trim() : '' ;
            address1 = String.isNotBlank(address1) ? address1.trim() : '' ;
            address2 = String.isNotBlank(address2) ? address2.trim() : '' ;
            if(String.isBlank(address2)){
                address2 = null;
            }
            
            city = String.isNotBlank(city) ? city.trim() : '' ;
            postalCode = String.isNotBlank(postalCode) ? postalCode.deleteWhitespace() : '' ;
            authenticationCode = String.isNotBlank(authenticationCode) ? authenticationCode.trim() : '' ;
            
            Set<Decimal> setPlacementsToInclude = new Set<Decimal>();
            for(Placement__c placement : [SELECT Name 
                                          FROM Placement__c 
                                          WHERE Include_In_Portal_Search__c = True]){
                setPlacementsToInclude.add(decimal.valueOf(placement.Name));                                              
            }
            
            //get the Account Purchase Groups to exclude from Portal Search
            list<String> listPurchaseGroupToExclude = 
                String.isNotBlank(setting.Exclude_Account_Purchase_Group__c) ? 
                setting.Exclude_Account_Purchase_Group__c.split(',') :
            	new list<String>{};
            
            //get the Portfolio Names to exclude from Portal Search
            list<String> listPortfolioNameToExclude = 
                String.isNotBlank(setting.Exclude_Portfolio_Name__c) ? 
                setting.Exclude_Portfolio_Name__c.split(',') :
            	new list<String>{};
                    
            //Fetch product records for the searched criteria
            //Check First Name and Last Name are not blank on the records
            List <Product__c> listProducts = [Select Id, Name, Customer__c, Collection_Agency__c, Account_Purchase_Group__c	,
                                              	  Portfolio_Name_Lookup__r.Name,
                                              	  Customer__r.Verification_Status__c, Customer__r.Verification_Sent_Date__c,
                                              	  Customer__r.Verification_Expiration_Date__c, Customer__r.User_Registration_Date__c
                                                  FROM Product__c 
                                                  WHERE 
                                                        RecordtypeID = :setting.Distressed_Product_RecordTypeID__c
                                                        AND Customer__r.RecordtypeId= :setting.Canaccede_Customer_RecordTypeID__c
                                                        AND 
                                                        (
                                                            (                                                           
                                                                Customer__r.Secret_Code__c= :authenticationCode
                                                                AND Customer__r.Secret_Code_Expiration_Date__c > TODAY
                                                                AND Customer__c != null
                                                                //AND State__c != :QUEBEC
                                                                AND Customer__r.PersonMailingState != :QUEBEC
                                                                //AND State__c !=  'QC'
                                                                AND Customer__r.PersonMailingState != 'QC'                                                          
                                                            )  
                                                            or  
                                                            (   ((First_Name__c != null AND Customer__r.FirstName != null) AND (First_Name__c= :firstName or Customer__r.FirstName= :firstName)) 
                                                                AND ((Last_Name__c != null AND Customer__r.LastName != null) AND(Last_Name__c= :lastName or Customer__r.LastName= :lastName))
                                                                AND ((((Address_Line1__c= :address1 and Address_Line2__c= :address2) 
                                                                 or (Customer__r.PersonMailingStreet= :fullAddress))
                                                                AND (City__c = :city OR Customer__r.PersonMailingCity= :city)
                                                                AND (/*State__c = :provinceName 
                                                                    OR*/ Customer__r.PersonMailingState = :provinceName
                                                                    OR Customer__r.PersonMailingState = :provinceNameFull
                                                                    /*OR State__c = :provinceNameFull*/)
                                                                AND (Postal_Code_Without_Space__c = :postalCode
                                                                    OR Customer__r.Postal_Code_Without_Space__c= :postalCode))
                                                                OR ((Date_Of_Birth__c != NULL) AND (Date_Of_Birth__c= :dateOfBirthDT OR Customer__r.PersonBirthdate= :dateOfBirthDT)))
                                                            ) 
                                                        )
                                                  LIMIT 10
                                                  ];
            system.debug('listProducts: '+listProducts);
            
            if(!listProducts.isEmpty()){
                for(Product__c product : listProducts){
                    setCustomerID.add(product.Customer__c);
                }
                system.debug('setCustomerID: '+setCustomerID.size());
                system.debug('listProducts.size() '+listProducts.size());
                system.debug('listPurchaseGroupToExclude '+listPurchaseGroupToExclude);
                system.debug('value '+listProducts[0].Account_Purchase_Group__c);
                system.debug('boolean '+listPurchaseGroupToExclude.contains(String.valueOf(listProducts[0].Account_Purchase_Group__c)));
                
                //error message if multiple customers/products found for searched crietria
                //If single product is associated,check agency checkbox to 'Include in Portal Search' = false and show error
                if(setCustomerID.size() > 1 || listProducts.size() > 1 || 
					(listProducts.size() == 1 
                    && 
					(!setPlacementsToInclude.contains(listProducts[0].Collection_Agency__c) 
                  	|| (listProducts[0].Account_Purchase_Group__c != NULL 
                    	&& listPurchaseGroupToExclude.contains(String.valueOf(listProducts[0].Account_Purchase_Group__c)))
                    || (listProducts[0].Portfolio_Name_Lookup__r.Name != NULL 
                    	&& listPortfolioNameToExclude.contains(String.valueOf(listProducts[0].Portfolio_Name_Lookup__r.Name)))   
                       )
                    )
                ){
                    showMessage = true;
                    message = UNABLE_TO_RETRIEVE_INFO;
					return null; 
                }
                else{
                    Account accountToUpdate = new Account();
                    accountToUpdate.Id = listProducts[0].Customer__c;
                    accountToUpdate.Search_Performed__c = true;
                    if(String.isNotBlank(authenticationCode)){
                        accountToUpdate.Secret_Code_Last_Used_Date__c = system.now();    
                    }
                    
                    update accountToUpdate;
                    
                    //display message if customer is registered but not verified
                    if(listProducts[0].Customer__r.Verification_Status__c != 'Verified'
                    && listProducts[0].Customer__r.User_Registration_Date__c != null){
                        showMessage = true;
                        message = 'Your information has not yet been verified.  Please click on the link that was emailed to you to complete the verification process.<br/><br/>If you require assistance, please contact Canaccede client services for assistance toll-free at '
                        + '<a href="tel:1-888-316-2369" style="color: #0078d4;">1-888-316-2369</a>,'+
                            ' or <a href = "mailto: client.services@canaccede.com" style="color: #0078d4;">client.services@canaccede.com.</a>';                          
                        return null; 
                    }
                    //else redirect
                    else{
                        showMessage = false;
                        PageReference retURL;
                        retURL = new PageReference('/apex/AccountInitiate'+'?_iframeDomain='+ setting.iFrameDomain__c+'&uniqueID='+listProducts[0].Customer__c);
                        system.debug('retURL in Search: '+retURL);
                        retURL.setRedirect(true);
                        return retURL;    
                    }
                }
            }
            else{
                showMessage = true;
                message = UNABLE_TO_RETRIEVE_INFO;
            }
        }
        catch(Exception ex){
            system.debug('exception: '+ex);
            showMessage = true;
            message = UNABLE_TO_RETRIEVE_INFO;
        }      
        return null;
    }

    //List of Provinces
    public list<SelectOption> getProvinceList(){
        list<SelectOption> listProvinces = new list<SelectOption>();
        listProvinces.add(new SelectOption('','Province'));
        listProvinces.add(new SelectOption('Alberta','AB'));
        listProvinces.add(new SelectOption('British Columbia','BC'));
        listProvinces.add(new SelectOption('Manitoba','MB'));
        listProvinces.add(new SelectOption('New Brunswick','NB'));
        listProvinces.add(new SelectOption('Newfoundland and Labrador','NL'));
        listProvinces.add(new SelectOption('Northwest Territories','NT'));
        listProvinces.add(new SelectOption('Nova Scotia','NS'));
        listProvinces.add(new SelectOption('Nunavut','NU'));
        listProvinces.add(new SelectOption('Ontario','ON'));
        listProvinces.add(new SelectOption('Prince Edward Island','PE'));
        listProvinces.add(new SelectOption('Saskatchewan','SK'));
        listProvinces.add(new SelectOption('Yukon','YT'));
        return listProvinces;
     }
}