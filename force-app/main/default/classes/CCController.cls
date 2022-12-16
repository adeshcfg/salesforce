/**************************************************************************************************
 *
 *  Class:   
 *
 *  @description : This class is responsible for cleaning of Contact Centre records related to particular campaign
 *  @author : A5E Consulting
 *  @date : 02/01/2022
 * 
 *************************************************************************************************/
public class CCController {
  
    // Get Set methods for message Flag 
    public Boolean messageFlag{get; set;}
    
    //public static Final String LRT_CAMPAIGN_NAME = 'LRT 8x8 Dialer';
        

    public CCController (ApexPages.StandardController stdController) {
        messageFlag = false;
    }
    
    public CCController(){
      
    }
  
    // Delete LRT Contact Centre records                                    
    public void deleteCCRecords(){
              
        try{
            Database.executeBatch(new ContactCentreCleaner(ApexPages.currentPage().getParameters().get('id')));
            messageFlag = true;          
        }
        catch(Exception e){
            messageFlag=false;
        } 
    }
}