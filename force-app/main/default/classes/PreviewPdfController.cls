/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is to preview document
*  @author : A5E Consulting
*  @date : 07/12/2021  
*
*************************************************************************************************/
public class PreviewPdfController{  
    public String dcoumentId {get;set;}
    public Blob pdfBlob;
    
    //constructor
    public PreviewPdfController(){
         dcoumentId = System.currentPageReference().getParameters().get('documentId');
         system.debug('dcoumentId in preview :'+dcoumentId);
         pdfBlob = DocumentAPIClient.getDocument(dcoumentId);
    }
	@TestVisible
    public string getString{
        get{
        string s;
        s = EncodingUtil.Base64Encode(pdfBlob); 
        return s;
        }
    }
    @TestVisible
    public String pdf {
        get {
             return EncodingUtil.Base64Encode(pdfBlob);
        }
    }
}