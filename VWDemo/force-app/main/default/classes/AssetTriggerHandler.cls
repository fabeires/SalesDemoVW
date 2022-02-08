public without sharing class AssetTriggerHandler {
    
    public static void handleAfterInsert(List<Asset> assetList) {    
        // Call batch for API data enrichment
        AssetBatch batchContext = new AssetBatch(assetList);
        Database.executeBatch(batchContext, 1);
    }
}