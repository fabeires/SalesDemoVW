global class WebserviceUtils {
    
    global static String sendRequest() {
        
        // Custom setting data
        AssetEnrichmentParameters__c customSettingData = new AssetEnrichmentParameters__c();
        customSettingData = getAPIParameters();
        
        // HTTp parameters
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        String responseBody;
        
        // Build Request
        try{
            request.setMethod('GET');
            request.setEndpoint(customSettingData.Endpoint__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Client-secret', customSettingData.Client_Secret__c);
            request.setHeader('Client-id', customSettingData.Client_Id__c);
            request.setHeader('correlation-id', customSettingData.Correlation_Id__c);
            response = http.send(request);
            
            // Get response
            if(response != null && response.getStatusCode() == 200) {
                responseBody = response.getBody();
            }  
        }
        catch(Exception e) {
            system.debug('AssetBatch ' + e.getMessage());
        }
        
        return responseBody;
    }
    
    public static AssetEnrichmentParameters__c getAPIParameters() {
        AssetEnrichmentParameters__c customSettingData = new AssetEnrichmentParameters__c();
        customSettingData = AssetEnrichmentParameters__c.getOrgDefaults();
        return customSettingData;
    }
}