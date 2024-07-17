public class AgencySnapshotController {
    public String agencyID { get; set; }
    public boolean SUCCESS_MSG { get; set; }
    public Placement__c agencyRecord { get; set; }

    public AgencySnapshotController(ApexPages.StandardController stdController) {
        agencyID = ApexPages.currentPage().getParameters().get('id');
    }

    public PageReference agencySnapshotData() {
        SUCCESS_MSG = true;
        List<Product__c> product = [
            SELECT ID, Name, Collection_Agency__c, RecordTypeId, Collection_Agency_Placement__c
            FROM Product__c
            WHERE Collection_Agency_Placement__c = :agencyID
        ];
        getSnapshortRecords(product);
        return null;
    }

    public static void getSnapshortRecords(List<Product__c> prodNew) {
        System.enqueueJob(new SnapshotQueueableClass(prodNew));
    }

    public pageReference redirectToAgency() {
        PageReference pageRef = new PageReference('/' + agencyID);
        pageRef.setRedirect(true);
        return pageRef;
    }
}
