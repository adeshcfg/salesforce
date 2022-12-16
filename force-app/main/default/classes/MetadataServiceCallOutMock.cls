global with sharing class MetadataServiceCallOutMock implements WebServiceMock{
 public void doInvoke(
        Object stub, Object request, Map<String, Object> response,
        String endpoint, String soapAction, String requestName,
        String responseNS, String responseName, String responseType) 
    {
  if(request instanceof MetadataService.readMetadata_element){
    response.put('response_x', new MetadataService.readMetadata_element());
  }
        return;
    }
}