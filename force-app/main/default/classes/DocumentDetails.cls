public class DocumentDetails {
        @AuraEnabled
        public Blob document {set;get;}
         @AuraEnabled
        public String contentType {set;get;}
         @AuraEnabled
        public String fileString {set;get;}
        
}