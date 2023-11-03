public with sharing class CTB_FileAutomationAdesh {
    public static void processFile() {
        Folder documents = [SELECT Id, Name FROM Folder WHERE Name = 'Metadata_Content' LIMIT 1];
        String fileToDownloadID = DocumentApiClient.createDocumentFromAzure(documents.Id, 'account@9f9247e8-6796-4d86-914c-c88d5570d23a_csv');
        Document fileToProccess = [SELECT Id, Body FROM Document WHERE Id = :fileToDownloadID];
        String csvContents = fileToProccess.Body.toString();
        List<String> csvRows = csvContents.split('\n');
        // CSVIterator iterator = new CSVIterator(csvContents, '\n');
        // List<String> csvStringList = csvContents.split('\n');
        // Add every row of CSV except the first header row into an array
        /* while (iterator.hasNext()) {
            String row = iterator.next().trim();
            System.debug(row);
        } */
        // Read the CSV file row by row, starting from the second row (index 1)
        for (Integer i = 1; i < csvRows.size() - 1; i++) {
            // Split the current row into columns
            // List<String> csvColumns = csvRows[i].split(',');
            System.debug(csvRows[i]);
        }
    }
}
// CTB_FileAutomationAdesh.processFile();