public class SnapshotQueueableClass implements Queueable, Database.AllowsCallouts {
    private List<Product__c> productList = new List<Product__c>();

    Agency_Portal_Settings__c config = Agency_Portal_Settings__c.getOrgDefaults();

    public SnapshotQueueableClass(List<Product__c> productList) {
        this.productList = productList;
    }

    public void execute(QueueableContext context) {
        Datetime myDate = Datetime.now();
        String curreTime = myDate.format('HHmmss');
        string currentDate = Datetime.now().format('yyMMdd');
        String documentStorageId = 'DS_ACC' + currentDate + curreTime;
        List<String> productIds = new List<String>();
        for (Product__c prod : productList) {
            productIds.add(prod.Id);
        }
        if (!productIds.isEmpty() && !Test.isRunningTest()) {
            SnapShotAPIToPortal.parse(documentStorageId, productIds);
        }
    }
}
