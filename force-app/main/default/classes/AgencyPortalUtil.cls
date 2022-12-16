/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : Utility class for Agency Portal 
 *  @author : A5E Consulting
 *  @date : 06/30/2022
 
 *************************************************************************************************/
public class AgencyPortalUtil {
    
    //Get agency user first Name last name from email address
    public static string getUserNamefromEmail(String emailAddress){
        
        list<Agency_User__c> agencyUsers = [SELECT First_Name__c, 
                                                  Last_Name__c,
                                                  Email_Address__c 
                                                  from Agency_User__c
                                                  where Email_Address__c =:emailAddress];
        
        //Send first name last name if agency user found
        if(!agencyUsers.isEmpty()){
            return agencyUsers[0].First_Name__c +' '+ agencyUsers[0].Last_Name__c;
        }
        //send email address if agency user is not found
        else {
            return emailAddress;
        }                                       
    }
}