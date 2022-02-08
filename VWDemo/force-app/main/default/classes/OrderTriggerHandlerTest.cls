@isTest
public class OrderTriggerHandlerTest {
    
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
        
        // Build Opp line item
        OpportunityLineItem testLineItem = new OpportunityLineItem();
        testLineItem.OpportunityId = testOpportunity.Id;
        testLineItem.Product2Id = testProduct.Id;
        testLineItem.Has_subscription__c = true;
        testLineItem.Subscription_Percentage__c = '10';
        testLineItem.UnitPrice = 10;
        testLineItem.Quantity = 1;
        testLineItem.PricebookEntryId = testEntry.Id;
        insert testLineItem;
        
    }
    
    @isTest
    public static void shouldAddOrderItems() {
        
        // Create Order
        Order testOrder = new Order();
        testOrder.AccountId = [Select id from Account limit 1].Id;
        testOrder.OpportunityId = [Select id from Opportunity limit 1].Id;
        testOrder.Status = System.Label.OrderDraft;
        testOrder.EffectiveDate = System.today();
        testOrder.Pricebook2Id = Test.getStandardPricebookId();
        Test.startTest();
        
        insert testOrder;
        
        Test.stopTest();
        
        // Query to get the new value after trigger function
        List<OrderItem> testOrderItems = [Select Id, Order.Pricebook2Id from OrderItem];
        
        // If all goes well there should now be an order item
        System.assertEquals(1, testOrderItems.size());
        
        // Check if pricebook Id is set from Opportunity
        System.assertEquals(Test.getStandardPricebookId(), testOrderItems.get(0).Order.Pricebook2Id);
    }
 
}