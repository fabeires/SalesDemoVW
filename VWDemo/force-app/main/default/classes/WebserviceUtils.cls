public class WebserviceUtils {
    
    public static String sendGetRequest(Map<String, String> requestHeaders, String endpoint) {
        
        // HTTp parameters
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody;
        
        // Build Request
        try{
            request.setMethod('GET');
            request.setEndpoint(endpoint);
            
            if(!requestHeaders.isEmpty()) {
                for(String auxString : requestHeaders.keySet()) {
                    request.setHeader(auxString, requestHeaders.get(auxString));
                }
            }
            
            // Send request
            response = http.send(request);
            
            // Get response
            if(response != null && response.getStatusCode() == 200) {
                responseBody = response.getBody();
            }  
        }
        catch(Exception e) {
            system.debug('WebserviceUtils ' + e.getMessage());
        }
        return responseBody;
    }
    
}