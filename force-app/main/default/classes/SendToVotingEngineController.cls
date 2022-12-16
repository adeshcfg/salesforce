public class SendToVotingEngineController {
    
    public string message{get;set;}
    
    public SendToVotingEngineController(ApexPages.StandardController stdController) {
        
        
    }
    //This inner method resubmit the voting engine automation - insolvency voting engine
    public void mypageloadingmethod(){

        List<Id> votingAutomationList = new List<Id>();
        string InsolId = ApexPages.CurrentPage().getParameters().get('Id');
        votingAutomationList.add(InsolId);
        
        try{
            
            List<Insolvency__c> Insol = [select id, name, Eligible_For_Voting_Decision__c from insolvency__c where id =: InsolId];
            system.debug('ID is' +Insol);
            
            for(Insolvency__c insolNew : Insol){
                if(insolNew.Eligible_For_Voting_Decision__c == true){
                    VotingEngineFutureCall.votingAutomationCall(votingAutomationList);
                    message = 'Data is send to voting engine, Please refresh the page after few minutes.';
                }else{
                    
                    message = 'Voting decision cannot be set, if eligible for voting decision is not checked.';
                    
                }
            }
            
        }catch(Exception e){           
        }
    }  
}