trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update) {
	
    // Before Logic
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            // Set Unit price based on subscription on Insert
            OpportunityLineItemTriggerHandler.adjustLineItem(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            // Set Unit price based on subscription on Update
            OpportunityLineItemTriggerHandler.adjustLineItemOnUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}