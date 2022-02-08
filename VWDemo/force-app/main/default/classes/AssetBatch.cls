public class AssetBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    // List passed to batch
    public List <Asset> assetList = new List<Asset>();
    public AssetBatch(List<Asset> assetList){
        this.assetList = assetList;
    }
    
    public List<Asset> start(Database.BatchableContext BC){
        return assetList;
    }
    
    public void execute(Database.BatchableContext BC, List<Asset> scope){
        Set<id> currentAssetIds = new Set<Id>();
        for(Asset auxAsset : scope) {
            currentAssetIds.add(auxAsset.Id);
        }
        
        // query assets in scope for non read only version
        List<Asset> assetListToUpdate= [Select Id, Vehicle_number__c, Manufacturer__c, Model_Range__c from Asset where ID IN:currentAssetIds];
        
        for(Asset auxAsset : assetListToUpdate) {
            // Call API
            String responseBody = WebserviceUtils.sendRequest();
            
            if(responseBody != null) {
                //Parse result
                AssetWrapper currentWrapperObject = new AssetWrapper();
                currentWrapperObject = (AssetWrapper)JSON.deserialize(responseBody, AssetWrapper.class);
                              
                // Set new fields to enrich Asset data
                auxAsset.Vehicle_number__c = currentWrapperObject.vehicleNum;
                auxAsset.Manufacturer__c = currentWrapperObject.manufacturer;
                auxAsset.Model_Range__c = currentWrapperObject.modelRange;
            }    
        }
        
        try{
            update assetListToUpdate;
        }
        catch(exception e) {
            system.debug('AssetBatch' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}