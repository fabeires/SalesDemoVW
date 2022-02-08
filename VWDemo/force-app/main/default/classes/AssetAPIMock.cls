@isTest
public class AssetAPIMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader(System.Label.ContentTypeHeader, System.Label.ContentTypeJson);
        response.setBody(System.Label.AssetAPIMockData);
        response.setStatusCode(200);
        return response;
    }
}