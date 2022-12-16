Public class MetaDataActivation implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        MetadataSwitchJob.activateProductMetadata();
    }
}