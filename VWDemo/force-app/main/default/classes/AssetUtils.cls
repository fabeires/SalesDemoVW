public class AssetUtils {
    
    // Get Asset API custom setting org defaults for API authentication
    public static AssetEnrichmentParameters__c getAssetAPIParameters() {
        AssetEnrichmentParameters__c customSettingData = new AssetEnrichmentParameters__c();
        customSettingData = AssetEnrichmentParameters__c.getOrgDefaults();
        return customSettingData;
    }
}