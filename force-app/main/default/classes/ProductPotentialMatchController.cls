/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This is a controller class to process product potential matches 
 *  @author : A5E Consulting
 *  @date : 02/15/2018
 *
 *************************************************************************************************/
public class ProductPotentialMatchController {
    
    public String prdctId;
    public Boolean manualReview{get;set;}
    public String validationErrMsg{get;set;}  
    
    //decides whether to refresh main detail page or not
    public Boolean refreshPage {get; set;}  
    
    //Wrapped Potential matches
    public List<PotentialMatchProductAccountWrapper> existingWrappedAccounts {get;set;}
        
    //Constructor
    public ProductPotentialMatchController(ApexPages.StandardController controller) {
        
        prdctId = ApexPages.currentPage().getParameters().get('id');
        existingWrappedAccounts = new List<PotentialMatchProductAccountWrapper>();
        refreshPage = false;
                
        Product__c prdct = getProductByID(prdctId);
        /*[Select Id, customer__c, 
                                        First_Name__c, Last_Name__c, Email_Address__c, 
                                        SIN__c, Date_of_Birth__c, 
                                        Needs_Manual_Review__c, Manual_Review_Reason__c 
                                        from  Product__c 
                                        where id=:prdctId];*/
                                        
        manualReview = prdct.Needs_Manual_Review__c == true ? true : false;
        
        if(manualReview){
        
            List<Account> potentialMatchList;
            
            /*
            if(String.isNotBlank(prdct.Last_Name__c)){
        
                String firstNameLetter;
                if(prdct.First_Name__c != null){
                    firstNameLetter = prdct.First_Name__c.subString(0,1)+'%';
                }
                
                potentialMatchList = [SELECT Id FROM Account WHERE (
                                    (LastName!=null and SIN__pc!=null and  LastName =: prdct.Last_Name__c AND SIN__pc =: prdct.SIN__c) 
                                     OR 
                                    (LastName!=null and FirstName!=null and PersonBirthdate!=null and FirstName =: prdct.First_Name__c AND LastName =: prdct.Last_Name__c AND PersonBirthdate =: prdct.Date_of_Birth__c) 
                                     OR 
                                    (LastName!=null and PersonEmail!=null and FirstName!=null and FirstName LIKE : firstNameLetter AND LastName =: prdct.Last_Name__c AND PersonEmail =: prdct.Email_Address__c )
                                    ) 
                                    AND (RecordType.Name= 'Customer Salesforce' OR RecordType.Name='Updated From SOR') 
                                    ORDER BY CreatedDate DESC];
            }
            */
            
            potentialMatchList = ProductUtil.queryCustomer(prdct, 'Canaccede Customer');
            if(!potentialMatchList.isEmpty()){
                                
                for(Account existingAcc : potentialMatchList){
                    if(existingAcc.Id != prdct.customer__c){
                        existingWrappedAccounts.add(new PotentialMatchProductAccountWrapper(existingAcc));
                    }                    
                }            
            }             
        }                                                                 
    }
    
    //Assign Application to selected Account  
    public PageReference assignSelected(){
        
        prdctId = ApexPages.currentPage().getParameters().get('id');         
        String matchAccntId;                
        Integer matchCnt = 0;
        refreshPage = false;
        
        for (PotentialMatchProductAccountWrapper matchAccntWrppr : existingWrappedAccounts){
            
            if(matchAccntWrppr.selected){
                matchAccntId = matchAccntWrppr.accnt.Id;
                matchCnt++;  
            }           
        }
        
        //Single selection
        if(matchCnt == 1){
            if(matchAccntId != null){
                //PotentialMatchUtil.assignSelectedAccountToApplication(Id.valueOf(matchAccntId), Id.valueOf(applnId));
                Product__C prdct = getProductByID(prdctId);
                prdct.Customer__c = matchAccntId;
                prdct.Manual_Review_Reason__c = null;
                prdct.Needs_Manual_Review__c = false;
        
                ProductTriggerHandler.runProductTrigger = false;
                update prdct;
                ProductTriggerHandler.runProductTrigger = true;
                refreshPage = true;
            }           
        }
        
        //No selection
        if(matchCnt == 0){
            validationErrMsg = 'You must first Select a Customer.';
            refreshPage = false;                        
        }
        
        //Multiple selection
        if(matchCnt > 1){
            validationErrMsg = 'Select only one Customer.';
            refreshPage = false;                    
        }   
               
        return null;     
    }
    
    //Create new Account and assign Application to it
    public PageReference createNewNAssign(){
        
        prdctId = ApexPages.currentPage().getParameters().get('id');
        //PotentialMatchUtil.createNewAccountAndAssignToApplication(Id.valueOf(applnId));
        Product__C prdct = getProductByID(prdctId);
        prdct.Customer__c = (ProductUtil.createCustomer(prdct, 'Canaccede Customer')).id;
        prdct.Manual_Review_Reason__c = null;
        prdct.Needs_Manual_Review__c = false;

        ProductTriggerHandler.runProductTrigger = false;
        update prdct;
        ProductTriggerHandler.runProductTrigger = true;
        
        refreshPage = true;
        
        return null;
    }
    
    //Keep Assignmnet as it is, reset review flags
    public PageReference keepSameCustomer(){
      
        prdctId = ApexPages.currentPage().getParameters().get('id');
        //PotentialMatchUtil.keepSameCustomer(Id.valueOf(applnId));
        Product__C prdct = getProductByID(prdctId);
        prdct.Manual_Review_Reason__c = null;
        prdct.Needs_Manual_Review__c = false;

        ProductTriggerHandler.runProductTrigger = false;
        update prdct;
        ProductTriggerHandler.runProductTrigger = true;
        refreshPage = true;
                       
        return null;
    }
    
    //WRapper Class
    public class PotentialMatchProductAccountWrapper {
        
        public Account accnt {get; set;}
        public Boolean selected {get;set;}
        public String accountLink {get;set;}
        public String birthdateStr {get;set;}
        
        public PotentialMatchProductAccountWrapper(Account accnt){
            
            this.accnt = accnt;
            this.selected = false; 
            this.accountLink = URL.getSalesforceBaseUrl().toExternalForm() + '/' + accnt.Id;    
            
            if(accnt.PersonBirthdate != null){
                birthdateStr = PotentialMatchUtil.formatDate(accnt.PersonBirthdate);        
            }
            else{
                birthdateStr = '';
            }
        }
    }
    
    public static String formatDate(Date d) {
        if (d == null) {
            return null;
        }
        return Datetime.newInstance(d.year(), d.month(), d.day()).format('MM-dd-yyyy');
    }
    
    public static Product__c getProductByID(Id prodID){
        Product__c prdct = [Select Id, customer__c, First_Name__c, Last_Name__c, Email_Address__c, SIN__c, Date_of_Birth__c, 
                            Needs_Manual_Review__c, Manual_Review_Reason__c, Address_Line1__c, Address_Line2__c, City__c,
                            Zip_Code__c, State__c, Phone_Home__c, Phone_Work__c, Phone_Other__c, Address_Last_Changed_Date__c
                            from  Product__c 
                            where id=:prodId];
        return prdct;
    }
}