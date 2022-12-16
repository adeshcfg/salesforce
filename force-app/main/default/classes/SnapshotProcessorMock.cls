/*
----------------------------------------------------------------------------
|  Class: SnapshotProcessorMock
|
|  Filename: SnapshotProcessorMock.cls
|
|  Author: A5E
|
|  Description:
|     Mock class for responding to callout made from Test class for creating and sending product snapshot
|
| Change Log:
| 2022-06-15
----------------------------------------------------------------------------
*/
global class SnapshotProcessorMock implements HttpCalloutMock {

    HttpResponse[] responses = new HttpResponse[0];
    public void addResponse(HttpResponse response) {
        responses.add(response);
    }

    public HttpResponse respond(HttpRequest request) {
        return responses.remove(0);
    }
    
    @Testvisible final String ACCESS_TOKEN = '{"token_type":"testToken", "access_token":"UHSDHSJNNMQZXNKLASO", "expires_in":"60"}';
    @Testvisible final String CREATE_SNAPSHOT_SUCCESS = 
                                                    '{'+
                                                        '"id": "hdhfhuru2323sdsda",'+
                                                        '"docId": "hdhfhuru2323sdsda",'+
                                                        '"docUrl": "hdhfhuru2323sdsda"'+
                                                    '}';
    @Testvisible final String CREATE_CUSTOMER_FAILED = 
                                                    '{'+
                                                        
                                                    '}';
}