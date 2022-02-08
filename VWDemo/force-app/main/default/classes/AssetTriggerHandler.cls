public without sharing class AssetTriggerHandler {
    
    public static void handleAfterInsert(List<Asset> assetList) {    
        // Call batch. One Record at a time because API is not bulkified
        AssetBatch batchContext = new AssetBatch(assetList);
        Database.executeBatch(batchContext, 1);
    }
}