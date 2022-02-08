trigger OrderTrigger on Order (before insert, after insert, after update) {
    
    // Before logic
     if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Check if order can be created
            OrderTriggerHandler.checkPreventCreation(Trigger.new);
        }
    }
    
    // After logic
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            // Transfer Items from Opp to Order
            OrderTriggerHandler.populateLineItems(Trigger.new);
             OrderTriggerHandler.activateOrder(Trigger.newMap);
        }
        if(Trigger.isUpdate) {
            // Order is activated so close Opp
            OrderTriggerHandler.updateRelatedOpportunity(Trigger.new);
        }
    }
}