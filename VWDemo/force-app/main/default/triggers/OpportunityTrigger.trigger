trigger OpportunityTrigger on Opportunity (after update) {
    
    // After Logic
    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            OpportunityTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}