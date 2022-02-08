public class AssetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    // List passed to batch
    public List <Asset> assetList = new List<Asset>();
    public AssetBatch(List<Asset> assetList){
        this.assetList = assetList;
    }
    
    // Start
    public List<Asset> start(Database.BatchableContext BC){
        return assetList;
    }
    
    // Execute
    public void execute(Database.BatchableContext BC, List<Asset> scope){
        Set<id> currentAssetIds = new Set<Id>();
        for(Asset auxAsset : scope) {
            currentAssetIds.add(auxAsset.Id);
        }
        
        // query assets in scope for non read only version
        List<Asset> assetListToUpdate= [Select Id, Vehicle_number__c, Manufacturer__c, Model_Range__c from Asset where ID IN:currentAssetIds];
        
        for(Asset auxAsset : assetListToUpdate) {
            // Call API
            String responseBody = WebserviceUtils.sendGetRequest(buildApiParameters(), AssetUtils.getAssetAPIParameters()?.Endpoint__c);
            
            if(responseBody != null) {
                //Parse result
                AssetWrapper currentWrapperObject = new AssetWrapper();
                currentWrapperObject = (AssetWrapper)JSON.deserialize(responseBody, AssetWrapper.class);
                
                // Set new fields to update Asset data
                auxAsset.Vehicle_number__c = currentWrapperObject.vehicleNum;
                auxAsset.Manufacturer__c = currentWrapperObject.manufacturer;
                auxAsset.Model_Range__c = currentWrapperObject.modelRange;
            }    
        }
        
        // Update Asset records
        try{
            update assetListToUpdate;
        }
        catch(exception e) {
            system.debug('AssetBatch' + e.getMessage());
        }
    }
    
    // Finish
    public void finish(Database.BatchableContext BC){
    }
    
    // get all necessary data for API call
    public static Map<String, String> buildApiParameters() {
        Map<String, String> apiParametersMap = new Map<String, String>();
        AssetEnrichmentParameters__c customSettingData = AssetUtils.getAssetAPIParameters();
        
        apiParametersMap.put(System.Label.ContentTypeHeader, System.Label.ContentTypeJson);
        apiParametersMap.put(System.Label.ClientSecretHeader, customSettingData.Client_Secret__c);
        apiParametersMap.put(System.Label.ClientIdHeader, customSettingData.Client_Id__c);
        apiParametersMap.put(System.Label.CorrelationIdHeader, customSettingData.Correlation_Id__c);
        return apiParametersMap;
    }
}