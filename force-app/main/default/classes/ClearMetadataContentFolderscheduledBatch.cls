global class ClearMetadataContentFolderscheduledBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      ClearMetadataContentFolderBatch cmb = new ClearMetadataContentFolderBatch(); 
      Database.executeBatch(cmb);
   }
}