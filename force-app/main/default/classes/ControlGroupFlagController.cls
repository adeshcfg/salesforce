public class ControlGroupFlagController {
    
    public Insolvency_Account__c InsolAcc {get;set;}
    public boolean hasControlGroupFlag {get;set;}
    
      
    public ControlGroupFlagController(ApexPages.StandardController controller){
        
        Id insolvencyId = controller.getId();
        InsolAcc = [SELECT Id, Control_Group__c FROM Insolvency_Account__c WHERE Id = :insolvencyId];
        
        hasControlGroupFlag = checkPermission();
    }
    
   private Boolean checkPermission() {
       
        Id currentUserId = UserInfo.getUserId();

        Boolean hasPermission = [
        SELECT COUNT() 
        FROM PermissionSetAssignment 
        WHERE AssigneeId = :currentUserId 
        AND PermissionSet.Name = 'Control_Group_Flag'
    ] >0;
    
    return hasPermission;

   } 
}