public class BuybackSellerExportController {
    public String documentID {get;set;}
    public String blobContents {get;set;}
    public String contentType {get;set;}
    public list<Product__c> listProducts {get;set;} 
    public list<Id> listProd; 
    public Map<Id, Decimal> totalPaymentsMap;      
    public String ERROR_MSG {get;set;}
    public boolean DisableExportBtn{get;set;}
    public list<Document_Storage__c> listDocStorage {get;set;}
    String headerCSV ;
    
    public BuybackSellerExportController (ApexPages.StandardController stdController){
        listProducts = [Select id,Name,Originating_Creditor__c,Purchase_Date__c,Customer__c, Customer__r.Name,First_Name__c,Last_Name__c,
                        Previous_Secondary_Account_Number__c,Previous_Primary_Account_Number__c,Product_Type__c,Charged_Off_Date__c,
                        Charged_Off_Amount__c,Purchase_Price__c,Putback_Buyback_Amount__c,Putback_Reason__c, Purchase_Status__c,
                        Purchase_Face_Value__c
                        from Product__c Where Purchase_Status__c = 'Buyback Initiated' 
                       OR Purchase_Status__c = 'Putback Initiated'];
            
        if(listProducts.isEmpty()){
            ERROR_MSG = '&nbsp;&nbsp;No Eligible Product Records to Export';
            DisableExportBtn = true;
        }

        listDocStorage =  [Select id,Name,Media_Request__c,File_Processing_Date__c,
                          Document_Type__c,Creator__c,Document_Id__c,Document_URL__c
                         from Document_Storage__c Where BuyBack_Request__c = TRUE ORDER BY Name DESC LIMIT 8];
    }
    
    public  PageReference getDocumentInfo(){
        DocumentDetails docDetails = DocumentAPIClient.getDocumentInfo(documentId);
        system.debug('docDetails: '+docDetails);
        if(docDetails.document != NULL){
            blobContents = EncodingUtil.base64Encode(docDetails.document);
            contentType = docDetails.contentType;
        }
        else{
            blobContents ='';
        }
        system.debug('docDetails.fileString: '+docDetails.fileString); 
        return null;  
    }
   
    public  PageReference createCSV(){
       headerCSV = 'Seller'+',' 
            + 'Purchase Date' +','                
            + 'Name' +','
            + 'Last Name' +',' 
            + 'First Name' +',' 
            + 'Account Number' +',' 
            + 'Secondary Account number' +',' 
            + 'Product Type' +','
            + 'Charge Off Date' +',' 
            + 'Charge Off Amount' +',' 
            + 'Total Amount of Payments Received' +',' 
            + 'Purchase Price' +','            
            + 'Purchased Amount' +','            
            + 'BuyBack/PutBack Amount' +',' 
            + 'BuyBack/Putback Reason' +',' 
            + 'Note' +','
            + '\n';
        list<Id> stringList = new list<Id>();
        for(Product__c prodList : listProducts){
           stringList.add(formatString(prodList.id)); 
        }
        decimal amount = 0;
        List<Product_Payments__c> prodpay = [SELECT Payment_Amount__c, CCS_Account__c,Payment_Type__c FROM Product_Payments__c WHERE CCS_Account__c IN: stringList AND Payment_Type__c = '1000'];
        
        for(Product_Payments__c pp: prodpay ){
            amount += pp.Payment_Amount__c;
        }
        system.debug('amount check**'+amount);
        for(Product__c prodObj : listProducts){
            system.debug('prodObj'+prodObj.Id);
            String strSeller = formatString(prodObj.Originating_Creditor__c);
            String purchaseDate = convertDateToString(prodObj.Purchase_Date__c);
            String Name = prodObj.Customer__c != null ? formatString(prodObj.Customer__r.Name): '';
            String lastName = formatString(prodObj.Last_Name__c);
            String firstName = formatString(prodObj.First_Name__c);
            String accountNo = formatString(prodObj.Previous_Primary_Account_Number__c);
            String secondoryAccountNo = formatString(prodObj.Previous_Secondary_Account_Number__c);
            String productType = formatString(prodObj.Product_Type__c);
            String chargeOffDate = convertDateToString(prodObj.Charged_Off_Date__c);
            String chargeOffAmount = prodObj.Charged_Off_Amount__c != null ? String.valueOf(prodObj.Charged_Off_Amount__c) : '';
            String totalAmountOfPaymentsReceived = (amount != null ? String.valueOf(amount): '0');
            String purchasePrice = prodObj.Purchase_Price__c != null ? String.valueOf(prodObj.Purchase_Price__c +'%') : '';
            String purchasedAmount = prodObj.Purchase_Face_Value__c != null ? String.valueOf(prodObj.Purchase_Face_Value__c) : '';
            String buyBackAmount = prodObj.Putback_Buyback_Amount__c != null ? String.valueOf('$'+prodObj.Putback_Buyback_Amount__c) : '';
            String putbackReason = formatString(prodObj.Putback_Reason__c);
            
            String mediaRqstCSV = checkComma(strSeller)+',' 
                                + checkComma(purchaseDate)+',' 
                                + checkComma(Name) +','
                                + checkComma(lastName) +',' 
                                + checkComma(firstName) +','
                                + checkComma(accountNo) +','
                                + checkComma(secondoryAccountNo) +','
                                + checkComma(productType) +','
                                + checkComma(chargeOffDate) +','
                                + checkComma(chargeOffAmount) +',' 
                                + checkComma(totalAmountOfPaymentsReceived) +','
                                + checkComma(purchasePrice) +','
                                + checkComma(purchasedAmount) +',' 
                                + checkComma(buyBackAmount) +','
                                + checkComma(putbackReason) +','
                                + '' + '\n'; 
            
              if(String.isNotBlank(mediaRqstCSV)){
                headerCSV += mediaRqstCSV;
              } 
        }
        system.debug('headerCSV***' +headerCSV);
        postDocumentAPI(headerCSV);
        return null;
    }   
    
