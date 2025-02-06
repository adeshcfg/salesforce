public class SendToVotingEngineController {
    
    public string message{get;set;}
    
    public SendToVotingEngineController(ApexPages.StandardController stdController) {
        
        
    }
    //This inner method resubmit the voting engine automation - insolvency voting engine
    public void mypageloadingmethod(){

        List<Id> votingAutomationList = new List<Id>();
        string InsolId = ApexPages.CurrentPage().getParameters().get('Id');
        votingAutomationList.add(InsolId);
        List<Insolvency__c> listInsolToUpdate = new List<Insolvency__c>();
        String newManualReviewReason = '';
        try{
            
            List<Insolvency__c> Insol = [select id, name, Manual_Review_Reason__c,Eligible_For_Voting_Decision__c,Total_Estimated_Realizable_Value__c from insolvency__c where id =: InsolId];
            system.debug('ID is' +Insol);
            
            for(Insolvency__c insolNew : Insol){
                if(insolNew.Total_Estimated_Realizable_Value__c >= 20000){
                    insolNew.Eligible_For_Voting_Decision__c = true;
                    insolNew.Voting_Decision__c = 'Needs Manual Review';
                    insolNew.Manual_Review_Reason__c = 'Total Estimated Realizable Value should be less than $20000';
                    listInsolToUpdate.add(insolNew);
                    message = 'Voting decision cannot be set, if Total Estimated Realizable Value is equal or greater than $20000.'; 
                }else{
                    if(insolNew.Eligible_For_Voting_Decision__c == true){
                        if(insolNew.Manual_Review_Reason__c.contains('Total Estimated Realizable Value should be less than $20000')){
                            newManualReviewReason = insolNew.Manual_Review_Reason__c.remove('Total Estimated Realizable Value should be less than $20000');
                            insolNew.Manual_Review_Reason__c = newManualReviewReason;
                            listInsolToUpdate.add(insolNew);
                        }
                        VotingEngineFutureCall.votingAutomationCall(votingAutomationList);
                        message = 'Data is send to voting engine, Please refresh the page after few minutes.';
                    }else{
                        message = 'Voting decision cannot be set, if eligible for voting decision is not checked.'; 
                    }
                }
                
            }
            if(!listInsolToUpdate.isEmpty()){
                update listInsolToUpdate;
            }
        }catch(Exception e){
            system.debug('exception is::'+e.getMessage());
        }
    }  
}