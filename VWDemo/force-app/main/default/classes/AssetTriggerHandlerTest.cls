@isTest
public class AssetTriggerHandlerTest {
    
    // Test setup
    @testSetup 
    public static void setup() {
        
        // Create pricebook
        Pricebook2 standardPricebook = new Pricebook2();
        standardPricebook.Id =Test.getStandardPricebookId();
        standardPricebook.IsActive = true;
        
        // Create product
        Product2 testProduct = new Product2();
        testProduct.Name = 'TestProduct';
        testProduct.Allows_subscription__c = true;
        insert testProduct;
        
        // Create pricebook entry
        PricebookEntry testEntry = new PricebookEntry();
        testEntry.Product2Id = testProduct.Id;
        testEntry.Pricebook2Id = Test.getStandardPricebookId();
        testEntry.UnitPrice = 10;
        testEntry.IsActive = true;
        insert testEntry;
        
        // Create Account
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        insert testAccount;
        
        // Custom Setting
        AssetEnrichmentParameters__c customSettingData = new AssetEnrichmentParameters__c();
        customSettingData.Endpoint__c = 'https://eu1.anypoint.mulesoft.com/mocking/api/v1/links/267cf127-5cc9-499d-bb5c-fe2d447aa99d/JOINTHEDIGITALHUB/WMAH05ZZZ4B011671';
        customSettingData.Client_Id__c = 'b903e91e6c6542a3a4a6e800f37f95ea';
        customSettingData.Client_Secret__c = '4d73e495F84E4c47B8a8E37C8F8B96b3';
        customSettingData.Correlation_Id__c = '267cf127-5cc9-499d-bb5c-fe2d447aa99d';
        insert customSettingData;
    }
    
    @isTest
    public static void shouldCallAPI() {
        // Set mock
        Test.setMock(HttpCalloutMock.class, new AssetAPIMock());
        
        // Build Asset
        Asset testAsset = new Asset();
        testAsset.Product2Id = [Select id from Product2 limit 1].Id;
        testAsset.AccountId = [Select id from Account limit 1].Id;
        testAsset.Name = 'testAsset';
    
        // insert asset so it goes through the trigger and batch
        Test.startTest();
        
        insert testAsset;
        
        Test.stopTest();
        
        // Query to get the new value after trigger function
        Asset testAssetAfterSave = [Select Id, Vehicle_number__c from Asset limit 1];
        
        // If all goes well percentage of 10% should be added to the unit price 
        System.assert(testAssetAfterSave.Vehicle_number__c != null);
    }
    
}