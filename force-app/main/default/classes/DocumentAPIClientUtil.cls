/**************************************************************************************************
*
*  Class:   
*
*  @description : This class is utility class for DocumentAPIClient class
*  @author : A5E Consulting
*  @date : 07/12/2021   
*
*************************************************************************************************/
public with sharing class DocumentAPIClientUtil{
    //This inner class will be used for the request JSON
    public class WebServiceResponseJSONObject{
        Public String id{get;set;}
        Public String docId{get;set;}
        Public String docUrl{get;set;}
        public WebServiceResponseJSONObject parse(String json) {
            System.debug('##json '+json);
            json = json.replace('$', '');
            System.debug('##json '+json);
            return (WebServiceResponseJSONObject) System.JSON.deserialize(json, WebServiceResponseJSONObject.class);
        }
    }
    //This inner class will be store parsed response
    public class ParsedResponse{
        public String docId{get;set;}
        public String DocUrl{get;set;}
        public String request{get;set;}
        public String response{get;set;}
    } //Added by Rajesh 4134
    public class ReverseProxyAPI
     {
	public boolean isSuccess{get;set;}
	public String returnMessage{get;set;}
	public ReverseProxyAPIData data{get;set;}	
	public Integer statusCode{get;set;}	
    public String request{get;set;}
    public String response{get;set;}
}   //Added by Rajesh 4134
    public class ReverseProxyAPIData {		
		public String id{get;set;}
		public boolean success{get;set;}		
	}
}