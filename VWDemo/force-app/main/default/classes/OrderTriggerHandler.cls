public without sharing class OrderTriggerHandler {
    
    public static void populateLineItems(List<Order> orderList) {
        // List to insert
        List<OrderItem> orderLineItemList = new List<OrderItem>();
        
        // Opportunity Id set
        Set<Id> opportunityIdSet = new Set<Id>();
        
        // for each order that is activated
        for(Order auxOppLine : orderList) {
            opportunityIdSet.add(auxOppLine.OpportunityId); 
        }
        
        // If any Opportunity
        if(!opportunityIdSet.isEmpty()) {
            List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
            opportunityListToUpdate = [Select Id, StageName, (Select Id, UnitPrice, Quantity, Product2Id, PricebookEntryId, Has_subscription__c, Subscription_Percentage__c from OpportunityLineItems) from Opportunity where Id IN: opportunityIdSet];
                     
            // Creation if Order item for item Line Item on Opportunity
            for(Order auxOrder : orderList) {
                for(Opportunity auxOpp : opportunityListToUpdate) {
                    if(auxOpp.OpportunityLineItems.size() > 0) {
                        for(OpportunityLineItem auxLineItem: auxOpp.OpportunityLineItems) {
                            
                            // Each Order item
                            OrderItem currentItem = new OrderItem();
                            currentItem.OrderId = auxOrder.Id;
                            currentItem.UnitPrice = auxLineItem.UnitPrice;
                            currentItem.Quantity = auxLineItem.Quantity;
                            currentItem.Product2Id = auxLineItem.Product2Id;
                            currentItem.PricebookEntryId = auxLineItem.PricebookEntryId;
                            currentItem.Has_subscription__c = auxLineItem.Has_subscription__c;
                            currentItem.Subscription_Percentage__c = auxLineItem.Subscription_Percentage__c;
                            orderLineItemList.add(currentItem);
                        }  
                    }
                }
            }
            
            // Insert Order Items
            if(!orderLineItemList.isEmpty()) {       
                try{
                    insert orderLineItemList;
                }
                catch(Exception e) {
                    system.debug('OrderTriggerHandler populateLineItems' + e.getMessage());
                }
            }
        }
    }
    
    public static void checkPreventCreation(List<Order> orderList) {
        // Opportunity Id set
        Set<Id> opportunityIdSet = new Set<Id>();
        
        // for each order that is activated
        for(Order auxOppLine : orderList) {
            opportunityIdSet.add(auxOppLine.OpportunityId); 
        }
        
        // If any Opportunity
        if(!opportunityIdSet.isEmpty()) {
            List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
            opportunityListToUpdate = [Select Id, StageName, (Select Id from OpportunityLineItems), (Select Id, OrderNumber from Orders) from Opportunity where Id IN: opportunityIdSet];
            
            // prevent creation if Opportunity has no products or if it has any other order
            for(Opportunity auxOpp : opportunityListToUpdate) {
                if(auxOpp.OpportunityLineItems.size() == 0) {
                    for(Order aux: orderList) {
                        if(aux.OpportunityId == auxOpp.Id) {
                            aux.addError(System.Label.AddProductsToOpp); 
                        }
                    }  
                }
                if(auxOpp.Orders.size() > 0) { 
                    for(Order aux: orderList) {
                        if(aux.OpportunityId == auxOpp.Id) {
                            aux.addError(System.Label.AlreadyAssociatedOrder + auxOpp.Orders.get(0).OrderNumber); 
                        }
                    }  
                }
            }  
        }
    }
    
    public static void updateRelatedOpportunity(List<Order> orderList) {
        // Opportunity Id set
        Set<Id> opportunityIdSet = new Set<Id>();
        
        // for each order that is activated
        for(Order auxOppLine : orderList) {
            if(auxOppLine.Status == System.Label.OrderActivated) {
                opportunityIdSet.add(auxOppLine.OpportunityId);
            } 
        }
        
        // If any Opportunity
        if(!opportunityIdSet.isEmpty()) {
            List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
            opportunityListToUpdate = [Select Id, StageName from Opportunity where Id IN: opportunityIdSet AND StageName !=: System.Label.OpportunityClosedWon];
            
            // update Opportunity
            for(Opportunity auxOpp : opportunityListToUpdate) {
                auxOpp.StageName = System.Label.OpportunityClosedWon;
            }
            
            if(!opportunityListToUpdate.isEmpty()) {
                try{
                    update opportunityListToUpdate;
                }
                catch(Exception e) {
                    system.debug('OrderTriggerHandler updateRelatedOpportunity' + e.getMessage());
                }
            }
        }
    }
    
}