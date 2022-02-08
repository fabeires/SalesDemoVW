@isTest
global class AssetAPIMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
       
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"vin": "WMAH05ZZZ4B011671","vehicleNum": "MAN-DIGI-007"}');
        response.setStatusCode(200);
        
        return response;
    }
}