    public void postDocumentAPI(String cSV){
        Map<String,Object> rawObj;       
        DocumentAPIClientUtil.ParsedResponse parsedResponse = new DocumentAPIClientUtil.ParsedResponse();
        system.debug('123');
        Blob fileBlob;
        
        if(Test.isRunningTest()) {
        	fileBlob = Blob.valueOf('test');
        }else{
            fileBlob = Blob.valueOf(cSV);
        }
        
        if(!Test.isRunningTest()) {
        	parsedResponse = DocumentAPIClient.postDocument(fileBlob, 'Buyback/Putback Initiated file Exported.csv', 'Task');
        }else{
            parsedResponse.DocUrl = 'Test';
            parsedResponse.docId = 'Test';
        }    
        system.debug('parsedResponse in controller: '+parsedResponse);
        //rawObj = (Map<String,Object>) JSON.deserializeUntyped(parsedResponse.response); 
        
        //Create  CSV Document Storage Record
        Document_Storage__c  DocStorage = new Document_Storage__c();
        if(null != parsedResponse 
           && String.isnotBlank(parsedResponse.docId)){
            DocStorage.Document_Name__c = 'Buyback/Putback Initiated Export Document.csv';
            DocStorage.Document_Extension__c = 'csv';
            //DocStorage.Document_ID__c = String.valueOf(rawObj.get('docId'));
            DocStorage.Document_ID__c = parsedResponse.docId;
            DocStorage.Document_Type__C = 'Buyback/Putback Initiated File';
            //DocStorage.Document_URL__c = String.valueOf(rawObj.get('docUrl'));
            DocStorage.Document_URL__c = parsedResponse.DocUrl;
            DocStorage.Uploaded_By__c = 'Internal User';
            DocStorage.Creator__c = UserInfo.getName();
            DocStorage.Document_Related_To__c = 'Buyback/Putback Initiated';
            DocStorage.BuyBack_Request__c = TRUE;
            DocStorage.File_Processed_By__c = UserInfo.getName();
            DocStorage.File_Processing_Date__c = Date.today();
            insert DocStorage;
            system.debug('DocStorage: '+DocStorage);
        }
        
        List<Product__c> listProductUpdate = New List<Product__c>();
        for(Product__c updateProduct : listProducts){
            if(updateProduct.Purchase_Status__c == 'Buyback Initiated'){
                updateProduct.Purchase_Status__c = 'Buyback Requested';
            }
            if(updateProduct.Purchase_Status__c == 'Putback Initiated'){
                updateProduct.Purchase_Status__c = 'Putback Requested';
            }
            
            listProductUpdate.add(updateProduct);
        }
        
        update listProductUpdate;
        ERROR_MSG = '&nbsp;&nbsp;Buyback/Putback Requested Records Exported Successfully';
        DisableExportBtn = true;
        listDocStorage = [Select id,Name,BuyBack_Request__c,File_Processing_Date__c,
                          Document_Type__c,Creator__c,Document_Id__c,Document_URL__c
                         from Document_Storage__c Where BuyBack_Request__c = TRUE ORDER BY Name DESC LIMIT 8];
    }
    
    
     //Convert Date to String
    @testvisible
    private static String convertDateToString(DateTime dt){
        if(dt != null){
            return (dt.formatGMT('MM/dd/yyyy'));
        }
        else{
            return '';
        }
    }
    
    @testvisible
    private static String checkComma(String str){
        if(String.isNotBlank(str) && str.contains(',')){
                return +' \"'+str+'\" ';
        }
        else{
            return str;
        }
    }

    @testvisible
    private static String formatString(String str){
        return String.isNotBlank(str) ? str : '';
    }
}