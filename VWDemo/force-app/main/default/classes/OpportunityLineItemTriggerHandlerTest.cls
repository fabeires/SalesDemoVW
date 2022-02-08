@isTest
public class OpportunityLineItemTriggerHandlerTest {
    
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
        
        // Create Opportunity
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.AccountId = testAccount.Id;
        testOpportunity.Pricebook2Id = Test.getStandardPricebookId();
        testOpportunity.Name= 'testOpp';
        testOpportunity.StageName = System.Label.OpportunityOpen;
        testOpportunity.CloseDate = system.today();
        insert testOpportunity;
    }
    
    @isTest
    public static void shouldAdjustUnitPrice() {
        // Build Opp line item
        OpportunityLineItem testLineItem = new OpportunityLineItem();
        testLineItem.OpportunityId = [Select id from Opportunity limit 1].Id;
        testLineItem.Product2Id = [Select id from Product2 limit 1].Id;
        testLineItem.Has_subscription__c = true;
        testLineItem.Subscription_Percentage__c = '10';
        testLineItem.UnitPrice = 10;
        testLineItem.Quantity = 1;
        testLineItem.PricebookEntryId = [Select id from PricebookEntry limit 1].Id;
        
        // insert line item so it goes through the trigger
        Test.startTest();
        
        insert testLineItem;
        
        Test.stopTest();
        
        // Query to get the new value after trigger function
        OpportunityLineItem testLineItemAfterSave = [Select UnitPrice from OpportunityLineItem limit 1];
        
        // If all goes well percentage of 10% should be added to the unit price 
        System.assertEquals(11, testLineItemAfterSave.UnitPrice);
    }
    
    @isTest
    public static void shouldSetSubscriptionToZero() {
        // Build Opp line item
        OpportunityLineItem testLineItem = new OpportunityLineItem();
        testLineItem.OpportunityId = [Select id from Opportunity limit 1].Id;
        testLineItem.Product2Id = [Select id from Product2 limit 1].Id;
        testLineItem.Has_subscription__c = false;
        testLineItem.Subscription_Percentage__c = '10';
        testLineItem.UnitPrice = 10;
        testLineItem.Quantity = 1;
        testLineItem.PricebookEntryId = [Select id from PricebookEntry limit 1].Id;
        
        // insert line item so it goes through the trigger
        Test.startTest();
        
        insert testLineItem;
        
        Test.stopTest();
        
        // Query to get the new value after trigger function
        OpportunityLineItem testLineItemAfterSave = [Select UnitPrice,Subscription_Percentage__c from OpportunityLineItem limit 1];
        
        // If all goes well no percentage should be added to the unit price 
        System.assertEquals(10, testLineItemAfterSave.UnitPrice);
        System.assertEquals('0', testLineItemAfterSave.Subscription_Percentage__c);
    }
    
    @isTest
    public static void shouldAdjustUnitPriceOnUpdate() {
        // Build Opp line item
        OpportunityLineItem testLineItem = new OpportunityLineItem();
        testLineItem.OpportunityId = [Select id from Opportunity limit 1].Id;
        testLineItem.Product2Id = [Select id from Product2 limit 1].Id;
        testLineItem.Has_subscription__c = true;
        testLineItem.Subscription_Percentage__c = '10';
        testLineItem.UnitPrice = 10;
        testLineItem.Quantity = 1;
        testLineItem.PricebookEntryId = [Select id from PricebookEntry limit 1].Id;
        insert testLineItem;
        
        // update line item so it goes through the trigger
        Test.startTest();
        
        testLineItem.Subscription_Percentage__c = '20';
        update testLineItem;
        
        Test.stopTest();
        
        // Query to get the new value after trigger function
        OpportunityLineItem testLineItemAfterSave = [Select UnitPrice,Subscription_Percentage__c from OpportunityLineItem limit 1];
        
        // If all goes well percentage of 20% should be added to the unit price
        System.assertEquals(12, testLineItemAfterSave.UnitPrice);
    }
}