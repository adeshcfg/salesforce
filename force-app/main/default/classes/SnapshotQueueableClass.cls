public class SnapshotQueueableClass implements Queueable, Database.AllowsCallouts{
    private List<Id> prodIds = new List<Id>();
    private Id placementId;
    private string finalStr;
    private String PRODUCT_SNAPSHOT = 'Product Snapshot';
      public string csvString = '';
    
    Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();
    
    public SnapshotQueueableClass(List<Id> productIds, Id agencyId) {
        placementId = agencyId;
        system.debug('productIds::'+productIds);
        prodIds = productIds; 
    }
    
    public void execute(QueueableContext context) {
       
          Datetime myDate = Datetime.now();
            String curreTime = myDate.format('HHmmss');
            string currentDate = Datetime.now().format('yyMMdd');
            String DocumentStorageId = 'DS_ACC'+currentDate+curreTime;
        if(!Test.isRunningTest()) {
            //Call snapshot API.Developer name - satyajit.for ticket 4307
            SnapShotAPIToPortal.parse(DocumentStorageId,prodIds);
            //system.debug('parsedResponse in controller: '+parsedResponse);
            
        }
    }

}