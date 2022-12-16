public class ComplaintWorkAssignmentWidgetController {
//@AuraEnabled Public static List<Settlement__C> settljudglist{set;get;}
  Public Static Set<Id> SetId = new Set<Id>();
  Public Static Set<Id> setProdId = new Set<Id>();
	@AuraEnabled 
    public static List<Product__C> getproduct(String parentId){
    	List<Work_Assignment__c> complaintprolist= [SELECT Product__c, Customer__c from Work_Assignment__c where id=: parentId ];
        system.debug('product record is' + complaintprolist);
        List<Id> lisid= new List<Id>();
        list<product__C> prodList = new List<Product__C>();
        for(Work_Assignment__c proid:complaintprolist){
            system.debug('Block'+proid);
            //if(proid.product__c <> NULL){
            	prodList = [SELECT Name, First_Name__c,Co_Borrower_First_Name__c,Last_Name__c,Co_Borrower_Last_Name__c,Current_Principal_Balance__c,
                            Current_Interest_Rate__c,Current_Interest_Amount__c,Current_Balance__c,Product_Type__c,Collection_Agency__c,
                            Collection_Agency_Formula__c,Refer_to_Legal__c,Collection_Sub_Status__c,Interest_Rate__c,Account_Portfolio_ID__c,Originating_Creditor__c
                            from Product__C where Id =: proid.product__c];
            //}
            
            /*else if(proid.Customer__c <> NULL){
                //prodList = JudgmentWidgetController.getaccountnumbers(proid.Judgment__c);
            }*/
        }
        system.debug('prodList' + prodList);
        return prodList;
    }

    @AuraEnabled 
	public static List<Account> getcustomer(String parentId){
    	List<Work_Assignment__c> complaintcustlist= [SELECT Product__c, Customer__c from Work_Assignment__c where id=: parentId ];
        For (Work_Assignment__c workAssig :complaintcustlist ){
            setProdId.add(workAssig.Product__c);
        }
        List<Product__c> prodList= [SELECT Id, Customer__c/*,(Select Name From Work_Assignments__r where id=: parentId)*/ from Product__c  where id=: setProdId ];
        For(Product__c prod :prodList ){
            SetId.add(prod.Customer__c);
        }
        system.debug('product record is' + complaintcustlist);
        List<Id> lisid= new List<Id>();
        list<Account> custList = new List<Account>();
        for(Work_Assignment__c custid:complaintcustlist){
            if(custid.Customer__c <> NULL){
            	/*custList = [SELECT Name, Customer_ID__c, Mobile_Phone__c, Office_Phone__c, BillingAddress,
                          AccountNumber, PersonEmail,Phone,ShippingAddress
                          from Account where Id =: custid.Customer__c];*/
                custList = [SELECT Name,Previous_First_Name__c,Previous_Last_Name__c,Previous_Email_Address__c,Previous_MailingCity__c,
                  			  Previous_HomePhone__c,Previous_Mobile_Phone__c,Previous_MailingStreet__c,Previous_MailingState__c,
                  			  Address_Type__pc,PersonMailingAddress,PersonHomePhone,PersonEmail,PersonMobilePhone,PersonMailingCity,PersonMailingState ,PersonMailingCountry
                  			  from Account where Id =: custid.Customer__c];
            }
            Else if (custid.Customer__c == NULL){
                custList = [SELECT Name,Previous_First_Name__c,Previous_Last_Name__c,Previous_Email_Address__c,Previous_MailingCity__c,
                  			  Previous_HomePhone__c,Previous_Mobile_Phone__c,Previous_MailingStreet__c,Previous_MailingState__c,
                  			  Address_Type__pc,PersonMailingAddress,PersonHomePhone,PersonEmail,PersonMobilePhone,PersonMailingCity,PersonMailingState,PersonMailingCountry
                  			  from Account where Id =:SetId ];
                
            }
      }
    	return custList;
    }
}